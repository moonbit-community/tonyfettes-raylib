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
struct Ghost {
  mut active : Bool
  body : Actor
  mut mode : Int
  mut stun_t : Float
  mut move_cd : Float
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
  shelf_x : Array[Int]
  shelf_y : Array[Int]
  mut shelf_n : Int
  page_x : Array[Int]
  page_y : Array[Int]
  page_taken : Array[Bool]
  ghosts : Array[Ghost]
  particles : Array[Particle]
  mut state : Int
  player : Actor
  mut lives : Int
  mut pages : Int
  mut seals_on : Int
  mut gate_open : Bool
  mut score : Int
  mut steps : Int
  mut time_s : Float
  mut req_dx : Int
  mut req_dy : Int
  mut action_down : Bool
  mut action_pressed : Bool
  mut move_cd : Float
  mut action_cd : Float
  mut stun_energy : Float
  mut touch_cd : Float
  mut msg : String
  mut msg_t : Float
  mut flash_t : Float
  mut shake_t : Float
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
fn Ghost::new() -> Ghost {
  {
    active: false,
    body: Actor::new(),
    mode: ghost_patrol,
    stun_t: 0.0,
    move_cd: 0.0,
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
    map: Array::make(grid_w * grid_h, tile_floor),
    shelf_x: Array::make(max_shelves, 0),
    shelf_y: Array::make(max_shelves, 0),
    shelf_n: 0,
    page_x: Array::make(max_pages, 0),
    page_y: Array::make(max_pages, 0),
    page_taken: Array::make(max_pages, false),
    ghosts: Array::makei(max_ghosts, fn(_i) { Ghost::new() }),
    particles: Array::makei(max_particles, fn(_i) { Particle::new() }),
    state: state_title,
    player: Actor::new(),
    lives: 3,
    pages: 0,
    seals_on: 0,
    gate_open: false,
    score: 0,
    steps: 0,
    time_s: 0.0,
    req_dx: 0,
    req_dy: 0,
    action_down: false,
    action_pressed: false,
    move_cd: 0.0,
    action_cd: 0.0,
    stun_energy: 100.0,
    touch_cd: 0.0,
    msg: "",
    msg_t: 0.0,
    flash_t: 0.0,
    shake_t: 0.0,
    hint_i: 0,
    win: false,
    loss_reason: "",
  }
}
