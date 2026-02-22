///|
fn draw_center_text(
  text : String,
  y : Int,
  size : Int,
  color : @raylib.Color,
) -> Unit {
  let w : Int = @raylib.measure_text(text, size)
  @raylib.draw_text(text, screen_w / 2 - w / 2, y, size, color)
}

///|
fn map_px_w() -> Int {
  grid_w * tile_size
}

///|
fn map_px_h() -> Int {
  grid_h * tile_size
}

///|
fn cell_screen_x(x : Int) -> Int {
  map_x + x * tile_size
}

///|
fn cell_screen_y(y : Int) -> Int {
  map_y + y * tile_size
}

///|
fn cell_center_x(x : Int) -> Int {
  cell_screen_x(x) + tile_size / 2
}

///|
fn cell_center_y(y : Int) -> Int {
  cell_screen_y(y) + tile_size / 2
}

///|
fn draw_bg(game : Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(18, 16, 20, 255))

  let pulse : Float = Float::from_double(
    @math.sin((game.ui_t * 0.8).to_double()),
  )

  @raylib.draw_circle(
    220,
    180,
    180.0 + pulse * 18.0,
    @raylib.Color::new(145, 38, 22, 42),
  )
  @raylib.draw_circle(
    screen_w - 260,
    170,
    210.0 - pulse * 20.0,
    @raylib.Color::new(66, 86, 118, 34),
  )

  for i = 0; i < 16; i = i + 1 {
    let y : Int = i * 66 - 24
    @raylib.draw_rectangle(
      0,
      y,
      screen_w,
      52,
      @raylib.Color::new(16 + i * 3 % 18, 14 + i * 4 % 22, 20 + i * 4 % 24, 22),
    )
  }
}

///|
fn draw_cell_base(game : Game, x : Int, y : Int) -> Unit {
  let px : Int = cell_screen_x(x)
  let py : Int = cell_screen_y(y)
  let t : Int = tile_at(game, x, y)

  let base : @raylib.Color = if t == tile_rock {
    @raylib.Color::new(52, 52, 58, 255)
  } else if t == tile_depot {
    @raylib.Color::new(48, 86, 118, 255)
  } else if t == tile_shelter {
    @raylib.Color::new(56, 108, 80, 255)
  } else {
    @raylib.Color::new(98, 70, 54, 255)
  }

  @raylib.draw_rectangle(px, py, tile_size, tile_size, base)

  @raylib.draw_rectangle_lines(
    px,
    py,
    tile_size,
    tile_size,
    @raylib.Color::new(34, 28, 26, 160),
  )

  if lava_at(game, x, y) {
    @raylib.draw_rectangle(
      px + 4,
      py + 4,
      tile_size - 8,
      tile_size - 8,
      @raylib.Color::new(230, 82, 22, 220),
    )

    let core_r : Float = Float::from_int(tile_size / 2 - 8)
    @raylib.draw_circle(
      px + tile_size / 2,
      py + tile_size / 2,
      core_r,
      @raylib.Color::new(255, 170, 58, 220),
    )
  }
}

///|
fn draw_map(game : Game) -> Unit {
  @raylib.draw_rectangle(
    map_x - 14,
    map_y - 14,
    map_px_w() + 28,
    map_px_h() + 28,
    @raylib.Color::new(20, 20, 24, 230),
  )

  @raylib.draw_rectangle_lines(
    map_x - 14,
    map_y - 14,
    map_px_w() + 28,
    map_px_h() + 28,
    @raylib.Color::new(188, 154, 116, 210),
  )

  for y = 0; y < grid_h; y = y + 1 {
    for x = 0; x < grid_w; x = x + 1 {
      draw_cell_base(game, x, y)
    }
  }

  if game.selected_tx >= 0 && game.selected_ty >= 0 {
    let sx : Int = cell_screen_x(game.selected_tx)
    let sy : Int = cell_screen_y(game.selected_ty)
    let col : @raylib.Color = if game.last_plan_ok {
      @raylib.Color::new(158, 240, 136, 255)
    } else {
      @raylib.Color::new(246, 122, 96, 255)
    }

    @raylib.draw_rectangle_lines(
      sx + 3,
      sy + 3,
      tile_size - 6,
      tile_size - 6,
      col,
    )
    @raylib.draw_rectangle_lines(
      sx + 8,
      sy + 8,
      tile_size - 16,
      tile_size - 16,
      col,
    )
  }
}

///|
fn draw_sites(game : Game) -> Unit {
  for i = 0; i < game.site_count; i = i + 1 {
    if not(game.sites[i].active) {
      continue
    }

    let x : Int = game.sites[i].x
    let y : Int = game.sites[i].y
    let cx : Int = cell_center_x(x)
    let cy : Int = cell_center_y(y)

    if game.sites[i].waiting > 0 {
      @raylib.draw_circle(cx, cy, 18.0, @raylib.Color::new(198, 228, 242, 230))
      @raylib.draw_circle_lines(
        cx,
        cy,
        18.0,
        @raylib.Color::new(42, 62, 84, 255),
      )

      let label : String = game.sites[i].waiting.to_string()
      @raylib.draw_text(
        label,
        cx - @raylib.measure_text(label, 20) / 2,
        cy - 11,
        20,
        @raylib.Color::new(20, 28, 34, 255),
      )
    } else {
      @raylib.draw_line(
        cx - 15,
        cy - 15,
        cx + 15,
        cy + 15,
        @raylib.Color::new(140, 44, 34, 220),
      )
      @raylib.draw_line(
        cx + 15,
        cy - 15,
        cx - 15,
        cy + 15,
        @raylib.Color::new(140, 44, 34, 220),
      )
    }
  }
}

///|
fn draw_route_preview(game : Game) -> Unit {
  let mut x : Int = game.truck_x
  let mut y : Int = game.truck_y

  let mut px : Int = cell_center_x(x)
  let mut py : Int = cell_center_y(y)

  for i = 0; i < game.route_len; i = i + 1 {
    let dir : Int = game.route[i]
    x = x + route_dx(dir)
    y = y + route_dy(dir)

    let nx : Int = cell_center_x(x)
    let ny : Int = cell_center_y(y)

    @raylib.draw_line(
      px,
      py,
      nx,
      ny,
      if game.route_running {
        @raylib.Color::new(255, 216, 126, 245)
      } else {
        @raylib.Color::new(146, 220, 255, 240)
      },
    )

    @raylib.draw_circle(
      nx,
      ny,
      5.0,
      if game.route_running {
        @raylib.Color::new(255, 206, 108, 230)
      } else {
        @raylib.Color::new(120, 198, 246, 230)
      },
    )

    px = nx
    py = ny
  }
}

///|
fn draw_truck(game : Game) -> Unit {
  let cx : Int = cell_center_x(game.truck_x)
  let cy : Int = cell_center_y(game.truck_y)

  @raylib.draw_rectangle(
    cx - 18,
    cy - 14,
    36,
    28,
    @raylib.Color::new(234, 236, 248, 255),
  )
  @raylib.draw_rectangle(
    cx - 12,
    cy - 20,
    24,
    9,
    @raylib.Color::new(66, 90, 112, 255),
  )
  @raylib.draw_rectangle_lines(
    cx - 18,
    cy - 14,
    36,
    28,
    @raylib.Color::new(40, 48, 60, 255),
  )

  if game.carrying > 0 {
    let txt : String = game.carrying.to_string()
    @raylib.draw_circle(
      cx + 17,
      cy - 18,
      12.0,
      @raylib.Color::new(94, 176, 228, 240),
    )
    @raylib.draw_text(
      txt,
      cx + 17 - @raylib.measure_text(txt, 18) / 2,
      cy - 26,
      18,
      @raylib.Color::new(15, 21, 28, 255),
    )
  }
}

///|
fn draw_metric_bar(
  label : String,
  value : Float,
  maxv : Float,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  fill : @raylib.Color,
  back : @raylib.Color,
  text : @raylib.Color,
) -> Unit {
  let ratio : Float = clampf(value / maxv, 0.0, 1.0)

  @raylib.draw_rectangle(x, y, w, h, back)
  @raylib.draw_rectangle(x, y, (Float::from_int(w) * ratio).to_int(), h, fill)
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(220, 220, 220, 60),
  )

  let s : String = label + " " + value.to_int().to_string() + "%"
  @raylib.draw_text(s, x + 8, y + h / 2 - 11, 22, text)
}

///|
fn draw_button(
  label : String,
  rect : (Int, Int, Int, Int),
  active : Bool,
  base : @raylib.Color,
) -> Unit {
  @raylib.draw_rectangle(
    rect.0,
    rect.1,
    rect.2,
    rect.3,
    if active {
      base
    } else {
      @raylib.Color::new(58, 60, 70, 220)
    },
  )

  @raylib.draw_rectangle_lines(
    rect.0,
    rect.1,
    rect.2,
    rect.3,
    @raylib.Color::new(220, 220, 230, 110),
  )

  @raylib.draw_text(
    label,
    rect.0 + rect.2 / 2 - @raylib.measure_text(label, 28) / 2,
    rect.1 + rect.3 / 2 - 14,
    28,
    @raylib.Color::new(248, 248, 252, 240),
  )
}

///|
fn draw_side_panel(
  game : Game,
  mouse_x : Float,
  mouse_y : Float,
  mouse_hold : Bool,
  touch_count : Int,
) -> Unit {
  @raylib.draw_rectangle(
    panel_x,
    18,
    panel_w,
    screen_h - 36,
    @raylib.Color::new(22, 28, 34, 224),
  )

  @raylib.draw_rectangle_lines(
    panel_x,
    18,
    panel_w,
    screen_h - 36,
    @raylib.Color::new(134, 166, 188, 140),
  )

  let title : String = "VOLCANO OPS // " + level_title(game.level_index)
  @raylib.draw_text(
    title,
    panel_x + 18,
    34,
    28,
    @raylib.Color::new(250, 214, 152, 240),
  )

  @raylib.draw_text(
    "Rescued " + current_goal_progress(game),
    panel_x + 18,
    76,
    30,
    @raylib.Color::new(234, 238, 246, 242),
  )

  @raylib.draw_text(
    "Carrying " +
    game.carrying.to_string() +
    "  Waiting " +
    total_waiting(game).to_string() +
    "  Lost " +
    game.lost.to_string(),
    panel_x + 18,
    114,
    23,
    @raylib.Color::new(196, 212, 226, 230),
  )

  let remain : Int = maxi(0, (game.mission_limit - game.mission_time).to_int())
  @raylib.draw_text(
    "Time " + remain.to_string() + "s",
    panel_x + 18,
    146,
    24,
    @raylib.Color::new(255, 198, 146, 236),
  )

  draw_metric_bar(
    "HEAT",
    game.heat,
    max_heat,
    panel_x + 20,
    258,
    panel_w - 40,
    34,
    @raylib.Color::new(238, 88, 56, 238),
    @raylib.Color::new(58, 22, 22, 220),
    @raylib.Color::new(255, 236, 228, 250),
  )

  draw_metric_bar(
    "FUEL",
    game.fuel,
    max_fuel,
    panel_x + 20,
    304,
    panel_w - 40,
    34,
    @raylib.Color::new(90, 188, 238, 238),
    @raylib.Color::new(20, 44, 62, 220),
    @raylib.Color::new(230, 246, 255, 248),
  )

  draw_metric_bar(
    "COOL",
    game.coolant,
    max_coolant,
    panel_x + 20,
    350,
    panel_w - 40,
    34,
    @raylib.Color::new(104, 212, 176, 238),
    @raylib.Color::new(22, 52, 44, 220),
    @raylib.Color::new(228, 255, 246, 248),
  )

  @raylib.draw_text(
    "Queue " +
    game.route_len.to_string() +
    (if game.route_running { " (moving)" } else { " (planning)" }),
    panel_x + 20,
    414,
    24,
    @raylib.Color::new(208, 224, 240, 236),
  )

  let restart = restart_button_rect()
  let restart_hot = pointer_on_rect(
    mouse_x,
    mouse_y,
    mouse_hold,
    touch_count,
    restart.0,
    restart.1,
    restart.2,
    restart.3,
  )

  draw_button(
    "RESTART",
    restart,
    restart_hot,
    @raylib.Color::new(180, 82, 74, 236),
  )

  let l = dpad_left_rect()
  let r = dpad_right_rect()
  let u = dpad_up_rect()
  let d = dpad_down_rect()

  draw_button(
    "<",
    l,
    pointer_on_rect(
      mouse_x,
      mouse_y,
      mouse_hold,
      touch_count,
      l.0,
      l.1,
      l.2,
      l.3,
    ),
    @raylib.Color::new(96, 142, 196, 240),
  )
  draw_button(
    ">",
    r,
    pointer_on_rect(
      mouse_x,
      mouse_y,
      mouse_hold,
      touch_count,
      r.0,
      r.1,
      r.2,
      r.3,
    ),
    @raylib.Color::new(96, 142, 196, 240),
  )
  draw_button(
    "^",
    u,
    pointer_on_rect(
      mouse_x,
      mouse_y,
      mouse_hold,
      touch_count,
      u.0,
      u.1,
      u.2,
      u.3,
    ),
    @raylib.Color::new(96, 142, 196, 240),
  )
  draw_button(
    "v",
    d,
    pointer_on_rect(
      mouse_x,
      mouse_y,
      mouse_hold,
      touch_count,
      d.0,
      d.1,
      d.2,
      d.3,
    ),
    @raylib.Color::new(96, 142, 196, 240),
  )

  let exec = execute_button_rect()
  let clear = clear_route_button_rect()
  let cool = coolant_button_rect()

  draw_button(
    "EXECUTE",
    exec,
    pointer_on_rect(
      mouse_x,
      mouse_y,
      mouse_hold,
      touch_count,
      exec.0,
      exec.1,
      exec.2,
      exec.3,
    ),
    @raylib.Color::new(212, 122, 56, 236),
  )
  draw_button(
    "CLEAR ROUTE",
    clear,
    pointer_on_rect(
      mouse_x,
      mouse_y,
      mouse_hold,
      touch_count,
      clear.0,
      clear.1,
      clear.2,
      clear.3,
    ),
    @raylib.Color::new(116, 138, 186, 236),
  )
  draw_button(
    "COOLANT",
    cool,
    pointer_on_rect(
      mouse_x,
      mouse_y,
      mouse_hold,
      touch_count,
      cool.0,
      cool.1,
      cool.2,
      cool.3,
    ),
    @raylib.Color::new(82, 174, 148, 236),
  )

  @raylib.draw_text(
    "Desktop: WASD/arrows add route, E/Enter execute, C spray, R restart",
    panel_x + 20,
    screen_h - 322,
    18,
    @raylib.Color::new(176, 194, 208, 220),
  )
  @raylib.draw_text(
    "Touch: tap map to auto-plan around lava, use D-pad and buttons",
    panel_x + 20,
    screen_h - 298,
    18,
    @raylib.Color::new(176, 194, 208, 220),
  )
}

///|
fn draw_play_scene(
  game : Game,
  mouse_x : Float,
  mouse_y : Float,
  mouse_hold : Bool,
  touch_count : Int,
) -> Unit {
  draw_map(game)
  draw_route_preview(game)
  draw_sites(game)
  draw_truck(game)
  draw_side_panel(game, mouse_x, mouse_y, mouse_hold, touch_count)
}

///|
fn draw_title_scene(
  game : Game,
  mouse_x : Float,
  mouse_y : Float,
  mouse_hold : Bool,
  touch_count : Int,
) -> Unit {
  draw_center_text(
    "VOLCANO RESCUE OPERATIONS",
    166,
    76,
    @raylib.Color::new(255, 222, 172, 248),
  )
  draw_center_text(
    "Plan convoy routes before lava cuts off civilian sectors",
    258,
    30,
    @raylib.Color::new(216, 226, 238, 236),
  )

  @raylib.draw_rectangle(
    screen_w / 2 - 520,
    332,
    1040,
    286,
    @raylib.Color::new(20, 26, 34, 220),
  )
  @raylib.draw_rectangle_lines(
    screen_w / 2 - 520,
    332,
    1040,
    286,
    @raylib.Color::new(154, 178, 198, 136),
  )

  @raylib.draw_text(
    "Objective",
    screen_w / 2 - 482,
    360,
    34,
    @raylib.Color::new(255, 204, 148, 244),
  )
  @raylib.draw_text(
    "Rescue enough civilians by picking them up and delivering to the shelter.",
    screen_w / 2 - 482,
    404,
    28,
    @raylib.Color::new(222, 232, 242, 236),
  )

  @raylib.draw_text(
    "Lava expands every few seconds. Tap cells to auto-plan routes around hazards.",
    screen_w / 2 - 482,
    442,
    28,
    @raylib.Color::new(222, 232, 242, 236),
  )

  @raylib.draw_text(
    "Manage heat, fuel, and coolant. Depots refill resources but can be overrun.",
    screen_w / 2 - 482,
    480,
    28,
    @raylib.Color::new(222, 232, 242, 236),
  )

  @raylib.draw_text(
    "Keyboard: WASD/Arrows plan, Enter execute, C coolant, R restart, N next mission.",
    screen_w / 2 - 482,
    526,
    24,
    @raylib.Color::new(194, 208, 224, 230),
  )

  @raylib.draw_text(
    "Touch: Tap map and on-screen controls. Gameplay is fully mobile-compatible.",
    screen_w / 2 - 482,
    556,
    24,
    @raylib.Color::new(194, 208, 224, 230),
  )

  let start = title_start_button_rect()
  let hot = pointer_on_rect(
    mouse_x,
    mouse_y,
    mouse_hold,
    touch_count,
    start.0,
    start.1,
    start.2,
    start.3,
  )

  draw_button(
    "START CAMPAIGN",
    start,
    hot,
    @raylib.Color::new(216, 122, 56, 238),
  )

  @raylib.draw_text(
    "3 missions",
    screen_w / 2 - @raylib.measure_text("3 missions", 24) / 2,
    screen_h - 72,
    24,
    @raylib.Color::new(194, 208, 224, 220),
  )

  ignore(game)
}

///|
fn draw_result_scene(
  game : Game,
  mouse_x : Float,
  mouse_y : Float,
  mouse_hold : Bool,
  touch_count : Int,
) -> Unit {
  let panel_wide : Int = 920
  let panel_x0 : Int = screen_w / 2 - panel_wide / 2

  @raylib.draw_rectangle(
    panel_x0,
    174,
    panel_wide,
    512,
    @raylib.Color::new(22, 26, 34, 236),
  )

  @raylib.draw_rectangle_lines(
    panel_x0,
    174,
    panel_wide,
    512,
    if game.result == result_win {
      @raylib.Color::new(156, 228, 168, 180)
    } else {
      @raylib.Color::new(240, 130, 102, 180)
    },
  )

  draw_center_text(
    mission_result_label(game),
    232,
    66,
    if game.result == result_win {
      @raylib.Color::new(192, 248, 204, 250)
    } else {
      @raylib.Color::new(255, 184, 164, 250)
    },
  )

  draw_center_text(
    "Level " +
    (game.level_index + 1).to_string() +
    " - " +
    level_title(game.level_index),
    314,
    30,
    @raylib.Color::new(222, 232, 244, 238),
  )

  draw_center_text(
    "Rescued " +
    game.rescued.to_string() +
    " / " +
    game.goal_rescue.to_string() +
    "   Lost " +
    game.lost.to_string(),
    358,
    34,
    @raylib.Color::new(242, 228, 198, 240),
  )

  draw_center_text(
    "Time used " +
    game.mission_time.to_int().to_string() +
    "s   Heat " +
    game.heat.to_int().to_string() +
    "%   Fuel " +
    game.fuel.to_int().to_string() +
    "%",
    404,
    28,
    @raylib.Color::new(198, 214, 228, 236),
  )

  draw_center_text(game.msg, 452, 28, @raylib.Color::new(255, 208, 150, 236))

  let rb = result_restart_button_rect()
  let nb = result_next_button_rect()

  draw_button(
    "RESTART",
    rb,
    pointer_on_rect(
      mouse_x,
      mouse_y,
      mouse_hold,
      touch_count,
      rb.0,
      rb.1,
      rb.2,
      rb.3,
    ),
    @raylib.Color::new(176, 88, 78, 236),
  )

  let can_next : Bool = game.result == result_win
  draw_button(
    if has_next_level(game) {
      "NEXT"
    } else {
      "TITLE"
    },
    nb,
    can_next &&
    pointer_on_rect(
      mouse_x,
      mouse_y,
      mouse_hold,
      touch_count,
      nb.0,
      nb.1,
      nb.2,
      nb.3,
    ),
    if can_next {
      @raylib.Color::new(98, 164, 214, 236)
    } else {
      @raylib.Color::new(86, 92, 110, 220)
    },
  )

  if not(can_next) {
    draw_center_text(
      "Next mission unlocks on success",
      612,
      24,
      @raylib.Color::new(214, 170, 160, 220),
    )
  }
}

///|
fn draw_message(game : Game) -> Unit {
  if game.msg_t <= 0.0 || game.msg == "" {
    return
  }

  let text_w : Int = @raylib.measure_text(game.msg, 26)
  let box_w : Int = text_w + 44

  @raylib.draw_rectangle(
    screen_w / 2 - box_w / 2,
    26,
    box_w,
    48,
    @raylib.Color::new(20, 26, 34, 230),
  )

  @raylib.draw_rectangle_lines(
    screen_w / 2 - box_w / 2,
    26,
    box_w,
    48,
    @raylib.Color::new(200, 214, 228, 136),
  )

  draw_center_text(game.msg, 38, 26, @raylib.Color::new(238, 244, 250, 245))
}

///|
fn draw_frame(
  game : Game,
  mouse_x : Float,
  mouse_y : Float,
  mouse_hold : Bool,
  touch_count : Int,
) -> Unit {
  draw_bg(game)

  if game.state == state_title {
    draw_title_scene(game, mouse_x, mouse_y, mouse_hold, touch_count)
  } else if game.state == state_play {
    draw_play_scene(game, mouse_x, mouse_y, mouse_hold, touch_count)
  } else {
    draw_result_scene(game, mouse_x, mouse_y, mouse_hold, touch_count)
  }

  draw_message(game)
}
