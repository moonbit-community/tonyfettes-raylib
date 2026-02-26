///|
fn make_move(
  name : String,
  attack_id : Int,
  move_kind : Int,
  total_frames : Int,
  startup_frames : Int,
  active_frames : Int,
  damage : Int,
  chip_damage : Int,
  hitstun_frames : Int,
  blockstun_frames : Int,
  pushback : Float,
  launch_x : Float,
  launch_y : Float,
  drift_speed : Float,
  hitbox_x : Float,
  hitbox_y : Float,
  hitbox_w : Float,
  hitbox_h : Float,
) -> MoveSpec {
  let mv = MoveSpec::empty()
  mv.name = name
  mv.attack_id = attack_id
  mv.move_kind = move_kind
  mv.total_frames = total_frames
  mv.startup_frames = startup_frames
  mv.active_frames = active_frames
  mv.recovery_frames = total_frames - startup_frames - active_frames
  if mv.recovery_frames < 1 {
    mv.recovery_frames = 1
  }
  mv.damage = damage
  mv.chip_damage = chip_damage
  mv.hitstun_frames = hitstun_frames
  mv.blockstun_frames = blockstun_frames
  mv.pushback = pushback
  mv.launch_x = launch_x
  mv.launch_y = launch_y
  mv.drift_speed = drift_speed
  mv.hitbox_x = hitbox_x
  mv.hitbox_y = hitbox_y
  mv.hitbox_w = hitbox_w
  mv.hitbox_h = hitbox_h
  mv.meter_gain_on_use = if move_kind == move_kind_normal {
    4
  } else if move_kind == move_kind_special {
    3
  } else {
    0
  }
  mv.meter_gain_on_hit = if move_kind == move_kind_normal {
    8
  } else if move_kind == move_kind_special {
    12
  } else {
    0
  }
  mv.hitstop_frames = if move_kind == move_kind_super {
    hitstop_super
  } else {
    hitstop_default
  }
  mv.cancel_window_start = startup_frames + active_frames
  mv.cancel_window_end = total_frames - 3
  mv
}

///|
fn roster_kai() -> CharacterArchetype {
  let lp = make_move(
    "flash jab", attack_lp, move_kind_normal, 22, 4, 3, 34, 0, 10, 7, 20.0, 90.0,
    -18.0, 0.0, 48.0, -98.0, 38.0, 22.0,
  )

  let hp = make_move(
    "meteor straight", attack_hp, move_kind_normal, 34, 8, 4, 76, 0, 17, 12, 30.0,
    150.0, -30.0, 24.0, 58.0, -106.0, 44.0, 30.0,
  )

  let lk = make_move(
    "step low", attack_lk, move_kind_normal, 24, 5, 3, 40, 0, 11, 8, 23.0, 94.0,
    0.0, 10.0, 46.0, -58.0, 42.0, 24.0,
  )
  lk.low_attack = true

  let hk = make_move(
    "crescent heel", attack_hk, move_kind_normal, 36, 10, 4, 90, 0, 18, 12, 34.0,
    160.0, -120.0, 20.0, 66.0, -120.0, 48.0, 34.0,
  )
  hk.overhead_attack = true
  hk.knockdown = true

  let qcf = make_move(
    "dragon burst", attack_special_qcf, move_kind_special, 54, 13, 5, 122, 8, 22,
    16, 58.0, 220.0, -55.0, 70.0, 86.0, -98.0, 56.0, 34.0,
  )
  qcf.cancel_on_hit = true
  qcf.cancel_window_start = 18
  qcf.cancel_window_end = 33

  let dp = make_move(
    "sky shatter", attack_special_dp, move_kind_special, 58, 6, 6, 138, 10, 25, 15,
    45.0, 100.0, -290.0, 48.0, 56.0, -130.0, 44.0, 78.0,
  )
  dp.invuln_start = 1
  dp.invuln_end = 9
  dp.knockdown = true

  let super_move = make_move(
    "solar annihilation", attack_super, move_kind_super, 88, 10, 10, 270, 22, 36,
    22, 78.0, 220.0, -180.0, 96.0, 86.0, -126.0, 80.0, 86.0,
  )
  super_move.invuln_start = 1
  super_move.invuln_end = 15
  super_move.knockdown = true
  super_move.cancel_on_hit = false

  {
    id: 0,
    name: "KAI",
    title: "Northern Fist",
    intro_quote: "Strength is not enough. Control the flame.",
    victory_quote: "One clean strike ends every argument.",
    body_main: @raylib.Color::new(218, 68, 54, 255),
    body_trim: @raylib.Color::new(255, 202, 132, 255),
    aura_color: @raylib.Color::new(255, 120, 73, 255),
    ui_color: @raylib.Color::new(233, 102, 80, 255),
    speed_mul: 1.0,
    jump_mul: 1.0,
    offense_mul: 1.0,
    defense_mul: 1.0,
    meter_mul: 1.0,
    max_guard_bonus: 0,
    normal_lp: lp,
    normal_hp: hp,
    normal_lk: lk,
    normal_hk: hk,
    special_qcf: qcf,
    special_dp: dp,
    super_move,
  }
}

///|
fn roster_yun() -> CharacterArchetype {
  let lp = make_move(
    "needle jab", attack_lp, move_kind_normal, 20, 3, 3, 32, 0, 9, 7, 18.0, 80.0,
    -12.0, 0.0, 50.0, -96.0, 34.0, 20.0,
  )

  let hp = make_move(
    "wind palm", attack_hp, move_kind_normal, 30, 7, 4, 64, 0, 15, 11, 28.0, 130.0,
    -16.0, 14.0, 62.0, -108.0, 46.0, 28.0,
  )

  let lk = make_move(
    "ankle cut", attack_lk, move_kind_normal, 22, 4, 3, 36, 0, 10, 8, 22.0, 80.0,
    0.0, 6.0, 42.0, -55.0, 44.0, 22.0,
  )
  lk.low_attack = true

  let hk = make_move(
    "arc kick", attack_hk, move_kind_normal, 34, 9, 4, 80, 0, 16, 11, 30.0, 144.0,
    -90.0, 22.0, 72.0, -126.0, 48.0, 32.0,
  )
  hk.overhead_attack = true

  let qcf = make_move(
    "tempest wheel", attack_special_qcf, move_kind_special, 52, 12, 6, 110, 8, 20,
    15, 44.0, 188.0, -40.0, 76.0, 92.0, -86.0, 52.0, 34.0,
  )
  qcf.cancel_on_hit = true

  let dp = make_move(
    "azure spike", attack_special_dp, move_kind_special, 54, 5, 5, 126, 10, 24, 14,
    34.0, 86.0, -318.0, 52.0, 52.0, -138.0, 42.0, 86.0,
  )
  dp.invuln_start = 1
  dp.invuln_end = 8
  dp.knockdown = true

  let super_move = make_move(
    "thousand leaves", attack_super, move_kind_super, 82, 9, 12, 248, 18, 34, 21,
    70.0, 180.0, -110.0, 92.0, 90.0, -112.0, 88.0, 84.0,
  )
  super_move.knockdown = true
  super_move.invuln_start = 1
  super_move.invuln_end = 12

  {
    id: 1,
    name: "YUN",
    title: "Silent Crane",
    intro_quote: "Your stance leaks intent.",
    victory_quote: "Wind has no shape, but it still cuts.",
    body_main: @raylib.Color::new(70, 174, 231, 255),
    body_trim: @raylib.Color::new(205, 241, 255, 255),
    aura_color: @raylib.Color::new(102, 223, 255, 255),
    ui_color: @raylib.Color::new(96, 191, 240, 255),
    speed_mul: 1.08,
    jump_mul: 1.08,
    offense_mul: 0.95,
    defense_mul: 0.92,
    meter_mul: 1.12,
    max_guard_bonus: -8,
    normal_lp: lp,
    normal_hp: hp,
    normal_lk: lk,
    normal_hk: hk,
    special_qcf: qcf,
    special_dp: dp,
    super_move,
  }
}

///|
fn roster_lei() -> CharacterArchetype {
  let lp = make_move(
    "iron jab", attack_lp, move_kind_normal, 24, 4, 3, 38, 0, 11, 8, 24.0, 96.0,
    -18.0, 0.0, 52.0, -92.0, 36.0, 24.0,
  )

  let hp = make_move(
    "stone elbow", attack_hp, move_kind_normal, 36, 9, 4, 84, 0, 18, 12, 32.0, 168.0,
    -26.0, 18.0, 56.0, -96.0, 48.0, 32.0,
  )

  let lk = make_move(
    "deep sweep", attack_lk, move_kind_normal, 28, 7, 3, 46, 0, 14, 9, 28.0, 120.0,
    0.0, 8.0, 52.0, -42.0, 52.0, 20.0,
  )
  lk.low_attack = true
  lk.knockdown = true

  let hk = make_move(
    "iron mountain", attack_hk, move_kind_normal, 40, 11, 4, 102, 0, 20, 13, 36.0,
    170.0, -84.0, 24.0, 70.0, -116.0, 54.0, 32.0,
  )
  hk.knockdown = true

  let qcf = make_move(
    "titan break", attack_special_qcf, move_kind_special, 56, 14, 5, 140, 10, 24,
    16, 62.0, 240.0, -62.0, 74.0, 94.0, -84.0, 62.0, 36.0,
  )
  qcf.auto_dash = true
  qcf.cancel_on_hit = true

  let dp = make_move(
    "earth pillar", attack_special_dp, move_kind_special, 60, 8, 6, 148, 10, 25,
    15, 40.0, 92.0, -300.0, 42.0, 62.0, -130.0, 48.0, 82.0,
  )
  dp.invuln_start = 1
  dp.invuln_end = 11
  dp.knockdown = true

  let super_move = make_move(
    "volcanic judgement", attack_super, move_kind_super, 94, 12, 10, 294, 24, 38,
    22, 84.0, 240.0, -180.0, 90.0, 96.0, -124.0, 96.0, 88.0,
  )
  super_move.invuln_start = 1
  super_move.invuln_end = 16
  super_move.knockdown = true

  {
    id: 2,
    name: "LEI",
    title: "Iron Wall",
    intro_quote: "Stand your ground and take it.",
    victory_quote: "I can hear your fear through your bones.",
    body_main: @raylib.Color::new(196, 158, 78, 255),
    body_trim: @raylib.Color::new(255, 231, 170, 255),
    aura_color: @raylib.Color::new(255, 190, 90, 255),
    ui_color: @raylib.Color::new(215, 173, 91, 255),
    speed_mul: 0.92,
    jump_mul: 0.9,
    offense_mul: 1.12,
    defense_mul: 1.1,
    meter_mul: 0.95,
    max_guard_bonus: 12,
    normal_lp: lp,
    normal_hp: hp,
    normal_lk: lk,
    normal_hk: hk,
    special_qcf: qcf,
    special_dp: dp,
    super_move,
  }
}

///|
fn roster_qin() -> CharacterArchetype {
  let lp = make_move(
    "shadow needle", attack_lp, move_kind_normal, 19, 3, 3, 30, 0, 8, 6, 16.0, 78.0,
    -10.0, 0.0, 50.0, -100.0, 34.0, 20.0,
  )

  let hp = make_move(
    "night slash", attack_hp, move_kind_normal, 28, 6, 4, 62, 0, 15, 11, 24.0, 118.0,
    -24.0, 20.0, 66.0, -108.0, 46.0, 30.0,
  )

  let lk = make_move(
    "ghost low", attack_lk, move_kind_normal, 21, 4, 3, 34, 0, 10, 7, 20.0, 84.0,
    0.0, 12.0, 44.0, -58.0, 44.0, 22.0,
  )
  lk.low_attack = true

  let hk = make_move(
    "moon arc", attack_hk, move_kind_normal, 32, 8, 4, 78, 0, 17, 11, 26.0, 130.0,
    -130.0, 18.0, 70.0, -128.0, 46.0, 34.0,
  )
  hk.overhead_attack = true

  let qcf = make_move(
    "phantom spiral", attack_special_qcf, move_kind_special, 48, 10, 6, 108, 8, 20,
    15, 40.0, 180.0, -30.0, 86.0, 92.0, -98.0, 48.0, 34.0,
  )
  qcf.cancel_on_hit = true

  let dp = make_move(
    "void rise", attack_special_dp, move_kind_special, 50, 5, 5, 118, 9, 24, 14,
    30.0, 76.0, -312.0, 54.0, 50.0, -136.0, 40.0, 84.0,
  )
  dp.invuln_start = 1
  dp.invuln_end = 7
  dp.knockdown = true

  let super_move = make_move(
    "midnight requiem", attack_super, move_kind_super, 80, 8, 11, 238, 16, 32, 20,
    64.0, 172.0, -120.0, 98.0, 92.0, -116.0, 90.0, 82.0,
  )
  super_move.invuln_start = 1
  super_move.invuln_end = 11
  super_move.knockdown = true

  {
    id: 3,
    name: "QIN",
    title: "Night Blade",
    intro_quote: "Blink once. I only need that long.",
    victory_quote: "You never even found my real angle.",
    body_main: @raylib.Color::new(128, 101, 214, 255),
    body_trim: @raylib.Color::new(231, 218, 255, 255),
    aura_color: @raylib.Color::new(174, 133, 255, 255),
    ui_color: @raylib.Color::new(154, 122, 230, 255),
    speed_mul: 1.13,
    jump_mul: 1.12,
    offense_mul: 0.92,
    defense_mul: 0.88,
    meter_mul: 1.16,
    max_guard_bonus: -10,
    normal_lp: lp,
    normal_hp: hp,
    normal_lk: lk,
    normal_hk: hk,
    special_qcf: qcf,
    special_dp: dp,
    super_move,
  }
}

///|
fn roster_tora() -> CharacterArchetype {
  let lp = make_move(
    "claw jab", attack_lp, move_kind_normal, 21, 4, 3, 36, 0, 10, 7, 20.0, 94.0,
    -14.0, 0.0, 52.0, -98.0, 36.0, 22.0,
  )

  let hp = make_move(
    "tiger smash", attack_hp, move_kind_normal, 32, 8, 4, 80, 0, 18, 12, 30.0, 150.0,
    -40.0, 26.0, 58.0, -108.0, 48.0, 30.0,
  )

  let lk = make_move(
    "fang sweep", attack_lk, move_kind_normal, 23, 5, 3, 40, 0, 11, 8, 24.0, 96.0,
    0.0, 16.0, 48.0, -54.0, 46.0, 22.0,
  )
  lk.low_attack = true

  let hk = make_move(
    "axe claw", attack_hk, move_kind_normal, 35, 9, 4, 92, 0, 19, 12, 34.0, 170.0,
    -118.0, 20.0, 70.0, -124.0, 50.0, 34.0,
  )
  hk.knockdown = true

  let qcf = make_move(
    "rending rush", attack_special_qcf, move_kind_special, 50, 11, 6, 132, 9, 24,
    16, 52.0, 220.0, -56.0, 94.0, 94.0, -90.0, 56.0, 34.0,
  )
  qcf.auto_dash = true
  qcf.cancel_on_hit = true

  let dp = make_move(
    "predator leap", attack_special_dp, move_kind_special, 52, 6, 6, 134, 10, 25,
    15, 36.0, 100.0, -304.0, 66.0, 54.0, -132.0, 42.0, 82.0,
  )
  dp.invuln_start = 1
  dp.invuln_end = 9
  dp.knockdown = true

  let super_move = make_move(
    "king of beasts", attack_super, move_kind_super, 86, 10, 12, 272, 22, 36, 22,
    76.0, 220.0, -156.0, 104.0, 94.0, -118.0, 94.0, 84.0,
  )
  super_move.invuln_start = 1
  super_move.invuln_end = 13
  super_move.knockdown = true

  {
    id: 4,
    name: "TORA",
    title: "Wild Fang",
    intro_quote: "Fight me at full speed. No excuses.",
    victory_quote: "You brought fear into the ring. Bad idea.",
    body_main: @raylib.Color::new(238, 108, 58, 255),
    body_trim: @raylib.Color::new(255, 214, 160, 255),
    aura_color: @raylib.Color::new(255, 142, 86, 255),
    ui_color: @raylib.Color::new(240, 126, 82, 255),
    speed_mul: 1.04,
    jump_mul: 1.06,
    offense_mul: 1.06,
    defense_mul: 0.95,
    meter_mul: 1.02,
    max_guard_bonus: -2,
    normal_lp: lp,
    normal_hp: hp,
    normal_lk: lk,
    normal_hk: hk,
    special_qcf: qcf,
    special_dp: dp,
    super_move,
  }
}

///|
fn roster_mei() -> CharacterArchetype {
  let lp = make_move(
    "lotus jab", attack_lp, move_kind_normal, 20, 3, 3, 30, 0, 9, 7, 18.0, 80.0,
    -12.0, 0.0, 48.0, -98.0, 34.0, 20.0,
  )

  let hp = make_move(
    "petal palm", attack_hp, move_kind_normal, 31, 7, 4, 68, 0, 16, 11, 26.0, 136.0,
    -20.0, 12.0, 62.0, -108.0, 44.0, 30.0,
  )

  let lk = make_move(
    "river sweep", attack_lk, move_kind_normal, 24, 5, 3, 40, 0, 12, 8, 24.0, 94.0,
    0.0, 8.0, 44.0, -56.0, 44.0, 22.0,
  )
  lk.low_attack = true

  let hk = make_move(
    "spring fan", attack_hk, move_kind_normal, 34, 9, 4, 84, 0, 17, 12, 30.0, 152.0,
    -112.0, 16.0, 68.0, -126.0, 48.0, 34.0,
  )
  hk.overhead_attack = true

  let qcf = make_move(
    "jade storm", attack_special_qcf, move_kind_special, 50, 11, 5, 114, 8, 22, 16,
    40.0, 178.0, -28.0, 72.0, 90.0, -94.0, 52.0, 34.0,
  )
  qcf.cancel_on_hit = true

  let dp = make_move(
    "white crane rise", attack_special_dp, move_kind_special, 52, 5, 5, 122, 9, 24,
    14, 34.0, 82.0, -310.0, 50.0, 50.0, -134.0, 40.0, 84.0,
  )
  dp.invuln_start = 1
  dp.invuln_end = 8
  dp.knockdown = true

  let super_move = make_move(
    "moonlit finale", attack_super, move_kind_super, 82, 9, 11, 246, 18, 34, 21,
    66.0, 176.0, -118.0, 92.0, 90.0, -116.0, 90.0, 82.0,
  )
  super_move.invuln_start = 1
  super_move.invuln_end = 12
  super_move.knockdown = true

  {
    id: 5,
    name: "MEI",
    title: "Jade Dancer",
    intro_quote: "A true rhythm controls the whole arena.",
    victory_quote: "Grace can break steel if timing is perfect.",
    body_main: @raylib.Color::new(90, 198, 136, 255),
    body_trim: @raylib.Color::new(210, 255, 230, 255),
    aura_color: @raylib.Color::new(122, 240, 180, 255),
    ui_color: @raylib.Color::new(106, 210, 154, 255),
    speed_mul: 1.06,
    jump_mul: 1.04,
    offense_mul: 0.94,
    defense_mul: 0.96,
    meter_mul: 1.18,
    max_guard_bonus: -4,
    normal_lp: lp,
    normal_hp: hp,
    normal_lk: lk,
    normal_hk: hk,
    special_qcf: qcf,
    special_dp: dp,
    super_move,
  }
}

///|
fn build_roster() -> Array[CharacterArchetype] {
  [
    roster_kai(),
    roster_yun(),
    roster_lei(),
    roster_qin(),
    roster_tora(),
    roster_mei(),
  ]
}
