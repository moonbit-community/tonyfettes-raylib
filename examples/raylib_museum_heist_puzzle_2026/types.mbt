///|
struct Artifact {
  x : Int
  y : Int
  mut taken : Bool
}

///|
struct Guard {
  mut x : Int
  mut y : Int
  mut dir_x : Int
  mut dir_y : Int
  view_range : Int
  path : Array[Int]
  mut path_index : Int
  mut step_timer : Float
}

///|
struct FrameInput {
  move_dir : Int
  start_pressed : Bool
  next_pressed : Bool
  retry_pressed : Bool
  restart_pressed : Bool
}

///|
struct Game {
  tiles : Array[Int]
  mut artifacts : Array[Artifact]
  mut guards : Array[Guard]
  mut state : Int
  mut level_index : Int
  level_count : Int
  mut level_name : String
  mut player_x : Int
  mut player_y : Int
  mut exit_x : Int
  mut exit_y : Int
  mut artifacts_total : Int
  mut artifacts_collected : Int
  mut player_step_t : Float
  mut state_t : Float
  mut pulse_t : Float
  mut alarm_t : Float
}

///|
fn Game::new() -> Game {
  {
    tiles: Array::make(board_cells, tile_floor),
    artifacts: [],
    guards: [],
    state: state_title,
    level_index: 0,
    level_count: 3,
    level_name: "",
    player_x: 1,
    player_y: 1,
    exit_x: board_cols - 2,
    exit_y: 1,
    artifacts_total: 0,
    artifacts_collected: 0,
    player_step_t: 0.0,
    state_t: 0.0,
    pulse_t: 0.0,
    alarm_t: 0.0,
  }
}
