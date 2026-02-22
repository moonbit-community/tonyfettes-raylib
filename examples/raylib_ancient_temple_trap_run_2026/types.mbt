///|
struct Relic {
  mut active : Bool
  x : Float
  y : Float
  r : Float
}

///|
struct Trap {
  x : Float
  y : Float
  w : Float
  h : Float
  cycle : Float
  hot_window : Float
  phase : Float
  kind : Int
  label : String
  mut timer : Float
}

///|
struct Hazard {
  x : Float
  y : Float
  w : Float
  h : Float
  kind : Int
  label : String
}

///|
struct Plate {
  x : Float
  y : Float
  w : Float
  h : Float
  mut pressed : Bool
}

///|
struct Door {
  x : Float
  y : Float
  w : Float
  h : Float
  plate_index : Int
  hold_time : Float
  mut timer : Float
  mut open : Bool
}

///|
struct StageLayout {
  start_x : Float
  start_y : Float
  exit_x : Float
  exit_y : Float
  exit_w : Float
  exit_h : Float
  relics : Array[Relic]
  traps : Array[Trap]
  hazards : Array[Hazard]
  plates : Array[Plate]
  doors : Array[Door]
}

///|
struct Player {
  mut x : Float
  mut y : Float
  w : Float
  h : Float
  mut stamina : Float
  mut dash_on : Bool
}

///|
struct Game {
  player : Player
  mut relics : Array[Relic]
  mut traps : Array[Trap]
  mut hazards : Array[Hazard]
  mut plates : Array[Plate]
  mut doors : Array[Door]
  mut state : Int
  mut stage_index : Int
  stage_count : Int
  mut required_relics : Int
  mut collected_relics : Int
  mut exit_x : Float
  mut exit_y : Float
  mut exit_w : Float
  mut exit_h : Float
  mut stage_time : Float
  mut fail_reason : String
  mut banner_text : String
  mut banner_t : Float
  mut input_x : Float
  mut input_y : Float
  mut input_dash_hold : Bool
  mut input_start_press : Bool
  mut input_restart_press : Bool
  mut input_next_press : Bool
  mut touch_mode : Bool
  mut touch_start_prev : Bool
  mut touch_restart_prev : Bool
  mut touch_next_prev : Bool
}

///|
fn Player::new() -> Player {
  {
    x: world_x + 90.0,
    y: world_y + world_h - 100.0,
    w: player_w,
    h: player_h,
    stamina: stamina_max,
    dash_on: false,
  }
}

///|
fn Game::new() -> Game {
  {
    player: Player::new(),
    relics: [],
    traps: [],
    hazards: [],
    plates: [],
    doors: [],
    state: state_title,
    stage_index: 0,
    stage_count: stage_total,
    required_relics: 0,
    collected_relics: 0,
    exit_x: world_x + world_w - 110.0,
    exit_y: world_y + 80.0,
    exit_w: 80.0,
    exit_h: 120.0,
    stage_time: 0.0,
    fail_reason: "",
    banner_text: "",
    banner_t: 0.0,
    input_x: 0.0,
    input_y: 0.0,
    input_dash_hold: false,
    input_start_press: false,
    input_restart_press: false,
    input_next_press: false,
    touch_mode: false,
    touch_start_prev: false,
    touch_restart_prev: false,
    touch_next_prev: false,
  }
}
