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
  let (a0, a1, a2, a3) = write_float(c.offset.x)
  let (a4, a5, a6, a7) = write_float(c.offset.y)
  let (b0, b1, b2, b3) = write_float(c.target.x)
  let (b4, b5, b6, b7) = write_float(c.target.y)
  let (c0, c1, c2, c3) = write_float(c.rotation)
  let (d0, d1, d2, d3) = write_float(c.zoom)
  [
    a0, a1, a2, a3, a4, a5, a6, a7, b0, b1, b2, b3, b4, b5, b6, b7, c0, c1, c2, c3,
    d0, d1, d2, d3,
  ]
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
  let (a0, a1, a2, a3) = write_float(c.position.x)
  let (a4, a5, a6, a7) = write_float(c.position.y)
  let (a8, a9, aa, ab) = write_float(c.position.z)
  let (b0, b1, b2, b3) = write_float(c.target.x)
  let (b4, b5, b6, b7) = write_float(c.target.y)
  let (b8, b9, ba, bb) = write_float(c.target.z)
  let (c0, c1, c2, c3) = write_float(c.up.x)
  let (c4, c5, c6, c7) = write_float(c.up.y)
  let (c8, c9, ca, cb) = write_float(c.up.z)
  let (d0, d1, d2, d3) = write_float(c.fovy)
  let (e0, e1, e2, e3) = write_int(c.projection)
  [
    a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, aa, ab, b0, b1, b2, b3, b4, b5, b6, b7,
    b8, b9, ba, bb, c0, c1, c2, c3, c4, c5, c6, c7, c8, c9, ca, cb, d0, d1, d2, d3,
    e0, e1, e2, e3,
  ]
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
pub using @raylib {end_mode_2d, end_mode_3d}

// Camera wrappers

///|
pub fn begin_mode_2d(camera : Camera2D) -> Unit {
  @raylib.begin_mode_2d(camera.to_bytes())
}

///|
pub fn begin_mode_3d(camera : Camera3D) -> Unit {
  @raylib.begin_mode_3d(camera.to_bytes())
}

///|
pub fn update_camera(camera : Camera3D, mode : Int) -> Camera3D {
  Camera3D::from_bytes(@raylib.update_camera(camera.to_bytes(), mode))
}

///|
pub fn update_camera_pro(
  camera : Camera3D,
  movement : Vector3,
  rotation : Vector3,
  zoom : Float,
) -> Camera3D {
  Camera3D::from_bytes(
    @raylib.update_camera_pro(
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
    @raylib.get_world_to_screen(position.to_bytes(), camera.to_bytes()),
  )
}

///|
pub fn get_screen_to_world_2d(position : Vector2, camera : Camera2D) -> Vector2 {
  Vector2::from_bytes(
    @raylib.get_screen_to_world_2d(position.to_bytes(), camera.to_bytes()),
  )
}

///|
pub fn get_world_to_screen_2d(position : Vector2, camera : Camera2D) -> Vector2 {
  Vector2::from_bytes(
    @raylib.get_world_to_screen_2d(position.to_bytes(), camera.to_bytes()),
  )
}
