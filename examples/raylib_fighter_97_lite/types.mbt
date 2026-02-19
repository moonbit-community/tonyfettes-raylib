///|
struct InputState {
  mut x : Int
  mut y : Int
  mut prev_x : Int
  mut prev_y : Int
  mut hold_forward : Bool
  mut hold_back : Bool
  mut hold_up : Bool
  mut hold_down : Bool
  mut lp_down : Bool
  mut hp_down : Bool
  mut lk_down : Bool
  mut hk_down : Bool
  mut start_down : Bool
  mut lp_pressed : Bool
  mut hp_pressed : Bool
  mut lk_pressed : Bool
  mut hk_pressed : Bool
  mut start_pressed : Bool
  mut lp_released : Bool
  mut hp_released : Bool
  mut lk_released : Bool
  mut hk_released : Bool
  mut any_attack_pressed : Bool
  mut dash_forward_pressed : Bool
  mut dash_back_pressed : Bool
  dir_history : Array[Int]
  mut dir_head : Int
  mut tap_forward_timer : Float
  mut tap_back_timer : Float
  mut buffered_motion : Int
  mut motion_timer : Float
  mut attack_buffer_timer : Float
}

///|
fn InputState::new() -> InputState {
  {
    x: 0,
    y: 0,
    prev_x: 0,
    prev_y: 0,
    hold_forward: false,
    hold_back: false,
    hold_up: false,
    hold_down: false,
    lp_down: false,
    hp_down: false,
    lk_down: false,
    hk_down: false,
    start_down: false,
    lp_pressed: false,
    hp_pressed: false,
    lk_pressed: false,
    hk_pressed: false,
    start_pressed: false,
    lp_released: false,
    hp_released: false,
    lk_released: false,
    hk_released: false,
    any_attack_pressed: false,
    dash_forward_pressed: false,
    dash_back_pressed: false,
    dir_history: Array::make(direction_buffer_size, dir_neutral),
    dir_head: 0,
    tap_forward_timer: 0.0,
    tap_back_timer: 0.0,
    buffered_motion: motion_none,
    motion_timer: 0.0,
    attack_buffer_timer: 0.0,
  }
}

///|
struct MoveSpec {
  mut name : String
  mut attack_id : Int
  mut move_kind : Int
  mut total_frames : Int
  mut startup_frames : Int
  mut active_frames : Int
  mut recovery_frames : Int
  mut damage : Int
  mut chip_damage : Int
  mut hitstun_frames : Int
  mut blockstun_frames : Int
  mut hitstop_frames : Int
  mut pushback : Float
  mut launch_x : Float
  mut launch_y : Float
  mut drift_speed : Float
  mut meter_gain_on_use : Int
  mut meter_gain_on_hit : Int
  mut hitbox_x : Float
  mut hitbox_y : Float
  mut hitbox_w : Float
  mut hitbox_h : Float
  mut knockdown : Bool
  mut low_attack : Bool
  mut overhead_attack : Bool
  airborne_only : Bool
  crouch_only : Bool
  mut invuln_start : Int
  mut invuln_end : Int
  mut cancel_window_start : Int
  mut cancel_window_end : Int
  mut cancel_on_hit : Bool
  mut auto_dash : Bool
}

///|
fn MoveSpec::empty() -> MoveSpec {
  {
    name: "none",
    attack_id: attack_none,
    move_kind: move_kind_normal,
    total_frames: 1,
    startup_frames: 0,
    active_frames: 0,
    recovery_frames: 1,
    damage: 0,
    chip_damage: 0,
    hitstun_frames: 0,
    blockstun_frames: 0,
    hitstop_frames: hitstop_default,
    pushback: 0.0,
    launch_x: 0.0,
    launch_y: 0.0,
    drift_speed: 0.0,
    meter_gain_on_use: 0,
    meter_gain_on_hit: 0,
    hitbox_x: 0.0,
    hitbox_y: -80.0,
    hitbox_w: 28.0,
    hitbox_h: 24.0,
    knockdown: false,
    low_attack: false,
    overhead_attack: false,
    airborne_only: false,
    crouch_only: false,
    invuln_start: 0,
    invuln_end: 0,
    cancel_window_start: 0,
    cancel_window_end: 0,
    cancel_on_hit: false,
    auto_dash: false,
  }
}

///|
struct CharacterArchetype {
  id : Int
  name : String
  title : String
  intro_quote : String
  victory_quote : String
  body_main : @raylib.Color
  body_trim : @raylib.Color
  aura_color : @raylib.Color
  ui_color : @raylib.Color
  speed_mul : Float
  jump_mul : Float
  offense_mul : Float
  defense_mul : Float
  meter_mul : Float
  max_guard_bonus : Int
  normal_lp : MoveSpec
  normal_hp : MoveSpec
  normal_lk : MoveSpec
  normal_hk : MoveSpec
  special_qcf : MoveSpec
  special_dp : MoveSpec
  super_move : MoveSpec
}

///|
struct Particle {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut life : Float
  mut max_life : Float
  mut size : Float
  mut growth : Float
  mut spin : Float
  mut rot : Float
  mut color : @raylib.Color
}

///|
fn Particle::inactive() -> Particle {
  {
    active: false,
    kind: spark_kind_hit,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    life: 0.0,
    max_life: 0.6,
    size: 4.0,
    growth: 0.0,
    spin: 0.0,
    rot: 0.0,
    color: @raylib.white,
  }
}

///|
struct Fighter {
  slot : Int
  mut is_cpu : Bool
  mut archetype_index : Int
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut facing : Int
  mut on_ground : Bool
  mut crouching : Bool
  mut jumped : Bool
  mut health : Int
  mut guard_meter : Int
  mut super_meter : Int
  mut round_wins : Int
  mut action : Int
  mut action_frame : Int
  mut action_elapsed : Float
  mut current_move : MoveSpec
  mut move_connected : Bool
  mut move_was_blocked : Bool
  mut move_cancel_enabled : Bool
  mut hitstop : Int
  mut hitstun : Int
  mut blockstun : Int
  mut knockdown : Int
  mut invuln : Int
  mut throw_tech_timer : Int
  mut combo_counter : Int
  mut combo_damage : Int
  mut combo_timer : Int
  mut counter_hit_flag : Bool
  mut flash_timer : Float
  mut trail_timer : Float
  mut shake_timer : Float
  mut hurt_shake_x : Float
  mut hurt_shake_y : Float
  mut ai_timer : Float
  mut ai_mode : Int
  mut ai_cooldown : Float
  mut ai_wants_jump : Bool
  mut ai_wants_special : Bool
  mut ai_wants_super : Bool
  mut ai_wants_throw : Bool
  mut input : InputState
}

///|
fn Fighter::new(slot : Int, is_cpu : Bool) -> Fighter {
  {
    slot,
    is_cpu,
    archetype_index: slot,
    x: if slot == 0 {
      460.0
    } else {
      900.0
    },
    y: floor_y,
    vx: 0.0,
    vy: 0.0,
    facing: if slot == 0 {
      facing_right
    } else {
      facing_left
    },
    on_ground: true,
    crouching: false,
    jumped: false,
    health: health_max,
    guard_meter: guard_max,
    super_meter: 0,
    round_wins: 0,
    action: action_idle,
    action_frame: 0,
    action_elapsed: 0.0,
    current_move: MoveSpec::empty(),
    move_connected: false,
    move_was_blocked: false,
    move_cancel_enabled: false,
    hitstop: 0,
    hitstun: 0,
    blockstun: 0,
    knockdown: 0,
    invuln: 0,
    throw_tech_timer: 0,
    combo_counter: 0,
    combo_damage: 0,
    combo_timer: 0,
    counter_hit_flag: false,
    flash_timer: 0.0,
    trail_timer: 0.0,
    shake_timer: 0.0,
    hurt_shake_x: 0.0,
    hurt_shake_y: 0.0,
    ai_timer: 0.0,
    ai_mode: ai_mode_idle,
    ai_cooldown: 0.0,
    ai_wants_jump: false,
    ai_wants_special: false,
    ai_wants_super: false,
    ai_wants_throw: false,
    input: InputState::new(),
  }
}

///|
struct Game {
  mut state : Int
  mut frame_count : Int
  mut rng_state : Int
  roster : Array[CharacterArchetype]
  fighters : Array[Fighter]
  mut mode_vs_cpu : Bool
  mut mode_training : Bool
  mut select_cursor_p1 : Int
  mut select_cursor_p2 : Int
  mut p1_confirmed : Bool
  mut p2_confirmed : Bool
  mut round_index : Int
  mut round_timer : Float
  mut intro_timer : Float
  mut round_over_timer : Float
  mut match_over_timer : Float
  mut winner_slot : Int
  mut pause_blink : Float
  mut dramatic_freeze : Int
  mut hud_flash : Float
  mut announcer_text : String
  mut announcer_timer : Float
  mut training_adv_text : String
  mut training_adv_timer : Float
  mut title_blink : Float
  mut select_blink : Float
  mut bg_scroll : Float
  mut stage_flash : Float
  mut camera_x : Float
  mut camera_y : Float
  mut camera_zoom : Float
  mut camera_shake : Float
  mut camera_phase : Float
  particles : Array[Particle]
  hit_sparks : Array[Particle]
  mut debug_overlay : Bool
}

///|
fn Game::new() -> Game {
  {
    state: state_title,
    frame_count: 0,
    rng_state: 0x4A71C39F,
    roster: build_roster(),
    fighters: [Fighter::new(0, false), Fighter::new(1, true)],
    mode_vs_cpu: true,
    mode_training: false,
    select_cursor_p1: 0,
    select_cursor_p2: 1,
    p1_confirmed: false,
    p2_confirmed: false,
    round_index: 1,
    round_timer: round_time_start,
    intro_timer: intro_duration,
    round_over_timer: 0.0,
    match_over_timer: 0.0,
    winner_slot: winner_none,
    pause_blink: 0.0,
    dramatic_freeze: 0,
    hud_flash: 0.0,
    announcer_text: "",
    announcer_timer: 0.0,
    training_adv_text: "",
    training_adv_timer: 0.0,
    title_blink: 0.0,
    select_blink: 0.0,
    bg_scroll: 0.0,
    stage_flash: 0.0,
    camera_x: 0.0,
    camera_y: 0.0,
    camera_zoom: camera_zoom_base,
    camera_shake: 0.0,
    camera_phase: 0.0,
    particles: Array::make(max_particles, Particle::inactive()),
    hit_sparks: Array::make(max_hit_sparks, Particle::inactive()),
    debug_overlay: false,
  }
}
