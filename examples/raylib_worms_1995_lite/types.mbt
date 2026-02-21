///|
struct Tank {
  mut active : Bool
  mut is_player : Bool
  mut player_index : Int
  enemy_kind : Int
  mut elite_rank : Int
  mut overheat : Float
  mut x : Float
  mut y : Float
  mut spawn_x : Float
  mut spawn_y : Float
  mut dir : Int
  mut move_speed : Float
  mut hp : Int
  mut max_hp : Int
  mut reload_timer : Float
  mut reload_delay : Float
  mut ai_move_timer : Float
  mut ai_fire_timer : Float
  mut ai_stuck_timer : Float
  mut freeze_timer : Float
  mut shield_timer : Float
  mut invuln_timer : Float
  mut respawn_timer : Float
  mut lives : Int
  mut score : Int
  mut weapon_level : Int
  mut grenade_stock : Int
  mut grenade_cooldown : Float
  mut guard_timer : Float
  mut guard_cooldown_timer : Float
  mut spin_timer : Float
  mut spin_cooldown_timer : Float
  mut blink_timer : Float
  mut skid_timer : Float
}

///|
fn Tank::inactive() -> Tank {
  {
    active: false,
    is_player: false,
    player_index: 0,
    enemy_kind: enemy_basic,
    elite_rank: 0,
    overheat: 0.0,
    x: 0.0,
    y: 0.0,
    spawn_x: 0.0,
    spawn_y: 0.0,
    dir: dir_up,
    move_speed: speed_enemy_basic,
    hp: 1,
    max_hp: 1,
    reload_timer: 0.0,
    reload_delay: enemy_reload_base,
    ai_move_timer: 0.0,
    ai_fire_timer: 0.0,
    ai_stuck_timer: 0.0,
    freeze_timer: 0.0,
    shield_timer: 0.0,
    invuln_timer: 0.0,
    respawn_timer: 0.0,
    lives: 0,
    score: 0,
    weapon_level: 0,
    grenade_stock: 0,
    grenade_cooldown: 0.0,
    guard_timer: 0.0,
    guard_cooldown_timer: 0.0,
    spin_timer: 0.0,
    spin_cooldown_timer: 0.0,
    blink_timer: 0.0,
    skid_timer: 0.0,
  }
}

///|
fn Tank::new_player(index : Int, spawn_x : Float, spawn_y : Float) -> Tank {
  {
    active: true,
    is_player: true,
    player_index: index,
    enemy_kind: enemy_basic,
    elite_rank: 0,
    overheat: 0.0,
    x: spawn_x,
    y: spawn_y,
    spawn_x,
    spawn_y,
    dir: dir_up,
    move_speed: speed_player,
    hp: 1,
    max_hp: 1,
    reload_timer: 0.0,
    reload_delay: player_reload_base,
    ai_move_timer: 0.0,
    ai_fire_timer: 0.0,
    ai_stuck_timer: 0.0,
    freeze_timer: 0.0,
    shield_timer: 0.0,
    invuln_timer: player_invuln_spawn,
    respawn_timer: 0.0,
    lives: 3,
    score: 0,
    weapon_level: 0,
    grenade_stock: player_grenade_stock_base,
    grenade_cooldown: 0.0,
    guard_timer: 0.0,
    guard_cooldown_timer: 0.0,
    spin_timer: 0.0,
    spin_cooldown_timer: 0.0,
    blink_timer: 0.0,
    skid_timer: 0.0,
  }
}

///|
fn Tank::new_enemy(kind : Int, spawn_x : Float, spawn_y : Float) -> Tank {
  let (speed, hp, reload) = if kind == enemy_fast {
    (speed_enemy_fast, 1, enemy_reload_base * 0.85)
  } else if kind == enemy_heavy {
    (speed_enemy_heavy, 4, enemy_reload_base * 1.35)
  } else if kind == enemy_sniper {
    (speed_enemy_sniper, 2, enemy_reload_base * 0.72)
  } else {
    (speed_enemy_basic, 1, enemy_reload_base)
  }
  {
    active: true,
    is_player: false,
    player_index: 0,
    enemy_kind: kind,
    elite_rank: 0,
    overheat: 0.0,
    x: spawn_x,
    y: spawn_y,
    spawn_x,
    spawn_y,
    dir: dir_down,
    move_speed: speed,
    hp,
    max_hp: hp,
    reload_timer: 0.0,
    reload_delay: reload,
    ai_move_timer: 0.12,
    ai_fire_timer: 0.35,
    ai_stuck_timer: 0.0,
    freeze_timer: 0.0,
    shield_timer: 0.0,
    invuln_timer: 1.0,
    respawn_timer: 0.0,
    lives: 0,
    score: 0,
    weapon_level: 0,
    grenade_stock: 0,
    grenade_cooldown: 0.0,
    guard_timer: 0.0,
    guard_cooldown_timer: 0.0,
    spin_timer: 0.0,
    spin_cooldown_timer: 0.0,
    blink_timer: 0.0,
    skid_timer: 0.0,
  }
}

///|
struct Bullet {
  mut active : Bool
  mut owner_team : Int
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut ttl : Float
  mut damage : Int
  mut power : Int
  mut radius : Float
}

///|
fn Bullet::inactive() -> Bullet {
  {
    active: false,
    owner_team: team_none,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    ttl: 0.0,
    damage: 1,
    power: 1,
    radius: bullet_radius,
  }
}

///|
struct Grenade {
  mut active : Bool
  mut owner_team : Int
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut fuse : Float
  mut blast_radius : Float
  mut power : Int
  mut spin : Float
}

///|
fn Grenade::inactive() -> Grenade {
  {
    active: false,
    owner_team: team_none,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    fuse: 0.0,
    blast_radius: grenade_blast_radius,
    power: 1,
    spin: 0.0,
  }
}

///|
struct Particle {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut life : Float
  mut max_life : Float
  mut size : Float
  mut spin : Float
  mut rot : Float
  mut fade : Float
  mut color : @raylib.Color
}

///|
fn Particle::inactive() -> Particle {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    life: 0.0,
    max_life: 1.0,
    size: 1.0,
    spin: 0.0,
    rot: 0.0,
    fade: 0.0,
    color: @raylib.white,
  }
}

///|
struct Powerup {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut ttl : Float
  mut blink : Float
  mut pulse : Float
}

///|
fn Powerup::inactive() -> Powerup {
  {
    active: false,
    kind: powerup_shield,
    x: 0.0,
    y: 0.0,
    ttl: 0.0,
    blink: 0.0,
    pulse: 0.0,
  }
}

///|
struct BioCore {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut hp : Int
  mut max_hp : Int
  mut pulse : Float
  mut flash : Float
}

///|
fn BioCore::inactive() -> BioCore {
  { active: false, x: 0.0, y: 0.0, hp: 0, max_hp: 1, pulse: 0.0, flash: 0.0 }
}

///|
struct Star {
  mut x : Float
  mut y : Float
  mut speed : Float
  mut twinkle : Float
}

///|
fn Star::new(x : Float, y : Float, speed : Float, twinkle : Float) -> Star {
  { x, y, speed, twinkle }
}

///|
struct StageContract {
  mut kind : Int
  mut name : String
  mut detail : String
  mut goal : Int
  mut progress : Int
  mut completed : Bool
  mut failed : Bool
  mut bonus_score : Int
}

///|
fn StageContract::inactive() -> StageContract {
  {
    kind: contract_none,
    name: "No Contract",
    detail: "",
    goal: 0,
    progress: 0,
    completed: false,
    failed: false,
    bonus_score: 0,
  }
}

///|
struct HazardMarker {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut radius : Float
  mut warn_timer : Float
  mut pulse : Float
  mut damage : Int
}

///|
fn HazardMarker::inactive() -> HazardMarker {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    radius: 0.0,
    warn_timer: 0.0,
    pulse: 0.0,
    damage: 1,
  }
}

///|
struct Game {
  mut state : Int
  mut coop_enabled : Bool
  mut demo_mode : Bool
  mut demo_runs : Int
  mut demo_elapsed : Float
  mut mode_name : String
  mut mode_hint : String
  mut mode_base_required : Bool
  mut mode_timer : Float
  mut mode_goal : Int
  mut mode_goal_b : Int
  mut mode_progress : Int
  mut mode_score_anchor : Int
  mut menu_cursor : Int
  mut menu_blink : Float
  mut frame_counter : Int
  mut stage_index : Int
  mut stage_intro_timer : Float
  mut stage_clear_timer : Float
  mut game_over_timer : Float
  mut campaign_clear_timer : Float
  mut pause_blink : Float
  mut profile : StageProfile
  mut freeze_all_timer : Float
  mut shovel_timer : Float
  mut camera_shake : Float
  mut camera_shake_phase : Float
  mut base_alive : Bool
  mut base_flash : Float
  base_tiles_cached : Array[Int]
  mut score_total : Int
  mut high_score : Int
  mut cores_goal : Int
  mut cores_destroyed : Int
  mut enemies_to_spawn : Int
  mut enemies_spawned : Int
  mut enemies_alive : Int
  mut spawn_timer : Float
  mut kill_combo : Int
  mut combo_timer : Float
  mut stage_timer : Float
  mut stage_deaths : Int
  mut stage_base_losses : Int
  mut stage_elite_kills : Int
  mut stage_hazard_hits : Int
  mut contracts_completed_stage : Int
  mut contracts_completed_total : Int
  mut mission_title : String
  mut mission_brief : String
  mut mutator_name : String
  mut mutator_desc : String
  mut mutator_spawn_scale : Float
  mut mutator_enemy_hp_bonus : Int
  mut mutator_enemy_speed_scale : Float
  mut mutator_score_scale : Float
  mut hazard_spawn_timer : Float
  mut hazard_intensity : Float
  mut rng_state : Int
  map_tiles : Array[Int]
  map_hp : Array[Int]
  players : Array[Tank]
  enemies : Array[Tank]
  bullets : Array[Bullet]
  grenades : Array[Grenade]
  particles : Array[Particle]
  powerups : Array[Powerup]
  cores : Array[BioCore]
  stars : Array[Star]
  stage_contracts : Array[StageContract]
  hazards : Array[HazardMarker]
}

///|
fn Game::new() -> Game {
  let stars : Array[Star] = []
  for i = 0; i < 120; i = i + 1 {
    let x = Float::from_int(@raylib.get_random_value(0, screen_width))
    let y = Float::from_int(@raylib.get_random_value(0, screen_height))
    let speed = Float::from_int(@raylib.get_random_value(12, 85))
    let twinkle = Float::from_int(@raylib.get_random_value(0, 1000)) / 1000.0
    stars.push(Star::new(x, y, speed, twinkle))
  }

  {
    state: state_menu,
    coop_enabled: false,
    demo_mode: false,
    demo_runs: 0,
    demo_elapsed: 0.0,
    mode_name: "Assault",
    mode_hint: "Eliminate all hostiles and secure objective sites.",
    mode_base_required: true,
    mode_timer: 0.0,
    mode_goal: 0,
    mode_goal_b: 0,
    mode_progress: 0,
    mode_score_anchor: 0,
    menu_cursor: 0,
    menu_blink: 0.0,
    frame_counter: 0,
    stage_index: 0,
    stage_intro_timer: 0.0,
    stage_clear_timer: 0.0,
    game_over_timer: 0.0,
    campaign_clear_timer: 0.0,
    pause_blink: 0.0,
    profile: default_stage_profile(),
    freeze_all_timer: 0.0,
    shovel_timer: 0.0,
    camera_shake: 0.0,
    camera_shake_phase: 0.0,
    base_alive: true,
    base_flash: 0.0,
    base_tiles_cached: Array::make(base_ring_count, tile_brick),
    score_total: 0,
    high_score: 0,
    cores_goal: 0,
    cores_destroyed: 0,
    enemies_to_spawn: 20,
    enemies_spawned: 0,
    enemies_alive: 0,
    spawn_timer: 0.0,
    kill_combo: 0,
    combo_timer: 0.0,
    stage_timer: 0.0,
    stage_deaths: 0,
    stage_base_losses: 0,
    stage_elite_kills: 0,
    stage_hazard_hits: 0,
    contracts_completed_stage: 0,
    contracts_completed_total: 0,
    mission_title: "Neon Contract",
    mission_brief: "Clear hostiles and stabilize district control.",
    mutator_name: "Baseline City Grid",
    mutator_desc: "No active district anomaly.",
    mutator_spawn_scale: 1.0,
    mutator_enemy_hp_bonus: 0,
    mutator_enemy_speed_scale: 1.0,
    mutator_score_scale: 1.0,
    hazard_spawn_timer: 0.0,
    hazard_intensity: 0.0,
    rng_state: 0x13572468,
    map_tiles: Array::make(max_tiles, tile_empty),
    map_hp: Array::make(max_tiles, 0),
    players: [
      Tank::new_player(0, player1_spawn_x, player1_spawn_y),
      Tank::new_player(1, player2_spawn_x, player2_spawn_y),
    ],
    enemies: Array::make(max_enemies, Tank::inactive()),
    bullets: Array::make(max_bullets, Bullet::inactive()),
    grenades: Array::make(max_grenades, Grenade::inactive()),
    particles: Array::make(max_particles, Particle::inactive()),
    powerups: Array::make(max_powerups, Powerup::inactive()),
    cores: Array::make(max_cores, BioCore::inactive()),
    stars,
    stage_contracts: Array::make(max_contracts, StageContract::inactive()),
    hazards: Array::make(max_hazards, HazardMarker::inactive()),
  }
}

///|
fn team_of_player(index : Int) -> Int {
  if index == 0 {
    team_player1
  } else {
    team_player2
  }
}
