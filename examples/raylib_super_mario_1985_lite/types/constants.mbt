///|
pub let screen_width : Int = 1280

///|
pub let screen_height : Int = 720

///|
pub let hud_height : Int = 84

///|
pub let tile_size : Int = 32

///|
pub let tile_size_f : Float = 32.0

///|
pub let world_tiles_w : Int = 236

///|
pub let world_tiles_h : Int = 22

///|
pub let world_width_px : Float = Float::from_int(world_tiles_w * tile_size)

///|
pub let world_height_px : Float = Float::from_int(world_tiles_h * tile_size)

///|
pub let ground_row : Int = 17

///|
pub let state_title : Int = 0

///|
pub let state_playing : Int = 1

///|
pub let state_win : Int = 2

///|
pub let state_game_over : Int = 3

///|
pub let tile_empty : Int = 0

///|
pub let tile_ground : Int = 1

///|
pub let tile_brick : Int = 2

///|
pub let tile_question : Int = 3

///|
pub let tile_used : Int = 4

///|
pub let tile_pipe : Int = 5

///|
pub let tile_flag_pole : Int = 6

///|
pub let tile_castle : Int = 7

///|
pub let player_w : Float = 24.0

///|
pub let player_h : Float = 30.0

///|
pub let player_start_x : Float = 3.0 * tile_size_f

///|
pub let gravity : Float = 2150.0

///|
pub let run_accel_ground : Float = 2300.0

///|
pub let run_accel_air : Float = 1500.0

///|
pub let run_friction : Float = 2700.0

///|
pub let max_run_speed : Float = 270.0

///|
pub let max_fall_speed : Float = 950.0

///|
pub let jump_speed : Float = 760.0

///|
pub let stomp_bounce_speed : Float = 510.0

///|
pub let coyote_time : Float = 0.09

///|
pub let jump_buffer_time : Float = 0.11

///|
pub let jump_cut_multiplier : Float = 0.52

///|
pub let player_invuln_time : Float = 1.3

///|
pub let start_time_seconds : Int = 400

///|
pub let flag_slide_speed : Float = 210.0

///|
pub let castle_walk_speed : Float = 130.0

///|
pub let camera_lerp : Float = 9.0

///|
pub let camera_lead_px : Float = 165.0

///|
pub let enemy_w : Float = 24.0

///|
pub let enemy_h : Float = 22.0

///|
pub let enemy_speed : Float = 88.0

///|
pub let max_enemies : Int = 56

///|
pub let max_coins : Int = 256

///|
pub let max_particles : Int = 720

///|
pub let coin_collect_score : Int = 200

///|
pub let stomp_score : Int = 400

///|
pub let block_hit_score : Int = 50
