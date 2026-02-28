///|
pub fn draw_ui(game : @types.Game) -> Unit {
  if game.state == @types.state_menu {
    draw_menu(game)
  } else if game.state == @types.state_aircraft_select {
    draw_aircraft_select(game)
  } else if game.state == @types.state_mission_briefing {
    draw_mission_briefing(game)
  } else if game.state == @types.state_playing {
    draw_hud(game)
    draw_radar(game)
    draw_warning_indicators(game)
  } else if game.state == @types.state_paused {
    draw_hud(game)
    draw_pause_overlay()
  } else if game.state == @types.state_mission_complete {
    draw_hud(game)
    draw_mission_complete_detailed(game)
  } else if game.state == @types.state_game_over {
    draw_game_over_detailed(game)
  }
}

///|
fn draw_menu(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(20, 30, 50, 255),
  )
  let title = "FLIGHT SIM 3D"
  let tw = @raylib.measure_text(title, 48)
  @raylib.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    60,
    48,
    @raylib.Color::new(255, 255, 255, 255),
  )
  let sub = "Select Mission"
  let sw = @raylib.measure_text(sub, 22)
  @raylib.draw_text(
    sub,
    (@types.screen_width - sw) / 2,
    120,
    22,
    @raylib.Color::new(200, 200, 220, 255),
  )
  // Mission list (scrollable, show 8 at a time)
  let visible = 8
  let start = @types.clampi(
    game.menu_cursor - visible / 2,
    0,
    @types.total_missions - visible,
  )
  let start_safe = @types.clampi(start, 0, @types.total_missions - 1)
  let end_val = @types.clampi(start_safe + visible, 0, @types.total_missions)
  for i in start_safe..<end_val {
    let row = i - start_safe
    let y = 170 + row * 55
    let is_sel = game.menu_cursor == i
    let blink = @math.sinf(game.menu_blink * 2.0)
    let color = if is_sel {
      if blink > 0.0 {
        @raylib.Color::new(255, 255, 100, 255)
      } else {
        @raylib.Color::new(200, 200, 80, 255)
      }
    } else {
      @raylib.Color::new(180, 180, 200, 255)
    }
    let prefix = if is_sel { "> " } else { "  " }
    let mission = game.missions[i]
    let num_text = prefix + "\{i + 1}. " + mission.name
    @raylib.draw_text(num_text, 200, y, 24, color)
    // Description
    let desc_color = if is_sel {
      @raylib.Color::new(200, 200, 220, 255)
    } else {
      @raylib.Color::new(130, 130, 150, 255)
    }
    @raylib.draw_text(mission.description, 230, y + 26, 14, desc_color)
    // Weather icon
    let weather_text = if mission.weather == @types.weather_fog {
      "[FOG]"
    } else if mission.weather == @types.weather_storm {
      "[STORM]"
    } else {
      ""
    }
    if weather_text != "" {
      @raylib.draw_text(
        weather_text,
        750,
        y + 2,
        16,
        @raylib.Color::new(200, 150, 80, 255),
      )
    }
    // Completed indicator
    if i < game.missions_completed {
      @raylib.draw_text(
        "DONE",
        880,
        y + 2,
        16,
        @raylib.Color::new(100, 200, 100, 255),
      )
    }
  }
  let hint = "Up/Down: Select | Enter: Start Mission"
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
fn draw_hud(game : @types.Game) -> Unit {
  let player = game.player
  // Top bar
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    36,
    @raylib.Color::new(0, 0, 0, 140),
  )
  let mission = game.missions[game.current_mission]
  @raylib.draw_text(
    mission.name,
    10,
    8,
    20,
    @raylib.Color::new(200, 220, 255, 255),
  )
  @raylib.draw_text(
    "Score: \{game.score}",
    350,
    8,
    18,
    @raylib.Color::new(255, 255, 200, 255),
  )
  @raylib.draw_text(
    "Kills: \{game.kills}",
    520,
    8,
    18,
    @raylib.Color::new(255, 150, 100, 255),
  )
  // Altitude gauge (left side)
  let alt_y = 60
  @raylib.draw_rectangle(20, alt_y, 40, 200, @raylib.Color::new(0, 0, 0, 120))
  let alt_text = "ALT"
  @raylib.draw_text(
    alt_text,
    22,
    alt_y - 16,
    14,
    @raylib.Color::new(150, 200, 255, 255),
  )
  let alt_ratio = @types.clampf(player.y / 80.0, 0.0, 1.0)
  let alt_bar_h = (alt_ratio * 196.0).to_int()
  @raylib.draw_rectangle(
    22,
    alt_y + 198 - alt_bar_h,
    36,
    alt_bar_h,
    @raylib.Color::new(50, 150, 255, 200),
  )
  let alt_val = player.y.to_int()
  @raylib.draw_text(
    "\{alt_val}m",
    22,
    alt_y + 202,
    14,
    @raylib.Color::new(150, 200, 255, 255),
  )
  // Speed gauge (left side, below altitude)
  let spd_y = alt_y + 240
  @raylib.draw_rectangle(20, spd_y, 40, 100, @raylib.Color::new(0, 0, 0, 120))
  @raylib.draw_text(
    "SPD",
    22,
    spd_y - 16,
    14,
    @raylib.Color::new(100, 255, 100, 255),
  )
  let spd_ratio = @types.clampf(
    (player.speed - @types.aircraft_speed_min) /
    (@types.aircraft_speed_max - @types.aircraft_speed_min),
    0.0,
    1.0,
  )
  let spd_bar_h = (spd_ratio * 96.0).to_int()
  @raylib.draw_rectangle(
    22,
    spd_y + 98 - spd_bar_h,
    36,
    spd_bar_h,
    @raylib.Color::new(100, 255, 100, 200),
  )
  let spd_val = player.speed.to_int()
  @raylib.draw_text(
    "\{spd_val}",
    22,
    spd_y + 102,
    14,
    @raylib.Color::new(100, 255, 100, 255),
  )
  // Fuel gauge (right side)
  let fuel_x = @types.screen_width - 60
  let fuel_y = 60
  @raylib.draw_rectangle(
    fuel_x,
    fuel_y,
    40,
    150,
    @raylib.Color::new(0, 0, 0, 120),
  )
  @raylib.draw_text(
    "FUEL",
    fuel_x - 2,
    fuel_y - 16,
    14,
    @raylib.Color::new(255, 200, 50, 255),
  )
  let fuel_ratio = @types.clampf(
    player.fuel / @types.aircraft_max_fuel,
    0.0,
    1.0,
  )
  let fuel_bar_h = (fuel_ratio * 146.0).to_int()
  let fuel_color = if fuel_ratio < 0.2 {
    @raylib.Color::new(255, 50, 50, 200)
  } else if fuel_ratio < 0.5 {
    @raylib.Color::new(255, 200, 50, 200)
  } else {
    @raylib.Color::new(50, 200, 50, 200)
  }
  @raylib.draw_rectangle(
    fuel_x + 2,
    fuel_y + 148 - fuel_bar_h,
    36,
    fuel_bar_h,
    fuel_color,
  )
  let fuel_pct = (fuel_ratio * 100.0).to_int()
  @raylib.draw_text(
    "\{fuel_pct}%",
    fuel_x,
    fuel_y + 152,
    14,
    @raylib.Color::new(255, 200, 50, 255),
  )
  // HP bar (bottom left)
  let hp_y = @types.screen_height - 60
  let hp_ratio = @types.clampf(player.hp / player.max_hp, 0.0, 1.0)
  let hp_bar_w = 200
  @raylib.draw_rectangle(
    20,
    hp_y,
    hp_bar_w,
    20,
    @raylib.Color::new(80, 0, 0, 200),
  )
  @raylib.draw_rectangle(
    20,
    hp_y,
    (Float::from_int(hp_bar_w) * hp_ratio).to_int(),
    20,
    @raylib.Color::new(0, 200, 0, 200),
  )
  @raylib.draw_rectangle_lines(
    20,
    hp_y,
    hp_bar_w,
    20,
    @raylib.Color::new(200, 200, 200, 150),
  )
  let hp_val = player.hp.to_int()
  @raylib.draw_text(
    "HP: \{hp_val}",
    25,
    hp_y + 2,
    16,
    @raylib.Color::new(255, 255, 255, 255),
  )
  // Throttle indicator (bottom center)
  @raylib.draw_text(
    "THR",
    @types.screen_width / 2 - 60,
    hp_y,
    14,
    @raylib.Color::new(200, 200, 200, 200),
  )
  @raylib.draw_rectangle(
    @types.screen_width / 2 - 20,
    hp_y,
    100,
    16,
    @raylib.Color::new(40, 40, 40, 200),
  )
  let thr_w = (player.throttle * 96.0).to_int()
  @raylib.draw_rectangle(
    @types.screen_width / 2 - 18,
    hp_y + 2,
    thr_w,
    12,
    @raylib.Color::new(255, 150, 50, 200),
  )
  // Crosshair
  let cx = @types.screen_width / 2
  let cy = @types.screen_height / 2
  @raylib.draw_line(cx - 15, cy, cx - 5, cy, @raylib.Color::new(0, 255, 0, 180))
  @raylib.draw_line(cx + 5, cy, cx + 15, cy, @raylib.Color::new(0, 255, 0, 180))
  @raylib.draw_line(cx, cy - 15, cx, cy - 5, @raylib.Color::new(0, 255, 0, 180))
  @raylib.draw_line(cx, cy + 5, cx, cy + 15, @raylib.Color::new(0, 255, 0, 180))
  // Mission objective text
  draw_objective(game)
  // Message display
  if game.message_timer > 0.0 {
    let msg_w = @raylib.measure_text(game.message_text, 22)
    @raylib.draw_rectangle(
      (@types.screen_width - msg_w) / 2 - 10,
      @types.screen_height / 2 + 140,
      msg_w + 20,
      30,
      @raylib.Color::new(0, 0, 0, 150),
    )
    @raylib.draw_text(
      game.message_text,
      (@types.screen_width - msg_w) / 2,
      @types.screen_height / 2 + 144,
      22,
      @raylib.Color::new(255, 255, 200, 255),
    )
  }
  // Damage flash
  if player.damage_flash > 0.0 {
    let flash_alpha = (player.damage_flash * 200.0).to_int()
    let fa = @types.clampi(flash_alpha, 0, 150)
    @raylib.draw_rectangle(
      0,
      0,
      @types.screen_width,
      @types.screen_height,
      @raylib.Color::new(255, 0, 0, fa),
    )
  }
  // Controls bar
  @raylib.draw_rectangle(
    0,
    @types.screen_height - 28,
    @types.screen_width,
    28,
    @raylib.Color::new(0, 0, 0, 100),
  )
  @raylib.draw_text(
    "W/S: Pitch | A/D: Yaw | Q/E: Roll | Shift: Throttle Up | Ctrl: Down | Space: Fire | P: Pause",
    10,
    @types.screen_height - 22,
    12,
    @raylib.Color::new(150, 150, 170, 255),
  )
  // Weather indicator
  if game.weather != @types.weather_clear {
    let weather_text = if game.weather == @types.weather_fog {
      "FOG"
    } else {
      "STORM"
    }
    let weather_color = if game.weather == @types.weather_fog {
      @raylib.Color::new(200, 200, 150, 255)
    } else {
      @raylib.Color::new(255, 150, 50, 255)
    }
    @raylib.draw_text(
      weather_text,
      @types.screen_width - 80,
      @types.screen_height - 22,
      14,
      weather_color,
    )
  }
}

///|
fn draw_objective(game : @types.Game) -> Unit {
  let mission = game.missions[game.current_mission]
  let obj_text = if mission.kind == @types.mission_checkpoint {
    "Checkpoints: \{mission.targets_done}/\{mission.target_count}"
  } else if mission.kind == @types.mission_destroy {
    "Targets: \{mission.targets_done}/\{mission.target_count}"
  } else if mission.kind == @types.mission_landing {
    if game.landing_approach {
      "LANDING..."
    } else {
      "Fly to landing zone"
    }
  } else if mission.kind == @types.mission_survive {
    let remaining = mission.target_count - mission.targets_done
    "Survive: \{remaining}s"
  } else if mission.kind == @types.mission_escort {
    "Escort: Protect the convoy"
  } else if mission.kind == @types.mission_patrol {
    "Patrol: Visit checkpoints"
  } else if mission.kind == @types.mission_intercept {
    "Intercept: \{mission.targets_done}/\{mission.target_count} shot down"
  } else if mission.kind == @types.mission_bombing_run {
    "Bomb targets: \{mission.targets_done}/\{mission.target_count}"
  } else if mission.kind == @types.mission_dogfight {
    "Dogfight: \{mission.targets_done}/\{mission.target_count} shot down"
  } else if mission.kind == @types.mission_recon {
    "Recon: \{mission.targets_done}/\{mission.target_count} photographed"
  } else if mission.kind == @types.mission_defense {
    "Defend base: \{mission.targets_done}/\{mission.target_count} eliminated"
  } else if mission.kind == @types.mission_attack_base {
    "Attack base: \{mission.targets_done}/\{mission.target_count} destroyed"
  } else if mission.kind == @types.mission_canyon_run {
    "Canyon run: \{mission.targets_done}/\{mission.target_count} rings"
  } else if mission.kind == @types.mission_night_mission {
    "Night op: \{mission.targets_done}/\{mission.target_count} complete"
  } else if mission.kind == @types.mission_boss {
    "Boss fight: \{mission.targets_done}/\{mission.target_count} targets"
  } else {
    ""
  }
  if obj_text != "" {
    let ow = @raylib.measure_text(obj_text, 18)
    @raylib.draw_rectangle(
      (@types.screen_width - ow) / 2 - 8,
      42,
      ow + 16,
      26,
      @raylib.Color::new(0, 0, 0, 120),
    )
    @raylib.draw_text(
      obj_text,
      (@types.screen_width - ow) / 2,
      46,
      18,
      @raylib.Color::new(255, 220, 100, 255),
    )
  }
}

///|
fn draw_pause_overlay() -> Unit {
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
    @types.screen_height / 2 - 50,
    60,
    @raylib.Color::new(255, 255, 255, 255),
  )
  let hint = "P: Resume | R: Restart | Q: Quit to Menu"
  let hw = @raylib.measure_text(hint, 20)
  @raylib.draw_text(
    hint,
    (@types.screen_width - hw) / 2,
    @types.screen_height / 2 + 20,
    20,
    @raylib.Color::new(200, 200, 220, 255),
  )
}

///|
fn draw_mission_complete_detailed(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(0, 0, 0, 180),
  )
  let text = "MISSION COMPLETE!"
  let tw = @raylib.measure_text(text, 48)
  @raylib.draw_text(
    text,
    (@types.screen_width - tw) / 2,
    100,
    48,
    @raylib.Color::new(100, 255, 100, 255),
  )
  let mission = game.missions[game.current_mission]
  let mw = @raylib.measure_text(mission.name, 28)
  @raylib.draw_text(
    mission.name,
    (@types.screen_width - mw) / 2,
    160,
    28,
    @raylib.Color::new(200, 220, 255, 255),
  )
  // Score breakdown panel
  let panel_x = @types.screen_width / 2 - 200
  let panel_y = 210
  @raylib.draw_rectangle(
    panel_x,
    panel_y,
    400,
    280,
    @raylib.Color::new(20, 30, 50, 200),
  )
  @raylib.draw_rectangle_lines(
    panel_x,
    panel_y,
    400,
    280,
    @raylib.Color::new(100, 150, 200, 200),
  )
  // Score details
  let line_x = panel_x + 20
  let mut line_y = panel_y + 15
  @raylib.draw_text(
    "SCORE BREAKDOWN",
    line_x,
    line_y,
    20,
    @raylib.Color::new(255, 220, 100, 255),
  )
  line_y = line_y + 35
  let mission_pts = "Mission Score: \{game.mission_score}"
  @raylib.draw_text(
    mission_pts,
    line_x,
    line_y,
    16,
    @raylib.Color::new(200, 200, 220, 255),
  )
  line_y = line_y + 25
  let kills_text = "Kills: \{game.kills}"
  @raylib.draw_text(
    kills_text,
    line_x,
    line_y,
    16,
    @raylib.Color::new(255, 150, 100, 255),
  )
  line_y = line_y + 25
  let destroyed_text = "Buildings Destroyed: \{game.buildings_destroyed}"
  @raylib.draw_text(
    destroyed_text,
    line_x,
    line_y,
    16,
    @raylib.Color::new(255, 180, 80, 255),
  )
  line_y = line_y + 25
  let acc_val = game.accuracy_pct.to_int()
  let accuracy_text = "Accuracy: \{acc_val}%"
  @raylib.draw_text(
    accuracy_text,
    line_x,
    line_y,
    16,
    @raylib.Color::new(150, 200, 255, 255),
  )
  line_y = line_y + 25
  let time_val = game.mission_timer.to_int()
  let time_text = "Time: \{time_val}s"
  @raylib.draw_text(
    time_text,
    line_x,
    line_y,
    16,
    @raylib.Color::new(200, 200, 200, 255),
  )
  line_y = line_y + 25
  let hp_pct = (game.player.hp / game.player.max_hp * 100.0).to_int()
  let hp_text = "Hull Integrity: \{hp_pct}%"
  @raylib.draw_text(
    hp_text,
    line_x,
    line_y,
    16,
    @raylib.Color::new(100, 255, 100, 255),
  )
  line_y = line_y + 35
  // Rating display
  let rating_label = "RATING: " + game.mission_rating
  let rating_color = if game.mission_rating == "S" {
    @raylib.Color::new(255, 215, 0, 255)
  } else if game.mission_rating == "A" {
    @raylib.Color::new(100, 255, 100, 255)
  } else if game.mission_rating == "B" {
    @raylib.Color::new(100, 200, 255, 255)
  } else {
    @raylib.Color::new(200, 200, 200, 255)
  }
  let rw = @raylib.measure_text(rating_label, 28)
  @raylib.draw_text(
    rating_label,
    panel_x + (400 - rw) / 2,
    line_y,
    28,
    rating_color,
  )
  // Total score
  let total_text = "Total Score: \{game.score}"
  let tsw = @raylib.measure_text(total_text, 22)
  @raylib.draw_text(
    total_text,
    (@types.screen_width - tsw) / 2,
    panel_y + 290,
    22,
    @raylib.Color::new(255, 255, 200, 255),
  )
  // Hint
  let hint = "Enter: Back to Menu"
  let hw = @raylib.measure_text(hint, 18)
  @raylib.draw_text(
    hint,
    (@types.screen_width - hw) / 2,
    @types.screen_height - 60,
    18,
    @raylib.Color::new(150, 150, 170, 255),
  )
}

///|
fn draw_game_over_detailed(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(30, 0, 0, 220),
  )
  let text = "MISSION FAILED"
  let tw = @raylib.measure_text(text, 50)
  @raylib.draw_text(
    text,
    (@types.screen_width - tw) / 2,
    @types.screen_height / 2 - 80,
    50,
    @raylib.Color::new(255, 80, 60, 255),
  )
  // Show what happened
  let mission = game.missions[game.current_mission]
  let mission_w = @raylib.measure_text(mission.name, 22)
  @raylib.draw_text(
    mission.name,
    (@types.screen_width - mission_w) / 2,
    @types.screen_height / 2 - 20,
    22,
    @raylib.Color::new(200, 180, 180, 255),
  )
  let progress_done = mission.targets_done
  let progress_total = mission.target_count
  let progress_text = "Progress: \{progress_done}/\{progress_total}"
  let pw = @raylib.measure_text(progress_text, 18)
  @raylib.draw_text(
    progress_text,
    (@types.screen_width - pw) / 2,
    @types.screen_height / 2 + 15,
    18,
    @raylib.Color::new(200, 150, 100, 255),
  )
  let kills_text = "Kills: \{game.kills}"
  let kw = @raylib.measure_text(kills_text, 18)
  @raylib.draw_text(
    kills_text,
    (@types.screen_width - kw) / 2,
    @types.screen_height / 2 + 40,
    18,
    @raylib.Color::new(255, 150, 100, 255),
  )
  let hint = "Enter: Menu | R: Retry"
  let hw = @raylib.measure_text(hint, 20)
  @raylib.draw_text(
    hint,
    (@types.screen_width - hw) / 2,
    @types.screen_height / 2 + 80,
    20,
    @raylib.Color::new(200, 180, 180, 255),
  )
}

// Aircraft selection screen

///|
fn draw_aircraft_select(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(15, 25, 45, 255),
  )
  let title = "SELECT AIRCRAFT"
  let tw = @raylib.measure_text(title, 40)
  @raylib.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    40,
    40,
    @raylib.Color::new(255, 255, 255, 255),
  )
  // Draw 4 aircraft cards
  let card_w = 250
  let card_h = 380
  let card_spacing = 20
  let total_w = card_w * 4 + card_spacing * 3
  let start_x = (@types.screen_width - total_w) / 2
  let card_y = 110
  // Aircraft data arrays
  let names = ["Trainer", "Fighter", "Bomber", "Interceptor"]
  let speed_vals = ["60", "90", "55", "110"]
  let hp_vals = ["80", "100", "160", "70"]
  let ammo_mg_vals = ["300", "500", "200", "400"]
  let ammo_rkt_vals = ["4", "8", "6", "12"]
  let ammo_bomb_vals = ["2", "4", "12", "0"]
  let turn_vals = ["Good", "Great", "Poor", "Fair"]
  let descriptions = [
    "Easy handling, balanced stats", "All-around combat aircraft", "Heavy payload, tough armor",
    "Fast but fragile speedster",
  ]
  for i in 0..<4 {
    let cx = start_x + i * (card_w + card_spacing)
    let is_sel = game.selected_aircraft == i
    // Card background
    let bg_color = if is_sel {
      @raylib.Color::new(40, 60, 100, 255)
    } else {
      @raylib.Color::new(25, 35, 55, 255)
    }
    @raylib.draw_rectangle(cx, card_y, card_w, card_h, bg_color)
    // Selection border
    if is_sel {
      let blink = @math.sinf(game.menu_blink * 2.0)
      let border_alpha = 180 + (blink * 75.0).to_int()
      let ba = @types.clampi(border_alpha, 100, 255)
      @raylib.draw_rectangle_lines(
        cx - 2,
        card_y - 2,
        card_w + 4,
        card_h + 4,
        @raylib.Color::new(100, 200, 255, ba),
      )
    }
    // Aircraft name
    let name_color = if is_sel {
      @raylib.Color::new(255, 255, 200, 255)
    } else {
      @raylib.Color::new(180, 180, 200, 255)
    }
    let nw = @raylib.measure_text(names[i], 24)
    @raylib.draw_text(
      names[i],
      cx + (card_w - nw) / 2,
      card_y + 15,
      24,
      name_color,
    )
    // Aircraft icon (simplified silhouette using rectangles)
    let icon_cx = cx + card_w / 2
    let icon_cy = card_y + 80
    let icon_color = if is_sel {
      @raylib.Color::new(100, 180, 255, 255)
    } else {
      @raylib.Color::new(80, 120, 180, 200)
    }
    // Fuselage
    @raylib.draw_rectangle(icon_cx - 8, icon_cy - 20, 16, 40, icon_color)
    // Wings
    @raylib.draw_rectangle(icon_cx - 35, icon_cy - 5, 70, 10, icon_color)
    // Tail
    @raylib.draw_rectangle(icon_cx - 15, icon_cy + 15, 30, 6, icon_color)
    // Stats
    let stat_x = cx + 15
    let mut stat_y = card_y + 130
    let stat_color = @raylib.Color::new(180, 200, 220, 255)
    let val_color = if is_sel {
      @raylib.Color::new(100, 255, 150, 255)
    } else {
      @raylib.Color::new(150, 200, 150, 255)
    }
    @raylib.draw_text("Speed:", stat_x, stat_y, 14, stat_color)
    @raylib.draw_text(speed_vals[i], stat_x + 130, stat_y, 14, val_color)
    stat_y = stat_y + 22
    @raylib.draw_text("HP:", stat_x, stat_y, 14, stat_color)
    @raylib.draw_text(hp_vals[i], stat_x + 130, stat_y, 14, val_color)
    stat_y = stat_y + 22
    @raylib.draw_text("MG Ammo:", stat_x, stat_y, 14, stat_color)
    @raylib.draw_text(ammo_mg_vals[i], stat_x + 130, stat_y, 14, val_color)
    stat_y = stat_y + 22
    @raylib.draw_text("Rockets:", stat_x, stat_y, 14, stat_color)
    @raylib.draw_text(ammo_rkt_vals[i], stat_x + 130, stat_y, 14, val_color)
    stat_y = stat_y + 22
    @raylib.draw_text("Bombs:", stat_x, stat_y, 14, stat_color)
    @raylib.draw_text(ammo_bomb_vals[i], stat_x + 130, stat_y, 14, val_color)
    stat_y = stat_y + 22
    @raylib.draw_text("Handling:", stat_x, stat_y, 14, stat_color)
    @raylib.draw_text(turn_vals[i], stat_x + 130, stat_y, 14, val_color)
    stat_y = stat_y + 30
    // Description
    let desc_color = if is_sel {
      @raylib.Color::new(200, 220, 240, 255)
    } else {
      @raylib.Color::new(130, 140, 160, 255)
    }
    @raylib.draw_text(descriptions[i], stat_x, stat_y, 12, desc_color)
    ignore(i)
  }
  // Controls hint
  let hint = "Left/Right: Select | Enter: Confirm | Esc: Back"
  let hw = @raylib.measure_text(hint, 16)
  @raylib.draw_text(
    hint,
    (@types.screen_width - hw) / 2,
    @types.screen_height - 40,
    16,
    @raylib.Color::new(120, 120, 140, 255),
  )
}

// Mission briefing overlay

///|
fn draw_mission_briefing(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(10, 15, 30, 250),
  )
  let mission = game.missions[game.current_mission]
  // Title
  let title = "MISSION BRIEFING"
  let tw = @raylib.measure_text(title, 36)
  @raylib.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    50,
    36,
    @raylib.Color::new(255, 220, 100, 255),
  )
  // Mission name
  let mw = @raylib.measure_text(mission.name, 30)
  @raylib.draw_text(
    mission.name,
    (@types.screen_width - mw) / 2,
    110,
    30,
    @raylib.Color::new(255, 255, 255, 255),
  )
  // Briefing panel
  let panel_x = @types.screen_width / 2 - 350
  let panel_y = 170
  let panel_w = 700
  let panel_h = 380
  @raylib.draw_rectangle(
    panel_x,
    panel_y,
    panel_w,
    panel_h,
    @raylib.Color::new(20, 30, 50, 200),
  )
  @raylib.draw_rectangle_lines(
    panel_x,
    panel_y,
    panel_w,
    panel_h,
    @raylib.Color::new(80, 120, 180, 200),
  )
  // Briefing text lines
  let lines = @levels.get_mission_briefing_lines(game.current_mission)
  for i in 0..<lines.length() {
    let line_y = panel_y + 20 + i * 28
    let line_color = if i == 0 {
      @raylib.Color::new(255, 220, 100, 255)
    } else {
      @raylib.Color::new(200, 210, 230, 255)
    }
    @raylib.draw_text(lines[i], panel_x + 25, line_y, 18, line_color)
    ignore(i)
  }
  // Mission stats
  let stats_y = panel_y + 210
  let stats_x = panel_x + 25
  let difficulty_label = "Difficulty: " +
    @types.difficulty_str(mission.difficulty)
  @raylib.draw_text(
    difficulty_label,
    stats_x,
    stats_y,
    16,
    @raylib.Color::new(255, 180, 80, 255),
  )
  let weather_label = "Weather: " + @types.weather_name(mission.weather)
  @raylib.draw_text(
    weather_label,
    stats_x,
    stats_y + 24,
    16,
    @raylib.Color::new(150, 200, 255, 255),
  )
  let threats_air = mission.enemy_air_count
  let threats_ground = mission.enemy_count
  let threats_turret = mission.turret_count
  let threat_text = "Air: \{threats_air}  Ground: \{threats_ground}  Turrets: \{threats_turret}"
  @raylib.draw_text(
    "Threats - " + threat_text,
    stats_x,
    stats_y + 48,
    16,
    @raylib.Color::new(255, 120, 100, 255),
  )
  if mission.time_limit > 0.0 {
    let time_int = mission.time_limit.to_int()
    let time_text = "Time Limit: \{time_int}s"
    @raylib.draw_text(
      time_text,
      stats_x,
      stats_y + 72,
      16,
      @raylib.Color::new(255, 200, 50, 255),
    )
  }
  // Best score for this mission
  let best = game.best_scores[game.current_mission]
  if best > 0 {
    let best_text = "Best Score: \{best}"
    @raylib.draw_text(
      best_text,
      stats_x,
      stats_y + 96,
      16,
      @raylib.Color::new(100, 255, 100, 255),
    )
  }
  // Controls hint
  let hint = "Enter: Start Mission | Esc: Back to Aircraft Select"
  let hw = @raylib.measure_text(hint, 16)
  @raylib.draw_text(
    hint,
    (@types.screen_width - hw) / 2,
    @types.screen_height - 40,
    16,
    @raylib.Color::new(120, 120, 140, 255),
  )
}

// Mini radar display

///|
fn draw_radar(game : @types.Game) -> Unit {
  let radar_x = @types.screen_width - 130
  let radar_y = @types.screen_height - 160
  let radar_r = @types.radar_size / 2
  let radar_cx = radar_x + radar_r
  let radar_cy = radar_y + radar_r
  // Radar background
  @raylib.draw_rectangle(
    radar_x - 5,
    radar_y - 5,
    @types.radar_size + 10,
    @types.radar_size + 10,
    @raylib.Color::new(0, 0, 0, 160),
  )
  @raylib.draw_rectangle(
    radar_x,
    radar_y,
    @types.radar_size,
    @types.radar_size,
    @raylib.Color::new(0, 30, 0, 180),
  )
  // Radar grid lines
  @raylib.draw_line(
    radar_cx,
    radar_y,
    radar_cx,
    radar_y + @types.radar_size,
    @raylib.Color::new(0, 80, 0, 100),
  )
  @raylib.draw_line(
    radar_x,
    radar_cy,
    radar_x + @types.radar_size,
    radar_cy,
    @raylib.Color::new(0, 80, 0, 100),
  )
  // Sweep line
  let sweep_angle = Float::from_int(game.frame_counter) * 0.05
  let sweep_end_x = radar_cx +
    (Float::from_int(radar_r) * @math.cosf(sweep_angle)).to_int()
  let sweep_end_y = radar_cy +
    (Float::from_int(radar_r) * @math.sinf(sweep_angle)).to_int()
  @raylib.draw_line(
    radar_cx,
    radar_cy,
    sweep_end_x,
    sweep_end_y,
    @raylib.Color::new(0, 200, 0, 150),
  )
  // Player dot (center)
  @raylib.draw_rectangle(
    radar_cx - 2,
    radar_cy - 2,
    4,
    4,
    @raylib.Color::new(0, 255, 0, 255),
  )
  // Enemy blips
  let player = game.player
  let radar_scale = @types.radar_range / Float::from_int(radar_r)
  for e in game.enemies {
    if not(e.active) {
      continue
    }
    let dx = e.x - player.x
    let dz = e.z - player.z
    let dist = (dx * dx + dz * dz).sqrt()
    if dist > @types.radar_range {
      continue
    }
    // Rotate relative to player yaw
    let cos_yaw = @math.cosf(-player.yaw)
    let sin_yaw = @math.sinf(-player.yaw)
    let rx = dx * cos_yaw - dz * sin_yaw
    let rz = dx * sin_yaw + dz * cos_yaw
    let blip_x = radar_cx + (rx / radar_scale).to_int()
    let blip_y = radar_cy + (rz / radar_scale).to_int()
    // Clamp to radar area
    let bx = @types.clampi(blip_x, radar_x + 2, radar_x + @types.radar_size - 2)
    let by = @types.clampi(blip_y, radar_y + 2, radar_y + @types.radar_size - 2)
    let blip_color = if e.kind == @types.enemy_type_air {
      @raylib.Color::new(255, 50, 50, 255)
    } else {
      @raylib.Color::new(255, 150, 50, 255)
    }
    @raylib.draw_rectangle(bx - 1, by - 1, 3, 3, blip_color)
  }
  // Turret blips
  for t in game.turrets {
    if not(t.active) {
      continue
    }
    let dx = t.x - player.x
    let dz = t.z - player.z
    let dist = (dx * dx + dz * dz).sqrt()
    if dist > @types.radar_range {
      continue
    }
    let cos_yaw = @math.cosf(-player.yaw)
    let sin_yaw = @math.sinf(-player.yaw)
    let rx = dx * cos_yaw - dz * sin_yaw
    let rz = dx * sin_yaw + dz * cos_yaw
    let blip_x = radar_cx + (rx / radar_scale).to_int()
    let blip_y = radar_cy + (rz / radar_scale).to_int()
    let bx = @types.clampi(blip_x, radar_x + 2, radar_x + @types.radar_size - 2)
    let by = @types.clampi(blip_y, radar_y + 2, radar_y + @types.radar_size - 2)
    @raylib.draw_rectangle(
      bx - 1,
      by - 1,
      3,
      3,
      @raylib.Color::new(255, 200, 50, 255),
    )
  }
  // Radar label
  @raylib.draw_text(
    "RADAR",
    radar_x,
    radar_y - 16,
    12,
    @raylib.Color::new(0, 200, 0, 200),
  )
}

// Warning indicators

///|
fn draw_warning_indicators(game : @types.Game) -> Unit {
  let flash_sin = @math.sinf(
    game.warning_flash_timer * @types.warning_flash_rate,
  )
  let flash_on = flash_sin > 0.0
  let warn_x = 20
  let mut warn_y = @types.screen_height - 180
  // Stall warning
  if game.stall_warning && flash_on {
    @raylib.draw_rectangle(
      warn_x,
      warn_y,
      90,
      22,
      @raylib.Color::new(255, 0, 0, 180),
    )
    @raylib.draw_text(
      "STALL",
      warn_x + 8,
      warn_y + 3,
      16,
      @raylib.Color::new(255, 255, 255, 255),
    )
  }
  warn_y = warn_y + 26
  // Low fuel warning
  if game.fuel_warning {
    let fuel_flash = @math.sinf(
      game.warning_flash_timer * @types.warning_fuel_rate,
    )
    if fuel_flash > 0.0 {
      @raylib.draw_rectangle(
        warn_x,
        warn_y,
        90,
        22,
        @raylib.Color::new(255, 150, 0, 180),
      )
      @raylib.draw_text(
        "FUEL LOW",
        warn_x + 5,
        warn_y + 3,
        14,
        @raylib.Color::new(255, 255, 255, 255),
      )
    }
  }
  warn_y = warn_y + 26
  // Altitude warning
  if game.altitude_warning {
    let alt_flash = @math.sinf(
      game.warning_flash_timer * @types.warning_altitude_rate,
    )
    if alt_flash > 0.0 {
      @raylib.draw_rectangle(
        warn_x,
        warn_y,
        90,
        22,
        @raylib.Color::new(255, 80, 0, 180),
      )
      @raylib.draw_text(
        "PULL UP",
        warn_x + 8,
        warn_y + 3,
        14,
        @raylib.Color::new(255, 255, 255, 255),
      )
    }
  }
  warn_y = warn_y + 26
  // Damage warning
  if game.damage_warning && flash_on {
    @raylib.draw_rectangle(
      warn_x,
      warn_y,
      90,
      22,
      @raylib.Color::new(200, 0, 0, 180),
    )
    @raylib.draw_text(
      "DAMAGE",
      warn_x + 8,
      warn_y + 3,
      14,
      @raylib.Color::new(255, 255, 255, 255),
    )
  }
  warn_y = warn_y + 26
  // Incoming fire warning
  if game.incoming_warning && flash_on {
    @raylib.draw_rectangle(
      warn_x,
      warn_y,
      100,
      22,
      @raylib.Color::new(255, 50, 50, 200),
    )
    @raylib.draw_text(
      "INCOMING!",
      warn_x + 5,
      warn_y + 3,
      14,
      @raylib.Color::new(255, 255, 200, 255),
    )
  }
  // Weapon and ammo display (right side)
  let weapon_x = @types.screen_width - 150
  let weapon_y = 60
  @raylib.draw_rectangle(
    weapon_x,
    weapon_y,
    130,
    60,
    @raylib.Color::new(0, 0, 0, 140),
  )
  let wep_name = @types.weapon_name(game.player.current_weapon)
  @raylib.draw_text(
    "WPN: " + wep_name,
    weapon_x + 8,
    weapon_y + 5,
    16,
    @raylib.Color::new(200, 220, 255, 255),
  )
  let ammo = @types.get_ammo(game.player)
  let ammo_text = "Ammo: \{ammo}"
  let ammo_color = if ammo <= 0 {
    @raylib.Color::new(255, 50, 50, 255)
  } else if ammo < 50 {
    @raylib.Color::new(255, 200, 50, 255)
  } else {
    @raylib.Color::new(100, 255, 100, 255)
  }
  @raylib.draw_text(ammo_text, weapon_x + 8, weapon_y + 28, 16, ammo_color)
  // Camera mode
  let cam_text = if game.camera_mode == @types.camera_mode_chase {
    "CAM: Chase"
  } else if game.camera_mode == @types.camera_mode_cockpit {
    "CAM: Cockpit"
  } else {
    "CAM: Free"
  }
  @raylib.draw_text(
    cam_text,
    weapon_x + 8,
    weapon_y + 46,
    12,
    @raylib.Color::new(150, 150, 170, 200),
  )
}
