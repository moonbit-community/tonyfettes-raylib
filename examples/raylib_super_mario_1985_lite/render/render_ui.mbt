///|
fn draw_hud(game : @types.Game) -> Unit {
  @raylib.draw_rectangle(
    0,
    0,
    @types.screen_width,
    @types.hud_height,
    @raylib.Color::new(18, 18, 26, 255),
  )
  @raylib.draw_rectangle(
    0,
    @types.hud_height - 2,
    @types.screen_width,
    2,
    @raylib.Color::new(68, 90, 134, 255),
  )

  let player = game.player
  let coins_left = @types.remaining_coins(game)
  let enemies_left = @types.active_enemy_count(game)

  @raylib.draw_text("SUPER MARIO 1985 LITE", 18, 12, 28, @raylib.white)
  @raylib.draw_text("SCORE \{player.score}", 20, 46, 20, @raylib.yellow)
  @raylib.draw_text("COINS \{player.coins}", 250, 46, 20, @raylib.gold)
  @raylib.draw_text("LIVES \{player.lives}", 440, 46, 20, @raylib.orange)
  @raylib.draw_text("TIME \{game.time_left}", 610, 46, 20, @raylib.white)
  @raylib.draw_text("ENEMIES \{enemies_left}", 780, 46, 20, @raylib.lightgray)
  @raylib.draw_text("COINS LEFT \{coins_left}", 990, 46, 20, @raylib.lightgray)
}

///|
fn draw_center_panel(
  title : String,
  line1 : String,
  line2 : String,
  line3 : String,
) -> Unit {
  let box_w = 720
  let box_h = 240
  let x = (@types.screen_width - box_w) / 2
  let y = (@types.screen_height - box_h) / 2

  @raylib.draw_rectangle(
    x,
    y,
    box_w,
    box_h,
    @raylib.Color::new(14, 20, 37, 228),
  )
  @raylib.draw_rectangle_lines_ex(
    @raylib.Rectangle::new(
      Float::from_int(x),
      Float::from_int(y),
      Float::from_int(box_w),
      Float::from_int(box_h),
    ),
    2.0,
    @raylib.Color::new(106, 152, 255, 255),
  )

  @raylib.draw_text(title, x + 24, y + 30, 40, @raylib.yellow)
  @raylib.draw_text(line1, x + 24, y + 94, 24, @raylib.white)
  @raylib.draw_text(line2, x + 24, y + 128, 24, @raylib.white)
  @raylib.draw_text(line3, x + 24, y + 168, 24, @raylib.lightgray)
}

///|
fn draw_title_overlay(game : @types.Game) -> Unit {
  let _ = game
  draw_center_panel(
    "WORLD 1-1", "Run, jump, stomp goombas, and smash question blocks.", "Reach the flagpole and walk to the castle to clear the stage.",
    "Controls: Arrow/A,D move | Space/W/Up jump | Enter start",
  )
}

///|
fn draw_win_overlay(game : @types.Game) -> Unit {
  draw_center_panel(
    "COURSE CLEAR!",
    "You reached the castle.",
    "Final score: \{game.player.score} | Coins: \{game.player.coins}",
    "Press Enter or R to play again.",
  )
}

///|
fn draw_game_over_overlay(game : @types.Game) -> Unit {
  draw_center_panel(
    "GAME OVER",
    "Time or lives reached zero.",
    "Score: \{game.player.score} | Coins: \{game.player.coins}",
    "Press Enter or R to restart.",
  )
}

///|
pub fn draw_ui(game : @types.Game) -> Unit {
  draw_hud(game)

  if game.state == @types.state_title {
    draw_title_overlay(game)
  } else if game.state == @types.state_win {
    draw_win_overlay(game)
  } else if game.state == @types.state_game_over {
    draw_game_over_overlay(game)
  }
}
