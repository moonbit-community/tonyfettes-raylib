///|
fn load_level(game : Game, level_id : Int) -> Unit {
  let mut id : Int = level_id
  if id < 0 {
    id = 0
  }
  if id >= game.level_count {
    id = game.level_count - 1
  }

  let v : Int = 0
  let f : Int = 1
  let w : Int = 2
  let g : Int = 3
  let b : Int = 4
  let p : Int = 5

  if id == 0 {
    let rows : Array[Array[Int]] = [
      [v, v, w, w, w, w, w, v, v, v],
      [v, w, w, f, f, f, w, w, v, v],
      [w, w, f, f, b, f, f, w, w, v],
      [w, f, f, g, f, g, f, f, w, v],
      [w, f, f, f, p, f, f, f, w, v],
      [w, w, f, f, b, f, f, w, w, v],
      [v, w, w, f, f, f, w, w, v, v],
      [v, v, w, w, w, w, w, v, v, v],
    ]
    apply_level_rows(game, rows, "Dock Warmup", 14)
  } else if id == 1 {
    let rows : Array[Array[Int]] = [
      [v, w, w, w, w, w, w, w, v],
      [w, w, f, f, f, f, f, w, w],
      [w, f, f, b, f, b, f, f, w],
      [w, f, g, f, p, f, g, f, w],
      [w, f, f, b, f, b, f, f, w],
      [w, w, f, f, g, f, f, w, w],
      [v, w, w, w, w, w, w, w, v],
    ]
    apply_level_rows(game, rows, "Twin Lift Hall", 22)
  } else if id == 2 {
    let rows : Array[Array[Int]] = [
      [v, v, w, w, w, w, w, w, v, v],
      [v, w, w, f, f, f, f, w, w, v],
      [w, w, f, f, w, f, f, f, w, w],
      [w, f, f, b, w, g, b, f, f, w],
      [w, f, g, f, p, f, f, g, f, w],
      [w, f, f, b, w, g, b, f, f, w],
      [w, w, f, f, w, f, f, f, w, w],
      [v, w, w, f, f, f, f, w, w, v],
      [v, v, w, w, w, w, w, w, v, v],
    ]
    apply_level_rows(game, rows, "Gear Junction", 28)
  } else if id == 3 {
    let rows : Array[Array[Int]] = [
      [v, v, w, w, w, w, w, w, w, v, v],
      [v, w, w, f, f, f, f, f, w, w, v],
      [w, w, f, f, b, f, b, f, f, w, w],
      [w, f, f, w, f, f, f, w, f, f, w],
      [w, f, g, w, f, p, f, w, g, f, w],
      [w, f, f, w, b, f, b, w, f, f, w],
      [w, w, f, f, f, g, f, f, f, w, w],
      [v, w, w, f, f, f, f, f, w, w, v],
      [v, v, w, w, w, w, w, w, w, v, v],
    ]
    apply_level_rows(game, rows, "Steel Switchback", 34)
  } else if id == 4 {
    let rows : Array[Array[Int]] = [
      [v, w, w, w, w, w, w, w, w, w, v],
      [w, w, f, f, f, g, f, f, f, w, w],
      [w, f, f, b, w, f, w, b, f, f, w],
      [w, f, g, f, w, f, w, f, g, f, w],
      [w, f, f, b, w, p, w, b, f, f, w],
      [w, f, g, f, w, f, w, f, g, f, w],
      [w, f, f, b, w, f, w, b, f, f, w],
      [w, w, f, f, f, g, f, f, f, w, w],
      [v, w, w, w, w, w, w, w, w, w, v],
    ]
    apply_level_rows(game, rows, "Crane Cross", 42)
  } else if id == 5 {
    let rows : Array[Array[Int]] = [
      [v, v, w, w, w, w, w, w, w, v, v],
      [v, w, w, f, f, f, f, f, w, w, v],
      [w, w, f, b, f, w, f, b, f, w, w],
      [w, f, f, f, f, w, f, f, f, f, w],
      [w, f, g, w, f, p, f, w, g, f, w],
      [w, f, f, f, f, w, f, f, f, f, w],
      [w, w, f, b, f, w, f, b, f, w, w],
      [v, w, w, f, f, g, f, f, w, w, v],
      [v, v, w, w, w, w, w, w, w, v, v],
    ]
    apply_level_rows(game, rows, "Midnight Depot", 44)
  } else if id == 6 {
    let rows : Array[Array[Int]] = [
      [v, w, w, w, w, w, w, w, w, w, w, v],
      [w, w, f, f, f, f, f, f, f, f, w, w],
      [w, f, f, b, f, b, f, b, f, f, f, w],
      [w, f, w, w, f, w, f, w, w, f, f, w],
      [w, f, g, f, f, g, p, f, f, g, f, w],
      [w, f, w, w, f, w, f, w, w, f, f, w],
      [w, f, f, b, f, b, f, b, f, f, f, w],
      [w, w, f, f, f, f, g, f, f, f, w, w],
      [v, w, w, w, w, w, w, w, w, w, w, v],
    ]
    apply_level_rows(game, rows, "Triple Cargo", 52)
  } else if id == 7 {
    let rows : Array[Array[Int]] = [
      [v, v, w, w, w, w, w, w, w, w, v, v],
      [v, w, w, f, f, f, f, f, f, w, w, v],
      [w, w, f, f, b, w, b, w, f, f, w, w],
      [w, f, f, g, f, w, f, w, g, f, f, w],
      [w, f, b, f, f, f, p, f, f, b, f, w],
      [w, f, f, g, f, w, f, w, g, f, f, w],
      [w, w, f, f, b, w, b, w, f, f, w, w],
      [v, w, w, f, f, f, f, f, f, w, w, v],
      [v, v, w, w, w, w, w, w, w, w, v, v],
    ]
    apply_level_rows(game, rows, "Rivet Split", 58)
  } else if id == 8 {
    let rows : Array[Array[Int]] = [
      [v, w, w, w, w, w, w, w, w, w, w, v],
      [w, w, f, f, f, f, g, f, f, f, w, w],
      [w, f, f, b, f, w, f, w, b, f, f, w],
      [w, f, g, f, f, w, f, w, f, g, f, w],
      [w, f, f, w, f, f, p, f, f, w, f, w],
      [w, f, g, f, f, w, f, w, f, g, f, w],
      [w, f, f, b, f, w, f, w, b, f, f, w],
      [w, w, f, f, f, f, g, f, f, f, w, w],
      [v, w, w, w, w, w, w, w, w, w, w, v],
    ]
    apply_level_rows(game, rows, "Relay Loop", 62)
  } else if id == 9 {
    let rows : Array[Array[Int]] = [
      [v, v, w, w, w, w, w, w, w, w, v, v],
      [v, w, w, f, f, f, f, f, f, w, w, v],
      [w, w, f, b, f, b, w, b, f, f, w, w],
      [w, f, f, f, g, f, w, f, g, f, f, w],
      [w, f, w, w, f, f, p, f, f, w, f, w],
      [w, f, f, f, g, f, w, f, g, f, f, w],
      [w, w, f, b, f, b, w, b, f, f, w, w],
      [v, w, w, f, f, f, f, f, f, w, w, v],
      [v, v, w, w, w, w, w, w, w, w, v, v],
    ]
    apply_level_rows(game, rows, "Night Shift Maze", 68)
  } else if id == 10 {
    let rows : Array[Array[Int]] = [
      [v, w, w, w, w, w, w, w, w, w, w, w, v],
      [w, w, f, f, f, g, f, g, f, f, f, w, w],
      [w, f, f, b, f, f, f, f, f, b, f, f, w],
      [w, f, w, f, w, f, w, f, w, f, w, f, w],
      [w, f, g, f, f, f, p, f, f, f, g, f, w],
      [w, f, w, f, w, f, w, f, w, f, w, f, w],
      [w, f, f, b, f, f, f, f, f, b, f, f, w],
      [w, w, f, f, f, g, f, g, f, f, f, w, w],
      [v, w, w, w, w, w, w, w, w, w, w, w, v],
    ]
    apply_level_rows(game, rows, "Hydraulic Crown", 76)
  } else {
    let rows : Array[Array[Int]] = [
      [v, v, w, w, w, w, w, w, w, w, w, v, v],
      [v, w, w, f, f, f, f, g, f, f, w, w, v],
      [w, w, f, f, b, f, b, f, b, f, f, w, w],
      [w, f, f, w, f, w, f, w, f, w, f, f, w],
      [w, f, g, f, f, f, p, f, f, f, g, f, w],
      [w, f, f, w, f, w, f, w, f, w, f, f, w],
      [w, w, f, f, b, f, b, f, b, f, f, w, w],
      [v, w, w, f, f, f, f, g, f, f, w, w, v],
      [v, v, w, w, w, w, w, w, w, w, w, v, v],
    ]
    apply_level_rows(game, rows, "Master Freight Ring", 84)
  }

  game.level_index = id
  game.state = state_play
  game.message = "Level \{id + 1}: \{game.level_name}"
  game.message_t = 1.4
}

///|
fn reload_level(game : Game) -> Unit {
  load_level(game, game.level_index)
}

///|
fn restart_campaign(game : Game) -> Unit {
  game.total_moves = 0
  game.total_pushes = 0
  game.total_elapsed = 0.0
  game.campaign_stars = 0
  load_level(game, 0)
}
