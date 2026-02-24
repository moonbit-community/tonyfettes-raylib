///|
fn mini(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

///|
fn maxi(a : Int, b : Int) -> Int {
  if a > b {
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
fn cell_index(x : Int, y : Int) -> Int {
  y * grid_w + x
}

///|
fn in_bounds(x : Int, y : Int) -> Bool {
  x >= 0 && x < grid_w && y >= 0 && y < grid_h
}

///|
fn tile_at(game : Game, x : Int, y : Int) -> Int {
  if in_bounds(x, y) {
    game.terrain[cell_index(x, y)]
  } else {
    tile_rock
  }
}

///|
fn set_tile(game : Game, x : Int, y : Int, t : Int) -> Unit {
  if in_bounds(x, y) {
    game.terrain[cell_index(x, y)] = t
  }
}

///|
fn lava_at(game : Game, x : Int, y : Int) -> Bool {
  if in_bounds(x, y) {
    game.lava[cell_index(x, y)]
  } else {
    false
  }
}

///|
fn set_lava(game : Game, x : Int, y : Int, v : Bool) -> Unit {
  if in_bounds(x, y) {
    game.lava[cell_index(x, y)] = v
  }
}

///|
fn set_message(game : Game, msg : String, ttl : Float) -> Unit {
  game.msg = msg
  game.msg_t = ttl
}

///|
fn clear_route(game : Game) -> Unit {
  game.route_len = 0
  game.route_running = false
  game.step_timer = 0.0
  for i = 0; i < game.route.length(); i = i + 1 {
    game.route[i] = dir_none
  }
}

///|
fn push_route_step(game : Game, dir : Int) -> Bool {
  if game.route_len >= max_route_steps {
    return false
  }

  game.route[game.route_len] = dir
  game.route_len = game.route_len + 1
  true
}

///|
fn pop_route_step(game : Game) -> Int {
  if game.route_len <= 0 {
    return dir_none
  }

  let dir : Int = game.route[0]
  for i = 1; i < game.route_len; i = i + 1 {
    game.route[i - 1] = game.route[i]
  }
  game.route_len = game.route_len - 1
  game.route[game.route_len] = dir_none
  dir
}

///|
fn route_dx(dir : Int) -> Int {
  if dir == dir_left {
    -1
  } else if dir == dir_right {
    1
  } else {
    0
  }
}

///|
fn route_dy(dir : Int) -> Int {
  if dir == dir_up {
    -1
  } else if dir == dir_down {
    1
  } else {
    0
  }
}

///|
fn is_walkable(game : Game, x : Int, y : Int) -> Bool {
  in_bounds(x, y) &&
  tile_at(game, x, y) != tile_rock &&
  not(lava_at(game, x, y))
}

///|
fn clear_sites(game : Game) -> Unit {
  game.site_count = 0
  for i = 0; i < game.sites.length(); i = i + 1 {
    game.sites[i].active = false
    game.sites[i].x = 0
    game.sites[i].y = 0
    game.sites[i].waiting = 0
  }
}

///|
fn add_site(game : Game, x : Int, y : Int, waiting : Int) -> Unit {
  if game.site_count >= max_sites || waiting <= 0 || not(in_bounds(x, y)) {
    return
  }

  let i : Int = game.site_count
  game.sites[i].active = true
  game.sites[i].x = x
  game.sites[i].y = y
  game.sites[i].waiting = waiting
  game.site_count = game.site_count + 1
}

///|
fn total_waiting(game : Game) -> Int {
  let mut total : Int = 0
  for i = 0; i < game.site_count; i = i + 1 {
    if game.sites[i].active && game.sites[i].waiting > 0 {
      total = total + game.sites[i].waiting
    }
  }
  total
}

///|
fn clear_world(game : Game) -> Unit {
  for i = 0; i < max_cells; i = i + 1 {
    game.terrain[i] = tile_ground
    game.lava[i] = false
    game.lava_buf[i] = false
  }

  clear_sites(game)
  clear_route(game)

  game.selected_tx = -1
  game.selected_ty = -1
  game.last_plan_ok = false
}

///|
fn add_rock_line(game : Game, x0 : Int, y0 : Int, x1 : Int, y1 : Int) -> Unit {
  if x0 == x1 {
    let mut a : Int = mini(y0, y1)
    let b : Int = maxi(y0, y1)
    while a <= b {
      set_tile(game, x0, a, tile_rock)
      a = a + 1
    }
  } else if y0 == y1 {
    let mut a : Int = mini(x0, x1)
    let b : Int = maxi(x0, x1)
    while a <= b {
      set_tile(game, a, y0, tile_rock)
      a = a + 1
    }
  }
}

///|
fn add_rock_block(game : Game, x : Int, y : Int, w : Int, h : Int) -> Unit {
  for yy = y; yy < y + h; yy = yy + 1 {
    for xx = x; xx < x + w; xx = xx + 1 {
      set_tile(game, xx, yy, tile_rock)
    }
  }
}

///|
fn add_depot(game : Game, x : Int, y : Int) -> Unit {
  if in_bounds(x, y) {
    set_tile(game, x, y, tile_depot)
  }
}

///|
fn add_lava_seed(game : Game, x : Int, y : Int) -> Unit {
  if in_bounds(x, y) && tile_at(game, x, y) != tile_rock {
    set_lava(game, x, y, true)
  }
}

///|
fn setup_level_0(game : Game) -> Unit {
  game.start_x = 1
  game.start_y = 8
  game.shelter_x = 13
  game.shelter_y = 1
  game.goal_rescue = 11
  game.mission_limit = 205.0
  game.lava_interval = 1.58

  add_rock_line(game, 4, 0, 4, 8)
  set_tile(game, 4, 2, tile_ground)
  set_tile(game, 4, 5, tile_ground)
  set_tile(game, 4, 7, tile_ground)

  add_rock_line(game, 7, 4, 14, 4)
  set_tile(game, 9, 4, tile_ground)
  set_tile(game, 12, 4, tile_ground)

  add_rock_block(game, 8, 0, 2, 2)
  add_rock_block(game, 10, 6, 2, 2)
  add_rock_block(game, 1, 4, 2, 1)

  add_depot(game, 2, 3)
  add_depot(game, 11, 8)

  add_lava_seed(game, 0, 0)
  add_lava_seed(game, 7, 0)
  add_lava_seed(game, 14, 9)

  add_site(game, 3, 7, 4)
  add_site(game, 8, 8, 3)
  add_site(game, 12, 6, 5)
  add_site(game, 6, 2, 3)
}

///|
fn setup_level_1(game : Game) -> Unit {
  game.start_x = 0
  game.start_y = 5
  game.shelter_x = 14
  game.shelter_y = 8
  game.goal_rescue = 13
  game.mission_limit = 225.0
  game.lava_interval = 1.42

  add_rock_line(game, 2, 0, 2, 8)
  set_tile(game, 2, 2, tile_ground)
  set_tile(game, 2, 6, tile_ground)

  add_rock_line(game, 6, 1, 6, 9)
  set_tile(game, 6, 3, tile_ground)
  set_tile(game, 6, 7, tile_ground)

  add_rock_line(game, 9, 0, 13, 0)
  add_rock_line(game, 9, 5, 14, 5)
  set_tile(game, 11, 5, tile_ground)

  add_rock_block(game, 10, 2, 2, 2)
  add_rock_block(game, 4, 7, 1, 3)

  add_depot(game, 5, 1)
  add_depot(game, 10, 6)

  add_lava_seed(game, 14, 0)
  add_lava_seed(game, 13, 1)
  add_lava_seed(game, 7, 9)

  add_site(game, 1, 1, 4)
  add_site(game, 4, 8, 3)
  add_site(game, 8, 4, 3)
  add_site(game, 11, 2, 4)
  add_site(game, 13, 6, 3)
}

///|
fn setup_level_2(game : Game) -> Unit {
  game.start_x = 7
  game.start_y = 9
  game.shelter_x = 1
  game.shelter_y = 0
  game.goal_rescue = 15
  game.mission_limit = 245.0
  game.lava_interval = 1.31

  add_rock_line(game, 3, 2, 12, 2)
  set_tile(game, 5, 2, tile_ground)
  set_tile(game, 8, 2, tile_ground)
  set_tile(game, 10, 2, tile_ground)

  add_rock_line(game, 4, 6, 11, 6)
  set_tile(game, 6, 6, tile_ground)
  set_tile(game, 9, 6, tile_ground)

  add_rock_line(game, 12, 3, 12, 9)
  set_tile(game, 12, 5, tile_ground)
  set_tile(game, 12, 8, tile_ground)

  add_rock_block(game, 0, 4, 2, 2)
  add_rock_block(game, 7, 4, 2, 1)

  add_depot(game, 6, 5)
  add_depot(game, 13, 2)

  add_lava_seed(game, 14, 4)
  add_lava_seed(game, 14, 5)
  add_lava_seed(game, 13, 4)
  add_lava_seed(game, 0, 9)

  add_site(game, 2, 8, 4)
  add_site(game, 5, 4, 5)
  add_site(game, 8, 8, 4)
  add_site(game, 10, 1, 4)
  add_site(game, 13, 7, 3)
}

///|
fn finalize_level_setup(game : Game) -> Unit {
  set_tile(game, game.shelter_x, game.shelter_y, tile_shelter)
  set_tile(game, game.start_x, game.start_y, tile_ground)

  game.truck_x = game.start_x
  game.truck_y = game.start_y

  game.total_civilians = total_waiting(game)
  game.goal_rescue = clampi(game.goal_rescue, 1, game.total_civilians)

  game.carrying = 0
  game.rescued = 0
  game.lost = 0

  game.heat = 14.0 + Float::from_int(game.level_index * 4)
  game.fuel = max_fuel
  game.coolant = max_coolant

  game.mission_time = 0.0
  game.lava_timer = 0.0
  game.result = result_none
  game.state = state_play

  clear_route(game)

  set_message(
    game,
    "Mission " + (game.level_index + 1).to_string() + " underway",
    1.4,
  )
}

///|
fn load_level(game : Game, index : Int) -> Unit {
  clear_world(game)

  game.level_index = clampi(index, 0, level_count - 1)

  if game.level_index == 0 {
    setup_level_0(game)
  } else if game.level_index == 1 {
    setup_level_1(game)
  } else {
    setup_level_2(game)
  }

  finalize_level_setup(game)
}

///|
fn restart_level(game : Game) -> Unit {
  load_level(game, game.level_index)
}

///|
fn start_campaign(game : Game) -> Unit {
  load_level(game, 0)
}

///|
fn has_next_level(game : Game) -> Bool {
  game.level_index + 1 < level_count
}

///|
fn next_level_or_title(game : Game) -> Unit {
  if has_next_level(game) {
    load_level(game, game.level_index + 1)
  } else {
    game.state = state_title
    game.result = result_none
    game.msg = ""
    game.msg_t = 0.0
    game.route_len = 0
    game.route_running = false
    game.selected_tx = -1
    game.selected_ty = -1
    game.last_plan_ok = false
  }
}

///|
fn level_title(index : Int) -> String {
  if index == 0 {
    "North Ridge Lift"
  } else if index == 1 {
    "Molten Corridor"
  } else {
    "Caldera Spiral"
  }
}

///|
fn mission_result_label(game : Game) -> String {
  if game.result == result_win {
    "Mission Successful"
  } else {
    "Mission Failed"
  }
}

///|
fn append_manual_step(game : Game, dir : Int) -> Bool {
  if dir == dir_none {
    return false
  }

  let ok : Bool = push_route_step(game, dir)
  game.last_plan_ok = ok
  game.selected_tx = -1
  game.selected_ty = -1

  if not(ok) {
    set_message(game, "Route queue full", 0.8)
  }

  ok
}

///|
fn begin_route(game : Game) -> Unit {
  if game.route_len <= 0 {
    set_message(game, "Route queue is empty", 0.8)
    return
  }

  game.route_running = true
  game.step_timer = 0.0
  set_message(game, "Convoy moving", 0.55)
}

///|
fn clear_planned_route(game : Game) -> Unit {
  if game.route_len > 0 {
    clear_route(game)
    set_message(game, "Route queue cleared", 0.55)
  }
}

///|
fn use_coolant(game : Game) -> Unit {
  if game.coolant < 18.0 {
    set_message(game, "Coolant too low", 0.7)
    return
  }

  game.coolant = clampf(game.coolant - 18.0, 0.0, max_coolant)
  game.heat = clampf(game.heat - 28.0, 0.0, max_heat)
  set_message(game, "Emergency spray deployed", 0.75)
}

///|
fn plan_route_to(game : Game, tx : Int, ty : Int) -> Bool {
  game.selected_tx = tx
  game.selected_ty = ty

  if not(in_bounds(tx, ty)) {
    game.last_plan_ok = false
    return false
  }

  if not(is_walkable(game, tx, ty)) {
    game.last_plan_ok = false
    set_message(game, "Target cell is blocked", 0.85)
    return false
  }

  let start : Int = cell_index(game.truck_x, game.truck_y)
  let goal : Int = cell_index(tx, ty)

  let q : Array[Int] = Array::make(max_cells, 0)
  let parent : Array[Int] = Array::make(max_cells, -1)
  let parent_dir : Array[Int] = Array::make(max_cells, dir_none)
  let visited : Array[Bool] = Array::make(max_cells, false)

  let mut head : Int = 0
  let mut tail : Int = 0

  q[tail] = start
  tail = tail + 1
  visited[start] = true

  while head < tail && not(visited[goal]) {
    let cur : Int = q[head]
    head = head + 1

    let cx : Int = cur % grid_w
    let cy : Int = cur / grid_w

    for k = 0; k < 4; k = k + 1 {
      let dir : Int = if k == 0 {
        dir_up
      } else if k == 1 {
        dir_down
      } else if k == 2 {
        dir_left
      } else {
        dir_right
      }

      let nx : Int = cx + route_dx(dir)
      let ny : Int = cy + route_dy(dir)

      if not(in_bounds(nx, ny)) {
        continue
      }
      if not(is_walkable(game, nx, ny)) {
        continue
      }

      let nidx : Int = cell_index(nx, ny)
      if visited[nidx] {
        continue
      }

      visited[nidx] = true
      parent[nidx] = cur
      parent_dir[nidx] = dir
      q[tail] = nidx
      tail = tail + 1
    }
  }

  if not(visited[goal]) {
    game.last_plan_ok = false
    set_message(game, "No safe path available", 0.95)
    return false
  }

  let rev : Array[Int] = Array::make(max_route_steps, dir_none)
  let mut rev_len : Int = 0
  let mut cur : Int = goal

  while cur != start {
    if rev_len >= max_route_steps {
      game.last_plan_ok = false
      set_message(game, "Path exceeds queue limit", 0.95)
      return false
    }

    let d : Int = parent_dir[cur]
    if d == dir_none {
      game.last_plan_ok = false
      set_message(game, "Planner failed", 0.95)
      return false
    }

    rev[rev_len] = d
    rev_len = rev_len + 1
    cur = parent[cur]

    if cur < 0 {
      game.last_plan_ok = false
      set_message(game, "Planner failed", 0.95)
      return false
    }
  }

  clear_route(game)

  let mut i : Int = rev_len - 1
  while i >= 0 {
    ignore(push_route_step(game, rev[i]))
    i = i - 1
  }

  game.last_plan_ok = true

  if rev_len > 0 {
    set_message(game, "Route planned: " + rev_len.to_string() + " steps", 0.9)
  } else {
    set_message(game, "Already at target", 0.7)
  }

  true
}

///|
fn pickup_civilians(game : Game) -> Unit {
  if game.carrying >= vehicle_capacity {
    return
  }

  for i = 0; i < game.site_count; i = i + 1 {
    if not(game.sites[i].active) || game.sites[i].waiting <= 0 {
      continue
    }

    if game.sites[i].x != game.truck_x || game.sites[i].y != game.truck_y {
      continue
    }

    let room : Int = vehicle_capacity - game.carrying
    if room <= 0 {
      return
    }

    let take : Int = mini(room, game.sites[i].waiting)
    if take <= 0 {
      continue
    }

    game.sites[i].waiting = game.sites[i].waiting - take
    game.carrying = game.carrying + take

    set_message(game, "Picked up " + take.to_string() + " civilians", 0.85)
  }
}

///|
fn dropoff_civilians(game : Game) -> Unit {
  if game.carrying <= 0 {
    return
  }

  if game.truck_x == game.shelter_x && game.truck_y == game.shelter_y {
    let delivered : Int = game.carrying
    game.rescued = game.rescued + delivered
    game.carrying = 0

    set_message(game, "Delivered " + delivered.to_string() + " civilians", 0.9)
  }
}

///|
fn tile_is_depot(game : Game, x : Int, y : Int) -> Bool {
  tile_at(game, x, y) == tile_depot
}

///|
fn process_arrival(game : Game) -> Unit {
  pickup_civilians(game)
  dropoff_civilians(game)
}

///|
fn move_step(game : Game, dir : Int) -> Bool {
  if dir == dir_none {
    return false
  }

  if game.fuel < move_fuel_cost {
    game.route_running = false
    set_message(game, "Insufficient fuel", 0.75)
    return false
  }

  let nx : Int = game.truck_x + route_dx(dir)
  let ny : Int = game.truck_y + route_dy(dir)

  if not(is_walkable(game, nx, ny)) {
    game.route_running = false
    set_message(game, "Route blocked by lava or debris", 0.9)
    return false
  }

  game.truck_x = nx
  game.truck_y = ny
  game.fuel = clampf(game.fuel - move_fuel_cost, 0.0, max_fuel)
  game.heat = clampf(game.heat + move_heat_gain, 0.0, max_heat)

  process_arrival(game)
  true
}

///|
fn update_route_run(game : Game, dt : Float) -> Unit {
  if not(game.route_running) {
    return
  }

  game.step_timer = game.step_timer + dt

  while game.step_timer >= step_interval {
    game.step_timer = game.step_timer - step_interval

    if game.route_len <= 0 {
      game.route_running = false
      break
    }

    let dir : Int = pop_route_step(game)
    if dir == dir_none {
      game.route_running = false
      break
    }

    if not(move_step(game, dir)) {
      break
    }
  }
}

///|
fn lava_pressure(game : Game) -> Int {
  let mut pressure : Int = 0

  for oy = -1; oy <= 1; oy = oy + 1 {
    for ox = -1; ox <= 1; ox = ox + 1 {
      let nx : Int = game.truck_x + ox
      let ny : Int = game.truck_y + oy
      if lava_at(game, nx, ny) {
        let add : Int = if ox == 0 && oy == 0 { 4 } else { 2 }
        pressure = pressure + add
      }
    }
  }

  pressure
}

///|
fn update_passive_heat_and_supply(game : Game, dt : Float) -> Unit {
  let pressure : Int = lava_pressure(game)

  let mut heat_gain : Float = 1.2 + Float::from_int(pressure) * 0.34
  heat_gain = heat_gain + Float::from_int(game.carrying) * 0.24
  if game.route_running {
    heat_gain = heat_gain + 0.25
  }

  let mut cooling : Float = 0.95

  if tile_is_depot(game, game.truck_x, game.truck_y) {
    cooling = cooling + 5.6
    game.fuel = clampf(game.fuel + dt * 23.0, 0.0, max_fuel)
    game.coolant = clampf(game.coolant + dt * 16.0, 0.0, max_coolant)
  }

  game.fuel = clampf(
    game.fuel - dt * (0.36 + Float::from_int(game.carrying) * 0.06),
    0.0,
    max_fuel,
  )

  game.heat = clampf(game.heat + (heat_gain - cooling) * dt, 0.0, max_heat)
}

///|
fn burn_sites_from_lava(game : Game) -> Unit {
  let mut losses : Int = 0

  for i = 0; i < game.site_count; i = i + 1 {
    if not(game.sites[i].active) || game.sites[i].waiting <= 0 {
      continue
    }

    if lava_at(game, game.sites[i].x, game.sites[i].y) {
      losses = losses + game.sites[i].waiting
      game.lost = game.lost + game.sites[i].waiting
      game.sites[i].waiting = 0
    }
  }

  if losses > 0 {
    set_message(game, losses.to_string() + " civilians lost to lava", 1.0)
  }
}

///|
fn spread_chance(game : Game, nx : Int, ny : Int, base : Int) -> Int {
  let mut chance : Int = base

  if tile_at(game, nx, ny) == tile_depot {
    chance = chance + 8
  }

  if nx == game.shelter_x && ny == game.shelter_y {
    chance = chance - 12
  }

  if nx == game.truck_x && ny == game.truck_y {
    chance = chance + 10
  }

  clampi(chance, 6, 95)
}

///|
fn try_spread_to(game : Game, nx : Int, ny : Int, base : Int) -> Unit {
  if not(in_bounds(nx, ny)) {
    return
  }
  if tile_at(game, nx, ny) == tile_rock {
    return
  }

  let idx : Int = cell_index(nx, ny)
  if game.lava[idx] || game.lava_buf[idx] {
    return
  }

  let chance : Int = spread_chance(game, nx, ny, base)
  if @raylib.get_random_value(0, 99) < chance {
    game.lava_buf[idx] = true
  }
}

///|
fn spread_lava_once(game : Game) -> Unit {
  for i = 0; i < max_cells; i = i + 1 {
    game.lava_buf[i] = game.lava[i]
  }

  let base : Int = 28 + game.level_index * 8

  for y = 0; y < grid_h; y = y + 1 {
    for x = 0; x < grid_w; x = x + 1 {
      if not(lava_at(game, x, y)) {
        continue
      }

      try_spread_to(game, x + 1, y, base)
      try_spread_to(game, x - 1, y, base)
      try_spread_to(game, x, y + 1, base)
      try_spread_to(game, x, y - 1, base)
    }
  }

  for i = 0; i < max_cells; i = i + 1 {
    game.lava[i] = game.lava_buf[i]
  }

  burn_sites_from_lava(game)
}

///|
fn finish_mission(game : Game, win : Bool, reason : String) -> Unit {
  game.state = state_result
  game.result = if win { result_win } else { result_lose }
  clear_route(game)
  set_message(game, reason, 2.8)
}

///|
fn evaluate_mission_state(game : Game) -> Unit {
  if game.rescued >= game.goal_rescue {
    finish_mission(game, true, "Rescue quota achieved")
    return
  }

  if game.heat >= max_heat {
    finish_mission(game, false, "Vehicle overheated")
    return
  }

  if game.mission_time >= game.mission_limit {
    finish_mission(game, false, "Mission timer expired")
    return
  }

  if lava_at(game, game.truck_x, game.truck_y) {
    finish_mission(game, false, "Convoy consumed by lava")
    return
  }

  if lava_at(game, game.shelter_x, game.shelter_y) {
    finish_mission(game, false, "Shelter overrun")
    return
  }

  let remaining_possible : Int = game.rescued +
    game.carrying +
    total_waiting(game)
  if remaining_possible < game.goal_rescue {
    finish_mission(game, false, "Rescue quota no longer possible")
    return
  }

  if game.fuel <= 0.0 && not(tile_is_depot(game, game.truck_x, game.truck_y)) {
    if game.route_len <= 0 && not(game.route_running) {
      finish_mission(game, false, "Fuel exhausted")
    }
  }
}

///|
fn update_play(game : Game, dt : Float) -> Unit {
  if game.state != state_play {
    return
  }

  game.mission_time = game.mission_time + dt

  update_route_run(game, dt)
  update_passive_heat_and_supply(game, dt)

  game.lava_timer = game.lava_timer + dt
  while game.lava_timer >= game.lava_interval {
    game.lava_timer = game.lava_timer - game.lava_interval
    spread_lava_once(game)
  }

  process_arrival(game)
  evaluate_mission_state(game)
}

///|
fn update_timers(game : Game, dt : Float) -> Unit {
  game.ui_t = game.ui_t + dt

  if game.msg_t > 0.0 {
    game.msg_t = clampf(game.msg_t - dt, 0.0, 1000.0)
  }

  if game.touch_cd > 0.0 {
    game.touch_cd = clampf(game.touch_cd - dt, 0.0, 1000.0)
  }
}

///|
fn current_goal_progress(game : Game) -> String {
  game.rescued.to_string() + " / " + game.goal_rescue.to_string()
}
