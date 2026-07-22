# Audio Raw Stream

Demonstrates real-time audio synthesis by generating sine waves and streaming raw PCM samples to an audio output, with mouse-controlled frequency and stereo panning.

## Build and Run

```bash
cd examples && moon build --target native raylib_audio_raw_stream/
cd examples && ./_build/native/debug/build/raylib_audio_raw_stream/raylib_audio_raw_stream.exe
```

## Controls

- **Mouse (hold left button)**: Y-axis controls sine wave frequency, X-axis controls stereo pan

## Key Concepts

- **`load_audio_stream`**: Creates a raw audio stream (44100 Hz, 16-bit, mono) for manual sample feeding.
- **`update_audio_stream`**: Pushes a buffer of synthesized PCM samples each frame when the stream needs more data.
- **`is_audio_stream_processed`**: Polls whether the stream buffer is ready for a refill (polling approach).
- **Real-time synthesis**: Generates a sine waveform on the fly, recalculating samples when frequency changes.
- **Waveform visualization**: Draws the current sample buffer as a pixel-level waveform across the screen.
