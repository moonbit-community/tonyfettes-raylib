# Audio Sound Loading

Demonstrates loading and playing sound effects from WAV and OGG files.

## Build and Run

```bash
cd examples && moon build --target native raylib_audio_sound_loading/
cd examples && ./_build/native/debug/build/raylib_audio_sound_loading/raylib_audio_sound_loading.exe
```

## Controls

- **Space**: Play WAV sound
- **Enter**: Play OGG sound

## Key Concepts

- **`load_sound`**: Loads an entire audio file into memory for instant playback (unlike streamed music).
- **Format support**: Demonstrates loading both WAV and OGG formats.
- **`play_sound`**: Triggers immediate playback of a loaded sound buffer.
