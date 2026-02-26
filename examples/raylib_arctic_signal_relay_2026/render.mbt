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
fn col_a(c : @raylib.Color, a : Int) -> @raylib.Color {
  @raylib.Color::new(
    c.r.to_int(),
    c.g.to_int(),
    c.b.to_int(),
    clampi(a, 0, 255),
  )
}

///|
fn draw_mask_rect(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  col : @raylib.Color,
) -> Unit {
  if w <= 0 || h <= 0 {
    return
  }
  @raylib.draw_rectangle(x, y, w, h, col)
}

///|
fn draw_background(game : Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(8, 22, 38, 255))

  @raylib.draw_rectangle_gradient_v(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(18, 36, 58, 255),
    @raylib.Color::new(7, 14, 28, 255),
  )

  for i = 0; i < 120; i = i + 1 {
    let fi = Float::from_int(i)
    let x = (fi * 91.0 + fi * fi * 0.19 + game.ui_t * 11.0) %
      Float::from_int(screen_w)
    let y = (fi * 43.0 + fi * 13.0 + game.ui_t * 4.0) %
      Float::from_int(screen_h)
    let tw : Float = 0.45 + 0.55 * sinf(fi * 0.71 + game.ui_t * 1.6)

    @raylib.draw_circle(
      x.to_int(),
      y.to_int(),
      0.8 + tw * 1.1,
      @raylib.Color::new(
        180 + (tw * 60.0).to_int(),
        220,
        255,
        48 + (tw * 72.0).to_int(),
      ),
    )
  }
}

///|
fn draw_world_back(game : Game) -> Unit {
  @raylib.draw_rectangle(
    world_x0,
    world_y0,
    world_w,
    world_h,
    @raylib.Color::new(14, 30, 44, 236),
  )

  for row = 0; row < 22; row = row + 1 {
    let y = world_y0 + row * 40
    @raylib.draw_line(
      world_x0 + 8,
      y,
      world_x0 + world_w - 8,
      y,
      @raylib.Color::new(66, 106, 128, 36),
    )
  }

  for col = 0; col < 25; col = col + 1 {
    let x = world_x0 + col * 40
    @raylib.draw_line(
      x,
      world_y0 + 8,
      x,
      world_y0 + world_h - 8,
      @raylib.Color::new(72, 112, 134, 28),
    )
  }

  @raylib.draw_rectangle_lines(
    world_x0,
    world_y0,
    world_w,
    world_h,
    @raylib.Color::new(176, 208, 228, 220),
  )

  let depot_glow : Float = 0.55 + 0.45 * sinf(game.ui_t * 2.0)
  @raylib.draw_circle(
    depot_x().to_int(),
    depot_y().to_int(),
    depot_r() + 16.0 + depot_glow * 7.0,
    @raylib.Color::new(104, 196, 255, 38 + (depot_glow * 28.0).to_int()),
  )
}

///|
fn draw_signal_links(game : Game) -> Unit {
  for i = 0; i < game.towers.length(); i = i + 1 {
    if not(game.towers[i].active) {
      continue
    }

    let progress : Float = if game.towers[i].need <= 0 {
      0.0
    } else {
      Float::from_int(game.towers[i].delivered) /
      Float::from_int(game.towers[i].need)
    }

    let alpha = 32 + (progress * 124.0).to_int()

    @raylib.draw_line(
      depot_x().to_int(),
      depot_y().to_int(),
      game.towers[i].x.to_int(),
      game.towers[i].y.to_int(),
      @raylib.Color::new(118, 206, 255, alpha),
    )
  }
}

///|
fn tower_col(active : Bool) -> @raylib.Color {
  if active {
    @raylib.Color::new(116, 244, 226, 255)
  } else {
    @raylib.Color::new(80, 130, 166, 240)
  }
}

///|
fn draw_towers(game : Game) -> Unit {
  for i = 0; i < game.towers.length(); i = i + 1 {
    if not(game.towers[i].active) {
      continue
    }

    let done = game.towers[i].delivered >= game.towers[i].need
    let base_col = tower_col(done)
    let x = game.towers[i].x.to_int()
    let y = game.towers[i].y.to_int()

    let pulse : Float = 0.8 + 0.2 * sinf(game.towers[i].pulse_t * 2.2)

    @raylib.draw_circle(
      x,
      y,
      tower_hit_r() + 14.0 + pulse * 4.0,
      col_a(base_col, 56),
    )
    @raylib.draw_circle(x, y, tower_hit_r() + 3.0, col_a(base_col, 204))
    @raylib.draw_circle(
      x,
      y,
      tower_hit_r() - 8.0,
      @raylib.Color::new(20, 40, 62, 242),
    )

    if game.state == state_play && i == game.nearby_tower {
      @raylib.draw_circle_lines(
        x,
        y,
        tower_interact_r(),
        @raylib.Color::new(246, 248, 255, 210),
      )
    }

    let slots = clampi(game.towers[i].need, 1, 6)
    for k = 0; k < slots; k = k + 1 {
      let a = Float::from_int(k) / Float::from_int(slots) * 6.283
      let px = game.towers[i].x + cosf(a) * (tower_hit_r() + 17.0)
      let py = game.towers[i].y + sinf(a) * (tower_hit_r() + 17.0)
      let col = if k < game.towers[i].delivered {
        @raylib.Color::new(232, 255, 208, 236)
      } else {
        @raylib.Color::new(58, 92, 114, 190)
      }
      @raylib.draw_circle(px.to_int(), py.to_int(), 4.0, col)
    }

    let txt = "\{game.towers[i].delivered}/\{game.towers[i].need}"
    @raylib.draw_text(
      txt,
      x - @raylib.measure_text(txt, 18) / 2,
      y - 10,
      18,
      @raylib.Color::new(238, 246, 255, 230),
    )
  }
}

///|
fn draw_depot(game : Game) -> Unit {
  let x = depot_x().to_int()
  let y = depot_y().to_int()

  @raylib.draw_circle(x, y, depot_r(), @raylib.Color::new(34, 86, 122, 228))

  @raylib.draw_circle_lines(
    x,
    y,
    depot_r() + 8.0,
    @raylib.Color::new(180, 228, 255, 198),
  )

  @raylib.draw_rectangle(
    x - 24,
    y - 18,
    48,
    36,
    @raylib.Color::new(42, 110, 148, 250),
  )

  @raylib.draw_text(
    "CELL",
    x - @raylib.measure_text("CELL", 16) / 2,
    y - 8,
    16,
    @raylib.Color::new(232, 246, 255, 250),
  )

  if game.state == state_play && game.in_depot {
    @raylib.draw_circle_lines(
      x,
      y,
      depot_r() + 20.0,
      @raylib.Color::new(248, 252, 255, 228),
    )
  }
}

///|
fn draw_storms(game : Game) -> Unit {
  for i = 0; i < game.storms.length(); i = i + 1 {
    if not(game.storms[i].active) {
      continue
    }

    let base_alpha = 28 + (game.storms[i].strength * 28.0).to_int()

    @raylib.draw_circle(
      game.storms[i].x.to_int(),
      game.storms[i].y.to_int(),
      game.storms[i].r,
      @raylib.Color::new(202, 228, 255, base_alpha),
    )

    @raylib.draw_circle_lines(
      game.storms[i].x.to_int(),
      game.storms[i].y.to_int(),
      game.storms[i].r,
      @raylib.Color::new(224, 240, 255, 70),
    )

    for k = 0; k < 12; k = k + 1 {
      let a = game.storms[i].phase + Float::from_int(k) * 0.52
      let sx = game.storms[i].x + cosf(a) * (game.storms[i].r - 12.0)
      let sy = game.storms[i].y + sinf(a) * (game.storms[i].r - 12.0)
      let ex = sx + game.storms[i].vx * 0.06 + cosf(a * 2.0) * 8.0
      let ey = sy + game.storms[i].vy * 0.06 + sinf(a * 2.0) * 8.0

      @raylib.draw_line(
        sx.to_int(),
        sy.to_int(),
        ex.to_int(),
        ey.to_int(),
        @raylib.Color::new(240, 248, 255, 92),
      )
    }
  }
}

///|
fn draw_rover(game : Game) -> Unit {
  let x = game.rover_x.to_int()
  let y = game.rover_y.to_int()

  let heat_ratio = clampf(game.rover_heat / heat_max, 0.0, 1.0)
  let energy_ratio = clampf(game.rover_energy / energy_max, 0.0, 1.0)

  let body_col = @raylib.Color::new(
    64 + (energy_ratio * 70.0).to_int(),
    96 + (heat_ratio * 88.0).to_int(),
    146 + (energy_ratio * 56.0).to_int(),
    255,
  )

  @raylib.draw_circle(x, y, rover_r + 8.0, @raylib.Color::new(24, 42, 62, 220))
  @raylib.draw_circle(x, y, rover_r, body_col)
  @raylib.draw_circle_lines(
    x,
    y,
    rover_r + 2.0,
    @raylib.Color::new(224, 244, 255, 220),
  )

  let head_x = game.rover_x + game.rover_vx * 0.10
  let head_y = game.rover_y + game.rover_vy * 0.10
  @raylib.draw_circle(
    head_x.to_int(),
    head_y.to_int(),
    8.0,
    @raylib.Color::new(232, 246, 255, 240),
  )

  for i = 0; i < game.cargo_cells; i = i + 1 {
    let off_x = -16 + i * 16
    @raylib.draw_rectangle(
      x + off_x - 5,
      y - 32,
      10,
      10,
      @raylib.Color::new(248, 224, 128, 242),
    )
  }
}

///|
fn draw_whiteout(game : Game) -> Unit {
  if game.state != state_play || game.storm_intensity <= 0.02 {
    return
  }

  let fog : Float = clampf(game.storm_intensity, 0.0, 1.4)
  let fog_alpha = 24 + (fog * 78.0).to_int()

  @raylib.draw_rectangle(
    world_x0,
    world_y0,
    world_w,
    world_h,
    @raylib.Color::new(216, 234, 250, fog_alpha),
  )

  for i = 0; i < 52; i = i + 1 {
    let fi = Float::from_int(i)
    let x0 = world_left() +
      (fi * 76.0 + game.ui_t * (220.0 + fog * 120.0)) % Float::from_int(world_w)
    let y0 = world_top() +
      (fi * 47.0 + fi * fi * 0.33 + game.ui_t * 40.0) % Float::from_int(world_h)

    let len : Float = 18.0 + fog * 34.0

    @raylib.draw_line(
      x0.to_int(),
      y0.to_int(),
      (x0 - len).to_int(),
      (y0 + len * 0.35).to_int(),
      @raylib.Color::new(248, 252, 255, 90 + (fog * 40.0).to_int()),
    )
  }

  let vis_r : Float = 270.0 - fog * 120.0
  let vx0 = clampi(
    (game.rover_x - vis_r).to_int(),
    world_x0,
    world_x0 + world_w,
  )
  let vy0 = clampi(
    (game.rover_y - vis_r).to_int(),
    world_y0,
    world_y0 + world_h,
  )
  let vx1 = clampi(
    (game.rover_x + vis_r).to_int(),
    world_x0,
    world_x0 + world_w,
  )
  let vy1 = clampi(
    (game.rover_y + vis_r).to_int(),
    world_y0,
    world_y0 + world_h,
  )

  let shadow = @raylib.Color::new(10, 18, 28, 42 + (fog * 58.0).to_int())
  let wx1 = world_x0 + world_w
  let wy1 = world_y0 + world_h

  draw_mask_rect(world_x0, world_y0, world_w, vy0 - world_y0, shadow)
  draw_mask_rect(world_x0, vy1, world_w, wy1 - vy1, shadow)
  draw_mask_rect(world_x0, vy0, vx0 - world_x0, vy1 - vy0, shadow)
  draw_mask_rect(vx1, vy0, wx1 - vx1, vy1 - vy0, shadow)

  @raylib.draw_circle_lines(
    game.rover_x.to_int(),
    game.rover_y.to_int(),
    vis_r,
    @raylib.Color::new(224, 238, 255, 80),
  )
}

///|
fn draw_bar(
  label : String,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  value : Float,
  maxv : Float,
  col : @raylib.Color,
) -> Unit {
  let ratio : Float = if maxv <= 0.0 {
    0.0
  } else {
    clampf(value / maxv, 0.0, 1.0)
  }

  @raylib.draw_text(
    label,
    x,
    y - 20,
    18,
    @raylib.Color::new(208, 228, 244, 240),
  )
  @raylib.draw_rectangle(x, y, w, h, @raylib.Color::new(20, 38, 56, 236))
  @raylib.draw_rectangle(
    x + 2,
    y + 2,
    (Float::from_int(w - 4) * ratio).to_int(),
    h - 4,
    col,
  )
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(172, 202, 222, 180),
  )

  let txt = "\{value.to_int()}/\{maxv.to_int()}"
  @raylib.draw_text(
    txt,
    x + w - @raylib.measure_text(txt, 16) - 8,
    y + 4,
    16,
    @raylib.Color::new(246, 250, 255, 230),
  )
}

///|
fn draw_panel(game : Game) -> Unit {
  @raylib.draw_rectangle(
    panel_x0,
    world_y0,
    panel_w,
    world_h,
    @raylib.Color::new(10, 24, 38, 236),
  )

  @raylib.draw_rectangle_lines(
    panel_x0,
    world_y0,
    panel_w,
    world_h,
    @raylib.Color::new(164, 196, 216, 184),
  )

  @raylib.draw_text(
    "ARCTIC RELAY OPS",
    panel_x0 + 22,
    world_y0 + 18,
    28,
    @raylib.Color::new(230, 244, 255, 248),
  )

  @raylib.draw_text(
    "Stage: \{game.stage}",
    panel_x0 + 22,
    world_y0 + 62,
    22,
    @raylib.Color::new(194, 226, 246, 236),
  )

  @raylib.draw_text(
    "Best Stage: \{game.best_stage}",
    panel_x0 + 190,
    world_y0 + 62,
    20,
    @raylib.Color::new(172, 210, 236, 220),
  )

  let timer_col = if game.timer_s <= 18.0 {
    @raylib.Color::new(255, 146, 132, 248)
  } else {
    @raylib.Color::new(182, 228, 250, 244)
  }

  @raylib.draw_text(
    "Timer: \{maxf(0.0, game.timer_s).to_int()}s",
    panel_x0 + 22,
    world_y0 + 98,
    28,
    timer_col,
  )

  @raylib.draw_text(
    "Objective: \{game.objective_done}/\{game.objective_total}",
    panel_x0 + 22,
    world_y0 + 136,
    24,
    @raylib.Color::new(232, 246, 255, 230),
  )

  @raylib.draw_text(
    "Cargo Cells: \{game.cargo_cells}/\{cargo_capacity}",
    panel_x0 + 22,
    world_y0 + 168,
    22,
    @raylib.Color::new(246, 228, 162, 236),
  )

  draw_bar(
    "Energy",
    panel_x0 + 22,
    world_y0 + 208,
    panel_w - 44,
    28,
    game.rover_energy,
    energy_max,
    @raylib.Color::new(94, 216, 246, 236),
  )

  draw_bar(
    "Heat",
    panel_x0 + 22,
    world_y0 + 264,
    panel_w - 44,
    28,
    game.rover_heat,
    heat_max,
    @raylib.Color::new(254, 184, 122, 238),
  )

  draw_bar(
    "Storm Load",
    panel_x0 + 22,
    world_y0 + 320,
    panel_w - 44,
    28,
    game.storm_intensity * 55.0,
    100.0,
    @raylib.Color::new(210, 224, 250, 220),
  )

  @raylib.draw_text(
    "Depot: load cells + recover heat/energy",
    panel_x0 + 22,
    world_y0 + 374,
    18,
    @raylib.Color::new(170, 204, 224, 224),
  )

  @raylib.draw_text(
    "Desktop: WASD/Arrows move",
    panel_x0 + 22,
    world_y0 + 416,
    18,
    @raylib.Color::new(184, 216, 236, 226),
  )

  @raylib.draw_text(
    "Action: E / Space / Enter / LMB",
    panel_x0 + 22,
    world_y0 + 440,
    18,
    @raylib.Color::new(184, 216, 236, 226),
  )

  @raylib.draw_text(
    "Esc: return to title",
    panel_x0 + 22,
    world_y0 + 464,
    18,
    @raylib.Color::new(184, 216, 236, 226),
  )

  if game.state == state_play && game.hint_t > 0.0 {
    let a = (clampf(game.hint_t / 1.4, 0.0, 1.0) * 230.0).to_int()
    @raylib.draw_rectangle(
      world_x0 + 14,
      world_y0 + world_h - 58,
      world_w - 28,
      40,
      @raylib.Color::new(12, 26, 40, a),
    )
    @raylib.draw_text(
      game.hint_text,
      world_x0 + 26,
      world_y0 + world_h - 48,
      22,
      @raylib.Color::new(236, 246, 255, a),
    )
  }
}

///|
fn draw_touch_btn(
  label : String,
  rect : (Int, Int, Int, Int),
  held : Bool,
  bright : Bool,
) -> Unit {
  let base_col = if bright {
    @raylib.Color::new(86, 160, 206, if held { 228 } else { 166 })
  } else {
    @raylib.Color::new(64, 110, 146, if held { 212 } else { 132 })
  }

  @raylib.draw_rectangle(rect.0, rect.1, rect.2, rect.3, base_col)
  @raylib.draw_rectangle_lines(
    rect.0,
    rect.1,
    rect.2,
    rect.3,
    @raylib.Color::new(204, 232, 248, if held { 240 } else { 164 }),
  )

  @raylib.draw_text(
    label,
    rect.0 + rect.2 / 2 - @raylib.measure_text(label, 24) / 2,
    rect.1 + rect.3 / 2 - 12,
    24,
    @raylib.Color::new(246, 250, 255, 242),
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

  let left_btn = touch_left_rect()
  let right_btn = touch_right_rect()
  let up_btn = touch_up_rect()
  let down_btn = touch_down_rect()
  let action_btn = touch_action_rect()

  let left_held = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    left_btn.0,
    left_btn.1,
    left_btn.2,
    left_btn.3,
  )
  let right_held = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    right_btn.0,
    right_btn.1,
    right_btn.2,
    right_btn.3,
  )
  let up_held = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    up_btn.0,
    up_btn.1,
    up_btn.2,
    up_btn.3,
  )
  let down_held = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    down_btn.0,
    down_btn.1,
    down_btn.2,
    down_btn.3,
  )
  let action_held = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    action_btn.0,
    action_btn.1,
    action_btn.2,
    action_btn.3,
  )

  draw_touch_btn("<", left_btn, left_held, game.touch_mode)
  draw_touch_btn(">", right_btn, right_held, game.touch_mode)
  draw_touch_btn("^", up_btn, up_held, game.touch_mode)
  draw_touch_btn("v", down_btn, down_held, game.touch_mode)
  draw_touch_btn("ACT", action_btn, action_held, true)
}

///|
fn draw_button(
  rect : (Int, Int, Int, Int),
  label : String,
  hover : Bool,
  bold : Bool,
) -> Unit {
  let fill = if bold {
    if hover {
      @raylib.Color::new(94, 182, 220, 250)
    } else {
      @raylib.Color::new(62, 148, 186, 236)
    }
  } else if hover {
    @raylib.Color::new(78, 124, 162, 232)
  } else {
    @raylib.Color::new(50, 94, 126, 220)
  }

  @raylib.draw_rectangle(rect.0, rect.1, rect.2, rect.3, fill)
  @raylib.draw_rectangle_lines(
    rect.0,
    rect.1,
    rect.2,
    rect.3,
    @raylib.Color::new(222, 240, 252, 240),
  )

  @raylib.draw_text(
    label,
    rect.0 + rect.2 / 2 - @raylib.measure_text(label, 34) / 2,
    rect.1 + rect.3 / 2 - 17,
    34,
    @raylib.Color::new(246, 252, 255, 246),
  )
}

///|
fn draw_title_overlay(
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
    @raylib.Color::new(8, 16, 30, 164),
  )

  draw_center_text(
    "ARCTIC SIGNAL RELAY",
    screen_h / 2 - 210,
    68,
    @raylib.Color::new(238, 248, 255, 252),
  )

  draw_center_text(
    "Run power cells from depot to relay towers before the storm collapses comms.",
    screen_h / 2 - 128,
    28,
    @raylib.Color::new(194, 224, 244, 236),
  )

  draw_center_text(
    "Manage heat + energy, survive whiteouts, and keep each tower online.",
    screen_h / 2 - 90,
    28,
    @raylib.Color::new(194, 224, 244, 236),
  )

  let start_btn = title_start_rect()
  let hover = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    start_btn.0,
    start_btn.1,
    start_btn.2,
    start_btn.3,
  )

  draw_button(start_btn, "START SHIFT", hover, true)

  draw_center_text(
    "Desktop: WASD / Arrows, E or Space to load/deliver",
    screen_h / 2 + 258,
    24,
    @raylib.Color::new(188, 216, 236, 226),
  )

  draw_center_text(
    "Mobile: use panel D-pad + ACT button",
    screen_h / 2 + 292,
    24,
    @raylib.Color::new(188, 216, 236, 226),
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
    @raylib.Color::new(8, 16, 30, 170),
  )

  let title = if game.result_win { "SHIFT COMPLETE" } else { "SHIFT FAILED" }
  let title_col = if game.result_win {
    @raylib.Color::new(212, 252, 226, 252)
  } else {
    @raylib.Color::new(255, 180, 162, 252)
  }

  draw_center_text(title, screen_h / 2 - 176, 72, title_col)
  draw_center_text(
    game.result_note,
    screen_h / 2 - 90,
    34,
    @raylib.Color::new(216, 234, 248, 240),
  )

  draw_center_text(
    "Objective \{game.objective_done}/\{game.objective_total} | Stage \{game.stage}",
    screen_h / 2 - 36,
    28,
    @raylib.Color::new(194, 220, 238, 236),
  )

  let primary = result_primary_rect()
  let secondary = result_secondary_rect()

  let primary_hover = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    primary.0,
    primary.1,
    primary.2,
    primary.3,
  )

  let secondary_hover = pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    secondary.0,
    secondary.1,
    secondary.2,
    secondary.3,
  )

  let primary_label = if game.result_win { "NEXT SHIFT" } else { "RETRY SHIFT" }

  draw_button(primary, primary_label, primary_hover, true)
  draw_button(secondary, "RESTART RUN", secondary_hover, false)

  draw_center_text(
    "Enter/Space: primary | R: restart from stage 1",
    screen_h / 2 + 320,
    24,
    @raylib.Color::new(188, 214, 234, 224),
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
  draw_world_back(game)
  draw_signal_links(game)
  draw_storms(game)
  draw_towers(game)
  draw_depot(game)
  draw_rover(game)
  draw_whiteout(game)
  draw_panel(game)
  draw_touch_controls(game, mx, my, hold, touch_count)

  if game.state == state_title {
    draw_title_overlay(mx, my, hold, touch_count)
  } else if game.state == state_result {
    draw_result_overlay(game, mx, my, hold, touch_count)
  }
}
