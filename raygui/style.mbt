// raygui style system
// Style array: 16 controls * (16 base + 8 extended) = 384 entries

///|
let gui_style : FixedArray[Int] = FixedArray::make(
  max_controls * (max_props_base + max_props_extended),
  0,
)

// Set control style property value

///|
pub fn gui_set_style(control : Int, property : Int, value : Int) -> Unit {
  if not(gui_globals.style_loaded) {
    gui_load_style_default()
  }
  gui_style[control * (max_props_base + max_props_extended) + property] = value
  // Default properties are propagated to all controls
  if control == 0 && property < max_props_base {
    for i = 1; i < max_controls; i = i + 1 {
      gui_style[i * (max_props_base + max_props_extended) + property] = value
    }
  }
}

// Get control style property value

///|
pub fn gui_get_style(control : Int, property : Int) -> Int {
  if not(gui_globals.style_loaded) {
    gui_load_style_default()
  }
  gui_style[control * (max_props_base + max_props_extended) + property]
}

// Load default style values

///|
pub fn gui_load_style_default() -> Unit {
  // Set flag first to avoid cyclic calls
  gui_globals.style_loaded = true
  // Default LIGHT style base colors
  gui_set_style(ControlDefault, BorderColorNormal, 0x838383ff)
  gui_set_style(ControlDefault, BaseColorNormal, 0xc9c9c9ff)
  gui_set_style(ControlDefault, TextColorNormal, 0x686868ff)
  gui_set_style(ControlDefault, BorderColorFocused, 0x5bb2d9ff)
  gui_set_style(ControlDefault, BaseColorFocused, 0xc9effeff)
  gui_set_style(ControlDefault, TextColorFocused, 0x6c9bbcff)
  gui_set_style(ControlDefault, BorderColorPressed, 0x0492c7ff)
  gui_set_style(ControlDefault, BaseColorPressed, 0x97e8ffff)
  gui_set_style(ControlDefault, TextColorPressed, 0x368bafff)
  gui_set_style(ControlDefault, BorderColorDisabled, 0xb5c1c2ff)
  gui_set_style(ControlDefault, BaseColorDisabled, 0xe6e9e9ff)
  gui_set_style(ControlDefault, TextColorDisabled, 0xaeb7b8ff)
  gui_set_style(ControlDefault, BorderWidth, 1)
  gui_set_style(ControlDefault, TextPadding, 0)
  gui_set_style(ControlDefault, TextAlignment, TextAlignCenter)
  // Default extended properties
  gui_set_style(ControlDefault, TextSize, 10)
  gui_set_style(ControlDefault, TextSpacing, 1)
  gui_set_style(ControlDefault, LineColor, 0x90abb5ff)
  gui_set_style(ControlDefault, BackgroundColor, 0xf5f5f5ff)
  gui_set_style(ControlDefault, TextLineSpacing, 5)
  gui_set_style(ControlDefault, TextAlignmentVertical, TextAlignMiddle)
  // Control-specific property overrides
  gui_set_style(ControlLabel, TextAlignment, TextAlignLeft)
  gui_set_style(ControlButton, BorderWidth, 2)
  gui_set_style(ControlSlider, TextPadding, 4)
  gui_set_style(ControlProgressbar, TextPadding, 4)
  gui_set_style(ControlCheckbox, TextPadding, 4)
  gui_set_style(ControlCheckbox, TextAlignment, TextAlignRight)
  gui_set_style(ControlDropdownbox, TextPadding, 0)
  gui_set_style(ControlDropdownbox, TextAlignment, TextAlignCenter)
  gui_set_style(ControlTextbox, TextPadding, 4)
  gui_set_style(ControlTextbox, TextAlignment, TextAlignLeft)
  gui_set_style(ControlValuebox, TextPadding, 0)
  gui_set_style(ControlValuebox, TextAlignment, TextAlignLeft)
  gui_set_style(ControlStatusbar, TextPadding, 8)
  gui_set_style(ControlStatusbar, TextAlignment, TextAlignLeft)
  // Extended property values
  gui_set_style(ControlToggle, GroupPadding, 2)
  gui_set_style(ControlSlider, SliderWidth, 16)
  gui_set_style(ControlSlider, SliderPadding, 1)
  gui_set_style(ControlProgressbar, ProgressPadding, 1)
  gui_set_style(ControlCheckbox, CheckPadding, 1)
  gui_set_style(ControlCombobox, ComboButtonWidth, 32)
  gui_set_style(ControlCombobox, ComboButtonSpacing, 2)
  gui_set_style(ControlDropdownbox, ArrowPadding, 16)
  gui_set_style(ControlDropdownbox, DropdownItemsSpacing, 2)
  gui_set_style(ControlValuebox, SpinnerButtonWidth, 24)
  gui_set_style(ControlValuebox, SpinnerButtonSpacing, 2)
  gui_set_style(ControlScrollbar, BorderWidth, 0)
  gui_set_style(ControlScrollbar, ArrowsVisible, 0)
  gui_set_style(ControlScrollbar, ArrowsSize, 6)
  gui_set_style(ControlScrollbar, ScrollSliderPadding, 0)
  gui_set_style(ControlScrollbar, ScrollSliderSize, 16)
  gui_set_style(ControlScrollbar, ScrollPadding, 0)
  gui_set_style(ControlScrollbar, ScrollSpeed, 12)
  gui_set_style(ControlListview, ListItemsHeight, 28)
  gui_set_style(ControlListview, ListItemsSpacing, 2)
  gui_set_style(ControlListview, ListItemsBorderWidth, 1)
  gui_set_style(ControlListview, ScrollbarWidth, 12)
  gui_set_style(ControlListview, ScrollbarSide, ScrollbarRightSide)
  gui_set_style(ControlColorpicker, ColorSelectorSize, 8)
  gui_set_style(ControlColorpicker, HuebarWidth, 16)
  gui_set_style(ControlColorpicker, HuebarPadding, 8)
  gui_set_style(ControlColorpicker, HuebarSelectorHeight, 8)
  gui_set_style(ControlColorpicker, HuebarSelectorOverflow, 2)
  // Initialize font
  gui_globals.font = Some(@raylib.get_font_default())
}
