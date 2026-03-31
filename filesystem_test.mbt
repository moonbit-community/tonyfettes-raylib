///|
test "file_exists detects existing file" {
  assert_true(@raylib.file_exists("moon.mod.json"))
}

///|
test "file_exists returns false for nonexistent" {
  assert_false(@raylib.file_exists("nonexistent_file_xyz.txt"))
}

///|
test "directory_exists detects existing directory" {
  assert_true(@raylib.directory_exists("internal"))
}

///|
test "directory_exists returns false for nonexistent" {
  assert_false(@raylib.directory_exists("nonexistent_dir_xyz"))
}

///|
test "is_file_extension matches" {
  assert_true(@raylib.is_file_extension("test.png", ".png"))
  assert_false(@raylib.is_file_extension("test.png", ".jpg"))
}

///|
test "get_file_length returns positive for existing file" {
  let len = @raylib.get_file_length("moon.mod.json")
  assert_true(len > 0)
}

///|
test "is_path_file distinguishes files from dirs" {
  assert_true(@raylib.is_path_file("moon.mod.json"))
  assert_false(@raylib.is_path_file("internal"))
}

///|
test "is_file_name_valid checks validity" {
  assert_true(@raylib.is_file_name_valid("test.txt"))
}

///|
test "get_application_directory returns non-empty" {
  let dir = @raylib.get_application_directory()
  assert_true(dir.length() > 0)
}

///|
test "load_file_data/save_file_data round-trip" {
  let data : Bytes = b"test data content"
  let path = "/tmp/raylib_test_file.bin"
  assert_true(@raylib.save_file_data(path, data, data.length()))
  let loaded = @raylib.load_file_data(path)
  assert_eq(loaded, data)
}

///|
test "get_prev_directory_path returns parent" {
  let prev = @raylib.get_prev_directory_path("/usr/local/bin")
  assert_true(prev.length() > 0)
}
