///|
fn draw_center_text(
  text : String,
  y : Int,
  size : Int,
  color : @raylib.Color,
) -> Unit {
  let tw = @raylib.measure_text(text, size)
  @raylib.draw_text(text, screen_w / 2 - tw / 2, y, size, color)
}

///|
fn alpha_col(c : @raylib.Color, alpha : Int) -> @raylib.Color {
  @raylib.Color::new(
    c.r.to_int(),
    c.g.to_int(),
    c.b.to_int(),
    clampi(alpha, 0, 255),
  )
}

///|
fn room_fill_color(room : Int) -> @raylib.Color {
  if room == 0 {
    @raylib.Color::new(64, 34, 24, 255)
  } else if room == 1 {
    @raylib.Color::new(28, 44, 62, 255)
  } else {
    @raylib.Color::new(36, 30, 64, 255)
  }
}

///|
fn draw_background(game : Game) -> Unit {
  let pulse : Float = 0.5 +
    0.5 * Float::from_int((game.time_s * 60.0).to_int() % 120) / 120.0
  let top = @raylib.Color::new(10, 16, 24 + (pulse * 18.0).to_int(), 255)
  let bottom = @raylib.Color::new(30, 14, 18, 255)

  @raylib.draw_rectangle_gradient_v(0, 0, screen_w, screen_h, top, bottom)

  for i in 0..<120 {
    let x = (i * 97 + i * i * 23) % screen_w
    let y = (i * 41 + i * 17) % screen_h
    let tw = (i * 37 + (game.time_s * 120.0).to_int()) % 100
    let alpha = 40 + tw
    @raylib.draw_circle(
      x,
      y,
      1.0 + Float::from_int(tw % 5) * 0.35,
      @raylib.Color::new(180, 210, 230, alpha),
    )
  }
}

///|
fn draw_chamber_shell(game : Game) -> Unit {
  let x = chamber_left.to_int()
  let y = chamber_top.to_int()
  let w = chamber_w.to_int()
  let h = chamber_h.to_int()

  @raylib.draw_rectangle(
    x,
    y,
    w,
    h,
    alpha_col(room_fill_color(game.keeper.room), 210),
  )
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(178, 202, 222, 220),
  )

  let door_y = (door_center_y - door_half_h).to_int()
  let door_h = (door_half_h * 2.0).to_int()

  if game.keeper.room > 0 {
    @raylib.draw_rectangle(
      x - 2,
      door_y,
      10,
      door_h,
      @raylib.Color::new(76, 148, 184, 180),
    )
    @raylib.draw_text(
      "<",
      x + 10,
      door_y + door_h / 2 - 12,
      28,
      @raylib.Color::new(210, 236, 252, 255),
    )
  }

  if game.keeper.room < chamber_count - 1 {
    @raylib.draw_rectangle(
      x + w - 8,
      door_y,
      10,
      door_h,
      @raylib.Color::new(76, 148, 184, 180),
    )
    @raylib.draw_text(
      ">",
      x + w - 30,
      door_y + door_h / 2 - 12,
      28,
      @raylib.Color::new(210, 236, 252, 255),
    )
  }

  @raylib.draw_text(
    room_name(game.keeper.room),
    x + 20,
    y + 14,
    26,
    @raylib.Color::new(236, 244, 250, 235),
  )
}

///|
fn draw_vault_core(game : Game) -> Unit {
  if game.keeper.room != vault_room {
    return
  }

  let pulse : Float = 6.0 +
    Float::from_int((game.time_s * 100.0).to_int() % 100) / 20.0
  let x = vault_core_x().to_int()
  let y = vault_core_y().to_int()

  @raylib.draw_circle(x, y, 42.0 + pulse, @raylib.Color::new(56, 90, 132, 70))
  @raylib.draw_circle(x, y, 34.0, @raylib.Color::new(82, 162, 206, 220))
  @raylib.draw_circle_lines(
    x,
    y,
    52.0 + pulse,
    @raylib.Color::new(184, 226, 246, 190),
  )
  @raylib.draw_text(
    "Dragon Scroll",
    x - 70,
    y - 10,
    20,
    @raylib.Color::new(238, 248, 255, 235),
  )
}

///|
fn draw_breaches(game : Game) -> Unit {
  for i in 0..<game.breaches.length() {
    if game.breaches[i].room != game.keeper.room {
      continue
    }

    let x = breach_anchor_x(game.breaches[i].room)
    let y = breach_anchor_y(game.breaches[i].room)
    let severity = game.breaches[i].severity
    let ratio = clamp01(severity / breach_severity_max)

    if severity > 0.0 {
      let radius : Float = 16.0 + ratio * 28.0
      @raylib.draw_circle(
        x.to_int(),
        y.to_int(),
        radius,
        @raylib.Color::new(186 + (ratio * 68.0).to_int(), 64, 44, 165),
      )
      @raylib.draw_circle_lines(
        x.to_int(),
        y.to_int(),
        radius + 8.0,
        @raylib.Color::new(246, 158, 110, 220),
      )
      @raylib.draw_text(
        "Breach " + severity.to_int().to_string() + "%",
        x.to_int() - 50,
        y.to_int() - 40,
        18,
        @raylib.Color::new(250, 214, 198, 220),
      )
    } else {
      @raylib.draw_circle_lines(
        x.to_int(),
        y.to_int(),
        18.0,
        @raylib.Color::new(128, 206, 166, 190),
      )
      @raylib.draw_text(
        "sealed",
        x.to_int() - 26,
        y.to_int() - 8,
        14,
        @raylib.Color::new(162, 226, 194, 215),
      )
    }
  }
}

///|
fn draw_flames(game : Game) -> Unit {
  for i in 0..<game.flames.length() {
    if not(game.flames[i].active) || game.flames[i].room != game.keeper.room {
      continue
    }

    let heat = clamp01(game.flames[i].intensity / 100.0)
    @raylib.draw_circle(
      game.flames[i].x.to_int(),
      game.flames[i].y.to_int(),
      8.0 + heat * 20.0,
      @raylib.Color::new(255, 108 + (heat * 86.0).to_int(), 40, 190),
    )
    @raylib.draw_circle(
      game.flames[i].x.to_int(),
      game.flames[i].y.to_int(),
      4.0 + heat * 12.0,
      @raylib.Color::new(255, 198 + (heat * 50.0).to_int(), 90, 220),
    )
  }
}

///|
fn draw_raiders(game : Game) -> Unit {
  for i in 0..<game.raiders.length() {
    if not(game.raiders[i].active) || game.raiders[i].room != game.keeper.room {
      continue
    }

    let panic_alpha = if game.raiders[i].panic_t > 0.0 { 220 } else { 176 }
    @raylib.draw_circle(
      game.raiders[i].x.to_int(),
      game.raiders[i].y.to_int(),
      raider_radius,
      @raylib.Color::new(212, 72, 86, panic_alpha),
    )
    @raylib.draw_circle_lines(
      game.raiders[i].x.to_int(),
      game.raiders[i].y.to_int(),
      raider_radius + 3.0,
      @raylib.Color::new(252, 162, 174, 210),
    )

    let ratio = clamp01(game.raiders[i].hp / game.raiders[i].max_hp)
    let bx = game.raiders[i].x.to_int() - 20
    let by = game.raiders[i].y.to_int() - 24
    @raylib.draw_rectangle(bx, by, 40, 4, @raylib.Color::new(28, 18, 24, 220))
    @raylib.draw_rectangle(
      bx,
      by,
      (ratio * 40.0).to_int(),
      4,
      @raylib.Color::new(244, 112, 124, 235),
    )
  }
}

///|
fn draw_keeper(game : Game) -> Unit {
  let x = game.keeper.x.to_int()
  let y = game.keeper.y.to_int()

  let keeper_col = if game.keeper.extinguisher_mode {
    @raylib.Color::new(98, 216, 198, 255)
  } else {
    @raylib.Color::new(126, 198, 255, 255)
  }

  @raylib.draw_circle(x, y, keeper_radius, keeper_col)
  @raylib.draw_circle_lines(
    x,
    y,
    keeper_radius + 3.0,
    @raylib.Color::new(238, 248, 255, 230),
  )

  let facing_len : Float = 26.0
  @raylib.draw_line(
    x,
    y,
    (game.keeper.x + game.keeper.facing_x * facing_len).to_int(),
    (game.keeper.y + game.keeper.facing_y * facing_len).to_int(),
    @raylib.Color::new(240, 250, 255, 240),
  )

  if game.keeper.extinguisher_mode {
    @raylib.draw_circle_lines(
      x,
      y,
      extinguisher_range,
      @raylib.Color::new(120, 240, 210, 72),
    )
  }

  if game.keeper.shield_t > 0.0 {
    let shield_ratio = clamp01(game.keeper.shield_t / ink_shield_duration)
    @raylib.draw_circle_lines(
      x,
      y,
      ink_shield_radius * (0.85 + 0.2 * shield_ratio),
      @raylib.Color::new(
        136,
        210,
        246,
        (Float::from_int(180) + shield_ratio * 70.0).to_int(),
      ),
    )
  }
}

///|
fn count_raiders_in_room(game : Game, room : Int) -> Int {
  let mut count = 0
  for i in 0..<game.raiders.length() {
    if game.raiders[i].active && game.raiders[i].room == room {
      count = count + 1
    }
  }
  count
}

///|
fn count_flames_in_room(game : Game, room : Int) -> Int {
  let mut count = 0
  for i in 0..<game.flames.length() {
    if game.flames[i].active && game.flames[i].room == room {
      count = count + 1
    }
  }
  count
}

///|
fn draw_room_minimap(game : Game) -> Unit {
  let panel_x = 24
  let panel_y = 20
  let panel_w = 420
  let panel_h = 96

  @raylib.draw_rectangle(
    panel_x,
    panel_y,
    panel_w,
    panel_h,
    @raylib.Color::new(6, 12, 20, 178),
  )
  @raylib.draw_rectangle_lines(
    panel_x,
    panel_y,
    panel_w,
    panel_h,
    @raylib.Color::new(116, 144, 172, 185),
  )

  for room in 0..<chamber_count {
    let x = panel_x + 16 + room * 132
    let y = panel_y + 16
    let w = 120
    let h = 62

    @raylib.draw_rectangle(
      x,
      y,
      w,
      h,
      alpha_col(
        room_fill_color(room),
        if game.keeper.room == room {
          230
        } else {
          170
        },
      ),
    )
    @raylib.draw_rectangle_lines(
      x,
      y,
      w,
      h,
      if game.keeper.room == room {
        @raylib.Color::new(232, 244, 255, 240)
      } else {
        @raylib.Color::new(124, 146, 168, 210)
      },
    )

    let breach_ratio = clamp01(
      game.breaches[room].severity / breach_severity_max,
    )
    @raylib.draw_rectangle(
      x + 8,
      y + 38,
      104,
      10,
      @raylib.Color::new(24, 18, 20, 220),
    )
    @raylib.draw_rectangle(
      x + 8,
      y + 38,
      (Float::from_int(104) * breach_ratio).to_int(),
      10,
      @raylib.Color::new(238, 128, 92, 240),
    )

    @raylib.draw_text(
      room_name(room),
      x + 8,
      y + 8,
      15,
      @raylib.Color::new(236, 244, 252, 235),
    )
    @raylib.draw_text(
      "R" +
      count_raiders_in_room(game, room).to_string() +
      " F" +
      count_flames_in_room(game, room).to_string(),
      x + 8,
      y + 22,
      13,
      @raylib.Color::new(208, 224, 238, 225),
    )
  }
}

///|
fn draw_meter(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  label : String,
  ratio : Float,
  col : @raylib.Color,
  value_text : String,
) -> Unit {
  let r = clamp01(ratio)
  @raylib.draw_text(
    label,
    x,
    y - 22,
    18,
    @raylib.Color::new(226, 236, 246, 235),
  )
  @raylib.draw_rectangle(x, y, w, h, @raylib.Color::new(18, 26, 36, 220))
  @raylib.draw_rectangle(x, y, (Float::from_int(w) * r).to_int(), h, col)
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(148, 176, 200, 200),
  )
  @raylib.draw_text(
    value_text,
    x + w + 12,
    y + 2,
    16,
    @raylib.Color::new(220, 234, 246, 225),
  )
}

///|
fn draw_hud(game : Game) -> Unit {
  let panel_x = 24
  let panel_y = screen_h - 168
  let panel_w = screen_w - 48
  let panel_h = 144

  @raylib.draw_rectangle(
    panel_x,
    panel_y,
    panel_w,
    panel_h,
    @raylib.Color::new(6, 10, 16, 186),
  )
  @raylib.draw_rectangle_lines(
    panel_x,
    panel_y,
    panel_w,
    panel_h,
    @raylib.Color::new(112, 142, 170, 180),
  )

  draw_meter(
    panel_x + 20,
    panel_y + 34,
    320,
    20,
    "Scroll Integrity",
    game.scroll_integrity / scroll_integrity_max,
    @raylib.Color::new(126, 226, 174, 230),
    game.scroll_integrity.to_int().to_string() + "%",
  )

  draw_meter(
    panel_x + 20,
    panel_y + 86,
    320,
    20,
    "Stamina",
    game.keeper.stamina / keeper_stamina_max,
    @raylib.Color::new(112, 194, 246, 232),
    game.keeper.stamina.to_int().to_string(),
  )

  let shield_ready_ratio : Float = if game.keeper.shield_cd <= 0.0 {
    Float::from_int(1)
  } else {
    Float::from_int(1) - clamp01(game.keeper.shield_cd / ink_shield_cooldown)
  }
  draw_meter(
    panel_x + 410,
    panel_y + 34,
    260,
    20,
    "Ink Shield Cooldown",
    shield_ready_ratio,
    @raylib.Color::new(158, 206, 255, 232),
    game.keeper.shield_cd.to_int().to_string() + "s",
  )

  @raylib.draw_text(
    "Wave " +
    game.wave.to_string() +
    "  Time " +
    maxf(0.0, game.wave_goal_t - game.wave_t).to_int().to_string() +
    "s",
    panel_x + 410,
    panel_y + 82,
    24,
    @raylib.Color::new(246, 214, 136, 236),
  )

  @raylib.draw_text(
    "Seal charges: " + game.seal_charges.to_string(),
    panel_x + 710,
    panel_y + 36,
    22,
    @raylib.Color::new(246, 206, 170, 238),
  )
  @raylib.draw_text(
    "Ink shields: " + game.keeper.ink_shields.to_int().to_string(),
    panel_x + 710,
    panel_y + 64,
    22,
    @raylib.Color::new(192, 228, 255, 238),
  )
  @raylib.draw_text(
    "Score: " +
    game.score.to_string() +
    "  Best: " +
    game.best_score.to_string(),
    panel_x + 710,
    panel_y + 94,
    22,
    @raylib.Color::new(236, 242, 248, 236),
  )

  @raylib.draw_text(
    if game.keeper.extinguisher_mode {
      "Mode: Extinguisher"
    } else {
      "Mode: Combat/Seal"
    },
    panel_x + panel_w - 286,
    panel_y + 118,
    18,
    @raylib.Color::new(196, 218, 242, 236),
  )

  @raylib.draw_text(
    "WASD move  J action/seal  K mode/cancel  Space shield  P pause  R restart",
    panel_x + 20,
    panel_y + 118,
    18,
    @raylib.Color::new(198, 220, 242, 220),
  )
}

///|
fn draw_message(game : Game) -> Unit {
  if game.message_t <= 0.0 {
    return
  }

  let alpha = clampi(
    (Float::from_int(80) + game.message_t * 180.0).to_int(),
    70,
    230,
  )
  let y = screen_h - 206

  @raylib.draw_rectangle(
    24,
    y,
    screen_w - 48,
    28,
    @raylib.Color::new(12, 20, 30, alpha),
  )
  @raylib.draw_text(
    game.message,
    36,
    y + 6,
    18,
    @raylib.Color::new(232, 242, 250, 235),
  )
}

///|
fn draw_title_overlay() -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(6, 10, 16, 132),
  )

  draw_center_text(
    "DRAGON SCROLL KEEPER 2026",
    176,
    58,
    @raylib.Color::new(242, 226, 188, 248),
  )
  draw_center_text(
    "Protect the vault chambers from raiders and fire.",
    256,
    30,
    @raylib.Color::new(220, 236, 246, 236),
  )
  draw_center_text(
    "Move room-to-room, seal breaches, extinguish flames, preserve scroll integrity.",
    294,
    26,
    @raylib.Color::new(212, 230, 244, 228),
  )

  draw_center_text(
    "J start  |  WASD/Arrows move  |  J attack/seal  |  K extinguisher mode",
    370,
    24,
    @raylib.Color::new(236, 244, 250, 234),
  )
  draw_center_text(
    "Space ink shield burst  |  P pause  |  R restart",
    404,
    24,
    @raylib.Color::new(236, 244, 250, 234),
  )
}

///|
fn draw_paused_overlay() -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(4, 8, 14, 158),
  )
  draw_center_text("PAUSED", 284, 76, @raylib.Color::new(238, 248, 255, 248))
  draw_center_text(
    "P resume  |  K title  |  R restart",
    370,
    30,
    @raylib.Color::new(204, 224, 244, 236),
  )
}

///|
fn draw_game_over_overlay(game : Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(18, 8, 10, 166),
  )
  draw_center_text(
    "ARCHIVE LOST",
    250,
    82,
    @raylib.Color::new(255, 188, 182, 252),
  )
  draw_center_text(
    "Wave " +
    game.wave.to_string() +
    "  Score " +
    game.score.to_string() +
    "  Best " +
    game.best_score.to_string(),
    344,
    32,
    @raylib.Color::new(248, 224, 190, 244),
  )
  draw_center_text(
    "Raiders defeated " +
    game.raiders_defeated.to_string() +
    "  Flames cleared " +
    game.flames_cleared.to_string() +
    "  Seals " +
    game.seals_done.to_string(),
    388,
    28,
    @raylib.Color::new(232, 236, 248, 236),
  )
  draw_center_text(
    "J or R restart  |  K title",
    440,
    28,
    @raylib.Color::new(230, 238, 246, 232),
  )
}

///|
fn draw_frame(game : Game) -> Unit {
  draw_background(game)
  draw_chamber_shell(game)
  draw_vault_core(game)
  draw_breaches(game)
  draw_flames(game)
  draw_raiders(game)
  draw_keeper(game)

  draw_room_minimap(game)
  draw_hud(game)
  draw_message(game)

  if game.state == state_title {
    draw_title_overlay()
  } else if game.state == state_paused {
    draw_paused_overlay()
  } else if game.state == state_game_over {
    draw_game_over_overlay(game)
  }
}
