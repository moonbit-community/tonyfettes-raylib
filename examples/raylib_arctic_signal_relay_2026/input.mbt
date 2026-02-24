///|
fn pointer_on_rect(
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
  rx : Int,
  ry : Int,
  rw : Int,
  rh : Int,
) -> Bool {
  if hold && point_in_rect(mx, my, rx, ry, rw, rh) {
    return true
  }

  for i = 0; i < touch_count; i = i + 1 {
    let p = @raylib.get_touch_position(i)
    if point_in_rect(p.x, p.y, rx, ry, rw, rh) {
      return true
    }
  }

  false
}

///|
fn clear_input(game : Game) -> Unit {
  game.input_x = 0.0
  game.input_y = 0.0
  game.input_action_press = false
  game.input_start_press = false
  game.input_next_press = false
  game.input_restart_press = false
}

///|
fn update_title_input(
  game : Game,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  clear_input(game)
  game.touch_mode = touch_count > 0

  let start_btn = title_start_rect()
  let hover = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    start_btn.0,
    start_btn.1,
    start_btn.2,
    start_btn.3,
  )

  let key_start = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace)

  let mouse_start = @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) &&
    point_in_rect(mx, my, start_btn.0, start_btn.1, start_btn.2, start_btn.3)

  let touch_start = hover && not(game.touch_start_prev)

  game.input_start_press = key_start || mouse_start || touch_start

  game.touch_start_prev = hover
  game.touch_action_prev = false
  game.touch_next_prev = false
  game.touch_restart_prev = false
}

///|
fn update_play_input(
  game : Game,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  clear_input(game)
  game.touch_mode = touch_count > 0

  let left_btn = touch_left_rect()
  let right_btn = touch_right_rect()
  let up_btn = touch_up_rect()
  let down_btn = touch_down_rect()
  let action_btn = touch_action_rect()

  let mut move_x : Float = 0.0
  let mut move_y : Float = 0.0

  let key_left = @raylib.is_key_down(@raylib.KeyA) ||
    @raylib.is_key_down(@raylib.KeyLeft)
  let key_right = @raylib.is_key_down(@raylib.KeyD) ||
    @raylib.is_key_down(@raylib.KeyRight)
  let key_up = @raylib.is_key_down(@raylib.KeyW) ||
    @raylib.is_key_down(@raylib.KeyUp)
  let key_down = @raylib.is_key_down(@raylib.KeyS) ||
    @raylib.is_key_down(@raylib.KeyDown)

  let t_left = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    left_btn.0,
    left_btn.1,
    left_btn.2,
    left_btn.3,
  )
  let t_right = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    right_btn.0,
    right_btn.1,
    right_btn.2,
    right_btn.3,
  )
  let t_up = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    up_btn.0,
    up_btn.1,
    up_btn.2,
    up_btn.3,
  )
  let t_down = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    down_btn.0,
    down_btn.1,
    down_btn.2,
    down_btn.3,
  )

  if key_left || t_left {
    move_x = move_x - 1.0
  }
  if key_right || t_right {
    move_x = move_x + 1.0
  }
  if key_up || t_up {
    move_y = move_y - 1.0
  }
  if key_down || t_down {
    move_y = move_y + 1.0
  }

  game.input_x = clampf(move_x, -1.0, 1.0)
  game.input_y = clampf(move_y, -1.0, 1.0)

  let action_hover = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    action_btn.0,
    action_btn.1,
    action_btn.2,
    action_btn.3,
  )

  let key_action = @raylib.is_key_pressed(@raylib.KeyE) ||
    @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyEnter)

  let mouse_action = @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) &&
    point_in_rect(mx, my, world_x0, world_y0, world_w, world_h)

  let touch_action = action_hover && not(game.touch_action_prev)

  game.input_action_press = key_action || mouse_action || touch_action

  game.touch_start_prev = false
  game.touch_action_prev = action_hover
  game.touch_next_prev = false
  game.touch_restart_prev = false
}

///|
fn update_result_input(
  game : Game,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  clear_input(game)
  game.touch_mode = touch_count > 0

  let primary = result_primary_rect()
  let secondary = result_secondary_rect()

  let primary_hover = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    primary.0,
    primary.1,
    primary.2,
    primary.3,
  )

  let secondary_hover = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    secondary.0,
    secondary.1,
    secondary.2,
    secondary.3,
  )

  let key_next = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace)
  let key_restart = @raylib.is_key_pressed(@raylib.KeyR)

  let mouse_next = @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) &&
    point_in_rect(mx, my, primary.0, primary.1, primary.2, primary.3)

  let mouse_restart = @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) &&
    point_in_rect(mx, my, secondary.0, secondary.1, secondary.2, secondary.3)

  let touch_next = primary_hover && not(game.touch_next_prev)
  let touch_restart = secondary_hover && not(game.touch_restart_prev)

  game.input_next_press = key_next || mouse_next || touch_next
  game.input_restart_press = key_restart || mouse_restart || touch_restart

  game.touch_start_prev = false
  game.touch_action_prev = false
  game.touch_next_prev = primary_hover
  game.touch_restart_prev = secondary_hover
}
