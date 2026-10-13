// raygui global state, enums, and constants

// Gui control state

///|
pub(all) enum GuiState {
  Normal
  Focused
  Pressed
  Disabled
} derive(Eq, Debug)

///|
pub extend GuiState with Eq::{not_equal, equal}

///|
pub extend GuiState with @debug.Debug::{to_repr}

///|
pub fn GuiState::to_int(self : GuiState) -> Int32 {
  match self {
    Normal => 0
    Focused => 1
    Pressed => 2
    Disabled => 3
  }
}

// Gui control text alignment

///|
pub const TextAlignLeft : Int32 = 0

///|
pub const TextAlignCenter : Int32 = 1

///|
pub const TextAlignRight : Int32 = 2

// Gui control text vertical alignment

///|
pub const TextAlignTop : Int32 = 0

///|
pub const TextAlignMiddle : Int32 = 1

///|
pub const TextAlignBottom : Int32 = 2

// Gui text wrap mode

///|
pub const TextWrapNone : Int32 = 0

///|
pub const TextWrapChar : Int32 = 1

///|
pub const TextWrapWord : Int32 = 2

// Max values

///|
let max_controls : Int32 = 16

///|
let max_props_base : Int32 = 16

///|
let max_props_extended : Int32 = 8

// Gui controls

///|
pub const ControlDefault : Int32 = 0

///|
pub const ControlLabel : Int32 = 1

///|
pub const ControlButton : Int32 = 2

///|
pub const ControlToggle : Int32 = 3

///|
pub const ControlSlider : Int32 = 4

///|
pub const ControlProgressbar : Int32 = 5

///|
pub const ControlCheckbox : Int32 = 6

///|
pub const ControlCombobox : Int32 = 7

///|
pub const ControlDropdownbox : Int32 = 8

///|
pub const ControlTextbox : Int32 = 9

///|
pub const ControlValuebox : Int32 = 10

///|
pub const ControlControl11 : Int32 = 11

///|
pub const ControlListview : Int32 = 12

///|
pub const ControlColorpicker : Int32 = 13

///|
pub const ControlScrollbar : Int32 = 14

///|
pub const ControlStatusbar : Int32 = 15

// Gui base properties for every control (0-15)

///|
pub const BorderColorNormal : Int32 = 0

///|
pub const BaseColorNormal : Int32 = 1

///|
pub const TextColorNormal : Int32 = 2

///|
pub const BorderColorFocused : Int32 = 3

///|
pub const BaseColorFocused : Int32 = 4

///|
pub const TextColorFocused : Int32 = 5

///|
pub const BorderColorPressed : Int32 = 6

///|
pub const BaseColorPressed : Int32 = 7

///|
pub const TextColorPressed : Int32 = 8

///|
pub const BorderColorDisabled : Int32 = 9

///|
pub const BaseColorDisabled : Int32 = 10

///|
pub const TextColorDisabled : Int32 = 11

///|
pub const BorderWidth : Int32 = 12

///|
pub const TextPadding : Int32 = 13

///|
pub const TextAlignment : Int32 = 14

// DEFAULT extended properties (16-23)

///|
pub const TextSize : Int32 = 16

///|
pub const TextSpacing : Int32 = 17

///|
pub const LineColor : Int32 = 18

///|
pub const BackgroundColor : Int32 = 19

///|
pub const TextLineSpacing : Int32 = 20

///|
pub const TextAlignmentVertical : Int32 = 21

///|
pub const TextWrapMode : Int32 = 22

// Toggle properties

///|
pub const GroupPadding : Int32 = 16

// Slider properties

///|
pub const SliderWidth : Int32 = 16

///|
pub const SliderPadding : Int32 = 17

// ProgressBar properties

///|
pub const ProgressPadding : Int32 = 16

// ScrollBar properties

///|
pub const ArrowsSize : Int32 = 16

///|
pub const ArrowsVisible : Int32 = 17

///|
pub const ScrollSliderPadding : Int32 = 18

///|
pub const ScrollSliderSize : Int32 = 19

///|
pub const ScrollPadding : Int32 = 20

///|
pub const ScrollSpeed : Int32 = 21

// CheckBox properties

///|
pub const CheckPadding : Int32 = 16

// ComboBox properties

///|
pub const ComboButtonWidth : Int32 = 16

///|
pub const ComboButtonSpacing : Int32 = 17

// DropdownBox properties

///|
pub const ArrowPadding : Int32 = 16

///|
pub const DropdownItemsSpacing : Int32 = 17

///|
pub const DropdownArrowHidden : Int32 = 18

///|
pub const DropdownRollUp : Int32 = 19

// TextBox properties

///|
pub const TextReadonly : Int32 = 16

// Spinner properties

///|
pub const SpinnerButtonWidth : Int32 = 16

///|
pub const SpinnerButtonSpacing : Int32 = 17

// ListView properties

///|
pub const ListItemsHeight : Int32 = 16

///|
pub const ListItemsSpacing : Int32 = 17

///|
pub const ScrollbarWidth : Int32 = 18

///|
pub const ScrollbarSide : Int32 = 19

///|
pub const ListItemsBorderNormal : Int32 = 20

///|
pub const ListItemsBorderWidth : Int32 = 21

// ColorPicker properties

///|
pub const ColorSelectorSize : Int32 = 16

///|
pub const HuebarWidth : Int32 = 17

///|
pub const HuebarPadding : Int32 = 18

///|
pub const HuebarSelectorHeight : Int32 = 19

///|
pub const HuebarSelectorOverflow : Int32 = 20

// Scrollbar side

///|
pub const ScrollbarLeftSide : Int32 = 0

///|
pub const ScrollbarRightSide : Int32 = 1

// Icon constants

///|
pub const RayguiIconSize : Int32 = 16

///|
pub const IconTextPadding : Int32 = 4

// Mouse button

///|
pub const MouseButtonLeft : Int32 = 0

///|
pub const MouseButtonMiddle : Int32 = 2

// Key constants (matching raylib key codes)

///|
pub const KeyRight : Int32 = 262

///|
pub const KeyLeft : Int32 = 263

///|
pub const KeyDown : Int32 = 264

///|
pub const KeyUp : Int32 = 265

///|
pub const KeyBackspace : Int32 = 259

///|
pub const KeyEnter : Int32 = 257

///|
pub const KeyDelete : Int32 = 261

///|
pub const KeyHome : Int32 = 268

///|
pub const KeyEnd : Int32 = 269

// --- Global mutable state ---

///|
priv struct GuiGlobals {
  mut state : GuiState
  mut locked : Bool
  mut alpha : Float
  mut icon_scale : Int32
  mut tooltip : Bool
  mut tooltip_ptr : String?
  mut control_exclusive_mode : Bool
  mut control_exclusive_rec : @raylib.Rectangle?
  mut text_box_cursor_index : Int32
  mut auto_cursor_counter : Int32
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
      let f = @raylib.Font::default()
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
pub fn gui_get_icon_scale() -> Int32 {
  gui_globals.icon_scale
}

///|
pub fn gui_set_icon_scale(scale : Int32) -> Unit {
  if scale >= 1 {
    gui_globals.icon_scale = scale
  }
}
