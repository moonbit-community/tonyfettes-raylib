///|
struct Obstacle {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut w : Float
  mut h : Float
  mut vx : Float
  mut vy : Float
  mut kind : Int
  mut phase : Float
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
  mut raft_x : Float
  mut raft_y : Float
  mut raft_vx : Float
  mut raft_vy : Float
  mut move_x : Float
  mut move_y : Float
  mut lives : Int
  mut shield_t : Float
  mut fuel : Float
  mut boost_on : Bool
  mut score : Int
  mut best_score : Int
  mut distance : Int
  mut level : Int
  mut combo : Int
  mut combo_t : Float
  mut spawn_t : Float
  mut pickup_t : Float
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
fn Obstacle::new() -> Obstacle {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    w: 0.0,
    h: 0.0,
    vx: 0.0,
    vy: 0.0,
    kind: obstacle_rock,
    phase: 0.0,
  }
}

///|
fn Pickup::new() -> Pickup {
  { active: false, x: 0.0, y: 0.0, kind: pickup_coin, phase: 0.0 }
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
    obstacles: Array::makei(max_obstacles, fn(_i) { Obstacle::new() }),
    pickups: Array::makei(max_pickups, fn(_i) { Pickup::new() }),
    particles: Array::makei(max_particles, fn(_i) { Particle::new() }),
    state: state_title,
    raft_x: Float::from_int(world_x0 + world_w / 2),
    raft_y: Float::from_int(world_y0 + world_h - 180),
    raft_vx: 0.0,
    raft_vy: 0.0,
    move_x: 0.0,
    move_y: 0.0,
    lives: 3,
    shield_t: 0.0,
    fuel: 100.0,
    boost_on: false,
    score: 0,
    best_score: 0,
    distance: 0,
    level: 1,
    combo: 0,
    combo_t: 0.0,
    spawn_t: 0.0,
    pickup_t: 0.0,
    game_t: 0.0,
    ui_t: 0.0,
    hint_left: 3,
    hint_t: 0.0,
    hint_x: 0.0,
    hint_y: 0.0,
    msg: "",
    msg_t: 0.0,
    shake_t: 0.0,
    touch_cd: 0.0,
    win: false,
  }
}
