// UI rendering: HUD, menus, crosshair, inventory, crafting, game over

///|
pub fn draw_ui(game : @types.Game) -> Unit {
  if game.state == @types.state_menu {
    draw_menu(game)
  } else if game.state == @types.state_playing {
    draw_hud(game)
    draw_crosshair()
    draw_health_hunger_bars(game)
    draw_air_bar(game)
    if game.show_debug {
      draw_debug_info(game)
    }
  } else if game.state == @types.state_paused {
    draw_hud(game)
    draw_crosshair()
    draw_health_hunger_bars(game)
    draw_pause_overlay(game)
  } else if game.state == @types.state_inventory {
    draw_hud(game)
    draw_health_hunger_bars(game)
    draw_inventory_screen(game)
  } else if game.state == @types.state_crafting {
    draw_hud(game)
    draw_health_hunger_bars(game)
    draw_crafting_screen(game)
  } else if game.state == @types.state_game_over {
    draw_game_over_screen(game)
  }
  // Biome name display
  if game.state == @types.state_playing {
    draw_biome_indicator(game)
    draw_compass(game)
    draw_tool_durability(game)
    draw_event_log(game)
  }
  // Damage flash overlay
  if game.player.damage_flash > 0.0 {
    let alpha = (game.player.damage_flash * 120.0).to_int()
    let clamped = @types.clampi(alpha, 0, 120)
    @raylib.draw_rectangle(
      0,
      0,
      @types.screen_width,
      @types.screen_height,
      @raylib.Color::new(255, 0, 0, clamped),
    )
  }
  // Underwater overlay
  if game.player.underwater {
    @raylib.draw_rectangle(
      0,
      0,
      @types.screen_width,
      @types.screen_height,
      @raylib.Color::new(30, 80, 180, 80),
    )
  }
}

// ========== Main menu ==========

///|
fn draw_menu(game : @types.Game) -> Unit {
  // Background gradient
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height / 2,
    @raylib.Color::new(30, 80, 50, 255),
  )
  @raylib.draw_rectangle(
    0,
    @types.screen_height / 2,
    @types.screen_width,
    @types.screen_height / 2,
    @raylib.Color::new(20, 50, 30, 255),
  )
  // Title
  let title = "VOXEL WORLD 3D"
  let tw = @raylib.measure_text(title, 52)
  // Shadow (drawn first, behind the title)
  @raylib.draw_text(
    title,
    (@types.screen_width - tw) / 2 + 2,
    102,
    52,
    @raylib.Color::new(20, 60, 20, 255),
  )
  // Main title text (drawn on top of shadow)
  @raylib.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    100,
    52,
    @raylib.Color::new(100, 220, 100, 255),
  )
  // Subtitle
  let sub = "A Minecraft-lite Sandbox Adventure"
  let sw = @raylib.measure_text(sub, 22)
  @raylib.draw_text(
    sub,
    (@types.screen_width - sw) / 2,
    165,
    22,
    @raylib.Color::new(180, 220, 180, 255),
  )
  // Version
  let ver = "v2.0 - MoonBit Edition"
  let vw = @raylib.measure_text(ver, 16)
  @raylib.draw_text(
    ver,
    (@types.screen_width - vw) / 2,
    195,
    16,
    @raylib.Color::new(120, 160, 120, 255),
  )
  // Feature list
  let features : Array[String] = [
    "6 Biomes: Plains, Forest, Desert, Mountains, Tundra, Swamp", "24 Block Types | Caves & Ores | Day/Night Cycle",
    "Mobs: Pigs, Cows, Chickens, Zombies, Skeletons, Spiders", "Mining System | Inventory | Crafting | Health & Hunger",
  ]
  for i in 0..<features.length() {
    let fy = 240 + i * 24
    let fw = @raylib.measure_text(features[i], 16)
    @raylib.draw_text(
      features[i],
      (@types.screen_width - fw) / 2,
      fy,
      16,
      @raylib.Color::new(140, 170, 140, 255),
    )
  }
  // Animated prompt
  let blink = @math.sinf(game.menu_blink * 2.0)
  let alpha = if blink > 0.0 { 255 } else { 120 }
  let prompt = "Press ENTER or SPACE to Play"
  let pw = @raylib.measure_text(prompt, 28)
  @raylib.draw_text(
    prompt,
    (@types.screen_width - pw) / 2,
    370,
    28,
    @raylib.Color::new(255, 255, 100, alpha),
  )
  // Controls info
  let controls : Array[String] = [
    "WASD - Move   |   Mouse - Look   |   Space - Jump", "LMB/Hold - Mine   |   RMB - Place   |   1-9 - Hotbar",
    "E - Inventory   |   C - Craft   |   Shift - Sprint", "Esc - Pause   |   F3 - Debug Info   |   Scroll - Cycle Items",
  ]
  for i in 0..<controls.length() {
    let cy = 430 + i * 26
    let cw = @raylib.measure_text(controls[i], 17)
    @raylib.draw_text(
      controls[i],
      (@types.screen_width - cw) / 2,
      cy,
      17,
      @raylib.Color::new(160, 180, 160, 255),
    )
  }
  // Credits
  let credits = "Built with MoonBit + raylib"
  let crw = @raylib.measure_text(credits, 14)
  @raylib.draw_text(
    credits,
    (@types.screen_width - crw) / 2,
    @types.screen_height - 30,
    14,
    @raylib.Color::new(100, 120, 100, 200),
  )
}

// ========== HUD ==========

///|
fn draw_hud(game : @types.Game) -> Unit {
  // Top bar background
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    32,
    @raylib.Color::new(0, 0, 0, 140),
  )
  // Selected block name
  let sel = game.player.inventory.selected
  let slot = game.player.inventory.slots[sel]
  let block_text : String = if slot.count > 0 {
    "\{@types.block_name(slot.item_id)} x\{slot.count}"
  } else {
    "Empty"
  }
  @raylib.draw_text(
    block_text,
    10,
    6,
    20,
    @raylib.Color::new(200, 220, 200, 255),
  )
  // FPS
  let fps = @raylib.get_fps()
  let fps_text = "FPS: \{fps}"
  let fps_w = @raylib.measure_text(fps_text, 18)
  @raylib.draw_text(
    fps_text,
    @types.screen_width - fps_w - 10,
    6,
    18,
    @raylib.Color::new(200, 200, 200, 255),
  )
  // Day/night indicator
  let time_pct = game.day_timer / @types.day_length * 100.0
  let time_text : String = if game.is_night { "Night" } else { "Day" }
  let day_text = "Day \{game.day_count} - \{time_text} (\{time_pct.to_int()}%)"
  let dw = @raylib.measure_text(day_text, 16)
  @raylib.draw_text(
    day_text,
    (@types.screen_width - dw) / 2,
    8,
    16,
    @raylib.Color::new(180, 180, 200, 255),
  )
  // Hotbar at bottom
  draw_hotbar(game)
  // Message
  if game.message_timer > 0.0 {
    let msg_alpha : Int = if game.message_timer < 1.0 {
      (game.message_timer * 255.0).to_int()
    } else {
      255
    }
    let msg_w = @raylib.measure_text(game.message_text, 20)
    // Background for message
    @raylib.draw_rectangle(
      (@types.screen_width - msg_w) / 2 - 8,
      @types.screen_height / 2 + 52,
      msg_w + 16,
      28,
      @raylib.Color::new(0, 0, 0, @types.clampi(msg_alpha / 2, 0, 140)),
    )
    @raylib.draw_text(
      game.message_text,
      (@types.screen_width - msg_w) / 2,
      @types.screen_height / 2 + 56,
      20,
      @raylib.Color::new(255, 255, 200, @types.clampi(msg_alpha, 0, 255)),
    )
  }
}

// ========== Hotbar ==========

///|
fn draw_hotbar(game : @types.Game) -> Unit {
  let slot_size = 48
  let slot_gap = 4
  let total_slots = @types.hotbar_slots
  let total_width = total_slots * slot_size + (total_slots - 1) * slot_gap
  let start_x = (@types.screen_width - total_width) / 2
  let start_y = @types.screen_height - slot_size - 10
  // Background
  @raylib.draw_rectangle(
    start_x - 4,
    start_y - 4,
    total_width + 8,
    slot_size + 8,
    @raylib.Color::new(0, 0, 0, 160),
  )
  for i in 0..<total_slots {
    let sx = start_x + i * (slot_size + slot_gap)
    let is_selected = game.player.inventory.selected == i
    let slot = game.player.inventory.slots[i]
    // Slot background
    let bg_color = if is_selected {
      @raylib.Color::new(255, 255, 255, 180)
    } else {
      @raylib.Color::new(60, 60, 60, 180)
    }
    @raylib.draw_rectangle(sx, start_y, slot_size, slot_size, bg_color)
    // Block color preview if slot has items
    if slot.count > 0 {
      let r = @levels.block_color_r(slot.item_id)
      let g = @levels.block_color_g(slot.item_id)
      let b = @levels.block_color_b(slot.item_id)
      @raylib.draw_rectangle(
        sx + 8,
        start_y + 8,
        slot_size - 16,
        slot_size - 16,
        @raylib.Color::new(r, g, b, 255),
      )
      // Darker border for 3D effect on icon
      @raylib.draw_rectangle(
        sx + 8,
        start_y + slot_size - 12,
        slot_size - 16,
        4,
        @raylib.Color::new(r * 2 / 3, g * 2 / 3, b * 2 / 3, 255),
      )
      // Count
      if slot.count > 1 {
        let count_text = "\{slot.count}"
        let count_w = @raylib.measure_text(count_text, 12)
        @raylib.draw_text(
          count_text,
          sx + slot_size - count_w - 4,
          start_y + slot_size - 16,
          12,
          @raylib.Color::new(255, 255, 255, 255),
        )
      }
    }
    // Slot number
    let num_text = "\{i + 1}"
    @raylib.draw_text(
      num_text,
      sx + 2,
      start_y + 2,
      12,
      @raylib.Color::new(200, 200, 200, 200),
    )
    // Selection highlight border
    if is_selected {
      @raylib.draw_rectangle_lines(
        sx - 1,
        start_y - 1,
        slot_size + 2,
        slot_size + 2,
        @raylib.Color::new(255, 255, 0, 255),
      )
      @raylib.draw_rectangle_lines(
        sx,
        start_y,
        slot_size,
        slot_size,
        @raylib.Color::new(255, 255, 0, 255),
      )
    }
  }
}

// ========== Crosshair ==========

///|
fn draw_crosshair() -> Unit {
  let cx = @types.screen_width / 2
  let cy = @types.screen_height / 2
  let size = 12
  let thickness = 2
  let color = @raylib.Color::new(255, 255, 255, 200)
  // Horizontal line
  @raylib.draw_rectangle(
    cx - size,
    cy - thickness / 2,
    size * 2,
    thickness,
    color,
  )
  // Vertical line
  @raylib.draw_rectangle(
    cx - thickness / 2,
    cy - size,
    thickness,
    size * 2,
    color,
  )
  // Center dot
  @raylib.draw_rectangle(
    cx - 1,
    cy - 1,
    2,
    2,
    @raylib.Color::new(255, 255, 0, 255),
  )
}

// ========== Health & Hunger bars ==========

///|
fn draw_health_hunger_bars(game : @types.Game) -> Unit {
  let player = game.player
  let bar_width = 200
  let bar_height = 14
  let start_y = @types.screen_height - 78

  // Health bar
  let health_x = @types.screen_width / 2 - bar_width - 20
  // Background
  @raylib.draw_rectangle(
    health_x - 1,
    start_y - 1,
    bar_width + 2,
    bar_height + 2,
    @raylib.Color::new(0, 0, 0, 180),
  )
  // Health amount
  let health_pct = Float::from_int(player.health) /
    Float::from_int(@types.player_max_health)
  let health_fill = (Float::from_int(bar_width) * health_pct).to_int()
  let hr : Int = if health_pct > 0.5 {
    @types.lerpi(255, 0, (health_pct - 0.5) * 2.0)
  } else {
    255
  }
  let hg : Int = if health_pct > 0.5 {
    200
  } else {
    @types.lerpi(0, 200, health_pct * 2.0)
  }
  @raylib.draw_rectangle(
    health_x,
    start_y,
    health_fill,
    bar_height,
    @raylib.Color::new(hr, hg, 0, 255),
  )
  // Health text
  let health_text = "HP: \{player.health}/\{@types.player_max_health}"
  @raylib.draw_text(
    health_text,
    health_x + 4,
    start_y + 1,
    12,
    @raylib.Color::new(255, 255, 255, 255),
  )
  // Heart icon placeholder
  @raylib.draw_text(
    "+",
    health_x - 16,
    start_y,
    16,
    @raylib.Color::new(255, 50, 50, 255),
  )

  // Hunger bar
  let hunger_x = @types.screen_width / 2 + 20
  @raylib.draw_rectangle(
    hunger_x - 1,
    start_y - 1,
    bar_width + 2,
    bar_height + 2,
    @raylib.Color::new(0, 0, 0, 180),
  )
  let hunger_pct = Float::from_int(player.hunger) /
    Float::from_int(@types.player_max_hunger)
  let hunger_fill = (Float::from_int(bar_width) * hunger_pct).to_int()
  let hunger_r : Int = if hunger_pct < 0.3 { 200 } else { 180 }
  let hunger_g : Int = if hunger_pct < 0.3 { 100 } else { 130 }
  let hunger_b : Int = if hunger_pct < 0.3 { 30 } else { 50 }
  @raylib.draw_rectangle(
    hunger_x,
    start_y,
    hunger_fill,
    bar_height,
    @raylib.Color::new(hunger_r, hunger_g, hunger_b, 255),
  )
  let hunger_text = "Food: \{player.hunger}/\{@types.player_max_hunger}"
  @raylib.draw_text(
    hunger_text,
    hunger_x + 4,
    start_y + 1,
    12,
    @raylib.Color::new(255, 255, 255, 255),
  )
  // Drumstick icon placeholder
  @raylib.draw_text(
    "~",
    hunger_x + bar_width + 4,
    start_y,
    16,
    @raylib.Color::new(180, 130, 50, 255),
  )

  // Mining progress bar (below crosshair)
  if player.mining_active {
    let mine_bar_w = 120
    let mine_bar_h = 6
    let mine_x = @types.screen_width / 2 - mine_bar_w / 2
    let mine_y = @types.screen_height / 2 + 25
    @raylib.draw_rectangle(
      mine_x - 1,
      mine_y - 1,
      mine_bar_w + 2,
      mine_bar_h + 2,
      @raylib.Color::new(0, 0, 0, 150),
    )
    let fill = (Float::from_int(mine_bar_w) * player.mining_progress).to_int()
    @raylib.draw_rectangle(
      mine_x,
      mine_y,
      fill,
      mine_bar_h,
      @raylib.Color::new(255, 200, 50, 255),
    )
  }
}

// ========== Air bar (when underwater) ==========

///|
fn draw_air_bar(game : @types.Game) -> Unit {
  if not(game.player.underwater) {
    return
  }
  let bar_width = 150
  let bar_height = 10
  let air_x = @types.screen_width / 2 - bar_width / 2
  let air_y = @types.screen_height / 2 + 40
  @raylib.draw_rectangle(
    air_x - 1,
    air_y - 1,
    bar_width + 2,
    bar_height + 2,
    @raylib.Color::new(0, 0, 0, 150),
  )
  let air_pct = Float::from_int(game.player.air) /
    Float::from_int(@types.player_max_air)
  let fill = (Float::from_int(bar_width) * air_pct).to_int()
  @raylib.draw_rectangle(
    air_x,
    air_y,
    fill,
    bar_height,
    @raylib.Color::new(50, 150, 255, 255),
  )
  let air_text = "Air"
  @raylib.draw_text(
    air_text,
    air_x + bar_width / 2 - 10,
    air_y - 1,
    10,
    @raylib.Color::new(255, 255, 255, 220),
  )
}

// ========== Debug info ==========

///|
fn draw_debug_info(game : @types.Game) -> Unit {
  let player = game.player
  let x = 10
  let mut y = 40
  let line_h = 18
  let bg_w = 320
  let line_count = 12
  @raylib.draw_rectangle(
    x - 4,
    y - 4,
    bg_w,
    line_count * line_h + 8,
    @raylib.Color::new(0, 0, 0, 160),
  )
  let color = @raylib.Color::new(200, 220, 200, 255)
  let pos_text = "Pos: \{player.x.to_int()}, \{player.y.to_int()}, \{player.z.to_int()}"
  @raylib.draw_text(pos_text, x, y, 15, color)
  y += line_h
  let chunk_cx = player.x.to_int() / @types.chunk_x
  let chunk_cz = player.z.to_int() / @types.chunk_z
  let chunk_text = "Chunk: \{chunk_cx}, \{chunk_cz}"
  @raylib.draw_text(chunk_text, x, y, 15, color)
  y += line_h
  let facing = @types.facing_direction(player.yaw)
  let facing_text = "Facing: \{facing}"
  @raylib.draw_text(facing_text, x, y, 15, color)
  y += line_h
  let biome = @types.get_biome_at(player.x.to_int(), player.z.to_int())
  let biome_text = "Biome: \{@types.biome_name(biome)}"
  @raylib.draw_text(biome_text, x, y, 15, color)
  y += line_h
  let vel_text = "Vel: \{player.vx.to_int()}, \{player.vy.to_int()}, \{player.vz.to_int()}"
  @raylib.draw_text(vel_text, x, y, 15, color)
  y += line_h
  let ground_text : String = if player.on_ground {
    "On Ground: Yes"
  } else {
    "On Ground: No"
  }
  @raylib.draw_text(ground_text, x, y, 15, color)
  y += line_h
  let tool_text = "Tool: \{@types.tool_name(player.equipped_tool)}"
  @raylib.draw_text(tool_text, x, y, 15, color)
  y += line_h
  // Target block info
  if game.target.hit {
    let tblock = @types.get_world_block(
      game,
      game.target.bx,
      game.target.by,
      game.target.bz,
    )
    let target_text = "Target: \{@types.block_name(tblock)} at \{game.target.bx},\{game.target.by},\{game.target.bz}"
    @raylib.draw_text(target_text, x, y, 15, color)
  } else {
    @raylib.draw_text("Target: None", x, y, 15, color)
  }
  y += line_h
  // Entity count
  let mut ent_count = 0
  for i in 0..<@types.entity_max {
    if game.entities[i].active {
      ent_count += 1
    }
  }
  let ent_text = "Entities: \{ent_count}/\{@types.entity_max}"
  @raylib.draw_text(ent_text, x, y, 15, color)
  y += line_h
  let stat_text = "Broken: \{game.blocks_broken} | Placed: \{game.blocks_placed} | Kills: \{game.mobs_killed}"
  @raylib.draw_text(stat_text, x, y, 15, color)
  y += line_h
  let dist_text = "Distance: \{game.distance_walked.to_int()}m"
  @raylib.draw_text(dist_text, x, y, 15, color)
  y += line_h
  let night_text : String = if game.is_night {
    "Night time"
  } else {
    "Day time"
  }
  let time_text = "\{night_text} | Day \{game.day_count}"
  @raylib.draw_text(time_text, x, y, 15, color)
}

// ========== Pause screen ==========

///|
fn draw_pause_overlay(game : @types.Game) -> Unit {
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
    @types.screen_height / 2 - 80,
    60,
    @raylib.Color::new(255, 255, 255, 255),
  )
  // Stats summary
  let stats : Array[String] = [
    "Day \{game.day_count}  |  Blocks Broken: \{game.blocks_broken}  |  Blocks Placed: \{game.blocks_placed}",
    "Mobs Killed: \{game.mobs_killed}  |  Distance: \{game.distance_walked.to_int()}m",
    "Health: \{game.player.health}/\{@types.player_max_health}  |  Hunger: \{game.player.hunger}/\{@types.player_max_hunger}",
  ]
  for i in 0..<stats.length() {
    let sy = @types.screen_height / 2 - 10 + i * 22
    let sw = @raylib.measure_text(stats[i], 16)
    @raylib.draw_text(
      stats[i],
      (@types.screen_width - sw) / 2,
      sy,
      16,
      @raylib.Color::new(180, 200, 180, 255),
    )
  }
  let hint = "Esc/P: Resume  |  Q: Quit to Menu"
  let hw = @raylib.measure_text(hint, 20)
  @raylib.draw_text(
    hint,
    (@types.screen_width - hw) / 2,
    @types.screen_height / 2 + 70,
    20,
    @raylib.Color::new(200, 200, 220, 255),
  )
}

// ========== Inventory screen ==========

///|
fn draw_inventory_screen(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(0, 0, 0, 190),
  )
  let title = "INVENTORY"
  let tw = @raylib.measure_text(title, 30)
  @raylib.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    50,
    30,
    @raylib.Color::new(255, 255, 255, 255),
  )
  let hint = "1-9: Select Hotbar | E/Esc: Close"
  let hw = @raylib.measure_text(hint, 16)
  @raylib.draw_text(
    hint,
    (@types.screen_width - hw) / 2,
    85,
    16,
    @raylib.Color::new(180, 180, 180, 255),
  )
  // Draw inventory grid
  let slot_size = 52
  let gap = 6
  let cols = @types.inventory_cols
  let rows = @types.inventory_rows
  let grid_width = cols * slot_size + (cols - 1) * gap
  let grid_start_x = (@types.screen_width - grid_width) / 2
  let grid_start_y = 120
  // Background panel
  @raylib.draw_rectangle(
    grid_start_x - 12,
    grid_start_y - 12,
    grid_width + 24,
    rows * (slot_size + gap) + 24,
    @raylib.Color::new(40, 40, 40, 220),
  )
  @raylib.draw_rectangle_lines(
    grid_start_x - 12,
    grid_start_y - 12,
    grid_width + 24,
    rows * (slot_size + gap) + 24,
    @raylib.Color::new(100, 100, 100, 255),
  )
  for row in 0..<rows {
    for col in 0..<cols {
      let idx = row * cols + col
      if idx >= @types.inventory_slots {
        continue
      }
      let sx = grid_start_x + col * (slot_size + gap)
      let sy = grid_start_y + row * (slot_size + gap)
      let slot = game.player.inventory.slots[idx]
      let is_selected = idx == game.player.inventory.selected
      // Slot background
      let bg = if is_selected {
        @raylib.Color::new(120, 120, 80, 230)
      } else if row == 0 {
        @raylib.Color::new(60, 60, 70, 220)
      } else {
        @raylib.Color::new(45, 45, 50, 220)
      }
      @raylib.draw_rectangle(sx, sy, slot_size, slot_size, bg)
      // Item
      if slot.count > 0 {
        let r = @levels.block_color_r(slot.item_id)
        let g = @levels.block_color_g(slot.item_id)
        let b = @levels.block_color_b(slot.item_id)
        // 3D-ish block icon
        @raylib.draw_rectangle(
          sx + 10,
          sy + 8,
          slot_size - 20,
          slot_size - 20,
          @raylib.Color::new(r, g, b, 255),
        )
        // Dark bottom edge
        @raylib.draw_rectangle(
          sx + 10,
          sy + slot_size - 16,
          slot_size - 20,
          4,
          @raylib.Color::new(r * 3 / 5, g * 3 / 5, b * 3 / 5, 255),
        )
        // Light top edge
        @raylib.draw_rectangle(
          sx + 10,
          sy + 8,
          slot_size - 20,
          3,
          @raylib.Color::new(
            @types.mini(r + 30, 255),
            @types.mini(g + 30, 255),
            @types.mini(b + 30, 255),
            200,
          ),
        )
        // Count
        if slot.count > 1 {
          let cnt_text = "\{slot.count}"
          let cnt_w = @raylib.measure_text(cnt_text, 12)
          @raylib.draw_text(
            cnt_text,
            sx + slot_size - cnt_w - 3,
            sy + slot_size - 15,
            12,
            @raylib.Color::new(255, 255, 255, 255),
          )
        }
        // Item name on hover/select
        if is_selected {
          let name = @types.block_name(slot.item_id)
          let nw = @raylib.measure_text(name, 14)
          @raylib.draw_rectangle(
            sx + (slot_size - nw) / 2 - 4,
            sy - 18,
            nw + 8,
            18,
            @raylib.Color::new(0, 0, 0, 200),
          )
          @raylib.draw_text(
            name,
            sx + (slot_size - nw) / 2,
            sy - 16,
            14,
            @raylib.Color::new(255, 255, 200, 255),
          )
        }
      }
      // Selection border
      if is_selected {
        @raylib.draw_rectangle_lines(
          sx - 1,
          sy - 1,
          slot_size + 2,
          slot_size + 2,
          @raylib.Color::new(255, 255, 0, 255),
        )
      }
      // Row label for hotbar row
      if row == 0 {
        let key_text = "\{col + 1}"
        @raylib.draw_text(
          key_text,
          sx + 2,
          sy + 2,
          10,
          @raylib.Color::new(200, 200, 100, 180),
        )
      }
    }
  }
  // Label for hotbar row
  let hotbar_label = "Hotbar"
  @raylib.draw_text(
    hotbar_label,
    grid_start_x - 12,
    grid_start_y + slot_size / 2 - 6,
    14,
    @raylib.Color::new(200, 200, 100, 200),
  )
}

// ========== Crafting screen ==========

///|
fn draw_crafting_screen(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(0, 0, 0, 190),
  )
  let title = "CRAFTING"
  let tw = @raylib.measure_text(title, 30)
  @raylib.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    40,
    30,
    @raylib.Color::new(255, 255, 255, 255),
  )
  let hint = "W/S: Navigate | Enter/Space: Craft | C/Esc: Close"
  let hw = @raylib.measure_text(hint, 16)
  @raylib.draw_text(
    hint,
    (@types.screen_width - hw) / 2,
    75,
    16,
    @raylib.Color::new(180, 180, 180, 255),
  )
  let recipes = @levels.get_crafting_recipes()
  let recipe_height = 50
  let panel_width = 500
  let panel_x = (@types.screen_width - panel_width) / 2
  let panel_y = 110
  // Background panel
  @raylib.draw_rectangle(
    panel_x - 10,
    panel_y - 10,
    panel_width + 20,
    recipes.length() * recipe_height + 20,
    @raylib.Color::new(40, 40, 40, 220),
  )
  @raylib.draw_rectangle_lines(
    panel_x - 10,
    panel_y - 10,
    panel_width + 20,
    recipes.length() * recipe_height + 20,
    @raylib.Color::new(100, 100, 100, 255),
  )
  for i in 0..<recipes.length() {
    let recipe = recipes[i]
    let ry = panel_y + i * recipe_height
    let is_selected = game.crafting_selection == i
    // Background
    let bg = if is_selected {
      @raylib.Color::new(80, 80, 60, 230)
    } else {
      @raylib.Color::new(50, 50, 50, 200)
    }
    @raylib.draw_rectangle(panel_x, ry, panel_width, recipe_height - 4, bg)
    // Check if player can craft this
    let can_craft = check_can_craft(game, recipe)
    let text_color = if can_craft {
      @raylib.Color::new(200, 255, 200, 255)
    } else {
      @raylib.Color::new(150, 100, 100, 200)
    }
    // Recipe name
    @raylib.draw_text(recipe.name, panel_x + 10, ry + 6, 18, text_color)
    // Input display
    let mut input_text = "Needs: \{@types.block_name(recipe.input1_id)} x\{recipe.input1_count}"
    if recipe.input2_id > 0 {
      input_text = "\{input_text} + \{@types.block_name(recipe.input2_id)} x\{recipe.input2_count}"
    }
    @raylib.draw_text(
      input_text,
      panel_x + 10,
      ry + 26,
      13,
      @raylib.Color::new(160, 160, 160, 220),
    )
    // Output display
    let output_text = "=> \{@types.block_name(recipe.output_id)} x\{recipe.output_count}"
    let ow = @raylib.measure_text(output_text, 14)
    @raylib.draw_text(
      output_text,
      panel_x + panel_width - ow - 10,
      ry + 14,
      14,
      @raylib.Color::new(255, 255, 100, 255),
    )
    // Input color swatch
    let ir = @levels.block_color_r(recipe.input1_id)
    let ig = @levels.block_color_g(recipe.input1_id)
    let ib = @levels.block_color_b(recipe.input1_id)
    @raylib.draw_rectangle(
      panel_x + panel_width - 60,
      ry + 6,
      14,
      14,
      @raylib.Color::new(ir, ig, ib, 255),
    )
    // Output color swatch
    let or_ = @levels.block_color_r(recipe.output_id)
    let og = @levels.block_color_g(recipe.output_id)
    let ob = @levels.block_color_b(recipe.output_id)
    @raylib.draw_rectangle(
      panel_x + panel_width - 40,
      ry + 6,
      14,
      14,
      @raylib.Color::new(or_, og, ob, 255),
    )
    // Selection indicator
    if is_selected {
      @raylib.draw_rectangle_lines(
        panel_x - 2,
        ry - 2,
        panel_width + 4,
        recipe_height,
        @raylib.Color::new(255, 255, 0, 255),
      )
      // Arrow indicator
      @raylib.draw_text(
        ">",
        panel_x - 20,
        ry + 12,
        24,
        @raylib.Color::new(255, 255, 0, 255),
      )
    }
  }
}

///|
fn check_can_craft(game : @types.Game, recipe : @types.CraftingRecipe) -> Bool {
  let inv = game.player.inventory
  let mut has1 = false
  let mut has2 = false
  if recipe.input1_id > 0 && recipe.input1_count > 0 {
    for i in 0..<@types.inventory_slots {
      if inv.slots[i].item_id == recipe.input1_id &&
        inv.slots[i].count >= recipe.input1_count {
        has1 = true
      }
    }
  } else {
    has1 = true
  }
  if recipe.input2_id > 0 && recipe.input2_count > 0 {
    for i in 0..<@types.inventory_slots {
      if inv.slots[i].item_id == recipe.input2_id &&
        inv.slots[i].count >= recipe.input2_count {
        has2 = true
      }
    }
  } else {
    has2 = true
  }
  has1 && has2
}

// ========== Game over screen ==========

///|
fn draw_game_over_screen(game : @types.Game) -> Unit {
  // Dark overlay
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.screen_height,
    @raylib.Color::new(80, 0, 0, 200),
  )
  // Title
  let title = "YOU DIED"
  let tw = @raylib.measure_text(title, 64)
  // Fade in
  let alpha : Int = @types.mini((game.death_timer * 200.0).to_int(), 255)
  @raylib.draw_text(
    title,
    (@types.screen_width - tw) / 2,
    @types.screen_height / 2 - 100,
    64,
    @raylib.Color::new(255, 50, 50, @types.clampi(alpha, 0, 255)),
  )
  // Stats
  if game.death_timer > 0.5 {
    let stats : Array[String] = [
      "Survived \{game.day_count} days",
      "Blocks Broken: \{game.blocks_broken}",
      "Blocks Placed: \{game.blocks_placed}",
      "Mobs Killed: \{game.mobs_killed}",
      "Distance: \{game.distance_walked.to_int()}m",
    ]
    for i in 0..<stats.length() {
      let sy = @types.screen_height / 2 - 20 + i * 24
      let sw = @raylib.measure_text(stats[i], 18)
      @raylib.draw_text(
        stats[i],
        (@types.screen_width - sw) / 2,
        sy,
        18,
        @raylib.Color::new(220, 180, 180, 255),
      )
    }
  }
  if game.death_timer > 1.5 {
    let prompt = "Press ENTER to Respawn  |  Q to Quit"
    let pw = @raylib.measure_text(prompt, 22)
    @raylib.draw_text(
      prompt,
      (@types.screen_width - pw) / 2,
      @types.screen_height / 2 + 120,
      22,
      @raylib.Color::new(255, 255, 200, 255),
    )
  }
}

// ========== Biome name display ==========

///|
fn draw_biome_indicator(game : @types.Game) -> Unit {
  let player = game.player
  let biome = @types.get_biome_at(player.x.to_int(), player.z.to_int())
  let bname = @types.biome_name(biome)
  // Draw biome name in top-right area
  let text_x = @types.screen_width - 150
  let text_y = 36
  // Background
  let text_w = @raylib.measure_text(bname, 16)
  @raylib.draw_rectangle(
    text_x - 6,
    text_y - 2,
    text_w + 12,
    22,
    @raylib.Color::new(0, 0, 0, 120),
  )
  // Biome color indicator dot
  let dot_r : Int = if biome == @types.biome_plains {
    100
  } else if biome == @types.biome_forest {
    30
  } else if biome == @types.biome_desert {
    210
  } else if biome == @types.biome_mountains {
    140
  } else if biome == @types.biome_tundra {
    200
  } else if biome == @types.biome_swamp {
    60
  } else {
    150
  }
  let dot_g : Int = if biome == @types.biome_plains {
    180
  } else if biome == @types.biome_forest {
    120
  } else if biome == @types.biome_desert {
    180
  } else if biome == @types.biome_mountains {
    140
  } else if biome == @types.biome_tundra {
    220
  } else if biome == @types.biome_swamp {
    100
  } else {
    150
  }
  let dot_b : Int = if biome == @types.biome_plains {
    80
  } else if biome == @types.biome_forest {
    50
  } else if biome == @types.biome_desert {
    100
  } else if biome == @types.biome_mountains {
    160
  } else if biome == @types.biome_tundra {
    240
  } else if biome == @types.biome_swamp {
    70
  } else {
    150
  }
  @raylib.draw_rectangle(
    text_x - 14,
    text_y + 3,
    8,
    12,
    @raylib.Color::new(dot_r, dot_g, dot_b, 255),
  )
  @raylib.draw_text(
    bname,
    text_x,
    text_y,
    16,
    @raylib.Color::new(200, 220, 200, 220),
  )
}

// ========== Compass / direction indicator ==========

///|
fn draw_compass(game : @types.Game) -> Unit {
  let player = game.player
  let cx = @types.screen_width / 2
  let cy = 24
  let radius = 8
  // Draw compass background
  @raylib.draw_rectangle(
    cx - 50,
    cy - 10,
    100,
    20,
    @raylib.Color::new(0, 0, 0, 100),
  )
  // North indicator
  let yaw = player.yaw
  let n_offset = @math.sinf(yaw) * 40.0
  let n_x = cx + n_offset.to_int()
  // Draw N marker
  let n_alpha : Int = if @types.absf(n_offset) < 30.0 { 255 } else { 100 }
  @raylib.draw_text(
    "N",
    n_x - 4,
    cy - 8,
    14,
    @raylib.Color::new(255, 80, 80, n_alpha),
  )
  // South indicator
  let s_offset = @math.sinf(yaw + @types.pi) * 40.0
  let s_x = cx + s_offset.to_int()
  let s_alpha : Int = if @types.absf(s_offset) < 30.0 { 255 } else { 100 }
  @raylib.draw_text(
    "S",
    s_x - 4,
    cy - 8,
    14,
    @raylib.Color::new(200, 200, 200, s_alpha),
  )
  // East indicator
  let e_offset = @math.sinf(yaw + @types.pi * 0.5) * 40.0
  let e_x = cx + e_offset.to_int()
  let e_alpha : Int = if @types.absf(e_offset) < 30.0 { 200 } else { 80 }
  @raylib.draw_text(
    "E",
    e_x - 4,
    cy - 8,
    14,
    @raylib.Color::new(200, 200, 100, e_alpha),
  )
  // West indicator
  let w_offset = @math.sinf(yaw - @types.pi * 0.5) * 40.0
  let w_x = cx + w_offset.to_int()
  let w_alpha : Int = if @types.absf(w_offset) < 30.0 { 200 } else { 80 }
  @raylib.draw_text(
    "W",
    w_x - 4,
    cy - 8,
    14,
    @raylib.Color::new(200, 200, 100, w_alpha),
  )
  // Center tick mark
  @raylib.draw_rectangle(
    cx - 1,
    cy - 12,
    2,
    4,
    @raylib.Color::new(255, 255, 255, 200),
  )
  ignore(radius)
}

// ========== Tool durability display ==========

///|
fn draw_tool_durability(game : @types.Game) -> Unit {
  let player = game.player
  let tool = player.equipped_tool
  if tool == @types.tool_hand {
    return
  }
  // Show tool name and icon below hotbar
  let tname = @types.tool_name(tool)
  let bar_width = 80
  let bar_height = 6
  let bar_x = @types.screen_width / 2 - bar_width / 2
  let bar_y = @types.screen_height - 70
  // Tool name text
  let tw = @raylib.measure_text(tname, 14)
  @raylib.draw_text(
    tname,
    @types.screen_width / 2 - tw / 2,
    bar_y - 16,
    14,
    @raylib.Color::new(220, 200, 150, 220),
  )
  // Durability bar background
  @raylib.draw_rectangle(
    bar_x - 1,
    bar_y - 1,
    bar_width + 2,
    bar_height + 2,
    @raylib.Color::new(0, 0, 0, 150),
  )
  // Durability fill (simplified: always full since we don't track per-use yet)
  let dur_pct : Float = 0.8 // Placeholder durability
  let fill = (Float::from_int(bar_width) * dur_pct).to_int()
  let dur_r : Int = if dur_pct > 0.5 { 50 } else { 220 }
  let dur_g : Int = if dur_pct > 0.5 { 200 } else { 80 }
  @raylib.draw_rectangle(
    bar_x,
    bar_y,
    fill,
    bar_height,
    @raylib.Color::new(dur_r, dur_g, 50, 255),
  )
  // Tool tier indicator
  let tier_text : String = if tool == @types.tool_wooden_pickaxe ||
    tool == @types.tool_wooden_axe ||
    tool == @types.tool_wooden_shovel ||
    tool == @types.tool_wooden_sword {
    "[Wood]"
  } else if tool == @types.tool_stone_pickaxe ||
    tool == @types.tool_stone_axe ||
    tool == @types.tool_stone_shovel ||
    tool == @types.tool_stone_sword {
    "[Stone]"
  } else if tool == @types.tool_iron_pickaxe ||
    tool == @types.tool_iron_axe ||
    tool == @types.tool_iron_shovel ||
    tool == @types.tool_iron_sword {
    "[Iron]"
  } else {
    ""
  }
  if tier_text.length() > 0 {
    let tier_w = @raylib.measure_text(tier_text, 10)
    @raylib.draw_text(
      tier_text,
      @types.screen_width / 2 - tier_w / 2,
      bar_y + bar_height + 2,
      10,
      @raylib.Color::new(180, 180, 140, 180),
    )
  }
}

// ========== Event log area ==========

///|
fn draw_event_log(game : @types.Game) -> Unit {
  // Show recent stats in bottom-left corner
  let log_x = 10
  let log_y = @types.screen_height - 140
  let line_h = 16
  // Background
  @raylib.draw_rectangle(
    log_x - 4,
    log_y - 4,
    200,
    line_h * 4 + 8,
    @raylib.Color::new(0, 0, 0, 80),
  )
  let log_color = @raylib.Color::new(160, 180, 160, 180)
  // Entity count
  let mut ent_count = 0
  for i in 0..<@types.entity_max {
    if game.entities[i].active {
      ent_count += 1
    }
  }
  let ent_text = "Mobs: \{ent_count}"
  @raylib.draw_text(ent_text, log_x, log_y, 13, log_color)
  let kills_text = "Kills: \{game.mobs_killed}"
  @raylib.draw_text(kills_text, log_x, log_y + line_h, 13, log_color)
  let blocks_text = "Mined: \{game.blocks_broken}"
  @raylib.draw_text(blocks_text, log_x, log_y + line_h * 2, 13, log_color)
  let placed_text = "Placed: \{game.blocks_placed}"
  @raylib.draw_text(placed_text, log_x, log_y + line_h * 3, 13, log_color)
}
