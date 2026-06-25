if (MSVC OR APPLE)
    if (APPLE)
        # Only disable NEON extension for Apple ARM builds, leave it enabled for Raspberry PI.
        set(_disable_neon_extension "-DPNG_ARM_NEON:STRING=off")
    else ()
        set(_disable_neon_extension "")
    endif ()

    set(_patch_cmd PATCH_COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt.patched CMakeLists.txt)

    if (APPLE)
        set(_patch_cmd ${_patch_cmd} && ${PATCH_CMD} ${CMAKE_CURRENT_LIST_DIR}/PNG.patch)
    endif ()

    add_cmake_project(PNG
        URL https://github.com/glennrp/libpng/archive/refs/tags/v1.6.58.zip
        URL_HASH SHA256=ad8fc23d75a76f352989bbec9e905bdfe8f2d2e77b32e4f2070a4bb1849802ee
        PATCH_COMMAND "${_patch_cmd}"
        CMAKE_ARGS
            -DPNG_SHARED=OFF
            -DPNG_STATIC=ON
            -DPNG_PREFIX=prusaslicer_
            -DPNG_TESTS=OFF
            -DPNG_EXECUTABLES=OFF
            ${_disable_neon_extension}
    )

    set(DEP_PNG_DEPENDS ZLIB)
endif()
