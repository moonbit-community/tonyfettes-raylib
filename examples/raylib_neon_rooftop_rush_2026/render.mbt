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
    let power = game.shake_t * 14.0
    (randf(-power, power), randf(-power, power))
  }
}

///|
fn draw_skyline(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  let top_a = bg_night()
  let top_b = @raylib.Color::new(24, 24, 52, 255)
  @raylib.draw_rectangle_gradient_v(0, 0, screen_w, screen_h, top_a, top_b)

  for layer = 0; layer < skyline_layers; layer = layer + 1 {
    let p : Float = Float::from_int(layer) / Float::from_int(skyline_layers - 1)
    let speed : Float = 0.12 + p * 0.32
    let base_y : Float = 170.0 + p * 210.0
    let col_a = if layer == 0 {
      @raylib.Color::new(26, 34, 62, 220)
    } else if layer == 1 {
      @raylib.Color::new(34, 44, 76, 230)
    } else {
      @raylib.Color::new(42, 54, 94, 236)
    }

    for i = -1; i < 18; i = i + 1 {
      let bw = 90 + (i * 37 + layer * 23) % 140
      let bh = 120 + (i * 41 + layer * 17) % 240
      let x : Float = Float::from_int(i * 98) -
        game.distance * speed * 0.6 +
        cam_x * 0.4
      let y : Float = base_y + Float::from_int(260 - bh) + cam_y * 0.2

      @raylib.draw_rectangle(x.to_int(), y.to_int(), bw, bh, col_a)

      if layer == skyline_layers - 1 {
        let window_col = @raylib.Color::new(120, 210, 255, 88)
        let mut wy = y.to_int() + 12
        while wy < y.to_int() + bh - 8 {
          let mut wx = x.to_int() + 8
          while wx < x.to_int() + bw - 8 {
            if (wx + wy + i * 17) % 5 != 0 {
              @raylib.draw_rectangle(wx, wy, 4, 7, window_col)
            }
            wx = wx + 12
          }
          wy = wy + 14
        }
      }
    }
  }

  for i = 0; i < 44; i = i + 1 {
    let sx = (i * 67 + 39) % screen_w
    let sy = (i * 41 + 73) % (screen_h / 2)
    let phase = game.time_s * 0.7 + Float::from_int(i) * 0.4
    let pulse : Float = 0.5 + 0.32 * sinf(phase) + 0.18 * cosf(phase * 1.7)
    let c = @raylib.Color::new(
      110 + (pulse * 70.0).to_int(),
      130 + (pulse * 70.0).to_int(),
      200 + (pulse * 40.0).to_int(),
      130,
    )
    let star_r : Float = 1.2 + pulse * 1.8
    @raylib.draw_circle(sx, sy, star_r, c)
  }
}

///|
fn segment_color_base(seg : Segment) -> @raylib.Color {
  if seg.skin == 0 {
    @raylib.Color::new(34, 40, 58, 255)
  } else if seg.skin == 1 {
    @raylib.Color::new(42, 46, 64, 255)
  } else if seg.skin == 2 {
    @raylib.Color::new(30, 36, 50, 255)
  } else {
    @raylib.Color::new(38, 44, 62, 255)
  }
}

///|
fn segment_color_glow(seg : Segment) -> @raylib.Color {
  if seg.neon == 0 {
    neon_blue()
  } else if seg.neon == 1 {
    neon_pink()
  } else if seg.neon == 2 {
    neon_lime()
  } else {
    neon_orange()
  }
}

///|
fn draw_segments(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  for i = 0; i < game.segments.length(); i = i + 1 {
    if not(game.segments[i].active) {
      continue
    }

    let sx = game.segments[i].x + cam_x
    let sy = game.segments[i].y + cam_y
    let sw = game.segments[i].w
    let sh = game.segments[i].h

    if sx > Float::from_int(screen_w) + 50.0 || sx + sw < -50.0 {
      continue
    }

    let base_col = segment_color_base(game.segments[i])
    @raylib.draw_rectangle(
      sx.to_int(),
      sy.to_int(),
      sw.to_int(),
      sh.to_int(),
      base_col,
    )

    let glow = segment_color_glow(game.segments[i])
    @raylib.draw_rectangle(
      sx.to_int(),
      (sy - 6.0).to_int(),
      sw.to_int(),
      8,
      @raylib.Color::new(glow.r.to_int(), glow.g.to_int(), glow.b.to_int(), 170),
    )

    let seed = game.segments[i].window_seed
    let mut wy = sy.to_int() + 14
    while wy < sy.to_int() + sh.to_int() - 10 {
      let mut wx = sx.to_int() + 10
      while wx < sx.to_int() + sw.to_int() - 10 {
        let idx = (wx + wy + seed) % 7
        let alpha = if idx < 3 { 104 } else if idx == 3 { 140 } else { 70 }
        @raylib.draw_rectangle(
          wx,
          wy,
          6,
          9,
          @raylib.Color::new(
            glow.r.to_int(),
            glow.g.to_int(),
            glow.b.to_int(),
            alpha,
          ),
        )
        wx = wx + 14
      }
      wy = wy + 18
    }

    @raylib.draw_rectangle_lines(
      sx.to_int(),
      sy.to_int(),
      sw.to_int(),
      sh.to_int(),
      @raylib.Color::new(10, 12, 18, 130),
    )
  }
}

///|
fn draw_anchor(a : Anchor, cam_x : Float, cam_y : Float) -> Unit {
  if not(a.active) {
    return
  }

  let x = a.x + cam_x
  let y = a.y + cam_y
  if x < -60.0 || x > Float::from_int(screen_w) + 60.0 {
    return
  }

  let pulse : Float = 0.5 + 0.5 * sinf(a.glow_t)
  let core = color_mix(neon_blue(), neon_pink(), pulse)
  let halo_r : Float = 10.0 + pulse * 8.0

  @raylib.draw_circle(
    x.to_int(),
    y.to_int(),
    halo_r,
    @raylib.Color::new(core.r.to_int(), core.g.to_int(), core.b.to_int(), 80),
  )
  @raylib.draw_circle(x.to_int(), y.to_int(), 6.0, core)
  @raylib.draw_circle_lines(
    x.to_int(),
    y.to_int(),
    Float::from_int(12) + pulse * Float::from_int(5),
    @raylib.Color::new(core.r.to_int(), core.g.to_int(), core.b.to_int(), 170),
  )
}

///|
fn draw_obstacle(ob : Obstacle, cam_x : Float, cam_y : Float) -> Unit {
  if not(ob.active) {
    return
  }

  let x = ob.x + cam_x
  let y = ob.y + cam_y
  if x > Float::from_int(screen_w) + 80.0 || x + ob.w < -80.0 {
    return
  }

  if ob.kind == obstacle_vent {
    @raylib.draw_rectangle(
      x.to_int(),
      y.to_int(),
      ob.w.to_int(),
      ob.h.to_int(),
      @raylib.Color::new(98, 110, 132, 255),
    )
    @raylib.draw_rectangle_lines(
      x.to_int(),
      y.to_int(),
      ob.w.to_int(),
      ob.h.to_int(),
      @raylib.Color::new(20, 26, 34, 220),
    )
    for i = 0; i < 4; i = i + 1 {
      @raylib.draw_line(
        x.to_int() + 8,
        y.to_int() + 5 + i * 5,
        x.to_int() + ob.w.to_int() - 8,
        y.to_int() + 5 + i * 5,
        @raylib.Color::new(66, 74, 92, 240),
      )
    }
  } else if ob.kind == obstacle_sign {
    @raylib.draw_rectangle(
      x.to_int() + 6,
      y.to_int() + ob.h.to_int(),
      6,
      26,
      @raylib.Color::new(80, 90, 114, 255),
    )
    @raylib.draw_rectangle(
      x.to_int(),
      y.to_int(),
      ob.w.to_int(),
      ob.h.to_int(),
      @raylib.Color::new(38, 20, 40, 255),
    )
    @raylib.draw_rectangle_lines(
      x.to_int(),
      y.to_int(),
      ob.w.to_int(),
      ob.h.to_int(),
      neon_pink(),
    )
    @raylib.draw_text(
      "N",
      x.to_int() + ob.w.to_int() / 2 - 8,
      y.to_int() + 2,
      22,
      neon_pink(),
    )
  } else if ob.kind == obstacle_drone {
    let pulse : Float = 0.5 + 0.5 * sinf(ob.phase * 2.2)
    let glow = color_mix(neon_blue(), neon_pink(), pulse)
    @raylib.draw_ellipse(
      (x + ob.w * 0.5).to_int(),
      (y + ob.h * 0.5).to_int(),
      ob.w * 0.5,
      ob.h * 0.5,
      @raylib.Color::new(70, 76, 98, 255),
    )
    @raylib.draw_circle(
      (x + ob.w * 0.5).to_int(),
      (y + ob.h * 0.5).to_int(),
      8.0,
      glow,
    )
    @raylib.draw_circle_lines(
      (x + ob.w * 0.5).to_int(),
      (y + ob.h * 0.5).to_int(),
      Float::from_int(14) + pulse * Float::from_int(6),
      @raylib.Color::new(glow.r.to_int(), glow.g.to_int(), glow.b.to_int(), 160),
    )
    @raylib.draw_line(
      x.to_int() - 6,
      (y + ob.h * 0.5).to_int(),
      x.to_int() + ob.w.to_int() + 6,
      (y + ob.h * 0.5).to_int(),
      @raylib.Color::new(70, 78, 100, 240),
    )
  } else {
    let pulse : Float = 0.5 + 0.5 * sinf(ob.phase)
    let c = color_mix(neon_pink(), neon_orange(), pulse)
    @raylib.draw_rectangle(
      x.to_int(),
      y.to_int(),
      ob.w.to_int(),
      ob.h.to_int(),
      @raylib.Color::new(36, 22, 28, 255),
    )
    @raylib.draw_rectangle(
      x.to_int() + 5,
      y.to_int(),
      4,
      ob.h.to_int(),
      @raylib.Color::new(c.r.to_int(), c.g.to_int(), c.b.to_int(), 220),
    )
    @raylib.draw_rectangle(
      x.to_int() + ob.w.to_int() - 9,
      y.to_int(),
      4,
      ob.h.to_int(),
      @raylib.Color::new(c.r.to_int(), c.g.to_int(), c.b.to_int(), 220),
    )
  }
}

///|
fn draw_chips(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  for i = 0; i < game.chips.length(); i = i + 1 {
    if not(game.chips[i].active) {
      continue
    }

    let x = game.chips[i].x + cam_x
    let y = game.chips[i].y + sinf(game.chips[i].bob_t) * 9.0 + cam_y
    if x < -40.0 || x > Float::from_int(screen_w) + 40.0 {
      continue
    }

    let spin : Float = 0.5 + 0.5 * sinf(game.chips[i].spin_t)
    let glow = color_mix(neon_lime(), neon_blue(), spin)

    @raylib.draw_circle(
      x.to_int(),
      y.to_int(),
      Float::from_int(10) + spin * Float::from_int(2),
      @raylib.Color::new(glow.r.to_int(), glow.g.to_int(), glow.b.to_int(), 130),
    )
    @raylib.draw_rectangle((x - 6.0).to_int(), (y - 6.0).to_int(), 12, 12, glow)
    @raylib.draw_rectangle_lines(
      (x - 6.0).to_int(),
      (y - 6.0).to_int(),
      12,
      12,
      @raylib.Color::new(12, 18, 24, 220),
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
    let alpha = clampi((p.life * 255.0).to_int(), 0, 255)
    let col = if p.kind == 0 {
      @raylib.Color::new(130, 250, 216, alpha)
    } else if p.kind == 1 {
      @raylib.Color::new(98, 178, 255, alpha)
    } else {
      @raylib.Color::new(255, 108, 156, alpha)
    }

    @raylib.draw_circle(
      (p.x + cam_x).to_int(),
      (p.y + cam_y).to_int(),
      p.size,
      col,
    )
  }

  for i = 0; i < game.ghosts.length(); i = i + 1 {
    if not(game.ghosts[i].active) {
      continue
    }

    let g = game.ghosts[i]
    let a = clampi((g.life * 160.0).to_int(), 0, 160)
    let tint = if g.hue < 0.5 {
      @raylib.Color::new(96, 178, 255, a)
    } else {
      @raylib.Color::new(255, 116, 180, a)
    }

    @raylib.draw_rectangle(
      (g.x + cam_x).to_int(),
      (g.y + cam_y).to_int(),
      g.w.to_int(),
      g.h.to_int(),
      tint,
    )
  }
}

///|
fn draw_hero(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  let hero = game.hero

  let hx = hero.x + cam_x
  let hy = hero.y + cam_y
  let run_pulse : Float = 0.5 + 0.5 * sinf(hero.anim_t * 14.0)

  if hero.grapple_t > 0.0 {
    let anchor_y = hero.grapple_target_y
    @raylib.draw_line_ex(
      @raylib.Vector2::new(hx + hero.w * 0.5, hy + hero.h * 0.26),
      @raylib.Vector2::new(hx + hero.w * 1.35, anchor_y + cam_y),
      2.2,
      @raylib.Color::new(130, 220, 255, 210),
    )
  }

  let base_col = if hero.hurt_t > 0.0 {
    @raylib.Color::new(255, 126, 162, 255)
  } else {
    @raylib.Color::new(220, 236, 255, 255)
  }

  let suit_col = @raylib.Color::new(
    40 + (run_pulse * 24.0).to_int(),
    58 + (run_pulse * 20.0).to_int(),
    88 + (run_pulse * 26.0).to_int(),
    255,
  )

  if hero.slide_t > 0.0 {
    @raylib.draw_rectangle(
      (hx + 4.0).to_int(),
      (hy + hero.h * 0.35).to_int(),
      (hero.w - 8.0).to_int(),
      (hero.h * 0.58).to_int(),
      suit_col,
    )
    @raylib.draw_rectangle(
      (hx + hero.w * 0.62).to_int(),
      (hy + hero.h * 0.2).to_int(),
      14,
      14,
      base_col,
    )
  } else {
    @raylib.draw_rectangle(
      (hx + 8.0).to_int(),
      (hy + 20.0).to_int(),
      (hero.w - 16.0).to_int(),
      (hero.h - 20.0).to_int(),
      suit_col,
    )
    @raylib.draw_rectangle((hx + 18.0).to_int(), hy.to_int(), 28, 28, base_col)

    let leg_off = (run_pulse * 8.0).to_int()
    @raylib.draw_rectangle(
      (hx + 14.0).to_int(),
      (hy + hero.h - 16.0).to_int(),
      12,
      16 + leg_off,
      @raylib.Color::new(24, 30, 42, 255),
    )
    @raylib.draw_rectangle(
      (hx + 34.0).to_int(),
      (hy + hero.h - 16.0).to_int(),
      12,
      16 + (8 - leg_off),
      @raylib.Color::new(24, 30, 42, 255),
    )
  }

  if hero.invuln_t > 0.0 {
    let blink = (hero.invuln_t * 16.0).to_int() % 2 == 0
    if blink {
      @raylib.draw_rectangle_lines(
        hx.to_int() - 2,
        hy.to_int() - 2,
        hero.w.to_int() + 4,
        hero.h.to_int() + 4,
        neon_pink(),
      )
    }
  }
}

///|
fn draw_touch_controls(
  _game : Game,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  let jr = button_jump_rect()
  let sr = button_slide_rect()
  let gr = button_grapple_rect()

  let jump_hot = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    jr.0,
    jr.1,
    jr.2,
    jr.3,
  )
  let slide_hot = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    sr.0,
    sr.1,
    sr.2,
    sr.3,
  )
  let grapple_hot = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    gr.0,
    gr.1,
    gr.2,
    gr.3,
  )

  let btn_col = @raylib.Color::new(24, 28, 40, 160)
  let stroke = @raylib.Color::new(170, 208, 255, 180)

  @raylib.draw_rectangle(
    jr.0.to_int(),
    jr.1.to_int(),
    jr.2.to_int(),
    jr.3.to_int(),
    btn_col,
  )
  @raylib.draw_rectangle(
    sr.0.to_int(),
    sr.1.to_int(),
    sr.2.to_int(),
    sr.3.to_int(),
    btn_col,
  )
  @raylib.draw_rectangle(
    gr.0.to_int(),
    gr.1.to_int(),
    gr.2.to_int(),
    gr.3.to_int(),
    btn_col,
  )

  @raylib.draw_rectangle_lines(
    jr.0.to_int(),
    jr.1.to_int(),
    jr.2.to_int(),
    jr.3.to_int(),
    if jump_hot {
      neon_lime()
    } else {
      stroke
    },
  )
  @raylib.draw_rectangle_lines(
    sr.0.to_int(),
    sr.1.to_int(),
    sr.2.to_int(),
    sr.3.to_int(),
    if slide_hot {
      neon_orange()
    } else {
      stroke
    },
  )
  @raylib.draw_rectangle_lines(
    gr.0.to_int(),
    gr.1.to_int(),
    gr.2.to_int(),
    gr.3.to_int(),
    if grapple_hot {
      neon_blue()
    } else {
      stroke
    },
  )

  draw_center_text(
    "JUMP",
    jr.1.to_int() + 34,
    18,
    if jump_hot {
      neon_lime()
    } else {
      ui_light()
    },
  )
  @raylib.draw_text(
    "SLIDE",
    sr.0.to_int() + 20,
    sr.1.to_int() + 40,
    18,
    if slide_hot {
      neon_orange()
    } else {
      ui_light()
    },
  )
  @raylib.draw_text(
    "HOOK",
    gr.0.to_int() + 24,
    gr.1.to_int() + 40,
    18,
    if grapple_hot {
      neon_blue()
    } else {
      ui_light()
    },
  )
}

///|
fn draw_hud(game : Game) -> Unit {
  @raylib.draw_rectangle(16, 14, 450, 108, ui_dark())
  @raylib.draw_rectangle_lines(
    16,
    14,
    450,
    108,
    @raylib.Color::new(130, 174, 220, 190),
  )

  @raylib.draw_text("NEON ROOFTOP RUSH", 28, 24, 28, neon_blue())
  @raylib.draw_text(
    "Score: \{game.score}   Best: \{game.best_score}",
    30,
    56,
    22,
    ui_light(),
  )
  @raylib.draw_text(
    "Stage \{game.stage}   Chips \{game.chips_collected}   Combo x\{game.combo}",
    30,
    82,
    20,
    @raylib.Color::new(182, 214, 255, 255),
  )

  let health_w = 250
  let health_fill = (Float::from_int(health_w) * game.health / 100.0).to_int()
  @raylib.draw_rectangle(
    500,
    24,
    health_w,
    16,
    @raylib.Color::new(42, 16, 24, 210),
  )
  @raylib.draw_rectangle(
    500,
    24,
    health_fill,
    16,
    @raylib.Color::new(255, 96, 126, 255),
  )
  @raylib.draw_rectangle_lines(
    500,
    24,
    health_w,
    16,
    @raylib.Color::new(220, 240, 250, 200),
  )
  @raylib.draw_text("HEALTH", 500, 2, 16, ui_light())

  let stamina_w = 250
  let stamina_fill = (Float::from_int(stamina_w) * game.stamina / 100.0).to_int()
  @raylib.draw_rectangle(
    500,
    70,
    stamina_w,
    16,
    @raylib.Color::new(20, 26, 44, 210),
  )
  @raylib.draw_rectangle(
    500,
    70,
    stamina_fill,
    16,
    @raylib.Color::new(90, 182, 255, 255),
  )
  @raylib.draw_rectangle_lines(
    500,
    70,
    stamina_w,
    16,
    @raylib.Color::new(220, 240, 250, 200),
  )
  @raylib.draw_text("GRAPPLE", 500, 48, 16, ui_light())

  let stage_p = clampf(
    game.stage_progress / maxf(1.0, game.stage_goal),
    0.0,
    1.0,
  )
  let meter_w = 310
  let meter_fill = (Float::from_int(meter_w) * stage_p).to_int()
  @raylib.draw_rectangle(
    840,
    24,
    meter_w,
    18,
    @raylib.Color::new(26, 30, 40, 210),
  )
  @raylib.draw_rectangle(
    840,
    24,
    meter_fill,
    18,
    @raylib.Color::new(132, 244, 194, 255),
  )
  @raylib.draw_rectangle_lines(
    840,
    24,
    meter_w,
    18,
    @raylib.Color::new(210, 242, 230, 200),
  )
  @raylib.draw_text(
    "Stage Progress \{(stage_p * 100.0).to_int()}%",
    840,
    46,
    18,
    ui_light(),
  )

  @raylib.draw_rectangle(1146, 14, 118, 46, @raylib.Color::new(20, 24, 34, 196))
  @raylib.draw_rectangle_lines(
    1146,
    14,
    118,
    46,
    @raylib.Color::new(160, 194, 230, 210),
  )
  @raylib.draw_text(
    "RESTART",
    1161,
    30,
    16,
    @raylib.Color::new(228, 236, 246, 255),
  )

  if game.stage_intro_t > 0.0 {
    let alpha = clampi(
      (game.stage_intro_t / stage_intro_time * 255.0).to_int(),
      0,
      255,
    )
    draw_center_text(
      "Stage \{game.stage}",
      154,
      46,
      @raylib.Color::new(230, 252, 255, alpha),
    )
  }

  if game.hint_t > 0.0 {
    let a = clampi((game.hint_t / 8.0 * 255.0).to_int(), 0, 255)
    @raylib.draw_text(
      "Hint: chain chips + hook takedowns to keep combo alive",
      28,
      118,
      18,
      @raylib.Color::new(170, 228, 255, a),
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
    @raylib.Color::new(6, 8, 18, 120),
  )

  draw_center_text("NEON ROOFTOP RUSH 2026", 146, 70, neon_blue())
  draw_center_text(
    "Sprint rooftops, chain combos, hook across city gaps",
    236,
    28,
    ui_light(),
  )

  @raylib.draw_rectangle(
    318,
    302,
    644,
    234,
    @raylib.Color::new(14, 20, 30, 210),
  )
  @raylib.draw_rectangle_lines(
    318,
    302,
    644,
    234,
    @raylib.Color::new(120, 184, 236, 220),
  )

  @raylib.draw_text("Controls", 348, 326, 34, neon_lime())
  @raylib.draw_text("Jump: Space / W / Up", 356, 374, 26, ui_light())
  @raylib.draw_text("Slide: S / Down / Shift", 356, 408, 26, ui_light())
  @raylib.draw_text("Grapple Hook: J / K / L", 356, 442, 26, ui_light())
  @raylib.draw_text(
    "Mobile: tap on-screen Jump / Slide / Hook",
    356,
    476,
    24,
    ui_light(),
  )

  let blink = (game.title_t * 2.4).to_int() % 2 == 0
  draw_center_text(
    if blink {
      "Press Space or Tap to Start"
    } else {
      ""
    },
    586,
    36,
    neon_pink(),
  )
}

///|
fn draw_stage_clear_overlay(game : Game) -> Unit {
  let p = ease_in_out(1.0 - game.stage_intro_t / 1.5)
  let alpha = clampi(
    (Float::from_int(90) + p * Float::from_int(80)).to_int(),
    0,
    180,
  )
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(10, 12, 24, alpha),
  )
  draw_center_text("STAGE CLEAR", 220, 64, neon_lime())
  draw_center_text("Bonus +\{game.stage_clear_bonus}", 292, 44, neon_orange())
  draw_center_text("Preparing next rooftop zone...", 356, 28, ui_light())
}

///|
fn draw_game_over_overlay(game : Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(8, 6, 16, 180),
  )

  draw_center_text(
    "RUN FAILED",
    184,
    72,
    @raylib.Color::new(255, 120, 154, 255),
  )
  draw_center_text("Score \{game.score}", 276, 44, ui_light())
  draw_center_text(
    "Best \{game.best_score}",
    330,
    36,
    @raylib.Color::new(170, 216, 255, 255),
  )

  @raylib.draw_rectangle(
    404,
    398,
    470,
    138,
    @raylib.Color::new(18, 24, 34, 220),
  )
  @raylib.draw_rectangle_lines(
    404,
    398,
    470,
    138,
    @raylib.Color::new(150, 192, 230, 220),
  )
  draw_center_text("Press R / Enter / Tap to Retry", 446, 34, neon_blue())
}

///|
fn draw_game_world(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  draw_skyline(game, cam_x, cam_y)

  for i = 0; i < game.anchors.length(); i = i + 1 {
    draw_anchor(game.anchors[i], cam_x, cam_y)
  }

  draw_segments(game, cam_x, cam_y)

  for i = 0; i < game.obstacles.length(); i = i + 1 {
    draw_obstacle(game.obstacles[i], cam_x, cam_y)
  }

  draw_chips(game, cam_x, cam_y)
  draw_particles(game, cam_x, cam_y)
  draw_hero(game, cam_x, cam_y)
}

///|
fn draw_frame(
  game : Game,
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  @raylib.clear_background(bg_haze())

  let shake = shake_offset(game)
  draw_game_world(game, shake.0, shake.1)

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
        @raylib.Color::new(160, 218, 255, 120),
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
    let a = clampi((game.flash_t * 150.0).to_int(), 0, 150)
    @raylib.draw_rectangle(
      0,
      0,
      screen_w,
      screen_h,
      @raylib.Color::new(180, 220, 255, a),
    )
  }
}
