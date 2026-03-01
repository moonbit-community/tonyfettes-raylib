///|
pub let screen_w : Int = 1780

///|
pub let screen_h : Int = 1000

///|
pub let target_fps : Int = 120

///|
pub let board_x0 : Int = 28

///|
pub let board_y0 : Int = 86

///|
pub let cell : Int = 60

///|
pub let grid_w : Int = 23

///|
pub let grid_h : Int = 13

///|
pub let board_w : Int = grid_w * cell

///|
pub let board_h : Int = grid_h * cell

///|
pub let panel_x0 : Int = board_x0 + board_w + 24

///|
pub let panel_w : Int = screen_w - panel_x0 - 24

///|
pub let state_title : Int = 0

///|
pub let state_play : Int = 1

///|
pub let state_result : Int = 2

///|
pub let tile_wall : Int = 0

///|
pub let tile_floor : Int = 1

///|
pub let tile_exit : Int = 2

///|
pub let drone_patrol : Int = 0

///|
pub let drone_hunt : Int = 1

///|
pub let drone_stunned : Int = 2

///|
pub let max_drones : Int = 5

///|
pub let max_cores : Int = 8

///|
pub let max_flares : Int = 6

///|
pub let max_particles : Int = 420

///|
pub let core_need : Int = 6

///|
pub let max_lives : Int = 3

///|
pub let round_time_limit : Float = 210.0

///|
pub let start_x : Int = 2

///|
pub let start_y : Int = 11

///|
pub let exit_x : Int = 21

///|
pub let exit_y : Int = 1

///|
pub let portal_ax : Int = 4

///|
pub let portal_ay : Int = 10

///|
pub let portal_bx : Int = 18

///|
pub let portal_by : Int = 3

///|
pub let player_move_t : Float = 0.105

///|
pub let drone_move_t : Float = 0.150

///|
pub let flare_ttl : Float = 4.2

///|
pub let flare_cost : Float = 34.0

///|
pub let flare_stun_t : Float = 2.3

///|
pub let score_core : Int = 180

///|
pub let score_teleport : Int = 90

///|
pub let score_stun : Int = 60

///|
pub let score_win : Int = 1100
