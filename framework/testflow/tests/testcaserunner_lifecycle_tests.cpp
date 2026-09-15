/*
 * SPDX-License-Identifier: GPL-3.0-only
 * MuseScore-CLA-applies
 *
 * MuseScore Studio
 * Music Composition & Notation
 *
 * Copyright (C) 2026 MuseScore Limited and others
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

#include <gtest/gtest.h>

#include <QEventLoop>
#include <QMetaObject>
#include <QTimer>

#include "../internal/testcaserunner.h"

using namespace muse::testflow;

TEST(TestCaseRunnerLifecycle, CompletionBeforeExecSkipsEventLoop)
{
    std::atomic_bool finished = true;

    EXPECT_FALSE(detail::shouldEnterEventLoop(0, 1, finished));
}

TEST(TestCaseRunnerLifecycle, CompletionAfterExecQuitsThroughQueuedInvocation)
{
    std::atomic_bool finished = false;
    QEventLoop loop;

    QTimer::singleShot(0, &loop, [&]() {
        finished.store(true, std::memory_order_release);
        EXPECT_FALSE(detail::shouldEnterEventLoop(0, 1, finished));
        QMetaObject::invokeMethod(&loop, &QEventLoop::quit, Qt::QueuedConnection);
    });

    ASSERT_TRUE(detail::shouldEnterEventLoop(0, 1, finished));
    loop.exec();

    EXPECT_TRUE(finished.load(std::memory_order_acquire));
}
