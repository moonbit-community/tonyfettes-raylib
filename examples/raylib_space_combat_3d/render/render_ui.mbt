// 2D UI overlay

pub fn draw_ui(game : @types.Game) -> Unit {
  if game.state == @types.state_menu {
    draw_menu(game)
  } else if game.state == @types.state_playing {
    draw_hud(game)
    draw_crosshair(game)
    if game.message_timer > 0.0 {
      draw_message(game)
    }
  } else if game.state == @types.state_paused {
    draw_hud(game)
    draw_pause_overlay(game)
  } else if game.state == @types.state_mission_complete {
    draw_hud(game)
    draw_mission_complete(game)
  } else if game.state == @types.state_game_over {
    draw_game_over(game)
  }
}

fn draw_menu(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0, 0, @types.screen_width, @types.screen_height, @raylib.Color::new(
      2, 2, 8, 255,
    ),
  )

  // Starfield effect on menu
  let frame_f = Float::from_int(game.frame_counter)
  for i = 0; i < 60; i = i + 1 {
    let fi = Float::from_int(i)
    let sx = ((@math.sinf(fi * 3.7 + frame_f * 0.01) + 1.0) * 0.5 * Float::from_int(
        @types.screen_width,
      )).to_int()
    let sy = ((@math.cosf(fi * 2.1 + frame_f * 0.008) + 1.0) * 0.5 * Float::from_int(
        @types.screen_height,
      )).to_int()
    let bright = 80 + (fi * 2.5).to_int()
    @raylib.draw_rectangle(
      sx, sy, 2, 2, @raylib.Color::new(bright, bright, bright, 200),
    )
    ignore(i)
  }

  let title = "SPACE COMBAT 3D"
  let tw = @raylib.measure_text(title, 52)
  @raylib.draw_text(
    title, (@types.screen_width - tw) / 2, 120, 52, @raylib.Color::new(
      100, 180, 255, 255,
    ),
  )

  let sub = "Dogfighting in the void"
  let sw = @raylib.measure_text(sub, 20)
  @raylib.draw_text(
    sub, (@types.screen_width - sw) / 2, 185, 20, @raylib.Color::new(
      80, 130, 200, 255,
    ),
  )

  let items : Array[String] = ["New Game", "Continue", "Start"]
  for i = 0; i < items.length(); i = i + 1 {
    let y = 300 + i * 50
    let is_sel = game.menu_cursor == i
    let blink = @math.sinf(game.menu_blink * 2.0)
    let color = if is_sel {
      if blink > 0.0 {
        @raylib.Color::new(255, 255, 100, 255)
      } else {
        @raylib.Color::new(200, 200, 80, 255)
      }
    } else {
      @raylib.Color::new(150, 150, 170, 255)
    }
    let prefix = if is_sel { "> " } else { "  " }
    let text = prefix + items[i]
    let full_w = @raylib.measure_text(text, 28)
    @raylib.draw_text(text, (@types.screen_width - full_w) / 2, y, 28, color)
  }

  @raylib.draw_text(
    "Arrows: Select | Enter: Play",
    (@types.screen_width - @raylib.measure_text(
        "Arrows: Select | Enter: Play", 16,
      )) /
    2,
    @types.screen_height - 60,
    16,
    @raylib.Color::new(80, 100, 120, 255),
  )
  @raylib.draw_text(
    "WASD: Fly | QE: Roll | Space: Fire | Tab: Target | 1-3: Weapons",
    (@types.screen_width - @raylib.measure_text(
        "WASD: Fly | QE: Roll | Space: Fire | Tab: Target | 1-3: Weapons",
        14,
      )) /
    2,
    @types.screen_height - 35,
    14,
    @raylib.Color::new(60, 80, 100, 255),
  )
}

fn draw_hud(game : @types.Game) -> Unit {
  let p = game.player

  // Top bar
  @raylib.draw_rectangle(0, 0, @types.screen_width, 36, @raylib.Color::new(
    0, 0, 0, 160,
  ))
  @raylib.draw_text(
    "Mission \{game.current_mission + 1}: \{@levels.mission_name(game.current_mission)}",
    10,
    8,
    20,
    @raylib.Color::new(200, 220, 255, 255),
  )
  @raylib.draw_text(
    "Score: \{game.score}",
    @types.screen_width - 150,
    8,
    20,
    @raylib.Color::new(255, 255, 200, 255),
  )
  @raylib.draw_text(
    "Enemies: \{game.enemies_remaining}",
    @types.screen_width / 2 - 50,
    8,
    20,
    @raylib.Color::new(255, 150, 100, 255),
  )

  // Hull bar (bottom left)
  let bar_x = 10
  let bar_y = @types.screen_height - 60
  let bar_w = 200
  let bar_h = 16
  @raylib.draw_rectangle(bar_x, bar_y, bar_w, bar_h, @raylib.Color::new(
    40, 0, 0, 200,
  ))
  let hull_w = (p.hull / @types.player_max_hull * Float::from_int(bar_w)).to_int()
  let hull_color = if p.hull > 50.0 {
    @raylib.Color::new(0, 200, 0, 255)
  } else if p.hull > 25.0 {
    @raylib.Color::new(200, 200, 0, 255)
  } else {
    @raylib.Color::new(200, 0, 0, 255)
  }
  @raylib.draw_rectangle(bar_x, bar_y, hull_w, bar_h, hull_color)
  @raylib.draw_rectangle_lines(bar_x, bar_y, bar_w, bar_h, @raylib.Color::new(
    150, 150, 150, 200,
  ))
  @raylib.draw_text(
    "HULL",
    bar_x,
    bar_y - 16,
    14,
    @raylib.Color::new(200, 200, 200, 255),
  )

  // Shield bar
  let shield_y = @types.screen_height - 35
  @raylib.draw_rectangle(bar_x, shield_y, bar_w, bar_h, @raylib.Color::new(
    0, 0, 40, 200,
  ))
  let shield_w = (p.shield / @types.player_max_shield * Float::from_int(
      bar_w,
    )).to_int()
  @raylib.draw_rectangle(
    bar_x, shield_y, shield_w, bar_h, @raylib.Color::new(80, 140, 255, 255),
  )
  @raylib.draw_rectangle_lines(
    bar_x, shield_y, bar_w, bar_h, @raylib.Color::new(100, 120, 180, 200),
  )
  @raylib.draw_text(
    "SHIELD",
    bar_x,
    shield_y - 16,
    14,
    @raylib.Color::new(100, 150, 255, 255),
  )

  // Weapon indicator (bottom right)
  let wpn_x = @types.screen_width - 180
  let wpn_y = @types.screen_height - 60
  @raylib.draw_rectangle(wpn_x, wpn_y, 170, 50, @raylib.Color::new(
    0, 0, 0, 160,
  ))
  @raylib.draw_text(
    "WEAPON:",
    wpn_x + 5,
    wpn_y + 5,
    14,
    @raylib.Color::new(150, 150, 170, 255),
  )
  let wpn_name = @types.weapon_name(p.weapon)
  let wpn_color = if p.weapon == @types.weapon_laser {
    @raylib.Color::new(255, 255, 100, 255)
  } else if p.weapon == @types.weapon_missile {
    @raylib.Color::new(255, 180, 80, 255)
  } else {
    @raylib.Color::new(100, 255, 150, 255)
  }
  @raylib.draw_text(wpn_name, wpn_x + 5, wpn_y + 25, 20, wpn_color)

  // Weapon selection keys
  let key1_color = if p.weapon == @types.weapon_laser {
    @raylib.Color::new(255, 255, 100, 255)
  } else {
    @raylib.Color::new(100, 100, 100, 255)
  }
  let key2_color = if p.weapon == @types.weapon_missile {
    @raylib.Color::new(255, 180, 80, 255)
  } else {
    @raylib.Color::new(100, 100, 100, 255)
  }
  let key3_color = if p.weapon == @types.weapon_plasma {
    @raylib.Color::new(100, 255, 150, 255)
  } else {
    @raylib.Color::new(100, 100, 100, 255)
  }
  @raylib.draw_text("1", wpn_x + 90, wpn_y + 25, 18, key1_color)
  @raylib.draw_text("2", wpn_x + 110, wpn_y + 25, 18, key2_color)
  @raylib.draw_text("3", wpn_x + 130, wpn_y + 25, 18, key3_color)

  // Target info
  if game.target_idx >= 0 && game.target_idx < game.enemies.length() {
    let e = game.enemies[game.target_idx]
    if e.active {
      let tgt_x = @types.screen_width / 2 - 80
      let tgt_y = @types.screen_height - 80
      @raylib.draw_rectangle(tgt_x, tgt_y, 160, 40, @raylib.Color::new(
        0, 0, 0, 140,
      ))
      let tgt_name = if e.kind == @types.enemy_fighter {
        "FIGHTER"
      } else {
        "CRUISER"
      }
      @raylib.draw_text(
        "TARGET: \{tgt_name}",
        tgt_x + 5,
        tgt_y + 3,
        14,
        @raylib.Color::new(255, 255, 0, 255),
      )
      let dist = @types.distance3d(
        game.player.x, game.player.y, game.player.z, e.x, e.y, e.z,
      )
      let dist_i = dist.to_int()
      @raylib.draw_text(
        "Dist: \{dist_i}m  HP: \{e.hp.to_int()}",
        tgt_x + 5,
        tgt_y + 20,
        14,
        @raylib.Color::new(200, 200, 100, 255),
      )
    }
  }

  // Speed indicator
  let spd_text = "SPD: \{game.player.speed.to_int()}"
  @raylib.draw_text(
    spd_text,
    @types.screen_width - 130,
    40,
    16,
    @raylib.Color::new(150, 200, 150, 255),
  )
  if game.player.boosting {
    @raylib.draw_text(
      "BOOST",
      @types.screen_width - 130,
      58,
      14,
      @raylib.Color::new(255, 200, 50, 255),
    )
  }

  // Bottom bar - controls reminder
  @raylib.draw_rectangle(
    0, @types.screen_height - 18, @types.screen_width, 18, @raylib.Color::new(
      0, 0, 0, 100,
    ),
  )
  @raylib.draw_text(
    "WASD: Fly | QE: Roll | Shift: Boost | Space: Fire | Tab: Target | 1-3: Weapons | P: Pause",
    10,
    @types.screen_height - 16,
    12,
    @raylib.Color::new(80, 90, 100, 255),
  )
}

fn draw_crosshair(game : @types.Game) -> Unit {
  let cx = @types.screen_width / 2
  let cy = @types.screen_height / 2
  let s = 12
  let color = if game.target_idx >= 0 {
    @raylib.Color::new(255, 255, 0, 200)
  } else {
    @raylib.Color::new(100, 200, 100, 150)
  }
  // Crosshair lines
  @raylib.draw_line(cx - s, cy, cx - 4, cy, color)
  @raylib.draw_line(cx + 4, cy, cx + s, cy, color)
  @raylib.draw_line(cx, cy - s, cx, cy - 4, color)
  @raylib.draw_line(cx, cy + 4, cx, cy + s, color)
  // Center dot
  @raylib.draw_rectangle(cx - 1, cy - 1, 2, 2, color)
}

fn draw_message(game : @types.Game) -> Unit {
  let text = game.message_text
  let tw = @raylib.measure_text(text, 32)
  let alpha = @types.minf(game.message_timer * 2.0, 1.0)
  let a = (alpha * 255.0).to_int()
  @raylib.draw_text(
    text,
    (@types.screen_width - tw) / 2,
    @types.screen_height / 2 - 120,
    32,
    @raylib.Color::new(255, 255, 200, @types.clampi(a, 0, 255)),
  )
}

fn draw_pause_overlay(game : @types.Game) -> Unit {
  ignore(game)
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
    @types.screen_height / 2 - 30,
    60,
    @raylib.white,
  )
  let sub = "Press P or ESC to resume"
  let sw = @raylib.measure_text(sub, 20)
  @raylib.draw_text(
    sub,
    (@types.screen_width - sw) / 2,
    @types.screen_height / 2 + 40,
    20,
    @raylib.Color::new(180, 180, 200, 255),
  )
}

fn draw_mission_complete(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0, 0, @types.screen_width, @types.screen_height, @raylib.Color::new(
      0, 10, 30, 200,
    ),
  )
  let text = "MISSION COMPLETE"
  let tw = @raylib.measure_text(text, 48)
  @raylib.draw_text(
    text,
    (@types.screen_width - tw) / 2,
    @types.screen_height / 2 - 80,
    48,
    @raylib.Color::new(100, 255, 100, 255),
  )
  let score_text = "Score: \{game.score}  Kills: \{game.total_kills}"
  let sw = @raylib.measure_text(score_text, 24)
  @raylib.draw_text(
    score_text,
    (@types.screen_width - sw) / 2,
    @types.screen_height / 2 - 10,
    24,
    @raylib.Color::new(200, 255, 200, 255),
  )
  let next_text = if game.current_mission + 1 >= @types.total_missions {
    "All missions complete! Enter: Menu"
  } else {
    "Enter: Next Mission"
  }
  let nw = @raylib.measure_text(next_text, 20)
  @raylib.draw_text(
    next_text,
    (@types.screen_width - nw) / 2,
    @types.screen_height / 2 + 40,
    20,
    @raylib.Color::new(180, 200, 180, 255),
  )
}

fn draw_game_over(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0, 0, @types.screen_width, @types.screen_height, @raylib.Color::new(
      30, 0, 0, 220,
    ),
  )
  let text = "DESTROYED"
  let tw = @raylib.measure_text(text, 60)
  @raylib.draw_text(
    text,
    (@types.screen_width - tw) / 2,
    @types.screen_height / 2 - 60,
    60,
    @raylib.Color::new(255, 80, 60, 255),
  )
  let score_text = "Score: \{game.score}  Mission: \{game.current_mission + 1}"
  let sw = @raylib.measure_text(score_text, 24)
  @raylib.draw_text(
    score_text,
    (@types.screen_width - sw) / 2,
    @types.screen_height / 2 + 20,
    24,
    @raylib.Color::new(200, 200, 200, 255),
  )
  @raylib.draw_text(
    "Enter: Menu",
    (@types.screen_width - @raylib.measure_text("Enter: Menu", 18)) / 2,
    @types.screen_height / 2 + 60,
    18,
    @raylib.Color::new(180, 180, 200, 255),
  )
}
