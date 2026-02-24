///|
struct Mine {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut r : Float
  mut reveal_t : Float
  mut armed : Bool
}

///|
struct Target {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut detected : Bool
  mut pulse_t : Float
}

///|
struct Game {
  mines : Array[Mine]
  targets : Array[Target]
  mut state : Int
  mut mission : Int
  mut best_mission : Int
  mut mine_count : Int
  mut target_goal : Int
  mut targets_found : Int
  mut sub_x : Float
  mut sub_y : Float
  mut sub_vx : Float
  mut sub_vy : Float
  mut move_x : Float
  mut move_y : Float
  mut boost_hold : Bool
  mut sonar_trigger : Bool
  mut sonar_cd : Float
  mut sonar_wave_t : Float
  mut sonar_wave_r : Float
  mut last_pulse_range : Float
  mut oxygen : Float
  mut fuel : Float
  mut hull : Float
  mut lose_reason : Int
  mut time_s : Float
  mut touch_cd : Float
  mut shake_t : Float
}

///|
fn Mine::new() -> Mine {
  { active: false, x: 0.0, y: 0.0, r: 0.0, reveal_t: 0.0, armed: true }
}

///|
fn Target::new() -> Target {
  { active: false, x: 0.0, y: 0.0, detected: false, pulse_t: 0.0 }
}

///|
fn Game::new() -> Game {
  {
    mines: Array::makei(max_mines, fn(_i) { Mine::new() }),
    targets: Array::makei(max_targets, fn(_i) { Target::new() }),
    state: state_title,
    mission: mission_min,
    best_mission: mission_min,
    mine_count: base_mine_count,
    target_goal: base_target_goal,
    targets_found: 0,
    sub_x: sub_start_x,
    sub_y: sub_start_y,
    sub_vx: 0.0,
    sub_vy: 0.0,
    move_x: 0.0,
    move_y: 0.0,
    boost_hold: false,
    sonar_trigger: false,
    sonar_cd: 0.0,
    sonar_wave_t: 0.0,
    sonar_wave_r: 0.0,
    last_pulse_range: sonar_base_range,
    oxygen: oxygen_max,
    fuel: fuel_max,
    hull: hull_max,
    lose_reason: lose_none,
    time_s: 0.0,
    touch_cd: 0.0,
    shake_t: 0.0,
  }
}
