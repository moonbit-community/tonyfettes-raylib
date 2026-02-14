// Cursor re-exports

///|
pub using @raylib {
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
}

// Mouse wrappers

///|
pub fn get_mouse_position() -> Vector2 {
  Vector2::from_bytes(@raylib.get_mouse_position())
}

///|
pub fn get_mouse_delta() -> Vector2 {
  Vector2::from_bytes(@raylib.get_mouse_delta())
}

///|
pub fn get_mouse_wheel_move_v() -> Vector2 {
  Vector2::from_bytes(@raylib.get_mouse_wheel_move_v())
}

// Keyboard key constants

///|
pub const KeyNull : Int = 0

///|
pub const KeyApostrophe : Int = 39

///|
pub const KeyComma : Int = 44

///|
pub const KeyMinus : Int = 45

///|
pub const KeyPeriod : Int = 46

///|
pub const KeySlash : Int = 47

///|
pub const KeyZero : Int = 48

///|
pub const KeyOne : Int = 49

///|
pub const KeyTwo : Int = 50

///|
pub const KeyThree : Int = 51

///|
pub const KeyFour : Int = 52

///|
pub const KeyFive : Int = 53

///|
pub const KeySix : Int = 54

///|
pub const KeySeven : Int = 55

///|
pub const KeyEight : Int = 56

///|
pub const KeyNine : Int = 57

///|
pub const KeySemicolon : Int = 59

///|
pub const KeyEqual : Int = 61

///|
pub const KeyA : Int = 65

///|
pub const KeyB : Int = 66

///|
pub const KeyC : Int = 67

///|
pub const KeyD : Int = 68

///|
pub const KeyE : Int = 69

///|
pub const KeyF : Int = 70

///|
pub const KeyG : Int = 71

///|
pub const KeyH : Int = 72

///|
pub const KeyI : Int = 73

///|
pub const KeyJ : Int = 74

///|
pub const KeyK : Int = 75

///|
pub const KeyL : Int = 76

///|
pub const KeyM : Int = 77

///|
pub const KeyN : Int = 78

///|
pub const KeyO : Int = 79

///|
pub const KeyP : Int = 80

///|
pub const KeyQ : Int = 81

///|
pub const KeyR : Int = 82

///|
pub const KeyS : Int = 83

///|
pub const KeyT : Int = 84

///|
pub const KeyU : Int = 85

///|
pub const KeyV : Int = 86

///|
pub const KeyW : Int = 87

///|
pub const KeyX : Int = 88

///|
pub const KeyY : Int = 89

///|
pub const KeyZ : Int = 90

///|
pub const KeyLeftBracket : Int = 91

///|
pub const KeyBackslash : Int = 92

///|
pub const KeyRightBracket : Int = 93

///|
pub const KeyGrave : Int = 96

///|
pub const KeySpace : Int = 32

///|
pub const KeyEscape : Int = 256

///|
pub const KeyEnter : Int = 257

///|
pub const KeyTab : Int = 258

///|
pub const KeyBackspace : Int = 259

///|
pub const KeyInsert : Int = 260

///|
pub const KeyDelete : Int = 261

///|
pub const KeyRight : Int = 262

///|
pub const KeyLeft : Int = 263

///|
pub const KeyDown : Int = 264

///|
pub const KeyUp : Int = 265

///|
pub const KeyPageUp : Int = 266

///|
pub const KeyPageDown : Int = 267

///|
pub const KeyHome : Int = 268

///|
pub const KeyEnd : Int = 269

///|
pub const KeyCapsLock : Int = 280

///|
pub const KeyScrollLock : Int = 281

///|
pub const KeyNumLock : Int = 282

///|
pub const KeyPrintScreen : Int = 283

///|
pub const KeyPause : Int = 284

///|
pub const KeyF1 : Int = 290

///|
pub const KeyF2 : Int = 291

///|
pub const KeyF3 : Int = 292

///|
pub const KeyF4 : Int = 293

///|
pub const KeyF5 : Int = 294

///|
pub const KeyF6 : Int = 295

///|
pub const KeyF7 : Int = 296

///|
pub const KeyF8 : Int = 297

///|
pub const KeyF9 : Int = 298

///|
pub const KeyF10 : Int = 299

///|
pub const KeyF11 : Int = 300

///|
pub const KeyF12 : Int = 301

///|
pub const KeyLeftShift : Int = 340

///|
pub const KeyLeftControl : Int = 341

///|
pub const KeyLeftAlt : Int = 342

///|
pub const KeyLeftSuper : Int = 343

///|
pub const KeyRightShift : Int = 344

///|
pub const KeyRightControl : Int = 345

///|
pub const KeyRightAlt : Int = 346

///|
pub const KeyRightSuper : Int = 347

///|
pub const KeyKbMenu : Int = 348

///|
pub const KeyKp0 : Int = 320

///|
pub const KeyKp1 : Int = 321

///|
pub const KeyKp2 : Int = 322

///|
pub const KeyKp3 : Int = 323

///|
pub const KeyKp4 : Int = 324

///|
pub const KeyKp5 : Int = 325

///|
pub const KeyKp6 : Int = 326

///|
pub const KeyKp7 : Int = 327

///|
pub const KeyKp8 : Int = 328

///|
pub const KeyKp9 : Int = 329

// Mouse button constants

///|
pub const MouseButtonLeft : Int = 0

///|
pub const MouseButtonRight : Int = 1

///|
pub const MouseButtonMiddle : Int = 2

///|
pub const MouseButtonSide : Int = 3

///|
pub const MouseButtonExtra : Int = 4

///|
pub const MouseButtonForward : Int = 5

///|
pub const MouseButtonBack : Int = 6

// Mouse cursor type constants

///|
pub const MouseCursorDefault : Int = 0

///|
pub const MouseCursorArrow : Int = 1

///|
pub const MouseCursorIbeam : Int = 2

///|
pub const MouseCursorCrosshair : Int = 3

///|
pub const MouseCursorPointingHand : Int = 4

///|
pub const MouseCursorResizeEw : Int = 5

///|
pub const MouseCursorResizeNs : Int = 6

///|
pub const MouseCursorResizeNwse : Int = 7

///|
pub const MouseCursorResizeNesw : Int = 8

///|
pub const MouseCursorResizeAll : Int = 9

///|
pub const MouseCursorNotAllowed : Int = 10

// Gesture constants

///|
pub const GestureNone : Int = 0

///|
pub const GestureTap : Int = 1

///|
pub const GestureDoubletap : Int = 2

///|
pub const GestureHold : Int = 4

///|
pub const GestureDrag : Int = 8

///|
pub const GestureSwipeRight : Int = 16

///|
pub const GestureSwipeLeft : Int = 32

///|
pub const GestureSwipeUp : Int = 64

///|
pub const GestureSwipeDown : Int = 128

///|
pub const GesturePinchIn : Int = 256

///|
pub const GesturePinchOut : Int = 512
