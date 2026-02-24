///|
struct InputState {
  mut move_x : Int
  mut move_y : Int
  mut press_j : Bool
  mut press_k : Bool
  mut press_space : Bool
  mut press_pause : Bool
  mut press_restart : Bool
  mut press_start : Bool
}

///|
fn InputState::new() -> InputState {
  {
    move_x: 0,
    move_y: 0,
    press_j: false,
    press_k: false,
    press_space: false,
    press_pause: false,
    press_restart: false,
    press_start: false,
  }
}

///|
struct Player {
  mut x : Float
  mut y : Float
  mut facing_x : Float
  mut facing_y : Float
  mut dash_vx : Float
  mut dash_vy : Float
  mut dash_t : Float
  mut dash_cd : Float
  mut attack_cd : Float
  mut attack_t : Float
}

///|
fn Player::new() -> Player {
  {
    x: Float::from_int(world_x + 330),
    y: lane_y(1),
    facing_x: 1.0,
    facing_y: 0.0,
    dash_vx: 0.0,
    dash_vy: 0.0,
    dash_t: 0.0,
    dash_cd: 0.0,
    attack_cd: 0.0,
    attack_t: 0.0,
  }
}

///|
struct Beacon {
  x : Float
  y : Float
  mut integrity : Float
  mut pulse_t : Float
}

///|
fn Beacon::new(index : Int) -> Beacon {
  let (x, y) = beacon_position(index)
  { x, y, integrity: beacon_integrity_max, pulse_t: 0.0 }
}

///|
struct Trap {
  mut active : Bool
  x : Float
  y : Float
  mut trigger_cd : Float
  mut flash_t : Float
}

///|
fn Trap::new(index : Int) -> Trap {
  let (x, y) = trap_slot_position(index)
  { active: false, x, y, trigger_cd: 0.0, flash_t: 0.0 }
}

///|
struct Enemy {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut hp : Float
  mut max_hp : Float
  mut speed : Float
  mut damage : Float
  mut target : Int
  mut slow_t : Float
  mut kind : Int
  mut anim_t : Float
}

///|
fn Enemy::new() -> Enemy {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    hp: 0.0,
    max_hp: 0.0,
    speed: 0.0,
    damage: 0.0,
    target: 0,
    slow_t: 0.0,
    kind: 0,
    anim_t: 0.0,
  }
}

///|
struct Game {
  input : InputState
  player : Player
  beacons : Array[Beacon]
  traps : Array[Trap]
  enemies : Array[Enemy]
  mut state : Int
  mut night : Int
  mut score : Int
  mut best_score : Int
  mut kills : Int
  mut elapsed : Float
  mut energy : Float
  mut sweep_charge : Float
  mut trap_place_cd : Float
  mut spawn_pool : Int
  mut spawn_cd : Float
  mut sweep_t : Float
  mut night_banner_t : Float
  mut status_text : String
  mut status_t : Float
  mut shake_t : Float
  mut game_over_reason : String
}

///|
fn Game::new() -> Game {
  let beacons = Array::makei(beacon_count, fn(i) { Beacon::new(i) })
  let traps = Array::makei(trap_slot_count, fn(i) { Trap::new(i) })
  let enemies = Array::makei(max_enemies, fn(_i) { Enemy::new() })

  {
    input: InputState::new(),
    player: Player::new(),
    beacons,
    traps,
    enemies,
    state: state_title,
    night: 1,
    score: 0,
    best_score: 0,
    kills: 0,
    elapsed: 0.0,
    energy: energy_max,
    sweep_charge: 0.0,
    trap_place_cd: 0.0,
    spawn_pool: 0,
    spawn_cd: 0.0,
    sweep_t: 0.0,
    night_banner_t: 0.0,
    status_text: "Press J / Enter / Space to begin the first night",
    status_t: 2.4,
    shake_t: 0.0,
    game_over_reason: "",
  }
}
