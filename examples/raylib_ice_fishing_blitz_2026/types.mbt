///|
struct Fish {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut r : Float
  mut value : Int
  mut kind : Int
  mut phase : Float
  mut hooked : Bool
}

///|
struct Hazard {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut r : Float
  mut dmg : Float
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
  fish : Array[Fish]
  hazards : Array[Hazard]
  pickups : Array[Pickup]
  particles : Array[Particle]
  mut state : Int
  mut hook_x : Float
  mut hook_y : Float
  mut hook_vx : Float
  mut hook_vy : Float
  mut line_len : Float
  mut move_x : Float
  mut move_y : Float
  mut grab_on : Bool
  mut boost_on : Bool
  mut carrying_idx : Int
  mut lives : Int
  mut line_hp : Float
  mut bait : Float
  mut turbo_t : Float
  mut repair_cd : Float
  mut score : Int
  mut best_score : Int
  mut caught : Int
  mut escaped : Int
  mut wave : Int
  mut combo : Int
  mut combo_t : Float
  mut fish_spawn_t : Float
  mut hazard_spawn_t : Float
  mut pickup_spawn_t : Float
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
fn Fish::new() -> Fish {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    r: 0.0,
    value: 0,
    kind: fish_trout,
    phase: 0.0,
    hooked: false,
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
    dmg: 0.0,
    kind: hazard_jelly,
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
    kind: pickup_bait,
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
    fish: Array::makei(max_fish, fn(_i) { Fish::new() }),
    hazards: Array::makei(max_hazards, fn(_i) { Hazard::new() }),
    pickups: Array::makei(max_pickups, fn(_i) { Pickup::new() }),
    particles: Array::makei(max_particles, fn(_i) { Particle::new() }),
    state: state_title,
    hook_x: Float::from_int(hole_x),
    hook_y: Float::from_int(water_top + 70),
    hook_vx: 0.0,
    hook_vy: 0.0,
    line_len: 70.0,
    move_x: 0.0,
    move_y: 0.0,
    grab_on: false,
    boost_on: false,
    carrying_idx: -1,
    lives: 3,
    line_hp: 100.0,
    bait: 100.0,
    turbo_t: 0.0,
    repair_cd: 0.0,
    score: 0,
    best_score: 0,
    caught: 0,
    escaped: 0,
    wave: 1,
    combo: 0,
    combo_t: 0.0,
    fish_spawn_t: 0.0,
    hazard_spawn_t: 0.0,
    pickup_spawn_t: 0.0,
    game_t: 0.0,
    ui_t: 0.0,
    hint_left: 3,
    hint_t: 0.0,
    hint_x: Float::from_int(hole_x),
    hint_y: Float::from_int(water_top + 200),
    msg: "",
    msg_t: 0.0,
    shake_t: 0.0,
    touch_cd: 0.0,
    win: false,
  }
}
