///|
struct Tower {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut need : Int
  mut delivered : Int
  mut pulse_t : Float
}

///|
struct Storm {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut r : Float
  mut vx : Float
  mut vy : Float
  mut phase : Float
  mut strength : Float
}

///|
struct Game {
  towers : Array[Tower]
  storms : Array[Storm]
  mut state : Int
  mut stage : Int
  mut best_stage : Int
  mut mission_limit_s : Float
  mut timer_s : Float
  mut objective_total : Int
  mut objective_done : Int
  mut rover_x : Float
  mut rover_y : Float
  mut rover_vx : Float
  mut rover_vy : Float
  mut rover_energy : Float
  mut rover_heat : Float
  mut cargo_cells : Int
  mut storm_intensity : Float
  mut in_depot : Bool
  mut nearby_tower : Int
  mut result_win : Bool
  mut result_note : String
  mut ui_t : Float
  mut flash_t : Float
  mut hint_t : Float
  mut hint_text : String
  mut input_x : Float
  mut input_y : Float
  mut input_action_press : Bool
  mut input_start_press : Bool
  mut input_next_press : Bool
  mut input_restart_press : Bool
  mut touch_mode : Bool
  mut touch_start_prev : Bool
  mut touch_action_prev : Bool
  mut touch_next_prev : Bool
  mut touch_restart_prev : Bool
}

///|
fn Tower::new() -> Tower {
  { active: false, x: 0.0, y: 0.0, need: 0, delivered: 0, pulse_t: 0.0 }
}

///|
fn Storm::new() -> Storm {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    r: 0.0,
    vx: 0.0,
    vy: 0.0,
    phase: 0.0,
    strength: 0.0,
  }
}

///|
fn Game::new() -> Game {
  {
    towers: Array::makei(max_towers, fn(_i) { Tower::new() }),
    storms: Array::makei(max_storms, fn(_i) { Storm::new() }),
    state: state_title,
    stage: 1,
    best_stage: 0,
    mission_limit_s: timer_base,
    timer_s: timer_base,
    objective_total: 0,
    objective_done: 0,
    rover_x: depot_x(),
    rover_y: depot_y(),
    rover_vx: 0.0,
    rover_vy: 0.0,
    rover_energy: energy_max,
    rover_heat: heat_max,
    cargo_cells: 0,
    storm_intensity: 0.0,
    in_depot: true,
    nearby_tower: -1,
    result_win: false,
    result_note: "Power relay prep",
    ui_t: 0.0,
    flash_t: 0.0,
    hint_t: 0.0,
    hint_text: "",
    input_x: 0.0,
    input_y: 0.0,
    input_action_press: false,
    input_start_press: false,
    input_next_press: false,
    input_restart_press: false,
    touch_mode: false,
    touch_start_prev: false,
    touch_action_prev: false,
    touch_next_prev: false,
    touch_restart_prev: false,
  }
}
