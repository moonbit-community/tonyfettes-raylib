///|
test "ShaderUniformDataV::to_bytes Int" {
  let data : ShaderUniformDataV = ShaderUniformDataV::Int([1, 256])
  let bytes = data.to_bytes()
  // Two little-endian int32s: 1 = [0x01,0x00,0x00,0x00], 256 = [0x00,0x01,0x00,0x00]
  assert_eq(bytes.length(), 8)
  assert_eq(bytes[0], b'\x01')
  assert_eq(bytes[1], b'\x00')
  assert_eq(bytes[2], b'\x00')
  assert_eq(bytes[3], b'\x00')
  assert_eq(bytes[4], b'\x00')
  assert_eq(bytes[5], b'\x01')
  assert_eq(bytes[6], b'\x00')
  assert_eq(bytes[7], b'\x00')
}

///|
test "ShaderUniformDataV::to_bytes IVec3" {
  let data : ShaderUniformDataV = ShaderUniformDataV::IVec3([(10, 20, 30)])
  let bytes = data.to_bytes()
  // One ivec3: three little-endian int32s
  assert_eq(bytes.length(), 12)
  assert_eq(bytes[0], b'\x0A')
  assert_eq(bytes[4], b'\x14')
  assert_eq(bytes[8], b'\x1E')
}

///|
test "ShaderUniformDataV::to_bytes Vec4" {
  let data : ShaderUniformDataV = ShaderUniformDataV::Vec4([
    Vector4::new(1.0, 0.0, 0.0, 0.0),
  ])
  let bytes = data.to_bytes()
  // One vec4: four little-endian float32s, 1.0f = 0x3F800000
  assert_eq(bytes.length(), 16)
  assert_eq(bytes[0], b'\x00')
  assert_eq(bytes[1], b'\x00')
  assert_eq(bytes[2], b'\x80')
  assert_eq(bytes[3], b'\x3F')
}

///|
test "ShaderUniformDataV::to_bytes empty" {
  let data : ShaderUniformDataV = ShaderUniformDataV::Float([])
  let bytes = data.to_bytes()
  assert_eq(bytes.length(), 0)
}

///|
test "ShaderUniformDataV uniform_type and count" {
  let data : ShaderUniformDataV = ShaderUniformDataV::IVec3([
    (1, 2, 3), (4, 5, 6),
  ])
  assert_eq(data.uniform_type(), ShaderUniformIvec3)
  assert_eq(data.count(), 2)
  assert_eq(data.elem_size(), 12)
}
