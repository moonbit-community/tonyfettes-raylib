///|
fn draw_center_text(
  text : String,
  y : Int,
  size : Int,
  col : @raylib.Color,
) -> Unit {
  let tw = @raylib.measure_text(text, size)
  @raylib.draw_text(text, @types.screen_w / 2 - tw / 2, y, size, col)
}

///|
fn draw_right_text(
  text : String,
  x : Int,
  y : Int,
  size : Int,
  col : @raylib.Color,
) -> Unit {
  let tw = @raylib.measure_text(text, size)
  @raylib.draw_text(text, x - tw, y, size, col)
}

///|
fn draw_bar(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  value : Float,
  maxv : Float,
  label : String,
  col : @raylib.Color,
) -> Unit {
  let ratio : Float = if maxv <= 0.0 {
    Float::from_int(0)
  } else {
    @types.clampf(value / maxv, 0.0, 1.0)
  }

  @raylib.draw_rectangle(x, y, w, h, @raylib.Color::new(8, 16, 28, 220))
  @raylib.draw_rectangle(
    x,
    y,
    (Float::from_int(w) * ratio).to_int(),
    h,
    @raylib.Color::new(col.r.to_int(), col.g.to_int(), col.b.to_int(), 240),
  )
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(160, 210, 244, 180),
  )

  @raylib.draw_text(
    label,
    x + 8,
    y + h / 2 - 8,
    17,
    @raylib.Color::new(218, 240, 255, 230),
  )
}

///|
fn shake_offset(game : @types.Game) -> (Float, Float) {
  if game.shake_t <= 0.0 {
    (0.0, 0.0)
  } else {
    let p = game.shake_t * 22.0
    (@types.randf(-p, p), @types.randf(-p, p))
  }
}

///|
fn draw_sky(game : @types.Game, cam_x : Float, cam_y : Float) -> Unit {
  @raylib.draw_rectangle_gradient_v(
    0,
    0,
    @types.screen_w,
    @types.screen_h,
    @types.bg_top(),
    @types.bg_bottom(),
  )

  let g0x = Float::from_int(@types.screen_w) * 0.2 +
    @types.sinf(game.time_s * 0.28) * 140.0
  let g0y = Float::from_int(@types.screen_h) * 0.22 +
    @types.cosf(game.time_s * 0.24) * 70.0
  @raylib.draw_circle(
    (g0x + cam_x).to_int(),
    (g0y + cam_y).to_int(),
    240.0,
    @raylib.Color::new(46, 102, 184, 40),
  )

  let g1x = Float::from_int(@types.screen_w) * 0.8 +
    @types.sinf(game.time_s * 0.22 + 0.9) * 130.0
  let g1y = Float::from_int(@types.screen_h) * 0.74 +
    @types.cosf(game.time_s * 0.16 + 1.1) * 80.0
  @raylib.draw_circle(
    (g1x + cam_x).to_int(),
    (g1y + cam_y).to_int(),
    280.0,
    @raylib.Color::new(164, 60, 180, 40),
  )

  for i in 0..<140 {
    let p = Float::from_int(i)
    let x = (p * 79.0 + @types.sinf(game.time_s * 0.16 + p * 0.38) * 76.0) %
      Float::from_int(@types.screen_w)
    let mut y = (p * 44.0 + game.distance * 0.12 + p * 0.8) %
      Float::from_int(@types.screen_h)
    y = Float::from_int(@types.screen_h) - y

    let pulse : Float = 0.5 + 0.5 * @types.sinf(game.time_s * 0.94 + p * 0.17)
    @raylib.draw_circle(
      (x + cam_x).to_int(),
      (y + cam_y).to_int(),
      0.8 + pulse * 1.6,
      @raylib.Color::new(
        100 + (pulse * 100.0).to_int(),
        120 + (pulse * 94.0).to_int(),
        180 + (pulse * 70.0).to_int(),
        110,
      ),
    )
  }
}

///|
fn draw_horizon(game : @types.Game, cam_x : Float, cam_y : Float) -> Unit {
  let base_y = Float::from_int(@types.hud_h) + 20.0

  for i in 0..<44 {
    let p = Float::from_int(i)
    let w = 18 + i * 17 % 52
    let h = 46 + i * 31 % 180
    let x = (i * 33 + (game.distance * 0.02).to_int()) %
      (@types.screen_w + 120) -
      60
    let y = (base_y - Float::from_int(h) + cam_y * 0.3).to_int()

    let pulse : Float = 0.5 + 0.5 * @types.sinf(game.time_s * 0.8 + p * 0.44)
    @raylib.draw_rectangle(
      (Float::from_int(x) + cam_x * 0.28).to_int(),
      y,
      w,
      h,
      @raylib.Color::new(10, 16, 30, 180),
    )

    if i % 3 == 0 {
      @raylib.draw_rectangle(
        (Float::from_int(x) + cam_x * 0.28).to_int(),
        y + 8,
        w,
        2,
        @raylib.Color::new(
          140 + (pulse * 80.0).to_int(),
          80 + (pulse * 70.0).to_int(),
          190 + (pulse * 50.0).to_int(),
          130,
        ),
      )
    }
  }
}

///|
fn draw_track(game : @types.Game, cam_x : Float, cam_y : Float) -> Unit {
  let step = 12

  for yi = @types.hud_h; yi < @types.screen_h + step; yi = yi + step {
    let y0 = Float::from_int(yi)
    let y1 = Float::from_int(yi + step)

    let d0 = game.distance + (Float::from_int(@types.screen_h) - y0)
    let d1 = game.distance + (Float::from_int(@types.screen_h) - y1)

    let e0 = @types.track_edges(game.stage, d0, game.time_s)
    let e1 = @types.track_edges(game.stage, d1, game.time_s)

    let left0 = (e0.0 + cam_x).to_int()
    let right0 = (e0.1 + cam_x).to_int()
    let left1 = (e1.0 + cam_x).to_int()
    let right1 = (e1.1 + cam_x).to_int()

    let left = @types.clampi(
      @types.minf(Float::from_int(left0), Float::from_int(left1)).to_int(),
      -180,
      @types.screen_w + 180,
    )
    let right = @types.clampi(
      @types.maxf(Float::from_int(right0), Float::from_int(right1)).to_int(),
      -180,
      @types.screen_w + 180,
    )

    let pulse : Float = 0.5 + 0.5 * @types.sinf(d0 * 0.02 + game.time_s * 3.8)
    let road = if yi % 24 == 0 { @types.track_mid() } else { @types.track_dark() }

    if left > 0 {
      @raylib.draw_rectangle(
        0,
        (y0 + cam_y).to_int(),
        left,
        step + 1,
        @raylib.Color::new(6, 12, 22, 240),
      )
    }

    @raylib.draw_rectangle(
      left,
      (y0 + cam_y).to_int(),
      @types.maxf(0.0, Float::from_int(right - left)).to_int(),
      step + 1,
      road,
    )

    if right < @types.screen_w {
      @raylib.draw_rectangle(
        right,
        (y0 + cam_y).to_int(),
        @types.screen_w - right,
        step + 1,
        @raylib.Color::new(6, 12, 22, 240),
      )
    }

    @raylib.draw_line_ex(
      @raylib.Vector2::new(Float::from_int(left0), y0 + cam_y),
      @raylib.Vector2::new(Float::from_int(left1), y1 + cam_y),
      2.8,
      @raylib.Color::new(82, 236, 255, 120 + (pulse * 90.0).to_int()),
    )
    @raylib.draw_line_ex(
      @raylib.Vector2::new(Float::from_int(right0), y0 + cam_y),
      @raylib.Vector2::new(Float::from_int(right1), y1 + cam_y),
      2.8,
      @raylib.Color::new(255, 112, 216, 120 + (pulse * 90.0).to_int()),
    )

    for lane in 1..< @types.lane_count {
      let t = Float::from_int(lane) / Float::from_int(@types.lane_count)
      let x0 = @types.lerpf(e0.0, e0.1, t) + cam_x
      let x1 = @types.lerpf(e1.0, e1.1, t) + cam_x
      let blink = (yi / 24 + lane + (game.distance * 0.04).to_int()) % 6
      if blink <= 2 {
        @raylib.draw_line_ex(
          @raylib.Vector2::new(x0, y0 + cam_y),
          @raylib.Vector2::new(x1, y1 + cam_y),
          1.8,
          @raylib.Color::new(164, 206, 236, 90),
        )
      }
    }
  }
}

///|
fn obj_col(kind : Int) -> @raylib.Color {
  if kind == @types.obj_scout {
    @raylib.Color::new(255, 138, 198, 255)
  } else if kind == @types.obj_spinner {
    @raylib.Color::new(132, 246, 255, 255)
  } else if kind == @types.obj_tank {
    @raylib.Color::new(255, 178, 110, 255)
  } else if kind == @types.obj_gear_wall {
    @raylib.Color::new(255, 106, 154, 255)
  } else if kind == @types.obj_coin {
    @types.amber()
  } else if kind == @types.obj_coolant {
    @types.heat_col()
  } else {
    @raylib.Color::new(170, 140, 255, 255)
  }
}

///|
fn draw_scout(
  o : @types.Obj,
  col : @raylib.Color,
  cam_x : Float,
  cam_y : Float,
) -> Unit {
  let x = o.x + cam_x
  let y = o.y + cam_y

  @raylib.draw_triangle(
    @raylib.Vector2::new(x, y - o.h * 0.5),
    @raylib.Vector2::new(x - o.w * 0.5, y + o.h * 0.36),
    @raylib.Vector2::new(x + o.w * 0.5, y + o.h * 0.36),
    col,
  )
  @raylib.draw_circle(
    (x - o.w * 0.22).to_int(),
    (y + o.h * 0.3).to_int(),
    9.0,
    @raylib.Color::new(14, 20, 30, 220),
  )
  @raylib.draw_circle(
    (x + o.w * 0.22).to_int(),
    (y + o.h * 0.3).to_int(),
    9.0,
    @raylib.Color::new(14, 20, 30, 220),
  )
}

///|
fn draw_spinner(
  o : @types.Obj,
  col : @raylib.Color,
  cam_x : Float,
  cam_y : Float,
) -> Unit {
  let x = o.x + cam_x
  let y = o.y + cam_y
  let r = o.w * 0.42
  let pulse : Float = 0.5 + 0.5 * @types.sinf(o.spin * 4.0)

  @raylib.draw_circle(
    x.to_int(),
    y.to_int(),
    r,
    @types.alpha_color(col, 200),
  )
  @raylib.draw_circle_lines(
    x.to_int(),
    y.to_int(),
    r + pulse * 6.0,
    @types.alpha_color(col, 180),
  )
  @raylib.draw_circle(
    x.to_int(),
    y.to_int(),
    4.6,
    @raylib.Color::new(240, 250, 255, 240),
  )
}

///|
fn draw_tank(
  o : @types.Obj,
  col : @raylib.Color,
  cam_x : Float,
  cam_y : Float,
) -> Unit {
  let x = o.x + cam_x
  let y = o.y + cam_y

  @raylib.draw_rectangle(
    (x - o.w * 0.5).to_int(),
    (y - o.h * 0.5).to_int(),
    o.w.to_int(),
    o.h.to_int(),
    @types.alpha_color(col, 214),
  )
  @raylib.draw_rectangle_lines(
    (x - o.w * 0.5).to_int(),
    (y - o.h * 0.5).to_int(),
    o.w.to_int(),
    o.h.to_int(),
    @raylib.Color::new(30, 40, 58, 220),
  )

  @raylib.draw_rectangle(
    (x - o.w * 0.38).to_int(),
    (y - o.h * 0.24).to_int(),
    (o.w * 0.76).to_int(),
    (o.h * 0.2).to_int(),
    @raylib.Color::new(220, 236, 250, 84),
  )
}

///|
fn draw_gear_wall(
  o : @types.Obj,
  col : @raylib.Color,
  cam_x : Float,
  cam_y : Float,
) -> Unit {
  let x = o.x + cam_x
  let y = o.y + cam_y
  let pulse : Float = 0.5 + 0.5 * @types.sinf(o.spin * 4.6)

  @raylib.draw_rectangle(
    (x - o.w * 0.5).to_int(),
    (y - o.h * 0.5).to_int(),
    o.w.to_int(),
    o.h.to_int(),
    @raylib.Color::new(col.r.to_int(), col.g.to_int(), col.b.to_int(), 170),
  )
  @raylib.draw_rectangle(
    (x - o.w * 0.5).to_int(),
    (y - 2.0).to_int(),
    o.w.to_int(),
    4,
    @raylib.Color::new(255, 200, 228, 160 + (pulse * 80.0).to_int()),
  )
}

///|
fn draw_pickup(
  o : @types.Obj,
  col : @raylib.Color,
  cam_x : Float,
  cam_y : Float,
) -> Unit {
  let x = o.x + cam_x
  let y = o.y + cam_y
  let r = o.w * 0.46
  let pulse : Float = 0.5 + 0.5 * @types.sinf(o.spin * 3.2)

  @raylib.draw_circle(
    x.to_int(),
    y.to_int(),
    r + pulse * 2.0,
    @types.alpha_color(col, 130),
  )
  @raylib.draw_circle_lines(
    x.to_int(),
    y.to_int(),
    r + pulse * 5.2,
    @types.alpha_color(col, 180),
  )

  if o.kind == @types.obj_coin {
    @raylib.draw_text(
      "$",
      (x - 8.0).to_int(),
      (y - 12.0).to_int(),
      24,
      @raylib.Color::new(255, 242, 162, 230),
    )
  } else if o.kind == @types.obj_coolant {
    @raylib.draw_rectangle(
      (x - 10.0).to_int(),
      (y - 14.0).to_int(),
      20,
      28,
      @raylib.Color::new(220, 255, 240, 220),
    )
    @raylib.draw_rectangle(
      (x - 4.0).to_int(),
      (y - 19.0).to_int(),
      8,
      4,
      @raylib.Color::new(220, 255, 240, 220),
    )
  } else {
    @raylib.draw_text(
      "E",
      (x - 9.0).to_int(),
      (y - 12.0).to_int(),
      24,
      @raylib.Color::new(236, 214, 255, 230),
    )
  }
}

///|
fn draw_objs(game : @types.Game, cam_x : Float, cam_y : Float) -> Unit {
  for o in game.objs {
    if not(o.active) {
      continue
    }

    let col0 = obj_col(o.kind)
    let col = if o.cloak && game.emp_t <= 0.0 {
      @types.alpha_color(col0, 80)
    } else {
      col0
    }

    if o.kind == @types.obj_scout {
      draw_scout(o, col, cam_x, cam_y)
    } else if o.kind == @types.obj_spinner {
      draw_spinner(o, col, cam_x, cam_y)
    } else if o.kind == @types.obj_tank {
      draw_tank(o, col, cam_x, cam_y)
    } else if o.kind == @types.obj_gear_wall {
      draw_gear_wall(o, col, cam_x, cam_y)
    } else {
      draw_pickup(o, col, cam_x, cam_y)
    }

    if @types.is_hostile(o.kind) && o.hp > 0.0 {
      let hp_ratio = @types.clampf(
        o.hp / (if o.kind == @types.obj_tank { 50.0 } else { 20.0 }),
        0.0,
        1.0,
      )
      @raylib.draw_rectangle(
        (o.x - o.w * 0.42 + cam_x).to_int(),
        (o.y - o.h * 0.62 + cam_y).to_int(),
        (o.w * 0.84).to_int(),
        4,
        @raylib.Color::new(18, 26, 40, 210),
      )
      @raylib.draw_rectangle(
        (o.x - o.w * 0.42 + cam_x).to_int(),
        (o.y - o.h * 0.62 + cam_y).to_int(),
        (o.w * 0.84 * hp_ratio).to_int(),
        4,
        @raylib.Color::new(255, 124, 170, 220),
      )
    }
  }
}

///|
fn draw_shots(game : @types.Game, cam_x : Float, cam_y : Float) -> Unit {
  for s in game.shots {
    if not(s.active) {
      continue
    }

    let col = if s.from_player {
      if s.kind == 1 {
        @raylib.Color::new(180, 236, 255, 250)
      } else {
        @raylib.Color::new(120, 246, 214, 250)
      }
    } else if s.kind == 1 {
      @raylib.Color::new(196, 146, 255, 240)
    } else if s.kind == 2 {
      @raylib.Color::new(255, 206, 136, 240)
    } else {
      @raylib.Color::new(255, 140, 188, 240)
    }

    @raylib.draw_circle(
      (s.x + cam_x).to_int(),
      (s.y + cam_y).to_int(),
      4.2,
      col,
    )

    let len : Float = if s.from_player { 16.0 } else { 12.0 }
    let p0 = @raylib.Vector2::new(s.x + cam_x, s.y + cam_y)
    let p1 = @raylib.Vector2::new(
      s.x + cam_x - s.vx * 0.001 * len,
      s.y + cam_y - s.vy * 0.001 * len,
    )
    @raylib.draw_line_ex(p0, p1, 2.0, @types.alpha_color(col, 140))
  }
}

///|
fn draw_spark_fx(game : @types.Game, cam_x : Float, cam_y : Float) -> Unit {
  for s in game.sparks {
    if not(s.active) {
      continue
    }

    let a = @types.clampi((s.life * 255.0).to_int(), 0, 255)
    let col = if s.kind == 1 {
      @raylib.Color::new(255, 134, 178, a)
    } else if s.kind == 2 {
      @raylib.Color::new(180, 156, 255, a)
    } else {
      @raylib.Color::new(120, 246, 225, a)
    }

    @raylib.draw_circle(
      (s.x + cam_x).to_int(),
      (s.y + cam_y).to_int(),
      s.size,
      col,
    )
  }
}

///|
fn draw_ring_fx(game : @types.Game, cam_x : Float, cam_y : Float) -> Unit {
  for r in game.rings {
    if not(r.active) {
      continue
    }

    let a = @types.clampi((r.life * 255.0).to_int(), 0, 255)
    let c = if r.kind == 2 {
      @raylib.Color::new(186, 146, 255, a)
    } else if r.kind == 1 {
      @raylib.Color::new(255, 132, 198, a)
    } else {
      @raylib.Color::new(102, 236, 255, a)
    }

    @raylib.draw_circle_lines(
      (r.x + cam_x).to_int(),
      (r.y + cam_y).to_int(),
      r.r,
      c,
    )
  }
}

///|
fn draw_ghost_fx(game : @types.Game, cam_x : Float, cam_y : Float) -> Unit {
  for g in game.ghosts {
    if not(g.active) {
      continue
    }

    let a = @types.clampi((g.life * 210.0).to_int(), 0, 210)
    let c = if g.kind == 1 {
      @raylib.Color::new(122, 242, 255, a)
    } else {
      @raylib.Color::new(214, 230, 246, a)
    }

    @raylib.draw_rectangle_pro(
      @raylib.Rectangle::new(g.x + cam_x, g.y + cam_y, g.w, g.h),
      @raylib.Vector2::new(g.w * 0.5, g.h * 0.5),
      g.rot,
      c,
    )
  }
}

///|
fn draw_player(game : @types.Game, cam_x : Float, cam_y : Float) -> Unit {
  let x = game.hero.x + cam_x
  let y = game.hero.y + cam_y

  let lean = @types.clampf(game.hero.vx / @types.max_speed_x, -1.0, 1.0)
  let rot = lean * 18.0
  let pulse : Float = 0.5 + 0.5 * @types.sinf(game.hero.engine_t * 8.2)

  let body = if game.hero.hurt_t > 0.0 {
    @raylib.Color::new(255, 188, 204, 255)
  } else {
    @raylib.Color::new(136, 236, 255, 255)
  }

  @raylib.draw_rectangle_pro(
    @raylib.Rectangle::new(x, y, game.hero.w, game.hero.h),
    @raylib.Vector2::new(game.hero.w * 0.5, game.hero.h * 0.5),
    rot,
    body,
  )
  @raylib.draw_rectangle_pro(
    @raylib.Rectangle::new(
      x,
      y + game.hero.h * 0.18,
      game.hero.w * 0.86,
      game.hero.h * 0.42,
    ),
    @raylib.Vector2::new(game.hero.w * 0.43, game.hero.h * 0.21),
    rot,
    @raylib.Color::new(20, 34, 56, 220),
  )

  @raylib.draw_circle(
    x.to_int(),
    (y - game.hero.h * 0.46).to_int(),
    8.0 + pulse * 2.2,
    @raylib.Color::new(236, 246, 255, 230),
  )

  @raylib.draw_triangle(
    @raylib.Vector2::new(x - game.hero.w * 0.4, y + game.hero.h * 0.48),
    @raylib.Vector2::new(x - game.hero.w * 0.8, y + game.hero.h * 0.64),
    @raylib.Vector2::new(x - game.hero.w * 0.1, y + game.hero.h * 0.56),
    @raylib.Color::new(106, 206, 242, 220),
  )
  @raylib.draw_triangle(
    @raylib.Vector2::new(x + game.hero.w * 0.4, y + game.hero.h * 0.48),
    @raylib.Vector2::new(x + game.hero.w * 0.8, y + game.hero.h * 0.64),
    @raylib.Vector2::new(x + game.hero.w * 0.1, y + game.hero.h * 0.56),
    @raylib.Color::new(106, 206, 242, 220),
  )

  if game.hero.muzzle_t > 0.0 {
    let a = @types.clampi((game.hero.muzzle_t * 255.0).to_int(), 0, 255)
    @raylib.draw_circle(
      (x - 10.0).to_int(),
      (y - game.hero.h * 0.53).to_int(),
      5.2,
      @raylib.Color::new(255, 236, 180, a),
    )
    @raylib.draw_circle(
      (x + 10.0).to_int(),
      (y - game.hero.h * 0.53).to_int(),
      5.2,
      @raylib.Color::new(255, 236, 180, a),
    )
  }

  if game.dash_t > 0.0 {
    @raylib.draw_circle_lines(
      x.to_int(),
      y.to_int(),
      @types.maxf(game.hero.w, game.hero.h) * 0.65 + game.dash_t * 40.0,
      @raylib.Color::new(120, 248, 255, 210),
    )
  }

  if game.hero.invuln > 0.0 {
    let flicker = Float::from_int(80) +
      @types.sinf(game.time_s * 14.0) * 70.0 +
      70.0
    let aa = @types.clampi(flicker.to_int(), 30, 220)
    @raylib.draw_circle(
      x.to_int(),
      y.to_int(),
      @types.maxf(game.hero.w, game.hero.h) * 0.6,
      @raylib.Color::new(246, 252, 255, aa),
    )
  }
}

///|
fn draw_emp_wave(game : @types.Game) -> Unit {
  if game.emp_t <= 0.0 {
    return
  }

  let t : Float = Float::from_int(1) - game.emp_t / @types.emp_time
  let rr = @types.emp_radius * t
  let aa = @types.clampi(
    ((Float::from_int(1) - t) * 200.0).to_int(),
    0,
    200,
  )

  @raylib.draw_circle_lines(
    game.hero.x.to_int(),
    game.hero.y.to_int(),
    rr,
    @raylib.Color::new(186, 146, 255, aa),
  )
}

///|
fn cooldown_text(cd : Float, total : Float) -> String {
  if cd <= 0.0 {
    "READY"
  } else {
    (cd / total * 100.0).to_int().to_string() + "%"
  }
}

///|
fn draw_hud(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_w,
    @types.hud_h,
    @raylib.Color::new(4, 10, 20, 236),
  )
  @raylib.draw_line(
    0,
    @types.hud_h,
    @types.screen_w,
    @types.hud_h,
    @raylib.Color::new(100, 204, 244, 160),
  )

  draw_bar(
    20,
    16,
    290,
    24,
    game.armor,
    @types.armor_max,
    "ARMOR",
    @types.armor_col(),
  )
  draw_bar(
    20,
    48,
    290,
    24,
    game.heat,
    @types.heat_max,
    "HEAT",
    @types.heat_col(),
  )

  @raylib.draw_rectangle(326, 16, 150, 56, @raylib.Color::new(8, 18, 30, 214))
  @raylib.draw_rectangle_lines(
    326,
    16,
    150,
    56,
    @raylib.Color::new(134, 208, 242, 170),
  )
  @raylib.draw_text(
    "DASH",
    338,
    24,
    18,
    @raylib.Color::new(206, 230, 248, 230),
  )
  @raylib.draw_text(
    cooldown_text(game.dash_cd, @types.dash_cd_time),
    338,
    44,
    16,
    if game.dash_cd <= 0.0 {
      @raylib.Color::new(128, 248, 170, 240)
    } else {
      @raylib.Color::new(236, 194, 136, 220)
    },
  )

  @raylib.draw_rectangle(486, 16, 150, 56, @raylib.Color::new(8, 18, 30, 214))
  @raylib.draw_rectangle_lines(
    486,
    16,
    150,
    56,
    @raylib.Color::new(152, 192, 244, 170),
  )
  @raylib.draw_text(
    "EMP",
    498,
    24,
    18,
    @raylib.Color::new(212, 224, 255, 230),
  )
  @raylib.draw_text(
    cooldown_text(game.emp_cd, @types.emp_cd_time),
    498,
    44,
    16,
    if game.emp_cd <= 0.0 {
      @raylib.Color::new(128, 248, 170, 240)
    } else {
      @raylib.Color::new(236, 194, 136, 220)
    },
  )

  @raylib.draw_rectangle(
    @types.screen_w - 360,
    14,
    344,
    88,
    @raylib.Color::new(8, 18, 30, 214),
  )
  @raylib.draw_rectangle_lines(
    @types.screen_w - 360,
    14,
    344,
    88,
    @raylib.Color::new(128, 202, 236, 170),
  )

  @raylib.draw_text(
    "SCORE " + game.score.to_string(),
    @types.screen_w - 344,
    22,
    24,
    @raylib.Color::new(228, 248, 255, 240),
  )
  @raylib.draw_text(
    "BEST " + game.best_score.to_string(),
    @types.screen_w - 344,
    50,
    18,
    @raylib.Color::new(178, 226, 244, 230),
  )
  @raylib.draw_text(
    "STAGE " +
    game.stage.to_string() +
    "  COINS " +
    game.coins.to_string() +
    "  KILLS " +
    game.kills.to_string(),
    @types.screen_w - 344,
    70,
    16,
    @raylib.Color::new(172, 244, 220, 230),
  )

  let dist = "DIST " +
    game.distance.to_int().to_string() +
    " / " +
    game.stage_goal.to_int().to_string()
  draw_right_text(
    dist,
    @types.screen_w - 20,
    104,
    18,
    @raylib.Color::new(198, 236, 255, 230),
  )

  @raylib.draw_rectangle(
    @types.screen_w - 334,
    104,
    308,
    10,
    @raylib.Color::new(8, 18, 30, 220),
  )
  let ratio = @types.clampf(
    game.distance / @types.maxf(game.stage_goal, 1.0),
    0.0,
    1.0,
  )
  @raylib.draw_rectangle(
    @types.screen_w - 334,
    104,
    (Float::from_int(308) * ratio).to_int(),
    10,
    @raylib.Color::new(128, 248, 210, 220),
  )
  @raylib.draw_rectangle_lines(
    @types.screen_w - 334,
    104,
    308,
    10,
    @raylib.Color::new(132, 206, 232, 170),
  )

  if game.combo >= 2 && game.combo_t > 0.0 {
    let aa = @types.clampi((game.combo_t * 130.0 + 60.0).to_int(), 0, 255)
    draw_center_text(
      "COMBO x" + game.combo.to_string(),
      12,
      28,
      @raylib.Color::new(255, 224, 146, aa),
    )
  }
}

///|
fn draw_btn(
  rect : (Float, Float, Float, Float),
  text : String,
  active : Bool,
  primary : Bool,
) -> Unit {
  let aa = if active { 172 } else { 88 }
  let edge = if primary {
    @raylib.Color::new(116, 220, 255, aa)
  } else {
    @raylib.Color::new(198, 156, 255, aa)
  }

  @raylib.draw_rectangle(
    rect.0.to_int(),
    rect.1.to_int(),
    rect.2.to_int(),
    rect.3.to_int(),
    @raylib.Color::new(10, 24, 42, aa),
  )
  @raylib.draw_rectangle_lines(
    rect.0.to_int(),
    rect.1.to_int(),
    rect.2.to_int(),
    rect.3.to_int(),
    edge,
  )

  let tw = @raylib.measure_text(text, 24)
  @raylib.draw_text(
    text,
    (rect.0 + rect.2 * 0.5 - Float::from_int(tw) * 0.5).to_int(),
    (rect.1 + rect.3 * 0.5 - 12.0).to_int(),
    24,
    @raylib.Color::new(230, 246, 255, @types.clampi(aa + 46, 0, 255)),
  )
}

///|
fn draw_touch(game : @types.Game) -> Unit {
  let left = @types.btn_left_rect()
  let right = @types.btn_right_rect()
  let up = @types.btn_up_rect()
  let down = @types.btn_down_rect()
  let fire = @types.btn_fire_rect()
  let dash = @types.btn_dash_rect()
  let emp = @types.btn_emp_rect()

  draw_btn(left, "<", game.input_x < -0.1, true)
  draw_btn(right, ">", game.input_x > 0.1, true)
  draw_btn(up, "^", game.input_y < -0.1, true)
  draw_btn(down, "v", game.input_y > 0.1, true)
  draw_btn(fire, "FIRE", game.input_fire_hold, false)
  draw_btn(dash, "DASH", game.dash_t > 0.0, false)
  draw_btn(emp, "EMP", game.emp_t > 0.0, false)
}

///|
fn draw_play_hint(game : @types.Game) -> Unit {
  if game.hint_t > 16.0 {
    return
  }

  let fade : Float = Float::from_int(1) -
    @types.clampf((game.hint_t - 7.0) / 9.0, 0.0, 1.0)
  let aa = @types.clampi((fade * 190.0).to_int(), 0, 190)

  @raylib.draw_rectangle(
    @types.screen_w / 2 - 360,
    @types.screen_h - 54,
    720,
    32,
    @raylib.Color::new(8, 18, 30, aa),
  )
  draw_center_text(
    "Dash rams targets. EMP reveals cloaked enemies and clears projectiles.",
    @types.screen_h - 50,
    21,
    @raylib.Color::new(206, 232, 246, aa + 42),
  )
}

///|
fn draw_title_overlay(game : @types.Game) -> Unit {
  let mx = game.mouse_x
  let my = game.mouse_y
  let hold = game.mouse_hold
  let tc = game.touch_count

  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_w,
    @types.screen_h,
    @raylib.Color::new(4, 8, 16, 124),
  )

  draw_center_text(
    "CLOCKWORK CITY CHASE 2026",
    110,
    62,
    @raylib.Color::new(188, 244, 255, 250),
  )
  draw_center_text(
    "Thread the midnight gearway and break mechanized convoys.",
    198,
    28,
    @raylib.Color::new(190, 224, 246, 224),
  )
  draw_center_text(
    "Balance armor, heat, and timing for long combo routes.",
    232,
    24,
    @raylib.Color::new(178, 216, 238, 224),
  )

  let b = @types.title_start_rect()
  let hover = @types.pointer_on_rect(mx, my, hold, tc, b.0, b.1, b.2, b.3)

  @raylib.draw_rectangle(
    b.0.to_int(),
    b.1.to_int(),
    b.2.to_int(),
    b.3.to_int(),
    if hover {
      @raylib.Color::new(40, 110, 152, 224)
    } else {
      @raylib.Color::new(20, 66, 96, 214)
    },
  )
  @raylib.draw_rectangle_lines(
    b.0.to_int(),
    b.1.to_int(),
    b.2.to_int(),
    b.3.to_int(),
    @raylib.Color::new(168, 238, 255, 220),
  )

  draw_center_text(
    "START CHASE",
    (b.1 + 24.0).to_int(),
    36,
    @raylib.Color::new(230, 246, 255, 255),
  )

  @raylib.draw_rectangle(
    @types.screen_w / 2 - 462,
    372,
    924,
    236,
    @raylib.Color::new(8, 18, 30, 184),
  )
  @raylib.draw_rectangle_lines(
    @types.screen_w / 2 - 462,
    372,
    924,
    236,
    @raylib.Color::new(124, 204, 236, 170),
  )

  draw_center_text(
    "Keyboard: WASD/Arrows move | Space/J fire | Shift/K dash | L/E EMP",
    402,
    22,
    @raylib.Color::new(204, 228, 244, 224),
  )
  draw_center_text(
    "Mobile: Left pad = move | Right pad = Fire, Dash, EMP",
    437,
    22,
    @raylib.Color::new(196, 224, 244, 224),
  )
  draw_center_text(
    "Reach distance target each stage. Armor break ends the run.",
    472,
    22,
    @raylib.Color::new(220, 232, 246, 224),
  )
  draw_center_text(
    "EMP pulse can instantly break nearby threats.",
    507,
    22,
    @raylib.Color::new(220, 232, 246, 224),
  )

  if game.best_score > 0 {
    draw_center_text(
      "Best Score: " + game.best_score.to_string(),
      556,
      27,
      @raylib.Color::new(255, 222, 146, 242),
    )
  }
}

///|
fn draw_stage_clear(game : @types.Game) -> Unit {
  let t = @types.ease_out_cubic(
    @types.clampf(game.result_t / @types.stage_clear_wait, 0.0, 1.0),
  )
  let panel_w = (Float::from_int(430) + t * Float::from_int(140)).to_int()
  let panel_h = (Float::from_int(170) + t * Float::from_int(44)).to_int()

  @raylib.draw_rectangle(
    @types.screen_w / 2 - panel_w / 2,
    @types.screen_h / 2 - panel_h / 2,
    panel_w,
    panel_h,
    @raylib.Color::new(10, 30, 44, 218),
  )
  @raylib.draw_rectangle_lines(
    @types.screen_w / 2 - panel_w / 2,
    @types.screen_h / 2 - panel_h / 2,
    panel_w,
    panel_h,
    @raylib.Color::new(150, 242, 220, 226),
  )

  draw_center_text(
    "STAGE " + game.stage.to_string() + " CLEARED",
    @types.screen_h / 2 - 46,
    44,
    @raylib.Color::new(182, 255, 212, 255),
  )
  draw_center_text(
    "Next gearway route loading...",
    @types.screen_h / 2 + 8,
    26,
    @raylib.Color::new(206, 236, 240, 230),
  )
  draw_center_text(
    "Tap / Enter to continue now",
    @types.screen_h / 2 + 44,
    20,
    @raylib.Color::new(196, 222, 238, 222),
  )
}

///|
fn draw_game_over(game : @types.Game) -> Unit {
  let mx = game.mouse_x
  let my = game.mouse_y
  let hold = game.mouse_hold
  let tc = game.touch_count

  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_w,
    @types.screen_h,
    @raylib.Color::new(12, 8, 16, 196),
  )

  draw_center_text(
    "CHASE LOST",
    166,
    66,
    @raylib.Color::new(255, 184, 206, 250),
  )
  draw_center_text(
    "Final Score: " + game.score.to_string(),
    254,
    36,
    @raylib.Color::new(236, 238, 246, 240),
  )
  draw_center_text(
    "Coins: " + game.coins.to_string() + "   Kills: " + game.kills.to_string(),
    298,
    28,
    @raylib.Color::new(194, 244, 214, 230),
  )
  draw_center_text(
    "Stage Reached: " + game.stage.to_string(),
    332,
    28,
    @raylib.Color::new(186, 224, 244, 230),
  )

  let b = @types.retry_rect()
  let hover = @types.pointer_on_rect(mx, my, hold, tc, b.0, b.1, b.2, b.3)

  @raylib.draw_rectangle(
    b.0.to_int(),
    b.1.to_int(),
    b.2.to_int(),
    b.3.to_int(),
    if hover {
      @raylib.Color::new(124, 72, 96, 224)
    } else {
      @raylib.Color::new(84, 44, 66, 214)
    },
  )
  @raylib.draw_rectangle_lines(
    b.0.to_int(),
    b.1.to_int(),
    b.2.to_int(),
    b.3.to_int(),
    @raylib.Color::new(255, 176, 206, 224),
  )

  draw_center_text(
    "RETRY",
    (b.1 + 16.0).to_int(),
    34,
    @raylib.Color::new(255, 236, 244, 255),
  )

  draw_center_text(
    "Press R / ENTER or tap RETRY",
    560,
    24,
    @raylib.Color::new(222, 226, 236, 222),
  )
}

///|
fn draw_world(game : @types.Game, cam_x : Float, cam_y : Float) -> Unit {
  draw_ghost_fx(game, cam_x, cam_y)
  draw_ring_fx(game, cam_x, cam_y)
  draw_objs(game, cam_x, cam_y)
  draw_shots(game, cam_x, cam_y)
  draw_spark_fx(game, cam_x, cam_y)
  draw_player(game, cam_x, cam_y)
}

///|
pub fn draw_frame(game : @types.Game) -> Unit {
  @raylib.clear_background(@types.bg_top())

  let cam = shake_offset(game)
  let cam_x = cam.0
  let cam_y = cam.1

  draw_sky(game, cam_x, cam_y)
  draw_horizon(game, cam_x, cam_y)
  draw_track(game, cam_x, cam_y)
  draw_world(game, cam_x, cam_y)
  draw_emp_wave(game)

  if game.flash_t > 0.0 {
    let aa = @types.clampi((game.flash_t * 220.0).to_int(), 0, 220)
    @raylib.draw_rectangle(
      0,
      0,
      @types.screen_w,
      @types.screen_h,
      @raylib.Color::new(255, 148, 186, aa),
    )
  }

  if game.state != @types.state_title {
    draw_hud(game)
  }

  if game.state == @types.state_title {
    draw_title_overlay(game)
  } else if game.state == @types.state_play {
    draw_play_hint(game)
    if game.touch_mode {
      draw_touch(game)
    }
  } else if game.state == @types.state_stage_clear {
    draw_stage_clear(game)
  } else {
    draw_game_over(game)
  }
}
