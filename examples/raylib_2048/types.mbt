///|
struct Tile {
  mut value : Int
  mut anim_x : Float // current animated x position
  mut anim_y : Float // current animated y position
  mut target_x : Float // target x position
  mut target_y : Float // target y position
  mut scale : Float // pop animation scale (1.0 = normal)
  mut is_new : Bool // just spawned
  mut is_merged : Bool // just merged
}

///|
fn Tile::empty() -> Tile {
  {
    value: 0,
    anim_x: 0.0,
    anim_y: 0.0,
    target_x: 0.0,
    target_y: 0.0,
    scale: 1.0,
    is_new: false,
    is_merged: false,
  }
}

///|
struct Game {
  tiles : Array[Tile]
  prev_values : Array[Int]
  mut state : Int
  mut score : Int
  mut best_score : Int
  mut prev_score : Int
  mut can_undo : Bool
  mut animating : Bool
  mut msg : String
  mut msg_t : Float
  mut keep_playing : Bool // continue after 2048
}

///|
fn Game::new() -> Game {
  let g : Game = {
    tiles: Array::makei(cell_count, fn(_i) { Tile::empty() }),
    prev_values: Array::make(cell_count, 0),
    state: state_title,
    score: 0,
    best_score: 0,
    prev_score: 0,
    can_undo: false,
    animating: false,
    msg: "",
    msg_t: 0.0,
    keep_playing: false,
  }
  g
}

///|
fn clampf(v : Float, lo : Float, hi : Float) -> Float {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}
