///|
fn main {
  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(@types.screen_width, @types.screen_height, "Flight Sim 3D")
  @raylib.set_target_fps(60)
  let game = @types.Game::new()
  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 { dt = 0.05 }
    @game.update_game(game, dt)
    @raylib.begin_drawing()
    let sky_b : Int = if game.weather == @types.weather_storm {
      80
    } else if game.weather == @types.weather_fog {
      160
    } else {
      235
    }
    let sky_g : Int = if game.weather == @types.weather_storm {
      80
    } else if game.weather == @types.weather_fog {
      170
    } else {
      206
    }
    let sky_r : Int = if game.weather == @types.weather_storm {
      60
    } else if game.weather == @types.weather_fog {
      180
    } else {
      135
    }
    @raylib.clear_background(@raylib.Color::new(sky_r, sky_g, sky_b, 255))
    if game.state == @types.state_playing || game.state == @types.state_paused ||
    game.state == @types.state_mission_complete {
      @render.draw_world(game)
    }
    @render.draw_ui(game)
    @raylib.end_drawing()
  }
  @raylib.close_window()
}
