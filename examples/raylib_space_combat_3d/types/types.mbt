// Player ship
///|
pub(all) struct Player {
  mut x : Float
  mut y : Float
  mut z : Float
  mut yaw : Float
  mut pitch : Float
  mut roll : Float
  mut vx : Float
  mut vy : Float
  mut vz : Float
  mut hull : Float
  mut max_hull : Float
  mut shield : Float
  mut max_shield : Float
  mut shield_timer : Float
  mut weapon : Int
  mut fire_timer : Float
  mut boosting : Bool
  mut speed : Float
  mut ship_class : Int
  mut turn_rate : Float
  mut weapon_level : Int
  mut missile_ammo : Int
  mut weapon_energy : Float
  mut boost_fuel : Float
  mut weapon_boost_timer : Float
  mut speed_boost_timer : Float
  mut damage_flash : Float
  mut strafe_x : Float
  mut strafe_y : Float
  mut kills : Int
  mut shots_fired : Int
  mut shots_hit : Int
}

///|
pub fn Player::new() -> Player {
  {
    x: 0.0,
    y: 0.0,
    z: 0.0,
    yaw: 0.0,
    pitch: 0.0,
    roll: 0.0,
    vx: 0.0,
    vy: 0.0,
    vz: 0.0,
    hull: player_max_hull,
    max_hull: player_max_hull,
    shield: player_max_shield,
    max_shield: player_max_shield,
    shield_timer: 0.0,
    weapon: weapon_laser,
    fire_timer: 0.0,
    boosting: false,
    speed: player_speed,
    ship_class: ship_fighter,
    turn_rate: player_turn_speed,
    weapon_level: 1,
    missile_ammo: missile_max_ammo,
    weapon_energy: max_weapon_energy,
    boost_fuel: max_boost_fuel,
    weapon_boost_timer: 0.0,
    speed_boost_timer: 0.0,
    damage_flash: 0.0,
    strafe_x: 0.0,
    strafe_y: 0.0,
    kills: 0,
    shots_fired: 0,
    shots_hit: 0,
  }
}

// Enemy entity

///|
pub(all) struct Enemy {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut z : Float
  mut vx : Float
  mut vy : Float
  mut vz : Float
  mut yaw : Float
  mut pitch : Float
  mut hp : Float
  mut max_hp : Float
  mut shield_hp : Float
  mut max_shield_hp : Float
  mut fire_timer : Float
  mut ai_timer : Float
  mut ai_state : Int
  mut score_value : Int
  mut size : Float
  mut squad_id : Int
  mut formation_index : Int
  mut aggression : Float
  mut flee_threshold : Float
  mut detect_range : Float
  mut damage_flash : Float
  mut patrol_x : Float
  mut patrol_y : Float
  mut patrol_z : Float
  mut turret_timer_1 : Float
  mut turret_timer_2 : Float
  mut weak_point_hp : Float
}

///|
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
    yaw: 0.0,
    pitch: 0.0,
    hp: 0.0,
    max_hp: 1.0,
    shield_hp: 0.0,
    max_shield_hp: 0.0,
    fire_timer: 0.0,
    ai_timer: 0.0,
    ai_state: ai_idle,
    score_value: 100,
    size: 1.0,
    squad_id: -1,
    formation_index: 0,
    aggression: 0.5,
    flee_threshold: 0.15,
    detect_range: 120.0,
    damage_flash: 0.0,
    patrol_x: 0.0,
    patrol_y: 0.0,
    patrol_z: 0.0,
    turret_timer_1: 0.0,
    turret_timer_2: 0.0,
    weak_point_hp: 0.0,
  }
}

// Projectile

///|
pub(all) struct Projectile {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut z : Float
  mut vx : Float
  mut vy : Float
  mut vz : Float
  mut damage : Float
  mut life : Float
  mut from_player : Bool
  mut target_idx : Int
  mut size : Float
  mut fuel : Float
  mut piercing : Bool
}

///|
pub fn Projectile::inactive() -> Projectile {
  {
    active: false,
    kind: 0,
    x: 0.0,
    y: 0.0,
    z: 0.0,
    vx: 0.0,
    vy: 0.0,
    vz: 0.0,
    damage: 0.0,
    life: 0.0,
    from_player: true,
    target_idx: -1,
    size: 0.1,
    fuel: 0.0,
    piercing: false,
  }
}

// Particle effect

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
  mut kind : Int
}

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
    kind: 0,
  }
}

// Asteroid

///|
pub(all) struct Asteroid {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut z : Float
  mut vx : Float
  mut vy : Float
  mut vz : Float
  mut rot_x : Float
  mut rot_y : Float
  mut rot_z : Float
  mut rot_speed : Float
  mut hp : Float
  mut size : Float
  mut size_tier : Int
  mut breakable : Bool
}

///|
pub fn Asteroid::inactive() -> Asteroid {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    z: 0.0,
    vx: 0.0,
    vy: 0.0,
    vz: 0.0,
    rot_x: 0.0,
    rot_y: 0.0,
    rot_z: 0.0,
    rot_speed: 0.5,
    hp: 50.0,
    size: 2.0,
    size_tier: asteroid_large,
    breakable: true,
  }
}

// Power-up

///|
pub(all) struct PowerUp {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut z : Float
  mut bob_timer : Float
  mut spin_angle : Float
  mut life : Float
}

///|
pub fn PowerUp::inactive() -> PowerUp {
  {
    active: false,
    kind: 0,
    x: 0.0,
    y: 0.0,
    z: 0.0,
    bob_timer: 0.0,
    spin_angle: 0.0,
    life: 30.0,
  }
}

// Space Station

///|
pub(all) struct SpaceStation {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut z : Float
  mut hp : Float
  mut max_hp : Float
  mut rot_angle : Float
  mut ring_angle : Float
}

///|
pub fn SpaceStation::inactive() -> SpaceStation {
  {
    active: false,
    kind: station_friendly,
    x: 0.0,
    y: 0.0,
    z: 0.0,
    hp: station_hp,
    max_hp: station_hp,
    rot_angle: 0.0,
    ring_angle: 0.0,
  }
}

// Debris piece from destroyed ships

///|
pub(all) struct Debris {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut z : Float
  mut vx : Float
  mut vy : Float
  mut vz : Float
  mut rot_x : Float
  mut rot_y : Float
  mut rot_speed : Float
  mut life : Float
  mut size : Float
  mut r : Int
  mut g : Int
  mut b : Int
}

///|
pub fn Debris::inactive() -> Debris {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    z: 0.0,
    vx: 0.0,
    vy: 0.0,
    vz: 0.0,
    rot_x: 0.0,
    rot_y: 0.0,
    rot_speed: 1.0,
    life: 5.0,
    size: 0.3,
    r: 150,
    g: 130,
    b: 100,
  }
}

// Kill feed entry

///|
pub(all) struct KillFeedEntry {
  mut active : Bool
  mut text : String
  mut timer : Float
  mut r : Int
  mut g : Int
  mut b : Int
}

///|
pub fn KillFeedEntry::inactive() -> KillFeedEntry {
  { active: false, text: "", timer: 0.0, r: 255, g: 255, b: 255 }
}

// Mission Objective

///|
pub(all) struct MissionObjective {
  mut obj_type : Int
  mut target_count : Int
  mut current_count : Int
  mut complete : Bool
  mut description : String
}

///|
pub fn MissionObjective::new(
  obj_type : Int,
  target_count : Int,
  description : String,
) -> MissionObjective {
  { obj_type, target_count, current_count: 0, complete: false, description }
}

// Background star

///|
pub(all) struct Star {
  x : Float
  y : Float
  z : Float
  brightness : Int
  r : Int
  g : Int
  b : Int
}

// Main Game struct

///|
pub(all) struct Game {
  mut state : Int

  // Player
  player : Player

  // Targeting
  mut target_idx : Int
  mut target_lock_timer : Float

  // Score / mission
  mut score : Int
  mut current_mission : Int
  mut enemies_remaining : Int
  mut mission_timer : Float
  mut total_kills : Int

  // Combo system
  mut combo_count : Int
  mut combo_timer : Float
  mut combo_multiplier : Float

  // Mission objectives
  objectives : Array[MissionObjective]
  mut objectives_count : Int

  // Entity pools
  enemies : Array[Enemy]
  projectiles : Array[Projectile]
  particles : Array[Particle]
  asteroids : Array[Asteroid]
  powerups : Array[PowerUp]
  stations : Array[SpaceStation]
  debris : Array[Debris]
  stars : Array[Star]

  // Kill feed
  kill_feed : Array[KillFeedEntry]

  // Camera
  mut camera_shake : Float

  // UI
  mut menu_cursor : Int
  mut menu_blink : Float
  mut message_text : String
  mut message_timer : Float
  mut briefing_scroll : Int

  // Pause menu
  mut pause_cursor : Int

  // Mission select
  mut select_cursor : Int

  // Loadout
  mut loadout_cursor : Int
  mut selected_ship_class : Int

  // Wave spawning
  mut wave_timer : Float
  mut wave_number : Int
  mut waves_total : Int

  // Mission stats
  mut mission_time : Float
  mut mission_kills : Int

  // Damage flash overlay
  mut screen_flash : Float
  mut flash_r : Int
  mut flash_g : Int
  mut flash_b : Int

  // RNG
  mut rng_state : Int
  mut frame_counter : Int
}

///|
pub fn Game::new() -> Game {
  let stars_arr : Array[Star] = []
  let mut rng = 54321
  for i = 0; i < max_stars; i = i + 1 {
    rng = xor_rng(rng)
    let sx = rand_float_from(rng, -world_size, world_size)
    rng = xor_rng(rng)
    let sy = rand_float_from(rng, -world_size, world_size)
    rng = xor_rng(rng)
    let sz = rand_float_from(rng, -world_size, world_size)
    rng = xor_rng(rng)
    let bright = 100 + xor_rng_abs(rng) % 156
    // Slight color variation for stars
    rng = xor_rng(rng)
    let color_type = xor_rng_abs(rng) % 5
    let sr : Int = if color_type == 0 {
      bright
    } else if color_type == 1 {
      let v : Int = bright + 30
      if v > 255 {
        255
      } else {
        v
      }
    } else if color_type == 2 {
      let v : Int = bright - 20
      if v < 80 {
        80
      } else {
        v
      }
    } else {
      bright
    }
    let sg : Int = if color_type == 0 {
      bright
    } else if color_type == 1 {
      let v : Int = bright - 10
      if v < 80 {
        80
      } else {
        v
      }
    } else if color_type == 2 {
      let v : Int = bright + 20
      if v > 255 {
        255
      } else {
        v
      }
    } else {
      bright
    }
    let sb : Int = if color_type == 0 {
      bright
    } else if color_type == 3 {
      let v : Int = bright + 40
      if v > 255 {
        255
      } else {
        v
      }
    } else {
      bright
    }
    stars_arr.push({
      x: sx,
      y: sy,
      z: sz,
      brightness: bright,
      r: sr,
      g: sg,
      b: sb,
    })
    ignore(i)
  }

  let objectives_arr : Array[MissionObjective] = []
  for i = 0; i < 4; i = i + 1 {
    objectives_arr.push(MissionObjective::new(objective_destroy_all, 0, ""))
    ignore(i)
  }

  let kill_feed_arr : Array[KillFeedEntry] = []
  for i = 0; i < max_kill_feed; i = i + 1 {
    kill_feed_arr.push(KillFeedEntry::inactive())
    ignore(i)
  }

  {
    state: state_menu,
    player: Player::new(),
    target_idx: -1,
    target_lock_timer: 0.0,
    score: 0,
    current_mission: 0,
    enemies_remaining: 0,
    mission_timer: 0.0,
    total_kills: 0,
    combo_count: 0,
    combo_timer: 0.0,
    combo_multiplier: 1.0,
    objectives: objectives_arr,
    objectives_count: 0,
    enemies: {
      let arr : Array[Enemy] = []
      for i = 0; i < max_enemies; i = i + 1 {
        arr.push(Enemy::inactive())
        ignore(i)
      }
      arr
    },
    projectiles: {
      let arr : Array[Projectile] = []
      for i = 0; i < max_projectiles; i = i + 1 {
        arr.push(Projectile::inactive())
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
    asteroids: {
      let arr : Array[Asteroid] = []
      for i = 0; i < max_asteroids; i = i + 1 {
        arr.push(Asteroid::inactive())
        ignore(i)
      }
      arr
    },
    powerups: {
      let arr : Array[PowerUp] = []
      for i = 0; i < max_powerups; i = i + 1 {
        arr.push(PowerUp::inactive())
        ignore(i)
      }
      arr
    },
    stations: {
      let arr : Array[SpaceStation] = []
      for i = 0; i < max_stations; i = i + 1 {
        arr.push(SpaceStation::inactive())
        ignore(i)
      }
      arr
    },
    debris: {
      let arr : Array[Debris] = []
      for i = 0; i < max_debris; i = i + 1 {
        arr.push(Debris::inactive())
        ignore(i)
      }
      arr
    },
    stars: stars_arr,
    kill_feed: kill_feed_arr,
    camera_shake: 0.0,
    menu_cursor: 0,
    menu_blink: 0.0,
    message_text: "",
    message_timer: 0.0,
    briefing_scroll: 0,
    pause_cursor: 0,
    select_cursor: 0,
    loadout_cursor: 0,
    selected_ship_class: ship_fighter,
    wave_timer: 0.0,
    wave_number: 0,
    waves_total: 1,
    mission_time: 0.0,
    mission_kills: 0,
    screen_flash: 0.0,
    flash_r: 255,
    flash_g: 0,
    flash_b: 0,
    rng_state: 12345,
    frame_counter: 0,
  }
}

///|
fn xor_rng(state : Int) -> Int {
  let mut x = state
  x = x ^ (x << 13)
  x = x ^ (x >> 17)
  x = x ^ (x << 5)
  x
}

///|
fn xor_rng_abs(state : Int) -> Int {
  let x = xor_rng(state)
  if x < 0 {
    -x
  } else {
    x
  }
}

///|
fn rand_float_from(state : Int, low : Float, high : Float) -> Float {
  let v = xor_rng_abs(state) % 10000
  let n = Float::from_int(v) / 10000.0
  low + (high - low) * n
}
