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
fn col_a(c : @raylib.Color, a : Int) -> @raylib.Color {
  @raylib.Color::new(
    c.r.to_int(),
    c.g.to_int(),
    c.b.to_int(),
    @types.clampi(a, 0, 255),
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
fn draw_background(game : @types.Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(8, 22, 38, 255))

  @raylib.draw_rectangle_gradient_v(
    0,
    0,
    @types.screen_w,
    @types.screen_h,
    @raylib.Color::new(18, 36, 58, 255),
    @raylib.Color::new(7, 14, 28, 255),
  )

  for i in 0..<120 {
    let fi = Float::from_int(i)
    let x = (fi * 91.0 + fi * fi * 0.19 + game.ui_t * 11.0) %
      Float::from_int(@types.screen_w)
    let y = (fi * 43.0 + fi * 13.0 + game.ui_t * 4.0) %
      Float::from_int(@types.screen_h)
    let tw : Float = 0.45 + 0.55 * @types.sinf(fi * 0.71 + game.ui_t * 1.6)

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
fn draw_world_back(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    @types.world_x0,
    @types.world_y0,
    @types.world_w,
    @types.world_h,
    @raylib.Color::new(14, 30, 44, 236),
  )

  for row in 0..<22 {
    let y = @types.world_y0 + row * 40
    @raylib.draw_line(
      @types.world_x0 + 8,
      y,
      @types.world_x0 + @types.world_w - 8,
      y,
      @raylib.Color::new(66, 106, 128, 36),
    )
  }

  for col in 0..<25 {
    let x = @types.world_x0 + col * 40
    @raylib.draw_line(
      x,
      @types.world_y0 + 8,
      x,
      @types.world_y0 + @types.world_h - 8,
      @raylib.Color::new(72, 112, 134, 28),
    )
  }

  @raylib.draw_rectangle_lines(
    @types.world_x0,
    @types.world_y0,
    @types.world_w,
    @types.world_h,
    @raylib.Color::new(176, 208, 228, 220),
  )

  let depot_glow : Float = 0.55 + 0.45 * @types.sinf(game.ui_t * 2.0)
  @raylib.draw_circle(
    @types.depot_x().to_int(),
    @types.depot_y().to_int(),
    @types.depot_r() + 16.0 + depot_glow * 7.0,
    @raylib.Color::new(104, 196, 255, 38 + (depot_glow * 28.0).to_int()),
  )
}

///|
fn draw_signal_links(game : @types.Game) -> Unit {
  for tower in game.towers {
    if not(tower.active) {
      continue
    }

    let progress : Float = if tower.need <= 0 {
      0.0
    } else {
      Float::from_int(tower.delivered) / Float::from_int(tower.need)
    }

    let alpha = 32 + (progress * 124.0).to_int()

    @raylib.draw_line(
      @types.depot_x().to_int(),
      @types.depot_y().to_int(),
      tower.x.to_int(),
      tower.y.to_int(),
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
fn draw_towers(game : @types.Game) -> Unit {
  for i in 0..<game.towers.length() {
    if not(game.towers[i].active) {
      continue
    }

    let done = game.towers[i].delivered >= game.towers[i].need
    let base_col = tower_col(done)
    let x = game.towers[i].x.to_int()
    let y = game.towers[i].y.to_int()

    let pulse : Float = 0.8 +
      0.2 * @types.sinf(game.towers[i].pulse_t * 2.2)

    @raylib.draw_circle(
      x,
      y,
      @types.tower_hit_r() + 14.0 + pulse * 4.0,
      col_a(base_col, 56),
    )
    @raylib.draw_circle(
      x,
      y,
      @types.tower_hit_r() + 3.0,
      col_a(base_col, 204),
    )
    @raylib.draw_circle(
      x,
      y,
      @types.tower_hit_r() - 8.0,
      @raylib.Color::new(20, 40, 62, 242),
    )

    if game.state == Play && i == game.nearby_tower {
      @raylib.draw_circle_lines(
        x,
        y,
        @types.tower_interact_r(),
        @raylib.Color::new(246, 248, 255, 210),
      )
    }

    let slots = @types.clampi(game.towers[i].need, 1, 6)
    for k in 0..<slots {
      let a = Float::from_int(k) / Float::from_int(slots) * 6.283
      let px = game.towers[i].x +
        @types.cosf(a) * (@types.tower_hit_r() + 17.0)
      let py = game.towers[i].y +
        @types.sinf(a) * (@types.tower_hit_r() + 17.0)
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
fn draw_depot(game : @types.Game) -> Unit {
  let x = @types.depot_x().to_int()
  let y = @types.depot_y().to_int()

  @raylib.draw_circle(
    x,
    y,
    @types.depot_r(),
    @raylib.Color::new(34, 86, 122, 228),
  )

  @raylib.draw_circle_lines(
    x,
    y,
    @types.depot_r() + 8.0,
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

  if game.state == Play && game.in_depot {
    @raylib.draw_circle_lines(
      x,
      y,
      @types.depot_r() + 20.0,
      @raylib.Color::new(248, 252, 255, 228),
    )
  }
}

///|
fn draw_storms(game : @types.Game) -> Unit {
  for storm in game.storms {
    if not(storm.active) {
      continue
    }

    let base_alpha = 28 + (storm.strength * 28.0).to_int()

    @raylib.draw_circle(
      storm.x.to_int(),
      storm.y.to_int(),
      storm.r,
      @raylib.Color::new(202, 228, 255, base_alpha),
    )

    @raylib.draw_circle_lines(
      storm.x.to_int(),
      storm.y.to_int(),
      storm.r,
      @raylib.Color::new(224, 240, 255, 70),
    )

    for k in 0..<12 {
      let a = storm.phase + Float::from_int(k) * 0.52
      let sx = storm.x + @types.cosf(a) * (storm.r - 12.0)
      let sy = storm.y + @types.sinf(a) * (storm.r - 12.0)
      let ex = sx + storm.vx * 0.06 + @types.cosf(a * 2.0) * 8.0
      let ey = sy + storm.vy * 0.06 + @types.sinf(a * 2.0) * 8.0

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
fn draw_rover(game : @types.Game) -> Unit {
  let x = game.rover_x.to_int()
  let y = game.rover_y.to_int()

  let heat_ratio = @types.clampf(game.rover_heat / @types.heat_max, 0.0, 1.0)
  let energy_ratio = @types.clampf(
    game.rover_energy / @types.energy_max,
    0.0,
    1.0,
  )

  let body_col = @raylib.Color::new(
    64 + (energy_ratio * 70.0).to_int(),
    96 + (heat_ratio * 88.0).to_int(),
    146 + (energy_ratio * 56.0).to_int(),
    255,
  )

  @raylib.draw_circle(
    x,
    y,
    @types.rover_r + 8.0,
    @raylib.Color::new(24, 42, 62, 220),
  )
  @raylib.draw_circle(x, y, @types.rover_r, body_col)
  @raylib.draw_circle_lines(
    x,
    y,
    @types.rover_r + 2.0,
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

  for i in 0..<game.cargo_cells {
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
fn draw_whiteout(game : @types.Game) -> Unit {
  if game.state != Play || game.storm_intensity <= 0.02 {
    return
  }

  let fog : Float = @types.clampf(game.storm_intensity, 0.0, 1.4)
  let fog_alpha = 24 + (fog * 78.0).to_int()

  @raylib.draw_rectangle(
    @types.world_x0,
    @types.world_y0,
    @types.world_w,
    @types.world_h,
    @raylib.Color::new(216, 234, 250, fog_alpha),
  )

  for i in 0..<52 {
    let fi = Float::from_int(i)
    let x0 = @types.world_left() +
      (fi * 76.0 + game.ui_t * (220.0 + fog * 120.0)) %
        Float::from_int(@types.world_w)
    let y0 = @types.world_top() +
      (fi * 47.0 + fi * fi * 0.33 + game.ui_t * 40.0) %
        Float::from_int(@types.world_h)

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
  let vx0 = @types.clampi(
    (game.rover_x - vis_r).to_int(),
    @types.world_x0,
    @types.world_x0 + @types.world_w,
  )
  let vy0 = @types.clampi(
    (game.rover_y - vis_r).to_int(),
    @types.world_y0,
    @types.world_y0 + @types.world_h,
  )
  let vx1 = @types.clampi(
    (game.rover_x + vis_r).to_int(),
    @types.world_x0,
    @types.world_x0 + @types.world_w,
  )
  let vy1 = @types.clampi(
    (game.rover_y + vis_r).to_int(),
    @types.world_y0,
    @types.world_y0 + @types.world_h,
  )

  let shadow = @raylib.Color::new(
    10,
    18,
    28,
    42 + (fog * 58.0).to_int(),
  )
  let wx1 = @types.world_x0 + @types.world_w
  let wy1 = @types.world_y0 + @types.world_h

  draw_mask_rect(
    @types.world_x0,
    @types.world_y0,
    @types.world_w,
    vy0 - @types.world_y0,
    shadow,
  )
  draw_mask_rect(
    @types.world_x0,
    vy1,
    @types.world_w,
    wy1 - vy1,
    shadow,
  )
  draw_mask_rect(
    @types.world_x0,
    vy0,
    vx0 - @types.world_x0,
    vy1 - vy0,
    shadow,
  )
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
    @types.clampf(value / maxv, 0.0, 1.0)
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
fn draw_panel(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    @types.panel_x0,
    @types.world_y0,
    @types.panel_w,
    @types.world_h,
    @raylib.Color::new(10, 24, 38, 236),
  )

  @raylib.draw_rectangle_lines(
    @types.panel_x0,
    @types.world_y0,
    @types.panel_w,
    @types.world_h,
    @raylib.Color::new(164, 196, 216, 184),
  )

  @raylib.draw_text(
    "ARCTIC RELAY OPS",
    @types.panel_x0 + 22,
    @types.world_y0 + 18,
    28,
    @raylib.Color::new(230, 244, 255, 248),
  )

  @raylib.draw_text(
    "Stage: \{game.stage}",
    @types.panel_x0 + 22,
    @types.world_y0 + 62,
    22,
    @raylib.Color::new(194, 226, 246, 236),
  )

  @raylib.draw_text(
    "Best Stage: \{game.best_stage}",
    @types.panel_x0 + 190,
    @types.world_y0 + 62,
    20,
    @raylib.Color::new(172, 210, 236, 220),
  )

  let timer_col = if game.timer_s <= 18.0 {
    @raylib.Color::new(255, 146, 132, 248)
  } else {
    @raylib.Color::new(182, 228, 250, 244)
  }

  @raylib.draw_text(
    "Timer: \{@types.maxf(0.0, game.timer_s).to_int()}s",
    @types.panel_x0 + 22,
    @types.world_y0 + 98,
    28,
    timer_col,
  )

  @raylib.draw_text(
    "Objective: \{game.objective_done}/\{game.objective_total}",
    @types.panel_x0 + 22,
    @types.world_y0 + 136,
    24,
    @raylib.Color::new(232, 246, 255, 230),
  )

  @raylib.draw_text(
    "Cargo Cells: \{game.cargo_cells}/\{@types.cargo_capacity}",
    @types.panel_x0 + 22,
    @types.world_y0 + 168,
    22,
    @raylib.Color::new(246, 228, 162, 236),
  )

  draw_bar(
    "Energy",
    @types.panel_x0 + 22,
    @types.world_y0 + 208,
    @types.panel_w - 44,
    28,
    game.rover_energy,
    @types.energy_max,
    @raylib.Color::new(94, 216, 246, 236),
  )

  draw_bar(
    "Heat",
    @types.panel_x0 + 22,
    @types.world_y0 + 264,
    @types.panel_w - 44,
    28,
    game.rover_heat,
    @types.heat_max,
    @raylib.Color::new(254, 184, 122, 238),
  )

  draw_bar(
    "Storm Load",
    @types.panel_x0 + 22,
    @types.world_y0 + 320,
    @types.panel_w - 44,
    28,
    game.storm_intensity * 55.0,
    100.0,
    @raylib.Color::new(210, 224, 250, 220),
  )

  @raylib.draw_text(
    "Depot: load cells + recover heat/energy",
    @types.panel_x0 + 22,
    @types.world_y0 + 374,
    18,
    @raylib.Color::new(170, 204, 224, 224),
  )

  @raylib.draw_text(
    "Desktop: WASD/Arrows move",
    @types.panel_x0 + 22,
    @types.world_y0 + 416,
    18,
    @raylib.Color::new(184, 216, 236, 226),
  )

  @raylib.draw_text(
    "Action: E / Space / Enter / LMB",
    @types.panel_x0 + 22,
    @types.world_y0 + 440,
    18,
    @raylib.Color::new(184, 216, 236, 226),
  )

  @raylib.draw_text(
    "Esc: return to title",
    @types.panel_x0 + 22,
    @types.world_y0 + 464,
    18,
    @raylib.Color::new(184, 216, 236, 226),
  )

  if game.state == Play && game.hint_t > 0.0 {
    let a = (@types.clampf(game.hint_t / 1.4, 0.0, 1.0) * 230.0).to_int()
    @raylib.draw_rectangle(
      @types.world_x0 + 14,
      @types.world_y0 + @types.world_h - 58,
      @types.world_w - 28,
      40,
      @raylib.Color::new(12, 26, 40, a),
    )
    @raylib.draw_text(
      game.hint_text,
      @types.world_x0 + 26,
      @types.world_y0 + @types.world_h - 48,
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
fn draw_touch_controls(game : @types.Game) -> Unit {
  if game.state != Play {
    return
  }

  let mx = game.mouse_x
  let my = game.mouse_y
  let hold = game.mouse_hold
  let touch_count = game.touch_count

  let left_btn = @types.touch_left_rect()
  let right_btn = @types.touch_right_rect()
  let up_btn = @types.touch_up_rect()
  let down_btn = @types.touch_down_rect()
  let action_btn = @types.touch_action_rect()

  let left_held = @types.pointer_on_rect(
    mx, my, hold, touch_count, left_btn.0, left_btn.1, left_btn.2, left_btn.3,
  )
  let right_held = @types.pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    right_btn.0,
    right_btn.1,
    right_btn.2,
    right_btn.3,
  )
  let up_held = @types.pointer_on_rect(
    mx, my, hold, touch_count, up_btn.0, up_btn.1, up_btn.2, up_btn.3,
  )
  let down_held = @types.pointer_on_rect(
    mx, my, hold, touch_count, down_btn.0, down_btn.1, down_btn.2, down_btn.3,
  )
  let action_held = @types.pointer_on_rect(
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
fn draw_title_overlay(game : @types.Game) -> Unit {
  let mx = game.mouse_x
  let my = game.mouse_y
  let hold = game.mouse_hold
  let touch_count = game.touch_count

  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_w,
    @types.screen_h,
    @raylib.Color::new(8, 16, 30, 164),
  )

  draw_center_text(
    "ARCTIC SIGNAL RELAY",
    @types.screen_h / 2 - 210,
    68,
    @raylib.Color::new(238, 248, 255, 252),
  )

  draw_center_text(
    "Run power cells from depot to relay towers before the storm collapses comms.",
    @types.screen_h / 2 - 128,
    28,
    @raylib.Color::new(194, 224, 244, 236),
  )

  draw_center_text(
    "Manage heat + energy, survive whiteouts, and keep each tower online.",
    @types.screen_h / 2 - 90,
    28,
    @raylib.Color::new(194, 224, 244, 236),
  )

  let start_btn = @types.title_start_rect()
  let hover = @types.pointer_on_rect(
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
    @types.screen_h / 2 + 258,
    24,
    @raylib.Color::new(188, 216, 236, 226),
  )

  draw_center_text(
    "Mobile: use panel D-pad + ACT button",
    @types.screen_h / 2 + 292,
    24,
    @raylib.Color::new(188, 216, 236, 226),
  )
}

///|
fn draw_result_overlay(game : @types.Game) -> Unit {
  let mx = game.mouse_x
  let my = game.mouse_y
  let hold = game.mouse_hold
  let touch_count = game.touch_count

  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_w,
    @types.screen_h,
    @raylib.Color::new(8, 16, 30, 170),
  )

  let title = if game.result_win { "SHIFT COMPLETE" } else { "SHIFT FAILED" }
  let title_col = if game.result_win {
    @raylib.Color::new(212, 252, 226, 252)
  } else {
    @raylib.Color::new(255, 180, 162, 252)
  }

  draw_center_text(title, @types.screen_h / 2 - 176, 72, title_col)
  draw_center_text(
    game.result_note,
    @types.screen_h / 2 - 90,
    34,
    @raylib.Color::new(216, 234, 248, 240),
  )

  draw_center_text(
    "Objective \{game.objective_done}/\{game.objective_total} | Stage \{game.stage}",
    @types.screen_h / 2 - 36,
    28,
    @raylib.Color::new(194, 220, 238, 236),
  )

  let primary = @types.result_primary_rect()
  let secondary = @types.result_secondary_rect()

  let primary_hover = @types.pointer_on_rect(
    mx,
    my,
    hold,
    touch_count,
    primary.0,
    primary.1,
    primary.2,
    primary.3,
  )

  let secondary_hover = @types.pointer_on_rect(
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
    @types.screen_h / 2 + 320,
    24,
    @raylib.Color::new(188, 214, 234, 224),
  )
}

///|
pub fn draw_frame(game : @types.Game) -> Unit {
  draw_background(game)
  draw_world_back(game)
  draw_signal_links(game)
  draw_storms(game)
  draw_towers(game)
  draw_depot(game)
  draw_rover(game)
  draw_whiteout(game)
  draw_panel(game)
  draw_touch_controls(game)

  match game.state {
    Title => draw_title_overlay(game)
    Play => ()
    Result => draw_result_overlay(game)
  }
}
