# Test Report

## Commands

`xvfb-run moon test --target native`

`moon test --target native`

## Relevant output

```text
/usr/bin/bash: line 1: xvfb-run: command not found
```

```text
fatal error: X11/Xcursor/Xcursor.h: No such file or directory
fatal error: X11/extensions/Xrandr.h: No such file or directory
```

## Analysis

The Linux CI test command requires `xvfb-run`, which is not installed in this
environment. Running the underlying native MoonBit test command directly then
fails while compiling bundled GLFW/raylib C sources because X11 development
headers are missing. This is an unavailable system dependency issue, not a
MoonBit source failure from this promotion.
