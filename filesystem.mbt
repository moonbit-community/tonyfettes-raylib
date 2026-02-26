// Re-export passthrough functions from internal FFI layer

///|
pub using @ffi {
  type FilePathList,
  is_file_dropped,
  load_dropped_files,
  unload_dropped_files,
  unload_directory_files,
  file_path_list_count,
}

// ============================================================================
// File system: Queries (wrappers)
// ============================================================================

///|
pub fn file_exists(file_name : String) -> Bool {
  @ffi.file_exists(@utf8.encode(file_name))
}

///|
pub fn directory_exists(dir_path : String) -> Bool {
  @ffi.directory_exists(@utf8.encode(dir_path))
}

///|
pub fn is_file_extension(file_name : String, ext : String) -> Bool {
  @ffi.is_file_extension(@utf8.encode(file_name), @utf8.encode(ext))
}

///|
pub fn get_file_length(file_name : String) -> Int {
  @ffi.get_file_length(@utf8.encode(file_name))
}

///|
pub fn get_file_extension(file_name : String) -> String {
  @utf8.decode_lossy(@ffi.get_file_extension(@utf8.encode(file_name)))
}

///|
pub fn get_file_name(file_path : String) -> String {
  @utf8.decode_lossy(@ffi.get_file_name(@utf8.encode(file_path)))
}

///|
pub fn get_file_name_without_ext(file_path : String) -> String {
  @utf8.decode_lossy(@ffi.get_file_name_without_ext(@utf8.encode(file_path)))
}

///|
pub fn get_directory_path(file_path : String) -> String {
  @utf8.decode_lossy(@ffi.get_directory_path(@utf8.encode(file_path)))
}

///|
pub fn get_prev_directory_path(dir_path : String) -> String {
  @utf8.decode_lossy(@ffi.get_prev_directory_path(@utf8.encode(dir_path)))
}

///|
pub fn get_working_directory() -> String {
  @utf8.decode_lossy(@ffi.get_working_directory())
}

///|
pub fn get_application_directory() -> String {
  @utf8.decode_lossy(@ffi.get_application_directory())
}

///|
pub fn make_directory(dir_path : String) -> Int {
  @ffi.make_directory(@utf8.encode(dir_path))
}

///|
pub fn change_directory(dir : String) -> Bool {
  @ffi.change_directory(@utf8.encode(dir))
}

///|
pub fn is_path_file(path : String) -> Bool {
  @ffi.is_path_file(@utf8.encode(path))
}

///|
pub fn is_file_name_valid(file_name : String) -> Bool {
  @ffi.is_file_name_valid(@utf8.encode(file_name))
}

// ============================================================================
// File system: Data load/save (wrappers)
// ============================================================================

///|
pub fn load_file_data(file_name : String) -> Bytes {
  @ffi.load_file_data(@utf8.encode(file_name))
}

///|
pub fn save_file_data(
  file_name : String,
  data : Bytes,
  data_size : Int,
) -> Bool {
  @ffi.save_file_data(@utf8.encode(file_name), data, data_size)
}

///|
pub fn load_file_text(file_name : String) -> String {
  @utf8.decode_lossy(@ffi.load_file_text(@utf8.encode(file_name)))
}

///|
pub fn save_file_text(file_name : String, text : String) -> Bool {
  @ffi.save_file_text(@utf8.encode(file_name), @utf8.encode(text))
}

///|
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
pub fn load_directory_files(dir_path : String) -> FilePathList {
  @ffi.load_directory_files(@utf8.encode(dir_path))
}

///|
pub fn load_directory_files_ex(
  base_path : String,
  filter : String,
  scan_subdirs : Bool,
) -> FilePathList {
  @ffi.load_directory_files_ex(
    @utf8.encode(base_path),
    @utf8.encode(filter),
    scan_subdirs,
  )
}

///|
pub fn file_path_list_get(files : FilePathList, index : Int) -> String {
  @utf8.decode_lossy(@ffi.file_path_list_get(files, index))
}

// ============================================================================
// File system: File mod time (wrapper)
// ============================================================================

///|
pub fn get_file_mod_time(file_name : String) -> Int {
  @ffi.get_file_mod_time(@utf8.encode(file_name))
}
