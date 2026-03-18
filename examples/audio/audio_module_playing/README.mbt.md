# Audio Module Playing

Demonstrates streaming playback of a tracker module (.xm) file with pitch control and animated circle visualizations synced to the music.

## Build and Run

```bash
cd examples && moon build --target native raylib_audio_module_playing/
cd examples && ./_build/native/debug/build/raylib_audio_module_playing/raylib_audio_module_playing.exe
```

## Controls

- **Space**: Restart music from the beginning
- **P**: Pause / resume music
- **Up/Down Arrows**: Increase / decrease playback pitch

## Key Concepts

- **`load_music_stream`**: Streams a tracker module file (`.xm` format) with automatic buffering.
- **`set_music_pitch`**: Dynamically adjusts playback speed/pitch in real time.
- **Animated visualization**: 64 colored circles fade and pulse while music plays, creating a visual effect tied to the playback state.
- **Progress bar**: Shows normalized playback position using `get_music_time_played` / `get_music_time_length`.
