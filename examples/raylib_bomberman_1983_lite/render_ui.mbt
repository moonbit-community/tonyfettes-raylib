///|
fn draw_enemy_counter(game : Game, x : Int, y : Int) -> Unit {
  let pending = game.enemies_to_spawn - game.enemies_spawned
  let remaining = game.enemies_alive + (if pending > 0 { pending } else { 0 })
  draw_shadow_text("MONSTERS", x, y, 18, @raylib.raywhite)

  for i = 0; i < enemy_icon_rows * enemy_icon_cols; i = i + 1 {
    let row = i / enemy_icon_cols
    let col = i % enemy_icon_cols
    let ix = x + col * 18
    let iy = y + 30 + row * 16
    if i < remaining {
      @raylib.draw_rectangle(ix, iy, 12, 10, @raylib.orange)
      @raylib.draw_rectangle(ix + 3, iy + 3, 6, 4, @raylib.brown)
    } else {
      @raylib.draw_rectangle_lines(ix, iy, 12, 10, @raylib.darkgray)
    }
  }
}

///|
fn draw_player_card(
  game : Game,
  player_index : Int,
  x : Int,
  y : Int,
  label : String,
  accent : @raylib.Color,
) -> Unit {
  let player = game.players[player_index]
  let alive_flag = player.active || player.lives > 0
  let active_bombs = count_team_bombs(game, team_of_player(player_index))

  @raylib.draw_rectangle(
    x,
    y,
    panel_w - 24,
    108,
    @raylib.Color::new(24, 28, 36, 255),
  )
  @raylib.draw_rectangle_lines(
    x,
    y,
    panel_w - 24,
    108,
    @raylib.Color::new(58, 70, 89, 255),
  )
  draw_shadow_text(label, x + 10, y + 8, 20, accent)

  draw_shadow_text("SCORE", x + 12, y + 36, 16, @raylib.lightgray)
  draw_shadow_text("\{player.score}", x + 12, y + 56, 20, @raylib.white)

  draw_shadow_text("LIVES", x + 120, y + 36, 16, @raylib.lightgray)
  draw_shadow_text("\{player.lives}", x + 120, y + 56, 20, @raylib.white)

  draw_shadow_text("UPG", x + 200, y + 36, 16, @raylib.lightgray)
  draw_shadow_text("\{player.weapon_level}", x + 200, y + 56, 20, @raylib.white)
  draw_shadow_text(
    "BOMBS \{active_bombs}",
    x + 12,
    y + 74,
    14,
    @raylib.Color::new(255, 220, 156, 255),
  )

  if alive_flag {
    let ready = if player.active { "READY" } else { "RESPAWN" }
    let color = if player.active { @raylib.lime } else { @raylib.yellow }
    draw_shadow_text(ready, x + 110, y + 82, 14, color)
  } else {
    draw_shadow_text("OUT", x + 110, y + 82, 14, @raylib.red)
  }

  if player.shield_timer > 0.0 {
    draw_shadow_text("SHIELD", x + 158, y + 82, 14, @raylib.skyblue)
  }
  if player.invuln_timer > 0.0 {
    draw_shadow_text("SPAWN SAFE", x + 214, y + 82, 14, @raylib.gold)
  }
}

///|
fn draw_panel(game : Game) -> Unit {
  @raylib.draw_rectangle(
    panel_x,
    map_offset_y,
    panel_w,
    map_pixel_h,
    @raylib.Color::new(18, 21, 28, 255),
  )
  @raylib.draw_rectangle_lines(
    panel_x,
    map_offset_y,
    panel_w,
    map_pixel_h,
    @raylib.Color::new(50, 60, 80, 255),
  )

  draw_shadow_text(
    "BOMBERMAN 1983",
    panel_x + 16,
    map_offset_y + 14,
    30,
    game.profile.ui_accent,
  )
  draw_shadow_text(
    "STAGE \{game.stage_index + 1}/\{level_count}",
    panel_x + 16,
    map_offset_y + 50,
    18,
    @raylib.raywhite,
  )
  draw_shadow_text(
    game.profile.title,
    panel_x + 16,
    map_offset_y + 66,
    14,
    @raylib.lightgray,
  )
  if game.demo_mode {
    draw_shadow_text(
      "DEMO RUN \{game.demo_runs}",
      panel_x + 16,
      map_offset_y + 80,
      14,
      @raylib.lime,
    )
    draw_shadow_text(
      "AUTO \{game.demo_elapsed.to_int()}s",
      panel_x + 145,
      map_offset_y + 80,
      14,
      @raylib.lime,
    )
  }

  draw_shadow_text(
    "TOTAL",
    panel_x + 16,
    map_offset_y + 88,
    15,
    @raylib.lightgray,
  )
  draw_shadow_text(
    "\{game.score_total}",
    panel_x + 16,
    map_offset_y + 106,
    24,
    @raylib.white,
  )

  draw_shadow_text(
    "BEST",
    panel_x + 145,
    map_offset_y + 88,
    15,
    @raylib.lightgray,
  )
  draw_shadow_text(
    "\{game.high_score}",
    panel_x + 145,
    map_offset_y + 106,
    24,
    @raylib.white,
  )

  draw_enemy_counter(game, panel_x + 20, map_offset_y + 148)

  draw_player_card(
    game,
    0,
    panel_x + 12,
    map_offset_y + 330,
    "P1",
    @raylib.skyblue,
  )

  if game.coop_enabled {
    draw_player_card(
      game,
      1,
      panel_x + 12,
      map_offset_y + 444,
      "P2",
      @raylib.orange,
    )
  } else {
    @raylib.draw_rectangle(
      panel_x + 12,
      map_offset_y + 444,
      panel_w - 24,
      108,
      @raylib.Color::new(24, 28, 36, 255),
    )
    @raylib.draw_rectangle_lines(
      panel_x + 12,
      map_offset_y + 444,
      panel_w - 24,
      108,
      @raylib.Color::new(58, 70, 89, 255),
    )
    draw_shadow_text(
      "P2 OFF",
      panel_x + 22,
      map_offset_y + 458,
      24,
      @raylib.darkgray,
    )
    draw_shadow_text(
      "Press C in menu",
      panel_x + 22,
      map_offset_y + 495,
      16,
      @raylib.gray,
    )
  }

  let fx = panel_x + 18
  let fy = map_offset_y + map_pixel_h - 118
  draw_shadow_text("P1: Arrows + Shift (bomb)", fx, fy, 14, @raylib.lightgray)
  draw_shadow_text(
    "P2: WASD + Space (bomb)",
    fx,
    fy + 18,
    14,
    @raylib.lightgray,
  )
  draw_shadow_text("P: Pause", fx, fy + 36, 14, @raylib.lightgray)
  draw_shadow_text(
    "Chain bombs to clear monsters",
    fx,
    fy + 54,
    14,
    @raylib.gold,
  )

  if game.freeze_all_timer > 0.0 {
    draw_shadow_text(
      "FROZEN \{game.freeze_all_timer.to_int()}s",
      fx,
      fy + 74,
      16,
      @raylib.skyblue,
    )
  }
  if game.shovel_timer > 0.0 {
    draw_shadow_text(
      "FORTIFY \{game.shovel_timer.to_int()}s",
      fx + 126,
      fy + 74,
      16,
      @raylib.orange,
    )
  }

  if game.combo_timer > 0.0 && game.kill_combo > 1 {
    draw_shadow_text(
      "COMBO x\{combo_multiplier(game)}",
      panel_x + 18,
      map_offset_y + 292,
      18,
      @raylib.lime,
    )
  }
}

///|
fn draw_menu_overlay(game : Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_width,
    screen_height,
    @raylib.Color::new(5, 8, 14, 190),
  )

  draw_centered_text("BOMBERMAN 1983", screen_width / 2, 110, 66, @raylib.gold)
  draw_centered_text(
    "MoonBit + raylib",
    screen_width / 2,
    182,
    24,
    @raylib.Color::new(180, 210, 255, 255),
  )

  let options : Array[String] = [
    "START CAMPAIGN",
    "START DEMO (AUTO)",
    if game.coop_enabled {
      "CO-OP: ON"
    } else {
      "CO-OP: OFF"
    },
    "QUIT",
  ]

  for i = 0; i < options.length(); i = i + 1 {
    let selected = i == game.menu_cursor
    let phase = game.menu_blink + Float::from_int(i)
    let pulse = Float::from_double(@math.sin(phase.to_double())) * 0.5 + 0.5
    let color = if selected {
      @raylib.color_lerp(@raylib.yellow, @raylib.white, pulse)
    } else {
      @raylib.gray
    }
    draw_centered_text(options[i], screen_width / 2, 300 + i * 52, 36, color)
  }

  draw_centered_text(
    "Arrows/W/S + Enter",
    screen_width / 2,
    490,
    22,
    @raylib.lightgray,
  )
  draw_centered_text(
    "Press D for instant demo run",
    screen_width / 2,
    520,
    18,
    @raylib.lime,
  )
  draw_centered_text(
    "Press C anytime in menu to toggle co-op",
    screen_width / 2,
    546,
    18,
    @raylib.darkgray,
  )
  draw_centered_text(
    "Plant bombs, avoid blast lines, clear monsters.",
    screen_width / 2,
    578,
    20,
    @raylib.raywhite,
  )
}

///|
fn draw_stage_intro_overlay(game : Game) -> Unit {
  let alpha = clampf(game.stage_intro_timer / stage_intro_time, 0.0, 1.0)
  @raylib.draw_rectangle(
    0,
    0,
    screen_width,
    screen_height,
    @raylib.color_alpha(@raylib.black, 0.65 * alpha + 0.25),
  )
  draw_centered_text(
    "STAGE \{game.stage_index + 1}",
    screen_width / 2,
    screen_height / 2 - 52,
    54,
    @raylib.white,
  )
  draw_centered_text(
    game.profile.title,
    screen_width / 2,
    screen_height / 2 + 10,
    28,
    game.profile.ui_accent,
  )
  draw_centered_text(
    game.profile.subtitle,
    screen_width / 2,
    screen_height / 2 + 42,
    20,
    @raylib.lightgray,
  )
  draw_centered_text(
    "Enemies: \{game.enemies_to_spawn}",
    screen_width / 2,
    screen_height / 2 + 78,
    24,
    @raylib.lightgray,
  )
  if game.demo_mode {
    draw_centered_text(
      "AUTO DEMO ACTIVE",
      screen_width / 2,
      screen_height / 2 + 112,
      20,
      @raylib.lime,
    )
  }
}

///|
fn draw_pause_overlay(game : Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_width,
    screen_height,
    @raylib.Color::new(5, 8, 14, 160),
  )
  let pulse = Float::from_double(@math.sin(game.pause_blink.to_double() * 3.0)) *
    0.5 +
    0.5
  let color = @raylib.color_lerp(@raylib.yellow, @raylib.white, pulse)
  draw_centered_text("PAUSED", screen_width / 2, 300, 62, color)
  draw_centered_text(
    "P to resume",
    screen_width / 2,
    380,
    24,
    @raylib.lightgray,
  )
  draw_centered_text(
    "ESC to menu",
    screen_width / 2,
    412,
    24,
    @raylib.lightgray,
  )
}

///|
fn draw_stage_clear_overlay(game : Game) -> Unit {
  let t = clampf(1.0 - game.stage_clear_timer / stage_clear_time, 0.0, 1.0)
  @raylib.draw_rectangle(
    0,
    0,
    screen_width,
    screen_height,
    @raylib.color_alpha(@raylib.black, 0.35 + t * 0.2),
  )
  let color = pulse_color(
    @raylib.lime,
    Float::from_int(game.frame_counter) * 0.08,
  )
  draw_centered_text("STAGE CLEAR", screen_width / 2, 298, 58, color)
  draw_centered_text(
    "Maze cleared. Next labyrinth incoming.",
    screen_width / 2,
    370,
    26,
    @raylib.white,
  )
}

///|
fn draw_game_over_overlay(game : Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_width,
    screen_height,
    @raylib.Color::new(20, 0, 0, 170),
  )
  draw_centered_text("GAME OVER", screen_width / 2, 294, 62, @raylib.red)
  draw_centered_text(
    "Score: \{game.score_total}",
    screen_width / 2,
    370,
    30,
    @raylib.white,
  )
}

///|
fn draw_campaign_clear_overlay(game : Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_width,
    screen_height,
    @raylib.Color::new(0, 28, 16, 178),
  )
  let color = pulse_color(
    @raylib.gold,
    Float::from_int(game.frame_counter) * 0.1,
  )
  draw_centered_text("CAMPAIGN COMPLETE", screen_width / 2, 266, 58, color)
  draw_centered_text(
    "Final Score: \{game.score_total}",
    screen_width / 2,
    340,
    30,
    @raylib.white,
  )
  draw_centered_text(
    "Best Score: \{game.high_score}",
    screen_width / 2,
    378,
    24,
    @raylib.lightgray,
  )
}

///|
fn draw_ui(game : Game) -> Unit {
  draw_panel(game)

  if game.state == state_menu {
    draw_menu_overlay(game)
  } else if game.state == state_stage_intro {
    draw_stage_intro_overlay(game)
  } else if game.state == state_paused {
    draw_pause_overlay(game)
  } else if game.state == state_stage_clear {
    draw_stage_clear_overlay(game)
  } else if game.state == state_game_over {
    draw_game_over_overlay(game)
  } else if game.state == state_campaign_clear {
    draw_campaign_clear_overlay(game)
  }
}
