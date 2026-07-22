///|
fn[T : Debug] show_debug(value : T, logger : &Logger) -> Unit {
  logger.write_string(@debug.to_string(value))
}

///|
pub impl Show for AutomationEvent with fn output(self, logger) {
  show_debug(self, logger)
}

///|
pub impl Show for Camera2D with fn output(self, logger) {
  show_debug(self, logger)
}

///|
pub impl Show for Camera3D with fn output(self, logger) {
  show_debug(self, logger)
}

///|
pub impl Show for Color with fn output(self, logger) {
  show_debug(self, logger)
}

///|
pub impl Show for VrDeviceInfo with fn output(self, logger) {
  show_debug(self, logger)
}

///|
pub impl Show for Matrix with fn output(self, logger) {
  show_debug(self, logger)
}

///|
pub impl Show for NPatchInfo with fn output(self, logger) {
  show_debug(self, logger)
}

///|
pub impl Show for Ray with fn output(self, logger) {
  show_debug(self, logger)
}

///|
pub impl Show for BoundingBox with fn output(self, logger) {
  show_debug(self, logger)
}

///|
pub impl Show for RayCollision with fn output(self, logger) {
  show_debug(self, logger)
}

///|
pub impl Show for Rectangle with fn output(self, logger) {
  show_debug(self, logger)
}

///|
pub impl Show for GlyphInfo with fn output(self, logger) {
  show_debug(self, logger)
}

///|
pub impl Show for Vector2 with fn output(self, logger) {
  show_debug(self, logger)
}

///|
pub impl Show for Vector3 with fn output(self, logger) {
  show_debug(self, logger)
}

///|
pub impl Show for Vector4 with fn output(self, logger) {
  show_debug(self, logger)
}
