///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [core] example - input gestures",
  )
  let touch_area = @raylib.Rectangle::new(
    220.0,
    10.0,
    Float::from_int(screen_width) - 230.0,
    Float::from_int(screen_height) - 20.0,
  )
  let gesture_strings : Array[String] = []
  let max_gesture_strings = 20
  let mut current_gesture = @raylib.GestureNone
  let mut last_gesture = @raylib.GestureNone
  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    last_gesture = current_gesture
    current_gesture = @raylib.get_gesture_detected()
    let touch_position = @raylib.get_touch_position(0)
    if @raylib.check_collision_point_rec(touch_position, touch_area) &&
      current_gesture != @raylib.GestureNone {
      if current_gesture != last_gesture {
        // Store gesture string
        let gesture_str = if current_gesture == @raylib.GestureTap {
          "GESTURE TAP"
        } else if current_gesture == @raylib.GestureDoubletap {
          "GESTURE DOUBLETAP"
        } else if current_gesture == @raylib.GestureHold {
          "GESTURE HOLD"
        } else if current_gesture == @raylib.GestureDrag {
          "GESTURE DRAG"
        } else if current_gesture == @raylib.GestureSwipeRight {
          "GESTURE SWIPE RIGHT"
        } else if current_gesture == @raylib.GestureSwipeLeft {
          "GESTURE SWIPE LEFT"
        } else if current_gesture == @raylib.GestureSwipeUp {
          "GESTURE SWIPE UP"
        } else if current_gesture == @raylib.GestureSwipeDown {
          "GESTURE SWIPE DOWN"
        } else if current_gesture == @raylib.GesturePinchIn {
          "GESTURE PINCH IN"
        } else if current_gesture == @raylib.GesturePinchOut {
          "GESTURE PINCH OUT"
        } else {
          ""
        }
        if gesture_str.length() > 0 {
          gesture_strings.push(gesture_str)
          // Reset gestures strings if max reached
          if gesture_strings.length() >= max_gesture_strings {
            gesture_strings.clear()
          }
        }
      }
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.draw_rectangle_rec(touch_area, @raylib.gray)
    @raylib.draw_rectangle(
      225,
      15,
      screen_width - 240,
      screen_height - 30,
      @raylib.raywhite,
    )
    @raylib.draw_text(
      "GESTURES TEST AREA",
      screen_width - 270,
      screen_height - 40,
      20,
      @raylib.fade(@raylib.gray, 0.5),
    )
    for i = 0; i < gesture_strings.length(); i = i + 1 {
      if i % 2 == 0 {
        @raylib.draw_rectangle(
          10,
          30 + 20 * i,
          200,
          20,
          @raylib.fade(@raylib.lightgray, 0.5),
        )
      } else {
        @raylib.draw_rectangle(
          10,
          30 + 20 * i,
          200,
          20,
          @raylib.fade(@raylib.lightgray, 0.3),
        )
      }
      if i < gesture_strings.length() - 1 {
        @raylib.draw_text(
          gesture_strings[i],
          35,
          36 + 20 * i,
          10,
          @raylib.darkgray,
        )
      } else {
        @raylib.draw_text(
          gesture_strings[i],
          35,
          36 + 20 * i,
          10,
          @raylib.maroon,
        )
      }
    }
    @raylib.draw_rectangle_lines(10, 29, 200, screen_height - 50, @raylib.gray)
    @raylib.draw_text("DETECTED GESTURES", 50, 15, 10, @raylib.gray)
    if current_gesture != @raylib.GestureNone {
      @raylib.draw_circle_v(touch_position, 30.0, @raylib.maroon)
    }
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
