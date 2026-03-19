// Cursor re-exports

///|
pub using @ffi {
  show_cursor,
  hide_cursor,
  is_cursor_hidden,
  enable_cursor,
  disable_cursor,
  is_cursor_on_screen,
  // Keyboard
  is_key_pressed,
  is_key_pressed_repeat,
  is_key_down,
  is_key_released,
  is_key_up,
  get_key_pressed,
  get_char_pressed,
  set_exit_key,
  // Mouse
  is_mouse_button_pressed,
  is_mouse_button_down,
  is_mouse_button_released,
  is_mouse_button_up,
  get_mouse_x,
  get_mouse_y,
  set_mouse_position,
  set_mouse_offset,
  set_mouse_scale,
  get_mouse_wheel_move,
  set_mouse_cursor,
  // Gamepad
  is_gamepad_available,
  is_gamepad_button_pressed,
  is_gamepad_button_down,
  is_gamepad_button_released,
  is_gamepad_button_up,
  get_gamepad_button_pressed,
  get_gamepad_axis_count,
  get_gamepad_axis_movement,
  set_gamepad_vibration,
  // Touch
  get_touch_x,
  get_touch_y,
  get_touch_point_id,
  get_touch_point_count,
  // Gesture
  set_gestures_enabled,
  is_gesture_detected,
  get_gesture_detected,
  get_gesture_hold_duration,
  get_gesture_drag_angle,
  get_gesture_pinch_angle,
}

// Mouse wrappers

///|
/// Get mouse position XY.
pub fn get_mouse_position() -> Vector2 {
  Vector2::from_bytes(@ffi.get_mouse_position())
}

///|
/// Get mouse delta between frames.
pub fn get_mouse_delta() -> Vector2 {
  Vector2::from_bytes(@ffi.get_mouse_delta())
}

///|
/// Get mouse wheel movement for both X and Y.
pub fn get_mouse_wheel_move_v() -> Vector2 {
  Vector2::from_bytes(@ffi.get_mouse_wheel_move_v())
}

// Gamepad wrappers

///|
/// Get gamepad internal name id.
pub fn get_gamepad_name(gamepad : Int) -> String {
  @utf8.decode_lossy(@ffi.get_gamepad_name(gamepad))
}

///|
/// Set internal gamepad mappings (SDL_GameControllerDB).
pub fn set_gamepad_mappings(mappings : String) -> Int {
  @ffi.set_gamepad_mappings(@utf8.encode(mappings))
}

// Touch wrappers

///|
/// Get touch position XY for a touch point index (relative to screen size).
pub fn get_touch_position(index : Int) -> Vector2 {
  Vector2::from_bytes(@ffi.get_touch_position(index))
}

// Gesture wrappers

///|
/// Get gesture drag vector.
pub fn get_gesture_drag_vector() -> Vector2 {
  Vector2::from_bytes(@ffi.get_gesture_drag_vector())
}

///|
/// Get gesture pinch delta.
pub fn get_gesture_pinch_vector() -> Vector2 {
  Vector2::from_bytes(@ffi.get_gesture_pinch_vector())
}

// Keyboard key constants

///|
/// Key: NULL, used for no key pressed.
pub const KeyNull : Int = 0

///|
/// Key: '
pub const KeyApostrophe : Int = 39

///|
/// Key: ,
pub const KeyComma : Int = 44

///|
/// Key: -
pub const KeyMinus : Int = 45

///|
/// Key: .
pub const KeyPeriod : Int = 46

///|
/// Key: /
pub const KeySlash : Int = 47

///|
/// Key: 0
pub const KeyZero : Int = 48

///|
/// Key: 1
pub const KeyOne : Int = 49

///|
/// Key: 2
pub const KeyTwo : Int = 50

///|
/// Key: 3
pub const KeyThree : Int = 51

///|
/// Key: 4
pub const KeyFour : Int = 52

///|
/// Key: 5
pub const KeyFive : Int = 53

///|
/// Key: 6
pub const KeySix : Int = 54

///|
/// Key: 7
pub const KeySeven : Int = 55

///|
/// Key: 8
pub const KeyEight : Int = 56

///|
/// Key: 9
pub const KeyNine : Int = 57

///|
/// Key: ;
pub const KeySemicolon : Int = 59

///|
/// Key: =
pub const KeyEqual : Int = 61

///|
/// Key: A | a
pub const KeyA : Int = 65

///|
/// Key: B | b
pub const KeyB : Int = 66

///|
/// Key: C | c
pub const KeyC : Int = 67

///|
/// Key: D | d
pub const KeyD : Int = 68

///|
/// Key: E | e
pub const KeyE : Int = 69

///|
/// Key: F | f
pub const KeyF : Int = 70

///|
/// Key: G | g
pub const KeyG : Int = 71

///|
/// Key: H | h
pub const KeyH : Int = 72

///|
/// Key: I | i
pub const KeyI : Int = 73

///|
/// Key: J | j
pub const KeyJ : Int = 74

///|
/// Key: K | k
pub const KeyK : Int = 75

///|
/// Key: L | l
pub const KeyL : Int = 76

///|
/// Key: M | m
pub const KeyM : Int = 77

///|
/// Key: N | n
pub const KeyN : Int = 78

///|
/// Key: O | o
pub const KeyO : Int = 79

///|
/// Key: P | p
pub const KeyP : Int = 80

///|
/// Key: Q | q
pub const KeyQ : Int = 81

///|
/// Key: R | r
pub const KeyR : Int = 82

///|
/// Key: S | s
pub const KeyS : Int = 83

///|
/// Key: T | t
pub const KeyT : Int = 84

///|
/// Key: U | u
pub const KeyU : Int = 85

///|
/// Key: V | v
pub const KeyV : Int = 86

///|
/// Key: W | w
pub const KeyW : Int = 87

///|
/// Key: X | x
pub const KeyX : Int = 88

///|
/// Key: Y | y
pub const KeyY : Int = 89

///|
/// Key: Z | z
pub const KeyZ : Int = 90

///|
/// Key: [
pub const KeyLeftBracket : Int = 91

///|
/// Key: '\'
pub const KeyBackslash : Int = 92

///|
/// Key: ]
pub const KeyRightBracket : Int = 93

///|
/// Key: `
pub const KeyGrave : Int = 96

///|
/// Key: Space
pub const KeySpace : Int = 32

///|
/// Key: Esc
pub const KeyEscape : Int = 256

///|
/// Key: Enter
pub const KeyEnter : Int = 257

///|
/// Key: Tab
pub const KeyTab : Int = 258

///|
/// Key: Backspace
pub const KeyBackspace : Int = 259

///|
/// Key: Ins
pub const KeyInsert : Int = 260

///|
/// Key: Del
pub const KeyDelete : Int = 261

///|
/// Key: Cursor right
pub const KeyRight : Int = 262

///|
/// Key: Cursor left
pub const KeyLeft : Int = 263

///|
/// Key: Cursor down
pub const KeyDown : Int = 264

///|
/// Key: Cursor up
pub const KeyUp : Int = 265

///|
/// Key: Page up
pub const KeyPageUp : Int = 266

///|
/// Key: Page down
pub const KeyPageDown : Int = 267

///|
/// Key: Home
pub const KeyHome : Int = 268

///|
/// Key: End
pub const KeyEnd : Int = 269

///|
/// Key: Caps lock
pub const KeyCapsLock : Int = 280

///|
/// Key: Scroll down
pub const KeyScrollLock : Int = 281

///|
/// Key: Num lock
pub const KeyNumLock : Int = 282

///|
/// Key: Print screen
pub const KeyPrintScreen : Int = 283

///|
/// Key: Pause
pub const KeyPause : Int = 284

///|
/// Key: F1
pub const KeyF1 : Int = 290

///|
/// Key: F2
pub const KeyF2 : Int = 291

///|
/// Key: F3
pub const KeyF3 : Int = 292

///|
/// Key: F4
pub const KeyF4 : Int = 293

///|
/// Key: F5
pub const KeyF5 : Int = 294

///|
/// Key: F6
pub const KeyF6 : Int = 295

///|
/// Key: F7
pub const KeyF7 : Int = 296

///|
/// Key: F8
pub const KeyF8 : Int = 297

///|
/// Key: F9
pub const KeyF9 : Int = 298

///|
/// Key: F10
pub const KeyF10 : Int = 299

///|
/// Key: F11
pub const KeyF11 : Int = 300

///|
/// Key: F12
pub const KeyF12 : Int = 301

///|
/// Key: Shift left
pub const KeyLeftShift : Int = 340

///|
/// Key: Control left
pub const KeyLeftControl : Int = 341

///|
/// Key: Alt left
pub const KeyLeftAlt : Int = 342

///|
/// Key: Super left
pub const KeyLeftSuper : Int = 343

///|
/// Key: Shift right
pub const KeyRightShift : Int = 344

///|
/// Key: Control right
pub const KeyRightControl : Int = 345

///|
/// Key: Alt right
pub const KeyRightAlt : Int = 346

///|
/// Key: Super right
pub const KeyRightSuper : Int = 347

///|
/// Key: KB menu
pub const KeyKbMenu : Int = 348

///|
/// Key: Keypad 0
pub const KeyKp0 : Int = 320

///|
/// Key: Keypad 1
pub const KeyKp1 : Int = 321

///|
/// Key: Keypad 2
pub const KeyKp2 : Int = 322

///|
/// Key: Keypad 3
pub const KeyKp3 : Int = 323

///|
/// Key: Keypad 4
pub const KeyKp4 : Int = 324

///|
/// Key: Keypad 5
pub const KeyKp5 : Int = 325

///|
/// Key: Keypad 6
pub const KeyKp6 : Int = 326

///|
/// Key: Keypad 7
pub const KeyKp7 : Int = 327

///|
/// Key: Keypad 8
pub const KeyKp8 : Int = 328

///|
/// Key: Keypad 9
pub const KeyKp9 : Int = 329

// Mouse button constants

///|
/// Mouse button: left
pub const MouseButtonLeft : Int = 0

///|
/// Mouse button: right
pub const MouseButtonRight : Int = 1

///|
/// Mouse button: middle (pressed wheel)
pub const MouseButtonMiddle : Int = 2

///|
/// Mouse button: side (advanced mouse device)
pub const MouseButtonSide : Int = 3

///|
/// Mouse button: extra (advanced mouse device)
pub const MouseButtonExtra : Int = 4

///|
/// Mouse button: forward (advanced mouse device)
pub const MouseButtonForward : Int = 5

///|
/// Mouse button: back (advanced mouse device)
pub const MouseButtonBack : Int = 6

// Mouse cursor type constants

///|
/// Mouse cursor: default pointer shape
pub const MouseCursorDefault : Int = 0

///|
/// Mouse cursor: arrow shape
pub const MouseCursorArrow : Int = 1

///|
/// Mouse cursor: text writing cursor shape
pub const MouseCursorIbeam : Int = 2

///|
/// Mouse cursor: cross shape
pub const MouseCursorCrosshair : Int = 3

///|
/// Mouse cursor: pointing hand cursor
pub const MouseCursorPointingHand : Int = 4

///|
/// Mouse cursor: horizontal resize/move arrow shape
pub const MouseCursorResizeEw : Int = 5

///|
/// Mouse cursor: vertical resize/move arrow shape
pub const MouseCursorResizeNs : Int = 6

///|
/// Mouse cursor: top-left to bottom-right diagonal resize/move arrow shape
pub const MouseCursorResizeNwse : Int = 7

///|
/// Mouse cursor: top-right to bottom-left diagonal resize/move arrow shape
pub const MouseCursorResizeNesw : Int = 8

///|
/// Mouse cursor: omnidirectional resize/move cursor shape
pub const MouseCursorResizeAll : Int = 9

///|
/// Mouse cursor: operation-not-allowed shape
pub const MouseCursorNotAllowed : Int = 10

// Gamepad button constants

///|
/// Gamepad button: unknown, just for error checking
pub const GamepadButtonUnknown : Int = 0

///|
/// Gamepad button: left DPAD up
pub const GamepadButtonLeftFaceUp : Int = 1

///|
/// Gamepad button: left DPAD right
pub const GamepadButtonLeftFaceRight : Int = 2

///|
/// Gamepad button: left DPAD down
pub const GamepadButtonLeftFaceDown : Int = 3

///|
/// Gamepad button: left DPAD left
pub const GamepadButtonLeftFaceLeft : Int = 4

///|
/// Gamepad button: center buttons, left one (i.e. PS3: Select)
pub const GamepadButtonMiddleLeft : Int = 5

///|
/// Gamepad button: center buttons, middle one (i.e. PS3: PS, Xbox: XBOX)
pub const GamepadButtonMiddle : Int = 6

///|
/// Gamepad button: center buttons, right one (i.e. PS3: Start)
pub const GamepadButtonMiddleRight : Int = 7

///|
/// Gamepad button: right button up (i.e. PS3: Triangle, Xbox: Y)
pub const GamepadButtonRightFaceUp : Int = 8

///|
/// Gamepad button: right button right (i.e. PS3: Circle, Xbox: B)
pub const GamepadButtonRightFaceRight : Int = 9

///|
/// Gamepad button: right button down (i.e. PS3: Cross, Xbox: A)
pub const GamepadButtonRightFaceDown : Int = 10

///|
/// Gamepad button: right button left (i.e. PS3: Square, Xbox: X)
pub const GamepadButtonRightFaceLeft : Int = 11

///|
/// Gamepad button: top/back trigger left (first)
pub const GamepadButtonLeftTrigger1 : Int = 12

///|
/// Gamepad button: top/back trigger left (second)
pub const GamepadButtonLeftTrigger2 : Int = 13

///|
/// Gamepad button: top/back trigger right (first)
pub const GamepadButtonRightTrigger1 : Int = 14

///|
/// Gamepad button: top/back trigger right (second)
pub const GamepadButtonRightTrigger2 : Int = 15

///|
/// Gamepad button: joystick pressed button left
pub const GamepadButtonLeftThumb : Int = 16

///|
/// Gamepad button: joystick pressed button right
pub const GamepadButtonRightThumb : Int = 17

// Gamepad axis constants

///|
/// Gamepad axis: left stick X
pub const GamepadAxisLeftX : Int = 0

///|
/// Gamepad axis: left stick Y
pub const GamepadAxisLeftY : Int = 1

///|
/// Gamepad axis: right stick X
pub const GamepadAxisRightX : Int = 2

///|
/// Gamepad axis: right stick Y
pub const GamepadAxisRightY : Int = 3

///|
/// Gamepad axis: back trigger left, pressure level: [1..-1]
pub const GamepadAxisLeftTrigger : Int = 4

///|
/// Gamepad axis: back trigger right, pressure level: [1..-1]
pub const GamepadAxisRightTrigger : Int = 5

// Gesture constants

///|
/// Gesture: no gesture
pub const GestureNone : Int = 0

///|
/// Gesture: tap
pub const GestureTap : Int = 1

///|
/// Gesture: double tap
pub const GestureDoubletap : Int = 2

///|
/// Gesture: hold
pub const GestureHold : Int = 4

///|
/// Gesture: drag
pub const GestureDrag : Int = 8

///|
/// Gesture: swipe right
pub const GestureSwipeRight : Int = 16

///|
/// Gesture: swipe left
pub const GestureSwipeLeft : Int = 32

///|
/// Gesture: swipe up
pub const GestureSwipeUp : Int = 64

///|
/// Gesture: swipe down
pub const GestureSwipeDown : Int = 128

///|
/// Gesture: pinch in
pub const GesturePinchIn : Int = 256

///|
/// Gesture: pinch out
pub const GesturePinchOut : Int = 512
