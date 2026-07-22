# Core Random Sequence

Demonstrates `load_random_sequence` for generating shuffled integer sequences, visualized as a bar chart of colored rectangles that can be shuffled interactively.

## Build and Run

```bash
cd examples && moon build --target native raylib_core_random_sequence/
cd examples && ./_build/native/debug/build/raylib_core_random_sequence/raylib_core_random_sequence.exe
```

## Controls

- **Space**: Shuffle the current sequence
- **Up**: Add a rectangle and regenerate the sequence
- **Down**: Remove a rectangle and regenerate the sequence

## Key Concepts

- `load_random_sequence` for generating a shuffled permutation of integers.
- Mapping sequence values to rectangle heights for visualization.
- Shuffle operation by swapping elements according to a random permutation.
- Dynamic resizing of the bar chart with keyboard input.
