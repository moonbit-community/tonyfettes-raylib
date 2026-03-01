///|
pub fn grant_score(
  game : @types.Game,
  team : @types.Team,
  points : Int,
) -> Unit {
  game.score_total += points
  if team == @types.Player1 {
    game.players[0].score += points
  } else if team == @types.Player2 {
    game.players[1].score += points
  }
  if game.score_total > game.high_score {
    game.high_score = game.score_total
  }
}

///|
pub fn bump_combo(game : @types.Game) -> Unit {
  game.kill_combo += 1
  if game.kill_combo > 9 {
    game.kill_combo = 9
  }
  game.combo_timer = 2.1
}

///|
pub fn combo_multiplier(game : @types.Game) -> Int {
  if game.kill_combo <= 1 {
    1
  } else if game.kill_combo <= 3 {
    2
  } else if game.kill_combo <= 6 {
    3
  } else {
    4
  }
}

///|
pub fn update_combo(game : @types.Game, dt : Float) -> Unit {
  if game.combo_timer > 0.0 {
    game.combo_timer -= dt
    if game.combo_timer <= 0.0 {
      game.combo_timer = 0.0
      game.kill_combo = 0
    }
  }
}
