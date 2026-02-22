///|
let sw : Int = 1366

///|
let sh : Int = 768

///|
let world_l : Float = 24.0

///|
let world_t : Float = 24.0

///|
let world_r : Float = 970.0

///|
let world_b : Float = 744.0

///|
let reservoir_x : Int = 42

///|
let reservoir_y : Int = 596

///|
let reservoir_w : Int = 250

///|
let reservoir_h : Int = 128

///|
let hospital_x : Int = 700

///|
let hospital_y : Int = 596

///|
let hospital_w : Int = 244

///|
let hospital_h : Int = 128

///|
let max_buildings : Int = 28

///|
let max_drops : Int = 220

///|
let max_particles : Int = 360

///|
struct Helicopter {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut water : Float
  mut water_max : Float
  mut passengers : Int
  mut capacity : Int
  mut fire_cd : Float
  mut rescue_cd : Float
  wobble : Float
}

///|
struct Building {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut w : Float
  mut h : Float
  mut fire : Float
  mut integrity : Float
  mut people : Int
  mut casualties : Int
  mut spread_cd : Float
  mut emergency_cd : Float
  mut collapsed : Bool
  mut pulse : Float
  mut name : String
}

///|
struct WaterDrop {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut power : Float
  mut life : Float
  mut kind : Int
}

///|
struct Particle {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut size : Float
  mut life : Float
  mut pulse : Float
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
fn circle_rect_hit(
  cx : Float,
  cy : Float,
  r : Float,
  rx : Float,
  ry : Float,
  rw : Float,
  rh : Float,
) -> Bool {
  let nx : Float = clampf(cx, rx, rx + rw)
  let ny : Float = clampf(cy, ry, ry + rh)
  let dx : Float = cx - nx
  let dy : Float = cy - ny
  dx * dx + dy * dy <= r * r
}

///|
fn building_center_x(b : Building) -> Float {
  b.x + b.w * 0.5
}

///|
fn building_center_y(b : Building) -> Float {
  b.y + b.h * 0.5
}

///|
fn clear_buildings(buildings : Array[Building]) -> Unit {
  for i = 0; i < buildings.length(); i = i + 1 {
    buildings[i].active = false
    buildings[i].x = 0.0
    buildings[i].y = 0.0
    buildings[i].w = 0.0
    buildings[i].h = 0.0
    buildings[i].fire = 0.0
    buildings[i].integrity = 100.0
    buildings[i].people = 0
    buildings[i].casualties = 0
    buildings[i].spread_cd = 0.0
    buildings[i].emergency_cd = 0.0
    buildings[i].collapsed = false
    buildings[i].pulse = 0.0
    buildings[i].name = ""
  }
}

///|
fn clear_drops(drops : Array[WaterDrop]) -> Unit {
  for i = 0; i < drops.length(); i = i + 1 {
    drops[i].active = false
    drops[i].x = 0.0
    drops[i].y = 0.0
    drops[i].vx = 0.0
    drops[i].vy = 0.0
    drops[i].power = 0.0
    drops[i].life = 0.0
    drops[i].kind = 0
  }
}

///|
fn clear_particles(parts : Array[Particle]) -> Unit {
  for i = 0; i < parts.length(); i = i + 1 {
    parts[i].active = false
    parts[i].kind = 0
    parts[i].x = 0.0
    parts[i].y = 0.0
    parts[i].vx = 0.0
    parts[i].vy = 0.0
    parts[i].size = 0.0
    parts[i].life = 0.0
    parts[i].pulse = 0.0
  }
}

///|
fn add_building(
  buildings : Array[Building],
  x : Float,
  y : Float,
  w : Float,
  h : Float,
  people : Int,
  fire : Float,
  name : String,
) -> Bool {
  for i = 0; i < buildings.length(); i = i + 1 {
    if not(buildings[i].active) {
      buildings[i].active = true
      buildings[i].x = x
      buildings[i].y = y
      buildings[i].w = w
      buildings[i].h = h
      buildings[i].fire = fire
      buildings[i].integrity = randf(78.0, 100.0)
      buildings[i].people = people
      buildings[i].casualties = 0
      buildings[i].spread_cd = randf(2.0, 5.2)
      buildings[i].emergency_cd = randf(5.0, 13.0)
      buildings[i].collapsed = false
      buildings[i].pulse = randf(0.0, 20.0)
      buildings[i].name = name
      return true
    }
  }
  false
}

///|
fn setup_city(buildings : Array[Building]) -> Unit {
  clear_buildings(buildings)

  ignore(
    add_building(buildings, 108.0, 126.0, 132.0, 102.0, 5, 20.0, "Atlas Mall"),
  )
  ignore(
    add_building(buildings, 292.0, 108.0, 148.0, 120.0, 7, 16.0, "North Clinic"),
  )
  ignore(
    add_building(buildings, 494.0, 102.0, 126.0, 116.0, 6, 14.0, "Solar Tower"),
  )
  ignore(
    add_building(buildings, 664.0, 122.0, 126.0, 102.0, 5, 12.0, "Cloud School"),
  )
  ignore(
    add_building(buildings, 812.0, 108.0, 126.0, 116.0, 8, 18.0, "Metro Hall"),
  )

  ignore(
    add_building(buildings, 94.0, 280.0, 146.0, 124.0, 10, 22.0, "Harbor Hotel"),
  )
  ignore(
    add_building(
      buildings, 282.0, 272.0, 150.0, 126.0, 12, 26.0, "Civic Center",
    ),
  )
  ignore(
    add_building(buildings, 484.0, 288.0, 146.0, 110.0, 9, 24.0, "Tech Market"),
  )
  ignore(
    add_building(buildings, 668.0, 278.0, 120.0, 122.0, 7, 16.0, "Art Museum"),
  )
  ignore(
    add_building(buildings, 812.0, 272.0, 128.0, 124.0, 10, 18.0, "Rose Homes"),
  )

  ignore(
    add_building(buildings, 108.0, 454.0, 130.0, 116.0, 7, 14.0, "West Library"),
  )
  ignore(
    add_building(buildings, 292.0, 456.0, 136.0, 110.0, 9, 12.0, "Park Block"),
  )
  ignore(
    add_building(buildings, 486.0, 452.0, 140.0, 118.0, 11, 18.0, "Old Theater"),
  )
  ignore(
    add_building(buildings, 672.0, 458.0, 118.0, 110.0, 8, 12.0, "Sky Offices"),
  )
  ignore(
    add_building(
      buildings, 812.0, 448.0, 126.0, 120.0, 12, 20.0, "Delta Residences",
    ),
  )

  for i = 0; i < buildings.length(); i = i + 1 {
    if not(buildings[i].active) {
      continue
    }
    if buildings[i].fire < 1.0 {
      buildings[i].fire = randf(2.0, 8.0)
    }
  }
}

///|
fn add_drop(
  drops : Array[WaterDrop],
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  power : Float,
  life : Float,
  kind : Int,
) -> Bool {
  for i = 0; i < drops.length(); i = i + 1 {
    if not(drops[i].active) {
      drops[i].active = true
      drops[i].x = x
      drops[i].y = y
      drops[i].vx = vx
      drops[i].vy = vy
      drops[i].power = power
      drops[i].life = life
      drops[i].kind = kind
      return true
    }
  }
  false
}

///|
fn add_particle(
  parts : Array[Particle],
  x : Float,
  y : Float,
  kind : Int,
) -> Unit {
  for i = 0; i < parts.length(); i = i + 1 {
    if not(parts[i].active) {
      parts[i].active = true
      parts[i].kind = kind
      parts[i].x = x
      parts[i].y = y
      let a : Float = randf(0.0, 6.28318)
      let s : Float = randf(18.0, 220.0)
      parts[i].vx = @math.cosf(a) * s
      parts[i].vy = @math.sinf(a) * s
      parts[i].size = randf(2.0, 8.0)
      parts[i].life = randf(0.2, 0.9)
      parts[i].pulse = randf(0.0, 20.0)
      return
    }
  }
}

///|
fn burst_particles(
  parts : Array[Particle],
  x : Float,
  y : Float,
  n : Int,
  kind : Int,
) -> Unit {
  for _i = 0; _i < n; _i = _i + 1 {
    add_particle(parts, x, y, kind)
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

    parts[i].pulse = parts[i].pulse + dt
    parts[i].x = parts[i].x + parts[i].vx * dt
    parts[i].y = parts[i].y + parts[i].vy * dt
    parts[i].vx = parts[i].vx * (1.0 - dt * 2.4)
    parts[i].vy = parts[i].vy * (1.0 - dt * 2.2) + 10.0 * dt
  }
}

///|
fn draw_particles(parts : Array[Particle]) -> Unit {
  for i = 0; i < parts.length(); i = i + 1 {
    if not(parts[i].active) {
      continue
    }

    let c = if parts[i].kind == 0 {
      @raylib.Color::new(248, 226, 120, 238)
    } else if parts[i].kind == 1 {
      @raylib.Color::new(126, 210, 252, 238)
    } else if parts[i].kind == 2 {
      @raylib.Color::new(126, 236, 154, 238)
    } else {
      @raylib.Color::new(244, 126, 142, 238)
    }

    @raylib.draw_circle(
      parts[i].x.to_int(),
      parts[i].y.to_int(),
      parts[i].size * parts[i].life * 2.0,
      c,
    )
  }
}

///|
fn update_drops(
  drops : Array[WaterDrop],
  buildings : Array[Building],
  dt : Float,
  parts : Array[Particle],
) -> Float {
  let mut hit_power : Float = 0.0

  for i = 0; i < drops.length(); i = i + 1 {
    if not(drops[i].active) {
      continue
    }

    drops[i].life = drops[i].life - dt
    if drops[i].life <= 0.0 {
      drops[i].active = false
      continue
    }

    drops[i].x = drops[i].x + drops[i].vx * dt
    drops[i].y = drops[i].y + drops[i].vy * dt
    drops[i].vy = drops[i].vy + 240.0 * dt

    if drops[i].x < world_l - 40.0 ||
      drops[i].x > world_r + 40.0 ||
      drops[i].y > world_b + 40.0 {
      drops[i].active = false
      continue
    }

    let r : Float = if drops[i].kind == 0 { 4.0 } else { 6.0 }

    for b = 0; b < buildings.length(); b = b + 1 {
      if not(buildings[b].active) || buildings[b].collapsed {
        continue
      }

      if circle_rect_hit(
          drops[i].x,
          drops[i].y,
          r,
          buildings[b].x,
          buildings[b].y,
          buildings[b].w,
          buildings[b].h,
        ) {
        let cool : Float = drops[i].power
        buildings[b].fire = buildings[b].fire - cool
        if buildings[b].fire < 0.0 {
          buildings[b].fire = 0.0
        }
        hit_power = hit_power + cool

        burst_particles(parts, drops[i].x, drops[i].y, 3, 1)
        drops[i].active = false
        break
      }
    }
  }

  hit_power
}

///|
fn nearest_viable_building(
  buildings : Array[Building],
  x : Float,
  y : Float,
) -> Int {
  let mut best : Int = -1
  let mut best_d2 : Float = 99999999.0

  for i = 0; i < buildings.length(); i = i + 1 {
    if not(buildings[i].active) || buildings[i].collapsed {
      continue
    }

    let bx : Float = building_center_x(buildings[i])
    let by : Float = building_center_y(buildings[i])
    let d2 : Float = dist2(x, y, bx, by)
    if d2 < best_d2 {
      best_d2 = d2
      best = i
    }
  }

  best
}

///|
fn update_fire_system(
  buildings : Array[Building],
  dt : Float,
  tier : Int,
  parts : Array[Particle],
) -> (Int, Int, Int) {
  let mut active_fire_n : Int = 0
  let mut new_casualties : Int = 0
  let mut collapsed_n : Int = 0

  for i = 0; i < buildings.length(); i = i + 1 {
    if not(buildings[i].active) {
      continue
    }

    buildings[i].pulse = buildings[i].pulse + dt
    if buildings[i].pulse > 1000.0 {
      buildings[i].pulse = buildings[i].pulse - 1000.0
    }

    if buildings[i].collapsed {
      continue
    }

    let growth : Float = 0.9 + Float::from_int(tier) * 0.14 + randf(0.0, 0.35)
    buildings[i].fire = buildings[i].fire + growth * dt

    if buildings[i].fire > 0.2 {
      active_fire_n = active_fire_n + 1
    }

    buildings[i].integrity = buildings[i].integrity -
      buildings[i].fire * 0.055 * dt
    if buildings[i].integrity < 0.0 {
      buildings[i].integrity = 0.0
    }

    if buildings[i].people > 0 {
      let hazard : Float = buildings[i].fire - 54.0
      if hazard > 0.0 {
        let lose_prob : Int = (hazard * dt * 9.0).to_int() + 1
        if @raylib.get_random_value(0, 99) < clampi(lose_prob, 0, 70) {
          buildings[i].people = buildings[i].people - 1
          buildings[i].casualties = buildings[i].casualties + 1
          new_casualties = new_casualties + 1

          burst_particles(
            parts,
            building_center_x(buildings[i]),
            building_center_y(buildings[i]),
            4,
            3,
          )
        }
      }
    }

    buildings[i].spread_cd = buildings[i].spread_cd - dt
    if buildings[i].spread_cd <= 0.0 {
      buildings[i].spread_cd = randf(2.5, 5.4)
      if buildings[i].fire >= 52.0 {
        let target : Int = nearest_viable_building(
          buildings,
          building_center_x(buildings[i]),
          building_center_y(buildings[i]),
        )
        if target >= 0 && target != i {
          let d2 : Float = dist2(
            building_center_x(buildings[i]),
            building_center_y(buildings[i]),
            building_center_x(buildings[target]),
            building_center_y(buildings[target]),
          )
          if d2 <= 280.0 * 280.0 {
            buildings[target].fire = buildings[target].fire + randf(6.0, 12.0)
            if buildings[target].fire > 120.0 {
              buildings[target].fire = 120.0
            }
            burst_particles(
              parts,
              building_center_x(buildings[target]),
              building_center_y(buildings[target]),
              8,
              0,
            )
          }
        }
      }
    }

    buildings[i].emergency_cd = buildings[i].emergency_cd - dt
    if buildings[i].emergency_cd <= 0.0 {
      buildings[i].emergency_cd = randf(7.0, 15.0)
      if @raylib.get_random_value(0, 99) < clampi(26 + tier * 3, 0, 78) {
        buildings[i].people = buildings[i].people + 1
      }
    }

    if buildings[i].fire > 120.0 {
      buildings[i].fire = 120.0
    }

    if buildings[i].integrity <= 0.0 {
      buildings[i].collapsed = true
      collapsed_n = collapsed_n + 1
      buildings[i].fire = 0.0

      if buildings[i].people > 0 {
        new_casualties = new_casualties + buildings[i].people
        buildings[i].casualties = buildings[i].casualties + buildings[i].people
        buildings[i].people = 0
      }

      burst_particles(
        parts,
        building_center_x(buildings[i]),
        building_center_y(buildings[i]),
        26,
        3,
      )
    }
  }

  (active_fire_n, new_casualties, collapsed_n)
}

///|
fn try_rescue(
  heli : Helicopter,
  buildings : Array[Building],
  parts : Array[Particle],
) -> Int {
  if heli.passengers >= heli.capacity {
    return 0
  }

  let mut loaded : Int = 0

  for i = 0; i < buildings.length(); i = i + 1 {
    if not(buildings[i].active) || buildings[i].collapsed {
      continue
    }
    if buildings[i].people <= 0 {
      continue
    }
    if buildings[i].fire > 68.0 {
      continue
    }

    let bx : Float = building_center_x(buildings[i])
    let by : Float = building_center_y(buildings[i])
    let d2 : Float = dist2(heli.x, heli.y, bx, by)
    if d2 <= 72.0 * 72.0 {
      buildings[i].people = buildings[i].people - 1
      loaded = loaded + 1
      heli.passengers = heli.passengers + 1
      burst_particles(parts, bx, by, 5, 2)

      if heli.passengers >= heli.capacity {
        break
      }
    }
  }

  loaded
}

///|
fn draw_city_bg(t : Float) -> Unit {
  @raylib.draw_rectangle_gradient_v(
    world_l.to_int(),
    world_t.to_int(),
    (world_r - world_l).to_int(),
    (world_b - world_t).to_int(),
    @raylib.Color::new(30, 44, 70, 255),
    @raylib.Color::new(22, 30, 50, 255),
  )

  // roads
  let road_x : Int = world_l.to_int()
  for i = 0; i < 4; i = i + 1 {
    let y : Int = 94 + i * 168
    @raylib.draw_rectangle(
      road_x,
      y,
      (world_r - world_l).to_int(),
      22,
      @raylib.Color::new(40, 46, 62, 236),
    )
    for k = 0; k < 28; k = k + 1 {
      let x : Int = road_x + k * 38
      @raylib.draw_rectangle(
        x + (t * 120.0).to_int() % 38,
        y + 9,
        16,
        4,
        @raylib.Color::new(176, 184, 206, 182),
      )
    }
  }

  for i = 0; i < 5; i = i + 1 {
    let x : Int = 130 + i * 178
    @raylib.draw_rectangle(
      x,
      world_t.to_int(),
      22,
      (world_b - world_t).to_int(),
      @raylib.Color::new(40, 46, 62, 226),
    )
  }

  // skyline lights
  for i = 0; i < 44; i = i + 1 {
    let fi : Float = Float::from_int(i)
    let x : Int = (fi * 71.0 + t * (20.0 + Float::from_int(i % 6) * 7.0)).to_int() %
      (world_r - world_l).to_int() +
      world_l.to_int()
    let y : Int = (fi * 143.0 + t * 28.0).to_int() %
      (world_b - world_t).to_int() +
      world_t.to_int()
    @raylib.draw_circle(
      x,
      y,
      1.5 + Float::from_int(i % 3),
      @raylib.Color::new(132, 176, 236, 112),
    )
  }
}

///|
fn draw_special_zones() -> Unit {
  @raylib.draw_rectangle(
    reservoir_x,
    reservoir_y,
    reservoir_w,
    reservoir_h,
    @raylib.Color::new(64, 132, 214, 212),
  )
  @raylib.draw_rectangle_lines(
    reservoir_x,
    reservoir_y,
    reservoir_w,
    reservoir_h,
    @raylib.Color::new(196, 226, 252, 240),
  )
  @raylib.draw_text(
    "WATER RESERVOIR",
    reservoir_x + 20,
    reservoir_y + 8,
    24,
    @raylib.Color::new(238, 248, 255, 250),
  )
  @raylib.draw_text(
    "Hover here to refill",
    reservoir_x + 20,
    reservoir_y + 40,
    22,
    @raylib.Color::new(224, 238, 255, 236),
  )

  @raylib.draw_rectangle(
    hospital_x,
    hospital_y,
    hospital_w,
    hospital_h,
    @raylib.Color::new(86, 176, 122, 214),
  )
  @raylib.draw_rectangle_lines(
    hospital_x,
    hospital_y,
    hospital_w,
    hospital_h,
    @raylib.Color::new(208, 242, 220, 246),
  )
  @raylib.draw_text(
    "CITY HOSPITAL",
    hospital_x + 36,
    hospital_y + 8,
    26,
    @raylib.Color::new(240, 252, 244, 252),
  )
  @raylib.draw_text(
    "Drop rescued civilians",
    hospital_x + 24,
    hospital_y + 42,
    22,
    @raylib.Color::new(228, 248, 236, 238),
  )
}

///|
fn draw_buildings(buildings : Array[Building], t : Float) -> Unit {
  for i = 0; i < buildings.length(); i = i + 1 {
    if not(buildings[i].active) {
      continue
    }

    let bx : Int = buildings[i].x.to_int()
    let by : Int = buildings[i].y.to_int()
    let bw : Int = buildings[i].w.to_int()
    let bh : Int = buildings[i].h.to_int()

    let base = if buildings[i].collapsed {
      @raylib.Color::new(56, 44, 52, 226)
    } else {
      @raylib.Color::new(96, 106, 136, 232)
    }
    @raylib.draw_rectangle(bx, by, bw, bh, base)
    @raylib.draw_rectangle_lines(
      bx,
      by,
      bw,
      bh,
      @raylib.Color::new(218, 228, 248, 204),
    )

    // windows
    for wy = 0; wy < 4; wy = wy + 1 {
      for wx = 0; wx < 5; wx = wx + 1 {
        let px : Int = bx + 12 + wx * ((bw - 24) / 5)
        let py : Int = by + 12 + wy * ((bh - 24) / 4)

        let light = if buildings[i].collapsed {
          @raylib.Color::new(74, 74, 86, 160)
        } else if buildings[i].fire > 40.0 {
          @raylib.Color::new(252, 186, 96, 220)
        } else {
          @raylib.Color::new(196, 214, 246, 192)
        }
        @raylib.draw_rectangle(px, py, 8, 8, light)
      }
    }

    if not(buildings[i].collapsed) {
      let fire_n : Int = clampi((buildings[i].fire / 18.0).to_int(), 0, 7)
      for f = 0; f < fire_n; f = f + 1 {
        let fx : Float = buildings[i].x + randf(10.0, buildings[i].w - 10.0)
        let fy : Float = buildings[i].y + randf(8.0, buildings[i].h - 8.0)
        let rr : Float = 6.0 +
          randf(0.0, 8.0) +
          @math.sinf(t * 8.0 + Float::from_int(i + f)) * 2.0
        @raylib.draw_circle(
          fx.to_int(),
          fy.to_int(),
          rr,
          @raylib.Color::new(248, 134, 62, 238),
        )
        @raylib.draw_circle(
          fx.to_int(),
          fy.to_int(),
          rr * 0.55,
          @raylib.Color::new(252, 226, 132, 238),
        )
      }

      if buildings[i].fire > 0.0 {
        for s = 0; s < 3; s = s + 1 {
          let sx : Int = (buildings[i].x + randf(8.0, buildings[i].w - 8.0)).to_int()
          let sy : Int = (buildings[i].y -
          randf(8.0, 24.0) -
          Float::from_int(s) * 10.0).to_int()
          @raylib.draw_circle(
            sx,
            sy,
            8.0 + randf(0.0, 8.0),
            @raylib.Color::new(96, 98, 116, 138),
          )
        }
      }
    }

    if buildings[i].people > 0 {
      @raylib.draw_text(
        "\{buildings[i].people}",
        bx + bw - 26,
        by + 6,
        24,
        @raylib.Color::new(242, 252, 244, 248),
      )
    }

    let hpw : Int = (buildings[i].integrity * Float::from_int(bw - 8) / 100.0).to_int()
    @raylib.draw_rectangle(
      bx + 4,
      by + bh - 10,
      bw - 8,
      6,
      @raylib.Color::new(18, 26, 36, 240),
    )
    let hp_col = if buildings[i].integrity > 65.0 {
      @raylib.Color::new(136, 232, 164, 236)
    } else if buildings[i].integrity > 35.0 {
      @raylib.Color::new(246, 216, 126, 236)
    } else {
      @raylib.Color::new(246, 126, 142, 236)
    }
    @raylib.draw_rectangle(bx + 4, by + bh - 10, hpw, 6, hp_col)

    if buildings[i].collapsed {
      @raylib.draw_text(
        "COLLAPSED",
        bx + 12,
        by + bh / 2 - 12,
        22,
        @raylib.Color::new(252, 208, 214, 242),
      )
    }
  }
}

///|
fn draw_drops(drops : Array[WaterDrop]) -> Unit {
  for i = 0; i < drops.length(); i = i + 1 {
    if not(drops[i].active) {
      continue
    }

    let c = if drops[i].kind == 0 {
      @raylib.Color::new(118, 212, 252, 238)
    } else {
      @raylib.Color::new(146, 228, 255, 248)
    }

    @raylib.draw_circle(
      drops[i].x.to_int(),
      drops[i].y.to_int(),
      3.0 + drops[i].power * 0.2,
      c,
    )
  }
}

///|
fn draw_helicopter(heli : Helicopter, t : Float) -> Unit {
  let bob : Float = @math.sinf(t * 8.0 + heli.wobble) * 2.0
  let x : Float = heli.x
  let y : Float = heli.y + bob

  // rotor
  let rot_w : Float = 48.0 + @math.sinf(t * 18.0) * 8.0
  @raylib.draw_line_ex(
    @raylib.Vector2::new(x - rot_w, y - 24.0),
    @raylib.Vector2::new(x + rot_w, y - 24.0),
    4.0,
    @raylib.Color::new(236, 242, 250, 246),
  )

  @raylib.draw_circle(
    x.to_int(),
    y.to_int(),
    16.0,
    @raylib.Color::new(242, 214, 108, 248),
  )
  @raylib.draw_circle(
    x.to_int(),
    y.to_int(),
    11.0,
    @raylib.Color::new(64, 78, 112, 248),
  )
  @raylib.draw_rectangle(
    (x - 28.0).to_int(),
    (y + 8.0).to_int(),
    56,
    9,
    @raylib.Color::new(194, 206, 224, 232),
  )

  @raylib.draw_circle(
    (x - 8.0).to_int(),
    (y - 2.0).to_int(),
    4.0,
    @raylib.Color::new(228, 240, 255, 250),
  )
  @raylib.draw_circle(
    (x + 6.0).to_int(),
    (y - 2.0).to_int(),
    4.0,
    @raylib.Color::new(228, 240, 255, 250),
  )

  if heli.passengers > 0 {
    @raylib.draw_text(
      "\{heli.passengers}",
      (x + 18.0).to_int(),
      (y - 8.0).to_int(),
      20,
      @raylib.Color::new(246, 246, 252, 252),
    )
  }
}

///|
fn draw_touch_ui() -> Unit {
  let pad_x : Int = 28
  let pad_y : Int = sh - 194

  @raylib.draw_rectangle(
    pad_x + 84,
    pad_y,
    76,
    58,
    @raylib.Color::new(80, 102, 154, 160),
  )
  @raylib.draw_rectangle(
    pad_x,
    pad_y + 68,
    76,
    58,
    @raylib.Color::new(80, 102, 154, 160),
  )
  @raylib.draw_rectangle(
    pad_x + 84,
    pad_y + 68,
    76,
    58,
    @raylib.Color::new(80, 102, 154, 160),
  )
  @raylib.draw_rectangle(
    pad_x + 168,
    pad_y + 68,
    76,
    58,
    @raylib.Color::new(80, 102, 154, 160),
  )
  @raylib.draw_rectangle(
    pad_x + 84,
    pad_y + 136,
    76,
    58,
    @raylib.Color::new(80, 102, 154, 160),
  )

  @raylib.draw_text(
    "UP",
    pad_x + 107,
    pad_y + 16,
    24,
    @raylib.Color::new(234, 242, 255, 240),
  )
  @raylib.draw_text(
    "LT",
    pad_x + 24,
    pad_y + 84,
    24,
    @raylib.Color::new(234, 242, 255, 240),
  )
  @raylib.draw_text(
    "RT",
    pad_x + 188,
    pad_y + 84,
    24,
    @raylib.Color::new(234, 242, 255, 240),
  )
  @raylib.draw_text(
    "DN",
    pad_x + 103,
    pad_y + 152,
    24,
    @raylib.Color::new(234, 242, 255, 240),
  )

  let fire_x : Int = sw - 292
  let fire_y : Int = sh - 180
  @raylib.draw_circle(
    fire_x,
    fire_y,
    62.0,
    @raylib.Color::new(242, 118, 106, 176),
  )
  @raylib.draw_text(
    "DROP",
    fire_x - 36,
    fire_y - 14,
    28,
    @raylib.Color::new(248, 244, 244, 248),
  )

  let rescue_x : Int = sw - 160
  let rescue_y : Int = sh - 246
  @raylib.draw_circle(
    rescue_x,
    rescue_y,
    54.0,
    @raylib.Color::new(118, 202, 132, 176),
  )
  @raylib.draw_text(
    "RES",
    rescue_x - 24,
    rescue_y - 14,
    28,
    @raylib.Color::new(244, 252, 246, 248),
  )
}

///|
fn main {
  @raylib.init_window(sw, sh, "raylib [game] skyline fire rescue 2026")
  @raylib.set_target_fps(60)

  let heli : Helicopter = {
    x: 220.0,
    y: 220.0,
    vx: 0.0,
    vy: 0.0,
    water: 100.0,
    water_max: 100.0,
    passengers: 0,
    capacity: 6,
    fire_cd: 0.0,
    rescue_cd: 0.0,
    wobble: randf(0.0, 30.0),
  }

  let buildings : Array[Building] = Array::makei(max_buildings, fn(_i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      w: 0.0,
      h: 0.0,
      fire: 0.0,
      integrity: 0.0,
      people: 0,
      casualties: 0,
      spread_cd: 0.0,
      emergency_cd: 0.0,
      collapsed: false,
      pulse: 0.0,
      name: "",
    }
  })

  let drops : Array[WaterDrop] = Array::makei(max_drops, fn(_i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      power: 0.0,
      life: 0.0,
      kind: 0,
    }
  })

  let parts : Array[Particle] = Array::makei(max_particles, fn(_i) {
    {
      active: false,
      kind: 0,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      size: 0.0,
      life: 0.0,
      pulse: 0.0,
    }
  })

  let mut state : Int = 0 // 0 menu 1 play 2 win 3 lose
  let mut timer : Float = 300.0
  let mut rescued_total : Int = 0
  let mut casualties_total : Int = 0
  let mut collapsed_total : Int = 0
  let mut score : Int = 0
  let mut tier : Int = 1

  let mut msg : String = ""
  let mut msg_t : Float = 0.0
  let mut scene_t : Float = 0.0
  let mut event_cd : Float = 8.0

  fn reset_run() -> Unit {
    setup_city(buildings)
    clear_drops(drops)
    clear_particles(parts)

    heli.x = 220.0
    heli.y = 220.0
    heli.vx = 0.0
    heli.vy = 0.0
    heli.water = 100.0
    heli.water_max = 100.0
    heli.passengers = 0
    heli.capacity = 6
    heli.fire_cd = 0.0
    heli.rescue_cd = 0.0

    timer = 300.0
    rescued_total = 0
    casualties_total = 0
    collapsed_total = 0
    score = 0
    tier = 1

    msg = "Dispatch ready"
    msg_t = 2.0
    event_cd = 8.0
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

    let mouse = @raylib.get_mouse_position()
    let click : Bool = @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft)
    let hold : Bool = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft)

    scene_t = scene_t + dt
    while scene_t > 100000.0 {
      scene_t = scene_t - 100000.0
    }

    if msg_t > 0.0 {
      msg_t = msg_t - dt
      if msg_t < 0.0 {
        msg_t = 0.0
      }
    }

    update_particles(parts, dt)

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

      tier = 1 + rescued_total / 12
      if tier > 8 {
        tier = 8
      }

      heli.fire_cd = heli.fire_cd - dt
      if heli.fire_cd < 0.0 {
        heli.fire_cd = 0.0
      }

      heli.rescue_cd = heli.rescue_cd - dt
      if heli.rescue_cd < 0.0 {
        heli.rescue_cd = 0.0
      }

      // input
      let mut move_l : Bool = @raylib.is_key_down(@raylib.KeyA) ||
        @raylib.is_key_down(@raylib.KeyLeft)
      let mut move_r : Bool = @raylib.is_key_down(@raylib.KeyD) ||
        @raylib.is_key_down(@raylib.KeyRight)
      let mut move_u : Bool = @raylib.is_key_down(@raylib.KeyW) ||
        @raylib.is_key_down(@raylib.KeyUp)
      let mut move_d : Bool = @raylib.is_key_down(@raylib.KeyS) ||
        @raylib.is_key_down(@raylib.KeyDown)

      let mut fire_action : Bool = @raylib.is_key_down(@raylib.KeyJ) ||
        @raylib.is_key_down(@raylib.KeySpace)
      let mut rescue_action : Bool = @raylib.is_key_pressed(@raylib.KeyK) ||
        @raylib.is_key_pressed(@raylib.KeyH)

      if hold {
        let pad_x : Int = 28
        let pad_y : Int = sh - 194
        if inside_rect(mouse.x, mouse.y, pad_x + 84, pad_y, 76, 58) {
          move_u = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x, pad_y + 68, 76, 58) {
          move_l = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 168, pad_y + 68, 76, 58) {
          move_r = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 84, pad_y + 136, 76, 58) {
          move_d = true
        }

        let fire_x : Float = Float::from_int(sw - 292)
        let fire_y : Float = Float::from_int(sh - 180)
        if dist2(mouse.x, mouse.y, fire_x, fire_y) <= 62.0 * 62.0 {
          fire_action = true
        }
      }

      if click {
        let rescue_x : Float = Float::from_int(sw - 160)
        let rescue_y : Float = Float::from_int(sh - 246)
        if dist2(mouse.x, mouse.y, rescue_x, rescue_y) <= 54.0 * 54.0 {
          rescue_action = true
        }
      }

      // helicopter movement
      let acc : Float = 460.0
      if move_l {
        heli.vx = heli.vx - acc * dt
      }
      if move_r {
        heli.vx = heli.vx + acc * dt
      }
      if move_u {
        heli.vy = heli.vy - acc * dt
      }
      if move_d {
        heli.vy = heli.vy + acc * dt
      }

      let drag : Float = 5.2
      heli.vx = heli.vx * (1.0 - dt * drag)
      heli.vy = heli.vy * (1.0 - dt * drag)

      let speed_max : Float = 240.0
      let sp2 : Float = heli.vx * heli.vx + heli.vy * heli.vy
      if sp2 > speed_max * speed_max {
        let inv : Float = speed_max / sp2.sqrt()
        heli.vx = heli.vx * inv
        heli.vy = heli.vy * inv
      }

      heli.x = heli.x + heli.vx * dt
      heli.y = heli.y + heli.vy * dt

      heli.x = clampf(heli.x, world_l + 20.0, world_r - 20.0)
      heli.y = clampf(heli.y, world_t + 20.0, world_b - 20.0)

      // water refill at reservoir
      if inside_rect(
          heli.x,
          heli.y,
          reservoir_x,
          reservoir_y,
          reservoir_w,
          reservoir_h,
        ) {
        heli.water = heli.water + dt * 36.0
        if heli.water > heli.water_max {
          heli.water = heli.water_max
        }
      }

      // deliver passengers at hospital
      if heli.passengers > 0 &&
        inside_rect(
          heli.x,
          heli.y,
          hospital_x,
          hospital_y,
          hospital_w,
          hospital_h,
        ) {
        rescued_total = rescued_total + heli.passengers
        score = score + heli.passengers * 55
        burst_particles(parts, heli.x, heli.y, 12 + heli.passengers * 2, 2)
        msg = "Delivered \{heli.passengers} civilians"
        msg_t = 1.2
        heli.passengers = 0
      }

      // rescue action
      if rescue_action && heli.rescue_cd <= 0.0 {
        let loaded : Int = try_rescue(heli, buildings, parts)
        if loaded > 0 {
          score = score + loaded * 20
          msg = "Rescued \{loaded} civilians"
          msg_t = 1.0
        } else {
          msg = "No safe rescue target"
          msg_t = 0.8
        }
        heli.rescue_cd = 0.42
      }

      // fire water action
      if fire_action && heli.fire_cd <= 0.0 && heli.water >= 2.0 {
        let n : Int = 6 + @raylib.get_random_value(0, 3)
        for i = 0; i < n; i = i + 1 {
          let ax : Float = randf(-0.6, 0.6)
          let vx : Float = ax * 80.0 + heli.vx * 0.3
          let vy : Float = randf(120.0, 210.0)
          ignore(
            add_drop(
              drops,
              heli.x + randf(-8.0, 8.0),
              heli.y + 12.0,
              vx,
              vy,
              randf(2.5, 4.2),
              randf(0.5, 0.9),
              0,
            ),
          )
        }
        heli.water = heli.water - 2.0
        if heli.water < 0.0 {
          heli.water = 0.0
        }
        heli.fire_cd = 0.12
      }

      let hit_power : Float = update_drops(drops, buildings, dt, parts)
      if hit_power > 0.0 {
        score = score + hit_power.to_int()
      }

      let (active_fires, casualties_new, collapsed_new) = update_fire_system(
        buildings, dt, tier, parts,
      )
      casualties_total = casualties_total + casualties_new
      collapsed_total = collapsed_total + collapsed_new

      if casualties_new > 0 {
        score = score - casualties_new * 30
      }

      if collapsed_new > 0 {
        msg = "\{collapsed_new} building(s) collapsed"
        msg_t = 1.4
      }

      event_cd = event_cd - dt
      if event_cd <= 0.0 {
        event_cd = randf(8.0, 14.0)
        let bid : Int = @raylib.get_random_value(0, buildings.length() - 1)
        if buildings[bid].active && not(buildings[bid].collapsed) {
          buildings[bid].fire = buildings[bid].fire + randf(8.0, 18.0)
          if buildings[bid].fire > 120.0 {
            buildings[bid].fire = 120.0
          }
          buildings[bid].people = buildings[bid].people +
            @raylib.get_random_value(0, 2)
          burst_particles(
            parts,
            building_center_x(buildings[bid]),
            building_center_y(buildings[bid]),
            12,
            0,
          )
          msg = "New fire spike at \{buildings[bid].name}"
          msg_t = 1.1
        }
      }

      if rescued_total >= 42 {
        state = 2
        msg = "City stabilized"
        msg_t = 3.0
        burst_particles(
          parts,
          Float::from_int(sw / 2),
          Float::from_int(sh / 2),
          70,
          2,
        )
      } else if timer <= 0.0 {
        state = 3
        msg = "Time over"
        msg_t = 3.0
      } else if casualties_total >= 34 {
        state = 3
        msg = "Casualties too high"
        msg_t = 3.0
      }

      if active_fires <= 2 && rescued_total >= 24 && timer > 120.0 {
        score = score + 1
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
    @raylib.clear_background(@raylib.Color::new(8, 12, 18, 255))

    draw_city_bg(scene_t)
    draw_special_zones()
    draw_buildings(buildings, scene_t)
    draw_drops(drops)
    draw_helicopter(heli, scene_t)
    draw_particles(parts)

    @raylib.draw_rectangle(
      984,
      24,
      354,
      720,
      @raylib.Color::new(16, 22, 34, 244),
    )
    @raylib.draw_rectangle_lines(
      984,
      24,
      354,
      720,
      @raylib.Color::new(164, 188, 230, 242),
    )

    @raylib.draw_text(
      "SKYLINE FIRE RESCUE",
      1002,
      44,
      34,
      @raylib.Color::new(236, 246, 255, 252),
    )
    @raylib.draw_text(
      "Extinguish, rescue, deliver",
      1004,
      82,
      22,
      @raylib.Color::new(188, 214, 252, 238),
    )

    @raylib.draw_text(
      "Timer",
      1004,
      130,
      24,
      @raylib.Color::new(224, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{timer.to_int()}s",
      1126,
      130,
      32,
      @raylib.Color::new(248, 228, 148, 252),
    )

    @raylib.draw_text(
      "Rescued",
      1004,
      172,
      24,
      @raylib.Color::new(224, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{rescued_total}/42",
      1126,
      172,
      32,
      @raylib.Color::new(136, 224, 164, 252),
    )

    @raylib.draw_text(
      "Casualties",
      1004,
      214,
      24,
      @raylib.Color::new(224, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{casualties_total}/34",
      1126,
      214,
      32,
      @raylib.Color::new(244, 132, 148, 252),
    )

    @raylib.draw_text(
      "Collapses",
      1004,
      256,
      24,
      @raylib.Color::new(224, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{collapsed_total}",
      1126,
      256,
      32,
      @raylib.Color::new(244, 176, 134, 252),
    )

    @raylib.draw_text(
      "Tier",
      1004,
      298,
      24,
      @raylib.Color::new(224, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{tier}",
      1126,
      298,
      32,
      @raylib.Color::new(252, 218, 126, 252),
    )

    @raylib.draw_text(
      "Score",
      1004,
      340,
      24,
      @raylib.Color::new(224, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{score}",
      1126,
      340,
      32,
      @raylib.Color::new(134, 210, 252, 252),
    )

    @raylib.draw_text(
      "Water",
      1004,
      388,
      24,
      @raylib.Color::new(220, 236, 252, 246),
    )
    @raylib.draw_rectangle(
      1004,
      418,
      312,
      24,
      @raylib.Color::new(24, 32, 48, 255),
    )
    let w01 : Float = clampf(heli.water / heli.water_max, 0.0, 1.0)
    let wf : Int = (Float::from_int(312) * w01).to_int()
    @raylib.draw_rectangle(
      1004,
      418,
      wf,
      24,
      @raylib.Color::new(118, 212, 252, 250),
    )
    @raylib.draw_rectangle_lines(
      1004,
      418,
      312,
      24,
      @raylib.Color::new(186, 212, 250, 246),
    )
    @raylib.draw_text(
      "\{heli.water.to_int()}/\{heli.water_max.to_int()}",
      1120,
      446,
      24,
      @raylib.Color::new(224, 240, 255, 246),
    )

    @raylib.draw_text(
      "Passengers",
      1004,
      484,
      24,
      @raylib.Color::new(224, 236, 252, 246),
    )
    @raylib.draw_text(
      "\{heli.passengers}/\{heli.capacity}",
      1140,
      484,
      30,
      @raylib.Color::new(224, 248, 228, 252),
    )

    @raylib.draw_text(
      "Controls",
      1004,
      544,
      28,
      @raylib.Color::new(236, 246, 255, 252),
    )
    @raylib.draw_text(
      "WASD/Arrows: move",
      1004,
      578,
      22,
      @raylib.Color::new(200, 222, 252, 238),
    )
    @raylib.draw_text(
      "Space/J: water drop",
      1004,
      606,
      22,
      @raylib.Color::new(200, 222, 252, 238),
    )
    @raylib.draw_text(
      "K/H or button: rescue",
      1004,
      634,
      22,
      @raylib.Color::new(200, 222, 252, 238),
    )
    @raylib.draw_text(
      "Mobile: tap controls",
      1004,
      662,
      22,
      @raylib.Color::new(200, 222, 252, 238),
    )

    draw_touch_ui()

    if msg_t > 0.0 {
      let bw : Int = @raylib.measure_text(msg, 30) + 44
      let bx : Int = sw / 2 - bw / 2
      @raylib.draw_rectangle(
        bx,
        20,
        bw,
        52,
        @raylib.Color::new(12, 18, 28, 224),
      )
      @raylib.draw_rectangle_lines(
        bx,
        20,
        bw,
        52,
        @raylib.Color::new(184, 208, 246, 246),
      )
      @raylib.draw_text(
        msg,
        bx + 22,
        32,
        30,
        @raylib.Color::new(236, 244, 255, 252),
      )
    }

    if state == 0 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(8, 12, 20, 204))
      @raylib.draw_text(
        "SKYLINE FIRE RESCUE",
        sw / 2 - 334,
        150,
        74,
        @raylib.Color::new(238, 246, 255, 255),
      )
      @raylib.draw_text(
        "Arcade rescue simulation",
        sw / 2 - 176,
        244,
        38,
        @raylib.Color::new(196, 220, 252, 252),
      )

      @raylib.draw_rectangle(
        sw / 2 - 468,
        320,
        936,
        240,
        @raylib.Color::new(16, 24, 40, 236),
      )
      @raylib.draw_rectangle_lines(
        sw / 2 - 468,
        320,
        936,
        240,
        @raylib.Color::new(166, 196, 246, 246),
      )

      @raylib.draw_text(
        "Desktop",
        sw / 2 - 434,
        350,
        32,
        @raylib.Color::new(242, 246, 255, 252),
      )
      @raylib.draw_text(
        "- Fly to fires and cool them down",
        sw / 2 - 434,
        390,
        28,
        @raylib.Color::new(210, 228, 252, 248),
      )
      @raylib.draw_text(
        "- Rescue people and deliver to hospital",
        sw / 2 - 434,
        424,
        28,
        @raylib.Color::new(210, 228, 252, 248),
      )
      @raylib.draw_text(
        "- Refill water at reservoir",
        sw / 2 - 434,
        458,
        28,
        @raylib.Color::new(210, 228, 252, 248),
      )

      @raylib.draw_text(
        "Mobile",
        sw / 2 + 74,
        350,
        32,
        @raylib.Color::new(242, 246, 255, 252),
      )
      @raylib.draw_text(
        "- Hold D-pad to move",
        sw / 2 + 74,
        390,
        28,
        @raylib.Color::new(210, 228, 252, 248),
      )
      @raylib.draw_text(
        "- Tap DROP and RES buttons",
        sw / 2 + 74,
        424,
        28,
        @raylib.Color::new(210, 228, 252, 248),
      )
      @raylib.draw_text(
        "- Fully touch-playable",
        sw / 2 + 74,
        458,
        28,
        @raylib.Color::new(210, 228, 252, 248),
      )

      @raylib.draw_rectangle(
        sw / 2 - 190,
        604,
        380,
        92,
        @raylib.Color::new(96, 138, 216, 246),
      )
      @raylib.draw_rectangle_lines(
        sw / 2 - 190,
        604,
        380,
        92,
        @raylib.Color::new(230, 240, 255, 252),
      )
      @raylib.draw_text(
        "START MISSION",
        sw / 2 - 120,
        638,
        42,
        @raylib.Color::new(244, 248, 255, 252),
      )
    } else if state == 2 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(8, 18, 10, 196))
      @raylib.draw_text(
        "CITY SAVED",
        sw / 2 - 184,
        194,
        88,
        @raylib.Color::new(162, 246, 180, 252),
      )
      @raylib.draw_text(
        "Rescued \{rescued_total} civilians",
        sw / 2 - 206,
        324,
        42,
        @raylib.Color::new(232, 248, 236, 252),
      )
      @raylib.draw_text(
        "Score \{score}",
        sw / 2 - 84,
        376,
        38,
        @raylib.Color::new(244, 232, 160, 248),
      )
      @raylib.draw_text(
        "Tap or Enter to restart",
        sw / 2 - 170,
        460,
        34,
        @raylib.Color::new(218, 234, 252, 246),
      )
    } else if state == 3 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(24, 8, 14, 204))
      @raylib.draw_text(
        "MISSION FAILED",
        sw / 2 - 268,
        194,
        86,
        @raylib.Color::new(252, 162, 178, 252),
      )
      @raylib.draw_text(
        "Rescued \{rescued_total}/42",
        sw / 2 - 160,
        324,
        42,
        @raylib.Color::new(242, 232, 236, 252),
      )
      @raylib.draw_text(
        "Casualties \{casualties_total}",
        sw / 2 - 138,
        376,
        38,
        @raylib.Color::new(248, 214, 158, 248),
      )
      @raylib.draw_text(
        "Tap or Enter to retry",
        sw / 2 - 160,
        460,
        34,
        @raylib.Color::new(218, 234, 252, 246),
      )
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
