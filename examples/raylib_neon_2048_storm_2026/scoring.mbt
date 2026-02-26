///|
fn charge_for_merge(v : Int) -> Int {
  if v >= 1024 {
    40
  } else if v >= 512 {
    28
  } else if v >= 256 {
    20
  } else if v >= 128 {
    14
  } else if v >= 64 {
    10
  } else {
    6
  }
}

///|
fn bonus_for_chain(chain : Int) -> Int {
  if chain <= 1 {
    0
  } else if chain == 2 {
    24
  } else if chain == 3 {
    56
  } else {
    56 + (chain - 3) * 34
  }
}

///|
fn tile_rank(v : Int) -> Int {
  if v <= 0 {
    0
  } else if v == 2 {
    1
  } else if v == 4 {
    2
  } else if v == 8 {
    3
  } else if v == 16 {
    4
  } else if v == 32 {
    5
  } else if v == 64 {
    6
  } else if v == 128 {
    7
  } else if v == 256 {
    8
  } else if v == 512 {
    9
  } else if v == 1024 {
    10
  } else if v == 2048 {
    11
  } else if v == 4096 {
    12
  } else if v == 8192 {
    13
  } else {
    14
  }
}

///|
fn rank_name(rank : Int) -> String {
  if rank >= 13 {
    "Storm God"
  } else if rank >= 12 {
    "Quantum Master"
  } else if rank >= 11 {
    "Neon Legend"
  } else if rank >= 10 {
    "City Pro"
  } else if rank >= 9 {
    "Street Expert"
  } else if rank >= 8 {
    "Rising Player"
  } else {
    "Rookie"
  }
}

///|
fn final_grade(game : Game) -> String {
  let rank : Int = tile_rank(game.max_tile)
  let score : Int = game.score

  if rank >= 12 || score >= 18000 {
    "S"
  } else if rank >= 11 || score >= 12000 {
    "A"
  } else if rank >= 9 || score >= 7600 {
    "B"
  } else if rank >= 7 || score >= 4200 {
    "C"
  } else {
    "D"
  }
}
