///|
test "GenImageColor creates image resource (no window needed)" {
  let img = gen_image_color(16, 16, red)
  unload_image(img)
}

///|
test "GenImageChecked creates image resource (no window needed)" {
  let img = gen_image_checked(16, 16, 4, 4, red, blue)
  unload_image(img)
}
