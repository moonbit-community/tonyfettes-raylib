///|
pub fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub fn clampf(v : Float, lo : Float, hi : Float) -> Float {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
pub fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
pub fn sq(v : Float) -> Float {
  v * v
}

///|
pub fn rects_overlap(
  ax : Float,
  ay : Float,
  aw : Float,
  ah : Float,
  bx : Float,
  by : Float,
  bw : Float,
  bh : Float,
) -> Bool {
  ax < bx + bw && ax + aw > bx && ay < by + bh && ay + ah > by
}

///|
pub fn inside_rect(
  px : Float,
  py : Float,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> Bool {
  px >= Float::from_int(x) &&
  px <= Float::from_int(x + w) &&
  py >= Float::from_int(y) &&
  py <= Float::from_int(y + h)
}

///|
pub fn pointer_on_rect(
  mouse_x : Float,
  mouse_y : Float,
  mouse_hold : Bool,
  touch_count : Int,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> Bool {
  if mouse_hold && inside_rect(mouse_x, mouse_y, x, y, w, h) {
    return true
  }

  for i in 0..<touch_count {
    let p = @raylib.get_touch_position(i)
    if inside_rect(p.x, p.y, x, y, w, h) {
      return true
    }
  }

  false
}

///|
pub fn mouse_click_on_rect(
  mouse_x : Float,
  mouse_y : Float,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> Bool {
  @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) &&
  inside_rect(mouse_x, mouse_y, x, y, w, h)
}

///|
pub fn player_rect_at(
  game : Game,
  px : Float,
  py : Float,
) -> (Float, Float, Float, Float) {
  (
    px - game.player.w * 0.5,
    py - game.player.h * 0.5,
    game.player.w,
    game.player.h,
  )
}

///|
pub fn player_hits_rect(
  game : Game,
  x : Float,
  y : Float,
  w : Float,
  h : Float,
) -> Bool {
  let (px, py, pw, ph) = player_rect_at(game, game.player.x, game.player.y)
  rects_overlap(px, py, pw, ph, x, y, w, h)
}

///|
pub fn trap_is_hot(trap : Trap) -> Bool {
  let mut t : Float = trap.timer + trap.phase
  while t >= trap.cycle {
    t = t - trap.cycle
  }
  t < trap.hot_window
}

///|
pub fn exit_unlocked(game : Game) -> Bool {
  game.collected_relics >= game.required_relics
}

///|
pub fn stage_name(index : Int) -> String {
  match index {
    0 => "Sunken Antechamber"
    1 => "Obsidian Gauntlet"
    _ => "Crown Vault"
  }
}

///|
pub fn set_banner(game : Game, text : String, ttl : Float) -> Unit {
  game.banner_text = text
  game.banner_t = ttl
}
