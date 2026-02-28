// Waypoint for track definition
///|
pub(all) struct Waypoint {
  x : Float
  y : Float
  z : Float
}

// Track segment metadata

///|
pub(all) struct TrackSegment {
  mut seg_type : Int
  mut surface_type : Int
  mut width_mult : Float
  mut banking : Float
  mut has_item_boxes : Bool
  mut decoration_type : Int
  mut is_ramp : Bool
  mut ramp_height : Float
}

///|
pub fn TrackSegment::default() -> TrackSegment {
  {
    seg_type: seg_straight,
    surface_type: surface_road,
    width_mult: 1.0,
    banking: 0.0,
    has_item_boxes: false,
    decoration_type: 0,
    is_ramp: false,
    ramp_height: 0.0,
  }
}

// Kart entity

///|
pub(all) struct Kart {
  mut active : Bool
  mut character_id : Int
  mut kart_type : Int
  mut x : Float
  mut y : Float
  mut z : Float
  mut angle : Float
  mut speed : Float
  mut steer : Float
  mut vy : Float
  mut on_ground : Bool
  mut lap : Int
  mut waypoint_idx : Int
  mut waypoint_progress : Float
  mut total_progress : Float
  mut place : Int
  mut held_powerup : Int
  mut item_count : Int
  mut boost_timer : Float
  mut boost_power : Float
  mut shield_timer : Float
  mut drift_left : Bool
  mut drift_right : Bool
  mut drift_timer : Float
  mut drift_level : Int
  mut drift_angle : Float
  mut spin_timer : Float
  mut stunned_timer : Float
  mut invincible_timer : Float
  mut star_timer : Float
  mut lightning_timer : Float
  mut finish_time : Float
  mut finished : Bool
  mut is_player : Bool
  mut on_surface_type : Int
  mut wrong_way : Bool
  mut wrong_way_timer : Float
  mut air_timer : Float
  mut bounce_timer : Float
  mut race_time : Float
  mut lap_times : Array[Float]
  mut best_lap : Float
  // AI fields
  mut ai_steer_target : Float
  mut ai_accel : Float
  mut ai_use_item_timer : Float
  mut ai_difficulty : Int
  mut ai_line_offset : Float
  mut ai_reaction_timer : Float
  mut ai_brake_timer : Float
}

///|
pub fn Kart::inactive() -> Kart {
  {
    active: false,
    character_id: 0,
    kart_type: kart_type_balanced,
    x: 0.0,
    y: 0.0,
    z: 0.0,
    angle: 0.0,
    speed: 0.0,
    steer: 0.0,
    vy: 0.0,
    on_ground: true,
    lap: 0,
    waypoint_idx: 0,
    waypoint_progress: 0.0,
    total_progress: 0.0,
    place: 0,
    held_powerup: powerup_none,
    item_count: 0,
    boost_timer: 0.0,
    boost_power: 0.0,
    shield_timer: 0.0,
    drift_left: false,
    drift_right: false,
    drift_timer: 0.0,
    drift_level: drift_level_none,
    drift_angle: 0.0,
    spin_timer: 0.0,
    stunned_timer: 0.0,
    invincible_timer: 0.0,
    star_timer: 0.0,
    lightning_timer: 0.0,
    finish_time: 0.0,
    finished: false,
    is_player: false,
    on_surface_type: surface_road,
    wrong_way: false,
    wrong_way_timer: 0.0,
    air_timer: 0.0,
    bounce_timer: 0.0,
    race_time: 0.0,
    lap_times: [],
    best_lap: 999.0,
    ai_steer_target: 0.0,
    ai_accel: 0.0,
    ai_use_item_timer: 0.0,
    ai_difficulty: ai_difficulty_medium,
    ai_line_offset: 0.0,
    ai_reaction_timer: 0.0,
    ai_brake_timer: 0.0,
  }
}

// Powerup pickup on track

///|
pub(all) struct Powerup {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut z : Float
  mut kind : Int
  mut respawn_timer : Float
  mut collected : Bool
  mut bob_offset : Float
}

///|
pub fn Powerup::inactive() -> Powerup {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    z: 0.0,
    kind: powerup_none,
    respawn_timer: 0.0,
    collected: false,
    bob_offset: 0.0,
  }
}

// Dropped item on track (banana, oil slick)

///|
pub(all) struct DroppedItem {
  mut active : Bool
  mut item_type : Int
  mut x : Float
  mut y : Float
  mut z : Float
  mut lifetime : Float
  mut owner : Int
  mut rotation : Float
}

///|
pub fn DroppedItem::inactive() -> DroppedItem {
  {
    active: false,
    item_type: powerup_none,
    x: 0.0,
    y: 0.0,
    z: 0.0,
    lifetime: 0.0,
    owner: -1,
    rotation: 0.0,
  }
}

// Projectile (missile)

///|
pub(all) struct Projectile {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut z : Float
  mut angle : Float
  mut speed : Float
  mut owner : Int
  mut life : Float
  mut target_kart : Int
  mut homing_strength : Float
}

///|
pub fn Projectile::inactive() -> Projectile {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    z: 0.0,
    angle: 0.0,
    speed: 0.0,
    owner: -1,
    life: 0.0,
    target_kart: -1,
    homing_strength: 2.0,
  }
}

// Particle

///|
pub(all) struct Particle {
  mut active : Bool
  mut particle_type : Int
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

// Particle types

///|
pub let particle_drift_spark : Int = 0

///|
pub let particle_boost_flame : Int = 1

///|
pub let particle_dust : Int = 2

///|
pub let particle_splash : Int = 3

///|
pub let particle_explosion : Int = 4

///|
pub let particle_star_sparkle : Int = 5

///|
pub let particle_lightning : Int = 6

///|
pub fn Particle::inactive() -> Particle {
  {
    active: false,
    particle_type: 0,
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
    size: 0.05,
  }
}

// Cup standings

///|
pub(all) struct CupStanding {
  mut points : Array[Int]
}

// Track data for a single track

///|
pub(all) struct TrackData {
  mut track_name : String
  mut theme : Int
  mut lap_count : Int
  mut cup_index : Int
  mut segments : Array[TrackSegment]
}

///|
pub fn TrackData::default() -> TrackData {
  {
    track_name: "Unknown",
    theme: theme_circuit,
    lap_count: total_laps,
    cup_index: 0,
    segments: [],
  }
}

// Race result for a single kart

///|
pub(all) struct RaceResult {
  mut kart_index : Int
  mut position : Int
  mut finish_time : Float
  mut best_lap : Float
  mut points_earned : Int
}

///|
pub fn RaceResult::default() -> RaceResult {
  {
    kart_index: 0,
    position: 0,
    finish_time: 0.0,
    best_lap: 999.0,
    points_earned: 0,
  }
}

// Main Game struct

///|
pub(all) struct Game {
  mut state : Int

  // Race info
  mut current_cup : Int
  mut current_race : Int
  mut race_time : Float
  mut countdown_timer : Float
  mut best_lap_time : Float
  mut current_lap_time : Float
  mut lap_start_time : Float

  // Track
  waypoints : Array[Waypoint]
  mut waypoint_count : Int
  segments : Array[TrackSegment]
  mut track_theme : Int
  mut track_name : String

  // Entity pools
  karts : Array[Kart]
  powerups : Array[Powerup]
  projectiles : Array[Projectile]
  particles : Array[Particle]
  dropped_items : Array[DroppedItem]

  // Cup points (index = kart index)
  cup_points : Array[Int]

  // Race results history
  race_results : Array[RaceResult]

  // Camera
  mut camera_x : Float
  mut camera_y : Float
  mut camera_z : Float
  mut camera_look_x : Float
  mut camera_look_y : Float
  mut camera_look_z : Float
  mut camera_fov : Float
  mut camera_shake : Float

  // UI
  mut menu_cursor : Int
  mut menu_blink : Float
  mut results_scroll : Float
  mut selected_kart_type : Int
  mut selected_character : Int
  mut kart_select_cursor : Int
  mut wrong_way_flash : Float

  // Lightning effect
  mut lightning_active : Bool
  mut lightning_timer : Float
  mut lightning_source : Int

  // Star effect visuals
  mut star_rainbow_timer : Float

  // RNG
  mut rng_state : Int
  mut frame_counter : Int

  // Track preview
  mut preview_rotation : Float
  mut preview_timer : Float

  // Lap tracking
  mut fastest_lap_kart : Int
  mut fastest_lap_time : Float
}

///|
pub fn Game::new() -> Game {
  {
    state: state_menu,
    current_cup: 0,
    current_race: 0,
    race_time: 0.0,
    countdown_timer: countdown_total,
    best_lap_time: 999.0,
    current_lap_time: 0.0,
    lap_start_time: 0.0,
    waypoints: {
      let arr : Array[Waypoint] = []
      for i = 0; i < max_waypoints; i = i + 1 {
        arr.push({ x: 0.0, y: 0.0, z: 0.0 })
        ignore(i)
      }
      arr
    },
    waypoint_count: 0,
    segments: {
      let arr : Array[TrackSegment] = []
      for i = 0; i < max_waypoints; i = i + 1 {
        arr.push(TrackSegment::default())
        ignore(i)
      }
      arr
    },
    track_theme: theme_circuit,
    track_name: "",
    karts: {
      let arr : Array[Kart] = []
      for i = 0; i < max_karts; i = i + 1 {
        arr.push(Kart::inactive())
        ignore(i)
      }
      arr
    },
    powerups: Array::make(max_powerups, Powerup::inactive()),
    projectiles: Array::make(max_projectiles, Projectile::inactive()),
    particles: Array::make(max_particles, Particle::inactive()),
    dropped_items: Array::make(max_dropped_items, DroppedItem::inactive()),
    cup_points: Array::make(max_karts, 0),
    race_results: [],
    camera_x: 0.0,
    camera_y: camera_height,
    camera_z: 0.0,
    camera_look_x: 0.0,
    camera_look_y: 0.0,
    camera_look_z: 0.0,
    camera_fov: camera_fovy,
    camera_shake: 0.0,
    menu_cursor: 0,
    menu_blink: 0.0,
    results_scroll: 0.0,
    selected_kart_type: 0,
    selected_character: 0,
    kart_select_cursor: 0,
    wrong_way_flash: 0.0,
    lightning_active: false,
    lightning_timer: 0.0,
    lightning_source: -1,
    star_rainbow_timer: 0.0,
    rng_state: 54321,
    frame_counter: 0,
    preview_rotation: 0.0,
    preview_timer: 0.0,
    fastest_lap_kart: -1,
    fastest_lap_time: 999.0,
  }
}
