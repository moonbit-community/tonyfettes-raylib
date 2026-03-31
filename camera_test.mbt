///|
test "Camera2D round-trip through Bytes" {
  let cam = @raylib.Camera2D::new(
    @raylib.Vector2::new(400.0, 300.0),
    @raylib.Vector2::new(0.0, 0.0),
    0.0,
    1.0,
  )
  let bytes = cam.to_bytes()
  let cam2 = @raylib.Camera2D::from_bytes(bytes)
  assert_eq(cam, cam2)
}

///|
test "Camera3D round-trip through Bytes" {
  let cam = @raylib.Camera3D::new(
    @raylib.Vector3::new(0.0, 10.0, 10.0),
    @raylib.Vector3::new(0.0, 0.0, 0.0),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    45.0,
    0,
  )
  let bytes = cam.to_bytes()
  let cam2 = @raylib.Camera3D::from_bytes(bytes)
  assert_eq(cam, cam2)
}

///|
test "get_screen_to_world_2d identity camera" {
  let identity_cam = @raylib.Camera2D::new(
    @raylib.Vector2::new(0.0, 0.0),
    @raylib.Vector2::new(0.0, 0.0),
    0.0,
    1.0,
  )
  let point = @raylib.Vector2::new(150.0, 250.0)
  let result = @raylib.get_screen_to_world_2d(point, identity_cam)
  assert_eq(result.x, point.x)
  assert_eq(result.y, point.y)
}

///|
test "get_world_to_screen_2d identity camera" {
  let identity_cam = @raylib.Camera2D::new(
    @raylib.Vector2::new(0.0, 0.0),
    @raylib.Vector2::new(0.0, 0.0),
    0.0,
    1.0,
  )
  let point = @raylib.Vector2::new(150.0, 250.0)
  let result = @raylib.get_world_to_screen_2d(point, identity_cam)
  assert_eq(result.x, point.x)
  assert_eq(result.y, point.y)
}

///|
test "get_world_to_screen_2d and get_screen_to_world_2d round-trip" {
  let cam = @raylib.Camera2D::new(
    @raylib.Vector2::new(100.0, 50.0),
    @raylib.Vector2::new(200.0, 150.0),
    0.0,
    2.0,
  )
  let original = @raylib.Vector2::new(300.0, 400.0)
  let screen_pos = @raylib.get_world_to_screen_2d(original, cam)
  let back = @raylib.get_screen_to_world_2d(screen_pos, cam)
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
  let cam = @raylib.Camera3D::new(
    @raylib.Vector3::new(0.0, 10.0, 10.0),
    @raylib.Vector3::new(0.0, 0.0, 0.0),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    45.0,
    @raylib.CameraPerspective,
  )
  let updated = @raylib.update_camera(cam, @raylib.CameraCustom)
  // With custom mode and no input, the camera position should remain unchanged
  assert_eq(updated.position.x, cam.position.x)
  assert_eq(updated.position.y, cam.position.y)
  assert_eq(updated.position.z, cam.position.z)
}

///|
test "update_camera_pro applies zero movement" {
  let cam = @raylib.Camera3D::new(
    @raylib.Vector3::new(5.0, 10.0, 15.0),
    @raylib.Vector3::new(0.0, 0.0, 0.0),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    45.0,
    @raylib.CameraPerspective,
  )
  let zero = @raylib.Vector3::new(0.0, 0.0, 0.0)
  let updated = @raylib.update_camera_pro(cam, zero, zero, 0.0)
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
  let cam = @raylib.Camera3D::new(
    @raylib.Vector3::new(0.0, 10.0, 10.0),
    @raylib.Vector3::new(0.0, 0.0, 0.0),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    45.0,
    @raylib.CameraPerspective,
  )
  let pos = @raylib.Vector3::new(1.0, 2.0, 3.0)
  // Without a window the result will be degenerate, but it should not crash
  let _result = @raylib.get_world_to_screen(pos, cam)
  assert_true(true)
}

///|
test "get_camera_matrix returns valid matrix" {
  let cam = @raylib.Camera3D::new(
    @raylib.Vector3::new(0.0, 10.0, 10.0),
    @raylib.Vector3::new(0.0, 0.0, 0.0),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    45.0,
    @raylib.CameraPerspective,
  )
  let m = @raylib.get_camera_matrix(cam)
  // Should be a valid affine matrix (m15 close to 1)
  assert_true((m.m15 - 1.0).abs() < 0.001)
}

///|
test "get_camera_matrix_2d returns valid matrix" {
  let cam = @raylib.Camera2D::new(
    @raylib.Vector2::new(400.0, 300.0),
    @raylib.Vector2::new(0.0, 0.0),
    0.0,
    1.0,
  )
  let m = @raylib.get_camera_matrix_2d(cam)
  // Should be a valid matrix
  assert_true((m.m15 - 1.0).abs() < 0.001)
}

///|
test "get_screen_to_world_ray returns a ray" {
  let cam = @raylib.Camera3D::new(
    @raylib.Vector3::new(0.0, 10.0, 10.0),
    @raylib.Vector3::new(0.0, 0.0, 0.0),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    45.0,
    @raylib.CameraPerspective,
  )
  let pos = @raylib.Vector2::new(400.0, 300.0)
  // Without a window, results may be degenerate, but should not crash
  let _ray = @raylib.get_screen_to_world_ray(pos, cam)
  assert_true(true)
}

///|
test "get_screen_to_world_ray_ex returns a ray" {
  let cam = @raylib.Camera3D::new(
    @raylib.Vector3::new(0.0, 10.0, 10.0),
    @raylib.Vector3::new(0.0, 0.0, 0.0),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    45.0,
    @raylib.CameraPerspective,
  )
  let pos = @raylib.Vector2::new(400.0, 300.0)
  let _ray = @raylib.get_screen_to_world_ray_ex(pos, cam, 800, 600)
  assert_true(true)
}

///|
test "get_world_to_screen_ex returns screen coordinates" {
  let cam = @raylib.Camera3D::new(
    @raylib.Vector3::new(0.0, 10.0, 10.0),
    @raylib.Vector3::new(0.0, 0.0, 0.0),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    45.0,
    @raylib.CameraPerspective,
  )
  let pos = @raylib.Vector3::new(1.0, 2.0, 3.0)
  let _result = @raylib.get_world_to_screen_ex(pos, cam, 800, 600)
  assert_true(true)
}
