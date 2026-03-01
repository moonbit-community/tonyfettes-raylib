///|
pub fn mini(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

///|
pub fn clampi(v : Int, lo : Int, hi : Int) -> Int {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
pub fn clampf(v : Float, lo : Float, hi : Float) -> Float {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
pub fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub fn sinf(v : Float) -> Float {
  Float::from_double(@math.sin(v.to_double()))
}

///|
pub fn cosf(v : Float) -> Float {
  Float::from_double(@math.cos(v.to_double()))
}

///|
pub fn sqrtf(v : Float) -> Float {
  v.sqrt()
}

///|
pub fn randf(lo : Float, hi : Float) -> Float {
  let r = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
pub fn randi(lo : Int, hi : Int) -> Int {
  @raylib.get_random_value(lo, hi)
}

///|
pub fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx = x1 - x0
  let dy = y1 - y0
  dx * dx + dy * dy
}

///|
pub fn board_left() -> Float {
  Float::from_int(board_x)
}

///|
pub fn board_top() -> Float {
  Float::from_int(board_y)
}

///|
pub fn board_right() -> Float {
  Float::from_int(board_x + board_w)
}

///|
pub fn board_bottom() -> Float {
  Float::from_int(board_y + board_h)
}

///|
pub fn cell_center_x(gx : Int) -> Float {
  Float::from_int(board_x + gx * cell_size + cell_size / 2)
}

///|
pub fn cell_center_y(gy : Int) -> Float {
  Float::from_int(board_y + gy * cell_size + cell_size / 2)
}

///|
pub fn gate_x() -> Float {
  cell_center_x(gate_gx)
}

///|
pub fn gate_y() -> Float {
  cell_center_y(gate_gy)
}

///|
pub fn is_gate_cell(gx : Int, gy : Int) -> Bool {
  gx == gate_gx && gy == gate_gy
}

///|
pub fn node_upgrade_cost(next_level : Int) -> Float {
  if next_level <= 1 {
    node_build_cost
  } else if next_level == 2 {
    node_upgrade_cost_l2
  } else {
    node_upgrade_cost_l3
  }
}

///|
pub fn node_total_cost(level : Int) -> Float {
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
pub fn node_sell_refund(level : Int) -> Float {
  node_total_cost(level) * node_sell_ratio
}

///|
pub fn node_range(level : Int) -> Float {
  if level <= 1 {
    node_range_l1
  } else if level == 2 {
    node_range_l2
  } else {
    node_range_l3
  }
}

///|
pub fn node_damage(level : Int) -> Float {
  if level <= 1 {
    node_damage_l1
  } else if level == 2 {
    node_damage_l2
  } else {
    node_damage_l3
  }
}

///|
pub fn node_fire_cd(level : Int) -> Float {
  if level <= 1 {
    node_fire_cd_l1
  } else if level == 2 {
    node_fire_cd_l2
  } else {
    node_fire_cd_l3
  }
}

///|
pub fn wave_spawn_count(wave : Int) -> Int {
  let w = maxf(Float::from_int(wave), 1.0).to_int()
  wave_spawn_count_base + (w - 1) * wave_spawn_count_step + (w - 1) / 2
}

///|
pub fn wave_spawn_cd(wave : Int) -> Float {
  let reduction = Float::from_int(maxf(Float::from_int(wave - 1), 0.0).to_int()) *
    0.06
  clampf(spawn_cd_base - reduction, spawn_cd_min, spawn_cd_base)
}

///|
pub fn dir_vec_x(dir : Int) -> Float {
  if dir == dir_right {
    1.0
  } else if dir == dir_left {
    -1.0
  } else {
    0.0
  }
}

///|
pub fn dir_vec_y(dir : Int) -> Float {
  if dir == dir_down {
    1.0
  } else if dir == dir_up {
    -1.0
  } else {
    0.0
  }
}

///|
pub fn col_bg_top() -> @raylib.Color {
  @raylib.Color::new(12, 16, 34, 255)
}

///|
pub fn col_bg_bottom() -> @raylib.Color {
  @raylib.Color::new(10, 28, 52, 255)
}

///|
pub fn col_grid() -> @raylib.Color {
  @raylib.Color::new(74, 128, 160, 180)
}

///|
pub fn col_gate() -> @raylib.Color {
  @raylib.Color::new(92, 224, 244, 255)
}

///|
pub fn col_energy() -> @raylib.Color {
  @raylib.Color::new(120, 236, 166, 255)
}

///|
pub fn col_barrier() -> @raylib.Color {
  @raylib.Color::new(172, 154, 255, 255)
}

///|
pub fn col_enemy(kind : Int) -> @raylib.Color {
  if kind == enemy_kind_carapace {
    @raylib.Color::new(248, 134, 104, 255)
  } else if kind == enemy_kind_wraith {
    @raylib.Color::new(166, 122, 252, 255)
  } else {
    @raylib.Color::new(250, 206, 116, 255)
  }
}

///|
pub fn col_node(level : Int) -> @raylib.Color {
  if level == 1 {
    @raylib.Color::new(112, 192, 246, 255)
  } else if level == 2 {
    @raylib.Color::new(92, 232, 204, 255)
  } else {
    @raylib.Color::new(252, 218, 104, 255)
  }
}
