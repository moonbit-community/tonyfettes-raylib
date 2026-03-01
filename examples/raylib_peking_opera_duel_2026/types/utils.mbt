///|
pub fn maxi(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}

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
pub fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
pub fn sinf(v : Float) -> Float {
  Float::from_double(@math.sin(v.to_double()))
}

///|
pub fn stance_name(stance : Int) -> String {
  if stance == stance_spear {
    "Spear Lift"
  } else if stance == stance_fan {
    "Fan Sweep"
  } else if stance == stance_guard {
    "Guard Frame"
  } else {
    "Sleeve Arc"
  }
}

///|
pub fn grade_for_acclaim(acclaim : Int) -> String {
  if acclaim >= 1700 {
    "Legendary Curtain Call"
  } else if acclaim >= 1200 {
    "House Favorite"
  } else if acclaim >= 800 {
    "Respected Ensemble"
  } else {
    "Crowd Unconvinced"
  }
}

///|
pub fn set_message(game : Game, text : String, ttl : Float) -> Unit {
  game.message = text
  game.message_t = ttl
}

///|
pub fn col(r : Int, g : Int, b : Int, a : Int) -> @raylib.Color {
  @raylib.Color::new(r, g, b, a)
}

///|
pub fn stance_color(stance : Int, alpha : Int) -> @raylib.Color {
  if stance == stance_spear {
    col(231, 103, 80, alpha)
  } else if stance == stance_fan {
    col(255, 195, 84, alpha)
  } else if stance == stance_guard {
    col(113, 200, 149, alpha)
  } else {
    col(134, 157, 245, alpha)
  }
}

///|
pub fn lane_to_x(lane_x : Int) -> Int {
  screen_w / 2 + lane_x * lane_step_x
}

///|
pub fn lane_to_y(lane_y : Int) -> Int {
  stage_top + stage_h / 2 + lane_y * lane_step_y
}

///|
pub fn draw_center_text(
  text : String,
  y : Int,
  size : Int,
  tint : @raylib.Color,
) -> Unit {
  let w = @raylib.measure_text(text, size)
  @raylib.draw_text(text, screen_w / 2 - w / 2, y, size, tint)
}
