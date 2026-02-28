// Aircraft type definition with flight characteristics
pub(all) struct AircraftStats {
  kind : Int
  name : String
  max_speed : Float
  min_speed : Float
  turn_rate : Float
  roll_rate : Float
  climb_rate : Float
  fuel_capacity : Float
  max_hp : Float
  ammo_mg : Int
  ammo_rockets : Int
  ammo_bombs : Int
}

pub fn AircraftStats::trainer() -> AircraftStats {
  {
    kind: aircraft_trainer,
    name: "Trainer",
    max_speed: trainer_speed_max,
    min_speed: trainer_speed_min,
    turn_rate: trainer_turn_rate,
    roll_rate: trainer_roll_rate,
    climb_rate: trainer_climb_rate,
    fuel_capacity: trainer_fuel_capacity,
    max_hp: trainer_hp,
    ammo_mg: trainer_ammo_mg,
    ammo_rockets: trainer_ammo_rockets,
    ammo_bombs: trainer_ammo_bombs,
  }
}

pub fn AircraftStats::fighter() -> AircraftStats {
  {
    kind: aircraft_fighter,
    name: "Fighter",
    max_speed: fighter_speed_max,
    min_speed: fighter_speed_min,
    turn_rate: fighter_turn_rate,
    roll_rate: fighter_roll_rate,
    climb_rate: fighter_climb_rate,
    fuel_capacity: fighter_fuel_capacity,
    max_hp: fighter_hp,
    ammo_mg: fighter_ammo_mg,
    ammo_rockets: fighter_ammo_rockets,
    ammo_bombs: fighter_ammo_bombs,
  }
}

pub fn AircraftStats::bomber() -> AircraftStats {
  {
    kind: aircraft_bomber,
    name: "Bomber",
    max_speed: bomber_speed_max,
    min_speed: bomber_speed_min,
    turn_rate: bomber_turn_rate,
    roll_rate: bomber_roll_rate,
    climb_rate: bomber_climb_rate,
    fuel_capacity: bomber_fuel_capacity,
    max_hp: bomber_hp,
    ammo_mg: bomber_ammo_mg,
    ammo_rockets: bomber_ammo_rockets,
    ammo_bombs: bomber_ammo_bombs,
  }
}

pub fn AircraftStats::interceptor() -> AircraftStats {
  {
    kind: aircraft_interceptor,
    name: "Interceptor",
    max_speed: interceptor_speed_max,
    min_speed: interceptor_speed_min,
    turn_rate: interceptor_turn_rate,
    roll_rate: interceptor_roll_rate,
    climb_rate: interceptor_climb_rate,
    fuel_capacity: interceptor_fuel_capacity,
    max_hp: interceptor_hp,
    ammo_mg: interceptor_ammo_mg,
    ammo_rockets: interceptor_ammo_rockets,
    ammo_bombs: interceptor_ammo_bombs,
  }
}

pub fn get_aircraft_stats(kind : Int) -> AircraftStats {
  if kind == aircraft_trainer {
    AircraftStats::trainer()
  } else if kind == aircraft_fighter {
    AircraftStats::fighter()
  } else if kind == aircraft_bomber {
    AircraftStats::bomber()
  } else {
    AircraftStats::interceptor()
  }
}

// Player aircraft
pub(all) struct Player {
  mut x : Float
  mut y : Float
  mut z : Float
  mut pitch : Float
  mut yaw : Float
  mut roll : Float
  mut speed : Float
  mut throttle : Float
  mut fuel : Float
  mut max_fuel : Float
  mut hp : Float
  mut max_hp : Float
  mut fire_timer : Float
  mut damage_flash : Float
  mut alive : Bool
  mut aircraft_type : Int
  mut ammo_mg : Int
  mut ammo_rockets : Int
  mut ammo_bombs : Int
  mut current_weapon : Int
  mut stalling : Bool
  mut stall_timer : Float
  mut damage_smoke : Bool
  mut engine_on : Bool
  mut landing_gear : Bool
  mut flaps : Float
  mut trim : Float
  mut gforce : Float
  mut prev_vy : Float
  mut shots_fired : Int
  mut shots_hit : Int
  mut weapon_switch_timer : Float
}

pub fn Player::new() -> Player {
  {
    x: 0.0,
    y: 30.0,
    z: 0.0,
    pitch: 0.0,
    yaw: 0.0,
    roll: 0.0,
    speed: aircraft_speed_start,
    throttle: 0.5,
    fuel: aircraft_max_fuel,
    max_fuel: aircraft_max_fuel,
    hp: 100.0,
    max_hp: 100.0,
    fire_timer: 0.0,
    damage_flash: 0.0,
    alive: true,
    aircraft_type: aircraft_fighter,
    ammo_mg: fighter_ammo_mg,
    ammo_rockets: fighter_ammo_rockets,
    ammo_bombs: fighter_ammo_bombs,
    current_weapon: weapon_machine_gun,
    stalling: false,
    stall_timer: 0.0,
    damage_smoke: false,
    engine_on: true,
    landing_gear: false,
    flaps: 0.0,
    trim: 0.0,
    gforce: 1.0,
    prev_vy: 0.0,
    shots_fired: 0,
    shots_hit: 0,
    weapon_switch_timer: 0.0,
  }
}

pub fn Player::apply_stats(self : Player, stats : AircraftStats) -> Unit {
  self.aircraft_type = stats.kind
  self.max_hp = stats.max_hp
  self.hp = stats.max_hp
  self.max_fuel = stats.fuel_capacity
  self.fuel = stats.fuel_capacity
  self.ammo_mg = stats.ammo_mg
  self.ammo_rockets = stats.ammo_rockets
  self.ammo_bombs = stats.ammo_bombs
}

// Enemy entity
pub(all) struct Enemy {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut z : Float
  mut vx : Float
  mut vy : Float
  mut vz : Float
  mut hp : Float
  mut max_hp : Float
  mut speed : Float
  mut size : Float
  mut fire_timer : Float
  mut flash_timer : Float
  mut orbit_angle : Float
  mut orbit_radius : Float
  mut target_y : Float
  mut ai_state : Int
  mut patrol_cx : Float
  mut patrol_cz : Float
  mut patrol_index : Int
  mut aggression : Float
  mut maneuver_timer : Float
  mut evade_timer : Float
  mut heading : Float
}

pub fn Enemy::inactive() -> Enemy {
  {
    active: false,
    kind: 0,
    x: 0.0,
    y: 0.0,
    z: 0.0,
    vx: 0.0,
    vy: 0.0,
    vz: 0.0,
    hp: 0.0,
    max_hp: 1.0,
    speed: 20.0,
    size: 1.0,
    fire_timer: 0.0,
    flash_timer: 0.0,
    orbit_angle: 0.0,
    orbit_radius: 30.0,
    target_y: 25.0,
    ai_state: ai_patrol,
    patrol_cx: 0.0,
    patrol_cz: 0.0,
    patrol_index: 0,
    aggression: 0.5,
    maneuver_timer: 0.0,
    evade_timer: 0.0,
    heading: 0.0,
  }
}

// Turret (anti-aircraft emplacement)
pub(all) struct Turret {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut z : Float
  mut rotation : Float
  mut elevation : Float
  mut fire_timer : Float
  mut range : Float
  mut hp : Float
  mut max_hp : Float
  mut flash_timer : Float
}

pub fn Turret::inactive() -> Turret {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    z: 0.0,
    rotation: 0.0,
    elevation: 0.0,
    fire_timer: 0.0,
    range: turret_range,
    hp: turret_hp,
    max_hp: turret_hp,
    flash_timer: 0.0,
  }
}

// Projectile
pub(all) struct Projectile {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut z : Float
  mut dx : Float
  mut dy : Float
  mut dz : Float
  mut speed : Float
  mut damage : Float
  mut life : Float
  mut is_enemy : Bool
  mut gravity_affected : Bool
  mut blast_radius : Float
}

pub fn Projectile::inactive() -> Projectile {
  {
    active: false,
    kind: proj_bullet,
    x: 0.0,
    y: 0.0,
    z: 0.0,
    dx: 0.0,
    dy: 0.0,
    dz: 0.0,
    speed: 120.0,
    damage: 25.0,
    life: 2.0,
    is_enemy: false,
    gravity_affected: false,
    blast_radius: 0.0,
  }
}

// Building / structure
pub(all) struct Building {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut z : Float
  mut hp : Float
  mut max_hp : Float
  mut destructible : Bool
  mut width : Float
  mut height : Float
  mut depth : Float
  mut flash_timer : Float
}

pub fn Building::inactive() -> Building {
  {
    active: false,
    kind: building_house,
    x: 0.0,
    y: 0.0,
    z: 0.0,
    hp: 100.0,
    max_hp: 100.0,
    destructible: true,
    width: 3.0,
    height: 3.0,
    depth: 3.0,
    flash_timer: 0.0,
  }
}

// Particle
pub(all) struct Particle {
  mut active : Bool
  mut kind : Int
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
}

pub fn Particle::inactive() -> Particle {
  {
    active: false,
    kind: particle_exhaust,
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
  }
}

// Checkpoint ring
pub(all) struct Checkpoint {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut z : Float
  mut radius : Float
  mut collected : Bool
  mut order : Int
}

pub fn Checkpoint::inactive() -> Checkpoint {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    z: 0.0,
    radius: checkpoint_radius,
    collected: false,
    order: 0,
  }
}

// Terrain chunk (one column of terrain)
pub(all) struct TerrainChunk {
  mut active : Bool
  mut grid_x : Int
  mut grid_z : Int
  mut height : Float
  mut color_r : Int
  mut color_g : Int
  mut color_b : Int
}

pub fn TerrainChunk::inactive() -> TerrainChunk {
  {
    active: false,
    grid_x: 0,
    grid_z: 0,
    height: 1.0,
    color_r: 60,
    color_g: 120,
    color_b: 40,
  }
}

// Cloud entity
pub(all) struct Cloud {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut z : Float
  mut size_x : Float
  mut size_y : Float
  mut size_z : Float
  mut alpha : Int
}

pub fn Cloud::inactive() -> Cloud {
  {
    active: false,
    x: 0.0,
    y: 50.0,
    z: 0.0,
    size_x: 8.0,
    size_y: 3.0,
    size_z: 6.0,
    alpha: 120,
  }
}

// Weather state
pub(all) struct WeatherState {
  mut kind : Int
  mut visibility : Float
  mut turbulence : Float
  mut wind_dir_x : Float
  mut wind_dir_z : Float
  mut wind_speed : Float
  mut cloud_height : Float
  mut rain_intensity : Float
  mut time_of_day : Float
}

pub fn WeatherState::new() -> WeatherState {
  {
    kind: weather_clear,
    visibility: fog_clear_dist,
    turbulence: 0.0,
    wind_dir_x: 1.0,
    wind_dir_z: 0.0,
    wind_speed: 0.0,
    cloud_height: cloud_base_height,
    rain_intensity: 0.0,
    time_of_day: 0.5,
  }
}

pub fn WeatherState::set_weather(self : WeatherState, kind : Int) -> Unit {
  self.kind = kind
  if kind == weather_clear {
    self.visibility = fog_clear_dist
    self.turbulence = turb_clear
    self.wind_speed = wind_clear
    self.rain_intensity = 0.0
    self.time_of_day = 0.5
  } else if kind == weather_cloudy {
    self.visibility = fog_cloudy_dist
    self.turbulence = turb_cloudy
    self.wind_speed = wind_cloudy
    self.rain_intensity = 0.0
    self.time_of_day = 0.5
  } else if kind == weather_fog {
    self.visibility = fog_fog_dist
    self.turbulence = turb_fog
    self.wind_speed = wind_fog
    self.rain_intensity = 0.0
    self.time_of_day = 0.4
  } else if kind == weather_rain {
    self.visibility = fog_rain_dist
    self.turbulence = turb_rain
    self.wind_speed = wind_rain
    self.rain_intensity = 0.7
    self.time_of_day = 0.35
  } else if kind == weather_storm {
    self.visibility = fog_storm_dist
    self.turbulence = turb_storm
    self.wind_speed = wind_storm
    self.rain_intensity = 1.0
    self.time_of_day = 0.25
  } else if kind == weather_night {
    self.visibility = fog_night_dist
    self.turbulence = turb_night
    self.wind_speed = wind_night
    self.rain_intensity = 0.0
    self.time_of_day = 0.05
  }
}

// Message for radio/event display
pub(all) struct GameMessage {
  mut text : String
  mut timer : Float
  mut priority : Int
}

pub fn GameMessage::empty() -> GameMessage {
  { text: "", timer: 0.0, priority: 0 }
}

// Mission definition
pub(all) struct Mission {
  name : String
  kind : Int
  description : String
  mut target_count : Int
  mut targets_done : Int
  weather : Int
  enemy_count : Int
  enemy_air_count : Int
  has_landing : Bool
  landing_x : Float
  landing_z : Float
  turret_count : Int
  building_count : Int
  difficulty : Int
  allowed_aircraft : Int
  time_limit : Float
  briefing : String
}

// Main Game struct
pub(all) struct Game {
  mut state : Int

  // Player
  player : Player

  // Camera
  mut cam_x : Float
  mut cam_y : Float
  mut cam_z : Float
  mut cam_target_x : Float
  mut cam_target_y : Float
  mut cam_target_z : Float
  mut camera_mode : Int

  // Mission
  mut current_mission : Int
  mut mission_timer : Float
  mut missions_completed : Int
  missions : Array[Mission]
  mut selected_aircraft : Int

  // Entity pools
  enemies : Array[Enemy]
  turrets : Array[Turret]
  projectiles : Array[Projectile]
  particles : Array[Particle]
  checkpoints : Array[Checkpoint]
  buildings : Array[Building]
  terrain : Array[TerrainChunk]
  clouds : Array[Cloud]

  // Terrain tracking
  mut last_terrain_cx : Int
  mut last_terrain_cz : Int

  // Weather
  weather_state : WeatherState
  mut weather : Int
  mut draw_distance : Float

  // Score
  mut score : Int
  mut kills : Int
  mut buildings_destroyed : Int
  mut mission_score : Int

  // UI
  mut menu_cursor : Int
  mut menu_blink : Float
  mut message_text : String
  mut message_timer : Float
  messages : Array[GameMessage]

  // Warnings
  mut fuel_warning : Bool
  mut stall_warning : Bool
  mut altitude_warning : Bool
  mut damage_warning : Bool
  mut incoming_warning : Bool
  mut warning_flash_timer : Float

  // RNG
  mut rng_state : Int
  mut frame_counter : Int

  // Landing
  mut landing_approach : Bool
  mut landing_timer : Float

  // Mission rating
  mut accuracy_pct : Float
  mut mission_rating : String

  // Best scores per mission
  best_scores : Array[Int]
}

pub fn Game::new() -> Game {
  let missions = build_missions()
  {
    state: state_menu,
    player: Player::new(),
    cam_x: 0.0,
    cam_y: 34.0,
    cam_z: -12.0,
    cam_target_x: 0.0,
    cam_target_y: 30.0,
    cam_target_z: 0.0,
    camera_mode: camera_mode_chase,
    current_mission: 0,
    mission_timer: 0.0,
    missions_completed: 0,
    missions,
    selected_aircraft: aircraft_fighter,
    enemies: Array::make(max_enemies, Enemy::inactive()),
    turrets: Array::make(max_turrets, Turret::inactive()),
    projectiles: Array::make(max_projectiles, Projectile::inactive()),
    particles: Array::make(max_particles, Particle::inactive()),
    checkpoints: Array::make(max_checkpoints, Checkpoint::inactive()),
    buildings: Array::make(max_buildings, Building::inactive()),
    terrain: Array::make(max_terrain_chunks, TerrainChunk::inactive()),
    clouds: Array::make(max_clouds, Cloud::inactive()),
    last_terrain_cx: -9999,
    last_terrain_cz: -9999,
    weather_state: WeatherState::new(),
    weather: weather_clear,
    draw_distance: fog_clear_dist,
    score: 0,
    kills: 0,
    buildings_destroyed: 0,
    mission_score: 0,
    menu_cursor: 0,
    menu_blink: 0.0,
    message_text: "",
    message_timer: 0.0,
    messages: Array::make(4, GameMessage::empty()),
    fuel_warning: false,
    stall_warning: false,
    altitude_warning: false,
    damage_warning: false,
    incoming_warning: false,
    warning_flash_timer: 0.0,
    rng_state: 73219,
    frame_counter: 0,
    landing_approach: false,
    landing_timer: 0.0,
    accuracy_pct: 0.0,
    mission_rating: "D",
    best_scores: Array::make(total_missions, 0),
  }
}

fn build_missions() -> Array[Mission] {
  let m : Array[Mission] = []
  // Mission 0: Training patrol - fly through checkpoints
  m.push({
    name: "Training Flight",
    kind: mission_checkpoint,
    description: "Fly through all checkpoint rings",
    target_count: 5,
    targets_done: 0,
    weather: weather_clear,
    enemy_count: 0,
    enemy_air_count: 0,
    has_landing: false,
    landing_x: 0.0,
    landing_z: 0.0,
    turret_count: 0,
    building_count: 0,
    difficulty: 1,
    allowed_aircraft: -1,
    time_limit: 0.0,
    briefing: "Welcome, pilot. Fly through all checkpoint rings to complete basic training.",
  })
  // Mission 1: Ground strike
  m.push({
    name: "Ground Strike",
    kind: mission_destroy,
    description: "Destroy all ground targets",
    target_count: 4,
    targets_done: 0,
    weather: weather_clear,
    enemy_count: 4,
    enemy_air_count: 0,
    has_landing: false,
    landing_x: 0.0,
    landing_z: 0.0,
    turret_count: 2,
    building_count: 3,
    difficulty: 2,
    allowed_aircraft: -1,
    time_limit: 0.0,
    briefing: "Enemy ground installations detected. Destroy all targets in the area.",
  })
  // Mission 2: Dogfight
  m.push({
    name: "Dogfight",
    kind: mission_dogfight,
    description: "Shoot down enemy fighters",
    target_count: 3,
    targets_done: 0,
    weather: weather_clear,
    enemy_count: 0,
    enemy_air_count: 3,
    has_landing: false,
    landing_x: 0.0,
    landing_z: 0.0,
    turret_count: 0,
    building_count: 0,
    difficulty: 3,
    allowed_aircraft: -1,
    time_limit: 0.0,
    briefing: "Enemy fighters inbound. Engage and destroy all hostile aircraft.",
  })
  // Mission 3: Fog navigation
  m.push({
    name: "Fog Navigation",
    kind: mission_checkpoint,
    description: "Navigate checkpoints in heavy fog",
    target_count: 6,
    targets_done: 0,
    weather: weather_fog,
    enemy_count: 0,
    enemy_air_count: 0,
    has_landing: false,
    landing_x: 0.0,
    landing_z: 0.0,
    turret_count: 0,
    building_count: 0,
    difficulty: 3,
    allowed_aircraft: -1,
    time_limit: 0.0,
    briefing: "Heavy fog reported. Navigate using instruments to reach all waypoints.",
  })
  // Mission 4: Landing challenge
  m.push({
    name: "Emergency Landing",
    kind: mission_landing,
    description: "Land at the marked runway",
    target_count: 1,
    targets_done: 0,
    weather: weather_clear,
    enemy_count: 0,
    enemy_air_count: 0,
    has_landing: true,
    landing_x: 50.0,
    landing_z: 50.0,
    turret_count: 0,
    building_count: 4,
    difficulty: 2,
    allowed_aircraft: -1,
    time_limit: 0.0,
    briefing: "Fuel is low. Locate the runway and land safely. Reduce speed and align carefully.",
  })
  // Mission 5: Mixed assault
  m.push({
    name: "Valley Assault",
    kind: mission_destroy,
    description: "Clear the valley of enemies",
    target_count: 6,
    targets_done: 0,
    weather: weather_clear,
    enemy_count: 3,
    enemy_air_count: 3,
    has_landing: false,
    landing_x: 0.0,
    landing_z: 0.0,
    turret_count: 2,
    building_count: 4,
    difficulty: 4,
    allowed_aircraft: -1,
    time_limit: 0.0,
    briefing: "A valley stronghold must be cleared. Engage both air and ground threats.",
  })
  // Mission 6: Storm run
  m.push({
    name: "Storm Runner",
    kind: mission_checkpoint,
    description: "Fly through rings in a storm",
    target_count: 7,
    targets_done: 0,
    weather: weather_storm,
    enemy_count: 0,
    enemy_air_count: 0,
    has_landing: false,
    landing_x: 0.0,
    landing_z: 0.0,
    turret_count: 0,
    building_count: 0,
    difficulty: 5,
    allowed_aircraft: -1,
    time_limit: 0.0,
    briefing: "A massive storm is rolling in. Navigate through checkpoint rings despite turbulence.",
  })
  // Mission 7: Air superiority
  m.push({
    name: "Air Superiority",
    kind: mission_intercept,
    description: "Defeat the enemy squadron",
    target_count: 5,
    targets_done: 0,
    weather: weather_cloudy,
    enemy_count: 0,
    enemy_air_count: 5,
    has_landing: false,
    landing_x: 0.0,
    landing_z: 0.0,
    turret_count: 0,
    building_count: 0,
    difficulty: 5,
    allowed_aircraft: -1,
    time_limit: 120.0,
    briefing: "A large enemy formation approaches. Intercept and destroy all hostile aircraft.",
  })
  // Mission 8: Base raid - bombing run
  m.push({
    name: "Base Raid",
    kind: mission_bombing_run,
    description: "Destroy enemy base installations",
    target_count: 6,
    targets_done: 0,
    weather: weather_fog,
    enemy_count: 2,
    enemy_air_count: 2,
    has_landing: false,
    landing_x: 0.0,
    landing_z: 0.0,
    turret_count: 4,
    building_count: 6,
    difficulty: 6,
    allowed_aircraft: -1,
    time_limit: 0.0,
    briefing: "Enemy base located. Bomb key installations while evading AA fire.",
  })
  // Mission 9: Survive
  m.push({
    name: "Survival",
    kind: mission_survive,
    description: "Survive for 60 seconds",
    target_count: 60,
    targets_done: 0,
    weather: weather_clear,
    enemy_count: 2,
    enemy_air_count: 4,
    has_landing: false,
    landing_x: 0.0,
    landing_z: 0.0,
    turret_count: 3,
    building_count: 0,
    difficulty: 5,
    allowed_aircraft: -1,
    time_limit: 60.0,
    briefing: "You are surrounded. Survive for 60 seconds until reinforcements arrive.",
  })
  // Mission 10: Night mission
  m.push({
    name: "Night Recon",
    kind: mission_recon,
    description: "Photograph targets at night",
    target_count: 4,
    targets_done: 0,
    weather: weather_night,
    enemy_count: 2,
    enemy_air_count: 1,
    has_landing: false,
    landing_x: 0.0,
    landing_z: 0.0,
    turret_count: 2,
    building_count: 4,
    difficulty: 6,
    allowed_aircraft: -1,
    time_limit: 0.0,
    briefing: "Fly over enemy positions at night. Pass near each target to photograph it.",
  })
  // Mission 11: Canyon run
  m.push({
    name: "Canyon Run",
    kind: mission_canyon_run,
    description: "High speed canyon checkpoint run",
    target_count: 8,
    targets_done: 0,
    weather: weather_clear,
    enemy_count: 2,
    enemy_air_count: 2,
    has_landing: false,
    landing_x: 0.0,
    landing_z: 0.0,
    turret_count: 3,
    building_count: 0,
    difficulty: 7,
    allowed_aircraft: -1,
    time_limit: 90.0,
    briefing: "Fly through the canyon at high speed. Hit all checkpoints before time runs out.",
  })
  // Mission 12: Base defense
  m.push({
    name: "Base Defense",
    kind: mission_defense,
    description: "Defend the base from attack",
    target_count: 8,
    targets_done: 0,
    weather: weather_rain,
    enemy_count: 4,
    enemy_air_count: 4,
    has_landing: false,
    landing_x: 0.0,
    landing_z: 0.0,
    turret_count: 0,
    building_count: 6,
    difficulty: 7,
    allowed_aircraft: -1,
    time_limit: 90.0,
    briefing: "Enemy forces are attacking our base. Shoot down all attackers before buildings fall.",
  })
  // Mission 13: Storm survival
  m.push({
    name: "Storm Survival",
    kind: mission_survive,
    description: "Survive 90 seconds in storm",
    target_count: 90,
    targets_done: 0,
    weather: weather_storm,
    enemy_count: 3,
    enemy_air_count: 5,
    has_landing: false,
    landing_x: 0.0,
    landing_z: 0.0,
    turret_count: 4,
    building_count: 0,
    difficulty: 8,
    allowed_aircraft: -1,
    time_limit: 90.0,
    briefing: "Extreme weather. Survive the onslaught for 90 seconds in a violent storm.",
  })
  // Mission 14: Final mission - boss
  m.push({
    name: "Final Sortie",
    kind: mission_boss,
    description: "Eliminate the ace commander",
    target_count: 10,
    targets_done: 0,
    weather: weather_storm,
    enemy_count: 5,
    enemy_air_count: 5,
    has_landing: false,
    landing_x: 0.0,
    landing_z: 0.0,
    turret_count: 6,
    building_count: 8,
    difficulty: 10,
    allowed_aircraft: -1,
    time_limit: 0.0,
    briefing: "The enemy ace and his full squadron defend their fortress. Destroy everything.",
  })
  m
}
