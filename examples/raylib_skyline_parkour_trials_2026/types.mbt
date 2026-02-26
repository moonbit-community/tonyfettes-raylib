///|
struct Tile {
  mut kind : Int
  mut x : Float
  mut y : Float
  mut w : Float
  mut h : Float
}

///|
struct Checkpoint {
  mut x : Float
  mut y : Float
  mut w : Float
  mut h : Float
  mut bonus_s : Int
  mut taken : Bool
}

///|
struct Player {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut on_ground : Bool
  mut wall_side : Int
  mut wall_window_t : Float
  mut wall_climb_t : Float
  mut coyote_t : Float
  mut jump_buffer_t : Float
  mut facing : Int
}

///|
struct Game {
  tiles : Array[Tile]
  checkpoints : Array[Checkpoint]
  hero : Player
  mut tile_count : Int
  mut checkpoint_count : Int
  mut state : Int
  mut stage : Int
  mut pending_next_stage : Int
  mut stage_width : Float
  mut stage_fail_y : Float
  mut start_x : Float
  mut start_y : Float
  mut goal_x : Float
  mut goal_y : Float
  mut goal_w : Float
  mut goal_h : Float
  mut timer_s : Float
  mut run_time_s : Float
  mut stage_time_s : Float
  mut bonus_popup_t : Float
  mut bonus_popup_value : Int
  mut checkpoints_hit : Int
  mut lose_reason : Int
  mut input_x : Float
  mut input_jump_press : Bool
  mut input_jump_hold : Bool
  mut input_climb_hold : Bool
  mut input_next_press : Bool
  mut input_restart_press : Bool
  mut touch_mode : Bool
  mut touch_jump_prev : Bool
  mut touch_next_prev : Bool
  mut touch_restart_prev : Bool
}

///|
fn Tile::new() -> Tile {
  { kind: tile_solid, x: 0.0, y: 0.0, w: 0.0, h: 0.0 }
}

///|
fn Checkpoint::new() -> Checkpoint {
  { x: 0.0, y: 0.0, w: 0.0, h: 0.0, bonus_s: 0, taken: false }
}

///|
fn Player::new() -> Player {
  {
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    on_ground: false,
    wall_side: 0,
    wall_window_t: 0.0,
    wall_climb_t: wall_climb_time_max,
    coyote_t: 0.0,
    jump_buffer_t: 0.0,
    facing: 1,
  }
}

///|
fn Game::new() -> Game {
  {
    tiles: Array::makei(max_tiles, fn(_i) { Tile::new() }),
    checkpoints: Array::makei(max_checkpoints, fn(_i) { Checkpoint::new() }),
    hero: Player::new(),
    tile_count: 0,
    checkpoint_count: 0,
    state: state_title,
    stage: 1,
    pending_next_stage: 0,
    stage_width: Float::from_int(screen_w),
    stage_fail_y: Float::from_int(screen_h) + stage_fail_y_pad,
    start_x: 0.0,
    start_y: 0.0,
    goal_x: 0.0,
    goal_y: 0.0,
    goal_w: 0.0,
    goal_h: 0.0,
    timer_s: stage_initial_time(1),
    run_time_s: 0.0,
    stage_time_s: 0.0,
    bonus_popup_t: 0.0,
    bonus_popup_value: 0,
    checkpoints_hit: 0,
    lose_reason: lose_none,
    input_x: 0.0,
    input_jump_press: false,
    input_jump_hold: false,
    input_climb_hold: false,
    input_next_press: false,
    input_restart_press: false,
    touch_mode: false,
    touch_jump_prev: false,
    touch_next_prev: false,
    touch_restart_prev: false,
  }
}
