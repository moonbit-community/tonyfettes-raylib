///|
pub fn mini(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

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
pub fn absi(v : Int) -> Int {
  if v < 0 {
    -v
  } else {
    v
  }
}

///|
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

///|
pub fn sinf(v : Float) -> Float {
  Float::from_double(@math.sin(v.to_double()))
}

///|
pub fn randf(lo : Float, hi : Float) -> Float {
  let r : Float = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
pub fn manhattan(x0 : Int, y0 : Int, x1 : Int, y1 : Int) -> Int {
  absi(x1 - x0) + absi(y1 - y0)
}

///|
pub fn board_px(x : Int) -> Int {
  board_x0 + x * cell
}

///|
pub fn board_py(y : Int) -> Int {
  board_y0 + y * cell
}

///|
pub fn cell_center_x(x : Float) -> Int {
  board_x0 + (x * Float::from_int(cell)).to_int() + cell / 2
}

///|
pub fn cell_center_y(y : Float) -> Int {
  board_y0 + (y * Float::from_int(cell)).to_int() + cell / 2
}

///|
pub fn start_button_rect() -> (Int, Int, Int, Int) {
  (panel_x0 + 26, screen_h - 192, panel_w - 52, 72)
}

///|
pub fn retry_button_rect() -> (Int, Int, Int, Int) {
  (panel_x0 + 26, screen_h - 192, panel_w - 52, 72)
}

///|
pub fn btn_left() -> (Int, Int, Int, Int) {
  let x0 : Int = 38
  let y0 : Int = screen_h - 244
  (x0, y0 + 72, 78, 78)
}

///|
pub fn btn_right() -> (Int, Int, Int, Int) {
  let x0 : Int = 38
  let y0 : Int = screen_h - 244
  (x0 + 156, y0 + 72, 78, 78)
}

///|
pub fn btn_up() -> (Int, Int, Int, Int) {
  let x0 : Int = 38
  let y0 : Int = screen_h - 244
  (x0 + 78, y0, 78, 78)
}

///|
pub fn btn_down() -> (Int, Int, Int, Int) {
  let x0 : Int = 38
  let y0 : Int = screen_h - 244
  (x0 + 78, y0 + 144, 78, 78)
}

///|
pub fn btn_action() -> (Int, Int, Int, Int) {
  (screen_w - 192, screen_h - 226, 128, 128)
}

///|
pub fn btn_hint() -> (Int, Int, Int, Int) {
  (screen_w - 338, screen_h - 182, 118, 70)
}

///|
pub fn btn_restart() -> (Int, Int, Int, Int) {
  (screen_w - 338, screen_h - 266, 118, 70)
}

///|
pub fn btn_menu() -> (Int, Int, Int, Int) {
  (screen_w - 338, screen_h - 350, 118, 70)
}

///|
pub fn hint_text(i : Int) -> String {
  if i == 0 {
    "Recover 6 energy cores to power the portal network."
  } else if i == 1 {
    "Action near portal teleports; action elsewhere drops flare EMP."
  } else if i == 2 {
    "Flares reveal darkness and stun nearby drones briefly."
  } else {
    "Exit gate unlocks only after portal power reaches 100%."
  }
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
  let x0 : Float = Float::from_int(rx)
  let y0 : Float = Float::from_int(ry)
  let x1 : Float = Float::from_int(rx + rw)
  let y1 : Float = Float::from_int(ry + rh)
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
