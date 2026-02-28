// 2D UI overlay

///|
pub fn draw_ui(game : @types.Game) -> Unit {
  if game.state == @types.state_menu {
    draw_menu(game)
  } else if game.state == @types.state_playing {
    draw_hud(game)
    draw_crosshair(game)
    draw_weapon_display(game)
    draw_damage_flash(game)
    draw_message(game)
  } else if game.state == @types.state_wave_complete {
    draw_hud(game)
    draw_crosshair(game)
    draw_weapon_display(game)
    draw_shop_ui(game)
    draw_message(game)
  } else if game.state == @types.state_paused {
    draw_hud(game)
    draw_pause_overlay(game)
  } else if game.state == @types.state_game_over {
    draw_game_over(game)
  }
}

///|
fn draw_menu(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  let sh = @types.screen_height
  @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(10, 10, 20, 255))
  // Title
  let title = "SURVIVAL ARENA 3D"
  let tw = @raylib.measure_text(title, 52)
  @raylib.draw_text(
    title,
    (sw - tw) / 2,
    140,
    52,
    @raylib.Color::new(200, 50, 50, 255),
  )
  // Subtitle
  let sub = "Wave-based FPS Survival"
  let sub_w = @raylib.measure_text(sub, 22)
  @raylib.draw_text(
    sub,
    (sw - sub_w) / 2,
    200,
    22,
    @raylib.Color::new(180, 180, 200, 255),
  )
  // Instructions
  let blink = @math.sinf(game.menu_blink * 2.0)
  let start_color = if blink > 0.0 {
    @raylib.Color::new(255, 255, 100, 255)
  } else {
    @raylib.Color::new(200, 200, 80, 255)
  }
  let start_text = "Press ENTER or SPACE to Start"
  let start_w = @raylib.measure_text(start_text, 26)
  @raylib.draw_text(start_text, (sw - start_w) / 2, 300, 26, start_color)
  // Controls info
  let controls : Array[String] = [
    "WASD - Move | Mouse - Look", "Left Click - Shoot | Shift - Sprint", "1-4 / Scroll - Switch Weapon",
    "ESC - Pause",
  ]
  for i = 0; i < controls.length(); i = i + 1 {
    let text = controls[i]
    let cw = @raylib.measure_text(text, 16)
    @raylib.draw_text(
      text,
      (sw - cw) / 2,
      400 + i * 26,
      16,
      @raylib.Color::new(140, 140, 160, 255),
    )
  }
  // Game info
  let info = "Survive 20 waves of enemies. Collect ammo crates. Buy upgrades between waves."
  let iw = @raylib.measure_text(info, 14)
  @raylib.draw_text(
    info,
    (sw - iw) / 2,
    sh - 60,
    14,
    @raylib.Color::new(120, 120, 140, 255),
  )
}

///|
fn draw_hud(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  let player = game.player
  // Top bar background
  @raylib.draw_rectangle(0, 0, sw, 44, @raylib.Color::new(0, 0, 0, 160))
  // Wave info
  @raylib.draw_text(
    "Wave: \{game.current_wave + 1}/\{@types.max_waves}",
    10,
    12,
    20,
    @raylib.Color::new(200, 220, 255, 255),
  )
  // Score
  @raylib.draw_text(
    "Score: \{player.score}",
    200,
    12,
    20,
    @raylib.Color::new(200, 200, 200, 255),
  )
  // Gold
  @raylib.draw_text(
    "Gold: \{player.money}",
    400,
    12,
    20,
    @raylib.Color::new(255, 215, 0, 255),
  )
  // Kills
  @raylib.draw_text(
    "Kills: \{player.kills}",
    580,
    12,
    20,
    @raylib.Color::new(200, 100, 100, 255),
  )
  // FPS
  let fps = @raylib.get_fps()
  @raylib.draw_text(
    "FPS: \{fps}",
    sw - 100,
    12,
    18,
    @raylib.Color::new(150, 150, 150, 255),
  )
  // Health bar (bottom left)
  let sh = @types.screen_height
  let bar_x = 20
  let bar_y = sh - 60
  let bar_w = 200
  let bar_h = 20
  // HP background
  @raylib.draw_rectangle(
    bar_x - 2,
    bar_y - 2,
    bar_w + 4,
    bar_h + 4,
    @raylib.Color::new(0, 0, 0, 180),
  )
  // HP fill
  let hp_pct = player.hp / @types.player_max_hp
  let hp_fill_w = (Float::from_int(bar_w) * hp_pct).to_int()
  let hp_color = if hp_pct > 0.6 {
    @raylib.Color::new(0, 200, 50, 255)
  } else if hp_pct > 0.3 {
    @raylib.Color::new(220, 200, 0, 255)
  } else {
    @raylib.Color::new(220, 50, 30, 255)
  }
  @raylib.draw_rectangle(bar_x, bar_y, hp_fill_w, bar_h, hp_color)
  @raylib.draw_text(
    "HP: \{player.hp.to_int()}/\{@types.player_max_hp.to_int()}",
    bar_x + 5,
    bar_y + 2,
    16,
    @raylib.Color::new(255, 255, 255, 255),
  )
  // Armor bar
  let armor_y = bar_y - 28
  @raylib.draw_rectangle(
    bar_x - 2,
    armor_y - 2,
    bar_w + 4,
    bar_h + 4,
    @raylib.Color::new(0, 0, 0, 180),
  )
  let armor_pct = player.armor / @types.player_max_armor
  let armor_fill_w = (Float::from_int(bar_w) * armor_pct).to_int()
  @raylib.draw_rectangle(
    bar_x,
    armor_y,
    armor_fill_w,
    bar_h,
    @raylib.Color::new(50, 120, 220, 255),
  )
  @raylib.draw_text(
    "Armor: \{player.armor.to_int()}/\{@types.player_max_armor.to_int()}",
    bar_x + 5,
    armor_y + 2,
    16,
    @raylib.Color::new(255, 255, 255, 255),
  )
  // Ammo display (bottom right)
  let ammo_x = sw - 220
  let ammo_y = sh - 60
  @raylib.draw_rectangle(
    ammo_x - 5,
    ammo_y - 5,
    210,
    50,
    @raylib.Color::new(0, 0, 0, 160),
  )
  let weapon = player.current_weapon
  let weapon_text = @types.weapon_name(weapon)
  @raylib.draw_text(
    weapon_text,
    ammo_x,
    ammo_y,
    20,
    @raylib.Color::new(255, 220, 100, 255),
  )
  let ammo_count = player.ammo[weapon]
  let ammo_text = if weapon == @types.weapon_pistol {
    "Ammo: INF"
  } else {
    "Ammo: \{ammo_count}"
  }
  let ammo_color = if ammo_count > 0 || weapon == @types.weapon_pistol {
    @raylib.Color::new(200, 200, 200, 255)
  } else {
    @raylib.Color::new(255, 80, 80, 255)
  }
  @raylib.draw_text(ammo_text, ammo_x, ammo_y + 22, 18, ammo_color)
  // Weapon slots indicator
  let slot_y = sh - 95
  for i = 0; i < @types.weapon_count; i = i + 1 {
    let slot_x = ammo_x + i * 50
    let is_selected = i == player.current_weapon
    let bg_color = if is_selected {
      @raylib.Color::new(80, 80, 120, 200)
    } else {
      @raylib.Color::new(30, 30, 40, 150)
    }
    @raylib.draw_rectangle(slot_x, slot_y, 44, 28, bg_color)
    @raylib.draw_rectangle_lines(
      slot_x,
      slot_y,
      44,
      28,
      if is_selected {
        @raylib.Color::new(200, 200, 255, 255)
      } else {
        @raylib.Color::new(80, 80, 100, 255)
      },
    )
    let key_text = "\{i + 1}"
    @raylib.draw_text(
      key_text,
      slot_x + 4,
      slot_y + 4,
      14,
      @raylib.Color::new(200, 200, 200, 255),
    )
    let short_name = if i == 0 {
      "P"
    } else if i == 1 {
      "SG"
    } else if i == 2 {
      "R"
    } else if i == 3 {
      "S"
    } else if i == 4 {
      "RL"
    } else {
      "MG"
    }
    @raylib.draw_text(
      short_name,
      slot_x + 18,
      slot_y + 8,
      12,
      @raylib.Color::new(180, 180, 200, 255),
    )
  }
  // Enemy count during wave
  if game.wave_active {
    let alive = @types.count_active_enemies(game)
    let remaining = game.enemies_to_spawn - game.enemies_spawned + alive
    @raylib.draw_text(
      "Enemies: \{remaining}",
      sw / 2 - 50,
      50,
      18,
      @raylib.Color::new(255, 150, 100, 255),
    )
  }
}

///|
fn draw_crosshair(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  let sh = @types.screen_height
  let cx = sw / 2
  let cy = sh / 2
  let size = 10
  let gap = 3
  // Hit marker color flash
  let color = if game.hit_marker_timer > 0.0 {
    @raylib.Color::new(255, 50, 50, 255)
  } else {
    @raylib.Color::new(220, 220, 220, 200)
  }
  // Cross lines
  @raylib.draw_rectangle(cx - size, cy - 1, size - gap, 2, color)
  @raylib.draw_rectangle(cx + gap + 1, cy - 1, size - gap, 2, color)
  @raylib.draw_rectangle(cx - 1, cy - size, 2, size - gap, color)
  @raylib.draw_rectangle(cx - 1, cy + gap + 1, 2, size - gap, color)
  // Center dot
  @raylib.draw_rectangle(cx - 1, cy - 1, 2, 2, color)
  // Hit marker X when hitting
  if game.hit_marker_timer > 0.0 {
    let hm_size = 6
    // Top-left to bottom-right
    @raylib.draw_rectangle(
      cx - hm_size - 2,
      cy - hm_size - 2,
      4,
      4,
      @raylib.Color::new(255, 100, 100, 255),
    )
    @raylib.draw_rectangle(
      cx + hm_size - 2,
      cy + hm_size - 2,
      4,
      4,
      @raylib.Color::new(255, 100, 100, 255),
    )
    // Top-right to bottom-left
    @raylib.draw_rectangle(
      cx + hm_size - 2,
      cy - hm_size - 2,
      4,
      4,
      @raylib.Color::new(255, 100, 100, 255),
    )
    @raylib.draw_rectangle(
      cx - hm_size - 2,
      cy + hm_size - 2,
      4,
      4,
      @raylib.Color::new(255, 100, 100, 255),
    )
  }
}

///|
fn draw_weapon_display(game : @types.Game) -> Unit {
  let sh = @types.screen_height
  let sw = @types.screen_width
  let player = game.player
  // Weapon view model (simplified gun shape in 2D)
  let weapon = player.current_weapon
  let gun_x = sw / 2 + 80
  let gun_y = sh - 140
  // Muzzle flash
  if player.flash_timer > 0.0 {
    let flash_alpha = (player.flash_timer / 0.08 * 200.0).to_int()
    let fa = @types.clampi(flash_alpha, 0, 200)
    @raylib.draw_rectangle(
      gun_x - 5,
      gun_y - 30,
      10,
      20,
      @raylib.Color::new(255, 230, 100, fa),
    )
    @raylib.draw_rectangle(
      gun_x - 10,
      gun_y - 20,
      20,
      10,
      @raylib.Color::new(255, 200, 50, fa),
    )
  }
  if weapon == @types.weapon_pistol {
    // Pistol shape
    @raylib.draw_rectangle(
      gun_x - 6,
      gun_y,
      12,
      30,
      @raylib.Color::new(80, 80, 90, 255),
    )
    @raylib.draw_rectangle(
      gun_x - 4,
      gun_y - 15,
      8,
      18,
      @raylib.Color::new(100, 100, 110, 255),
    )
  } else if weapon == @types.weapon_shotgun {
    // Shotgun shape - wider
    @raylib.draw_rectangle(
      gun_x - 8,
      gun_y,
      16,
      35,
      @raylib.Color::new(120, 80, 40, 255),
    )
    @raylib.draw_rectangle(
      gun_x - 5,
      gun_y - 25,
      10,
      28,
      @raylib.Color::new(90, 90, 100, 255),
    )
    @raylib.draw_rectangle(
      gun_x - 5,
      gun_y - 28,
      10,
      6,
      @raylib.Color::new(70, 70, 80, 255),
    )
  } else if weapon == @types.weapon_rifle {
    // Rifle shape - long
    @raylib.draw_rectangle(
      gun_x - 6,
      gun_y,
      12,
      30,
      @raylib.Color::new(50, 80, 50, 255),
    )
    @raylib.draw_rectangle(
      gun_x - 4,
      gun_y - 35,
      8,
      38,
      @raylib.Color::new(80, 90, 80, 255),
    )
    @raylib.draw_rectangle(
      gun_x - 3,
      gun_y - 40,
      6,
      8,
      @raylib.Color::new(60, 70, 60, 255),
    )
  } else if weapon == @types.weapon_sniper {
    // Sniper shape - very long barrel with scope
    @raylib.draw_rectangle(
      gun_x - 5,
      gun_y,
      10,
      32,
      @raylib.Color::new(60, 60, 70, 255),
    )
    @raylib.draw_rectangle(
      gun_x - 3,
      gun_y - 45,
      6,
      48,
      @raylib.Color::new(90, 90, 100, 255),
    )
    // Scope
    @raylib.draw_rectangle(
      gun_x - 6,
      gun_y - 30,
      12,
      6,
      @raylib.Color::new(40, 40, 50, 255),
    )
    @raylib.draw_rectangle(
      gun_x - 2,
      gun_y - 50,
      4,
      8,
      @raylib.Color::new(70, 70, 80, 255),
    )
  } else if weapon == @types.weapon_minigun {
    // Minigun shape - wide with multiple barrels
    @raylib.draw_rectangle(
      gun_x - 10,
      gun_y,
      20,
      28,
      @raylib.Color::new(70, 70, 80, 255),
    )
    @raylib.draw_rectangle(
      gun_x - 8,
      gun_y - 30,
      16,
      34,
      @raylib.Color::new(90, 90, 100, 255),
    )
    // Multiple barrels
    @raylib.draw_rectangle(
      gun_x - 6,
      gun_y - 38,
      4,
      12,
      @raylib.Color::new(100, 100, 110, 255),
    )
    @raylib.draw_rectangle(
      gun_x + 2,
      gun_y - 38,
      4,
      12,
      @raylib.Color::new(100, 100, 110, 255),
    )
    // Ammo box
    @raylib.draw_rectangle(
      gun_x + 10,
      gun_y - 5,
      12,
      16,
      @raylib.Color::new(60, 80, 50, 255),
    )
  } else {
    // Rocket launcher - chunky
    @raylib.draw_rectangle(
      gun_x - 10,
      gun_y,
      20,
      30,
      @raylib.Color::new(60, 80, 60, 255),
    )
    @raylib.draw_rectangle(
      gun_x - 8,
      gun_y - 30,
      16,
      35,
      @raylib.Color::new(80, 80, 60, 255),
    )
    @raylib.draw_rectangle(
      gun_x - 10,
      gun_y - 15,
      20,
      8,
      @raylib.Color::new(120, 50, 30, 255),
    )
  }
}

///|
fn draw_damage_flash(game : @types.Game) -> Unit {
  if game.player.flash_timer > 0.0 && game.player.damage_timer > 0.0 {
    let alpha = (game.player.flash_timer / 0.2 * 100.0).to_int()
    let a = @types.clampi(alpha, 0, 100)
    @raylib.draw_rectangle(
      0,
      0,
      @types.screen_width,
      @types.screen_height,
      @raylib.Color::new(200, 0, 0, a),
    )
  }
}

///|
fn draw_message(game : @types.Game) -> Unit {
  if game.message_timer > 0.0 {
    let alpha_f = @types.minf(game.message_timer * 2.0, 1.0) * 255.0
    let alpha = alpha_f.to_int()
    let a = @types.clampi(alpha, 0, 255)
    let text = game.message_text
    let tw = @raylib.measure_text(text, 22)
    let cx = (@types.screen_width - tw) / 2
    let cy = 80
    @raylib.draw_rectangle(
      cx - 10,
      cy - 5,
      tw + 20,
      32,
      @raylib.Color::new(0, 0, 0, a / 2),
    )
    @raylib.draw_text(text, cx, cy, 22, @raylib.Color::new(255, 255, 200, a))
  }
}

///|
fn draw_shop_ui(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  // Shop panel
  let panel_w = 320
  let panel_h = 620
  let panel_x = (sw - panel_w) / 2
  let panel_y = 40
  @raylib.draw_rectangle(
    panel_x,
    panel_y,
    panel_w,
    panel_h,
    @raylib.Color::new(15, 18, 28, 230),
  )
  @raylib.draw_rectangle_lines(
    panel_x,
    panel_y,
    panel_w,
    panel_h,
    @raylib.Color::new(100, 120, 180, 255),
  )
  // Title
  let title = "SHOP - Between Waves"
  let ttw = @raylib.measure_text(title, 20)
  @raylib.draw_text(
    title,
    panel_x + (panel_w - ttw) / 2,
    panel_y + 10,
    20,
    @raylib.Color::new(200, 220, 255, 255),
  )
  // Timer
  let timer_text = "Next wave in: \{game.wave_timer.to_int() + 1}s (SPACE to skip)"
  let ttw2 = @raylib.measure_text(timer_text, 14)
  @raylib.draw_text(
    timer_text,
    panel_x + (panel_w - ttw2) / 2,
    panel_y + 35,
    14,
    @raylib.Color::new(255, 200, 100, 255),
  )
  // Shop items
  let items : Array[(String, Int)] = [
    ("Heal +40 HP", @types.cost_heal),
    ("Armor +30", @types.cost_armor),
    ("Shotgun Ammo +12", @types.cost_shotgun_ammo),
    ("Rifle Ammo +30", @types.cost_rifle_ammo),
    ("Sniper Ammo +5", @types.cost_sniper_ammo),
    ("Rocket Ammo +3", @types.cost_rocket_ammo),
    ("Minigun Ammo +100", @types.cost_minigun_ammo),
    ("Damage +15%", @types.cost_damage_up),
    ("Speed +10%", @types.cost_speed_up),
    ("Buy Sniper Rifle", @types.cost_buy_sniper),
    ("Buy Rocket Launcher", @types.cost_buy_rocket),
    ("Buy Minigun", @types.cost_buy_minigun),
    ("Place Barricade", @types.cost_barricade),
    ("Place Spike Trap", @types.cost_trap_spike),
  ]
  for i = 0; i < items.length(); i = i + 1 {
    let item = items[i]
    let iy = panel_y + 58 + i * 38
    let is_sel = game.shop_cursor == i
    let can_afford = game.player.money >= item.1
    let bg = if is_sel {
      @raylib.Color::new(50, 55, 80, 255)
    } else {
      @raylib.Color::new(25, 28, 40, 255)
    }
    @raylib.draw_rectangle(panel_x + 10, iy, panel_w - 20, 34, bg)
    if is_sel {
      @raylib.draw_rectangle_lines(
        panel_x + 10,
        iy,
        panel_w - 20,
        34,
        @raylib.Color::new(150, 170, 220, 255),
      )
    }
    let text_color = if can_afford {
      @raylib.Color::new(220, 220, 240, 255)
    } else {
      @raylib.Color::new(100, 80, 80, 255)
    }
    let prefix = if is_sel { "> " } else { "  " }
    @raylib.draw_text(prefix + item.0, panel_x + 18, iy + 5, 16, text_color)
    @raylib.draw_text(
      "\{item.1}g",
      panel_x + panel_w - 60,
      iy + 5,
      16,
      @raylib.Color::new(255, 215, 0, 200),
    )
  }
  // Gold display
  @raylib.draw_text(
    "Gold: \{game.player.money}",
    panel_x + 10,
    panel_y + panel_h - 30,
    16,
    @raylib.Color::new(255, 215, 0, 255),
  )
  // Controls hint
  @raylib.draw_text(
    "Up/Down: Select | E/Enter: Buy",
    panel_x + panel_w - 220,
    panel_y + panel_h - 30,
    12,
    @raylib.Color::new(140, 140, 160, 255),
  )
}

///|
fn draw_pause_overlay(game : @types.Game) -> Unit {
  ignore(game)
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(0, 0, 0, 150),
  )
  let text = "PAUSED"
  let tw = @raylib.measure_text(text, 60)
  @raylib.draw_text(
    text,
    (@types.screen_width - tw) / 2,
    @types.screen_height / 2 - 60,
    60,
    @raylib.white,
  )
  let sub = "ESC - Resume | Q - Quit to Menu"
  let sw2 = @raylib.measure_text(sub, 20)
  @raylib.draw_text(
    sub,
    (@types.screen_width - sw2) / 2,
    @types.screen_height / 2 + 20,
    20,
    @raylib.Color::new(180, 180, 200, 255),
  )
}

///|
fn draw_game_over(game : @types.Game) -> Unit {
  let sw = @types.screen_width
  let sh = @types.screen_height
  let player = game.player
  // Check if it was a victory (survived all waves)
  let is_victory = game.current_wave >= @types.max_waves
  let bg_color = if is_victory {
    @raylib.Color::new(0, 30, 0, 220)
  } else {
    @raylib.Color::new(40, 0, 0, 220)
  }
  @raylib.draw_rectangle(0, 0, sw, sh, bg_color)
  let title = if is_victory { "VICTORY!" } else { "GAME OVER" }
  let title_color = if is_victory {
    @raylib.Color::new(100, 255, 100, 255)
  } else {
    @raylib.Color::new(255, 80, 60, 255)
  }
  let tw = @raylib.measure_text(title, 60)
  @raylib.draw_text(title, (sw - tw) / 2, sh / 2 - 100, 60, title_color)
  // Stats
  let stats : Array[String] = [
    "Score: \{player.score}",
    "Kills: \{player.kills}",
    "Wave Reached: \{game.current_wave + 1}/\{@types.max_waves}",
    "Gold Earned: \{player.money + player.score}",
  ]
  for i = 0; i < stats.length(); i = i + 1 {
    let text = stats[i]
    let stw = @raylib.measure_text(text, 22)
    @raylib.draw_text(
      text,
      (sw - stw) / 2,
      sh / 2 - 20 + i * 30,
      22,
      @raylib.Color::new(200, 200, 220, 255),
    )
  }
  let restart_text = "Press ENTER or SPACE to return to Menu"
  let rw = @raylib.measure_text(restart_text, 18)
  @raylib.draw_text(
    restart_text,
    (sw - rw) / 2,
    sh / 2 + 120,
    18,
    @raylib.Color::new(180, 180, 200, 255),
  )
}
