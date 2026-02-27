# Audio Music Stream

Demonstrates basic music streaming playback from an MP3 file with pause/resume and a progress bar.

## Build and Run

```bash
cd examples && moon build --target native raylib_audio_music_stream/
cd examples && ./_build/native/debug/build/raylib_audio_music_stream/raylib_audio_music_stream.exe
```

## Controls

- **Space**: Restart music from the beginning
- **P**: Pause / resume music

## Key Concepts

- **`load_music_stream`**: Opens an MP3 file for streamed playback (no full decode into memory).
- **`update_music_stream`**: Must be called every frame to feed audio data to the output buffer.
- **Playback progress**: Uses `get_music_time_played` and `get_music_time_length` to compute a normalized progress bar.
