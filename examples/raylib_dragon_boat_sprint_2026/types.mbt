///|
struct Input {
  mut steer : Float
  mut paddle_pressed : Bool
  mut stabilize_down : Bool
  mut burst_pressed : Bool
  mut pause_pressed : Bool
  mut restart_pressed : Bool
  mut start_pressed : Bool
}

///|
struct Hazard {
  mut active : Bool
  mut kind : Int
  mut lane : Float
  mut dist : Float
  mut size : Float
  mut drift : Float
  mut phase : Float
}

///|
struct Rival {
  mut active : Bool
  mut id : Int
  mut lane : Float
  mut dist : Float
  mut speed_bias : Float
  mut stroke_t : Float
}

///|
struct Game {
  input : Input
  hazards : Array[Hazard]
  rivals : Array[Rival]
  mut state : Int
  mut distance : Float
  mut speed : Float
  mut lane : Float
  mut rhythm_t : Float
  mut stroke_cd : Float
  mut since_paddle_t : Float
  mut streak : Int
  mut best_streak : Int
  mut rhythm_meter : Float
  mut burst_t : Float
  mut wave_t : Float
  mut wobble : Float
  mut checkpoint_idx : Int
  mut score : Int
  mut hit_count : Int
  mut best_rank : Int
  mut finish_rank : Int
  mut finish_time : Float
  mut game_t : Float
  mut ui_t : Float
  mut hazard_spawn_t : Float
  mut msg : String
  mut msg_t : Float
}

///|
fn Input::new() -> Input {
  {
    steer: 0.0,
    paddle_pressed: false,
    stabilize_down: false,
    burst_pressed: false,
    pause_pressed: false,
    restart_pressed: false,
    start_pressed: false,
  }
}

///|
fn Hazard::new() -> Hazard {
  {
    active: false,
    kind: hazard_debris,
    lane: 0.0,
    dist: 0.0,
    size: 0.0,
    drift: 0.0,
    phase: 0.0,
  }
}

///|
fn Rival::new() -> Rival {
  { active: false, id: 0, lane: 0.0, dist: 0.0, speed_bias: 0.0, stroke_t: 0.0 }
}

///|
fn Game::new() -> Game {
  {
    input: Input::new(),
    hazards: Array::makei(max_hazards, fn(_i) { Hazard::new() }),
    rivals: Array::makei(max_rivals, fn(_i) { Rival::new() }),
    state: state_title,
    distance: 0.0,
    speed: base_speed,
    lane: 0.0,
    rhythm_t: 0.0,
    stroke_cd: 0.0,
    since_paddle_t: 0.0,
    streak: 0,
    best_streak: 0,
    rhythm_meter: 0.0,
    burst_t: 0.0,
    wave_t: 0.0,
    wobble: 0.0,
    checkpoint_idx: 0,
    score: 0,
    hit_count: 0,
    best_rank: max_rivals + 1,
    finish_rank: max_rivals + 1,
    finish_time: 0.0,
    game_t: 0.0,
    ui_t: 0.0,
    hazard_spawn_t: 0.35,
    msg: "",
    msg_t: 0.0,
  }
}
