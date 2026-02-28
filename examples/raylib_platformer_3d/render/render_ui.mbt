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
  } else if game.state == @types.state_campaign_complete {
    draw_campaign_complete(game)
  } else if game.state == @types.state_level_select {
    draw_level_select(game)
  } else if game.state == @types.state_death_anim {
    draw_hud(game)
    draw_death_overlay(game)
  } else if game.state == @types.state_world_intro {
    draw_world_intro(game)
  }
  // Score flies (drawn over everything)
  draw_score_flies(game)
}

///|
fn draw_menu(game : @types.Game) -> Unit {
  let bg = @levels.world_bg_color(0)
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(bg.0, bg.1, bg.2, 255),
  )
  // Animated background elements
  let wave_y = @math.sinf(game.menu_blink * 0.5) * 10.0
  for i in 0..<5 {
    let bx = 50 + i * 220
    let by = 500 + (wave_y * Float::from_int(i + 1) * 0.3).to_int()
    @raylib.draw_rectangle(
      bx,
      by,
      150,
      80,
      @raylib.Color::new(bg.0 - 15, bg.1 - 15, bg.2 - 10, 80),
    )
    ignore(i)
  }
  // Title
  let title = "PLATFORMER 3D"
  let tw = @raylib.measure_text(title, 52)
  // Title shadow
  @raylib.draw_text(
    title,
    (@types.screen_width - tw) / 2 + 2,
    122,
    52,
    @raylib.Color::new(0, 0, 0, 80),
  )
  @raylib.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    120,
    52,
    @raylib.Color::new(255, 255, 255, 255),
  )
  // Subtitle
  let sub = "Jump. Collect. Ascend."
  let sw = @raylib.measure_text(sub, 20)
  @raylib.draw_text(
    sub,
    (@types.screen_width - sw) / 2,
    185,
    20,
    @raylib.Color::new(220, 220, 240, 255),
  )
  // Decorative line
  @raylib.draw_rectangle(
    (@types.screen_width - 300) / 2,
    215,
    300,
    2,
    @raylib.Color::new(200, 200, 220, 150),
  )
  // Menu items
  let items : Array[String] = ["New Game", "World Select", "Level Select"]
  for i in 0..<items.length() {
    let y = 280 + i * 50
    let is_sel = game.menu_cursor == i
    let blink = @math.sinf(game.menu_blink * 2.0)
    let color = if is_sel {
      if blink > 0.0 {
        @raylib.Color::new(255, 255, 100, 255)
      } else {
        @raylib.Color::new(200, 200, 80, 255)
      }
    } else {
      @raylib.Color::new(200, 200, 220, 255)
    }
    let prefix = if is_sel { "> " } else { "  " }
    let text = prefix + items[i]
    let full_w = @raylib.measure_text(text, 28)
    // Selection highlight bar
    if is_sel {
      @raylib.draw_rectangle(
        (@types.screen_width - full_w) / 2 - 15,
        y - 5,
        full_w + 30,
        38,
        @raylib.Color::new(255, 255, 100, 20),
      )
    }
    @raylib.draw_text(text, (@types.screen_width - full_w) / 2, y, 28, color)
  }
  // Controls hint
  let hint = "Arrows: Select | Enter: Play"
  let hint_w = @raylib.measure_text(hint, 16)
  @raylib.draw_text(
    hint,
    (@types.screen_width - hint_w) / 2,
    @types.screen_height - 50,
    16,
    @raylib.Color::new(180, 180, 200, 255),
  )
  // Version info
  @raylib.draw_text(
    "v1.0",
    @types.screen_width - 50,
    @types.screen_height - 25,
    14,
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
    @types.hud_height,
    @raylib.Color::new(0, 0, 0, 160),
  )
  // Level name
  let level_name = @levels.get_level_name(
    game.current_world,
    game.current_level,
  )
  @raylib.draw_text(
    level_name,
    10,
    8,
    20,
    @raylib.Color::new(200, 220, 255, 255),
  )
  // Gems
  @raylib.draw_text(
    "Gems: \{game.gems_collected}/\{game.gems_total}",
    230,
    8,
    18,
    @raylib.Color::new(@types.gem_r, @types.gem_g, @types.gem_b, 255),
  )
  // Coins
  @raylib.draw_text(
    "Coins: \{game.coins_collected}",
    400,
    8,
    18,
    @raylib.Color::new(
      @types.coin_gold_r, @types.coin_gold_g, @types.coin_gold_b, 255,
    ),
  )
  // Stars
  @raylib.draw_text(
    "Stars: \{game.stars_collected}",
    540,
    8,
    18,
    @raylib.Color::new(@types.star_r, @types.star_g, @types.star_b, 255),
  )
  // Lives
  draw_lives(game)
  // Score
  @raylib.draw_text(
    "Score: \{game.score}",
    830,
    8,
    18,
    @raylib.Color::new(200, 200, 200, 255),
  )
  // Combo bar
  if game.combo_count > 0 {
    draw_combo_bar(game)
  }
  // Power-up indicator
  if game.powerup_type >= 0 {
    draw_powerup_indicator(game)
  }
  // Level time
  let time_secs = game.level_time.to_int()
  let mins = time_secs / 60
  let secs = time_secs % 60
  let pad = if secs < 10 { "0" } else { "" }
  let time_str = "\{mins}:\{pad}\{secs}"
  let time_w = @raylib.measure_text(time_str, 16)
  @raylib.draw_text(
    time_str,
    @types.screen_width - time_w - 10,
    @types.hud_height + 5,
    16,
    @raylib.Color::new(180, 180, 200, 200),
  )
  // Minimap
  draw_minimap(game)
  // Bottom controls
  @raylib.draw_rectangle(
    0,
    @types.screen_height - 28,
    @types.screen_width,
    28,
    @raylib.Color::new(0, 0, 0, 100),
  )
  @raylib.draw_text(
    "WASD: Move | Space: Jump | Shift: Dash | Q/E: Camera | P: Pause",
    10,
    @types.screen_height - 22,
    14,
    @raylib.Color::new(150, 150, 170, 255),
  )
}

///|
fn draw_lives(game : @types.Game) -> Unit {
  let start_x = 680
  let y = 6
  @raylib.draw_text(
    "Lives:",
    start_x,
    y + 2,
    18,
    @raylib.Color::new(255, 100, 100, 255),
  )
  for i = 0; i < game.lives && i < 10; i = i + 1 {
    let x = start_x + 60 + i * 18
    @raylib.draw_rectangle(
      x,
      y + 4,
      12,
      12,
      @raylib.Color::new(255, 80, 80, 255),
    )
    @raylib.draw_rectangle(
      x + 2,
      y + 6,
      8,
      8,
      @raylib.Color::new(255, 120, 120, 255),
    )
    ignore(i)
  }
}

///|
fn draw_combo_bar(game : @types.Game) -> Unit {
  let bar_x = 10
  let bar_y = @types.hud_height + 5
  let bar_w = @types.hud_combo_bar_width
  let bar_h = @types.hud_combo_bar_height
  // Background
  @raylib.draw_rectangle(
    bar_x,
    bar_y,
    bar_w,
    bar_h,
    @raylib.Color::new(40, 40, 50, 180),
  )
  // Fill
  let fill_ratio : Float = game.combo_timer / @types.combo_decay_time
  let fill_w = (Float::from_int(bar_w) * fill_ratio).to_int()
  let combo_r : Int = @types.clampi((game.combo_mult * 50.0).to_int(), 0, 255)
  @raylib.draw_rectangle(
    bar_x,
    bar_y,
    fill_w,
    bar_h,
    @raylib.Color::new(255, combo_r, 50, 220),
  )
  // Border
  @raylib.draw_rectangle_lines(
    bar_x,
    bar_y,
    bar_w,
    bar_h,
    @raylib.Color::new(180, 180, 200, 150),
  )
  // Combo text
  let combo_text = "x\{game.combo_count}"
  @raylib.draw_text(
    combo_text,
    bar_x + bar_w + 5,
    bar_y - 1,
    14,
    @raylib.Color::new(255, 200, 50, 255),
  )
}

///|
fn draw_powerup_indicator(game : @types.Game) -> Unit {
  let x = 10
  let y = @types.hud_height + 22
  let name : String = if game.powerup_type == @types.powerup_double_jump {
    "DOUBLE JUMP"
  } else if game.powerup_type == @types.powerup_speed {
    "SPEED BOOST"
  } else if game.powerup_type == @types.powerup_shield {
    "SHIELD"
  } else if game.powerup_type == @types.powerup_magnet {
    "MAGNET"
  } else {
    "SLOW FALL"
  }
  let time_left = game.powerup_timer.to_int()
  let text = "\{name} [\{time_left}s]"
  // Flash when about to expire
  let alpha : Int = if game.powerup_timer < 2.0 {
    let flash = @math.sinf(game.powerup_timer * 8.0)
    if flash > 0.0 {
      255
    } else {
      100
    }
  } else {
    255
  }
  @raylib.draw_text(text, x, y, 14, @raylib.Color::new(200, 255, 200, alpha))
}

///|
fn draw_minimap(game : @types.Game) -> Unit {
  let mm_size = @types.minimap_size
  let mm_margin = @types.minimap_margin
  let mm_x = @types.screen_width - mm_size - mm_margin
  let mm_y = @types.hud_height + mm_margin
  // Background
  @raylib.draw_rectangle(
    mm_x,
    mm_y,
    mm_size,
    mm_size,
    @raylib.Color::new(0, 0, 0, 100),
  )
  @raylib.draw_rectangle_lines(
    mm_x,
    mm_y,
    mm_size,
    mm_size,
    @raylib.Color::new(100, 100, 120, 150),
  )
  // Find bounds of level
  let mut min_x : Float = game.px
  let mut max_x : Float = game.px
  let mut min_z : Float = game.pz
  let mut max_z : Float = game.pz
  for p in game.platforms {
    if not(p.active) {
      continue
    }
    if p.x < min_x {
      min_x = p.x
    }
    if p.x > max_x {
      max_x = p.x
    }
    if p.z < min_z {
      min_z = p.z
    }
    if p.z > max_z {
      max_z = p.z
    }
  }
  let range_x = max_x - min_x + 10.0
  let range_z = max_z - min_z + 10.0
  let scale : Float = Float::from_int(mm_size - 10) /
    @types.maxf(range_x, range_z)
  let offset_x : Float = Float::from_int(mm_x + 5) - min_x * scale + 5.0
  let offset_z : Float = Float::from_int(mm_y + 5) - min_z * scale + 5.0
  // Draw platforms on minimap
  for p in game.platforms {
    if not(p.active) {
      continue
    }
    let px = (p.x * scale + offset_x).to_int()
    let pz = (p.z * scale + offset_z).to_int()
    let pw = @types.maxi((p.w * scale * 0.5).to_int(), 2)
    let pd = @types.maxi((p.d * scale * 0.5).to_int(), 2)
    @raylib.draw_rectangle(
      px - pw / 2,
      pz - pd / 2,
      pw,
      pd,
      @raylib.Color::new(p.r, p.g, p.b, 180),
    )
  }
  // Goal on minimap
  let gx = (game.goal_x * scale + offset_x).to_int()
  let gz = (game.goal_z * scale + offset_z).to_int()
  @raylib.draw_rectangle(
    gx - 3,
    gz - 3,
    6,
    6,
    @raylib.Color::new(255, 215, 0, 255),
  )
  // Player on minimap
  let player_mx = (game.px * scale + offset_x).to_int()
  let player_mz = (game.pz * scale + offset_z).to_int()
  @raylib.draw_rectangle(
    player_mx - 2,
    player_mz - 2,
    5,
    5,
    @raylib.Color::new(60, 140, 220, 255),
  )
  // Enemies on minimap
  for e in game.enemies {
    if not(e.active) {
      continue
    }
    let ex = (e.x * scale + offset_x).to_int()
    let ez = (e.z * scale + offset_z).to_int()
    @raylib.draw_rectangle(
      ex - 1,
      ez - 1,
      3,
      3,
      @raylib.Color::new(255, 60, 60, 200),
    )
  }
}

///|
fn draw_pause_overlay(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(0, 0, 0, 150),
  )
  // Title
  let text = "PAUSED"
  let tw = @raylib.measure_text(text, 60)
  @raylib.draw_text(
    text,
    (@types.screen_width - tw) / 2,
    @types.screen_height / 2 - 100,
    60,
    @raylib.white,
  )
  // Menu items
  let items : Array[String] = ["Resume", "Restart", "Quit to Menu"]
  for i in 0..<items.length() {
    let y = @types.screen_height / 2 - 20 + i * 40
    let is_sel = game.pause_cursor == i
    let color = if is_sel {
      @raylib.Color::new(255, 255, 100, 255)
    } else {
      @raylib.Color::new(200, 200, 220, 255)
    }
    let prefix = if is_sel { "> " } else { "  " }
    let item_text = prefix + items[i]
    let item_w = @raylib.measure_text(item_text, 24)
    if is_sel {
      @raylib.draw_rectangle(
        (@types.screen_width - item_w) / 2 - 10,
        y - 3,
        item_w + 20,
        32,
        @raylib.Color::new(255, 255, 100, 15),
      )
    }
    @raylib.draw_text(
      item_text,
      (@types.screen_width - item_w) / 2,
      y,
      24,
      color,
    )
  }
  // Controls
  let hint = "Arrows: Select | Enter: Choose | P: Resume"
  let hw = @raylib.measure_text(hint, 16)
  @raylib.draw_text(
    hint,
    (@types.screen_width - hw) / 2,
    @types.screen_height / 2 + 110,
    16,
    @raylib.Color::new(150, 150, 170, 255),
  )
}

///|
fn draw_level_complete(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(0, 0, 0, 160),
  )
  // Title
  let text = "LEVEL COMPLETE!"
  let tw = @raylib.measure_text(text, 48)
  @raylib.draw_text(
    text,
    (@types.screen_width - tw) / 2,
    @types.screen_height / 2 - 120,
    48,
    @raylib.Color::new(100, 255, 100, 255),
  )
  // Stats panel
  let panel_x = @types.screen_width / 2 - 180
  let panel_y = @types.screen_height / 2 - 60
  @raylib.draw_rectangle(
    panel_x,
    panel_y,
    360,
    200,
    @raylib.Color::new(20, 25, 40, 200),
  )
  @raylib.draw_rectangle_lines(
    panel_x,
    panel_y,
    360,
    200,
    @raylib.Color::new(100, 150, 200, 200),
  )
  // Gems
  let gems_text = "Gems: \{game.gems_collected}/\{game.gems_total}"
  @raylib.draw_text(
    gems_text,
    panel_x + 20,
    panel_y + 15,
    22,
    @raylib.Color::new(@types.gem_r, @types.gem_g, @types.gem_b, 255),
  )
  // Coins
  let coins_text = "Coins: \{game.coins_collected}"
  @raylib.draw_text(
    coins_text,
    panel_x + 20,
    panel_y + 45,
    22,
    @raylib.Color::new(
      @types.coin_gold_r, @types.coin_gold_g, @types.coin_gold_b, 255,
    ),
  )
  // Time
  let secs = game.level_time.to_int()
  let t_min = secs / 60
  let t_sec = secs % 60
  let t_pad = if t_sec < 10 { "0" } else { "" }
  let time_text = "Time: \{t_min}:\{t_pad}\{t_sec}"
  @raylib.draw_text(
    time_text,
    panel_x + 20,
    panel_y + 75,
    22,
    @raylib.Color::new(200, 200, 220, 255),
  )
  // Deaths
  let death_text = "Deaths: \{game.level_deaths}"
  @raylib.draw_text(
    death_text,
    panel_x + 20,
    panel_y + 105,
    22,
    @raylib.Color::new(255, 120, 100, 255),
  )
  // Stars earned
  let lvl_idx = game.current_world * @types.levels_per_world +
    game.current_level
  let stars = game.level_stars[lvl_idx]
  draw_star_rating(panel_x + 200, panel_y + 15, stars, 3)
  // Score
  let score_text = "Score: \{game.score}"
  let scw = @raylib.measure_text(score_text, 26)
  @raylib.draw_text(
    score_text,
    (@types.screen_width - scw) / 2,
    panel_y + 145,
    26,
    @raylib.Color::new(255, 255, 200, 255),
  )
  // Hint
  let hint = "Enter: Next Level | M: Menu"
  let hw = @raylib.measure_text(hint, 18)
  @raylib.draw_text(
    hint,
    (@types.screen_width - hw) / 2,
    panel_y + 215,
    18,
    @raylib.Color::new(180, 180, 200, 255),
  )
  ignore(game.complete_timer)
}

///|
fn draw_star_rating(x : Int, y : Int, filled : Int, total : Int) -> Unit {
  for i in 0..<total {
    let sx = x + i * 30
    let color = if i < filled {
      @raylib.Color::new(255, 215, 0, 255)
    } else {
      @raylib.Color::new(80, 80, 90, 255)
    }
    // Star shape approximation with rectangles
    @raylib.draw_rectangle(sx, y + 4, 20, 12, color)
    @raylib.draw_rectangle(sx + 4, y, 12, 20, color)
    ignore(i)
  }
}

///|
fn draw_game_over(game : @types.Game) -> Unit {
  ignore(game)
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(30, 0, 0, 230),
  )
  // Vignette effect
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    100,
    @raylib.Color::new(0, 0, 0, 100),
  )
  @raylib.draw_rectangle(
    0,
    @types.screen_height - 100,
    @types.screen_width,
    100,
    @raylib.Color::new(0, 0, 0, 100),
  )
  // Title
  let text = "GAME OVER"
  let tw = @raylib.measure_text(text, 64)
  // Shadow
  @raylib.draw_text(
    text,
    (@types.screen_width - tw) / 2 + 3,
    @types.screen_height / 2 - 67,
    64,
    @raylib.Color::new(100, 20, 10, 255),
  )
  @raylib.draw_text(
    text,
    (@types.screen_width - tw) / 2,
    @types.screen_height / 2 - 70,
    64,
    @raylib.Color::new(255, 80, 60, 255),
  )
  // Score display
  let score_text = "Final Score: \{game.score}"
  let sw = @raylib.measure_text(score_text, 24)
  @raylib.draw_text(
    score_text,
    (@types.screen_width - sw) / 2,
    @types.screen_height / 2 + 10,
    24,
    @raylib.Color::new(200, 180, 160, 255),
  )
  // Options
  let retry = "Enter: Retry Level"
  let rw = @raylib.measure_text(retry, 20)
  @raylib.draw_text(
    retry,
    (@types.screen_width - rw) / 2,
    @types.screen_height / 2 + 60,
    20,
    @raylib.Color::new(200, 200, 220, 255),
  )
  let menu = "M: Return to Menu"
  let mw = @raylib.measure_text(menu, 20)
  @raylib.draw_text(
    menu,
    (@types.screen_width - mw) / 2,
    @types.screen_height / 2 + 90,
    20,
    @raylib.Color::new(180, 180, 200, 255),
  )
}

///|
fn draw_death_overlay(game : @types.Game) -> Unit {
  let progress : Float = game.death_timer / @types.death_anim_time
  let alpha = (progress * 100.0).to_int()
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(255, 0, 0, @types.clampi(alpha, 0, 100)),
  )
}

///|
fn draw_world_select(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(20, 25, 40, 255),
  )
  // Title
  let title = "SELECT WORLD"
  let tw = @raylib.measure_text(title, 36)
  @raylib.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    40,
    36,
    @raylib.Color::new(200, 220, 255, 255),
  )
  // Decorative line
  @raylib.draw_rectangle(
    (@types.screen_width - 250) / 2,
    82,
    250,
    2,
    @raylib.Color::new(100, 120, 160, 150),
  )
  for i in 0..<@types.num_worlds {
    let x = 70 + i * 230
    let y = 140
    let is_sel = game.world_select_cursor == i
    // Card background
    let wbg = @levels.world_bg_color(i)
    let bg_color = if is_sel {
      @raylib.Color::new(wbg.0 / 2 + 30, wbg.1 / 2 + 30, wbg.2 / 2 + 30, 255)
    } else {
      @raylib.Color::new(35, 40, 55, 255)
    }
    @raylib.draw_rectangle(x, y, 200, 280, bg_color)
    if is_sel {
      @raylib.draw_rectangle_lines(
        x - 2,
        y - 2,
        204,
        284,
        @raylib.Color::new(200, 220, 255, 255),
      )
    }
    // World color swatch
    let wpc = @levels.world_platform_color(i)
    @raylib.draw_rectangle(
      x + 15,
      y + 15,
      170,
      80,
      @raylib.Color::new(wpc.0, wpc.1, wpc.2, 200),
    )
    // World name
    let wname = @levels.get_world_name(i)
    @raylib.draw_text(
      wname,
      x + 15,
      y + 110,
      22,
      @raylib.Color::new(220, 220, 240, 255),
    )
    // Level count
    let levels_text = "\{@types.levels_per_world} Levels"
    @raylib.draw_text(
      levels_text,
      x + 15,
      y + 145,
      16,
      @raylib.Color::new(150, 150, 170, 255),
    )
    // Difficulty
    let diff = @levels.get_level_difficulty(i, 0)
    let diff_text = "Difficulty: \{diff}/5"
    @raylib.draw_text(
      diff_text,
      x + 15,
      y + 170,
      16,
      @raylib.Color::new(150, 150, 170, 255),
    )
    // Stars collected in this world
    let mut world_stars = 0
    for j in 0..<@types.levels_per_world {
      let lvl_idx = i * @types.levels_per_world + j
      world_stars += game.level_stars[lvl_idx]
      ignore(j)
    }
    let star_text = "Stars: \{world_stars}/\{@types.levels_per_world * 3}"
    @raylib.draw_text(
      star_text,
      x + 15,
      y + 200,
      16,
      @raylib.Color::new(255, 215, 0, 200),
    )
    // World number
    let num_text = "\{i + 1}"
    @raylib.draw_text(
      num_text,
      x + 170,
      y + 240,
      32,
      @raylib.Color::new(60, 60, 80, 100),
    )
    ignore(i)
  }
  // Controls
  let hint = "Arrows: Select | Enter: Play | Esc: Back"
  let hw = @raylib.measure_text(hint, 16)
  @raylib.draw_text(
    hint,
    (@types.screen_width - hw) / 2,
    @types.screen_height - 50,
    16,
    @raylib.Color::new(120, 120, 140, 255),
  )
}

///|
fn draw_level_select(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(20, 25, 40, 255),
  )
  // Title
  let title = "SELECT LEVEL"
  let tw = @raylib.measure_text(title, 36)
  @raylib.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    30,
    36,
    @raylib.Color::new(200, 220, 255, 255),
  )
  // Grid layout
  let cols = @types.level_grid_cols
  let card_w = @types.level_card_w
  let card_h = @types.level_card_h
  let gap = @types.level_card_gap
  let grid_w = cols * card_w + (cols - 1) * gap
  let start_x = (@types.screen_width - grid_w) / 2
  let start_y = 90
  for i in 0..<@types.total_levels {
    let col = i % cols
    let row = i / cols
    let x = start_x + col * (card_w + gap)
    let y = start_y + row * (card_h + gap)
    let is_sel = game.level_select_cursor == i
    let world = i / @types.levels_per_world
    let level = i % @types.levels_per_world
    // Card background
    let wbg = @levels.world_bg_color(world)
    let bg_alpha : Int = if is_sel { 200 } else { 120 }
    @raylib.draw_rectangle(
      x,
      y,
      card_w,
      card_h,
      @raylib.Color::new(
        wbg.0 / 3 + 20,
        wbg.1 / 3 + 20,
        wbg.2 / 3 + 20,
        bg_alpha,
      ),
    )
    if is_sel {
      @raylib.draw_rectangle_lines(
        x - 1,
        y - 1,
        card_w + 2,
        card_h + 2,
        @raylib.Color::new(255, 255, 100, 255),
      )
    }
    // Level number
    let num_text = "\{i + 1}"
    @raylib.draw_text(
      num_text,
      x + 8,
      y + 5,
      22,
      @raylib.Color::new(220, 220, 240, 255),
    )
    // Level name
    let lname = @levels.get_level_name(world, level)
    @raylib.draw_text(
      lname,
      x + 8,
      y + 30,
      12,
      @raylib.Color::new(180, 180, 200, 255),
    )
    // Stars
    let stars = game.level_stars[i]
    draw_star_rating(x + 8, y + card_h - 30, stars, 3)
    // World color indicator
    let wpc = @levels.world_platform_color(world)
    @raylib.draw_rectangle(
      x + card_w - 15,
      y + 5,
      8,
      8,
      @raylib.Color::new(wpc.0, wpc.1, wpc.2, 255),
    )
    ignore(i)
  }
  // Controls
  let hint = "Arrows: Navigate | Enter: Play | Esc: Back"
  let hw = @raylib.measure_text(hint, 16)
  @raylib.draw_text(
    hint,
    (@types.screen_width - hw) / 2,
    @types.screen_height - 40,
    16,
    @raylib.Color::new(120, 120, 140, 255),
  )
}

///|
fn draw_world_intro(game : @types.Game) -> Unit {
  let progress : Float = 1.0 -
    game.world_intro_timer / @types.world_intro_duration
  // Background
  let bg = @levels.world_bg_color(game.current_world)
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(bg.0, bg.1, bg.2, 255),
  )
  // Fade in
  let fade_alpha : Int = if progress < 0.2 {
    (progress / 0.2 * 255.0).to_int()
  } else {
    255
  }
  // World name
  let wname = @levels.get_world_name(game.current_world)
  let ww = @raylib.measure_text(wname, 56)
  @raylib.draw_text(
    wname,
    (@types.screen_width - ww) / 2,
    @types.screen_height / 2 - 60,
    56,
    @raylib.Color::new(255, 255, 255, @types.clampi(fade_alpha, 0, 255)),
  )
  // Level name
  let lname = @levels.get_level_name(game.current_world, game.current_level)
  let lw = @raylib.measure_text(lname, 24)
  @raylib.draw_text(
    lname,
    (@types.screen_width - lw) / 2,
    @types.screen_height / 2 + 10,
    24,
    @raylib.Color::new(220, 220, 240, @types.clampi(fade_alpha, 0, 255)),
  )
  // World number
  let world_num = "World \{game.current_world + 1}"
  let wnw = @raylib.measure_text(world_num, 18)
  @raylib.draw_text(
    world_num,
    (@types.screen_width - wnw) / 2,
    @types.screen_height / 2 - 90,
    18,
    @raylib.Color::new(180, 180, 200, @types.clampi(fade_alpha, 0, 255)),
  )
  // Press to continue
  if progress > 0.5 {
    let skip = "Press Enter to continue..."
    let sk_w = @raylib.measure_text(skip, 16)
    @raylib.draw_text(
      skip,
      (@types.screen_width - sk_w) / 2,
      @types.screen_height / 2 + 80,
      16,
      @raylib.Color::new(150, 150, 170, 200),
    )
  }
  // Decorative line
  @raylib.draw_rectangle(
    (@types.screen_width - 200) / 2,
    @types.screen_height / 2 - 2,
    200,
    2,
    @raylib.Color::new(200, 200, 220, @types.clampi(fade_alpha / 2, 0, 255)),
  )
}

///|
fn draw_campaign_complete(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(10, 20, 40, 255),
  )
  // Stars background animation
  let star_y_offset = @math.sinf(Float::from_int(game.frame_counter) * 0.02)
  for i in 0..<20 {
    let sx = i * 53 % @types.screen_width
    let sy_base : Float = Float::from_int((i * 41 + 17) % @types.screen_height)
    let sy = sy_base + star_y_offset * Float::from_int(i % 5 + 1) * 3.0
    @raylib.draw_rectangle(
      sx,
      sy.to_int(),
      2,
      2,
      @raylib.Color::new(255, 255, 200, 150),
    )
    ignore(i)
  }
  // Title
  let text = "CONGRATULATIONS!"
  let tw = @raylib.measure_text(text, 52)
  @raylib.draw_text(
    text,
    (@types.screen_width - tw) / 2 + 2,
    192,
    52,
    @raylib.Color::new(180, 150, 0, 255),
  )
  @raylib.draw_text(
    text,
    (@types.screen_width - tw) / 2,
    190,
    52,
    @raylib.Color::new(255, 215, 0, 255),
  )
  // Message
  let sub = "You completed all worlds!"
  let sw = @raylib.measure_text(sub, 28)
  @raylib.draw_text(
    sub,
    (@types.screen_width - sw) / 2,
    270,
    28,
    @raylib.Color::new(200, 220, 255, 255),
  )
  // Final stats
  let mut total_stars = 0
  for i in 0..<@types.total_levels {
    total_stars += game.level_stars[i]
  }
  let stars_text = "Total Stars: \{total_stars}/\{@types.total_levels * 3}"
  let stw = @raylib.measure_text(stars_text, 22)
  @raylib.draw_text(
    stars_text,
    (@types.screen_width - stw) / 2,
    330,
    22,
    @raylib.Color::new(255, 215, 0, 255),
  )
  let score_text = "Final Score: \{game.score}"
  let scw = @raylib.measure_text(score_text, 22)
  @raylib.draw_text(
    score_text,
    (@types.screen_width - scw) / 2,
    365,
    22,
    @raylib.Color::new(200, 200, 220, 255),
  )
  // Hint
  let hint = "Enter: Return to Menu"
  let hw = @raylib.measure_text(hint, 18)
  @raylib.draw_text(
    hint,
    (@types.screen_width - hw) / 2,
    430,
    18,
    @raylib.Color::new(150, 150, 170, 255),
  )
}

///|
fn draw_score_flies(game : @types.Game) -> Unit {
  for sf in game.score_flies {
    if not(sf.active) {
      continue
    }
    let progress : Float = sf.timer / sf.max_time
    let alpha_f : Float = (1.0 - progress) * 255.0
    let alpha = alpha_f.to_int()
    let a = @types.clampi(alpha, 0, 255)
    let text = "+\{sf.value}"
    @raylib.draw_text(
      text,
      sf.x.to_int(),
      sf.y.to_int(),
      18,
      @raylib.Color::new(255, 255, 100, a),
    )
  }
}
