///|
fn stage_layout_one() -> @types.StageLayout {
  let relics : Array[@types.Relic] = [
    @types.make_relic(210.0, 220.0),
    @types.make_relic(530.0, 650.0),
    @types.make_relic(910.0, 430.0),
  ]

  let traps : Array[@types.Trap] = [
    @types.make_trap(
      170.0, 680.0, 130.0, 30.0, 2.2, 0.72, 0.10, @types.trap_kind_spike,
      "Spikes burst from the floor.",
    ),
    @types.make_trap(
      450.0, 350.0, 190.0, 30.0, 2.6, 0.92, 1.00, @types.trap_kind_dart,
      "A dart launcher catches you mid-run.",
    ),
    @types.make_trap(
      860.0, 380.0, 150.0, 30.0, 1.8, 0.62, 0.35, @types.trap_kind_spike,
      "Ceiling spikes slam down.",
    ),
  ]

  let hazards : Array[@types.Hazard] = [
    @types.make_hazard(
      560.0, 230.0, 130.0, 110.0, @types.hazard_kind_lava,
      "You slipped into a molten trench.",
    ),
    @types.make_hazard(
      820.0, 650.0, 160.0, 110.0, @types.hazard_kind_lava,
      "The sand gave way above magma.",
    ),
  ]

  let plates : Array[@types.Plate] = [
    @types.make_plate(120.0, 740.0, 102.0, 90.0),
    @types.make_plate(472.0, 110.0, 102.0, 90.0),
  ]

  let doors : Array[@types.Door] = [
    @types.make_door(360.0, @types.world_y, 28.0, @types.world_h, 0, 0.62),
    @types.make_door(700.0, @types.world_y, 28.0, @types.world_h, 1, 0.58),
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
fn stage_layout_two() -> @types.StageLayout {
  let relics : Array[@types.Relic] = [
    @types.make_relic(920.0, 150.0),
    @types.make_relic(210.0, 470.0),
    @types.make_relic(770.0, 500.0),
    @types.make_relic(500.0, 760.0),
  ]

  let traps : Array[@types.Trap] = [
    @types.make_trap(
      420.0, 180.0, 190.0, 30.0, 2.0, 0.66, 0.18, @types.trap_kind_dart,
      "Poison bolts flood the corridor.",
    ),
    @types.make_trap(
      360.0, 430.0, 220.0, 30.0, 2.4, 0.82, 1.0, @types.trap_kind_spike,
      "Rotating blades slice through the lane.",
    ),
    @types.make_trap(
      820.0, 520.0, 130.0, 120.0, 3.0, 1.16, 0.22, @types.trap_kind_spike,
      "A crusher chamber closes around you.",
    ),
    @types.make_trap(
      220.0, 700.0, 180.0, 30.0, 1.7, 0.52, 0.55, @types.trap_kind_dart,
      "Darts ricochet across the lower vault.",
    ),
  ]

  let hazards : Array[@types.Hazard] = [
    @types.make_hazard(
      120.0, 540.0, 130.0, 60.0, @types.hazard_kind_lava,
      "Corrosive sludge dissolves your boots.",
    ),
    @types.make_hazard(
      620.0, 680.0, 170.0, 120.0, @types.hazard_kind_lava,
      "A lava vent erupts beneath you.",
    ),
  ]

  let plates : Array[@types.Plate] = [
    @types.make_plate(112.0, 120.0, 110.0, 90.0),
    @types.make_plate(850.0, 440.0, 110.0, 90.0),
  ]

  let doors : Array[@types.Door] = [
    @types.make_door(
      @types.world_x, 320.0, @types.world_w, 28.0, 0, 0.66,
    ),
    @types.make_door(
      @types.world_x, 600.0, @types.world_w, 28.0, 1, 0.58,
    ),
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
fn stage_layout_three() -> @types.StageLayout {
  let relics : Array[@types.Relic] = [
    @types.make_relic(190.0, 700.0),
    @types.make_relic(450.0, 180.0),
    @types.make_relic(430.0, 500.0),
    @types.make_relic(660.0, 700.0),
    @types.make_relic(920.0, 200.0),
  ]

  let traps : Array[@types.Trap] = [
    @types.make_trap(
      150.0, 300.0, 110.0, 30.0, 1.8, 0.70, 0.08, @types.trap_kind_spike,
      "Stone spears erupt around you.",
    ),
    @types.make_trap(
      350.0, 340.0, 140.0, 30.0, 2.2, 0.76, 0.48, @types.trap_kind_dart,
      "A hidden slit fires a volley of darts.",
    ),
    @types.make_trap(
      610.0, 450.0, 150.0, 30.0, 2.6, 1.0, 0.30, @types.trap_kind_spike,
      "The pendulum blades sweep this platform.",
    ),
    @types.make_trap(
      860.0, 520.0, 130.0, 30.0, 1.9, 0.65, 0.96, @types.trap_kind_dart,
      "A crossfire trap catches your dash.",
    ),
  ]

  let hazards : Array[@types.Hazard] = [
    @types.make_hazard(
      360.0, 620.0, 120.0, 100.0, @types.hazard_kind_lava,
      "Scalding oil floods the chamber.",
    ),
    @types.make_hazard(
      620.0, 250.0, 130.0, 110.0, @types.hazard_kind_lava,
      "You tumble into a fire pit.",
    ),
    @types.make_hazard(
      890.0, 690.0, 120.0, 90.0, @types.hazard_kind_lava,
      "The final vault floor collapses.",
    ),
  ]

  let plates : Array[@types.Plate] = [
    @types.make_plate(108.0, 120.0, 110.0, 90.0),
    @types.make_plate(370.0, 740.0, 110.0, 90.0),
    @types.make_plate(640.0, 120.0, 110.0, 90.0),
  ]

  let doors : Array[@types.Door] = [
    @types.make_door(280.0, @types.world_y, 28.0, @types.world_h, 0, 0.58),
    @types.make_door(540.0, @types.world_y, 28.0, @types.world_h, 1, 0.58),
    @types.make_door(800.0, @types.world_y, 28.0, @types.world_h, 2, 0.56),
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
fn stage_layout(index : Int) -> @types.StageLayout {
  match index {
    0 => stage_layout_one()
    1 => stage_layout_two()
    _ => stage_layout_three()
  }
}

///|
fn apply_layout(
  game : @types.Game,
  layout : @types.StageLayout,
  stage_index : Int,
) -> Unit {
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
  game.player.stamina = @types.stamina_max
  game.player.dash_on = false
  game.state = @types.state_play
  @types.set_banner(game, "Relics power the exit seal", 2.2)
}

///|
fn load_stage(game : @types.Game, stage_index : Int) -> Unit {
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
fn start_new_run(game : @types.Game) -> Unit {
  load_stage(game, 0)
}

///|
fn retry_stage(game : @types.Game) -> Unit {
  load_stage(game, game.stage_index)
}

///|
fn start_next_stage(game : @types.Game) -> Unit {
  let next_index = game.stage_index + 1
  if next_index >= game.stage_count {
    game.state = @types.state_victory
    @types.set_banner(game, "Temple mastered", 2.6)
  } else {
    load_stage(game, next_index)
  }
}

///|
pub fn init_title_scene(game : @types.Game) -> Unit {
  game.state = @types.state_title
  game.stage_index = 0
  game.required_relics = 0
  game.collected_relics = 0
  game.exit_x = @types.world_x + @types.world_w - 100.0
  game.exit_y = @types.world_y + 80.0
  game.exit_w = 80.0
  game.exit_h = 120.0
  game.stage_time = 0.0
  game.fail_reason = ""
  game.player.stamina = @types.stamina_max
  game.player.dash_on = false
  @types.set_banner(game, "Tap, dash, survive", 1.8)
}

///|
fn update_trap_timers(game : @types.Game, dt : Float) -> Unit {
  for trap in game.traps {
    trap.timer = trap.timer + dt
    while trap.timer >= trap.cycle {
      trap.timer = trap.timer - trap.cycle
    }
  }
}

///|
fn refresh_plates(game : @types.Game) -> Unit {
  for plate in game.plates {
    plate.pressed = @types.player_hits_rect(
      game, plate.x, plate.y, plate.w, plate.h,
    )
  }
}

///|
fn refresh_doors(game : @types.Game, dt : Float) -> Unit {
  for door in game.doors {
    let plate_index = door.plate_index
    let plate_pressed : Bool = if plate_index >= 0 &&
      plate_index < game.plates.length() {
      game.plates[plate_index].pressed
    } else {
      false
    }

    if plate_pressed {
      door.timer = door.hold_time
    } else {
      door.timer = @types.maxf(0.0, door.timer - dt)
    }

    door.open = door.timer > 0.0

    // Prevent doors from sealing while the player is inside the doorway volume.
    if not(door.open) &&
      @types.player_hits_rect(game, door.x, door.y, door.w, door.h) {
      door.open = true
    }
  }
}

///|
fn collides_closed_door(game : @types.Game, x : Float, y : Float) -> Bool {
  let (px, py, pw, ph) = @types.player_rect_at(game, x, y)

  for door in game.doors {
    if not(door.open) &&
      @types.rects_overlap(px, py, pw, ph, door.x, door.y, door.w, door.h) {
      return true
    }
  }

  false
}

///|
fn move_player(game : @types.Game, dt : Float) -> Unit {
  let mut axis_x = @types.clampf(game.input_x, -1.0, 1.0)
  let mut axis_y = @types.clampf(game.input_y, -1.0, 1.0)

  if @types.absf(axis_x) > 0.0 && @types.absf(axis_y) > 0.0 {
    axis_x = axis_x * 0.707
    axis_y = axis_y * 0.707
  }

  let moving : Bool = @types.absf(axis_x) + @types.absf(axis_y) > 0.01

  let mut dash_now : Bool = false
  if game.input_dash_hold && moving && game.player.stamina > @types.dash_min_stamina {
    dash_now = true
    game.player.stamina = @types.maxf(
      0.0,
      game.player.stamina - @types.stamina_drain_per_s * dt,
    )
  } else {
    game.player.stamina = @types.minf(
      @types.stamina_max,
      game.player.stamina + @types.stamina_recover_per_s * dt,
    )
  }

  game.player.dash_on = dash_now

  let speed : Float = if dash_now {
    @types.player_speed_dash
  } else {
    @types.player_speed_walk
  }

  let dx : Float = axis_x * speed * dt
  let dy : Float = axis_y * speed * dt

  let half_w = game.player.w * 0.5
  let half_h = game.player.h * 0.5

  let nx = @types.clampf(
    game.player.x + dx,
    @types.world_x + half_w,
    @types.world_x + @types.world_w - half_w,
  )
  if not(collides_closed_door(game, nx, game.player.y)) {
    game.player.x = nx
  }

  let ny = @types.clampf(
    game.player.y + dy,
    @types.world_y + half_h,
    @types.world_y + @types.world_h - half_h,
  )
  if not(collides_closed_door(game, game.player.x, ny)) {
    game.player.y = ny
  }
}

///|
fn collect_relics(game : @types.Game) -> Unit {
  for relic in game.relics {
    if not(relic.active) {
      continue
    }

    let dx = game.player.x - relic.x
    let dy = game.player.y - relic.y
    let reach = relic.r + game.player.w * 0.36

    if @types.sq(dx) + @types.sq(dy) <= @types.sq(reach) {
      relic.active = false
      game.collected_relics = game.collected_relics + 1
      game.player.stamina = @types.minf(
        @types.stamina_max,
        game.player.stamina + @types.relic_stamina_bonus,
      )
      @types.set_banner(game, "Relic secured", 0.9)
    }
  }
}

///|
fn fail_stage(game : @types.Game, reason : String) -> Unit {
  if game.state != @types.state_play {
    return
  }

  game.state = @types.state_failed
  game.fail_reason = reason
  game.player.dash_on = false
  @types.set_banner(game, "Run failed", 1.3)
}

///|
fn check_hazards(game : @types.Game) -> Bool {
  for hazard in game.hazards {
    if @types.player_hits_rect(
      game, hazard.x, hazard.y, hazard.w, hazard.h,
    ) {
      fail_stage(game, hazard.label)
      return true
    }
  }

  false
}

///|
fn check_traps(game : @types.Game) -> Bool {
  for trap in game.traps {
    if @types.trap_is_hot(trap) &&
      @types.player_hits_rect(game, trap.x, trap.y, trap.w, trap.h) {
      fail_stage(game, trap.label)
      return true
    }
  }

  false
}

///|
fn reach_exit(game : @types.Game) -> Unit {
  if not(
      @types.player_hits_rect(
        game, game.exit_x, game.exit_y, game.exit_w, game.exit_h,
      ),
    ) {
    return
  }

  if not(@types.exit_unlocked(game)) {
    if game.banner_t <= 0.0 {
      @types.set_banner(game, "Exit sealed: collect every relic", 1.2)
    }
    return
  }

  if game.stage_index + 1 < game.stage_count {
    game.state = @types.state_stage_clear
    @types.set_banner(game, "Chamber cleared", 1.6)
  } else {
    game.state = @types.state_victory
    @types.set_banner(game, "Temple mastered", 2.6)
  }
}

///|
fn update_title_state(game : @types.Game, _dt : Float) -> Unit {
  if game.input_start_press {
    start_new_run(game)
  }
}

///|
fn update_play_state(game : @types.Game, dt : Float) -> Unit {
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
fn update_stage_clear_state(game : @types.Game, _dt : Float) -> Unit {
  if game.input_restart_press {
    retry_stage(game)
  } else if game.input_next_press {
    start_next_stage(game)
  }
}

///|
fn update_failed_state(game : @types.Game, _dt : Float) -> Unit {
  if game.input_restart_press {
    retry_stage(game)
  } else if game.input_next_press {
    init_title_scene(game)
  }
}

///|
fn update_victory_state(game : @types.Game, _dt : Float) -> Unit {
  if game.input_next_press {
    start_new_run(game)
  } else if game.input_restart_press {
    init_title_scene(game)
  }
}

///|
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  // Handle input based on current state
  if game.state == @types.state_title {
    update_title_input(game)
  } else if game.state == @types.state_play {
    update_play_input(game)
  } else if game.state == @types.state_stage_clear {
    update_stage_clear_input(game)
  } else if game.state == @types.state_failed {
    update_failed_input(game)
  } else {
    update_victory_input(game)
  }

  game.banner_t = @types.maxf(0.0, game.banner_t - dt)

  if game.state == @types.state_title {
    update_title_state(game, dt)
  } else if game.state == @types.state_play {
    update_play_state(game, dt)
  } else if game.state == @types.state_stage_clear {
    update_stage_clear_state(game, dt)
  } else if game.state == @types.state_failed {
    update_failed_state(game, dt)
  } else {
    update_victory_state(game, dt)
  }
}
