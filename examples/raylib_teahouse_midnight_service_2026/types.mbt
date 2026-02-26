///|
struct Customer {
  mut active : Bool
  mut tea_type : Int
  mut slot : Int
  mut x : Float
  mut y : Float
  mut patience : Float
  mut patience_max : Float
  mut life : Float
  mut reward : Int
  mut mood : Float
  mut served_t : Float
  mut angry : Bool
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
  mut life : Float
  mut rot : Float
}

///|
struct Player {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut w : Float
  mut h : Float
  mut angle : Float
  mut dash_cd : Float
  mut dash_t : Float
  mut interact_t : Float
  mut anim_t : Float
  mut carry_water : Bool
  mut carry_leaf : Int
}

///|
struct Game {
  customers : Array[Customer]
  sparks : Array[Spark]
  rings : Array[Ring]
  shadows : Array[Shadow]
  player : Player
  mut state : Int
  mut stage : Int
  mut stage_goal : Int
  mut score : Int
  mut best_score : Int
  mut served : Int
  mut missed : Int
  mut combo : Int
  mut combo_t : Float
  mut reputation : Float
  mut focus : Float
  mut time_left : Float
  mut spawn_cd : Float
  mut brew_active : Bool
  mut brew_t : Float
  mut brew_type : Int
  mut ready_cup : Int
  mut focus_mode : Bool
  mut flash_t : Float
  mut shake_t : Float
  mut result_t : Float
  mut hint_t : Float
  mut time_s : Float
  mut input_x : Float
  mut input_y : Float
  mut input_interact_press : Bool
  mut input_focus_hold : Bool
  mut input_dash_press : Bool
  mut input_restart_press : Bool
  mut touch_mode : Bool
  mut touch_interact_prev : Bool
  mut touch_dash_prev : Bool
  mut touch_restart_prev : Bool
}

///|
fn Customer::new() -> Customer {
  {
    active: false,
    tea_type: tea_jasmine,
    slot: 0,
    x: 0.0,
    y: 0.0,
    patience: 0.0,
    patience_max: 0.0,
    life: 0.0,
    reward: 0,
    mood: 0.0,
    served_t: 0.0,
    angry: false,
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
fn Ring::new() -> Ring {
  { active: false, x: 0.0, y: 0.0, r: 0.0, life: 0.0, kind: 0 }
}

///|
fn Shadow::new() -> Shadow {
  { active: false, x: 0.0, y: 0.0, w: 0.0, h: 0.0, life: 0.0, rot: 0.0 }
}

///|
fn Player::new() -> Player {
  {
    x: 628.0,
    y: 468.0,
    vx: 0.0,
    vy: 0.0,
    w: player_w,
    h: player_h,
    angle: 0.0,
    dash_cd: 0.0,
    dash_t: 0.0,
    interact_t: 0.0,
    anim_t: 0.0,
    carry_water: false,
    carry_leaf: -1,
  }
}

///|
fn Game::new() -> Game {
  {
    customers: Array::makei(max_customers, fn(_i) { Customer::new() }),
    sparks: Array::makei(max_sparks, fn(_i) { Spark::new() }),
    rings: Array::makei(max_rings, fn(_i) { Ring::new() }),
    shadows: Array::makei(max_shadows, fn(_i) { Shadow::new() }),
    player: Player::new(),
    state: state_title,
    stage: 1,
    stage_goal: stage_goal_base,
    score: 0,
    best_score: 0,
    served: 0,
    missed: 0,
    combo: 0,
    combo_t: 0.0,
    reputation: reputation_max,
    focus: focus_max,
    time_left: stage_time_base,
    spawn_cd: 0.0,
    brew_active: false,
    brew_t: 0.0,
    brew_type: tea_jasmine,
    ready_cup: -1,
    focus_mode: false,
    flash_t: 0.0,
    shake_t: 0.0,
    result_t: 0.0,
    hint_t: 0.0,
    time_s: 0.0,
    input_x: 0.0,
    input_y: 0.0,
    input_interact_press: false,
    input_focus_hold: false,
    input_dash_press: false,
    input_restart_press: false,
    touch_mode: false,
    touch_interact_prev: false,
    touch_dash_prev: false,
    touch_restart_prev: false,
  }
}
