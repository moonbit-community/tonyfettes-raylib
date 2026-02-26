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
    clampf(value / maxv, 0.0, 1.0)
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
fn alpha_color(c : @raylib.Color, a : Int) -> @raylib.Color {
  @raylib.Color::new(
    c.r.to_int(),
    c.g.to_int(),
    c.b.to_int(),
    clampi(a, 0, 255),
  )
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
fn draw_sky_backdrop(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  @raylib.draw_rectangle_gradient_v(
    0,
    0,
    screen_w,
    screen_h,
    bg_top(),
    bg_bottom(),
  )

  let glow0x = Float::from_int(screen_w) * 0.18 +
    sinf(game.time_s * 0.3) * 140.0
  let glow0y = Float::from_int(screen_h) * 0.2 + cosf(game.time_s * 0.22) * 70.0
  @raylib.draw_circle(
    (glow0x + cam_x).to_int(),
    (glow0y + cam_y).to_int(),
    240.0,
    @raylib.Color::new(44, 96, 182, 42),
  )

  let glow1x = Float::from_int(screen_w) * 0.82 +
    sinf(game.time_s * 0.24 + 0.9) * 130.0
  let glow1y = Float::from_int(screen_h) * 0.76 +
    cosf(game.time_s * 0.16 + 1.1) * 80.0
  @raylib.draw_circle(
    (glow1x + cam_x).to_int(),
    (glow1y + cam_y).to_int(),
    280.0,
    @raylib.Color::new(164, 52, 178, 42),
  )

  for i = 0; i < 140; i = i + 1 {
    let p = Float::from_int(i)
    let x = (p * 77.0 + sinf(game.time_s * 0.15 + p * 0.37) * 80.0) %
      Float::from_int(screen_w)
    let mut y = (p * 43.0 + game.distance * 0.11 + p * 0.8) %
      Float::from_int(screen_h)
    y = Float::from_int(screen_h) - y

    let pulse : Float = 0.5 + 0.5 * sinf(game.time_s * 0.9 + p * 0.17)
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
fn draw_city_horizon(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  let base_y = Float::from_int(ui_panel_h) + 20.0

  for i = 0; i < 44; i = i + 1 {
    let p = Float::from_int(i)
    let w = 18 + i * 17 % 52
    let h = 46 + i * 31 % 180
    let x = (i * 33 + (game.distance * 0.02).to_int()) % (screen_w + 120) - 60
    let y = (base_y - Float::from_int(h) + cam_y * 0.3).to_int()

    let pulse : Float = 0.5 + 0.5 * sinf(game.time_s * 0.8 + p * 0.44)
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
fn draw_road_surface(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  let step = 12

  for yi = ui_panel_h; yi < screen_h + step; yi = yi + step {
    let y0 = Float::from_int(yi)
    let y1 = Float::from_int(yi + step)

    let d0 = game.distance + (Float::from_int(screen_h) - y0)
    let d1 = game.distance + (Float::from_int(screen_h) - y1)

    let e0 = road_edges(game.stage, d0, game.time_s)
    let e1 = road_edges(game.stage, d1, game.time_s)

    let left0 = (e0.0 + cam_x).to_int()
    let right0 = (e0.1 + cam_x).to_int()
    let left1 = (e1.0 + cam_x).to_int()
    let right1 = (e1.1 + cam_x).to_int()

    let left = clampi(
      minf(Float::from_int(left0), Float::from_int(left1)).to_int(),
      -180,
      screen_w + 180,
    )
    let right = clampi(
      maxf(Float::from_int(right0), Float::from_int(right1)).to_int(),
      -180,
      screen_w + 180,
    )

    let line_pulse : Float = 0.5 + 0.5 * sinf(d0 * 0.02 + game.time_s * 3.8)
    let road_col = if yi % 24 == 0 { road_mid() } else { road_dark() }

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
      maxf(0.0, Float::from_int(right - left)).to_int(),
      step + 1,
      road_col,
    )

    if right < screen_w {
      @raylib.draw_rectangle(
        right,
        (y0 + cam_y).to_int(),
        screen_w - right,
        step + 1,
        @raylib.Color::new(6, 12, 22, 240),
      )
    }

    @raylib.draw_line_ex(
      @raylib.Vector2::new(Float::from_int(left0), y0 + cam_y),
      @raylib.Vector2::new(Float::from_int(left1), y1 + cam_y),
      2.8,
      @raylib.Color::new(82, 236, 255, 120 + (line_pulse * 90.0).to_int()),
    )
    @raylib.draw_line_ex(
      @raylib.Vector2::new(Float::from_int(right0), y0 + cam_y),
      @raylib.Vector2::new(Float::from_int(right1), y1 + cam_y),
      2.8,
      @raylib.Color::new(255, 112, 216, 120 + (line_pulse * 90.0).to_int()),
    )

    for lane = 1; lane < lanes_count; lane = lane + 1 {
      let t = Float::from_int(lane) / Float::from_int(lanes_count)
      let x0 = lerpf(e0.0, e0.1, t) + cam_x
      let x1 = lerpf(e1.0, e1.1, t) + cam_x
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
fn entity_body_col(kind : Int) -> @raylib.Color {
  if kind == foe_bike {
    @raylib.Color::new(255, 138, 198, 255)
  } else if kind == foe_drone {
    @raylib.Color::new(132, 246, 255, 255)
  } else if kind == foe_truck {
    @raylib.Color::new(255, 178, 110, 255)
  } else if kind == foe_laser {
    @raylib.Color::new(255, 106, 154, 255)
  } else if kind == item_credit {
    neon_yellow()
  } else if kind == item_battery {
    energy_col()
  } else {
    @raylib.Color::new(170, 140, 255, 255)
  }
}

///|
fn draw_entity_bike(
  e : Entity,
  col : @raylib.Color,
  cam_x : Float,
  cam_y : Float,
) -> Unit {
  let x = e.x + cam_x
  let y = e.y + cam_y
  let w = e.w
  let h = e.h

  @raylib.draw_triangle(
    @raylib.Vector2::new(x, y - h * 0.5),
    @raylib.Vector2::new(x - w * 0.5, y + h * 0.36),
    @raylib.Vector2::new(x + w * 0.5, y + h * 0.36),
    col,
  )
  @raylib.draw_circle(
    (x - w * 0.22).to_int(),
    (y + h * 0.3).to_int(),
    9.0,
    @raylib.Color::new(14, 20, 30, 220),
  )
  @raylib.draw_circle(
    (x + w * 0.22).to_int(),
    (y + h * 0.3).to_int(),
    9.0,
    @raylib.Color::new(14, 20, 30, 220),
  )
}

///|
fn draw_entity_drone(
  e : Entity,
  col : @raylib.Color,
  cam_x : Float,
  cam_y : Float,
) -> Unit {
  let x = e.x + cam_x
  let y = e.y + cam_y
  let r = e.w * 0.42
  let pulse : Float = 0.5 + 0.5 * sinf(e.spin * 4.0)

  @raylib.draw_circle(x.to_int(), y.to_int(), r, alpha_color(col, 200))
  @raylib.draw_circle_lines(
    x.to_int(),
    y.to_int(),
    r + pulse * 6.0,
    alpha_color(col, 180),
  )
  @raylib.draw_circle(
    x.to_int(),
    y.to_int(),
    4.6,
    @raylib.Color::new(240, 250, 255, 240),
  )
}

///|
fn draw_entity_truck(
  e : Entity,
  col : @raylib.Color,
  cam_x : Float,
  cam_y : Float,
) -> Unit {
  let x = e.x + cam_x
  let y = e.y + cam_y

  @raylib.draw_rectangle(
    (x - e.w * 0.5).to_int(),
    (y - e.h * 0.5).to_int(),
    e.w.to_int(),
    e.h.to_int(),
    alpha_color(col, 214),
  )
  @raylib.draw_rectangle_lines(
    (x - e.w * 0.5).to_int(),
    (y - e.h * 0.5).to_int(),
    e.w.to_int(),
    e.h.to_int(),
    @raylib.Color::new(30, 40, 58, 220),
  )

  @raylib.draw_rectangle(
    (x - e.w * 0.38).to_int(),
    (y - e.h * 0.24).to_int(),
    (e.w * 0.76).to_int(),
    (e.h * 0.2).to_int(),
    @raylib.Color::new(220, 236, 250, 84),
  )
}

///|
fn draw_entity_laser(
  e : Entity,
  col : @raylib.Color,
  cam_x : Float,
  cam_y : Float,
) -> Unit {
  let x = e.x + cam_x
  let y = e.y + cam_y
  let pulse : Float = 0.5 + 0.5 * sinf(e.spin * 4.6)

  @raylib.draw_rectangle(
    (x - e.w * 0.5).to_int(),
    (y - e.h * 0.5).to_int(),
    e.w.to_int(),
    e.h.to_int(),
    @raylib.Color::new(col.r.to_int(), col.g.to_int(), col.b.to_int(), 170),
  )
  @raylib.draw_rectangle(
    (x - e.w * 0.5).to_int(),
    (y - 2.0).to_int(),
    e.w.to_int(),
    4,
    @raylib.Color::new(255, 200, 228, 160 + (pulse * 80.0).to_int()),
  )
}

///|
fn draw_entity_pickup(
  e : Entity,
  col : @raylib.Color,
  cam_x : Float,
  cam_y : Float,
) -> Unit {
  let x = e.x + cam_x
  let y = e.y + cam_y
  let r = e.w * 0.46
  let pulse : Float = 0.5 + 0.5 * sinf(e.spin * 3.2)

  @raylib.draw_circle(
    x.to_int(),
    y.to_int(),
    r + pulse * 2.0,
    alpha_color(col, 130),
  )
  @raylib.draw_circle_lines(
    x.to_int(),
    y.to_int(),
    r + pulse * 5.2,
    alpha_color(col, 180),
  )

  if e.kind == item_credit {
    @raylib.draw_text(
      "$",
      (x - 8.0).to_int(),
      (y - 12.0).to_int(),
      24,
      @raylib.Color::new(255, 242, 162, 230),
    )
  } else if e.kind == item_battery {
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
      "H",
      (x - 9.0).to_int(),
      (y - 12.0).to_int(),
      24,
      @raylib.Color::new(236, 214, 255, 230),
    )
  }
}

///|
fn draw_entities(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  for i = 0; i < game.entities.length(); i = i + 1 {
    let e = game.entities[i]
    if not(e.active) {
      continue
    }

    let col0 = entity_body_col(e.kind)
    let col = if e.cloak && game.hack_t <= 0.0 {
      alpha_color(col0, 80)
    } else {
      col0
    }

    if e.kind == foe_bike {
      draw_entity_bike(e, col, cam_x, cam_y)
    } else if e.kind == foe_drone {
      draw_entity_drone(e, col, cam_x, cam_y)
    } else if e.kind == foe_truck {
      draw_entity_truck(e, col, cam_x, cam_y)
    } else if e.kind == foe_laser {
      draw_entity_laser(e, col, cam_x, cam_y)
    } else {
      draw_entity_pickup(e, col, cam_x, cam_y)
    }

    if entity_is_hostile(e.kind) && e.hp > 0.0 {
      let hp_ratio = clampf(
        e.hp / (if e.kind == foe_truck { 50.0 } else { 20.0 }),
        0.0,
        1.0,
      )
      @raylib.draw_rectangle(
        (e.x - e.w * 0.42 + cam_x).to_int(),
        (e.y - e.h * 0.62 + cam_y).to_int(),
        (e.w * 0.84).to_int(),
        4,
        @raylib.Color::new(18, 26, 40, 210),
      )
      @raylib.draw_rectangle(
        (e.x - e.w * 0.42 + cam_x).to_int(),
        (e.y - e.h * 0.62 + cam_y).to_int(),
        (e.w * 0.84 * hp_ratio).to_int(),
        4,
        @raylib.Color::new(255, 124, 170, 220),
      )
    }
  }
}

///|
fn draw_bullets(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  for i = 0; i < game.bullets.length(); i = i + 1 {
    let b = game.bullets[i]
    if not(b.active) {
      continue
    }

    let col = if b.from_player {
      if b.kind == 1 {
        @raylib.Color::new(180, 236, 255, 250)
      } else {
        @raylib.Color::new(120, 246, 214, 250)
      }
    } else if b.kind == 1 {
      @raylib.Color::new(196, 146, 255, 240)
    } else if b.kind == 2 {
      @raylib.Color::new(255, 206, 136, 240)
    } else {
      @raylib.Color::new(255, 140, 188, 240)
    }

    @raylib.draw_circle(
      (b.x + cam_x).to_int(),
      (b.y + cam_y).to_int(),
      4.2,
      col,
    )

    let len : Float = if b.from_player { 16.0 } else { 12.0 }
    let p0 = @raylib.Vector2::new(b.x + cam_x, b.y + cam_y)
    let p1 = @raylib.Vector2::new(
      b.x + cam_x - b.vx * 0.001 * len,
      b.y + cam_y - b.vy * 0.001 * len,
    )
    @raylib.draw_line_ex(p0, p1, 2.0, alpha_color(col, 140))
  }
}

///|
fn draw_sparks(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  for i = 0; i < game.sparks.length(); i = i + 1 {
    let s = game.sparks[i]
    if not(s.active) {
      continue
    }

    let a = clampi((s.life * 255.0).to_int(), 0, 255)
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
fn draw_rings(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  for i = 0; i < game.rings.length(); i = i + 1 {
    let r = game.rings[i]
    if not(r.active) {
      continue
    }

    let a = clampi((r.life * 255.0).to_int(), 0, 255)
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
fn draw_afterimages(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  for i = 0; i < game.images.length(); i = i + 1 {
    let it = game.images[i]
    if not(it.active) {
      continue
    }

    let a = clampi((it.life * 210.0).to_int(), 0, 210)
    let col = if it.kind == 1 {
      @raylib.Color::new(122, 242, 255, a)
    } else {
      @raylib.Color::new(214, 230, 246, a)
    }

    @raylib.draw_rectangle_pro(
      @raylib.Rectangle::new(it.x + cam_x, it.y + cam_y, it.w, it.h),
      @raylib.Vector2::new(it.w * 0.5, it.h * 0.5),
      it.rot,
      col,
    )
  }
}

///|
fn draw_player(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  let x = game.hero.x + cam_x
  let y = game.hero.y + cam_y

  let lean = clampf(game.hero.vx / player_max_speed_x, -1.0, 1.0)
  let rot = lean * 18.0
  let pulse : Float = 0.5 + 0.5 * sinf(game.hero.engine_t * 8.2)

  let body_col = if game.hero.hurt_t > 0.0 {
    @raylib.Color::new(255, 188, 204, 255)
  } else {
    @raylib.Color::new(136, 236, 255, 255)
  }

  @raylib.draw_rectangle_pro(
    @raylib.Rectangle::new(x, y, game.hero.w, game.hero.h),
    @raylib.Vector2::new(game.hero.w * 0.5, game.hero.h * 0.5),
    rot,
    body_col,
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
    let a = clampi((game.hero.muzzle_t * 255.0).to_int(), 0, 255)
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

  if game.boost_t > 0.0 {
    @raylib.draw_circle_lines(
      x.to_int(),
      y.to_int(),
      maxf(game.hero.w, game.hero.h) * 0.65 + game.boost_t * 40.0,
      @raylib.Color::new(120, 248, 255, 210),
    )
  }

  if game.hero.invuln > 0.0 {
    let flicker = Float::from_int(80) + sinf(game.time_s * 14.0) * 70.0 + 70.0
    let aa = clampi(flicker.to_int(), 30, 220)
    @raylib.draw_circle(
      x.to_int(),
      y.to_int(),
      maxf(game.hero.w, game.hero.h) * 0.6,
      @raylib.Color::new(246, 252, 255, aa),
    )
  }
}

///|
fn draw_hack_pulse(game : Game) -> Unit {
  if game.hack_t <= 0.0 {
    return
  }

  let t = Float::from_int(1) - game.hack_t / hack_time
  let rr = hack_radius * t
  let aa = clampi(((Float::from_int(1) - t) * 200.0).to_int(), 0, 200)

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
fn draw_hud(game : Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    ui_panel_h,
    @raylib.Color::new(4, 10, 20, 236),
  )
  @raylib.draw_line(
    0,
    ui_panel_h,
    screen_w,
    ui_panel_h,
    @raylib.Color::new(100, 204, 244, 160),
  )

  draw_bar(
    20,
    16,
    290,
    24,
    game.shield,
    player_shield_max,
    "SHIELD",
    shield_col(),
  )
  draw_bar(
    20,
    48,
    290,
    24,
    game.energy,
    player_energy_max,
    "ENERGY",
    energy_col(),
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
    "BOOST",
    338,
    24,
    18,
    @raylib.Color::new(206, 230, 248, 230),
  )
  @raylib.draw_text(
    cooldown_text(game.boost_cd, boost_cd_time),
    338,
    44,
    16,
    if game.boost_cd <= 0.0 {
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
  @raylib.draw_text("HACK", 498, 24, 18, @raylib.Color::new(212, 224, 255, 230))
  @raylib.draw_text(
    cooldown_text(game.hack_cd, hack_cd_time),
    498,
    44,
    16,
    if game.hack_cd <= 0.0 {
      @raylib.Color::new(128, 248, 170, 240)
    } else {
      @raylib.Color::new(236, 194, 136, 220)
    },
  )

  @raylib.draw_rectangle(
    screen_w - 360,
    14,
    344,
    88,
    @raylib.Color::new(8, 18, 30, 214),
  )
  @raylib.draw_rectangle_lines(
    screen_w - 360,
    14,
    344,
    88,
    @raylib.Color::new(128, 202, 236, 170),
  )

  @raylib.draw_text(
    "SCORE " + game.score.to_string(),
    screen_w - 344,
    22,
    24,
    @raylib.Color::new(228, 248, 255, 240),
  )
  @raylib.draw_text(
    "BEST " + game.best_score.to_string(),
    screen_w - 344,
    50,
    18,
    @raylib.Color::new(178, 226, 244, 230),
  )
  @raylib.draw_text(
    "STAGE " +
    game.stage.to_string() +
    "  CREDITS " +
    game.credits.to_string() +
    "  KILLS " +
    game.kills.to_string(),
    screen_w - 344,
    70,
    16,
    @raylib.Color::new(172, 244, 220, 230),
  )

  let depth_text = "DIST " +
    game.distance.to_int().to_string() +
    " / " +
    game.stage_goal.to_int().to_string()
  draw_right_text(
    depth_text,
    screen_w - 20,
    104,
    18,
    @raylib.Color::new(198, 236, 255, 230),
  )

  @raylib.draw_rectangle(
    screen_w - 334,
    104,
    308,
    10,
    @raylib.Color::new(8, 18, 30, 220),
  )
  let ratio = clampf(game.distance / maxf(game.stage_goal, 1.0), 0.0, 1.0)
  @raylib.draw_rectangle(
    screen_w - 334,
    104,
    (Float::from_int(308) * ratio).to_int(),
    10,
    @raylib.Color::new(128, 248, 210, 220),
  )
  @raylib.draw_rectangle_lines(
    screen_w - 334,
    104,
    308,
    10,
    @raylib.Color::new(132, 206, 232, 170),
  )

  if game.combo >= 2 && game.combo_t > 0.0 {
    let aa = clampi((game.combo_t * 130.0 + 60.0).to_int(), 0, 255)
    draw_center_text(
      "COMBO x" + game.combo.to_string(),
      12,
      28,
      @raylib.Color::new(255, 224, 146, aa),
    )
  }
}

///|
fn draw_button(
  rect : (Float, Float, Float, Float),
  text : String,
  active : Bool,
  primary : Bool,
) -> Unit {
  let aa = if active { 172 } else { 88 }
  let line_col = if primary {
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
    line_col,
  )

  let tw = @raylib.measure_text(text, 24)
  @raylib.draw_text(
    text,
    (rect.0 + rect.2 * 0.5 - Float::from_int(tw) * 0.5).to_int(),
    (rect.1 + rect.3 * 0.5 - 12.0).to_int(),
    24,
    @raylib.Color::new(230, 246, 255, clampi(aa + 46, 0, 255)),
  )
}

///|
fn draw_touch_controls(game : Game) -> Unit {
  let left = btn_left_rect()
  let right = btn_right_rect()
  let up = btn_up_rect()
  let down = btn_down_rect()
  let fire = btn_fire_rect()
  let boost = btn_boost_rect()
  let hack = btn_hack_rect()

  draw_button(left, "<", game.input_x < -0.1, true)
  draw_button(right, ">", game.input_x > 0.1, true)
  draw_button(up, "^", game.input_y < -0.1, true)
  draw_button(down, "v", game.input_y > 0.1, true)
  draw_button(fire, "FIRE", game.input_fire_hold, false)
  draw_button(boost, "BOOST", game.boost_t > 0.0, false)
  draw_button(hack, "HACK", game.hack_t > 0.0, false)
}

///|
fn draw_play_hint(game : Game) -> Unit {
  if game.hint_t > 16.0 {
    return
  }

  let fade : Float = Float::from_int(1) -
    clampf((game.hint_t - 7.0) / 9.0, 0.0, 1.0)
  let aa = clampi((fade * 190.0).to_int(), 0, 190)

  @raylib.draw_rectangle(
    screen_w / 2 - 360,
    screen_h - 54,
    720,
    32,
    @raylib.Color::new(8, 18, 30, aa),
  )
  draw_center_text(
    "Boost rams enemies. Hack disables threats and enemy shots.",
    screen_h - 50,
    21,
    @raylib.Color::new(206, 232, 246, aa + 42),
  )
}

///|
fn draw_title_overlay(
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
    @raylib.Color::new(4, 8, 16, 124),
  )

  draw_center_text(
    "NEON DRIFT BOUNTY 2026",
    110,
    62,
    @raylib.Color::new(188, 244, 255, 250),
  )
  draw_center_text(
    "High-speed bounty pursuit on a living cyber expressway.",
    198,
    28,
    @raylib.Color::new(190, 224, 246, 224),
  )
  draw_center_text(
    "Trade shield, energy, and timing to chain giant combos.",
    232,
    24,
    @raylib.Color::new(178, 216, 238, 224),
  )

  let b = title_start_rect()
  let hover = pointer_on_rect(mx, my, hold, touch_count, b.0, b.1, b.2, b.3)

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
    screen_w / 2 - 462,
    372,
    924,
    236,
    @raylib.Color::new(8, 18, 30, 184),
  )
  @raylib.draw_rectangle_lines(
    screen_w / 2 - 462,
    372,
    924,
    236,
    @raylib.Color::new(124, 204, 236, 170),
  )

  draw_center_text(
    "Keyboard: WASD/Arrows move | Space/J fire | Shift/K boost | L/E hack",
    402,
    22,
    @raylib.Color::new(204, 228, 244, 224),
  )
  draw_center_text(
    "Mobile: Left pad = move | Right pad = Fire, Boost, Hack",
    437,
    22,
    @raylib.Color::new(196, 224, 244, 224),
  )
  draw_center_text(
    "Hit stage distance target to advance. Shield breaks = mission fails.",
    472,
    22,
    @raylib.Color::new(220, 232, 246, 224),
  )
  draw_center_text(
    "Cloaked drones are revealed by Hack pulse.",
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
fn draw_stage_clear_overlay(game : Game) -> Unit {
  let t = ease_out_cubic(clampf(game.result_t / stage_clear_delay, 0.0, 1.0))
  let panel_w = (Float::from_int(430) + t * Float::from_int(140)).to_int()
  let panel_h = (Float::from_int(170) + t * Float::from_int(44)).to_int()

  @raylib.draw_rectangle(
    screen_w / 2 - panel_w / 2,
    screen_h / 2 - panel_h / 2,
    panel_w,
    panel_h,
    @raylib.Color::new(10, 30, 44, 218),
  )
  @raylib.draw_rectangle_lines(
    screen_w / 2 - panel_w / 2,
    screen_h / 2 - panel_h / 2,
    panel_w,
    panel_h,
    @raylib.Color::new(150, 242, 220, 226),
  )

  draw_center_text(
    "STAGE " + game.stage.to_string() + " CLEARED",
    screen_h / 2 - 46,
    44,
    @raylib.Color::new(182, 255, 212, 255),
  )
  draw_center_text(
    "Next pursuit route loading...",
    screen_h / 2 + 8,
    26,
    @raylib.Color::new(206, 236, 240, 230),
  )
  draw_center_text(
    "Tap / Enter to continue now",
    screen_h / 2 + 44,
    20,
    @raylib.Color::new(196, 222, 238, 222),
  )
}

///|
fn draw_game_over_overlay(
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
    "Credits: " +
    game.credits.to_string() +
    "   Kills: " +
    game.kills.to_string(),
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

  let b = result_retry_rect()
  let hover = pointer_on_rect(mx, my, hold, touch_count, b.0, b.1, b.2, b.3)

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
fn draw_world(game : Game, cam_x : Float, cam_y : Float) -> Unit {
  draw_afterimages(game, cam_x, cam_y)
  draw_rings(game, cam_x, cam_y)
  draw_entities(game, cam_x, cam_y)
  draw_bullets(game, cam_x, cam_y)
  draw_sparks(game, cam_x, cam_y)
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
  @raylib.clear_background(bg_top())

  let cam = shake_offset(game)
  let cam_x = cam.0
  let cam_y = cam.1

  draw_sky_backdrop(game, cam_x, cam_y)
  draw_city_horizon(game, cam_x, cam_y)
  draw_road_surface(game, cam_x, cam_y)
  draw_world(game, cam_x, cam_y)
  draw_hack_pulse(game)

  if game.flash_t > 0.0 {
    let aa = clampi((game.flash_t * 220.0).to_int(), 0, 220)
    @raylib.draw_rectangle(
      0,
      0,
      screen_w,
      screen_h,
      @raylib.Color::new(255, 148, 186, aa),
    )
  }

  if game.state != state_title {
    draw_hud(game)
  }

  if game.state == state_title {
    draw_title_overlay(game, mx, my, hold, touch_count)
  } else if game.state == state_play {
    draw_play_hint(game)
    if game.touch_mode {
      draw_touch_controls(game)
    }
  } else if game.state == state_stage_clear {
    draw_stage_clear_overlay(game)
  } else {
    draw_game_over_overlay(game, mx, my, hold, touch_count)
  }
}
