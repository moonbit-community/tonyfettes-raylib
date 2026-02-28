// 2D UI overlay rendering

///|
pub fn draw_ui(game : @types.Game) -> Unit {
  if game.state == @types.state_menu {
    draw_menu(game)
  } else if game.state == @types.state_playing {
    draw_hud(game)
    draw_minimap(game)
    draw_crosshair()
  } else if game.state == @types.state_paused {
    draw_hud(game)
    draw_minimap(game)
    draw_pause_overlay(game)
  } else if game.state == @types.state_game_over {
    draw_game_over(game)
  } else if game.state == @types.state_level_up {
    draw_hud(game)
    draw_level_up_overlay(game)
  } else if game.state == @types.state_floor_complete {
    draw_hud(game)
    draw_floor_complete_overlay(game)
  } else if game.state == @types.state_class_select {
    draw_class_select(game)
  } else if game.state == @types.state_shop {
    draw_hud(game)
    draw_shop(game)
  } else if game.state == @types.state_shrine {
    draw_hud(game)
    draw_shrine(game)
  }
  // Damage flash
  if game.damage_flash > 0.0 {
    let alpha = (game.damage_flash / 0.2 * 100.0).to_int()
    let a = @types.clampi(alpha, 0, 150)
    @raylib.draw_rectangle(
      0,
      0,
      @types.screen_width,
      @types.screen_height,
      @raylib.Color::new(255, 0, 0, a),
    )
  }
  // Message overlay
  if game.message_timer > 0.0 {
    let alpha = @types.minf(game.message_timer * 2.0, 1.0)
    let a = (alpha * 255.0).to_int()
    let tw = @raylib.measure_text(game.message_text, 28)
    @raylib.draw_text(
      game.message_text,
      (@types.screen_width - tw) / 2,
      @types.screen_height / 2 - 60,
      28,
      @raylib.Color::new(255, 255, 100, a),
    )
  }
  // Level up glow
  if game.level_up_timer > 0.0 {
    let alpha = (game.level_up_timer / 3.0 * 60.0).to_int()
    let a = @types.clampi(alpha, 0, 60)
    @raylib.draw_rectangle(
      0,
      0,
      @types.screen_width,
      @types.screen_height,
      @raylib.Color::new(255, 255, 100, a),
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
    @raylib.Color::new(5, 5, 15, 255),
  )
  // Title
  let title = "DUNGEON CRAWLER 3D"
  let tw = @raylib.measure_text(title, 52)
  @raylib.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    140,
    52,
    @raylib.Color::new(200, 50, 50, 255),
  )
  // Subtitle
  let sub = "Descend. Fight. Survive."
  let sw = @raylib.measure_text(sub, 22)
  @raylib.draw_text(
    sub,
    (@types.screen_width - sw) / 2,
    200,
    22,
    @raylib.Color::new(180, 150, 130, 255),
  )
  // Decorative torches
  draw_menu_torch(game, @types.screen_width / 2 - 200, 300)
  draw_menu_torch(game, @types.screen_width / 2 + 180, 300)
  // Menu items
  let items : Array[String] = ["New Game", "Continue"]
  for i in 0..<items.length() {
    let y = 330 + i * 55
    let is_selected = game.menu_cursor == i
    let blink_val = @math.sinf(game.menu_blink * 2.0)
    let color = if is_selected {
      if blink_val > 0.0 {
        @raylib.Color::new(255, 200, 80, 255)
      } else {
        @raylib.Color::new(220, 170, 60, 255)
      }
    } else {
      @raylib.Color::new(160, 150, 140, 255)
    }
    let prefix = if is_selected { "> " } else { "  " }
    let text = prefix + items[i]
    let full_w = @raylib.measure_text(text, 32)
    @raylib.draw_text(text, (@types.screen_width - full_w) / 2, y, 32, color)
  }
  // Controls hint
  let hint = "Arrow Keys: Navigate | Enter: Select | WASD: Move | Mouse: Look"
  let hw = @raylib.measure_text(hint, 14)
  @raylib.draw_text(
    hint,
    (@types.screen_width - hw) / 2,
    @types.screen_height - 50,
    14,
    @raylib.Color::new(100, 100, 110, 255),
  )
}

///|
fn draw_menu_torch(game : @types.Game, x : Int, y : Int) -> Unit {
  // Torch post
  @raylib.draw_rectangle(x + 6, y, 8, 40, @raylib.Color::new(100, 70, 30, 255))
  // Flame (animated)
  let flicker = @math.sinf(Float::from_int(game.frame_counter) * 0.15) * 3.0
  let flame_y = y - 12 + flicker.to_int()
  @raylib.draw_circle(
    x + 10,
    flame_y,
    8.0,
    @raylib.Color::new(255, 150, 30, 220),
  )
  @raylib.draw_circle(
    x + 10,
    flame_y - 4,
    5.0,
    @raylib.Color::new(255, 220, 80, 180),
  )
}

///|
fn draw_hud(game : @types.Game) -> Unit {
  // Top bar
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    45,
    @raylib.Color::new(0, 0, 0, 180),
  )
  // Floor name
  let floor_name = "F\{game.current_floor + 1}: \{@levels.get_floor_name(game.current_floor)}"
  @raylib.draw_text(
    floor_name,
    10,
    12,
    20,
    @raylib.Color::new(200, 180, 150, 255),
  )
  // Player level
  let level_text = "Lv.\{game.player_level}"
  @raylib.draw_text(
    level_text,
    @types.screen_width / 2 - 30,
    12,
    20,
    @raylib.Color::new(255, 215, 80, 255),
  )
  // Enemies remaining
  let info = game.floor_info[game.current_floor]
  let alive = info.enemies_total - info.enemies_killed
  let enemy_text = "Enemies: \{alive}"
  let enemy_color = if alive == 0 {
    @raylib.Color::new(80, 255, 80, 255)
  } else {
    @raylib.Color::new(255, 150, 100, 255)
  }
  @raylib.draw_text(enemy_text, @types.screen_width - 200, 12, 18, enemy_color)
  // Bottom bar - health and stats
  @raylib.draw_rectangle(
    0,
    @types.screen_height - 80,
    @types.screen_width,
    80,
    @raylib.Color::new(0, 0, 0, 180),
  )
  // HP bar
  let hp_bar_x = 15
  let hp_bar_y = @types.screen_height - 65
  let hp_bar_w = 250
  let hp_bar_h = 24
  @raylib.draw_rectangle(
    hp_bar_x,
    hp_bar_y,
    hp_bar_w,
    hp_bar_h,
    @raylib.Color::new(60, 20, 20, 255),
  )
  let hp_frac = Float::from_int(game.player_hp) /
    Float::from_int(game.player_max_hp)
  let hp_fill = (Float::from_int(hp_bar_w) * hp_frac).to_int()
  let hp_color = if hp_frac > 0.5 {
    @raylib.Color::new(50, 200, 50, 255)
  } else if hp_frac > 0.25 {
    @raylib.Color::new(220, 200, 30, 255)
  } else {
    @raylib.Color::new(220, 40, 40, 255)
  }
  @raylib.draw_rectangle(hp_bar_x, hp_bar_y, hp_fill, hp_bar_h, hp_color)
  @raylib.draw_rectangle_lines(
    hp_bar_x,
    hp_bar_y,
    hp_bar_w,
    hp_bar_h,
    @raylib.Color::new(180, 180, 180, 255),
  )
  let hp_text = "HP: \{game.player_hp}/\{game.player_max_hp}"
  @raylib.draw_text(
    hp_text,
    hp_bar_x + 8,
    hp_bar_y + 3,
    18,
    @raylib.Color::new(255, 255, 255, 255),
  )
  // XP bar
  let xp_bar_y = @types.screen_height - 35
  let xp_bar_h = 12
  @raylib.draw_rectangle(
    hp_bar_x,
    xp_bar_y,
    hp_bar_w,
    xp_bar_h,
    @raylib.Color::new(20, 20, 60, 255),
  )
  let xp_frac = Float::from_int(game.player_xp) /
    Float::from_int(game.player_xp_next)
  let xp_fill = (Float::from_int(hp_bar_w) * xp_frac).to_int()
  @raylib.draw_rectangle(
    hp_bar_x,
    xp_bar_y,
    xp_fill,
    xp_bar_h,
    @raylib.Color::new(80, 120, 255, 255),
  )
  @raylib.draw_rectangle_lines(
    hp_bar_x,
    xp_bar_y,
    hp_bar_w,
    xp_bar_h,
    @raylib.Color::new(120, 120, 160, 255),
  )
  let xp_text = "XP: \{game.player_xp}/\{game.player_xp_next}"
  @raylib.draw_text(
    xp_text,
    hp_bar_x + 8,
    xp_bar_y - 1,
    10,
    @raylib.Color::new(200, 200, 255, 255),
  )
  // Stats
  let stat_x = 290
  let stat_y = @types.screen_height - 65
  @raylib.draw_text(
    "ATK: \{game.player_atk}",
    stat_x,
    stat_y,
    18,
    @raylib.Color::new(255, 100, 80, 255),
  )
  @raylib.draw_text(
    "DEF: \{game.player_def}",
    stat_x,
    stat_y + 22,
    18,
    @raylib.Color::new(80, 140, 255, 255),
  )
  // Controls hint
  @raylib.draw_text(
    "WASD: Move | Mouse: Look | LMB/Space: Attack | E: Interact | Esc: Pause",
    stat_x + 130,
    @types.screen_height - 25,
    12,
    @raylib.Color::new(120, 120, 130, 255),
  )
}

///|
fn draw_crosshair() -> Unit {
  let cx = @types.screen_width / 2
  let cy = @types.screen_height / 2
  let size = 12
  let thick = 2
  @raylib.draw_rectangle(
    cx - size,
    cy - thick / 2,
    size * 2,
    thick,
    @raylib.Color::new(255, 255, 255, 150),
  )
  @raylib.draw_rectangle(
    cx - thick / 2,
    cy - size,
    thick,
    size * 2,
    @raylib.Color::new(255, 255, 255, 150),
  )
}

///|
fn draw_minimap(game : @types.Game) -> Unit {
  let mx = @types.minimap_x
  let my = @types.minimap_y
  let ms = @types.minimap_size
  // Background
  @raylib.draw_rectangle(
    mx - 2,
    my - 2,
    ms + 4,
    ms + 4,
    @raylib.Color::new(0, 0, 0, 200),
  )
  // Draw explored tiles
  let pgx = @types.world_to_grid_x(game.player_x)
  let pgz = @types.world_to_grid_z(game.player_z)
  let half_view = ms / @types.minimap_cell / 2
  let start_gx = pgx - half_view
  let start_gz = pgz - half_view
  for dy in 0..<(ms / @types.minimap_cell) {
    for dx in 0..<(ms / @types.minimap_cell) {
      let gx = start_gx + dx
      let gz = start_gz + dy
      if not(@types.in_bounds(gx, gz)) {
        continue
      }
      if not(game.explored[@types.tile_index(gx, gz)]) {
        continue
      }
      let tile = @types.get_tile(game, gx, gz)
      let px = mx + dx * @types.minimap_cell
      let py = my + dy * @types.minimap_cell
      let cs = @types.minimap_cell
      if tile == @types.tile_wall {
        @raylib.draw_rectangle(
          px,
          py,
          cs,
          cs,
          @raylib.Color::new(50, 45, 60, 255),
        )
      } else if tile == @types.tile_floor {
        @raylib.draw_rectangle(
          px,
          py,
          cs,
          cs,
          @raylib.Color::new(100, 95, 110, 255),
        )
      } else if tile == @types.tile_door {
        @raylib.draw_rectangle(
          px,
          py,
          cs,
          cs,
          @raylib.Color::new(140, 100, 50, 255),
        )
      } else if tile == @types.tile_stairs {
        @raylib.draw_rectangle(
          px,
          py,
          cs,
          cs,
          @raylib.Color::new(80, 200, 255, 255),
        )
      } else if tile == @types.tile_chest {
        @raylib.draw_rectangle(
          px,
          py,
          cs,
          cs,
          @raylib.Color::new(255, 200, 50, 255),
        )
      }
    }
  }
  // Draw enemies on minimap
  for i in 0..<game.enemies.length() {
    let e = game.enemies[i]
    if not(e.active) {
      continue
    }
    let egx = @types.world_to_grid_x(e.x)
    let egz = @types.world_to_grid_z(e.z)
    if not(@types.in_bounds(egx, egz)) {
      continue
    }
    if not(game.explored[@types.tile_index(egx, egz)]) {
      continue
    }
    // Only show if close enough
    let dist = @types.dist2d(game.player_x, game.player_z, e.x, e.z)
    if dist > 15.0 {
      continue
    }
    let ex = mx + (egx - start_gx) * @types.minimap_cell
    let ey = my + (egz - start_gz) * @types.minimap_cell
    if ex >= mx && ex < mx + ms && ey >= my && ey < my + ms {
      @raylib.draw_rectangle(
        ex,
        ey,
        @types.minimap_cell,
        @types.minimap_cell,
        @raylib.Color::new(255, 50, 50, 255),
      )
    }
  }
  // Draw loot on minimap
  for i in 0..<game.loot.length() {
    let l = game.loot[i]
    if not(l.active) {
      continue
    }
    let lgx = @types.world_to_grid_x(l.x)
    let lgz = @types.world_to_grid_z(l.z)
    if not(@types.in_bounds(lgx, lgz)) {
      continue
    }
    if not(game.explored[@types.tile_index(lgx, lgz)]) {
      continue
    }
    let lx = mx + (lgx - start_gx) * @types.minimap_cell
    let ly = my + (lgz - start_gz) * @types.minimap_cell
    if lx >= mx && lx < mx + ms && ly >= my && ly < my + ms {
      @raylib.draw_rectangle(
        lx,
        ly,
        @types.minimap_cell,
        @types.minimap_cell,
        @raylib.Color::new(50, 255, 100, 255),
      )
    }
  }
  // Draw player dot
  let px = mx + half_view * @types.minimap_cell
  let py = my + half_view * @types.minimap_cell
  @raylib.draw_rectangle(
    px - 1,
    py - 1,
    @types.minimap_cell + 2,
    @types.minimap_cell + 2,
    @raylib.Color::new(255, 255, 255, 255),
  )
  // Player facing direction indicator
  let dir_len : Float = 8.0
  let dir_ex = px + (@math.sinf(game.camera_yaw) * dir_len).to_int()
  let dir_ey = py + (@math.cosf(game.camera_yaw) * dir_len).to_int()
  @raylib.draw_line(
    px + @types.minimap_cell / 2,
    py + @types.minimap_cell / 2,
    dir_ex,
    dir_ey,
    @raylib.Color::new(255, 255, 100, 200),
  )
  // Border
  @raylib.draw_rectangle_lines(
    mx - 2,
    my - 2,
    ms + 4,
    ms + 4,
    @raylib.Color::new(150, 140, 120, 255),
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
    @raylib.Color::new(0, 0, 0, 160),
  )
  let text = "PAUSED"
  let tw = @raylib.measure_text(text, 64)
  @raylib.draw_text(
    text,
    (@types.screen_width - tw) / 2,
    @types.screen_height / 2 - 60,
    64,
    @raylib.Color::new(255, 255, 255, 255),
  )
  let hint1 = "Esc/P: Resume | M: Main Menu"
  let hw = @raylib.measure_text(hint1, 22)
  @raylib.draw_text(
    hint1,
    (@types.screen_width - hw) / 2,
    @types.screen_height / 2 + 20,
    22,
    @raylib.Color::new(200, 200, 220, 255),
  )
}

///|
fn draw_game_over(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(40, 0, 0, 220),
  )
  let text = "YOU DIED"
  let tw = @raylib.measure_text(text, 72)
  @raylib.draw_text(
    text,
    (@types.screen_width - tw) / 2,
    @types.screen_height / 2 - 80,
    72,
    @raylib.Color::new(255, 50, 50, 255),
  )
  let floor_text = "Reached Floor \{game.current_floor + 1} - Level \{game.player_level}"
  let fw = @raylib.measure_text(floor_text, 24)
  @raylib.draw_text(
    floor_text,
    (@types.screen_width - fw) / 2,
    @types.screen_height / 2,
    24,
    @raylib.Color::new(200, 180, 160, 255),
  )
  let hint = "Enter: Try Again | M: Menu"
  let hw = @raylib.measure_text(hint, 20)
  @raylib.draw_text(
    hint,
    (@types.screen_width - hw) / 2,
    @types.screen_height / 2 + 50,
    20,
    @raylib.Color::new(180, 170, 160, 255),
  )
}

///|
fn draw_level_up_overlay(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(0, 0, 0, 120),
  )
  let text = "LEVEL UP!"
  let tw = @raylib.measure_text(text, 56)
  @raylib.draw_text(
    text,
    (@types.screen_width - tw) / 2,
    @types.screen_height / 2 - 80,
    56,
    @raylib.Color::new(255, 215, 0, 255),
  )
  let stats = "Level \{game.player_level} | HP: \{game.player_max_hp} | ATK: \{game.player_atk} | DEF: \{game.player_def}"
  let sw = @raylib.measure_text(stats, 22)
  @raylib.draw_text(
    stats,
    (@types.screen_width - sw) / 2,
    @types.screen_height / 2 - 10,
    22,
    @raylib.Color::new(255, 255, 200, 255),
  )
  let hint = "Press Enter to continue"
  let hw = @raylib.measure_text(hint, 18)
  @raylib.draw_text(
    hint,
    (@types.screen_width - hw) / 2,
    @types.screen_height / 2 + 40,
    18,
    @raylib.Color::new(180, 180, 200, 255),
  )
}

///|
fn draw_floor_complete_overlay(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(0, 0, 0, 160),
  )
  let is_final = game.current_floor >= @types.max_floors - 1
  let title = if is_final { "VICTORY!" } else { "FLOOR CLEARED!" }
  let tw = @raylib.measure_text(title, 52)
  let title_color = if is_final {
    @raylib.Color::new(255, 215, 0, 255)
  } else {
    @raylib.Color::new(80, 255, 120, 255)
  }
  @raylib.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    @types.screen_height / 2 - 80,
    52,
    title_color,
  )
  let floor_text = if is_final {
    "You have conquered the dungeon!"
  } else {
    "Floor \{game.current_floor + 1} complete - descending deeper..."
  }
  let fw = @raylib.measure_text(floor_text, 22)
  @raylib.draw_text(
    floor_text,
    (@types.screen_width - fw) / 2,
    @types.screen_height / 2 - 10,
    22,
    @raylib.Color::new(200, 220, 255, 255),
  )
  let hint = if is_final {
    "Enter: Return to Menu"
  } else {
    "Enter: Next Floor | M: Menu"
  }
  let hw = @raylib.measure_text(hint, 18)
  @raylib.draw_text(
    hint,
    (@types.screen_width - hw) / 2,
    @types.screen_height / 2 + 40,
    18,
    @raylib.Color::new(180, 180, 200, 255),
  )
}

///|
fn draw_class_select(game : @types.Game) -> Unit {
  // Full-screen dark background
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(5, 5, 15, 255),
  )
  // Title
  let title = "CHOOSE YOUR CLASS"
  let tw = @raylib.measure_text(title, 48)
  @raylib.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    80,
    48,
    @raylib.Color::new(200, 180, 100, 255),
  )
  // Class names and descriptions
  let names : Array[String] = ["Warrior", "Rogue", "Mage"]
  let descs : Array[String] = [
    "High HP and defense. Starts with a sword.", "Fast and deadly. Starts with a dagger.",
    "Wields magic. Starts with a staff and spells.",
  ]
  for i in 0..<3 {
    let y = 200 + i * 120
    let is_selected = game.class_select_cursor == i
    // Highlight box for selected class
    if is_selected {
      @raylib.draw_rectangle(
        @types.screen_width / 2 - 260,
        y - 10,
        520,
        100,
        @raylib.Color::new(60, 50, 30, 255),
      )
      @raylib.draw_rectangle_lines(
        @types.screen_width / 2 - 260,
        y - 10,
        520,
        100,
        @raylib.Color::new(255, 200, 80, 255),
      )
    }
    // Class name
    let blink_val = @math.sinf(game.menu_blink * 2.0)
    let name_color = if is_selected {
      if blink_val > 0.0 {
        @raylib.Color::new(255, 220, 80, 255)
      } else {
        @raylib.Color::new(220, 180, 60, 255)
      }
    } else {
      @raylib.Color::new(160, 150, 140, 255)
    }
    let prefix = if is_selected { "> " } else { "  " }
    let name_text = prefix + names[i]
    let nw = @raylib.measure_text(name_text, 36)
    @raylib.draw_text(
      name_text,
      (@types.screen_width - nw) / 2,
      y,
      36,
      name_color,
    )
    // Description
    let desc_color = if is_selected {
      @raylib.Color::new(200, 200, 200, 255)
    } else {
      @raylib.Color::new(120, 120, 120, 255)
    }
    let dw = @raylib.measure_text(descs[i], 18)
    @raylib.draw_text(
      descs[i],
      (@types.screen_width - dw) / 2,
      y + 45,
      18,
      desc_color,
    )
  }
  // Controls hint
  let hint = "Up/Down: Select | Enter: Confirm"
  let hint_w = @raylib.measure_text(hint, 16)
  @raylib.draw_text(
    hint,
    (@types.screen_width - hint_w) / 2,
    @types.screen_height - 60,
    16,
    @raylib.Color::new(100, 100, 110, 255),
  )
}

///|
fn draw_shop(game : @types.Game) -> Unit {
  ignore(game)
  // Semi-transparent overlay
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(0, 0, 0, 180),
  )
  let title = "SHOP"
  let tw = @raylib.measure_text(title, 56)
  @raylib.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    @types.screen_height / 2 - 60,
    56,
    @raylib.Color::new(255, 215, 80, 255),
  )
  let hint = "Press Escape to leave"
  let hw = @raylib.measure_text(hint, 22)
  @raylib.draw_text(
    hint,
    (@types.screen_width - hw) / 2,
    @types.screen_height / 2 + 20,
    22,
    @raylib.Color::new(200, 200, 220, 255),
  )
}

///|
fn draw_shrine(game : @types.Game) -> Unit {
  ignore(game)
  // Semi-transparent overlay
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(0, 0, 0, 180),
  )
  let title = "SHRINE"
  let tw = @raylib.measure_text(title, 56)
  @raylib.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    @types.screen_height / 2 - 60,
    56,
    @raylib.Color::new(120, 200, 255, 255),
  )
  let hint = "Press Escape to leave"
  let hw = @raylib.measure_text(hint, 22)
  @raylib.draw_text(
    hint,
    (@types.screen_width - hw) / 2,
    @types.screen_height / 2 + 20,
    22,
    @raylib.Color::new(200, 200, 220, 255),
  )
}
