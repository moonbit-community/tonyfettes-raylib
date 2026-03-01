///|
pub fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
pub fn clampf(v : Float, low : Float, high : Float) -> Float {
  if v < low {
    low
  } else if v > high {
    high
  } else {
    v
  }
}

///|
pub fn clampi(v : Int, low : Int, high : Int) -> Int {
  if v < low {
    low
  } else if v > high {
    high
  } else {
    v
  }
}

///|
pub fn f(v : Double) -> Float {
  Float::from_double(v)
}

///|
pub fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

///|
pub fn approachf(current : Float, target : Float, delta : Float) -> Float {
  if current < target {
    minf(current + delta, target)
  } else {
    maxf(current - delta, target)
  }
}

///|
pub fn rand_next(game : Game) -> Int {
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
pub fn rand_range(game : Game, low : Int, high : Int) -> Int {
  if high <= low {
    low
  } else {
    low + rand_next(game) % (high - low + 1)
  }
}

///|
pub fn rand_rangef(game : Game, low : Float, high : Float) -> Float {
  let t = Float::from_int(rand_next(game) % 10000) / 10000.0
  low + (high - low) * t
}

///|
pub fn rand_chance(game : Game, p : Float) -> Bool {
  rand_rangef(game, 0.0, 1.0) < p
}

///|
pub fn fighter_archetype(game : Game, fighter : Fighter) -> CharacterArchetype {
  game.roster[clampi(fighter.archetype_index, 0, game.roster.length() - 1)]
}

///|
pub fn other_slot(slot : Int) -> Int {
  if slot == 0 {
    1
  } else {
    0
  }
}

///|
pub fn facing_sign(facing : Int) -> Float {
  if facing < 0 {
    -1.0
  } else {
    1.0
  }
}

///|
pub fn stage_clamp_x(x : Float) -> Float {
  clampf(x, stage_left_x + 24.0, stage_right_x - 24.0)
}

///|
pub fn fighter_distance_x(a : Fighter, b : Fighter) -> Float {
  absf(a.x - b.x)
}

///|
pub fn hurtbox_for(fighter : Fighter) -> @raylib.Rectangle {
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
pub fn attack_hitbox_for(fighter : Fighter, mv : MoveSpec) -> @raylib.Rectangle {
  let fx = facing_sign(fighter.facing)
  @raylib.Rectangle::new(
    fighter.x + mv.hitbox_x * fx - mv.hitbox_w * 0.5,
    fighter.y + mv.hitbox_y,
    mv.hitbox_w,
    mv.hitbox_h,
  )
}

///|
pub fn draw_shadow_text(
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
pub fn draw_center_shadow_text(
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
pub fn countdown_color(timer : Float) -> @raylib.Color {
  if timer > 20.0 {
    @raylib.raywhite
  } else if timer > 10.0 {
    @raylib.gold
  } else {
    @raylib.red
  }
}

///|
pub fn fighter_total_guard(archetype : CharacterArchetype) -> Int {
  guard_max + archetype.max_guard_bonus
}

///|
pub fn action_name(action : Action) -> String {
  if action == ActionIdle {
    "idle"
  } else if action == ActionWalkForward {
    "walk_fwd"
  } else if action == ActionWalkBack {
    "walk_back"
  } else if action == ActionCrouch {
    "crouch"
  } else if action == ActionJump {
    "jump"
  } else if action == ActionDashForward {
    "dash_fwd"
  } else if action == ActionDashBack {
    "dash_back"
  } else if action == ActionAttack {
    "attack"
  } else if action == ActionThrow {
    "throw"
  } else if action == ActionHitstun {
    "hit"
  } else if action == ActionBlockstun {
    "block"
  } else if action == ActionKnockdown {
    "down"
  } else if action == ActionWakeup {
    "wake"
  } else if action == ActionVictory {
    "victory"
  } else if action == ActionIntro {
    "intro"
  } else {
    "unknown"
  }
}

///|
pub fn add_meter(
  fighter : Fighter,
  value : Int,
  archetype : CharacterArchetype,
) -> Unit {
  let scaled = Float::from_int(value) * archetype.meter_mul
  let next = fighter.super_meter + scaled.to_int()
  fighter.super_meter = clampi(next, 0, super_max)
}

///|
pub fn add_guard(
  fighter : Fighter,
  value : Float,
  archetype : CharacterArchetype,
) -> Unit {
  let target = fighter_total_guard(archetype)
  fighter.guard_meter = clampi(fighter.guard_meter + value.to_int(), 0, target)
}

///|
pub fn reset_fighter_round_state(fighter : Fighter) -> Unit {
  fighter.vx = 0.0
  fighter.vy = 0.0
  fighter.on_ground = true
  fighter.crouching = false
  fighter.action = ActionIntro
  fighter.action_frame = 0
  fighter.action_elapsed = 0.0
  fighter.current_move = MoveSpec::empty()
  fighter.move_connected = false
  fighter.move_cancel_enabled = false
  fighter.hitstop = 0
  fighter.hitstun = 0
  fighter.blockstun = 0
  fighter.knockdown = 0
  fighter.invuln = 0
  fighter.throw_tech_timer = 0
  fighter.combo_counter = 0
  fighter.combo_timer = 0
  fighter.flash_timer = 0.0
  fighter.shake_timer = 0.0
  fighter.hurt_shake_x = 0.0
  fighter.hurt_shake_y = 0.0
  fighter.input = InputState::new()
}

///|
pub fn health_ratio(fighter : Fighter) -> Float {
  Float::from_int(clampi(fighter.health, 0, health_max)) /
  Float::from_int(health_max)
}

///|
pub fn meter_ratio(fighter : Fighter) -> Float {
  Float::from_int(clampi(fighter.super_meter, 0, super_max)) /
  Float::from_int(super_max)
}

///|
pub fn guard_ratio(fighter : Fighter, archetype : CharacterArchetype) -> Float {
  let total = fighter_total_guard(archetype)
  if total <= 0 {
    0.0
  } else {
    Float::from_int(clampi(fighter.guard_meter, 0, total)) /
    Float::from_int(total)
  }
}

///|
pub fn throw_input_pressed(input : InputState) -> Bool {
  (input.lp_pressed && input.lk_down) || (input.lk_pressed && input.lp_down)
}

///|
pub fn fighter_is_throw_vulnerable(fighter : Fighter) -> Bool {
  fighter.on_ground &&
  fighter.invuln <= 0 &&
  fighter.action != ActionHitstun &&
  fighter.action != ActionBlockstun &&
  fighter.action != ActionKnockdown &&
  fighter.action != ActionWakeup &&
  fighter.action != ActionIntro &&
  fighter.action != ActionVictory &&
  fighter.action != ActionThrow
}

///|
pub fn signed_frames_text(frames : Int) -> String {
  if frames > 0 {
    "+\{frames}"
  } else {
    "\{frames}"
  }
}

///|
pub fn set_training_note(game : Game, text : String) -> Unit {
  if not(game.mode_training) {
    return
  }
  game.training_adv_text = text
  game.training_adv_timer = training_info_duration
}

///|
pub fn set_training_frame_adv(
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
pub fn screen_center_xf() -> Float {
  Float::from_int(screen_width) * 0.5
}

///|
pub fn screen_center_yf() -> Float {
  Float::from_int(screen_height) * 0.5
}

///|
pub fn camera_project_x(game : Game, x : Float) -> Float {
  let cx = screen_center_xf()
  (x - cx) * game.camera_zoom + cx + game.camera_x
}

///|
pub fn camera_project_y(game : Game, y : Float) -> Float {
  let cy = screen_center_yf()
  (y - cy) * game.camera_zoom + cy + game.camera_y
}

///|
pub fn camera_project_size(game : Game, size : Float) -> Float {
  size * game.camera_zoom
}
