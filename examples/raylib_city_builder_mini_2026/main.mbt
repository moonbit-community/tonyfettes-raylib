///|
let gw : Int = 16

///|
let gh : Int = 12

///|
let cell : Int = 44

///|
let ox : Int = 36

///|
let oy : Int = 90

///|
let sw : Int = ox * 2 + gw * cell

///|
let sh : Int = 700

///|
fn gidx(x : Int, y : Int) -> Int {
  y * gw + x
}

///|
fn inb(x : Int, y : Int) -> Bool {
  x >= 0 && x < gw && y >= 0 && y < gh
}

///|
fn zone_cost(tool : Int) -> Int {
  match tool {
    1 => 5 // road
    2 => 22 // residential
    3 => 30 // commercial
    4 => 36 // industrial
    _ => 0
  }
}

///|
fn zone_color(zone : Int) -> @raylib.Color {
  match zone {
    1 => @raylib.darkgray
    2 => @raylib.green
    3 => @raylib.blue
    4 => @raylib.orange
    _ => @raylib.Color::new(52, 90, 52, 255)
  }
}

///|
fn terrain_color(t : Int) -> @raylib.Color {
  if t == 1 {
    @raylib.Color::new(92, 92, 102, 255)
  } else {
    @raylib.Color::new(74, 120, 74, 255)
  }
}

///|
fn adjacent_roads(zone : Array[Int], x : Int, y : Int) -> Int {
  let dirs : Array[(Int, Int)] = [(-1, 0), (1, 0), (0, -1), (0, 1)]
  let mut count = 0
  for i = 0; i < dirs.length(); i = i + 1 {
    let (dx, dy) = dirs[i]
    let nx = x + dx
    let ny = y + dy
    if inb(nx, ny) && zone[gidx(nx, ny)] == 1 {
      count = count + 1
    }
  }
  count
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
fn regen_world(terrain : Array[Int], zone : Array[Int]) -> Unit {
  for y = 0; y < gh; y = y + 1 {
    for x = 0; x < gw; x = x + 1 {
      let i = gidx(x, y)
      terrain[i] = if @raylib.get_random_value(0, 99) < 10 { 1 } else { 0 }
      zone[i] = 0
    }
  }
  terrain[gidx(2, 2)] = 0
  terrain[gidx(3, 2)] = 0
  terrain[gidx(2, 3)] = 0
}

///|
fn main {
  @raylib.init_window(sw, sh, "City Builder Mini 2026")
  @raylib.set_target_fps(60)

  let terrain : Array[Int] = Array::make(gw * gh, 0)
  let zone : Array[Int] = Array::make(gw * gh, 0)
  regen_world(terrain, zone)

  let mut money = 420
  let mut population = 0
  let mut happiness = 55
  let mut day = 1
  let mut tool = 1
  let mut tick : Float = 0.0
  let mut lost = false
  let mut won = false

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      regen_world(terrain, zone)
      money = 420
      population = 0
      happiness = 55
      day = 1
      tool = 1
      tick = 0.0
      lost = false
      won = false
    }

    if @raylib.is_key_pressed(@raylib.KeyZero) {
      tool = 0
    }
    if @raylib.is_key_pressed(@raylib.KeyOne) {
      tool = 1
    }
    if @raylib.is_key_pressed(@raylib.KeyTwo) {
      tool = 2
    }
    if @raylib.is_key_pressed(@raylib.KeyThree) {
      tool = 3
    }
    if @raylib.is_key_pressed(@raylib.KeyFour) {
      tool = 4
    }

    if not(lost) && not(won) {
      if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
        let mx = @raylib.get_mouse_x()
        let my = @raylib.get_mouse_y()
        let gx = (mx - ox) / cell
        let gy = (my - oy) / cell
        if inb(gx, gy) {
          let i = gidx(gx, gy)
          if tool == 0 {
            zone[i] = 0
          } else if terrain[i] == 0 {
            let cost = zone_cost(tool)
            if money >= cost {
              zone[i] = tool
              money = money - cost
            }
          }
        }
      }

      tick = tick + dt
      if tick >= 1.0 {
        tick = tick - 1.0
        day = day + 1

        let mut roads = 0
        let mut res_cap = 0
        let mut comm = 0
        let mut ind = 0
        let mut serviced = 0

        for y = 0; y < gh; y = y + 1 {
          for x = 0; x < gw; x = x + 1 {
            let z = zone[gidx(x, y)]
            if z == 1 {
              roads = roads + 1
            }
            if z == 2 {
              if adjacent_roads(zone, x, y) > 0 {
                res_cap = res_cap + 10
                serviced = serviced + 1
              } else {
                res_cap = res_cap + 3
              }
            }
            if z == 3 {
              comm = comm + 1
            }
            if z == 4 {
              ind = ind + 1
            }
          }
        }

        let jobs = comm * 12 + ind * 16
        let target_pop = if res_cap < jobs + 20 { res_cap } else { jobs + 20 }
        let delta_pop = clampi(target_pop - population, -8, 12)
        population = population + delta_pop
        if population < 0 {
          population = 0
        }

        happiness = 50 + serviced * 2 - ind * 2
        happiness = clampi(happiness, 5, 95)

        let income = population / 4 + comm * 5 + ind * 6 + happiness / 8
        let upkeep = roads + comm * 2 + ind * 2
        money = money + income - upkeep

        if money < -500 {
          lost = true
        }
        if population >= 450 && money >= 1200 {
          won = true
        }
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(18, 22, 28, 255))

    for y = 0; y < gh; y = y + 1 {
      for x = 0; x < gw; x = x + 1 {
        let i = gidx(x, y)
        let px = ox + x * cell
        let py = oy + y * cell
        @raylib.draw_rectangle(px, py, cell, cell, terrain_color(terrain[i]))
        if zone[i] != 0 {
          @raylib.draw_rectangle(
            px + 5,
            py + 5,
            cell - 10,
            cell - 10,
            zone_color(zone[i]),
          )
        }
        @raylib.draw_rectangle_lines(
          px,
          py,
          cell,
          cell,
          @raylib.Color::new(30, 30, 36, 255),
        )
      }
    }

    @raylib.draw_text("CITY BUILDER MINI 2026", 20, 18, 34, @raylib.yellow)
    @raylib.draw_text("Day: \{day}", 24, 58, 24, @raylib.raywhite)
    @raylib.draw_text("Money: \{money}", 170, 58, 24, @raylib.gold)
    @raylib.draw_text(
      "Population: \{population}",
      360,
      58,
      24,
      @raylib.raywhite,
    )
    @raylib.draw_text("Happiness: \{happiness}", 620, 58, 24, @raylib.lime)

    let tool_name = match tool {
      0 => "Bulldoze"
      1 => "Road"
      2 => "Residential"
      3 => "Commercial"
      4 => "Industrial"
      _ => ""
    }
    @raylib.draw_text("Tool: \{tool_name}", 24, 630, 24, @raylib.skyblue)
    @raylib.draw_text(
      "0 bulldoze | 1 road | 2 res | 3 com | 4 ind | click to build | R restart",
      260, 630, 22, @raylib.gray,
    )

    if won || lost {
      @raylib.draw_rectangle(
        300,
        280,
        460,
        130,
        @raylib.fade(@raylib.black, 0.78),
      )
      @raylib.draw_text(
        if won {
          "CITY THRIVES"
        } else {
          "CITY BANKRUPT"
        },
        365,
        318,
        44,
        if won {
          @raylib.lime
        } else {
          @raylib.red
        },
      )
      @raylib.draw_text("Press R to restart", 430, 366, 26, @raylib.raywhite)
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
