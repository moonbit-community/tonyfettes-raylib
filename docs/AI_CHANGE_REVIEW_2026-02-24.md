# AI Change Review (2026-02-24)

## Scope

Reviewed staged AI-generated edits in:

- `internal/raylib/platforms/rcore_desktop_glfw.c`
- `internal/raylib/stub_window.c`

This note documents likely intent, what improved, and why parts are risky.

## Likely intent behind the GLFW changes

### 1) Prefer recovery over fail-fast when monitor detection is unreliable

Evidence:

- Previous behavior (HEAD) aborted window init when monitor lookup failed.
- New behavior logs a warning and falls back to `glfwGetPrimaryMonitor()`.
- If that still fails, it keeps going instead of returning `-1`.

Most likely motivation: avoid startup failures on environments where monitor APIs are flaky (remote sessions, unusual compositor/WM states, edge desktop backends).

### 2) Avoid null monitor dereference later in centering

Evidence:

- Added `if (monitor) { ... glfwGetMonitorWorkarea(...) ... } else { glfwGetWindowPos(...) }` in centering path.

Most likely motivation: once monitor lookup became non-fatal, the code needed a safe path when no monitor handle exists.

### 3) Harden monitor index bounds

Evidence:

- Changed from `if (monitorIndex < monitorCount)` to `if ((monitorIndex >= 0) && (monitorIndex < monitorCount))`.

Most likely motivation: prevent negative index reads (`monitors[-1]`) when `GetCurrentMonitor()` reports failure.

## Why the GLFW change is risky

### [High] Zero-dimension state can escape fallback and continue initialization

Location:

- `internal/raylib/platforms/rcore_desktop_glfw.c:1536-1540`
- `internal/raylib/platforms/rcore_desktop_glfw.c:1589`

Problem:

- When both monitor discovery and primary-monitor fallback fail, code copies `CORE.Window.screen` into `CORE.Window.display`.
- For `InitWindow(0, 0, ...)` (windowed-fullscreen request), `CORE.Window.screen` can still be `0x0`.
- Init continues, then high-DPI scale math divides by `CORE.Window.screen.width/height`.

Impact:

- Division by zero or invalid scale matrix path.
- Inconsistent render/fbo state with zero sizes.
- Regression from prior behavior that failed fast.

### [Medium] Behavior contract changed from deterministic failure to partial initialization

Location:

- `internal/raylib/platforms/rcore_desktop_glfw.c:1522-1541`

Problem:

- Earlier code returned `-1` immediately when monitor could not be resolved.
- New code continues with degraded assumptions.

Impact:

- Failures move from startup to downstream rendering/input math.
- Harder to debug because warning is non-fatal and error manifests later.

### [Low] Windowed-fullscreen fallback may not reach intended monitor-sized window when monitor is absent

Location:

- `internal/raylib/platforms/rcore_desktop_glfw.c:1500-1506`
- `internal/raylib/platforms/rcore_desktop_glfw.c:1533-1541`

Problem:

- Creation starts at `1x1` for zero requests.
- If no monitor is found, no monitor-based resize occurs.

Impact:

- Runtime window can start in a tiny/inconsistent size while internal screen/display state may be zero.

## Likely intent behind `stub_window.c` changes

### 1) Fix incorrect string ABI use between MoonBit bytes and C strings

Evidence:

- Added helper to copy bytes and append `\0`.
- Replaced direct casts for window/title/log/url/screenshot/clipboard calls.

Most likely motivation: `moonbit_bytes_t` is a byte slice, not guaranteed NUL-terminated. Direct cast to `const char *` is unsafe for C string APIs.

## Why `stub_window.c` changes are risky (and what is good)

### Good

- Correctness improves for APIs requiring C strings.
- Prevents over-read/UB when byte arrays are not NUL-terminated.

### [Low] New allocation path does not check OOM

Location:

- `internal/raylib/stub_window.c:7-11`

Problem:

- `libc_malloc` result is used without null check.

Impact:

- On allocation failure, code would dereference null.
- Low practical risk, but still a correctness gap.

### [Low] Fix is local, string-cast pattern still exists in many other stubs

Problem:

- Similar direct `(const char *)` casts remain in other `stub_*.c` files.

Impact:

- Inconsistency and potential hidden bugs remain outside `stub_window.c`.

## Practical takeaway

The AI seems to have optimized for robustness against monitor-discovery failures and for safer MoonBit-to-C string passing. Those are reasonable goals. The main regression is that the new GLFW fallback allows invalid zero dimensions to survive, which can break later size-dependent math.

A safe follow-up is to keep the non-fatal fallback only if dimensions are normalized before continuing (or return `-1` when they cannot be made valid).
