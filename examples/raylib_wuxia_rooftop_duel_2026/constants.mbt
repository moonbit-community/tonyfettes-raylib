///|
let screen_w : Int = 1520

///|
let screen_h : Int = 920

///|
let target_fps : Int = 120

///|
let state_title : Int = 0

///|
let state_playing : Int = 1

///|
let state_paused : Int = 2

///|
let state_game_over : Int = 3

///|
let enemy_state_seek : Int = 0

///|
let enemy_state_telegraph : Int = 1

///|
let enemy_state_strike : Int = 2

///|
let enemy_state_recover : Int = 3

///|
let enemy_state_stunned : Int = 4

///|
let attack_none : Int = 0

///|
let attack_light : Int = 1

///|
let attack_heavy : Int = 2

///|
let max_enemy_slots : Int = 84

///|
let arena_x : Int = 120

///|
let arena_y : Int = 90

///|
let arena_w : Int = 1280

///|
let arena_h : Int = 760

///|
fn arena_left() -> Float {
  Float::from_int(arena_x)
}

///|
fn arena_right() -> Float {
  Float::from_int(arena_x + arena_w)
}

///|
fn arena_top() -> Float {
  Float::from_int(arena_y)
}

///|
fn arena_bottom() -> Float {
  Float::from_int(arena_y + arena_h)
}

///|
fn arena_center_x() -> Float {
  Float::from_int(arena_x + arena_w / 2)
}

///|
fn arena_center_y() -> Float {
  Float::from_int(arena_y + arena_h / 2)
}

///|
let player_radius : Float = 22.0

///|
let player_max_health : Float = 100.0

///|
let player_max_stamina : Float = 100.0

///|
let player_move_accel : Float = 1700.0

///|
let player_friction : Float = 6.3

///|
let player_hit_invuln : Float = 0.56

///|
let light_attack_cost : Float = 14.0

///|
let light_attack_damage : Float = 34.0

///|
let light_attack_range : Float = 118.0

///|
let light_attack_arc_dot : Float = 0.10

///|
let light_attack_cooldown : Float = 0.20

///|
let light_attack_anim_t : Float = 0.16

///|
let heavy_attack_cost : Float = 30.0

///|
let heavy_attack_damage : Float = 58.0

///|
let heavy_attack_range : Float = 170.0

///|
let heavy_attack_arc_dot : Float = -0.22

///|
let heavy_attack_cooldown : Float = 0.44

///|
let heavy_attack_anim_t : Float = 0.30

///|
let parry_dash_cost : Float = 22.0

///|
let parry_active_t : Float = 0.24

///|
let dash_t : Float = 0.16

///|
let dash_speed : Float = 900.0

///|
let parry_counter_damage : Float = 46.0

///|
let parry_range : Float = 102.0

///|
let stamina_regen_fast : Float = 27.0

///|
let stamina_regen_slow : Float = 14.0

///|
let combo_timeout : Float = 2.3

///|
let enemy_telegraph_min : Float = 0.64

///|
let enemy_telegraph_max : Float = 1.18

///|
let enemy_parry_window : Float = 0.24

///|
let enemy_strike_t : Float = 0.22

///|
let enemy_recover_t : Float = 0.48

///|
let enemy_stunned_t : Float = 0.95

///|
let enemy_contact_damage : Float = 16.0

///|
let wave_gap_duration : Float = 1.25

///|
let spawn_interval_base : Float = 0.96

///|
let spawn_interval_min : Float = 0.30
