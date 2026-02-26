///|
struct Obstacle {
  mut active : Bool
  mut x : Float
  mut gap_y : Float
  mut gap_h : Float
  mut w : Float
  mut speed : Float
  mut kind : Int
  mut phase : Float
  mut scored : Bool
}

///|
struct Pickup {
  mut active : Bool
  mut x : Float
  mut y : Float
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
  obstacles : Array[Obstacle]
  pickups : Array[Pickup]
  particles : Array[Particle]
  mut state : Int
  mut px : Float
  mut py : Float
  mut vy : Float
  mut lives : Int
  mut shield_t : Float
  mut boost_meter : Float
  mut boost_on : Bool
  mut boost_t : Float
  mut score : Int
  mut best_score : Int
  mut distance : Int
  mut combo : Int
  mut combo_t : Float
  mut level : Int
  mut spawn_t : Float
  mut pickup_t : Float
  mut game_t : Float
  mut ui_t : Float
  mut msg : String
  mut msg_t : Float
  mut hint_left : Int
  mut hint_t : Float
  mut hint_y : Float
  mut shake_t : Float
  mut win : Bool
  mut touch_cd : Float
}

///|
fn Obstacle::new() -> Obstacle {
  {
    active: false,
    x: 0.0,
    gap_y: 0.0,
    gap_h: 0.0,
    w: 0.0,
    speed: 0.0,
    kind: obstacle_kind_gate,
    phase: 0.0,
    scored: false,
  }
}

///|
fn Pickup::new() -> Pickup {
  { active: false, x: 0.0, y: 0.0, kind: pickup_score, phase: 0.0 }
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
    obstacles: Array::makei(max_obs, fn(_i) { Obstacle::new() }),
    pickups: Array::makei(max_pickups, fn(_i) { Pickup::new() }),
    particles: Array::makei(max_particles, fn(_i) { Particle::new() }),
    state: state_title,
    px: Float::from_int(world_x0 + world_w / 4),
    py: Float::from_int(world_y0 + world_h / 2),
    vy: 0.0,
    lives: 3,
    shield_t: 0.0,
    boost_meter: 1.0,
    boost_on: false,
    boost_t: 0.0,
    score: 0,
    best_score: 0,
    distance: 0,
    combo: 0,
    combo_t: 0.0,
    level: 1,
    spawn_t: 0.0,
    pickup_t: 0.0,
    game_t: 0.0,
    ui_t: 0.0,
    msg: "",
    msg_t: 0.0,
    hint_left: 3,
    hint_t: 0.0,
    hint_y: 0.0,
    shake_t: 0.0,
    win: false,
    touch_cd: 0.0,
  }
}
