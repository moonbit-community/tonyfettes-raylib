///|
struct Ghost {
  mut x : Int
  mut y : Int
  mut dir_x : Int
  mut dir_y : Int
  start_x : Int
  start_y : Int
  scatter_x : Int
  scatter_y : Int
  color : @raylib.Color
}

///|
fn Ghost::new(
  x : Int,
  y : Int,
  scatter_x : Int,
  scatter_y : Int,
  color : @raylib.Color,
) -> Ghost {
  {
    x,
    y,
    dir_x: 1,
    dir_y: 0,
    start_x: x,
    start_y: y,
    scatter_x,
    scatter_y,
    color,
  }
}

///|
struct Game {
  walls : Array[Int]
  pellets : Array[Int]
  mut player_x : Int
  mut player_y : Int
  mut dir_x : Int
  mut dir_y : Int
  mut want_x : Int
  mut want_y : Int
  ghosts : Array[Ghost]
  mut score : Int
  mut lives : Int
  mut pellets_left : Int
  mut frightened_timer : Float
  mut phase_timer : Float
  mut chase_mode : Bool
  mut step_timer_player : Float
  mut step_timer_ghost : Float
  mut game_over : Bool
  mut win : Bool
}

///|
fn Game::new() -> Game {
  {
    walls: Array::make(maze_cols * maze_rows, 0),
    pellets: Array::make(maze_cols * maze_rows, 0),
    player_x: maze_cols / 2,
    player_y: maze_rows - 4,
    dir_x: 0,
    dir_y: 0,
    want_x: 0,
    want_y: 0,
    ghosts: [],
    score: 0,
    lives: 3,
    pellets_left: 0,
    frightened_timer: 0.0,
    phase_timer: 0.0,
    chase_mode: true,
    step_timer_player: 0.0,
    step_timer_ghost: 0.0,
    game_over: false,
    win: false,
  }
}
