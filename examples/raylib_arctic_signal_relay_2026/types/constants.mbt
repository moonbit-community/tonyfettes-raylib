///|
pub let screen_w : Int = 1440

///|
pub let screen_h : Int = 900

///|
pub let target_fps : Int = 120

///|
pub let state_title : Int = 0

///|
pub let state_play : Int = 1

///|
pub let state_result : Int = 2

///|
pub let world_x0 : Int = 24

///|
pub let world_y0 : Int = 24

///|
pub let world_w : Int = 980

///|
pub let world_h : Int = 852

///|
pub let panel_x0 : Int = world_x0 + world_w + 20

///|
pub let panel_w : Int = screen_w - panel_x0 - 24

///|
pub let max_towers : Int = 6

///|
pub let max_storms : Int = 5

///|
pub let rover_r : Float = 22.0

///|
pub let rover_accel : Float = 760.0

///|
pub let rover_drag : Float = 5.0

///|
pub let rover_max_speed : Float = 280.0

///|
pub let rover_wind_force : Float = 180.0

///|
pub let storm_control_penalty : Float = 0.45

///|
pub let cargo_capacity : Int = 3

///|
pub let energy_max : Float = 100.0

///|
pub let heat_max : Float = 100.0

///|
pub let energy_idle_drain : Float = 1.6

///|
pub let energy_move_drain : Float = 0.008

///|
pub let energy_storm_drain : Float = 7.4

///|
pub let energy_recharge_rate : Float = 29.0

///|
pub let heat_idle_drain : Float = 2.0

///|
pub let heat_storm_drain : Float = 10.8

///|
pub let heat_recharge_rate : Float = 34.0

///|
pub let timer_base : Float = 92.0

///|
pub let timer_floor : Float = 48.0

///|
pub let timer_step : Float = 5.0

///|
pub let tower_online_bonus_base : Float = 3.0

///|
pub let tower_online_bonus_step : Float = 0.9
