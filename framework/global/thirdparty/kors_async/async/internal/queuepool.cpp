/*
MIT License

Copyright (c) Igor Korsukov

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#include <algorithm>
#include <chrono>

#include "../conf.h"
#include "queuepool.h"

namespace kors::async {
QueuePool* QueuePool::instance()
{
    static QueuePool p;
    return &p;
}

QueuePool::QueuePool()
    : m_threads{conf::MAX_THREADS, nullptr}
{
}

QueuePool::~QueuePool()
{
    for (ThreadData* thdata : m_threads) {
        if (thdata) {
            thdata->ports.clear();
            delete thdata;
        }
    }
}

QueuePool::ThreadData* QueuePool::threadData(const std::thread::id& threadId, bool create)
{
    //! NOTE The calling thread and the thread in the argument can be different,
    // so we find data for a given thread,
    // but we can work with it concurrently from different threads!!

    //! Guard against access during shutdown. Callers (regPort, processMessages)
    //! check conf::terminated before calling, but static destruction order means
    //! threadData() can still be reached from other threads after terminate().
    if (conf::terminated.load()) {
        return nullptr;
    }

    ThreadData* result = nullptr;

    //! Lock the entire lookup + create path. The vector itself is never
    //! resized (fixed at MAX_THREADS), but under MSVC Debug
    //! (_ITERATOR_DEBUG_LEVEL=2) concurrent element writes
    //! (m_threads[count] = thdata) invalidate the vector proxy, making
    //! concurrent reads of m_threads.size() or m_threads.at(i) crash.
    //! The lock is held only for the lookup/allocation, not for the
    //! caller's subsequent thdata->mutex lock (avoids the deadlock that
    //! commit f923d41 was addressing — all callers acquire thdata->mutex
    //! only after threadData() returns, i.e. after m_mutex is released).
    std::scoped_lock lock(m_mutex);

    size_t count = m_count.load();
    assert(count <= m_threads.size());
    for (size_t i = 0; i < count; ++i) {
        ThreadData* thdata = m_threads.at(i);
        // found a slot for the given thread
        if (thdata->threadId == threadId) {
            result = thdata;
            break;
        }
    }

    if (!result && create) {
        // We didn't find ThreadData, let's use the next empty slot if there are any left.
        count = m_count.load();
        if (count < m_threads.size()) {
            ThreadData* thdata = new ThreadData();
            thdata->threadId = threadId;
            m_threads[count] = thdata;
            ++m_count;
            result = thdata;
        } else {
            // There are no empty slots, let's try
            // found a slot that has no ports (all ports are unregistered)
            for (size_t i = 0; i < m_threads.size(); ++i) {
                ThreadData* thdata = m_threads.at(i);
                if (!thdata) {
                    continue;
                }

                std::scoped_lock innerLock(thdata->mutex);
                if (!thdata->ports.empty()) {
                    continue;
                }

                // Reuse the existing ThreadData if it has no ports
                thdata->threadId = threadId;
                result = thdata;
                break;
            }

            if (!result) {
                // No free slots found, the thread pool is exhausted
                assert(false && "thread pool exhausted");
            }
        }
    }

    return result;
}

void QueuePool::regPort(const std::thread::id& th, const std::shared_ptr<Port>& port)
{
    assert(port);
    if (!port) {
        return;
    }

    // the queue is no longer functioning
    if (conf::terminated) {
        return;
    }

    ThreadData* thdata = nullptr;
    int iteration = 0;
    while (iteration < 100) {
        ++iteration;
        thdata = threadData(th, true);
        if (thdata) {
            break;
        }
        // trying to get ThreadData again
        std::this_thread::sleep_for(std::chrono::milliseconds(1));
    }

    if (!thdata) {
        return;
    }

    std::scoped_lock lock(thdata->mutex);
    thdata->ports.push_back(port);
}

void QueuePool::unregPort(const std::thread::id& th, const std::shared_ptr<Port>& port)
{
    assert(port);
    if (!port) {
        return;
    }

    ThreadData* thdata = threadData(th, false);
    if (!thdata) {
        return;
    }

    std::scoped_lock lock(thdata->mutex);
    auto& ports = thdata->ports;
    ports.erase(std::remove(ports.begin(), ports.end(), port), ports.end());
}

void QueuePool::processMessages()
{
    std::thread::id threadId = std::this_thread::get_id();
    processMessages(threadId);
}

void QueuePool::processMessages(const std::thread::id& th)
{
    ThreadData* thdata = threadData(th, false);
    if (!thdata) {
        return;
    }

    std::unique_lock lock(thdata->mutex, std::defer_lock);
    // try lock
    if (!lock.try_lock()) {
        // if we couldn't lock it, we just skip it
        return;
    }

    for (size_t i = 0; i < thdata->ports.size(); ++i) {
        std::shared_ptr<Port>& port = thdata->ports.at(i);
        port->process();
    }
}
} // kors::async
