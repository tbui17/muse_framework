
function(asiosdk_Populate remote_url local_path os arch build_type)

    if(os STREQUAL "source")

            set(name "ASIO-SDK_2.3.4_2025-10-15.zip")

            if (NOT EXISTS ${local_path}/${name})
                message(STATUS "[asiosdk] Populate: ${remote_url} to ${local_path} ${os} ${arch} ${build_type}")
                file(DOWNLOAD ${remote_url}/${name} ${local_path}/${name})
                file(ARCHIVE_EXTRACT INPUT ${local_path}/${name} DESTINATION ${local_path})
            endif()

    else()
        message(FATAL_ERROR "[asiosdk] Not supported os: ${os}")
    endif()

endfunction()

