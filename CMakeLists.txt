cmake_minimum_required(VERSION 3.22.1)
project(raylib_moonbit C)

set(RAYLIB_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/internal/raylib)

# ---- Platform detection ----
if(ANDROID)
    set(_RL_PLATFORM ANDROID)
elseif(EMSCRIPTEN)
    set(_RL_PLATFORM WEB)
elseif(APPLE OR UNIX OR WIN32)
    set(_RL_PLATFORM DESKTOP_GLFW)
else()
    message(FATAL_ERROR "raylib_moonbit: unsupported platform")
endif()
message(STATUS "raylib_moonbit: platform=${_RL_PLATFORM}")

# ---- raylib static library ----
# rcore.c #includes the platform file via preprocessor; rglfw.c is desktop-only.
set(_RL_SRCS
    ${RAYLIB_SRC_DIR}/utils.c
    ${RAYLIB_SRC_DIR}/rcore.c
    ${RAYLIB_SRC_DIR}/rshapes.c
    ${RAYLIB_SRC_DIR}/rtextures.c
    ${RAYLIB_SRC_DIR}/rtext.c
    ${RAYLIB_SRC_DIR}/rmodels.c
    ${RAYLIB_SRC_DIR}/raudio.c
)
if(_RL_PLATFORM STREQUAL "DESKTOP_GLFW")
    list(APPEND _RL_SRCS ${RAYLIB_SRC_DIR}/rglfw.c)
endif()

add_library(raylib STATIC ${_RL_SRCS})
target_include_directories(raylib PUBLIC
    ${RAYLIB_SRC_DIR}
    ${RAYLIB_SRC_DIR}/external/glfw/include
)

if(_RL_PLATFORM STREQUAL "ANDROID")
    target_compile_definitions(raylib PUBLIC
        PLATFORM_ANDROID GRAPHICS_API_OPENGL_ES2 _DEFAULT_SOURCE)
    target_include_directories(raylib PRIVATE
        ${ANDROID_NDK}/sources/android/native_app_glue)
    target_link_libraries(raylib PUBLIC android log EGL GLESv2 OpenSLES atomic m)
elseif(_RL_PLATFORM STREQUAL "WEB")
    target_compile_definitions(raylib PUBLIC PLATFORM_WEB GRAPHICS_API_OPENGL_ES2)
    # string.h force-include: raylib web sources and MoonBit generated C rely on
    # string.h symbols without always including it explicitly.
    target_compile_options(raylib PUBLIC -include string.h)
    # Only -sUSE_GLFW=3 belongs at the library level (raylib's own cmake does the
    # same). All other emcc flags (-sASYNCIFY, -sFORCE_FILESYSTEM, -sEXPORTED_*,
    # -O2, --closure, etc.) are application-level concerns and belong in the
    # consuming project's CMakeLists.txt.
    target_link_options(raylib PUBLIC -sUSE_GLFW=3)
else()
    target_compile_definitions(raylib PUBLIC PLATFORM_DESKTOP_GLFW)
    if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
        target_compile_definitions(raylib PRIVATE _GLFW_X11)
        target_link_libraries(raylib PUBLIC GL m pthread dl rt X11)
    elseif(APPLE)
        # rglfw.c #includes Cocoa .m files; compile that TU as Objective-C only.
        set_source_files_properties(${RAYLIB_SRC_DIR}/rglfw.c
            PROPERTIES COMPILE_FLAGS "-x objective-c")
        target_link_libraries(raylib PUBLIC
            "-framework OpenGL" "-framework Cocoa" "-framework IOKit"
            "-framework CoreAudio" "-framework CoreVideo"
            "-framework AudioToolbox" "-framework CoreFoundation")
    elseif(WIN32)
        target_link_libraries(raylib PUBLIC opengl32 gdi32 winmm user32 shell32)
    endif()
endif()

set_target_properties(raylib PROPERTIES C_STANDARD 99 C_STANDARD_REQUIRED ON)
target_compile_options(raylib PRIVATE
    -Wno-unused-value
    $<$<STREQUAL:${_RL_PLATFORM},ANDROID>:-ffunction-sections -fdata-sections>)

# ---- MOON_HOME resolution (required for raylib_moonbit stubs) ----
if(NOT DEFINED MOON_HOME)
    if(DEFINED ENV{MOON_HOME})
        set(MOON_HOME "$ENV{MOON_HOME}")
    else()
        find_program(_MOON_EXE moon)
        if(_MOON_EXE)
            get_filename_component(_MOON_BIN "${_MOON_EXE}" DIRECTORY)
            set(MOON_HOME "${_MOON_BIN}/..")
        else()
            set(MOON_HOME "$ENV{HOME}/.moon")
        endif()
    endif()
endif()
if(NOT EXISTS "${MOON_HOME}/include/moonbit.h")
    message(FATAL_ERROR
        "moonbit.h not found at ${MOON_HOME}/include. "
        "Export MOON_HOME or pass -DMOON_HOME=<path>.")
endif()
set(RAYLIB_MOONBIT_MOON_HOME "${MOON_HOME}"
    CACHE INTERNAL "Resolved MoonBit installation root")
message(STATUS "raylib_moonbit: MOON_HOME=${MOON_HOME}")

# ---- raylib_moonbit: stubs compiled against moonbit.h + raylib ----
# PUBLIC includes propagate MOON_HOME/include and RAYLIB_SRC_DIR to consumers,
# so they get moonbit.h and raylib.h / stub_internal.h transitively.
add_library(raylib_moonbit STATIC
    ${RAYLIB_SRC_DIR}/stub_window.c
    ${RAYLIB_SRC_DIR}/stub_input.c
    ${RAYLIB_SRC_DIR}/stub_drawing.c
    ${RAYLIB_SRC_DIR}/stub_camera.c
    ${RAYLIB_SRC_DIR}/stub_color.c
    ${RAYLIB_SRC_DIR}/stub_shapes.c
    ${RAYLIB_SRC_DIR}/stub_textures.c
    ${RAYLIB_SRC_DIR}/stub_text.c
    ${RAYLIB_SRC_DIR}/stub_models.c
    ${RAYLIB_SRC_DIR}/stub_audio.c
    ${RAYLIB_SRC_DIR}/stub_image_processing.c
    ${RAYLIB_SRC_DIR}/stub_image_drawing.c
    ${RAYLIB_SRC_DIR}/stub_filesystem.c
    ${RAYLIB_SRC_DIR}/stub_utils.c
    ${RAYLIB_SRC_DIR}/stub_automation.c
)
target_include_directories(raylib_moonbit PUBLIC
    ${RAYLIB_SRC_DIR}
    ${MOON_HOME}/include
)
set_target_properties(raylib_moonbit PROPERTIES C_STANDARD 99 C_STANDARD_REQUIRED ON)
target_compile_options(raylib_moonbit PRIVATE
    -Wno-unused-value
    $<$<STREQUAL:${_RL_PLATFORM},ANDROID>:-ffunction-sections -fdata-sections>)
target_link_libraries(raylib_moonbit PUBLIC raylib)
