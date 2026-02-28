// Player ship

///|
pub(all) struct Ship {
  mut x : Float
  mut z : Float
  mut heading : Float
  mut speed : Float
  mut drift_x : Float
  mut drift_z : Float
  mut sail_amount : Float
  mut sail_state : Int
  mut hull_hp : Float
  mut bow_hp : Float
  mut mid_hp : Float
  mut stern_hp : Float
  mut mast_hp : Float
  mut sail_hp : Float
  mut rudder_hp : Float
  mut cannon_deck_hp : Float
  mut max_hp : Float
  mut reload_left : Float
  mut reload_right : Float
  mut cannon_damage : Float
  mut reload_time : Float
  mut ship_class : Int
  mut cannon_count : Int
  mut cannon_type : Int
  mut ammo_type : Int
  mut ammo_round : Int
  mut ammo_chain : Int
  mut ammo_grape : Int
  mut crew : Int
  mut max_crew : Int
  mut crew_action : Int
  mut turn_rate_base : Float
  mut ship_length : Float
  mut ship_width : Float
  mut bob_phase : Float
  mut roll_angle : Float
  mut taking_water : Float
  mut on_fire : Bool
  mut fire_timer : Float
  mut boarding_target : Int
  mut boarding_timer : Float
  mut kills : Int
  mut damage_dealt : Float
  mut damage_taken : Float
}

///|
pub fn Ship::new_player() -> Ship {
  {
    x: 0.0,
    z: 0.0,
    heading: 0.0,
    speed: 0.0,
    drift_x: 0.0,
    drift_z: 0.0,
    sail_amount: 0.5,
    sail_state: sail_half,
    hull_hp: player_max_hp,
    bow_hp: player_max_hp * 0.8,
    mid_hp: player_max_hp,
    stern_hp: player_max_hp * 0.8,
    mast_hp: frigate_max_mast,
    sail_hp: player_max_hp,
    rudder_hp: player_max_hp * 0.8,
    cannon_deck_hp: player_max_hp * 0.9,
    max_hp: player_max_hp,
    reload_left: 0.0,
    reload_right: 0.0,
    cannon_damage: player_cannon_damage,
    reload_time: player_cannon_reload,
    ship_class: class_frigate,
    cannon_count: frigate_cannon_count,
    cannon_type: cannon_medium,
    ammo_type: ammo_round_shot,
    ammo_round: player_start_ammo,
    ammo_chain: 20,
    ammo_grape: 15,
    crew: player_start_crew,
    max_crew: frigate_max_crew,
    crew_action: crew_action_cannons,
    turn_rate_base: frigate_turn_rate,
    ship_length: frigate_length,
    ship_width: frigate_width,
    bob_phase: 0.0,
    roll_angle: 0.0,
    taking_water: 0.0,
    on_fire: false,
    fire_timer: 0.0,
    boarding_target: -1,
    boarding_timer: 0.0,
    kills: 0,
    damage_dealt: 0.0,
    damage_taken: 0.0,
  }
}

// Enemy ship

///|
pub(all) struct EnemyShip {
  mut active : Bool
  mut x : Float
  mut z : Float
  mut heading : Float
  mut speed : Float
  mut drift_x : Float
  mut drift_z : Float
  mut hull_hp : Float
  mut mast_hp : Float
  mut rudder_hp : Float
  mut max_hp : Float
  mut max_mast_hp : Float
  mut max_rudder_hp : Float
  mut ai_state : Int
  mut ai_personality : Int
  mut patrol_angle : Float
  mut patrol_cx : Float
  mut patrol_cz : Float
  mut patrol_radius : Float
  mut fire_timer : Float
  mut fire_rate : Float
  mut cannon_damage : Float
  mut cannon_type : Int
  mut cannon_count : Int
  mut detect_range : Float
  mut attack_range : Float
  mut score_value : Int
  mut ship_class : Int
  mut crew : Int
  mut max_crew : Int
  mut sail_amount : Float
  mut turn_rate_base : Float
  mut ship_length : Float
  mut ship_width : Float
  mut bob_phase : Float
  mut roll_angle : Float
  mut retreat_hp_pct : Float
  mut is_flagship : Bool
  mut taking_water : Float
  mut on_fire : Bool
  mut fire_timer_decay : Float
  mut broadside_cooldown : Float
  mut target_heading : Float
  mut formation_offset_x : Float
  mut formation_offset_z : Float
}

///|
pub fn EnemyShip::inactive() -> EnemyShip {
  {
    active: false,
    x: 0.0,
    z: 0.0,
    heading: 0.0,
    speed: 3.0,
    drift_x: 0.0,
    drift_z: 0.0,
    hull_hp: 0.0,
    mast_hp: 50.0,
    rudder_hp: 40.0,
    max_hp: 50.0,
    max_mast_hp: 50.0,
    max_rudder_hp: 40.0,
    ai_state: ai_patrol,
    ai_personality: ai_personality_aggressive,
    patrol_angle: 0.0,
    patrol_cx: 0.0,
    patrol_cz: 0.0,
    patrol_radius: 15.0,
    fire_timer: 0.0,
    fire_rate: 2.0,
    cannon_damage: 8.0,
    cannon_type: cannon_light,
    cannon_count: 4,
    detect_range: 40.0,
    attack_range: 25.0,
    score_value: 100,
    ship_class: class_sloop,
    crew: 20,
    max_crew: 20,
    sail_amount: 0.8,
    turn_rate_base: 1.5,
    ship_length: 3.0,
    ship_width: 1.2,
    bob_phase: 0.0,
    roll_angle: 0.0,
    retreat_hp_pct: 0.2,
    is_flagship: false,
    taking_water: 0.0,
    on_fire: false,
    fire_timer_decay: 0.0,
    broadside_cooldown: 0.0,
    target_heading: 0.0,
    formation_offset_x: 0.0,
    formation_offset_z: 0.0,
  }
}

// Cannonball

///|
pub(all) struct Cannonball {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut z : Float
  mut vx : Float
  mut vy : Float
  mut vz : Float
  mut life : Float
  mut damage : Float
  mut from_player : Bool
  mut ammo_type : Int
  mut cannon_type : Int
  mut wind_drift : Float
  mut trail_timer : Float
}

///|
pub fn Cannonball::inactive() -> Cannonball {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    z: 0.0,
    vx: 0.0,
    vy: 0.0,
    vz: 0.0,
    life: 0.0,
    damage: 0.0,
    from_player: false,
    ammo_type: ammo_round_shot,
    cannon_type: cannon_medium,
    wind_drift: 0.0,
    trail_timer: 0.0,
  }
}

// Particle

///|
pub(all) struct Particle {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut z : Float
  mut vx : Float
  mut vy : Float
  mut vz : Float
  mut life : Float
  mut max_life : Float
  mut r : Int
  mut g : Int
  mut b : Int
  mut size : Float
  mut particle_type : Int
}

///|
pub let particle_generic : Int = 0

///|
pub let particle_smoke : Int = 1

///|
pub let particle_fire : Int = 2

///|
pub let particle_splash : Int = 3

///|
pub let particle_debris : Int = 4

///|
pub let particle_spark : Int = 5

///|
pub fn Particle::inactive() -> Particle {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    z: 0.0,
    vx: 0.0,
    vy: 0.0,
    vz: 0.0,
    life: 0.0,
    max_life: 1.0,
    r: 255,
    g: 255,
    b: 255,
    size: 0.1,
    particle_type: particle_generic,
  }
}

// Island obstacle

///|
pub(all) struct Island {
  mut active : Bool
  mut x : Float
  mut z : Float
  mut radius : Float
  mut height : Float
  mut blocks : Int
  mut island_type : Int
  mut has_fortress : Bool
  mut fortress_hp : Float
  mut fortress_max_hp : Float
  mut fortress_fire_timer : Float
  mut fortress_cannons_active : Int
  mut beach_color_r : Int
  mut beach_color_g : Int
  mut beach_color_b : Int
  mut vegetation_density : Int
}

///|
pub fn Island::inactive() -> Island {
  {
    active: false,
    x: 0.0,
    z: 0.0,
    radius: 5.0,
    height: 3.0,
    blocks: 3,
    island_type: island_small,
    has_fortress: false,
    fortress_hp: 0.0,
    fortress_max_hp: fortress_base_hp,
    fortress_fire_timer: 0.0,
    fortress_cannons_active: 0,
    beach_color_r: 200,
    beach_color_g: 180,
    beach_color_b: 130,
    vegetation_density: 3,
  }
}

// Water wake trail

///|
pub(all) struct WaterWake {
  mut active : Bool
  mut x : Float
  mut z : Float
  mut age : Float
  mut max_age : Float
  mut width : Float
  mut heading : Float
  mut speed_at_spawn : Float
}

///|
pub fn WaterWake::inactive() -> WaterWake {
  {
    active: false,
    x: 0.0,
    z: 0.0,
    age: 0.0,
    max_age: wake_lifetime,
    width: 0.5,
    heading: 0.0,
    speed_at_spawn: 0.0,
  }
}

// Floating debris from destroyed ships

///|
pub(all) struct Debris {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut z : Float
  mut vx : Float
  mut vz : Float
  mut rotation : Float
  mut rot_speed : Float
  mut life : Float
  mut size : Float
  mut debris_type : Int
  mut r : Int
  mut g : Int
  mut b : Int
}

///|
pub let debris_plank : Int = 0

///|
pub let debris_barrel : Int = 1

///|
pub let debris_sail_scrap : Int = 2

///|
pub let debris_mast_piece : Int = 3

///|
pub fn Debris::inactive() -> Debris {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    z: 0.0,
    vx: 0.0,
    vz: 0.0,
    rotation: 0.0,
    rot_speed: 0.0,
    life: 0.0,
    size: 0.3,
    debris_type: debris_plank,
    r: 120,
    g: 80,
    b: 40,
  }
}

// Wind system

///|
pub(all) struct Wind {
  mut direction : Float
  mut speed : Float
  mut target_direction : Float
  mut target_speed : Float
  mut gust_timer : Float
  mut gust_active : Bool
  mut gust_strength : Float
  mut shift_timer : Float
  mut shift_interval : Float
  mut turbulence : Float
}

///|
pub fn Wind::new() -> Wind {
  {
    direction: 0.5,
    speed: wind_speed_moderate,
    target_direction: 0.5,
    target_speed: wind_speed_moderate,
    gust_timer: 0.0,
    gust_active: false,
    gust_strength: 0.0,
    shift_timer: 15.0,
    shift_interval: 15.0,
    turbulence: 0.0,
  }
}

// Battle message

///|
pub(all) struct BattleMessage {
  mut active : Bool
  mut text : String
  mut timer : Float
  mut priority : Int
  mut color_r : Int
  mut color_g : Int
  mut color_b : Int
}

///|
pub fn BattleMessage::inactive() -> BattleMessage {
  {
    active: false,
    text: "",
    timer: 0.0,
    priority: 0,
    color_r: 255,
    color_g: 220,
    color_b: 100,
  }
}

// Battle objective

///|
pub(all) struct BattleObjective {
  mut objective_type : Int
  mut target_count : Int
  mut current_count : Int
  mut time_limit : Float
  mut time_elapsed : Float
  mut completed : Bool
  mut failed : Bool
  mut description : String
}

///|
pub fn BattleObjective::new() -> BattleObjective {
  {
    objective_type: objective_destroy_all,
    target_count: 0,
    current_count: 0,
    time_limit: 0.0,
    time_elapsed: 0.0,
    completed: false,
    failed: false,
    description: "Destroy all enemy ships",
  }
}

// Battle statistics

///|
pub(all) struct BattleStats {
  mut ships_sunk : Int
  mut damage_dealt : Float
  mut damage_taken : Float
  mut crew_lost : Int
  mut ammo_used : Int
  mut time_elapsed : Float
  mut accuracy_hits : Int
  mut accuracy_shots : Int
  mut boarding_wins : Int
  mut fortresses_destroyed : Int
}

///|
pub fn BattleStats::new() -> BattleStats {
  {
    ships_sunk: 0,
    damage_dealt: 0.0,
    damage_taken: 0.0,
    crew_lost: 0,
    ammo_used: 0,
    time_elapsed: 0.0,
    accuracy_hits: 0,
    accuracy_shots: 0,
    boarding_wins: 0,
    fortresses_destroyed: 0,
  }
}

// Convoy ship (for escort missions)

///|
pub(all) struct ConvoyShip {
  mut active : Bool
  mut x : Float
  mut z : Float
  mut heading : Float
  mut speed : Float
  mut hull_hp : Float
  mut max_hp : Float
  mut arrived : Bool
}

///|
pub fn ConvoyShip::inactive() -> ConvoyShip {
  {
    active: false,
    x: 0.0,
    z: 0.0,
    heading: 0.0,
    speed: convoy_speed,
    hull_hp: 50.0,
    max_hp: 50.0,
    arrived: false,
  }
}

// Fleet ally ship (player-commanded)

///|
pub(all) struct FleetShip {
  mut active : Bool
  mut x : Float
  mut z : Float
  mut heading : Float
  mut speed : Float
  mut hull_hp : Float
  mut max_hp : Float
  mut mast_hp : Float
  mut max_mast_hp : Float
  mut ship_class : Int
  mut cannon_count : Int
  mut fire_timer : Float
  mut fire_rate : Float
  mut cannon_damage : Float
  mut crew : Int
  mut max_crew : Int
  mut sail_amount : Float
  mut turn_rate_base : Float
  mut ship_length : Float
  mut ship_width : Float
  mut bob_phase : Float
  mut order : Int
  mut target_x : Float
  mut target_z : Float
}

///|
pub let fleet_order_follow : Int = 0

///|
pub let fleet_order_attack : Int = 1

///|
pub let fleet_order_defend : Int = 2

///|
pub let fleet_order_hold : Int = 3

///|
pub fn FleetShip::inactive() -> FleetShip {
  {
    active: false,
    x: 0.0,
    z: 0.0,
    heading: 0.0,
    speed: 0.0,
    hull_hp: 0.0,
    max_hp: 60.0,
    mast_hp: 50.0,
    max_mast_hp: 50.0,
    ship_class: class_sloop,
    cannon_count: 4,
    fire_timer: 0.0,
    fire_rate: 2.5,
    cannon_damage: 8.0,
    crew: 20,
    max_crew: 20,
    sail_amount: 0.7,
    turn_rate_base: 1.5,
    ship_length: 3.0,
    ship_width: 1.2,
    bob_phase: 0.0,
    order: fleet_order_follow,
    target_x: 0.0,
    target_z: 0.0,
  }
}

///|
pub let max_fleet_ships : Int = 4

///|
pub let max_convoy_ships : Int = 4

// Main Game struct

///|
pub(all) struct Game {
  mut state : Int

  // Player
  player : Ship

  // Score and battle
  mut score : Int
  mut reputation : Int
  mut current_battle : Int
  mut enemies_alive : Int
  mut total_battles : Int

  // Wind
  wind : Wind

  // For legacy compat
  mut wind_angle : Float
  mut wind_speed : Float

  // Battle objective
  objective : BattleObjective

  // Battle stats
  battle_stats : BattleStats

  // Entity pools
  enemies : Array[EnemyShip]
  cannonballs : Array[Cannonball]
  particles : Array[Particle]
  islands : Array[Island]
  wakes : Array[WaterWake]
  debris_pool : Array[Debris]
  fleet_ships : Array[FleetShip]
  convoy_ships : Array[ConvoyShip]
  mut island_count : Int

  // Battle messages
  messages : Array[BattleMessage]

  // Camera
  mut camera_offset_angle : Float
  mut camera_dist : Float
  mut camera_height_offset : Float

  // UI state
  mut menu_cursor : Int
  mut menu_blink : Float
  mut message_timer : Float
  mut message_text : String
  mut show_minimap : Bool
  mut show_battle_log : Bool
  mut selected_fleet_ship : Int
  mut battle_select_cursor : Int
  mut fleet_command_mode : Bool

  // Battle log
  battle_log : Array[String]
  mut battle_log_count : Int

  // RNG
  mut rng_state : Int
  mut frame_counter : Int

  // Timers
  mut battle_timer : Float
  mut wave_time : Float
  mut wake_spawn_timer : Float

  // Convoy
  mut convoy_target_x : Float
  mut convoy_target_z : Float
  mut convoy_arrived_count : Int
}

///|
pub fn Game::new() -> Game {
  {
    state: state_menu,
    player: Ship::new_player(),
    score: 0,
    reputation: 0,
    current_battle: 0,
    enemies_alive: 0,
    total_battles: 12,
    wind: Wind::new(),
    wind_angle: 0.5,
    wind_speed: wind_strength,
    objective: BattleObjective::new(),
    battle_stats: BattleStats::new(),
    enemies: {
      let arr : Array[EnemyShip] = []
      for i = 0; i < max_enemies; i = i + 1 {
        arr.push(EnemyShip::inactive())
        ignore(i)
      }
      arr
    },
    cannonballs: {
      let arr : Array[Cannonball] = []
      for i = 0; i < max_cannonballs; i = i + 1 {
        arr.push(Cannonball::inactive())
        ignore(i)
      }
      arr
    },
    particles: {
      let arr : Array[Particle] = []
      for i = 0; i < max_particles; i = i + 1 {
        arr.push(Particle::inactive())
        ignore(i)
      }
      arr
    },
    islands: {
      let arr : Array[Island] = []
      for i = 0; i < max_islands; i = i + 1 {
        arr.push(Island::inactive())
        ignore(i)
      }
      arr
    },
    wakes: {
      let arr : Array[WaterWake] = []
      for i = 0; i < max_wakes; i = i + 1 {
        arr.push(WaterWake::inactive())
        ignore(i)
      }
      arr
    },
    debris_pool: {
      let arr : Array[Debris] = []
      for i = 0; i < max_debris; i = i + 1 {
        arr.push(Debris::inactive())
        ignore(i)
      }
      arr
    },
    fleet_ships: {
      let arr : Array[FleetShip] = []
      for i = 0; i < max_fleet_ships; i = i + 1 {
        arr.push(FleetShip::inactive())
        ignore(i)
      }
      arr
    },
    convoy_ships: {
      let arr : Array[ConvoyShip] = []
      for i = 0; i < max_convoy_ships; i = i + 1 {
        arr.push(ConvoyShip::inactive())
        ignore(i)
      }
      arr
    },
    island_count: 0,
    messages: {
      let arr : Array[BattleMessage] = []
      for i = 0; i < max_messages; i = i + 1 {
        arr.push(BattleMessage::inactive())
        ignore(i)
      }
      arr
    },
    camera_offset_angle: 0.0,
    camera_dist,
    camera_height_offset: 0.0,
    menu_cursor: 0,
    menu_blink: 0.0,
    message_timer: 0.0,
    message_text: "",
    show_minimap: true,
    show_battle_log: false,
    selected_fleet_ship: -1,
    battle_select_cursor: 0,
    fleet_command_mode: false,
    battle_log: {
      let arr : Array[String] = []
      for i = 0; i < 20; i = i + 1 {
        arr.push("")
        ignore(i)
      }
      arr
    },
    battle_log_count: 0,
    rng_state: 54321,
    frame_counter: 0,
    battle_timer: 0.0,
    wave_time: 0.0,
    wake_spawn_timer: 0.0,
    convoy_target_x: 0.0,
    convoy_target_z: 80.0,
    convoy_arrived_count: 0,
  }
}
