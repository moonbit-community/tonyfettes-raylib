///|
pub let screen_w : Int = 1440

///|
pub let screen_h : Int = 860

///|
pub let target_fps : Int = 120

///|
pub let state_title : Int = 0

///|
pub let state_playing : Int = 1

///|
pub let state_paused : Int = 2

///|
pub let state_game_over : Int = 3

///|
pub let play_x : Int = 36

///|
pub let play_y : Int = 70

///|
pub let play_w : Int = 1046

///|
pub let play_h : Int = 752

///|
pub let hud_x : Int = play_x + play_w + 18

///|
pub let hud_y : Int = play_y

///|
pub let hud_w : Int = screen_w - hud_x - play_x

///|
pub let hud_h : Int = play_h

///|
pub let play_left : Float = Float::from_int(play_x + 12)

///|
pub let play_top : Float = Float::from_int(play_y + 12)

///|
pub let play_right : Float = Float::from_int(play_x + play_w - 12)

///|
pub let play_bottom : Float = Float::from_int(play_y + play_h - 12)

///|
pub let shrine_count : Int = 4

///|
pub let max_lanterns : Int = 20

///|
pub let max_gusts : Int = 24

///|
pub let max_sparks : Int = 180

///|
pub let max_thieves : Int = 18

///|
pub let patrol_radius : Float = 18.0

///|
pub let patrol_accel : Float = 980.0

///|
pub let patrol_drag : Float = 4.2

///|
pub let patrol_max_speed : Float = 322.0

///|
pub let guard_time : Float = 1.20

///|
pub let guard_radius : Float = 112.0

///|
pub let guard_push : Float = 320.0

///|
pub let calm_duration : Float = 1.80

///|
pub let calm_radius : Float = 128.0

///|
pub let calm_cooldown : Float = 6.20

///|
pub let lantern_radius : Float = 12.0

///|
pub let lantern_base_drain : Float = 3.8

///|
pub let lantern_drag : Float = 1.8

///|
pub let lantern_escort_regen : Float = 8.2

///|
pub let escort_pickup_range : Float = 78.0

///|
pub let escort_pull : Float = 6.2

///|
pub let delivery_radius : Float = 34.0

///|
pub let combo_window : Float = 4.2

///|
pub let combo_bonus_step : Int = 42

///|
pub let delivery_score_base : Int = 128

///|
pub let score_per_flame : Int = 2

///|
pub let extinguish_limit : Int = 7

///|
pub let interact_stabilize_boost : Float = 6.0

///|
pub let lantern_spawn_interval : Float = 2.20

///|
pub let lantern_spawn_floor : Float = 0.86

///|
pub let gust_spawn_interval : Float = 1.40

///|
pub let gust_spawn_floor : Float = 0.44

///|
pub let spark_spawn_interval : Float = 0.18

///|
pub let spark_spawn_floor : Float = 0.07

///|
pub let thief_spawn_interval : Float = 7.20

///|
pub let thief_spawn_floor : Float = 2.50

///|
pub let gust_drain_power : Float = 16.0

///|
pub let spark_drain_power : Float = 26.0

///|
pub let thief_drain_burst : Float = 32.0

///|
pub let thief_speed : Float = 136.0

///|
pub let thief_radius : Float = 14.0

///|
pub let thief_contact_radius : Float = thief_radius + lantern_radius + 4.0

///|
pub let thief_steal_period : Float = 0.65

///|
pub let status_default_t : Float = 1.30

///|
pub fn gate_position() -> (Float, Float) {
  (Float::from_int(play_x + 110), Float::from_int(play_y + play_h / 2))
}

///|
pub fn shrine_position(index : Int) -> (Float, Float) {
  match clampi(index, 0, shrine_count - 1) {
    0 => (Float::from_int(play_x + play_w - 140), Float::from_int(play_y + 126))
    1 =>
      (
        Float::from_int(play_x + play_w - 168),
        Float::from_int(play_y + play_h / 2),
      )
    2 =>
      (
        Float::from_int(play_x + play_w - 140),
        Float::from_int(play_y + play_h - 126),
      )
    _ =>
      (
        Float::from_int(play_x + play_w / 2 + 106),
        Float::from_int(play_y + 104),
      )
  }
}
