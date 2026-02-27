# Contributing

## Prerequisites

- [MoonBit toolchain](https://www.moonbitlang.com/download/) installed
- Native target support (macOS, Linux, or Windows)

## Building

This module is a **library**, not an executable. Running `moon build` without
arguments will fail with a linker error (missing `_main`). Use one of the
following commands instead:

```bash
# Type-check without building
moon check --target native

# Build a specific example
moon -C examples build --target native raylib_demo/

# Run a specific example
moon -C examples run --target native raylib_tank_1990/

# Run tests
moon test --target native
```

The `examples/` directory is a separate module, so `-C examples` is required to
set the working directory.

## Conventions

- Use conventional commits (e.g., `feat:`, `fix:`, `refactor:`)
- See [CLAUDE.md](CLAUDE.md) for architecture details, FFI rules, and coding patterns
