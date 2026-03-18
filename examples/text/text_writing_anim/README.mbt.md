# raylib_text_writing_anim

Demonstrates a typewriter-style text writing animation effect by progressively revealing characters over time.

## Build and Run

```bash
cd examples && moon build --target native raylib_text_writing_anim/
cd examples && ./_build/native/debug/build/raylib_text_writing_anim/raylib_text_writing_anim.exe
```

## Controls

- **Space (hold)**: Speed up the writing animation (8x speed)
- **Enter**: Reset the animation from the beginning

## Key Concepts

- Uses a frame counter divided by 10 to control character reveal rate
- Implements `text_subtext` to extract a substring of the message up to the current position
- Supports multiline text with newline characters in the animation
- Simple but effective approach to creating dialogue/story text effects
