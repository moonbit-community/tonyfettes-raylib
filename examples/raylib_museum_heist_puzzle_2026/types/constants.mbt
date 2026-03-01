///|
pub let screen_w : Int = 1280

///|
pub let screen_h : Int = 800

///|
pub let target_fps : Int = 60

///|
pub let board_cols : Int = 20

///|
pub let board_rows : Int = 14

///|
pub let board_cells : Int = board_cols * board_rows

///|
pub let tile_size : Int = 44

///|
pub let board_origin_x : Int = 36

///|
pub let board_origin_y : Int = 96

///|
pub let panel_x : Int = board_origin_x + board_cols * tile_size + 22

///|
pub let panel_y : Int = 22

///|
pub let panel_w : Int = screen_w - panel_x - 22

///|
pub let panel_h : Int = screen_h - 44

///|
pub let tile_floor : Int = 0

///|
pub let tile_wall : Int = 1

///|
pub let state_title : Int = 0

///|
pub let state_play : Int = 1

///|
pub let state_win : Int = 2

///|
pub let state_lose : Int = 3

///|
pub let state_campaign_clear : Int = 4

///|
pub let dir_none : Int = 0

///|
pub let dir_left : Int = 1

///|
pub let dir_right : Int = 2

///|
pub let dir_up : Int = 3

///|
pub let dir_down : Int = 4

///|
pub let player_step_interval : Float = 0.14

///|
pub let guard_step_interval : Float = 0.33

///|
pub let menu_action_delay : Float = 0.16

///|
pub let alarm_flash_time : Float = 0.45
