///|
struct InputState {
  mut axis_x : Int
  mut axis_y : Int
  mut hit_pressed : Bool
  mut defend_pressed : Bool
  mut burst_pressed : Bool
  mut pause_pressed : Bool
  mut restart_pressed : Bool
  mut confirm_pressed : Bool
}

///|
struct Prompt {
  lane_x : Int
  lane_y : Int
  stance : Int
  mut time_left : Float
}

///|
struct Game {
  input : InputState
  mut state : Int
  mut lane_x : Int
  mut lane_y : Int
  mut stance : Int
  mut health : Float
  mut harmony : Float
  mut acclaim : Int
  mut combo : Int
  mut best_combo : Int
  mut hits : Int
  mut misses : Int
  mut duel_time_left : Float
  mut elapsed : Float
  mut beat_interval : Float
  mut next_prompt_t : Float
  mut prompt_active : Bool
  mut prompt : Prompt
  mut prompt_serial : Int
  mut burst_t : Float
  mut burst_cd : Float
  mut guard_flash_t : Float
  mut crowd_wave_t : Float
  mut message : String
  mut message_t : Float
  mut game_over_reason : String
}

///|
fn InputState::new() -> InputState {
  {
    axis_x: 0,
    axis_y: 0,
    hit_pressed: false,
    defend_pressed: false,
    burst_pressed: false,
    pause_pressed: false,
    restart_pressed: false,
    confirm_pressed: false,
  }
}

///|
fn Prompt::new(
  lane_x : Int,
  lane_y : Int,
  stance : Int,
  time_left : Float,
) -> Prompt {
  { lane_x, lane_y, stance, time_left }
}

///|
fn Game::new() -> Game {
  {
    input: InputState::new(),
    state: state_title,
    lane_x: 0,
    lane_y: 0,
    stance: stance_spear,
    health: health_max,
    harmony: harmony_max,
    acclaim: 0,
    combo: 0,
    best_combo: 0,
    hits: 0,
    misses: 0,
    duel_time_left: duel_duration,
    elapsed: 0.0,
    beat_interval: beat_start_interval,
    next_prompt_t: 0.7,
    prompt_active: false,
    prompt: Prompt::new(0, 0, stance_spear, 0.0),
    prompt_serial: 0,
    burst_t: 0.0,
    burst_cd: 0.0,
    guard_flash_t: 0.0,
    crowd_wave_t: 0.0,
    message: "",
    message_t: 0.0,
    game_over_reason: "",
  }
}
