///|
test "GuiState::to_int" {
  assert_eq(GuiState::Normal.to_int(), 0)
  assert_eq(GuiState::Focused.to_int(), 1)
  assert_eq(GuiState::Pressed.to_int(), 2)
  assert_eq(GuiState::Disabled.to_int(), 3)
}
