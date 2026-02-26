///|
struct TrackObj {
  mut active : Bool
  mut kind : Int
  mut lane : Int
  mut z : Float
  mut y_off : Float
  mut w : Float
  mut h : Float
  mut phase_only : Int
  mut spin : Float
  mut hit_lock : Float
}

///|
struct Particle {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut life : Float
  mut size : Float
  mut kind : Int
}

///|
struct Trail {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut w : Float
  mut h : Float
  mut life : Float
  mut beta : Bool
}

///|
struct Player {
  mut lane : Int
  mut lane_f : Float
  mut y : Float
  mut vy : Float
  mut jump_buf : Float
  mut grounded : Bool
  mut invuln_t : Float
  mut hurt_t : Float
  mut anim_t : Float
}

///|
struct Game {
  objs : Array[TrackObj]
  particles : Array[Particle]
  trails : Array[Trail]
  hero : Player
  mut state : Int
  mut stage : Int
  mut stage_goal : Float
  mut stage_progress : Float
  mut speed : Float
  mut speed_mul : Float
  mut boost_t : Float
  mut score : Int
  mut best_score : Int
  mut stage_bonus : Int
  mut combo : Int
  mut combo_t : Float
  mut orbs : Int
  mut health : Float
  mut phase_energy : Float
  mut phase_beta : Bool
  mut phase_cd : Float
  mut flash_t : Float
  mut shake_t : Float
  mut title_t : Float
  mut result_t : Float
  mut hint_t : Float
  mut next_spawn_z : Float
  mut input_move : Int
  mut input_jump_press : Bool
  mut input_jump_hold : Bool
  mut input_phase_press : Bool
  mut input_restart_press : Bool
  mut input_pause_press : Bool
  mut touch_mode : Bool
  mut touch_count : Int
  mut pointer_x : Float
  mut pointer_y : Float
  mut touch_left_prev : Bool
  mut touch_right_prev : Bool
  mut touch_jump_prev : Bool
  mut touch_phase_prev : Bool
  mut touch_restart_prev : Bool
}

///|
fn TrackObj::new() -> TrackObj {
  {
    active: false,
    kind: obj_wall,
    lane: 0,
    z: 0.0,
    y_off: 0.0,
    w: 0.0,
    h: 0.0,
    phase_only: 0,
    spin: 0.0,
    hit_lock: 0.0,
  }
}

///|
fn Particle::new() -> Particle {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    life: 0.0,
    size: 0.0,
    kind: 0,
  }
}

///|
fn Trail::new() -> Trail {
  { active: false, x: 0.0, y: 0.0, w: 0.0, h: 0.0, life: 0.0, beta: false }
}

///|
fn Player::new() -> Player {
  {
    lane: 2,
    lane_f: lane_world_x(2),
    y: 0.0,
    vy: 0.0,
    jump_buf: 0.0,
    grounded: true,
    invuln_t: 0.0,
    hurt_t: 0.0,
    anim_t: 0.0,
  }
}

///|
fn Game::new() -> Game {
  {
    objs: Array::makei(max_objs, fn(_i) { TrackObj::new() }),
    particles: Array::makei(max_particles, fn(_i) { Particle::new() }),
    trails: Array::makei(max_trails, fn(_i) { Trail::new() }),
    hero: Player::new(),
    state: state_title,
    stage: 1,
    stage_goal: stage_base_distance,
    stage_progress: 0.0,
    speed: base_speed,
    speed_mul: 1.0,
    boost_t: 0.0,
    score: 0,
    best_score: 0,
    stage_bonus: 0,
    combo: 0,
    combo_t: 0.0,
    orbs: 0,
    health: 100.0,
    phase_energy: 100.0,
    phase_beta: false,
    phase_cd: 0.0,
    flash_t: 0.0,
    shake_t: 0.0,
    title_t: 0.0,
    result_t: 0.0,
    hint_t: 0.0,
    next_spawn_z: 400.0,
    input_move: 0,
    input_jump_press: false,
    input_jump_hold: false,
    input_phase_press: false,
    input_restart_press: false,
    input_pause_press: false,
    touch_mode: false,
    touch_count: 0,
    pointer_x: 0.0,
    pointer_y: 0.0,
    touch_left_prev: false,
    touch_right_prev: false,
    touch_jump_prev: false,
    touch_phase_prev: false,
    touch_restart_prev: false,
  }
}
