///|
pub fn chamber_right() -> Float {
  chamber_left + chamber_w
}

///|
pub fn chamber_bottom() -> Float {
  chamber_top + chamber_h
}

///|
pub fn chamber_center_x() -> Float {
  chamber_left + chamber_w * 0.5
}

///|
pub fn chamber_center_y() -> Float {
  chamber_top + chamber_h * 0.5
}

///|
pub fn room_name(room : Int) -> String {
  if room == 0 {
    "Ember Archive"
  } else if room == 1 {
    "Vault Core"
  } else {
    "Seal Scriptorium"
  }
}

///|
pub fn breach_anchor_x(room : Int) -> Float {
  if room == 0 {
    chamber_left + chamber_w * 0.82
  } else if room == 1 {
    chamber_left + chamber_w * 0.18
  } else {
    chamber_left + chamber_w * 0.58
  }
}

///|
pub fn breach_anchor_y(room : Int) -> Float {
  if room == 0 {
    chamber_top + chamber_h * 0.24
  } else if room == 1 {
    chamber_top + chamber_h * 0.78
  } else {
    chamber_top + chamber_h * 0.32
  }
}

///|
pub fn vault_core_x() -> Float {
  chamber_left + chamber_w * 0.50
}

///|
pub fn vault_core_y() -> Float {
  chamber_top + chamber_h * 0.52
}

///|
pub fn raider_goal_x(room : Int) -> Float {
  if room < vault_room {
    chamber_right() - 18.0
  } else if room > vault_room {
    chamber_left + 18.0
  } else {
    vault_core_x()
  }
}

///|
pub fn raider_goal_y(room : Int) -> Float {
  if room == vault_room {
    vault_core_y()
  } else {
    door_center_y
  }
}

///|
pub fn wave_duration(wave : Int) -> Float {
  wave_duration_base + Float::from_int(wave - 1) * wave_duration_step
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
pub fn clamp01(v : Float) -> Float {
  clampf(v, 0.0, 1.0)
}

///|
pub fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx = x1 - x0
  let dy = y1 - y0
  dx * dx + dy * dy
}

///|
pub fn sqrtf(v : Float) -> Float {
  if v <= 0.0 {
    0.0
  } else {
    v.sqrt()
  }
}

///|
pub fn randf(lo : Float, hi : Float) -> Float {
  let r = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
pub fn randi(lo : Int, hi : Int) -> Int {
  @raylib.get_random_value(lo, hi)
}
