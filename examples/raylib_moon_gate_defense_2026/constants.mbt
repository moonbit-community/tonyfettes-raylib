///|
let screen_w : Int = 1420

///|
let screen_h : Int = 900

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
let dir_up : Int = 0

///|
let dir_right : Int = 1

///|
let dir_down : Int = 2

///|
let dir_left : Int = 3

///|
let grid_cols : Int = 11

///|
let grid_rows : Int = 7

///|
let cell_size : Int = 82

///|
let board_w : Int = grid_cols * cell_size

///|
let board_h : Int = grid_rows * cell_size

///|
let board_x : Int = (screen_w - board_w) / 2

///|
let board_y : Int = 168

///|
let gate_gx : Int = grid_cols / 2

///|
let gate_gy : Int = grid_rows / 2

///|
let gate_radius : Float = 44.0

///|
let gate_hit_radius : Float = 30.0

///|
let gate_hp_max : Float = 260.0

///|
let max_nodes : Int = grid_cols * grid_rows

///|
let max_enemies : Int = 200

///|
let max_bolts : Int = 300

///|
let max_pulses : Int = 320

///|
let node_max_level : Int = 3

///|
let node_build_cost : Float = 36.0

///|
let node_upgrade_cost_l2 : Float = 52.0

///|
let node_upgrade_cost_l3 : Float = 76.0

///|
let node_sell_ratio : Float = 0.65

///|
let node_range_l1 : Float = 168.0

///|
let node_range_l2 : Float = 218.0

///|
let node_range_l3 : Float = 270.0

///|
let node_damage_l1 : Float = 17.0

///|
let node_damage_l2 : Float = 28.0

///|
let node_damage_l3 : Float = 42.0

///|
let node_fire_cd_l1 : Float = 0.58

///|
let node_fire_cd_l2 : Float = 0.40

///|
let node_fire_cd_l3 : Float = 0.27

///|
let node_projectile_speed : Float = 620.0

///|
let node_cone_dot_sq : Float = 0.22

///|
let bolt_life : Float = 1.2

///|
let bolt_hit_radius : Float = 8.0

///|
let energy_start : Float = 120.0

///|
let energy_max : Float = 320.0

///|
let energy_regen : Float = 13.5

///|
let wave_energy_bonus : Float = 12.0

///|
let wave_intro_delay : Float = 0.8

///|
let wave_spawn_count_base : Int = 7

///|
let wave_spawn_count_step : Int = 3

///|
let spawn_cd_base : Float = 0.95

///|
let spawn_cd_min : Float = 0.20

///|
let enemy_kind_skitter : Int = 0

///|
let enemy_kind_carapace : Int = 1

///|
let enemy_kind_wraith : Int = 2

///|
let enemy_base_hp : Float = 28.0

///|
let enemy_hp_per_wave : Float = 5.2

///|
let enemy_base_speed : Float = 62.0

///|
let enemy_speed_per_wave : Float = 5.0

///|
let enemy_contact_damage_base : Float = 12.0

///|
let enemy_contact_damage_wave : Float = 1.5

///|
let combo_window : Float = 2.5

///|
let combo_score_step : Int = 4

///|
let barrier_charge_goal : Float = 100.0

///|
let barrier_charge_kill : Float = 11.0

///|
let barrier_charge_combo : Float = 1.8

///|
let barrier_charge_combo_cap : Int = 12

///|
let barrier_radius : Float = 235.0

///|
let barrier_damage : Float = 95.0

///|
let barrier_push : Float = 72.0

///|
let barrier_flash_time : Float = 0.56

///|
let shake_time_hit : Float = 0.22

///|
fn mini(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
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
fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

///|
fn sinf(v : Float) -> Float {
  Float::from_double(@math.sin(v.to_double()))
}

///|
fn cosf(v : Float) -> Float {
  Float::from_double(@math.cos(v.to_double()))
}

///|
fn sqrtf(v : Float) -> Float {
  v.sqrt()
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

///|
fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx = x1 - x0
  let dy = y1 - y0
  dx * dx + dy * dy
}

///|
fn board_left() -> Float {
  Float::from_int(board_x)
}

///|
fn board_top() -> Float {
  Float::from_int(board_y)
}

///|
fn board_right() -> Float {
  Float::from_int(board_x + board_w)
}

///|
fn board_bottom() -> Float {
  Float::from_int(board_y + board_h)
}

///|
fn cell_center_x(gx : Int) -> Float {
  Float::from_int(board_x + gx * cell_size + cell_size / 2)
}

///|
fn cell_center_y(gy : Int) -> Float {
  Float::from_int(board_y + gy * cell_size + cell_size / 2)
}

///|
fn gate_x() -> Float {
  cell_center_x(gate_gx)
}

///|
fn gate_y() -> Float {
  cell_center_y(gate_gy)
}

///|
fn is_inside_grid(gx : Int, gy : Int) -> Bool {
  gx >= 0 && gx < grid_cols && gy >= 0 && gy < grid_rows
}

///|
fn is_gate_cell(gx : Int, gy : Int) -> Bool {
  gx == gate_gx && gy == gate_gy
}

///|
fn node_upgrade_cost(next_level : Int) -> Float {
  if next_level <= 1 {
    node_build_cost
  } else if next_level == 2 {
    node_upgrade_cost_l2
  } else {
    node_upgrade_cost_l3
  }
}

///|
fn node_total_cost(level : Int) -> Float {
  if level <= 0 {
    0.0
  } else if level == 1 {
    node_build_cost
  } else if level == 2 {
    node_build_cost + node_upgrade_cost_l2
  } else {
    node_build_cost + node_upgrade_cost_l2 + node_upgrade_cost_l3
  }
}

///|
fn node_sell_refund(level : Int) -> Float {
  node_total_cost(level) * node_sell_ratio
}

///|
fn node_range(level : Int) -> Float {
  if level <= 1 {
    node_range_l1
  } else if level == 2 {
    node_range_l2
  } else {
    node_range_l3
  }
}

///|
fn node_damage(level : Int) -> Float {
  if level <= 1 {
    node_damage_l1
  } else if level == 2 {
    node_damage_l2
  } else {
    node_damage_l3
  }
}

///|
fn node_fire_cd(level : Int) -> Float {
  if level <= 1 {
    node_fire_cd_l1
  } else if level == 2 {
    node_fire_cd_l2
  } else {
    node_fire_cd_l3
  }
}

///|
fn wave_spawn_count(wave : Int) -> Int {
  let w = maxf(Float::from_int(wave), 1.0).to_int()
  wave_spawn_count_base + (w - 1) * wave_spawn_count_step + (w - 1) / 2
}

///|
fn wave_spawn_cd(wave : Int) -> Float {
  let reduction = Float::from_int(maxf(Float::from_int(wave - 1), 0.0).to_int()) *
    0.06
  clampf(spawn_cd_base - reduction, spawn_cd_min, spawn_cd_base)
}

///|
fn dir_vec_x(dir : Int) -> Float {
  if dir == dir_right {
    1.0
  } else if dir == dir_left {
    -1.0
  } else {
    0.0
  }
}

///|
fn dir_vec_y(dir : Int) -> Float {
  if dir == dir_down {
    1.0
  } else if dir == dir_up {
    -1.0
  } else {
    0.0
  }
}

///|
fn col_bg_top() -> @raylib.Color {
  @raylib.Color::new(12, 16, 34, 255)
}

///|
fn col_bg_bottom() -> @raylib.Color {
  @raylib.Color::new(10, 28, 52, 255)
}

///|
fn col_grid() -> @raylib.Color {
  @raylib.Color::new(74, 128, 160, 180)
}

///|
fn col_gate() -> @raylib.Color {
  @raylib.Color::new(92, 224, 244, 255)
}

///|
fn col_energy() -> @raylib.Color {
  @raylib.Color::new(120, 236, 166, 255)
}

///|
fn col_barrier() -> @raylib.Color {
  @raylib.Color::new(172, 154, 255, 255)
}

///|
fn col_enemy(kind : Int) -> @raylib.Color {
  if kind == enemy_kind_carapace {
    @raylib.Color::new(248, 134, 104, 255)
  } else if kind == enemy_kind_wraith {
    @raylib.Color::new(166, 122, 252, 255)
  } else {
    @raylib.Color::new(250, 206, 116, 255)
  }
}

///|
fn col_node(level : Int) -> @raylib.Color {
  if level == 1 {
    @raylib.Color::new(112, 192, 246, 255)
  } else if level == 2 {
    @raylib.Color::new(92, 232, 204, 255)
  } else {
    @raylib.Color::new(252, 218, 104, 255)
  }
}
