// Camera2D: 24 bytes (offset, target as Vector2; rotation, zoom as float)

///|
pub struct Camera2D {
  offset : Vector2
  target : Vector2
  rotation : Float
  zoom : Float
} derive(Eq, Show)

///|
pub fn Camera2D::new(
  offset : Vector2,
  target : Vector2,
  rotation : Float,
  zoom : Float,
) -> Camera2D {
  { offset, target, rotation, zoom }
}

///|
pub fn Camera2D::to_bytes(c : Camera2D) -> Bytes {
  let buf = @buffer.new(size_hint=24)
  buf.write_float_le(c.offset.x)
  buf.write_float_le(c.offset.y)
  buf.write_float_le(c.target.x)
  buf.write_float_le(c.target.y)
  buf.write_float_le(c.rotation)
  buf.write_float_le(c.zoom)
  buf.to_bytes()
}

///|
pub fn Camera2D::from_bytes(b : Bytes) -> Camera2D {
  {
    offset: { x: read_float(b, 0), y: read_float(b, 4) },
    target: { x: read_float(b, 8), y: read_float(b, 12) },
    rotation: read_float(b, 16),
    zoom: read_float(b, 20),
  }
}

// Camera3D: 44 bytes (position, target, up as Vector3; fovy as float; projection as int)

///|
pub struct Camera3D {
  position : Vector3
  target : Vector3
  up : Vector3
  fovy : Float
  projection : Int
} derive(Eq, Show)

///|
pub fn Camera3D::new(
  position : Vector3,
  target : Vector3,
  up : Vector3,
  fovy : Float,
  projection : Int,
) -> Camera3D {
  { position, target, up, fovy, projection }
}

///|
pub fn Camera3D::to_bytes(c : Camera3D) -> Bytes {
  let buf = @buffer.new(size_hint=44)
  buf.write_float_le(c.position.x)
  buf.write_float_le(c.position.y)
  buf.write_float_le(c.position.z)
  buf.write_float_le(c.target.x)
  buf.write_float_le(c.target.y)
  buf.write_float_le(c.target.z)
  buf.write_float_le(c.up.x)
  buf.write_float_le(c.up.y)
  buf.write_float_le(c.up.z)
  buf.write_float_le(c.fovy)
  buf.write_int_le(c.projection)
  buf.to_bytes()
}

///|
pub fn Camera3D::from_bytes(b : Bytes) -> Camera3D {
  {
    position: { x: read_float(b, 0), y: read_float(b, 4), z: read_float(b, 8) },
    target: { x: read_float(b, 12), y: read_float(b, 16), z: read_float(b, 20) },
    up: { x: read_float(b, 24), y: read_float(b, 28), z: read_float(b, 32) },
    fovy: read_float(b, 36),
    projection: read_int(b, 40),
  }
}

// Camera mode constants

///|
pub const CameraCustom : Int = 0

///|
pub const CameraFree : Int = 1

///|
pub const CameraOrbital : Int = 2

///|
pub const CameraFirstPerson : Int = 3

///|
pub const CameraThirdPerson : Int = 4

// Camera projection constants

///|
pub const CameraPerspective : Int = 0

///|
pub const CameraOrthographic : Int = 1

// Re-export passthrough camera functions

///|
pub using @ffi {end_mode_2d, end_mode_3d}

// Camera wrappers

///|
pub fn begin_mode_2d(camera : Camera2D) -> Unit {
  @ffi.begin_mode_2d(camera.to_bytes())
}

///|
pub fn begin_mode_3d(camera : Camera3D) -> Unit {
  @ffi.begin_mode_3d(camera.to_bytes())
}

///|
pub fn update_camera(camera : Camera3D, mode : Int) -> Camera3D {
  Camera3D::from_bytes(@ffi.update_camera(camera.to_bytes(), mode))
}

///|
pub fn update_camera_pro(
  camera : Camera3D,
  movement : Vector3,
  rotation : Vector3,
  zoom : Float,
) -> Camera3D {
  Camera3D::from_bytes(
    @ffi.update_camera_pro(
      camera.to_bytes(),
      movement.to_bytes(),
      rotation.to_bytes(),
      zoom,
    ),
  )
}

///|
pub fn get_world_to_screen(position : Vector3, camera : Camera3D) -> Vector2 {
  Vector2::from_bytes(
    @ffi.get_world_to_screen(position.to_bytes(), camera.to_bytes()),
  )
}

///|
pub fn get_screen_to_world_2d(position : Vector2, camera : Camera2D) -> Vector2 {
  Vector2::from_bytes(
    @ffi.get_screen_to_world_2d(position.to_bytes(), camera.to_bytes()),
  )
}

///|
pub fn get_world_to_screen_2d(position : Vector2, camera : Camera2D) -> Vector2 {
  Vector2::from_bytes(
    @ffi.get_world_to_screen_2d(position.to_bytes(), camera.to_bytes()),
  )
}

// ============================================================================
// Camera matrix
// ============================================================================

///|
pub fn get_camera_matrix(camera : Camera3D) -> Matrix {
  Matrix::from_bytes(@ffi.get_camera_matrix(camera.to_bytes()))
}

///|
pub fn get_camera_matrix_2d(camera : Camera2D) -> Matrix {
  Matrix::from_bytes(@ffi.get_camera_matrix_2d(camera.to_bytes()))
}

///|
pub fn get_screen_to_world_ray(position : Vector2, camera : Camera3D) -> Ray {
  Ray::from_bytes(
    @ffi.get_screen_to_world_ray(position.to_bytes(), camera.to_bytes()),
  )
}

///|
pub fn get_screen_to_world_ray_ex(
  position : Vector2,
  camera : Camera3D,
  width : Int,
  height : Int,
) -> Ray {
  Ray::from_bytes(
    @ffi.get_screen_to_world_ray_ex(
      position.to_bytes(),
      camera.to_bytes(),
      width,
      height,
    ),
  )
}

///|
pub fn get_world_to_screen_ex(
  position : Vector3,
  camera : Camera3D,
  width : Int,
  height : Int,
) -> Vector2 {
  Vector2::from_bytes(
    @ffi.get_world_to_screen_ex(
      position.to_bytes(),
      camera.to_bytes(),
      width,
      height,
    ),
  )
}
