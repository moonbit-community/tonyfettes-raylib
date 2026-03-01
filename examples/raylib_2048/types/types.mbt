///|
pub(all) struct Tile {
  mut value : Int
  mut anim_x : Float
  mut anim_y : Float
  mut target_x : Float
  mut target_y : Float
  mut scale : Float
  mut is_new : Bool
  mut is_merged : Bool
}

///|
pub fn Tile::empty() -> Tile {
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
pub(all) struct Game {
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
  mut keep_playing : Bool
}

///|
pub fn Game::new() -> Game {
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
