///|
pub let screen_w : Int = 1680

///|
pub let screen_h : Int = 960

///|
pub let target_fps : Int = 120

///|
pub let grid_w : Int = 15

///|
pub let grid_h : Int = 10

///|
pub let max_cells : Int = grid_w * grid_h

///|
pub let max_sites : Int = 12

///|
pub let max_route_steps : Int = 96

///|
pub let level_count : Int = 3

///|
pub let state_title : Int = 0

///|
pub let state_play : Int = 1

///|
pub let state_result : Int = 2

///|
pub let result_none : Int = 0

///|
pub let result_win : Int = 1

///|
pub let result_lose : Int = 2

///|
pub let tile_ground : Int = 0

///|
pub let tile_rock : Int = 1

///|
pub let tile_depot : Int = 2

///|
pub let tile_shelter : Int = 3

///|
pub let dir_none : Int = 0

///|
pub let dir_up : Int = 1

///|
pub let dir_down : Int = 2

///|
pub let dir_left : Int = 3

///|
pub let dir_right : Int = 4

///|
pub let map_x : Int = 44

///|
pub let map_y : Int = 124

///|
pub let tile_size : Int = 56

///|
pub let panel_x : Int = map_x + grid_w * tile_size + 32

///|
pub let panel_w : Int = screen_w - panel_x - 24

///|
pub let vehicle_capacity : Int = 6

///|
pub let max_heat : Float = 100.0

///|
pub let max_fuel : Float = 100.0

///|
pub let max_coolant : Float = 100.0

///|
pub let move_fuel_cost : Float = 6.0

///|
pub let move_heat_gain : Float = 4.8

///|
pub let step_interval : Float = 0.22
