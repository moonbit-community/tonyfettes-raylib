///|
test "Camera2D round-trip through Bytes" {
  let cam = Camera2D::new(
    Vector2::new(400.0, 300.0),
    Vector2::new(0.0, 0.0),
    0.0,
    1.0,
  )
  let bytes = cam.to_bytes()
  let cam2 = Camera2D::from_bytes(bytes)
  assert_eq(cam, cam2)
}

///|
test "Camera3D round-trip through Bytes" {
  let cam = Camera3D::new(
    Vector3::new(0.0, 10.0, 10.0),
    Vector3::new(0.0, 0.0, 0.0),
    Vector3::new(0.0, 1.0, 0.0),
    45.0,
    0,
  )
  let bytes = cam.to_bytes()
  let cam2 = Camera3D::from_bytes(bytes)
  assert_eq(cam, cam2)
}

///|
test "get_screen_to_world_2d identity camera" {
  let identity_cam = Camera2D::new(
    Vector2::new(0.0, 0.0),
    Vector2::new(0.0, 0.0),
    0.0,
    1.0,
  )
  let point = Vector2::new(150.0, 250.0)
  let result = get_screen_to_world_2d(point, identity_cam)
  assert_eq(result.x, point.x)
  assert_eq(result.y, point.y)
}

///|
test "get_world_to_screen_2d identity camera" {
  let identity_cam = Camera2D::new(
    Vector2::new(0.0, 0.0),
    Vector2::new(0.0, 0.0),
    0.0,
    1.0,
  )
  let point = Vector2::new(150.0, 250.0)
  let result = get_world_to_screen_2d(point, identity_cam)
  assert_eq(result.x, point.x)
  assert_eq(result.y, point.y)
}

///|
test "get_world_to_screen_2d and get_screen_to_world_2d round-trip" {
  let cam = Camera2D::new(
    Vector2::new(100.0, 50.0),
    Vector2::new(200.0, 150.0),
    0.0,
    2.0,
  )
  let original = Vector2::new(300.0, 400.0)
  let screen_pos = get_world_to_screen_2d(original, cam)
  let back = get_screen_to_world_2d(screen_pos, cam)
  // Check approximate equality within tolerance of 0.1
  let dx = back.x - original.x
  let dy = back.y - original.y
  let dx_abs : Float = if dx < 0.0 { 0.0 - dx } else { dx }
  let dy_abs : Float = if dy < 0.0 { 0.0 - dy } else { dy }
  assert_true(dx_abs < 0.1)
  assert_true(dy_abs < 0.1)
}

///|
test "update_camera with custom mode" {
  let cam = Camera3D::new(
    Vector3::new(0.0, 10.0, 10.0),
    Vector3::new(0.0, 0.0, 0.0),
    Vector3::new(0.0, 1.0, 0.0),
    45.0,
    CameraPerspective,
  )
  let updated = update_camera(cam, CameraCustom)
  // With custom mode and no input, the camera position should remain unchanged
  assert_eq(updated.position.x, cam.position.x)
  assert_eq(updated.position.y, cam.position.y)
  assert_eq(updated.position.z, cam.position.z)
}

///|
test "update_camera_pro applies zero movement" {
  let cam = Camera3D::new(
    Vector3::new(5.0, 10.0, 15.0),
    Vector3::new(0.0, 0.0, 0.0),
    Vector3::new(0.0, 1.0, 0.0),
    45.0,
    CameraPerspective,
  )
  let zero = Vector3::new(0.0, 0.0, 0.0)
  let updated = update_camera_pro(cam, zero, zero, 0.0)
  // With zero movement, rotation, and zoom, position should remain approximately unchanged
  let dx : Float = if updated.position.x - cam.position.x < 0.0 {
    0.0 - (updated.position.x - cam.position.x)
  } else {
    updated.position.x - cam.position.x
  }
  let dy : Float = if updated.position.y - cam.position.y < 0.0 {
    0.0 - (updated.position.y - cam.position.y)
  } else {
    updated.position.y - cam.position.y
  }
  let dz : Float = if updated.position.z - cam.position.z < 0.0 {
    0.0 - (updated.position.z - cam.position.z)
  } else {
    updated.position.z - cam.position.z
  }
  assert_true(dx < 0.001)
  assert_true(dy < 0.001)
  assert_true(dz < 0.001)
}

///|
test "get_world_to_screen without window returns some value" {
  let cam = Camera3D::new(
    Vector3::new(0.0, 10.0, 10.0),
    Vector3::new(0.0, 0.0, 0.0),
    Vector3::new(0.0, 1.0, 0.0),
    45.0,
    CameraPerspective,
  )
  let pos = Vector3::new(1.0, 2.0, 3.0)
  // Without a window the result will be degenerate, but it should not crash
  let _result = get_world_to_screen(pos, cam)
  assert_true(true)
}
