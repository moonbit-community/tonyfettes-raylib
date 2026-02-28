// 2D UI overlay

pub fn draw_ui(game : @types.Game) -> Unit {
  if game.state == @types.state_menu {
    draw_menu(game)
  } else if game.state == @types.state_playing {
    draw_hud(game)
    if game.message_timer > 0.0 {
      draw_message(game)
    }
  } else if game.state == @types.state_paused {
    draw_hud(game)
    draw_pause_overlay()
  } else if game.state == @types.state_battle_complete {
    draw_hud(game)
    draw_battle_complete(game)
  } else if game.state == @types.state_game_over {
    draw_game_over(game)
  }
}

fn draw_menu(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0, 0, @types.screen_width, @types.screen_height, @raylib.Color::new(
      15, 30, 60, 255,
    ),
  )
  // Title
  let title = "NAVAL COMBAT 3D"
  let tw = @raylib.measure_text(title, 52)
  @raylib.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    120,
    52,
    @raylib.Color::new(220, 200, 140, 255),
  )
  // Subtitle
  let sub = "Command your ship. Destroy the fleet."
  let sw = @raylib.measure_text(sub, 20)
  @raylib.draw_text(
    sub,
    (@types.screen_width - sw) / 2,
    185,
    20,
    @raylib.Color::new(140, 160, 200, 255),
  )
  // Ship art (simple text art)
  let art = "~ ~ ~ __|__ ~ ~ ~"
  let aw = @raylib.measure_text(art, 24)
  @raylib.draw_text(
    art,
    (@types.screen_width - aw) / 2,
    240,
    24,
    @raylib.Color::new(100, 140, 200, 200),
  )
  // Start prompt
  let blink_val = @math.sinf(game.menu_blink * 2.0)
  let prompt_alpha : Int = if blink_val > 0.0 { 255 } else { 150 }
  let prompt = "Press ENTER or SPACE to begin"
  let pw = @raylib.measure_text(prompt, 24)
  @raylib.draw_text(
    prompt,
    (@types.screen_width - pw) / 2,
    350,
    24,
    @raylib.Color::new(255, 220, 100, prompt_alpha),
  )
  // Controls info
  let controls : Array[String] = [
    "WASD - Sail and Steer",
    "Q / Left Click - Fire Port Cannons",
    "E / Right Click - Fire Starboard Cannons",
    "Space - Fire Both Broadsides",
    "P / ESC - Pause",
    "Mouse Wheel - Rotate Camera",
  ]
  for i = 0; i < controls.length(); i = i + 1 {
    let y = 430 + i * 24
    let cw = @raylib.measure_text(controls[i], 16)
    @raylib.draw_text(
      controls[i],
      (@types.screen_width - cw) / 2,
      y,
      16,
      @raylib.Color::new(120, 140, 170, 255),
    )
  }
  // Version
  @raylib.draw_text(
    "8 Battles | Wind Sailing | Broadside Cannons",
    10,
    @types.screen_height - 25,
    14,
    @raylib.Color::new(80, 100, 130, 255),
  )
}

fn draw_hud(game : @types.Game) -> Unit {
  let ship = game.player
  // Top bar background
  @raylib.draw_rectangle(0, 0, @types.screen_width, 50, @raylib.Color::new(
    0, 0, 0, 160,
  ))
  // Battle info
  @raylib.draw_text(
    "Battle: \{game.current_battle + 1}/\{game.total_battles}",
    10,
    5,
    20,
    @raylib.Color::new(220, 200, 140, 255),
  )
  // Score
  @raylib.draw_text(
    "Score: \{game.score}",
    220,
    5,
    20,
    @raylib.Color::new(200, 200, 200, 255),
  )
  // Enemies alive
  @raylib.draw_text(
    "Enemies: \{game.enemies_alive}",
    420,
    5,
    20,
    @raylib.Color::new(255, 150, 100, 255),
  )
  // Wind indicator text
  @raylib.draw_text(
    "Wind",
    650,
    5,
    16,
    @raylib.Color::new(150, 180, 220, 255),
  )
  // Wind direction as arrow character hint
  let wind_rel = @types.angle_diff(ship.heading, game.wind_angle)
  let wind_str = if @types.absf(wind_rel) < 0.5 {
    "Tailwind"
  } else if @types.absf(wind_rel) > 2.6 {
    "Headwind"
  } else {
    "Crosswind"
  }
  @raylib.draw_text(
    wind_str, 700, 5, 16, @raylib.Color::new(180, 200, 255, 255),
  )
  // Speed
  let speed_pct = (ship.speed / @types.player_max_sail * 100.0).to_int()
  @raylib.draw_text(
    "Speed: \{speed_pct}%",
    830,
    5,
    16,
    @raylib.Color::new(200, 220, 255, 255),
  )
  // Sail amount
  let sail_pct = (ship.sail_amount * 100.0).to_int()
  @raylib.draw_text(
    "Sails: \{sail_pct}%",
    830,
    25,
    16,
    @raylib.Color::new(220, 220, 200, 255),
  )
  // Damage zone bars - bottom left
  let bar_x = 10
  let bar_base_y = @types.screen_height - 80
  let bar_w = 150
  let bar_h = 16
  // Hull HP bar
  draw_hp_bar(
    bar_x,
    bar_base_y,
    bar_w,
    bar_h,
    "Hull",
    ship.hull_hp,
    ship.max_hp,
    180,
    60,
    60,
  )
  // Sail HP bar
  draw_hp_bar(
    bar_x,
    bar_base_y + 22,
    bar_w,
    bar_h,
    "Sails",
    ship.sail_hp,
    ship.max_hp,
    200,
    200,
    140,
  )
  // Rudder HP bar
  draw_hp_bar(
    bar_x,
    bar_base_y + 44,
    bar_w,
    bar_h,
    "Rudder",
    ship.rudder_hp,
    ship.max_hp,
    100,
    160,
    220,
  )
  // Reload indicators - bottom right
  let reload_x = @types.screen_width - 200
  let reload_y = @types.screen_height - 50
  let left_pct : Float = if ship.reload_time > 0.0 {
    1.0 - ship.reload_left / ship.reload_time
  } else {
    1.0
  }
  let right_pct : Float = if ship.reload_time > 0.0 {
    1.0 - ship.reload_right / ship.reload_time
  } else {
    1.0
  }
  @raylib.draw_text(
    "Port", reload_x, reload_y, 14, @raylib.Color::new(180, 180, 200, 255),
  )
  @raylib.draw_rectangle(
    reload_x + 50, reload_y + 2, 60, 12, @raylib.Color::new(40, 40, 50, 200),
  )
  let left_fill = (left_pct * 60.0).to_int()
  let left_color = if left_pct >= 1.0 {
    @raylib.Color::new(100, 255, 100, 255)
  } else {
    @raylib.Color::new(255, 200, 50, 255)
  }
  @raylib.draw_rectangle(reload_x + 50, reload_y + 2, left_fill, 12, left_color)
  @raylib.draw_text(
    "Star",
    reload_x,
    reload_y + 18,
    14,
    @raylib.Color::new(180, 180, 200, 255),
  )
  @raylib.draw_rectangle(
    reload_x + 50,
    reload_y + 20,
    60,
    12,
    @raylib.Color::new(40, 40, 50, 200),
  )
  let right_fill = (right_pct * 60.0).to_int()
  let right_color = if right_pct >= 1.0 {
    @raylib.Color::new(100, 255, 100, 255)
  } else {
    @raylib.Color::new(255, 200, 50, 255)
  }
  @raylib.draw_rectangle(
    reload_x + 50, reload_y + 20, right_fill, 12, right_color,
  )
  // Bottom control hints
  @raylib.draw_rectangle(
    0, @types.screen_height - 20, @types.screen_width, 20, @raylib.Color::new(
      0, 0, 0, 100,
    ),
  )
  @raylib.draw_text(
    "WASD: Sail | Q/LMB: Port Fire | E/RMB: Starboard Fire | Space: Both | P: Pause",
    10,
    @types.screen_height - 18,
    12,
    @raylib.Color::new(130, 140, 160, 255),
  )
}

fn draw_hp_bar(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  label : String,
  hp : Float,
  max_hp : Float,
  r : Int,
  g : Int,
  b : Int
) -> Unit {
  let pct : Float = if max_hp > 0.0 { hp / max_hp } else { 0.0 }
  let clamped = @types.clampf(pct, 0.0, 1.0)
  // Background
  @raylib.draw_rectangle(x, y, w, h, @raylib.Color::new(30, 30, 40, 200))
  // Fill
  let fill_w = (clamped * Float::from_int(w)).to_int()
  @raylib.draw_rectangle(x, y, fill_w, h, @raylib.Color::new(r, g, b, 220))
  // Border
  @raylib.draw_rectangle_lines(
    x, y, w, h, @raylib.Color::new(100, 100, 120, 255),
  )
  // Label
  @raylib.draw_text(
    label, x + 4, y + 1, 12, @raylib.Color::new(255, 255, 255, 220),
  )
  // Percentage
  let pct_text = "\{(clamped * 100.0).to_int()}%"
  let tw = @raylib.measure_text(pct_text, 12)
  @raylib.draw_text(
    pct_text,
    x + w - tw - 4,
    y + 1,
    12,
    @raylib.Color::new(255, 255, 255, 200),
  )
}

fn draw_message(game : @types.Game) -> Unit {
  let text = game.message_text
  let tw = @raylib.measure_text(text, 28)
  let y = 60
  @raylib.draw_rectangle(
    (@types.screen_width - tw) / 2 - 15,
    y - 5,
    tw + 30,
    40,
    @raylib.Color::new(0, 0, 0, 180),
  )
  @raylib.draw_text(
    text,
    (@types.screen_width - tw) / 2,
    y,
    28,
    @raylib.Color::new(255, 220, 100, 255),
  )
}

fn draw_pause_overlay() -> Unit {
  @raylib.draw_rectangle(
    0, 0, @types.screen_width, @types.screen_height, @raylib.Color::new(
      0, 0, 0, 150,
    ),
  )
  let text = "PAUSED"
  let tw = @raylib.measure_text(text, 60)
  @raylib.draw_text(
    text,
    (@types.screen_width - tw) / 2,
    @types.screen_height / 2 - 50,
    60,
    @raylib.white,
  )
  let hint = "Press P or ESC to resume"
  let hw = @raylib.measure_text(hint, 20)
  @raylib.draw_text(
    hint,
    (@types.screen_width - hw) / 2,
    @types.screen_height / 2 + 20,
    20,
    @raylib.Color::new(180, 180, 200, 255),
  )
}

fn draw_battle_complete(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0, 0, @types.screen_width, @types.screen_height, @raylib.Color::new(
      0, 20, 40, 200,
    ),
  )
  if game.current_battle >= game.total_battles {
    // Victory screen
    let title = "VICTORY!"
    let tw = @raylib.measure_text(title, 60)
    @raylib.draw_text(
      title,
      (@types.screen_width - tw) / 2,
      @types.screen_height / 2 - 80,
      60,
      @raylib.Color::new(255, 220, 100, 255),
    )
    let score_text = "Final Score: \{game.score}"
    let sw = @raylib.measure_text(score_text, 28)
    @raylib.draw_text(
      score_text,
      (@types.screen_width - sw) / 2,
      @types.screen_height / 2,
      28,
      @raylib.Color::new(200, 220, 255, 255),
    )
    let msg = "All 8 battles won! You are the Admiral!"
    let mw = @raylib.measure_text(msg, 20)
    @raylib.draw_text(
      msg,
      (@types.screen_width - mw) / 2,
      @types.screen_height / 2 + 40,
      20,
      @raylib.Color::new(150, 200, 150, 255),
    )
  } else {
    let title = "BATTLE COMPLETE!"
    let tw = @raylib.measure_text(title, 48)
    @raylib.draw_text(
      title,
      (@types.screen_width - tw) / 2,
      @types.screen_height / 2 - 60,
      48,
      @raylib.Color::new(100, 255, 100, 255),
    )
    let score_text = "Score: \{game.score}"
    let sw = @raylib.measure_text(score_text, 24)
    @raylib.draw_text(
      score_text,
      (@types.screen_width - sw) / 2,
      @types.screen_height / 2,
      24,
      @raylib.Color::new(200, 200, 200, 255),
    )
    let next_text = "Next: Battle \{game.current_battle + 1}"
    let nw = @raylib.measure_text(next_text, 20)
    @raylib.draw_text(
      next_text,
      (@types.screen_width - nw) / 2,
      @types.screen_height / 2 + 35,
      20,
      @raylib.Color::new(180, 200, 255, 255),
    )
  }
  let prompt = "Press ENTER to continue"
  let pw = @raylib.measure_text(prompt, 18)
  @raylib.draw_text(
    prompt,
    (@types.screen_width - pw) / 2,
    @types.screen_height / 2 + 80,
    18,
    @raylib.Color::new(180, 180, 200, 255),
  )
}

fn draw_game_over(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0, 0, @types.screen_width, @types.screen_height, @raylib.Color::new(
      40, 0, 0, 220,
    ),
  )
  let title = "SHIP SUNK!"
  let tw = @raylib.measure_text(title, 60)
  @raylib.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    @types.screen_height / 2 - 80,
    60,
    @raylib.Color::new(255, 80, 60, 255),
  )
  let score_text = "Score: \{game.score} | Battle: \{game.current_battle + 1}"
  let sw = @raylib.measure_text(score_text, 24)
  @raylib.draw_text(
    score_text,
    (@types.screen_width - sw) / 2,
    @types.screen_height / 2 + 10,
    24,
    @raylib.Color::new(200, 200, 200, 255),
  )
  let prompt = "Press ENTER to return to menu"
  let pw = @raylib.measure_text(prompt, 18)
  @raylib.draw_text(
    prompt,
    (@types.screen_width - pw) / 2,
    @types.screen_height / 2 + 50,
    18,
    @raylib.Color::new(180, 180, 200, 255),
  )
}
