///|
fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
fn clampf(v : Float, low : Float, high : Float) -> Float {
  if v < low {
    low
  } else if v > high {
    high
  } else {
    v
  }
}

///|
fn clampi(v : Int, low : Int, high : Int) -> Int {
  if v < low {
    low
  } else if v > high {
    high
  } else {
    v
  }
}

///|
fn f(v : Double) -> Float {
  Float::from_double(v)
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
fn signf(v : Float) -> Float {
  if v < 0.0 {
    -1.0
  } else if v > 0.0 {
    1.0
  } else {
    0.0
  }
}

///|
fn signi(v : Int) -> Int {
  if v < 0 {
    -1
  } else if v > 0 {
    1
  } else {
    0
  }
}

///|
fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

///|
fn approachf(current : Float, target : Float, delta : Float) -> Float {
  if current < target {
    minf(current + delta, target)
  } else {
    maxf(current - delta, target)
  }
}

///|
fn rand_next(game : Game) -> Int {
  let mut x = game.rng_state
  x = x ^ (x << 13)
  x = x ^ (x >> 17)
  x = x ^ (x << 5)
  if x < 0 {
    x = -x
  }
  game.rng_state = x
  x
}

///|
fn rand_range(game : Game, low : Int, high : Int) -> Int {
  if high <= low {
    low
  } else {
    low + rand_next(game) % (high - low + 1)
  }
}

///|
fn rand_rangef(game : Game, low : Float, high : Float) -> Float {
  let t = Float::from_int(rand_next(game) % 10000) / 10000.0
  low + (high - low) * t
}

///|
fn rand_chance(game : Game, p : Float) -> Bool {
  rand_rangef(game, 0.0, 1.0) < p
}

///|
fn fighter_archetype(game : Game, fighter : Fighter) -> CharacterArchetype {
  game.roster[clampi(fighter.archetype_index, 0, game.roster.length() - 1)]
}

///|
fn fighter_by_slot(game : Game, slot : Int) -> Fighter {
  game.fighters[clampi(slot, 0, max_players - 1)]
}

///|
fn other_slot(slot : Int) -> Int {
  if slot == 0 {
    1
  } else {
    0
  }
}

///|
fn facing_sign(facing : Int) -> Float {
  if facing < 0 {
    -1.0
  } else {
    1.0
  }
}

///|
fn stage_clamp_x(x : Float) -> Float {
  clampf(x, stage_left_x + 24.0, stage_right_x - 24.0)
}

///|
fn fighter_distance_x(a : Fighter, b : Fighter) -> Float {
  absf(a.x - b.x)
}

///|
fn fighter_distance_y(a : Fighter, b : Fighter) -> Float {
  absf(a.y - b.y)
}

///|
fn hurtbox_for(fighter : Fighter) -> @raylib.Rectangle {
  if fighter.crouching && fighter.on_ground {
    @raylib.Rectangle::new(
      fighter.x - fighter_crouch_hurtbox_w * 0.5,
      fighter.y - fighter_crouch_hurtbox_h,
      fighter_crouch_hurtbox_w,
      fighter_crouch_hurtbox_h,
    )
  } else {
    @raylib.Rectangle::new(
      fighter.x - fighter_stand_hurtbox_w * 0.5,
      fighter.y - fighter_stand_hurtbox_h,
      fighter_stand_hurtbox_w,
      fighter_stand_hurtbox_h,
    )
  }
}

///|
fn attack_hitbox_for(fighter : Fighter, mv : MoveSpec) -> @raylib.Rectangle {
  let fx = facing_sign(fighter.facing)
  @raylib.Rectangle::new(
    fighter.x + mv.hitbox_x * fx - mv.hitbox_w * 0.5,
    fighter.y + mv.hitbox_y,
    mv.hitbox_w,
    mv.hitbox_h,
  )
}

///|
fn draw_center_text(
  text : String,
  x : Int,
  y : Int,
  size : Int,
  color : @raylib.Color,
) -> Unit {
  let w = @raylib.measure_text(text, size)
  @raylib.draw_text(text, x - w / 2, y, size, color)
}

///|
fn draw_shadow_text(
  text : String,
  x : Int,
  y : Int,
  size : Int,
  color : @raylib.Color,
) -> Unit {
  @raylib.draw_text(text, x + 2, y + 2, size, @raylib.black)
  @raylib.draw_text(text, x, y, size, color)
}

///|
fn draw_center_shadow_text(
  text : String,
  x : Int,
  y : Int,
  size : Int,
  color : @raylib.Color,
) -> Unit {
  let w = @raylib.measure_text(text, size)
  draw_shadow_text(text, x - w / 2, y, size, color)
}

///|
fn countdown_color(timer : Float) -> @raylib.Color {
  if timer > 20.0 {
    @raylib.raywhite
  } else if timer > 10.0 {
    @raylib.gold
  } else {
    @raylib.red
  }
}

///|
fn fighter_total_guard(archetype : CharacterArchetype) -> Int {
  guard_max + archetype.max_guard_bonus
}

///|
fn action_is_busy(action : Int) -> Bool {
  action == action_attack ||
  action == action_throw ||
  action == action_hitstun ||
  action == action_blockstun ||
  action == action_knockdown ||
  action == action_wakeup ||
  action == action_intro ||
  action == action_victory
}

///|
fn action_can_move(action : Int) -> Bool {
  action == action_idle ||
  action == action_walk_forward ||
  action == action_walk_back ||
  action == action_crouch ||
  action == action_jump ||
  action == action_dash_forward ||
  action == action_dash_back
}

///|
fn action_name(action : Int) -> String {
  if action == action_idle {
    "idle"
  } else if action == action_walk_forward {
    "walk_fwd"
  } else if action == action_walk_back {
    "walk_back"
  } else if action == action_crouch {
    "crouch"
  } else if action == action_jump {
    "jump"
  } else if action == action_dash_forward {
    "dash_fwd"
  } else if action == action_dash_back {
    "dash_back"
  } else if action == action_attack {
    "attack"
  } else if action == action_throw {
    "throw"
  } else if action == action_hitstun {
    "hit"
  } else if action == action_blockstun {
    "block"
  } else if action == action_knockdown {
    "down"
  } else if action == action_wakeup {
    "wake"
  } else if action == action_victory {
    "victory"
  } else if action == action_intro {
    "intro"
  } else {
    "unknown"
  }
}

///|
fn add_meter(
  fighter : Fighter,
  value : Int,
  archetype : CharacterArchetype,
) -> Unit {
  let scaled = Float::from_int(value) * archetype.meter_mul
  let next = fighter.super_meter + scaled.to_int()
  fighter.super_meter = clampi(next, 0, super_max)
}

///|
fn add_guard(
  fighter : Fighter,
  value : Float,
  archetype : CharacterArchetype,
) -> Unit {
  let target = fighter_total_guard(archetype)
  fighter.guard_meter = clampi(fighter.guard_meter + value.to_int(), 0, target)
}

///|
fn reset_fighter_round_state(fighter : Fighter) -> Unit {
  fighter.vx = 0.0
  fighter.vy = 0.0
  fighter.on_ground = true
  fighter.crouching = false
  fighter.jumped = false
  fighter.action = action_intro
  fighter.action_frame = 0
  fighter.action_elapsed = 0.0
  fighter.current_move = MoveSpec::empty()
  fighter.move_connected = false
  fighter.move_was_blocked = false
  fighter.move_cancel_enabled = false
  fighter.hitstop = 0
  fighter.hitstun = 0
  fighter.blockstun = 0
  fighter.knockdown = 0
  fighter.invuln = 0
  fighter.throw_tech_timer = 0
  fighter.combo_counter = 0
  fighter.combo_damage = 0
  fighter.combo_timer = 0
  fighter.counter_hit_flag = false
  fighter.flash_timer = 0.0
  fighter.trail_timer = 0.0
  fighter.shake_timer = 0.0
  fighter.hurt_shake_x = 0.0
  fighter.hurt_shake_y = 0.0
  fighter.input = InputState::new()
}

///|
fn health_ratio(fighter : Fighter) -> Float {
  Float::from_int(clampi(fighter.health, 0, health_max)) /
  Float::from_int(health_max)
}

///|
fn meter_ratio(fighter : Fighter) -> Float {
  Float::from_int(clampi(fighter.super_meter, 0, super_max)) /
  Float::from_int(super_max)
}

///|
fn guard_ratio(fighter : Fighter, archetype : CharacterArchetype) -> Float {
  let total = fighter_total_guard(archetype)
  if total <= 0 {
    0.0
  } else {
    Float::from_int(clampi(fighter.guard_meter, 0, total)) /
    Float::from_int(total)
  }
}

///|
fn throw_input_pressed(input : InputState) -> Bool {
  (input.lp_pressed && input.lk_down) || (input.lk_pressed && input.lp_down)
}

///|
fn fighter_is_throw_vulnerable(fighter : Fighter) -> Bool {
  fighter.on_ground &&
  fighter.invuln <= 0 &&
  fighter.action != action_hitstun &&
  fighter.action != action_blockstun &&
  fighter.action != action_knockdown &&
  fighter.action != action_wakeup &&
  fighter.action != action_intro &&
  fighter.action != action_victory &&
  fighter.action != action_throw
}

///|
fn signed_frames_text(frames : Int) -> String {
  if frames > 0 {
    "+\{frames}"
  } else {
    "\{frames}"
  }
}

///|
fn set_training_note(game : Game, text : String) -> Unit {
  if not(game.mode_training) {
    return
  }
  game.training_adv_text = text
  game.training_adv_timer = training_info_duration
}

///|
fn set_training_frame_adv(
  game : Game,
  attacker_slot : Int,
  label : String,
  advantage : Int,
) -> Unit {
  set_training_note(
    game,
    "P\{attacker_slot + 1} \{label}: \{signed_frames_text(advantage)}f",
  )
}

///|
fn screen_center_xf() -> Float {
  Float::from_int(screen_width) * 0.5
}

///|
fn screen_center_yf() -> Float {
  Float::from_int(screen_height) * 0.5
}

///|
fn camera_project_x(game : Game, x : Float) -> Float {
  let cx = screen_center_xf()
  (x - cx) * game.camera_zoom + cx + game.camera_x
}

///|
fn camera_project_y(game : Game, y : Float) -> Float {
  let cy = screen_center_yf()
  (y - cy) * game.camera_zoom + cy + game.camera_y
}

///|
fn camera_project_size(game : Game, size : Float) -> Float {
  size * game.camera_zoom
}
