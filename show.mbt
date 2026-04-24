///|
fn[T : Debug] show_debug(value : T, logger : &Logger) -> Unit {
  logger.write_string(@debug.to_string(value))
}

///|
pub impl Show for AutomationEvent with output(self, logger) {
  show_debug(self, logger)
}

///|
pub impl Show for Camera2D with output(self, logger) {
  show_debug(self, logger)
}

///|
pub impl Show for Camera3D with output(self, logger) {
  show_debug(self, logger)
}

///|
pub impl Show for Color with output(self, logger) {
  show_debug(self, logger)
}

///|
pub impl Show for VrDeviceInfo with output(self, logger) {
  show_debug(self, logger)
}

///|
pub impl Show for Matrix with output(self, logger) {
  show_debug(self, logger)
}

///|
pub impl Show for NPatchInfo with output(self, logger) {
  show_debug(self, logger)
}

///|
pub impl Show for Ray with output(self, logger) {
  show_debug(self, logger)
}

///|
pub impl Show for BoundingBox with output(self, logger) {
  show_debug(self, logger)
}

///|
pub impl Show for RayCollision with output(self, logger) {
  show_debug(self, logger)
}

///|
pub impl Show for Rectangle with output(self, logger) {
  show_debug(self, logger)
}

///|
pub impl Show for GlyphInfo with output(self, logger) {
  show_debug(self, logger)
}

///|
pub impl Show for Vector2 with output(self, logger) {
  show_debug(self, logger)
}

///|
pub impl Show for Vector3 with output(self, logger) {
  show_debug(self, logger)
}

///|
pub impl Show for Vector4 with output(self, logger) {
  show_debug(self, logger)
}
