///|
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  update_timers(game, dt)

  let start_press : Bool = detect_start_press(game)
  let next_press : Bool = detect_next_press(game)
  let reset_press : Bool = detect_reset_press(game)

  match game.state {
    @types.Title => if start_press { reset_round(game, true) }
    @types.Play => {
      let held_dir : @types.Dir = detect_held_dir(game)
      update_cursor_hold(game, dt, held_dir)

      if game.turn == @types.Human {
        let place_press : Bool = detect_place_press(game)
        let hint_press : Bool = detect_hint_press(game)
        let undo_press : Bool = detect_undo_press(game)
        let clear_press : Bool = detect_clear_press(game)
        let board_tap = detect_board_tap(game)

        if reset_press && game.touch_action_cd <= 0.0 {
          game.touch_action_cd = 0.2
          reset_round(game, true)
        } else if hint_press && game.touch_action_cd <= 0.0 {
          game.touch_action_cd = 0.2
          ignore(use_hint(game))
        } else if undo_press && game.touch_action_cd <= 0.0 {
          game.touch_action_cd = 0.2
          ignore(undo_last_turn(game))
        } else if clear_press && game.touch_action_cd <= 0.0 {
          game.touch_action_cd = 0.12
          @types.clear_hint(game)
          @types.set_message(game, "Hint cleared", 0.45)
        } else if board_tap.0 && game.touch_action_cd <= 0.0 {
          game.touch_action_cd = 0.1
          @types.clear_hint(game)
          ignore(place_stone(game, board_tap.1, board_tap.2, @types.Human))
        } else if place_press && game.touch_action_cd <= 0.0 {
          game.touch_action_cd = 0.1
          @types.clear_hint(game)
          ignore(place_stone(game, game.cursor_x, game.cursor_y, @types.Human))
        }
      }

      ai_step(game)
    }
    @types.Result =>
      if next_press || reset_press {
        let odd_round : Bool = (game.human_wins + game.ai_wins + game.draws) % 2 ==
          1
        reset_round(game, not(odd_round))
      }
  }
}
