// Tests for camera functions and core utilities that are safe to call
// without an active window context.

///|
test "color_alpha adjusts alpha channel" {
  let c = Color::new(230, 41, 55, 255)
  let result = color_alpha(c, 0.5)
  // Alpha should be roughly half of 255 (around 127-128)
  assert_true(result.a.to_int() >= 127 && result.a.to_int() <= 128)
  // RGB channels should remain unchanged
  assert_eq(result.r, c.r)
  assert_eq(result.g, c.g)
  assert_eq(result.b, c.b)
}

///|
test "set_random_seed + get_random_value determinism" {
  set_random_seed(42)
  let a1 = get_random_value(0, 1000)
  let a2 = get_random_value(0, 1000)
  set_random_seed(42)
  let b1 = get_random_value(0, 1000)
  let b2 = get_random_value(0, 1000)
  assert_eq(a1, b1)
  assert_eq(a2, b2)
}

///|
test "set_target_fps does not crash" {
  set_target_fps(60)
  // If we reach here, no crash occurred
  assert_true(true)
}

///|
test "get_time returns non-negative" {
  let t = get_time()
  assert_true(t >= 0.0)
}

///|
test "get_frame_time returns non-negative" {
  let dt = get_frame_time()
  assert_true(dt >= 0.0)
}

///|
test "set_trace_log_level does not crash" {
  set_trace_log_level(log_none)
  // If we reach here, no crash occurred
  assert_true(true)
}

///|
test "set_text_line_spacing does not crash" {
  set_text_line_spacing(15)
  // If we reach here, no crash occurred
  assert_true(true)
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
    camera_perspective,
  )
  let updated = update_camera(cam, camera_custom)
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
    camera_perspective,
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
    camera_perspective,
  )
  let pos = Vector3::new(1.0, 2.0, 3.0)
  // Without a window the result will be degenerate, but it should not crash
  let _result = get_world_to_screen(pos, cam)
  assert_true(true)
}

///|
test "Constants: key codes sample" {
  assert_eq(key_space, 32)
  assert_eq(key_escape, 256)
}

///|
test "Constants: flags and modes" {
  assert_eq(flag_window_hidden, 0x80)
  assert_eq(camera_perspective, 0)
  assert_eq(blend_alpha, 0)
  assert_eq(mouse_button_left, 0)
}
