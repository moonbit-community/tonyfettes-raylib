// Minesweeper — 16x16 grid, 40 mines

///|
const Rows : Int = 16

///|
const Cols : Int = 16

///|
const MineCount : Int = 40

///|
const CellSize : Int = 30

///|
const GridOffsetX : Int = 10

///|
const GridOffsetY : Int = 60

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
  for dr in -1..<=1 {
    for dc in -1..<=1 {
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
  for i in 0..<total {
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
  for r in 0..<Rows {
    for c in 0..<Cols {
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
    for dr in -1..<=1 {
      for dc in -1..<=1 {
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
  for i in 0..<total {
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
  for i in 0..<total {
    mines[i] = 0
    revealed[i] = 0
    flagged[i] = 0
    adjacent[i] = 0
  }
}

///|
fn main {
  let screen_width = GridOffsetX * 2 + Cols * CellSize
  let screen_height = GridOffsetY + Rows * CellSize + 10
  @raylib.init_window(screen_width, screen_height, "Minesweeper")
  @raylib.set_target_fps(60)

  let total = Rows * Cols
  let mines : Array[Int] = Array::make(total, 0)
  let revealed : Array[Int] = Array::make(total, 0)
  let flagged : Array[Int] = Array::make(total, 0)
  let adjacent : Array[Int] = Array::make(total, 0)

  let mut game_state = StateWaiting
  let mut flags_placed = 0
  let mut start_time = 0.0
  let mut elapsed_time = 0

  // Colors
  let bg_color = @raylib.Color::new(192, 192, 192, 255)
  let cell_unrevealed = @raylib.Color::new(190, 190, 190, 255)
  let cell_revealed_bg = @raylib.Color::new(215, 215, 215, 255)
  let highlight_light = @raylib.Color::new(224, 224, 224, 255)
  let highlight_dark = @raylib.Color::new(128, 128, 128, 255)

  while not(@raylib.window_should_close()) {
    // === UPDATE ===
    // Restart
    if @raylib.is_key_pressed(@raylib.KeyR) {
      reset_game(mines, revealed, flagged, adjacent)
      game_state = StateWaiting
      flags_placed = 0
      elapsed_time = 0
    }

    // Timer
    if game_state == StatePlaying {
      elapsed_time = (@raylib.get_time() - start_time).to_int()
      if elapsed_time > 999 {
        elapsed_time = 999
      }
    }

    // Mouse input
    if game_state == StateWaiting || game_state == StatePlaying {
      let mx = @raylib.get_mouse_x()
      let my = @raylib.get_mouse_y()
      let col = (mx - GridOffsetX) / CellSize
      let row = (my - GridOffsetY) / CellSize
      if in_bounds(row, col) && mx >= GridOffsetX && my >= GridOffsetY {
        // Left click — reveal
        if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
          let idx = cell_index(row, col)
          if flagged[idx] == 0 && revealed[idx] == 0 {
            if game_state == StateWaiting {
              // First click: generate mines, start timer
              generate_mines(mines, adjacent, row, col)
              game_state = StatePlaying
              start_time = @raylib.get_time()
            }
            if mines[idx] != 0 {
              // Hit a mine
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

    // === DRAW ===
    @raylib.begin_drawing()
    @raylib.clear_background(bg_color)

    // Header
    let mines_left = MineCount - flags_placed
    @raylib.draw_text(
      "Mines: \{mines_left}",
      GridOffsetX,
      15,
      20,
      @raylib.darkgray,
    )
    // Status text
    let status = match game_state {
      s if s == StateWon => "YOU WIN!"
      s if s == StateLost => "GAME OVER"
      _ => ""
    }
    if status.length() > 0 {
      let status_width = @raylib.measure_text(status, 20)
      @raylib.draw_text(
        status,
        (screen_width - status_width) / 2,
        15,
        20,
        if game_state == StateWon {
          @raylib.darkgreen
        } else {
          @raylib.red
        },
      )
    }
    // Timer
    let timer_text = "Time: \{elapsed_time}"
    let timer_width = @raylib.measure_text(timer_text, 20)
    @raylib.draw_text(
      timer_text,
      screen_width - timer_width - GridOffsetX,
      15,
      20,
      @raylib.darkgray,
    )

    // Grid
    for r in 0..<Rows {
      for c in 0..<Cols {
        let idx = cell_index(r, c)
        let x = GridOffsetX + c * CellSize
        let y = GridOffsetY + r * CellSize
        if revealed[idx] != 0 {
          // Revealed cell
          @raylib.draw_rectangle(x, y, CellSize, CellSize, cell_revealed_bg)
          @raylib.draw_rectangle_lines(x, y, CellSize, CellSize, highlight_dark)
          if mines[idx] != 0 {
            // Mine — draw filled circle
            let cx = x + CellSize / 2
            let cy = y + CellSize / 2
            @raylib.draw_circle(cx, cy, 8.0, @raylib.black)
          } else if adjacent[idx] > 0 {
            // Number
            let num_text = adjacent[idx].to_string()
            let tw = @raylib.measure_text(num_text, 20)
            @raylib.draw_text(
              num_text,
              x + (CellSize - tw) / 2,
              y + (CellSize - 20) / 2,
              20,
              number_color(adjacent[idx]),
            )
          }
        } else {
          // Unrevealed cell — draw 3D raised appearance
          @raylib.draw_rectangle(x, y, CellSize, CellSize, cell_unrevealed)
          // Light edges (top, left)
          @raylib.draw_line(x, y, x + CellSize - 1, y, highlight_light)
          @raylib.draw_line(x, y, x, y + CellSize - 1, highlight_light)
          // Dark edges (bottom, right)
          @raylib.draw_line(
            x,
            y + CellSize - 1,
            x + CellSize - 1,
            y + CellSize - 1,
            highlight_dark,
          )
          @raylib.draw_line(
            x + CellSize - 1,
            y,
            x + CellSize - 1,
            y + CellSize - 1,
            highlight_dark,
          )
          if flagged[idx] != 0 {
            // Flag — red triangle
            let fx = Float::from_int(x + CellSize / 2)
            let fy_top = Float::from_int(y + 5)
            let fy_bot = Float::from_int(y + CellSize - 8)
            let fx_left = Float::from_int(x + 7)
            let fx_right = Float::from_int(x + CellSize - 7)
            @raylib.draw_triangle(
              @raylib.Vector2::new(fx, fy_top),
              @raylib.Vector2::new(fx_left, fy_bot),
              @raylib.Vector2::new(fx_right, fy_bot),
              @raylib.red,
            )
          }
          // Show mines on game over
          if game_state == StateLost && mines[idx] != 0 && flagged[idx] == 0 {
            let cx = x + CellSize / 2
            let cy = y + CellSize / 2
            @raylib.draw_circle(cx, cy, 8.0, @raylib.black)
          }
        }
      }
    }

    // Restart hint
    if game_state == StateWon || game_state == StateLost {
      let hint = "Press R to restart"
      let hint_width = @raylib.measure_text(hint, 16)
      @raylib.draw_text(
        hint,
        (screen_width - hint_width) / 2,
        screen_height - 25,
        16,
        @raylib.darkgray,
      )
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
