///|
fn draw_center_text(
  text : String,
  y : Int,
  size : Int,
  col : @raylib.Color,
) -> Unit {
  let tw = @raylib.measure_text(text, size)
  @raylib.draw_text(text, screen_w / 2 - tw / 2, y, size, col)
}

///|
fn shake_offset(game : Game) -> (Float, Float) {
  if game.shake_t <= 0.0 {
    (0.0, 0.0)
  } else {
    let p = game.shake_t * 18.0
    (randf(-p, p), randf(-p, p))
  }
}

///|
fn world_to_screen(
  x : Float,
  y : Float,
  cam_x : Float,
  cam_y : Float,
) -> (Float, Float) {
  (center_x() + x + cam_x, center_y() + y + cam_y)
}

///|
fn ring_color(game : Game, ring : Int) -> @raylib.Color {
  let phase = game.time_s * 1.2 + Float::from_int(ring) * 0.9
  let pulse : Float = 0.5 + 0.5 * sinf(phase)
  if game.phase_beta {
    @raylib.Color::new(
      180 + (pulse * 60.0).to_int(),
      120 + (pulse * 26.0).to_int(),
      220 + (pulse * 34.0).to_int(),
      180,
    )
  } else {
    @raylib.Color::new(
      80 + (pulse * 34.0).to_int(),
      180 + (pulse * 58.0).to_int(),
      240 + (pulse * 14.0).to_int(),
      180,
    )
  }
}

///|
fn draw_backdrop(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  @raylib.draw_rectangle_gradient_v(
    0,
    0,
    screen_w,
    screen_h,
    bg_top(),
    bg_bottom(),
  )

  for i = 0; i < 90; i = i + 1 {
    let px = (i * 71 + 53) % screen_w
    let py = (i * 43 + 91) % screen_h
    let phase = game.time_s * 0.4 + Float::from_int(i) * 0.21
    let v : Float = 0.5 + 0.3 * sinf(phase) + 0.2 * cosf(phase * 1.6)
    let star_r : Float = 0.8 + v * 1.8
    @raylib.draw_circle(
      px,
      py,
      star_r,
      @raylib.Color::new(
        120 + (v * 70.0).to_int(),
        120 + (v * 70.0).to_int(),
        190 + (v * 40.0).to_int(),
        110,
      ),
    )
  }

  @raylib.draw_circle(
    (center_x() + cam_x).to_int(),
    (center_y() + cam_y).to_int(),
    56.0,
    @raylib.Color::new(255, 174, 88, 230),
  )
  @raylib.draw_circle(
    (center_x() + cam_x).to_int(),
    (center_y() + cam_y).to_int(),
    78.0,
    @raylib.Color::new(255, 168, 96, 90),
  )
  @raylib.draw_circle_lines(
    (center_x() + cam_x).to_int(),
    (center_y() + cam_y).to_int(),
    92.0,
    @raylib.Color::new(255, 188, 132, 110),
  )
}

///|
fn draw_rings(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  for ring = 0; ring < ring_count; ring = ring + 1 {
    let r = ring_radius(ring)
    let col = ring_color(game, ring)

    @raylib.draw_circle_lines(
      (center_x() + cam_x).to_int(),
      (center_y() + cam_y).to_int(),
      r,
      col,
    )

    let sweep = wrap_angle(game.time_s * 0.6 + Float::from_int(ring) * 0.8)
    let p0 = world_to_screen(world_x(r, sweep), world_y(r, sweep), cam_x, cam_y)
    @raylib.draw_circle(
      p0.0.to_int(),
      p0.1.to_int(),
      4.0,
      @raylib.Color::new(col.r.to_int(), col.g.to_int(), col.b.to_int(), 180),
    )
  }
}

///|
fn draw_flares(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  for i = 0; i < game.flares.length(); i = i + 1 {
    if not(game.flares[i].active) {
      continue
    }

    let f0 = game.flares[i]
    let r = ring_radius(f0.ring)
    let segs = 16

    for s = 0; s < segs; s = s + 1 {
      let t0 = Float::from_int(s) / Float::from_int(segs)
      let t1 = Float::from_int(s + 1) / Float::from_int(segs)
      let a0 = f0.angle - f0.span + f0.span * 2.0 * t0
      let a1 = f0.angle - f0.span + f0.span * 2.0 * t1

      let p0 = world_to_screen(world_x(r, a0), world_y(r, a0), cam_x, cam_y)
      let p1 = world_to_screen(world_x(r, a1), world_y(r, a1), cam_x, cam_y)

      let alpha = clampi(
        (Float::from_int(80) + f0.danger * 160.0).to_int(),
        40,
        240,
      )
      let c = @raylib.Color::new(255, 190, 94, alpha)
      @raylib.draw_line_ex(
        @raylib.Vector2::new(p0.0, p0.1),
        @raylib.Vector2::new(p1.0, p1.1),
        4.0,
        c,
      )
    }
  }
}

///|
fn enemy_color(_game : Game, e : Enemy) -> @raylib.Color {
  if e.kind == 0 {
    if e.phase_mask == 1 {
      @raylib.Color::new(94, 222, 255, 255)
    } else if e.phase_mask == 2 {
      @raylib.Color::new(255, 136, 224, 255)
    } else {
      @raylib.Color::new(222, 228, 248, 255)
    }
  } else if e.kind == 1 {
    @raylib.Color::new(255, 172, 102, 255)
  } else {
    @raylib.Color::new(174, 240, 164, 255)
  }
}

///|
fn draw_enemy(game : Game, e : Enemy, cam_x : Float, cam_y : Float) -> Unit {
  if not(e.active) {
    return
  }

  let p = enemy_world_xy(e)
  let s = world_to_screen(p.0, p.1, cam_x, cam_y)
  let col = enemy_color(game, e)

  if not(phase_mask_active(e.phase_mask, game.phase_beta)) {
    @raylib.draw_circle(
      s.0.to_int(),
      s.1.to_int(),
      e.size,
      @raylib.Color::new(col.r.to_int(), col.g.to_int(), col.b.to_int(), 70),
    )
    @raylib.draw_circle_lines(
      s.0.to_int(),
      s.1.to_int(),
      e.size + 2.0,
      @raylib.Color::new(col.r.to_int(), col.g.to_int(), col.b.to_int(), 120),
    )
    return
  }

  if e.kind == 1 {
    @raylib.draw_circle(s.0.to_int(), s.1.to_int(), e.size + 6.0, col)
    @raylib.draw_circle_lines(
      s.0.to_int(),
      s.1.to_int(),
      e.size + 14.0,
      @raylib.Color::new(col.r.to_int(), col.g.to_int(), col.b.to_int(), 160),
    )
  } else if e.kind == 2 {
    let pulse : Float = 0.5 + 0.5 * sinf(e.spin * 2.9)
    let mine_r : Float = e.size + pulse * 4.0
    @raylib.draw_circle(
      s.0.to_int(),
      s.1.to_int(),
      mine_r,
      @raylib.Color::new(col.r.to_int(), col.g.to_int(), col.b.to_int(), 220),
    )
    @raylib.draw_circle_lines(
      s.0.to_int(),
      s.1.to_int(),
      e.size + 8.0,
      @raylib.Color::new(col.r.to_int(), col.g.to_int(), col.b.to_int(), 180),
    )
  } else {
    @raylib.draw_rectangle(
      (s.0 - e.size).to_int(),
      (s.1 - e.size).to_int(),
      (e.size * 2.0).to_int(),
      (e.size * 2.0).to_int(),
      col,
    )
    @raylib.draw_rectangle_lines(
      (s.0 - e.size).to_int(),
      (s.1 - e.size).to_int(),
      (e.size * 2.0).to_int(),
      (e.size * 2.0).to_int(),
      @raylib.Color::new(20, 24, 32, 220),
    )
  }
}

///|
fn draw_enemies(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  for i = 0; i < game.enemies.length(); i = i + 1 {
    draw_enemy(game, game.enemies[i], cam_x, cam_y)
  }
}

///|
fn draw_bullets(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  for i = 0; i < game.bullets.length(); i = i + 1 {
    if not(game.bullets[i].active) {
      continue
    }

    let b = game.bullets[i]
    let r = ring_radius(clampi((b.ring_f + 0.5).to_int(), 0, ring_count - 1))
    let p = world_to_screen(
      world_x(r, b.angle),
      world_y(r, b.angle),
      cam_x,
      cam_y,
    )
    @raylib.draw_circle(
      p.0.to_int(),
      p.1.to_int(),
      4.2,
      if b.kind == 0 {
        @raylib.Color::new(134, 236, 255, 255)
      } else {
        @raylib.Color::new(255, 176, 120, 255)
      },
    )
  }

  for i = 0; i < game.enemy_bullets.length(); i = i + 1 {
    if not(game.enemy_bullets[i].active) {
      continue
    }

    let b = game.enemy_bullets[i]
    let p = world_to_screen(b.x, b.y, cam_x, cam_y)
    let col = if b.kind == 1 {
      @raylib.Color::new(255, 176, 106, 255)
    } else if b.kind == 2 {
      @raylib.Color::new(168, 248, 162, 255)
    } else {
      @raylib.Color::new(252, 146, 190, 255)
    }

    @raylib.draw_circle(p.0.to_int(), p.1.to_int(), 4.6, col)
  }
}

///|
fn draw_particles(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  for i = 0; i < game.particles.length(); i = i + 1 {
    if not(game.particles[i].active) {
      continue
    }

    let p = game.particles[i]
    let s = world_to_screen(p.x, p.y, cam_x, cam_y)
    let alpha = clampi((p.life * 255.0).to_int(), 0, 255)

    let c = if p.kind == 0 {
      @raylib.Color::new(136, 242, 255, alpha)
    } else if p.kind == 1 {
      @raylib.Color::new(255, 184, 112, alpha)
    } else {
      @raylib.Color::new(255, 130, 170, alpha)
    }

    @raylib.draw_circle(s.0.to_int(), s.1.to_int(), p.size, c)
  }
}

///|
fn draw_shocks(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  for i = 0; i < game.shocks.length(); i = i + 1 {
    if not(game.shocks[i].active) {
      continue
    }

    let s = game.shocks[i]
    let r = ring_radius(s.ring)
    let segs = 24

    for k = 0; k < segs; k = k + 1 {
      let t0 = Float::from_int(k) / Float::from_int(segs)
      let t1 = Float::from_int(k + 1) / Float::from_int(segs)
      let a0 = wrap_angle(lerpf(s.a0, s.a1, t0))
      let a1 = wrap_angle(lerpf(s.a0, s.a1, t1))

      let p0 = world_to_screen(world_x(r, a0), world_y(r, a0), cam_x, cam_y)
      let p1 = world_to_screen(world_x(r, a1), world_y(r, a1), cam_x, cam_y)

      let alpha = clampi((s.life / 0.34 * 220.0).to_int(), 0, 220)
      let col = if s.beta {
        @raylib.Color::new(255, 156, 232, alpha)
      } else {
        @raylib.Color::new(122, 230, 255, alpha)
      }

      @raylib.draw_line_ex(
        @raylib.Vector2::new(p0.0, p0.1),
        @raylib.Vector2::new(p1.0, p1.1),
        5.0,
        col,
      )
    }
  }
}

///|
fn draw_player(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  let p = player_world_xy(game.player)
  let s = world_to_screen(p.0, p.1, cam_x, cam_y)

  let a = game.player.angle
  let tangent = a + pi * 0.5

  let nose_x = s.0 + cosf(tangent) * 24.0
  let nose_y = s.1 + sinf(tangent) * 24.0
  let left_x = s.0 + cosf(tangent + 2.5) * 16.0
  let left_y = s.1 + sinf(tangent + 2.5) * 16.0
  let right_x = s.0 + cosf(tangent - 2.5) * 16.0
  let right_y = s.1 + sinf(tangent - 2.5) * 16.0

  let core_col = if game.phase_beta { ring_beta() } else { ring_alpha() }
  let hull_col = if game.player.hurt_t > 0.0 {
    @raylib.Color::new(255, 140, 166, 255)
  } else {
    @raylib.Color::new(228, 238, 252, 255)
  }

  @raylib.draw_triangle(
    @raylib.Vector2::new(nose_x, nose_y),
    @raylib.Vector2::new(left_x, left_y),
    @raylib.Vector2::new(right_x, right_y),
    hull_col,
  )

  @raylib.draw_circle(s.0.to_int(), s.1.to_int(), 6.0, core_col)
  @raylib.draw_circle_lines(
    s.0.to_int(),
    s.1.to_int(),
    10.0,
    @raylib.Color::new(
      core_col.r.to_int(),
      core_col.g.to_int(),
      core_col.b.to_int(),
      180,
    ),
  )

  if game.player.invuln > 0.0 {
    let blink = (game.player.invuln * 14.0).to_int() % 2 == 0
    if blink {
      @raylib.draw_circle_lines(
        s.0.to_int(),
        s.1.to_int(),
        player_hit_r + 2.0,
        @raylib.Color::new(255, 140, 188, 180),
      )
    }
  }
}

///|
fn draw_hud(game : Game) -> Unit {
  @raylib.draw_rectangle(14, 14, 530, 108, @raylib.Color::new(16, 20, 30, 202))
  @raylib.draw_rectangle_lines(
    14,
    14,
    530,
    108,
    @raylib.Color::new(130, 178, 220, 210),
  )

  @raylib.draw_text("SOLAR RAIL BREAKER", 28, 26, 30, ring_alpha())
  @raylib.draw_text(
    "Score: \{game.score}   Best: \{game.best_score}",
    30,
    56,
    22,
    @raylib.Color::new(232, 238, 250, 255),
  )
  @raylib.draw_text(
    "Stage \{game.stage}   Kills \{game.stage_kills}/\{game.stage_goal}   Combo x\{game.combo}",
    30,
    84,
    20,
    @raylib.Color::new(184, 214, 245, 255),
  )

  let hp_w = 280
  let hp_fill = (Float::from_int(hp_w) * game.hp / 100.0).to_int()
  @raylib.draw_rectangle(570, 24, hp_w, 16, @raylib.Color::new(46, 20, 30, 220))
  @raylib.draw_rectangle(570, 24, hp_fill, 16, hp_bar_col())
  @raylib.draw_rectangle_lines(
    570,
    24,
    hp_w,
    16,
    @raylib.Color::new(220, 236, 246, 220),
  )
  @raylib.draw_text("HULL", 570, 2, 16, @raylib.Color::new(236, 242, 250, 255))

  let phase_w = 280
  let phase_fill = (Float::from_int(phase_w) * game.phase / player_phase_max).to_int()
  @raylib.draw_rectangle(
    570,
    72,
    phase_w,
    16,
    @raylib.Color::new(22, 26, 44, 220),
  )
  @raylib.draw_rectangle(570, 72, phase_fill, 16, phase_bar_col())
  @raylib.draw_rectangle_lines(
    570,
    72,
    phase_w,
    16,
    @raylib.Color::new(220, 236, 246, 220),
  )
  @raylib.draw_text(
    if game.phase_beta {
      "PHASE BETA"
    } else {
      "PHASE ALPHA"
    },
    570,
    50,
    16,
    if game.phase_beta {
      ring_beta()
    } else {
      ring_alpha()
    },
  )

  let t = clampf(
    game.stage_time_left / (stage_time + Float::from_int(game.stage - 1) * 2.0),
    0.0,
    1.0,
  )
  let t_w = 360
  let t_fill = (Float::from_int(t_w) * t).to_int()
  @raylib.draw_rectangle(884, 24, t_w, 20, @raylib.Color::new(24, 30, 42, 220))
  @raylib.draw_rectangle(
    884,
    24,
    t_fill,
    20,
    @raylib.Color::new(142, 244, 188, 255),
  )
  @raylib.draw_rectangle_lines(
    884,
    24,
    t_w,
    20,
    @raylib.Color::new(220, 236, 246, 220),
  )
  @raylib.draw_text(
    "Time \{game.stage_time_left.to_int()}s",
    884,
    48,
    18,
    @raylib.Color::new(230, 238, 248, 255),
  )

  @raylib.draw_rectangle(1122, 68, 122, 44, @raylib.Color::new(20, 24, 34, 206))
  @raylib.draw_rectangle_lines(
    1122,
    68,
    122,
    44,
    @raylib.Color::new(166, 198, 226, 220),
  )
  @raylib.draw_text(
    "RESTART",
    1138,
    82,
    17,
    @raylib.Color::new(236, 242, 250, 255),
  )

  if game.hint_t > 0.0 {
    let alpha = clampi((game.hint_t / 7.0 * 255.0).to_int(), 0, 255)
    @raylib.draw_text(
      "Hint: phase shift to hit hidden enemies and avoid wrong gates",
      30,
      120,
      18,
      @raylib.Color::new(176, 228, 255, alpha),
    )
  }
}

///|
fn draw_button(
  x : Float,
  y : Float,
  w : Float,
  h : Float,
  hot : Bool,
  label : String,
  col : @raylib.Color,
) -> Unit {
  @raylib.draw_rectangle(
    x.to_int(),
    y.to_int(),
    w.to_int(),
    h.to_int(),
    @raylib.Color::new(18, 24, 38, 170),
  )

  let stroke = if hot { col } else { @raylib.Color::new(162, 190, 220, 190) }
  @raylib.draw_rectangle_lines(
    x.to_int(),
    y.to_int(),
    w.to_int(),
    h.to_int(),
    stroke,
  )

  let tw = @raylib.measure_text(label, 34)
  @raylib.draw_text(
    label,
    x.to_int() + w.to_int() / 2 - tw / 2,
    y.to_int() + h.to_int() / 2 - 16,
    34,
    if hot {
      @raylib.Color::new(250, 254, 255, 255)
    } else {
      @raylib.Color::new(220, 232, 248, 230)
    },
  )
}

///|
fn draw_touch_controls(
  _game : Game,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  let b_left = button_left_rect()
  let b_right = button_right_rect()
  let b_in = button_in_rect()
  let b_out = button_out_rect()
  let b_fire = button_fire_rect()
  let b_beam = beam_rect()

  let h_left = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    b_left.0,
    b_left.1,
    b_left.2,
    b_left.3,
  )
  let h_right = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    b_right.0,
    b_right.1,
    b_right.2,
    b_right.3,
  )
  let h_in = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    b_in.0,
    b_in.1,
    b_in.2,
    b_in.3,
  )
  let h_out = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    b_out.0,
    b_out.1,
    b_out.2,
    b_out.3,
  )
  let h_fire = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    b_fire.0,
    b_fire.1,
    b_fire.2,
    b_fire.3,
  )
  let h_beam = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    b_beam.0,
    b_beam.1,
    b_beam.2,
    b_beam.3,
  )

  draw_button(b_left.0, b_left.1, b_left.2, b_left.3, h_left, "<", ring_alpha())
  draw_button(
    b_right.0,
    b_right.1,
    b_right.2,
    b_right.3,
    h_right,
    ">",
    ring_alpha(),
  )
  draw_button(
    b_in.0,
    b_in.1,
    b_in.2,
    b_in.3,
    h_in,
    "IN",
    @raylib.Color::new(166, 214, 255, 255),
  )
  draw_button(
    b_out.0,
    b_out.1,
    b_out.2,
    b_out.3,
    h_out,
    "OUT",
    @raylib.Color::new(166, 214, 255, 255),
  )
  draw_button(b_fire.0, b_fire.1, b_fire.2, b_fire.3, h_fire, "F", ring_alpha())
  draw_button(b_beam.0, b_beam.1, b_beam.2, b_beam.3, h_beam, "B", ring_beta())

  @raylib.draw_text(
    "Mobile: < > rotate, IN/OUT switch rail, F fire, B beam",
    240,
    screen_h - 26,
    16,
    @raylib.Color::new(208, 224, 246, 210),
  )
}

///|
fn draw_title_overlay(game : Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(8, 10, 18, 140),
  )

  draw_center_text("SOLAR RAIL BREAKER 2026", 130, 66, ring_alpha())
  draw_center_text(
    "Orbit rails. Break enemy waves. Bend phase to survive.",
    212,
    30,
    @raylib.Color::new(230, 238, 248, 255),
  )

  @raylib.draw_rectangle(
    284,
    282,
    714,
    242,
    @raylib.Color::new(14, 20, 30, 218),
  )
  @raylib.draw_rectangle_lines(
    284,
    282,
    714,
    242,
    @raylib.Color::new(126, 182, 232, 220),
  )

  @raylib.draw_text(
    "A / D or Left / Right: orbit rotate",
    326,
    328,
    28,
    @raylib.Color::new(230, 238, 248, 255),
  )
  @raylib.draw_text(
    "W / S or Up / Down: switch rail",
    326,
    366,
    28,
    @raylib.Color::new(230, 238, 248, 255),
  )
  @raylib.draw_text(
    "Space / J: rapid fire",
    326,
    404,
    28,
    @raylib.Color::new(230, 238, 248, 255),
  )
  @raylib.draw_text(
    "K / L / Shift: phase beam",
    326,
    442,
    28,
    @raylib.Color::new(230, 238, 248, 255),
  )

  let blink = (game.time_s * 2.2).to_int() % 2 == 0
  draw_center_text(
    if blink {
      "Press Space or Tap to Start"
    } else {
      ""
    },
    572,
    36,
    ring_beta(),
  )
}

///|
fn draw_stage_clear_overlay(game : Game) -> Unit {
  let p = ease_in_out(1.0 - game.result_t / stage_clear_delay)
  let alpha = clampi((Float::from_int(90) + p * 90.0).to_int(), 0, 190)
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(10, 12, 24, alpha),
  )

  draw_center_text(
    "STAGE CLEAR",
    220,
    64,
    @raylib.Color::new(142, 250, 204, 255),
  )
  draw_center_text(
    "Bonus +\{game.stage_bonus}",
    292,
    44,
    @raylib.Color::new(255, 216, 132, 255),
  )
  draw_center_text(
    "Warping to next orbit...",
    356,
    28,
    @raylib.Color::new(230, 238, 248, 255),
  )
}

///|
fn draw_game_over_overlay(game : Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(8, 4, 14, 188),
  )

  draw_center_text(
    "CORE BREACH",
    184,
    70,
    @raylib.Color::new(255, 122, 164, 255),
  )
  draw_center_text(
    "Score \{game.score}",
    274,
    44,
    @raylib.Color::new(232, 238, 248, 255),
  )
  draw_center_text(
    "Best \{game.best_score}",
    328,
    36,
    @raylib.Color::new(170, 218, 255, 255),
  )

  @raylib.draw_rectangle(
    410,
    398,
    468,
    132,
    @raylib.Color::new(18, 22, 34, 224),
  )
  @raylib.draw_rectangle_lines(
    410,
    398,
    468,
    132,
    @raylib.Color::new(150, 194, 230, 220),
  )
  draw_center_text("Press R / Enter / Tap to Retry", 444, 34, ring_alpha())
}

///|
fn draw_world(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  draw_backdrop(game, cam_x, cam_y)
  draw_rings(game, cam_x, cam_y)
  draw_flares(game, cam_x, cam_y)
  draw_shocks(game, cam_x, cam_y)
  draw_enemies(game, cam_x, cam_y)
  draw_bullets(game, cam_x, cam_y)
  draw_particles(game, cam_x, cam_y)
  draw_player(game, cam_x, cam_y)
}

///|
fn draw_frame(
  game : Game,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  @raylib.clear_background(@raylib.black)

  let shake = shake_offset(game)
  draw_world(game, shake.0, shake.1)

  if game.state != state_title {
    draw_hud(game)
  }

  if game.touch_mode || touch_count > 0 {
    if game.state == state_play {
      draw_touch_controls(game, mx, my, hold, touch_count)
    }

    if game.touch_count > 0 {
      @raylib.draw_circle(
        game.pointer_x.to_int(),
        game.pointer_y.to_int(),
        7.0,
        @raylib.Color::new(162, 216, 255, 120),
      )
    }
  }

  if game.state == state_title {
    draw_title_overlay(game)
  } else if game.state == state_stage_clear {
    draw_stage_clear_overlay(game)
  } else if game.state == state_game_over {
    draw_game_over_overlay(game)
  }

  if game.flash_t > 0.0 {
    let a = clampi((game.flash_t * 155.0).to_int(), 0, 155)
    @raylib.draw_rectangle(
      0,
      0,
      screen_w,
      screen_h,
      @raylib.Color::new(188, 224, 255, a),
    )
  }
}
