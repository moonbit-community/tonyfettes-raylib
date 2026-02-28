///|
fn update_coins(game : @types.Game, dt : Float) -> Unit {
  let player = game.player
  let px0 = player.x - @types.player_half_w()
  let py0 = player.y - @types.player_half_h()
  let px1 = player.x + @types.player_half_w()
  let py1 = player.y + @types.player_half_h()

  for i in 0..<game.coins.length() {
    let coin = game.coins[i]
    if not(coin.active) {
      continue
    }

    coin.phase += dt * 7.0
    coin.y = coin.base_y + @math.sinf(coin.phase) * 3.8

    let r : Float = 10.0
    let cx0 = coin.x - r
    let cy0 = coin.y - r
    let cx1 = coin.x + r
    let cy1 = coin.y + r

    if @types.rects_overlap(px0, py0, px1, py1, cx0, cy0, cx1, cy1) {
      coin.active = false
      collect_coin(game, coin.x, coin.y)
    }
  }
}
