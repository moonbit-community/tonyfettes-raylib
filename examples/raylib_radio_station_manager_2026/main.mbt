///|
let sw : Int = 1120

///|
let sh : Int = 740

///|
struct Song {
  mood : Int // 0 chill, 1 pop, 2 rock, 3 classic
  len : Float
  energy : Int
}

///|
fn mood_name(m : Int) -> String {
  if m == 0 {
    "Chill"
  } else if m == 1 {
    "Pop"
  } else if m == 2 {
    "Rock"
  } else {
    "Classic"
  }
}

///|
fn mood_color(m : Int) -> @raylib.Color {
  if m == 0 {
    @raylib.skyblue
  } else if m == 1 {
    @raylib.pink
  } else if m == 2 {
    @raylib.red
  } else {
    @raylib.gold
  }
}

///|
fn random_song() -> Song {
  let m = @raylib.get_random_value(0, 3)
  let l = Float::from_int(@raylib.get_random_value(6, 11))
  let e = @raylib.get_random_value(30, 95)
  { mood: m, len: l, energy: e }
}

///|
fn take_song(queue : Array[Song], slot : Int) -> Song {
  let picked = queue[slot]
  if slot <= 0 {
    queue[0] = queue[1]
  }
  if slot <= 1 {
    queue[1] = queue[2]
  }
  if slot <= 2 {
    queue[2] = queue[3]
  }
  queue[3] = random_song()
  picked
}

///|
fn main {
  @raylib.init_window(sw, sh, "Radio Station Manager 2026")
  @raylib.set_target_fps(60)

  let mut queue : Array[Song] = [random_song(), random_song(), random_song(), random_song()]
  let mut current : Song = take_song(queue, 0)
  let mut current_time : Float = current.len

  let mut listeners = 62
  let mut ad_budget = 50
  let mut rating = 50
  let mut trend : Float = 0.0

  let mut shift_time : Float = 180.0
  let mut ad_cd : Float = 0.0
  let mut over = false
  let mut msg = "1-4 play queued track, A ad break (+budget, -listeners), R restart"

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      queue = [random_song(), random_song(), random_song(), random_song()]
      current = take_song(queue, 0)
      current_time = current.len
      listeners = 62
      ad_budget = 50
      rating = 50
      trend = 0.0
      shift_time = 180.0
      ad_cd = 0.0
      over = false
      msg = "Broadcast shift restarted."
    }

    if not(over) {
      shift_time = shift_time - dt
      if shift_time <= 0.0 {
        shift_time = 0.0
        over = true
        msg = "Broadcast complete."
      }

      ad_cd = ad_cd - dt
      if ad_cd < 0.0 {
        ad_cd = 0.0
      }

      if @raylib.is_key_pressed(@raylib.KeyA) && ad_cd <= 0.0 {
        ad_cd = 9.0
        ad_budget = ad_budget + 14
        listeners = listeners - 5
        rating = rating - 2
        msg = "Ad break aired."
      }

      // Schedule selected queue slot into current track
      if @raylib.is_key_pressed(@raylib.KeyOne) {
        current = take_song(queue, 0)
        current_time = current.len
        msg = "Track 1 queued now."
      }
      if @raylib.is_key_pressed(@raylib.KeyTwo) {
        current = take_song(queue, 1)
        current_time = current.len
        msg = "Track 2 queued now."
      }
      if @raylib.is_key_pressed(@raylib.KeyThree) {
        current = take_song(queue, 2)
        current_time = current.len
        msg = "Track 3 queued now."
      }
      if @raylib.is_key_pressed(@raylib.KeyFour) {
        current = take_song(queue, 3)
        current_time = current.len
        msg = "Track 4 queued now."
      }

      current_time = current_time - dt
      if current_time <= 0.0 {
        current = take_song(queue, 0)
        current_time = current.len
        msg = "Auto switched to next track."
      }

      // Listener model
      let desired = if shift_time > 120.0 {
        1
      } else if shift_time > 70.0 {
        2
      } else {
        0
      }

      let mood_delta : Float =
        if current.mood == desired { (2.2 : Float) } else { (-1.6 : Float) }
      let energy_target = if desired == 2 { 75 } else if desired == 1 { 62 } else { 45 }
      let energy_delta : Float =
        if (current.energy - energy_target).abs() <= 14 {
          (1.5 : Float)
        } else {
          (-1.1 : Float)
        }

      trend = trend + (mood_delta + energy_delta) * dt
      trend = trend - dt * (0.8 : Float)

      if trend > 3.0 {
        listeners = listeners + 1
        rating = rating + 1
        trend = 1.0
      }
      if trend < -3.0 {
        listeners = listeners - 1
        rating = rating - 1
        trend = -1.0
      }

      if listeners < 0 {
        listeners = 0
      }
      if listeners > 120 {
        listeners = 120
      }
      if rating < 0 {
        rating = 0
      }
      if rating > 100 {
        rating = 100
      }

      ad_budget = ad_budget + listeners / 70
      if ad_budget > 999 {
        ad_budget = 999
      }

      if listeners <= 0 {
        over = true
        msg = "No audience left."
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(21, 20, 30, 255))

    @raylib.draw_rectangle(0, 0, sw, 120, @raylib.Color::new(34, 34, 52, 255))
    @raylib.draw_text("RADIO STATION MANAGER 2026", 20, 20, 38, @raylib.skyblue)
    @raylib.draw_text("Listeners \{listeners}", 20, 68, 28, @raylib.white)
    @raylib.draw_text("Rating \{rating}", 240, 68, 28, @raylib.lime)
    @raylib.draw_text("Budget \{ad_budget}", 420, 68, 28, @raylib.gold)

    let st = shift_time.to_int()
    @raylib.draw_text("Time \{st}s", 620, 68, 30, if st < 25 { @raylib.red } else { @raylib.orange })

    // Current live deck
    @raylib.draw_rectangle(40, 160, 500, 220, @raylib.Color::new(32, 38, 56, 255))
    @raylib.draw_text("LIVE NOW", 60, 178, 30, @raylib.white)
    @raylib.draw_text("Mood: \{mood_name(current.mood)}", 60, 222, 30, mood_color(current.mood))
    @raylib.draw_text("Energy: \{current.energy}", 60, 266, 28, @raylib.raywhite)
    @raylib.draw_text("Remain: \{current_time.to_int()}s", 60, 304, 28, @raylib.raywhite)
    @raylib.draw_circle(460, 270, 42.0, mood_color(current.mood))

    // Queue board
    @raylib.draw_rectangle(580, 160, 500, 420, @raylib.Color::new(30, 34, 50, 255))
    @raylib.draw_text("QUEUE", 600, 178, 30, @raylib.white)

    for i = 0; i < queue.length(); i = i + 1 {
      let y = 220 + i * 80
      let s = queue[i]
      @raylib.draw_rectangle(608, y, 450, 64, @raylib.Color::new(44, 50, 72, 255))
      @raylib.draw_text("\{i + 1}", 620, y + 16, 30, @raylib.yellow)
      @raylib.draw_text("\{mood_name(s.mood)}", 670, y + 16, 28, mood_color(s.mood))
      @raylib.draw_text("E\{s.energy}", 840, y + 16, 24, @raylib.raywhite)
      @raylib.draw_text("\{s.len.to_int()}s", 930, y + 16, 24, @raylib.raywhite)
    }

    @raylib.draw_text("Desired mood now changes over shift (Pop -> Rock -> Chill)", 40, 612, 24, @raylib.lightgray)
    @raylib.draw_rectangle(20, 686, sw - 40, 30, @raylib.Color::new(10, 14, 20, 220))
    @raylib.draw_text(msg, 28, 691, 20, @raylib.raywhite)

    if over {
      @raylib.draw_rectangle(280, 250, 560, 190, @raylib.fade(@raylib.black, 0.82))
      @raylib.draw_text("SHIFT OVER", 430, 320, 56, @raylib.orange)
      @raylib.draw_text("Press R to restart", 440, 386, 34, @raylib.white)
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
