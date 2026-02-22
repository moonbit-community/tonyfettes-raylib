///|
fn shake_x(game : Game) -> Int {
  if game.shake_t <= 0.0 {
    0
  } else {
    @raylib.get_random_value(-5, 5)
  }
}

///|
fn shake_y(game : Game) -> Int {
  if game.shake_t <= 0.0 {
    0
  } else {
    @raylib.get_random_value(-4, 4)
  }
}

///|
fn draw_background(game : Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(10, 14, 26, 255))

  let moon_pulse : Float = sinf(game.ui_t * 0.9)

  @raylib.draw_circle(
    1240,
    122,
    108.0 + moon_pulse * 4.0,
    @raylib.Color::new(216, 224, 255, 72),
  )
  @raylib.draw_circle(1240, 122, 72.0, @raylib.Color::new(232, 236, 255, 132))

  for i = 0; i < 20; i = i + 1 {
    let h : Int = 140 + i * 17 % 120
    let w : Int = 28 + i * 29 % 54
    let x : Int = 24 + i * 76
    let y : Int = 310 - h / 3

    @raylib.draw_rectangle(
      x,
      y,
      w,
      h,
      @raylib.Color::new(24 + i % 8, 30 + i % 7, 52 + i % 10, 186),
    )
  }

  for i = 0; i < 36; i = i + 1 {
    let x : Int = i * 43 + 10
    let y : Int = 32 + i * 37 % 140
    @raylib.draw_circle(
      x,
      y,
      Float::from_int(1 + i % 3),
      @raylib.Color::new(220, 230, 255, 112 + i % 90),
    )
  }
}

///|
fn draw_rooftop(ox : Int, oy : Int) -> Unit {
  @raylib.draw_rectangle(
    arena_x + ox,
    arena_y + oy,
    arena_w,
    arena_h,
    @raylib.Color::new(30, 36, 56, 246),
  )

  for i = 0; i < 21; i = i + 1 {
    let y : Int = arena_y + oy + i * 36
    @raylib.draw_line(
      arena_x + 8 + ox,
      y,
      arena_x + arena_w - 8 + ox,
      y,
      @raylib.Color::new(54, 66, 96, 96),
    )
  }

  for i = 0; i < 33; i = i + 1 {
    let x : Int = arena_x + ox + i * 40
    @raylib.draw_line(
      x,
      arena_y + 8 + oy,
      x,
      arena_y + arena_h - 8 + oy,
      @raylib.Color::new(52, 62, 90, 76),
    )
  }

  @raylib.draw_rectangle_lines(
    arena_x + ox,
    arena_y + oy,
    arena_w,
    arena_h,
    @raylib.Color::new(182, 204, 244, 208),
  )

  @raylib.draw_rectangle(
    arena_x - 18 + ox,
    arena_y + 24 + oy,
    14,
    arena_h - 48,
    @raylib.Color::new(66, 74, 108, 220),
  )
  @raylib.draw_rectangle(
    arena_x + arena_w + 4 + ox,
    arena_y + 24 + oy,
    14,
    arena_h - 48,
    @raylib.Color::new(66, 74, 108, 220),
  )
}

///|
fn enemy_color(enemy : Enemy) -> @raylib.Color {
  if enemy.state == enemy_state_strike {
    @raylib.Color::new(236, 112, 128, 242)
  } else if enemy.state == enemy_state_telegraph {
    @raylib.Color::new(244, 200, 126, 242)
  } else if enemy.state == enemy_state_stunned {
    @raylib.Color::new(128, 220, 218, 242)
  } else {
    @raylib.Color::new(188, 202, 232, 236)
  }
}

///|
fn draw_enemy(enemy : Enemy, game : Game, ox : Int, oy : Int) -> Unit {
  if not(enemy.active) {
    return
  }

  let ex : Int = enemy.x.to_int() + ox
  let ey : Int = enemy.y.to_int() + oy
  let body_color : @raylib.Color = enemy_color(enemy)

  @raylib.draw_circle(
    ex,
    ey + 6,
    enemy.radius,
    @raylib.Color::new(10, 12, 22, 130),
  )
  @raylib.draw_circle(ex, ey, enemy.radius, body_color)
  @raylib.draw_circle(
    ex,
    ey,
    enemy.radius - 7.0,
    @raylib.Color::new(36, 42, 64, 200),
  )

  if enemy.state == enemy_state_telegraph {
    let ratio : Float = clampf(
      enemy.state_t / maxf(0.001, enemy.telegraph_total_t),
      0.0,
      1.0,
    )
    let inv_ratio : Float = (1.0 : Float) - ratio

    let alert_alpha : Int = 120 + (inv_ratio * 120.0).to_int()
    let alert_color : @raylib.Color = if enemy.state_t <= enemy_parry_window {
      @raylib.Color::new(255, 102, 122, alert_alpha)
    } else {
      @raylib.Color::new(248, 204, 124, alert_alpha)
    }

    @raylib.draw_circle_lines(ex, ey, enemy.radius + 10.0, alert_color)
    @raylib.draw_line(
      ex,
      ey,
      game.player_x.to_int() + ox,
      game.player_y.to_int() + oy,
      @raylib.Color::new(250, 220, 154, 120),
    )
  }

  if enemy.state == enemy_state_stunned {
    @raylib.draw_line(
      ex - 9,
      ey - 14,
      ex + 9,
      ey - 4,
      @raylib.Color::new(124, 242, 236, 218),
    )
    @raylib.draw_line(
      ex - 9,
      ey - 4,
      ex + 9,
      ey - 14,
      @raylib.Color::new(124, 242, 236, 218),
    )
  }

  let hp_ratio : Float = clampf(enemy.hp / maxf(1.0, enemy.max_hp), 0.0, 1.0)
  let bar_w : Int = 34
  let fill_w : Int = (Float::from_int(bar_w) * hp_ratio).to_int()

  @raylib.draw_rectangle(
    ex - bar_w / 2,
    ey - 30,
    bar_w,
    5,
    @raylib.Color::new(44, 20, 28, 188),
  )
  if fill_w > 0 {
    @raylib.draw_rectangle(
      ex - bar_w / 2,
      ey - 30,
      fill_w,
      5,
      @raylib.Color::new(248, 148, 166, 232),
    )
  }
}

///|
fn draw_player(game : Game, ox : Int, oy : Int) -> Unit {
  let px : Int = game.player_x.to_int() + ox
  let py : Int = game.player_y.to_int() + oy

  let body_color : @raylib.Color = if game.invuln_t > 0.0 {
    @raylib.Color::new(250, 214, 180, 248)
  } else {
    @raylib.Color::new(226, 236, 248, 244)
  }

  @raylib.draw_circle(
    px,
    py + 8,
    player_radius,
    @raylib.Color::new(8, 12, 24, 138),
  )
  @raylib.draw_circle(
    px,
    py,
    player_radius + 2.0,
    @raylib.Color::new(84, 96, 140, 240),
  )
  @raylib.draw_circle(px, py, player_radius - 6.0, body_color)

  let blade_x : Int = (game.player_x + game.facing_x * 30.0).to_int() + ox
  let blade_y : Int = (game.player_y + game.facing_y * 30.0).to_int() + oy
  let blade_tip_x : Int = (game.player_x + game.facing_x * 62.0).to_int() + ox
  let blade_tip_y : Int = (game.player_y + game.facing_y * 62.0).to_int() + oy

  @raylib.draw_line(
    px,
    py,
    blade_x,
    blade_y,
    @raylib.Color::new(138, 162, 210, 240),
  )
  @raylib.draw_line(
    blade_x,
    blade_y,
    blade_tip_x,
    blade_tip_y,
    @raylib.Color::new(230, 242, 255, 246),
  )

  if game.attack_anim_t > 0.0 {
    let attack_reach : Float = if game.attack_kind == attack_heavy {
      heavy_attack_range
    } else {
      light_attack_range
    }

    @raylib.draw_circle_lines(
      (game.player_x + game.facing_x * attack_reach * 0.58).to_int() + ox,
      (game.player_y + game.facing_y * attack_reach * 0.58).to_int() + oy,
      if game.attack_kind == attack_heavy {
        44.0
      } else {
        28.0
      },
      if game.attack_kind == attack_heavy {
        @raylib.Color::new(255, 196, 132, 240)
      } else {
        @raylib.Color::new(164, 222, 255, 236)
      },
    )
  }

  if game.parry_t > 0.0 {
    let pulse : Float = 30.0 + sinf(game.ui_t * 20.0) * 4.0
    @raylib.draw_circle_lines(
      px,
      py,
      pulse,
      @raylib.Color::new(122, 252, 218, 242),
    )
  }
}

///|
fn draw_bar(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  ratio : Float,
  fill : @raylib.Color,
  back : @raylib.Color,
) -> Unit {
  @raylib.draw_rectangle(x, y, w, h, back)

  let clamped : Float = clampf(ratio, 0.0, 1.0)
  let fill_w : Int = (Float::from_int(w) * clamped).to_int()
  if fill_w > 0 {
    @raylib.draw_rectangle(x, y, fill_w, h, fill)
  }

  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(210, 224, 250, 170),
  )
}

///|
fn draw_hud(game : Game) -> Unit {
  @raylib.draw_rectangle(0, 0, screen_w, 76, @raylib.Color::new(8, 10, 18, 180))

  @raylib.draw_text(
    "WUXIA ROOFTOP DUEL 2026",
    20,
    14,
    32,
    @raylib.Color::new(232, 240, 255, 246),
  )

  @raylib.draw_text(
    "Wave " + game.wave.to_string(),
    700,
    22,
    30,
    @raylib.Color::new(246, 222, 166, 240),
  )

  @raylib.draw_text(
    "Score " + game.score.to_string(),
    860,
    22,
    30,
    @raylib.Color::new(218, 236, 252, 236),
  )

  @raylib.draw_text(
    "Best " + game.best_score.to_string(),
    1080,
    22,
    28,
    @raylib.Color::new(178, 212, 244, 226),
  )

  draw_bar(
    20,
    58,
    280,
    12,
    game.health / player_max_health,
    @raylib.Color::new(244, 120, 142, 242),
    @raylib.Color::new(58, 24, 36, 220),
  )

  draw_bar(
    320,
    58,
    280,
    12,
    game.stamina / player_max_stamina,
    @raylib.Color::new(122, 218, 242, 242),
    @raylib.Color::new(20, 42, 58, 220),
  )

  let wave_ratio : Float = if game.wave_enemies_total <= 0 {
    0.0
  } else {
    Float::from_int(game.wave_defeated) /
    Float::from_int(game.wave_enemies_total)
  }

  draw_bar(
    620,
    58,
    260,
    12,
    wave_ratio,
    @raylib.Color::new(254, 212, 130, 242),
    @raylib.Color::new(64, 52, 26, 220),
  )

  @raylib.draw_text("HP", 20, 40, 16, @raylib.Color::new(242, 210, 220, 228))
  @raylib.draw_text(
    "STAMINA",
    320,
    40,
    16,
    @raylib.Color::new(198, 230, 242, 228),
  )
  @raylib.draw_text(
    "WAVE KILLS",
    620,
    40,
    16,
    @raylib.Color::new(242, 228, 178, 228),
  )

  @raylib.draw_text(
    "Combo x" + game.combo.to_string(),
    910,
    52,
    22,
    if game.combo >= 6 {
      @raylib.Color::new(255, 232, 126, 248)
    } else {
      @raylib.Color::new(202, 226, 248, 230)
    },
  )

  @raylib.draw_text(
    "Stage " +
    game.stage_score.to_string() +
    "  Last bonus +" +
    game.last_stage_bonus.to_string(),
    1120,
    52,
    20,
    @raylib.Color::new(232, 214, 170, 222),
  )

  @raylib.draw_text(
    "Move: WASD/Arrows  Light: J  Heavy: K  Parry-Dash: L/Space  Pause: P  Restart: R",
    140,
    screen_h - 32,
    22,
    @raylib.Color::new(202, 220, 246, 226),
  )
}

///|
fn draw_message(game : Game) -> Unit {
  if game.message == "" || game.message_t <= 0.0 {
    return
  }

  let alpha : Int = if game.message_t >= 1.0 {
    232
  } else {
    90 + (game.message_t * 142.0).to_int()
  }

  let w : Int = @raylib.measure_text(game.message, 30) + 42
  let x : Int = screen_w / 2 - w / 2
  let y : Int = arena_y + 16

  @raylib.draw_rectangle(x, y, w, 48, @raylib.Color::new(14, 20, 34, alpha))
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    48,
    @raylib.Color::new(206, 226, 250, mini(255, alpha + 18)),
  )
  @raylib.draw_text(
    game.message,
    x + 20,
    y + 10,
    30,
    @raylib.Color::new(242, 248, 255, mini(255, alpha + 18)),
  )
}

///|
fn draw_title_overlay() -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(8, 10, 18, 168),
  )

  let t0 : String = "WUXIA ROOFTOP DUEL"
  let t1 : String = "Read telegraphs. Parry inside the red window. Survive endless waves."

  @raylib.draw_text(
    t0,
    screen_w / 2 - @raylib.measure_text(t0, 78) / 2,
    190,
    78,
    @raylib.Color::new(238, 246, 255, 248),
  )
  @raylib.draw_text(
    t1,
    screen_w / 2 - @raylib.measure_text(t1, 30) / 2,
    286,
    30,
    @raylib.Color::new(202, 222, 244, 236),
  )

  @raylib.draw_text(
    "Controls",
    screen_w / 2 - 110,
    382,
    44,
    @raylib.Color::new(248, 226, 180, 242),
  )
  @raylib.draw_text(
    "Move: WASD / Arrows",
    screen_w / 2 - 180,
    444,
    32,
    @raylib.Color::new(226, 236, 252, 236),
  )
  @raylib.draw_text(
    "J: Light slash   K: Heavy slash",
    screen_w / 2 - 220,
    486,
    32,
    @raylib.Color::new(226, 236, 252, 236),
  )
  @raylib.draw_text(
    "L or Space: Parry-Dash   P: Pause   R: Restart",
    screen_w / 2 - 300,
    528,
    32,
    @raylib.Color::new(226, 236, 252, 236),
  )

  let start : String = "Press Enter / Space / J / K to start"
  @raylib.draw_text(
    start,
    screen_w / 2 - @raylib.measure_text(start, 38) / 2,
    646,
    38,
    @raylib.Color::new(180, 246, 216, 244),
  )
}

///|
fn draw_paused_overlay() -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(12, 14, 24, 138),
  )

  let title : String = "PAUSED"
  @raylib.draw_text(
    title,
    screen_w / 2 - @raylib.measure_text(title, 88) / 2,
    260,
    88,
    @raylib.Color::new(244, 246, 255, 248),
  )

  let line : String = "Press P to resume. Press R to restart the duel."
  @raylib.draw_text(
    line,
    screen_w / 2 - @raylib.measure_text(line, 36) / 2,
    382,
    36,
    @raylib.Color::new(214, 226, 246, 238),
  )
}

///|
fn draw_game_over_overlay(game : Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(12, 8, 16, 176),
  )

  let title : String = "DUEL LOST"
  @raylib.draw_text(
    title,
    screen_w / 2 - @raylib.measure_text(title, 84) / 2,
    210,
    84,
    @raylib.Color::new(255, 182, 194, 248),
  )

  let l0 : String = "Score " + game.score.to_string()
  let l1 : String = "Best " + game.best_score.to_string()
  let l2 : String = "Reached wave " + game.wave.to_string()
  let l3 : String = "Time survived " + game.game_t.to_int().to_string() + " s"

  @raylib.draw_text(
    l0,
    screen_w / 2 - @raylib.measure_text(l0, 42) / 2,
    340,
    42,
    @raylib.Color::new(238, 242, 252, 246),
  )
  @raylib.draw_text(
    l1,
    screen_w / 2 - @raylib.measure_text(l1, 38) / 2,
    392,
    38,
    @raylib.Color::new(220, 230, 246, 240),
  )
  @raylib.draw_text(
    l2,
    screen_w / 2 - @raylib.measure_text(l2, 34) / 2,
    440,
    34,
    @raylib.Color::new(220, 230, 246, 236),
  )
  @raylib.draw_text(
    l3,
    screen_w / 2 - @raylib.measure_text(l3, 34) / 2,
    482,
    34,
    @raylib.Color::new(220, 230, 246, 236),
  )

  let hint : String = "Press R to restart or Enter/Space to re-enter the rooftop."
  @raylib.draw_text(
    hint,
    screen_w / 2 - @raylib.measure_text(hint, 32) / 2,
    610,
    32,
    @raylib.Color::new(194, 240, 216, 244),
  )
}

///|
fn draw_frame(game : Game) -> Unit {
  draw_background(game)

  let ox : Int = shake_x(game)
  let oy : Int = shake_y(game)

  draw_rooftop(ox, oy)

  for i = 0; i < game.enemies.length(); i = i + 1 {
    draw_enemy(game.enemies[i], game, ox, oy)
  }

  draw_player(game, ox, oy)
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
