///|
pub fn clampi(v : Int, lo : Int, hi : Int) -> Int {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
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
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
pub fn sqrtf(v : Float) -> Float {
  v.sqrt()
}

///|
pub fn sinf(v : Float) -> Float {
  Float::from_double(@math.sin(v.to_double()))
}

///|
pub fn cosf(v : Float) -> Float {
  Float::from_double(@math.cos(v.to_double()))
}

///|
pub fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx = x1 - x0
  let dy = y1 - y0
  dx * dx + dy * dy
}

///|
pub fn randf(lo : Float, hi : Float) -> Float {
  let r = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
pub fn arena_left() -> Float {
  Float::from_int(arena_x0)
}

///|
pub fn arena_right() -> Float {
  Float::from_int(arena_x1)
}

///|
pub fn arena_top() -> Float {
  Float::from_int(arena_y0)
}

///|
pub fn arena_bottom() -> Float {
  Float::from_int(arena_y1)
}

///|
pub fn title_start_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 180, screen_h / 2 + 112, 360, 72)
}

///|
pub fn result_restart_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 190, screen_h / 2 + 84, 180, 64)
}

///|
pub fn result_next_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 + 10, screen_h / 2 + 84, 180, 64)
}

///|
pub fn result_title_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 110, screen_h / 2 + 160, 220, 52)
}

///|
pub fn mobile_left_btn() -> (Int, Int, Int, Int) {
  (34, screen_h - 146, 66, 66)
}

///|
pub fn mobile_right_btn() -> (Int, Int, Int, Int) {
  (182, screen_h - 146, 66, 66)
}

///|
pub fn mobile_up_btn() -> (Int, Int, Int, Int) {
  (108, screen_h - 220, 66, 66)
}

///|
pub fn mobile_down_btn() -> (Int, Int, Int, Int) {
  (108, screen_h - 72, 66, 66)
}

///|
pub fn mobile_sonar_btn() -> (Int, Int, Int, Int) {
  (screen_w - 184, screen_h - 152, 148, 66)
}

///|
pub fn mobile_boost_btn() -> (Int, Int, Int, Int) {
  (screen_w - 184, screen_h - 76, 148, 58)
}

///|
pub fn mobile_restart_btn() -> (Int, Int, Int, Int) {
  (screen_w - 148, 20, 128, 46)
}

///|
pub fn in_hot_zone_xy(x : Float, y : Float) -> Bool {
  dist2(x, y, hot_zone_x, hot_zone_y) <= hot_zone_r * hot_zone_r
}

///|
pub fn point_in_rect(
  x : Float,
  y : Float,
  rx : Int,
  ry : Int,
  rw : Int,
  rh : Int,
) -> Bool {
  let x0 = Float::from_int(rx)
  let y0 = Float::from_int(ry)
  let x1 = Float::from_int(rx + rw)
  let y1 = Float::from_int(ry + rh)
  x >= x0 && x <= x1 && y >= y0 && y <= y1
}

///|
pub fn pointer_on_rect(
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
  for i in 0..<touch_count {
    let p = @raylib.get_touch_position(i)
    if point_in_rect(p.x, p.y, rx, ry, rw, rh) {
      return true
    }
  }
  false
}

///|
pub fn nearest_undetected_target(game : Game) -> (Float, Float, Bool) {
  let mut best_x = game.sub_x
  let mut best_y = game.sub_y
  let mut found = false
  let mut best_d : Float = 1_000_000_000.0
  for i in 0..<game.target_goal {
    if not(game.targets[i].active) || game.targets[i].detected {
      continue
    }
    let d = dist2(game.sub_x, game.sub_y, game.targets[i].x, game.targets[i].y)
    if d < best_d {
      best_d = d
      best_x = game.targets[i].x
      best_y = game.targets[i].y
      found = true
    }
  }
  (best_x, best_y, found)
}

///|
pub fn lose_reason_text(game : Game) -> String {
  if game.lose_reason == lose_hull {
    "Hull failure after mine impact"
  } else if game.lose_reason == lose_oxygen {
    "Crew oxygen depleted"
  } else if game.lose_reason == lose_fuel {
    "Fuel reserves exhausted"
  } else {
    "Mission failed"
  }
}
