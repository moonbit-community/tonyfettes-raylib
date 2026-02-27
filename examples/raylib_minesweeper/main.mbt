// Minesweeper — 16x16 grid, 40 mines

///|
const Rows : Int = 16

///|
const Cols : Int = 16

///|
const MineCount : Int = 40

// Game states

///|
const StateWaiting : Int = 0 // before first click

///|
const StatePlaying : Int = 1

///|
const StateWon : Int = 2

///|
const StateLost : Int = 3

///|
fn cell_index(row : Int, col : Int) -> Int {
  row * Cols + col
}

///|
fn in_bounds(row : Int, col : Int) -> Bool {
  row >= 0 && row < Rows && col >= 0 && col < Cols
}

///|
fn count_adjacent(mines : Array[Int], row : Int, col : Int) -> Int {
  let mut count = 0
  for dr = -1; dr <= 1; dr = dr + 1 {
    for dc = -1; dc <= 1; dc = dc + 1 {
      if not(dr == 0 && dc == 0) {
        let nr = row + dr
        let nc = col + dc
        if in_bounds(nr, nc) && mines[cell_index(nr, nc)] != 0 {
          count = count + 1
        }
      }
    }
  }
  count
}

///|
fn number_color(n : Int) -> @raylib.Color {
  match n {
    1 => @raylib.Color::new(0, 0, 255, 255) // blue
    2 => @raylib.Color::new(0, 128, 0, 255) // green
    3 => @raylib.Color::new(255, 0, 0, 255) // red
    4 => @raylib.Color::new(0, 0, 128, 255) // dark blue
    5 => @raylib.Color::new(128, 0, 0, 255) // maroon
    6 => @raylib.Color::new(0, 128, 128, 255) // teal
    7 => @raylib.Color::new(0, 0, 0, 255) // black
    8 => @raylib.Color::new(128, 128, 128, 255) // gray
    _ => @raylib.black
  }
}

///|
fn generate_mines(
  mines : Array[Int],
  adjacent : Array[Int],
  safe_row : Int,
  safe_col : Int,
) -> Unit {
  let total = Rows * Cols
  // Clear
  for i = 0; i < total; i = i + 1 {
    mines[i] = 0
    adjacent[i] = 0
  }
  // Place mines
  let mut placed = 0
  while placed < MineCount {
    let idx = @raylib.get_random_value(0, total - 1)
    let r = idx / Cols
    let c = idx % Cols
    // Skip if already a mine or in safe zone (3x3 around first click)
    if mines[idx] != 0 {
      continue
    }
    let dr = r - safe_row
    let dc = c - safe_col
    if dr >= -1 && dr <= 1 && dc >= -1 && dc <= 1 {
      continue
    }
    mines[idx] = 1
    placed = placed + 1
  }
  // Compute adjacency counts
  for r = 0; r < Rows; r = r + 1 {
    for c = 0; c < Cols; c = c + 1 {
      adjacent[cell_index(r, c)] = count_adjacent(mines, r, c)
    }
  }
}

///|
fn flood_fill(
  mines : Array[Int],
  revealed : Array[Int],
  flagged : Array[Int],
  adjacent : Array[Int],
  row : Int,
  col : Int,
) -> Unit {
  if not(in_bounds(row, col)) {
    return
  }
  let idx = cell_index(row, col)
  if revealed[idx] != 0 || flagged[idx] != 0 || mines[idx] != 0 {
    return
  }
  revealed[idx] = 1
  if adjacent[idx] == 0 {
    for dr = -1; dr <= 1; dr = dr + 1 {
      for dc = -1; dc <= 1; dc = dc + 1 {
        if not(dr == 0 && dc == 0) {
          flood_fill(mines, revealed, flagged, adjacent, row + dr, col + dc)
        }
      }
    }
  }
}

///|
fn check_win(mines : Array[Int], revealed : Array[Int]) -> Bool {
  let total = Rows * Cols
  for i = 0; i < total; i = i + 1 {
    if mines[i] == 0 && revealed[i] == 0 {
      return false
    }
  }
  true
}

///|
fn reset_game(
  mines : Array[Int],
  revealed : Array[Int],
  flagged : Array[Int],
  adjacent : Array[Int],
) -> Unit {
  let total = Rows * Cols
  for i = 0; i < total; i = i + 1 {
    mines[i] = 0
    revealed[i] = 0
    flagged[i] = 0
    adjacent[i] = 0
  }
}

///|
fn main {
  @raylib.init_window(0, 0, "Minesweeper")
  @raylib.set_target_fps(60)
  @raylib.set_exit_key(0)
  @raylib.set_gestures_enabled(0)

  // Layout — computed from fullscreen dimensions instead of hardcoded constants
  let screen_width = @raylib.get_screen_width()
  let screen_height = @raylib.get_screen_height()
  let header_height = screen_height / 10
  let cell_size = {
    let cw = screen_width / Cols
    let ch = (screen_height - header_height) / Rows
    if cw < ch { cw } else { ch }
  }
  let grid_offset_x = (screen_width - cell_size * Cols) / 2
  let grid_offset_y = header_height +
    (screen_height - header_height - cell_size * Rows) / 2
  let text_size = header_height / 3

  let total = Rows * Cols
  let mines : Array[Int] = Array::make(total, 0)
  let revealed : Array[Int] = Array::make(total, 0)
  let flagged : Array[Int] = Array::make(total, 0)
  let adjacent : Array[Int] = Array::make(total, 0)

  let mut game_state = StateWaiting
  let mut flags_placed = 0
  let mut start_time = 0.0
  let mut elapsed_time = 0

  // Touch state (replaces mouse + keyboard)
  let mut touch_active = false
  let mut touch_x : Float = 0.0
  let mut touch_y : Float = 0.0
  let mut touch_timer : Float = 0.0
  let mut touch_dist : Float = 0.0
  let mut long_fired = false

  // Colors
  let bg_color = @raylib.Color::new(192, 192, 192, 255)
  let cell_unrevealed = @raylib.Color::new(190, 190, 190, 255)
  let cell_revealed_bg = @raylib.Color::new(215, 215, 215, 255)
  let highlight_light = @raylib.Color::new(224, 224, 224, 255)
  let highlight_dark = @raylib.Color::new(128, 128, 128, 255)

  while not(@raylib.window_should_close()) {
    let dt = @raylib.get_frame_time()

    // === UPDATE ===

    // Timer
    if game_state == StatePlaying {
      elapsed_time = (@raylib.get_time() - start_time).to_int()
      if elapsed_time > 999 {
        elapsed_time = 999
      }
    }

    // Restart (keyboard)
    if @raylib.is_key_pressed(@raylib.KeyR) {
      reset_game(mines, revealed, flagged, adjacent)
      game_state = StateWaiting
      flags_placed = 0
      elapsed_time = 0
    }

    // Mouse input
    if game_state == StateWaiting || game_state == StatePlaying {
      let mx = @raylib.get_mouse_x()
      let my = @raylib.get_mouse_y()
      let col = (mx - grid_offset_x) / cell_size
      let row = (my - grid_offset_y) / cell_size
      if in_bounds(row, col) && mx >= grid_offset_x && my >= grid_offset_y {
        // Left click — reveal
        if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
          let idx = cell_index(row, col)
          if flagged[idx] == 0 && revealed[idx] == 0 {
            if game_state == StateWaiting {
              generate_mines(mines, adjacent, row, col)
              game_state = StatePlaying
              start_time = @raylib.get_time()
            }
            if mines[idx] != 0 {
              revealed[idx] = 1
              game_state = StateLost
            } else {
              flood_fill(mines, revealed, flagged, adjacent, row, col)
              if check_win(mines, revealed) {
                game_state = StateWon
              }
            }
          }
        }
        // Right click — flag
        if @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight) {
          let idx = cell_index(row, col)
          if revealed[idx] == 0 {
            if flagged[idx] != 0 {
              flagged[idx] = 0
              flags_placed = flags_placed - 1
            } else {
              flagged[idx] = 1
              flags_placed = flags_placed + 1
            }
          }
        }
      }
    }

    // Touch input (tap = reveal, long press = flag, tap on game over = restart)
    let ntouch = @raylib.get_touch_point_count()
    if ntouch > 0 && not(touch_active) {
      let pos = @raylib.get_touch_position(0)
      touch_x = pos.x
      touch_y = pos.y
      touch_timer = 0.0
      touch_dist = 0.0
      long_fired = false
      touch_active = true
    }
    if ntouch > 0 && touch_active {
      let pos = @raylib.get_touch_position(0)
      let dx = pos.x - touch_x
      let dy = pos.y - touch_y
      touch_dist = (dx * dx + dy * dy).sqrt()
      touch_timer = touch_timer + dt
      // Long press — flag
      if not(long_fired) && touch_timer >= 0.5 && touch_dist < 15.0 {
        long_fired = true
        let col = (touch_x.to_int() - grid_offset_x) / cell_size
        let row = (touch_y.to_int() - grid_offset_y) / cell_size
        if (game_state == StateWaiting || game_state == StatePlaying) &&
          in_bounds(row, col) {
          let idx = cell_index(row, col)
          if revealed[idx] == 0 {
            if flagged[idx] != 0 {
              flagged[idx] = 0
              flags_placed = flags_placed - 1
            } else {
              flagged[idx] = 1
              flags_placed = flags_placed + 1
            }
          }
        }
      }
    }
    if ntouch == 0 && touch_active {
      touch_active = false
      if not(long_fired) && touch_dist < 15.0 {
        // Tap on game over — restart
        if game_state == StateWon || game_state == StateLost {
          reset_game(mines, revealed, flagged, adjacent)
          game_state = StateWaiting
          flags_placed = 0
          elapsed_time = 0
        }
        // Tap — reveal
        if game_state == StateWaiting || game_state == StatePlaying {
          let col = (touch_x.to_int() - grid_offset_x) / cell_size
          let row = (touch_y.to_int() - grid_offset_y) / cell_size
          if in_bounds(row, col) {
            let idx = cell_index(row, col)
            if flagged[idx] == 0 && revealed[idx] == 0 {
              if game_state == StateWaiting {
                generate_mines(mines, adjacent, row, col)
                game_state = StatePlaying
                start_time = @raylib.get_time()
              }
              if mines[idx] != 0 {
                revealed[idx] = 1
                game_state = StateLost
              } else {
                flood_fill(mines, revealed, flagged, adjacent, row, col)
                if check_win(mines, revealed) {
                  game_state = StateWon
                }
              }
            }
          }
        }
      }
    }

    // === DRAW ===
    @raylib.begin_drawing()
    @raylib.clear_background(bg_color)

    // Header
    let mines_left = MineCount - flags_placed
    @raylib.draw_text(
      "Mines: \{mines_left}",
      grid_offset_x,
      (header_height - text_size) / 2,
      text_size,
      @raylib.darkgray,
    )
    // Status text
    let status = match game_state {
      s if s == StateWon => "YOU WIN!"
      s if s == StateLost => "GAME OVER"
      _ => ""
    }
    if status.length() > 0 {
      let status_width = @raylib.measure_text(status, text_size)
      @raylib.draw_text(
        status,
        (screen_width - status_width) / 2,
        (header_height - text_size) / 2,
        text_size,
        if game_state == StateWon {
          @raylib.darkgreen
        } else {
          @raylib.red
        },
      )
    }
    // Timer
    let timer_text = "Time: \{elapsed_time}"
    let timer_width = @raylib.measure_text(timer_text, text_size)
    @raylib.draw_text(
      timer_text,
      screen_width - timer_width - grid_offset_x,
      (header_height - text_size) / 2,
      text_size,
      @raylib.darkgray,
    )

    // Grid
    let num_font_size = cell_size * 2 / 3
    let mine_radius = Float::from_int(cell_size) / 4.0
    for r = 0; r < Rows; r = r + 1 {
      for c = 0; c < Cols; c = c + 1 {
        let idx = cell_index(r, c)
        let x = grid_offset_x + c * cell_size
        let y = grid_offset_y + r * cell_size
        if revealed[idx] != 0 {
          // Revealed cell
          @raylib.draw_rectangle(x, y, cell_size, cell_size, cell_revealed_bg)
          @raylib.draw_rectangle_lines(x, y, cell_size, cell_size, highlight_dark)
          if mines[idx] != 0 {
            // Mine — draw filled circle
            let cx = x + cell_size / 2
            let cy = y + cell_size / 2
            @raylib.draw_circle(cx, cy, mine_radius, @raylib.black)
          } else if adjacent[idx] > 0 {
            // Number
            let num_text = adjacent[idx].to_string()
            let tw = @raylib.measure_text(num_text, num_font_size)
            @raylib.draw_text(
              num_text,
              x + (cell_size - tw) / 2,
              y + (cell_size - num_font_size) / 2,
              num_font_size,
              number_color(adjacent[idx]),
            )
          }
        } else {
          // Unrevealed cell — draw 3D raised appearance
          @raylib.draw_rectangle(x, y, cell_size, cell_size, cell_unrevealed)
          // Light edges (top, left)
          @raylib.draw_line(x, y, x + cell_size - 1, y, highlight_light)
          @raylib.draw_line(x, y, x, y + cell_size - 1, highlight_light)
          // Dark edges (bottom, right)
          @raylib.draw_line(
            x,
            y + cell_size - 1,
            x + cell_size - 1,
            y + cell_size - 1,
            highlight_dark,
          )
          @raylib.draw_line(
            x + cell_size - 1,
            y,
            x + cell_size - 1,
            y + cell_size - 1,
            highlight_dark,
          )
          if flagged[idx] != 0 {
            // Flag — red triangle, proportional to cell_size
            let fx = Float::from_int(x + cell_size / 2)
            let fy_top = Float::from_int(y + cell_size / 6)
            let fy_bot = Float::from_int(y + cell_size * 5 / 6)
            let fx_left = Float::from_int(x + cell_size / 4)
            let fx_right = Float::from_int(x + cell_size * 3 / 4)
            @raylib.draw_triangle(
              @raylib.Vector2::new(fx, fy_top),
              @raylib.Vector2::new(fx_left, fy_bot),
              @raylib.Vector2::new(fx_right, fy_bot),
              @raylib.red,
            )
          }
          // Show mines on game over
          if game_state == StateLost && mines[idx] != 0 && flagged[idx] == 0 {
            let cx = x + cell_size / 2
            let cy = y + cell_size / 2
            @raylib.draw_circle(cx, cy, mine_radius, @raylib.black)
          }
        }
      }
    }

    // Restart hint
    if game_state == StateWon || game_state == StateLost {
      let hint = "R / Tap to restart"
      let hint_width = @raylib.measure_text(hint, text_size)
      let hint_area_top = grid_offset_y + Rows * cell_size
      @raylib.draw_text(
        hint,
        (screen_width - hint_width) / 2,
        hint_area_top + (screen_height - hint_area_top - text_size) / 2,
        text_size,
        @raylib.darkgray,
      )
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
