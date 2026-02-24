///|
fn main {
  @raylib.set_config_flags(@raylib.FlagVsyncHint)
  @raylib.init_window(ScreenWidth, ScreenHeight, "raylib celeste classic")
  @raylib.set_target_fps(60)
  render_init()

  let mut level = load_level()
  let mut state = new_game_state(level)
  let mut accumulator : Float = 0.0
  let mut level_time : Float = 0.0

  while not(@raylib.window_should_close()) {
    let mut frame_dt = @raylib.get_frame_time()
    if frame_dt > 0.05 {
      frame_dt = 0.05
    } else if frame_dt < 0.0 {
      frame_dt = 0.0
    }

    let input = read_input()
    accumulator = accumulator + frame_dt

    while accumulator >= fixed_dt {
      if state.phase == PhasePlaying {
        level_time = level_time + fixed_dt
      }
      let previous_room = state.room_index
      state = update_game_state(state, level, input, fixed_dt, level_time)
      if state.room_index != previous_room {
        level = load_room(state.room_index)
      }
      accumulator = accumulator - fixed_dt
    }

    render_game(level, state)
  }

  render_shutdown()
  @raylib.close_window()
}
