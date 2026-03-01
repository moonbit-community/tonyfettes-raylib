///|
pub fn update_title_input(game : @types.Game) -> Unit {
  let mx = game.mouse_x
  let my = game.mouse_y
  let hold = game.mouse_hold
  let touch_count = game.touch_count
  let key_start : Bool = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace)
  let click_start : Bool = @raylib.is_mouse_button_pressed(
    @raylib.MouseButtonLeft,
  )
  let tap_start : Bool = game.touch_cd <= 0.0 &&
    @types.title_hover(mx, my, hold, touch_count)

  if key_start || click_start || tap_start {
    start_run(game)
    game.touch_cd = 0.16
  }
}

///|
pub fn update_result_input(game : @types.Game) -> Unit {
  let mx = game.mouse_x
  let my = game.mouse_y
  let hold = game.mouse_hold
  let touch_count = game.touch_count
  let key_retry : Bool = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyR)
  let click_retry : Bool = @raylib.is_mouse_button_pressed(
    @raylib.MouseButtonLeft,
  )
  let tap_retry : Bool = game.touch_cd <= 0.0 &&
    @types.retry_hover(mx, my, hold, touch_count)

  if key_retry || click_retry || tap_retry {
    start_run(game)
    game.touch_cd = 0.16
  }
}

///|
pub fn update_play_input(game : @types.Game) -> Unit {
  let mx = game.mouse_x
  let my = game.mouse_y
  let hold = game.mouse_hold
  let touch_count = game.touch_count
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    go_title(game)
    return
  }

  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_run(game)
    return
  }

  if @raylib.is_key_pressed(@raylib.KeyH) {
    cycle_hint(game)
  }

  let mut dx : Int = 0
  let mut dy : Int = 0

  if @raylib.is_key_down(@raylib.KeyA) || @raylib.is_key_down(@raylib.KeyLeft) {
    dx = dx - 1
  }
  if @raylib.is_key_down(@raylib.KeyD) || @raylib.is_key_down(@raylib.KeyRight) {
    dx = dx + 1
  }
  if @raylib.is_key_down(@raylib.KeyW) || @raylib.is_key_down(@raylib.KeyUp) {
    dy = dy - 1
  }
  if @raylib.is_key_down(@raylib.KeyS) || @raylib.is_key_down(@raylib.KeyDown) {
    dy = dy + 1
  }

  let b_l = @types.btn_left()
  let b_r = @types.btn_right()
  let b_u = @types.btn_up()
  let b_d = @types.btn_down()

  if @types.pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    b_l.0,
    b_l.1,
    b_l.2,
    b_l.3,
  ) {
    dx = dx - 1
  }
  if @types.pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    b_r.0,
    b_r.1,
    b_r.2,
    b_r.3,
  ) {
    dx = dx + 1
  }
  if @types.pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    b_u.0,
    b_u.1,
    b_u.2,
    b_u.3,
  ) {
    dy = dy - 1
  }
  if @types.pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    b_d.0,
    b_d.1,
    b_d.2,
    b_d.3,
  ) {
    dy = dy + 1
  }

  dx = @types.clampi(dx, -1, 1)
  dy = @types.clampi(dy, -1, 1)

  if dx != 0 && dy != 0 {
    if @raylib.is_key_down(@raylib.KeyA) ||
      @raylib.is_key_down(@raylib.KeyD) ||
      @raylib.is_key_down(@raylib.KeyLeft) ||
      @raylib.is_key_down(@raylib.KeyRight) {
      dy = 0
    } else {
      dx = 0
    }
  }

  game.req_dx = dx
  game.req_dy = dy

  let a = @types.btn_action()
  let action_key_down : Bool = @raylib.is_key_down(@raylib.KeySpace) ||
    @raylib.is_key_down(@raylib.KeyE) ||
    @raylib.is_key_down(@raylib.KeyJ)
  let action_touch_down : Bool = @types.pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    a.0,
    a.1,
    a.2,
    a.3,
  )

  let down_now : Bool = action_key_down || action_touch_down
  game.action_pressed = down_now && not(game.action_down)
  game.action_down = down_now

  let h = @types.btn_hint()
  let r = @types.btn_restart()
  let m = @types.btn_menu()

  if game.touch_cd <= 0.0 &&
    @types.pointer_on_rect(mx, my, hold, touch_count, h.0, h.1, h.2, h.3) {
    cycle_hint(game)
    game.touch_cd = 0.16
  }

  if game.touch_cd <= 0.0 &&
    @types.pointer_on_rect(mx, my, hold, touch_count, r.0, r.1, r.2, r.3) {
    start_run(game)
    game.touch_cd = 0.16
    return
  }

  if game.touch_cd <= 0.0 &&
    @types.pointer_on_rect(mx, my, hold, touch_count, m.0, m.1, m.2, m.3) {
    go_title(game)
    game.touch_cd = 0.16
  }
}
