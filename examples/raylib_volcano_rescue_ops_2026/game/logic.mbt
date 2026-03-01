///|
fn set_tile(game : @types.Game, x : Int, y : Int, t : Int) -> Unit {
  if @types.in_bounds(x, y) {
    game.terrain[@types.cell_index(x, y)] = t
  }
}

///|
fn set_lava(game : @types.Game, x : Int, y : Int, v : Bool) -> Unit {
  if @types.in_bounds(x, y) {
    game.lava[@types.cell_index(x, y)] = v
  }
}

///|
fn set_message(game : @types.Game, msg : String, ttl : Float) -> Unit {
  game.msg = msg
  game.msg_t = ttl
}

///|
fn clear_route(game : @types.Game) -> Unit {
  game.route_len = 0
  game.route_running = false
  game.step_timer = 0.0
  for i in 0..<game.route.length() {
    game.route[i] = @types.dir_none
  }
}

///|
fn push_route_step(game : @types.Game, dir : Int) -> Bool {
  if game.route_len >= @types.max_route_steps {
    return false
  }

  game.route[game.route_len] = dir
  game.route_len = game.route_len + 1
  true
}

///|
fn pop_route_step(game : @types.Game) -> Int {
  if game.route_len <= 0 {
    return @types.dir_none
  }

  let dir : Int = game.route[0]
  for i in 1..<game.route_len {
    game.route[i - 1] = game.route[i]
  }
  game.route_len = game.route_len - 1
  game.route[game.route_len] = @types.dir_none
  dir
}

///|
fn is_walkable(game : @types.Game, x : Int, y : Int) -> Bool {
  @types.in_bounds(x, y) &&
  @types.tile_at(game, x, y) != @types.tile_rock &&
  not(@types.lava_at(game, x, y))
}

///|
fn clear_sites(game : @types.Game) -> Unit {
  game.site_count = 0
  for site in game.sites {
    site.active = false
    site.x = 0
    site.y = 0
    site.waiting = 0
  }
}

///|
fn add_site(game : @types.Game, x : Int, y : Int, waiting : Int) -> Unit {
  if game.site_count >= @types.max_sites || waiting <= 0 || not(@types.in_bounds(x, y)) {
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
fn clear_world(game : @types.Game) -> Unit {
  for i in 0..< @types.max_cells {
    game.terrain[i] = @types.tile_ground
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
fn add_rock_line(game : @types.Game, x0 : Int, y0 : Int, x1 : Int, y1 : Int) -> Unit {
  if x0 == x1 {
    let mut a : Int = @types.mini(y0, y1)
    let b : Int = @types.maxi(y0, y1)
    while a <= b {
      set_tile(game, x0, a, @types.tile_rock)
      a = a + 1
    }
  } else if y0 == y1 {
    let mut a : Int = @types.mini(x0, x1)
    let b : Int = @types.maxi(x0, x1)
    while a <= b {
      set_tile(game, a, y0, @types.tile_rock)
      a = a + 1
    }
  }
}

///|
fn add_rock_block(game : @types.Game, x : Int, y : Int, w : Int, h : Int) -> Unit {
  for yy in y..<(y + h) {
    for xx in x..<(x + w) {
      set_tile(game, xx, yy, @types.tile_rock)
    }
  }
}

///|
fn add_depot(game : @types.Game, x : Int, y : Int) -> Unit {
  if @types.in_bounds(x, y) {
    set_tile(game, x, y, @types.tile_depot)
  }
}

///|
fn add_lava_seed(game : @types.Game, x : Int, y : Int) -> Unit {
  if @types.in_bounds(x, y) && @types.tile_at(game, x, y) != @types.tile_rock {
    set_lava(game, x, y, true)
  }
}

///|
fn setup_level_0(game : @types.Game) -> Unit {
  game.start_x = 1
  game.start_y = 8
  game.shelter_x = 13
  game.shelter_y = 1
  game.goal_rescue = 11
  game.mission_limit = 205.0
  game.lava_interval = 1.58

  add_rock_line(game, 4, 0, 4, 8)
  set_tile(game, 4, 2, @types.tile_ground)
  set_tile(game, 4, 5, @types.tile_ground)
  set_tile(game, 4, 7, @types.tile_ground)

  add_rock_line(game, 7, 4, 14, 4)
  set_tile(game, 9, 4, @types.tile_ground)
  set_tile(game, 12, 4, @types.tile_ground)

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
fn setup_level_1(game : @types.Game) -> Unit {
  game.start_x = 0
  game.start_y = 5
  game.shelter_x = 14
  game.shelter_y = 8
  game.goal_rescue = 13
  game.mission_limit = 225.0
  game.lava_interval = 1.42

  add_rock_line(game, 2, 0, 2, 8)
  set_tile(game, 2, 2, @types.tile_ground)
  set_tile(game, 2, 6, @types.tile_ground)

  add_rock_line(game, 6, 1, 6, 9)
  set_tile(game, 6, 3, @types.tile_ground)
  set_tile(game, 6, 7, @types.tile_ground)

  add_rock_line(game, 9, 0, 13, 0)
  add_rock_line(game, 9, 5, 14, 5)
  set_tile(game, 11, 5, @types.tile_ground)

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
fn setup_level_2(game : @types.Game) -> Unit {
  game.start_x = 7
  game.start_y = 9
  game.shelter_x = 1
  game.shelter_y = 0
  game.goal_rescue = 15
  game.mission_limit = 245.0
  game.lava_interval = 1.31

  add_rock_line(game, 3, 2, 12, 2)
  set_tile(game, 5, 2, @types.tile_ground)
  set_tile(game, 8, 2, @types.tile_ground)
  set_tile(game, 10, 2, @types.tile_ground)

  add_rock_line(game, 4, 6, 11, 6)
  set_tile(game, 6, 6, @types.tile_ground)
  set_tile(game, 9, 6, @types.tile_ground)

  add_rock_line(game, 12, 3, 12, 9)
  set_tile(game, 12, 5, @types.tile_ground)
  set_tile(game, 12, 8, @types.tile_ground)

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
fn finalize_level_setup(game : @types.Game) -> Unit {
  set_tile(game, game.shelter_x, game.shelter_y, @types.tile_shelter)
  set_tile(game, game.start_x, game.start_y, @types.tile_ground)

  game.truck_x = game.start_x
  game.truck_y = game.start_y

  game.total_civilians = @types.total_waiting(game)
  game.goal_rescue = @types.clampi(game.goal_rescue, 1, game.total_civilians)

  game.carrying = 0
  game.rescued = 0
  game.lost = 0

  game.heat = 14.0 + Float::from_int(game.level_index * 4)
  game.fuel = @types.max_fuel
  game.coolant = @types.max_coolant

  game.mission_time = 0.0
  game.lava_timer = 0.0
  game.result = @types.result_none
  game.state = @types.state_play

  clear_route(game)

  set_message(
    game,
    "Mission " + (game.level_index + 1).to_string() + " underway",
    1.4,
  )
}

///|
fn load_level(game : @types.Game, index : Int) -> Unit {
  clear_world(game)

  game.level_index = @types.clampi(index, 0, @types.level_count - 1)

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
fn restart_level(game : @types.Game) -> Unit {
  load_level(game, game.level_index)
}

///|
fn start_campaign(game : @types.Game) -> Unit {
  load_level(game, 0)
}

///|
fn next_level_or_title(game : @types.Game) -> Unit {
  if @types.has_next_level(game) {
    load_level(game, game.level_index + 1)
  } else {
    game.state = @types.state_title
    game.result = @types.result_none
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
fn append_manual_step(game : @types.Game, dir : Int) -> Bool {
  if dir == @types.dir_none {
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
fn begin_route(game : @types.Game) -> Unit {
  if game.route_len <= 0 {
    set_message(game, "Route queue is empty", 0.8)
    return
  }

  game.route_running = true
  game.step_timer = 0.0
  set_message(game, "Convoy moving", 0.55)
}

///|
fn clear_planned_route(game : @types.Game) -> Unit {
  if game.route_len > 0 {
    clear_route(game)
    set_message(game, "Route queue cleared", 0.55)
  }
}

///|
fn use_coolant(game : @types.Game) -> Unit {
  if game.coolant < 18.0 {
    set_message(game, "Coolant too low", 0.7)
    return
  }

  game.coolant = @types.clampf(game.coolant - 18.0, 0.0, @types.max_coolant)
  game.heat = @types.clampf(game.heat - 28.0, 0.0, @types.max_heat)
  set_message(game, "Emergency spray deployed", 0.75)
}

///|
fn plan_route_to(game : @types.Game, tx : Int, ty : Int) -> Bool {
  game.selected_tx = tx
  game.selected_ty = ty

  if not(@types.in_bounds(tx, ty)) {
    game.last_plan_ok = false
    return false
  }

  if not(is_walkable(game, tx, ty)) {
    game.last_plan_ok = false
    set_message(game, "Target cell is blocked", 0.85)
    return false
  }

  let start : Int = @types.cell_index(game.truck_x, game.truck_y)
  let goal : Int = @types.cell_index(tx, ty)

  let q : Array[Int] = Array::make(@types.max_cells, 0)
  let parent : Array[Int] = Array::make(@types.max_cells, -1)
  let parent_dir : Array[Int] = Array::make(@types.max_cells, @types.dir_none)
  let visited : Array[Bool] = Array::make(@types.max_cells, false)

  let mut head : Int = 0
  let mut tail : Int = 0

  q[tail] = start
  tail = tail + 1
  visited[start] = true

  while head < tail && not(visited[goal]) {
    let cur : Int = q[head]
    head = head + 1

    let cx : Int = cur % @types.grid_w
    let cy : Int = cur / @types.grid_w

    for k in 0..<4 {
      let dir : Int = if k == 0 {
        @types.dir_up
      } else if k == 1 {
        @types.dir_down
      } else if k == 2 {
        @types.dir_left
      } else {
        @types.dir_right
      }

      let nx : Int = cx + @types.route_dx(dir)
      let ny : Int = cy + @types.route_dy(dir)

      if not(@types.in_bounds(nx, ny)) {
        continue
      }
      if not(is_walkable(game, nx, ny)) {
        continue
      }

      let nidx : Int = @types.cell_index(nx, ny)
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

  let rev : Array[Int] = Array::make(@types.max_route_steps, @types.dir_none)
  let mut rev_len : Int = 0
  let mut cur : Int = goal

  while cur != start {
    if rev_len >= @types.max_route_steps {
      game.last_plan_ok = false
      set_message(game, "Path exceeds queue limit", 0.95)
      return false
    }

    let d : Int = parent_dir[cur]
    if d == @types.dir_none {
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
fn pickup_civilians(game : @types.Game) -> Unit {
  if game.carrying >= @types.vehicle_capacity {
    return
  }

  for i in 0..<game.site_count {
    if not(game.sites[i].active) || game.sites[i].waiting <= 0 {
      continue
    }

    if game.sites[i].x != game.truck_x || game.sites[i].y != game.truck_y {
      continue
    }

    let room : Int = @types.vehicle_capacity - game.carrying
    if room <= 0 {
      return
    }

    let take : Int = @types.mini(room, game.sites[i].waiting)
    if take <= 0 {
      continue
    }

    game.sites[i].waiting = game.sites[i].waiting - take
    game.carrying = game.carrying + take

    set_message(game, "Picked up " + take.to_string() + " civilians", 0.85)
  }
}

///|
fn dropoff_civilians(game : @types.Game) -> Unit {
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
fn tile_is_depot(game : @types.Game, x : Int, y : Int) -> Bool {
  @types.tile_at(game, x, y) == @types.tile_depot
}

///|
fn process_arrival(game : @types.Game) -> Unit {
  pickup_civilians(game)
  dropoff_civilians(game)
}

///|
fn move_step(game : @types.Game, dir : Int) -> Bool {
  if dir == @types.dir_none {
    return false
  }

  if game.fuel < @types.move_fuel_cost {
    game.route_running = false
    set_message(game, "Insufficient fuel", 0.75)
    return false
  }

  let nx : Int = game.truck_x + @types.route_dx(dir)
  let ny : Int = game.truck_y + @types.route_dy(dir)

  if not(is_walkable(game, nx, ny)) {
    game.route_running = false
    set_message(game, "Route blocked by lava or debris", 0.9)
    return false
  }

  game.truck_x = nx
  game.truck_y = ny
  game.fuel = @types.clampf(game.fuel - @types.move_fuel_cost, 0.0, @types.max_fuel)
  game.heat = @types.clampf(game.heat + @types.move_heat_gain, 0.0, @types.max_heat)

  process_arrival(game)
  true
}

///|
fn update_route_run(game : @types.Game, dt : Float) -> Unit {
  if not(game.route_running) {
    return
  }

  game.step_timer = game.step_timer + dt

  while game.step_timer >= @types.step_interval {
    game.step_timer = game.step_timer - @types.step_interval

    if game.route_len <= 0 {
      game.route_running = false
      break
    }

    let dir : Int = pop_route_step(game)
    if dir == @types.dir_none {
      game.route_running = false
      break
    }

    if not(move_step(game, dir)) {
      break
    }
  }
}

///|
fn lava_pressure(game : @types.Game) -> Int {
  let mut pressure : Int = 0

  for oy in -1..<=1 {
    for ox in -1..<=1 {
      let nx : Int = game.truck_x + ox
      let ny : Int = game.truck_y + oy
      if @types.lava_at(game, nx, ny) {
        let add : Int = if ox == 0 && oy == 0 { 4 } else { 2 }
        pressure = pressure + add
      }
    }
  }

  pressure
}

///|
fn update_passive_heat_and_supply(game : @types.Game, dt : Float) -> Unit {
  let pressure : Int = lava_pressure(game)

  let mut heat_gain : Float = 1.2 + Float::from_int(pressure) * 0.34
  heat_gain = heat_gain + Float::from_int(game.carrying) * 0.24
  if game.route_running {
    heat_gain = heat_gain + 0.25
  }

  let mut cooling : Float = 0.95

  if tile_is_depot(game, game.truck_x, game.truck_y) {
    cooling = cooling + 5.6
    game.fuel = @types.clampf(game.fuel + dt * 23.0, 0.0, @types.max_fuel)
    game.coolant = @types.clampf(game.coolant + dt * 16.0, 0.0, @types.max_coolant)
  }

  game.fuel = @types.clampf(
    game.fuel - dt * (0.36 + Float::from_int(game.carrying) * 0.06),
    0.0,
    @types.max_fuel,
  )

  game.heat = @types.clampf(game.heat + (heat_gain - cooling) * dt, 0.0, @types.max_heat)
}

///|
fn burn_sites_from_lava(game : @types.Game) -> Unit {
  let mut losses : Int = 0

  for i in 0..<game.site_count {
    if not(game.sites[i].active) || game.sites[i].waiting <= 0 {
      continue
    }

    if @types.lava_at(game, game.sites[i].x, game.sites[i].y) {
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
fn spread_chance(game : @types.Game, nx : Int, ny : Int, base : Int) -> Int {
  let mut chance : Int = base

  if @types.tile_at(game, nx, ny) == @types.tile_depot {
    chance = chance + 8
  }

  if nx == game.shelter_x && ny == game.shelter_y {
    chance = chance - 12
  }

  if nx == game.truck_x && ny == game.truck_y {
    chance = chance + 10
  }

  @types.clampi(chance, 6, 95)
}

///|
fn try_spread_to(game : @types.Game, nx : Int, ny : Int, base : Int) -> Unit {
  if not(@types.in_bounds(nx, ny)) {
    return
  }
  if @types.tile_at(game, nx, ny) == @types.tile_rock {
    return
  }

  let idx : Int = @types.cell_index(nx, ny)
  if game.lava[idx] || game.lava_buf[idx] {
    return
  }

  let chance : Int = spread_chance(game, nx, ny, base)
  if @raylib.get_random_value(0, 99) < chance {
    game.lava_buf[idx] = true
  }
}

///|
fn spread_lava_once(game : @types.Game) -> Unit {
  for i in 0..< @types.max_cells {
    game.lava_buf[i] = game.lava[i]
  }

  let base : Int = 28 + game.level_index * 8

  for y in 0..< @types.grid_h {
    for x in 0..< @types.grid_w {
      if not(@types.lava_at(game, x, y)) {
        continue
      }

      try_spread_to(game, x + 1, y, base)
      try_spread_to(game, x - 1, y, base)
      try_spread_to(game, x, y + 1, base)
      try_spread_to(game, x, y - 1, base)
    }
  }

  for i in 0..< @types.max_cells {
    game.lava[i] = game.lava_buf[i]
  }

  burn_sites_from_lava(game)
}

///|
fn finish_mission(game : @types.Game, win : Bool, reason : String) -> Unit {
  game.state = @types.state_result
  game.result = if win { @types.result_win } else { @types.result_lose }
  clear_route(game)
  set_message(game, reason, 2.8)
}

///|
fn evaluate_mission_state(game : @types.Game) -> Unit {
  if game.rescued >= game.goal_rescue {
    finish_mission(game, true, "Rescue quota achieved")
    return
  }

  if game.heat >= @types.max_heat {
    finish_mission(game, false, "Vehicle overheated")
    return
  }

  if game.mission_time >= game.mission_limit {
    finish_mission(game, false, "Mission timer expired")
    return
  }

  if @types.lava_at(game, game.truck_x, game.truck_y) {
    finish_mission(game, false, "Convoy consumed by lava")
    return
  }

  if @types.lava_at(game, game.shelter_x, game.shelter_y) {
    finish_mission(game, false, "Shelter overrun")
    return
  }

  let remaining_possible : Int = game.rescued +
    game.carrying +
    @types.total_waiting(game)
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
fn update_play(game : @types.Game, dt : Float) -> Unit {
  if game.state != @types.state_play {
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
fn update_timers(game : @types.Game, dt : Float) -> Unit {
  game.ui_t = game.ui_t + dt

  if game.msg_t > 0.0 {
    game.msg_t = @types.clampf(game.msg_t - dt, 0.0, 1000.0)
  }

  if game.touch_cd > 0.0 {
    game.touch_cd = @types.clampf(game.touch_cd - dt, 0.0, 1000.0)
  }
}

///|
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  // Handle F11 toggle
  if @raylib.is_key_pressed(@raylib.KeyF11) {
    @raylib.toggle_borderless_windowed()
  }

  // Read mouse/touch state
  let mouse = @raylib.get_mouse_position()
  game.mouse_x = mouse.x
  game.mouse_y = mouse.y
  game.mouse_hold = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft)
  game.mouse_press = @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft)
  let mut tc : Int = @raylib.get_touch_point_count()
  if tc < 0 {
    tc = 0
  }
  game.touch_count = tc

  update_timers(game, dt)

  if game.state == @types.state_title {
    if detect_start_press(game.mouse_x, game.mouse_y, game.mouse_press, game.touch_count) {
      start_campaign(game)
    }
  } else if game.state == @types.state_play {
    let restart_press : Bool = detect_restart_press(
      game.mouse_x, game.mouse_y, game.mouse_press, game.touch_count,
    )

    if restart_press && game.touch_cd <= 0.0 {
      game.touch_cd = 0.2
      restart_level(game)
    } else {
      let dir : Int = detect_dir_press(
        game.mouse_x, game.mouse_y, game.mouse_press, game.touch_count,
      )
      if dir != @types.dir_none && game.touch_cd <= 0.0 {
        game.touch_cd = 0.08
        ignore(append_manual_step(game, dir))
      }

      let tap = detect_map_target(game.mouse_x, game.mouse_y, game.mouse_press, game.touch_count)
      if tap.0 && game.touch_cd <= 0.0 {
        game.touch_cd = 0.12
        ignore(plan_route_to(game, tap.1, tap.2))
      }

      if detect_execute_press(game.mouse_x, game.mouse_y, game.mouse_press, game.touch_count) &&
        game.touch_cd <= 0.0 {
        game.touch_cd = 0.14
        begin_route(game)
      }

      if detect_clear_route_press(game.mouse_x, game.mouse_y, game.mouse_press, game.touch_count) &&
        game.touch_cd <= 0.0 {
        game.touch_cd = 0.14
        clear_planned_route(game)
      }

      if detect_coolant_press(game.mouse_x, game.mouse_y, game.mouse_press, game.touch_count) &&
        game.touch_cd <= 0.0 {
        game.touch_cd = 0.18
        use_coolant(game)
      }
    }

    update_play(game, dt)
  } else if detect_restart_press(game.mouse_x, game.mouse_y, game.mouse_press, game.touch_count) &&
    game.touch_cd <= 0.0 {
    game.touch_cd = 0.2
    restart_level(game)
  } else if detect_next_press(game.mouse_x, game.mouse_y, game.mouse_press, game.touch_count) &&
    game.touch_cd <= 0.0 &&
    game.result == @types.result_win {
    game.touch_cd = 0.2
    next_level_or_title(game)
  }
}
