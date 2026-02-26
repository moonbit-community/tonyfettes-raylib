///|
let screen_w : Int = 1366

///|
let screen_h : Int = 768

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
let chamber_count : Int = 3

///|
let vault_room : Int = 1

///|
let chamber_left : Float = 184.0

///|
let chamber_top : Float = 132.0

///|
let chamber_w : Float = 998.0

///|
let chamber_h : Float = 554.0

///|
fn chamber_right() -> Float {
  chamber_left + chamber_w
}

///|
fn chamber_bottom() -> Float {
  chamber_top + chamber_h
}

///|
let door_center_y : Float = chamber_top + chamber_h * 0.56

///|
let door_half_h : Float = 78.0

///|
let keeper_radius : Float = 18.0

///|
let keeper_speed : Float = 270.0

///|
let keeper_mode_speed_scale : Float = 0.76

///|
let keeper_action_cd : Float = 0.20

///|
let keeper_stamina_max : Float = 100.0

///|
let keeper_stamina_regen : Float = 24.0

///|
let keeper_stamina_regen_mode : Float = 12.0

///|
let stamina_attack_cost : Float = 13.0

///|
let stamina_seal_cost : Float = 20.0

///|
let stamina_extinguish_cost : Float = 16.0

///|
let attack_range : Float = 82.0

///|
let attack_damage : Float = 50.0

///|
let attack_damage_wave_bonus : Float = 1.6

///|
let extinguisher_range : Float = 118.0

///|
let extinguisher_power : Float = 62.0

///|
let ink_shield_stock_start : Float = 2.0

///|
let ink_shield_stock_max : Float = 3.0

///|
let ink_shield_cooldown : Float = 7.5

///|
let ink_shield_duration : Float = 2.2

///|
let ink_shield_radius : Float = 176.0

///|
let ink_shield_damage : Float = 82.0

///|
let ink_shield_fire_quench : Float = 72.0

///|
let ink_shield_integrity_block : Float = 0.55

///|
let scroll_integrity_max : Float = 100.0

///|
let seal_charges_start : Int = 4

///|
let seal_charges_wave_gain : Int = 1

///|
let seal_charges_max : Int = 7

///|
let breach_severity_max : Float = 100.0

///|
let breach_event_cd_base : Float = 4.1

///|
let breach_event_cd_floor : Float = 1.2

///|
let breach_wave_growth : Float = 0.24

///|
let breach_integrity_drain : Float = 5.4

///|
let breach_seal_power : Float = 42.0

///|
let breach_seal_wave_bonus : Float = 2.2

///|
let raider_radius : Float = 14.0

///|
let raider_hp_base : Float = 82.0

///|
let raider_hp_wave_bonus : Float = 8.4

///|
let raider_speed_base : Float = 78.0

///|
let raider_speed_wave_bonus : Float = 5.6

///|
let raider_spawn_cd_base : Float = 2.2

///|
let raider_spawn_cd_floor : Float = 0.68

///|
let raider_vault_strike : Float = 6.5

///|
let raider_keeper_stamina_hit : Float = 10.5

///|
let flame_spawn_cd_base : Float = 2.8

///|
let flame_spawn_cd_floor : Float = 0.9

///|
let flame_spread_cd_base : Float = 3.2

///|
let flame_spread_cd_floor : Float = 1.0

///|
let flame_decay : Float = 1.2

///|
let flame_breach_feed : Float = 0.11

///|
let flame_integrity_side_mul : Float = 0.030

///|
let flame_integrity_vault_mul : Float = 0.064

///|
let wave_duration_base : Float = 28.0

///|
let wave_duration_step : Float = 3.8

///|
let max_raiders : Int = 160

///|
let max_flames : Int = 220

///|
fn chamber_center_x() -> Float {
  chamber_left + chamber_w * 0.5
}

///|
fn chamber_center_y() -> Float {
  chamber_top + chamber_h * 0.5
}

///|
fn room_name(room : Int) -> String {
  if room == 0 {
    "Ember Archive"
  } else if room == 1 {
    "Vault Core"
  } else {
    "Seal Scriptorium"
  }
}

///|
fn breach_anchor_x(room : Int) -> Float {
  if room == 0 {
    chamber_left + chamber_w * 0.82
  } else if room == 1 {
    chamber_left + chamber_w * 0.18
  } else {
    chamber_left + chamber_w * 0.58
  }
}

///|
fn breach_anchor_y(room : Int) -> Float {
  if room == 0 {
    chamber_top + chamber_h * 0.24
  } else if room == 1 {
    chamber_top + chamber_h * 0.78
  } else {
    chamber_top + chamber_h * 0.32
  }
}

///|
fn vault_core_x() -> Float {
  chamber_left + chamber_w * 0.50
}

///|
fn vault_core_y() -> Float {
  chamber_top + chamber_h * 0.52
}

///|
fn raider_goal_x(room : Int) -> Float {
  if room < vault_room {
    chamber_right() - 18.0
  } else if room > vault_room {
    chamber_left + 18.0
  } else {
    vault_core_x()
  }
}

///|
fn raider_goal_y(room : Int) -> Float {
  if room == vault_room {
    vault_core_y()
  } else {
    door_center_y
  }
}

///|
fn wave_duration(wave : Int) -> Float {
  wave_duration_base + Float::from_int(wave - 1) * wave_duration_step
}

///|
fn clampi(v : Int, lo : Int, hi : Int) -> Int {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
fn clampf(v : Float, lo : Float, hi : Float) -> Float {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
fn clamp01(v : Float) -> Float {
  clampf(v, 0.0, 1.0)
}

///|
fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx = x1 - x0
  let dy = y1 - y0
  dx * dx + dy * dy
}

///|
fn sqrtf(v : Float) -> Float {
  if v <= 0.0 {
    0.0
  } else {
    v.sqrt()
  }
}

///|
fn randf(lo : Float, hi : Float) -> Float {
  let r = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
fn randi(lo : Int, hi : Int) -> Int {
  @raylib.get_random_value(lo, hi)
}
