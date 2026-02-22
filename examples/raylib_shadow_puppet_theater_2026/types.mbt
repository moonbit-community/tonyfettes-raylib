///|
struct Pose {
  mut ax : Int
  mut ay : Int
}

///|
struct Input {
  mut axis_dx : Int
  mut axis_dy : Int
  mut lock_pressed : Bool
  mut undo_pressed : Bool
  mut burst_pressed : Bool
  mut pause_pressed : Bool
  mut restart_pressed : Bool
  mut start_pressed : Bool
}

///|
struct Game {
  input : Input
  sequence : Array[Pose]
  history : Array[Pose]
  mut state : Int
  mut stage : Int
  mut score : Int
  mut best_score : Int
  mut combo : Int
  mut best_combo : Int
  mut excitement : Float
  mut spotlight : Float
  mut cue_time_left : Float
  mut cue_time_limit : Float
  mut target_idx : Int
  current_pose : Pose
  mut burst_t : Float
  mut burst_cd : Float
  mut combo_t : Float
  mut beat_t : Float
  mut scene_t : Float
  mut result_t : Float
  mut hit_count : Int
  mut miss_count : Int
  mut message : String
  mut message_t : Float
}

///|
fn Pose::new(ax : Int, ay : Int) -> Pose {
  { ax, ay }
}

///|
fn Input::new() -> Input {
  {
    axis_dx: 0,
    axis_dy: 0,
    lock_pressed: false,
    undo_pressed: false,
    burst_pressed: false,
    pause_pressed: false,
    restart_pressed: false,
    start_pressed: false,
  }
}

///|
fn Game::new() -> Game {
  {
    input: Input::new(),
    sequence: [],
    history: [],
    state: state_title,
    stage: 1,
    score: 0,
    best_score: 0,
    combo: 0,
    best_combo: 0,
    excitement: 0.0,
    spotlight: spotlight_start,
    cue_time_left: 0.0,
    cue_time_limit: cue_base_time,
    target_idx: 0,
    current_pose: Pose::new(0, 0),
    burst_t: 0.0,
    burst_cd: 0.0,
    combo_t: 0.0,
    beat_t: 0.0,
    scene_t: 0.0,
    result_t: 0.0,
    hit_count: 0,
    miss_count: 0,
    message: "",
    message_t: 0.0,
  }
}
