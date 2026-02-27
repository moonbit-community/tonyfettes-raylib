# Audio Stream Effects

Demonstrates attaching and detaching real-time audio processing effects (low-pass filter and delay) to a music stream.

## Build and Run

```bash
cd examples && moon build --target native raylib_audio_stream_effects/
cd examples && ./_build/native/debug/build/raylib_audio_stream_effects/raylib_audio_stream_effects.exe
```

## Controls

- **Space**: Restart music
- **P**: Pause / resume music
- **F**: Toggle low-pass filter (LPF) effect
- **D**: Toggle delay (echo) effect

## Key Concepts

- **`attach_music_stream_processor`**: Registers a per-stream audio callback that processes samples before output.
- **`detach_music_stream_processor`**: Removes a previously attached processor, restoring clean audio.
- **LPF implementation**: A simple one-pole low-pass filter applied per stereo sample using a cutoff coefficient.
- **Delay implementation**: A circular buffer storing 1 second of stereo audio, mixed at 50% with the live signal to create an echo.
