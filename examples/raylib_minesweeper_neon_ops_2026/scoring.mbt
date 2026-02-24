///|
fn safe_cells_total(game : Game) -> Int {
  board_w * board_h - game.mine_count
}

///|
fn flags_left(game : Game) -> Int {
  game.mine_count - game.flagged_count
}

///|
fn unrevealed_safe_cells(game : Game) -> Int {
  let left : Int = safe_cells_total(game) - game.revealed_safe
  if left < 0 {
    0
  } else {
    left
  }
}

///|
fn clear_ratio_pct(game : Game) -> Int {
  let total : Int = safe_cells_total(game)
  if total <= 0 {
    return 0
  }

  let mut pct : Int = game.revealed_safe * 100 / total
  if pct < 0 {
    pct = 0
  }
  if pct > 100 {
    pct = 100
  }
  pct
}

///|
fn compute_grade(score : Int, time_s : Int, mistakes : Int, lives : Int) -> Int {
  let mut v : Int = score

  if time_s <= 130 {
    v = v + 380
  } else if time_s <= 200 {
    v = v + 250
  } else if time_s <= 280 {
    v = v + 120
  }

  v = v + lives * 170 - mistakes * 220

  if v >= 7000 {
    grade_s
  } else if v >= 5200 {
    grade_a
  } else if v >= 3600 {
    grade_b
  } else if v >= 2200 {
    grade_c
  } else {
    grade_d
  }
}

///|
fn grade_name(grade : Int) -> String {
  if grade == grade_s {
    "S"
  } else if grade == grade_a {
    "A"
  } else if grade == grade_b {
    "B"
  } else if grade == grade_c {
    "C"
  } else {
    "D"
  }
}

///|
fn grade_title(grade : Int) -> String {
  if grade == grade_s {
    "Neon Oracle"
  } else if grade == grade_a {
    "City Detective"
  } else if grade == grade_b {
    "Field Agent"
  } else if grade == grade_c {
    "Cadet"
  } else {
    "Rookie"
  }
}
