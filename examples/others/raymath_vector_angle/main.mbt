///|
let pi : Float = 3.14159265358979323846

///|
let rad2deg : Float = 180.0 / pi

///|
fn vec2_add(v1 : @raylib.Vector2, v2 : @raylib.Vector2) -> @raylib.Vector2 {
  @raylib.Vector2::new(v1.x + v2.x, v1.y + v2.y)
}

///|
fn vec2_sub(v1 : @raylib.Vector2, v2 : @raylib.Vector2) -> @raylib.Vector2 {
  @raylib.Vector2::new(v1.x - v2.x, v1.y - v2.y)
}

///|
fn vec2_normalize(v : @raylib.Vector2) -> @raylib.Vector2 {
  let len = (v.x * v.x + v.y * v.y).sqrt()
  if len > 0.0 {
    @raylib.Vector2::new(v.x / len, v.y / len)
  } else {
    @raylib.Vector2::new(0.0, 0.0)
  }
}

///|
fn vec2_angle(v1 : @raylib.Vector2, v2 : @raylib.Vector2) -> Float {
  @math.atan2f(v1.x * v2.y - v1.y * v2.x, v1.x * v2.x + v1.y * v2.y)
}

///|
fn vec2_line_angle(start : @raylib.Vector2, end_ : @raylib.Vector2) -> Float {
  -@math.atan2f(end_.y - start.y, end_.x - start.x)
}

///|
fn main {
  let screen_width = 800
  let screen_height = 450

  @raylib.init_window(
    screen_width, screen_height, "raylib [math] example - vector angle",
  )

  let v0 = @raylib.Vector2::new(
    Float::from_int(screen_width / 2),
    Float::from_int(screen_height / 2),
  )
  let mut v1 = vec2_add(v0, @raylib.Vector2::new(100.0, 80.0))
  let mut v2 = @raylib.Vector2::new(0.0, 0.0)

  let mut angle : Float = 0.0
  let mut angle_mode = 0 // 0-Vector2Angle(), 1-Vector2LineAngle()

  @raylib.set_target_fps(60)

  while not(@raylib.window_should_close()) {
    let mut startangle : Float = 0.0

    if angle_mode == 0 {
      startangle = -vec2_line_angle(v0, v1) * rad2deg
    }
    if angle_mode == 1 {
      startangle = 0.0
    }

    v2 = @raylib.get_mouse_position()

    if @raylib.is_key_pressed(@raylib.KeySpace) {
      if angle_mode == 0 {
        angle_mode = 1
      } else {
        angle_mode = 0
      }
    }

    if angle_mode == 0 && @raylib.is_mouse_button_down(@raylib.MouseButtonRight) {
      v1 = @raylib.get_mouse_position()
    }

    if angle_mode == 0 {
      let v1_normal = vec2_normalize(vec2_sub(v1, v0))
      let v2_normal = vec2_normalize(vec2_sub(v2, v0))
      angle = vec2_angle(v1_normal, v2_normal) * rad2deg
    } else if angle_mode == 1 {
      angle = vec2_line_angle(v0, v2) * rad2deg
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    if angle_mode == 0 {
      @raylib.draw_text(
        "MODE 0: Angle between V1 and V2", 10, 10, 20, @raylib.black,
      )
      @raylib.draw_text("Right Click to Move V2", 10, 30, 20, @raylib.darkgray)
      @raylib.draw_line_ex(v0, v1, 2.0, @raylib.black)
      @raylib.draw_line_ex(v0, v2, 2.0, @raylib.red)
      @raylib.draw_circle_sector(
        v0,
        40.0,
        startangle,
        startangle + angle,
        32,
        @raylib.fade(@raylib.green, 0.6),
      )
    } else if angle_mode == 1 {
      @raylib.draw_text(
        "MODE 1: Angle formed by line V1 to V2", 10, 10, 20, @raylib.black,
      )
      @raylib.draw_line(
        0,
        screen_height / 2,
        screen_width,
        screen_height / 2,
        @raylib.lightgray,
      )
      @raylib.draw_line_ex(v0, v2, 2.0, @raylib.red)
      @raylib.draw_circle_sector(
        v0,
        40.0,
        startangle,
        startangle - angle,
        32,
        @raylib.fade(@raylib.green, 0.6),
      )
    }

    @raylib.draw_text("v0", v0.x.to_int(), v0.y.to_int(), 10, @raylib.darkgray)

    if angle_mode == 0 && vec2_sub(v0, v1).y > 0.0 {
      @raylib.draw_text(
        "v1",
        v1.x.to_int(),
        v1.y.to_int() - 10,
        10,
        @raylib.darkgray,
      )
    }
    if angle_mode == 0 && vec2_sub(v0, v1).y < 0.0 {
      @raylib.draw_text(
        "v1",
        v1.x.to_int(),
        v1.y.to_int(),
        10,
        @raylib.darkgray,
      )
    }
    if angle_mode == 1 {
      @raylib.draw_text(
        "v1",
        v0.x.to_int() + 40,
        v0.y.to_int(),
        10,
        @raylib.darkgray,
      )
    }

    @raylib.draw_text(
      "v2",
      v2.x.to_int() - 10,
      v2.y.to_int() - 10,
      10,
      @raylib.darkgray,
    )
    @raylib.draw_text(
      "Press SPACE to change MODE", 460, 10, 20, @raylib.darkgray,
    )

    // Format angle with 2 decimal places
    let angle_int = angle.to_int()
    let angle_frac = ((angle - Float::from_int(angle_int)).abs() * 100.0).to_int()
    let sign = if angle < 0.0 { "-" } else { "" }
    @raylib.draw_text(
      "ANGLE: \{sign}\{angle_int.abs()}.\{angle_frac}",
      10,
      70,
      20,
      @raylib.lime,
    )

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
