///|
struct Chef {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut heading : Float
  mut stamina : Float
  stamina_max : Float
  mut heat_resist : Float
  mut action_cd : Float
  mut boost_t : Float
  mut step_t : Float
}

///|
struct Station {
  x : Float
  y : Float
  w : Float
  h : Float
  kind : Int
}

///|
struct Order {
  mut active : Bool
  mut id : Int
  mut kind : Int
  mut deadline : Float
  mut max_deadline : Float
  mut reward : Int
  mut pulse : Float
  mut mood : Float
}

///|
struct StoveSlot {
  mut active : Bool
  mut kind : Int
  mut progress : Float
  mut need : Float
  mut quality : Float
  mut pulse : Float
}

///|
struct SupplyBox {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut kind : Int
  mut amount : Int
  mut life : Float
  mut pulse : Float
}

///|
struct Particle {
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
fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
fn sinf(v : Float) -> Float {
  Float::from_double(@math.sin(v.to_double()))
}

///|
fn randf(lo : Float, hi : Float) -> Float {
  let r : Float = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
fn randi(lo : Int, hi : Int) -> Int {
  @raylib.get_random_value(lo, hi)
}

///|
fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx : Float = x1 - x0
  let dy : Float = y1 - y0
  dx * dx + dy * dy
}

///|
fn inside_rectf(
  px : Float,
  py : Float,
  x : Float,
  y : Float,
  w : Float,
  h : Float,
) -> Bool {
  px >= x && px <= x + w && py >= y && py <= y + h
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
fn pointer_on_rect(
  mouse_x : Float,
  mouse_y : Float,
  mouse_hold : Bool,
  touch_count : Int,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> Bool {
  let mut hit : Bool = false

  if mouse_hold && inside_rect(mouse_x, mouse_y, x, y, w, h) {
    hit = true
  }

  if not(hit) {
    for i = 0; i < touch_count; i = i + 1 {
      let p = @raylib.get_touch_position(i)
      if inside_rect(p.x, p.y, x, y, w, h) {
        hit = true
      }
    }
  }

  hit
}

///|
fn pointer_on_circle(
  mouse_x : Float,
  mouse_y : Float,
  mouse_hold : Bool,
  touch_count : Int,
  cx : Float,
  cy : Float,
  r : Float,
) -> Bool {
  let mut hit : Bool = false

  if mouse_hold && dist2(mouse_x, mouse_y, cx, cy) <= r * r {
    hit = true
  }

  if not(hit) {
    for i = 0; i < touch_count; i = i + 1 {
      let p = @raylib.get_touch_position(i)
      if dist2(p.x, p.y, cx, cy) <= r * r {
        hit = true
      }
    }
  }

  hit
}

///|
fn ingredient_name(kind : Int) -> String {
  match kind {
    0 => "Bun"
    1 => "Meat"
    2 => "Veg"
    3 => "Sauce"
    _ => "Noodle"
  }
}

///|
fn recipe_name(kind : Int) -> String {
  match kind {
    0 => "Classic Burger"
    1 => "Spicy Skewer"
    2 => "Noodle Bowl"
    3 => "Double Melt"
    _ => "Green Wrap"
  }
}

///|
fn recipe_short(kind : Int) -> String {
  match kind {
    0 => "Burger"
    1 => "Skewer"
    2 => "Noodle"
    3 => "Double"
    _ => "Wrap"
  }
}

///|
fn recipe_reward(kind : Int) -> Int {
  match kind {
    0 => 110
    1 => 128
    2 => 136
    3 => 152
    _ => 124
  }
}

///|
fn recipe_cook_time(kind : Int) -> Float {
  match kind {
    0 => 5.2
    1 => 4.4
    2 => 4.9
    3 => 6.0
    _ => 4.6
  }
}

///|
fn recipe_color(kind : Int) -> @raylib.Color {
  match kind {
    0 => @raylib.Color::new(246, 180, 92, 232)
    1 => @raylib.Color::new(250, 118, 94, 232)
    2 => @raylib.Color::new(112, 196, 246, 232)
    3 => @raylib.Color::new(246, 210, 98, 232)
    _ => @raylib.Color::new(132, 228, 136, 232)
  }
}

///|
fn recipe_need(kind : Int, ingredient : Int) -> Int {
  match kind {
    0 =>
      match ingredient {
        0 => 1
        1 => 1
        2 => 1
        3 => 1
        _ => 0
      }
    1 =>
      match ingredient {
        0 => 0
        1 => 1
        2 => 1
        3 => 1
        _ => 0
      }
    2 =>
      match ingredient {
        0 => 0
        1 => 0
        2 => 1
        3 => 1
        _ => 1
      }
    3 =>
      match ingredient {
        0 => 1
        1 => 2
        2 => 0
        3 => 1
        _ => 0
      }
    _ =>
      match ingredient {
        0 => 1
        1 => 0
        2 => 2
        3 => 1
        _ => 0
      }
  }
}

///|
fn recipe_can_make(kind : Int, ingredients : Array[Int]) -> Bool {
  let mut ok : Bool = true
  for i = 0; i < ingredients.length(); i = i + 1 {
    if ingredients[i] < recipe_need(kind, i) {
      ok = false
    }
  }
  ok
}

///|
fn recipe_consume(kind : Int, ingredients : Array[Int]) -> Unit {
  for i = 0; i < ingredients.length(); i = i + 1 {
    let need : Int = recipe_need(kind, i)
    ingredients[i] = maxi(0, ingredients[i] - need)
  }
}

///|
fn clear_orders(orders : Array[Order]) -> Unit {
  for i = 0; i < orders.length(); i = i + 1 {
    orders[i].active = false
    orders[i].id = i + 1
    orders[i].kind = 0
    orders[i].deadline = 0.0
    orders[i].max_deadline = 0.0
    orders[i].reward = 0
    orders[i].pulse = 0.0
    orders[i].mood = 0.0
  }
}

///|
fn clear_stoves(stoves : Array[StoveSlot]) -> Unit {
  for i = 0; i < stoves.length(); i = i + 1 {
    stoves[i].active = false
    stoves[i].kind = 0
    stoves[i].progress = 0.0
    stoves[i].need = 1.0
    stoves[i].quality = 1.0
    stoves[i].pulse = 0.0
  }
}

///|
fn clear_boxes(boxes : Array[SupplyBox]) -> Unit {
  for i = 0; i < boxes.length(); i = i + 1 {
    boxes[i].active = false
    boxes[i].x = 0.0
    boxes[i].y = 0.0
    boxes[i].kind = 0
    boxes[i].amount = 0
    boxes[i].life = 0.0
    boxes[i].pulse = 0.0
  }
}

///|
fn clear_particles(parts : Array[Particle]) -> Unit {
  for i = 0; i < parts.length(); i = i + 1 {
    parts[i].active = false
    parts[i].x = 0.0
    parts[i].y = 0.0
    parts[i].vx = 0.0
    parts[i].vy = 0.0
    parts[i].life = 0.0
    parts[i].size = 0.0
    parts[i].kind = 0
  }
}

///|
fn spawn_particle(
  parts : Array[Particle],
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  life : Float,
  size : Float,
  kind : Int,
) -> Unit {
  for i = 0; i < parts.length(); i = i + 1 {
    if parts[i].active {
      continue
    }
    parts[i].active = true
    parts[i].x = x
    parts[i].y = y
    parts[i].vx = vx
    parts[i].vy = vy
    parts[i].life = life
    parts[i].size = size
    parts[i].kind = kind
    break
  }
}

///|
fn burst_particles(
  parts : Array[Particle],
  x : Float,
  y : Float,
  count : Int,
  kind : Int,
) -> Unit {
  for _i = 0; _i < count; _i = _i + 1 {
    spawn_particle(
      parts,
      x + randf(-8.0, 8.0),
      y + randf(-8.0, 8.0),
      randf(-120.0, 120.0),
      randf(-130.0, 90.0),
      randf(0.28, 0.88),
      randf(2.0, 5.6),
      kind,
    )
  }
}

///|
fn update_particles(parts : Array[Particle], dt : Float) -> Unit {
  for i = 0; i < parts.length(); i = i + 1 {
    if not(parts[i].active) {
      continue
    }
    parts[i].life = parts[i].life - dt
    if parts[i].life <= 0.0 {
      parts[i].active = false
      continue
    }
    parts[i].x = parts[i].x + parts[i].vx * dt
    parts[i].y = parts[i].y + parts[i].vy * dt
    parts[i].vx = parts[i].vx * (1.0 - dt * 1.8)
    parts[i].vy = parts[i].vy * (1.0 - dt * 1.7) + dt * 42.0
  }
}

///|
fn spawn_order(orders : Array[Order], wave : Int, serial : Int) -> Bool {
  let mut placed : Bool = false

  for i = 0; i < orders.length(); i = i + 1 {
    if orders[i].active {
      continue
    }

    let roll : Int = randi(0, 99)
    let kind : Int = if roll < 24 {
      0
    } else if roll < 44 {
      1
    } else if roll < 66 {
      2
    } else if roll < 84 {
      4
    } else {
      3
    }

    let base_deadline : Float = if kind == 3 {
      randf(50.0, 72.0)
    } else {
      randf(34.0, 62.0)
    }
    let wave_penalty : Float = Float::from_int(wave) * 1.35
    let deadline : Float = maxf(20.0, base_deadline - wave_penalty)

    orders[i].active = true
    orders[i].id = serial
    orders[i].kind = kind
    orders[i].deadline = deadline
    orders[i].max_deadline = deadline
    orders[i].reward = recipe_reward(kind) + wave * 4
    orders[i].pulse = randf(0.0, 10.0)
    orders[i].mood = randf(0.0, 0.35)

    placed = true
    break
  }

  placed
}

///|
fn spawn_supply_box(
  boxes : Array[SupplyBox],
  world_l : Float,
  world_t : Float,
  world_r : Float,
  world_b : Float,
) -> Bool {
  let mut placed : Bool = false

  for i = 0; i < boxes.length(); i = i + 1 {
    if boxes[i].active {
      continue
    }
    boxes[i].active = true
    boxes[i].x = randf(world_l + 120.0, world_r - 120.0)
    boxes[i].y = randf(world_t + 120.0, world_b - 120.0)
    boxes[i].kind = randi(0, 4)
    boxes[i].amount = randi(1, 3)
    boxes[i].life = randf(14.0, 24.0)
    boxes[i].pulse = randf(0.0, 12.0)
    placed = true
    break
  }

  placed
}

///|
fn find_pending_for_kind(orders : Array[Order], kind : Int) -> Int {
  let mut c : Int = 0
  for i = 0; i < orders.length(); i = i + 1 {
    if orders[i].active && orders[i].kind == kind {
      c = c + 1
    }
  }
  c
}

///|
fn find_cooking_for_kind(stoves : Array[StoveSlot], kind : Int) -> Int {
  let mut c : Int = 0
  for i = 0; i < stoves.length(); i = i + 1 {
    if stoves[i].active && stoves[i].kind == kind {
      c = c + 1
    }
  }
  c
}

///|
fn choose_recipe_for_cook(
  orders : Array[Order],
  stoves : Array[StoveSlot],
  meals : Array[Int],
  ingredients : Array[Int],
) -> Int {
  let mut best_kind : Int = -1
  let mut best_time : Float = 10000.0

  for i = 0; i < orders.length(); i = i + 1 {
    if not(orders[i].active) {
      continue
    }
    let k : Int = orders[i].kind
    let ready : Int = meals[k]
    let cooking : Int = find_cooking_for_kind(stoves, k)
    let pending : Int = find_pending_for_kind(orders, k)

    if ready + cooking >= pending {
      continue
    }
    if not(recipe_can_make(k, ingredients)) {
      continue
    }
    if orders[i].deadline < best_time {
      best_time = orders[i].deadline
      best_kind = k
    }
  }

  if best_kind >= 0 {
    best_kind
  } else {
    let mut fallback : Int = -1
    for k = 0; k < 5; k = k + 1 {
      if recipe_can_make(k, ingredients) {
        fallback = k
      }
    }
    fallback
  }
}

///|
fn open_stove_slot(stoves : Array[StoveSlot]) -> Int {
  let mut idx : Int = -1
  for i = 0; i < stoves.length(); i = i + 1 {
    if not(stoves[i].active) {
      idx = i
      break
    }
  }
  idx
}

///|
fn earliest_servable_order_index(
  orders : Array[Order],
  meals : Array[Int],
) -> Int {
  let mut idx : Int = -1
  let mut best_deadline : Float = 10000.0

  for i = 0; i < orders.length(); i = i + 1 {
    if not(orders[i].active) {
      continue
    }
    if meals[orders[i].kind] <= 0 {
      continue
    }
    if orders[i].deadline < best_deadline {
      best_deadline = orders[i].deadline
      idx = i
    }
  }

  idx
}

///|
fn draw_floor_grid(x : Int, y : Int, w : Int, h : Int, scene_t : Float) -> Unit {
  @raylib.draw_rectangle_gradient_v(
    x,
    y,
    w,
    h,
    @raylib.Color::new(38, 42, 58, 255),
    @raylib.Color::new(26, 30, 44, 255),
  )

  let cell : Int = 54
  let cols : Int = w / cell + 1
  let rows : Int = h / cell + 1

  for r = 0; r < rows; r = r + 1 {
    for c = 0; c < cols; c = c + 1 {
      let px : Int = x + c * cell
      let py : Int = y + r * cell
      let wave : Float = sinf(scene_t * 1.8 + Float::from_int(r + c) * 0.45) *
        0.5 +
        0.5
      let alpha : Int = 16 + (wave * 20.0).to_int()
      @raylib.draw_rectangle_lines(
        px,
        py,
        cell,
        cell,
        @raylib.Color::new(92, 102, 128, alpha),
      )
    }
  }
}

///|
fn draw_station(s : Station, active : Bool, scene_t : Float) -> Unit {
  let color = match s.kind {
    0 => @raylib.Color::new(250, 196, 118, if active { 236 } else { 162 })
    1 => @raylib.Color::new(246, 124, 102, if active { 236 } else { 162 })
    2 => @raylib.Color::new(120, 206, 126, if active { 236 } else { 162 })
    3 => @raylib.Color::new(242, 216, 124, if active { 236 } else { 162 })
    4 => @raylib.Color::new(112, 182, 250, if active { 236 } else { 162 })
    5 => @raylib.Color::new(255, 140, 88, if active { 236 } else { 166 })
    6 => @raylib.Color::new(128, 220, 250, if active { 236 } else { 166 })
    7 => @raylib.Color::new(166, 232, 194, if active { 236 } else { 166 })
    _ => @raylib.Color::new(174, 204, 248, if active { 236 } else { 166 })
  }

  @raylib.draw_rectangle(
    s.x.to_int(),
    s.y.to_int(),
    s.w.to_int(),
    s.h.to_int(),
    @raylib.Color::new(24, 30, 44, 228),
  )
  @raylib.draw_rectangle(
    (s.x + 3.0).to_int(),
    (s.y + 3.0).to_int(),
    (s.w - 6.0).to_int(),
    (s.h - 6.0).to_int(),
    color,
  )
  @raylib.draw_rectangle_lines(
    s.x.to_int(),
    s.y.to_int(),
    s.w.to_int(),
    s.h.to_int(),
    @raylib.Color::new(230, 240, 252, 210),
  )

  let pulse : Float = sinf(scene_t * 6.0 + s.x * 0.01 + s.y * 0.01) * 0.5 + 0.5
  @raylib.draw_circle_v(
    @raylib.Vector2::new(s.x + s.w * 0.5, s.y + s.h * 0.5),
    5.0 + pulse * 4.0,
    @raylib.Color::new(255, 255, 255, if active { 164 } else { 84 }),
  )

  let label : String = match s.kind {
    0 => "BUN"
    1 => "MEAT"
    2 => "VEG"
    3 => "SAUCE"
    4 => "NOODLE"
    5 => "STOVE"
    6 => "WINDOW"
    7 => "SINK"
    _ => "FAN"
  }

  @raylib.draw_text(
    label,
    s.x.to_int() + s.w.to_int() / 2 - @raylib.measure_text(label, 20) / 2,
    s.y.to_int() + s.h.to_int() / 2 - 10,
    20,
    @raylib.Color::new(22, 26, 34, 240),
  )
}

///|
fn draw_chef(chef : Chef, scene_t : Float) -> Unit {
  let bob : Float = sinf(scene_t * 10.0 + chef.step_t * 0.08) * 1.2
  @raylib.draw_circle_v(
    @raylib.Vector2::new(chef.x, chef.y + bob),
    18.0,
    @raylib.Color::new(250, 226, 176, 242),
  )
  @raylib.draw_circle_v(
    @raylib.Vector2::new(chef.x, chef.y - 18.0 + bob),
    11.0,
    @raylib.Color::new(252, 252, 255, 242),
  )
  @raylib.draw_rectangle(
    (chef.x - 14.0).to_int(),
    (chef.y + 10.0 + bob).to_int(),
    28,
    18,
    @raylib.Color::new(210, 236, 252, 240),
  )

  if chef.boost_t > 0.0 {
    @raylib.draw_circle_v(
      @raylib.Vector2::new(chef.x - 18.0, chef.y + bob),
      10.0 + chef.boost_t * 8.0,
      @raylib.Color::new(118, 208, 252, 138),
    )
  }
}

///|
fn draw_orders_panel(
  panel_x : Int,
  panel_y : Int,
  panel_w : Int,
  orders : Array[Order],
  meals : Array[Int],
  scene_t : Float,
) -> Unit {
  @raylib.draw_text(
    "Orders",
    panel_x + 18,
    panel_y + 16,
    32,
    @raylib.Color::new(236, 246, 255, 244),
  )

  let mut draw_y : Int = panel_y + 56
  for i = 0; i < orders.length(); i = i + 1 {
    if not(orders[i].active) {
      continue
    }

    let urgency : Float = if orders[i].max_deadline <= 0.001 {
      0.0
    } else {
      clampf(1.0 - orders[i].deadline / orders[i].max_deadline, 0.0, 1.0)
    }
    let blink : Float = sinf(scene_t * 8.0 + orders[i].pulse) * 0.5 + 0.5
    let card_h : Int = 86

    @raylib.draw_rectangle(
      panel_x + 12,
      draw_y,
      panel_w - 24,
      card_h,
      @raylib.Color::new(28, 34, 52, 238),
    )
    @raylib.draw_rectangle(
      panel_x + 14,
      draw_y + 2,
      panel_w - 28,
      card_h - 4,
      @raylib.Color::new(44 + (urgency * 86.0).to_int(), 58, 74, 232),
    )
    @raylib.draw_rectangle_lines(
      panel_x + 12,
      draw_y,
      panel_w - 24,
      card_h,
      @raylib.Color::new(198, 214, 236, 176),
    )

    let rc = recipe_color(orders[i].kind)
    @raylib.draw_circle_v(
      @raylib.Vector2::new(
        Float::from_int(panel_x + 44),
        Float::from_int(draw_y + 42),
      ),
      18.0,
      rc,
    )

    @raylib.draw_text(
      "#\{orders[i].id} \{recipe_short(orders[i].kind)}",
      panel_x + 72,
      draw_y + 10,
      24,
      @raylib.Color::new(236, 246, 255, 238),
    )

    let dd_txt : String = "\{orders[i].deadline.to_int()}s"
    @raylib.draw_text(
      dd_txt,
      panel_x + panel_w - 22 - @raylib.measure_text(dd_txt, 22),
      draw_y + 12,
      22,
      if urgency > 0.7 {
        @raylib.Color::new(255, 126, 116, 246)
      } else {
        @raylib.Color::new(214, 232, 250, 238)
      },
    )

    let has_ready : Bool = meals[orders[i].kind] > 0
    @raylib.draw_text(
      if has_ready {
        "READY"
      } else {
        "WAITING"
      },
      panel_x + 72,
      draw_y + 42,
      20,
      if has_ready {
        @raylib.Color::new(146, 236, 152, 236)
      } else {
        @raylib.Color::new(244, 210, 132, 164 + (blink * 80.0).to_int())
      },
    )

    let bar_w : Int = 220
    @raylib.draw_rectangle(
      panel_x + panel_w - bar_w - 24,
      draw_y + 48,
      bar_w,
      20,
      @raylib.Color::new(22, 24, 34, 230),
    )
    @raylib.draw_rectangle(
      panel_x + panel_w - bar_w - 22,
      draw_y + 50,
      (Float::from_int(bar_w - 4) * (1.0 - urgency)).to_int(),
      16,
      @raylib.Color::new(122, 228, 162, 224),
    )
    @raylib.draw_rectangle_lines(
      panel_x + panel_w - bar_w - 24,
      draw_y + 48,
      bar_w,
      20,
      @raylib.Color::new(204, 220, 242, 180),
    )

    draw_y = draw_y + card_h + 8
    if draw_y > panel_y + 520 {
      break
    }
  }
}

///|
fn draw_inventory_panel(
  panel_x : Int,
  panel_y : Int,
  ingredients : Array[Int],
  meals : Array[Int],
) -> Unit {
  @raylib.draw_text(
    "Inventory",
    panel_x + 18,
    panel_y + 560,
    30,
    @raylib.Color::new(236, 246, 255, 240),
  )

  let mut y0 : Int = panel_y + 604
  for i = 0; i < ingredients.length(); i = i + 1 {
    let text : String = "\{ingredient_name(i)}: \{ingredients[i]}"
    @raylib.draw_text(
      text,
      panel_x + 20,
      y0,
      22,
      @raylib.Color::new(214, 230, 248, 232),
    )
    y0 = y0 + 30
  }

  y0 = panel_y + 604
  for k = 0; k < meals.length(); k = k + 1 {
    let t : String = "\{recipe_short(k)} x\{meals[k]}"
    @raylib.draw_text(t, panel_x + 242, y0, 20, recipe_color(k))
    y0 = y0 + 30
  }
}

///|
fn draw_stoves(
  stoves : Array[StoveSlot],
  stove_x : Float,
  stove_y : Float,
  parts : Array[Particle],
  dt : Float,
) -> Unit {
  for i = 0; i < stoves.length(); i = i + 1 {
    let x : Float = stove_x + Float::from_int(i) * 84.0
    let y : Float = stove_y + 14.0
    @raylib.draw_rectangle(
      x.to_int(),
      y.to_int(),
      70,
      54,
      @raylib.Color::new(34, 34, 40, 244),
    )
    @raylib.draw_rectangle_lines(
      x.to_int(),
      y.to_int(),
      70,
      54,
      @raylib.Color::new(186, 198, 214, 210),
    )

    if stoves[i].active {
      let p : Float = clampf(stoves[i].progress / stoves[i].need, 0.0, 1.0)
      @raylib.draw_rectangle(
        x.to_int() + 4,
        y.to_int() + 34,
        (Float::from_int(62) * p).to_int(),
        14,
        @raylib.Color::new(255, 146, 92, 236),
      )
      @raylib.draw_rectangle_lines(
        x.to_int() + 4,
        y.to_int() + 34,
        62,
        14,
        @raylib.Color::new(224, 232, 248, 200),
      )
      @raylib.draw_text(
        recipe_short(stoves[i].kind),
        x.to_int() + 4,
        y.to_int() + 8,
        16,
        @raylib.Color::new(238, 246, 255, 236),
      )

      stoves[i].pulse = stoves[i].pulse + dt * 9.2
      let wave : Float = sinf(stoves[i].pulse) * 0.5 + 0.5
      spawn_particle(
        parts,
        x + 35.0 + randf(-5.0, 5.0),
        y + 6.0,
        randf(-14.0, 14.0),
        -randf(46.0, 92.0),
        randf(0.26, 0.58),
        2.0 + wave * 2.4,
        1,
      )
    }
  }
}

///|
fn draw_supply_boxes(boxes : Array[SupplyBox], scene_t : Float) -> Unit {
  for i = 0; i < boxes.length(); i = i + 1 {
    if not(boxes[i].active) {
      continue
    }
    let pulse : Float = sinf(scene_t * 5.8 + boxes[i].pulse) * 0.5 + 0.5
    @raylib.draw_rectangle(
      (boxes[i].x - 14.0).to_int(),
      (boxes[i].y - 14.0).to_int(),
      28,
      28,
      recipe_color(boxes[i].kind),
    )
    @raylib.draw_rectangle_lines(
      (boxes[i].x - 14.0).to_int(),
      (boxes[i].y - 14.0).to_int(),
      28,
      28,
      @raylib.Color::new(248, 252, 255, 232),
    )
    @raylib.draw_circle_v(
      @raylib.Vector2::new(boxes[i].x, boxes[i].y),
      20.0 + pulse * 8.0,
      @raylib.Color::new(248, 252, 255, (pulse * 80.0).to_int()),
    )

    @raylib.draw_text(
      "\{boxes[i].amount}",
      (boxes[i].x - 6.0).to_int(),
      (boxes[i].y - 8.0).to_int(),
      18,
      @raylib.Color::new(20, 24, 32, 240),
    )
  }
}

///|
fn draw_particles(parts : Array[Particle]) -> Unit {
  for i = 0; i < parts.length(); i = i + 1 {
    if not(parts[i].active) {
      continue
    }
    let alpha : Int = clampf(parts[i].life * 255.0, 0.0, 255.0).to_int()
    let color = if parts[i].kind == 0 {
      @raylib.Color::new(148, 218, 254, alpha)
    } else if parts[i].kind == 1 {
      @raylib.Color::new(255, 154, 98, alpha)
    } else {
      @raylib.Color::new(246, 236, 160, alpha)
    }
    @raylib.draw_circle_v(
      @raylib.Vector2::new(parts[i].x, parts[i].y),
      parts[i].size,
      color,
    )
  }
}

///|
fn draw_touch_controls(
  sw : Int,
  sh : Int,
  mouse_x : Float,
  mouse_y : Float,
  hold : Bool,
  touch_count : Int,
) -> Unit {
  let pad_x : Int = 26
  let pad_y : Int = sh - 214
  let cell : Int = 72

  let up = pointer_on_rect(
    mouse_x,
    mouse_y,
    hold,
    touch_count,
    pad_x + cell,
    pad_y,
    cell,
    cell,
  )
  let left = pointer_on_rect(
    mouse_x,
    mouse_y,
    hold,
    touch_count,
    pad_x,
    pad_y + cell,
    cell,
    cell,
  )
  let right = pointer_on_rect(
    mouse_x,
    mouse_y,
    hold,
    touch_count,
    pad_x + cell * 2,
    pad_y + cell,
    cell,
    cell,
  )
  let down = pointer_on_rect(
    mouse_x,
    mouse_y,
    hold,
    touch_count,
    pad_x + cell,
    pad_y + cell * 2,
    cell,
    cell,
  )

  fn draw_pad(x : Int, y : Int, label : String, active : Bool) -> Unit {
    @raylib.draw_rectangle(
      x,
      y,
      cell - 4,
      cell - 4,
      if active {
        @raylib.Color::new(104, 178, 236, 184)
      } else {
        @raylib.Color::new(38, 54, 82, 134)
      },
    )
    @raylib.draw_rectangle_lines(
      x,
      y,
      cell - 4,
      cell - 4,
      @raylib.Color::new(188, 212, 236, 174),
    )
    @raylib.draw_text(
      label,
      x + (cell - 4) / 2 - @raylib.measure_text(label, 24) / 2,
      y + (cell - 4) / 2 - 12,
      24,
      @raylib.Color::new(236, 246, 255, 236),
    )
  }

  draw_pad(pad_x + cell, pad_y, "W", up)
  draw_pad(pad_x, pad_y + cell, "A", left)
  draw_pad(pad_x + cell * 2, pad_y + cell, "D", right)
  draw_pad(pad_x + cell, pad_y + cell * 2, "S", down)

  let boost_x : Float = Float::from_int(sw - 262)
  let boost_y : Float = Float::from_int(sh - 152)
  let act_x : Float = Float::from_int(sw - 128)
  let act_y : Float = Float::from_int(sh - 214)

  let boost = pointer_on_circle(
    mouse_x, mouse_y, hold, touch_count, boost_x, boost_y, 58.0,
  )
  let act = pointer_on_circle(
    mouse_x, mouse_y, hold, touch_count, act_x, act_y, 48.0,
  )

  fn draw_btn(
    x : Float,
    y : Float,
    r : Float,
    label : String,
    active : Bool,
    cr : Int,
    cg : Int,
    cb : Int,
  ) -> Unit {
    @raylib.draw_circle_v(
      @raylib.Vector2::new(x, y),
      r,
      if active {
        @raylib.Color::new(cr, cg, cb, 224)
      } else {
        @raylib.Color::new(cr, cg, cb, 136)
      },
    )
    @raylib.draw_circle_lines(
      x.to_int(),
      y.to_int(),
      r,
      @raylib.Color::new(228, 240, 252, 216),
    )
    @raylib.draw_text(
      label,
      (x - Float::from_int(@raylib.measure_text(label, 20) / 2)).to_int(),
      (y - 10.0).to_int(),
      20,
      @raylib.Color::new(246, 252, 255, 238),
    )
  }

  draw_btn(boost_x, boost_y, 58.0, "BOOST", boost, 64, 166, 236)
  draw_btn(act_x, act_y, 48.0, "ACT", act, 74, 204, 152)
}

///|
fn draw_hud(
  panel_x : Int,
  panel_y : Int,
  panel_w : Int,
  panel_h : Int,
  timer : Float,
  score : Int,
  score_target : Int,
  rep : Float,
  heat : Float,
  clean : Float,
  combo : Int,
  served : Int,
  lost : Int,
  queue_size : Int,
  msg : String,
) -> Unit {
  @raylib.draw_rectangle(
    panel_x,
    panel_y,
    panel_w,
    panel_h,
    @raylib.Color::new(18, 24, 36, 246),
  )
  @raylib.draw_rectangle_lines(
    panel_x,
    panel_y,
    panel_w,
    panel_h,
    @raylib.Color::new(170, 188, 214, 202),
  )

  @raylib.draw_text(
    "FOOD TRUCK FRENZY 2026",
    panel_x + 20,
    panel_y + 16,
    34,
    @raylib.Color::new(238, 246, 255, 244),
  )

  let mm : Int = timer.to_int() / 60
  let ss : Int = timer.to_int() % 60
  let ss_txt : String = if ss < 10 { "0\{ss}" } else { "\{ss}" }

  @raylib.draw_text(
    "Time \{mm}:\{ss_txt}",
    panel_x + 22,
    panel_y + 64,
    28,
    @raylib.Color::new(236, 246, 255, 242),
  )
  @raylib.draw_text(
    "Score \{score}/\{score_target}",
    panel_x + 22,
    panel_y + 98,
    26,
    @raylib.Color::new(248, 232, 150, 238),
  )
  @raylib.draw_text(
    "Combo x\{combo}",
    panel_x + 22,
    panel_y + 132,
    24,
    @raylib.Color::new(130, 222, 252, 236),
  )
  @raylib.draw_text(
    "Served \{served}  Lost \{lost}  Queue \{queue_size}",
    panel_x + 22,
    panel_y + 164,
    22,
    @raylib.Color::new(214, 230, 246, 228),
  )

  fn meter(
    title : String,
    value : Float,
    max_value : Float,
    x : Int,
    y : Int,
    w : Int,
    h : Int,
    c : @raylib.Color,
  ) -> Unit {
    let p : Float = if max_value <= 0.001 {
      0.0
    } else {
      clampf(value / max_value, 0.0, 1.0)
    }
    @raylib.draw_rectangle(x, y, w, h, @raylib.Color::new(18, 22, 32, 240))
    @raylib.draw_rectangle(
      x + 2,
      y + 2,
      (Float::from_int(w - 4) * p).to_int(),
      h - 4,
      c,
    )
    @raylib.draw_rectangle_lines(
      x,
      y,
      w,
      h,
      @raylib.Color::new(220, 232, 246, 186),
    )
    @raylib.draw_text(
      title,
      x,
      y - 22,
      20,
      @raylib.Color::new(228, 238, 248, 232),
    )
  }

  meter(
    "Reputation",
    rep,
    100.0,
    panel_x + 20,
    panel_y + 218,
    panel_w - 40,
    24,
    @raylib.Color::new(98, 216, 136, 232),
  )
  meter(
    "Truck Heat",
    heat,
    100.0,
    panel_x + 20,
    panel_y + 268,
    panel_w - 40,
    24,
    @raylib.Color::new(248, 128, 96, 232),
  )
  meter(
    "Cleanliness",
    clean,
    100.0,
    panel_x + 20,
    panel_y + 318,
    panel_w - 40,
    24,
    @raylib.Color::new(122, 198, 252, 232),
  )

  @raylib.draw_rectangle(
    panel_x + 14,
    panel_y + panel_h - 168,
    panel_w - 28,
    148,
    @raylib.Color::new(24, 30, 44, 238),
  )
  @raylib.draw_rectangle_lines(
    panel_x + 14,
    panel_y + panel_h - 168,
    panel_w - 28,
    148,
    @raylib.Color::new(118, 146, 182, 196),
  )

  @raylib.draw_text(
    "Controls",
    panel_x + 24,
    panel_y + panel_h - 158,
    24,
    @raylib.Color::new(238, 246, 255, 236),
  )
  @raylib.draw_text(
    "Move: WASD/Arrows\nBoost: Space/J\nInteract: L/U",
    panel_x + 24,
    panel_y + panel_h - 122,
    21,
    @raylib.Color::new(194, 218, 244, 228),
  )

  @raylib.draw_text(
    msg,
    panel_x + 20,
    panel_y + 362,
    22,
    @raylib.Color::new(250, 226, 162, 238),
  )
}

///|
fn draw_menu(sw : Int, sh : Int, scene_t : Float) -> Unit {
  @raylib.clear_background(@raylib.Color::new(10, 16, 26, 255))

  for i = 0; i < 24; i = i + 1 {
    let yy : Float = Float::from_int(i) / 24.0
    let wave : Float = sinf(scene_t * 1.2 + yy * 6.4) * 0.5 + 0.5
    let alpha : Int = 22 + (wave * 46.0).to_int()
    @raylib.draw_rectangle(
      0,
      (yy * Float::from_int(sh)).to_int(),
      sw,
      sh / 24 + 2,
      @raylib.Color::new(32, 58, 96, alpha),
    )
  }

  @raylib.draw_text(
    "FOOD TRUCK FRENZY 2026",
    sw / 2 - @raylib.measure_text("FOOD TRUCK FRENZY 2026", 72) / 2,
    182,
    72,
    @raylib.Color::new(238, 246, 255, 246),
  )
  @raylib.draw_text(
    "Dash around a packed kitchen: collect ingredients, cook dishes, and serve impatient customers.",
    sw / 2 -
    @raylib.measure_text(
      "Dash around a packed kitchen: collect ingredients, cook dishes, and serve impatient customers.",
      28,
    ) /
    2,
    300,
    28,
    @raylib.Color::new(188, 212, 236, 236),
  )
  @raylib.draw_text(
    "Keep reputation alive while heat and dirt pressure your workflow.",
    sw / 2 -
    @raylib.measure_text(
      "Keep reputation alive while heat and dirt pressure your workflow.", 26,
    ) /
    2,
    348,
    26,
    @raylib.Color::new(170, 204, 226, 226),
  )

  let pulse : Float = sinf(scene_t * 3.6) * 0.5 + 0.5
  let bw : Int = 470
  let bh : Int = 96
  let bx : Int = sw / 2 - bw / 2
  let by : Int = 470
  @raylib.draw_rectangle(
    bx,
    by,
    bw,
    bh,
    @raylib.Color::new(70, 134, 216, 146 + (pulse * 90.0).to_int()),
  )
  @raylib.draw_rectangle_lines(
    bx,
    by,
    bw,
    bh,
    @raylib.Color::new(224, 236, 250, 226),
  )
  @raylib.draw_text(
    "PRESS ENTER / TAP TO START",
    sw / 2 - @raylib.measure_text("PRESS ENTER / TAP TO START", 38) / 2,
    by + bh / 2 - 19,
    38,
    @raylib.Color::new(246, 252, 255, 244),
  )

  @raylib.draw_text(
    "Mobile: use on-screen D-pad + BOOST + ACT",
    sw / 2 -
    @raylib.measure_text("Mobile: use on-screen D-pad + BOOST + ACT", 24) / 2,
    620,
    24,
    @raylib.Color::new(186, 210, 236, 224),
  )
}

///|
fn draw_end(
  sw : Int,
  sh : Int,
  win : Bool,
  score : Int,
  target : Int,
  rep : Float,
  served : Int,
  lost : Int,
) -> Unit {
  @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(8, 12, 20, 220))
  let title : String = if win { "SHIFT COMPLETE" } else { "TRUCK CLOSED" }

  @raylib.draw_text(
    title,
    sw / 2 - @raylib.measure_text(title, 78) / 2,
    210,
    78,
    if win {
      @raylib.Color::new(164, 244, 188, 246)
    } else {
      @raylib.Color::new(252, 152, 136, 246)
    },
  )

  @raylib.draw_text(
    "Score: \{score}/\{target}",
    sw / 2 - @raylib.measure_text("Score: \{score}/\{target}", 40) / 2,
    334,
    40,
    @raylib.Color::new(236, 246, 255, 242),
  )
  @raylib.draw_text(
    "Reputation: \{rep.to_int()}%",
    sw / 2 - @raylib.measure_text("Reputation: \{rep.to_int()}%", 34) / 2,
    386,
    34,
    @raylib.Color::new(216, 232, 250, 236),
  )
  @raylib.draw_text(
    "Served: \{served}  Lost: \{lost}",
    sw / 2 - @raylib.measure_text("Served: \{served}  Lost: \{lost}", 32) / 2,
    430,
    32,
    @raylib.Color::new(204, 224, 244, 232),
  )

  @raylib.draw_text(
    "Press Enter / R to play again",
    sw / 2 - @raylib.measure_text("Press Enter / R to play again", 32) / 2,
    536,
    32,
    @raylib.Color::new(244, 250, 255, 236),
  )
}

///|
fn main {
  let sw : Int = 1680
  let sh : Int = 960
  @raylib.init_window(sw, sh, "raylib [game] food truck frenzy 2026")
  defer @raylib.close_window()
  @raylib.set_target_fps(120)

  let world_x : Int = 22
  let world_y : Int = 22
  let panel_w : Int = 460
  let world_w : Int = sw - panel_w - 42
  let world_h : Int = sh - 44

  let world_l : Float = Float::from_int(world_x)
  let world_t : Float = Float::from_int(world_y)
  let world_r : Float = Float::from_int(world_x + world_w)
  let world_b : Float = Float::from_int(world_y + world_h)

  let stations : Array[Station] = [
    { x: world_l + 30.0, y: world_t + 80.0, w: 120.0, h: 70.0, kind: 0 },
    { x: world_l + 30.0, y: world_t + 174.0, w: 120.0, h: 70.0, kind: 1 },
    { x: world_l + 30.0, y: world_t + 268.0, w: 120.0, h: 70.0, kind: 2 },
    { x: world_l + 30.0, y: world_t + 362.0, w: 120.0, h: 70.0, kind: 3 },
    { x: world_l + 30.0, y: world_t + 456.0, w: 120.0, h: 70.0, kind: 4 },
    { x: world_l + 312.0, y: world_t + 188.0, w: 226.0, h: 96.0, kind: 5 },
    { x: world_r - 210.0, y: world_t + 76.0, w: 174.0, h: 96.0, kind: 6 },
    { x: world_r - 210.0, y: world_t + 228.0, w: 174.0, h: 96.0, kind: 7 },
    { x: world_r - 210.0, y: world_t + 380.0, w: 174.0, h: 96.0, kind: 8 },
  ]

  let orders : Array[Order] = Array::makei(11, fn(i) {
    {
      active: false,
      id: i + 1,
      kind: 0,
      deadline: 0.0,
      max_deadline: 0.0,
      reward: 0,
      pulse: 0.0,
      mood: 0.0,
    }
  })

  let stoves : Array[StoveSlot] = Array::makei(2, fn(_i) {
    {
      active: false,
      kind: 0,
      progress: 0.0,
      need: 1.0,
      quality: 1.0,
      pulse: 0.0,
    }
  })

  let boxes : Array[SupplyBox] = Array::makei(14, fn(_i) {
    { active: false, x: 0.0, y: 0.0, kind: 0, amount: 0, life: 0.0, pulse: 0.0 }
  })

  let parts : Array[Particle] = Array::makei(900, fn(_i) {
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

  let ingredients : Array[Int] = Array::makei(5, fn(_i) { 0 })
  let meals : Array[Int] = Array::makei(5, fn(_i) { 0 })
  let bin_cd : Array[Float] = Array::makei(5, fn(_i) { 0.0 })

  let chef : Chef = {
    x: world_l + 270.0,
    y: world_t + 340.0,
    vx: 0.0,
    vy: 0.0,
    heading: 0.0,
    stamina: 100.0,
    stamina_max: 100.0,
    heat_resist: 0.0,
    action_cd: 0.0,
    boost_t: 0.0,
    step_t: 0.0,
  }

  let mut state : Int = 0 // 0 menu 1 play 2 win 3 lose
  let mut scene_t : Float = 0.0
  let mut timer : Float = 360.0
  let mut score : Int = 0
  let mut score_target : Int = 9200
  let mut rep : Float = 88.0
  let mut heat : Float = 18.0
  let mut clean : Float = 96.0
  let mut combo : Int = 0
  let mut served : Int = 0
  let mut lost : Int = 0
  let mut wave : Int = 1

  let mut order_serial : Int = 1
  let mut order_spawn_cd : Float = 1.2
  let mut supply_spawn_cd : Float = 10.0

  let mut msg : String = ""
  let mut msg_t : Float = 0.0

  fn reset_run() -> Unit {
    clear_orders(orders)
    clear_stoves(stoves)
    clear_boxes(boxes)
    clear_particles(parts)

    for i = 0; i < ingredients.length(); i = i + 1 {
      ingredients[i] = 4
      meals[i] = 0
      bin_cd[i] = 0.0
    }

    chef.x = world_l + 270.0
    chef.y = world_t + 340.0
    chef.vx = 0.0
    chef.vy = 0.0
    chef.heading = 0.0
    chef.stamina = 100.0
    chef.heat_resist = 0.0
    chef.action_cd = 0.0
    chef.boost_t = 0.0
    chef.step_t = 0.0

    state = 1
    scene_t = 0.0
    timer = 360.0
    score = 0
    score_target = 9200
    rep = 88.0
    heat = 18.0
    clean = 96.0
    combo = 0
    served = 0
    lost = 0
    wave = 1

    order_serial = 1
    order_spawn_cd = 1.2
    supply_spawn_cd = 10.0

    msg = "Collect ingredients, cook dishes, serve orders fast."
    msg_t = 3.0
  }

  reset_run()
  state = 0

  while not(@raylib.window_should_close()) {
    let mut dt : Float = @raylib.get_frame_time()
    if dt > 0.033 {
      dt = 0.033
    }
    scene_t = scene_t + dt

    let mouse = @raylib.get_mouse_position()
    let click : Bool = @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft)
    let hold : Bool = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft)
    let mut touch_count : Int = @raylib.get_touch_point_count()
    if touch_count > 10 {
      touch_count = 10
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

    if chef.action_cd > 0.0 {
      chef.action_cd = chef.action_cd - dt
      if chef.action_cd < 0.0 {
        chef.action_cd = 0.0
      }
    }

    for i = 0; i < bin_cd.length(); i = i + 1 {
      if bin_cd[i] > 0.0 {
        bin_cd[i] = bin_cd[i] - dt
        if bin_cd[i] < 0.0 {
          bin_cd[i] = 0.0
        }
      }
    }

    update_particles(parts, dt)

    if state == 0 {
      if click ||
        touch_count > 0 ||
        @raylib.is_key_pressed(@raylib.KeyEnter) ||
        @raylib.is_key_pressed(@raylib.KeySpace) {
        reset_run()
      }
    } else if state == 1 {
      timer = timer - dt
      if timer < 0.0 {
        timer = 0.0
      }

      wave = 1 + score / 900
      if wave > 12 {
        wave = 12
      }

      // Input
      let mut move_l : Bool = @raylib.is_key_down(@raylib.KeyA) ||
        @raylib.is_key_down(@raylib.KeyLeft)
      let mut move_r : Bool = @raylib.is_key_down(@raylib.KeyD) ||
        @raylib.is_key_down(@raylib.KeyRight)
      let mut move_u : Bool = @raylib.is_key_down(@raylib.KeyW) ||
        @raylib.is_key_down(@raylib.KeyUp)
      let mut move_d : Bool = @raylib.is_key_down(@raylib.KeyS) ||
        @raylib.is_key_down(@raylib.KeyDown)

      let mut boost_hold : Bool = @raylib.is_key_down(@raylib.KeySpace) ||
        @raylib.is_key_down(@raylib.KeyJ)
      let mut action_press : Bool = @raylib.is_key_pressed(@raylib.KeyL) ||
        @raylib.is_key_pressed(@raylib.KeyU)

      if pointer_on_rect(
          mouse.x,
          mouse.y,
          hold,
          touch_count,
          26 + 72,
          sh - 214,
          72,
          72,
        ) {
        move_u = true
      }
      if pointer_on_rect(
          mouse.x,
          mouse.y,
          hold,
          touch_count,
          26,
          sh - 214 + 72,
          72,
          72,
        ) {
        move_l = true
      }
      if pointer_on_rect(
          mouse.x,
          mouse.y,
          hold,
          touch_count,
          26 + 144,
          sh - 214 + 72,
          72,
          72,
        ) {
        move_r = true
      }
      if pointer_on_rect(
          mouse.x,
          mouse.y,
          hold,
          touch_count,
          26 + 72,
          sh - 214 + 144,
          72,
          72,
        ) {
        move_d = true
      }

      if pointer_on_circle(
          mouse.x,
          mouse.y,
          hold,
          touch_count,
          Float::from_int(sw - 262),
          Float::from_int(sh - 152),
          58.0,
        ) {
        boost_hold = true
      }
      if pointer_on_circle(
          mouse.x,
          mouse.y,
          hold,
          touch_count,
          Float::from_int(sw - 128),
          Float::from_int(sh - 214),
          48.0,
        ) {
        action_press = true
      }

      let mut mx : Float = 0.0
      let mut my : Float = 0.0
      if move_l {
        mx = mx - 1.0
      }
      if move_r {
        mx = mx + 1.0
      }
      if move_u {
        my = my - 1.0
      }
      if move_d {
        my = my + 1.0
      }

      let norm : Float = (mx * mx + my * my).sqrt()
      if norm > 0.001 {
        mx = mx / norm
        my = my / norm
      }

      let mut speed : Float = 244.0
      let mut stamina_drain : Float = 0.0
      if boost_hold && chef.stamina > 0.0 {
        speed = 372.0
        stamina_drain = 36.0
        chef.boost_t = clampf(chef.boost_t + dt * 2.0, 0.0, 1.0)
      } else {
        chef.boost_t = clampf(chef.boost_t - dt * 2.4, 0.0, 1.0)
      }

      if mx == 0.0 && my == 0.0 {
        speed = 0.0
      }

      chef.vx = mx * speed
      chef.vy = my * speed
      chef.x = chef.x + chef.vx * dt
      chef.y = chef.y + chef.vy * dt

      if speed > 0.0 {
        chef.step_t = chef.step_t + dt * speed
      }

      if chef.x < world_l + 20.0 {
        chef.x = world_l + 20.0
      }
      if chef.x > world_r - 20.0 {
        chef.x = world_r - 20.0
      }
      if chef.y < world_t + 20.0 {
        chef.y = world_t + 20.0
      }
      if chef.y > world_b - 20.0 {
        chef.y = world_b - 20.0
      }

      if stamina_drain > 0.0 {
        chef.stamina = chef.stamina - dt * stamina_drain
      } else {
        chef.stamina = chef.stamina + dt * 18.0
      }
      chef.stamina = clampf(chef.stamina, 0.0, chef.stamina_max)

      // Global systems
      heat = heat + dt * (0.82 + Float::from_int(wave) * 0.12)
      clean = clean - dt * (0.68 + heat * 0.012)

      heat = clampf(heat, 0.0, 100.0)
      clean = clampf(clean, 0.0, 100.0)

      let heat_penalty : Float = heat * 0.006
      let dirt_penalty : Float = (100.0 - clean) * 0.004
      rep = rep - dt * (0.06 + heat_penalty * 0.5 + dirt_penalty * 0.6)
      rep = clampf(rep, 0.0, 100.0)

      order_spawn_cd = order_spawn_cd - dt
      if order_spawn_cd <= 0.0 {
        let spawned : Bool = spawn_order(orders, wave, order_serial)
        if spawned {
          order_serial = order_serial + 1
        } else {
          rep = rep - 1.2
        }
        order_spawn_cd = maxf(1.3, 4.6 - Float::from_int(wave) * 0.24)
      }

      supply_spawn_cd = supply_spawn_cd - dt
      if supply_spawn_cd <= 0.0 {
        ignore(spawn_supply_box(boxes, world_l, world_t, world_r, world_b))
        supply_spawn_cd = randf(8.0, 15.0)
      }

      // Orders tick
      let mut active_orders : Int = 0
      for i = 0; i < orders.length(); i = i + 1 {
        if not(orders[i].active) {
          continue
        }
        active_orders = active_orders + 1
        orders[i].pulse = orders[i].pulse + dt * 3.6
        let queue_pressure : Float = Float::from_int(active_orders) * 0.007
        orders[i].deadline = orders[i].deadline -
          dt * (1.0 + heat_penalty + dirt_penalty + queue_pressure)
        if orders[i].deadline <= 0.0 {
          orders[i].active = false
          combo = 0
          lost = lost + 1
          rep = rep - 7.4
          msg = "Order timed out!"
          msg_t = 1.0
          burst_particles(parts, world_r - 90.0, world_t + 120.0, 14, 1)
        }
      }

      // Stove updates
      let cook_speed : Float = 0.72 + clean * 0.006
      for i = 0; i < stoves.length(); i = i + 1 {
        if not(stoves[i].active) {
          continue
        }
        stoves[i].progress = stoves[i].progress + dt * cook_speed
        stoves[i].quality = clampf(
          stoves[i].quality - dt * (0.03 + heat * 0.0009),
          0.5,
          1.0,
        )
        if stoves[i].progress >= stoves[i].need {
          meals[stoves[i].kind] = meals[stoves[i].kind] + 1
          if meals[stoves[i].kind] > 16 {
            meals[stoves[i].kind] = 16
          }
          stoves[i].active = false
          clean = clean - 1.4
          heat = heat + 1.8
          burst_particles(
            parts,
            stations[5].x + 112.0,
            stations[5].y + 30.0,
            12,
            2,
          )
        }
      }

      // Supply box updates
      for i = 0; i < boxes.length(); i = i + 1 {
        if not(boxes[i].active) {
          continue
        }
        boxes[i].life = boxes[i].life - dt
        boxes[i].pulse = boxes[i].pulse + dt * 4.6
        if boxes[i].life <= 0.0 {
          boxes[i].active = false
        }
        if dist2(chef.x, chef.y, boxes[i].x, boxes[i].y) <= 34.0 * 34.0 {
          ingredients[boxes[i].kind] = mini(
            24,
            ingredients[boxes[i].kind] + boxes[i].amount,
          )
          boxes[i].active = false
          msg = "Supply drop: +\{boxes[i].amount} \{ingredient_name(boxes[i].kind)}"
          msg_t = 1.2
          burst_particles(parts, chef.x, chef.y, 10, 0)
        }
      }

      // Interact action
      if action_press && chef.action_cd <= 0.0 {
        let mut did_action : Bool = false

        // Ingredient bins
        for k = 0; k < 5; k = k + 1 {
          if did_action {
            continue
          }
          if inside_rectf(
              chef.x,
              chef.y,
              stations[k].x,
              stations[k].y,
              stations[k].w,
              stations[k].h,
            ) &&
            bin_cd[k] <= 0.0 {
            let amount : Int = randi(2, 4)
            ingredients[k] = mini(24, ingredients[k] + amount)
            bin_cd[k] = 0.42
            did_action = true
            msg = "+\{amount} \{ingredient_name(k)}"
            msg_t = 0.9
            burst_particles(parts, chef.x, chef.y, 8, 0)
          }
        }

        // Stove cook
        if not(did_action) &&
          inside_rectf(
            chef.x,
            chef.y,
            stations[5].x,
            stations[5].y,
            stations[5].w,
            stations[5].h,
          ) {
          let slot : Int = open_stove_slot(stoves)
          if slot >= 0 {
            let pick : Int = choose_recipe_for_cook(
              orders, stoves, meals, ingredients,
            )
            if pick >= 0 {
              recipe_consume(pick, ingredients)
              stoves[slot].active = true
              stoves[slot].kind = pick
              stoves[slot].progress = 0.0
              stoves[slot].need = recipe_cook_time(pick) * (1.0 + heat * 0.003)
              stoves[slot].quality = 1.0
              stoves[slot].pulse = randf(0.0, 8.0)
              did_action = true
              msg = "Cooking \{recipe_short(pick)}"
              msg_t = 1.0
              heat = heat + 2.2
              clean = clean - 0.8
            } else {
              msg = "Missing ingredients for all recipes"
              msg_t = 1.0
            }
          } else {
            msg = "All stove slots are busy"
            msg_t = 1.0
          }
        }

        // Serve window
        if not(did_action) &&
          inside_rectf(
            chef.x,
            chef.y,
            stations[6].x,
            stations[6].y,
            stations[6].w,
            stations[6].h,
          ) {
          let oi : Int = earliest_servable_order_index(orders, meals)
          if oi >= 0 {
            let k : Int = orders[oi].kind
            meals[k] = meals[k] - 1
            let bonus : Int = (orders[oi].deadline * 2.0).to_int()
            let gain : Int = orders[oi].reward + combo * 12 + bonus
            score = score + gain
            served = served + 1
            combo = mini(30, combo + 1)
            rep = minf(100.0, rep + 3.0 + Float::from_int(combo) * 0.06)
            orders[oi].active = false
            did_action = true
            msg = "Served \{recipe_short(k)} +\{gain}"
            msg_t = 1.2
            burst_particles(
              parts,
              stations[6].x + 80.0,
              stations[6].y + 36.0,
              18,
              2,
            )
          } else {
            msg = "No matching ready meals"
            msg_t = 0.9
          }
        }

        // Sink clean
        if not(did_action) &&
          inside_rectf(
            chef.x,
            chef.y,
            stations[7].x,
            stations[7].y,
            stations[7].w,
            stations[7].h,
          ) {
          clean = minf(100.0, clean + 28.0)
          heat = maxf(0.0, heat - 8.0)
          rep = minf(100.0, rep + 0.8)
          did_action = true
          msg = "Quick cleanup complete"
          msg_t = 1.0
          burst_particles(
            parts,
            stations[7].x + 80.0,
            stations[7].y + 48.0,
            10,
            0,
          )
        }

        // Fan cool
        if not(did_action) &&
          inside_rectf(
            chef.x,
            chef.y,
            stations[8].x,
            stations[8].y,
            stations[8].w,
            stations[8].h,
          ) {
          heat = maxf(0.0, heat - 24.0)
          chef.stamina = minf(chef.stamina_max, chef.stamina + 20.0)
          did_action = true
          msg = "Cooling blast!"
          msg_t = 1.0
          burst_particles(
            parts,
            stations[8].x + 80.0,
            stations[8].y + 48.0,
            12,
            0,
          )
        }

        if did_action {
          chef.action_cd = 0.18
        }
      }

      // Passive visuals
      if chef.vx != 0.0 || chef.vy != 0.0 {
        spawn_particle(
          parts,
          chef.x + randf(-6.0, 6.0),
          chef.y + 20.0,
          -chef.vx * 0.16 + randf(-12.0, 12.0),
          -chef.vy * 0.16 + randf(-12.0, 12.0),
          randf(0.2, 0.52),
          randf(1.4, 2.8),
          0,
        )
      }

      // Win/Lose checks
      if rep <= 0.0 {
        state = 3
        msg = "Reputation collapsed."
      } else if timer <= 0.0 {
        if score >= score_target && rep >= 40.0 {
          state = 2
          msg = "Shift cleared with style."
        } else {
          state = 3
          msg = "Shift ended below target."
        }
      }
    } else if state == 2 || state == 3 {
      if @raylib.is_key_pressed(@raylib.KeyEnter) ||
        @raylib.is_key_pressed(@raylib.KeyR) ||
        click ||
        touch_count > 0 {
        reset_run()
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(10, 16, 26, 255))

    if state == 0 {
      draw_menu(sw, sh, scene_t)
    } else {
      draw_floor_grid(world_x, world_y, world_w, world_h, scene_t)

      let mut active_orders : Int = 0
      for i = 0; i < orders.length(); i = i + 1 {
        if orders[i].active {
          active_orders = active_orders + 1
        }
      }

      for i = 0; i < stations.length(); i = i + 1 {
        let near : Bool = inside_rectf(
          chef.x,
          chef.y,
          stations[i].x,
          stations[i].y,
          stations[i].w,
          stations[i].h,
        )
        draw_station(stations[i], near, scene_t)
      }

      draw_supply_boxes(boxes, scene_t)
      draw_stoves(stoves, stations[5].x + 8.0, stations[5].y + 10.0, parts, dt)
      draw_particles(parts)
      draw_chef(chef, scene_t)

      let panel_x : Int = world_x + world_w + 10
      let panel_y : Int = world_y
      let panel_w2 : Int = panel_w - 12
      let panel_h : Int = world_h

      draw_hud(
        panel_x,
        panel_y,
        panel_w2,
        panel_h,
        timer,
        score,
        score_target,
        rep,
        heat,
        clean,
        combo,
        served,
        lost,
        active_orders,
        if msg_t > 0.0 {
          msg
        } else {
          ""
        },
      )
      draw_orders_panel(
        panel_x,
        panel_y + 390,
        panel_w2,
        orders,
        meals,
        scene_t,
      )
      draw_inventory_panel(panel_x, panel_y + 390, ingredients, meals)

      draw_touch_controls(sw, sh, mouse.x, mouse.y, hold, touch_count)

      if state == 2 || state == 3 {
        draw_end(sw, sh, state == 2, score, score_target, rep, served, lost)
      }
    }

    @raylib.end_drawing()
  }
}
