# Core Directory Files

Demonstrates directory listing and file browsing using raylib's file system functions and raygui's list view widget.

## Build and Run

```bash
cd examples && moon build --target native raylib_core_directory_files/
cd examples && ./_build/native/debug/build/raylib_core_directory_files/raylib_core_directory_files.exe
```

## Controls

- **< Button**: Navigate to parent directory
- **List View**: Scroll and select files

## Key Concepts

- `load_directory_files` / `load_directory_files_ex` for listing directory contents with optional file extension filters.
- `get_working_directory` / `get_prev_directory_path` for directory navigation.
- `file_path_list_count` / `file_path_list_get` for accessing file path list items.
- raygui `gui_list_view_ex` for scrollable file lists.
