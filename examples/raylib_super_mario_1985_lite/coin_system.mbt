///|
fn remaining_coins(game : Game) -> Int {
  let mut count = 0
  for i = 0; i < game.coins.length(); i = i + 1 {
    if game.coins[i].active {
      count += 1
    }
  }
  count
}

///|
fn update_coins(game : Game, dt : Float) -> Unit {
  let player = game.player
  let px0 = player.x - player_half_w()
  let py0 = player.y - player_half_h()
  let px1 = player.x + player_half_w()
  let py1 = player.y + player_half_h()

  for i = 0; i < game.coins.length(); i = i + 1 {
    let coin = game.coins[i]
    if not(coin.active) {
      continue i + 1
    }

    coin.phase += dt * 7.0
    coin.y = coin.base_y + @math.sinf(coin.phase) * 3.8

    let r : Float = 10.0
    let cx0 = coin.x - r
    let cy0 = coin.y - r
    let cx1 = coin.x + r
    let cy1 = coin.y + r

    if rects_overlap(px0, py0, px1, py1, cx0, cy0, cx1, cy1) {
      coin.active = false
      collect_coin(game, coin.x, coin.y)
    }
  }
}
