///|
struct Obj {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut w : Float
  mut h : Float
  mut hp : Float
  mut shot_cd : Float
  mut spin : Float
  mut cloak : Bool
  mut reward : Int
}

///|
struct Shot {
  mut active : Bool
  mut from_player : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut life : Float
  mut dmg : Float
  mut kind : Int
}

///|
struct Spark {
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
struct ShockRing {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut r : Float
  mut life : Float
  mut kind : Int
}

///|
struct Ghost {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut w : Float
  mut h : Float
  mut rot : Float
  mut life : Float
  mut kind : Int
}

///|
struct Player {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut w : Float
  mut h : Float
  mut heading : Float
  mut invuln : Float
  mut hurt_t : Float
  mut muzzle_t : Float
  mut engine_t : Float
}

///|
struct Game {
  objs : Array[Obj]
  shots : Array[Shot]
  sparks : Array[Spark]
  rings : Array[ShockRing]
  ghosts : Array[Ghost]
  hero : Player
  mut state : Int
  mut stage : Int
  mut distance : Float
  mut stage_goal : Float
  mut score : Int
  mut best_score : Int
  mut coins : Int
  mut kills : Int
  mut combo : Int
  mut combo_t : Float
  mut armor : Float
  mut heat : Float
  mut fire_cd : Float
  mut dash_cd : Float
  mut dash_t : Float
  mut emp_cd : Float
  mut emp_t : Float
  mut time_s : Float
  mut flash_t : Float
  mut shake_t : Float
  mut result_t : Float
  mut hint_t : Float
  mut scroll : Float
  mut next_spawn_y : Float
  mut input_x : Float
  mut input_y : Float
  mut input_fire_hold : Bool
  mut input_dash_press : Bool
  mut input_emp_press : Bool
  mut input_restart_press : Bool
  mut touch_mode : Bool
  mut touch_dash_prev : Bool
  mut touch_emp_prev : Bool
  mut touch_restart_prev : Bool
}

///|
fn Obj::new() -> Obj {
  {
    active: false,
    kind: obj_scout,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    w: 0.0,
    h: 0.0,
    hp: 0.0,
    shot_cd: 0.0,
    spin: 0.0,
    cloak: false,
    reward: 0,
  }
}

///|
fn Shot::new() -> Shot {
  {
    active: false,
    from_player: true,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    life: 0.0,
    dmg: 0.0,
    kind: 0,
  }
}

///|
fn Spark::new() -> Spark {
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
fn ShockRing::new() -> ShockRing {
  { active: false, x: 0.0, y: 0.0, r: 0.0, life: 0.0, kind: 0 }
}

///|
fn Ghost::new() -> Ghost {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    w: 0.0,
    h: 0.0,
    rot: 0.0,
    life: 0.0,
    kind: 0,
  }
}

///|
fn Player::new() -> Player {
  {
    x: Float::from_int(screen_w / 2),
    y: Float::from_int(screen_h) * 0.76,
    vx: 0.0,
    vy: 0.0,
    w: car_w,
    h: car_h,
    heading: 0.0,
    invuln: 0.0,
    hurt_t: 0.0,
    muzzle_t: 0.0,
    engine_t: 0.0,
  }
}

///|
fn Game::new() -> Game {
  {
    objs: Array::makei(max_objs, fn(_i) { Obj::new() }),
    shots: Array::makei(max_shots, fn(_i) { Shot::new() }),
    sparks: Array::makei(max_sparks, fn(_i) { Spark::new() }),
    rings: Array::makei(max_shock_rings, fn(_i) { ShockRing::new() }),
    ghosts: Array::makei(max_ghosts, fn(_i) { Ghost::new() }),
    hero: Player::new(),
    state: state_title,
    stage: 1,
    distance: 0.0,
    stage_goal: stage_goal_base,
    score: 0,
    best_score: 0,
    coins: 0,
    kills: 0,
    combo: 0,
    combo_t: 0.0,
    armor: armor_max,
    heat: heat_max,
    fire_cd: 0.0,
    dash_cd: 0.0,
    dash_t: 0.0,
    emp_cd: 0.0,
    emp_t: 0.0,
    time_s: 0.0,
    flash_t: 0.0,
    shake_t: 0.0,
    result_t: 0.0,
    hint_t: 0.0,
    scroll: base_scroll,
    next_spawn_y: spawn_start_y,
    input_x: 0.0,
    input_y: 0.0,
    input_fire_hold: false,
    input_dash_press: false,
    input_emp_press: false,
    input_restart_press: false,
    touch_mode: false,
    touch_dash_prev: false,
    touch_emp_prev: false,
    touch_restart_prev: false,
  }
}
