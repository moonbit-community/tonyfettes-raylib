///|
let sw : Int = 1080

///|
let sh : Int = 700

///|
let lanes : Int = 3

///|
fn lane_y(lane : Int) -> Int {
  180 + lane * 170
}

///|
struct Unit {
  mut alive : Bool
  mut team : Int
  mut kind : Int
  mut lane : Int
  mut x : Float
  mut hp : Int
  mut atk : Int
  mut range : Float
  mut speed : Float
  mut cooldown : Float
}

///|
fn spawn_unit(units : Array[Unit], team : Int, kind : Int, lane : Int) -> Bool {
  let mut slot = -1
  for i = 0; i < units.length(); i = i + 1 {
    if slot < 0 && not(units[i].alive) {
      slot = i
    }
  }
  if slot < 0 {
    false
  } else {
    units[slot].alive = true
    units[slot].team = team
    units[slot].kind = kind
    units[slot].lane = lane
    units[slot].x = if team == 0 { 110.0 } else { Float::from_int(sw - 110) }
    if kind == 0 {
      units[slot].hp = 34
      units[slot].atk = 7
      units[slot].range = 26.0
      units[slot].speed = 58.0
    } else {
      units[slot].hp = 24
      units[slot].atk = 9
      units[slot].range = 120.0
      units[slot].speed = 46.0
    }
    units[slot].cooldown = 0.0
    true
  }
}

///|
fn closest_enemy(units : Array[Unit], me : Int) -> Int {
  let mut best = -1
  let mut best_d : Float = 1_000_000.0
  for i = 0; i < units.length(); i = i + 1 {
    if i == me || not(units[i].alive) {
      continue
    }
    if units[i].team == units[me].team || units[i].lane != units[me].lane {
      continue
    }
    let d = (units[i].x - units[me].x).abs()
    if d < best_d {
      best_d = d
      best = i
    }
  }
  best
}

///|
fn main {
  @raylib.init_window(sw, sh, "RTS Skirmish 2026")
  @raylib.set_target_fps(60)

  let units : Array[Unit] = Array::makei(240, fn(_i) {
    {
      alive: false,
      team: 0,
      kind: 0,
      lane: 0,
      x: 0.0,
      hp: 0,
      atk: 0,
      range: 0.0,
      speed: 0.0,
      cooldown: 0.0,
    }
  })

  let mut player_base_hp = 320
  let mut enemy_base_hp = 320
  let mut player_workers = 2
  let mut enemy_workers = 2
  let mut player_res = 120
  let mut enemy_res = 120
  let mut gather_tick : Float = 0.0

  let mut lane_select = 1
  let mut enemy_ai_tick : Float = 0.0
  let mut msg = "Q worker | W swordsman | E ranger | 1/2/3 lane"
  let mut won = false
  let mut lost = false

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      for i = 0; i < units.length(); i = i + 1 {
        units[i].alive = false
      }
      player_base_hp = 320
      enemy_base_hp = 320
      player_workers = 2
      enemy_workers = 2
      player_res = 120
      enemy_res = 120
      gather_tick = 0.0
      lane_select = 1
      enemy_ai_tick = 0.0
      msg = "Skirmish restarted"
      won = false
      lost = false
    }

    if not(won) && not(lost) {
      if @raylib.is_key_pressed(@raylib.KeyOne) {
        lane_select = 0
      }
      if @raylib.is_key_pressed(@raylib.KeyTwo) {
        lane_select = 1
      }
      if @raylib.is_key_pressed(@raylib.KeyThree) {
        lane_select = 2
      }

      if @raylib.is_key_pressed(@raylib.KeyQ) {
        if player_res >= 45 {
          player_res = player_res - 45
          player_workers = player_workers + 1
          msg = "Trained 1 worker."
        }
      }
      if @raylib.is_key_pressed(@raylib.KeyW) {
        if player_res >= 70 {
          player_res = player_res - 70
          ignore(spawn_unit(units, 0, 0, lane_select))
          msg = "Spawned swordsman in lane \{lane_select + 1}."
        }
      }
      if @raylib.is_key_pressed(@raylib.KeyE) {
        if player_res >= 90 {
          player_res = player_res - 90
          ignore(spawn_unit(units, 0, 1, lane_select))
          msg = "Spawned ranger in lane \{lane_select + 1}."
        }
      }

      // Resource economy
      gather_tick = gather_tick + dt
      if gather_tick >= 1.0 {
        gather_tick = gather_tick - 1.0
        player_res = player_res + player_workers * 5
        enemy_res = enemy_res + enemy_workers * 5
      }

      // Enemy AI production
      enemy_ai_tick = enemy_ai_tick + dt
      if enemy_ai_tick >= 1.3 {
        enemy_ai_tick = enemy_ai_tick - 1.3
        let lane = @raylib.get_random_value(0, lanes - 1)
        let pick = @raylib.get_random_value(0, 99)
        if pick < 20 && enemy_res >= 45 {
          enemy_res = enemy_res - 45
          enemy_workers = enemy_workers + 1
        } else if pick < 70 && enemy_res >= 70 {
          enemy_res = enemy_res - 70
          ignore(spawn_unit(units, 1, 0, lane))
        } else if enemy_res >= 90 {
          enemy_res = enemy_res - 90
          ignore(spawn_unit(units, 1, 1, lane))
        }
      }

      for i = 0; i < units.length(); i = i + 1 {
        if not(units[i].alive) {
          continue
        }
        units[i].cooldown = units[i].cooldown - dt

        let target = closest_enemy(units, i)
        if target >= 0 {
          let d = (units[target].x - units[i].x).abs()
          if d <= units[i].range {
            if units[i].cooldown <= 0.0 {
              units[i].cooldown = 0.6
              units[target].hp = units[target].hp - units[i].atk
              if units[target].hp <= 0 {
                units[target].alive = false
                if units[i].team == 0 {
                  player_res = player_res + 8
                } else {
                  enemy_res = enemy_res + 8
                }
              }
            }
          } else {
            let dir : Float =
              if units[i].team == 0 { (1.0 : Float) } else { (-1.0 : Float) }
            units[i].x = units[i].x + dir * units[i].speed * dt
          }
        } else {
          let dir : Float =
            if units[i].team == 0 { (1.0 : Float) } else { (-1.0 : Float) }
          units[i].x = units[i].x + dir * units[i].speed * dt
        }

        if units[i].team == 0 && units[i].x > Float::from_int(sw - 80) {
          enemy_base_hp = enemy_base_hp - units[i].atk * 2
          units[i].alive = false
        }
        if units[i].team == 1 && units[i].x < 80.0 {
          player_base_hp = player_base_hp - units[i].atk * 2
          units[i].alive = false
        }
      }

      if player_base_hp <= 0 {
        lost = true
      }
      if enemy_base_hp <= 0 {
        won = true
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(22, 24, 30, 255))

    for l = 0; l < lanes; l = l + 1 {
      let y = lane_y(l)
      @raylib.draw_rectangle(40, y - 44, sw - 80, 88, @raylib.Color::new(56, 64, 56, 255))
      @raylib.draw_line(40, y, sw - 40, y, @raylib.darkgreen)
      if l == lane_select {
        @raylib.draw_rectangle_lines(36, y - 48, sw - 72, 96, @raylib.yellow)
      }
    }

    // Bases
    @raylib.draw_rectangle(20, 250, 60, 200, @raylib.blue)
    @raylib.draw_rectangle(sw - 80, 250, 60, 200, @raylib.red)

    for i = 0; i < units.length(); i = i + 1 {
      if units[i].alive {
        let y = lane_y(units[i].lane)
        let color = if units[i].team == 0 {
          if units[i].kind == 0 { @raylib.skyblue } else { @raylib.lime }
        } else {
          if units[i].kind == 0 { @raylib.maroon } else { @raylib.orange }
        }
        @raylib.draw_circle(units[i].x.to_int(), y, 12.0, color)
        @raylib.draw_text("\{units[i].hp}", units[i].x.to_int() - 10, y - 26, 18, @raylib.white)
      }
    }

    @raylib.draw_text("RTS SKIRMISH 2026", 20, 16, 34, @raylib.skyblue)
    @raylib.draw_text("Base HP \{player_base_hp} vs \{enemy_base_hp}", 24, 56, 24, @raylib.raywhite)
    @raylib.draw_text("Workers \{player_workers}  Res \{player_res}", 360, 56, 24, @raylib.lime)
    @raylib.draw_text("Enemy workers \{enemy_workers}", 650, 56, 24, @raylib.orange)
    @raylib.draw_text("Q worker(45)  W swordsman(70)  E ranger(90)  1/2/3 lane", 120, 620, 24, @raylib.gray)

    @raylib.draw_rectangle(36, 654, sw - 72, 32, @raylib.Color::new(28, 30, 36, 255))
    @raylib.draw_text(msg, 48, 660, 20, @raylib.raywhite)

    if won || lost {
      @raylib.draw_rectangle(320, 270, 440, 120, @raylib.fade(@raylib.black, 0.8))
      @raylib.draw_text(if won { "ENEMY BASE DOWN" } else { "YOUR BASE FALLS" }, 350, 304, 42, if won { @raylib.lime } else { @raylib.red })
      @raylib.draw_text("Press R to restart", 420, 352, 26, @raylib.raywhite)
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
