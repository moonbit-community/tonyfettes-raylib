///|
struct Survivor {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut carried : Bool
  mut panic : Float
  mut phase : Float
}

///|
struct Hazard {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut r : Float
  mut hp : Float
  mut kind : Int
  mut phase : Float
}

///|
struct Pickup {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut kind : Int
  mut phase : Float
}

///|
struct Particle {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut life : Float
  mut size : Float
  mut kind : Int
}

///|
struct Game {
  survivors : Array[Survivor]
  hazards : Array[Hazard]
  pickups : Array[Pickup]
  particles : Array[Particle]
  mut state : Int
  mut heli_x : Float
  mut heli_y : Float
  mut heli_vx : Float
  mut heli_vy : Float
  mut move_x : Float
  mut move_y : Float
  mut boost_on : Bool
  mut hook_len : Float
  mut hook_target : Float
  mut hook_extending : Bool
  mut carrying_idx : Int
  mut lives : Int
  mut hull : Float
  mut fuel : Float
  mut turbo_t : Float
  mut repair_cd : Float
  mut score : Int
  mut best_score : Int
  mut rescued : Int
  mut lost : Int
  mut wave : Int
  mut combo : Int
  mut combo_t : Float
  mut survivor_spawn_t : Float
  mut hazard_spawn_t : Float
  mut pickup_spawn_t : Float
  mut storm_t : Float
  mut game_t : Float
  mut ui_t : Float
  mut hint_left : Int
  mut hint_t : Float
  mut hint_x : Float
  mut hint_y : Float
  mut msg : String
  mut msg_t : Float
  mut shake_t : Float
  mut touch_cd : Float
  mut win : Bool
}

///|
fn Survivor::new() -> Survivor {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    carried: false,
    panic: 0.0,
    phase: 0.0,
  }
}

///|
fn Hazard::new() -> Hazard {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    r: 0.0,
    hp: 0.0,
    kind: hazard_cloud,
    phase: 0.0,
  }
}

///|
fn Pickup::new() -> Pickup {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    kind: pickup_fuel,
    phase: 0.0,
  }
}

///|
fn Particle::new() -> Particle {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    life: 0.0,
    size: 0.0,
    kind: 0,
  }
}

///|
fn Game::new() -> Game {
  {
    survivors: Array::makei(max_survivors, fn(_i) { Survivor::new() }),
    hazards: Array::makei(max_hazards, fn(_i) { Hazard::new() }),
    pickups: Array::makei(max_pickups, fn(_i) { Pickup::new() }),
    particles: Array::makei(max_particles, fn(_i) { Particle::new() }),
    state: state_title,
    heli_x: Float::from_int(world_x0 + world_w / 2),
    heli_y: Float::from_int(world_y0 + world_h - 220),
    heli_vx: 0.0,
    heli_vy: 0.0,
    move_x: 0.0,
    move_y: 0.0,
    boost_on: false,
    hook_len: 46.0,
    hook_target: 46.0,
    hook_extending: false,
    carrying_idx: -1,
    lives: 3,
    hull: 100.0,
    fuel: 100.0,
    turbo_t: 0.0,
    repair_cd: 0.0,
    score: 0,
    best_score: 0,
    rescued: 0,
    lost: 0,
    wave: 1,
    combo: 0,
    combo_t: 0.0,
    survivor_spawn_t: 0.0,
    hazard_spawn_t: 0.0,
    pickup_spawn_t: 0.0,
    storm_t: 0.0,
    game_t: 0.0,
    ui_t: 0.0,
    hint_left: 3,
    hint_t: 0.0,
    hint_x: Float::from_int(world_x0 + world_w / 2),
    hint_y: Float::from_int(world_y0 + world_h / 2),
    msg: "",
    msg_t: 0.0,
    shake_t: 0.0,
    touch_cd: 0.0,
    win: false,
  }
}
