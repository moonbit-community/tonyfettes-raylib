// Tests for Issue 2: trailing null byte in filesystem string-returning stubs.
// These stubs allocate len+1 and memcpy the null terminator into the Bytes,
// causing @utf8.decode_lossy to produce strings with an embedded \0.

///|
test "get_file_extension returns clean string without trailing null" {
  let ext = get_file_extension("test.txt")
  assert_eq(ext.length(), 4) // ".txt" = 4 chars
  assert_eq(ext, ".txt")
}

///|
test "get_file_name returns clean string without trailing null" {
  let name = get_file_name("/foo/bar/test.txt")
  assert_eq(name, "test.txt")
}

///|
test "get_file_name_without_ext returns clean string without trailing null" {
  let name = get_file_name_without_ext("/foo/bar/test.txt")
  assert_eq(name, "test")
}

///|
test "get_directory_path returns clean string without trailing null" {
  let dir = get_directory_path("/foo/bar/test.txt")
  // Should end with a valid path character, not \0
  let chars = dir.to_array()
  assert_true(chars.length() > 0)
  assert_true(chars[chars.length() - 1] != '\x00')
}

///|
test "get_working_directory returns clean string" {
  set_config_flags(FlagWindowHidden)
  init_window(1, 1, "test")
  let dir = get_working_directory()
  assert_true(dir.length() > 0)
  let chars = dir.to_array()
  assert_true(chars[chars.length() - 1] != '\x00')
  close_window()
}
