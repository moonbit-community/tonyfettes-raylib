# Core Drop Files

Demonstrates drag-and-drop file handling. Drop files onto the window and their paths are displayed in a list.

## Build and Run

```bash
cd examples && moon build --target native raylib_core_drop_files/
cd examples && ./_build/native/debug/build/raylib_core_drop_files/raylib_core_drop_files.exe
```

## Controls

- **Drag and drop**: Drop files from your file manager onto the window

## Key Concepts

- `is_file_dropped` to detect file drop events each frame.
- `load_dropped_files` / `unload_dropped_files` for accessing dropped file paths.
- `file_path_list_count` / `file_path_list_get` to iterate over dropped files.
- Accumulative file list that grows as more files are dropped.
