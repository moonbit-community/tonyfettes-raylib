///|
struct Traffic {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut w : Float
  mut h : Float
  mut kind : Int
  mut phase : Float
}

///|
struct Order {
  mut active : Bool
  mut picked : Bool
  mut x_from : Float
  mut y_from : Float
  mut x_to : Float
  mut y_to : Float
  mut timer : Float
  mut value : Int
  mut id : Int
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
  traffic : Array[Traffic]
  orders : Array[Order]
  pickups : Array[Pickup]
  particles : Array[Particle]
  mut state : Int
  mut rider_x : Float
  mut rider_y : Float
  mut rider_vx : Float
  mut rider_vy : Float
  mut move_x : Float
  mut move_y : Float
  mut boost_on : Bool
  mut action_on : Bool
  mut cargo_idx : Int
  mut lives : Int
  mut scooter_hp : Float
  mut fuel : Float
  mut turbo_t : Float
  mut action_cd : Float
  mut score : Int
  mut best_score : Int
  mut delivered : Int
  mut missed : Int
  mut wave : Int
  mut combo : Int
  mut combo_t : Float
  mut order_spawn_t : Float
  mut traffic_spawn_t : Float
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
fn Traffic::new() -> Traffic {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    w: 0.0,
    h: 0.0,
    kind: traffic_sedan,
    phase: 0.0,
  }
}

///|
fn Order::new() -> Order {
  {
    active: false,
    picked: false,
    x_from: 0.0,
    y_from: 0.0,
    x_to: 0.0,
    y_to: 0.0,
    timer: 0.0,
    value: 0,
    id: 0,
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
    traffic: Array::makei(max_traffic, fn(_i) { Traffic::new() }),
    orders: Array::makei(max_orders, fn(_i) { Order::new() }),
    pickups: Array::makei(max_pickups, fn(_i) { Pickup::new() }),
    particles: Array::makei(max_particles, fn(_i) { Particle::new() }),
    state: state_title,
    rider_x: Float::from_int(world_x0 + world_w / 2),
    rider_y: Float::from_int(world_y0 + world_h / 2),
    rider_vx: 0.0,
    rider_vy: 0.0,
    move_x: 0.0,
    move_y: 0.0,
    boost_on: false,
    action_on: false,
    cargo_idx: -1,
    lives: 3,
    scooter_hp: 100.0,
    fuel: 100.0,
    turbo_t: 0.0,
    action_cd: 0.0,
    score: 0,
    best_score: 0,
    delivered: 0,
    missed: 0,
    wave: 1,
    combo: 0,
    combo_t: 0.0,
    order_spawn_t: 0.0,
    traffic_spawn_t: 0.0,
    pickup_spawn_t: 0.0,
    game_t: 0.0,
    ui_t: 0.0,
    hint_left: 3,
    hint_t: 0.0,
    hint_x: restaurant_x(0),
    hint_y: restaurant_y(0),
    msg: "",
    msg_t: 0.0,
    shake_t: 0.0,
    touch_cd: 0.0,
    win: false,
  }
}
