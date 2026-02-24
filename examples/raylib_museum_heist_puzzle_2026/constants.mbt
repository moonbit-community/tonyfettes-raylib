///|
let screen_w : Int = 1280

///|
let screen_h : Int = 800

///|
let target_fps : Int = 60

///|
let board_cols : Int = 20

///|
let board_rows : Int = 14

///|
let board_cells : Int = board_cols * board_rows

///|
let tile_size : Int = 44

///|
let board_origin_x : Int = 36

///|
let board_origin_y : Int = 96

///|
let panel_x : Int = board_origin_x + board_cols * tile_size + 22

///|
let panel_y : Int = 22

///|
let panel_w : Int = screen_w - panel_x - 22

///|
let panel_h : Int = screen_h - 44

///|
let tile_floor : Int = 0

///|
let tile_wall : Int = 1

///|
let state_title : Int = 0

///|
let state_play : Int = 1

///|
let state_win : Int = 2

///|
let state_lose : Int = 3

///|
let state_campaign_clear : Int = 4

///|
let dir_none : Int = 0

///|
let dir_left : Int = 1

///|
let dir_right : Int = 2

///|
let dir_up : Int = 3

///|
let dir_down : Int = 4

///|
let player_step_interval : Float = 0.14

///|
let guard_step_interval : Float = 0.33

///|
let menu_action_delay : Float = 0.16

///|
let alarm_flash_time : Float = 0.45
