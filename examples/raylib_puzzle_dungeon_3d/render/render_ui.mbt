// 2D UI overlay rendering

///|
pub fn draw_ui(game : @types.Game) -> Unit {
  if game.state == @types.state_menu {
    draw_menu(game)
  } else if game.state == @types.state_playing {
    draw_hud(game)
  } else if game.state == @types.state_paused {
    draw_hud(game)
    draw_pause_overlay(game)
  } else if game.state == @types.state_level_complete {
    draw_hud(game)
    draw_level_complete(game)
  } else if game.state == @types.state_game_over {
    draw_game_over(game)
  } else if game.state == @types.state_world_select {
    draw_world_select(game)
  } else if game.state == @types.state_floor_select {
    draw_floor_select(game)
  } else if game.state == @types.state_campaign_complete {
    draw_campaign_complete(game)
  }
  // Message overlay
  if game.message_timer > 0.0 {
    let alpha = @types.minf(game.message_timer * 2.0, 1.0)
    let a = (alpha * 255.0).to_int()
    let tw = @raylib.measure_text(game.message_text, 24)
    @raylib.draw_text(
      game.message_text,
      (@types.screen_width - tw) / 2,
      @types.screen_height / 2 + 80,
      24,
      @raylib.Color::new(255, 255, 200, a),
    )
  }
}

///|
fn draw_menu(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(15, 20, 35, 255),
  )
  // Title
  let title = "PUZZLE DUNGEON 3D"
  let tw = @raylib.measure_text(title, 48)
  @raylib.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    150,
    48,
    @raylib.Color::new(100, 180, 255, 255),
  )
  // Subtitle
  let sub = "Push blocks. Solve puzzles. Ascend."
  let sw = @raylib.measure_text(sub, 20)
  @raylib.draw_text(
    sub,
    (@types.screen_width - sw) / 2,
    210,
    20,
    @raylib.Color::new(150, 160, 180, 255),
  )
  // Menu items
  let items : Array[String] = ["New Game", "World Select", "Floor Select"]
  for i = 0; i < items.length(); i = i + 1 {
    let y = 320 + i * 50
    let is_selected = game.menu_cursor == i
    let blink_val = @math.sinf(game.menu_blink * 2.0)
    let color = if is_selected {
      if blink_val > 0.0 {
        @raylib.Color::new(255, 255, 100, 255)
      } else {
        @raylib.Color::new(200, 200, 80, 255)
      }
    } else {
      @raylib.Color::new(180, 180, 190, 255)
    }
    let iw = @raylib.measure_text(items[i], 30)
    let prefix = if is_selected { "> " } else { "  " }
    let text = prefix + items[i]
    let full_w = @raylib.measure_text(text, 30)
    @raylib.draw_text(text, (@types.screen_width - full_w) / 2, y, 30, color)
    ignore(iw)
  }
  // Controls hint
  @raylib.draw_text(
    "Arrow keys: Navigate | Enter: Select",
    (
      @types.screen_width -
      @raylib.measure_text("Arrow keys: Navigate | Enter: Select", 16)
    ) /
    2,
    @types.screen_height - 60,
    16,
    @raylib.Color::new(120, 120, 140, 255),
  )
}

///|
fn draw_hud(game : @types.Game) -> Unit {
  // Top bar background
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    40,
    @raylib.Color::new(0, 0, 0, 160),
  )
  // Floor name
  let floor_name = "F\{game.current_floor + 1}: \{@levels.get_floor_name(game.current_floor)}"
  @raylib.draw_text(
    floor_name,
    10,
    10,
    20,
    @raylib.Color::new(200, 220, 255, 255),
  )
  // Moves counter
  let moves_text = "Moves: \{game.moves}"
  @raylib.draw_text(
    moves_text,
    @types.screen_width / 2 - 50,
    10,
    20,
    @raylib.Color::new(255, 255, 200, 255),
  )
  // Objectives
  let mut obj_x = @types.screen_width - 300
  if game.plates_total > 0 {
    let plates_text = "Plates: \{game.plates_active}/\{game.plates_total}"
    let plate_color = if game.plates_active >= game.plates_total {
      @raylib.Color::new(100, 255, 100, 255)
    } else {
      @raylib.Color::new(255, 200, 100, 255)
    }
    @raylib.draw_text(plates_text, obj_x, 10, 18, plate_color)
    obj_x += 140
  }
  if game.diamonds_total > 0 {
    let diamond_text = "Gems: \{game.diamonds_collected}/\{game.diamonds_total}"
    let gem_color = if game.diamonds_collected >= game.diamonds_total {
      @raylib.Color::new(100, 255, 100, 255)
    } else {
      @raylib.Color::new(100, 200, 255, 255)
    }
    @raylib.draw_text(diamond_text, obj_x, 10, 18, gem_color)
  }
  if game.keys_held > 0 {
    let key_text = "Keys: \{game.keys_held}"
    @raylib.draw_text(
      key_text,
      @types.screen_width - 100,
      10,
      18,
      @raylib.Color::new(255, 215, 0, 255),
    )
  }
  // Bottom hints
  @raylib.draw_rectangle(
    0,
    @types.screen_height - 30,
    @types.screen_width,
    30,
    @raylib.Color::new(0, 0, 0, 120),
  )
  @raylib.draw_text(
    "WASD/Arrows: Move | Z: Undo | R: Restart | Q/E: Rotate | P: Pause",
    10,
    @types.screen_height - 24,
    14,
    @raylib.Color::new(150, 150, 170, 255),
  )
}

///|
fn draw_pause_overlay(game : @types.Game) -> Unit {
  ignore(game)
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(0, 0, 0, 150),
  )
  let text = "PAUSED"
  let tw = @raylib.measure_text(text, 60)
  @raylib.draw_text(
    text,
    (@types.screen_width - tw) / 2,
    @types.screen_height / 2 - 60,
    60,
    @raylib.Color::new(255, 255, 255, 255),
  )
  let hint1 = "P: Resume | R: Restart | M: Menu"
  let hw = @raylib.measure_text(hint1, 20)
  @raylib.draw_text(
    hint1,
    (@types.screen_width - hw) / 2,
    @types.screen_height / 2 + 20,
    20,
    @raylib.Color::new(200, 200, 220, 255),
  )
}

///|
fn draw_level_complete(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(0, 0, 0, 150),
  )
  let text = "FLOOR COMPLETE!"
  let tw = @raylib.measure_text(text, 48)
  @raylib.draw_text(
    text,
    (@types.screen_width - tw) / 2,
    @types.screen_height / 2 - 100,
    48,
    @raylib.Color::new(100, 255, 120, 255),
  )
  // Stars
  let par = @levels.get_par_moves(game.current_floor)
  let moves_text = "Moves: \{game.moves} (Par: \{par})"
  let mw = @raylib.measure_text(moves_text, 24)
  @raylib.draw_text(
    moves_text,
    (@types.screen_width - mw) / 2,
    @types.screen_height / 2 - 30,
    24,
    @raylib.Color::new(255, 255, 200, 255),
  )
  // Draw stars
  let star_y = @types.screen_height / 2 + 20
  for i = 0; i < 3; i = i + 1 {
    let star_x = @types.screen_width / 2 - 60 + i * 50
    let show_time = Float::from_int(i) * 0.3
    if game.complete_timer > show_time {
      let color = if i < game.complete_stars {
        @raylib.Color::new(255, 215, 0, 255)
      } else {
        @raylib.Color::new(80, 80, 80, 255)
      }
      @raylib.draw_text("*", star_x, star_y, 40, color)
    }
  }
  // Hint
  let hint = "Enter: Next Floor | M: Menu"
  let hintw = @raylib.measure_text(hint, 18)
  @raylib.draw_text(
    hint,
    (@types.screen_width - hintw) / 2,
    @types.screen_height / 2 + 80,
    18,
    @raylib.Color::new(180, 180, 200, 255),
  )
}

///|
fn draw_game_over(game : @types.Game) -> Unit {
  ignore(game)
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(30, 0, 0, 200),
  )
  let text = "STUCK!"
  let tw = @raylib.measure_text(text, 60)
  @raylib.draw_text(
    text,
    (@types.screen_width - tw) / 2,
    @types.screen_height / 2 - 50,
    60,
    @raylib.Color::new(255, 100, 80, 255),
  )
  let hint = "Enter: Retry | M: Menu"
  let hintw = @raylib.measure_text(hint, 20)
  @raylib.draw_text(
    hint,
    (@types.screen_width - hintw) / 2,
    @types.screen_height / 2 + 30,
    20,
    @raylib.Color::new(200, 180, 180, 255),
  )
}

///|
fn draw_floor_select(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(15, 20, 35, 255),
  )
  let title = "SELECT FLOOR"
  let tw = @raylib.measure_text(title, 36)
  @raylib.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    30,
    36,
    @raylib.Color::new(200, 220, 255, 255),
  )
  // Grid of floors (6 per row)
  let cols = 6
  let cell_w = 120
  let cell_h = 80
  let start_x = (@types.screen_width - cols * cell_w) / 2
  let start_y = 100
  for i = 0; i < @types.max_floors; i = i + 1 {
    let col = i % cols
    let row = i / cols
    let x = start_x + col * cell_w
    let y = start_y + row * cell_h
    let info = game.floor_info[i]
    let is_selected = game.floor_select_cursor == i
    // Background
    let bg = if is_selected {
      @raylib.Color::new(60, 80, 120, 255)
    } else if info.unlocked {
      @raylib.Color::new(35, 40, 55, 255)
    } else {
      @raylib.Color::new(20, 22, 30, 255)
    }
    @raylib.draw_rectangle(x + 2, y + 2, cell_w - 4, cell_h - 4, bg)
    if is_selected {
      @raylib.draw_rectangle_lines(
        x + 2,
        y + 2,
        cell_w - 4,
        cell_h - 4,
        @raylib.Color::new(200, 220, 255, 255),
      )
    }
    // Floor number
    let num_text = "\{i + 1}"
    let text_color = if info.unlocked {
      @raylib.Color::new(220, 220, 240, 255)
    } else {
      @raylib.Color::new(60, 60, 70, 255)
    }
    @raylib.draw_text(num_text, x + 10, y + 10, 24, text_color)
    // Stars
    if info.completed {
      for s = 0; s < 3; s = s + 1 {
        let star_color = if s < info.stars {
          @raylib.Color::new(255, 215, 0, 255)
        } else {
          @raylib.Color::new(60, 60, 70, 255)
        }
        @raylib.draw_text("*", x + 10 + s * 16, y + 45, 20, star_color)
      }
    }
    if not(info.unlocked) {
      @raylib.draw_text(
        "LOCKED",
        x + 10,
        y + 45,
        14,
        @raylib.Color::new(80, 60, 60, 255),
      )
    }
  }
  // Selected floor name
  let name = @levels.get_floor_name(game.floor_select_cursor)
  let nw = @raylib.measure_text(name, 22)
  @raylib.draw_text(
    name,
    (@types.screen_width - nw) / 2,
    @types.screen_height - 70,
    22,
    @raylib.Color::new(200, 220, 255, 255),
  )
  @raylib.draw_text(
    "Arrows: Navigate | Enter: Play | Esc: Back",
    (
      @types.screen_width -
      @raylib.measure_text("Arrows: Navigate | Enter: Play | Esc: Back", 16)
    ) /
    2,
    @types.screen_height - 35,
    16,
    @raylib.Color::new(120, 120, 140, 255),
  )
}

///|
fn draw_world_select(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(15, 20, 35, 255),
  )
  let title = "SELECT WORLD"
  let tw = @raylib.measure_text(title, 36)
  @raylib.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    60,
    36,
    @raylib.Color::new(200, 220, 255, 255),
  )
  // Draw world cards
  let card_w = 160
  let card_h = 200
  let gap = 20
  let total_w = @types.num_worlds * card_w + (@types.num_worlds - 1) * gap
  let start_x = (@types.screen_width - total_w) / 2
  let start_y = 160
  for i = 0; i < @types.num_worlds; i = i + 1 {
    let x = start_x + i * (card_w + gap)
    let y = start_y
    let is_selected = game.world_select_cursor == i
    let unlocked = @types.is_world_unlocked(game, i)
    // Card background
    let (ar, ag, ab) = @types.get_world_accent_color(i)
    let bg = if is_selected {
      @raylib.Color::new(ar, ag, ab, 180)
    } else if unlocked {
      @raylib.Color::new(ar / 3, ag / 3, ab / 3, 200)
    } else {
      @raylib.Color::new(20, 22, 30, 200)
    }
    @raylib.draw_rectangle(x, y, card_w, card_h, bg)
    if is_selected {
      @raylib.draw_rectangle_lines(
        x,
        y,
        card_w,
        card_h,
        @raylib.Color::new(255, 255, 255, 255),
      )
    }
    // World name
    let name = @types.get_world_name(i)
    let nw = @raylib.measure_text(name, 18)
    let name_color = if unlocked {
      @raylib.Color::new(240, 240, 255, 255)
    } else {
      @raylib.Color::new(80, 80, 90, 255)
    }
    @raylib.draw_text(name, x + (card_w - nw) / 2, y + 20, 18, name_color)
    // Floor range
    let first = i * @types.floors_per_world + 1
    let last = (i + 1) * @types.floors_per_world
    let range_text = "Floors \{first}-\{last}"
    let rw = @raylib.measure_text(range_text, 14)
    @raylib.draw_text(
      range_text,
      x + (card_w - rw) / 2,
      y + 50,
      14,
      if unlocked {
        @raylib.Color::new(180, 180, 200, 255)
      } else {
        @raylib.Color::new(60, 60, 70, 255)
      },
    )
    // Completion progress
    if unlocked {
      let mut completed = 0
      let floor_start = i * @types.floors_per_world
      for f = floor_start; f < floor_start + @types.floors_per_world; f = f + 1 {
        if game.floor_info[f].completed {
          completed += 1
        }
      }
      let prog_text = "\{completed}/\{@types.floors_per_world}"
      let pw = @raylib.measure_text(prog_text, 16)
      @raylib.draw_text(
        prog_text,
        x + (card_w - pw) / 2,
        y + 120,
        16,
        @raylib.Color::new(200, 200, 220, 255),
      )
    } else {
      let lock_text = "LOCKED"
      let lw = @raylib.measure_text(lock_text, 18)
      @raylib.draw_text(
        lock_text,
        x + (card_w - lw) / 2,
        y + 100,
        18,
        @raylib.Color::new(100, 60, 60, 255),
      )
    }
  }
  // Hint
  @raylib.draw_text(
    "Left/Right: Navigate | Enter: Select | Esc: Back",
    (
      @types.screen_width -
      @raylib.measure_text(
        "Left/Right: Navigate | Enter: Select | Esc: Back", 16,
      )
    ) /
    2,
    @types.screen_height - 50,
    16,
    @raylib.Color::new(120, 120, 140, 255),
  )
}

///|
fn draw_campaign_complete(game : @types.Game) -> Unit {
  ignore(game)
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(10, 20, 40, 255),
  )
  let text = "CONGRATULATIONS!"
  let tw = @raylib.measure_text(text, 48)
  @raylib.draw_text(
    text,
    (@types.screen_width - tw) / 2,
    200,
    48,
    @raylib.Color::new(255, 215, 0, 255),
  )
  let sub = "You completed all 30 floors!"
  let sw = @raylib.measure_text(sub, 24)
  @raylib.draw_text(
    sub,
    (@types.screen_width - sw) / 2,
    270,
    24,
    @raylib.Color::new(200, 220, 255, 255),
  )
  let hint = "Press Enter to return to menu"
  let hw = @raylib.measure_text(hint, 18)
  @raylib.draw_text(
    hint,
    (@types.screen_width - hw) / 2,
    350,
    18,
    @raylib.Color::new(150, 150, 170, 255),
  )
}
