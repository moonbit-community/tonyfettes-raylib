///|
fn bg_noise(game : Game, k : Float) -> Float {
  sinf(game.ui_t * k)
}

///|
fn shake_x(game : Game) -> Int {
  if game.shake_t <= 0.0 {
    0
  } else {
    @raylib.get_random_value(-6, 6)
  }
}

///|
fn shake_y(game : Game) -> Int {
  if game.shake_t <= 0.0 {
    0
  } else {
    @raylib.get_random_value(-5, 5)
  }
}

///|
fn draw_background(game : Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(8, 16, 28, 255))

  let n0 : Float = bg_noise(game, 0.43)
  let n1 : Float = bg_noise(game, 0.76)

  @raylib.draw_circle(
    200,
    120,
    230.0 + n0 * 16.0,
    @raylib.Color::new(20, 56, 86, 28),
  )
  @raylib.draw_circle(
    760,
    150,
    260.0 - n1 * 24.0,
    @raylib.Color::new(22, 62, 96, 30),
  )
  @raylib.draw_circle(
    screen_w - 300,
    180,
    300.0 + n1 * 20.0,
    @raylib.Color::new(36, 52, 86, 32),
  )

  for i = 0; i < 16; i = i + 1 {
    let y : Int = i * 66
    @raylib.draw_rectangle(
      0,
      y,
      screen_w,
      42,
      @raylib.Color::new(
        8 + i * 2 % 12,
        14 + i * 4 % 16,
        24 + i * 7 % 20,
        12 + i * 2 % 18,
      ),
    )
  }
}

///|
fn draw_world_back(_game : Game, ox : Int, oy : Int) -> Unit {
  @raylib.draw_rectangle(
    world_x0 + ox,
    world_y0 + oy,
    world_w,
    world_h,
    @raylib.Color::new(16, 30, 44, 236),
  )

  @raylib.draw_rectangle_lines(
    world_x0 + ox,
    world_y0 + oy,
    world_w,
    world_h,
    @raylib.Color::new(174, 206, 226, 204),
  )

  for i = 0; i < 20; i = i + 1 {
    let y : Int = world_y0 + oy + i * 48
    @raylib.draw_line(
      world_x0 + 12 + ox,
      y,
      world_x0 + world_w - 12 + ox,
      y,
      @raylib.Color::new(72, 110, 132, 36),
    )
  }

  for i = 0; i < 22; i = i + 1 {
    let x : Int = world_x0 + ox + i * 52
    @raylib.draw_line(
      x,
      world_y0 + 12 + oy,
      x,
      world_y0 + world_h - 12 + oy,
      @raylib.Color::new(66, 104, 126, 28),
    )
  }

  @raylib.draw_rectangle(
    world_x0 - 8 + ox,
    world_y0 + oy,
    12,
    world_h,
    @raylib.Color::new(76, 94, 92, 218),
  )
  @raylib.draw_rectangle(
    world_x0 + world_w - 4 + ox,
    world_y0 + oy,
    12,
    world_h,
    @raylib.Color::new(76, 94, 92, 218),
  )
}

///|
fn draw_storm(game : Game, ox : Int, oy : Int) -> Unit {
  let swirl : Float = 0.7 + Float::from_int(game.wave) * 0.08
  let alpha : Int = 36 + game.wave * 7

  for i = 0; i < 80; i = i + 1 {
    let t : Float = Float::from_int(i)
    let sx : Float = world_left() +
      Float::from_int(i * 73 % world_w) +
      sinf(game.storm_t * (0.9 + t * 0.01) + t * 0.7) * 30.0
    let sy : Float = world_top() +
      Float::from_int(i * 41 % world_h) +
      cosf(game.storm_t * (1.1 + t * 0.006) + t * 0.3) * 24.0

    let ex : Float = sx - 30.0 * swirl
    let ey : Float = sy + 18.0 * swirl

    @raylib.draw_line(
      sx.to_int() + ox,
      sy.to_int() + oy,
      ex.to_int() + ox,
      ey.to_int() + oy,
      @raylib.Color::new(198, 226, 244, alpha),
    )
  }
}

///|
fn draw_core(game : Game, ox : Int, oy : Int) -> Unit {
  let heat_ratio : Float = clampf(game.core_heat / 100.0, 0.0, 1.0)
  let pulse : Float = sinf(game.ui_t * 6.0)

  let cx : Int = core_x().to_int() + ox
  let cy : Int = core_y().to_int() + oy

  @raylib.draw_circle(
    cx,
    cy,
    core_r + 26.0,
    @raylib.Color::new(32, 48, 66, 210),
  )

  @raylib.draw_circle(
    cx,
    cy,
    core_r + pulse * 4.0,
    @raylib.Color::new(
      110 + (heat_ratio * 100.0).to_int(),
      120 + (heat_ratio * 60.0).to_int(),
      160 + (heat_ratio * 60.0).to_int(),
      220,
    ),
  )

  @raylib.draw_circle(
    cx,
    cy,
    core_r - 24.0,
    @raylib.Color::new(34, 62, 86, 242),
  )

  for i = 0; i < 6; i = i + 1 {
    let a : Float = game.ui_t * 0.8 + Float::from_int(i) * 1.047
    let px : Int = (core_x() + cosf(a) * (core_r + 20.0)).to_int() + ox
    let py : Int = (core_y() + sinf(a) * (core_r + 20.0)).to_int() + oy
    @raylib.draw_circle(px, py, 6.0, @raylib.Color::new(212, 236, 255, 186))
  }

  @raylib.draw_text(
    "CORE",
    cx - @raylib.measure_text("CORE", 24) / 2,
    cy - 14,
    24,
    @raylib.Color::new(236, 246, 255, 236),
  )
}

///|
fn enemy_color(kind : Int) -> @raylib.Color {
  if kind == enemy_wolf {
    @raylib.Color::new(180, 212, 232, 242)
  } else if kind == enemy_brute {
    @raylib.Color::new(146, 170, 194, 248)
  } else {
    @raylib.Color::new(196, 240, 255, 244)
  }
}

///|
fn draw_enemy(enemy : Enemy, ox : Int, oy : Int) -> Unit {
  if not(enemy.active) {
    return
  }

  let x : Int = enemy.x.to_int() + ox
  let y : Int = enemy.y.to_int() + oy

  let c0 : @raylib.Color = enemy_color(enemy.kind)

  if enemy.kind == enemy_wolf {
    @raylib.draw_circle(x, y, enemy.r, c0)
    @raylib.draw_triangle(
      @raylib.Vector2::new(Float::from_int(x - 10), Float::from_int(y - 8)),
      @raylib.Vector2::new(Float::from_int(x - 18), Float::from_int(y - 22)),
      @raylib.Vector2::new(Float::from_int(x - 2), Float::from_int(y - 18)),
      @raylib.Color::new(206, 232, 248, 238),
    )
    @raylib.draw_triangle(
      @raylib.Vector2::new(Float::from_int(x + 10), Float::from_int(y - 8)),
      @raylib.Vector2::new(Float::from_int(x + 2), Float::from_int(y - 22)),
      @raylib.Vector2::new(Float::from_int(x + 18), Float::from_int(y - 18)),
      @raylib.Color::new(206, 232, 248, 238),
    )
  } else if enemy.kind == enemy_brute {
    @raylib.draw_circle(
      x,
      y,
      enemy.r + 4.0,
      @raylib.Color::new(112, 136, 162, 248),
    )
    @raylib.draw_circle(x, y, enemy.r - 2.0, c0)
    @raylib.draw_circle_lines(
      x,
      y,
      enemy.r + 6.0,
      @raylib.Color::new(218, 236, 246, 188),
    )
  } else {
    let r : Float = enemy.r
    for k = 0; k < 4; k = k + 1 {
      let a0 : Float = enemy.phase + Float::from_int(k) * 1.57
      let a1 : Float = a0 + 0.7
      let a2 : Float = a0 - 0.7

      @raylib.draw_triangle(
        @raylib.Vector2::new(Float::from_int(x), Float::from_int(y)),
        @raylib.Vector2::new(
          (enemy.x + cosf(a1) * (r + 8.0)).to_int() |> Float::from_int,
          (enemy.y + sinf(a1) * (r + 8.0)).to_int() |> Float::from_int,
        ),
        @raylib.Vector2::new(
          (enemy.x + cosf(a2) * (r + 8.0)).to_int() |> Float::from_int,
          (enemy.y + sinf(a2) * (r + 8.0)).to_int() |> Float::from_int,
        ),
        c0,
      )
    }
  }

  @raylib.draw_circle(x + 4, y - 4, 3.0, @raylib.Color::new(24, 34, 42, 220))
}

///|
fn pickup_color(kind : Int) -> @raylib.Color {
  if kind == pickup_fuel {
    @raylib.Color::new(255, 196, 112, 244)
  } else if kind == pickup_medkit {
    @raylib.Color::new(255, 132, 156, 244)
  } else if kind == pickup_ammo {
    @raylib.Color::new(138, 222, 255, 244)
  } else {
    @raylib.Color::new(194, 142, 255, 244)
  }
}

///|
fn draw_pickup(p : Pickup, ox : Int, oy : Int) -> Unit {
  if not(p.active) {
    return
  }

  let x : Int = p.x.to_int() + ox
  let y : Int = p.y.to_int() + oy
  let pulse : Float = sinf(p.phase * 2.4)
  let rr : Float = pickup_radius(p.kind) + pulse * 1.8

  let c : @raylib.Color = pickup_color(p.kind)

  @raylib.draw_circle(x, y, rr, c)
  @raylib.draw_circle_lines(
    x,
    y,
    rr + 3.0,
    @raylib.Color::new(244, 250, 255, 210),
  )

  if p.kind == pickup_fuel {
    @raylib.draw_rectangle(
      x - 5,
      y - 8,
      10,
      16,
      @raylib.Color::new(58, 38, 24, 230),
    )
  } else if p.kind == pickup_medkit {
    @raylib.draw_line(
      x - 6,
      y,
      x + 6,
      y,
      @raylib.Color::new(250, 248, 248, 240),
    )
    @raylib.draw_line(
      x,
      y - 6,
      x,
      y + 6,
      @raylib.Color::new(250, 248, 248, 240),
    )
  } else if p.kind == pickup_ammo {
    @raylib.draw_circle(x, y, 4.0, @raylib.Color::new(22, 36, 50, 234))
  } else {
    @raylib.draw_circle_lines(
      x,
      y,
      rr - 5.0,
      @raylib.Color::new(236, 214, 255, 224),
    )
  }
}

///|
fn draw_bullet(b : Bullet, ox : Int, oy : Int) -> Unit {
  if not(b.active) {
    return
  }

  let c : @raylib.Color = if b.kind == bullet_pierce {
    @raylib.Color::new(198, 150, 255, 242)
  } else {
    @raylib.Color::new(152, 236, 255, 242)
  }

  @raylib.draw_circle(
    b.x.to_int() + ox,
    b.y.to_int() + oy,
    if b.kind == bullet_pierce {
      5.0
    } else {
      3.5
    },
    c,
  )
}

///|
fn draw_particles(game : Game, ox : Int, oy : Int) -> Unit {
  for i = 0; i < game.particles.length(); i = i + 1 {
    if not(game.particles[i].active) {
      continue
    }

    let a : Int = if game.particles[i].life > 0.7 {
      236
    } else if game.particles[i].life > 0.4 {
      180
    } else {
      108
    }

    let c : @raylib.Color = if game.particles[i].kind == 2 {
      @raylib.Color::new(208, 180, 255, a)
    } else if game.particles[i].kind == 1 {
      @raylib.Color::new(255, 160, 172, a)
    } else {
      @raylib.Color::new(180, 236, 255, a)
    }

    @raylib.draw_circle(
      game.particles[i].x.to_int() + ox,
      game.particles[i].y.to_int() + oy,
      game.particles[i].size,
      c,
    )
  }
}

///|
fn draw_player(game : Game, ox : Int, oy : Int) -> Unit {
  let x : Int = game.player_x.to_int() + ox
  let y : Int = game.player_y.to_int() + oy

  let tilt : Float = clampf(game.player_vx * 0.0015, -0.5, 0.5)

  @raylib.draw_circle(
    x,
    y,
    player_r + 2.0,
    @raylib.Color::new(74, 118, 146, 248),
  )
  @raylib.draw_circle(
    x,
    y,
    player_r - 6.0,
    @raylib.Color::new(192, 214, 232, 248),
  )

  @raylib.draw_triangle(
    @raylib.Vector2::new(Float::from_int(x), Float::from_int(y - 18)),
    @raylib.Vector2::new(Float::from_int(x - 12), Float::from_int(y + 10)),
    @raylib.Vector2::new(Float::from_int(x + 12), Float::from_int(y + 10)),
    @raylib.Color::new(78, 104, 132, 240),
  )

  @raylib.draw_circle(
    (Float::from_int(x) + tilt * 10.0).to_int(),
    y - 6,
    4.0,
    @raylib.Color::new(20, 34, 46, 220),
  )

  let ax : Int = game.aim_x.to_int() + ox
  let ay : Int = game.aim_y.to_int() + oy
  @raylib.draw_line(
    x,
    y,
    ax,
    ay,
    @raylib.Color::new(188, 232, 255, if game.fire_cd <= 0.0 { 86 } else { 44 }),
  )

  if game.overdrive_t > 0.0 {
    let pulse : Float = sinf(game.ui_t * 9.0)
    @raylib.draw_circle_lines(
      x,
      y,
      player_r + 8.0 + pulse * 2.0,
      @raylib.Color::new(210, 168, 255, 238),
    )
  }
}

///|
fn draw_hint(game : Game, ox : Int, oy : Int) -> Unit {
  if game.hint_t <= 0.0 {
    return
  }

  let pulse : Float = sinf(game.ui_t * 11.0)
  let alpha : Int = if game.hint_t > 1.2 {
    238
  } else {
    100 + (game.hint_t * 110.0).to_int()
  }

  @raylib.draw_circle_lines(
    game.hint_x.to_int() + ox,
    game.hint_y.to_int() + oy,
    28.0 + pulse * 4.0,
    @raylib.Color::new(255, 236, 130, alpha),
  )
  @raylib.draw_line(
    game.player_x.to_int() + ox,
    game.player_y.to_int() + oy,
    game.hint_x.to_int() + ox,
    game.hint_y.to_int() + oy,
    @raylib.Color::new(255, 236, 130, alpha / 2),
  )
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

  let r : Float = clampf(ratio, 0.0, 1.0)
  let fw : Int = (Float::from_int(w) * r).to_int()
  if fw > 0 {
    @raylib.draw_rectangle(x, y, fw, h, fill)
  }

  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(220, 236, 246, 186),
  )
}

///|
fn draw_panel(game : Game) -> Unit {
  @raylib.draw_rectangle(
    panel_x0,
    20,
    panel_w,
    screen_h - 40,
    @raylib.Color::new(14, 22, 36, 230),
  )
  @raylib.draw_rectangle_lines(
    panel_x0,
    20,
    panel_w,
    screen_h - 40,
    @raylib.Color::new(158, 200, 230, 204),
  )

  @raylib.draw_text(
    "ARCTIC OUTPOST",
    panel_x0 + 24,
    36,
    34,
    @raylib.Color::new(232, 246, 255, 246),
  )
  @raylib.draw_text(
    "SURVIVAL 2026",
    panel_x0 + 24,
    74,
    26,
    @raylib.Color::new(176, 206, 226, 236),
  )

  @raylib.draw_text(
    "Score " + game.score.to_string(),
    panel_x0 + 24,
    128,
    30,
    @raylib.Color::new(238, 246, 255, 244),
  )
  @raylib.draw_text(
    "Best " + game.best_score.to_string(),
    panel_x0 + 24,
    164,
    24,
    @raylib.Color::new(198, 226, 244, 236),
  )

  @raylib.draw_text(
    "Wave " + game.wave.to_string(),
    panel_x0 + 24,
    200,
    24,
    @raylib.Color::new(206, 232, 246, 236),
  )
  @raylib.draw_text(
    "Lives " + game.lives.to_string(),
    panel_x0 + 170,
    200,
    24,
    @raylib.Color::new(255, 212, 220, 240),
  )

  @raylib.draw_text(
    "Combo x" + game.combo.to_string(),
    panel_x0 + 24,
    236,
    24,
    if game.combo >= 5 {
      @raylib.Color::new(255, 234, 138, 248)
    } else {
      @raylib.Color::new(194, 224, 238, 228)
    },
  )

  @raylib.draw_text(
    "Suit",
    panel_x0 + 24,
    282,
    22,
    @raylib.Color::new(224, 236, 246, 224),
  )
  draw_bar(
    panel_x0 + 24,
    310,
    panel_w - 48,
    18,
    game.suit_hp / 100.0,
    @raylib.Color::new(255, 142, 164, 242),
    @raylib.Color::new(64, 36, 44, 220),
  )

  @raylib.draw_text(
    "Core heat",
    panel_x0 + 24,
    338,
    22,
    @raylib.Color::new(224, 236, 246, 224),
  )
  draw_bar(
    panel_x0 + 24,
    366,
    panel_w - 48,
    18,
    game.core_heat / 100.0,
    @raylib.Color::new(132, 222, 255, 242),
    @raylib.Color::new(36, 58, 76, 220),
  )

  @raylib.draw_text(
    "Fuel",
    panel_x0 + 24,
    394,
    22,
    @raylib.Color::new(224, 236, 246, 224),
  )
  draw_bar(
    panel_x0 + 24,
    422,
    panel_w - 48,
    18,
    game.fuel / 100.0,
    @raylib.Color::new(255, 196, 108, 242),
    @raylib.Color::new(74, 54, 28, 220),
  )

  @raylib.draw_text(
    "Survival",
    panel_x0 + 24,
    450,
    22,
    @raylib.Color::new(224, 236, 246, 224),
  )
  draw_bar(
    panel_x0 + 24,
    478,
    panel_w - 48,
    18,
    game.game_t / survival_time_goal,
    @raylib.Color::new(154, 236, 176, 242),
    @raylib.Color::new(34, 64, 44, 220),
  )

  @raylib.draw_text(
    "Ammo " + game.ammo.to_string(),
    panel_x0 + 24,
    516,
    24,
    @raylib.Color::new(202, 230, 252, 236),
  )
  @raylib.draw_text(
    "Overdrive " + game.overdrive_t.to_int().to_string() + "s",
    panel_x0 + 170,
    516,
    24,
    @raylib.Color::new(220, 188, 252, 236),
  )

  @raylib.draw_text(
    "Hints left " + game.hint_left.to_string(),
    panel_x0 + 24,
    550,
    22,
    @raylib.Color::new(204, 228, 246, 224),
  )

  @raylib.draw_text(
    "Desktop: WASD move, mouse/Space fire",
    panel_x0 + 24,
    590,
    20,
    @raylib.Color::new(172, 206, 226, 216),
  )
  @raylib.draw_text(
    "E repair, H hint, R restart",
    panel_x0 + 24,
    616,
    20,
    @raylib.Color::new(172, 206, 226, 216),
  )
  @raylib.draw_text(
    "Mobile: right-side touch controls",
    panel_x0 + 24,
    642,
    20,
    @raylib.Color::new(172, 206, 226, 216),
  )
}

///|
fn draw_touch_button(
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
  rect : (Int, Int, Int, Int),
  label : String,
  c_idle : @raylib.Color,
  c_on : @raylib.Color,
) -> Unit {
  let on : Bool = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    rect.0,
    rect.1,
    rect.2,
    rect.3,
  )

  let fill : @raylib.Color = if on { c_on } else { c_idle }

  @raylib.draw_rectangle(rect.0, rect.1, rect.2, rect.3, fill)
  @raylib.draw_rectangle_lines(
    rect.0,
    rect.1,
    rect.2,
    rect.3,
    @raylib.Color::new(218, 236, 248, 190),
  )

  let fs : Int = if rect.3 <= 96 { 24 } else { 30 }
  let tw : Int = @raylib.measure_text(label, fs)
  @raylib.draw_text(
    label,
    rect.0 + (rect.2 - tw) / 2,
    rect.1 + (rect.3 - fs) / 2,
    fs,
    @raylib.Color::new(238, 246, 252, 240),
  )
}

///|
fn draw_touch_controls(
  game : Game,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  if game.state != state_play {
    return
  }

  draw_touch_button(
    mx,
    my,
    hold,
    touch_count,
    btn_left(),
    "L",
    @raylib.Color::new(44, 76, 102, 176),
    @raylib.Color::new(70, 118, 156, 212),
  )
  draw_touch_button(
    mx,
    my,
    hold,
    touch_count,
    btn_right(),
    "R",
    @raylib.Color::new(44, 76, 102, 176),
    @raylib.Color::new(70, 118, 156, 212),
  )
  draw_touch_button(
    mx,
    my,
    hold,
    touch_count,
    btn_up(),
    "U",
    @raylib.Color::new(44, 76, 102, 176),
    @raylib.Color::new(70, 118, 156, 212),
  )
  draw_touch_button(
    mx,
    my,
    hold,
    touch_count,
    btn_down(),
    "D",
    @raylib.Color::new(44, 76, 102, 176),
    @raylib.Color::new(70, 118, 156, 212),
  )

  draw_touch_button(
    mx,
    my,
    hold,
    touch_count,
    btn_fire(),
    "FIRE",
    @raylib.Color::new(80, 90, 142, 182),
    @raylib.Color::new(126, 150, 228, 220),
  )
  draw_touch_button(
    mx,
    my,
    hold,
    touch_count,
    btn_repair(),
    "RPR",
    @raylib.Color::new(90, 92, 116, 182),
    @raylib.Color::new(150, 142, 196, 220),
  )
  draw_touch_button(
    mx,
    my,
    hold,
    touch_count,
    btn_hint(),
    "HNT",
    @raylib.Color::new(90, 96, 134, 182),
    @raylib.Color::new(150, 168, 224, 220),
  )
  draw_touch_button(
    mx,
    my,
    hold,
    touch_count,
    btn_restart(),
    "RST",
    @raylib.Color::new(104, 86, 122, 182),
    @raylib.Color::new(170, 134, 188, 220),
  )
}

///|
fn draw_message(game : Game) -> Unit {
  if game.msg_t <= 0.0 || game.msg == "" {
    return
  }

  let a : Int = if game.msg_t > 1.0 {
    228
  } else {
    90 + (game.msg_t * 138.0).to_int()
  }

  let w : Int = @raylib.measure_text(game.msg, 28) + 38
  let x : Int = world_x0 + (world_w - w) / 2
  let y : Int = world_y0 + 18

  @raylib.draw_rectangle(x, y, w, 46, @raylib.Color::new(22, 32, 50, a))
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    46,
    @raylib.Color::new(198, 226, 244, mini(250, a + 10)),
  )
  @raylib.draw_text(
    game.msg,
    x + 18,
    y + 10,
    28,
    @raylib.Color::new(236, 244, 252, mini(255, a + 20)),
  )
}

///|
fn draw_title_overlay(
  _game : Game,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(8, 12, 22, 162),
  )

  let h0 : String = "ARCTIC OUTPOST SURVIVAL"
  let h1 : String = "Hold the generator against storm waves"
  let h2 : String = "Repair near core, gather fuel/ammo, survive 200 seconds"

  @raylib.draw_text(
    h0,
    screen_w / 2 - @raylib.measure_text(h0, 72) / 2,
    178,
    72,
    @raylib.Color::new(232, 246, 255, 246),
  )
  @raylib.draw_text(
    h1,
    screen_w / 2 - @raylib.measure_text(h1, 32) / 2,
    272,
    32,
    @raylib.Color::new(186, 214, 236, 238),
  )
  @raylib.draw_text(
    h2,
    screen_w / 2 - @raylib.measure_text(h2, 26) / 2,
    326,
    26,
    @raylib.Color::new(182, 210, 232, 224),
  )

  let b = start_button_rect()
  let hover : Bool = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    b.0,
    b.1,
    b.2,
    b.3,
  )

  @raylib.draw_rectangle(
    b.0,
    b.1,
    b.2,
    b.3,
    if hover {
      @raylib.Color::new(82, 154, 214, 236)
    } else {
      @raylib.Color::new(56, 126, 186, 220)
    },
  )
  @raylib.draw_rectangle_lines(
    b.0,
    b.1,
    b.2,
    b.3,
    @raylib.Color::new(224, 242, 255, 230),
  )

  let txt : String = "START DEFENSE"
  @raylib.draw_text(
    txt,
    b.0 + (b.2 - @raylib.measure_text(txt, 46)) / 2,
    b.1 + 34,
    46,
    @raylib.Color::new(244, 250, 255, 248),
  )
}

///|
fn draw_result_overlay(
  game : Game,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(8, 10, 18, 174),
  )

  let h0 : String = if game.win { "OUTPOST SECURED" } else { "OUTPOST LOST" }
  let h1 : String = if game.win {
    "Dawn reached. Core remains stable."
  } else {
    "Heat core failed during blizzard surge."
  }

  @raylib.draw_text(
    h0,
    screen_w / 2 - @raylib.measure_text(h0, 74) / 2,
    182,
    74,
    if game.win {
      @raylib.Color::new(176, 246, 198, 246)
    } else {
      @raylib.Color::new(255, 184, 176, 246)
    },
  )
  @raylib.draw_text(
    h1,
    screen_w / 2 - @raylib.measure_text(h1, 32) / 2,
    276,
    32,
    @raylib.Color::new(208, 228, 242, 236),
  )

  let l0 : String = "Score " + game.score.to_string()
  let l1 : String = "Best " + game.best_score.to_string()
  let l2 : String = "Wave " + game.wave.to_string()
  let l3 : String = "Time " +
    game.game_t.to_int().to_string() +
    " / " +
    survival_time_goal.to_int().to_string() +
    " s"

  @raylib.draw_text(
    l0,
    screen_w / 2 - @raylib.measure_text(l0, 38) / 2,
    350,
    38,
    @raylib.Color::new(238, 246, 252, 244),
  )
  @raylib.draw_text(
    l1,
    screen_w / 2 - @raylib.measure_text(l1, 34) / 2,
    396,
    34,
    @raylib.Color::new(206, 230, 244, 238),
  )
  @raylib.draw_text(
    l2,
    screen_w / 2 - @raylib.measure_text(l2, 34) / 2,
    438,
    34,
    @raylib.Color::new(206, 230, 244, 238),
  )
  @raylib.draw_text(
    l3,
    screen_w / 2 - @raylib.measure_text(l3, 32) / 2,
    480,
    32,
    @raylib.Color::new(206, 230, 244, 238),
  )

  let b = retry_button_rect()
  let hover : Bool = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    b.0,
    b.1,
    b.2,
    b.3,
  )

  @raylib.draw_rectangle(
    b.0,
    b.1,
    b.2,
    b.3,
    if hover {
      @raylib.Color::new(76, 150, 212, 236)
    } else {
      @raylib.Color::new(52, 122, 180, 220)
    },
  )
  @raylib.draw_rectangle_lines(
    b.0,
    b.1,
    b.2,
    b.3,
    @raylib.Color::new(224, 242, 255, 228),
  )

  let txt : String = "DEFEND AGAIN"
  @raylib.draw_text(
    txt,
    b.0 + (b.2 - @raylib.measure_text(txt, 42)) / 2,
    b.1 + 32,
    42,
    @raylib.Color::new(242, 248, 255, 248),
  )
}

///|
fn draw_frame(
  game : Game,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  draw_background(game)

  let ox : Int = shake_x(game)
  let oy : Int = shake_y(game)

  draw_world_back(game, ox, oy)
  draw_storm(game, ox, oy)
  draw_core(game, ox, oy)

  for i = 0; i < game.enemies.length(); i = i + 1 {
    draw_enemy(game.enemies[i], ox, oy)
  }

  for i = 0; i < game.pickups.length(); i = i + 1 {
    draw_pickup(game.pickups[i], ox, oy)
  }

  for i = 0; i < game.bullets.length(); i = i + 1 {
    draw_bullet(game.bullets[i], ox, oy)
  }

  draw_hint(game, ox, oy)
  draw_particles(game, ox, oy)
  draw_player(game, ox, oy)

  draw_panel(game)
  draw_touch_controls(game, mx, my, hold, touch_count)
  draw_message(game)

  if game.state == state_title {
    draw_title_overlay(game, mx, my, hold, touch_count)
  } else if game.state == state_result {
    draw_result_overlay(game, mx, my, hold, touch_count)
  }
}
