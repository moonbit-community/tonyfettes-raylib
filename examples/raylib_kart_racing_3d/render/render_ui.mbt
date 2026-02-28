// Get item name for display
fn get_item_display_name(item_type : Int) -> String {
  if item_type == @types.powerup_boost {
    "BOOST"
  } else if item_type == @types.powerup_shield {
    "SHIELD"
  } else if item_type == @types.powerup_missile {
    "MISSILE"
  } else if item_type == @types.powerup_oil_slick {
    "OIL SLICK"
  } else if item_type == @types.powerup_lightning {
    "LIGHTNING"
  } else if item_type == @types.powerup_star {
    "STAR"
  } else if item_type == @types.powerup_banana {
    "BANANA"
  } else if item_type == @types.powerup_triple_mushroom {
    "TRIPLE"
  } else {
    "NONE"
  }
}

// Get item color for display (r, g, b)
fn get_item_display_color(item_type : Int) -> (Int, Int, Int) {
  if item_type == @types.powerup_boost {
    (255, 200, 0)
  } else if item_type == @types.powerup_shield {
    (80, 180, 255)
  } else if item_type == @types.powerup_missile {
    (255, 80, 30)
  } else if item_type == @types.powerup_oil_slick {
    (100, 100, 110)
  } else if item_type == @types.powerup_lightning {
    (255, 255, 100)
  } else if item_type == @types.powerup_star {
    (255, 255, 50)
  } else if item_type == @types.powerup_banana {
    (255, 230, 50)
  } else if item_type == @types.powerup_triple_mushroom {
    (255, 150, 200)
  } else {
    (200, 200, 200)
  }
}

pub fn draw_ui(game : @types.Game) -> Unit {
  if game.state == @types.state_menu {
    draw_menu(game)
  } else if game.state == @types.state_kart_select {
    draw_kart_select_ui(game)
  } else if game.state == @types.state_track_preview {
    draw_track_preview_panel(game)
  } else if game.state == @types.state_countdown {
    draw_hud(game)
    draw_countdown(game)
  } else if game.state == @types.state_racing {
    draw_hud(game)
    draw_lap_times(game)
    draw_item_indicator(game)
    draw_standings_sidebar(game)
  } else if game.state == @types.state_paused {
    draw_hud(game)
    draw_pause_overlay()
  } else if game.state == @types.state_race_complete {
    draw_hud(game)
    draw_race_results(game)
    draw_detailed_race_results(game)
  } else if game.state == @types.state_cup_complete {
    draw_cup_results(game)
  }
}

// Draw kart selection screen
fn draw_kart_select_ui(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0, 0, @types.screen_width, @types.screen_height,
    @raylib.Color::new(15, 20, 45, 255),
  )
  let title = "Select Your Kart"
  let tw = @raylib.measure_text(title, 36)
  @raylib.draw_text(
    title, (@types.screen_width - tw) / 2, 40, 36,
    @raylib.Color::new(255, 255, 255, 255),
  )
  // Kart type selection (horizontal)
  let sel_type = game.selected_kart_type
  let type_y = 120
  for t = 0; t < @types.kart_type_count; t = t + 1 {
    let tx = 60 + t * 115
    let is_sel = t == sel_type
    let bg_color = if is_sel {
      @raylib.Color::new(60, 80, 140, 255)
    } else {
      @raylib.Color::new(30, 35, 60, 255)
    }
    @raylib.draw_rectangle(tx, type_y, 105, 70, bg_color)
    if is_sel {
      @raylib.draw_rectangle_lines(
        tx, type_y, 105, 70, @raylib.Color::new(255, 255, 100, 255),
      )
    }
    let kart_name = @types.kart_type_names[@types.clampi(
      t, 0, @types.kart_type_count - 1,
    )]
    @raylib.draw_text(
      kart_name, tx + 5, type_y + 5, 14,
      @raylib.Color::new(220, 220, 240, 255),
    )
    // Stats display
    let stats = @types.kart_stats[@types.clampi(t, 0, @types.kart_type_count - 1)]
    let spd_bar = (stats.0 / 35.0 * 80.0).to_int()
    let acc_bar = (stats.1 / 25.0 * 80.0).to_int()
    let hdl_bar = (stats.2 / 4.0 * 80.0).to_int()
    @raylib.draw_rectangle(
      tx + 5, type_y + 25, @types.clampi(spd_bar, 0, 80), 6,
      @raylib.Color::new(255, 100, 100, 200),
    )
    @raylib.draw_rectangle(
      tx + 5, type_y + 35, @types.clampi(acc_bar, 0, 80), 6,
      @raylib.Color::new(100, 255, 100, 200),
    )
    @raylib.draw_rectangle(
      tx + 5, type_y + 45, @types.clampi(hdl_bar, 0, 80), 6,
      @raylib.Color::new(100, 100, 255, 200),
    )
    @raylib.draw_text(
      "S", tx + 90, type_y + 22, 10, @raylib.Color::new(255, 100, 100, 200),
    )
    @raylib.draw_text(
      "A", tx + 90, type_y + 32, 10, @raylib.Color::new(100, 255, 100, 200),
    )
    @raylib.draw_text(
      "H", tx + 90, type_y + 42, 10, @raylib.Color::new(100, 100, 255, 200),
    )
  }
  // Character selection (vertical)
  let sel_char = game.selected_character
  let char_y = 220
  @raylib.draw_text(
    "Select Character", 60, char_y, 22,
    @raylib.Color::new(200, 200, 220, 255),
  )
  for c = 0; c < @types.max_karts; c = c + 1 {
    let cy = char_y + 30 + c * 40
    let is_sel_c = c == sel_char
    let ci = @types.clampi(c, 0, @types.kart_colors.length() - 1)
    let kc = @types.kart_colors[ci]
    let bg = if is_sel_c {
      @raylib.Color::new(50, 70, 120, 255)
    } else {
      @raylib.Color::new(25, 30, 50, 255)
    }
    @raylib.draw_rectangle(60, cy, 400, 32, bg)
    if is_sel_c {
      @raylib.draw_rectangle_lines(
        60, cy, 400, 32, @raylib.Color::new(255, 255, 100, 255),
      )
    }
    // Color dot
    @raylib.draw_rectangle(
      70, cy + 8, 16, 16, @raylib.Color::new(kc.0, kc.1, kc.2, 255),
    )
    let char_name = @types.character_names[@types.clampi(
      c, 0, @types.character_names.length() - 1,
    )]
    @raylib.draw_text(
      char_name, 95, cy + 6, 20, @raylib.Color::new(220, 220, 240, 255),
    )
    // Character stat modifiers
    if c < @types.character_stats.length() {
      let cstats = @types.character_stats[c]
      let spd_mod = cstats.0
      let spd_str = if spd_mod > 1.0 {
        "+SPD"
      } else if spd_mod < 1.0 {
        "-SPD"
      } else {
        ""
      }
      let drift_mod = cstats.3
      let drift_str = if drift_mod > 1.0 {
        "+DFT"
      } else if drift_mod < 1.0 {
        "-DFT"
      } else {
        ""
      }
      @raylib.draw_text(
        spd_str, 280, cy + 8, 14, @raylib.Color::new(150, 200, 255, 200),
      )
      @raylib.draw_text(
        drift_str, 340, cy + 8, 14, @raylib.Color::new(255, 200, 150, 200),
      )
    }
  }
  // Selected kart preview summary (right side)
  let preview_x = 520
  let preview_y = 220
  @raylib.draw_rectangle(
    preview_x, preview_y, 440, 350, @raylib.Color::new(20, 25, 50, 200),
  )
  @raylib.draw_rectangle_lines(
    preview_x, preview_y, 440, 350, @raylib.Color::new(80, 80, 120, 200),
  )
  let kart_name_sel = @types.kart_type_names[@types.clampi(
    sel_type, 0, @types.kart_type_count - 1,
  )]
  let char_name_sel = @types.character_names[@types.clampi(
    sel_char, 0, @types.character_names.length() - 1,
  )]
  @raylib.draw_text(
    char_name_sel, preview_x + 20, preview_y + 15, 28,
    @raylib.Color::new(255, 255, 200, 255),
  )
  let kart_label = "Kart: \{kart_name_sel}"
  @raylib.draw_text(
    kart_label, preview_x + 20, preview_y + 50, 20,
    @raylib.Color::new(200, 200, 220, 255),
  )
  // Detailed stats bars
  let stats_sel = @types.kart_stats[@types.clampi(
    sel_type, 0, @types.kart_type_count - 1,
  )]
  let bar_x = preview_x + 20
  let bar_y = preview_y + 90
  let bar_w = 300
  let labels = ["Top Speed", "Acceleration", "Handling", "Weight", "Drift Boost"]
  let vals = [stats_sel.0 / 35.0, stats_sel.1 / 25.0, stats_sel.2 / 4.0, stats_sel.3 / 1.5, stats_sel.4 / 1.5]
  let bar_colors : Array[(Int, Int, Int)] = [
    (255, 100, 100), (100, 255, 100), (100, 100, 255),
    (255, 200, 100), (255, 100, 255),
  ]
  for bi = 0; bi < 5; bi = bi + 1 {
    let by = bar_y + bi * 40
    @raylib.draw_text(
      labels[bi], bar_x, by, 16, @raylib.Color::new(180, 180, 200, 255),
    )
    let fill_w_f : Float = vals[bi] * Float::from_int(bar_w)
    let fill_w = @types.clampi(fill_w_f.to_int(), 0, bar_w)
    let bc = bar_colors[bi]
    @raylib.draw_rectangle(
      bar_x, by + 20, bar_w, 10, @raylib.Color::new(40, 40, 60, 200),
    )
    @raylib.draw_rectangle(
      bar_x, by + 20, fill_w, 10,
      @raylib.Color::new(bc.0, bc.1, bc.2, 220),
    )
  }
  // Controls hint
  let hint = "Left/Right: Kart Type | Up/Down: Character | Enter: Confirm | Esc: Back"
  let hiw = @raylib.measure_text(hint, 14)
  @raylib.draw_text(
    hint, (@types.screen_width - hiw) / 2, @types.screen_height - 40, 14,
    @raylib.Color::new(120, 120, 140, 255),
  )
}

fn draw_menu(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0, 0, @types.screen_width, @types.screen_height,
    @raylib.Color::new(20, 30, 60, 255),
  )
  let title = "KART RACING 3D"
  let tw = @raylib.measure_text(title, 48)
  @raylib.draw_text(
    title, (@types.screen_width - tw) / 2, 100, 48,
    @raylib.Color::new(255, 255, 255, 255),
  )
  let sub = "Choose Your Cup"
  let sw = @raylib.measure_text(sub, 22)
  @raylib.draw_text(
    sub, (@types.screen_width - sw) / 2, 160, 22,
    @raylib.Color::new(200, 200, 220, 255),
  )
  for i = 0; i < @types.cups_count; i = i + 1 {
    let y = 250 + i * 55
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
    let cup_name = @levels.get_cup_name(i)
    let text = prefix + cup_name
    let ftw = @raylib.measure_text(text, 28)
    @raylib.draw_text(text, (@types.screen_width - ftw) / 2, y, 28, color)
    // Draw races info
    let info = "\{@types.races_per_cup} races"
    let iw = @raylib.measure_text(info, 16)
    @raylib.draw_text(
      info, (@types.screen_width - iw) / 2, y + 30, 16,
      @raylib.Color::new(130, 130, 150, 255),
    )
  }
  let hint = "Up/Down: Select | Enter: Race"
  let hw = @raylib.measure_text(hint, 16)
  @raylib.draw_text(
    hint, (@types.screen_width - hw) / 2, @types.screen_height - 50, 16,
    @raylib.Color::new(120, 120, 140, 255),
  )
}

fn draw_hud(game : @types.Game) -> Unit {
  let kart = game.karts[@types.player_kart]
  // Top bar
  @raylib.draw_rectangle(
    0, 0, @types.screen_width, 40, @raylib.Color::new(0, 0, 0, 150),
  )
  // Track name
  let track_name = @levels.get_track_name(game.current_cup, game.current_race)
  @raylib.draw_text(
    track_name, 10, 10, 20, @raylib.Color::new(200, 220, 255, 255),
  )
  // Position
  let place_text = "P\{kart.place}/\{@types.max_karts}"
  @raylib.draw_text(
    place_text, 300, 10, 22, @raylib.Color::new(255, 255, 100, 255),
  )
  // Lap
  let lap_num = @types.clampi(kart.lap + 1, 1, @types.total_laps)
  let lap_text = "Lap \{lap_num}/\{@types.total_laps}"
  @raylib.draw_text(
    lap_text, 460, 10, 20, @raylib.Color::new(200, 200, 200, 255),
  )
  // Speed
  let speed_int = (kart.speed * 3.6).to_int()
  let speed_text = "\{speed_int} km/h"
  @raylib.draw_text(
    speed_text, 640, 10, 20, @raylib.Color::new(100, 255, 100, 255),
  )
  // Time
  let time_secs = game.race_time.to_int()
  let time_ms = ((game.race_time - Float::from_int(time_secs)) * 100.0).to_int()
  let time_text = "Time: \{time_secs}.\{time_ms}"
  @raylib.draw_text(
    time_text, 800, 10, 18, @raylib.Color::new(200, 200, 200, 255),
  )
  // Bottom bar - controls
  @raylib.draw_rectangle(
    0, @types.screen_height - 28, @types.screen_width, 28,
    @raylib.Color::new(0, 0, 0, 100),
  )
  @raylib.draw_text(
    "W: Accel | S: Brake | A/D: Steer | Z/X: Drift | Space: Item | P: Pause",
    10, @types.screen_height - 22, 14,
    @raylib.Color::new(150, 150, 170, 255),
  )
  // Powerup indicator (bottom right)
  if kart.held_powerup != @types.powerup_none {
    let pu_name = if kart.held_powerup == @types.powerup_boost {
      "BOOST"
    } else if kart.held_powerup == @types.powerup_shield {
      "SHIELD"
    } else if kart.held_powerup == @types.powerup_missile {
      "MISSILE"
    } else if kart.held_powerup == @types.powerup_oil_slick {
      "OIL"
    } else if kart.held_powerup == @types.powerup_lightning {
      "BOLT"
    } else if kart.held_powerup == @types.powerup_star {
      "STAR"
    } else if kart.held_powerup == @types.powerup_banana {
      "BANANA"
    } else if kart.held_powerup == @types.powerup_triple_mushroom {
      "x3 BOOST"
    } else {
      "ITEM"
    }
    let pu_color = if kart.held_powerup == @types.powerup_boost {
      @raylib.Color::new(255, 200, 0, 255)
    } else if kart.held_powerup == @types.powerup_shield {
      @raylib.Color::new(80, 180, 255, 255)
    } else if kart.held_powerup == @types.powerup_missile {
      @raylib.Color::new(255, 80, 60, 255)
    } else if kart.held_powerup == @types.powerup_oil_slick {
      @raylib.Color::new(100, 100, 110, 255)
    } else if kart.held_powerup == @types.powerup_lightning {
      @raylib.Color::new(255, 255, 100, 255)
    } else if kart.held_powerup == @types.powerup_star {
      @raylib.Color::new(255, 255, 50, 255)
    } else if kart.held_powerup == @types.powerup_banana {
      @raylib.Color::new(255, 230, 50, 255)
    } else if kart.held_powerup == @types.powerup_triple_mushroom {
      @raylib.Color::new(255, 150, 200, 255)
    } else {
      @raylib.Color::new(200, 200, 200, 255)
    }
    @raylib.draw_rectangle(
      @types.screen_width - 120, @types.screen_height - 70, 110, 35,
      @raylib.Color::new(0, 0, 0, 180),
    )
    @raylib.draw_text(
      pu_name, @types.screen_width - 110, @types.screen_height - 62, 20,
      pu_color,
    )
  }
  // Boost/drift indicator
  if kart.boost_timer > 0.0 {
    let boost_text = "BOOST!"
    let bw = @raylib.measure_text(boost_text, 30)
    @raylib.draw_text(
      boost_text, (@types.screen_width - bw) / 2, @types.screen_height / 2 + 80,
      30, @raylib.Color::new(255, 200, 50, 255),
    )
  }
  if kart.drift_left || kart.drift_right {
    let drift_text = "DRIFT"
    let dw = @raylib.measure_text(drift_text, 24)
    @raylib.draw_text(
      drift_text, (@types.screen_width - dw) / 2, @types.screen_height / 2 + 115,
      24, @raylib.Color::new(255, 150, 50, 200),
    )
  }
  // Minimap (top-right corner)
  draw_minimap(game)
}

fn draw_minimap(game : @types.Game) -> Unit {
  let map_x = @types.screen_width - 160
  let map_y = 50
  let map_size = 140
  @raylib.draw_rectangle(
    map_x, map_y, map_size, map_size, @raylib.Color::new(0, 0, 0, 120),
  )
  @raylib.draw_rectangle_lines(
    map_x, map_y, map_size, map_size, @raylib.Color::new(100, 100, 120, 200),
  )
  let wc = game.waypoint_count
  if wc < 2 { return }
  // Find track bounds
  let mut min_x = game.waypoints[0].x
  let mut max_x = game.waypoints[0].x
  let mut min_z = game.waypoints[0].z
  let mut max_z = game.waypoints[0].z
  for i = 1; i < wc; i = i + 1 {
    let wp = game.waypoints[i]
    if wp.x < min_x { min_x = wp.x }
    if wp.x > max_x { max_x = wp.x }
    if wp.z < min_z { min_z = wp.z }
    if wp.z > max_z { max_z = wp.z }
  }
  let range_x = max_x - min_x + 10.0
  let range_z = max_z - min_z + 10.0
  let scale_x = Float::from_int(map_size - 20) / range_x
  let scale_z = Float::from_int(map_size - 20) / range_z
  let scale = @types.minf(scale_x, scale_z)
  // Draw track outline
  for i = 0; i < wc; i = i + 1 {
    let wp0 = game.waypoints[i]
    let wp1 = game.waypoints[(i + 1) % wc]
    let sx0 = map_x + 10 + ((wp0.x - min_x + 5.0) * scale).to_int()
    let sy0 = map_y + 10 + ((wp0.z - min_z + 5.0) * scale).to_int()
    let sx1 = map_x + 10 + ((wp1.x - min_x + 5.0) * scale).to_int()
    let sy1 = map_y + 10 + ((wp1.z - min_z + 5.0) * scale).to_int()
    @raylib.draw_line(sx0, sy0, sx1, sy1, @raylib.Color::new(100, 100, 120, 200))
  }
  // Draw karts
  for i = 0; i < @types.max_karts; i = i + 1 {
    let kart = game.karts[i]
    if not(kart.active) { continue i + 1 }
    let kx = map_x + 10 + ((kart.x - min_x + 5.0) * scale).to_int()
    let ky = map_y + 10 + ((kart.z - min_z + 5.0) * scale).to_int()
    let ci = @types.clampi(i, 0, @types.kart_colors.length() - 1)
    let kc = @types.kart_colors[ci]
    let dot_size = if i == @types.player_kart { 4 } else { 3 }
    @raylib.draw_rectangle(
      kx - dot_size / 2, ky - dot_size / 2, dot_size, dot_size,
      @raylib.Color::new(kc.0, kc.1, kc.2, 255),
    )
  }
}

fn draw_countdown(game : @types.Game) -> Unit {
  let count = game.countdown_timer.to_int() + 1
  let text = if count > 3 { "READY" } else if count <= 0 { "GO!" } else { "\{count}" }
  let size = if count <= 0 { 80 } else { 100 }
  let tw = @raylib.measure_text(text, size)
  let color = if count <= 0 {
    @raylib.Color::new(100, 255, 100, 255)
  } else if count == 1 {
    @raylib.Color::new(255, 80, 80, 255)
  } else if count == 2 {
    @raylib.Color::new(255, 200, 50, 255)
  } else {
    @raylib.Color::new(255, 255, 255, 255)
  }
  @raylib.draw_text(
    text, (@types.screen_width - tw) / 2, @types.screen_height / 2 - 60, size,
    color,
  )
}

fn draw_pause_overlay() -> Unit {
  @raylib.draw_rectangle(
    0, 0, @types.screen_width, @types.screen_height,
    @raylib.Color::new(0, 0, 0, 150),
  )
  let text = "PAUSED"
  let tw = @raylib.measure_text(text, 60)
  @raylib.draw_text(
    text, (@types.screen_width - tw) / 2, @types.screen_height / 2 - 50, 60,
    @raylib.Color::new(255, 255, 255, 255),
  )
  let hint = "P: Resume | Q: Quit to Menu"
  let hw = @raylib.measure_text(hint, 20)
  @raylib.draw_text(
    hint, (@types.screen_width - hw) / 2, @types.screen_height / 2 + 20, 20,
    @raylib.Color::new(200, 200, 220, 255),
  )
}

fn draw_race_results(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0, 0, @types.screen_width, @types.screen_height,
    @raylib.Color::new(0, 0, 0, 180),
  )
  let title = "RACE COMPLETE!"
  let tw = @raylib.measure_text(title, 48)
  @raylib.draw_text(
    title, (@types.screen_width - tw) / 2, 100, 48,
    @raylib.Color::new(100, 255, 100, 255),
  )
  let track_name = @levels.get_track_name(game.current_cup, game.current_race)
  let tnw = @raylib.measure_text(track_name, 22)
  @raylib.draw_text(
    track_name, (@types.screen_width - tnw) / 2, 155, 22,
    @raylib.Color::new(200, 200, 220, 255),
  )
  // Results table
  for i = 0; i < @types.max_karts; i = i + 1 {
    let kart = game.karts[i]
    if not(kart.active) { continue i + 1 }
    let y = 200 + (kart.place - 1) * 32
    let is_player = i == @types.player_kart
    let color = if is_player {
      @raylib.Color::new(255, 255, 100, 255)
    } else {
      @raylib.Color::new(200, 200, 200, 255)
    }
    let ci = @types.clampi(i, 0, @types.kart_colors.length() - 1)
    let kc = @types.kart_colors[ci]
    // Color dot
    @raylib.draw_rectangle(
      200, y + 4, 16, 16, @raylib.Color::new(kc.0, kc.1, kc.2, 255),
    )
    // Position and name
    let prefix = if is_player { "YOU" } else { "AI \{i}" }
    let place_text = "\{kart.place}. \{prefix}"
    @raylib.draw_text(place_text, 230, y, 22, color)
    // Points earned
    let pts = @types.position_points(kart.place)
    let pts_text = "+\{pts} pts"
    @raylib.draw_text(
      pts_text, 500, y, 20, @raylib.Color::new(150, 200, 255, 255),
    )
    // Time
    let t = kart.finish_time.to_int()
    let time_text = "\{t}s"
    @raylib.draw_text(
      time_text, 620, y, 18, @raylib.Color::new(180, 180, 180, 255),
    )
  }
  let hint = "Enter: Next Race"
  let hw = @raylib.measure_text(hint, 18)
  @raylib.draw_text(
    hint, (@types.screen_width - hw) / 2, @types.screen_height - 60, 18,
    @raylib.Color::new(150, 150, 170, 255),
  )
}

fn draw_cup_results(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0, 0, @types.screen_width, @types.screen_height,
    @raylib.Color::new(10, 20, 40, 255),
  )
  let cup_name = @levels.get_cup_name(game.current_cup)
  let title = cup_name + " COMPLETE!"
  let tw = @raylib.measure_text(title, 40)
  @raylib.draw_text(
    title, (@types.screen_width - tw) / 2, 80, 40,
    @raylib.Color::new(255, 215, 0, 255),
  )
  // Show final standings
  let header = "Final Standings"
  let hw = @raylib.measure_text(header, 24)
  @raylib.draw_text(
    header, (@types.screen_width - hw) / 2, 140, 24,
    @raylib.Color::new(200, 200, 220, 255),
  )
  // Sort by cup points descending
  let order : Array[Int] = Array::make(@types.max_karts, 0)
  for i = 0; i < @types.max_karts; i = i + 1 { order[i] = i }
  for i = 0; i < @types.max_karts - 1; i = i + 1 {
    for j = 0; j < @types.max_karts - 1 - i; j = j + 1 {
      if game.cup_points[order[j]] < game.cup_points[order[j + 1]] {
        let tmp = order[j]
        order[j] = order[j + 1]
        order[j + 1] = tmp
      }
    }
  }
  for i = 0; i < @types.max_karts; i = i + 1 {
    let ki = order[i]
    let y = 190 + i * 35
    let is_player = ki == @types.player_kart
    let color = if is_player {
      @raylib.Color::new(255, 255, 100, 255)
    } else {
      @raylib.Color::new(200, 200, 200, 255)
    }
    let ci = @types.clampi(ki, 0, @types.kart_colors.length() - 1)
    let kc = @types.kart_colors[ci]
    @raylib.draw_rectangle(
      240, y + 4, 14, 14, @raylib.Color::new(kc.0, kc.1, kc.2, 255),
    )
    let name = if is_player { "YOU" } else { "AI \{ki}" }
    @raylib.draw_text(name, 270, y, 22, color)
    let pts = game.cup_points[ki]
    let pts_text = "\{pts} pts"
    @raylib.draw_text(
      pts_text, 500, y, 22, @raylib.Color::new(150, 200, 255, 255),
    )
  }
  let hint = "Enter: Back to Menu"
  let hiw = @raylib.measure_text(hint, 18)
  @raylib.draw_text(
    hint, (@types.screen_width - hiw) / 2, @types.screen_height - 50, 18,
    @raylib.Color::new(120, 120, 140, 255),
  )
}

// Draw best lap time display during racing
pub fn draw_lap_times(game : @types.Game) -> Unit {
  if game.state != @types.state_racing { return }
  let kart = game.karts[@types.player_kart]
  if not(kart.active) { return }
  let base_y = 50
  // Current lap time
  let cur_lap = @types.format_time(game.current_lap_time)
  let cur_text = "Lap: \{cur_lap}"
  @raylib.draw_text(
    cur_text, 10, base_y, 18, @raylib.Color::new(200, 200, 200, 255),
  )
  // Best lap time
  if game.best_lap_time < 900.0 {
    let best_text = "Best: \{@types.format_time(game.best_lap_time)}"
    @raylib.draw_text(
      best_text, 10, base_y + 22, 18, @raylib.Color::new(100, 255, 100, 255),
    )
  }
  // Track record comparison
  let record = @levels.get_track_record_time(game.current_cup, game.current_race)
  if record < 900.0 {
    let rec_text = "Record: \{@types.format_time(record)}"
    @raylib.draw_text(
      rec_text, 10, base_y + 44, 16, @raylib.Color::new(255, 215, 0, 200),
    )
  }
  // Individual lap times display
  if kart.lap_times.length() > 0 {
    let laps_y = base_y + 70
    @raylib.draw_text(
      "Lap Times:", 10, laps_y, 14, @raylib.Color::new(150, 150, 170, 200),
    )
    let display_count = @types.mini(kart.lap_times.length(), 5)
    for li = 0; li < display_count; li = li + 1 {
      let lap_time = kart.lap_times[li]
      let li_display = li + 1
      let lap_str = @types.format_time(lap_time)
      let lap_text = "L\{li_display}: \{lap_str}"
      let lap_color = if lap_time <= game.best_lap_time + 0.01 {
        @raylib.Color::new(100, 255, 100, 200)
      } else {
        @raylib.Color::new(180, 180, 180, 200)
      }
      @raylib.draw_text(lap_text, 10, laps_y + 18 + li * 16, 14, lap_color)
    }
  }
}

// Draw enhanced item indicator with icon and count
pub fn draw_item_indicator(game : @types.Game) -> Unit {
  let kart = game.karts[@types.player_kart]
  if not(kart.active) { return }
  if kart.held_powerup == @types.powerup_none { return }
  let box_x = @types.screen_width - 130
  let box_y = @types.screen_height - 80
  let box_w = 120
  let box_h = 45
  // Background
  @raylib.draw_rectangle(
    box_x, box_y, box_w, box_h, @raylib.Color::new(0, 0, 0, 200),
  )
  @raylib.draw_rectangle_lines(
    box_x, box_y, box_w, box_h, @raylib.Color::new(100, 100, 120, 200),
  )
  // Item name
  let item_name = get_item_display_name(kart.held_powerup)
  let ic = get_item_display_color(kart.held_powerup)
  let item_color = @raylib.Color::new(ic.0, ic.1, ic.2, 255)
  @raylib.draw_text(item_name, box_x + 8, box_y + 5, 16, item_color)
  // Item count for triple mushroom
  if kart.held_powerup == @types.powerup_triple_mushroom && kart.item_count > 0 {
    let count = kart.item_count + 1
    let count_text = "x\{count}"
    @raylib.draw_text(
      count_text, box_x + 8, box_y + 25, 14,
      @raylib.Color::new(200, 200, 200, 255),
    )
  }
  // "SPACE to use" hint
  let hint = "[SPACE]"
  @raylib.draw_text(
    hint, box_x + 60, box_y + 28, 12,
    @raylib.Color::new(120, 120, 140, 200),
  )
  // Color indicator cube
  @raylib.draw_rectangle(
    box_x + box_w - 20, box_y + 5, 12, 12, item_color,
  )
}

// Draw race results with detailed breakdown
pub fn draw_detailed_race_results(game : @types.Game) -> Unit {
  if game.state != @types.state_race_complete { return }
  let player = game.karts[@types.player_kart]
  // Player performance summary
  let summary_y = 480
  @raylib.draw_rectangle(
    180, summary_y, 660, 110, @raylib.Color::new(0, 0, 0, 160),
  )
  @raylib.draw_rectangle_lines(
    180, summary_y, 660, 110, @raylib.Color::new(100, 100, 120, 150),
  )
  let summary_title = "Your Performance"
  let stw = @raylib.measure_text(summary_title, 20)
  @raylib.draw_text(
    summary_title, (@types.screen_width - stw) / 2, summary_y + 8, 20,
    @raylib.Color::new(255, 215, 0, 255),
  )
  // Finish time
  let finish_text = "Finish: \{@types.format_time(player.finish_time)}"
  @raylib.draw_text(
    finish_text, 200, summary_y + 35, 18,
    @raylib.Color::new(200, 200, 200, 255),
  )
  // Best lap
  if player.best_lap < 900.0 {
    let best_text = "Best Lap: \{@types.format_time(player.best_lap)}"
    @raylib.draw_text(
      best_text, 200, summary_y + 57, 18,
      @raylib.Color::new(100, 255, 100, 255),
    )
  }
  // Position result
  let place_ord = @types.ordinal_suffix(player.place)
  let place_result = "Position: \{place_ord}"
  let place_color = if player.place == 1 {
    @raylib.Color::new(255, 215, 0, 255)
  } else if player.place <= 3 {
    @raylib.Color::new(200, 200, 200, 255)
  } else {
    @raylib.Color::new(180, 130, 100, 255)
  }
  @raylib.draw_text(place_result, 500, summary_y + 35, 18, place_color)
  // Points earned
  let pts_earned = @types.position_points(player.place)
  let pts_text = "Points: +\{pts_earned}"
  @raylib.draw_text(
    pts_text, 500, summary_y + 57, 18,
    @raylib.Color::new(150, 200, 255, 255),
  )
  // Cup standing update
  let cup_total = game.cup_points[@types.player_kart]
  let cup_text = "Cup Total: \{cup_total} pts"
  @raylib.draw_text(
    cup_text, 200, summary_y + 82, 16,
    @raylib.Color::new(200, 180, 255, 255),
  )
  // Race progress indicator
  let race_num = game.current_race + 1
  let progress_text = "Race \{race_num} of \{@types.races_per_cup}"
  @raylib.draw_text(
    progress_text, 500, summary_y + 82, 16,
    @raylib.Color::new(150, 150, 170, 255),
  )
}

// Draw track preview info panel
pub fn draw_track_preview_panel(game : @types.Game) -> Unit {
  if game.state != @types.state_track_preview { return }
  @raylib.draw_rectangle(
    0, 0, @types.screen_width, @types.screen_height,
    @raylib.Color::new(10, 15, 30, 240),
  )
  // Track name
  let track_name = @levels.get_track_name(game.current_cup, game.current_race)
  let tw = @raylib.measure_text(track_name, 40)
  @raylib.draw_text(
    track_name, (@types.screen_width - tw) / 2, 60, 40,
    @raylib.Color::new(255, 255, 255, 255),
  )
  // Track description
  let desc = @levels.get_track_description(game.current_cup, game.current_race)
  let dw = @raylib.measure_text(desc, 20)
  @raylib.draw_text(
    desc, (@types.screen_width - dw) / 2, 110, 20,
    @raylib.Color::new(180, 180, 200, 255),
  )
  // Info panel
  let panel_x = 200
  let panel_y = 170
  @raylib.draw_rectangle(
    panel_x, panel_y, 624, 300, @raylib.Color::new(20, 25, 50, 200),
  )
  @raylib.draw_rectangle_lines(
    panel_x, panel_y, 624, 300, @raylib.Color::new(80, 80, 120, 200),
  )
  // Difficulty
  let diff = @levels.get_track_difficulty(game.current_cup, game.current_race)
  let mut star_str = "Difficulty: "
  for s = 0; s < 5; s = s + 1 {
    if s < diff {
      star_str = star_str + "*"
    } else {
      star_str = star_str + "-"
    }
  }
  @raylib.draw_text(
    star_str, panel_x + 20, panel_y + 20, 20,
    @raylib.Color::new(255, 200, 50, 255),
  )
  // Surface info
  let surface_info = @levels.get_track_surface_info(
    game.current_cup, game.current_race,
  )
  let surf_text = "Surface: \{surface_info}"
  @raylib.draw_text(
    surf_text, panel_x + 20, panel_y + 50, 18,
    @raylib.Color::new(180, 180, 200, 255),
  )
  // Elevation
  let elev_info = @levels.get_track_elevation_info(
    game.current_cup, game.current_race,
  )
  let elev_text = "Terrain: \{elev_info}"
  @raylib.draw_text(
    elev_text, panel_x + 20, panel_y + 76, 18,
    @raylib.Color::new(180, 180, 200, 255),
  )
  // Laps
  let laps = @levels.get_track_laps(game.current_cup, game.current_race)
  let laps_text = "Laps: \{laps}"
  @raylib.draw_text(
    laps_text, panel_x + 20, panel_y + 102, 18,
    @raylib.Color::new(180, 180, 200, 255),
  )
  // Track length
  let length = @levels.get_track_length_estimate(
    game.current_cup, game.current_race,
  )
  let len_int = length.to_int()
  let length_text = "Length: ~\{len_int}m"
  @raylib.draw_text(
    length_text, panel_x + 20, panel_y + 128, 18,
    @raylib.Color::new(180, 180, 200, 255),
  )
  // Record time
  let record = @levels.get_track_record_time(game.current_cup, game.current_race)
  let record_holder = @levels.get_track_record_holder(
    game.current_cup, game.current_race,
  )
  if record < 900.0 {
    let rec_str = @types.format_time(record)
    let rec_text = "Record: \{rec_str} by \{record_holder}"
    @raylib.draw_text(
      rec_text, panel_x + 20, panel_y + 160, 18,
      @raylib.Color::new(255, 215, 0, 255),
    )
  }
  // Item boxes
  let item_count = @levels.get_track_item_box_count(
    game.current_cup, game.current_race,
  )
  let items_text = "Item Boxes: \{item_count}"
  @raylib.draw_text(
    items_text, panel_x + 20, panel_y + 190, 18,
    @raylib.Color::new(180, 180, 200, 255),
  )
  // Cup progress
  let cup_name = @levels.get_cup_name(game.current_cup)
  let race_num = game.current_race + 1
  let prog_text = "\{cup_name} - Race \{race_num}/\{@types.races_per_cup}"
  @raylib.draw_text(
    prog_text, panel_x + 20, panel_y + 230, 20,
    @raylib.Color::new(200, 200, 255, 255),
  )
  // Selected kart info
  let kart_name = @types.kart_type_names[@types.clampi(
    game.selected_kart_type, 0, @types.kart_type_count - 1,
  )]
  let char_name = @types.character_names[@types.clampi(
    game.selected_character, 0, @types.max_karts - 1,
  )]
  let kart_info = "Racer: \{char_name} - \{kart_name} Kart"
  @raylib.draw_text(
    kart_info, panel_x + 20, panel_y + 260, 18,
    @raylib.Color::new(255, 255, 200, 255),
  )
  // Hint
  let hint = "Press Enter to Start Race"
  let hiw = @raylib.measure_text(hint, 20)
  let blink = @math.sinf(game.preview_timer * 4.0)
  let hint_alpha_f : Float = 180.0 + blink * 60.0
  let hint_alpha = @types.clampi(hint_alpha_f.to_int(), 120, 240)
  @raylib.draw_text(
    hint, (@types.screen_width - hiw) / 2, @types.screen_height - 60, 20,
    @raylib.Color::new(200, 200, 220, hint_alpha),
  )
}

// Draw position standings sidebar during race
pub fn draw_standings_sidebar(game : @types.Game) -> Unit {
  if game.state != @types.state_racing { return }
  let side_x = @types.screen_width - 155
  let side_y = 200
  let entry_h = 22
  // Background
  @raylib.draw_rectangle(
    side_x, side_y, 145, entry_h * @types.max_karts + 25,
    @raylib.Color::new(0, 0, 0, 100),
  )
  @raylib.draw_text(
    "Standings", side_x + 5, side_y + 3, 14,
    @raylib.Color::new(180, 180, 200, 200),
  )
  // Collect and sort by place
  for p = 1; p <= @types.max_karts; p = p + 1 {
    for i = 0; i < @types.max_karts; i = i + 1 {
      let kart = game.karts[i]
      if not(kart.active) { continue i + 1 }
      if kart.place != p { continue i + 1 }
      let y = side_y + 20 + (p - 1) * entry_h
      let is_player = i == @types.player_kart
      let ci = @types.clampi(i, 0, @types.kart_colors.length() - 1)
      let kc = @types.kart_colors[ci]
      // Color dot
      @raylib.draw_rectangle(
        side_x + 5, y + 3, 10, 10,
        @raylib.Color::new(kc.0, kc.1, kc.2, 255),
      )
      let name = if is_player { "YOU" } else { "AI \{i}" }
      let text_color = if is_player {
        @raylib.Color::new(255, 255, 100, 255)
      } else {
        @raylib.Color::new(180, 180, 180, 200)
      }
      let entry_text = "\{p}. \{name}"
      @raylib.draw_text(entry_text, side_x + 20, y, 14, text_color)
      // Show if finished
      if kart.finished {
        @raylib.draw_text(
          "FIN", side_x + 110, y, 12,
          @raylib.Color::new(100, 255, 100, 200),
        )
      }
    }
  }
}
