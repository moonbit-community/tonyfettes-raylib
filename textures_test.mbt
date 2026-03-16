///|
test "GenImageColor creates image resource (no window needed)" {
  let img = @raylib.gen_image_color(16, 16, @raylib.red)
  img.unload()
}

///|
test "GenImageChecked creates image resource (no window needed)" {
  let img = @raylib.gen_image_checked(16, 16, 4, 4, @raylib.red, @raylib.blue)
  img.unload()
}
