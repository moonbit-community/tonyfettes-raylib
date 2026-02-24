///|
let screen_w : Int = 1500

///|
let screen_h : Int = 900

///|
let target_fps : Int = 120

///|
let state_title : Int = 0

///|
let state_play : Int = 1

///|
let state_stage_clear : Int = 2

///|
let state_failed : Int = 3

///|
let state_victory : Int = 4

///|
let stage_total : Int = 3

///|
let world_x : Float = 40.0

///|
let world_y : Float = 70.0

///|
let world_w : Float = 1020.0

///|
let world_h : Float = 790.0

///|
let player_w : Float = 34.0

///|
let player_h : Float = 34.0

///|
let player_speed_walk : Float = 260.0

///|
let player_speed_dash : Float = 520.0

///|
let stamina_max : Float = 100.0

///|
let stamina_drain_per_s : Float = 44.0

///|
let stamina_recover_per_s : Float = 28.0

///|
let dash_min_stamina : Float = 8.0

///|
let relic_stamina_bonus : Float = 12.0

///|
let trap_kind_spike : Int = 0

///|
let trap_kind_dart : Int = 1

///|
let hazard_kind_lava : Int = 0

///|
fn panel_rect() -> (Int, Int, Int, Int) {
  (1080, 20, 390, 860)
}

///|
fn title_start_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 210, screen_h / 2 + 130, 420, 88)
}

///|
fn panel_next_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 230, screen_h / 2 + 82, 200, 72)
}

///|
fn panel_restart_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 + 30, screen_h / 2 + 82, 200, 72)
}

///|
fn play_restart_rect() -> (Int, Int, Int, Int) {
  let (px, py, _pw, ph) = panel_rect()
  (px + 84, py + ph - 84, 220, 58)
}

///|
fn touch_left_rect() -> (Int, Int, Int, Int) {
  (86, screen_h - 176, 88, 88)
}

///|
fn touch_right_rect() -> (Int, Int, Int, Int) {
  (268, screen_h - 176, 88, 88)
}

///|
fn touch_up_rect() -> (Int, Int, Int, Int) {
  (177, screen_h - 266, 88, 88)
}

///|
fn touch_down_rect() -> (Int, Int, Int, Int) {
  (177, screen_h - 86, 88, 88)
}

///|
fn touch_dash_rect() -> (Int, Int, Int, Int) {
  let (px, py, pw, ph) = panel_rect()
  (px + pw - 170, py + ph - 220, 132, 132)
}
