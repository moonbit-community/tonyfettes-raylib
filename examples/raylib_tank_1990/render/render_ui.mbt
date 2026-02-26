///|
fn draw_enemy_counter(game : @types.Game, x : Int, y : Int) -> Unit {
  let pending = game.enemies_to_spawn - game.enemies_spawned
  let remaining = game.enemies_alive + (if pending > 0 { pending } else { 0 })
  @types.draw_shadow_text("ENEMIES", x, y, 18, @raylib.raywhite)

  for i = 0; i < @types.enemy_icon_rows * @types.enemy_icon_cols; i = i + 1 {
    let row = i / @types.enemy_icon_cols
    let col = i % @types.enemy_icon_cols
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
  game : @types.Game,
  player_index : Int,
  x : Int,
  y : Int,
  label : String,
  accent : @raylib.Color,
) -> Unit {
  let player = game.players[player_index]
  let alive_flag = player.active || player.lives > 0

  @raylib.draw_rectangle(
    x,
    y,
    @types.panel_w - 24,
    108,
    @raylib.Color::new(24, 28, 36, 255),
  )
  @raylib.draw_rectangle_lines(
    x,
    y,
    @types.panel_w - 24,
    108,
    @raylib.Color::new(58, 70, 89, 255),
  )
  @types.draw_shadow_text(label, x + 10, y + 8, 20, accent)

  @types.draw_shadow_text("SCORE", x + 12, y + 36, 16, @raylib.lightgray)
  @types.draw_shadow_text("\{player.score}", x + 12, y + 56, 20, @raylib.white)

  @types.draw_shadow_text("LIVES", x + 120, y + 36, 16, @raylib.lightgray)
  @types.draw_shadow_text("\{player.lives}", x + 120, y + 56, 20, @raylib.white)

  @types.draw_shadow_text("UPG", x + 200, y + 36, 16, @raylib.lightgray)
  @types.draw_shadow_text("\{player.weapon_level}", x + 200, y + 56, 20, @raylib.white)

  if alive_flag {
    let ready = if player.active { "READY" } else { "RESPAWN" }
    let color = if player.active { @raylib.lime } else { @raylib.yellow }
    @types.draw_shadow_text(ready, x + 12, y + 82, 14, color)
  } else {
    @types.draw_shadow_text("OUT", x + 12, y + 82, 14, @raylib.red)
  }

  if player.shield_timer > 0.0 {
    @types.draw_shadow_text("SHIELD", x + 90, y + 82, 14, @raylib.skyblue)
  }
  if player.invuln_timer > 0.0 {
    @types.draw_shadow_text("SPAWN SAFE", x + 170, y + 82, 14, @raylib.gold)
  }
}

///|
fn draw_panel(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    @types.panel_x,
    @types.map_offset_y,
    @types.panel_w,
    @types.map_pixel_h,
    @raylib.Color::new(18, 21, 28, 255),
  )
  @raylib.draw_rectangle_lines(
    @types.panel_x,
    @types.map_offset_y,
    @types.panel_w,
    @types.map_pixel_h,
    @raylib.Color::new(50, 60, 80, 255),
  )

  @types.draw_shadow_text(
    "TANK 1990",
    @types.panel_x + 16,
    @types.map_offset_y + 14,
    30,
    game.profile.ui_accent,
  )
  @types.draw_shadow_text(
    "STAGE \{game.stage_index + 1}/\{@types.level_count}",
    @types.panel_x + 16,
    @types.map_offset_y + 50,
    18,
    @raylib.raywhite,
  )
  @types.draw_shadow_text(
    game.profile.title,
    @types.panel_x + 16,
    @types.map_offset_y + 66,
    14,
    @raylib.lightgray,
  )
  if game.demo_mode {
    @types.draw_shadow_text(
      "DEMO RUN \{game.demo_runs}",
      @types.panel_x + 16,
      @types.map_offset_y + 80,
      14,
      @raylib.lime,
    )
    @types.draw_shadow_text(
      "AUTO \{game.demo_elapsed.to_int()}s",
      @types.panel_x + 145,
      @types.map_offset_y + 80,
      14,
      @raylib.lime,
    )
  }

  @types.draw_shadow_text(
    "TOTAL",
    @types.panel_x + 16,
    @types.map_offset_y + 88,
    15,
    @raylib.lightgray,
  )
  @types.draw_shadow_text(
    "\{game.score_total}",
    @types.panel_x + 16,
    @types.map_offset_y + 106,
    24,
    @raylib.white,
  )

  @types.draw_shadow_text(
    "BEST",
    @types.panel_x + 145,
    @types.map_offset_y + 88,
    15,
    @raylib.lightgray,
  )
  @types.draw_shadow_text(
    "\{game.high_score}",
    @types.panel_x + 145,
    @types.map_offset_y + 106,
    24,
    @raylib.white,
  )

  draw_enemy_counter(game, @types.panel_x + 20, @types.map_offset_y + 148)

  draw_player_card(
    game,
    0,
    @types.panel_x + 12,
    @types.map_offset_y + 330,
    "P1",
    @raylib.skyblue,
  )

  if game.coop_enabled {
    draw_player_card(
      game,
      1,
      @types.panel_x + 12,
      @types.map_offset_y + 444,
      "P2",
      @raylib.orange,
    )
  } else {
    @raylib.draw_rectangle(
      @types.panel_x + 12,
      @types.map_offset_y + 444,
      @types.panel_w - 24,
      108,
      @raylib.Color::new(24, 28, 36, 255),
    )
    @raylib.draw_rectangle_lines(
      @types.panel_x + 12,
      @types.map_offset_y + 444,
      @types.panel_w - 24,
      108,
      @raylib.Color::new(58, 70, 89, 255),
    )
    @types.draw_shadow_text(
      "P2 OFF",
      @types.panel_x + 22,
      @types.map_offset_y + 458,
      24,
      @raylib.darkgray,
    )
    @types.draw_shadow_text(
      "Press C in menu",
      @types.panel_x + 22,
      @types.map_offset_y + 495,
      16,
      @raylib.gray,
    )
  }

  let fx = @types.panel_x + 18
  let fy = @types.map_offset_y + @types.map_pixel_h - 118
  @types.draw_shadow_text("P1: Arrows + Shift", fx, fy, 14, @raylib.lightgray)
  @types.draw_shadow_text("P2: WASD + Space", fx, fy + 18, 14, @raylib.lightgray)
  @types.draw_shadow_text("P: Pause", fx, fy + 36, 14, @raylib.lightgray)
  @types.draw_shadow_text("Base must survive", fx, fy + 54, 14, @raylib.gold)

  if game.freeze_all_timer > 0.0 {
    @types.draw_shadow_text(
      "FROZEN \{game.freeze_all_timer.to_int()}s",
      fx,
      fy + 74,
      16,
      @raylib.skyblue,
    )
  }
  if game.shovel_timer > 0.0 {
    @types.draw_shadow_text(
      "FORTIFY \{game.shovel_timer.to_int()}s",
      fx + 126,
      fy + 74,
      16,
      @raylib.orange,
    )
  }

  if game.combo_timer > 0.0 && game.kill_combo > 1 {
    @types.draw_shadow_text(
      "COMBO x\{@score.combo_multiplier(game)}",
      @types.panel_x + 18,
      @types.map_offset_y + 292,
      18,
      @raylib.lime,
    )
  }
}

///|
fn draw_menu_overlay(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(5, 8, 14, 190),
  )

  @types.draw_centered_text("TANK 1990", @types.screen_width / 2, 110, 66, @raylib.gold)
  @types.draw_centered_text(
    "MoonBit + raylib",
    @types.screen_width / 2,
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
    @types.draw_centered_text(options[i], @types.screen_width / 2, 300 + i * 52, 36, color)
  }

  @types.draw_centered_text(
    "Arrows/W/S + Enter",
    @types.screen_width / 2,
    490,
    22,
    @raylib.lightgray,
  )
  @types.draw_centered_text(
    "Press D for instant demo run",
    @types.screen_width / 2,
    520,
    18,
    @raylib.lime,
  )
  @types.draw_centered_text(
    "Press C anytime in menu to toggle co-op",
    @types.screen_width / 2,
    546,
    18,
    @raylib.darkgray,
  )
  @types.draw_centered_text(
    "Protect the base. Clear all stages.",
    @types.screen_width / 2,
    578,
    20,
    @raylib.raywhite,
  )
}

///|
fn draw_stage_intro_overlay(game : @types.Game) -> Unit {
  let alpha = @types.clampf(game.stage_intro_timer / @types.stage_intro_time, 0.0, 1.0)
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.color_alpha(@raylib.black, 0.65 * alpha + 0.25),
  )
  @types.draw_centered_text(
    "STAGE \{game.stage_index + 1}",
    @types.screen_width / 2,
    @types.screen_height / 2 - 52,
    54,
    @raylib.white,
  )
  @types.draw_centered_text(
    game.profile.title,
    @types.screen_width / 2,
    @types.screen_height / 2 + 10,
    28,
    game.profile.ui_accent,
  )
  @types.draw_centered_text(
    game.profile.subtitle,
    @types.screen_width / 2,
    @types.screen_height / 2 + 42,
    20,
    @raylib.lightgray,
  )
  @types.draw_centered_text(
    "Enemies: \{game.enemies_to_spawn}",
    @types.screen_width / 2,
    @types.screen_height / 2 + 78,
    24,
    @raylib.lightgray,
  )
  if game.demo_mode {
    @types.draw_centered_text(
      "AUTO DEMO ACTIVE",
      @types.screen_width / 2,
      @types.screen_height / 2 + 112,
      20,
      @raylib.lime,
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
    @raylib.Color::new(5, 8, 14, 160),
  )
  let pulse = Float::from_double(@math.sin(game.pause_blink.to_double() * 3.0)) *
    0.5 +
    0.5
  let color = @raylib.color_lerp(@raylib.yellow, @raylib.white, pulse)
  @types.draw_centered_text("PAUSED", @types.screen_width / 2, 300, 62, color)
  @types.draw_centered_text(
    "P to resume",
    @types.screen_width / 2,
    380,
    24,
    @raylib.lightgray,
  )
  @types.draw_centered_text(
    "ESC to menu",
    @types.screen_width / 2,
    412,
    24,
    @raylib.lightgray,
  )
}

///|
fn draw_stage_clear_overlay(game : @types.Game) -> Unit {
  let t = @types.clampf(1.0 - game.stage_clear_timer / @types.stage_clear_time, 0.0, 1.0)
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.color_alpha(@raylib.black, 0.35 + t * 0.2),
  )
  let color = @types.pulse_color(
    @raylib.lime,
    Float::from_int(game.frame_counter) * 0.08,
  )
  @types.draw_centered_text("STAGE CLEAR", @types.screen_width / 2, 298, 58, color)
  @types.draw_centered_text(
    "Prepare for next battle",
    @types.screen_width / 2,
    370,
    26,
    @raylib.white,
  )
}

///|
fn draw_game_over_overlay(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(20, 0, 0, 170),
  )
  @types.draw_centered_text("GAME OVER", @types.screen_width / 2, 294, 62, @raylib.red)
  @types.draw_centered_text(
    "Score: \{game.score_total}",
    @types.screen_width / 2,
    370,
    30,
    @raylib.white,
  )
}

///|
fn draw_campaign_clear_overlay(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(0, 28, 16, 178),
  )
  let color = @types.pulse_color(
    @raylib.gold,
    Float::from_int(game.frame_counter) * 0.1,
  )
  @types.draw_centered_text("CAMPAIGN COMPLETE", @types.screen_width / 2, 266, 58, color)
  @types.draw_centered_text(
    "Final Score: \{game.score_total}",
    @types.screen_width / 2,
    340,
    30,
    @raylib.white,
  )
  @types.draw_centered_text(
    "Best Score: \{game.high_score}",
    @types.screen_width / 2,
    378,
    24,
    @raylib.lightgray,
  )
}

///|
pub fn draw_ui(game : @types.Game) -> Unit {
  draw_panel(game)

  if game.state == @types.state_menu {
    draw_menu_overlay(game)
  } else if game.state == @types.state_stage_intro {
    draw_stage_intro_overlay(game)
  } else if game.state == @types.state_paused {
    draw_pause_overlay(game)
  } else if game.state == @types.state_stage_clear {
    draw_stage_clear_overlay(game)
  } else if game.state == @types.state_game_over {
    draw_game_over_overlay(game)
  } else if game.state == @types.state_campaign_clear {
    draw_campaign_clear_overlay(game)
  }
}
