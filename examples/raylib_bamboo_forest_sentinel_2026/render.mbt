///|
fn draw_centered(
  text : String,
  y : Int,
  size : Int,
  color : @raylib.Color,
) -> Unit {
  let width = @raylib.measure_text(text, size)
  @raylib.draw_text(text, screen_w / 2 - width / 2, y, size, color)
}

///|
fn draw_meter(
  label : String,
  x : Int,
  y : Int,
  w : Int,
  ratio : Float,
  fill : @raylib.Color,
) -> Unit {
  let clamped = clampf(ratio, 0.0, 1.0)

  @raylib.draw_text(label, x, y, 22, @raylib.Color::new(225, 238, 220, 248))
  @raylib.draw_rectangle(x, y + 28, w, 24, @raylib.Color::new(36, 46, 35, 240))
  @raylib.draw_rectangle(
    x + 2,
    y + 30,
    (Float::from_int(w - 4) * clamped).to_int(),
    20,
    fill,
  )
  @raylib.draw_rectangle_lines(
    x,
    y + 28,
    w,
    24,
    @raylib.Color::new(120, 166, 120, 220),
  )
}

///|
fn draw_forest_background(game : Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(9, 24, 14, 255))

  for i in 0..<34 {
    let sway = sinf(game.elapsed * 1.7 + Float::from_int(i) * 0.62) * 8.0
    let x = world_x - 70 + i * 34 + sway.to_int()
    let w = 16 + i * 5 % 11
    @raylib.draw_rectangle(
      x,
      world_y - 40,
      w,
      world_h + 120,
      @raylib.Color::new(22 + i * 3 % 18, 58 + i * 7 % 38, 28 + i * 2 % 16, 120),
    )
  }

  for i in 0..<12 {
    let stripe_h = 44 + i * 13 % 40
    @raylib.draw_rectangle(
      0,
      i * 78,
      screen_w,
      stripe_h,
      @raylib.Color::new(6 + i, 20 + i * 2, 10 + i, 26),
    )
  }
}

///|
fn draw_corridors() -> Unit {
  @raylib.draw_rectangle(
    world_x,
    world_y,
    world_w,
    world_h,
    @raylib.Color::new(13, 30, 17, 238),
  )

  for lane in 0..<corridor_lanes {
    let y = lane_y(lane).to_int() - 58
    @raylib.draw_rectangle(
      world_x + 10,
      y,
      world_w - 20,
      116,
      @raylib.Color::new(34, 56, 36, 235),
    )
    @raylib.draw_rectangle_lines(
      world_x + 10,
      y,
      world_w - 20,
      116,
      @raylib.Color::new(74, 112, 72, 180),
    )
  }

  @raylib.draw_rectangle(
    world_x + 640,
    world_y + 24,
    300,
    world_h - 48,
    @raylib.Color::new(40, 66, 38, 170),
  )

  @raylib.draw_rectangle_lines(
    world_x,
    world_y,
    world_w,
    world_h,
    @raylib.Color::new(136, 188, 130, 220),
  )
}

///|
fn draw_beacons(game : Game) -> Unit {
  for i in 0..<game.beacons.length() {
    let ratio = clampf(
      game.beacons[i].integrity / beacon_integrity_max,
      0.0,
      1.0,
    )
    let pulse = game.beacons[i].pulse_t

    if pulse > 0.0 {
      let pulse_r = beacon_radius + 24.0 + pulse * 55.0
      @raylib.draw_circle(
        game.beacons[i].x.to_int(),
        game.beacons[i].y.to_int(),
        pulse_r,
        @raylib.Color::new(220, 96, 76, 64),
      )
    }

    let body_color = if ratio > 0.65 {
      @raylib.Color::new(90, 218, 150, 238)
    } else if ratio > 0.35 {
      @raylib.Color::new(238, 184, 86, 238)
    } else {
      @raylib.Color::new(218, 88, 82, 238)
    }

    @raylib.draw_circle(
      game.beacons[i].x.to_int(),
      game.beacons[i].y.to_int(),
      beacon_radius,
      body_color,
    )
    @raylib.draw_circle_lines(
      game.beacons[i].x.to_int(),
      game.beacons[i].y.to_int(),
      beacon_radius + 3.0,
      @raylib.Color::new(238, 248, 214, 250),
    )

    let bar_x = game.beacons[i].x.to_int() - 42
    let bar_y = game.beacons[i].y.to_int() - 46
    @raylib.draw_rectangle(
      bar_x,
      bar_y,
      84,
      9,
      @raylib.Color::new(30, 40, 28, 240),
    )
    @raylib.draw_rectangle(
      bar_x + 1,
      bar_y + 1,
      (Float::from_int(82) * ratio).to_int(),
      7,
      @raylib.Color::new(146, 226, 130, 238),
    )

    @raylib.draw_text(
      "B\{i + 1}",
      game.beacons[i].x.to_int() - 9,
      game.beacons[i].y.to_int() - 8,
      20,
      @raylib.Color::new(16, 30, 14, 255),
    )
  }
}

///|
fn draw_traps(game : Game) -> Unit {
  for i in 0..<game.traps.length() {
    @raylib.draw_circle_lines(
      game.traps[i].x.to_int(),
      game.traps[i].y.to_int(),
      20.0,
      @raylib.Color::new(70, 108, 72, 140),
    )

    if not(game.traps[i].active) {
      continue
    }

    @raylib.draw_circle(
      game.traps[i].x.to_int(),
      game.traps[i].y.to_int(),
      13.0,
      @raylib.Color::new(92, 188, 116, 222),
    )

    @raylib.draw_circle_lines(
      game.traps[i].x.to_int(),
      game.traps[i].y.to_int(),
      trap_trigger_radius,
      @raylib.Color::new(122, 216, 132, 70),
    )

    if game.traps[i].trigger_cd > 0.0 {
      let ratio = clampf(game.traps[i].trigger_cd / trap_rearm_time, 0.0, 1.0)
      @raylib.draw_circle_lines(
        game.traps[i].x.to_int(),
        game.traps[i].y.to_int(),
        24.0 + ratio * 12.0,
        @raylib.Color::new(248, 196, 90, 180),
      )
    }

    if game.traps[i].flash_t > 0.0 {
      @raylib.draw_circle(
        game.traps[i].x.to_int(),
        game.traps[i].y.to_int(),
        28.0 + game.traps[i].flash_t * 38.0,
        @raylib.Color::new(186, 248, 176, 72),
      )
    }
  }
}

///|
fn draw_enemies(game : Game) -> Unit {
  for i in 0..<game.enemies.length() {
    if not(game.enemies[i].active) {
      continue
    }

    let radius = enemy_hit_radius(game.enemies[i].kind)
    let base_color = match game.enemies[i].kind {
      1 => @raylib.Color::new(214, 164, 82, 236)
      2 => @raylib.Color::new(186, 88, 74, 236)
      _ => @raylib.Color::new(174, 208, 102, 236)
    }

    @raylib.draw_circle(
      game.enemies[i].x.to_int(),
      game.enemies[i].y.to_int(),
      radius,
      base_color,
    )

    if game.enemies[i].slow_t > 0.0 {
      @raylib.draw_circle_lines(
        game.enemies[i].x.to_int(),
        game.enemies[i].y.to_int(),
        radius + 4.0,
        @raylib.Color::new(110, 220, 238, 220),
      )
    }

    @raylib.draw_circle_lines(
      game.enemies[i].x.to_int(),
      game.enemies[i].y.to_int(),
      radius + 2.0,
      @raylib.Color::new(28, 32, 22, 240),
    )

    let hp_ratio = clampf(
      game.enemies[i].hp / maxf(game.enemies[i].max_hp, 1.0),
      0.0,
      1.0,
    )
    let bar_x = game.enemies[i].x.to_int() - 18
    let bar_y = game.enemies[i].y.to_int() - radius.to_int() - 14
    @raylib.draw_rectangle(
      bar_x,
      bar_y,
      36,
      6,
      @raylib.Color::new(26, 30, 20, 230),
    )
    @raylib.draw_rectangle(
      bar_x + 1,
      bar_y + 1,
      (Float::from_int(34) * hp_ratio).to_int(),
      4,
      @raylib.Color::new(228, 114, 94, 238),
    )
  }
}

///|
fn draw_player(game : Game) -> Unit {
  if game.player.dash_t > 0.0 {
    @raylib.draw_circle(
      game.player.x.to_int(),
      game.player.y.to_int(),
      player_radius + 18.0,
      @raylib.Color::new(128, 204, 236, 86),
    )
  }

  if game.sweep_t > 0.0 {
    let ring = sweep_radius *
      (Float::from_int(1) - game.sweep_t / sweep_fx_time) +
      Float::from_int(40)
    @raylib.draw_circle_lines(
      game.player.x.to_int(),
      game.player.y.to_int(),
      ring,
      @raylib.Color::new(196, 250, 255, 210),
    )
  }

  if game.player.attack_t > 0.0 {
    let reach_x = game.player.x + game.player.facing_x * basic_attack_range
    let reach_y = game.player.y + game.player.facing_y * basic_attack_range
    @raylib.draw_line(
      game.player.x.to_int(),
      game.player.y.to_int(),
      reach_x.to_int(),
      reach_y.to_int(),
      @raylib.Color::new(246, 244, 196, 240),
    )
    @raylib.draw_circle(
      reach_x.to_int(),
      reach_y.to_int(),
      8.0,
      @raylib.Color::new(246, 234, 168, 220),
    )
  }

  @raylib.draw_circle(
    game.player.x.to_int(),
    game.player.y.to_int(),
    player_radius,
    @raylib.Color::new(208, 236, 226, 245),
  )
  @raylib.draw_circle_lines(
    game.player.x.to_int(),
    game.player.y.to_int(),
    player_radius + 2.0,
    @raylib.Color::new(22, 40, 32, 250),
  )

  let nose_x = game.player.x + game.player.facing_x * 17.0
  let nose_y = game.player.y + game.player.facing_y * 17.0
  @raylib.draw_circle(
    nose_x.to_int(),
    nose_y.to_int(),
    4.0,
    @raylib.Color::new(24, 52, 46, 250),
  )
}

///|
fn draw_hud(game : Game) -> Unit {
  @raylib.draw_rectangle(
    hud_x,
    hud_y,
    hud_w,
    hud_h,
    @raylib.Color::new(16, 30, 20, 238),
  )
  @raylib.draw_rectangle_lines(
    hud_x,
    hud_y,
    hud_w,
    hud_h,
    @raylib.Color::new(118, 188, 130, 218),
  )

  @raylib.draw_text(
    "BAMBOO FOREST SENTINEL",
    hud_x + 16,
    hud_y + 16,
    28,
    @raylib.Color::new(214, 246, 196, 248),
  )
  @raylib.draw_text(
    "Night \{game.night}  Score \{game.score}",
    hud_x + 18,
    hud_y + 58,
    24,
    @raylib.Color::new(228, 236, 212, 242),
  )
  @raylib.draw_text(
    "Best \{game.best_score}  Kills \{game.kills}",
    hud_x + 18,
    hud_y + 88,
    21,
    @raylib.Color::new(184, 212, 184, 238),
  )

  let energy_ratio = game.energy / energy_max
  let charge_ratio = game.sweep_charge / sweep_charge_max
  let trap_ratio : Float = if trap_place_cooldown <= 0.0 {
    1.0
  } else {
    Float::from_int(1) - game.trap_place_cd / trap_place_cooldown
  }

  draw_meter(
    "Energy",
    hud_x + 18,
    hud_y + 132,
    hud_w - 36,
    energy_ratio,
    @raylib.Color::new(90, 206, 142, 236),
  )
  draw_meter(
    "Sweep Charge",
    hud_x + 18,
    hud_y + 204,
    hud_w - 36,
    charge_ratio,
    @raylib.Color::new(110, 198, 246, 236),
  )
  draw_meter(
    "Trap Cooldown",
    hud_x + 18,
    hud_y + 276,
    hud_w - 36,
    trap_ratio,
    @raylib.Color::new(228, 196, 96, 236),
  )

  let beacon_total = beacon_total_integrity(game)
  let beacon_max = Float::from_int(beacon_count) * beacon_integrity_max
  draw_meter(
    "Beacon Integrity",
    hud_x + 18,
    hud_y + 348,
    hud_w - 36,
    beacon_total / beacon_max,
    @raylib.Color::new(236, 112, 92, 236),
  )

  @raylib.draw_text(
    "Active infiltrators: \{active_enemy_count(game)}",
    hud_x + 18,
    hud_y + 430,
    22,
    @raylib.Color::new(238, 230, 206, 238),
  )
  @raylib.draw_text(
    "Remaining this night: \{maxi(game.spawn_pool, 0)}",
    hud_x + 18,
    hud_y + 458,
    22,
    @raylib.Color::new(238, 230, 206, 238),
  )

  @raylib.draw_text(
    "Controls",
    hud_x + 18,
    hud_y + 520,
    24,
    @raylib.Color::new(214, 246, 196, 248),
  )
  @raylib.draw_text(
    "Move: WASD / Arrows",
    hud_x + 18,
    hud_y + 554,
    20,
    @raylib.Color::new(226, 234, 218, 238),
  )
  @raylib.draw_text(
    "J: Attack or place trap",
    hud_x + 18,
    hud_y + 580,
    20,
    @raylib.Color::new(226, 234, 218, 238),
  )
  @raylib.draw_text(
    "K: Remove nearby trap",
    hud_x + 18,
    hud_y + 606,
    20,
    @raylib.Color::new(226, 234, 218, 238),
  )
  @raylib.draw_text(
    "Space: Dash / full-charge sweep",
    hud_x + 18,
    hud_y + 632,
    20,
    @raylib.Color::new(226, 234, 218, 238),
  )
  @raylib.draw_text(
    "P: Pause    R: Restart",
    hud_x + 18,
    hud_y + 658,
    20,
    @raylib.Color::new(226, 234, 218, 238),
  )
}

///|
fn draw_status_strip(game : Game) -> Unit {
  if game.status_t <= 0.0 {
    return
  }

  let alpha = (clampf(game.status_t / status_default_t, 0.0, 1.0) * 200.0 + 40.0).to_int()
  let text_alpha = clampi(alpha + 20, 0, 255)
  @raylib.draw_rectangle(
    world_x + 20,
    world_y + 14,
    world_w - 40,
    44,
    @raylib.Color::new(18, 40, 30, alpha),
  )
  @raylib.draw_rectangle_lines(
    world_x + 20,
    world_y + 14,
    world_w - 40,
    44,
    @raylib.Color::new(142, 204, 152, alpha),
  )
  draw_centered(
    game.status_text,
    world_y + 24,
    24,
    @raylib.Color::new(238, 246, 224, text_alpha),
  )
}

///|
fn draw_night_banner(game : Game) -> Unit {
  if game.state != state_playing || game.night_banner_t <= 0.0 {
    return
  }

  let alpha = (clampf(game.night_banner_t / night_banner_time, 0.0, 1.0) * 230.0).to_int()
  draw_centered(
    "Night \{game.night}",
    world_y + 84,
    54,
    @raylib.Color::new(248, 246, 202, alpha),
  )
}

///|
fn draw_title_overlay() -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(6, 14, 10, 174),
  )
  draw_centered(
    "Bamboo Forest Sentinel 2026",
    180,
    58,
    @raylib.Color::new(228, 248, 210, 252),
  )
  draw_centered(
    "Protect the shrine beacons through escalating nights.",
    258,
    30,
    @raylib.Color::new(216, 230, 206, 242),
  )
  draw_centered(
    "Use traps and active combat to break infiltrator waves.",
    296,
    30,
    @raylib.Color::new(216, 230, 206, 242),
  )
  draw_centered(
    "Press J / Enter / Space to start",
    382,
    36,
    @raylib.Color::new(248, 236, 162, 252),
  )
}

///|
fn draw_paused_overlay() -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(8, 12, 12, 156),
  )
  draw_centered("PAUSED", 300, 72, @raylib.Color::new(244, 248, 230, 252))
  draw_centered(
    "Press P to resume, R to restart",
    392,
    34,
    @raylib.Color::new(214, 226, 208, 244),
  )
}

///|
fn draw_game_over_overlay(game : Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(22, 8, 8, 186),
  )
  draw_centered("GAME OVER", 264, 74, @raylib.Color::new(252, 188, 174, 252))
  draw_centered(
    game.game_over_reason,
    348,
    30,
    @raylib.Color::new(244, 222, 210, 242),
  )
  draw_centered(
    "Survived nights: \{game.night}",
    402,
    34,
    @raylib.Color::new(232, 242, 218, 244),
  )
  draw_centered(
    "Score \{game.score}  Best \{game.best_score}",
    442,
    34,
    @raylib.Color::new(232, 242, 218, 244),
  )
  draw_centered(
    "Press R / J / Space to restart",
    506,
    34,
    @raylib.Color::new(252, 234, 164, 248),
  )
}

///|
fn draw_frame(game : Game) -> Unit {
  draw_forest_background(game)
  draw_corridors()
  draw_traps(game)
  draw_beacons(game)
  draw_enemies(game)
  draw_player(game)
  draw_hud(game)
  draw_night_banner(game)
  draw_status_strip(game)

  if game.shake_t > 0.0 {
    let alpha = (clampf(game.shake_t / shake_hit_time, 0.0, 1.0) * 100.0).to_int()
    @raylib.draw_rectangle(
      0,
      0,
      screen_w,
      screen_h,
      @raylib.Color::new(166, 38, 34, alpha),
    )
  }

  if game.state == state_title {
    draw_title_overlay()
  } else if game.state == state_paused {
    draw_paused_overlay()
  } else if game.state == state_game_over {
    draw_game_over_overlay(game)
  }
}
