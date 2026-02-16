// ============================================================================
// File system: Queries
// ============================================================================

///|
#borrow(file_name)
pub extern "c" fn file_exists(file_name : Bytes) -> Bool = "moonbit_raylib_file_exists"

///|
#borrow(dir_path)
pub extern "c" fn directory_exists(dir_path : Bytes) -> Bool = "moonbit_raylib_directory_exists"

///|
#borrow(file_name, ext)
pub extern "c" fn is_file_extension(file_name : Bytes, ext : Bytes) -> Bool = "moonbit_raylib_is_file_extension"

///|
#borrow(file_name)
pub extern "c" fn get_file_length(file_name : Bytes) -> Int = "moonbit_raylib_get_file_length"

///|
#borrow(file_name)
pub extern "c" fn get_file_extension(file_name : Bytes) -> Bytes = "moonbit_raylib_get_file_extension"

///|
#borrow(file_path)
pub extern "c" fn get_file_name(file_path : Bytes) -> Bytes = "moonbit_raylib_get_file_name"

///|
#borrow(file_path)
pub extern "c" fn get_file_name_without_ext(file_path : Bytes) -> Bytes = "moonbit_raylib_get_file_name_without_ext"

///|
#borrow(file_path)
pub extern "c" fn get_directory_path(file_path : Bytes) -> Bytes = "moonbit_raylib_get_directory_path"

///|
#borrow(dir_path)
pub extern "c" fn get_prev_directory_path(dir_path : Bytes) -> Bytes = "moonbit_raylib_get_prev_directory_path"

///|
pub extern "c" fn get_working_directory() -> Bytes = "moonbit_raylib_get_working_directory"

///|
pub extern "c" fn get_application_directory() -> Bytes = "moonbit_raylib_get_application_directory"

///|
#borrow(dir_path)
pub extern "c" fn make_directory(dir_path : Bytes) -> Int = "moonbit_raylib_make_directory"

///|
#borrow(dir)
pub extern "c" fn change_directory(dir : Bytes) -> Bool = "moonbit_raylib_change_directory"

///|
#borrow(path)
pub extern "c" fn is_path_file(path : Bytes) -> Bool = "moonbit_raylib_is_path_file"

///|
#borrow(file_name)
pub extern "c" fn is_file_name_valid(file_name : Bytes) -> Bool = "moonbit_raylib_is_file_name_valid"

// ============================================================================
// File system: Data load/save
// ============================================================================

///|
#borrow(file_name)
pub extern "c" fn load_file_data(file_name : Bytes) -> Bytes = "moonbit_raylib_load_file_data"

///|
#borrow(file_name, data)
pub extern "c" fn save_file_data(
  file_name : Bytes,
  data : Bytes,
  data_size : Int,
) -> Bool = "moonbit_raylib_save_file_data"

///|
#borrow(file_name)
pub extern "c" fn load_file_text(file_name : Bytes) -> Bytes = "moonbit_raylib_load_file_text"

///|
#borrow(file_name, text)
pub extern "c" fn save_file_text(file_name : Bytes, text : Bytes) -> Bool = "moonbit_raylib_save_file_text"

///|
#borrow(data, file_name)
pub extern "c" fn export_data_as_code(
  data : Bytes,
  data_size : Int,
  file_name : Bytes,
) -> Bool = "moonbit_raylib_export_data_as_code"

// ============================================================================
// File system: File drop
// ============================================================================

///|
pub extern "c" fn is_file_dropped() -> Bool = "moonbit_raylib_is_file_dropped"

///|
pub extern "c" fn load_dropped_files() -> FilePathList = "moonbit_raylib_load_dropped_files"

///|
#borrow(files)
pub extern "c" fn unload_dropped_files(files : FilePathList) = "moonbit_raylib_unload_dropped_files"

// ============================================================================
// File system: Directory listing
// ============================================================================

///|
#borrow(dir_path)
pub extern "c" fn load_directory_files(dir_path : Bytes) -> FilePathList = "moonbit_raylib_load_directory_files"

///|
#borrow(base_path, filter)
pub extern "c" fn load_directory_files_ex(
  base_path : Bytes,
  filter : Bytes,
  scan_subdirs : Bool,
) -> FilePathList = "moonbit_raylib_load_directory_files_ex"

///|
#borrow(files)
pub extern "c" fn unload_directory_files(files : FilePathList) = "moonbit_raylib_unload_directory_files"

// ============================================================================
// File system: FilePathList accessors
// ============================================================================

///|
#borrow(files)
pub extern "c" fn file_path_list_count(files : FilePathList) -> Int = "moonbit_raylib_file_path_list_count"

///|
#borrow(files)
pub extern "c" fn file_path_list_get(
  files : FilePathList,
  index : Int,
) -> Bytes = "moonbit_raylib_file_path_list_get"

// ============================================================================
// File system: File mod time
// ============================================================================

///|
#borrow(file_name)
pub extern "c" fn get_file_mod_time(file_name : Bytes) -> Int = "moonbit_raylib_get_file_mod_time"
