///|
struct Obj {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut r : Float
  mut cloak : Bool
  mut spin : Float
  mut life : Float
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
struct Ripple {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut r : Float
  mut life : Float
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
  mut kind : Int
}

///|
struct Player {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut r : Float
  mut invuln : Float
  mut hurt_t : Float
  mut anim_t : Float
}

///|
struct Game {
  objs : Array[Obj]
  particles : Array[Particle]
  ripples : Array[Ripple]
  trails : Array[Trail]
  hero : Player
  mut state : Int
  mut stage : Int
  mut distance : Float
  mut stage_goal : Float
  mut score : Int
  mut best_score : Int
  mut data_collected : Int
  mut combo : Int
  mut combo_t : Float
  mut hull : Float
  mut oxygen : Float
  mut sonar_cd : Float
  mut sonar_t : Float
  mut dash_cd : Float
  mut dash_t : Float
  mut time_s : Float
  mut flash_t : Float
  mut shake_t : Float
  mut result_t : Float
  mut hint_t : Float
  mut scroll_speed : Float
  mut next_spawn_y : Float
  mut input_x : Float
  mut input_y : Float
  mut input_dash_press : Bool
  mut input_sonar_press : Bool
  mut input_restart_press : Bool
  mut touch_mode : Bool
  mut touch_dash_prev : Bool
  mut touch_sonar_prev : Bool
  mut touch_restart_prev : Bool
}

///|
fn Obj::new() -> Obj {
  {
    active: false,
    kind: obj_rock,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    r: 0.0,
    cloak: false,
    spin: 0.0,
    life: 0.0,
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
fn Ripple::new() -> Ripple {
  { active: false, x: 0.0, y: 0.0, r: 0.0, life: 0.0, kind: 0 }
}

///|
fn Trail::new() -> Trail {
  { active: false, x: 0.0, y: 0.0, w: 0.0, h: 0.0, life: 0.0, kind: 0 }
}

///|
fn Player::new() -> Player {
  {
    x: Float::from_int(screen_w / 2),
    y: Float::from_int(screen_h) * 0.72,
    vx: 0.0,
    vy: 0.0,
    r: player_r,
    invuln: 0.0,
    hurt_t: 0.0,
    anim_t: 0.0,
  }
}

///|
fn Game::new() -> Game {
  {
    objs: Array::makei(max_objs, fn(_i) { Obj::new() }),
    particles: Array::makei(max_particles, fn(_i) { Particle::new() }),
    ripples: Array::makei(max_ripples, fn(_i) { Ripple::new() }),
    trails: Array::makei(max_trails, fn(_i) { Trail::new() }),
    hero: Player::new(),
    state: state_title,
    stage: 1,
    distance: 0.0,
    stage_goal: stage_base_goal,
    score: 0,
    best_score: 0,
    data_collected: 0,
    combo: 0,
    combo_t: 0.0,
    hull: 100.0,
    oxygen: 100.0,
    sonar_cd: 0.0,
    sonar_t: 0.0,
    dash_cd: 0.0,
    dash_t: 0.0,
    time_s: 0.0,
    flash_t: 0.0,
    shake_t: 0.0,
    result_t: 0.0,
    hint_t: 0.0,
    scroll_speed: base_scroll,
    next_spawn_y: spawn_start_y,
    input_x: 0.0,
    input_y: 0.0,
    input_dash_press: false,
    input_sonar_press: false,
    input_restart_press: false,
    touch_mode: false,
    touch_dash_prev: false,
    touch_sonar_prev: false,
    touch_restart_prev: false,
  }
}
