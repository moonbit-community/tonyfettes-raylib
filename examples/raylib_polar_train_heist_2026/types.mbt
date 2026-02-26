///|
struct Ent {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut w : Float
  mut h : Float
  mut hp : Float
  mut lane : Int
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
struct Fx {
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
struct Ring {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut r : Float
  mut life : Float
  mut kind : Int
}

///|
struct Shadow {
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
  mut lane : Int
  mut ground_y : Float
  mut grounded : Bool
  mut coyote_t : Float
  mut jump_buf_t : Float
  mut heading : Float
  mut invuln : Float
  mut hurt_t : Float
  mut muzzle_t : Float
  mut anim_t : Float
}

///|
struct Game {
  ents : Array[Ent]
  shots : Array[Shot]
  fxs : Array[Fx]
  rings : Array[Ring]
  shadows : Array[Shadow]
  hero : Player
  mut state : Int
  mut stage : Int
  mut distance : Float
  mut stage_goal : Float
  mut score : Int
  mut best_score : Int
  mut loot : Int
  mut kills : Int
  mut combo : Int
  mut combo_t : Float
  mut armor : Float
  mut heat : Float
  mut fire_cd : Float
  mut dash_cd : Float
  mut dash_t : Float
  mut hook_cd : Float
  mut hook_t : Float
  mut time_s : Float
  mut flash_t : Float
  mut shake_t : Float
  mut result_t : Float
  mut hint_t : Float
  mut scroll : Float
  mut next_spawn_x : Float
  mut input_x : Float
  mut input_jump_press : Bool
  mut input_fire_hold : Bool
  mut input_dash_press : Bool
  mut input_hook_press : Bool
  mut input_restart_press : Bool
  mut touch_mode : Bool
  mut touch_jump_prev : Bool
  mut touch_dash_prev : Bool
  mut touch_hook_prev : Bool
  mut touch_restart_prev : Bool
}

///|
fn Ent::new() -> Ent {
  {
    active: false,
    kind: ent_guard,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    w: 0.0,
    h: 0.0,
    hp: 0.0,
    lane: 0,
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
fn Fx::new() -> Fx {
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
fn Ring::new() -> Ring {
  { active: false, x: 0.0, y: 0.0, r: 0.0, life: 0.0, kind: 0 }
}

///|
fn Shadow::new() -> Shadow {
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
  let lane = 1
  {
    x: Float::from_int(screen_w / 2),
    y: lane_y(lane),
    vx: 0.0,
    vy: 0.0,
    w: player_w,
    h: player_h,
    lane,
    ground_y: lane_y(lane),
    grounded: true,
    coyote_t: 0.0,
    jump_buf_t: 0.0,
    heading: 0.0,
    invuln: 0.0,
    hurt_t: 0.0,
    muzzle_t: 0.0,
    anim_t: 0.0,
  }
}

///|
fn Game::new() -> Game {
  {
    ents: Array::makei(max_ents, fn(_i) { Ent::new() }),
    shots: Array::makei(max_shots, fn(_i) { Shot::new() }),
    fxs: Array::makei(max_fx, fn(_i) { Fx::new() }),
    rings: Array::makei(max_rings, fn(_i) { Ring::new() }),
    shadows: Array::makei(max_shadows, fn(_i) { Shadow::new() }),
    hero: Player::new(),
    state: state_title,
    stage: 1,
    distance: 0.0,
    stage_goal: stage_goal_base,
    score: 0,
    best_score: 0,
    loot: 0,
    kills: 0,
    combo: 0,
    combo_t: 0.0,
    armor: armor_max,
    heat: heat_max,
    fire_cd: 0.0,
    dash_cd: 0.0,
    dash_t: 0.0,
    hook_cd: 0.0,
    hook_t: 0.0,
    time_s: 0.0,
    flash_t: 0.0,
    shake_t: 0.0,
    result_t: 0.0,
    hint_t: 0.0,
    scroll: base_scroll,
    next_spawn_x: spawn_start_x,
    input_x: 0.0,
    input_jump_press: false,
    input_fire_hold: false,
    input_dash_press: false,
    input_hook_press: false,
    input_restart_press: false,
    touch_mode: false,
    touch_jump_prev: false,
    touch_dash_prev: false,
    touch_hook_prev: false,
    touch_restart_prev: false,
  }
}
