# raylib_core_storage_values

Demonstrates saving and loading integer values to/from a binary file (`storage.data`) using raylib's file I/O functions. Values are serialized as little-endian 32-bit integers.

## Build and Run

```bash
cd examples && moon build --target native raylib_core_storage_values/
cd examples && ./_build/native/debug/build/raylib_core_storage_values/raylib_core_storage_values.exe
```

## Controls

- **R**: Generate random score and hi-score values
- **Enter**: Save current values to `storage.data`
- **Space**: Load previously saved values from `storage.data`

## Key Concepts

- Manual byte-level serialization of integers to a binary file
- Using `load_file_data` and `save_file_data` for raw file I/O
- Persistent storage pattern: values survive across application restarts
