///|
let sw : Int = 1020

///|
let sh : Int = 720

///|
let goods_count : Int = 5

///|
let planet_count : Int = 6

///|
let good_names : FixedArray[String] = ["Ore", "Food", "Tech", "Med", "Fuel"]

///|
let planet_names : FixedArray[String] = [
  "Astra Port",
  "Neon Bay",
  "Dust Colony",
  "Lumen Ring",
  "Frost Relay",
  "Echo Prime",
]

///|
fn wealth(cash : Int, cargo : Array[Int], prices : Array[Int], at : Int) -> Int {
  let mut v = cash
  for g = 0; g < goods_count; g = g + 1 {
    v = v + cargo[g] * prices[at * goods_count + g]
  }
  v
}

///|
fn roll_prices(prices : Array[Int], day : Int) -> Unit {
  for p = 0; p < planet_count; p = p + 1 {
    for g = 0; g < goods_count; g = g + 1 {
      let base = match g {
        0 => 52
        1 => 36
        2 => 84
        3 => 72
        _ => 41
      }
      let seed = (day * 37 + p * 53 + g * 97 + @raylib.get_random_value(0, 999)) % 100
      let mut delta = seed - 50
      if p == 2 && g == 0 {
        delta = delta - 18
      }
      if p == 1 && g == 2 {
        delta = delta - 22
      }
      if p == 4 && g == 1 {
        delta = delta - 15
      }
      let val = base + delta
      prices[p * goods_count + g] = if val < 8 { 8 } else { val }
    }
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
fn main {
  @raylib.init_window(sw, sh, "Space Trader 2026")
  @raylib.set_target_fps(60)

  let prices : Array[Int] = Array::make(planet_count * goods_count, 0)
  let cargo : Array[Int] = Array::make(goods_count, 0)

  let mut day = 1
  let mut fuel = 12
  let mut cash = 900
  let mut hp = 100
  let mut cargo_cap = 26
  let mut at = 0
  let mut target = 1
  let mut selected_good = 0
  let mut log = "Welcome captain. Buy low, sell high."
  let mut won = false
  let mut lost = false

  roll_prices(prices, day)

  while not(@raylib.window_should_close()) {
    if @raylib.is_key_pressed(@raylib.KeyR) {
      day = 1
      fuel = 12
      cash = 900
      hp = 100
      cargo_cap = 26
      at = 0
      target = 1
      selected_good = 0
      for i = 0; i < cargo.length(); i = i + 1 {
        cargo[i] = 0
      }
      won = false
      lost = false
      log = "New contract accepted."
      roll_prices(prices, day)
    }

    if not(won) && not(lost) {
      if @raylib.is_key_pressed(@raylib.KeyUp) {
        selected_good = clampi(selected_good - 1, 0, goods_count - 1)
      }
      if @raylib.is_key_pressed(@raylib.KeyDown) {
        selected_good = clampi(selected_good + 1, 0, goods_count - 1)
      }
      if @raylib.is_key_pressed(@raylib.KeyLeft) {
        target = clampi(target - 1, 0, planet_count - 1)
      }
      if @raylib.is_key_pressed(@raylib.KeyRight) {
        target = clampi(target + 1, 0, planet_count - 1)
      }

      let price = prices[at * goods_count + selected_good]

      if @raylib.is_key_pressed(@raylib.KeyB) {
        let mut used = 0
        for g = 0; g < goods_count; g = g + 1 {
          used = used + cargo[g]
        }
        if used >= cargo_cap {
          log = "Cargo hold full."
        } else if cash < price {
          log = "Not enough credits."
        } else {
          cash = cash - price
          cargo[selected_good] = cargo[selected_good] + 1
          log = "Bought 1 \{good_names[selected_good]} for \{price}."
        }
      }

      if @raylib.is_key_pressed(@raylib.KeyS) {
        if cargo[selected_good] <= 0 {
          log = "No cargo to sell."
        } else {
          cargo[selected_good] = cargo[selected_good] - 1
          cash = cash + price
          log = "Sold 1 \{good_names[selected_good]} for \{price}."
        }
      }

      if @raylib.is_key_pressed(@raylib.KeyT) {
        if target == at {
          log = "Already docked there."
        } else if fuel <= 0 {
          log = "Out of fuel."
        } else {
          let dist = (target - at).abs()
          let fuel_cost = if dist > 2 { 2 } else { 1 }
          if fuel < fuel_cost {
            log = "Need \{fuel_cost} fuel."
          } else {
            fuel = fuel - fuel_cost
            at = target
            day = day + 1
            roll_prices(prices, day)
            log = "Jumped to \{planet_names[at]}."

            // Random encounter
            let roll = @raylib.get_random_value(0, 99)
            if roll < 18 {
              let dmg = @raylib.get_random_value(6, 18)
              hp = hp - dmg
              log = "Pirate skirmish! Hull -\{dmg}."
            } else if roll > 90 {
              let bonus = @raylib.get_random_value(60, 150)
              cash = cash + bonus
              log = "Courier tip +\{bonus} credits."
            }
          }
        }
      }

      if @raylib.is_key_pressed(@raylib.KeyN) {
        day = day + 1
        roll_prices(prices, day)
        if fuel > 0 {
          fuel = fuel - 1
        }
        log = "A quiet day passes."
      }

      if @raylib.is_key_pressed(@raylib.KeyF) {
        let cost = prices[at * goods_count + 4]
        if cash >= cost {
          cash = cash - cost
          fuel = fuel + 1
          log = "Bought 1 fuel for \{cost}."
        } else {
          log = "Not enough credits for fuel."
        }
      }

      if @raylib.is_key_pressed(@raylib.KeyH) {
        let cost = 120
        if cash >= cost && hp < 100 {
          cash = cash - cost
          hp = hp + 15
          if hp > 100 {
            hp = 100
          }
          log = "Dock repair complete."
        } else {
          log = "Repair unavailable."
        }
      }

      let net = wealth(cash, cargo, prices, at)
      if net >= 7000 {
        won = true
        log = "Contract complete. You built a fortune."
      }
      if hp <= 0 || day > 80 || (fuel <= 0 && cash < prices[at * goods_count + 4]) {
        lost = true
        log = "Expedition failed."
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(10, 12, 20, 255))

    @raylib.draw_text("SPACE TRADER 2026", 20, 16, 36, @raylib.skyblue)
    @raylib.draw_text("Day \{day}", 24, 58, 24, @raylib.raywhite)
    @raylib.draw_text("Dock: \{planet_names[at]}", 140, 58, 24, @raylib.raywhite)
    @raylib.draw_text("Cash \{cash}", 450, 58, 24, @raylib.gold)
    @raylib.draw_text("Fuel \{fuel}", 620, 58, 24, @raylib.orange)
    @raylib.draw_text("Hull \{hp}", 760, 58, 24, @raylib.lime)

    @raylib.draw_rectangle(24, 100, 430, 470, @raylib.Color::new(22, 26, 38, 255))
    @raylib.draw_text("Commodities @ current dock", 36, 114, 24, @raylib.lightgray)
    for g = 0; g < goods_count; g = g + 1 {
      let y = 160 + g * 72
      if g == selected_good {
        @raylib.draw_rectangle(36, y - 10, 404, 58, @raylib.fade(@raylib.darkblue, 0.5))
      }
      let p = prices[at * goods_count + g]
      @raylib.draw_text("\{good_names[g]}", 44, y, 28, @raylib.raywhite)
      @raylib.draw_text("Price \{p}", 220, y, 26, @raylib.orange)
      @raylib.draw_text("Cargo \{cargo[g]}", 330, y, 26, @raylib.lime)
    }

    @raylib.draw_rectangle(480, 100, 510, 260, @raylib.Color::new(22, 26, 38, 255))
    @raylib.draw_text("Navigation", 494, 114, 24, @raylib.lightgray)
    for p = 0; p < planet_count; p = p + 1 {
      let y = 152 + p * 30
      let color = if p == at {
        @raylib.lime
      } else if p == target {
        @raylib.yellow
      } else {
        @raylib.raywhite
      }
      @raylib.draw_text("\{p}. \{planet_names[p]}", 496, y, 24, color)
    }

    let net_worth = wealth(cash, cargo, prices, at)
    @raylib.draw_text("Net worth: \{net_worth} / 7000", 494, 340, 24, @raylib.skyblue)

    @raylib.draw_rectangle(480, 380, 510, 190, @raylib.Color::new(22, 26, 38, 255))
    @raylib.draw_text("Controls", 494, 394, 24, @raylib.lightgray)
    @raylib.draw_text("UP/DOWN select good", 494, 426, 22, @raylib.gray)
    @raylib.draw_text("B buy, S sell", 494, 452, 22, @raylib.gray)
    @raylib.draw_text("LEFT/RIGHT select planet", 494, 478, 22, @raylib.gray)
    @raylib.draw_text("T travel, N next day", 494, 504, 22, @raylib.gray)
    @raylib.draw_text("F buy fuel, H repair, R restart", 494, 530, 22, @raylib.gray)

    @raylib.draw_rectangle(24, 590, 966, 92, @raylib.Color::new(22, 26, 38, 255))
    @raylib.draw_text(log, 40, 622, 26, @raylib.raywhite)

    if won || lost {
      @raylib.draw_rectangle(300, 250, 440, 130, @raylib.fade(@raylib.black, 0.82))
      @raylib.draw_text(if won { "MISSION SUCCESS" } else { "MISSION FAILED" }, 340, 288, 42, if won { @raylib.lime } else { @raylib.red })
      @raylib.draw_text("Press R to restart", 410, 336, 26, @raylib.raywhite)
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
