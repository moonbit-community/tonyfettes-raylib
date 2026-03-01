///|
fn update_title_input(game : @types.Game) -> Unit {
  let mx = game.mouse_x
  let my = game.mouse_y
  let hold = game.mouse_hold
  let touch_count = game.touch_count
  let start_btn = @types.title_start_button_rect()
  let key_start = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace)
  let click_start = @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) &&
    @types.point_in_rect(
      mx, my, start_btn.0, start_btn.1, start_btn.2, start_btn.3,
    )
  let tap_start = game.touch_cd <= 0.0 &&
    @types.pointer_on_rect(
      mx,
      my,
      hold,
      touch_count,
      start_btn.0,
      start_btn.1,
      start_btn.2,
      start_btn.3,
    )
  if key_start || click_start || tap_start {
    start_mission(game, game.best_mission)
    game.touch_cd = 0.2
  }
}

///|
fn update_play_input(game : @types.Game) -> Unit {
  let mx = game.mouse_x
  let my = game.mouse_y
  let hold = game.mouse_hold
  let touch_count = game.touch_count
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    init_title_scene(game)
    return
  }
  let restart_btn = @types.mobile_restart_btn()
  let restart_key = @raylib.is_key_pressed(@raylib.KeyR)
  let restart_tap = game.touch_cd <= 0.0 &&
    @types.pointer_on_rect(
      mx,
      my,
      hold,
      touch_count,
      restart_btn.0,
      restart_btn.1,
      restart_btn.2,
      restart_btn.3,
    )
  if restart_key || restart_tap {
    restart_mission(game)
    game.touch_cd = 0.18
    return
  }
  let mut move_x : Float = 0.0
  let mut move_y : Float = 0.0
  if @raylib.is_key_down(@raylib.KeyA) || @raylib.is_key_down(@raylib.KeyLeft) {
    move_x = move_x - 1.0
  }
  if @raylib.is_key_down(@raylib.KeyD) || @raylib.is_key_down(@raylib.KeyRight) {
    move_x = move_x + 1.0
  }
  if @raylib.is_key_down(@raylib.KeyW) || @raylib.is_key_down(@raylib.KeyUp) {
    move_y = move_y - 1.0
  }
  if @raylib.is_key_down(@raylib.KeyS) || @raylib.is_key_down(@raylib.KeyDown) {
    move_y = move_y + 1.0
  }
  let left_btn = @types.mobile_left_btn()
  let right_btn = @types.mobile_right_btn()
  let up_btn = @types.mobile_up_btn()
  let down_btn = @types.mobile_down_btn()
  if @types.pointer_on_rect(
      mx,
      my,
      hold,
      touch_count,
      left_btn.0,
      left_btn.1,
      left_btn.2,
      left_btn.3,
    ) {
    move_x = move_x - 1.0
  }
  if @types.pointer_on_rect(
      mx,
      my,
      hold,
      touch_count,
      right_btn.0,
      right_btn.1,
      right_btn.2,
      right_btn.3,
    ) {
    move_x = move_x + 1.0
  }
  if @types.pointer_on_rect(
      mx,
      my,
      hold,
      touch_count,
      up_btn.0,
      up_btn.1,
      up_btn.2,
      up_btn.3,
    ) {
    move_y = move_y - 1.0
  }
  if @types.pointer_on_rect(
      mx,
      my,
      hold,
      touch_count,
      down_btn.0,
      down_btn.1,
      down_btn.2,
      down_btn.3,
    ) {
    move_y = move_y + 1.0
  }
  game.move_x = @types.clampf(move_x, -1.0, 1.0)
  game.move_y = @types.clampf(move_y, -1.0, 1.0)
  let boost_btn = @types.mobile_boost_btn()
  let boost_key = @raylib.is_key_down(@raylib.KeyLeftShift) ||
    @raylib.is_key_down(@raylib.KeyRightShift)
  let boost_touch = @types.pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    boost_btn.0,
    boost_btn.1,
    boost_btn.2,
    boost_btn.3,
  )
  game.boost_hold = boost_key || boost_touch
  let sonar_btn = @types.mobile_sonar_btn()
  let sonar_key = @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyF)
  let sonar_tap = game.touch_cd <= 0.0 &&
    @types.pointer_on_rect(
      mx,
      my,
      hold,
      touch_count,
      sonar_btn.0,
      sonar_btn.1,
      sonar_btn.2,
      sonar_btn.3,
    )
  if sonar_key || sonar_tap {
    game.sonar_trigger = true
    game.touch_cd = 0.12
  }
}

///|
fn update_result_input(game : @types.Game) -> Unit {
  let mx = game.mouse_x
  let my = game.mouse_y
  let hold = game.mouse_hold
  let touch_count = game.touch_count
  let restart_btn = @types.result_restart_button_rect()
  let next_btn = @types.result_next_button_rect()
  let title_btn = @types.result_title_button_rect()
  let key_restart = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyR)
  let key_next = game.state == @types.state_win &&
    @raylib.is_key_pressed(@raylib.KeyN)
  let key_title = @raylib.is_key_pressed(@raylib.KeyT) ||
    @raylib.is_key_pressed(@raylib.KeyEscape)
  let tap_restart = game.touch_cd <= 0.0 &&
    @types.pointer_on_rect(
      mx,
      my,
      hold,
      touch_count,
      restart_btn.0,
      restart_btn.1,
      restart_btn.2,
      restart_btn.3,
    )
  let tap_next = game.state == @types.state_win &&
    game.touch_cd <= 0.0 &&
    @types.pointer_on_rect(
      mx,
      my,
      hold,
      touch_count,
      next_btn.0,
      next_btn.1,
      next_btn.2,
      next_btn.3,
    )
  let tap_title = game.touch_cd <= 0.0 &&
    @types.pointer_on_rect(
      mx,
      my,
      hold,
      touch_count,
      title_btn.0,
      title_btn.1,
      title_btn.2,
      title_btn.3,
    )
  if key_next || tap_next {
    next_mission(game)
    game.touch_cd = 0.2
    return
  }
  if key_restart || tap_restart {
    restart_mission(game)
    game.touch_cd = 0.2
    return
  }
  if key_title || tap_title {
    init_title_scene(game)
    game.touch_cd = 0.2
  }
}
