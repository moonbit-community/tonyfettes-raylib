///|
fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
fn clampf(v : Float, lo : Float, hi : Float) -> Float {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
fn sq(v : Float) -> Float {
  v * v
}

///|
fn rects_overlap(
  ax : Float,
  ay : Float,
  aw : Float,
  ah : Float,
  bx : Float,
  by : Float,
  bw : Float,
  bh : Float,
) -> Bool {
  ax < bx + bw && ax + aw > bx && ay < by + bh && ay + ah > by
}

///|
fn player_rect_at(
  game : Game,
  px : Float,
  py : Float,
) -> (Float, Float, Float, Float) {
  (
    px - game.player.w * 0.5,
    py - game.player.h * 0.5,
    game.player.w,
    game.player.h,
  )
}

///|
fn player_hits_rect(
  game : Game,
  x : Float,
  y : Float,
  w : Float,
  h : Float,
) -> Bool {
  let (px, py, pw, ph) = player_rect_at(game, game.player.x, game.player.y)
  rects_overlap(px, py, pw, ph, x, y, w, h)
}

///|
fn make_relic(x : Float, y : Float) -> Relic {
  { active: true, x, y, r: 13.0 }
}

///|
fn make_trap(
  x : Float,
  y : Float,
  w : Float,
  h : Float,
  cycle : Float,
  hot_window : Float,
  phase : Float,
  kind : Int,
  label : String,
) -> Trap {
  { x, y, w, h, cycle, hot_window, phase, kind, label, timer: 0.0 }
}

///|
fn make_hazard(
  x : Float,
  y : Float,
  w : Float,
  h : Float,
  kind : Int,
  label : String,
) -> Hazard {
  { x, y, w, h, kind, label }
}

///|
fn make_plate(x : Float, y : Float, w : Float, h : Float) -> Plate {
  { x, y, w, h, pressed: false }
}

///|
fn make_door(
  x : Float,
  y : Float,
  w : Float,
  h : Float,
  plate_index : Int,
  hold_time : Float,
) -> Door {
  { x, y, w, h, plate_index, hold_time, timer: 0.0, open: false }
}

///|
fn stage_layout_one() -> StageLayout {
  let relics : Array[Relic] = [
    make_relic(210.0, 220.0),
    make_relic(530.0, 650.0),
    make_relic(910.0, 430.0),
  ]

  let traps : Array[Trap] = [
    make_trap(
      170.0, 680.0, 130.0, 30.0, 2.2, 0.72, 0.10, trap_kind_spike, "Spikes burst from the floor.",
    ),
    make_trap(
      450.0, 350.0, 190.0, 30.0, 2.6, 0.92, 1.00, trap_kind_dart, "A dart launcher catches you mid-run.",
    ),
    make_trap(
      860.0, 380.0, 150.0, 30.0, 1.8, 0.62, 0.35, trap_kind_spike, "Ceiling spikes slam down.",
    ),
  ]

  let hazards : Array[Hazard] = [
    make_hazard(
      560.0, 230.0, 130.0, 110.0, hazard_kind_lava, "You slipped into a molten trench.",
    ),
    make_hazard(
      820.0, 650.0, 160.0, 110.0, hazard_kind_lava, "The sand gave way above magma.",
    ),
  ]

  let plates : Array[Plate] = [
    make_plate(120.0, 740.0, 102.0, 90.0),
    make_plate(472.0, 110.0, 102.0, 90.0),
  ]

  let doors : Array[Door] = [
    make_door(360.0, world_y, 28.0, world_h, 0, 0.62),
    make_door(700.0, world_y, 28.0, world_h, 1, 0.58),
  ]

  {
    start_x: 102.0,
    start_y: 800.0,
    exit_x: 934.0,
    exit_y: 110.0,
    exit_w: 88.0,
    exit_h: 120.0,
    relics,
    traps,
    hazards,
    plates,
    doors,
  }
}

///|
fn stage_layout_two() -> StageLayout {
  let relics : Array[Relic] = [
    make_relic(920.0, 150.0),
    make_relic(210.0, 470.0),
    make_relic(770.0, 500.0),
    make_relic(500.0, 760.0),
  ]

  let traps : Array[Trap] = [
    make_trap(
      420.0, 180.0, 190.0, 30.0, 2.0, 0.66, 0.18, trap_kind_dart, "Poison bolts flood the corridor.",
    ),
    make_trap(
      360.0, 430.0, 220.0, 30.0, 2.4, 0.82, 1.0, trap_kind_spike, "Rotating blades slice through the lane.",
    ),
    make_trap(
      820.0, 520.0, 130.0, 120.0, 3.0, 1.16, 0.22, trap_kind_spike, "A crusher chamber closes around you.",
    ),
    make_trap(
      220.0, 700.0, 180.0, 30.0, 1.7, 0.52, 0.55, trap_kind_dart, "Darts ricochet across the lower vault.",
    ),
  ]

  let hazards : Array[Hazard] = [
    make_hazard(
      120.0, 540.0, 130.0, 60.0, hazard_kind_lava, "Corrosive sludge dissolves your boots.",
    ),
    make_hazard(
      620.0, 680.0, 170.0, 120.0, hazard_kind_lava, "A lava vent erupts beneath you.",
    ),
  ]

  let plates : Array[Plate] = [
    make_plate(112.0, 120.0, 110.0, 90.0),
    make_plate(850.0, 440.0, 110.0, 90.0),
  ]

  let doors : Array[Door] = [
    make_door(world_x, 320.0, world_w, 28.0, 0, 0.66),
    make_door(world_x, 600.0, world_w, 28.0, 1, 0.58),
  ]

  {
    start_x: 110.0,
    start_y: 120.0,
    exit_x: 920.0,
    exit_y: 734.0,
    exit_w: 92.0,
    exit_h: 110.0,
    relics,
    traps,
    hazards,
    plates,
    doors,
  }
}

///|
fn stage_layout_three() -> StageLayout {
  let relics : Array[Relic] = [
    make_relic(190.0, 700.0),
    make_relic(450.0, 180.0),
    make_relic(430.0, 500.0),
    make_relic(660.0, 700.0),
    make_relic(920.0, 200.0),
  ]

  let traps : Array[Trap] = [
    make_trap(
      150.0, 300.0, 110.0, 30.0, 1.8, 0.70, 0.08, trap_kind_spike, "Stone spears erupt around you.",
    ),
    make_trap(
      350.0, 340.0, 140.0, 30.0, 2.2, 0.76, 0.48, trap_kind_dart, "A hidden slit fires a volley of darts.",
    ),
    make_trap(
      610.0, 450.0, 150.0, 30.0, 2.6, 1.0, 0.30, trap_kind_spike, "The pendulum blades sweep this platform.",
    ),
    make_trap(
      860.0, 520.0, 130.0, 30.0, 1.9, 0.65, 0.96, trap_kind_dart, "A crossfire trap catches your dash.",
    ),
  ]

  let hazards : Array[Hazard] = [
    make_hazard(
      360.0, 620.0, 120.0, 100.0, hazard_kind_lava, "Scalding oil floods the chamber.",
    ),
    make_hazard(
      620.0, 250.0, 130.0, 110.0, hazard_kind_lava, "You tumble into a fire pit.",
    ),
    make_hazard(
      890.0, 690.0, 120.0, 90.0, hazard_kind_lava, "The final vault floor collapses.",
    ),
  ]

  let plates : Array[Plate] = [
    make_plate(108.0, 120.0, 110.0, 90.0),
    make_plate(370.0, 740.0, 110.0, 90.0),
    make_plate(640.0, 120.0, 110.0, 90.0),
  ]

  let doors : Array[Door] = [
    make_door(280.0, world_y, 28.0, world_h, 0, 0.58),
    make_door(540.0, world_y, 28.0, world_h, 1, 0.58),
    make_door(800.0, world_y, 28.0, world_h, 2, 0.56),
  ]

  {
    start_x: 104.0,
    start_y: 450.0,
    exit_x: 930.0,
    exit_y: 430.0,
    exit_w: 90.0,
    exit_h: 110.0,
    relics,
    traps,
    hazards,
    plates,
    doors,
  }
}

///|
fn stage_layout(index : Int) -> StageLayout {
  match index {
    0 => stage_layout_one()
    1 => stage_layout_two()
    _ => stage_layout_three()
  }
}

///|
fn stage_name(index : Int) -> String {
  match index {
    0 => "Sunken Antechamber"
    1 => "Obsidian Gauntlet"
    _ => "Crown Vault"
  }
}

///|
fn set_banner(game : Game, text : String, ttl : Float) -> Unit {
  game.banner_text = text
  game.banner_t = ttl
}

///|
fn apply_layout(game : Game, layout : StageLayout, stage_index : Int) -> Unit {
  game.stage_index = stage_index
  game.relics = layout.relics
  game.traps = layout.traps
  game.hazards = layout.hazards
  game.plates = layout.plates
  game.doors = layout.doors
  game.required_relics = game.relics.length()
  game.collected_relics = 0
  game.exit_x = layout.exit_x
  game.exit_y = layout.exit_y
  game.exit_w = layout.exit_w
  game.exit_h = layout.exit_h
  game.stage_time = 0.0
  game.fail_reason = ""
  game.player.x = layout.start_x
  game.player.y = layout.start_y
  game.player.stamina = stamina_max
  game.player.dash_on = false
  game.state = state_play
  set_banner(game, "Relics power the exit seal", 2.2)
}

///|
fn load_stage(game : Game, stage_index : Int) -> Unit {
  let i : Int = if stage_index < 0 {
    0
  } else if stage_index >= game.stage_count {
    game.stage_count - 1
  } else {
    stage_index
  }

  let layout = stage_layout(i)
  apply_layout(game, layout, i)
}

///|
fn start_new_run(game : Game) -> Unit {
  load_stage(game, 0)
}

///|
fn retry_stage(game : Game) -> Unit {
  load_stage(game, game.stage_index)
}

///|
fn start_next_stage(game : Game) -> Unit {
  let next_index = game.stage_index + 1
  if next_index >= game.stage_count {
    game.state = state_victory
    set_banner(game, "Temple mastered", 2.6)
  } else {
    load_stage(game, next_index)
  }
}

///|
fn init_title_scene(game : Game) -> Unit {
  game.state = state_title
  game.stage_index = 0
  game.required_relics = 0
  game.collected_relics = 0
  game.exit_x = world_x + world_w - 100.0
  game.exit_y = world_y + 80.0
  game.exit_w = 80.0
  game.exit_h = 120.0
  game.stage_time = 0.0
  game.fail_reason = ""
  game.player.stamina = stamina_max
  game.player.dash_on = false
  set_banner(game, "Tap, dash, survive", 1.8)
}

///|
fn update_trap_timers(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.traps.length(); i = i + 1 {
    game.traps[i].timer = game.traps[i].timer + dt
    while game.traps[i].timer >= game.traps[i].cycle {
      game.traps[i].timer = game.traps[i].timer - game.traps[i].cycle
    }
  }
}

///|
fn trap_is_hot(trap : Trap) -> Bool {
  let mut t : Float = trap.timer + trap.phase
  while t >= trap.cycle {
    t = t - trap.cycle
  }
  t < trap.hot_window
}

///|
fn refresh_plates(game : Game) -> Unit {
  for i = 0; i < game.plates.length(); i = i + 1 {
    game.plates[i].pressed = player_hits_rect(
      game,
      game.plates[i].x,
      game.plates[i].y,
      game.plates[i].w,
      game.plates[i].h,
    )
  }
}

///|
fn refresh_doors(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.doors.length(); i = i + 1 {
    let plate_index = game.doors[i].plate_index
    let plate_pressed : Bool = if plate_index >= 0 &&
      plate_index < game.plates.length() {
      game.plates[plate_index].pressed
    } else {
      false
    }

    if plate_pressed {
      game.doors[i].timer = game.doors[i].hold_time
    } else {
      game.doors[i].timer = maxf(0.0, game.doors[i].timer - dt)
    }

    game.doors[i].open = game.doors[i].timer > 0.0

    // Prevent doors from sealing while the player is inside the doorway volume.
    if not(game.doors[i].open) &&
      player_hits_rect(
        game,
        game.doors[i].x,
        game.doors[i].y,
        game.doors[i].w,
        game.doors[i].h,
      ) {
      game.doors[i].open = true
    }
  }
}

///|
fn collides_closed_door(game : Game, x : Float, y : Float) -> Bool {
  let (px, py, pw, ph) = player_rect_at(game, x, y)

  for i = 0; i < game.doors.length(); i = i + 1 {
    if not(game.doors[i].open) &&
      rects_overlap(
        px,
        py,
        pw,
        ph,
        game.doors[i].x,
        game.doors[i].y,
        game.doors[i].w,
        game.doors[i].h,
      ) {
      return true
    }
  }

  false
}

///|
fn move_player(game : Game, dt : Float) -> Unit {
  let mut axis_x = clampf(game.input_x, -1.0, 1.0)
  let mut axis_y = clampf(game.input_y, -1.0, 1.0)

  if absf(axis_x) > 0.0 && absf(axis_y) > 0.0 {
    axis_x = axis_x * 0.707
    axis_y = axis_y * 0.707
  }

  let moving : Bool = absf(axis_x) + absf(axis_y) > 0.01

  let mut dash_now : Bool = false
  if game.input_dash_hold && moving && game.player.stamina > dash_min_stamina {
    dash_now = true
    game.player.stamina = maxf(
      0.0,
      game.player.stamina - stamina_drain_per_s * dt,
    )
  } else {
    game.player.stamina = minf(
      stamina_max,
      game.player.stamina + stamina_recover_per_s * dt,
    )
  }

  game.player.dash_on = dash_now

  let speed : Float = if dash_now {
    player_speed_dash
  } else {
    player_speed_walk
  }

  let dx : Float = axis_x * speed * dt
  let dy : Float = axis_y * speed * dt

  let half_w = game.player.w * 0.5
  let half_h = game.player.h * 0.5

  let nx = clampf(
    game.player.x + dx,
    world_x + half_w,
    world_x + world_w - half_w,
  )
  if not(collides_closed_door(game, nx, game.player.y)) {
    game.player.x = nx
  }

  let ny = clampf(
    game.player.y + dy,
    world_y + half_h,
    world_y + world_h - half_h,
  )
  if not(collides_closed_door(game, game.player.x, ny)) {
    game.player.y = ny
  }
}

///|
fn collect_relics(game : Game) -> Unit {
  for i = 0; i < game.relics.length(); i = i + 1 {
    if not(game.relics[i].active) {
      continue
    }

    let dx = game.player.x - game.relics[i].x
    let dy = game.player.y - game.relics[i].y
    let reach = game.relics[i].r + game.player.w * 0.36

    if sq(dx) + sq(dy) <= sq(reach) {
      game.relics[i].active = false
      game.collected_relics = game.collected_relics + 1
      game.player.stamina = minf(
        stamina_max,
        game.player.stamina + relic_stamina_bonus,
      )
      set_banner(game, "Relic secured", 0.9)
    }
  }
}

///|
fn fail_stage(game : Game, reason : String) -> Unit {
  if game.state != state_play {
    return
  }

  game.state = state_failed
  game.fail_reason = reason
  game.player.dash_on = false
  set_banner(game, "Run failed", 1.3)
}

///|
fn check_hazards(game : Game) -> Bool {
  for i = 0; i < game.hazards.length(); i = i + 1 {
    if player_hits_rect(
        game,
        game.hazards[i].x,
        game.hazards[i].y,
        game.hazards[i].w,
        game.hazards[i].h,
      ) {
      fail_stage(game, game.hazards[i].label)
      return true
    }
  }

  false
}

///|
fn check_traps(game : Game) -> Bool {
  for i = 0; i < game.traps.length(); i = i + 1 {
    if trap_is_hot(game.traps[i]) &&
      player_hits_rect(
        game,
        game.traps[i].x,
        game.traps[i].y,
        game.traps[i].w,
        game.traps[i].h,
      ) {
      fail_stage(game, game.traps[i].label)
      return true
    }
  }

  false
}

///|
fn exit_unlocked(game : Game) -> Bool {
  game.collected_relics >= game.required_relics
}

///|
fn reach_exit(game : Game) -> Unit {
  if not(
      player_hits_rect(game, game.exit_x, game.exit_y, game.exit_w, game.exit_h),
    ) {
    return
  }

  if not(exit_unlocked(game)) {
    if game.banner_t <= 0.0 {
      set_banner(game, "Exit sealed: collect every relic", 1.2)
    }
    return
  }

  if game.stage_index + 1 < game.stage_count {
    game.state = state_stage_clear
    set_banner(game, "Chamber cleared", 1.6)
  } else {
    game.state = state_victory
    set_banner(game, "Temple mastered", 2.6)
  }
}

///|
fn update_title_state(game : Game, _dt : Float) -> Unit {
  if game.input_start_press {
    start_new_run(game)
  }
}

///|
fn update_play_state(game : Game, dt : Float) -> Unit {
  if game.input_restart_press {
    retry_stage(game)
    return
  }

  game.stage_time = game.stage_time + dt

  update_trap_timers(game, dt)

  refresh_plates(game)
  refresh_doors(game, dt)

  move_player(game, dt)

  refresh_plates(game)
  refresh_doors(game, 0.0)

  collect_relics(game)

  if check_hazards(game) {
    return
  }

  if check_traps(game) {
    return
  }

  reach_exit(game)
}

///|
fn update_stage_clear_state(game : Game, _dt : Float) -> Unit {
  if game.input_restart_press {
    retry_stage(game)
  } else if game.input_next_press {
    start_next_stage(game)
  }
}

///|
fn update_failed_state(game : Game, _dt : Float) -> Unit {
  if game.input_restart_press {
    retry_stage(game)
  } else if game.input_next_press {
    init_title_scene(game)
  }
}

///|
fn update_victory_state(game : Game, _dt : Float) -> Unit {
  if game.input_next_press {
    start_new_run(game)
  } else if game.input_restart_press {
    init_title_scene(game)
  }
}

///|
fn update_game(game : Game, dt : Float) -> Unit {
  game.banner_t = maxf(0.0, game.banner_t - dt)

  if game.state == state_title {
    update_title_state(game, dt)
  } else if game.state == state_play {
    update_play_state(game, dt)
  } else if game.state == state_stage_clear {
    update_stage_clear_state(game, dt)
  } else if game.state == state_failed {
    update_failed_state(game, dt)
  } else {
    update_victory_state(game, dt)
  }
}
