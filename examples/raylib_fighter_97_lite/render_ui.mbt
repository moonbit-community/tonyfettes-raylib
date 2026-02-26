///|
fn draw_health_gauge(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  ratio : Float,
  base_color : @raylib.Color,
) -> Unit {
  @raylib.draw_rectangle(x, y, w, h, @raylib.Color::new(24, 26, 34, 220))
  @raylib.draw_rectangle_lines(x, y, w, h, @raylib.Color::new(80, 84, 96, 255))

  let fill = clampi((ratio * Float::from_int(w - 4)).to_int(), 0, w - 4)
  @raylib.draw_rectangle(x + 2, y + 2, fill, h - 4, base_color)
}

///|
fn draw_meter_gauge(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  ratio : Float,
  base_color : @raylib.Color,
) -> Unit {
  @raylib.draw_rectangle(x, y, w, h, @raylib.Color::new(20, 20, 26, 210))
  @raylib.draw_rectangle_lines(x, y, w, h, @raylib.Color::new(72, 80, 100, 255))

  let fill = clampi((ratio * Float::from_int(w - 2)).to_int(), 0, w - 2)
  @raylib.draw_rectangle(x + 1, y + 1, fill, h - 2, base_color)

  let step_w = (w - 2) / 5
  for i = 1; i < 5; i = i + 1 {
    let sx = x + 1 + i * step_w
    @raylib.draw_line(
      sx,
      y + 1,
      sx,
      y + h - 2,
      @raylib.Color::new(24, 32, 46, 180),
    )
  }
}

///|
fn draw_round_win_markers(
  x : Int,
  y : Int,
  wins : Int,
  tint : @raylib.Color,
) -> Unit {
  for i = 0; i < max_round_wins; i = i + 1 {
    let cx = x + i * 24
    let color = if i < wins {
      tint
    } else {
      @raylib.Color::new(56, 62, 76, 255)
    }
    @raylib.draw_circle(cx, y, 8.0, color)
    @raylib.draw_circle_lines(
      cx,
      y,
      8.0,
      @raylib.Color::new(220, 230, 240, 180),
    )
  }
}

///|
fn training_direction_numpad(input : InputState) -> String {
  if input.hold_down {
    if input.hold_back {
      "1"
    } else if input.hold_forward {
      "3"
    } else {
      "2"
    }
  } else if input.hold_up {
    if input.hold_back {
      "7"
    } else if input.hold_forward {
      "9"
    } else {
      "8"
    }
  } else if input.hold_back {
    "4"
  } else if input.hold_forward {
    "6"
  } else {
    "5"
  }
}

///|
fn training_button_color(down : Bool, pressed : Bool) -> @raylib.Color {
  if pressed {
    @raylib.Color::new(255, 226, 146, 255)
  } else if down {
    @raylib.raywhite
  } else {
    @raylib.Color::new(120, 130, 148, 255)
  }
}

///|
fn draw_training_input_panel(
  x : Int,
  y : Int,
  title : String,
  tint : @raylib.Color,
  input : InputState,
) -> Unit {
  @raylib.draw_rectangle(x, y, 266, 84, @raylib.Color::new(10, 12, 20, 210))
  @raylib.draw_rectangle_lines(x, y, 266, 84, tint)

  draw_shadow_text(title, x + 10, y + 8, 16, tint)
  draw_shadow_text(
    "DIR \{training_direction_numpad(input)}",
    x + 10,
    y + 28,
    24,
    @raylib.Color::new(172, 214, 250, 255),
  )

  draw_shadow_text(
    "LP",
    x + 94,
    y + 54,
    18,
    training_button_color(input.lp_down, input.lp_pressed),
  )
  draw_shadow_text(
    "HP",
    x + 130,
    y + 54,
    18,
    training_button_color(input.hp_down, input.hp_pressed),
  )
  draw_shadow_text(
    "LK",
    x + 166,
    y + 54,
    18,
    training_button_color(input.lk_down, input.lk_pressed),
  )
  draw_shadow_text(
    "HK",
    x + 202,
    y + 54,
    18,
    training_button_color(input.hk_down, input.hk_pressed),
  )
}

///|
fn draw_training_adv_panel(game : Game) -> Unit {
  @raylib.draw_rectangle(
    screen_width / 2 - 210,
    116,
    420,
    34,
    @raylib.Color::new(10, 12, 20, 210),
  )
  @raylib.draw_rectangle_lines(
    screen_width / 2 - 210,
    116,
    420,
    34,
    @raylib.Color::new(94, 132, 166, 255),
  )

  let text = if game.training_adv_text == "" {
    "No contact yet"
  } else {
    game.training_adv_text
  }
  let color = if game.training_adv_timer > 0.0 {
    @raylib.Color::new(255, 230, 156, 255)
  } else {
    @raylib.Color::new(156, 170, 192, 255)
  }
  draw_center_shadow_text(text, screen_width / 2, 123, 20, color)
}

///|
fn draw_fight_hud(game : Game) -> Unit {
  let p1 = game.fighters[0]
  let p2 = game.fighters[1]
  let a1 = fighter_archetype(game, p1)
  let a2 = fighter_archetype(game, p2)

  let flash = if game.hud_flash > 0.0 {
    @raylib.color_alpha(@raylib.white, game.hud_flash)
  } else {
    @raylib.Color::new(0, 0, 0, 0)
  }

  @raylib.draw_rectangle(
    0,
    0,
    screen_width,
    110,
    @raylib.Color::new(12, 14, 22, 178),
  )
  @raylib.draw_rectangle_lines(
    0,
    0,
    screen_width,
    110,
    @raylib.Color::new(70, 76, 94, 255),
  )

  draw_shadow_text(a1.name, 46, 18, 22, a1.ui_color)
  draw_shadow_text(a2.name, screen_width - 46 - 90, 18, 22, a2.ui_color)

  draw_health_gauge(42, 48, 470, 24, health_ratio(p1), a1.ui_color)
  draw_health_gauge(
    screen_width - 42 - 470,
    48,
    470,
    24,
    health_ratio(p2),
    a2.ui_color,
  )

  draw_meter_gauge(
    42,
    76,
    320,
    16,
    meter_ratio(p1),
    @raylib.Color::new(255, 188, 64, 255),
  )
  draw_meter_gauge(
    screen_width - 42 - 320,
    76,
    320,
    16,
    meter_ratio(p2),
    @raylib.Color::new(255, 188, 64, 255),
  )

  draw_meter_gauge(
    368,
    76,
    144,
    16,
    guard_ratio(p1, a1),
    @raylib.Color::new(132, 206, 255, 255),
  )
  draw_meter_gauge(
    screen_width - 512,
    76,
    144,
    16,
    guard_ratio(p2, a2),
    @raylib.Color::new(132, 206, 255, 255),
  )

  if game.mode_training {
    draw_shadow_text(
      "TRAINING",
      screen_width / 2 - 68,
      96,
      17,
      @raylib.Color::new(144, 226, 255, 255),
    )
  } else {
    draw_round_win_markers(44, 100, p1.round_wins, @raylib.gold)
    draw_round_win_markers(
      screen_width - 44 - 24,
      100,
      p2.round_wins,
      @raylib.gold,
    )
  }

  let timer_str = if game.mode_training {
    "INF"
  } else if game.round_timer <= 0.0 {
    "00"
  } else {
    "\{game.round_timer.to_int()}"
  }
  let timer_color = if game.mode_training {
    @raylib.Color::new(136, 228, 255, 255)
  } else {
    countdown_color(game.round_timer)
  }
  @raylib.draw_rectangle(
    screen_width / 2 - 66,
    24,
    132,
    66,
    @raylib.Color::new(18, 22, 30, 240),
  )
  @raylib.draw_rectangle_lines(
    screen_width / 2 - 66,
    24,
    132,
    66,
    @raylib.Color::new(92, 102, 124, 255),
  )
  draw_center_shadow_text(timer_str, screen_width / 2, 36, 42, timer_color)

  if p1.super_meter >= super_cost {
    draw_shadow_text("MAX", 46, 94, 14, @raylib.gold)
  }
  if p2.super_meter >= super_cost {
    draw_shadow_text("MAX", screen_width - 88, 94, 14, @raylib.gold)
  }

  if game.mode_training {
    draw_shadow_text(
      "R: reset  |  infinite meter + regen  |  frame data + input display",
      screen_width / 2 - 294,
      12,
      16,
      @raylib.Color::new(166, 208, 244, 255),
    )

    draw_training_adv_panel(game)
    draw_training_input_panel(
      24,
      116,
      "P1 INPUT",
      @raylib.Color::new(98, 190, 255, 255),
      p1.input,
    )
    draw_training_input_panel(
      screen_width - 24 - 266,
      116,
      "P2 INPUT",
      @raylib.Color::new(255, 156, 116, 255),
      p2.input,
    )
  }

  @raylib.draw_rectangle(0, 0, screen_width, screen_height, flash)
}

///|
fn draw_announcer(game : Game) -> Unit {
  if game.announcer_text == "" || game.announcer_timer <= 0.0 {
    return
  }

  let pop = Float::from_double(
      @math.sin((game.announcer_timer * 9.0).to_double()),
    ) *
    3.0
  let y = screen_height * 23 / 100 + pop.to_int()

  draw_center_shadow_text(
    game.announcer_text,
    screen_width / 2,
    y,
    48,
    @raylib.Color::new(255, 238, 188, 255),
  )
}

///|
fn draw_title_screen(game : Game) -> Unit {
  let glow = Float::from_double(@math.sin(game.title_blink.to_double())) * 0.5 +
    0.5
  let title_color = @raylib.color_lerp(
    @raylib.Color::new(248, 196, 98, 255),
    @raylib.Color::new(255, 240, 204, 255),
    glow,
  )

  draw_center_shadow_text(
    "FIGHTER '97 LITE",
    screen_width / 2,
    170,
    font_title,
    title_color,
  )
  draw_center_shadow_text(
    "KOF-style local duel built with MoonBit + raylib",
    screen_width / 2,
    250,
    font_subtitle,
    @raylib.Color::new(198, 218, 242, 255),
  )

  @raylib.draw_rectangle(
    screen_width / 2 - 360,
    314,
    720,
    182,
    @raylib.Color::new(14, 18, 28, 186),
  )
  @raylib.draw_rectangle_lines(
    screen_width / 2 - 360,
    314,
    720,
    182,
    @raylib.Color::new(84, 92, 116, 255),
  )

  draw_center_shadow_text(
    "P1: WASD + F/G/H/J",
    screen_width / 2,
    348,
    28,
    @raylib.raywhite,
  )
  draw_center_shadow_text(
    "P2: Arrows + U/I/O/P",
    screen_width / 2,
    386,
    28,
    @raylib.raywhite,
  )
  draw_center_shadow_text(
    "Double tap forward/back to dash",
    screen_width / 2,
    425,
    24,
    @raylib.Color::new(168, 212, 246, 255),
  )
  draw_center_shadow_text(
    "QCF + HP+HK when meter is MAX => SUPER",
    screen_width / 2,
    458,
    22,
    @raylib.Color::new(255, 205, 102, 255),
  )
  draw_center_shadow_text(
    "LP + LK at close range => THROW",
    screen_width / 2,
    488,
    22,
    @raylib.Color::new(168, 228, 196, 255),
  )

  let hint_color = if glow > 0.5 {
    @raylib.Color::new(255, 242, 198, 255)
  } else {
    @raylib.Color::new(220, 204, 160, 220)
  }
  draw_center_shadow_text(
    "PRESS ENTER TO START",
    screen_width / 2,
    590,
    34,
    hint_color,
  )

  draw_center_shadow_text(
    "F1: debug hitboxes",
    screen_width / 2,
    642,
    20,
    @raylib.Color::new(150, 166, 192, 255),
  )
}

///|
fn draw_select_card(
  game : Game,
  archetype : CharacterArchetype,
  index : Int,
  x : Int,
  y : Int,
  selected_p1 : Bool,
  selected_p2 : Bool,
) -> Unit {
  let card_w = 360
  let card_h = 182

  @raylib.draw_rectangle(
    x,
    y,
    card_w,
    card_h,
    @raylib.Color::new(18, 22, 32, 218),
  )

  let border = if selected_p1 && selected_p2 {
    @raylib.gold
  } else if selected_p1 {
    @raylib.Color::new(106, 198, 255, 255)
  } else if selected_p2 {
    @raylib.Color::new(255, 150, 98, 255)
  } else {
    @raylib.Color::new(70, 78, 94, 255)
  }
  @raylib.draw_rectangle_lines(x, y, card_w, card_h, border)

  @raylib.draw_rectangle(x + 10, y + 10, 100, 162, archetype.body_main)
  @raylib.draw_rectangle_lines(x + 10, y + 10, 100, 162, archetype.body_trim)

  draw_shadow_text(archetype.name, x + 124, y + 14, 34, archetype.ui_color)
  draw_shadow_text(archetype.title, x + 124, y + 52, 21, @raylib.raywhite)

  draw_shadow_text(
    "SPD \{(archetype.speed_mul * 100.0).to_int()}",
    x + 124,
    y + 88,
    18,
    @raylib.lightgray,
  )
  draw_shadow_text(
    "ATK \{(archetype.offense_mul * 100.0).to_int()}",
    x + 208,
    y + 88,
    18,
    @raylib.lightgray,
  )
  draw_shadow_text(
    "DEF \{(archetype.defense_mul * 100.0).to_int()}",
    x + 292,
    y + 88,
    18,
    @raylib.lightgray,
  )

  draw_shadow_text(
    archetype.intro_quote,
    x + 124,
    y + 122,
    18,
    @raylib.Color::new(180, 198, 220, 255),
  )

  draw_shadow_text(
    "#\{index + 1}",
    x + card_w - 44,
    y + card_h - 30,
    16,
    @raylib.gray,
  )
}

///|
fn draw_select_screen(game : Game) -> Unit {
  draw_center_shadow_text(
    "CHARACTER SELECT",
    screen_width / 2,
    36,
    46,
    @raylib.Color::new(246, 218, 152, 255),
  )

  let mode_text = if game.mode_training {
    "MODE: TRAINING (T to toggle off)"
  } else if game.mode_vs_cpu {
    "MODE: VS CPU (SPACE to switch)"
  } else {
    "MODE: P1 vs P2 (SPACE to switch)"
  }

  draw_center_shadow_text(
    mode_text,
    screen_width / 2,
    86,
    22,
    @raylib.Color::new(178, 204, 232, 255),
  )

  let card_w = 360
  let card_h = 182
  let gap_x = 28
  let gap_y = 24
  let start_x = (screen_width - (card_w * 3 + gap_x * 2)) / 2
  let start_y = 132

  for i = 0; i < roster_count; i = i + 1 {
    let row = i / select_grid_columns
    let col = i % select_grid_columns
    let x = start_x + col * (card_w + gap_x)
    let y = start_y + row * (card_h + gap_y)

    let selected_p1 = game.select_cursor_p1 == i
    let selected_p2 = game.select_cursor_p2 == i

    draw_select_card(game, game.roster[i], i, x, y, selected_p1, selected_p2)

    if selected_p1 {
      draw_shadow_text(
        if game.p1_confirmed {
          "P1 LOCK"
        } else {
          "P1"
        },
        x + 12,
        y + 12,
        18,
        if game.p1_confirmed {
          @raylib.gold
        } else {
          @raylib.Color::new(106, 198, 255, 255)
        },
      )
    }

    if selected_p2 {
      draw_shadow_text(
        if game.mode_vs_cpu {
          "CPU"
        } else if game.p2_confirmed {
          "P2 LOCK"
        } else {
          "P2"
        },
        x + card_w - 86,
        y + 12,
        18,
        if game.p2_confirmed || game.mode_vs_cpu {
          @raylib.gold
        } else {
          @raylib.Color::new(255, 150, 98, 255)
        },
      )
    }
  }

  draw_center_shadow_text(
    "P1 confirm: F or ENTER   |   P2 confirm: U or ENTER   |   T: training mode",
    screen_width / 2,
    564,
    20,
    @raylib.lightgray,
  )

  let ready = game.p1_confirmed && game.p2_confirmed
  draw_center_shadow_text(
    if ready {
      "MATCH STARTING..."
    } else {
      "Pick your fighter"
    },
    screen_width / 2,
    612,
    34,
    if ready {
      @raylib.Color::new(255, 228, 146, 255)
    } else {
      @raylib.Color::new(172, 204, 238, 255)
    },
  )

  if ready {
    let pulse = Float::from_double(@math.sin(game.select_blink.to_double())) *
      0.5 +
      0.5
    @raylib.draw_rectangle(
      screen_width / 2 - 300,
      650,
      600,
      40,
      @raylib.color_alpha(
        @raylib.Color::new(255, 202, 96, 255),
        0.12 + pulse * 0.2,
      ),
    )
  }
}

///|
fn draw_intro_overlay(game : Game) -> Unit {
  draw_announcer(game)

  let p1 = game.fighters[0]
  let p2 = game.fighters[1]
  let a1 = fighter_archetype(game, p1)
  let a2 = fighter_archetype(game, p2)

  @raylib.draw_rectangle(
    20,
    screen_height - quote_box_h - 22,
    quote_box_w,
    quote_box_h,
    @raylib.Color::new(12, 14, 22, 188),
  )
  @raylib.draw_rectangle_lines(
    20,
    screen_height - quote_box_h - 22,
    quote_box_w,
    quote_box_h,
    a1.ui_color,
  )
  draw_shadow_text(a1.intro_quote, 34, screen_height - 74, 20, @raylib.raywhite)

  @raylib.draw_rectangle(
    screen_width - quote_box_w - 20,
    screen_height - quote_box_h - 22,
    quote_box_w,
    quote_box_h,
    @raylib.Color::new(12, 14, 22, 188),
  )
  @raylib.draw_rectangle_lines(
    screen_width - quote_box_w - 20,
    screen_height - quote_box_h - 22,
    quote_box_w,
    quote_box_h,
    a2.ui_color,
  )
  draw_shadow_text(
    a2.intro_quote,
    screen_width - quote_box_w + 10,
    screen_height - 74,
    20,
    @raylib.raywhite,
  )
}

///|
fn draw_round_over_overlay(game : Game) -> Unit {
  draw_announcer(game)

  if game.winner_slot == winner_draw {
    draw_center_shadow_text(
      "DRAW",
      screen_width / 2,
      150,
      70,
      @raylib.Color::new(255, 232, 186, 255),
    )
  } else {
    let winner = game.fighters[game.winner_slot]
    let aw = fighter_archetype(game, winner)
    draw_center_shadow_text(
      "\{aw.name} TAKES THE ROUND",
      screen_width / 2,
      150,
      56,
      aw.ui_color,
    )
  }
}

///|
fn draw_match_over_overlay(game : Game) -> Unit {
  draw_announcer(game)

  if game.winner_slot == winner_draw {
    draw_center_shadow_text(
      "MATCH DRAW",
      screen_width / 2,
      142,
      70,
      @raylib.Color::new(255, 232, 188, 255),
    )
    return
  }

  let winner = game.fighters[game.winner_slot]
  let aw = fighter_archetype(game, winner)

  draw_center_shadow_text(
    "CHAMPION: \{aw.name}",
    screen_width / 2,
    120,
    64,
    aw.ui_color,
  )

  @raylib.draw_rectangle(
    screen_width / 2 - 520,
    206,
    1040,
    130,
    @raylib.Color::new(14, 18, 28, 194),
  )
  @raylib.draw_rectangle_lines(
    screen_width / 2 - 520,
    206,
    1040,
    130,
    aw.ui_color,
  )

  draw_center_shadow_text(
    aw.victory_quote,
    screen_width / 2,
    250,
    32,
    @raylib.raywhite,
  )

  draw_center_shadow_text(
    "Press ENTER for character select",
    screen_width / 2,
    366,
    24,
    @raylib.Color::new(180, 204, 226, 255),
  )
}

///|
fn draw_pause_overlay(game : Game) -> Unit {
  let pulse = Float::from_double(@math.sin(game.pause_blink.to_double())) * 0.5 +
    0.5
  @raylib.draw_rectangle(
    0,
    0,
    screen_width,
    screen_height,
    @raylib.Color::new(6, 8, 16, 140),
  )
  draw_center_shadow_text(
    "PAUSED",
    screen_width / 2,
    screen_height / 2 - 40,
    72,
    @raylib.color_alpha(@raylib.white, 0.7 + pulse * 0.3),
  )
  draw_center_shadow_text(
    "P: resume   ESC: character select",
    screen_width / 2,
    screen_height / 2 + 44,
    24,
    @raylib.raywhite,
  )
}

///|
fn draw_debug_overlay(game : Game) -> Unit {
  if not(game.debug_overlay) {
    return
  }

  let p1 = game.fighters[0]
  let p2 = game.fighters[1]

  @raylib.draw_rectangle(14, 120, 380, 132, @raylib.Color::new(0, 0, 0, 168))
  @raylib.draw_rectangle_lines(
    14,
    120,
    380,
    132,
    @raylib.Color::new(86, 100, 120, 255),
  )

  draw_shadow_text(
    "DEBUG p1: act=\{action_name(p1.action)} frame=\{p1.action_frame} hp=\{p1.health} guard=\{p1.guard_meter} meter=\{p1.super_meter}",
    24,
    136,
    16,
    @raylib.lime,
  )
  draw_shadow_text(
    "DEBUG p2: act=\{action_name(p2.action)} frame=\{p2.action_frame} hp=\{p2.health} guard=\{p2.guard_meter} meter=\{p2.super_meter}",
    24,
    158,
    16,
    @raylib.skyblue,
  )
  draw_shadow_text(
    "dist=\{fighter_distance_x(p1, p2).to_int()} freeze=\{game.dramatic_freeze} state=\{game.state}",
    24,
    180,
    16,
    @raylib.yellow,
  )
}

///|
fn draw_game(game : Game) -> Unit {
  draw_stage(game)

  if game.state == state_title {
    draw_title_screen(game)
  } else if game.state == state_select {
    draw_select_screen(game)
  } else {
    draw_fighters(game)
    draw_fight_hud(game)

    if game.state == state_intro {
      draw_intro_overlay(game)
    } else if game.state == state_round_over {
      draw_round_over_overlay(game)
    } else if game.state == state_match_over {
      draw_match_over_overlay(game)
    } else {
      draw_announcer(game)
    }

    if game.state == state_pause {
      draw_pause_overlay(game)
    }
  }

  draw_debug_overlay(game)
}
