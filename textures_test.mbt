///|
test "Texture round-trip through Bytes" {
  let t = Texture::new(id=42U, width=256, height=128)
  let bytes = t.to_bytes()
  let t2 = Texture::from_bytes(bytes)
  assert_eq(t, t2)
  assert_eq(t2.id, 42U)
  assert_eq(t2.width, 256)
  assert_eq(t2.height, 128)
}

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
