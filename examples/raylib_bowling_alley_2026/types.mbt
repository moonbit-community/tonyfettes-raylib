///|
struct Pin {
  mut standing : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut ang : Float
  mut ang_v : Float
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
struct Game {
  pins : Array[Pin]
  sparks : Array[Spark]
  rolls : Array[Int]
  frame_totals : Array[Int]
  mut roll_count : Int
  mut state : Int
  mut frame : Int
  mut roll_in_frame : Int
  mut first_roll : Int
  mut pins_before_roll : Int
  mut pins_left : Int
  mut ball_x : Float
  mut ball_y : Float
  mut ball_vx : Float
  mut ball_vy : Float
  mut ball_spin : Float
  mut ball_live : Bool
  mut can_throw : Bool
  mut charging : Bool
  mut power : Float
  mut power_dir : Float
  mut aim : Float
  mut spin : Float
  mut resolve_t : Float
  mut game_t : Float
  mut ui_t : Float
  mut shake_t : Float
  mut message : String
  mut message_t : Float
  mut strikes : Int
  mut spares : Int
  mut opens : Int
  mut score : Int
  mut best_score : Int
  mut last_knock : Int
  mut touch_cd : Float
}

///|
fn Pin::new() -> Pin {
  { standing: true, x: 0.0, y: 0.0, vx: 0.0, vy: 0.0, ang: 0.0, ang_v: 0.0 }
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
fn Game::new() -> Game {
  let pins : Array[Pin] = Array::makei(10, fn(_i) { Pin::new() })
  let sparks : Array[Spark] = Array::makei(max_sparks, fn(_i) { Spark::new() })

  {
    pins,
    sparks,
    rolls: Array::make(max_rolls, 0),
    frame_totals: Array::make(10, -1),
    roll_count: 0,
    state: state_title,
    frame: 0,
    roll_in_frame: 0,
    first_roll: 0,
    pins_before_roll: 10,
    pins_left: 10,
    ball_x: ball_start_x,
    ball_y: ball_start_y,
    ball_vx: 0.0,
    ball_vy: 0.0,
    ball_spin: 0.0,
    ball_live: false,
    can_throw: false,
    charging: false,
    power: 0.22,
    power_dir: 1.0,
    aim: 0.0,
    spin: 0.0,
    resolve_t: 0.0,
    game_t: 0.0,
    ui_t: 0.0,
    shake_t: 0.0,
    message: "",
    message_t: 0.0,
    strikes: 0,
    spares: 0,
    opens: 0,
    score: 0,
    best_score: 0,
    last_knock: 0,
    touch_cd: 0.0,
  }
}
