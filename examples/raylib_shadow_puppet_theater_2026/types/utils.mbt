///|
pub fn maxi(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub fn clampi(v : Int, lo : Int, hi : Int) -> Int {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
pub fn clampf(v : Float, lo : Float, hi : Float) -> Float {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
pub fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
pub fn sinf(v : Float) -> Float {
  Float::from_double(@math.sin(v.to_double()))
}

///|
pub fn same_pose(a : Pose, b : Pose) -> Bool {
  a.ax == b.ax && a.ay == b.ay
}

///|
pub fn set_message(game : Game, text : String, ttl : Float) -> Unit {
  game.message = text
  game.message_t = ttl
}

///|
pub fn add_score(game : Game, delta : Int) -> Unit {
  game.score = maxi(0, game.score + delta)
  if game.score > game.best_score {
    game.best_score = game.score
  }
}

///|
pub fn reset_current_pose(game : Game) -> Unit {
  game.current_pose.ax = 0
  game.current_pose.ay = 0
}

///|
pub fn target_pose(game : Game) -> Pose {
  if game.target_idx < game.sequence.length() {
    game.sequence[game.target_idx]
  } else {
    Pose::new(0, 0)
  }
}

///|
pub fn active_slow_factor(game : Game) -> Float {
  if game.burst_t > 0.0 {
    burst_slow_factor
  } else {
    1.0
  }
}
