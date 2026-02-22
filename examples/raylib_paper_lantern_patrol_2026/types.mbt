///|
struct InputState {
  mut move_x : Int
  mut move_y : Int
  mut press_interact : Bool
  mut press_cancel : Bool
  mut press_calm : Bool
  mut press_pause : Bool
  mut press_restart : Bool
  mut press_start : Bool
}

///|
fn InputState::new() -> InputState {
  {
    move_x: 0,
    move_y: 0,
    press_interact: false,
    press_cancel: false,
    press_calm: false,
    press_pause: false,
    press_restart: false,
    press_start: false,
  }
}

///|
struct Patrol {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut escort : Int
  mut guard_t : Float
  mut calm_t : Float
  mut calm_cd : Float
}

///|
fn Patrol::new() -> Patrol {
  let gate = gate_position()
  {
    x: gate.0 + 30.0,
    y: gate.1,
    vx: 0.0,
    vy: 0.0,
    escort: -1,
    guard_t: 0.0,
    calm_t: 0.0,
    calm_cd: 0.0,
  }
}

///|
struct Lantern {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut flame : Float
  mut target_shrine : Int
  mut escorting : Bool
  mut wobble : Float
}

///|
fn Lantern::new() -> Lantern {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    flame: 0.0,
    target_shrine: 0,
    escorting: false,
    wobble: 0.0,
  }
}

///|
struct Gust {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut radius : Float
  mut power : Float
  mut life : Float
}

///|
fn Gust::new() -> Gust {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    radius: 0.0,
    power: 0.0,
    life: 0.0,
  }
}

///|
struct Spark {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut life : Float
  mut power : Float
  mut size : Float
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
    power: 0.0,
    size: 0.0,
  }
}

///|
struct Thief {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut speed : Float
  mut target : Int
  mut steal_cd : Float
  mut life : Float
}

///|
fn Thief::new() -> Thief {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    speed: 0.0,
    target: -1,
    steal_cd: 0.0,
    life: 0.0,
  }
}

///|
struct Game {
  input : InputState
  patrol : Patrol
  lanterns : Array[Lantern]
  gusts : Array[Gust]
  sparks : Array[Spark]
  thieves : Array[Thief]
  mut state : Int
  mut score : Int
  mut best_score : Int
  mut deliveries : Int
  mut extinguished : Int
  mut combo : Int
  mut combo_t : Float
  mut run_time : Float
  mut lantern_spawn_cd : Float
  mut gust_spawn_cd : Float
  mut spark_spawn_cd : Float
  mut thief_spawn_cd : Float
  mut status_text : String
  mut status_t : Float
  mut screen_flash_t : Float
  mut game_over_reason : String
}

///|
fn Game::new() -> Game {
  {
    input: InputState::new(),
    patrol: Patrol::new(),
    lanterns: Array::makei(max_lanterns, fn(_i) { Lantern::new() }),
    gusts: Array::makei(max_gusts, fn(_i) { Gust::new() }),
    sparks: Array::makei(max_sparks, fn(_i) { Spark::new() }),
    thieves: Array::makei(max_thieves, fn(_i) { Thief::new() }),
    state: state_title,
    score: 0,
    best_score: 0,
    deliveries: 0,
    extinguished: 0,
    combo: 0,
    combo_t: 0.0,
    run_time: 0.0,
    lantern_spawn_cd: 0.0,
    gust_spawn_cd: 0.0,
    spark_spawn_cd: 0.0,
    thief_spawn_cd: 0.0,
    status_text: "Guide the lanterns safely.",
    status_t: 0.0,
    screen_flash_t: 0.0,
    game_over_reason: "",
  }
}
