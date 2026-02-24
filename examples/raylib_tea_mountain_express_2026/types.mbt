///|
struct Hazard {
  mut active : Bool
  mut lane : Int
  mut y : Float
  mut speed : Float
  mut size : Float
  mut kind : Int
  mut near_miss_awarded : Bool
}

///|
struct Game {
  hazards : Array[Hazard]
  mut state : Int
  mut lane : Int
  mut lane_x : Float
  mut tilt : Float
  mut speed : Float
  mut distance : Float
  mut next_checkpoint_distance : Float
  mut checkpoint_index : Int
  mut schedule_s : Float
  mut cargo_quality : Float
  mut durability : Float
  mut reputation : Float
  mut multiplier : Int
  mut score : Int
  mut best_score : Int
  mut successful_deliveries : Int
  mut failed_deliveries : Int
  mut boost_cd : Float
  mut boost_heat : Float
  mut boost_timer : Float
  mut hazard_spawn_t : Float
  mut world_t : Float
  mut message : String
  mut message_t : Float
  mut near_miss_combo : Int
  mut input_steer : Int
  mut input_tilt : Int
  mut input_brake_press : Bool
  mut input_stabilize_hold : Bool
  mut input_boost_press : Bool
  mut input_pause_press : Bool
  mut input_restart_press : Bool
  mut input_confirm_press : Bool
}

///|
fn Hazard::new() -> Hazard {
  {
    active: false,
    lane: 0,
    y: 0.0,
    speed: 0.0,
    size: 0.0,
    kind: hazard_rock,
    near_miss_awarded: false,
  }
}

///|
fn Game::new() -> Game {
  {
    hazards: Array::makei(max_hazards, fn(_i) { Hazard::new() }),
    state: state_title,
    lane: lane_count / 2,
    lane_x: lane_center_x(0.0, lane_count / 2, cart_y),
    tilt: 0.0,
    speed: speed_base,
    distance: 0.0,
    next_checkpoint_distance: checkpoint_segment_distance(1),
    checkpoint_index: 1,
    schedule_s: checkpoint_time_limit(1),
    cargo_quality: 100.0,
    durability: 100.0,
    reputation: 100.0,
    multiplier: 1,
    score: 0,
    best_score: 0,
    successful_deliveries: 0,
    failed_deliveries: 0,
    boost_cd: 0.0,
    boost_heat: 0.0,
    boost_timer: 0.0,
    hazard_spawn_t: 0.8,
    world_t: 0.0,
    message: "Press J to dispatch the tea caravan.",
    message_t: 99.0,
    near_miss_combo: 0,
    input_steer: 0,
    input_tilt: 0,
    input_brake_press: false,
    input_stabilize_hold: false,
    input_boost_press: false,
    input_pause_press: false,
    input_restart_press: false,
    input_confirm_press: false,
  }
}
