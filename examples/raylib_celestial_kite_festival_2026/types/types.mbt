///|
pub(all) enum ObjKind {
  Lantern
  Bird
  Storm
  Orb
  Koi
} derive(Eq)

///|
pub(all) struct SkyObj {
  mut active : Bool
  mut kind : ObjKind
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut w : Float
  mut h : Float
  mut hp : Float
  mut life : Float
  mut phase : Float
  mut value : Int
  mut flagged : Bool
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
pub(all) struct Halo {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut r : Float
  mut life : Float
  mut kind : Int
}

///|
pub(all) struct Trail {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut life : Float
  mut w : Float
  mut h : Float
  mut rot : Float
}

///|
pub(all) enum GameState {
  Title
  Play
  StageClear
  GameOver
} derive(Eq)

///|
pub(all) struct Kite {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut w : Float
  mut h : Float
  mut angle : Float
  mut invuln : Float
  mut hurt_t : Float
  mut burst_glow : Float
  mut reel_glow : Float
  mut anim_t : Float
}

///|
pub(all) struct Game {
  objs : Array[SkyObj]
  sparks : Array[Spark]
  halos : Array[Halo]
  trails : Array[Trail]
  kite : Kite
  mut state : GameState
  mut stage : Int
  mut stage_goal : Int
  mut score : Int
  mut best_score : Int
  mut rescued : Int
  mut hits : Int
  mut time_left : Float
  mut calm : Float
  mut energy : Float
  mut wind_x : Float
  mut wind_y : Float
  mut wind_power : Float
  mut gust_t : Float
  mut gust_phase : Float
  mut rope_len : Float
  mut burst_cd : Float
  mut burst_t : Float
  mut spawn_t : Float
  mut wave_t : Float
  mut combo : Int
  mut combo_t : Float
  mut flash_t : Float
  mut shake_t : Float
  mut result_t : Float
  mut hint_t : Float
  mut time_s : Float
  mut input_x : Float
  mut input_y : Float
  mut input_burst_press : Bool
  mut input_reel_hold : Bool
  mut input_restart_press : Bool
  mut touch_mode : Bool
  mut touch_burst_prev : Bool
  mut touch_restart_prev : Bool
  mut mouse_x : Float
  mut mouse_y : Float
  mut mouse_hold : Bool
  mut touch_count : Int
}

///|
pub fn SkyObj::new() -> SkyObj {
  {
    active: false,
    kind: Lantern,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    w: 0.0,
    h: 0.0,
    hp: 0.0,
    life: 0.0,
    phase: 0.0,
    value: 0,
    flagged: false,
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
pub fn Halo::new() -> Halo {
  { active: false, x: 0.0, y: 0.0, r: 0.0, life: 0.0, kind: 0 }
}

///|
pub fn Trail::new() -> Trail {
  { active: false, x: 0.0, y: 0.0, life: 0.0, w: 0.0, h: 0.0, rot: 0.0 }
}

///|
pub fn Kite::new() -> Kite {
  {
    x: Float::from_int(screen_w) * 0.5,
    y: Float::from_int(screen_h) * 0.5,
    vx: 0.0,
    vy: 0.0,
    w: kite_w,
    h: kite_h,
    angle: 0.0,
    invuln: 0.0,
    hurt_t: 0.0,
    burst_glow: 0.0,
    reel_glow: 0.0,
    anim_t: 0.0,
  }
}

///|
pub fn Game::new() -> Game {
  {
    objs: Array::makei(max_objs, fn(_i) { SkyObj::new() }),
    sparks: Array::makei(max_sparks, fn(_i) { Spark::new() }),
    halos: Array::makei(max_halos, fn(_i) { Halo::new() }),
    trails: Array::makei(max_trails, fn(_i) { Trail::new() }),
    kite: Kite::new(),
    state: Title,
    stage: 1,
    stage_goal: stage_goal_base,
    score: 0,
    best_score: 0,
    rescued: 0,
    hits: 0,
    time_left: stage_time_base,
    calm: calm_max,
    energy: energy_max,
    wind_x: 0.0,
    wind_y: 0.0,
    wind_power: wind_base,
    gust_t: 0.0,
    gust_phase: 0.0,
    rope_len: kite_rope_len_max,
    burst_cd: 0.0,
    burst_t: 0.0,
    spawn_t: 0.0,
    wave_t: 0.0,
    combo: 0,
    combo_t: 0.0,
    flash_t: 0.0,
    shake_t: 0.0,
    result_t: 0.0,
    hint_t: 0.0,
    time_s: 0.0,
    input_x: 0.0,
    input_y: 0.0,
    input_burst_press: false,
    input_reel_hold: false,
    input_restart_press: false,
    touch_mode: false,
    touch_burst_prev: false,
    touch_restart_prev: false,
    mouse_x: 0.0,
    mouse_y: 0.0,
    mouse_hold: false,
    touch_count: 0,
  }
}
