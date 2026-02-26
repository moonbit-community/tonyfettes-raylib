///|
struct InputState {
  mut move_x : Int
  mut move_y : Int
  mut press_strike : Bool
  mut press_guard : Bool
  mut press_burst : Bool
  mut press_pause : Bool
  mut press_restart : Bool
  mut press_start : Bool
}

///|
fn InputState::new() -> InputState {
  {
    move_x: 0,
    move_y: 0,
    press_strike: false,
    press_guard: false,
    press_burst: false,
    press_pause: false,
    press_restart: false,
    press_start: false,
  }
}

///|
struct Threat {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut speed : Float
  mut radius : Float
  mut stun_t : Float
  mut spin : Float
}

///|
fn Threat::new() -> Threat {
  {
    active: false,
    kind: threat_firecracker,
    x: 0.0,
    y: 0.0,
    speed: 0.0,
    radius: 0.0,
    stun_t: 0.0,
    spin: 0.0,
  }
}

///|
struct Game {
  input : InputState
  threats : Array[Threat]
  mut state : Int
  mut troupe_x : Float
  mut troupe_y : Float
  mut troupe_lane : Int
  mut score : Int
  mut best_score : Int
  mut cleared : Int
  mut leaked : Int
  mut combo : Int
  mut combo_t : Float
  mut hype : Float
  mut morale : Float
  mut crowd_order : Float
  mut strike_cd : Float
  mut strike_t : Float
  mut guard_cd : Float
  mut guard_t : Float
  mut burst_cd : Float
  mut burst_t : Float
  mut spawn_t : Float
  mut elapsed : Float
  mut flash_t : Float
  mut shake_t : Float
  mut msg : String
  mut msg_t : Float
  mut time_s : Float
}

///|
fn Game::new() -> Game {
  {
    input: InputState::new(),
    threats: Array::makei(max_threats, fn(_i) { Threat::new() }),
    state: state_title,
    troupe_x: Float::from_int(street_left + 220),
    troupe_y: lane_y(troupe_start_lane),
    troupe_lane: troupe_start_lane,
    score: 0,
    best_score: 0,
    cleared: 0,
    leaked: 0,
    combo: 0,
    combo_t: 0.0,
    hype: 0.0,
    morale: morale_start,
    crowd_order: order_start,
    strike_cd: 0.0,
    strike_t: 0.0,
    guard_cd: 0.0,
    guard_t: 0.0,
    burst_cd: 0.0,
    burst_t: 0.0,
    spawn_t: 0.9,
    elapsed: 0.0,
    flash_t: 0.0,
    shake_t: 0.0,
    msg: "",
    msg_t: 0.0,
    time_s: 0.0,
  }
}
