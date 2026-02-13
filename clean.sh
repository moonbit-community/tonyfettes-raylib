#!/bin/bash
set -euo pipefail

echo "Cleaning generated raylib files..."

# Remove raylib source files copied to root
rm -f rcore.c utils.c rshapes.c rtextures.c rtext.c rmodels.c raudio.c

# Remove GLFW source files copied to root
rm -f glfw_init.c glfw_platform.c glfw_context.c glfw_monitor.c glfw_window.c glfw_input.c glfw_vulkan.c
rm -f glfw_posix_module.c glfw_posix_thread.c glfw_posix_poll.c
rm -f glfw_cocoa_init.m glfw_cocoa_joystick.m glfw_cocoa_monitor.m glfw_cocoa_window.m glfw_cocoa_time.c glfw_nsgl_context.m
rm -f glfw_egl_context.c glfw_osmesa_context.c

# Remove downloaded raylib source tree
rm -rf external/

echo "Clean complete!"
