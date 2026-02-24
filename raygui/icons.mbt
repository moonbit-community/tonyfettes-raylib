// raygui icon drawing
// Icons are 16x16 1-bit bitmaps stored as 8 UInt values per icon (256 icons total)
// Each UInt32 stores 32 bits: bits 0-15 = one row, bits 16-31 = next row

// Icon data array: 256 icons * 8 uint32s = 2048 entries
// TODO: Populate with full raygui icon data
///|
let gui_icons : FixedArray[UInt] = FixedArray::make(2048, 0U)

// Draw an icon at position (pos_x, pos_y) with given pixel size and color

///|
pub fn gui_draw_icon(
  icon_id : Int,
  pos_x : Int,
  pos_y : Int,
  pixel_size : Int,
  color : @raylib.Color,
) -> Unit {
  if icon_id < 0 || icon_id >= 256 {
    return
  }
  let offset = icon_id * 8
  let mut y = 0
  for i = 0; i < 8; i = i + 1 {
    let word = gui_icons[offset + i]
    for k = 0; k < 32; k = k + 1 {
      if ((word >> k) & 1U) != 0U {
        let rec = @raylib.Rectangle::new(
          Float::from_int(pos_x + k % RayguiIconSize * pixel_size),
          Float::from_int(pos_y + y * pixel_size),
          Float::from_int(pixel_size),
          Float::from_int(pixel_size),
        )
        gui_draw_rectangle(rec, 0, color, color)
      }
      if k == 15 || k == 31 {
        y = y + 1
      }
    }
  }
}
