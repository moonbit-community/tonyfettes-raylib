# Raylib Minesweeper

A native Android Minesweeper game written in [MoonBit](https://www.moonbitlang.com/) with [Raylib](https://www.raylib.com/) for graphics.

## Features

- **Three difficulty levels**: Easy (12x8, 10 mines), Medium (20x12, 40 mines), Hard (30x16, 99 mines)
- **Touch controls**: Tap to reveal, long-press to flag, pinch to zoom, pan to scroll
- **Camera system**: Smooth pinch-to-zoom and pan for navigating large boards
- **Safe first click**: Mines are never placed adjacent to your first tap
- **Flood-fill reveal**: Tapping a zero-neighbor cell automatically reveals surrounding cells

## Screenshots

<!-- TODO: Add screenshots -->

## Build

### Prerequisites

- Android SDK (API 26+)
- Android NDK
- [MoonBit](https://www.moonbitlang.com/) compiler (`moon` on PATH)
- CMake 3.22.1+

### Build & Run

```bash
# Build debug APK
./gradlew assembleDebug

# Install and run on connected device/emulator
./gradlew installDebug
adb shell am start -n com.example.raylibminesweeper/.MainActivity
```

### MoonBit Type-Check Only

```bash
cd app/src/main/moonbit && moon check --target native
```

## Architecture

The game logic, rendering, and input handling are entirely in MoonBit (~950 lines), compiled to C via `moon build`, then linked with Raylib and the Android NDK into a native shared library.

```
Android (MainActivity.kt)
  └─ Native library (libraylibminesweeper.so)
       ├─ MoonBit game code (app/src/main/moonbit/main.mbt)
       ├─ Raylib FFI bindings (app/src/main/moonbit/external/raylib/)
       └─ Raylib 5.5 (vendored C sources)
```

## License

[Apache License 2.0](LICENSE)
