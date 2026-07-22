# Audio Sound Multi

Demonstrates playing the same sound effect multiple times simultaneously using sound aliases that share a single audio buffer.

## Build and Run

```bash
cd examples && moon build --target native raylib_audio_sound_multi/
cd examples && ./_build/native/debug/build/raylib_audio_sound_multi/raylib_audio_sound_multi.exe
```

## Controls

- **Space**: Play the sound (can be pressed rapidly for overlapping playback)

## Key Concepts

- **`load_sound_alias`**: Creates a lightweight alias of an existing sound that shares the same sample data but can play independently.
- **Polyphony**: 10 sound slots cycle in round-robin fashion, allowing up to 10 overlapping instances of the same effect.
- **`unload_sound_alias` vs `unload_sound`**: Aliases are unloaded separately; only the original source sound frees the audio data.
