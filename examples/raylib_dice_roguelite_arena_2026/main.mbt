///|
let sw = 1366

///|
let sh = 768

///|
let max_dice = 6

///|
let max_sparks = 180

///|
struct Player {
  mut hp : Int
  mut max_hp : Int
  mut shield : Int
  mut poison : Int
  mut energy : Int
  mut gold : Int
  mut floor : Int
  mut wins : Int
}

///|
struct Enemy {
  mut kind : Int
  mut hp : Int
  mut max_hp : Int
  mut shield : Int
  mut poison : Int
  mut rage : Int
  mut intent_kind : Int
  mut intent_value : Int
}

///|
struct Dice {
  mut value : Int
  mut face : Int
  mut used : Bool
  mut x : Float
  mut y : Float
  mut pulse_t : Float
}

///|
struct RewardCard {
  mut kind : Int
  mut value : Int
  mut title : String
  mut desc : String
}

///|
struct Artifacts {
  mut atk_bonus : Int
  mut guard_bonus : Int
  mut heal_bonus : Int
  mut venom_bonus : Int
  mut focus_bonus : Int
  mut crush_bonus : Int
  mut reroll_bonus : Int
  mut start_shield : Int
  mut crit_chance : Int
}

///|
struct Spark {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut life : Float
  mut size : Float
  mut kind : Int
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
fn clampf(v : Float, lo : Float, hi : Float) -> Float {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
fn randf(lo : Float, hi : Float) -> Float {
  let r : Float = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
fn inside_rect(
  px : Float,
  py : Float,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> Bool {
  px >= Float::from_int(x) &&
  px <= Float::from_int(x + w) &&
  py >= Float::from_int(y) &&
  py <= Float::from_int(y + h)
}

///|
fn enemy_name(kind : Int) -> String {
  if kind == 0 {
    "Scrap Berserker"
  } else if kind == 1 {
    "Aegis Sentinel"
  } else if kind == 2 {
    "Venom Archivist"
  } else {
    "Null Reaper"
  }
}

///|
fn face_name(face : Int) -> String {
  if face == 0 {
    "STRIKE"
  } else if face == 1 {
    "GUARD"
  } else if face == 2 {
    "FOCUS"
  } else if face == 3 {
    "MEND"
  } else if face == 4 {
    "VENOM"
  } else {
    "CRUSH"
  }
}

///|
fn face_desc(face : Int) -> String {
  if face == 0 {
    "Deal damage"
  } else if face == 1 {
    "Gain shield"
  } else if face == 2 {
    "Gain energy"
  } else if face == 3 {
    "Restore HP"
  } else if face == 4 {
    "Apply poison"
  } else {
    "Heavy hit"
  }
}

///|
fn clear_sparks(sp : Array[Spark]) -> Unit {
  for i = 0; i < sp.length(); i = i + 1 {
    sp[i].active = false
    sp[i].x = 0.0
    sp[i].y = 0.0
    sp[i].vx = 0.0
    sp[i].vy = 0.0
    sp[i].life = 0.0
    sp[i].size = 0.0
    sp[i].kind = 0
  }
}

///|
fn add_spark(sp : Array[Spark], x : Float, y : Float, kind : Int) -> Unit {
  for i = 0; i < sp.length(); i = i + 1 {
    if not(sp[i].active) {
      sp[i].active = true
      sp[i].x = x
      sp[i].y = y
      let a : Float = randf(0.0, 6.28318)
      let s : Float = randf(40.0, 240.0)
      sp[i].vx = @math.cosf(a) * s
      sp[i].vy = @math.sinf(a) * s
      sp[i].life = randf(0.25, 0.7)
      sp[i].size = randf(3.0, 8.0)
      sp[i].kind = kind
      return
    }
  }
}

///|
fn burst_sparks(
  sp : Array[Spark],
  x : Float,
  y : Float,
  n : Int,
  kind : Int,
) -> Unit {
  for _i = 0; _i < n; _i = _i + 1 {
    add_spark(sp, x, y, kind)
  }
}

///|
fn update_sparks(sp : Array[Spark], dt : Float) -> Unit {
  for i = 0; i < sp.length(); i = i + 1 {
    if not(sp[i].active) {
      continue
    }
    sp[i].life = sp[i].life - dt
    if sp[i].life <= 0.0 {
      sp[i].active = false
      continue
    }
    sp[i].x = sp[i].x + sp[i].vx * dt
    sp[i].y = sp[i].y + sp[i].vy * dt
    sp[i].vx = sp[i].vx * (1.0 - dt * 2.6)
    sp[i].vy = sp[i].vy * (1.0 - dt * 2.2) + 20.0 * dt
  }
}

///|
fn draw_sparks(sp : Array[Spark]) -> Unit {
  for i = 0; i < sp.length(); i = i + 1 {
    if not(sp[i].active) {
      continue
    }

    let c = if sp[i].kind == 0 {
      @raylib.Color::new(246, 225, 132, 244)
    } else if sp[i].kind == 1 {
      @raylib.Color::new(124, 232, 186, 244)
    } else if sp[i].kind == 2 {
      @raylib.Color::new(246, 112, 132, 244)
    } else {
      @raylib.Color::new(126, 198, 252, 244)
    }

    @raylib.draw_circle(
      sp[i].x.to_int(),
      sp[i].y.to_int(),
      sp[i].size * sp[i].life * 1.8,
      c,
    )
  }
}

///|
fn enemy_color(kind : Int) -> @raylib.Color {
  if kind == 0 {
    @raylib.Color::new(242, 118, 106, 255)
  } else if kind == 1 {
    @raylib.Color::new(136, 170, 244, 255)
  } else if kind == 2 {
    @raylib.Color::new(136, 222, 140, 255)
  } else {
    @raylib.Color::new(194, 132, 252, 255)
  }
}

///|
fn set_enemy(enemy : Enemy, floor : Int) -> Unit {
  let mut kind : Int = @raylib.get_random_value(0, 3)
  if floor >= 9 && @raylib.get_random_value(0, 99) < 46 {
    kind = 3
  }

  enemy.kind = kind
  enemy.shield = 0
  enemy.poison = 0
  enemy.rage = 0

  if kind == 0 {
    enemy.max_hp = 64 + floor * 13
  } else if kind == 1 {
    enemy.max_hp = 78 + floor * 15
  } else if kind == 2 {
    enemy.max_hp = 72 + floor * 14
  } else {
    enemy.max_hp = 98 + floor * 18
  }

  enemy.hp = enemy.max_hp
  enemy.intent_kind = 0
  enemy.intent_value = 8
}

///|
fn roll_enemy_intent(enemy : Enemy, floor : Int) -> Unit {
  let r : Int = @raylib.get_random_value(0, 99)

  if enemy.kind == 0 {
    if r < 58 {
      enemy.intent_kind = 0
      enemy.intent_value = 10 + floor * 2 + enemy.rage
    } else if r < 84 {
      enemy.intent_kind = 2
      enemy.intent_value = 4 + floor
    } else {
      enemy.intent_kind = 1
      enemy.intent_value = 12 + floor * 2
    }
  } else if enemy.kind == 1 {
    if r < 48 {
      enemy.intent_kind = 1
      enemy.intent_value = 13 + floor * 2
    } else if r < 78 {
      enemy.intent_kind = 0
      enemy.intent_value = 9 + floor * 2 + enemy.rage
    } else {
      enemy.intent_kind = 2
      enemy.intent_value = 5 + floor
    }
  } else if enemy.kind == 2 {
    if r < 44 {
      enemy.intent_kind = 3
      enemy.intent_value = 3 + floor / 2
    } else if r < 74 {
      enemy.intent_kind = 0
      enemy.intent_value = 9 + floor * 2 + enemy.rage
    } else {
      enemy.intent_kind = 2
      enemy.intent_value = 4 + floor
    }
  } else if r < 40 {
    enemy.intent_kind = 0
    enemy.intent_value = 14 + floor * 2 + enemy.rage
  } else if r < 66 {
    enemy.intent_kind = 3
    enemy.intent_value = 4 + floor / 2
  } else if r < 84 {
    enemy.intent_kind = 1
    enemy.intent_value = 12 + floor
  } else {
    enemy.intent_kind = 2
    enemy.intent_value = 7 + floor
  }
}

///|
fn intent_text(enemy : Enemy) -> String {
  if enemy.intent_kind == 0 {
    "Attack \{enemy.intent_value}"
  } else if enemy.intent_kind == 1 {
    "Guard \{enemy.intent_value}"
  } else if enemy.intent_kind == 2 {
    "Rage +\{enemy.intent_value}"
  } else {
    "Poison \{enemy.intent_value}"
  }
}

///|
fn roll_face(art : Artifacts) -> Int {
  let r : Int = @raylib.get_random_value(0, 999)

  let strike_w : Int = 280 + art.atk_bonus * 4
  let guard_w : Int = 220 + art.guard_bonus * 3
  let focus_w : Int = 150 + art.focus_bonus * 12
  let mend_w : Int = 120 + art.heal_bonus * 8
  let venom_w : Int = 120 + art.venom_bonus * 10
  let crush_w : Int = 110 + art.crush_bonus * 4

  let s0 : Int = strike_w
  let s1 : Int = s0 + guard_w
  let s2 : Int = s1 + focus_w
  let s3 : Int = s2 + mend_w
  let s4 : Int = s3 + venom_w
  let total : Int = s4 + crush_w

  let p : Int = r % total

  if p < s0 {
    0
  } else if p < s1 {
    1
  } else if p < s2 {
    2
  } else if p < s3 {
    3
  } else if p < s4 {
    4
  } else {
    5
  }
}

///|
fn init_dice(dice : Array[Dice]) -> Unit {
  for i = 0; i < dice.length(); i = i + 1 {
    dice[i].value = 1
    dice[i].face = 0
    dice[i].used = false
    dice[i].x = 0.0
    dice[i].y = 0.0
    dice[i].pulse_t = 0.0
  }
}

///|
fn roll_dice(dice : Array[Dice], art : Artifacts, force_all : Bool) -> Unit {
  for i = 0; i < dice.length(); i = i + 1 {
    if force_all || not(dice[i].used) {
      dice[i].face = roll_face(art)
      dice[i].value = @raylib.get_random_value(1, 6)
      dice[i].used = false
      dice[i].pulse_t = 0.16 + Float::from_int(i) * 0.03
    }
  }
}

///|
fn compute_damage_to_enemy(enemy : Enemy, damage : Int) -> Int {
  if damage <= enemy.shield {
    enemy.shield = enemy.shield - damage
    0
  } else {
    let left : Int = damage - enemy.shield
    enemy.shield = 0
    enemy.hp = enemy.hp - left
    left
  }
}

///|
fn compute_damage_to_player(player : Player, damage : Int) -> Int {
  if damage <= player.shield {
    player.shield = player.shield - damage
    0
  } else {
    let left : Int = damage - player.shield
    player.shield = 0
    player.hp = player.hp - left
    left
  }
}

///|
fn apply_face(
  face : Int,
  value : Int,
  player : Player,
  enemy : Enemy,
  art : Artifacts,
  crit_flash : Array[Spark],
  msg_slot : Int,
) -> (String, Int) {
  if face == 0 {
    let mut dmg : Int = value * 4 + art.atk_bonus * 2
    let crit_roll : Int = @raylib.get_random_value(0, 99)
    if crit_roll < art.crit_chance {
      dmg = dmg + value * 2 + art.atk_bonus
      burst_sparks(crit_flash, 978.0, 360.0, 12, 0)
      let dealt = compute_damage_to_enemy(enemy, dmg)
      ("Critical strike \{dmg}", dealt)
    } else {
      let dealt = compute_damage_to_enemy(enemy, dmg)
      burst_sparks(crit_flash, 978.0, 360.0, 6, 0)
      ("Strike \{dmg}", dealt)
    }
  } else if face == 1 {
    let gain : Int = value * 3 + 3 + art.guard_bonus * 2
    player.shield = player.shield + gain
    burst_sparks(crit_flash, 330.0, 470.0, 8, 1)
    ("Shield +\{gain}", 0)
  } else if face == 2 {
    let gain : Int = 1 + value / 2 + art.focus_bonus
    player.energy = player.energy + gain
    player.energy = clampi(player.energy, 0, 9)
    burst_sparks(crit_flash, 330.0, 470.0, 6, 3)
    ("Energy +\{gain}", 0)
  } else if face == 3 {
    let heal : Int = value * 2 + art.heal_bonus * 3
    player.hp = player.hp + heal
    if player.hp > player.max_hp {
      player.hp = player.max_hp
    }
    burst_sparks(crit_flash, 330.0, 470.0, 8, 1)
    ("Heal +\{heal}", 0)
  } else if face == 4 {
    let p : Int = value + art.venom_bonus
    enemy.poison = enemy.poison + p
    burst_sparks(crit_flash, 978.0, 360.0, 7, 2)
    ("Poison +\{p}", 0)
  } else {
    let base : Int = value * 5 + 5 + art.crush_bonus * 2
    let mut dmg : Int = base
    if player.shield > 0 {
      dmg = dmg + player.shield / 3
    }
    let dealt = compute_damage_to_enemy(enemy, dmg)
    burst_sparks(crit_flash, 978.0, 360.0, 11, 0)
    if msg_slot % 2 == 0 {
      ("Crush \{dmg}", dealt)
    } else {
      ("Impact \{dmg}", dealt)
    }
  }
}

///|
fn set_reward_card(card : RewardCard, kind : Int, value : Int) -> Unit {
  card.kind = kind
  card.value = value

  if kind == 0 {
    card.title = "Upgrade Core"
    card.desc = "Max HP +\{value}"
  } else if kind == 1 {
    card.title = "Sharpen Edge"
    card.desc = "Strike bonus +\{value}"
  } else if kind == 2 {
    card.title = "Titan Plate"
    card.desc = "Guard bonus +\{value}"
  } else if kind == 3 {
    card.title = "Medical Patch"
    card.desc = "Mend bonus +\{value}"
  } else if kind == 4 {
    card.title = "Toxic Injector"
    card.desc = "Venom bonus +\{value}"
  } else if kind == 5 {
    card.title = "Graviton Ram"
    card.desc = "Crush bonus +\{value}"
  } else if kind == 6 {
    card.title = "Debug Battery"
    card.desc = "Reroll +\{value}"
  } else if kind == 7 {
    card.title = "Start Barrier"
    card.desc = "Start shield +\{value}"
  } else if kind == 8 {
    card.title = "Lucky Engine"
    card.desc = "Crit chance +\{value}%"
  } else {
    card.title = "Cash Crate"
    card.desc = "Gold +\{value}"
  }
}

///|
fn generate_rewards(cards : Array[RewardCard], floor : Int) -> Unit {
  for i = 0; i < cards.length(); i = i + 1 {
    let mut kind : Int = @raylib.get_random_value(0, 9)
    if floor <= 2 && kind == 8 {
      kind = 1
    }

    let value : Int = if kind == 0 {
      @raylib.get_random_value(8, 14)
    } else if kind == 1 {
      @raylib.get_random_value(1, 2)
    } else if kind == 2 {
      @raylib.get_random_value(1, 2)
    } else if kind == 3 {
      @raylib.get_random_value(1, 2)
    } else if kind == 4 {
      @raylib.get_random_value(1, 2)
    } else if kind == 5 {
      @raylib.get_random_value(2, 4)
    } else if kind == 6 {
      1
    } else if kind == 7 {
      @raylib.get_random_value(3, 6)
    } else if kind == 8 {
      @raylib.get_random_value(3, 6)
    } else {
      @raylib.get_random_value(20, 50)
    }

    set_reward_card(cards[i], kind, value)
  }
}

///|
fn apply_reward(card : RewardCard, player : Player, art : Artifacts) -> String {
  if card.kind == 0 {
    player.max_hp = player.max_hp + card.value
    player.hp = player.hp + card.value
    if player.hp > player.max_hp {
      player.hp = player.max_hp
    }
    "Core reinforced"
  } else if card.kind == 1 {
    art.atk_bonus = art.atk_bonus + card.value
    "Strike upgraded"
  } else if card.kind == 2 {
    art.guard_bonus = art.guard_bonus + card.value
    "Guard upgraded"
  } else if card.kind == 3 {
    art.heal_bonus = art.heal_bonus + card.value
    "Medical systems upgraded"
  } else if card.kind == 4 {
    art.venom_bonus = art.venom_bonus + card.value
    "Venom upgraded"
  } else if card.kind == 5 {
    art.crush_bonus = art.crush_bonus + card.value
    "Crush upgraded"
  } else if card.kind == 6 {
    art.reroll_bonus = art.reroll_bonus + card.value
    "Reroll systems upgraded"
  } else if card.kind == 7 {
    art.start_shield = art.start_shield + card.value
    "Start barrier upgraded"
  } else if card.kind == 8 {
    art.crit_chance = art.crit_chance + card.value
    if art.crit_chance > 60 {
      art.crit_chance = 60
    }
    "Critical matrix upgraded"
  } else {
    player.gold = player.gold + card.value
    "Cash awarded"
  }
}

///|
fn draw_panel(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  border : @raylib.Color,
) -> Unit {
  @raylib.draw_rectangle(x, y, w, h, @raylib.Color::new(20, 24, 36, 236))
  @raylib.draw_rectangle_lines(x, y, w, h, border)
}

///|
fn draw_button(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  label : String,
  enabled : Bool,
  hover : Bool,
) -> Unit {
  let fill = if not(enabled) {
    @raylib.Color::new(58, 66, 82, 200)
  } else if hover {
    @raylib.Color::new(104, 138, 216, 242)
  } else {
    @raylib.Color::new(82, 104, 170, 228)
  }

  @raylib.draw_rectangle(x, y, w, h, fill)
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(194, 214, 252, 235),
  )

  let tw : Int = @raylib.measure_text(label, 26)
  @raylib.draw_text(
    label,
    x + (w - tw) / 2,
    y + h / 2 - 13,
    26,
    @raylib.Color::new(240, 246, 255, 252),
  )
}

///|
fn draw_bar(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  value : Int,
  max_v : Int,
  fill : @raylib.Color,
) -> Unit {
  let safe_max : Int = if max_v <= 0 { 1 } else { max_v }
  let mut n : Float = Float::from_int(value) / Float::from_int(safe_max)
  n = clampf(n, 0.0, 1.0)
  let fw : Int = (Float::from_int(w) * n).to_int()

  @raylib.draw_rectangle(x, y, w, h, @raylib.Color::new(18, 24, 34, 255))
  @raylib.draw_rectangle(x, y, fw, h, fill)
  @raylib.draw_rectangle_lines(
    x,
    y,
    w,
    h,
    @raylib.Color::new(164, 182, 214, 255),
  )
}

///|
fn draw_dice_face(
  face : Int,
  x : Int,
  y : Int,
  s : Int,
  col : @raylib.Color,
) -> Unit {
  if face == 0 {
    @raylib.draw_line(x + 16, y + s - 16, x + s - 16, y + 16, col)
    @raylib.draw_line(x + 16, y + s - 22, x + s - 10, y + 10, col)
  } else if face == 1 {
    @raylib.draw_rectangle(x + 18, y + 18, s - 36, s - 36, col)
  } else if face == 2 {
    @raylib.draw_circle(x + s / 2, y + s / 2, 15.0, col)
    @raylib.draw_circle_lines(x + s / 2, y + s / 2, 24.0, col)
  } else if face == 3 {
    @raylib.draw_circle(x + s / 2, y + s / 2, 18.0, col)
    @raylib.draw_rectangle(x + s / 2 - 4, y + s / 2 - 30, 8, 60, col)
  } else if face == 4 {
    @raylib.draw_triangle(
      @raylib.Vector2::new(Float::from_int(x + s / 2), Float::from_int(y + 12)),
      @raylib.Vector2::new(Float::from_int(x + 12), Float::from_int(y + s - 12)),
      @raylib.Vector2::new(
        Float::from_int(x + s - 12),
        Float::from_int(y + s - 12),
      ),
      col,
    )
  } else {
    @raylib.draw_rectangle(x + 14, y + 14, s - 28, s - 28, col)
    @raylib.draw_line(
      x + 10,
      y + 10,
      x + s - 10,
      y + s - 10,
      @raylib.Color::new(248, 242, 126, 252),
    )
    @raylib.draw_line(
      x + 10,
      y + s - 10,
      x + s - 10,
      y + 10,
      @raylib.Color::new(248, 242, 126, 252),
    )
  }
}

///|
fn draw_touch_help() -> Unit {
  @raylib.draw_rectangle(
    24,
    sh - 84,
    624,
    54,
    @raylib.Color::new(16, 20, 30, 180),
  )
  @raylib.draw_text(
    "Mobile: tap dice to play, tap REROLL and END TURN buttons.",
    38,
    sh - 66,
    24,
    @raylib.Color::new(218, 232, 252, 214),
  )
}

///|
fn main {
  @raylib.init_window(sw, sh, "raylib [game] dice roguelite arena 2026")
  @raylib.set_target_fps(60)

  let mut state : Int = 0 // 0 menu, 1 battle, 2 reward, 3 game over, 4 victory
  let mut turn : Int = 0 // 0 player turn, 1 enemy anim

  let player : Player = {
    hp: 120,
    max_hp: 120,
    shield: 0,
    poison: 0,
    energy: 3,
    gold: 0,
    floor: 1,
    wins: 0,
  }

  let enemy : Enemy = {
    kind: 0,
    hp: 100,
    max_hp: 100,
    shield: 0,
    poison: 0,
    rage: 0,
    intent_kind: 0,
    intent_value: 8,
  }

  let art : Artifacts = {
    atk_bonus: 0,
    guard_bonus: 0,
    heal_bonus: 0,
    venom_bonus: 0,
    focus_bonus: 0,
    crush_bonus: 0,
    reroll_bonus: 0,
    start_shield: 0,
    crit_chance: 8,
  }

  let dice : Array[Dice] = Array::makei(max_dice, fn(_i) {
    { value: 1, face: 0, used: false, x: 0.0, y: 0.0, pulse_t: 0.0 }
  })

  let rewards : Array[RewardCard] = Array::makei(3, fn(_i) {
    { kind: 0, value: 0, title: "", desc: "" }
  })

  let sparks : Array[Spark] = Array::makei(max_sparks, fn(_i) {
    {
      active: false,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      life: 0.0,
      size: 0.0,
      kind: 0,
    }
  })

  let mut rerolls_left : Int = 2
  let mut msg : String = ""
  let mut msg_t : Float = 0.0
  let mut enemy_anim_t : Float = 0.0
  let mut bg_t : Float = 0.0
  let mut combo_hits : Int = 0

  fn begin_new_run() -> Unit {
    player.hp = 120
    player.max_hp = 120
    player.shield = 0
    player.poison = 0
    player.energy = 3
    player.gold = 0
    player.floor = 1
    player.wins = 0

    art.atk_bonus = 0
    art.guard_bonus = 0
    art.heal_bonus = 0
    art.venom_bonus = 0
    art.focus_bonus = 0
    art.crush_bonus = 0
    art.reroll_bonus = 0
    art.start_shield = 0
    art.crit_chance = 8

    combo_hits = 0
    turn = 0

    set_enemy(enemy, player.floor)
    roll_enemy_intent(enemy, player.floor)

    init_dice(dice)
    roll_dice(dice, art, true)
    rerolls_left = 2 + art.reroll_bonus

    player.energy = 3 + art.focus_bonus
    player.shield = art.start_shield

    msg = "Combat started"
    msg_t = 2.2
    clear_sparks(sparks)
  }

  fn begin_player_turn() -> Unit {
    turn = 0

    if player.poison > 0 {
      let pdmg : Int = player.poison
      let taken = compute_damage_to_player(player, pdmg)
      player.poison = player.poison - 1
      msg = "Poison dealt \{taken} to you"
      msg_t = 1.4
      burst_sparks(sparks, 330.0, 360.0, 8, 2)
    }

    if player.hp <= 0 {
      state = 3
      msg = "Your deck collapsed"
      msg_t = 3.0
      return
    }

    roll_dice(dice, art, true)
    rerolls_left = 2 + art.reroll_bonus
    player.energy = 3 + art.focus_bonus
    player.energy = clampi(player.energy, 1, 9)
    player.shield = player.shield + art.start_shield / 2

    for i = 0; i < dice.length(); i = i + 1 {
      dice[i].used = false
    }

    roll_enemy_intent(enemy, player.floor)
  }

  fn begin_enemy_turn() -> Unit {
    turn = 1
    enemy_anim_t = 0.55

    if enemy.poison > 0 {
      let pdmg : Int = enemy.poison
      let dealt = compute_damage_to_enemy(enemy, pdmg)
      enemy.poison = enemy.poison - 1
      if dealt > 0 {
        msg = "Enemy takes poison \{dealt}"
        msg_t = 1.2
        burst_sparks(sparks, 978.0, 360.0, 8, 2)
      }
    }

    if enemy.hp <= 0 {
      return
    }

    if enemy.intent_kind == 0 {
      let dmg : Int = enemy.intent_value + enemy.rage
      let taken = compute_damage_to_player(player, dmg)
      msg = "Enemy attacked for \{dmg}"
      msg_t = 1.2
      if taken > 0 {
        burst_sparks(sparks, 330.0, 360.0, 10, 2)
      } else {
        burst_sparks(sparks, 330.0, 360.0, 6, 1)
      }
    } else if enemy.intent_kind == 1 {
      enemy.shield = enemy.shield + enemy.intent_value
      msg = "Enemy gains shield"
      msg_t = 1.2
      burst_sparks(sparks, 978.0, 360.0, 7, 1)
    } else if enemy.intent_kind == 2 {
      enemy.rage = enemy.rage + enemy.intent_value
      msg = "Enemy rage rises"
      msg_t = 1.2
      burst_sparks(sparks, 978.0, 360.0, 7, 0)
    } else {
      player.poison = player.poison + enemy.intent_value
      msg = "You are poisoned"
      msg_t = 1.2
      burst_sparks(sparks, 330.0, 360.0, 9, 2)
    }

    if player.hp <= 0 {
      state = 3
      msg = "System failure"
      msg_t = 3.0
      return
    }
  }

  begin_new_run()

  while not(@raylib.window_should_close()) {
    let mut dt : Float = @raylib.get_frame_time()
    if dt > 0.033 {
      dt = 0.033
    }

    if @raylib.is_key_pressed(@raylib.KeyF11) {
      @raylib.toggle_fullscreen()
    }

    bg_t = bg_t + dt * 1.2
    while bg_t >= 10000.0 {
      bg_t = bg_t - 10000.0
    }

    if msg_t > 0.0 {
      msg_t = msg_t - dt
      if msg_t < 0.0 {
        msg_t = 0.0
      }
    }

    let mouse = @raylib.get_mouse_position()
    let click : Bool = @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft)

    update_sparks(sparks, dt)

    if state == 0 {
      if click || @raylib.is_key_pressed(@raylib.KeyEnter) {
        begin_new_run()
        state = 1
      }
    } else if state == 1 {
      if turn == 1 {
        enemy_anim_t = enemy_anim_t - dt
        if enemy_anim_t <= 0.0 {
          if enemy.hp <= 0 {
            player.gold = player.gold + 24 + player.floor * 8
            player.wins = player.wins + 1

            generate_rewards(rewards, player.floor)
            state = 2
            msg = "Victory reward"
            msg_t = 2.0
            burst_sparks(sparks, 682.0, 220.0, 18, 0)
          } else {
            begin_player_turn()
          }
        }
      } else {
        for i = 0; i < dice.length(); i = i + 1 {
          if dice[i].pulse_t > 0.0 {
            dice[i].pulse_t = dice[i].pulse_t - dt
            if dice[i].pulse_t < 0.0 {
              dice[i].pulse_t = 0.0
            }
          }
        }

        let mut clicked_die : Int = -1
        let mut hovered_die : Int = -1

        for i = 0; i < dice.length(); i = i + 1 {
          let col : Int = i % 3
          let row : Int = i / 3
          let dx : Int = 458 + col * 154
          let dy : Int = 444 + row * 154
          dice[i].x = Float::from_int(dx)
          dice[i].y = Float::from_int(dy)

          if inside_rect(mouse.x, mouse.y, dx, dy, 132, 132) {
            hovered_die = i
            if click {
              clicked_die = i
            }
          }
        }

        let reroll_x = 1028
        let reroll_y = 468
        let reroll_w = 280
        let reroll_h = 64
        let reroll_hover : Bool = inside_rect(
          mouse.x,
          mouse.y,
          reroll_x,
          reroll_y,
          reroll_w,
          reroll_h,
        )

        let end_x = 1028
        let end_y = 550
        let end_w = 280
        let end_h = 64
        let end_hover : Bool = inside_rect(
          mouse.x,
          mouse.y,
          end_x,
          end_y,
          end_w,
          end_h,
        )

        let can_reroll : Bool = rerolls_left > 0 && player.energy > 0
        let mut reroll_trigger : Bool = false
        if @raylib.is_key_pressed(@raylib.KeyR) && can_reroll {
          reroll_trigger = true
        }
        if click && reroll_hover && can_reroll {
          reroll_trigger = true
        }

        if reroll_trigger {
          rerolls_left = rerolls_left - 1
          player.energy = player.energy - 1
          for i = 0; i < dice.length(); i = i + 1 {
            if not(dice[i].used) {
              dice[i].face = roll_face(art)
              dice[i].value = @raylib.get_random_value(1, 6)
              dice[i].pulse_t = 0.12 + Float::from_int(i) * 0.02
            }
          }
          msg = "Reroll"
          msg_t = 0.8
          burst_sparks(sparks, 1168.0, 502.0, 8, 3)
        }

        let mut end_turn_trigger : Bool = false
        if @raylib.is_key_pressed(@raylib.KeyE) {
          end_turn_trigger = true
        }
        if click && end_hover {
          end_turn_trigger = true
        }

        if clicked_die >= 0 && player.energy > 0 && not(dice[clicked_die].used) {
          let (new_msg, dealt) = apply_face(
            dice[clicked_die].face,
            dice[clicked_die].value,
            player,
            enemy,
            art,
            sparks,
            combo_hits,
          )

          dice[clicked_die].used = true
          player.energy = player.energy - 1
          msg = new_msg
          msg_t = 1.2

          if dealt > 0 {
            combo_hits = combo_hits + 1
          } else {
            combo_hits = 0
          }

          if enemy.hp <= 0 {
            enemy.hp = 0
            begin_enemy_turn()
          }
        }

        if enemy.hp > 0 {
          if player.energy <= 0 {
            end_turn_trigger = true
          }

          if end_turn_trigger {
            begin_enemy_turn()
          }
        }

        if hovered_die >= 0 {
          let n = face_name(dice[hovered_die].face)
          let d = face_desc(dice[hovered_die].face)
          msg = "\{n}: \{d}"
          msg_t = 0.24
        }
      }

      if player.hp <= 0 {
        state = 3
        msg = "System down"
        msg_t = 2.6
      }
    } else if state == 2 {
      let mut picked : Int = -1

      for i = 0; i < 3; i = i + 1 {
        let x = 194 + i * 330
        let y = 292
        if inside_rect(mouse.x, mouse.y, x, y, 290, 220) {
          if click {
            picked = i
          }
          if @raylib.is_key_pressed(@raylib.KeyOne + i) {
            picked = i
          }
        }
      }

      if @raylib.is_key_pressed(@raylib.KeyOne) {
        picked = 0
      }
      if @raylib.is_key_pressed(@raylib.KeyTwo) {
        picked = 1
      }
      if @raylib.is_key_pressed(@raylib.KeyThree) {
        picked = 2
      }

      if picked >= 0 {
        let idx : Int = clampi(picked, 0, 2)
        let t = apply_reward(rewards[idx], player, art)
        msg = t
        msg_t = 1.8

        player.floor = player.floor + 1

        if player.floor > 12 {
          state = 4
          msg = "Arena conquered"
          msg_t = 3.2
          burst_sparks(sparks, Float::from_int(sw / 2), 220.0, 30, 0)
        } else {
          set_enemy(enemy, player.floor)
          roll_enemy_intent(enemy, player.floor)
          rerolls_left = 2 + art.reroll_bonus
          player.energy = 3 + art.focus_bonus
          player.shield = player.shield / 2 + art.start_shield
          combo_hits = 0

          for i = 0; i < dice.length(); i = i + 1 {
            dice[i].used = false
          }
          roll_dice(dice, art, true)

          state = 1
          turn = 0
        }
      }
    } else if state == 3 {
      if click ||
        @raylib.is_key_pressed(@raylib.KeyR) ||
        @raylib.is_key_pressed(@raylib.KeyEnter) {
        state = 0
      }
    } else if click || @raylib.is_key_pressed(@raylib.KeyEnter) {
      state = 0
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(10, 12, 19, 255))

    // background layers
    @raylib.draw_rectangle_gradient_v(
      0,
      0,
      sw,
      sh,
      @raylib.Color::new(18, 26, 48, 255),
      @raylib.Color::new(10, 12, 22, 255),
    )

    for i = 0; i < 24; i = i + 1 {
      let fi : Float = Float::from_int(i)
      let x : Int = (fi * 80.0 + bg_t * (18.0 + Float::from_int(i % 5) * 7.0)).to_int() %
        sw
      let y : Int = 50 + (fi * 39.0 + bg_t * 22.0).to_int() % 240
      @raylib.draw_circle(
        x,
        y,
        2.0 + Float::from_int(i % 3),
        @raylib.Color::new(110, 150, 220, 152),
      )
    }

    for i = 0; i < 14; i = i + 1 {
      let fi : Float = Float::from_int(i)
      let base_x : Float = fi * 108.0 -
        bg_t * (18.0 + Float::from_int(i % 4) * 6.0)
      let wx : Int = (base_x % Float::from_int(sw + 220)).to_int()
      let y : Int = 180 + i % 4 * 28
      @raylib.draw_rectangle(
        wx - 110,
        y,
        220,
        26,
        @raylib.Color::new(34, 54, 96, 94),
      )
    }

    draw_panel(40, 28, 620, 180, @raylib.Color::new(104, 142, 232, 220))
    draw_panel(706, 28, 620, 180, @raylib.Color::new(230, 124, 126, 220))

    @raylib.draw_text(
      "Pilot",
      62,
      44,
      34,
      @raylib.Color::new(210, 236, 255, 255),
    )
    @raylib.draw_text(
      "Enemy",
      730,
      44,
      34,
      @raylib.Color::new(255, 214, 214, 255),
    )

    @raylib.draw_text("HP", 64, 88, 24, @raylib.Color::new(220, 228, 244, 255))
    draw_bar(
      114,
      92,
      510,
      24,
      player.hp,
      player.max_hp,
      @raylib.Color::new(120, 226, 156, 255),
    )
    @raylib.draw_text(
      "\{player.hp}/\{player.max_hp}",
      636 - 138,
      90,
      24,
      @raylib.Color::new(232, 248, 236, 255),
    )

    @raylib.draw_text("HP", 730, 88, 24, @raylib.Color::new(220, 228, 244, 255))
    draw_bar(
      780,
      92,
      510,
      24,
      enemy.hp,
      enemy.max_hp,
      @raylib.Color::new(242, 128, 122, 255),
    )
    @raylib.draw_text(
      "\{enemy.hp}/\{enemy.max_hp}",
      1290 - 136,
      90,
      24,
      @raylib.Color::new(255, 236, 236, 255),
    )

    @raylib.draw_text(
      "Shield \{player.shield}",
      64,
      132,
      26,
      @raylib.Color::new(146, 196, 248, 255),
    )
    @raylib.draw_text(
      "Poison \{player.poison}",
      262,
      132,
      26,
      @raylib.Color::new(130, 222, 136, 255),
    )
    @raylib.draw_text(
      "Energy \{player.energy}",
      464,
      132,
      26,
      @raylib.Color::new(236, 218, 136, 255),
    )

    @raylib.draw_text(
      "\{enemy_name(enemy.kind)}",
      730,
      132,
      26,
      enemy_color(enemy.kind),
    )
    @raylib.draw_text(
      "Shield \{enemy.shield}",
      964,
      132,
      24,
      @raylib.Color::new(156, 202, 250, 255),
    )
    @raylib.draw_text(
      "Poison \{enemy.poison}",
      1132,
      132,
      24,
      @raylib.Color::new(130, 232, 146, 255),
    )

    let intent_col = if enemy.intent_kind == 0 {
      @raylib.Color::new(246, 136, 142, 255)
    } else if enemy.intent_kind == 1 {
      @raylib.Color::new(154, 210, 250, 255)
    } else if enemy.intent_kind == 2 {
      @raylib.Color::new(250, 192, 118, 255)
    } else {
      @raylib.Color::new(136, 242, 144, 255)
    }
    @raylib.draw_text("Intent: \{intent_text(enemy)}", 730, 162, 22, intent_col)

    draw_panel(40, 228, 1286, 500, @raylib.Color::new(106, 124, 166, 224))

    @raylib.draw_circle(330, 468, 70.0, @raylib.Color::new(76, 112, 202, 190))
    @raylib.draw_circle(330, 468, 46.0, @raylib.Color::new(106, 170, 244, 232))
    @raylib.draw_text("YOU", 292, 454, 28, @raylib.Color::new(18, 28, 42, 250))

    let mut enemy_x : Int = 978
    if turn == 1 {
      enemy_x = enemy_x + (@math.sinf(enemy_anim_t * 34.0) * 18.0).to_int()
    }

    @raylib.draw_circle(enemy_x, 360, 82.0, enemy_color(enemy.kind))
    @raylib.draw_circle(enemy_x, 360, 58.0, @raylib.Color::new(30, 30, 44, 84))
    @raylib.draw_text(
      "ENEMY",
      enemy_x - 62,
      348,
      24,
      @raylib.Color::new(244, 246, 252, 252),
    )

    if state == 1 {
      for i = 0; i < dice.length(); i = i + 1 {
        let x : Int = dice[i].x.to_int()
        let y : Int = dice[i].y.to_int()

        let over : Bool = inside_rect(mouse.x, mouse.y, x, y, 132, 132)
        let mut bg = if dice[i].used {
          @raylib.Color::new(72, 76, 92, 210)
        } else if over && turn == 0 {
          @raylib.Color::new(132, 156, 222, 244)
        } else {
          @raylib.Color::new(94, 112, 170, 232)
        }

        if dice[i].pulse_t > 0.0 {
          let glow : Int = (dice[i].pulse_t * 420.0).to_int()
          bg = @raylib.Color::new(
            clampi(94 + glow / 9, 0, 255),
            clampi(112 + glow / 8, 0, 255),
            clampi(170 + glow / 7, 0, 255),
            240,
          )
        }

        @raylib.draw_rectangle(x, y, 132, 132, bg)
        @raylib.draw_rectangle_lines(
          x,
          y,
          132,
          132,
          @raylib.Color::new(224, 234, 252, 246),
        )

        let icon_col = if dice[i].used {
          @raylib.Color::new(176, 184, 202, 240)
        } else {
          @raylib.Color::new(242, 246, 255, 252)
        }
        draw_dice_face(dice[i].face, x, y, 132, icon_col)

        let vcol = if dice[i].used {
          @raylib.Color::new(196, 206, 226, 220)
        } else {
          @raylib.Color::new(250, 246, 132, 252)
        }
        @raylib.draw_text("\{dice[i].value}", x + 10, y + 8, 36, vcol)

        @raylib.draw_text(
          face_name(dice[i].face),
          x + 10,
          y + 98,
          20,
          @raylib.Color::new(234, 242, 252, 246),
        )
      }

      let reroll_x = 1028
      let reroll_y = 468
      let reroll_w = 280
      let reroll_h = 64
      let reroll_hover : Bool = inside_rect(
        mouse.x,
        mouse.y,
        reroll_x,
        reroll_y,
        reroll_w,
        reroll_h,
      )
      let can_reroll : Bool = turn == 0 && rerolls_left > 0 && player.energy > 0
      draw_button(
        reroll_x, reroll_y, reroll_w, reroll_h, "REROLL (-1 energy) [R]", can_reroll,
        reroll_hover,
      )

      let end_x = 1028
      let end_y = 550
      let end_w = 280
      let end_h = 64
      let end_hover : Bool = inside_rect(
        mouse.x,
        mouse.y,
        end_x,
        end_y,
        end_w,
        end_h,
      )
      draw_button(
        end_x,
        end_y,
        end_w,
        end_h,
        "END TURN [E]",
        turn == 0,
        end_hover,
      )

      @raylib.draw_text(
        "Rerolls: \{rerolls_left}",
        1028,
        442,
        24,
        @raylib.Color::new(216, 232, 252, 252),
      )
      @raylib.draw_text(
        "Floor \{player.floor}/12",
        1030,
        628,
        30,
        @raylib.Color::new(246, 226, 142, 252),
      )
      @raylib.draw_text(
        "Gold \{player.gold}",
        1030,
        664,
        28,
        @raylib.Color::new(242, 220, 128, 252),
      )

      @raylib.draw_text(
        "Tap any dice to trigger it",
        66,
        638,
        30,
        @raylib.Color::new(212, 230, 252, 236),
      )
      @raylib.draw_text(
        "Combos \{combo_hits}",
        66,
        674,
        28,
        @raylib.Color::new(168, 234, 184, 236),
      )

      draw_touch_help()
    }

    if state == 0 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(6, 8, 14, 196))
      @raylib.draw_text(
        "DICE ROGUELITE ARENA",
        sw / 2 - 322,
        180,
        62,
        @raylib.Color::new(232, 242, 252, 255),
      )
      @raylib.draw_text(
        "Build a run in 12 floors",
        sw / 2 - 170,
        266,
        34,
        @raylib.Color::new(186, 210, 242, 255),
      )

      draw_panel(
        sw / 2 - 420,
        322,
        840,
        230,
        @raylib.Color::new(150, 178, 244, 236),
      )
      @raylib.draw_text(
        "Desktop",
        sw / 2 - 390,
        348,
        30,
        @raylib.Color::new(242, 246, 254, 255),
      )
      @raylib.draw_text(
        "Click dice to play actions",
        sw / 2 - 390,
        390,
        28,
        @raylib.Color::new(218, 232, 252, 244),
      )
      @raylib.draw_text(
        "R = reroll, E = end turn",
        sw / 2 - 390,
        426,
        28,
        @raylib.Color::new(218, 232, 252, 244),
      )
      @raylib.draw_text(
        "Pick one upgrade after each win",
        sw / 2 - 390,
        462,
        28,
        @raylib.Color::new(218, 232, 252, 244),
      )

      @raylib.draw_text(
        "Mobile",
        sw / 2 + 56,
        348,
        30,
        @raylib.Color::new(242, 246, 254, 255),
      )
      @raylib.draw_text(
        "Tap dice and tap buttons",
        sw / 2 + 56,
        390,
        28,
        @raylib.Color::new(218, 232, 252, 244),
      )
      @raylib.draw_text(
        "All actions are touch-friendly",
        sw / 2 + 56,
        426,
        28,
        @raylib.Color::new(218, 232, 252, 244),
      )
      @raylib.draw_text(
        "No keyboard required",
        sw / 2 + 56,
        462,
        28,
        @raylib.Color::new(218, 232, 252, 244),
      )

      draw_button(
        sw / 2 - 160,
        590,
        320,
        84,
        "START RUN",
        true,
        inside_rect(mouse.x, mouse.y, sw / 2 - 160, 590, 320, 84),
      )
    } else if state == 2 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(6, 10, 18, 190))
      @raylib.draw_text(
        "Choose One Upgrade",
        sw / 2 - 240,
        172,
        56,
        @raylib.Color::new(238, 246, 255, 255),
      )
      @raylib.draw_text(
        "[1] [2] [3] or tap card",
        sw / 2 - 144,
        236,
        28,
        @raylib.Color::new(194, 220, 252, 240),
      )

      for i = 0; i < 3; i = i + 1 {
        let x = 194 + i * 330
        let y = 292
        let over : Bool = inside_rect(mouse.x, mouse.y, x, y, 290, 220)

        let fill = if over {
          @raylib.Color::new(102, 126, 204, 246)
        } else {
          @raylib.Color::new(70, 88, 152, 232)
        }

        @raylib.draw_rectangle(x, y, 290, 220, fill)
        @raylib.draw_rectangle_lines(
          x,
          y,
          290,
          220,
          @raylib.Color::new(218, 232, 252, 250),
        )

        @raylib.draw_text(
          "\{i + 1}",
          x + 14,
          y + 10,
          28,
          @raylib.Color::new(250, 236, 142, 252),
        )
        @raylib.draw_text(
          rewards[i].title,
          x + 18,
          y + 52,
          34,
          @raylib.Color::new(242, 248, 255, 252),
        )
        @raylib.draw_text(
          rewards[i].desc,
          x + 18,
          y + 108,
          30,
          @raylib.Color::new(222, 236, 252, 252),
        )
      }
    } else if state == 3 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(10, 8, 12, 208))
      @raylib.draw_text(
        "RUN FAILED",
        sw / 2 - 170,
        194,
        76,
        @raylib.Color::new(252, 158, 170, 252),
      )
      @raylib.draw_text(
        "Reached floor \{player.floor}",
        sw / 2 - 144,
        300,
        36,
        @raylib.Color::new(232, 232, 246, 246),
      )
      @raylib.draw_text(
        "Wins \{player.wins}    Gold \{player.gold}",
        sw / 2 - 180,
        350,
        34,
        @raylib.Color::new(222, 216, 150, 246),
      )
      @raylib.draw_text(
        "Tap or press Enter/R to return",
        sw / 2 - 216,
        436,
        30,
        @raylib.Color::new(218, 232, 252, 246),
      )
    } else if state == 4 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(8, 12, 8, 186))
      @raylib.draw_text(
        "ARENA CLEARED",
        sw / 2 - 246,
        176,
        74,
        @raylib.Color::new(168, 246, 174, 252),
      )
      @raylib.draw_text(
        "All 12 floors conquered",
        sw / 2 - 184,
        286,
        36,
        @raylib.Color::new(224, 246, 228, 246),
      )
      @raylib.draw_text(
        "Gold \{player.gold}    HP \{player.hp}",
        sw / 2 - 168,
        340,
        34,
        @raylib.Color::new(244, 232, 154, 246),
      )
      @raylib.draw_text(
        "Tap or press Enter for new run",
        sw / 2 - 208,
        432,
        30,
        @raylib.Color::new(218, 236, 252, 246),
      )
    }

    if msg_t > 0.0 {
      let box_w = @raylib.measure_text(msg, 30) + 44
      let box_x = sw / 2 - box_w / 2
      @raylib.draw_rectangle(
        box_x,
        206,
        box_w,
        52,
        @raylib.Color::new(14, 18, 28, 220),
      )
      @raylib.draw_rectangle_lines(
        box_x,
        206,
        box_w,
        52,
        @raylib.Color::new(184, 208, 242, 242),
      )
      @raylib.draw_text(
        msg,
        box_x + 22,
        218,
        30,
        @raylib.Color::new(238, 246, 255, 250),
      )
    }

    draw_sparks(sparks)

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
