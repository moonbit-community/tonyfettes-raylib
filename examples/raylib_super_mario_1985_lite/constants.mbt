///|
let screen_width : Int = 1280

///|
let screen_height : Int = 720

///|
let hud_height : Int = 84

///|
let tile_size : Int = 32

///|
let tile_size_f : Float = 32.0

///|
let world_tiles_w : Int = 236

///|
let world_tiles_h : Int = 22

///|
let world_width_px : Float = Float::from_int(world_tiles_w * tile_size)

///|
let world_height_px : Float = Float::from_int(world_tiles_h * tile_size)

///|
let ground_row : Int = 17

///|
let state_title : Int = 0

///|
let state_playing : Int = 1

///|
let state_win : Int = 2

///|
let state_game_over : Int = 3

///|
let tile_empty : Int = 0

///|
let tile_ground : Int = 1

///|
let tile_brick : Int = 2

///|
let tile_question : Int = 3

///|
let tile_used : Int = 4

///|
let tile_pipe : Int = 5

///|
let tile_flag_pole : Int = 6

///|
let tile_castle : Int = 7

///|
let player_w : Float = 24.0

///|
let player_h : Float = 30.0

///|
let player_start_x : Float = 3.0 * tile_size_f

///|
let gravity : Float = 2150.0

///|
let run_accel_ground : Float = 2300.0

///|
let run_accel_air : Float = 1500.0

///|
let run_friction : Float = 2700.0

///|
let max_run_speed : Float = 270.0

///|
let max_fall_speed : Float = 950.0

///|
let jump_speed : Float = 760.0

///|
let stomp_bounce_speed : Float = 510.0

///|
let coyote_time : Float = 0.09

///|
let jump_buffer_time : Float = 0.11

///|
let jump_cut_multiplier : Float = 0.52

///|
let player_invuln_time : Float = 1.3

///|
let start_time_seconds : Int = 400

///|
let flag_slide_speed : Float = 210.0

///|
let castle_walk_speed : Float = 130.0

///|
let camera_lerp : Float = 9.0

///|
let camera_lead_px : Float = 165.0

///|
let enemy_w : Float = 24.0

///|
let enemy_h : Float = 22.0

///|
let enemy_speed : Float = 88.0

///|
let max_enemies : Int = 56

///|
let max_coins : Int = 256

///|
let max_particles : Int = 720

///|
let coin_collect_score : Int = 200

///|
let stomp_score : Int = 400

///|
let block_hit_score : Int = 50
