///|
fn safe_roll(rolls : Array[Int], count : Int, idx : Int) -> Int {
  if idx >= 0 && idx < count {
    rolls[idx]
  } else {
    0
  }
}

///|
fn maybe_roll(rolls : Array[Int], count : Int, idx : Int) -> Int {
  if idx >= 0 && idx < count {
    rolls[idx]
  } else {
    -2
  }
}

///|
fn show_roll(v : Int) -> String {
  if v < 0 {
    ""
  } else if v == 0 {
    "-"
  } else {
    v.to_string()
  }
}

///|
fn clear_rolls(game : Game) -> Unit {
  game.roll_count = 0
  for i = 0; i < game.rolls.length(); i = i + 1 {
    game.rolls[i] = 0
  }
  for i = 0; i < game.frame_totals.length(); i = i + 1 {
    game.frame_totals[i] = -1
  }
  game.score = 0
}

///|
fn push_roll(game : Game, knocked : Int) -> Unit {
  if game.roll_count >= game.rolls.length() {
    return
  }
  game.rolls[game.roll_count] = knocked
  game.roll_count = game.roll_count + 1
}

///|
fn recompute_score(game : Game) -> Unit {
  for i = 0; i < 10; i = i + 1 {
    game.frame_totals[i] = -1
  }

  let mut idx : Int = 0
  let mut total : Int = 0

  for frame = 0; frame < 10; frame = frame + 1 {
    if idx >= game.roll_count {
      break
    }

    if frame < 9 {
      let a : Int = safe_roll(game.rolls, game.roll_count, idx)
      if a == 10 {
        if idx + 2 >= game.roll_count {
          break
        }
        total = total +
          10 +
          safe_roll(game.rolls, game.roll_count, idx + 1) +
          safe_roll(game.rolls, game.roll_count, idx + 2)
        game.frame_totals[frame] = total
        idx = idx + 1
      } else {
        if idx + 1 >= game.roll_count {
          break
        }

        let b : Int = safe_roll(game.rolls, game.roll_count, idx + 1)
        if a + b == 10 {
          if idx + 2 >= game.roll_count {
            break
          }
          total = total + 10 + safe_roll(game.rolls, game.roll_count, idx + 2)
        } else {
          total = total + a + b
        }

        game.frame_totals[frame] = total
        idx = idx + 2
      }
    } else {
      if idx + 1 >= game.roll_count {
        break
      }

      let a : Int = safe_roll(game.rolls, game.roll_count, idx)
      let b : Int = safe_roll(game.rolls, game.roll_count, idx + 1)
      let mut frame_total : Int = a + b

      if a == 10 || a + b == 10 {
        if idx + 2 >= game.roll_count {
          break
        }
        frame_total = frame_total +
          safe_roll(game.rolls, game.roll_count, idx + 2)
      }

      total = total + frame_total
      game.frame_totals[frame] = total
      idx = game.roll_count
    }
  }

  game.score = total
  if total > game.best_score {
    game.best_score = total
  }
}

///|
fn frame_start_roll_idx(game : Game, target : Int) -> Int {
  let mut idx : Int = 0

  for frame = 0; frame < target; frame = frame + 1 {
    if frame >= 9 {
      break
    }

    if idx >= game.roll_count {
      break
    }

    if game.rolls[idx] == 10 {
      idx = idx + 1
    } else {
      idx = idx + 2
    }
  }

  idx
}

///|
fn frame_marks(game : Game, frame : Int) -> (String, String, String) {
  let idx : Int = frame_start_roll_idx(game, frame)
  let a : Int = maybe_roll(game.rolls, game.roll_count, idx)
  let b : Int = maybe_roll(game.rolls, game.roll_count, idx + 1)
  let c : Int = maybe_roll(game.rolls, game.roll_count, idx + 2)

  if frame < 9 {
    if a == 10 {
      return ("X", "", "")
    }
    if a < -1 {
      return ("", "", "")
    }
    if b < -1 {
      return (show_roll(a), "", "")
    }
    if a + b == 10 {
      return (show_roll(a), "/", "")
    }
    return (show_roll(a), show_roll(b), "")
  }

  let r1 : String = if a == 10 { "X" } else { show_roll(a) }

  let r2 : String = if b < -1 {
    ""
  } else if a == 10 {
    if b == 10 {
      "X"
    } else {
      show_roll(b)
    }
  } else if a >= 0 && b >= 0 && a + b == 10 {
    "/"
  } else {
    show_roll(b)
  }

  let r3 : String = if c < -1 {
    ""
  } else if a == 10 {
    if b == 10 {
      if c == 10 {
        "X"
      } else {
        show_roll(c)
      }
    } else if b >= 0 && c >= 0 && b + c == 10 {
      "/"
    } else if c == 10 {
      "X"
    } else {
      show_roll(c)
    }
  } else if a >= 0 && b >= 0 && a + b == 10 {
    if c == 10 {
      "X"
    } else {
      show_roll(c)
    }
  } else {
    ""
  }

  (r1, r2, r3)
}
