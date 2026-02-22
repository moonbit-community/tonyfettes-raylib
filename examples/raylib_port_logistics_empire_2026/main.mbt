///|
let sw = 1366

///|
let sh = 768

///|
let world_l : Float = 24.0

///|
let world_t : Float = 24.0

///|
let world_r : Float = 950.0

///|
let world_b : Float = 744.0

///|
let max_nodes = 12

///|
let max_routes = 40

///|
let max_trucks = 140

///|
let max_sparks = 280

///|
struct Node {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut r : Float
  mut raw : Int
  mut goods : Int
  mut demand : Int
  mut delivered : Int
  mut prod_cd : Float
  mut pulse : Float
  mut outage_t : Float
  mut name : String
}

///|
struct Route {
  mut active : Bool
  mut a : Int
  mut b : Int
  mut level : Int
  mut hp : Float
  mut spawn_cd : Float
  mut blink : Float
}

///|
struct Truck {
  mut active : Bool
  mut route : Int
  mut t : Float
  mut dir : Int
  mut speed : Float
  mut cargo_kind : Int
  mut cargo : Int
  mut blink : Float
  mut stuck_t : Float
}

///|
struct Spark {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut life : Float
  mut size : Float
  mut kind : Int
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
fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx : Float = x1 - x0
  let dy : Float = y1 - y0
  dx * dx + dy * dy
}

///|
fn randf(lo : Float, hi : Float) -> Float {
  let r : Float = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
fn inside_rect(
  px : Float,
  py : Float,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> Bool {
  px >= Float::from_int(x) &&
  px <= Float::from_int(x + w) &&
  py >= Float::from_int(y) &&
  py <= Float::from_int(y + h)
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
fn node_kind_name(kind : Int) -> String {
  if kind == 0 {
    "PORT"
  } else if kind == 1 {
    "FACTORY"
  } else if kind == 2 {
    "MARKET"
  } else {
    "HUB"
  }
}

///|
fn node_color(kind : Int) -> @raylib.Color {
  if kind == 0 {
    @raylib.Color::new(98, 190, 250, 255)
  } else if kind == 1 {
    @raylib.Color::new(244, 156, 92, 255)
  } else if kind == 2 {
    @raylib.Color::new(132, 234, 150, 255)
  } else {
    @raylib.Color::new(194, 150, 244, 255)
  }
}

///|
fn cargo_color(kind : Int) -> @raylib.Color {
  if kind == 1 {
    @raylib.Color::new(112, 206, 252, 252)
  } else if kind == 2 {
    @raylib.Color::new(246, 210, 112, 252)
  } else {
    @raylib.Color::new(188, 196, 220, 220)
  }
}

///|
fn clear_nodes(nodes : Array[Node]) -> Unit {
  for i = 0; i < nodes.length(); i = i + 1 {
    nodes[i].active = false
    nodes[i].kind = 0
    nodes[i].x = 0.0
    nodes[i].y = 0.0
    nodes[i].r = 0.0
    nodes[i].raw = 0
    nodes[i].goods = 0
    nodes[i].demand = 0
    nodes[i].delivered = 0
    nodes[i].prod_cd = 0.0
    nodes[i].pulse = 0.0
    nodes[i].outage_t = 0.0
    nodes[i].name = ""
  }
}

///|
fn clear_routes(routes : Array[Route]) -> Unit {
  for i = 0; i < routes.length(); i = i + 1 {
    routes[i].active = false
    routes[i].a = -1
    routes[i].b = -1
    routes[i].level = 1
    routes[i].hp = 0.0
    routes[i].spawn_cd = 0.0
    routes[i].blink = 0.0
  }
}

///|
fn clear_trucks(trucks : Array[Truck]) -> Unit {
  for i = 0; i < trucks.length(); i = i + 1 {
    trucks[i].active = false
    trucks[i].route = -1
    trucks[i].t = 0.0
    trucks[i].dir = 1
    trucks[i].speed = 1.0
    trucks[i].cargo_kind = 0
    trucks[i].cargo = 0
    trucks[i].blink = 0.0
    trucks[i].stuck_t = 0.0
  }
}

///|
fn clear_sparks(sp : Array[Spark]) -> Unit {
  for i = 0; i < sp.length(); i = i + 1 {
    sp[i].active = false
    sp[i].x = 0.0
    sp[i].y = 0.0
    sp[i].vx = 0.0
    sp[i].vy = 0.0
    sp[i].life = 0.0
    sp[i].size = 0.0
    sp[i].kind = 0
  }
}

///|
fn add_node(
  nodes : Array[Node],
  kind : Int,
  x : Float,
  y : Float,
  r : Float,
  name : String,
) -> Int {
  for i = 0; i < nodes.length(); i = i + 1 {
    if not(nodes[i].active) {
      nodes[i].active = true
      nodes[i].kind = kind
      nodes[i].x = x
      nodes[i].y = y
      nodes[i].r = r
      nodes[i].raw = 0
      nodes[i].goods = 0
      nodes[i].demand = 0
      nodes[i].delivered = 0
      nodes[i].prod_cd = randf(0.1, 0.8)
      nodes[i].pulse = randf(0.0, 30.0)
      nodes[i].outage_t = 0.0
      nodes[i].name = name
      return i
    }
  }
  -1
}

///|
fn find_route(routes : Array[Route], a : Int, b : Int) -> Int {
  for i = 0; i < routes.length(); i = i + 1 {
    if not(routes[i].active) {
      continue
    }
    let x : Int = routes[i].a
    let y : Int = routes[i].b
    if (x == a && y == b) || (x == b && y == a) {
      return i
    }
  }
  -1
}

///|
fn add_route(routes : Array[Route], a : Int, b : Int) -> Int {
  for i = 0; i < routes.length(); i = i + 1 {
    if not(routes[i].active) {
      routes[i].active = true
      routes[i].a = a
      routes[i].b = b
      routes[i].level = 1
      routes[i].hp = 100.0
      routes[i].spawn_cd = randf(0.22, 0.86)
      routes[i].blink = 0.36
      return i
    }
  }
  -1
}

///|
fn count_active_routes(routes : Array[Route]) -> Int {
  let mut n : Int = 0
  for i = 0; i < routes.length(); i = i + 1 {
    if routes[i].active {
      n = n + 1
    }
  }
  n
}

///|
fn count_active_trucks(trucks : Array[Truck]) -> Int {
  let mut n : Int = 0
  for i = 0; i < trucks.length(); i = i + 1 {
    if trucks[i].active {
      n = n + 1
    }
  }
  n
}

///|
fn add_truck(
  trucks : Array[Truck],
  route_id : Int,
  dir : Int,
  level : Int,
) -> Int {
  for i = 0; i < trucks.length(); i = i + 1 {
    if not(trucks[i].active) {
      trucks[i].active = true
      trucks[i].route = route_id
      trucks[i].dir = if dir >= 0 { 1 } else { -1 }
      trucks[i].t = if trucks[i].dir > 0 { 0.0 } else { 1.0 }
      trucks[i].speed = randf(0.88, 1.18) + Float::from_int(level) * 0.03
      trucks[i].cargo_kind = 0
      trucks[i].cargo = 0
      trucks[i].blink = 0.22
      trucks[i].stuck_t = 0.0
      return i
    }
  }
  -1
}

///|
fn add_spark(sp : Array[Spark], x : Float, y : Float, kind : Int) -> Unit {
  for i = 0; i < sp.length(); i = i + 1 {
    if not(sp[i].active) {
      sp[i].active = true
      sp[i].x = x
      sp[i].y = y
      let a : Float = randf(0.0, 6.28318)
      let s : Float = randf(24.0, 220.0)
      sp[i].vx = @math.cosf(a) * s
      sp[i].vy = @math.sinf(a) * s
      sp[i].life = randf(0.2, 0.9)
      sp[i].size = randf(2.5, 8.0)
      sp[i].kind = kind
      return
    }
  }
}

///|
fn burst_sparks(
  sp : Array[Spark],
  x : Float,
  y : Float,
  n : Int,
  kind : Int,
) -> Unit {
  for _i = 0; _i < n; _i = _i + 1 {
    add_spark(sp, x, y, kind)
  }
}

///|
fn update_sparks(sp : Array[Spark], dt : Float) -> Unit {
  for i = 0; i < sp.length(); i = i + 1 {
    if not(sp[i].active) {
      continue
    }
    sp[i].life = sp[i].life - dt
    if sp[i].life <= 0.0 {
      sp[i].active = false
      continue
    }
    sp[i].x = sp[i].x + sp[i].vx * dt
    sp[i].y = sp[i].y + sp[i].vy * dt
    sp[i].vx = sp[i].vx * (1.0 - dt * 2.3)
    sp[i].vy = sp[i].vy * (1.0 - dt * 2.2) + 20.0 * dt
  }
}

///|
fn draw_sparks(sp : Array[Spark]) -> Unit {
  for i = 0; i < sp.length(); i = i + 1 {
    if not(sp[i].active) {
      continue
    }
    let c = if sp[i].kind == 0 {
      @raylib.Color::new(246, 220, 126, 238)
    } else if sp[i].kind == 1 {
      @raylib.Color::new(126, 214, 250, 238)
    } else if sp[i].kind == 2 {
      @raylib.Color::new(130, 236, 160, 238)
    } else {
      @raylib.Color::new(248, 122, 140, 238)
    }
    @raylib.draw_circle(
      sp[i].x.to_int(),
      sp[i].y.to_int(),
      sp[i].size * sp[i].life * 2.0,
      c,
    )
  }
}

///|
fn point_seg_dist2(
  px : Float,
  py : Float,
  ax : Float,
  ay : Float,
  bx : Float,
  by : Float,
) -> Float {
  let abx : Float = bx - ax
  let aby : Float = by - ay
  let apx : Float = px - ax
  let apy : Float = py - ay
  let mut d2 : Float = abx * abx + aby * aby
  if d2 < 0.00001 {
    d2 = 0.00001
  }
  let mut t : Float = (apx * abx + apy * aby) / d2
  t = clampf(t, 0.0, 1.0)
  let cx : Float = ax + abx * t
  let cy : Float = ay + aby * t
  dist2(px, py, cx, cy)
}

///|
fn pick_node(nodes : Array[Node], mx : Float, my : Float) -> Int {
  for i = 0; i < nodes.length(); i = i + 1 {
    if not(nodes[i].active) {
      continue
    }
    if dist2(mx, my, nodes[i].x, nodes[i].y) <= nodes[i].r * nodes[i].r {
      return i
    }
  }
  -1
}

///|
fn pick_route(
  routes : Array[Route],
  nodes : Array[Node],
  mx : Float,
  my : Float,
) -> Int {
  let mut best : Int = -1
  let mut best_d2 : Float = 99999999.0
  for i = 0; i < routes.length(); i = i + 1 {
    if not(routes[i].active) {
      continue
    }
    let a : Int = routes[i].a
    let b : Int = routes[i].b
    if a < 0 || b < 0 || not(nodes[a].active) || not(nodes[b].active) {
      continue
    }

    let d2 : Float = point_seg_dist2(
      mx,
      my,
      nodes[a].x,
      nodes[a].y,
      nodes[b].x,
      nodes[b].y,
    )
    if d2 < best_d2 {
      best_d2 = d2
      best = i
    }
  }
  if best >= 0 && best_d2 <= 17.0 * 17.0 {
    best
  } else {
    -1
  }
}

///|
fn setup_map(
  nodes : Array[Node],
  routes : Array[Route],
  trucks : Array[Truck],
) -> Unit {
  clear_nodes(nodes)
  clear_routes(routes)
  clear_trucks(trucks)

  ignore(add_node(nodes, 0, 138.0, 156.0, 42.0, "Port Azure"))
  ignore(add_node(nodes, 0, 170.0, 570.0, 42.0, "Port Ember"))
  ignore(add_node(nodes, 1, 408.0, 186.0, 38.0, "Forge North"))
  ignore(add_node(nodes, 1, 442.0, 520.0, 38.0, "Forge South"))
  ignore(add_node(nodes, 1, 642.0, 356.0, 38.0, "Forge Delta"))
  ignore(add_node(nodes, 2, 866.0, 146.0, 40.0, "Market Apex"))
  ignore(add_node(nodes, 2, 872.0, 360.0, 40.0, "Market Nova"))
  ignore(add_node(nodes, 2, 864.0, 578.0, 40.0, "Market Quay"))
  ignore(add_node(nodes, 3, 644.0, 568.0, 34.0, "Relay Hub"))

  if nodes[0].active {
    nodes[0].raw = 24
  }
  if nodes[1].active {
    nodes[1].raw = 28
  }
  if nodes[2].active {
    nodes[2].raw = 6
  }
  if nodes[3].active {
    nodes[3].raw = 6
  }
  if nodes[4].active {
    nodes[4].raw = 5
  }
  if nodes[8].active {
    nodes[8].goods = 4
  }

  if nodes[5].active {
    nodes[5].demand = 38
  }
  if nodes[6].active {
    nodes[6].demand = 34
  }
  if nodes[7].active {
    nodes[7].demand = 42
  }

  ignore(add_route(routes, 0, 2))
  ignore(add_route(routes, 1, 3))
  ignore(add_route(routes, 2, 4))
  ignore(add_route(routes, 3, 8))
  ignore(add_route(routes, 4, 6))
  ignore(add_route(routes, 2, 5))
  ignore(add_route(routes, 8, 7))
}

///|
fn load_from_node_to_target(
  nodes : Array[Node],
  truck : Truck,
  from_idx : Int,
  to_idx : Int,
  capacity : Int,
) -> Unit {
  truck.cargo_kind = 0
  truck.cargo = 0

  if not(nodes[from_idx].active) || not(nodes[to_idx].active) {
    return
  }

  let target_kind : Int = nodes[to_idx].kind
  let source_kind : Int = nodes[from_idx].kind

  if target_kind == 1 {
    let mut amount : Int = nodes[from_idx].raw
    if source_kind == 3 && amount == 0 {
      amount = nodes[from_idx].raw
    }
    if amount > 0 {
      let take : Int = clampi(amount, 0, capacity)
      truck.cargo_kind = 1
      truck.cargo = take
      nodes[from_idx].raw = nodes[from_idx].raw - take
      return
    }
  }

  if target_kind == 2 {
    let mut amount : Int = nodes[from_idx].goods
    if source_kind == 3 && amount == 0 {
      amount = nodes[from_idx].goods
    }
    if amount > 0 {
      let take : Int = clampi(amount, 0, capacity)
      truck.cargo_kind = 2
      truck.cargo = take
      nodes[from_idx].goods = nodes[from_idx].goods - take
      return
    }
  }

  if target_kind == 3 {
    if source_kind == 0 && nodes[from_idx].raw > 0 {
      let take : Int = clampi(nodes[from_idx].raw, 0, capacity)
      truck.cargo_kind = 1
      truck.cargo = take
      nodes[from_idx].raw = nodes[from_idx].raw - take
      return
    }

    if source_kind == 1 && nodes[from_idx].goods > 0 {
      let take : Int = clampi(nodes[from_idx].goods, 0, capacity)
      truck.cargo_kind = 2
      truck.cargo = take
      nodes[from_idx].goods = nodes[from_idx].goods - take
      return
    }
  }

  if target_kind == 0 {
    if source_kind == 1 && nodes[from_idx].raw > 0 {
      let take : Int = clampi(nodes[from_idx].raw, 0, capacity)
      truck.cargo_kind = 1
      truck.cargo = take
      nodes[from_idx].raw = nodes[from_idx].raw - take
      return
    }
  }
}

///|
fn update_nodes(nodes : Array[Node], dt : Float, cycle : Int) -> (Int, Int) {
  let mut delivery_gain : Int = 0
  let mut bonus_cash : Int = 0

  for i = 0; i < nodes.length(); i = i + 1 {
    if not(nodes[i].active) {
      continue
    }

    nodes[i].pulse = nodes[i].pulse + dt
    if nodes[i].pulse > 1000.0 {
      nodes[i].pulse = nodes[i].pulse - 1000.0
    }

    if nodes[i].outage_t > 0.0 {
      nodes[i].outage_t = nodes[i].outage_t - dt
      if nodes[i].outage_t < 0.0 {
        nodes[i].outage_t = 0.0
      }
      continue
    }

    nodes[i].prod_cd = nodes[i].prod_cd - dt

    if nodes[i].kind == 0 {
      if nodes[i].prod_cd <= 0.0 {
        nodes[i].raw = nodes[i].raw + 2 + cycle / 3
        nodes[i].raw = clampi(nodes[i].raw, 0, 120)
        nodes[i].prod_cd = 0.66
      }
    } else if nodes[i].kind == 1 {
      if nodes[i].prod_cd <= 0.0 {
        if nodes[i].raw >= 2 {
          nodes[i].raw = nodes[i].raw - 2
          nodes[i].goods = nodes[i].goods + 1 + cycle / 6
          nodes[i].goods = clampi(nodes[i].goods, 0, 120)
        }
        let cd : Float = 1.04 - Float::from_int(cycle) * 0.02
        nodes[i].prod_cd = maxf(0.55, cd)
      }
    } else if nodes[i].kind == 2 {
      if nodes[i].prod_cd <= 0.0 {
        if nodes[i].goods > 0 && nodes[i].demand > 0 {
          nodes[i].goods = nodes[i].goods - 1
          nodes[i].demand = nodes[i].demand - 1
          nodes[i].delivered = nodes[i].delivered + 1
          delivery_gain = delivery_gain + 1

          if nodes[i].demand <= 0 {
            nodes[i].demand = 22 + @raylib.get_random_value(0, 20) + cycle * 2
            bonus_cash = bonus_cash + 16 + cycle * 2
          }
        }
        nodes[i].prod_cd = 0.54
      }
    } else if nodes[i].prod_cd <= 0.0 {
      if nodes[i].raw > 0 && nodes[i].goods < 120 {
        nodes[i].raw = nodes[i].raw - 1
        nodes[i].goods = nodes[i].goods + 1
      }
      nodes[i].prod_cd = 1.42
    }
  }

  (delivery_gain, bonus_cash)
}

///|
fn update_routes(routes : Array[Route], dt : Float, storm_t : Float) -> Int {
  let mut broken_n : Int = 0

  for i = 0; i < routes.length(); i = i + 1 {
    if not(routes[i].active) {
      continue
    }

    if routes[i].blink > 0.0 {
      routes[i].blink = routes[i].blink - dt
      if routes[i].blink < 0.0 {
        routes[i].blink = 0.0
      }
    }

    if storm_t > 0.0 {
      routes[i].hp = routes[i].hp -
        dt * (1.4 + Float::from_int(routes[i].level) * 0.24)
    }

    if routes[i].hp <= 0.0 {
      routes[i].active = false
      routes[i].hp = 0.0
      broken_n = broken_n + 1
      continue
    }

    let mut mult : Float = 1.0 + Float::from_int(routes[i].level) * 0.16
    if storm_t > 0.0 {
      mult = mult * 0.56
    }

    routes[i].spawn_cd = routes[i].spawn_cd - dt * mult
  }

  broken_n
}

///|
fn update_trucks(
  trucks : Array[Truck],
  routes : Array[Route],
  nodes : Array[Node],
  dt : Float,
  storm_t : Float,
  sparks : Array[Spark],
) -> Unit {
  for i = 0; i < trucks.length(); i = i + 1 {
    if not(trucks[i].active) {
      continue
    }

    let rid : Int = trucks[i].route
    if rid < 0 || rid >= routes.length() || not(routes[rid].active) {
      trucks[i].active = false
      continue
    }

    if trucks[i].blink > 0.0 {
      trucks[i].blink = trucks[i].blink - dt
      if trucks[i].blink < 0.0 {
        trucks[i].blink = 0.0
      }
    }

    if trucks[i].stuck_t > 0.0 {
      trucks[i].stuck_t = trucks[i].stuck_t - dt
      if trucks[i].stuck_t < 0.0 {
        trucks[i].stuck_t = 0.0
      }
      continue
    }

    if storm_t > 0.0 && @raylib.get_random_value(0, 999) < 2 {
      trucks[i].stuck_t = randf(0.4, 0.9)
      continue
    }

    let dirf : Float = Float::from_int(trucks[i].dir)
    let step : Float = (0.13 + Float::from_int(routes[rid].level) * 0.028) *
      trucks[i].speed
    trucks[i].t = trucks[i].t + dt * step * dirf

    if trucks[i].t > 1.0 || trucks[i].t < 0.0 {
      let mut arrive : Int = routes[rid].a
      let mut depart : Int = routes[rid].b
      if trucks[i].t >= 1.0 {
        trucks[i].t = 1.0
        arrive = routes[rid].b
        depart = routes[rid].a
      } else {
        trucks[i].t = 0.0
        arrive = routes[rid].a
        depart = routes[rid].b
      }

      if trucks[i].cargo_kind == 1 && trucks[i].cargo > 0 {
        nodes[arrive].raw = nodes[arrive].raw + trucks[i].cargo
        nodes[arrive].raw = clampi(nodes[arrive].raw, 0, 120)
        burst_sparks(sparks, nodes[arrive].x, nodes[arrive].y, 4, 1)
      } else if trucks[i].cargo_kind == 2 && trucks[i].cargo > 0 {
        nodes[arrive].goods = nodes[arrive].goods + trucks[i].cargo
        nodes[arrive].goods = clampi(nodes[arrive].goods, 0, 120)
        burst_sparks(sparks, nodes[arrive].x, nodes[arrive].y, 4, 0)
      }

      trucks[i].dir = -trucks[i].dir
      trucks[i].cargo = 0
      trucks[i].cargo_kind = 0

      let capacity : Int = 2 + routes[rid].level
      load_from_node_to_target(nodes, trucks[i], arrive, depart, capacity)
      trucks[i].blink = 0.18
    }
  }
}

///|
fn damage_random_route(routes : Array[Route], amount : Float) -> Int {
  for _try_i = 0; _try_i < 48; _try_i = _try_i + 1 {
    let idx : Int = @raylib.get_random_value(0, routes.length() - 1)
    if not(routes[idx].active) {
      continue
    }
    routes[idx].hp = routes[idx].hp - amount
    routes[idx].blink = 0.55
    if routes[idx].hp < 0.0 {
      routes[idx].hp = 0.0
    }
    if routes[idx].hp <= 0.0 {
      routes[idx].active = false
    }
    return idx
  }
  -1
}

///|
fn truck_pos(
  truck : Truck,
  route : Route,
  nodes : Array[Node],
) -> (Float, Float) {
  let ax : Float = nodes[route.a].x
  let ay : Float = nodes[route.a].y
  let bx : Float = nodes[route.b].x
  let by : Float = nodes[route.b].y

  let x : Float = ax + (bx - ax) * truck.t
  let y : Float = ay + (by - ay) * truck.t
  (x, y)
}

///|
fn draw_button(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  label : String,
  enabled : Bool,
  hover : Bool,
) -> Unit {
  let fill = if not(enabled) {
    @raylib.Color::new(72, 78, 92, 208)
  } else if hover {
    @raylib.Color::new(102, 150, 230, 242)
  } else {
    @raylib.Color::new(82, 116, 190, 232)
  }

  @raylib.draw_rectangle(x, y, w, h, fill)
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(220, 232, 252, 246),
  )

  let tw : Int = @raylib.measure_text(label, 25)
  @raylib.draw_text(
    label,
    x + (w - tw) / 2,
    y + h / 2 - 12,
    25,
    @raylib.Color::new(246, 250, 255, 252),
  )
}

///|
fn draw_world_bg(t : Float) -> Unit {
  @raylib.draw_rectangle_gradient_v(
    world_l.to_int(),
    world_t.to_int(),
    (world_r - world_l).to_int(),
    (world_b - world_t).to_int(),
    @raylib.Color::new(16, 34, 62, 255),
    @raylib.Color::new(12, 24, 46, 255),
  )

  for i = 0; i < 22; i = i + 1 {
    let fi : Float = Float::from_int(i)
    let x : Float = world_l +
      (fi * 86.0 + t * (22.0 + Float::from_int(i % 5) * 6.0)) %
      (world_r - world_l)
    let y : Float = world_t +
      24.0 +
      Float::from_int(i % 8) * 84.0 +
      @math.sinf(t * 0.7 + fi * 0.4) * 8.0
    @raylib.draw_circle(
      x.to_int(),
      y.to_int(),
      2.0 + Float::from_int(i % 3),
      @raylib.Color::new(118, 168, 236, 122),
    )
  }

  for i = 0; i < 12; i = i + 1 {
    let fi : Float = Float::from_int(i)
    let x0 : Float = world_l +
      (fi * 140.0 - t * (26.0 + Float::from_int(i % 4) * 8.0)) %
      (world_r - world_l)
    let y : Float = world_b - 128.0 + Float::from_int(i % 4) * 20.0
    @raylib.draw_rectangle(
      (x0 - 90.0).to_int(),
      y.to_int(),
      190,
      16,
      @raylib.Color::new(40, 72, 124, 88),
    )
  }
}

///|
fn draw_routes(
  routes : Array[Route],
  nodes : Array[Node],
  selected_route : Int,
  storm_t : Float,
) -> Unit {
  for i = 0; i < routes.length(); i = i + 1 {
    if not(routes[i].active) {
      continue
    }
    let a : Int = routes[i].a
    let b : Int = routes[i].b
    if a < 0 || b < 0 || not(nodes[a].active) || not(nodes[b].active) {
      continue
    }

    let hp01 : Float = clampf(routes[i].hp / 100.0, 0.0, 1.0)
    let mut col = if hp01 > 0.7 {
      @raylib.Color::new(116, 228, 176, 214)
    } else if hp01 > 0.35 {
      @raylib.Color::new(246, 212, 118, 220)
    } else {
      @raylib.Color::new(242, 122, 130, 230)
    }

    if storm_t > 0.0 {
      if @raylib.get_random_value(0, 99) < 28 {
        col = @raylib.Color::new(252, 248, 192, 240)
      }
    }

    let thick : Float = if selected_route == i {
      7.0
    } else {
      3.0 + Float::from_int(routes[i].level)
    }

    @raylib.draw_line_ex(
      @raylib.Vector2::new(nodes[a].x, nodes[a].y),
      @raylib.Vector2::new(nodes[b].x, nodes[b].y),
      thick,
      col,
    )

    if routes[i].blink > 0.0 {
      let alpha : Int = (routes[i].blink * 420.0).to_int()
      @raylib.draw_line_ex(
        @raylib.Vector2::new(nodes[a].x, nodes[a].y),
        @raylib.Vector2::new(nodes[b].x, nodes[b].y),
        thick + 5.0,
        @raylib.Color::new(255, 248, 188, clampi(alpha, 0, 255)),
      )
    }

    let mx : Float = (nodes[a].x + nodes[b].x) * 0.5
    let my : Float = (nodes[a].y + nodes[b].y) * 0.5
    let hp_txt : Int = routes[i].hp.to_int()
    @raylib.draw_text(
      "L\{routes[i].level} \{hp_txt}%",
      (mx - 42.0).to_int(),
      (my - 14.0).to_int(),
      18,
      @raylib.Color::new(236, 244, 255, 236),
    )
  }
}

///|
fn draw_nodes(nodes : Array[Node], selected_node : Int) -> Unit {
  for i = 0; i < nodes.length(); i = i + 1 {
    if not(nodes[i].active) {
      continue
    }

    let base = node_color(nodes[i].kind)
    let pulse : Float = @math.sinf(nodes[i].pulse * 2.0) * 0.5 + 0.5

    @raylib.draw_circle(
      nodes[i].x.to_int(),
      nodes[i].y.to_int(),
      nodes[i].r + 10.0 + pulse * 4.0,
      @raylib.Color::new(24, 40, 70, 120),
    )
    @raylib.draw_circle(
      nodes[i].x.to_int(),
      nodes[i].y.to_int(),
      nodes[i].r,
      base,
    )
    @raylib.draw_circle_lines(
      nodes[i].x.to_int(),
      nodes[i].y.to_int(),
      nodes[i].r + 2.0,
      @raylib.Color::new(236, 244, 255, 228),
    )

    if selected_node == i {
      @raylib.draw_circle_lines(
        nodes[i].x.to_int(),
        nodes[i].y.to_int(),
        nodes[i].r + 10.0,
        @raylib.Color::new(252, 238, 142, 252),
      )
    }

    if nodes[i].kind == 0 {
      @raylib.draw_rectangle(
        (nodes[i].x - 14.0).to_int(),
        (nodes[i].y - 10.0).to_int(),
        28,
        20,
        @raylib.Color::new(16, 30, 46, 230),
      )
      @raylib.draw_line(
        (nodes[i].x - 8.0).to_int(),
        (nodes[i].y - 16.0).to_int(),
        (nodes[i].x - 8.0).to_int(),
        (nodes[i].y + 16.0).to_int(),
        @raylib.white,
      )
      @raylib.draw_line(
        (nodes[i].x + 8.0).to_int(),
        (nodes[i].y - 16.0).to_int(),
        (nodes[i].x + 8.0).to_int(),
        (nodes[i].y + 16.0).to_int(),
        @raylib.white,
      )
    } else if nodes[i].kind == 1 {
      @raylib.draw_rectangle(
        (nodes[i].x - 16.0).to_int(),
        (nodes[i].y - 16.0).to_int(),
        32,
        32,
        @raylib.Color::new(24, 32, 44, 220),
      )
      @raylib.draw_circle(
        nodes[i].x.to_int(),
        nodes[i].y.to_int(),
        8.0,
        @raylib.Color::new(246, 234, 170, 248),
      )
    } else if nodes[i].kind == 2 {
      @raylib.draw_triangle(
        @raylib.Vector2::new(nodes[i].x, nodes[i].y - 16.0),
        @raylib.Vector2::new(nodes[i].x - 15.0, nodes[i].y + 16.0),
        @raylib.Vector2::new(nodes[i].x + 15.0, nodes[i].y + 16.0),
        @raylib.Color::new(24, 36, 36, 220),
      )
    } else {
      @raylib.draw_rectangle(
        (nodes[i].x - 12.0).to_int(),
        (nodes[i].y - 12.0).to_int(),
        24,
        24,
        @raylib.Color::new(40, 26, 56, 220),
      )
      @raylib.draw_circle(
        nodes[i].x.to_int(),
        nodes[i].y.to_int(),
        4.0,
        @raylib.Color::new(242, 236, 255, 248),
      )
    }

    @raylib.draw_text(
      nodes[i].name,
      (nodes[i].x - 72.0).to_int(),
      (nodes[i].y - nodes[i].r - 28.0).to_int(),
      18,
      @raylib.Color::new(236, 242, 255, 248),
    )
    @raylib.draw_text(
      node_kind_name(nodes[i].kind),
      (nodes[i].x - 42.0).to_int(),
      (nodes[i].y - 8.0).to_int(),
      16,
      @raylib.Color::new(14, 20, 30, 250),
    )

    if nodes[i].kind == 2 {
      @raylib.draw_text(
        "G\{nodes[i].goods} D\{nodes[i].demand}",
        (nodes[i].x - 56.0).to_int(),
        (nodes[i].y + nodes[i].r + 8.0).to_int(),
        18,
        @raylib.Color::new(226, 240, 246, 246),
      )
    } else {
      @raylib.draw_text(
        "R\{nodes[i].raw} G\{nodes[i].goods}",
        (nodes[i].x - 56.0).to_int(),
        (nodes[i].y + nodes[i].r + 8.0).to_int(),
        18,
        @raylib.Color::new(226, 240, 246, 246),
      )
    }

    if nodes[i].outage_t > 0.0 {
      @raylib.draw_rectangle(
        (nodes[i].x - 44.0).to_int(),
        (nodes[i].y + 30.0).to_int(),
        88,
        24,
        @raylib.Color::new(138, 28, 44, 224),
      )
      @raylib.draw_text(
        "OUTAGE",
        (nodes[i].x - 38.0).to_int(),
        (nodes[i].y + 34.0).to_int(),
        18,
        @raylib.Color::new(252, 238, 238, 252),
      )
    }
  }
}

///|
fn draw_trucks(
  trucks : Array[Truck],
  routes : Array[Route],
  nodes : Array[Node],
) -> Unit {
  for i = 0; i < trucks.length(); i = i + 1 {
    if not(trucks[i].active) {
      continue
    }

    let rid : Int = trucks[i].route
    if rid < 0 || rid >= routes.length() || not(routes[rid].active) {
      continue
    }

    let (x, y) = truck_pos(trucks[i], routes[rid], nodes)
    let body = if trucks[i].stuck_t > 0.0 {
      @raylib.Color::new(146, 150, 166, 246)
    } else {
      @raylib.Color::new(236, 244, 254, 250)
    }

    @raylib.draw_rectangle((x - 8.0).to_int(), (y - 6.0).to_int(), 16, 12, body)
    @raylib.draw_rectangle_lines(
      (x - 8.0).to_int(),
      (y - 6.0).to_int(),
      16,
      12,
      @raylib.Color::new(18, 28, 46, 250),
    )

    let ccol = cargo_color(trucks[i].cargo_kind)
    if trucks[i].cargo > 0 {
      @raylib.draw_circle(
        (x + 10.0).to_int(),
        y.to_int(),
        4.0 + Float::from_int(trucks[i].cargo),
        ccol,
      )
    }

    if trucks[i].blink > 0.0 {
      @raylib.draw_circle(
        x.to_int(),
        y.to_int(),
        12.0 * trucks[i].blink + 4.0,
        @raylib.Color::new(248, 244, 190, 228),
      )
    }
  }
}

///|
fn draw_ui_panel(
  timer : Float,
  budget : Int,
  delivered : Int,
  goal : Int,
  cycle : Int,
  route_n : Int,
  truck_n : Int,
  storm_t : Float,
  storm_cd : Float,
  selected_route : Int,
  routes : Array[Route],
) -> Unit {
  @raylib.draw_rectangle(968, 22, 376, 724, @raylib.Color::new(18, 22, 34, 242))
  @raylib.draw_rectangle_lines(
    968,
    22,
    376,
    724,
    @raylib.Color::new(168, 188, 228, 244),
  )

  @raylib.draw_text(
    "PORT LOGISTICS EMPIRE",
    984,
    44,
    34,
    @raylib.Color::new(242, 248, 255, 255),
  )
  @raylib.draw_text(
    "Build routes. Move cargo. Beat the contract clock.",
    984,
    86,
    19,
    @raylib.Color::new(192, 214, 252, 238),
  )

  @raylib.draw_text(
    "Timer",
    984,
    132,
    24,
    @raylib.Color::new(226, 236, 252, 246),
  )
  @raylib.draw_text(
    "\{timer.to_int()}s",
    1126,
    132,
    30,
    @raylib.Color::new(248, 238, 150, 252),
  )

  @raylib.draw_text(
    "Budget",
    984,
    170,
    24,
    @raylib.Color::new(226, 236, 252, 246),
  )
  @raylib.draw_text(
    "$\{budget}",
    1126,
    170,
    30,
    @raylib.Color::new(138, 234, 156, 252),
  )

  @raylib.draw_text(
    "Delivered",
    984,
    208,
    24,
    @raylib.Color::new(226, 236, 252, 246),
  )
  @raylib.draw_text(
    "\{delivered}/\{goal}",
    1126,
    208,
    30,
    @raylib.Color::new(132, 214, 248, 252),
  )

  @raylib.draw_text(
    "Load Tier",
    984,
    246,
    24,
    @raylib.Color::new(226, 236, 252, 246),
  )
  @raylib.draw_text(
    "\{cycle}",
    1126,
    246,
    30,
    @raylib.Color::new(250, 210, 132, 252),
  )

  @raylib.draw_text(
    "Routes \{route_n}",
    984,
    286,
    24,
    @raylib.Color::new(208, 224, 252, 246),
  )
  @raylib.draw_text(
    "Trucks \{truck_n}",
    1148,
    286,
    24,
    @raylib.Color::new(208, 224, 252, 246),
  )

  let storm01 : Float = if storm_t > 0.0 {
    clampf(storm_t / 9.0, 0.0, 1.0)
  } else {
    0.0
  }
  let swid : Int = (Float::from_int(326) * storm01).to_int()
  @raylib.draw_rectangle(984, 328, 326, 20, @raylib.Color::new(26, 32, 46, 255))
  @raylib.draw_rectangle(
    984,
    328,
    swid,
    20,
    @raylib.Color::new(242, 124, 136, 250),
  )
  @raylib.draw_rectangle_lines(
    984,
    328,
    326,
    20,
    @raylib.Color::new(184, 198, 232, 248),
  )

  if storm_t > 0.0 {
    @raylib.draw_text(
      "STORM ACTIVE",
      984,
      354,
      26,
      @raylib.Color::new(252, 176, 186, 252),
    )
  } else {
    @raylib.draw_text(
      "Storm ETA \{storm_cd.to_int()}s",
      984,
      354,
      24,
      @raylib.Color::new(206, 220, 246, 244),
    )
  }

  if selected_route >= 0 &&
    selected_route < routes.length() &&
    routes[selected_route].active {
    @raylib.draw_rectangle(
      984,
      392,
      326,
      84,
      @raylib.Color::new(28, 38, 62, 236),
    )
    @raylib.draw_rectangle_lines(
      984,
      392,
      326,
      84,
      @raylib.Color::new(178, 204, 248, 242),
    )
    let hp_txt : Int = routes[selected_route].hp.to_int()
    @raylib.draw_text(
      "Selected Route #\{selected_route}",
      998,
      404,
      22,
      @raylib.Color::new(232, 242, 255, 252),
    )
    @raylib.draw_text(
      "Level \{routes[selected_route].level}",
      998,
      432,
      22,
      @raylib.Color::new(248, 234, 152, 252),
    )
    @raylib.draw_text(
      "Integrity \{hp_txt}%",
      1148,
      432,
      22,
      @raylib.Color::new(156, 228, 170, 252),
    )
  } else {
    @raylib.draw_rectangle(
      984,
      392,
      326,
      84,
      @raylib.Color::new(28, 34, 48, 220),
    )
    @raylib.draw_rectangle_lines(
      984,
      392,
      326,
      84,
      @raylib.Color::new(156, 178, 216, 236),
    )
    @raylib.draw_text(
      "Selected Route: none",
      998,
      420,
      24,
      @raylib.Color::new(214, 228, 252, 238),
    )
  }

  @raylib.draw_text(
    "How to play",
    984,
    672,
    26,
    @raylib.Color::new(230, 238, 252, 250),
  )
  @raylib.draw_text(
    "1) Tap node A then node B to build line",
    984,
    704,
    19,
    @raylib.Color::new(194, 216, 252, 236),
  )
  @raylib.draw_text(
    "2) Tap route to select, then upgrade",
    984,
    726,
    19,
    @raylib.Color::new(194, 216, 252, 236),
  )
}

///|
fn route_build_cost(route_n : Int) -> Int {
  34 + route_n * 2
}

///|
fn route_upgrade_cost(level : Int) -> Int {
  42 + level * 34
}

///|
fn main {
  @raylib.init_window(sw, sh, "raylib [game] port logistics empire 2026")
  @raylib.set_target_fps(60)

  let nodes : Array[Node] = Array::makei(max_nodes, fn(_i) {
    {
      active: false,
      kind: 0,
      x: 0.0,
      y: 0.0,
      r: 0.0,
      raw: 0,
      goods: 0,
      demand: 0,
      delivered: 0,
      prod_cd: 0.0,
      pulse: 0.0,
      outage_t: 0.0,
      name: "",
    }
  })

  let routes : Array[Route] = Array::makei(max_routes, fn(_i) {
    {
      active: false,
      a: -1,
      b: -1,
      level: 1,
      hp: 0.0,
      spawn_cd: 0.0,
      blink: 0.0,
    }
  })

  let trucks : Array[Truck] = Array::makei(max_trucks, fn(_i) {
    {
      active: false,
      route: -1,
      t: 0.0,
      dir: 1,
      speed: 1.0,
      cargo_kind: 0,
      cargo: 0,
      blink: 0.0,
      stuck_t: 0.0,
    }
  })

  let sparks : Array[Spark] = Array::makei(max_sparks, fn(_i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      life: 0.0,
      size: 0.0,
      kind: 0,
    }
  })

  let mut state : Int = 0 // 0 menu 1 play 2 win 3 lose

  let mut timer : Float = 260.0
  let mut budget : Int = 118
  let mut delivered_total : Int = 0
  let mut goal : Int = 260
  let mut cycle : Int = 1

  let mut selected_node : Int = -1
  let mut selected_route : Int = -1

  let mut storm_cd : Float = 18.0
  let mut storm_t : Float = 0.0
  let mut maint_cd : Float = 1.6

  let mut msg : String = ""
  let mut msg_t : Float = 0.0
  let mut bg_t : Float = 0.0

  fn reset_run() -> Unit {
    setup_map(nodes, routes, trucks)
    clear_sparks(sparks)

    timer = 260.0
    budget = 118
    delivered_total = 0
    goal = 260
    cycle = 1

    selected_node = -1
    selected_route = -1

    storm_cd = 18.0
    storm_t = 0.0
    maint_cd = 1.6

    msg = "Route network online"
    msg_t = 2.4
  }

  reset_run()

  while not(@raylib.window_should_close()) {
    let mut dt : Float = @raylib.get_frame_time()
    if dt > 0.033 {
      dt = 0.033
    }

    if @raylib.is_key_pressed(@raylib.KeyF11) {
      @raylib.toggle_fullscreen()
    }

    if msg_t > 0.0 {
      msg_t = msg_t - dt
      if msg_t < 0.0 {
        msg_t = 0.0
      }
    }

    bg_t = bg_t + dt * 1.7
    while bg_t > 100000.0 {
      bg_t = bg_t - 100000.0
    }

    let mouse = @raylib.get_mouse_position()
    let click : Bool = @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft)

    update_sparks(sparks, dt)

    if state == 0 {
      if click || @raylib.is_key_pressed(@raylib.KeyEnter) {
        reset_run()
        state = 1
      }
    } else if state == 1 {
      timer = timer - dt
      if timer < 0.0 {
        timer = 0.0
      }

      cycle = 1 + delivered_total / 48
      if cycle > 8 {
        cycle = 8
      }

      let (gain, bonus_cash) = update_nodes(nodes, dt, cycle)
      if gain > 0 {
        delivered_total = delivered_total + gain
        budget = budget + gain * 2
      }
      if bonus_cash > 0 {
        budget = budget + bonus_cash
        msg = "Major contract completed +$\{bonus_cash}"
        msg_t = 1.4
        burst_sparks(sparks, 866.0, 360.0, 12, 2)
      }

      let broken_n : Int = update_routes(routes, dt, storm_t)
      if broken_n > 0 {
        msg = "\{broken_n} route(s) collapsed"
        msg_t = 1.5
      }

      for i = 0; i < routes.length(); i = i + 1 {
        if not(routes[i].active) {
          continue
        }
        if routes[i].spawn_cd <= 0.0 {
          let dir : Int = if @raylib.get_random_value(0, 1) == 0 {
            -1
          } else {
            1
          }
          let tid : Int = add_truck(trucks, i, dir, routes[i].level)
          if tid >= 0 {
            let from_idx : Int = if trucks[tid].dir > 0 {
              routes[i].a
            } else {
              routes[i].b
            }
            let to_idx : Int = if trucks[tid].dir > 0 {
              routes[i].b
            } else {
              routes[i].a
            }
            let cap : Int = 2 + routes[i].level
            load_from_node_to_target(nodes, trucks[tid], from_idx, to_idx, cap)
          }
          let mut next_cd : Float = 2.9 -
            Float::from_int(routes[i].level) * 0.36 +
            randf(0.0, 0.55)
          next_cd = maxf(0.62, next_cd)
          routes[i].spawn_cd = next_cd
        }
      }

      update_trucks(trucks, routes, nodes, dt, storm_t, sparks)

      storm_cd = storm_cd - dt
      if storm_t > 0.0 {
        storm_t = storm_t - dt
        if storm_t < 0.0 {
          storm_t = 0.0
          msg = "Storm front cleared"
          msg_t = 1.0
        }
      }

      if storm_cd <= 0.0 {
        storm_t = randf(5.4, 8.8)
        let mut next : Float = randf(15.0, 26.0) - Float::from_int(cycle) * 0.45
        if next < 8.5 {
          next = 8.5
        }
        storm_cd = next

        let strike_n : Int = 1 + @raylib.get_random_value(0, 2)
        for _i = 0; _i < strike_n; _i = _i + 1 {
          let damaged : Int = damage_random_route(routes, randf(20.0, 36.0))
          if damaged >= 0 {
            let a : Int = routes[damaged].a
            let b : Int = routes[damaged].b
            if a >= 0 && b >= 0 && nodes[a].active && nodes[b].active {
              burst_sparks(
                sparks,
                (nodes[a].x + nodes[b].x) * 0.5,
                (nodes[a].y + nodes[b].y) * 0.5,
                10,
                3,
              )
            }
          }
        }

        for i = 0; i < nodes.length(); i = i + 1 {
          if not(nodes[i].active) || nodes[i].kind == 0 {
            continue
          }
          if @raylib.get_random_value(0, 99) < 15 {
            nodes[i].outage_t = randf(1.0, 2.6)
            burst_sparks(sparks, nodes[i].x, nodes[i].y, 8, 3)
          }
        }

        msg = "Severe storm damaged your network"
        msg_t = 1.6
      }

      maint_cd = maint_cd - dt
      if maint_cd <= 0.0 {
        let upkeep : Int = count_active_routes(routes)
        budget = budget - upkeep
        maint_cd = 1.8
      }

      if click || @raylib.is_key_pressed(@raylib.KeyEscape) {
        if @raylib.is_key_pressed(@raylib.KeyEscape) {
          selected_node = -1
          selected_route = -1
        }

        let route_n : Int = count_active_routes(routes)
        let build_cost : Int = route_build_cost(route_n)

        let upgrade_cost : Int = if selected_route >= 0 &&
          selected_route < routes.length() {
          route_upgrade_cost(routes[selected_route].level)
        } else {
          route_upgrade_cost(1)
        }

        let upgrade_hover : Bool = inside_rect(
          mouse.x,
          mouse.y,
          984,
          492,
          326,
          64,
        )
        let repair_hover : Bool = inside_rect(
          mouse.x,
          mouse.y,
          984,
          570,
          326,
          64,
        )
        let surge_hover : Bool = inside_rect(
          mouse.x,
          mouse.y,
          984,
          648,
          326,
          64,
        )

        let trigger_upgrade : Bool = @raylib.is_key_pressed(@raylib.KeyU) ||
          (click && upgrade_hover)
        if trigger_upgrade {
          if selected_route >= 0 &&
            selected_route < routes.length() &&
            routes[selected_route].active {
            if routes[selected_route].level < 5 {
              if budget >= upgrade_cost {
                budget = budget - upgrade_cost
                routes[selected_route].level = routes[selected_route].level + 1
                routes[selected_route].hp = minf(
                  100.0,
                  routes[selected_route].hp + 24.0,
                )
                routes[selected_route].blink = 0.5

                let a = routes[selected_route].a
                let b = routes[selected_route].b
                burst_sparks(
                  sparks,
                  (nodes[a].x + nodes[b].x) * 0.5,
                  (nodes[a].y + nodes[b].y) * 0.5,
                  12,
                  0,
                )

                msg = "Route upgraded to level \{routes[selected_route].level}"
                msg_t = 1.2
              } else {
                msg = "Need $\{upgrade_cost} to upgrade"
                msg_t = 1.0
              }
            } else {
              msg = "Route is already max level"
              msg_t = 1.0
            }
          } else {
            msg = "Select a route first"
            msg_t = 1.0
          }
        }

        let repair_cost : Int = 40
        let trigger_repair : Bool = @raylib.is_key_pressed(@raylib.KeyF) ||
          (click && repair_hover)
        if trigger_repair {
          if budget >= repair_cost {
            let mut repaired : Int = 0
            for i = 0; i < routes.length(); i = i + 1 {
              if not(routes[i].active) {
                continue
              }
              if routes[i].hp < 100.0 {
                routes[i].hp = 100.0
                routes[i].blink = 0.25
                repaired = repaired + 1
              }
            }
            budget = budget - repair_cost
            msg = "Repaired \{repaired} route(s)"
            msg_t = 1.0
          } else {
            msg = "Need $\{repair_cost} to repair"
            msg_t = 1.0
          }
        }

        let surge_cost : Int = 44
        let trigger_surge : Bool = @raylib.is_key_pressed(@raylib.KeyB) ||
          (click && surge_hover)
        if trigger_surge {
          if budget >= surge_cost {
            budget = budget - surge_cost
            for i = 0; i < nodes.length(); i = i + 1 {
              if not(nodes[i].active) {
                continue
              }
              if nodes[i].kind == 0 {
                nodes[i].raw = clampi(nodes[i].raw + 8, 0, 120)
              } else if nodes[i].kind == 1 {
                nodes[i].goods = clampi(nodes[i].goods + 4, 0, 120)
              } else if nodes[i].kind == 2 {
                let nd : Int = nodes[i].demand - 3
                nodes[i].demand = if nd < 0 { 0 } else { nd }
              }
              burst_sparks(sparks, nodes[i].x, nodes[i].y, 4, 1)
            }
            for i = 0; i < routes.length(); i = i + 1 {
              if routes[i].active {
                routes[i].spawn_cd = routes[i].spawn_cd - 0.7
                if routes[i].spawn_cd < 0.0 {
                  routes[i].spawn_cd = 0.0
                }
              }
            }
            msg = "Logistics surge activated"
            msg_t = 1.1
          } else {
            msg = "Need $\{surge_cost} for surge"
            msg_t = 1.0
          }
        }

        if click && not(upgrade_hover) && not(repair_hover) && not(surge_hover) {
          let n : Int = pick_node(nodes, mouse.x, mouse.y)
          if n >= 0 {
            if selected_node < 0 {
              selected_node = n
              selected_route = -1
              msg = "Selected \{nodes[n].name}"
              msg_t = 0.8
            } else if selected_node == n {
              selected_node = -1
              msg = "Node selection cleared"
              msg_t = 0.6
            } else {
              let existing : Int = find_route(routes, selected_node, n)
              if existing >= 0 {
                selected_route = existing
                selected_node = -1
                msg = "Route already exists (#\{existing})"
                msg_t = 0.9
              } else if budget >= build_cost {
                let idx : Int = add_route(routes, selected_node, n)
                if idx >= 0 {
                  budget = budget - build_cost
                  selected_route = idx
                  selected_node = -1
                  burst_sparks(
                    sparks,
                    (nodes[routes[idx].a].x + nodes[routes[idx].b].x) * 0.5,
                    (nodes[routes[idx].a].y + nodes[routes[idx].b].y) * 0.5,
                    16,
                    1,
                  )
                  msg = "Route #\{idx} built for $\{build_cost}"
                  msg_t = 1.3
                } else {
                  msg = "Route slots are full"
                  msg_t = 1.0
                }
              } else {
                msg = "Need $\{build_cost} to build route"
                msg_t = 1.0
              }
            }
          } else {
            let rid : Int = pick_route(routes, nodes, mouse.x, mouse.y)
            if rid >= 0 {
              selected_route = rid
              selected_node = -1
              msg = "Selected route #\{rid}"
              msg_t = 0.8
            } else {
              selected_node = -1
              selected_route = -1
            }
          }
        }
      }

      if delivered_total >= goal {
        state = 2
        msg = "Global contract completed"
        msg_t = 3.2
        burst_sparks(sparks, 684.0, 328.0, 48, 2)
      } else if timer <= 0.0 {
        state = 3
        msg = "Time over"
        msg_t = 3.2
      } else if budget < -120 {
        state = 3
        msg = "Company bankrupt"
        msg_t = 3.2
      }
    } else if state == 2 {
      if click || @raylib.is_key_pressed(@raylib.KeyEnter) {
        state = 0
      }
    } else if click ||
      @raylib.is_key_pressed(@raylib.KeyEnter) ||
      @raylib.is_key_pressed(@raylib.KeyR) {
      state = 0
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(8, 12, 20, 255))

    draw_world_bg(bg_t)
    draw_routes(routes, nodes, selected_route, storm_t)
    draw_trucks(trucks, routes, nodes)
    draw_nodes(nodes, selected_node)
    draw_sparks(sparks)

    let route_n : Int = count_active_routes(routes)
    let truck_n : Int = count_active_trucks(trucks)
    draw_ui_panel(
      timer, budget, delivered_total, goal, cycle, route_n, truck_n, storm_t, storm_cd,
      selected_route, routes,
    )

    let build_cost : Int = route_build_cost(route_n)
    let upgrade_cost : Int = if selected_route >= 0 &&
      selected_route < routes.length() {
      route_upgrade_cost(routes[selected_route].level)
    } else {
      route_upgrade_cost(1)
    }

    draw_button(
      984,
      492,
      326,
      64,
      "UPGRADE ROUTE [U] ($\{upgrade_cost})",
      selected_route >= 0 &&
      selected_route < routes.length() &&
      routes[selected_route].active &&
      budget >= upgrade_cost,
      inside_rect(mouse.x, mouse.y, 984, 492, 326, 64),
    )

    draw_button(
      984,
      570,
      326,
      64,
      "REPAIR ALL [F] ($40)",
      budget >= 40,
      inside_rect(mouse.x, mouse.y, 984, 570, 326, 64),
    )

    draw_button(
      984,
      648,
      326,
      64,
      "LOGISTICS SURGE [B] ($44)",
      budget >= 44,
      inside_rect(mouse.x, mouse.y, 984, 648, 326, 64),
    )

    @raylib.draw_text(
      "Build new route cost: $\{build_cost}",
      36,
      704,
      24,
      @raylib.Color::new(228, 238, 252, 246),
    )
    @raylib.draw_text(
      "Tap node A then node B to connect",
      36,
      730,
      22,
      @raylib.Color::new(196, 218, 252, 236),
    )

    if msg_t > 0.0 {
      let bw : Int = @raylib.measure_text(msg, 30) + 44
      let bx : Int = sw / 2 - bw / 2
      @raylib.draw_rectangle(
        bx,
        16,
        bw,
        52,
        @raylib.Color::new(12, 16, 24, 222),
      )
      @raylib.draw_rectangle_lines(
        bx,
        16,
        bw,
        52,
        @raylib.Color::new(188, 214, 252, 246),
      )
      @raylib.draw_text(
        msg,
        bx + 22,
        28,
        30,
        @raylib.Color::new(236, 244, 255, 252),
      )
    }

    if state == 0 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(8, 12, 20, 204))
      @raylib.draw_text(
        "PORT LOGISTICS EMPIRE",
        sw / 2 - 318,
        138,
        70,
        @raylib.Color::new(234, 244, 255, 255),
      )
      @raylib.draw_text(
        "Real-time shipping strategy",
        sw / 2 - 184,
        226,
        36,
        @raylib.Color::new(194, 218, 252, 252),
      )

      @raylib.draw_rectangle(
        sw / 2 - 450,
        296,
        900,
        252,
        @raylib.Color::new(18, 28, 44, 236),
      )
      @raylib.draw_rectangle_lines(
        sw / 2 - 450,
        296,
        900,
        252,
        @raylib.Color::new(164, 196, 244, 246),
      )

      @raylib.draw_text(
        "Desktop",
        sw / 2 - 420,
        326,
        30,
        @raylib.Color::new(242, 246, 255, 252),
      )
      @raylib.draw_text(
        "- Click node A then node B to build route",
        sw / 2 - 420,
        362,
        26,
        @raylib.Color::new(208, 226, 252, 248),
      )
      @raylib.draw_text(
        "- U/F/B for upgrade, repair, surge",
        sw / 2 - 420,
        396,
        26,
        @raylib.Color::new(208, 226, 252, 248),
      )
      @raylib.draw_text(
        "- Keep network healthy through storms",
        sw / 2 - 420,
        430,
        26,
        @raylib.Color::new(208, 226, 252, 248),
      )

      @raylib.draw_text(
        "Mobile",
        sw / 2 + 74,
        326,
        30,
        @raylib.Color::new(242, 246, 255, 252),
      )
      @raylib.draw_text(
        "- Tap nodes and routes",
        sw / 2 + 74,
        362,
        26,
        @raylib.Color::new(208, 226, 252, 248),
      )
      @raylib.draw_text(
        "- Tap right-panel buttons",
        sw / 2 + 74,
        396,
        26,
        @raylib.Color::new(208, 226, 252, 248),
      )
      @raylib.draw_text(
        "- No keyboard required",
        sw / 2 + 74,
        430,
        26,
        @raylib.Color::new(208, 226, 252, 248),
      )

      draw_button(
        sw / 2 - 176,
        592,
        352,
        88,
        "START RUN",
        true,
        inside_rect(mouse.x, mouse.y, sw / 2 - 176, 592, 352, 88),
      )
    } else if state == 2 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(8, 16, 10, 188))
      @raylib.draw_text(
        "CONTRACT COMPLETE",
        sw / 2 - 308,
        196,
        80,
        @raylib.Color::new(156, 244, 174, 252),
      )
      @raylib.draw_text(
        "Delivered \{delivered_total} cargo units",
        sw / 2 - 206,
        314,
        38,
        @raylib.Color::new(232, 246, 234, 252),
      )
      @raylib.draw_text(
        "Final budget $\{budget}",
        sw / 2 - 132,
        360,
        34,
        @raylib.Color::new(244, 228, 152, 252),
      )
      @raylib.draw_text(
        "Tap or Enter to return",
        sw / 2 - 166,
        446,
        32,
        @raylib.Color::new(214, 232, 252, 246),
      )
    } else if state == 3 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(24, 8, 12, 200))
      @raylib.draw_text(
        "OPERATION FAILED",
        sw / 2 - 266,
        194,
        80,
        @raylib.Color::new(250, 154, 170, 252),
      )
      @raylib.draw_text(
        "Delivered \{delivered_total}/\{goal}",
        sw / 2 - 174,
        322,
        38,
        @raylib.Color::new(242, 232, 236, 250),
      )
      @raylib.draw_text(
        "Budget $\{budget}",
        sw / 2 - 94,
        366,
        34,
        @raylib.Color::new(244, 226, 160, 248),
      )
      @raylib.draw_text(
        "Tap or Enter to retry",
        sw / 2 - 150,
        446,
        32,
        @raylib.Color::new(214, 232, 252, 246),
      )
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
