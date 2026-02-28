// 2D UI overlay

///|
pub fn draw_ui(game : @types.Game) -> Unit {
  if game.state == @types.state_menu {
    draw_menu(game)
  } else if game.state == @types.state_map_select {
    draw_map_select(game)
  } else if game.state == @types.state_playing ||
    game.state == @types.state_wave_prep ||
    game.state == @types.state_building ||
    game.state == @types.state_tower_info {
    draw_hud(game)
    draw_economy_panel(game)
    if game.show_minimap {
      draw_minimap(game)
    }
    if game.state == @types.state_wave_prep {
      draw_wave_prep_overlay(game)
    }
    if game.state == @types.state_building {
      draw_build_ui(game)
    }
    if game.state == @types.state_tower_info {
      draw_tower_info_panel(game)
    }
    draw_wave_message(game)
    draw_notification(game)
    draw_speed_indicator(game)
  } else if game.state == @types.state_paused {
    draw_hud(game)
    draw_pause_overlay(game)
  } else if game.state == @types.state_game_over {
    draw_game_over(game)
  } else if game.state == @types.state_victory {
    draw_victory(game)
  }
}

///|
fn draw_menu(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(20, 30, 20, 255),
  )
  // Title
  let title = "TOWER DEFENSE 3D"
  let tw = @raylib.measure_text(title, 48)
  @raylib.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    100,
    48,
    @raylib.Color::new(100, 200, 100, 255),
  )
  // Subtitle
  let sub = "Build towers. Survive the waves. Defend your base."
  let sw = @raylib.measure_text(sub, 18)
  @raylib.draw_text(
    sub,
    (@types.screen_width - sw) / 2,
    160,
    18,
    @raylib.Color::new(150, 180, 150, 255),
  )
  // Decorative line
  @raylib.draw_rectangle(
    (@types.screen_width - 400) / 2,
    190,
    400,
    2,
    @raylib.Color::new(80, 130, 80, 255),
  )
  // Menu items
  let items : Array[String] = [
    "Start Game",
    "Difficulty: " + @types.difficulty_name(game.difficulty),
  ]
  for i in 0..<items.length() {
    let y = 240 + i * 55
    let is_sel = game.menu_cursor == i
    let blink = @math.sinf(game.menu_blink * 2.0)
    let color = if is_sel {
      if blink > 0.0 {
        @raylib.Color::new(255, 255, 100, 255)
      } else {
        @raylib.Color::new(200, 200, 80, 255)
      }
    } else {
      @raylib.Color::new(180, 180, 190, 255)
    }
    let prefix = if is_sel { "> " } else { "  " }
    let text = prefix + items[i]
    let full_w = @raylib.measure_text(text, 28)
    @raylib.draw_text(text, (@types.screen_width - full_w) / 2, y, 28, color)
  }
  // Difficulty description
  let diff_desc = if game.difficulty == 0 {
    "Reduced enemy HP and speed"
  } else if game.difficulty == 2 {
    "Increased enemy HP and speed"
  } else {
    "Standard difficulty"
  }
  let dw = @raylib.measure_text(diff_desc, 14)
  @raylib.draw_text(
    diff_desc,
    (@types.screen_width - dw) / 2,
    295 + 55,
    14,
    @raylib.Color::new(140, 140, 160, 255),
  )
  // Features list
  let features_y = 480
  @raylib.draw_text(
    "Features:",
    (@types.screen_width - 300) / 2,
    features_y,
    16,
    @raylib.Color::new(150, 180, 150, 255),
  )
  let feature_items : Array[String] = [
    "8 Tower Types with 3 Upgrade Levels", "10 Enemy Types including Bosses", "5 Unique Maps | 30 Waves Each",
    "Status Effects: Slow, Burn, Stun, Chain", "Economy: Interest, Sell, Wave Bonuses",
  ]
  for i in 0..<feature_items.length() {
    let fy = features_y + 22 + i * 18
    let feat_w = @raylib.measure_text(feature_items[i], 13)
    @raylib.draw_text(
      feature_items[i],
      (@types.screen_width - feat_w) / 2,
      fy,
      13,
      @raylib.Color::new(120, 140, 120, 255),
    )
    ignore(i)
  }
  // Controls
  @raylib.draw_text(
    "Arrows: Select | Enter: Confirm | Left/Right: Difficulty",
    (
      @types.screen_width -
      @raylib.measure_text(
        "Arrows: Select | Enter: Confirm | Left/Right: Difficulty", 14,
      )
    ) /
    2,
    @types.screen_height - 40,
    14,
    @raylib.Color::new(120, 140, 120, 255),
  )
}

///|
fn draw_map_select(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(20, 25, 30, 255),
  )
  let title = "SELECT MAP"
  let tw = @raylib.measure_text(title, 40)
  @raylib.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    30,
    40,
    @raylib.Color::new(100, 180, 220, 255),
  )
  @raylib.draw_rectangle(
    (@types.screen_width - 350) / 2,
    75,
    350,
    2,
    @raylib.Color::new(60, 100, 150, 255),
  )
  // Map entries
  for i in 0..<@types.map_count {
    let info = @levels.get_map_info(i)
    let y = 100 + i * 110
    let is_sel = game.menu_cursor == i
    let bg = if is_sel {
      @raylib.Color::new(40, 50, 70, 255)
    } else {
      @raylib.Color::new(25, 30, 40, 200)
    }
    @raylib.draw_rectangle(100, y, @types.screen_width - 200, 95, bg)
    if is_sel {
      @raylib.draw_rectangle_lines(
        100,
        y,
        @types.screen_width - 200,
        95,
        @raylib.Color::new(100, 150, 200, 255),
      )
    }
    // Map name
    let name_color = if is_sel {
      @raylib.Color::new(255, 255, 200, 255)
    } else {
      @raylib.Color::new(200, 200, 220, 255)
    }
    @raylib.draw_text(info.name, 120, y + 8, 24, name_color)
    // Description
    @raylib.draw_text(
      info.description,
      120,
      y + 35,
      16,
      @raylib.Color::new(160, 160, 180, 255),
    )
    // Difficulty stars
    let diff_text = "Difficulty: " + difficulty_stars(info.difficulty)
    @raylib.draw_text(
      diff_text,
      120,
      y + 55,
      14,
      @raylib.Color::new(180, 150, 50, 255),
    )
    // Gold bonus
    if info.starting_gold_bonus > 0 {
      @raylib.draw_text(
        "+\{info.starting_gold_bonus}g bonus",
        120,
        y + 73,
        14,
        @raylib.Color::new(255, 215, 0, 200),
      )
    }
    // Map preview (miniature layout)
    draw_map_preview(info, @types.screen_width - 280, y + 10, 150, 75)
    ignore(i)
  }
  @raylib.draw_text(
    "Arrows: Select | Enter: Play | Esc: Back",
    (
      @types.screen_width -
      @raylib.measure_text("Arrows: Select | Enter: Play | Esc: Back", 16)
    ) /
    2,
    @types.screen_height - 40,
    16,
    @raylib.Color::new(120, 140, 150, 255),
  )
}

///|
fn difficulty_stars(diff : Int) -> String {
  if diff == 1 {
    "*"
  } else if diff == 2 {
    "**"
  } else if diff == 3 {
    "***"
  } else {
    "*"
  }
}

///|
fn draw_map_preview(
  info : @types.MapInfo,
  px : Int,
  py : Int,
  pw : Int,
  ph : Int,
) -> Unit {
  @raylib.draw_rectangle(px, py, pw, ph, @raylib.Color::new(30, 35, 45, 255))
  @raylib.draw_rectangle_lines(
    px,
    py,
    pw,
    ph,
    @raylib.Color::new(60, 70, 90, 255),
  )
  let layout = info.layout
  let rows = layout.length()
  if rows == 0 {
    return
  }
  let cell_w = pw / @types.map_w
  let cell_h = ph / @types.map_h
  for gy in 0..<@types.map_h {
    if gy >= rows {
      continue
    }
    let row = layout[gy]
    for gx in 0..<@types.map_w {
      let ch = if gx < row.length() { row[gx] } else { '.' }
      let cx = px + gx * cell_w
      let cy = py + gy * cell_h
      if ch == '#' {
        @raylib.draw_rectangle(
          cx,
          cy,
          cell_w,
          cell_h,
          @raylib.Color::new(160, 140, 100, 255),
        )
      } else if ch == 'S' {
        @raylib.draw_rectangle(
          cx,
          cy,
          cell_w,
          cell_h,
          @raylib.Color::new(50, 200, 50, 255),
        )
      } else if ch == 'E' {
        @raylib.draw_rectangle(
          cx,
          cy,
          cell_w,
          cell_h,
          @raylib.Color::new(200, 50, 50, 255),
        )
      } else if ch == '~' {
        @raylib.draw_rectangle(
          cx,
          cy,
          cell_w,
          cell_h,
          @raylib.Color::new(40, 80, 180, 200),
        )
      } else if ch == 'R' {
        @raylib.draw_rectangle(
          cx,
          cy,
          cell_w,
          cell_h,
          @raylib.Color::new(80, 75, 70, 255),
        )
      }
    }
  }
}

///|
fn draw_hud(game : @types.Game) -> Unit {
  // Top bar background
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    45,
    @raylib.Color::new(0, 0, 0, 180),
  )
  // Gold
  @raylib.draw_text(
    "Gold: \{game.gold}",
    10,
    12,
    20,
    @raylib.Color::new(255, 215, 0, 255),
  )
  // Lives (with color based on remaining)
  let lives_color = if game.lives > 15 {
    @raylib.Color::new(100, 255, 100, 255)
  } else if game.lives > 8 {
    @raylib.Color::new(255, 200, 50, 255)
  } else {
    @raylib.Color::new(255, 80, 80, 255)
  }
  @raylib.draw_text("Lives: \{game.lives}", 180, 12, 20, lives_color)
  // Wave
  @raylib.draw_text(
    "Wave: \{game.current_wave + 1}/\{@types.max_waves}",
    350,
    12,
    20,
    @raylib.Color::new(200, 220, 255, 255),
  )
  // Score
  @raylib.draw_text(
    "Score: \{game.score}",
    530,
    12,
    20,
    @raylib.Color::new(200, 200, 200, 255),
  )
  // Enemies alive count
  let alive = @types.count_active_enemies(game)
  if alive > 0 {
    @raylib.draw_text(
      "Enemies: \{alive}",
      700,
      12,
      20,
      @raylib.Color::new(255, 150, 150, 255),
    )
  }
  // Tower count
  let tower_count = @types.count_active_towers(game)
  @raylib.draw_text(
    "Towers: \{tower_count}",
    870,
    12,
    16,
    @raylib.Color::new(180, 180, 200, 255),
  )
  // Bottom bar
  @raylib.draw_rectangle(
    0,
    @types.screen_height - 30,
    @types.screen_width,
    30,
    @raylib.Color::new(0, 0, 0, 140),
  )
  @raylib.draw_text(
    "B:Build Q/E:Rotate W/A/S/D:Pan R:Ranges M:Map P:Pause Tab:Speed T:Tower Info Z/X:Pitch",
    10,
    @types.screen_height - 24,
    12,
    @raylib.Color::new(150, 150, 170, 255),
  )
}

///|
fn draw_economy_panel(game : @types.Game) -> Unit {
  // Small economy info in top-right
  let px = @types.screen_width - 160
  let py = 50
  @raylib.draw_rectangle(px, py, 155, 65, @raylib.Color::new(0, 0, 0, 140))
  @raylib.draw_rectangle_lines(
    px,
    py,
    155,
    65,
    @raylib.Color::new(60, 60, 80, 200),
  )
  // Interest timer
  let interest_pct = game.interest_timer / @types.interest_interval
  let bar_wf : Float = 130.0 * interest_pct
  let bar_w = bar_wf.to_int()
  @raylib.draw_text(
    "Interest:",
    px + 5,
    py + 5,
    12,
    @raylib.Color::new(180, 180, 200, 255),
  )
  @raylib.draw_rectangle(
    px + 5,
    py + 20,
    130,
    8,
    @raylib.Color::new(40, 40, 50, 255),
  )
  @raylib.draw_rectangle(
    px + 5,
    py + 20,
    bar_w,
    8,
    @raylib.Color::new(100, 180, 50, 200),
  )
  // Kill count this wave
  @raylib.draw_text(
    "Kills: \{game.enemies_killed_this_wave}",
    px + 5,
    py + 32,
    12,
    @raylib.Color::new(200, 150, 150, 255),
  )
  // Total kills
  @raylib.draw_text(
    "Total: \{game.total_kills}",
    px + 5,
    py + 46,
    12,
    @raylib.Color::new(180, 180, 180, 255),
  )
}

///|
fn draw_minimap(game : @types.Game) -> Unit {
  let mx = @types.minimap_x
  let my = @types.minimap_y
  let ms = @types.minimap_size
  let mw = ms
  let mh = ms * @types.map_h / @types.map_w
  // Background
  @raylib.draw_rectangle(
    mx - 2,
    my - 2,
    mw + 4,
    mh + 4,
    @raylib.Color::new(0, 0, 0, 200),
  )
  @raylib.draw_rectangle(mx, my, mw, mh, @raylib.Color::new(30, 40, 30, 220))
  // Draw tiles
  let cw = mw / @types.map_w
  let ch = mh / @types.map_h
  for gy in 0..<@types.map_h {
    for gx in 0..<@types.map_w {
      let tile = @types.get_tile(game, gx, gy)
      let cx = mx + gx * cw
      let cy = my + gy * ch
      if tile == @types.tile_path {
        @raylib.draw_rectangle(
          cx,
          cy,
          cw,
          ch,
          @raylib.Color::new(160, 140, 100, 200),
        )
      } else if tile == @types.tile_start {
        @raylib.draw_rectangle(
          cx,
          cy,
          cw,
          ch,
          @raylib.Color::new(50, 200, 50, 255),
        )
      } else if tile == @types.tile_end {
        @raylib.draw_rectangle(
          cx,
          cy,
          cw,
          ch,
          @raylib.Color::new(200, 50, 50, 255),
        )
      } else if tile == @types.tile_water {
        @raylib.draw_rectangle(
          cx,
          cy,
          cw,
          ch,
          @raylib.Color::new(40, 80, 180, 200),
        )
      } else if tile == @types.tile_rock {
        @raylib.draw_rectangle(
          cx,
          cy,
          cw,
          ch,
          @raylib.Color::new(80, 75, 70, 200),
        )
      }
    }
  }
  // Draw towers on minimap
  for i in 0..<game.towers.length() {
    let tower = game.towers[i]
    if not(tower.active) {
      continue
    }
    let cx = mx + tower.gx * cw
    let cy = my + tower.gy * ch
    @raylib.draw_rectangle(
      cx,
      cy,
      cw,
      ch,
      @raylib.Color::new(50, 150, 255, 255),
    )
  }
  // Draw enemies on minimap
  for i in 0..<game.enemies.length() {
    let enemy = game.enemies[i]
    if not(enemy.active) {
      continue
    }
    let egx = @types.world_to_grid_x(enemy.x)
    let egy = @types.world_to_grid_y(enemy.z)
    let cx = mx + egx * cw
    let cy = my + egy * ch
    let enemy_mm_color = if enemy.is_boss {
      @raylib.Color::new(255, 50, 255, 255)
    } else {
      @raylib.Color::new(255, 80, 80, 255)
    }
    @raylib.draw_rectangle(
      cx,
      cy,
      @types.maxi(cw, 2),
      @types.maxi(ch, 2),
      enemy_mm_color,
    )
  }
  // Border
  @raylib.draw_rectangle_lines(
    mx,
    my,
    mw,
    mh,
    @raylib.Color::new(100, 120, 100, 200),
  )
  // Label
  @raylib.draw_text(
    "Map",
    mx,
    my - 14,
    12,
    @raylib.Color::new(150, 170, 150, 255),
  )
}

///|
fn draw_wave_prep_overlay(game : @types.Game) -> Unit {
  let timer_text = "Next wave in: \{game.wave_timer.to_int() + 1}"
  let tw = @raylib.measure_text(timer_text, 30)
  @raylib.draw_rectangle(
    (@types.screen_width - tw) / 2 - 15,
    50,
    tw + 30,
    45,
    @raylib.Color::new(0, 0, 0, 180),
  )
  @raylib.draw_text(
    timer_text,
    (@types.screen_width - tw) / 2,
    58,
    30,
    @raylib.Color::new(255, 200, 100, 255),
  )
  // Next wave preview
  if game.current_wave < @types.max_waves {
    let info = @levels.get_wave_info(game.current_wave)
    let preview_y = 100
    @raylib.draw_rectangle(
      (@types.screen_width - 300) / 2,
      preview_y,
      300,
      55,
      @raylib.Color::new(0, 0, 0, 150),
    )
    let entry = info.entries[0]
    let enemy_name = @types.enemy_name(entry.enemy_kind)
    @raylib.draw_text(
      "Next: \{entry.count}x \{enemy_name}",
      (@types.screen_width - 280) / 2,
      preview_y + 5,
      18,
      @raylib.Color::new(220, 200, 180, 255),
    )
    if info.is_boss_wave {
      @raylib.draw_text(
        "!! BOSS WAVE !!",
        (@types.screen_width - @raylib.measure_text("!! BOSS WAVE !!", 18)) / 2,
        preview_y + 28,
        18,
        @raylib.Color::new(255, 80, 80, 255),
      )
    } else {
      @raylib.draw_text(
        "Bonus: +\{info.bonus_gold}g",
        (@types.screen_width - 280) / 2,
        preview_y + 28,
        14,
        @raylib.Color::new(255, 215, 0, 200),
      )
    }
  }
  @raylib.draw_text(
    "Space: Start Now | B: Build Towers",
    (
      @types.screen_width -
      @raylib.measure_text("Space: Start Now | B: Build Towers", 16)
    ) /
    2,
    160,
    16,
    @raylib.Color::new(200, 200, 220, 255),
  )
}

///|
fn draw_build_ui(game : @types.Game) -> Unit {
  // Tower selection panel on right
  let panel_x = @types.screen_width - 230
  let panel_y = 50
  let panel_h = 500
  @raylib.draw_rectangle(
    panel_x,
    panel_y,
    225,
    panel_h,
    @raylib.Color::new(20, 25, 35, 230),
  )
  @raylib.draw_rectangle_lines(
    panel_x,
    panel_y,
    225,
    panel_h,
    @raylib.Color::new(80, 100, 130, 255),
  )
  @raylib.draw_text(
    "BUILD TOWER",
    panel_x + 10,
    panel_y + 8,
    20,
    @raylib.Color::new(200, 220, 255, 255),
  )
  @raylib.draw_rectangle(
    panel_x + 10,
    panel_y + 30,
    205,
    1,
    @raylib.Color::new(60, 80, 110, 255),
  )
  let tower_types : Array[(Int, String, Int, String)] = [
    (@types.tower_arrow, "1: Arrow", @types.cost_arrow, "Fast single"),
    (@types.tower_cannon, "2: Cannon", @types.cost_cannon, "Splash dmg"),
    (@types.tower_frost, "3: Frost", @types.cost_frost, "Slows"),
    (@types.tower_lightning, "4: Lightning", @types.cost_lightning, "Chain"),
    (@types.tower_flame, "5: Flame", @types.cost_flame, "Burns"),
    (@types.tower_sniper, "6: Sniper", @types.cost_sniper, "Crit shots"),
    (@types.tower_splash, "7: Splash", @types.cost_splash, "Area dmg"),
    (@types.tower_buff, "8: Buff", @types.cost_buff, "Boosts"),
  ]
  for i in 0..<tower_types.length() {
    let entry = tower_types[i]
    let y = panel_y + 38 + i * 55
    let is_sel = game.selected_tower_type == entry.0
    let can_afford = game.gold >= entry.2
    let bg = if is_sel {
      @raylib.Color::new(50, 60, 80, 255)
    } else {
      @raylib.Color::new(30, 35, 45, 255)
    }
    @raylib.draw_rectangle(panel_x + 5, y, 215, 50, bg)
    if is_sel {
      @raylib.draw_rectangle_lines(
        panel_x + 5,
        y,
        215,
        50,
        @raylib.Color::new(120, 150, 200, 255),
      )
    }
    let text_color = if can_afford {
      @raylib.Color::new(220, 220, 240, 255)
    } else {
      @raylib.Color::new(100, 80, 80, 255)
    }
    @raylib.draw_text(entry.1, panel_x + 12, y + 5, 16, text_color)
    @raylib.draw_text(
      "\{entry.2}g",
      panel_x + 12,
      y + 22,
      14,
      @raylib.Color::new(255, 215, 0, 200),
    )
    // Description
    @raylib.draw_text(
      entry.3,
      panel_x + 80,
      y + 22,
      12,
      @raylib.Color::new(150, 150, 170, 200),
    )
    // Stats preview
    let dmg = @types.tower_damage(entry.0)
    let rng = @types.tower_range(entry.0)
    @raylib.draw_text(
      "D:\{dmg.to_int()} R:\{rng.to_int()}",
      panel_x + 12,
      y + 36,
      11,
      @raylib.Color::new(130, 130, 150, 200),
    )
  }
  // Controls reminder
  @raylib.draw_text(
    "Arrows:Move Enter:Place",
    panel_x + 10,
    panel_y + panel_h - 18,
    11,
    @raylib.Color::new(130, 130, 150, 255),
  )
  // Show cursor position
  @raylib.draw_text(
    "Pos: \{game.hover_gx},\{game.hover_gy}",
    10,
    50,
    18,
    @raylib.Color::new(200, 200, 200, 255),
  )
  // Show selected tower cost
  let cost = @types.tower_cost(game.selected_tower_type)
  let cost_color = if game.gold >= cost {
    @raylib.Color::new(255, 215, 0, 255)
  } else {
    @raylib.Color::new(255, 80, 80, 255)
  }
  @raylib.draw_text("Cost: \{cost}g", 10, 72, 16, cost_color)
}

///|
fn draw_tower_info_panel(game : @types.Game) -> Unit {
  if game.selected_tower_idx < 0 {
    return
  }
  let tower = game.towers[game.selected_tower_idx]
  if not(tower.active) {
    return
  }
  let px = @types.screen_width - 260
  let py = 50
  let pw = 255
  let ph = 400
  @raylib.draw_rectangle(px, py, pw, ph, @raylib.Color::new(15, 20, 30, 240))
  @raylib.draw_rectangle_lines(
    px,
    py,
    pw,
    ph,
    @raylib.Color::new(80, 100, 140, 255),
  )
  // Tower name and level
  let name = @types.tower_name(tower.kind)
  @raylib.draw_text(
    "\{name} Lv.\{tower.level}",
    px + 10,
    py + 8,
    22,
    @raylib.Color::new(220, 220, 255, 255),
  )
  // Level stars
  let level_text = if tower.level == 1 {
    "*"
  } else if tower.level == 2 {
    "**"
  } else {
    "***"
  }
  @raylib.draw_text(
    level_text,
    px + pw - 50,
    py + 10,
    20,
    @raylib.Color::new(255, 215, 0, 255),
  )
  @raylib.draw_rectangle(
    px + 10,
    py + 35,
    pw - 20,
    1,
    @raylib.Color::new(60, 80, 110, 255),
  )
  // Stats
  let stat_y = py + 45
  let dmg = @types.tower_effective_damage(tower)
  let rng = @types.tower_effective_range(tower)
  let rate = @types.tower_effective_rate(tower)
  let dps : Float = dmg / rate
  @raylib.draw_text(
    "Damage: \{dmg.to_int()}",
    px + 10,
    stat_y,
    16,
    @raylib.Color::new(255, 150, 100, 255),
  )
  @raylib.draw_text(
    "Range: \{rng.to_int()}",
    px + 10,
    stat_y + 20,
    16,
    @raylib.Color::new(100, 200, 255, 255),
  )
  @raylib.draw_text(
    "Fire Rate: \{rate.to_int()}s",
    px + 10,
    stat_y + 40,
    16,
    @raylib.Color::new(200, 200, 100, 255),
  )
  @raylib.draw_text(
    "DPS: \{dps.to_int()}",
    px + 10,
    stat_y + 60,
    16,
    @raylib.Color::new(255, 200, 150, 255),
  )
  // Targeting mode
  let mode_name = @types.targeting_mode_name(tower.targeting_mode)
  @raylib.draw_text(
    "Target: \{mode_name}",
    px + 10,
    stat_y + 85,
    16,
    @raylib.Color::new(180, 180, 220, 255),
  )
  // Kill stats
  @raylib.draw_rectangle(
    px + 10,
    stat_y + 105,
    pw - 20,
    1,
    @raylib.Color::new(50, 60, 80, 255),
  )
  @raylib.draw_text(
    "Kills: \{tower.kills}",
    px + 10,
    stat_y + 112,
    14,
    @raylib.Color::new(200, 150, 150, 255),
  )
  @raylib.draw_text(
    "Damage: \{tower.total_damage.to_int()}",
    px + 10,
    stat_y + 130,
    14,
    @raylib.Color::new(200, 150, 150, 255),
  )
  // Buff indicators
  if tower.buff_damage > 0.0 || tower.buff_range > 0.0 || tower.buff_rate > 0.0 {
    @raylib.draw_text(
      "BUFFED",
      px + 10,
      stat_y + 150,
      14,
      @raylib.Color::new(200, 150, 255, 255),
    )
  }
  // Upgrade section
  @raylib.draw_rectangle(
    px + 10,
    stat_y + 170,
    pw - 20,
    1,
    @raylib.Color::new(50, 60, 80, 255),
  )
  if tower.level < 3 {
    let upgrade_info = @types.get_upgrade_info(tower.kind, tower.level)
    let can_afford = game.gold >= upgrade_info.cost
    let upgrade_color = if can_afford {
      @raylib.Color::new(100, 255, 100, 255)
    } else {
      @raylib.Color::new(255, 100, 100, 255)
    }
    @raylib.draw_text(
      "[U] Upgrade: \{upgrade_info.cost}g",
      px + 10,
      stat_y + 180,
      16,
      upgrade_color,
    )
    @raylib.draw_text(
      upgrade_info.special_desc,
      px + 10,
      stat_y + 200,
      13,
      @raylib.Color::new(160, 160, 180, 255),
    )
    // Stat comparison preview
    let new_dmg = @types.tower_damage(tower.kind) * upgrade_info.damage_mult
    let new_rng = @types.tower_range(tower.kind) * upgrade_info.range_mult
    @raylib.draw_text(
      "DMG: \{dmg.to_int()} -> \{new_dmg.to_int()}",
      px + 10,
      stat_y + 218,
      12,
      @raylib.Color::new(255, 200, 100, 200),
    )
    @raylib.draw_text(
      "RNG: \{rng.to_int()} -> \{new_rng.to_int()}",
      px + 10,
      stat_y + 233,
      12,
      @raylib.Color::new(150, 200, 255, 200),
    )
  } else {
    @raylib.draw_text(
      "MAX LEVEL",
      px + 10,
      stat_y + 180,
      16,
      @raylib.Color::new(255, 215, 0, 255),
    )
  }
  // Sell section
  let sell_val = @types.tower_sell_value(tower.kind, tower.level)
  @raylib.draw_text(
    "[S] Sell: \{sell_val}g",
    px + 10,
    stat_y + 260,
    16,
    @raylib.Color::new(255, 180, 50, 255),
  )
  // Targeting mode change
  @raylib.draw_text(
    "[F] Cycle Target | [<>] Nav Towers",
    px + 10,
    stat_y + 285,
    11,
    @raylib.Color::new(130, 130, 150, 255),
  )
  // Close instruction
  @raylib.draw_text(
    "[T/Esc] Close",
    px + 10,
    stat_y + 305,
    12,
    @raylib.Color::new(130, 130, 150, 255),
  )
}

///|
fn draw_wave_message(game : @types.Game) -> Unit {
  if game.wave_message_timer <= 0.0 {
    return
  }
  let alpha_f : Float = @types.minf(game.wave_message_timer / 0.5, 1.0) * 255.0
  let alpha = @types.clampi(alpha_f.to_int(), 0, 255)
  let msg = game.wave_message
  let mw = @raylib.measure_text(msg, 32)
  let msg_y = @types.screen_height / 3
  @raylib.draw_rectangle(
    (@types.screen_width - mw) / 2 - 15,
    msg_y - 5,
    mw + 30,
    44,
    @raylib.Color::new(0, 0, 0, alpha / 2),
  )
  let is_boss = msg == "BOSS WAVE!" ||
    msg == "Double BOSS!" ||
    msg == "Triple BOSS!" ||
    msg == "Quad BOSS!" ||
    msg == "FINAL BOSS WAVE!"
  let color = if is_boss {
    @raylib.Color::new(255, 80, 80, alpha)
  } else {
    @raylib.Color::new(255, 255, 200, alpha)
  }
  @raylib.draw_text(msg, (@types.screen_width - mw) / 2, msg_y, 32, color)
}

///|
fn draw_notification(game : @types.Game) -> Unit {
  if game.notification_timer <= 0.0 {
    return
  }
  let alpha_f : Float = @types.minf(game.notification_timer / 0.3, 1.0) * 255.0
  let alpha = @types.clampi(alpha_f.to_int(), 0, 255)
  let msg = game.notification_text
  let mw = @raylib.measure_text(msg, 16)
  let ny = @types.screen_height - 60
  @raylib.draw_rectangle(
    (@types.screen_width - mw) / 2 - 10,
    ny - 3,
    mw + 20,
    24,
    @raylib.Color::new(0, 0, 0, alpha / 2),
  )
  @raylib.draw_text(
    msg,
    (@types.screen_width - mw) / 2,
    ny,
    16,
    @raylib.Color::new(220, 220, 240, alpha),
  )
}

///|
fn draw_speed_indicator(game : @types.Game) -> Unit {
  let speed_text = @types.speed_name(game.speed_setting)
  let sx = @types.screen_width - 60
  let sy = @types.screen_height - 55
  let bg_color = if game.speed_setting == 0 {
    @raylib.Color::new(50, 80, 50, 200)
  } else if game.speed_setting == 1 {
    @raylib.Color::new(80, 80, 50, 200)
  } else {
    @raylib.Color::new(80, 50, 50, 200)
  }
  @raylib.draw_rectangle(sx - 5, sy - 3, 55, 22, bg_color)
  @raylib.draw_text(
    speed_text,
    sx,
    sy,
    16,
    @raylib.Color::new(255, 255, 200, 255),
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
  let tw = @raylib.measure_text(text, 60)
  @raylib.draw_text(
    text,
    (@types.screen_width - tw) / 2,
    @types.screen_height / 2 - 60,
    60,
    @raylib.white,
  )
  @raylib.draw_text(
    "P: Resume | Q: Quit to Menu",
    (
      @types.screen_width -
      @raylib.measure_text("P: Resume | Q: Quit to Menu", 20)
    ) /
    2,
    @types.screen_height / 2 + 10,
    20,
    @raylib.Color::new(200, 200, 220, 255),
  )
  // Show game stats
  let stats_y = @types.screen_height / 2 + 60
  @raylib.draw_rectangle(
    (@types.screen_width - 300) / 2,
    stats_y,
    300,
    100,
    @raylib.Color::new(0, 0, 0, 120),
  )
  @raylib.draw_text(
    "Towers Built: \{game.towers_built} | Sold: \{game.towers_sold}",
    (@types.screen_width - 280) / 2,
    stats_y + 10,
    14,
    @raylib.Color::new(180, 180, 200, 255),
  )
  @raylib.draw_text(
    "Total Kills: \{game.total_kills}",
    (@types.screen_width - 280) / 2,
    stats_y + 30,
    14,
    @raylib.Color::new(180, 180, 200, 255),
  )
  @raylib.draw_text(
    "Damage Dealt: \{game.damage_dealt.to_int()}",
    (@types.screen_width - 280) / 2,
    stats_y + 50,
    14,
    @raylib.Color::new(180, 180, 200, 255),
  )
  @raylib.draw_text(
    "Gold Earned: \{game.total_gold_earned} | Spent: \{game.total_gold_spent}",
    (@types.screen_width - 280) / 2,
    stats_y + 70,
    14,
    @raylib.Color::new(255, 215, 0, 200),
  )
}

///|
fn draw_game_over(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(30, 0, 0, 230),
  )
  let text = "GAME OVER"
  let tw = @raylib.measure_text(text, 60)
  @raylib.draw_text(
    text,
    (@types.screen_width - tw) / 2,
    @types.screen_height / 2 - 100,
    60,
    @raylib.Color::new(255, 80, 60, 255),
  )
  // Stats summary
  let stats_y = @types.screen_height / 2 - 20
  @raylib.draw_rectangle(
    (@types.screen_width - 350) / 2,
    stats_y,
    350,
    150,
    @raylib.Color::new(0, 0, 0, 120),
  )
  let sx = (@types.screen_width - 330) / 2
  @raylib.draw_text(
    "Score: \{game.score}",
    sx,
    stats_y + 10,
    22,
    @raylib.Color::new(200, 200, 200, 255),
  )
  @raylib.draw_text(
    "Wave Reached: \{game.current_wave + 1}/\{@types.max_waves}",
    sx,
    stats_y + 38,
    18,
    @raylib.Color::new(200, 220, 255, 255),
  )
  @raylib.draw_text(
    "Total Kills: \{game.total_kills}",
    sx,
    stats_y + 62,
    16,
    @raylib.Color::new(200, 150, 150, 255),
  )
  @raylib.draw_text(
    "Towers Built: \{game.towers_built}",
    sx,
    stats_y + 82,
    16,
    @raylib.Color::new(150, 200, 255, 255),
  )
  @raylib.draw_text(
    "Gold Earned: \{game.total_gold_earned}",
    sx,
    stats_y + 102,
    16,
    @raylib.Color::new(255, 215, 0, 200),
  )
  @raylib.draw_text(
    "Damage Dealt: \{game.damage_dealt.to_int()}",
    sx,
    stats_y + 122,
    16,
    @raylib.Color::new(255, 180, 100, 200),
  )
  @raylib.draw_text(
    "Enter: Return to Menu",
    (@types.screen_width - @raylib.measure_text("Enter: Return to Menu", 18)) /
    2,
    @types.screen_height / 2 + 150,
    18,
    @raylib.Color::new(180, 180, 200, 255),
  )
}

///|
fn draw_victory(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(0, 30, 0, 230),
  )
  let text = "VICTORY!"
  let tw = @raylib.measure_text(text, 60)
  @raylib.draw_text(
    text,
    (@types.screen_width - tw) / 2,
    @types.screen_height / 2 - 100,
    60,
    @raylib.Color::new(100, 255, 100, 255),
  )
  // Stats summary
  let stats_y = @types.screen_height / 2 - 20
  @raylib.draw_rectangle(
    (@types.screen_width - 350) / 2,
    stats_y,
    350,
    170,
    @raylib.Color::new(0, 0, 0, 120),
  )
  let sx = (@types.screen_width - 330) / 2
  @raylib.draw_text(
    "Final Score: \{game.score}",
    sx,
    stats_y + 10,
    22,
    @raylib.Color::new(255, 255, 200, 255),
  )
  @raylib.draw_text(
    "Lives Remaining: \{game.lives}",
    sx,
    stats_y + 38,
    18,
    @raylib.Color::new(100, 255, 100, 255),
  )
  @raylib.draw_text(
    "Total Kills: \{game.total_kills}",
    sx,
    stats_y + 62,
    16,
    @raylib.Color::new(200, 150, 150, 255),
  )
  @raylib.draw_text(
    "Towers Built: \{game.towers_built} | Sold: \{game.towers_sold}",
    sx,
    stats_y + 82,
    16,
    @raylib.Color::new(150, 200, 255, 255),
  )
  @raylib.draw_text(
    "Gold Earned: \{game.total_gold_earned} | Spent: \{game.total_gold_spent}",
    sx,
    stats_y + 102,
    16,
    @raylib.Color::new(255, 215, 0, 200),
  )
  @raylib.draw_text(
    "Damage Dealt: \{game.damage_dealt.to_int()}",
    sx,
    stats_y + 122,
    16,
    @raylib.Color::new(255, 180, 100, 200),
  )
  // Difficulty bonus display
  let diff_text = "Difficulty: " + @types.difficulty_name(game.difficulty)
  @raylib.draw_text(
    diff_text,
    sx,
    stats_y + 142,
    16,
    @raylib.Color::new(200, 200, 220, 200),
  )
  @raylib.draw_text(
    "Enter: Return to Menu",
    (@types.screen_width - @raylib.measure_text("Enter: Return to Menu", 18)) /
    2,
    @types.screen_height / 2 + 170,
    18,
    @raylib.Color::new(180, 200, 180, 255),
  )
}
