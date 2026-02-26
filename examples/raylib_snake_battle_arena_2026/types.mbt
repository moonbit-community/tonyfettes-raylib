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
struct Rival {
  mut alive : Bool
  mut len : Int
  mut dir : Int
  mut next_dir : Int
  mut grow : Int
  mut score : Int
  mut deaths : Int
  color_kind : Int
  seg_x : Array[Int]
  seg_y : Array[Int]
}

///|
struct Game {
  p_seg_x : Array[Int]
  p_seg_y : Array[Int]
  sparks : Array[Spark]
  mut p_alive : Bool
  mut p_len : Int
  mut p_dir : Int
  mut p_next_dir : Int
  mut p_grow : Int
  rivals : Array[Rival]
  mut food_x : Int
  mut food_y : Int
  mut food_kind : Int
  mut trap_x : Int
  mut trap_y : Int
  mut trap_active : Bool
  mut trap_ttl : Float
  mut trap_flash : Float
  mut state : Int
  mut score : Int
  mut best_score : Int
  mut lives : Int
  mut total_kills : Int
  mut combo : Int
  mut combo_t : Float
  mut step_acc : Float
  mut game_t : Float
  mut ui_t : Float
  mut boost_meter : Float
  mut boost_on : Bool
  mut hint_left : Int
  mut hint_t : Float
  mut hint_x : Int
  mut hint_y : Int
  mut msg : String
  mut msg_t : Float
  mut shake_t : Float
  mut touch_cd : Float
  mut win : Bool
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
fn Rival::new(kind : Int) -> Rival {
  {
    alive: true,
    len: 4,
    dir: if kind % 2 == 0 {
      dir_left
    } else {
      dir_right
    },
    next_dir: if kind % 2 == 0 {
      dir_left
    } else {
      dir_right
    },
    grow: 0,
    score: 0,
    deaths: 0,
    color_kind: kind,
    seg_x: Array::make(max_segments, 0),
    seg_y: Array::make(max_segments, 0),
  }
}

///|
fn Game::new() -> Game {
  {
    p_seg_x: Array::make(max_segments, 0),
    p_seg_y: Array::make(max_segments, 0),
    sparks: Array::makei(1300, fn(_i) { Spark::new() }),
    p_alive: true,
    p_len: 5,
    p_dir: dir_right,
    p_next_dir: dir_right,
    p_grow: 0,
    rivals: Array::makei(max_rivals, fn(i) { Rival::new(i) }),
    food_x: 0,
    food_y: 0,
    food_kind: food_normal,
    trap_x: 0,
    trap_y: 0,
    trap_active: false,
    trap_ttl: 0.0,
    trap_flash: 0.0,
    state: state_title,
    score: 0,
    best_score: 0,
    lives: lives_default,
    total_kills: 0,
    combo: 0,
    combo_t: 0.0,
    step_acc: 0.0,
    game_t: 0.0,
    ui_t: 0.0,
    boost_meter: 1.0,
    boost_on: false,
    hint_left: 3,
    hint_t: 0.0,
    hint_x: 0,
    hint_y: 0,
    msg: "",
    msg_t: 0.0,
    shake_t: 0.0,
    touch_cd: 0.0,
    win: false,
  }
}
