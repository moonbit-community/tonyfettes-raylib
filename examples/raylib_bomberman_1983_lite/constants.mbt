///|
let screen_width : Int = 980

///|
let screen_height : Int = 760

///|
let map_tiles_w : Int = 26

///|
let map_tiles_h : Int = 26

///|
let tile_size : Int = 24

///|
let map_pixel_w : Int = map_tiles_w * tile_size

///|
let map_pixel_h : Int = map_tiles_h * tile_size

///|
let map_offset_x : Int = 36

///|
let map_offset_y : Int = 50

///|
let panel_x : Int = map_offset_x + map_pixel_w + 20

///|
let panel_w : Int = screen_width - panel_x - 24

///|
let tank_size : Float = 20.0

///|
let tank_half : Float = tank_size / 2.0

///|
let bullet_radius : Float = 3.0

///|
let max_players : Int = 2

///|
let max_enemies : Int = 42

///|
let max_bullets : Int = 320

///|
let max_particles : Int = 960

///|
let max_powerups : Int = 32

///|
let max_bombs : Int = 96

///|
let max_tiles : Int = map_tiles_w * map_tiles_h

///|
let enemy_on_field_limit : Int = 8

///|
let stage_intro_time : Float = 1.6

///|
let stage_clear_time : Float = 2.4

///|
let game_over_delay : Float = 2.8

///|
let campaign_clear_delay : Float = 3.6

///|
let enemy_spawn_period : Float = 0.95

///|
let powerup_life : Float = 11.0

///|
let freeze_duration : Float = 6.0

///|
let shovel_duration : Float = 11.0

///|
let player_respawn_delay : Float = 1.2

///|
let player_invuln_spawn : Float = 2.0

///|
let player_reload_base : Float = 0.30

///|
let enemy_reload_base : Float = 0.68

///|
let bomb_fuse_time : Float = 1.8

///|
let bomb_blast_time : Float = 0.36

///|
let bomb_range_base : Int = 2

///|
let bomb_chain_trigger_window : Float = 0.06

///|
let bomb_contact_radius : Float = 8.0

///|
let bullet_speed_player : Float = 350.0

///|
let bullet_speed_enemy : Float = 290.0

///|
let speed_player : Float = 128.0

///|
let speed_enemy_basic : Float = 78.0

///|
let speed_enemy_fast : Float = 110.0

///|
let speed_enemy_heavy : Float = 66.0

///|
let speed_enemy_sniper : Float = 84.0

///|
let base_tile_x : Int = 12

///|
let base_tile_y : Int = 24

///|
let menu_select_blink_speed : Float = 3.0

///|
let camera_shake_decay : Float = 3.3

///|
let camera_shake_power : Float = 7.5

///|
let level_count : Int = 96

///|
let map_pattern_count : Int = 48

///|
let team_none : Int = 0

///|
let team_player1 : Int = 1

///|
let team_player2 : Int = 2

///|
let team_enemy : Int = 3

///|
let dir_up : Int = 0

///|
let dir_right : Int = 1

///|
let dir_down : Int = 2

///|
let dir_left : Int = 3

///|
let tile_empty : Int = 0

///|
let tile_brick : Int = 1

///|
let tile_steel : Int = 2

///|
let tile_water : Int = 3

///|
let tile_bush : Int = 4

///|
let tile_ice : Int = 5

///|
let tile_base : Int = 6

///|
let state_menu : Int = 0

///|
let state_stage_intro : Int = 1

///|
let state_playing : Int = 2

///|
let state_paused : Int = 3

///|
let state_stage_clear : Int = 4

///|
let state_game_over : Int = 5

///|
let state_campaign_clear : Int = 6

///|
let enemy_basic : Int = 0

///|
let enemy_fast : Int = 1

///|
let enemy_heavy : Int = 2

///|
let enemy_sniper : Int = 3

///|
let powerup_shield : Int = 0

///|
let powerup_star : Int = 1

///|
let powerup_grenade : Int = 2

///|
let powerup_clock : Int = 3

///|
let powerup_shovel : Int = 4

///|
let powerup_tank : Int = 5

///|
let enemy_spawn_x0 : Float = 2.0 * Float::from_int(tile_size) + tank_half

///|
let enemy_spawn_x1 : Float = 12.0 * Float::from_int(tile_size) + tank_half

///|
let enemy_spawn_x2 : Float = 22.0 * Float::from_int(tile_size) + tank_half

///|
let enemy_spawn_y : Float = 1.5 * Float::from_int(tile_size)

///|
let player1_spawn_x : Float = 8.0 * Float::from_int(tile_size) + tank_half

///|
let player1_spawn_y : Float = 24.0 * Float::from_int(tile_size) + tank_half

///|
let player2_spawn_x : Float = 16.0 * Float::from_int(tile_size) + tank_half

///|
let player2_spawn_y : Float = 24.0 * Float::from_int(tile_size) + tank_half

///|
let enemy_icon_rows : Int = 10

///|
let enemy_icon_cols : Int = 2

///|
let base_ring_count : Int = 14

///|
let base_ring_x : Array[Int] = [
  11, 12, 13, 14, 11, 14, 11, 14, 11, 12, 13, 14, 12, 13,
]

///|
let base_ring_y : Array[Int] = [
  22, 22, 22, 22, 23, 23, 24, 24, 25, 25, 25, 25, 24, 24,
]
