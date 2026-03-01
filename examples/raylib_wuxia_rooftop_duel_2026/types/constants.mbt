///|
pub let screen_w : Int = 1520

///|
pub let screen_h : Int = 920

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
pub let enemy_state_seek : Int = 0

///|
pub let enemy_state_telegraph : Int = 1

///|
pub let enemy_state_strike : Int = 2

///|
pub let enemy_state_recover : Int = 3

///|
pub let enemy_state_stunned : Int = 4

///|
pub let attack_none : Int = 0

///|
pub let attack_light : Int = 1

///|
pub let attack_heavy : Int = 2

///|
pub let max_enemy_slots : Int = 84

///|
pub let arena_x : Int = 120

///|
pub let arena_y : Int = 90

///|
pub let arena_w : Int = 1280

///|
pub let arena_h : Int = 760

///|
pub fn arena_left() -> Float {
  Float::from_int(arena_x)
}

///|
pub fn arena_right() -> Float {
  Float::from_int(arena_x + arena_w)
}

///|
pub fn arena_top() -> Float {
  Float::from_int(arena_y)
}

///|
pub fn arena_bottom() -> Float {
  Float::from_int(arena_y + arena_h)
}

///|
pub fn arena_center_x() -> Float {
  Float::from_int(arena_x + arena_w / 2)
}

///|
pub fn arena_center_y() -> Float {
  Float::from_int(arena_y + arena_h / 2)
}

///|
pub let player_radius : Float = 22.0

///|
pub let player_max_health : Float = 100.0

///|
pub let player_max_stamina : Float = 100.0

///|
pub let player_move_accel : Float = 1700.0

///|
pub let player_friction : Float = 6.3

///|
pub let player_hit_invuln : Float = 0.56

///|
pub let light_attack_cost : Float = 14.0

///|
pub let light_attack_damage : Float = 34.0

///|
pub let light_attack_range : Float = 118.0

///|
pub let light_attack_arc_dot : Float = 0.10

///|
pub let light_attack_cooldown : Float = 0.20

///|
pub let light_attack_anim_t : Float = 0.16

///|
pub let heavy_attack_cost : Float = 30.0

///|
pub let heavy_attack_damage : Float = 58.0

///|
pub let heavy_attack_range : Float = 170.0

///|
pub let heavy_attack_arc_dot : Float = -0.22

///|
pub let heavy_attack_cooldown : Float = 0.44

///|
pub let heavy_attack_anim_t : Float = 0.30

///|
pub let parry_dash_cost : Float = 22.0

///|
pub let parry_active_t : Float = 0.24

///|
pub let dash_t : Float = 0.16

///|
pub let dash_speed : Float = 900.0

///|
pub let parry_counter_damage : Float = 46.0

///|
pub let parry_range : Float = 102.0

///|
pub let stamina_regen_fast : Float = 27.0

///|
pub let stamina_regen_slow : Float = 14.0

///|
pub let combo_timeout : Float = 2.3

///|
pub let enemy_telegraph_min : Float = 0.64

///|
pub let enemy_telegraph_max : Float = 1.18

///|
pub let enemy_parry_window : Float = 0.24

///|
pub let enemy_strike_t : Float = 0.22

///|
pub let enemy_recover_t : Float = 0.48

///|
pub let enemy_stunned_t : Float = 0.95

///|
pub let enemy_contact_damage : Float = 16.0

///|
pub let wave_gap_duration : Float = 1.25

///|
pub let spawn_interval_base : Float = 0.96

///|
pub let spawn_interval_min : Float = 0.30
