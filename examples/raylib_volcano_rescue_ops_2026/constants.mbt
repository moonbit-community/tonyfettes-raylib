///|
let screen_w : Int = 1680

///|
let screen_h : Int = 960

///|
let target_fps : Int = 120

///|
let grid_w : Int = 15

///|
let grid_h : Int = 10

///|
let max_cells : Int = grid_w * grid_h

///|
let max_sites : Int = 12

///|
let max_route_steps : Int = 96

///|
let level_count : Int = 3

///|
let state_title : Int = 0

///|
let state_play : Int = 1

///|
let state_result : Int = 2

///|
let result_none : Int = 0

///|
let result_win : Int = 1

///|
let result_lose : Int = 2

///|
let tile_ground : Int = 0

///|
let tile_rock : Int = 1

///|
let tile_depot : Int = 2

///|
let tile_shelter : Int = 3

///|
let dir_none : Int = 0

///|
let dir_up : Int = 1

///|
let dir_down : Int = 2

///|
let dir_left : Int = 3

///|
let dir_right : Int = 4

///|
let map_x : Int = 44

///|
let map_y : Int = 124

///|
let tile_size : Int = 56

///|
let panel_x : Int = map_x + grid_w * tile_size + 32

///|
let panel_w : Int = screen_w - panel_x - 24

///|
let vehicle_capacity : Int = 6

///|
let max_heat : Float = 100.0

///|
let max_fuel : Float = 100.0

///|
let max_coolant : Float = 100.0

///|
let move_fuel_cost : Float = 6.0

///|
let move_heat_gain : Float = 4.8

///|
let step_interval : Float = 0.22
