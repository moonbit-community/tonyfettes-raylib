# Audio Mixed Processor

Demonstrates raylib's audio mixed processor API by applying a real-time exponentiation effect to the combined audio output, with a visual volume history display.

## Build and Run

```bash
cd examples && moon build --target native raylib_audio_mixed_processor/
cd examples && ./_build/native/debug/build/raylib_audio_mixed_processor/raylib_audio_mixed_processor.exe
```

## Controls

- **Left/Right Arrows**: Decrease/increase distortion exponent (0.5 to 3.0)
- **Space**: Play a coin sound effect

## Key Concepts

- **`attach_audio_mixed_processor`**: Registers a callback that processes all mixed audio output before it reaches the speakers.
- **Per-sample processing**: The callback iterates over stereo frames, applying `pow(abs(sample), exponent)` to distort the waveform.
- **Volume visualization**: A rolling 400-sample average volume history is rendered as a bar chart, updated each audio callback.
