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
    let p = game.shake_t * 22.0
    (randf(-p, p), randf(-p, p))
  }
}

///|
fn world_to_screen(
  lane_x : Float,
  y_off : Float,
  z : Float,
  cam_x : Float,
  cam_y : Float,
) -> (Float, Float, Float) {
  let scale = proj_scale(z)
  let sx = lane_screen_x(lane_x, z) + cam_x
  let sy = track_y(z) - y_off * scale + cam_y
  (sx, sy, scale)
}

///|
fn draw_backdrop(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  @raylib.draw_rectangle_gradient_v(
    0,
    0,
    screen_w,
    screen_h,
    color_bg_top(),
    color_bg_bottom(),
  )

  for i = 0; i < 64; i = i + 1 {
    let x = (i * 71 + 29) % screen_w
    let y = (i * 37 + 61) % (screen_h / 2)
    let phase : Float = game.title_t * 0.7 + Float::from_int(i) * 0.33
    let pulse : Float = Float::from_int(1) * 0.5 +
      0.3 * sinf(phase) +
      0.2 * cosf(phase * 1.9)
    let star_r : Float = Float::from_int(1) + pulse * 1.8
    @raylib.draw_circle(
      x,
      y,
      star_r,
      @raylib.Color::new(
        130 + (pulse * 60.0).to_int(),
        150 + (pulse * 70.0).to_int(),
        220 + (pulse * 30.0).to_int(),
        120,
      ),
    )
  }

  for i = 0; i < 11; i = i + 1 {
    let bw = 130 + i * 43 % 220
    let bh = 120 + i * 67 % 220
    let x = Float::from_int(i * 132) - game.stage_progress * 0.04 + cam_x * 0.4
    let y = Float::from_int(screen_h - bh - 280) + cam_y * 0.3
    @raylib.draw_rectangle(
      x.to_int(),
      y.to_int(),
      bw,
      bh,
      @raylib.Color::new(32, 40, 70, 180),
    )
  }
}

///|
fn draw_track_grid(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  let lane_col = if game.phase_beta {
    @raylib.Color::new(255, 126, 234, 170)
  } else {
    @raylib.Color::new(104, 230, 255, 170)
  }

  for lane = 0; lane < lane_count; lane = lane + 1 {
    let lane_x = lane_world_x(lane)
    let p0 = world_to_screen(lane_x, 0.0, 0.0, cam_x, cam_y)
    let p1 = world_to_screen(lane_x, 0.0, 2500.0, cam_x, cam_y)

    @raylib.draw_line_ex(
      @raylib.Vector2::new(p0.0, p0.1),
      @raylib.Vector2::new(p1.0, p1.1),
      2.0,
      lane_col,
    )
  }

  for step = 0; step < 26; step = step + 1 {
    let z = Float::from_int(step * 100)
    let left = world_to_screen(lane_world_x(0) - 82.0, 0.0, z, cam_x, cam_y)
    let right = world_to_screen(
      lane_world_x(lane_count - 1) + 82.0,
      0.0,
      z,
      cam_x,
      cam_y,
    )

    let pulse : Float = 0.5 + 0.5 * sinf(game.title_t * 1.5 + z * 0.004)
    let line_w : Float = Float::from_int(1) + pulse * 2.0
    @raylib.draw_line_ex(
      @raylib.Vector2::new(left.0, left.1),
      @raylib.Vector2::new(right.0, right.1),
      line_w,
      @raylib.Color::new(
        lane_col.r.to_int(),
        lane_col.g.to_int(),
        lane_col.b.to_int(),
        70 + (pulse * 90.0).to_int(),
      ),
    )
  }
}

///|
fn obj_color(game : Game, o : TrackObj) -> @raylib.Color {
  if o.kind == obj_orb {
    @raylib.Color::new(140, 248, 212, 255)
  } else if o.kind == obj_boost {
    @raylib.Color::new(255, 210, 110, 255)
  } else if o.kind == obj_jump_bar {
    @raylib.Color::new(255, 168, 96, 255)
  } else if o.kind == obj_gate_alpha {
    if game.phase_beta {
      @raylib.Color::new(120, 140, 170, 170)
    } else {
      color_lane_alpha()
    }
  } else if o.kind == obj_gate_beta {
    if game.phase_beta {
      color_lane_beta()
    } else {
      @raylib.Color::new(120, 140, 170, 170)
    }
  } else {
    @raylib.Color::new(242, 112, 160, 255)
  }
}

///|
fn draw_obj(game : Game, o : TrackObj, cam_x : Float, cam_y : Float) -> Unit {
  if not(o.active) {
    return
  }

  if o.z < 0.0 || o.z > 2600.0 {
    return
  }

  let lane_x = lane_world_x(o.lane)
  let s = world_to_screen(lane_x, o.y_off, o.z, cam_x, cam_y)

  let w = maxf(8.0, o.w * s.2)
  let h = maxf(8.0, o.h * s.2)
  let col = obj_color(game, o)

  if o.kind == obj_orb {
    let pulse : Float = 0.5 + 0.5 * sinf(o.spin * 2.6)
    let orb_r : Float = w * 0.36 + pulse * 3.0
    @raylib.draw_circle(
      s.0.to_int(),
      s.1.to_int(),
      orb_r,
      @raylib.Color::new(col.r.to_int(), col.g.to_int(), col.b.to_int(), 130),
    )
    @raylib.draw_rectangle(
      (s.0 - w * 0.28).to_int(),
      (s.1 - h * 0.28).to_int(),
      (w * 0.56).to_int(),
      (h * 0.56).to_int(),
      col,
    )
    @raylib.draw_rectangle_lines(
      (s.0 - w * 0.28).to_int(),
      (s.1 - h * 0.28).to_int(),
      (w * 0.56).to_int(),
      (h * 0.56).to_int(),
      @raylib.Color::new(16, 24, 34, 220),
    )
    return
  }

  if o.kind == obj_boost {
    let pulse : Float = 0.5 + 0.5 * sinf(o.spin * 2.8)
    let boost_r : Float = Float::from_int(4) + pulse * Float::from_int(4)
    @raylib.draw_rectangle(
      (s.0 - w * 0.55).to_int(),
      (s.1 - h * 0.15).to_int(),
      (w * 1.10).to_int(),
      (h * 0.28).to_int(),
      col,
    )
    @raylib.draw_rectangle_lines(
      (s.0 - w * 0.55).to_int(),
      (s.1 - h * 0.15).to_int(),
      (w * 1.10).to_int(),
      (h * 0.28).to_int(),
      @raylib.Color::new(30, 24, 12, 220),
    )
    @raylib.draw_circle(
      s.0.to_int(),
      (s.1 - h * 0.02).to_int(),
      boost_r,
      @raylib.Color::new(255, 236, 180, 190),
    )
    return
  }

  if o.kind == obj_jump_bar {
    @raylib.draw_rectangle(
      (s.0 - w * 0.5).to_int(),
      (s.1 - h * 0.2).to_int(),
      w.to_int(),
      (h * 0.24).to_int(),
      col,
    )
    @raylib.draw_rectangle_lines(
      (s.0 - w * 0.5).to_int(),
      (s.1 - h * 0.2).to_int(),
      w.to_int(),
      (h * 0.24).to_int(),
      @raylib.Color::new(28, 24, 20, 220),
    )
    return
  }

  @raylib.draw_rectangle(
    (s.0 - w * 0.5).to_int(),
    (s.1 - h).to_int(),
    w.to_int(),
    h.to_int(),
    col,
  )
  @raylib.draw_rectangle_lines(
    (s.0 - w * 0.5).to_int(),
    (s.1 - h).to_int(),
    w.to_int(),
    h.to_int(),
    @raylib.Color::new(12, 18, 28, 230),
  )

  if o.kind == obj_gate_alpha || o.kind == obj_gate_beta {
    let alpha = 110 +
      (Float::from_int(1) * 0.5 + 0.5 * sinf(o.spin * 2.0) * 100.0).to_int()
    @raylib.draw_rectangle(
      (s.0 - w * 0.34).to_int(),
      (s.1 - h).to_int(),
      (w * 0.68).to_int(),
      h.to_int(),
      @raylib.Color::new(
        col.r.to_int(),
        col.g.to_int(),
        col.b.to_int(),
        clampi(alpha, 50, 220),
      ),
    )
  }
}

///|
fn draw_trails(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  for i = 0; i < game.trails.length(); i = i + 1 {
    if not(game.trails[i].active) {
      continue
    }

    let t = game.trails[i]
    let s = world_to_screen(t.x, t.y, 0.0, cam_x, cam_y)
    let alpha = clampi((t.life * 255.0).to_int(), 0, 255)
    let col = if t.beta {
      @raylib.Color::new(255, 140, 234, alpha)
    } else {
      @raylib.Color::new(112, 228, 255, alpha)
    }

    @raylib.draw_rectangle(
      (s.0 - t.w * 0.5).to_int(),
      (s.1 + 20.0 - t.h * 0.5).to_int(),
      t.w.to_int(),
      t.h.to_int(),
      col,
    )
  }
}

///|
fn draw_particles(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  for i = 0; i < game.particles.length(); i = i + 1 {
    if not(game.particles[i].active) {
      continue
    }

    let p = game.particles[i]
    let s = world_to_screen(p.x, p.y, 0.0, cam_x, cam_y)
    let alpha = clampi((p.life * 255.0).to_int(), 0, 255)
    let col = if p.kind == 0 {
      @raylib.Color::new(130, 248, 214, alpha)
    } else if p.kind == 1 {
      @raylib.Color::new(118, 192, 255, alpha)
    } else {
      @raylib.Color::new(255, 124, 172, alpha)
    }

    @raylib.draw_circle(s.0.to_int(), s.1.to_int(), p.size, col)
  }
}

///|
fn draw_player(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  let hero = game.hero
  let s = world_to_screen(hero.lane_f, hero.y, 0.0, cam_x, cam_y)

  let body_w : Float = Float::from_int(84)
  let body_h : Float = Float::from_int(116)

  let phase_col = if game.phase_beta {
    color_lane_beta()
  } else {
    color_lane_alpha()
  }

  let suit_p : Float = 0.5 + 0.5 * sinf(hero.anim_t * 10.0) * 18.0
  let suit = @raylib.Color::new(
    30 + suit_p.to_int(),
    52 + suit_p.to_int(),
    88 + suit_p.to_int(),
    255,
  )

  @raylib.draw_rectangle(
    (s.0 - body_w * 0.5).to_int(),
    (s.1 - body_h).to_int(),
    body_w.to_int(),
    body_h.to_int(),
    suit,
  )
  @raylib.draw_rectangle(
    (s.0 - Float::from_int(22)).to_int(),
    (s.1 - body_h - Float::from_int(28)).to_int(),
    44,
    34,
    @raylib.Color::new(226, 236, 250, 255),
  )

  @raylib.draw_rectangle(
    (s.0 - Float::from_int(26)).to_int(),
    (s.1 - Float::from_int(12)).to_int(),
    52,
    12,
    phase_col,
  )

  if hero.invuln_t > 0.0 {
    let blink = (hero.invuln_t * 12.0).to_int() % 2 == 0
    if blink {
      @raylib.draw_rectangle_lines(
        (s.0 - body_w * 0.5 - Float::from_int(3)).to_int(),
        (s.1 - body_h - Float::from_int(3)).to_int(),
        (body_w + 6.0).to_int(),
        (body_h + 6.0).to_int(),
        color_lane_beta(),
      )
    }
  }
}

///|
fn draw_touch_controls(
  game : Game,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  let l = button_left_rect()
  let r = button_right_rect()
  let j = button_jump_rect()
  let p = button_phase_rect()

  let l_hot = pointer_on_rect(mx, my, hold, touch_count, l.0, l.1, l.2, l.3)
  let r_hot = pointer_on_rect(mx, my, hold, touch_count, r.0, r.1, r.2, r.3)
  let j_hot = pointer_on_rect(mx, my, hold, touch_count, j.0, j.1, j.2, j.3)
  let p_hot = pointer_on_rect(mx, my, hold, touch_count, p.0, p.1, p.2, p.3)

  let base = @raylib.Color::new(18, 24, 40, 170)
  @raylib.draw_rectangle(
    l.0.to_int(),
    l.1.to_int(),
    l.2.to_int(),
    l.3.to_int(),
    base,
  )
  @raylib.draw_rectangle(
    r.0.to_int(),
    r.1.to_int(),
    r.2.to_int(),
    r.3.to_int(),
    base,
  )
  @raylib.draw_rectangle(
    j.0.to_int(),
    j.1.to_int(),
    j.2.to_int(),
    j.3.to_int(),
    base,
  )
  @raylib.draw_rectangle(
    p.0.to_int(),
    p.1.to_int(),
    p.2.to_int(),
    p.3.to_int(),
    base,
  )

  @raylib.draw_rectangle_lines(
    l.0.to_int(),
    l.1.to_int(),
    l.2.to_int(),
    l.3.to_int(),
    if l_hot {
      color_lane_alpha()
    } else {
      @raylib.Color::new(160, 188, 222, 180)
    },
  )
  @raylib.draw_rectangle_lines(
    r.0.to_int(),
    r.1.to_int(),
    r.2.to_int(),
    r.3.to_int(),
    if r_hot {
      color_lane_alpha()
    } else {
      @raylib.Color::new(160, 188, 222, 180)
    },
  )
  @raylib.draw_rectangle_lines(
    j.0.to_int(),
    j.1.to_int(),
    j.2.to_int(),
    j.3.to_int(),
    if j_hot {
      color_lane_alpha()
    } else {
      @raylib.Color::new(160, 188, 222, 180)
    },
  )
  @raylib.draw_rectangle_lines(
    p.0.to_int(),
    p.1.to_int(),
    p.2.to_int(),
    p.3.to_int(),
    if p_hot {
      color_lane_beta()
    } else {
      @raylib.Color::new(160, 188, 222, 180)
    },
  )

  @raylib.draw_text(
    "<",
    l.0.to_int() + 42,
    l.1.to_int() + 30,
    42,
    ui_text(game, l_hot),
  )
  @raylib.draw_text(
    ">",
    r.0.to_int() + 42,
    r.1.to_int() + 30,
    42,
    ui_text(game, r_hot),
  )
  @raylib.draw_text(
    "J",
    j.0.to_int() + 38,
    j.1.to_int() + 30,
    42,
    ui_text(game, j_hot),
  )
  @raylib.draw_text(
    "P",
    p.0.to_int() + 38,
    p.1.to_int() + 30,
    42,
    ui_text(game, p_hot),
  )
}

///|
fn ui_text(_game : Game, active : Bool) -> @raylib.Color {
  if active {
    @raylib.Color::new(252, 254, 255, 255)
  } else {
    @raylib.Color::new(218, 232, 250, 220)
  }
}

///|
fn draw_hud(game : Game) -> Unit {
  @raylib.draw_rectangle(16, 16, 550, 108, @raylib.Color::new(14, 18, 30, 196))
  @raylib.draw_rectangle_lines(
    16,
    16,
    550,
    108,
    @raylib.Color::new(132, 188, 234, 190),
  )

  @raylib.draw_text("QUANTUM SKATER", 30, 28, 30, color_lane_alpha())
  @raylib.draw_text(
    "Score: \{game.score}   Best: \{game.best_score}",
    30,
    58,
    22,
    @raylib.Color::new(228, 238, 252, 255),
  )
  @raylib.draw_text(
    "Stage \{game.stage}   Orbs \{game.orbs}   Combo x\{game.combo}",
    30,
    86,
    20,
    @raylib.Color::new(184, 214, 246, 255),
  )

  let hp_w = 280
  let hp_fill = (Float::from_int(hp_w) * game.health / 100.0).to_int()
  @raylib.draw_rectangle(590, 24, hp_w, 16, @raylib.Color::new(48, 20, 28, 210))
  @raylib.draw_rectangle(590, 24, hp_fill, 16, color_hp_bar())
  @raylib.draw_rectangle_lines(
    590,
    24,
    hp_w,
    16,
    @raylib.Color::new(220, 236, 250, 210),
  )
  @raylib.draw_text(
    "HEALTH",
    590,
    2,
    16,
    @raylib.Color::new(240, 244, 250, 255),
  )

  let ph_w = 280
  let ph_fill = (Float::from_int(ph_w) * game.phase_energy / 100.0).to_int()
  @raylib.draw_rectangle(590, 72, ph_w, 16, @raylib.Color::new(22, 26, 46, 210))
  @raylib.draw_rectangle(590, 72, ph_fill, 16, color_phase_bar())
  @raylib.draw_rectangle_lines(
    590,
    72,
    ph_w,
    16,
    @raylib.Color::new(220, 236, 250, 210),
  )
  @raylib.draw_text(
    if game.phase_beta {
      "PHASE BETA"
    } else {
      "PHASE ALPHA"
    },
    590,
    50,
    16,
    if game.phase_beta {
      color_lane_beta()
    } else {
      color_lane_alpha()
    },
  )

  let p = clampf(game.stage_progress / maxf(1.0, game.stage_goal), 0.0, 1.0)
  let meter_w = 360
  let meter_fill = (Float::from_int(meter_w) * p).to_int()
  @raylib.draw_rectangle(
    900,
    24,
    meter_w,
    20,
    @raylib.Color::new(24, 30, 42, 220),
  )
  @raylib.draw_rectangle(
    900,
    24,
    meter_fill,
    20,
    @raylib.Color::new(132, 248, 196, 255),
  )
  @raylib.draw_rectangle_lines(
    900,
    24,
    meter_w,
    20,
    @raylib.Color::new(220, 238, 248, 220),
  )
  @raylib.draw_text(
    "TRACK \{(p * 100.0).to_int()}%",
    900,
    48,
    18,
    @raylib.Color::new(226, 236, 248, 255),
  )

  @raylib.draw_rectangle(1220, 14, 130, 44, @raylib.Color::new(20, 24, 34, 206))
  @raylib.draw_rectangle_lines(
    1220,
    14,
    130,
    44,
    @raylib.Color::new(164, 196, 226, 210),
  )
  @raylib.draw_text(
    "RESTART",
    1238,
    28,
    17,
    @raylib.Color::new(236, 242, 250, 255),
  )

  if game.hint_t > 0.0 {
    let a = clampi((game.hint_t / 9.0 * 255.0).to_int(), 0, 255)
    @raylib.draw_text(
      "Hint: Shift phase to pass matching gates",
      30,
      124,
      18,
      @raylib.Color::new(176, 228, 255, a),
    )
  }
}

///|
fn draw_title_overlay(game : Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(8, 10, 20, 130),
  )

  draw_center_text("QUANTUM SKATER 2026", 132, 74, color_lane_alpha())
  draw_center_text(
    "Shift phase lanes. Jump barriers. Keep your combo alive.",
    226,
    30,
    @raylib.Color::new(228, 238, 248, 255),
  )

  @raylib.draw_rectangle(
    300,
    288,
    760,
    232,
    @raylib.Color::new(14, 20, 34, 214),
  )
  @raylib.draw_rectangle_lines(
    300,
    288,
    760,
    232,
    @raylib.Color::new(130, 188, 240, 220),
  )

  @raylib.draw_text(
    "A/D or Left/Right: lane swap",
    340,
    330,
    28,
    @raylib.Color::new(230, 240, 252, 255),
  )
  @raylib.draw_text(
    "Space / W / Up: jump",
    340,
    368,
    28,
    @raylib.Color::new(230, 240, 252, 255),
  )
  @raylib.draw_text(
    "E / Shift / K: phase shift",
    340,
    406,
    28,
    @raylib.Color::new(230, 240, 252, 255),
  )
  @raylib.draw_text(
    "Mobile: use <- -> J P buttons",
    340,
    444,
    26,
    @raylib.Color::new(230, 240, 252, 255),
  )

  let blink = (game.title_t * 2.2).to_int() % 2 == 0
  draw_center_text(
    if blink {
      "Press Space or Tap to Start"
    } else {
      ""
    },
    570,
    38,
    color_lane_beta(),
  )
}

///|
fn draw_stage_clear_overlay(game : Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(8, 12, 20, 92),
  )
  draw_center_text(
    "STAGE CLEAR",
    226,
    68,
    @raylib.Color::new(142, 250, 206, 255),
  )
  draw_center_text(
    "Bonus +\{game.stage_bonus}",
    302,
    44,
    @raylib.Color::new(255, 214, 136, 255),
  )
  draw_center_text(
    "Warping to next corridor...",
    360,
    30,
    @raylib.Color::new(228, 238, 248, 255),
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
    "SYSTEM CRASH",
    186,
    70,
    @raylib.Color::new(255, 120, 160, 255),
  )
  draw_center_text(
    "Score \{game.score}",
    280,
    44,
    @raylib.Color::new(230, 238, 248, 255),
  )
  draw_center_text(
    "Best \{game.best_score}",
    334,
    36,
    @raylib.Color::new(176, 220, 255, 255),
  )

  @raylib.draw_rectangle(
    420,
    402,
    520,
    130,
    @raylib.Color::new(18, 22, 34, 224),
  )
  @raylib.draw_rectangle_lines(
    420,
    402,
    520,
    130,
    @raylib.Color::new(150, 190, 228, 220),
  )
  draw_center_text(
    "Press R / Enter / Tap to Retry",
    448,
    34,
    color_lane_alpha(),
  )
}

///|
fn draw_world(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  draw_backdrop(game, cam_x, cam_y)
  draw_track_grid(game, cam_x, cam_y)

  for i = 0; i < game.objs.length(); i = i + 1 {
    draw_obj(game, game.objs[i], cam_x, cam_y)
  }

  draw_trails(game, cam_x, cam_y)
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
        8.0,
        @raylib.Color::new(160, 218, 255, 116),
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
    let a = clampi((game.flash_t * 160.0).to_int(), 0, 160)
    @raylib.draw_rectangle(
      0,
      0,
      screen_w,
      screen_h,
      @raylib.Color::new(188, 224, 255, a),
    )
  }
}
