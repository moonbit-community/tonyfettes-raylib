// ── Layout constants ──────────────────────────────────────────────────────────

///|
const TARGET_URL : String = "https://example.com"

///|
const SCREEN_WIDTH : Int = 960

///|
const SCREEN_HEIGHT : Int = 620

///|
const FONT_SIZE : Int = 14

///|
const LINE_HEIGHT : Int = 18

///|
const HEADER_H : Int = 40

///|
const FOOTER_H : Int = 28

///|
const MARGIN : Int = 8

///|
const MAX_LINE_CHARS : Int = 130

// ── Mutable app state (safe: async runtime is single-threaded) ────────────────

///|
struct AppState {
  mut loading : Bool
  mut lines : Array[String]
  mut status : String
  mut scroll : Int
}

///|
fn split_lines(content : String, max_chars : Int) -> Array[String] {
  let lines : Array[String] = []
  let line : StringBuilder = StringBuilder::new()
  let mut n = 0
  for content_elem in content {
    let ch = content_elem.to_int().unsafe_to_char()
    if ch == '\n' {
      lines.push(line.to_string())
      line.reset()
      n = 0
    } else if ch != '\r' && n < max_chars {
      line.write_char(ch)
      n += 1
    }
  }
  let last = line.to_string()
  if last.length() > 0 {
    lines.push(last)
  }
  lines
}

///|
async fn main {
  @raylib.init_window(
    SCREEN_WIDTH,
    SCREEN_HEIGHT,
    "raylib - async network demo",
  )
  @raylib.set_target_fps(60)
  defer @raylib.close_window()

  let state : AppState = {
    loading: true,
    lines: [],
    status: "Fetching \{TARGET_URL} ...",
    scroll: 0,
  }

  @async.with_task_group(group => {
    // ── HTTP fetch task ────────────────────────────────────────────────────
    group.spawn_bg(() => {
      try {
        let (_resp, body) = @http.get_stream(TARGET_URL)
        defer body.close()
        let text = body.read_all().text() catch {
            _ => "(could not decode response body as UTF-8)"
          }
        state.lines = split_lines(text, MAX_LINE_CHARS)
        state.status = "\{state.lines.length()} lines from \{TARGET_URL}"
      } catch {
        e => state.status = "Fetch error: \{e}"
      }
      state.loading = false
    })

    // ── Render loop ────────────────────────────────────────────────────────
    let visible = (SCREEN_HEIGHT - HEADER_H - FOOTER_H) / LINE_HEIGHT
    while not(@raylib.window_should_close()) {
      @async.pause()

      let total = state.lines.length()
      let max_scroll = if total > visible { total - visible } else { 0 }

      // Input: arrow keys and mouse wheel scrolling
      if @raylib.is_key_pressed(@raylib.KeyDown) ||
        @raylib.is_key_pressed_repeat(@raylib.KeyDown) {
        state.scroll = if state.scroll < max_scroll {
          state.scroll + 1
        } else {
          max_scroll
        }
      }
      if @raylib.is_key_pressed(@raylib.KeyUp) ||
        @raylib.is_key_pressed_repeat(@raylib.KeyUp) {
        state.scroll = if state.scroll > 0 { state.scroll - 1 } else { 0 }
      }
      if @raylib.is_key_pressed(@raylib.KeyPageDown) {
        let n = state.scroll + visible
        state.scroll = if n < max_scroll { n } else { max_scroll }
      }
      if @raylib.is_key_pressed(@raylib.KeyPageUp) {
        let n = state.scroll - visible
        state.scroll = if n > 0 { n } else { 0 }
      }
      let wheel = @raylib.get_mouse_wheel_move()
      if wheel != 0.0 {
        let d = state.scroll - wheel.to_int()
        state.scroll = if d < 0 {
          0
        } else if d > max_scroll {
          max_scroll
        } else {
          d
        }
      }

      @raylib.begin_drawing()
      @raylib.clear_background(@raylib.raywhite)

      // Header bar
      @raylib.draw_rectangle(0, 0, SCREEN_WIDTH, HEADER_H, @raylib.darkblue)
      @raylib.draw_text(
        "GET \{TARGET_URL}",
        MARGIN,
        (HEADER_H - FONT_SIZE) / 2,
        FONT_SIZE,
        @raylib.white,
      )

      // Content area
      if state.loading {
        let tw = @raylib.measure_text(state.status, 20)
        @raylib.draw_text(
          state.status,
          (SCREEN_WIDTH - tw) / 2,
          SCREEN_HEIGHT / 2 - 10,
          20,
          @raylib.gray,
        )
      } else {
        let end_line = if state.scroll + visible < total {
          state.scroll + visible
        } else {
          total
        }
        for idx in state.scroll..<end_line {
          let y = HEADER_H + (idx - state.scroll) * LINE_HEIGHT
          @raylib.draw_text(
            state.lines[idx],
            MARGIN,
            y,
            FONT_SIZE,
            @raylib.darkgray,
          )
        }

        // Footer bar
        let footer_y = SCREEN_HEIGHT - FOOTER_H
        @raylib.draw_rectangle(
          0,
          footer_y,
          SCREEN_WIDTH,
          FOOTER_H,
          @raylib.lightgray,
        )
        @raylib.draw_text(
          "\{state.status}  |  \{state.scroll + 1}-\{end_line}  |  arrows/scroll",
          MARGIN,
          footer_y + (FOOTER_H - FONT_SIZE) / 2,
          FONT_SIZE,
          @raylib.darkgray,
        )
      }

      @raylib.end_drawing()
      // Render loop exited → with_task_group cancels HTTP task automatically
    }
  })
}
