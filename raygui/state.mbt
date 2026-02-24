// raygui global state, enums, and constants

// Gui control state
///|
pub enum GuiState {
  Normal
  Focused
  Pressed
  Disabled
} derive(Eq, Show)

///|
pub fn GuiState::to_int(self : GuiState) -> Int {
  match self {
    Normal => 0
    Focused => 1
    Pressed => 2
    Disabled => 3
  }
}

// Gui control text alignment

///|
pub const TextAlignLeft : Int = 0

///|
pub const TextAlignCenter : Int = 1

///|
pub const TextAlignRight : Int = 2

// Gui control text vertical alignment

///|
pub const TextAlignTop : Int = 0

///|
pub const TextAlignMiddle : Int = 1

///|
pub const TextAlignBottom : Int = 2

// Gui text wrap mode

///|
pub const TextWrapNone : Int = 0

///|
pub const TextWrapChar : Int = 1

///|
pub const TextWrapWord : Int = 2

// Max values

///|
let max_controls : Int = 16

///|
let max_props_base : Int = 16

///|
let max_props_extended : Int = 8

// Gui controls

///|
pub const ControlDefault : Int = 0

///|
pub const ControlLabel : Int = 1

///|
pub const ControlButton : Int = 2

///|
pub const ControlToggle : Int = 3

///|
pub const ControlSlider : Int = 4

///|
pub const ControlProgressbar : Int = 5

///|
pub const ControlCheckbox : Int = 6

///|
pub const ControlCombobox : Int = 7

///|
pub const ControlDropdownbox : Int = 8

///|
pub const ControlTextbox : Int = 9

///|
pub const ControlValuebox : Int = 10

///|
pub const ControlControl11 : Int = 11

///|
pub const ControlListview : Int = 12

///|
pub const ControlColorpicker : Int = 13

///|
pub const ControlScrollbar : Int = 14

///|
pub const ControlStatusbar : Int = 15

// Gui base properties for every control (0-15)

///|
pub const BorderColorNormal : Int = 0

///|
pub const BaseColorNormal : Int = 1

///|
pub const TextColorNormal : Int = 2

///|
pub const BorderColorFocused : Int = 3

///|
pub const BaseColorFocused : Int = 4

///|
pub const TextColorFocused : Int = 5

///|
pub const BorderColorPressed : Int = 6

///|
pub const BaseColorPressed : Int = 7

///|
pub const TextColorPressed : Int = 8

///|
pub const BorderColorDisabled : Int = 9

///|
pub const BaseColorDisabled : Int = 10

///|
pub const TextColorDisabled : Int = 11

///|
pub const BorderWidth : Int = 12

///|
pub const TextPadding : Int = 13

///|
pub const TextAlignment : Int = 14

// DEFAULT extended properties (16-23)

///|
pub const TextSize : Int = 16

///|
pub const TextSpacing : Int = 17

///|
pub const LineColor : Int = 18

///|
pub const BackgroundColor : Int = 19

///|
pub const TextLineSpacing : Int = 20

///|
pub const TextAlignmentVertical : Int = 21

///|
pub const TextWrapMode : Int = 22

// Toggle properties

///|
pub const GroupPadding : Int = 16

// Slider properties

///|
pub const SliderWidth : Int = 16

///|
pub const SliderPadding : Int = 17

// ProgressBar properties

///|
pub const ProgressPadding : Int = 16

// ScrollBar properties

///|
pub const ArrowsSize : Int = 16

///|
pub const ArrowsVisible : Int = 17

///|
pub const ScrollSliderPadding : Int = 18

///|
pub const ScrollSliderSize : Int = 19

///|
pub const ScrollPadding : Int = 20

///|
pub const ScrollSpeed : Int = 21

// CheckBox properties

///|
pub const CheckPadding : Int = 16

// ComboBox properties

///|
pub const ComboButtonWidth : Int = 16

///|
pub const ComboButtonSpacing : Int = 17

// DropdownBox properties

///|
pub const ArrowPadding : Int = 16

///|
pub const DropdownItemsSpacing : Int = 17

///|
pub const DropdownArrowHidden : Int = 18

///|
pub const DropdownRollUp : Int = 19

// TextBox properties

///|
pub const TextReadonly : Int = 16

// Spinner properties

///|
pub const SpinnerButtonWidth : Int = 16

///|
pub const SpinnerButtonSpacing : Int = 17

// ListView properties

///|
pub const ListItemsHeight : Int = 16

///|
pub const ListItemsSpacing : Int = 17

///|
pub const ScrollbarWidth : Int = 18

///|
pub const ScrollbarSide : Int = 19

///|
pub const ListItemsBorderNormal : Int = 20

///|
pub const ListItemsBorderWidth : Int = 21

// ColorPicker properties

///|
pub const ColorSelectorSize : Int = 16

///|
pub const HuebarWidth : Int = 17

///|
pub const HuebarPadding : Int = 18

///|
pub const HuebarSelectorHeight : Int = 19

///|
pub const HuebarSelectorOverflow : Int = 20

// Scrollbar side

///|
pub const ScrollbarLeftSide : Int = 0

///|
pub const ScrollbarRightSide : Int = 1

// Icon constants

///|
pub const RayguiIconSize : Int = 16

///|
pub const IconTextPadding : Int = 4

// Mouse button

///|
pub const MouseButtonLeft : Int = 0

///|
pub const MouseButtonMiddle : Int = 2

// Key constants (matching raylib key codes)

///|
pub const KeyRight : Int = 262

///|
pub const KeyLeft : Int = 263

///|
pub const KeyDown : Int = 264

///|
pub const KeyUp : Int = 265

///|
pub const KeyBackspace : Int = 259

///|
pub const KeyEnter : Int = 257

///|
pub const KeyDelete : Int = 261

///|
pub const KeyHome : Int = 268

///|
pub const KeyEnd : Int = 269

// --- Global mutable state ---

///|
priv struct GuiGlobals {
  mut state : GuiState
  mut locked : Bool
  mut alpha : Float
  mut icon_scale : Int
  mut tooltip : Bool
  mut tooltip_ptr : String?
  mut control_exclusive_mode : Bool
  mut control_exclusive_rec : @raylib.Rectangle?
  mut text_box_cursor_index : Int
  mut auto_cursor_counter : Int
  mut font : @raylib.Font?
  mut text_edit_mode : Bool
  mut style_loaded : Bool
}

///|
let gui_globals : GuiGlobals = {
  state: GuiState::Normal,
  locked: false,
  alpha: 1.0,
  icon_scale: 1,
  tooltip: false,
  tooltip_ptr: None,
  control_exclusive_mode: false,
  control_exclusive_rec: None,
  text_box_cursor_index: 0,
  auto_cursor_counter: 0,
  font: None,
  text_edit_mode: false,
  style_loaded: false,
}

// --- Public accessor functions ---

///|
pub fn gui_get_state() -> GuiState {
  gui_globals.state
}

///|
pub fn gui_set_state(state : GuiState) -> Unit {
  gui_globals.state = state
}

///|
pub fn gui_enable() -> Unit {
  gui_globals.state = GuiState::Normal
}

///|
pub fn gui_disable() -> Unit {
  gui_globals.state = GuiState::Disabled
}

///|
pub fn gui_is_locked() -> Bool {
  gui_globals.locked
}

///|
pub fn gui_lock() -> Unit {
  gui_globals.locked = true
}

///|
pub fn gui_unlock() -> Unit {
  gui_globals.locked = false
}

///|
pub fn gui_get_alpha() -> Float {
  gui_globals.alpha
}

///|
pub fn gui_set_alpha(alpha : Float) -> Unit {
  let a : Float = if alpha < 0.0 {
    0.0
  } else if alpha > 1.0 {
    1.0
  } else {
    alpha
  }
  gui_globals.alpha = a
}

///|
pub fn gui_enable_tooltip() -> Unit {
  gui_globals.tooltip = true
}

///|
pub fn gui_disable_tooltip() -> Unit {
  gui_globals.tooltip = false
}

///|
pub fn gui_set_tooltip(tooltip : String) -> Unit {
  gui_globals.tooltip_ptr = Some(tooltip)
}

///|
pub fn gui_get_font() -> @raylib.Font {
  match gui_globals.font {
    Some(f) => f
    None => {
      let f = @raylib.get_font_default()
      gui_globals.font = Some(f)
      f
    }
  }
}

///|
pub fn gui_set_font(font : @raylib.Font) -> Unit {
  gui_globals.font = Some(font)
}

///|
pub fn gui_get_icon_scale() -> Int {
  gui_globals.icon_scale
}

///|
pub fn gui_set_icon_scale(scale : Int) -> Unit {
  if scale >= 1 {
    gui_globals.icon_scale = scale
  }
}
