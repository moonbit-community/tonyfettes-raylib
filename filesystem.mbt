///|
struct FilePathList(@ffi.FilePathList)

// Re-export passthrough functions from internal FFI layer

pub using @ffi {is_file_dropped}

///|
/// Load dropped filepaths.
#as_free_fn(load_dropped_files)
pub fn FilePathList::load_dropped() -> FilePathList {
  @ffi.load_dropped_files()
}

///|
/// Get the number of filepaths in the list.
#as_free_fn(file_path_list_count)
pub fn FilePathList::count(self : FilePathList) -> Int {
  @ffi.file_path_list_count(self.0)
}

///|
/// Unload dropped filepaths.
pub fn unload_dropped_files(files : FilePathList) -> Unit {
  @ffi.unload_dropped_files(files.0)
}

///|
/// Unload filepaths loaded with `load_directory_files`.
pub fn unload_directory_files(files : FilePathList) -> Unit {
  @ffi.unload_directory_files(files.0)
}

// ============================================================================
// File system: Queries (wrappers)
// ============================================================================

///|
/// Check if file exists.
pub fn file_exists(file_name : String) -> Bool {
  @ffi.file_exists(@utf8.encode(file_name))
}

///|
/// Check if a directory path exists.
pub fn directory_exists(dir_path : String) -> Bool {
  @ffi.directory_exists(@utf8.encode(dir_path))
}

///|
/// Check file extension (including point: .png, .wav).
pub fn is_file_extension(file_name : String, ext : String) -> Bool {
  @ffi.is_file_extension(@utf8.encode(file_name), @utf8.encode(ext))
}

///|
/// Get file length in bytes.
pub fn get_file_length(file_name : String) -> Int {
  @ffi.get_file_length(@utf8.encode(file_name))
}

///|
/// Get pointer to extension for a filename string (includes dot: '.png').
pub fn get_file_extension(file_name : String) -> String {
  @utf8.decode_lossy(@ffi.get_file_extension(@utf8.encode(file_name)))
}

///|
/// Get filename for a path string.
pub fn get_file_name(file_path : String) -> String {
  @utf8.decode_lossy(@ffi.get_file_name(@utf8.encode(file_path)))
}

///|
/// Get filename string without extension.
pub fn get_file_name_without_ext(file_path : String) -> String {
  @utf8.decode_lossy(@ffi.get_file_name_without_ext(@utf8.encode(file_path)))
}

///|
/// Get full path for a given fileName with path.
pub fn get_directory_path(file_path : String) -> String {
  @utf8.decode_lossy(@ffi.get_directory_path(@utf8.encode(file_path)))
}

///|
/// Get previous directory path for a given path.
pub fn get_prev_directory_path(dir_path : String) -> String {
  @utf8.decode_lossy(@ffi.get_prev_directory_path(@utf8.encode(dir_path)))
}

///|
/// Get current working directory.
pub fn get_working_directory() -> String {
  @utf8.decode_lossy(@ffi.get_working_directory())
}

///|
/// Get the directory of the running application.
pub fn get_application_directory() -> String {
  @utf8.decode_lossy(@ffi.get_application_directory())
}

///|
/// Create directories (including full path requested), returns 0 on success.
pub fn make_directory(dir_path : String) -> Int {
  @ffi.make_directory(@utf8.encode(dir_path))
}

///|
/// Change working directory, return true on success.
pub fn change_directory(dir : String) -> Bool {
  @ffi.change_directory(@utf8.encode(dir))
}

///|
/// Check if a given path is a file or a directory.
pub fn is_path_file(path : String) -> Bool {
  @ffi.is_path_file(@utf8.encode(path))
}

///|
/// Check if fileName is valid for the platform/OS.
pub fn is_file_name_valid(file_name : String) -> Bool {
  @ffi.is_file_name_valid(@utf8.encode(file_name))
}

// ============================================================================
// File system: Data load/save (wrappers)
// ============================================================================

///|
/// Load file data as byte array (read).
pub fn load_file_data(file_name : String) -> Bytes {
  @ffi.load_file_data(@utf8.encode(file_name))
}

///|
/// Save data to file from byte array (write), returns true on success.
pub fn save_file_data(
  file_name : String,
  data : Bytes,
  data_size : Int,
) -> Bool {
  @ffi.save_file_data(@utf8.encode(file_name), data, data_size)
}

///|
/// Load text data from file (read).
pub fn load_file_text(file_name : String) -> String {
  @utf8.decode_lossy(@ffi.load_file_text(@utf8.encode(file_name)))
}

///|
/// Save text data to file (write), returns true on success.
pub fn save_file_text(file_name : String, text : String) -> Bool {
  @ffi.save_file_text(@utf8.encode(file_name), @utf8.encode(text))
}

///|
/// Export data to code (.h), returns true on success.
pub fn export_data_as_code(
  data : Bytes,
  data_size : Int,
  file_name : String,
) -> Bool {
  @ffi.export_data_as_code(data, data_size, @utf8.encode(file_name))
}

// ============================================================================
// File system: Directory listing (wrappers)
// ============================================================================

///|
/// Load directory filepaths.
pub fn load_directory_files(dir_path : String) -> FilePathList {
  FilePathList(@ffi.load_directory_files(@utf8.encode(dir_path)))
}

///|
/// Load directory filepaths with extension filtering and recursive directory scan.
pub fn load_directory_files_ex(
  base_path : String,
  filter : String,
  scan_subdirs : Bool,
) -> FilePathList {
  FilePathList(
    @ffi.load_directory_files_ex(
      @utf8.encode(base_path),
      @utf8.encode(filter),
      scan_subdirs,
    ),
  )
}

///|
/// Get a filepath from the list by index.
pub fn file_path_list_get(files : FilePathList, index : Int) -> String {
  @utf8.decode_lossy(@ffi.file_path_list_get(files.0, index))
}

// ============================================================================
// File system: File mod time (wrapper)
// ============================================================================

///|
/// Get file modification time (last write time).
pub fn get_file_mod_time(file_name : String) -> Int {
  @ffi.get_file_mod_time(@utf8.encode(file_name))
}
