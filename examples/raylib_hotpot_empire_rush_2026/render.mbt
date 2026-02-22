///|
fn station_color(station : Int) -> @raylib.Color {
  if station == station_broth {
    @raylib.Color::new(120, 62, 48, 255)
  } else if station == station_protein {
    @raylib.Color::new(108, 44, 52, 255)
  } else if station == station_veg {
    @raylib.Color::new(44, 96, 60, 255)
  } else if station == station_spice {
    @raylib.Color::new(136, 70, 26, 255)
  } else if station == station_prep {
    @raylib.Color::new(72, 88, 102, 255)
  } else if station == station_pot {
    @raylib.Color::new(84, 56, 106, 255)
  } else if station == station_serve {
    @raylib.Color::new(34, 118, 126, 255)
  } else if station == station_rush {
    @raylib.Color::new(122, 82, 36, 255)
  } else if station == station_trash {
    @raylib.Color::new(62, 62, 62, 255)
  } else if station == station_queue {
    @raylib.Color::new(56, 72, 116, 255)
  } else if station == station_reputation {
    @raylib.Color::new(92, 54, 92, 255)
  } else {
    @raylib.Color::new(58, 70, 74, 255)
  }
}

///|
fn draw_meter(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  ratio : Float,
  bg : @raylib.Color,
  fg : @raylib.Color,
) -> Unit {
  let t = clampf(ratio, 0.0, 1.0)
  @raylib.draw_rectangle(x, y, w, h, bg)
  @raylib.draw_rectangle(x, y, (Float::from_int(w) * t).to_int(), h, fg)
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(228, 236, 244, 180),
  )
}

///|
fn broth_slot_text(v : Int) -> String {
  if v >= 0 {
    broth_name(v)
  } else {
    "--"
  }
}

///|
fn protein_slot_text(v : Int) -> String {
  if v >= 0 {
    protein_name(v)
  } else {
    "--"
  }
}

///|
fn veg_slot_text(v : Int) -> String {
  if v >= 0 {
    veg_name(v)
  } else {
    "--"
  }
}

///|
fn hand_text(game : Game) -> String {
  if game.hand.kind == ingredient_none {
    "Empty"
  } else if game.hand.kind == ingredient_protein {
    if game.hand.prepped {
      "Sliced \{protein_name(game.hand.flavor)}"
    } else {
      "Raw \{protein_name(game.hand.flavor)}"
    }
  } else if game.hand.prepped {
    "Clean \{veg_name(game.hand.flavor)}"
  } else {
    "Raw \{veg_name(game.hand.flavor)}"
  }
}

///|
fn draw_background(game : Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(14, 16, 24, 255))

  let wave = @math.sinf(game.elapsed * 0.28)
  for i = 0; i < 16; i = i + 1 {
    let y = i * (screen_h / 16)
    let tone = 20 + i * 5
    @raylib.draw_rectangle(
      0,
      y,
      screen_w,
      screen_h / 16 + 2,
      @raylib.Color::new(tone, 18 + i * 4, 30 + i * 3, 255),
    )
  }

  @raylib.draw_circle(
    190,
    140,
    170.0 + wave * 20.0,
    @raylib.Color::new(156, 64, 44, 48),
  )
  @raylib.draw_circle(
    screen_w - 240,
    170,
    200.0 - wave * 16.0,
    @raylib.Color::new(82, 120, 180, 46),
  )
  @raylib.draw_circle(
    640,
    screen_h - 110,
    180.0 + wave * 11.0,
    @raylib.Color::new(180, 132, 48, 40),
  )

  if game.flash_t > 0.0 {
    let alpha = clampi((game.flash_t * 140.0).to_int(), 0, 140)
    @raylib.draw_rectangle(
      0,
      0,
      screen_w,
      screen_h,
      @raylib.Color::new(236, 62, 52, alpha),
    )
  }
}

///|
fn draw_station_info(game : Game, station : Int, x : Int, y : Int) -> Unit {
  let text_color = @raylib.Color::new(238, 244, 252, 246)

  if station == station_broth {
    @raylib.draw_text(
      "Current: \{broth_slot_text(game.pot.broth)}",
      x + 14,
      y + 64,
      24,
      text_color,
    )
    @raylib.draw_text("J: cycle broth", x + 14, y + 96, 20, text_color)
  } else if station == station_protein {
    @raylib.draw_text(
      "Next raw: \{protein_name(game.next_protein_pick)}",
      x + 14,
      y + 64,
      24,
      text_color,
    )
    @raylib.draw_text("J: pick protein", x + 14, y + 96, 20, text_color)
  } else if station == station_veg {
    @raylib.draw_text(
      "Next raw: \{veg_name(game.next_veg_pick)}",
      x + 14,
      y + 64,
      24,
      text_color,
    )
    @raylib.draw_text("J: pick veg", x + 14, y + 96, 20, text_color)
  } else if station == station_spice {
    @raylib.draw_text(
      "Pot spice: \{spice_name(game.pot.spice)}",
      x + 14,
      y + 64,
      24,
      text_color,
    )
    @raylib.draw_text("J: cycle spice", x + 14, y + 96, 20, text_color)
  } else if station == station_prep {
    if game.prep.active {
      let ratio = game.prep.progress / maxf(game.prep.target, 0.01)
      draw_meter(
        x + 14,
        y + 70,
        station_tile_w - 28,
        22,
        ratio,
        @raylib.Color::new(28, 40, 54, 220),
        @raylib.Color::new(120, 222, 208, 236),
      )
      @raylib.draw_text("J: check progress", x + 14, y + 104, 20, text_color)
      @raylib.draw_text("K: cancel prep", x + 14, y + 130, 20, text_color)
    } else if game.prep.output_ready {
      let ready_label = if game.prep.out_kind == ingredient_protein {
        "Sliced \{protein_name(game.prep.out_flavor)}"
      } else {
        "Clean \{veg_name(game.prep.out_flavor)}"
      }
      @raylib.draw_text("Ready: \{ready_label}", x + 14, y + 64, 24, text_color)
      @raylib.draw_text("J: collect item", x + 14, y + 96, 20, text_color)
      @raylib.draw_text("K: clear station", x + 14, y + 122, 20, text_color)
    } else {
      @raylib.draw_text(
        "Bring raw protein or veg",
        x + 14,
        y + 64,
        24,
        text_color,
      )
      @raylib.draw_text("J: start prep", x + 14, y + 96, 20, text_color)
    }
  } else if station == station_pot {
    @raylib.draw_text(
      "Broth: \{broth_slot_text(game.pot.broth)}",
      x + 14,
      y + 54,
      21,
      text_color,
    )
    @raylib.draw_text(
      "Protein: \{protein_slot_text(game.pot.protein)}",
      x + 14,
      y + 79,
      21,
      text_color,
    )
    @raylib.draw_text(
      "Veg: \{veg_slot_text(game.pot.veg)}",
      x + 14,
      y + 104,
      21,
      text_color,
    )
    @raylib.draw_text(
      "Spice: \{spice_name(game.pot.spice)}",
      x + 14,
      y + 129,
      21,
      text_color,
    )

    if game.pot.cooking || game.pot.ready {
      draw_meter(
        x + 130,
        y + 140,
        station_tile_w - 144,
        18,
        game.pot.progress / maxf(game.pot.target, 0.01),
        @raylib.Color::new(44, 30, 58, 220),
        @raylib.Color::new(236, 146, 82, 236),
      )
    }

    let action_label = if game.pot.ready {
      "Ready: serve with K"
    } else if game.pot.cooking {
      "Simmering"
    } else {
      "J: add or start cook"
    }
    @raylib.draw_text(action_label, x + 14, y + 152, 19, text_color)
  } else if station == station_serve {
    if game.orders[0].active {
      @raylib.draw_text(
        "Head #\{game.orders[0].id}",
        x + 14,
        y + 54,
        24,
        text_color,
      )
      @raylib.draw_text(
        "\{broth_name(game.orders[0].broth)} / \{protein_name(game.orders[0].protein)}",
        x + 14,
        y + 84,
        20,
        text_color,
      )
      @raylib.draw_text(
        "\{veg_name(game.orders[0].veg)} / \{spice_name(game.orders[0].spice)}",
        x + 14,
        y + 108,
        20,
        text_color,
      )
      draw_meter(
        x + 14,
        y + 136,
        station_tile_w - 28,
        18,
        game.orders[0].patience / maxf(game.orders[0].max_patience, 0.01),
        @raylib.Color::new(24, 52, 58, 220),
        @raylib.Color::new(132, 234, 208, 236),
      )
      @raylib.draw_text("K: serve head order", x + 14, y + 156, 18, text_color)
    } else {
      @raylib.draw_text("No queue head", x + 14, y + 70, 26, text_color)
      @raylib.draw_text("K: serve (penalty)", x + 14, y + 106, 20, text_color)
    }
  } else if station == station_rush {
    @raylib.draw_text("Boost meter +24", x + 14, y + 64, 24, text_color)
    if game.rush_cd > 0.0 {
      @raylib.draw_text(
        "Cooldown: \{game.rush_cd.to_int() + 1}s",
        x + 14,
        y + 96,
        22,
        text_color,
      )
    } else {
      @raylib.draw_text("J: ring bell", x + 14, y + 96, 22, text_color)
    }
  } else if station == station_trash {
    @raylib.draw_text("Dump held ingredient", x + 14, y + 66, 24, text_color)
    @raylib.draw_text("J: throw away", x + 14, y + 98, 22, text_color)
  } else if station == station_queue {
    @raylib.draw_text("Review queue head", x + 14, y + 66, 24, text_color)
    @raylib.draw_text("J: repeat demand", x + 14, y + 98, 22, text_color)
  } else if station == station_reputation {
    @raylib.draw_text("Reputation is your HP", x + 14, y + 66, 24, text_color)
    @raylib.draw_text("Drops to 0 => game over", x + 14, y + 98, 22, text_color)
  } else {
    @raylib.draw_text("Shuffle next pickup", x + 14, y + 66, 24, text_color)
    @raylib.draw_text("J: randomize crates", x + 14, y + 98, 22, text_color)
  }
}

///|
fn draw_kitchen(game : Game) -> Unit {
  @raylib.draw_rectangle(
    kitchen_left - 16,
    kitchen_top - 56,
    kitchen_w() + 32,
    kitchen_h() + 68,
    @raylib.Color::new(12, 20, 30, 206),
  )
  @raylib.draw_rectangle_lines(
    kitchen_left - 16,
    kitchen_top - 56,
    kitchen_w() + 32,
    kitchen_h() + 68,
    @raylib.Color::new(178, 202, 228, 180),
  )

  @raylib.draw_text(
    "Hotpot Kitchen Grid",
    kitchen_left,
    kitchen_top - 44,
    34,
    @raylib.Color::new(234, 240, 250, 246),
  )

  for y = 0; y < station_rows; y = y + 1 {
    for x = 0; x < station_cols; x = x + 1 {
      let sx = station_x(x)
      let sy = station_y(y)
      let station = station_at(x, y)

      let base = station_color(station)
      @raylib.draw_rectangle(sx, sy, station_tile_w, station_tile_h, base)
      @raylib.draw_rectangle_lines(
        sx,
        sy,
        station_tile_w,
        station_tile_h,
        @raylib.Color::new(236, 242, 250, 214),
      )

      @raylib.draw_text(
        station_name(station),
        sx + 12,
        sy + 12,
        28,
        @raylib.Color::new(248, 250, 255, 248),
      )

      draw_station_info(game, station, sx, sy)

      if x == game.cursor_x && y == game.cursor_y {
        let pulse : Float = 0.54 + 0.46 * @math.sinf(game.elapsed * 8.0)
        let alpha = clampi((pulse * 230.0).to_int(), 80, 240)

        @raylib.draw_rectangle_lines_ex(
          @raylib.Rectangle::new(
            Float::from_int(sx + 2),
            Float::from_int(sy + 2),
            Float::from_int(station_tile_w - 4),
            Float::from_int(station_tile_h - 4),
          ),
          4.0,
          @raylib.Color::new(255, 240, 164, alpha),
        )
      }
    }
  }
}

///|
fn draw_order_card(
  game : Game,
  i : Int,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> Unit {
  if not(game.orders[i].active) {
    @raylib.draw_rectangle(x, y, w, h, @raylib.Color::new(28, 34, 48, 192))
    @raylib.draw_rectangle_lines(
      x,
      y,
      w,
      h,
      @raylib.Color::new(102, 120, 156, 156),
    )
    @raylib.draw_text(
      "Waiting slot",
      x + 18,
      y + h / 2 - 12,
      24,
      @raylib.Color::new(166, 180, 212, 182),
    )
    return
  }

  let is_head = i == 0
  @raylib.draw_rectangle(
    x,
    y,
    w,
    h,
    if is_head {
      @raylib.Color::new(54, 90, 126, 228)
    } else {
      @raylib.Color::new(40, 58, 86, 216)
    },
  )
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    if is_head {
      @raylib.Color::new(242, 246, 252, 240)
    } else {
      @raylib.Color::new(168, 190, 218, 206)
    },
  )

  @raylib.draw_text(
    if is_head {
      "HEAD #\{game.orders[i].id}"
    } else {
      "#\{game.orders[i].id}"
    },
    x + 14,
    y + 12,
    24,
    @raylib.Color::new(246, 250, 255, 246),
  )

  @raylib.draw_text(
    "\{broth_name(game.orders[i].broth)} / \{protein_name(game.orders[i].protein)}",
    x + 14,
    y + 38,
    20,
    @raylib.Color::new(230, 242, 255, 240),
  )
  @raylib.draw_text(
    "\{veg_name(game.orders[i].veg)} / \{spice_name(game.orders[i].spice)}",
    x + 14,
    y + 60,
    20,
    @raylib.Color::new(230, 242, 255, 240),
  )

  draw_meter(
    x + 14,
    y + h - 26,
    w - 28,
    14,
    game.orders[i].patience / maxf(game.orders[i].max_patience, 0.01),
    @raylib.Color::new(26, 32, 40, 220),
    if is_head {
      @raylib.Color::new(255, 196, 110, 240)
    } else {
      @raylib.Color::new(156, 220, 166, 236)
    },
  )
}

///|
fn draw_side_panel(game : Game) -> Unit {
  let x = panel_x()
  let w = panel_w()

  @raylib.draw_rectangle(
    x,
    24,
    w,
    screen_h - 48,
    @raylib.Color::new(10, 16, 26, 218),
  )
  @raylib.draw_rectangle_lines(
    x,
    24,
    w,
    screen_h - 48,
    @raylib.Color::new(154, 180, 216, 204),
  )

  @raylib.draw_text(
    "HOTPOT EMPIRE RUSH 2026",
    x + 18,
    44,
    34,
    @raylib.Color::new(244, 248, 255, 248),
  )

  @raylib.draw_text(
    "Score \{game.score}",
    x + 18,
    88,
    30,
    @raylib.Color::new(246, 228, 138, 246),
  )
  @raylib.draw_text(
    "Best \{game.best_score}",
    x + 18,
    122,
    28,
    @raylib.Color::new(214, 226, 244, 236),
  )

  @raylib.draw_text(
    "Served \{game.served}   Failed \{game.failed}",
    x + 18,
    158,
    26,
    @raylib.Color::new(216, 232, 248, 236),
  )

  @raylib.draw_text(
    if game.combo > 1 {
      "Combo x\{game.combo}"
    } else {
      "Combo x1"
    },
    x + 18,
    190,
    30,
    @raylib.Color::new(254, 220, 142, 240),
  )

  draw_meter(
    x + 18,
    234,
    w - 36,
    18,
    game.reputation / reputation_max,
    @raylib.Color::new(38, 26, 32, 220),
    @raylib.Color::new(246, 106, 120, 242),
  )
  @raylib.draw_text(
    "Reputation \{game.reputation.to_int()} / \{reputation_max.to_int()}",
    x + 18,
    258,
    22,
    @raylib.Color::new(236, 240, 248, 234),
  )

  draw_meter(
    x + 18,
    292,
    w - 36,
    18,
    game.boost_meter / boost_meter_max,
    @raylib.Color::new(22, 30, 46, 220),
    if game.boost_t > 0.0 {
      @raylib.Color::new(110, 228, 255, 244)
    } else {
      @raylib.Color::new(98, 170, 255, 234)
    },
  )
  @raylib.draw_text(
    if game.boost_t > 0.0 {
      "Boost ON \{game.boost_t.to_int() + 1}s"
    } else {
      "Boost meter \{game.boost_meter.to_int()}"
    },
    x + 18,
    316,
    22,
    @raylib.Color::new(232, 244, 255, 236),
  )

  @raylib.draw_text(
    "Hand: \{hand_text(game)}",
    x + 18,
    352,
    24,
    @raylib.Color::new(246, 248, 252, 244),
  )

  @raylib.draw_text(
    "Customer Queue",
    x + 18,
    390,
    30,
    @raylib.Color::new(238, 246, 255, 244),
  )

  for i = 0; i < max_orders; i = i + 1 {
    draw_order_card(game, i, x + 18, 430 + i * 80, w - 36, 72)
  }
}

///|
fn draw_controls_bar(game : Game) -> Unit {
  @raylib.draw_rectangle(
    kitchen_left,
    screen_h - 94,
    kitchen_w(),
    66,
    @raylib.Color::new(8, 14, 24, 208),
  )
  @raylib.draw_rectangle_lines(
    kitchen_left,
    screen_h - 94,
    kitchen_w(),
    66,
    @raylib.Color::new(130, 162, 198, 188),
  )

  @raylib.draw_text(
    "Move: WASD/Arrows | J interact/cook | K serve/cancel | Space boost | P pause | R restart",
    kitchen_left + 14,
    screen_h - 74,
    24,
    @raylib.Color::new(236, 244, 255, 236),
  )

  if game.msg_t > 0.0 {
    @raylib.draw_text(
      game.msg,
      kitchen_left + 14,
      screen_h - 104,
      24,
      @raylib.Color::new(255, 224, 154, 246),
    )
  }
}

///|
fn draw_title_overlay(_game : Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(8, 10, 16, 166),
  )

  let box_w = 860
  let box_h = 460
  let x = screen_w / 2 - box_w / 2
  let y = screen_h / 2 - box_h / 2

  @raylib.draw_rectangle(
    x,
    y,
    box_w,
    box_h,
    @raylib.Color::new(16, 24, 36, 242),
  )
  @raylib.draw_rectangle_lines(
    x,
    y,
    box_w,
    box_h,
    @raylib.Color::new(192, 214, 242, 220),
  )

  @raylib.draw_text(
    "HOTPOT EMPIRE RUSH 2026",
    x + 48,
    y + 48,
    56,
    @raylib.Color::new(250, 242, 214, 248),
  )
  @raylib.draw_text(
    "Queue management kitchen game",
    x + 48,
    y + 118,
    34,
    @raylib.Color::new(220, 236, 252, 236),
  )

  @raylib.draw_text(
    "1. Build the queue head order using broth, prepped protein, veg, and spice.",
    x + 48,
    y + 182,
    28,
    @raylib.Color::new(232, 242, 255, 238),
  )
  @raylib.draw_text(
    "2. J interacts and cooks. K serves or cancels. Space triggers speed boost.",
    x + 48,
    y + 220,
    28,
    @raylib.Color::new(232, 242, 255, 238),
  )
  @raylib.draw_text(
    "3. Missed/wrong orders drain reputation. Hit zero reputation to lose.",
    x + 48,
    y + 258,
    28,
    @raylib.Color::new(232, 242, 255, 238),
  )

  @raylib.draw_text(
    "Press J or Enter to start shift",
    x + 48,
    y + 336,
    38,
    @raylib.Color::new(255, 224, 142, 246),
  )
  @raylib.draw_text(
    "Press R anytime to restart",
    x + 48,
    y + 382,
    30,
    @raylib.Color::new(212, 228, 246, 236),
  )
}

///|
fn draw_pause_overlay() -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(6, 8, 12, 170),
  )

  let w = 620
  let h = 240
  let x = screen_w / 2 - w / 2
  let y = screen_h / 2 - h / 2

  @raylib.draw_rectangle(x, y, w, h, @raylib.Color::new(20, 26, 40, 240))
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(198, 214, 238, 224),
  )

  @raylib.draw_text(
    "PAUSED",
    x + w / 2 - @raylib.measure_text("PAUSED", 62) / 2,
    y + 42,
    62,
    @raylib.Color::new(246, 234, 178, 246),
  )
  @raylib.draw_text(
    "Press P or J to resume",
    x + w / 2 - @raylib.measure_text("Press P or J to resume", 32) / 2,
    y + 126,
    32,
    @raylib.Color::new(226, 238, 252, 236),
  )
}

///|
fn draw_game_over_overlay(game : Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    screen_w,
    screen_h,
    @raylib.Color::new(10, 4, 6, 186),
  )

  let w = 700
  let h = 330
  let x = screen_w / 2 - w / 2
  let y = screen_h / 2 - h / 2

  @raylib.draw_rectangle(x, y, w, h, @raylib.Color::new(36, 16, 20, 246))
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(246, 182, 182, 226),
  )

  @raylib.draw_text(
    "SHIFT FAILED",
    x + w / 2 - @raylib.measure_text("SHIFT FAILED", 64) / 2,
    y + 36,
    64,
    @raylib.Color::new(255, 218, 196, 248),
  )

  @raylib.draw_text(
    "Score \{game.score}   Best \{game.best_score}",
    x + 80,
    y + 138,
    40,
    @raylib.Color::new(248, 234, 204, 246),
  )
  @raylib.draw_text(
    "Served \{game.served}   Failed \{game.failed}",
    x + 80,
    y + 186,
    34,
    @raylib.Color::new(236, 228, 216, 236),
  )

  @raylib.draw_text(
    "Press R to restart or J to title",
    x + 80,
    y + 248,
    30,
    @raylib.Color::new(242, 236, 232, 236),
  )
}

///|
fn draw_frame(game : Game) -> Unit {
  draw_background(game)
  draw_kitchen(game)
  draw_side_panel(game)
  draw_controls_bar(game)

  if game.state == state_title {
    draw_title_overlay(game)
  } else if game.state == state_paused {
    draw_pause_overlay()
  } else if game.state == state_game_over {
    draw_game_over_overlay(game)
  }
}
