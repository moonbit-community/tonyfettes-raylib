///|
fn main {
  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(
    screen_w, screen_h, "raylib [game] ancient_temple_trap_run_2026",
  )
  defer @raylib.close_window()

  @raylib.set_target_fps(target_fps)

  let game = Game::new()
  init_title_scene(game)

  while not(@raylib.window_should_close()) {
    let dt = clampf(@raylib.get_frame_time(), 0.0, 0.033)
    let mouse_x = Float::from_int(@raylib.get_mouse_x())
    let mouse_y = Float::from_int(@raylib.get_mouse_y())
    let mouse_hold = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft)
    let touch_count = @raylib.get_touch_point_count()

    if game.state == state_title {
      update_title_input(game, mouse_x, mouse_y, mouse_hold, touch_count)
    } else if game.state == state_play {
      update_play_input(game, mouse_x, mouse_y, mouse_hold, touch_count)
    } else if game.state == state_stage_clear {
      update_stage_clear_input(game, mouse_x, mouse_y, mouse_hold, touch_count)
    } else if game.state == state_failed {
      update_failed_input(game, mouse_x, mouse_y, mouse_hold, touch_count)
    } else {
      update_victory_input(game, mouse_x, mouse_y, mouse_hold, touch_count)
    }

    update_game(game, dt)

    @raylib.begin_drawing()
    draw_frame(game, mouse_x, mouse_y, mouse_hold, touch_count)
    @raylib.end_drawing()
  }
}
