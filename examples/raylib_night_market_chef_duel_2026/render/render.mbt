///|
fn draw_center_text(
  text : String,
  y : Int,
  size : Int,
  color : @raylib.Color,
) -> Unit {
  let tw = @raylib.measure_text(text, size)
  @raylib.draw_text(text, @types.screen_w / 2 - tw / 2, y, size, color)
}

///|
fn dish_color(dish : @types.Dish) -> @raylib.Color {
  match dish {
    @types.Skewers => @raylib.Color::new(243, 139, 78, 255)
    @types.Noodles => @raylib.Color::new(247, 208, 82, 255)
    @types.Squid => @raylib.Color::new(232, 104, 115, 255)
    @types.FriedRice => @raylib.Color::new(115, 205, 124, 255)
    @types.DishNone => @raylib.Color::new(210, 210, 210, 255)
  }
}

///|
fn patience_color(ratio : Float) -> @raylib.Color {
  if ratio >= 0.65 {
    @raylib.Color::new(116, 226, 142, 255)
  } else if ratio >= 0.35 {
    @raylib.Color::new(244, 207, 97, 255)
  } else {
    @raylib.Color::new(237, 103, 103, 255)
  }
}

///|
fn progress_bar(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  ratio : Float,
  base : @raylib.Color,
  fill : @raylib.Color,
) -> Unit {
  @raylib.draw_rectangle(x, y, w, h, base)
  let rw = (Float::from_int(w) * @types.clampf(ratio, 0.0, 1.0)).to_int()
  @raylib.draw_rectangle(x + 2, y + 2, @types.maxi(0, rw - 4), h - 4, fill)
  @raylib.draw_rectangle_lines(x, y, w, h, @raylib.Color::new(26, 28, 32, 240))
}

///|
fn draw_background(game : @types.Game) -> Unit {
  @raylib.draw_rectangle_gradient_v(
    0,
    0,
    @types.screen_w,
    @types.screen_h,
    @raylib.Color::new(18, 22, 40, 255),
    @raylib.Color::new(42, 24, 26, 255),
  )

  for i in 0..<14 {
    let fi = Float::from_int(i)
    let x : Float = 90.0 +
      fi * 88.0 +
      @types.sinf(game.elapsed_t * 0.6 + fi * 0.9) * 18.0
    let y : Float = 62.0 + @types.cosf(game.elapsed_t * 0.9 + fi * 0.6) * 6.0

    @raylib.draw_circle(
      x.to_int(),
      y.to_int(),
      20.0,
      @raylib.Color::new(238, 102 + i * 5, 84, 90),
    )
    @raylib.draw_circle(
      x.to_int(),
      (y + 1.0).to_int(),
      12.0,
      @raylib.Color::new(255, 196, 124, 130),
    )
  }

  @raylib.draw_rectangle(
    20,
    @types.hud_h + 20,
    350,
    520,
    @raylib.Color::new(33, 40, 58, 184),
  )
  @raylib.draw_rectangle(
    380,
    @types.hud_h + 20,
    500,
    520,
    @raylib.Color::new(52, 35, 37, 165),
  )
  @raylib.draw_rectangle(
    900,
    @types.hud_h + 20,
    360,
    520,
    @raylib.Color::new(31, 47, 40, 164),
  )

  if game.flash_t > 0.0 {
    let alpha = @types.clampi((game.flash_t * 180.0).to_int(), 0, 180)
    @raylib.draw_rectangle(
      0,
      0,
      @types.screen_w,
      @types.screen_h,
      @raylib.Color::new(255, 240, 210, alpha),
    )
  }
}

///|
fn draw_order_slot(game : @types.Game, slot : Int) -> Unit {
  let x = @types.orders_x - 122.0
  let y = @types.order_node_y(slot) - 28.0
  let w = 248
  let h = 58

  let active = game.orders[slot].active
  let selected = active && game.selected_order == slot
  let cursor_on = game.cursor == slot

  let bg = if selected {
    @raylib.Color::new(74, 70, 106, 240)
  } else if active {
    @raylib.Color::new(58, 62, 80, 220)
  } else {
    @raylib.Color::new(43, 44, 56, 200)
  }

  @raylib.draw_rectangle(x.to_int(), y.to_int(), w, h, bg)

  let border = if cursor_on {
    @raylib.Color::new(255, 226, 132, 255)
  } else if selected {
    @raylib.Color::new(140, 214, 255, 230)
  } else {
    @raylib.Color::new(122, 126, 148, 190)
  }
  @raylib.draw_rectangle_lines(x.to_int(), y.to_int(), w, h, border)

  if active {
    @raylib.draw_circle(
      (x + 22.0).to_int(),
      (y + 29.0).to_int(),
      10.0,
      dish_color(game.orders[slot].dish),
    )

    @raylib.draw_text(
      "#" +
      game.orders[slot].ticket_no.to_string() +
      " " +
      @types.dish_name(game.orders[slot].dish),
      (x + 40.0).to_int(),
      (y + 8.0).to_int(),
      20,
      @raylib.Color::new(236, 240, 244, 240),
    )

    let ratio : Float = if game.orders[slot].patience_max <= 0.01 {
      0.0
    } else {
      game.orders[slot].patience / game.orders[slot].patience_max
    }
    progress_bar(
      (x + 40.0).to_int(),
      (y + 34.0).to_int(),
      182,
      16,
      ratio,
      @raylib.Color::new(24, 25, 34, 220),
      patience_color(ratio),
    )
  } else {
    @raylib.draw_text(
      "No order",
      (x + 18.0).to_int(),
      (y + 18.0).to_int(),
      22,
      @raylib.Color::new(126, 129, 144, 190),
    )
  }
}

///|
fn draw_orders_panel(game : @types.Game) -> Unit {
  @raylib.draw_text(
    "QUEUE",
    72,
    @types.hud_h + 24,
    30,
    @raylib.Color::new(246, 233, 181, 245),
  )

  for i in 0..<@types.max_orders {
    draw_order_slot(game, i)
  }
}

///|
fn draw_station_base(
  label : String,
  x : Float,
  y : Float,
  w : Int,
  h : Int,
  fill : @raylib.Color,
  border : @raylib.Color,
) -> Unit {
  let rx = (x - Float::from_int(w) * 0.5).to_int()
  let ry = (y - Float::from_int(h) * 0.5).to_int()

  @raylib.draw_rectangle(rx, ry, w, h, fill)
  @raylib.draw_rectangle_lines(rx, ry, w, h, border)

  let tw = @raylib.measure_text(label, 24)
  @raylib.draw_text(
    label,
    rx + w / 2 - tw / 2,
    ry - 28,
    24,
    @raylib.Color::new(236, 240, 247, 235),
  )
}

///|
fn draw_prep_station(game : @types.Game) -> Unit {
  let hot = game.cursor == @types.node_prep
  let working = game.cooking.active && game.cooking.stage == @types.Prep

  draw_station_base(
    "Prep",
    @types.prep_x,
    @types.prep_y,
    230,
    116,
    if working {
      @raylib.Color::new(73, 99, 129, 232)
    } else {
      @raylib.Color::new(61, 72, 93, 220)
    },
    if hot {
      @raylib.Color::new(255, 226, 132, 255)
    } else {
      @raylib.Color::new(188, 198, 214, 180)
    },
  )

  @raylib.draw_rectangle(
    (@types.prep_x - 74.0).to_int(),
    (@types.prep_y - 18.0).to_int(),
    148,
    36,
    @raylib.Color::new(38, 50, 69, 220),
  )

  if working {
    let need = @types.dish_prep_need(game.cooking.dish)
    let ratio : Float = if need <= 0.01 {
      0.0
    } else {
      game.cooking.prep_progress / need
    }

    @raylib.draw_text(
      "Cut " + @types.dish_name(game.cooking.dish),
      (@types.prep_x - 88.0).to_int(),
      (@types.prep_y - 52.0).to_int(),
      20,
      @raylib.Color::new(244, 248, 252, 235),
    )

    progress_bar(
      (@types.prep_x - 96.0).to_int(),
      (@types.prep_y + 24.0).to_int(),
      192,
      16,
      ratio,
      @raylib.Color::new(18, 26, 37, 230),
      @raylib.Color::new(116, 210, 255, 240),
    )
  } else {
    @raylib.draw_text(
      "Press J to start prep",
      (@types.prep_x - 98.0).to_int(),
      (@types.prep_y + 26.0).to_int(),
      18,
      @raylib.Color::new(212, 219, 232, 210),
    )
  }
}

///|
fn draw_grill_station(game : @types.Game) -> Unit {
  let hot = game.cursor == @types.node_grill
  let working = game.cooking.active &&
    game.cooking.stage == @types.Heat &&
    game.cooking.lane == @types.Grill

  draw_station_base(
    "Grill",
    @types.grill_x,
    @types.grill_y,
    220,
    132,
    if working {
      @raylib.Color::new(130, 73, 53, 234)
    } else {
      @raylib.Color::new(97, 59, 48, 220)
    },
    if hot {
      @raylib.Color::new(255, 226, 132, 255)
    } else {
      @raylib.Color::new(212, 172, 156, 190)
    },
  )

  for i in 0..<5 {
    let fi = Float::from_int(i)
    let pulse : Float = 0.5 + 0.5 * @types.sinf(game.elapsed_t * 6.0 + fi)
    let flame_h : Float = 14.0 + pulse * 8.0
    @raylib.draw_rectangle(
      (@types.grill_x - 78.0 + fi * 34.0).to_int(),
      (@types.grill_y + 18.0 - pulse * 10.0).to_int(),
      20,
      flame_h.to_int(),
      @raylib.Color::new(255, 124 + (pulse * 80.0).to_int(), 64, 210),
    )
  }

  if working {
    let need = @types.dish_cook_need(game.cooking.dish)
    let ratio : Float = if need <= 0.01 {
      0.0
    } else {
      game.cooking.cook_progress / need
    }
    progress_bar(
      (@types.grill_x - 96.0).to_int(),
      (@types.grill_y + 40.0).to_int(),
      192,
      16,
      ratio,
      @raylib.Color::new(34, 22, 17, 230),
      @raylib.Color::new(255, 147, 91, 240),
    )
  }
}

///|
fn draw_wok_station(game : @types.Game) -> Unit {
  let hot = game.cursor == @types.node_wok
  let working = game.cooking.active &&
    game.cooking.stage == @types.Heat &&
    game.cooking.lane == @types.Wok

  draw_station_base(
    "Wok",
    @types.wok_x,
    @types.wok_y,
    220,
    132,
    if working {
      @raylib.Color::new(60, 104, 81, 232)
    } else {
      @raylib.Color::new(44, 85, 66, 220)
    },
    if hot {
      @raylib.Color::new(255, 226, 132, 255)
    } else {
      @raylib.Color::new(168, 220, 187, 180)
    },
  )

  @raylib.draw_circle(
    @types.wok_x.to_int(),
    (@types.wok_y + 4.0).to_int(),
    42.0,
    @raylib.Color::new(38, 46, 55, 230),
  )
  @raylib.draw_circle_lines(
    @types.wok_x.to_int(),
    (@types.wok_y + 4.0).to_int(),
    42.0,
    @raylib.Color::new(212, 228, 233, 140),
  )

  if working {
    let need = @types.dish_cook_need(game.cooking.dish)
    let ratio : Float = if need <= 0.01 {
      0.0
    } else {
      game.cooking.cook_progress / need
    }
    progress_bar(
      (@types.wok_x - 96.0).to_int(),
      (@types.wok_y + 40.0).to_int(),
      192,
      16,
      ratio,
      @raylib.Color::new(16, 34, 28, 230),
      @raylib.Color::new(130, 241, 160, 240),
    )
  }
}

///|
fn draw_pass_station(game : @types.Game) -> Unit {
  let hot = game.cursor == @types.node_pass

  draw_station_base(
    "Serve Pass",
    @types.pass_x,
    @types.pass_y,
    236,
    140,
    if game.ready_dish != @types.DishNone {
      @raylib.Color::new(86, 84, 58, 232)
    } else {
      @raylib.Color::new(63, 61, 48, 220)
    },
    if hot {
      @raylib.Color::new(255, 226, 132, 255)
    } else {
      @raylib.Color::new(214, 208, 170, 180)
    },
  )

  if game.ready_dish != @types.DishNone {
    @raylib.draw_circle(
      (@types.pass_x - 78.0).to_int(),
      (@types.pass_y + 8.0).to_int(),
      18.0,
      dish_color(game.ready_dish),
    )

    @raylib.draw_text(
      @types.dish_name(game.ready_dish),
      (@types.pass_x - 50.0).to_int(),
      (@types.pass_y - 6.0).to_int(),
      24,
      @raylib.Color::new(244, 236, 218, 240),
    )

    progress_bar(
      (@types.pass_x - 96.0).to_int(),
      (@types.pass_y + 40.0).to_int(),
      192,
      16,
      @types.clampf((game.ready_quality - 0.55) / 0.6, 0.0, 1.0),
      @raylib.Color::new(35, 33, 24, 230),
      @raylib.Color::new(246, 214, 103, 240),
    )
  } else {
    @raylib.draw_text(
      "Press K to serve",
      (@types.pass_x - 90.0).to_int(),
      (@types.pass_y + 28.0).to_int(),
      20,
      @raylib.Color::new(218, 210, 190, 210),
    )
  }
}

///|
fn draw_cursor(game : @types.Game) -> Unit {
  let p = @types.node_pos(game.cursor)
  let r : Float = 28.0 + 6.0 * (0.5 + 0.5 * @types.sinf(game.elapsed_t * 8.0))

  @raylib.draw_circle_lines(
    p.0.to_int(),
    p.1.to_int(),
    r,
    @raylib.Color::new(255, 234, 164, 245),
  )
  @raylib.draw_circle(
    p.0.to_int(),
    p.1.to_int(),
    3.0,
    @raylib.Color::new(255, 241, 191, 255),
  )
}

///|
fn selected_order_line(game : @types.Game) -> String {
  if game.selected_order >= 0 &&
    game.selected_order < @types.max_orders &&
    game.orders[game.selected_order].active {
    "Target: #" +
    game.orders[game.selected_order].ticket_no.to_string() +
    " " +
    @types.dish_name(game.orders[game.selected_order].dish)
  } else {
    "Target: none"
  }
}

///|
fn draw_hud(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_w,
    @types.hud_h,
    @raylib.Color::new(18, 20, 30, 228),
  )
  @raylib.draw_rectangle_lines(
    0,
    0,
    @types.screen_w,
    @types.hud_h,
    @raylib.Color::new(80, 96, 124, 160),
  )

  @raylib.draw_text(
    "SCORE " + game.score.to_string(),
    24,
    18,
    30,
    @raylib.Color::new(242, 244, 248, 246),
  )
  @raylib.draw_text(
    "BEST " + game.best_score.to_string(),
    24,
    54,
    24,
    @raylib.Color::new(165, 210, 255, 236),
  )

  @raylib.draw_text(
    "COMBO x" + game.combo.to_string(),
    334,
    18,
    30,
    if game.combo > 0 {
      @raylib.Color::new(255, 220, 128, 246)
    } else {
      @raylib.Color::new(198, 201, 214, 222)
    },
  )

  @raylib.draw_text(
    "SERVED " +
    game.served_orders.to_string() +
    "   FAIL " +
    game.failed_orders.to_string() +
    "/" +
    @types.fail_limit.to_string(),
    334,
    54,
    24,
    @raylib.Color::new(224, 230, 238, 230),
  )

  @raylib.draw_text(
    selected_order_line(game),
    24,
    86,
    20,
    @raylib.Color::new(201, 210, 224, 220),
  )

  let boost_ratio = if game.boost_t > 0.0 {
    game.boost_t / @types.boost_time
  } else if game.boost_cd > 0.0 {
    1.0 - game.boost_cd / @types.boost_cooldown
  } else {
    1.0
  }

  @raylib.draw_text(
    if game.boost_t > 0.0 {
      "BOOST ACTIVE"
    } else if game.boost_cd > 0.0 {
      "BOOST CHARGING"
    } else {
      "BOOST READY"
    },
    900,
    18,
    24,
    @raylib.Color::new(223, 236, 252, 238),
  )

  progress_bar(
    900,
    52,
    336,
    24,
    boost_ratio,
    @raylib.Color::new(27, 31, 40, 224),
    if game.boost_t > 0.0 {
      @raylib.Color::new(121, 214, 255, 244)
    } else if game.boost_cd > 0.0 {
      @raylib.Color::new(150, 161, 189, 228)
    } else {
      @raylib.Color::new(131, 241, 170, 238)
    },
  )

  if game.cooking.active {
    let stage = match game.cooking.stage {
      @types.Prep => "PREP"
      @types.Heat =>
        match game.cooking.lane {
          @types.Grill => "GRILL"
          @types.Wok => "WOK"
        }
    }
    @raylib.draw_text(
      "Cooking: " + @types.dish_name(game.cooking.dish) + " @ " + stage,
      558,
      86,
      20,
      @raylib.Color::new(255, 232, 176, 236),
    )
  } else if game.ready_dish != @types.DishNone {
    @raylib.draw_text(
      "Dish Ready: " + @types.dish_name(game.ready_dish) + " (Serve at pass)",
      558,
      86,
      20,
      @raylib.Color::new(181, 240, 156, 236),
    )
  } else {
    @raylib.draw_text(
      "Cursor: " + @types.node_name(game.cursor),
      558,
      86,
      20,
      @raylib.Color::new(196, 206, 220, 220),
    )
  }
}

///|
fn draw_hint_line() -> Unit {
  @raylib.draw_rectangle(
    0,
    @types.screen_h - 34,
    @types.screen_w,
    34,
    @raylib.Color::new(14, 14, 18, 224),
  )
  @raylib.draw_text(
    "Arrows/WASD move cursor | J cook/select | K serve/cancel | Space dash boost | P pause | R restart",
    18,
    @types.screen_h - 27,
    20,
    @raylib.Color::new(224, 229, 238, 230),
  )
}

///|
fn draw_title_overlay(_game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_w,
    @types.screen_h,
    @raylib.Color::new(8, 8, 12, 166),
  )
  draw_center_text(
    "NIGHT MARKET CHEF DUEL 2026",
    194,
    56,
    @raylib.Color::new(255, 230, 148, 250),
  )
  draw_center_text(
    "Manage prep, grill and wok to survive the rush.",
    276,
    30,
    @raylib.Color::new(230, 236, 246, 240),
  )
  draw_center_text(
    "Serve before patience expires. Too many failed orders ends the duel.",
    318,
    26,
    @raylib.Color::new(196, 206, 226, 232),
  )
  draw_center_text(
    "Press J or Enter to start",
    386,
    34,
    @raylib.Color::new(133, 239, 177, 244),
  )
}

///|
fn draw_pause_overlay(_game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_w,
    @types.screen_h,
    @raylib.Color::new(6, 8, 12, 168),
  )
  draw_center_text("PAUSED", 248, 68, @raylib.Color::new(242, 246, 252, 250))
  draw_center_text(
    "Press P or J to resume",
    344,
    32,
    @raylib.Color::new(228, 234, 244, 235),
  )
  draw_center_text(
    "Press R to restart the duel",
    386,
    30,
    @raylib.Color::new(190, 202, 224, 232),
  )
}

///|
fn draw_game_over_overlay(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_w,
    @types.screen_h,
    @raylib.Color::new(14, 6, 8, 190),
  )
  draw_center_text(
    "SERVICE COLLAPSED",
    216,
    62,
    @raylib.Color::new(255, 154, 154, 248),
  )
  draw_center_text(
    "Final Score " + game.score.to_string(),
    310,
    40,
    @raylib.Color::new(244, 240, 230, 242),
  )
  draw_center_text(
    "Served " +
    game.served_orders.to_string() +
    " | Failed " +
    game.failed_orders.to_string() +
    " | Best " +
    game.best_score.to_string(),
    360,
    30,
    @raylib.Color::new(228, 213, 210, 238),
  )
  draw_center_text(
    "Press R or J to run another round",
    418,
    30,
    @raylib.Color::new(193, 225, 255, 238),
  )
}

///|
pub fn draw_frame(game : @types.Game) -> Unit {
  @raylib.clear_background(@raylib.Color::new(0, 0, 0, 255))

  draw_background(game)
  draw_orders_panel(game)
  draw_prep_station(game)
  draw_grill_station(game)
  draw_wok_station(game)
  draw_pass_station(game)
  draw_cursor(game)
  draw_hud(game)
  draw_hint_line()

  match game.state {
    @types.Title => draw_title_overlay(game)
    @types.Paused => draw_pause_overlay(game)
    @types.GameOver => draw_game_over_overlay(game)
    @types.Play => ()
  }
}
