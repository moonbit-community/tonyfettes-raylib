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
struct Train {
  mut active : Bool
  mut x : Float
  mut prev_x : Float
  mut lane : Int
  mut target_lane : Int
  mut speed : Float
  mut passed_junction : Int
  mut color_id : Int
}

///|
struct Inspector {
  mut active : Bool
  body : Actor
  mut mode : Int
  mut move_cd : Float
  mut dir_x : Int
  mut path_y : Int
  mut path_min_x : Int
  mut path_max_x : Int
  mut stun_t : Float
  mut seed : Int
  mut alert_t : Float
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
  switch_state : Array[Int]
  trains : Array[Train]
  inspectors : Array[Inspector]
  particles : Array[Particle]
  mut state : Int
  player : Actor
  mut lives : Int
  mut score : Int
  mut best_score : Int
  mut routed_ok : Int
  mut routed_bad : Int
  mut collisions : Int
  mut spawn_t : Float
  mut slow_t : Float
  mut time_left : Float
  mut req_dx : Int
  mut req_dy : Int
  mut action_down : Bool
  mut action_pressed : Bool
  mut move_cd : Float
  mut action_cd : Float
  mut emp_energy : Float
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
fn Train::new() -> Train {
  {
    active: false,
    x: 0.0,
    prev_x: 0.0,
    lane: 0,
    target_lane: 0,
    speed: 0.0,
    passed_junction: -1,
    color_id: 0,
  }
}

///|
fn Inspector::new() -> Inspector {
  {
    active: false,
    body: Actor::new(),
    mode: inspector_patrol,
    move_cd: 0.0,
    dir_x: 1,
    path_y: 2,
    path_min_x: 1,
    path_max_x: 1,
    stun_t: 0.0,
    seed: 1,
    alert_t: 0.0,
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
    map: Array::make(grid_w * grid_h, tile_void),
    switch_state: Array::make(junction_n, 0),
    trains: Array::makei(max_trains, fn(_i) { Train::new() }),
    inspectors: Array::makei(max_inspectors, fn(_i) { Inspector::new() }),
    particles: Array::makei(max_particles, fn(_i) { Particle::new() }),
    state: state_title,
    player: Actor::new(),
    lives: max_lives,
    score: 0,
    best_score: 0,
    routed_ok: 0,
    routed_bad: 0,
    collisions: 0,
    spawn_t: 0.0,
    slow_t: 0.0,
    time_left: round_time_limit,
    req_dx: 0,
    req_dy: 0,
    action_down: false,
    action_pressed: false,
    move_cd: 0.0,
    action_cd: 0.0,
    emp_energy: 100.0,
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
