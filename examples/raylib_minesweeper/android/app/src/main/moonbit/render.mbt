// Color constants, rendering layout constants, drawing helpers, and all rendering

// ---- Color constants ----

///|
let color_bg : @raylib.Color = @raylib.Color::new(240, 244, 248, 255)

///|
let color_header_bg : @raylib.Color = @raylib.Color::new(37, 53, 71, 255)

///|
let color_header_bg_bottom : @raylib.Color = @raylib.Color::new(30, 44, 60, 255)

///|
let color_header_text : @raylib.Color = @raylib.Color::new(236, 240, 241, 255)

///|
let color_unrevealed : @raylib.Color = @raylib.Color::new(76, 175, 147, 255)

///|
let color_unrevealed_alt : @raylib.Color = @raylib.Color::new(62, 152, 126, 255)

///|
let color_unrevealed_border : @raylib.Color = @raylib.Color::new(
  50, 130, 108, 255,
)

///|
let color_revealed : @raylib.Color = @raylib.Color::new(232, 236, 241, 255)

///|
let color_revealed_alt : @raylib.Color = @raylib.Color::new(220, 226, 233, 255)

///|
let color_revealed_border : @raylib.Color = @raylib.Color::new(
  200, 208, 218, 255,
)

///|
let color_flag : @raylib.Color = @raylib.Color::new(231, 76, 60, 255)

///|
let color_mine_bg : @raylib.Color = @raylib.Color::new(231, 76, 60, 255)

///|
let color_mine_fg : @raylib.Color = @raylib.Color::new(40, 40, 40, 255)

///|
let color_btn_restart : @raylib.Color = @raylib.Color::new(250, 200, 50, 255)

///|
let color_pressed : @raylib.Color = @raylib.Color::new(0, 0, 0, 40)

///|
let color_win : @raylib.Color = @raylib.Color::new(46, 204, 113, 255)

///|
let color_lose : @raylib.Color = @raylib.Color::new(231, 76, 60, 255)

///|
let color_overlay : @raylib.Color = @raylib.Color::new(0, 0, 0, 160)

///|
let color_shadow : @raylib.Color = @raylib.Color::new(0, 0, 0, 30)

///|
let color_shadow_strong : @raylib.Color = @raylib.Color::new(0, 0, 0, 50)

///|
let color_header_edge : @raylib.Color = @raylib.Color::new(0, 0, 0, 40)

///|
let color_menu_grad_top : @raylib.Color = @raylib.Color::new(245, 248, 252, 255)

///|
let color_menu_grad_bottom : @raylib.Color = @raylib.Color::new(
  228, 234, 242, 255,
)

///|
let color_btn_easy : @raylib.Color = @raylib.Color::new(52, 199, 110, 255)

///|
let color_btn_medium : @raylib.Color = @raylib.Color::new(245, 166, 35, 255)

///|
let color_btn_hard : @raylib.Color = @raylib.Color::new(220, 64, 50, 255)

///|
let number_colors : Array[@raylib.Color] = [
  @raylib.blank, // 0 - not used
  @raylib.Color::new(20, 100, 200, 255), // 1 - blue (boosted)
  @raylib.Color::new(40, 135, 45, 255), // 2 - green (boosted)
  @raylib.Color::new(200, 35, 35, 255), // 3 - red (boosted)
  @raylib.Color::new(115, 20, 155, 255), // 4 - purple (boosted)
  @raylib.Color::new(245, 130, 0, 255), // 5 - orange (boosted)
  @raylib.Color::new(0, 140, 155, 255), // 6 - teal (boosted)
  @raylib.Color::new(50, 50, 50, 255), // 7 - dark gray (boosted)
  @raylib.Color::new(140, 140, 140, 255), // 8 - gray (boosted)
]

// ---- Rendering layout constants ----

///|
let btn_roundness : Float = 0.3

///|
let cell_roundness : Float = 0.25

///|
let cell_padding : Float = 2.0

///|
let menu_btn_width_ratio : Float = 0.6

///|
let menu_btn_height_ratio : Float = 0.07

///|
let menu_start_y_ratio : Float = 0.35

///|
let menu_btn_spacing_mult : Float = 1.65

///|
let menu_font_ratio : Float = 0.45

///|
let menu_about_width_ratio : Float = 0.4

///|
let menu_about_height_ratio : Float = 0.055

///|
let restart_btn_ratio : Float = 0.7

///|
let card_width_ratio : Float = 0.7

///|
let card_height_ratio : Float = 0.25

///|
let card_y_ratio : Float = 0.35

// ---- Helpers ----

///|
fn int_abs(x : Int) -> Int {
  if x < 0 {
    -x
  } else {
    x
  }
}

///|
fn draw_text_centered_in_rect(
  text : String,
  rx : Float,
  ry : Float,
  rw : Float,
  rh : Float,
  font_size : Int,
  color : @raylib.Color,
) -> Unit {
  let tw = @raylib.measure_text(text, font_size)
  @raylib.draw_text(
    text,
    (rx + (rw - Float::from_int(tw)) / 2.0).to_int(),
    (ry + (rh - Float::from_int(font_size)) / 2.0).to_int(),
    font_size,
    color,
  )
}

///|
fn draw_text_hcentered(
  text : String,
  screen_width : Int,
  y : Int,
  font_size : Int,
  color : @raylib.Color,
) -> Unit {
  let tw = @raylib.measure_text(text, font_size)
  @raylib.draw_text(text, (screen_width - tw) / 2, y, font_size, color)
}

///|
fn fit_font_size(text : String, initial_size : Int, max_width : Int) -> Int {
  let tw = @raylib.measure_text(text, initial_size)
  if tw > max_width {
    (Float::from_int(initial_size) *
    (Float::from_int(max_width) / Float::from_int(tw))).to_int()
  } else {
    initial_size
  }
}

///|
fn draw_flag_icon(
  cx : Float,
  cy : Float,
  size : Float,
  thick : Float,
  pole_color : @raylib.Color,
  flag_color : @raylib.Color,
  base_color : @raylib.Color,
) -> Unit {
  // Flagpole
  @raylib.draw_line_ex(
    @raylib.Vector2::new(cx - size * 0.1, cy - size),
    @raylib.Vector2::new(cx - size * 0.1, cy + size * 0.7),
    thick,
    pole_color,
  )
  // Flag triangle
  @raylib.draw_triangle(
    @raylib.Vector2::new(cx - size * 0.1, cy - size),
    @raylib.Vector2::new(cx - size * 0.1, cy - size * 0.1),
    @raylib.Vector2::new(cx + size * 0.7, cy - size * 0.55),
    flag_color,
  )
  // Base line
  @raylib.draw_line_ex(
    @raylib.Vector2::new(cx - size * 0.5, cy + size * 0.7),
    @raylib.Vector2::new(cx + size * 0.3, cy + size * 0.7),
    thick,
    base_color,
  )
}

///|
fn draw_shadow_rounded(
  x : Float,
  y : Float,
  w : Float,
  h : Float,
  roundness : Float,
  shadow_offset : Float,
  shadow_color : @raylib.Color,
) -> Unit {
  let shadow_rect = @raylib.Rectangle::new(
    x + shadow_offset,
    y + shadow_offset,
    w,
    h,
  )
  @raylib.draw_rectangle_rounded(shadow_rect, roundness, 8, shadow_color)
}

// ---- Render functions ----

///|
fn render() -> Unit {
  @raylib.begin_drawing()
  @raylib.clear_background(color_bg)
  if game.state == state_menu {
    render_menu()
  } else if game.state == state_about {
    render_about()
  } else {
    render_playing()
  }
  @raylib.end_drawing()
}

///|
fn render_menu() -> Unit {
  let sw = Float::from_int(screen.width)
  let sh = Float::from_int(screen.height)
  let max_tw = (sw * 0.9).to_int()
  // Gradient background
  @raylib.draw_rectangle_gradient_v(
    0,
    0,
    screen.width,
    screen.height,
    color_menu_grad_top,
    color_menu_grad_bottom,
  )
  // Title
  let title = "MINESWEEPER"
  let title_size = fit_font_size(title, (sh / 12.0).to_int(), max_tw)
  draw_text_hcentered(
    title,
    screen.width,
    (sh / 6.0).to_int(),
    title_size,
    color_header_bg,
  )
  // Difficulty buttons
  let btn_w = sw * menu_btn_width_ratio
  let btn_h = sh * menu_btn_height_ratio
  let btn_x = (sw - btn_w) / 2.0
  let start_y = sh * menu_start_y_ratio
  let spacing = btn_h * menu_btn_spacing_mult
  let font_size = (btn_h * menu_font_ratio).to_int()
  let labels = ["Easy (12x8)", "Medium (14x9)", "Hard (16x10)"]
  let btn_colors = [color_btn_easy, color_btn_medium, color_btn_hard]
  let shadow_off = btn_h * 0.04
  for i = 0; i < 3; i = i + 1 {
    let y = start_y + spacing * Float::from_int(i)
    // Shadow
    draw_shadow_rounded(
      btn_x, y, btn_w, btn_h, btn_roundness, shadow_off, color_shadow_strong,
    )
    // Button
    let rect = @raylib.Rectangle::new(btn_x, y, btn_w, btn_h)
    @raylib.draw_rectangle_rounded(rect, btn_roundness, 8, btn_colors[i])
    draw_text_centered_in_rect(
      labels[i],
      btn_x,
      y,
      btn_w,
      btn_h,
      font_size,
      @raylib.white,
    )
  }
  // About button
  let about_w = sw * menu_about_width_ratio
  let about_h = sh * menu_about_height_ratio
  let about_x = (sw - about_w) / 2.0
  let about_y = start_y + spacing * 3.0 + btn_h * 0.3
  let about_font = (about_h * menu_font_ratio).to_int()
  // Shadow
  draw_shadow_rounded(
    about_x,
    about_y,
    about_w,
    about_h,
    btn_roundness,
    about_h * 0.04,
    color_shadow_strong,
  )
  let about_rect = @raylib.Rectangle::new(about_x, about_y, about_w, about_h)
  @raylib.draw_rectangle_rounded(about_rect, btn_roundness, 8, color_header_bg)
  draw_text_centered_in_rect(
    "About", about_x, about_y, about_w, about_h, about_font, @raylib.white,
  )
}

///|
fn render_about() -> Unit {
  let sw = Float::from_int(screen.width)
  let sh = Float::from_int(screen.height)
  let max_tw = (sw * 0.9).to_int()
  // Gradient background
  @raylib.draw_rectangle_gradient_v(
    0,
    0,
    screen.width,
    screen.height,
    color_menu_grad_top,
    color_menu_grad_bottom,
  )
  // Title
  let title_text = "ABOUT"
  let title_size = fit_font_size(title_text, (sh / 14.0).to_int(), max_tw)
  draw_text_hcentered(
    title_text,
    screen.width,
    (sh * 0.12).to_int(),
    title_size,
    color_header_bg,
  )
  // App name
  let name_text = "Minesweeper"
  let name_size = fit_font_size(name_text, (sh / 16.0).to_int(), max_tw)
  draw_text_hcentered(
    name_text,
    screen.width,
    (sh * 0.30).to_int(),
    name_size,
    color_header_bg,
  )
  // Version
  let ver_text = "Version 1.0"
  let info_size = fit_font_size(ver_text, (sh / 28.0).to_int(), max_tw)
  draw_text_hcentered(
    ver_text,
    screen.width,
    (sh * 0.40).to_int(),
    info_size,
    @raylib.gray,
  )
  // Tech info
  let tech_text = "Built with MoonBit + Raylib"
  let tech_size = fit_font_size(tech_text, info_size, max_tw)
  draw_text_hcentered(
    tech_text,
    screen.width,
    (sh * 0.48).to_int(),
    tech_size,
    @raylib.gray,
  )
  // Back button
  let back_w = sw * 0.4
  let back_h = sh * 0.06
  let back_x = (sw - back_w) / 2.0
  let back_y = sh * 0.75
  let back_font = (back_h * menu_font_ratio).to_int()
  // Shadow
  draw_shadow_rounded(
    back_x,
    back_y,
    back_w,
    back_h,
    btn_roundness,
    back_h * 0.04,
    color_shadow_strong,
  )
  let back_rect = @raylib.Rectangle::new(back_x, back_y, back_w, back_h)
  @raylib.draw_rectangle_rounded(back_rect, btn_roundness, 8, color_header_bg)
  draw_text_centered_in_rect(
    "Back", back_x, back_y, back_w, back_h, back_font, @raylib.white,
  )
}

///|
fn render_playing() -> Unit {
  render_board()
  render_header()
  render_footer()
  if game.state != state_playing {
    render_game_over_overlay()
  }
}

///|
fn render_board() -> Unit {
  let cam = make_camera()
  @raylib.begin_mode_2d(cam)
  // Pre-compute chord highlight info
  let chord_highlight_active = highlight.is_chord &&
    highlight.row >= 0 &&
    highlight.col >= 0
  let mut chord_flags_match = false
  if chord_highlight_active {
    let hidx = cell_index(highlight.row, highlight.col, game.cols)
    let hcell = game.board[hidx]
    let mut hflags = 0
    for dr = -1; dr <= 1; dr = dr + 1 {
      for dc = -1; dc <= 1; dc = dc + 1 {
        let nr = highlight.row + dr
        let nc = highlight.col + dc
        if is_valid_cell(nr, nc, game.rows, game.cols) &&
          game.board[cell_index(nr, nc, game.cols)].is_flagged {
          hflags = hflags + 1
        }
      }
    }
    chord_flags_match = hflags == hcell.neighbor_mines
  }
  for r = 0; r < game.rows; r = r + 1 {
    for c = 0; c < game.cols; c = c + 1 {
      let x = layout_.offset_x + Float::from_int(c) * layout_.cell_size
      let y = layout_.offset_y + Float::from_int(r) * layout_.cell_size
      let pad = cell_padding
      let rect = @raylib.Rectangle::new(
        x + pad,
        y + pad,
        layout_.cell_size - pad * 2.0,
        layout_.cell_size - pad * 2.0,
      )
      let idx = cell_index(r, c, game.cols)
      let cell = game.board[idx]
      let border_thick_unrevealed = layout_.cell_size * 0.02
      let border_thick_revealed = layout_.cell_size * 0.015
      if not(cell.is_revealed) {
        // Unrevealed — flat rounded rectangle with checkerboard
        let cell_color = if (r + c) % 2 == 0 {
          color_unrevealed
        } else {
          color_unrevealed_alt
        }
        @raylib.draw_rectangle_rounded(rect, cell_roundness, 8, cell_color)
        // Border
        @raylib.draw_rectangle_rounded_lines_ex(
          rect, cell_roundness, 8, border_thick_unrevealed, color_unrevealed_border,
        )
        if cell.is_flagged {
          // Flag icon
          let cx = x + layout_.cell_size / 2.0
          let cy = y + layout_.cell_size / 2.0
          let fs = layout_.cell_size * 0.25
          let thick = layout_.cell_size * 0.05
          draw_flag_icon(
            cx, cy, fs, thick, @raylib.white, color_flag, @raylib.white,
          )
        }
      } else if cell.has_mine {
        // Mine cell — rounded red background with mine icon
        @raylib.draw_rectangle_rounded(rect, cell_roundness, 8, color_mine_bg)
        let cx = x + layout_.cell_size / 2.0
        let cy = y + layout_.cell_size / 2.0
        let mr = layout_.cell_size * 0.25
        let thick = layout_.cell_size * 0.06
        // Mine body
        @raylib.draw_circle_v(@raylib.Vector2::new(cx, cy), mr, color_mine_fg)
        // Horizontal spike
        @raylib.draw_line_ex(
          @raylib.Vector2::new(cx - mr * 1.3, cy),
          @raylib.Vector2::new(cx + mr * 1.3, cy),
          thick,
          color_mine_fg,
        )
        // Vertical spike
        @raylib.draw_line_ex(
          @raylib.Vector2::new(cx, cy - mr * 1.3),
          @raylib.Vector2::new(cx, cy + mr * 1.3),
          thick,
          color_mine_fg,
        )
        // Diagonal spike (top-left to bottom-right)
        let diag = mr * 0.92
        @raylib.draw_line_ex(
          @raylib.Vector2::new(cx - diag, cy - diag),
          @raylib.Vector2::new(cx + diag, cy + diag),
          thick,
          color_mine_fg,
        )
        // Diagonal spike (top-right to bottom-left)
        @raylib.draw_line_ex(
          @raylib.Vector2::new(cx + diag, cy - diag),
          @raylib.Vector2::new(cx - diag, cy + diag),
          thick,
          color_mine_fg,
        )
        // White highlight dot
        @raylib.draw_circle_v(
          @raylib.Vector2::new(cx - mr * 0.3, cy - mr * 0.3),
          mr * 0.2,
          @raylib.white,
        )
      } else {
        // Revealed safe cell — flat rounded rectangle with checkerboard
        let cell_color = if (r + c) % 2 == 0 {
          color_revealed
        } else {
          color_revealed_alt
        }
        @raylib.draw_rectangle_rounded(rect, cell_roundness, 8, cell_color)
        // Border
        @raylib.draw_rectangle_rounded_lines_ex(
          rect, cell_roundness, 8, border_thick_revealed, color_revealed_border,
        )
        if cell.neighbor_mines > 0 {
          let font_size = (layout_.cell_size * 0.6).to_int()
          let num_text = cell.neighbor_mines.to_string()
          let tw = @raylib.measure_text(num_text, font_size)
          @raylib.draw_text(
            num_text,
            (x + (layout_.cell_size - Float::from_int(tw)) / 2.0).to_int(),
            (y + (layout_.cell_size - Float::from_int(font_size)) / 2.0).to_int(),
            font_size,
            number_colors[cell.neighbor_mines],
          )
        }
      }
      // Draw highlight overlay
      let should_highlight = if highlight.row == r && highlight.col == c {
        true
      } else if chord_highlight_active && chord_flags_match {
        int_abs(r - highlight.row) <= 1 &&
        int_abs(c - highlight.col) <= 1 &&
        not(cell.is_revealed) &&
        not(cell.is_flagged)
      } else {
        false
      }
      if should_highlight {
        @raylib.draw_rectangle_rounded(rect, cell_roundness, 8, color_pressed)
      }
    }
  }
  @raylib.end_mode_2d()
}

///|
fn render_header() -> Unit {
  let sw = Float::from_int(screen.width)
  let hh = screen.header_height
  // Gradient header background (lighter top → darker bottom)
  @raylib.draw_rectangle_gradient_v(
    0,
    0,
    screen.width,
    hh.to_int(),
    color_header_bg,
    color_header_bg_bottom,
  )
  // Bottom edge line for crisp separation
  @raylib.draw_rectangle(0, hh.to_int() - 1, screen.width, 1, color_header_edge)
  let h_font_size = (hh * menu_font_ratio).to_int()
  // Mine icon + counter (left)
  let icon_r = hh * 0.12
  let icon_cx = sw * 0.05 + icon_r
  let icon_cy = hh / 2.0
  draw_mine_icon_small(icon_cx, icon_cy, icon_r, color_header_text)
  let mine_text = "\{game.total_mines - game.flag_count}"
  @raylib.draw_text(
    mine_text,
    (icon_cx + icon_r * 1.8).to_int(),
    ((hh - Float::from_int(h_font_size)) / 2.0).to_int(),
    h_font_size,
    color_header_text,
  )
  // Restart button (center)
  let btn_size = hh * restart_btn_ratio
  let btn_x = (sw - btn_size) / 2.0
  let btn_y = (hh - btn_size) / 2.0
  // Shadow behind restart button
  draw_shadow_rounded(
    btn_x,
    btn_y,
    btn_size,
    btn_size,
    btn_roundness,
    btn_size * 0.04,
    color_shadow,
  )
  let btn_rect = @raylib.Rectangle::new(btn_x, btn_y, btn_size, btn_size)
  @raylib.draw_rectangle_rounded(btn_rect, btn_roundness, 8, color_btn_restart)
  // Restart icon (circular arrow)
  let cx = btn_x + btn_size / 2.0
  let cy = btn_y + btn_size / 2.0
  let icon_size = btn_size * 0.28
  render_restart_icon(cx, cy, icon_size, color_header_bg)
  // Clock icon + timer (right)
  let timer_text = "\{game.timer.to_int()}"
  let tw = @raylib.measure_text(timer_text, h_font_size)
  let timer_right = sw * 0.95
  let timer_x = timer_right - Float::from_int(tw)
  @raylib.draw_text(
    timer_text,
    timer_x.to_int(),
    ((hh - Float::from_int(h_font_size)) / 2.0).to_int(),
    h_font_size,
    color_header_text,
  )
  let clock_cx = timer_x - icon_r * 1.8
  draw_clock_icon(clock_cx, hh / 2.0, icon_r, color_header_text)
}

///|
fn render_restart_icon(
  cx : Float,
  cy : Float,
  r : Float,
  color : @raylib.Color,
) -> Unit {
  // Draw ~270° arc using draw_ring (gap at top-right)
  let thick = r * 0.25
  @raylib.draw_ring(
    @raylib.Vector2::new(cx, cy),
    r - thick,
    r,
    45.0,
    315.0,
    24,
    color,
  )
  // Arrowhead at the gap (pointing clockwise, at ~45° position)
  let arrow_size = r * 0.45
  // Tip of arrow at end of arc (45° = top-right, cos/sin = 0.707)
  let cos45 : Float = 0.707
  let tip_x = cx + (r - thick / 2.0) * cos45
  let tip_y = cy - (r - thick / 2.0) * cos45
  // Two base points of the triangle
  @raylib.draw_triangle(
    @raylib.Vector2::new(tip_x + arrow_size * 0.3, tip_y - arrow_size * 0.6),
    @raylib.Vector2::new(tip_x, tip_y),
    @raylib.Vector2::new(tip_x + arrow_size * 0.7, tip_y + arrow_size * 0.2),
    color,
  )
}

///|
fn render_footer() -> Unit {
  let sw = Float::from_int(screen.width)
  let sh = Float::from_int(screen.height)
  let footer_y = sh - screen.footer_height
  // Footer background (subtle)
  @raylib.draw_rectangle(
    0,
    footer_y.to_int(),
    screen.width,
    screen.footer_height.to_int(),
    color_bg,
  )
  // FAB mode toggle button at bottom center
  let fab_size = screen.footer_height * 0.75
  let fab_x = (sw - fab_size) / 2.0
  let fab_y = footer_y + (screen.footer_height - fab_size) / 2.0
  let fab_color = if game.current_mode == mode_dig {
    color_unrevealed
  } else {
    color_flag
  }
  // Shadow
  draw_shadow_rounded(
    fab_x,
    fab_y,
    fab_size,
    fab_size,
    0.5,
    fab_size * 0.05,
    color_shadow_strong,
  )
  // FAB circle background
  let fab_rect = @raylib.Rectangle::new(fab_x, fab_y, fab_size, fab_size)
  @raylib.draw_rectangle_rounded(fab_rect, 0.5, 16, fab_color)
  // Icon inside FAB
  let mcx = fab_x + fab_size / 2.0
  let mcy = fab_y + fab_size / 2.0
  if game.current_mode == mode_dig {
    // Dig mode icon: white circle
    @raylib.draw_circle_v(
      @raylib.Vector2::new(mcx, mcy),
      fab_size * 0.2,
      @raylib.white,
    )
  } else {
    // Flag mode icon: white flag
    let mfs = fab_size * 0.2
    let mthick = fab_size * 0.06
    draw_flag_icon(
      mcx, mcy, mfs, mthick, @raylib.white, @raylib.white, @raylib.white,
    )
  }
}

///|
fn draw_mine_icon_small(
  cx : Float,
  cy : Float,
  r : Float,
  color : @raylib.Color,
) -> Unit {
  // Circle body
  @raylib.draw_circle_v(@raylib.Vector2::new(cx, cy), r, color)
  // Spike lines
  let thick = r * 0.3
  let spike = r * 1.4
  // Horizontal
  @raylib.draw_line_ex(
    @raylib.Vector2::new(cx - spike, cy),
    @raylib.Vector2::new(cx + spike, cy),
    thick,
    color,
  )
  // Vertical
  @raylib.draw_line_ex(
    @raylib.Vector2::new(cx, cy - spike),
    @raylib.Vector2::new(cx, cy + spike),
    thick,
    color,
  )
  // Diagonal
  let diag = spike * 0.71
  @raylib.draw_line_ex(
    @raylib.Vector2::new(cx - diag, cy - diag),
    @raylib.Vector2::new(cx + diag, cy + diag),
    thick,
    color,
  )
  @raylib.draw_line_ex(
    @raylib.Vector2::new(cx + diag, cy - diag),
    @raylib.Vector2::new(cx - diag, cy + diag),
    thick,
    color,
  )
}

///|
fn draw_clock_icon(
  cx : Float,
  cy : Float,
  r : Float,
  color : @raylib.Color,
) -> Unit {
  // Clock circle outline
  let thick = r * 0.25
  @raylib.draw_ring(
    @raylib.Vector2::new(cx, cy),
    r - thick,
    r,
    0.0,
    360.0,
    24,
    color,
  )
  // Hour hand (pointing up-right, ~2 o'clock)
  @raylib.draw_line_ex(
    @raylib.Vector2::new(cx, cy),
    @raylib.Vector2::new(cx, cy - r * 0.55),
    thick * 0.8,
    color,
  )
  // Minute hand (pointing right, ~3 o'clock)
  @raylib.draw_line_ex(
    @raylib.Vector2::new(cx, cy),
    @raylib.Vector2::new(cx + r * 0.45, cy),
    thick * 0.6,
    color,
  )
}

///|
fn render_game_over_overlay() -> Unit {
  let sw = Float::from_int(screen.width)
  let sh = Float::from_int(screen.height)
  // Dark overlay
  @raylib.draw_rectangle(0, 0, screen.width, screen.height, color_overlay)
  // White card
  let card_w = sw * card_width_ratio
  let card_h = sh * card_height_ratio
  let card_x = (sw - card_w) / 2.0
  let card_y = sh * card_y_ratio
  // Drop shadow behind card
  draw_shadow_rounded(
    card_x,
    card_y,
    card_w,
    card_h,
    0.1,
    card_h * 0.04,
    color_shadow_strong,
  )
  let card_rect = @raylib.Rectangle::new(card_x, card_y, card_w, card_h)
  @raylib.draw_rectangle_rounded(card_rect, 0.1, 8, @raylib.white)
  // Colored accent bar at top of card
  let accent_color = if game.state == state_won {
    color_win
  } else {
    color_lose
  }
  let accent_h = card_h * 0.04
  let accent_rect = @raylib.Rectangle::new(card_x, card_y, card_w, accent_h)
  @raylib.draw_rectangle_rounded(accent_rect, 0.4, 8, accent_color)
  // Win/Loss message
  let msg = if game.state == state_won { "YOU WIN!" } else { "GAME OVER" }
  let msg_color = if game.state == state_won { color_win } else { color_lose }
  let max_msg_w = (card_w * 0.9).to_int()
  let msg_size = fit_font_size(msg, (card_h * 0.30).to_int(), max_msg_w)
  draw_text_hcentered(
    msg,
    screen.width,
    (card_y + card_h * 0.22).to_int(),
    msg_size,
    msg_color,
  )
  // Subtitle
  let sub_size = (card_h * 0.16).to_int()
  let sub = "Tap to continue"
  draw_text_hcentered(
    sub,
    screen.width,
    (card_y + card_h * 0.62).to_int(),
    sub_size,
    @raylib.gray,
  )
}
