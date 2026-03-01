///|
pub(all) enum GameState {
  Title
  Play
  Win
  Lose
  CampaignClear
} derive(Eq)

///|
pub(all) enum Direction {
  DirNone
  Left
  Right
  Up
  Down
} derive(Eq)

///|
pub(all) enum TileKind {
  Floor
  Wall
} derive(Eq)

///|
pub(all) struct Artifact {
  x : Int
  y : Int
  mut taken : Bool
}

///|
pub(all) struct Guard {
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
pub(all) struct FrameInput {
  move_dir : Direction
  start_pressed : Bool
  next_pressed : Bool
  retry_pressed : Bool
  restart_pressed : Bool
}

///|
pub(all) struct Game {
  tiles : Array[TileKind]
  mut artifacts : Array[Artifact]
  mut guards : Array[Guard]
  mut state : GameState
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
  mut mouse_x : Float
  mut mouse_y : Float
  mut mouse_hold : Bool
  mut mouse_press : Bool
  mut touch_count : Int
}

///|
pub fn Game::new() -> Game {
  {
    tiles: Array::make(board_cells, Floor),
    artifacts: [],
    guards: [],
    state: Title,
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
    mouse_x: 0.0,
    mouse_y: 0.0,
    mouse_hold: false,
    mouse_press: false,
    touch_count: 0,
  }
}
