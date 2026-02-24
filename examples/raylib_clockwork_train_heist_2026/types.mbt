///|
struct Actor {
  mut x : Int
  mut y : Int
  mut from_x : Int
  mut from_y : Int
  mut to_x : Int
  mut to_y : Int
  mut fx : Float
  mut fy : Float
  mut t : Float
  mut moving : Bool
}

///|
struct Guard {
  mut active : Bool
  body : Actor
  mut mode : Int
  mut move_cd : Float
  mut stun_t : Float
  mut dir_x : Int
  mut dir_y : Int
  mut patrol_min : Int
  mut patrol_max : Int
  mut seed : Int
  mut alert_t : Float
  mut color_id : Int
}

///|
struct Loot {
  mut active : Bool
  mut x : Int
  mut y : Int
  mut kind : Int
  mut value : Int
}

///|
struct Smoke {
  mut active : Bool
  mut x : Int
  mut y : Int
  mut t : Float
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
  map : Array[Int]
  guards : Array[Guard]
  loots : Array[Loot]
  smokes : Array[Smoke]
  particles : Array[Particle]
  mut state : Int
  player : Actor
  mut lives : Int
  mut score : Int
  mut best_score : Int
  mut loot_taken : Int
  mut vault_open : Bool
  mut time_left : Float
  mut req_dx : Int
  mut req_dy : Int
  mut action_down : Bool
  mut action_pressed : Bool
  mut move_cd : Float
  mut action_cd : Float
  mut smoke_energy : Float
  mut touch_cd : Float
  mut msg : String
  mut msg_t : Float
  mut flash_t : Float
  mut shake_t : Float
  mut time_s : Float
  mut hint_i : Int
  mut win : Bool
  mut loss_reason : String
}

///|
fn Actor::new() -> Actor {
  {
    x: start_x,
    y: start_y,
    from_x: start_x,
    from_y: start_y,
    to_x: start_x,
    to_y: start_y,
    fx: Float::from_int(start_x),
    fy: Float::from_int(start_y),
    t: 1.0,
    moving: false,
  }
}

///|
fn Guard::new() -> Guard {
  {
    active: false,
    body: Actor::new(),
    mode: guard_patrol,
    move_cd: 0.0,
    stun_t: 0.0,
    dir_x: 1,
    dir_y: 0,
    patrol_min: 1,
    patrol_max: 1,
    seed: 1,
    alert_t: 0.0,
    color_id: 0,
  }
}

///|
fn Loot::new() -> Loot {
  { active: false, x: 0, y: 0, kind: loot_gold, value: 0 }
}

///|
fn Smoke::new() -> Smoke {
  { active: false, x: 0, y: 0, t: 0.0 }
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
    map: Array::make(grid_w * grid_h, tile_wall),
    guards: Array::makei(max_guards, fn(_i) { Guard::new() }),
    loots: Array::makei(max_loot, fn(_i) { Loot::new() }),
    smokes: Array::makei(max_smokes, fn(_i) { Smoke::new() }),
    particles: Array::makei(max_particles, fn(_i) { Particle::new() }),
    state: state_title,
    player: Actor::new(),
    lives: 3,
    score: 0,
    best_score: 0,
    loot_taken: 0,
    vault_open: false,
    time_left: run_time_limit,
    req_dx: 0,
    req_dy: 0,
    action_down: false,
    action_pressed: false,
    move_cd: 0.0,
    action_cd: 0.0,
    smoke_energy: 100.0,
    touch_cd: 0.0,
    msg: "",
    msg_t: 0.0,
    flash_t: 0.0,
    shake_t: 0.0,
    time_s: 0.0,
    hint_i: 0,
    win: false,
    loss_reason: "",
  }
}
