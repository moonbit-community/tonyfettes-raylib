///|
pub let screen_width : Int = 980

///|
pub let screen_height : Int = 760

///|
pub let map_tiles_w : Int = 26

///|
pub let map_tiles_h : Int = 26

///|
pub let tile_size : Int = 24

///|
pub let map_pixel_w : Int = map_tiles_w * tile_size

///|
pub let map_pixel_h : Int = map_tiles_h * tile_size

///|
pub let map_offset_x : Int = 36

///|
pub let map_offset_y : Int = 50

///|
pub let panel_x : Int = map_offset_x + map_pixel_w + 20

///|
pub let panel_w : Int = screen_width - panel_x - 24

///|
pub let tank_size : Float = 20.0

///|
pub let tank_half : Float = tank_size / 2.0

///|
pub let bullet_radius : Float = 3.0

///|
pub let max_players : Int = 2

///|
pub let max_enemies : Int = 42

///|
pub let max_bullets : Int = 320

///|
pub let max_particles : Int = 960

///|
pub let max_powerups : Int = 32

///|
pub let max_cores : Int = 20

///|
pub let max_tiles : Int = map_tiles_w * map_tiles_h

///|
pub let enemy_on_field_limit : Int = 8

///|
pub let stage_intro_time : Float = 1.6

///|
pub let stage_clear_time : Float = 2.4

///|
pub let game_over_delay : Float = 2.8

///|
pub let campaign_clear_delay : Float = 3.6

///|
pub let enemy_spawn_period : Float = 0.95

///|
pub let powerup_life : Float = 11.0

///|
pub let freeze_duration : Float = 6.0

///|
pub let shovel_duration : Float = 11.0

///|
pub let player_respawn_delay : Float = 1.2

///|
pub let player_invuln_spawn : Float = 2.0

///|
pub let player_reload_base : Float = 0.30

///|
pub let enemy_reload_base : Float = 0.68

///|
pub let bullet_speed_player : Float = 350.0

///|
pub let bullet_speed_enemy : Float = 290.0

///|
pub let speed_player : Float = 128.0

///|
pub let speed_enemy_basic : Float = 78.0

///|
pub let speed_enemy_fast : Float = 110.0

///|
pub let speed_enemy_heavy : Float = 66.0

///|
pub let speed_enemy_sniper : Float = 84.0

///|
pub let base_tile_x : Int = 12

///|
pub let base_tile_y : Int = 24

///|
pub let menu_select_blink_speed : Float = 3.0

///|
pub let camera_shake_decay : Float = 3.3

///|
pub let camera_shake_power : Float = 7.5

///|
pub let level_count : Int = 96

///|
pub let map_pattern_count : Int = 48

///|
pub let core_radius : Float = 14.0

///|
pub let core_hp_base : Int = 18

///|
pub let core_score_base : Int = 260

///|
pub let enemy_spawn_x0 : Float = 2.0 * Float::from_int(tile_size) + tank_half

///|
pub let enemy_spawn_x1 : Float = 12.0 * Float::from_int(tile_size) + tank_half

///|
pub let enemy_spawn_x2 : Float = 22.0 * Float::from_int(tile_size) + tank_half

///|
pub let enemy_spawn_y : Float = 1.5 * Float::from_int(tile_size)

///|
pub let player1_spawn_x : Float = 8.0 * Float::from_int(tile_size) + tank_half

///|
pub let player1_spawn_y : Float = 24.0 * Float::from_int(tile_size) + tank_half

///|
pub let player2_spawn_x : Float = 16.0 * Float::from_int(tile_size) + tank_half

///|
pub let player2_spawn_y : Float = 24.0 * Float::from_int(tile_size) + tank_half

///|
pub let enemy_icon_rows : Int = 10

///|
pub let enemy_icon_cols : Int = 2

///|
pub let base_ring_count : Int = 14

///|
pub let base_ring_x : Array[Int] = [
  11, 12, 13, 14, 11, 14, 11, 14, 11, 12, 13, 14, 12, 13,
]

///|
pub let base_ring_y : Array[Int] = [
  22, 22, 22, 22, 23, 23, 24, 24, 25, 25, 25, 25, 24, 24,
]
