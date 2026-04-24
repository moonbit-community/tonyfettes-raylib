///|
fn[T : Debug] show_debug(value : T, logger : &Logger) -> Unit {
  logger.write_string(@debug.to_string(value))
}

///|
pub impl Show for GuiState with output(self, logger) {
  show_debug(self, logger)
}

///|
pub impl Show for Vector3 with output(self, logger) {
  show_debug(self, logger)
}
