///|
let sw : Int = 1100

///|
let sh : Int = 700

///|
struct Platform {
  x : Int
  y : Int
  w : Int
  h : Int
}

///|
struct Spike {
  x : Int
  y : Int
  w : Int
  h : Int
}

///|
fn hit(ax : Int, ay : Int, aw : Int, ah : Int, bx : Int, by : Int, bw : Int, bh : Int) -> Bool {
  not(ax + aw < bx || ax > bx + bw || ay + ah < by || ay > by + bh)
}

///|
fn main {
  @raylib.init_window(sw, sh, "Platformer Precision 2026")
  @raylib.set_target_fps(60)

  let platforms : Array[Platform] = [
    { x: 0, y: 630, w: 4200, h: 80 },
    { x: 280, y: 560, w: 180, h: 20 },
    { x: 540, y: 510, w: 150, h: 20 },
    { x: 820, y: 465, w: 170, h: 20 },
    { x: 1160, y: 520, w: 170, h: 20 },
    { x: 1470, y: 450, w: 210, h: 20 },
    { x: 1780, y: 395, w: 160, h: 20 },
    { x: 2100, y: 340, w: 210, h: 20 },
    { x: 2460, y: 300, w: 130, h: 20 },
    { x: 2720, y: 350, w: 170, h: 20 },
    { x: 3020, y: 290, w: 190, h: 20 },
    { x: 3350, y: 250, w: 180, h: 20 },
  ]

  let spikes : Array[Spike] = [
    { x: 470, y: 620, w: 90, h: 10 },
    { x: 720, y: 620, w: 90, h: 10 },
    { x: 1000, y: 620, w: 100, h: 10 },
    { x: 1390, y: 620, w: 120, h: 10 },
    { x: 1960, y: 620, w: 130, h: 10 },
    { x: 2320, y: 620, w: 130, h: 10 },
    { x: 2900, y: 620, w: 150, h: 10 },
    { x: 3250, y: 620, w: 110, h: 10 },
  ]

  let checkpoints : Array[Int] = [80, 1000, 2050, 3000]
  let mut cp = 0

  let mut spawn_x = checkpoints[0]
  let spawn_y = 560
  let mut px = spawn_x
  let mut py = spawn_y
  let mut vx = 0
  let mut vy = 0
  let pw = 30
  let ph = 44

  let mut deaths = 0
  let mut won = false

  while not(@raylib.window_should_close()) {
    if @raylib.is_key_pressed(@raylib.KeyR) {
      cp = 0
      spawn_x = checkpoints[0]
      px = spawn_x
      py = spawn_y
      vx = 0
      vy = 0
      deaths = 0
      won = false
    }

    if not(won) {
      vx = 0
      if @raylib.is_key_down(@raylib.KeyLeft) || @raylib.is_key_down(@raylib.KeyA) {
        vx = -6
      }
      if @raylib.is_key_down(@raylib.KeyRight) || @raylib.is_key_down(@raylib.KeyD) {
        vx = 6
      }

      let mut grounded = false
      for i = 0; i < platforms.length(); i = i + 1 {
        let p = platforms[i]
        if px + pw > p.x + 2 && px < p.x + p.w - 2 && py + ph <= p.y + 4 &&
          py + ph >= p.y - 10 {
          grounded = true
        }
      }

      if grounded && (@raylib.is_key_pressed(@raylib.KeySpace) || @raylib.is_key_pressed(@raylib.KeyUp) || @raylib.is_key_pressed(@raylib.KeyW)) {
        vy = -19
      }

      vy = vy + 1
      if vy > 20 {
        vy = 20
      }

      let mut nx = px + vx
      let mut ny = py + vy

      for i = 0; i < platforms.length(); i = i + 1 {
        let p = platforms[i]
        if hit(nx, py, pw, ph, p.x, p.y, p.w, p.h) {
          if vx > 0 {
            nx = p.x - pw - 1
          } else if vx < 0 {
            nx = p.x + p.w + 1
          }
        }
      }

      for i = 0; i < platforms.length(); i = i + 1 {
        let p = platforms[i]
        if hit(nx, ny, pw, ph, p.x, p.y, p.w, p.h) {
          if vy > 0 && py + ph <= p.y + 12 {
            ny = p.y - ph - 1
            vy = 0
          } else if vy < 0 && py >= p.y + p.h - 8 {
            ny = p.y + p.h + 1
            vy = 0
          }
        }
      }

      px = nx
      py = ny

      for i = 0; i < checkpoints.length(); i = i + 1 {
        if i > cp && px >= checkpoints[i] {
          cp = i
          spawn_x = checkpoints[i]
        }
      }

      let mut dead = py > 700
      for i = 0; i < spikes.length(); i = i + 1 {
        let s = spikes[i]
        if hit(px, py, pw, ph, s.x, s.y, s.w, s.h) {
          dead = true
        }
      }

      if dead {
        deaths = deaths + 1
        px = spawn_x
        py = spawn_y
        vx = 0
        vy = 0
      }

      if px >= 3780 {
        won = true
      }
    }

    let mut cam_x = px - 350
    if cam_x < 0 {
      cam_x = 0
    }
    if cam_x > 3100 {
      cam_x = 3100
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(144, 194, 234, 255))

    for i = 0; i < platforms.length(); i = i + 1 {
      let p = platforms[i]
      @raylib.draw_rectangle(p.x - cam_x, p.y, p.w, p.h, @raylib.Color::new(84, 74, 62, 255))
    }

    for i = 0; i < spikes.length(); i = i + 1 {
      let s = spikes[i]
      @raylib.draw_rectangle(s.x - cam_x, s.y, s.w, s.h, @raylib.red)
    }

    @raylib.draw_rectangle(3800 - cam_x, 180, 24, 120, @raylib.yellow)
    @raylib.draw_rectangle(px - cam_x, py, pw, ph, @raylib.blue)

    @raylib.draw_text("PLATFORMER PRECISION 2026", 20, 16, 34, @raylib.darkblue)
    @raylib.draw_text("Checkpoint: \{cp + 1}/\{checkpoints.length()}", 24, 54, 24, @raylib.black)
    @raylib.draw_text("Deaths: \{deaths}", 380, 54, 24, @raylib.black)
    @raylib.draw_text("A/D move | SPACE jump | R restart", 700, 20, 22, @raylib.darkgray)

    if won {
      @raylib.draw_rectangle(310, 280, 480, 130, @raylib.fade(@raylib.black, 0.75))
      @raylib.draw_text("COURSE CLEARED", 390, 318, 46, @raylib.lime)
      @raylib.draw_text("Press R to run again", 424, 366, 26, @raylib.raywhite)
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
