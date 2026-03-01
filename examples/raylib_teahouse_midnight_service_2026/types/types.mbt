///|
pub(all) struct Customer {
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
pub(all) struct Spark {
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
pub(all) struct Ring {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut r : Float
  mut life : Float
  mut kind : Int
}

///|
pub(all) struct Shadow {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut w : Float
  mut h : Float
  mut life : Float
  mut rot : Float
}

///|
pub(all) struct Player {
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
pub(all) struct Game {
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
  mut mouse_x : Float
  mut mouse_y : Float
  mut mouse_hold : Bool
  mut touch_count : Int
}

///|
pub fn Customer::new() -> Customer {
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
pub fn Spark::new() -> Spark {
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
pub fn Ring::new() -> Ring {
  { active: false, x: 0.0, y: 0.0, r: 0.0, life: 0.0, kind: 0 }
}

///|
pub fn Shadow::new() -> Shadow {
  { active: false, x: 0.0, y: 0.0, w: 0.0, h: 0.0, life: 0.0, rot: 0.0 }
}

///|
pub fn Player::new() -> Player {
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
pub fn Game::new() -> Game {
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
    mouse_x: 0.0,
    mouse_y: 0.0,
    mouse_hold: false,
    touch_count: 0,
  }
}

///|
pub fn init_title_scene(game : Game) -> Unit {
  clear_customers(game)
  clear_sparks(game)
  clear_rings(game)
  clear_shadows(game)
  reset_player(game)

  game.state = state_title
  game.stage = 1
  game.stage_goal = stage_goal_base
  game.score = 0
  game.served = 0
  game.missed = 0
  game.combo = 0
  game.combo_t = 0.0

  game.reputation = reputation_max
  game.focus = focus_max
  game.time_left = stage_time_base

  game.spawn_cd = 0.8
  game.brew_active = false
  game.brew_t = 0.0
  game.brew_type = tea_jasmine
  game.ready_cup = -1
  game.focus_mode = false

  game.flash_t = 0.0
  game.shake_t = 0.0
  game.result_t = 0.0
  game.hint_t = 0.0
  game.time_s = 0.0
}

///|
fn clear_customers(game : Game) -> Unit {
  for customer in game.customers {
    customer.active = false
    customer.tea_type = tea_jasmine
    customer.slot = 0
    customer.x = 0.0
    customer.y = 0.0
    customer.patience = 0.0
    customer.patience_max = 0.0
    customer.life = 0.0
    customer.reward = 0
    customer.mood = 0.0
    customer.served_t = 0.0
    customer.angry = false
  }
}

///|
fn clear_sparks(game : Game) -> Unit {
  for spark in game.sparks {
    spark.active = false
    spark.x = 0.0
    spark.y = 0.0
    spark.vx = 0.0
    spark.vy = 0.0
    spark.life = 0.0
    spark.size = 0.0
    spark.kind = 0
  }
}

///|
fn clear_rings(game : Game) -> Unit {
  for ring in game.rings {
    ring.active = false
    ring.x = 0.0
    ring.y = 0.0
    ring.r = 0.0
    ring.life = 0.0
    ring.kind = 0
  }
}

///|
fn clear_shadows(game : Game) -> Unit {
  for shadow in game.shadows {
    shadow.active = false
    shadow.x = 0.0
    shadow.y = 0.0
    shadow.w = 0.0
    shadow.h = 0.0
    shadow.life = 0.0
    shadow.rot = 0.0
  }
}

///|
fn reset_player(game : Game) -> Unit {
  game.player.x = 628.0
  game.player.y = 468.0
  game.player.vx = 0.0
  game.player.vy = 0.0
  game.player.w = player_w
  game.player.h = player_h
  game.player.angle = 0.0
  game.player.dash_cd = 0.0
  game.player.dash_t = 0.0
  game.player.interact_t = 0.0
  game.player.anim_t = 0.0
  game.player.carry_water = false
  game.player.carry_leaf = -1
}
