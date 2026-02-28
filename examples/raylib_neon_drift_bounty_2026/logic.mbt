///|
fn clear_entities(game : Game) -> Unit {
  for entity in game.entities {
    entity.active = false
    entity.kind = foe_bike
    entity.x = 0.0
    entity.y = 0.0
    entity.vx = 0.0
    entity.vy = 0.0
    entity.w = 0.0
    entity.h = 0.0
    entity.hp = 0.0
    entity.shot_cd = 0.0
    entity.spin = 0.0
    entity.cloak = false
    entity.reward = 0
  }
}

///|
fn clear_bullets(game : Game) -> Unit {
  for bullet in game.bullets {
    bullet.active = false
    bullet.from_player = true
    bullet.x = 0.0
    bullet.y = 0.0
    bullet.vx = 0.0
    bullet.vy = 0.0
    bullet.life = 0.0
    bullet.dmg = 0.0
    bullet.kind = 0
  }
}

///|
fn clear_sparks(game : Game) -> Unit {
  for spark in game.sparks {
    spark.active = false
    spark.x = 0.0
    spark.y = 0.0
    spark.vx = 0.0
    spark.vy = 0.0
    spark.life = 0.0
    spark.size = 0.0
    spark.kind = 0
  }
}

///|
fn clear_rings(game : Game) -> Unit {
  for ring in game.rings {
    ring.active = false
    ring.x = 0.0
    ring.y = 0.0
    ring.r = 0.0
    ring.life = 0.0
    ring.kind = 0
  }
}

///|
fn clear_images(game : Game) -> Unit {
  for image in game.images {
    image.active = false
    image.x = 0.0
    image.y = 0.0
    image.w = 0.0
    image.h = 0.0
    image.rot = 0.0
    image.life = 0.0
    image.kind = 0
  }
}

///|
fn reset_player(hero : Player) -> Unit {
  hero.x = Float::from_int(screen_w / 2)
  hero.y = Float::from_int(screen_h) * 0.76
  hero.vx = 0.0
  hero.vy = 0.0
  hero.w = player_w
  hero.h = player_h
  hero.heading = 0.0
  hero.invuln = 0.0
  hero.hurt_t = 0.0
  hero.muzzle_t = 0.0
  hero.engine_t = 0.0
}

///|
fn alloc_entity(game : Game) -> Int {
  for i in 0..<game.entities.length() {
    if not(game.entities[i].active) {
      return i
    }
  }

  let mut best = 0
  let mut best_y = game.entities[0].y
  for i in 1..<game.entities.length() {
    if game.entities[i].y > best_y {
      best_y = game.entities[i].y
      best = i
    }
  }
  best
}

///|
fn alloc_bullet(game : Game) -> Int {
  for i in 0..<game.bullets.length() {
    if not(game.bullets[i].active) {
      return i
    }
  }

  let mut best = 0
  let mut best_life = game.bullets[0].life
  for i in 1..<game.bullets.length() {
    if game.bullets[i].life < best_life {
      best_life = game.bullets[i].life
      best = i
    }
  }
  best
}

///|
fn alloc_spark(game : Game) -> Int {
  for i in 0..<game.sparks.length() {
    if not(game.sparks[i].active) {
      return i
    }
  }

  let mut best = 0
  let mut best_life = game.sparks[0].life
  for i in 1..<game.sparks.length() {
    if game.sparks[i].life < best_life {
      best_life = game.sparks[i].life
      best = i
    }
  }
  best
}

///|
fn alloc_ring(game : Game) -> Int {
  for i in 0..<game.rings.length() {
    if not(game.rings[i].active) {
      return i
    }
  }

  let mut best = 0
  let mut best_life = game.rings[0].life
  for i in 1..<game.rings.length() {
    if game.rings[i].life < best_life {
      best_life = game.rings[i].life
      best = i
    }
  }
  best
}

///|
fn alloc_image(game : Game) -> Int {
  for i in 0..<game.images.length() {
    if not(game.images[i].active) {
      return i
    }
  }

  let mut best = 0
  let mut best_life = game.images[0].life
  for i in 1..<game.images.length() {
    if game.images[i].life < best_life {
      best_life = game.images[i].life
      best = i
    }
  }
  best
}

///|
fn emit_spark(
  game : Game,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  life : Float,
  size : Float,
  kind : Int,
) -> Unit {
  let i = alloc_spark(game)
  game.sparks[i].active = true
  game.sparks[i].x = x
  game.sparks[i].y = y
  game.sparks[i].vx = vx
  game.sparks[i].vy = vy
  game.sparks[i].life = life
  game.sparks[i].size = size
  game.sparks[i].kind = kind
}

///|
fn burst(game : Game, x : Float, y : Float, count : Int, kind : Int) -> Unit {
  for _i in 0..<count {
    emit_spark(
      game,
      x + randf(-22.0, 22.0),
      y + randf(-22.0, 22.0),
      randf(-280.0, 280.0),
      randf(-280.0, 280.0),
      randf(0.24, 1.04),
      randf(1.2, 6.8),
      kind,
    )
  }
}

///|
fn spawn_ring(
  game : Game,
  x : Float,
  y : Float,
  r : Float,
  life : Float,
  kind : Int,
) -> Unit {
  let i = alloc_ring(game)
  game.rings[i].active = true
  game.rings[i].x = x
  game.rings[i].y = y
  game.rings[i].r = r
  game.rings[i].life = life
  game.rings[i].kind = kind
}

///|
fn emit_image(
  game : Game,
  x : Float,
  y : Float,
  w : Float,
  h : Float,
  rot : Float,
  life : Float,
  kind : Int,
) -> Unit {
  let i = alloc_image(game)
  game.images[i].active = true
  game.images[i].x = x
  game.images[i].y = y
  game.images[i].w = w
  game.images[i].h = h
  game.images[i].rot = rot
  game.images[i].life = life
  game.images[i].kind = kind
}

///|
fn spawn_bullet(
  game : Game,
  from_player : Bool,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  life : Float,
  dmg : Float,
  kind : Int,
) -> Unit {
  let i = alloc_bullet(game)
  game.bullets[i].active = true
  game.bullets[i].from_player = from_player
  game.bullets[i].x = x
  game.bullets[i].y = y
  game.bullets[i].vx = vx
  game.bullets[i].vy = vy
  game.bullets[i].life = life
  game.bullets[i].dmg = dmg
  game.bullets[i].kind = kind
}

///|
fn spawn_entity(
  game : Game,
  kind : Int,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  w : Float,
  h : Float,
  hp : Float,
  shot_cd : Float,
  cloak : Bool,
  reward : Int,
) -> Unit {
  let i = alloc_entity(game)
  game.entities[i].active = true
  game.entities[i].kind = kind
  game.entities[i].x = x
  game.entities[i].y = y
  game.entities[i].vx = vx
  game.entities[i].vy = vy
  game.entities[i].w = w
  game.entities[i].h = h
  game.entities[i].hp = hp
  game.entities[i].shot_cd = shot_cd
  game.entities[i].spin = randf(0.0, 6.283)
  game.entities[i].cloak = cloak
  game.entities[i].reward = reward
}

///|
fn score_gain(game : Game, base : Int) -> Int {
  let bonus = base * game.combo / 5
  base + bonus
}

///|
fn add_score(game : Game, base : Int) -> Unit {
  let gained = score_gain(game, base)
  game.score = game.score + gained
  if game.score > game.best_score {
    game.best_score = game.score
  }
}

///|
fn push_combo(game : Game) -> Unit {
  game.combo = clampi(game.combo + 1, 0, 24)
  game.combo_t = 3.6
}

///|
fn reset_combo(game : Game) -> Unit {
  game.combo = 0
  game.combo_t = 0.0
}

///|
fn entity_is_hostile(kind : Int) -> Bool {
  kind == foe_bike ||
  kind == foe_drone ||
  kind == foe_truck ||
  kind == foe_laser
}

///|
fn is_pickup(kind : Int) -> Bool {
  kind == item_credit || kind == item_battery || kind == item_hackcell
}

///|
fn entity_hit_radius(e : Entity) -> Float {
  maxf(e.w, e.h) * 0.38
}

///|
fn player_hit_radius(hero : Player) -> Float {
  maxf(hero.w, hero.h) * 0.34
}

///|
fn damage_player(game : Game, dmg : Float) -> Unit {
  if game.hero.invuln > 0.0 {
    return
  }

  game.shield = maxf(0.0, game.shield - dmg)
  game.hero.invuln = invuln_after_hit
  game.hero.hurt_t = 0.58
  game.flash_t = maxf(game.flash_t, 0.34)
  game.shake_t = maxf(game.shake_t, 0.6)

  burst(game, game.hero.x, game.hero.y, 22, 1)
  reset_combo(game)

  if game.shield <= 0.0 {
    game.state = state_game_over
    game.result_t = 0.0
  }
}

///|
fn start_stage(game : Game, stage : Int) -> Unit {
  clear_entities(game)
  clear_bullets(game)
  clear_sparks(game)
  clear_rings(game)
  clear_images(game)

  reset_player(game.hero)

  game.state = state_play
  game.stage = stage
  game.distance = 0.0
  game.stage_goal = stage_distance_base +
    Float::from_int(stage - 1) * stage_distance_gain
  game.scroll_speed = base_scroll_speed +
    Float::from_int(stage - 1) * stage_scroll_gain
  game.next_spawn_y = spawn_start_y

  game.fire_cd = 0.0
  game.boost_cd = 0.0
  game.boost_t = 0.0
  game.hack_cd = 0.0
  game.hack_t = 0.0
  game.result_t = 0.0
  game.flash_t = 0.0
  game.shake_t = 0.0
  game.hint_t = 0.0
  reset_combo(game)

  if stage <= 1 {
    game.score = 0
    game.credits = 0
    game.kills = 0
    game.shield = player_shield_max
    game.energy = player_energy_max
  } else {
    game.shield = minf(player_shield_max, game.shield + 22.0)
    game.energy = minf(player_energy_max, game.energy + 34.0)
  }

  spawn_ring(game, game.hero.x, game.hero.y, 16.0, 0.72, 0)
}

///|
fn init_title_scene(game : Game) -> Unit {
  clear_entities(game)
  clear_bullets(game)
  clear_sparks(game)
  clear_rings(game)
  clear_images(game)
  reset_player(game.hero)

  game.state = state_title
  game.stage = 1
  game.distance = 0.0
  game.stage_goal = stage_distance_base
  game.score = 0
  game.credits = 0
  game.kills = 0
  game.combo = 0
  game.combo_t = 0.0
  game.shield = player_shield_max
  game.energy = player_energy_max

  game.fire_cd = 0.0
  game.boost_cd = 0.0
  game.boost_t = 0.0
  game.hack_cd = 0.0
  game.hack_t = 0.0

  game.time_s = 0.0
  game.flash_t = 0.0
  game.shake_t = 0.0
  game.result_t = 0.0
  game.hint_t = 0.0

  game.scroll_speed = base_scroll_speed
  game.next_spawn_y = spawn_start_y
}

///|
fn start_run(game : Game) -> Unit {
  start_stage(game, 1)
}

///|
fn spawn_enemy_pack(game : Game, y : Float) -> Unit {
  let depth = game.distance + (Float::from_int(screen_h) - y)
  let center = road_center_at(depth, game.time_s)

  let pack = 1 + randi(0, 2)
  for _i in 0..<pack {
    let roll = randi(0, 99)

    if roll < 34 {
      let lane = randi(0, lanes_count - 1)
      let x = lane_x(lane, center) + randf(-12.0, 12.0)
      spawn_entity(
        game,
        foe_bike,
        x,
        y + randf(-28.0, 20.0),
        randf(-44.0, 44.0),
        randf(-20.0, 40.0),
        44.0,
        76.0,
        18.0 + Float::from_int(game.stage - 1) * 3.0,
        randf(0.42, 1.22),
        false,
        120,
      )
    } else if roll < 56 {
      let lane = randi(0, lanes_count - 1)
      let x = lane_x(lane, center) + randf(-16.0, 16.0)
      spawn_entity(
        game,
        foe_drone,
        x,
        y + randf(-26.0, 24.0),
        randf(-60.0, 60.0),
        randf(-10.0, 30.0),
        40.0,
        40.0,
        12.0 + Float::from_int(game.stage - 1) * 2.0,
        randf(0.26, 0.9),
        game.stage >= 3 && chance(26),
        110,
      )
    } else if roll < 70 {
      let lane = randi(0, lanes_count - 1)
      let x = lane_x(lane, center)
      spawn_entity(
        game,
        foe_truck,
        x,
        y + randf(-32.0, 22.0),
        randf(-18.0, 18.0),
        randf(-16.0, 18.0),
        82.0,
        124.0,
        46.0 + Float::from_int(game.stage - 1) * 7.0,
        randf(0.7, 1.8),
        false,
        190,
      )
    } else if roll < 80 {
      let lane = randi(0, lanes_count - 1)
      let x = lane_x(lane, center)
      spawn_entity(
        game,
        foe_laser,
        x,
        y + randf(-14.0, 12.0),
        0.0,
        randf(-6.0, 12.0),
        126.0,
        18.0,
        16.0,
        randf(0.9, 2.0),
        false,
        96,
      )
    } else if roll < 90 {
      let x = road_spawn_x(game.distance, game.time_s, game.stage, y)
      spawn_entity(
        game,
        item_credit,
        x,
        y + randf(-18.0, 18.0),
        randf(-34.0, 34.0),
        randf(-14.0, 16.0),
        34.0,
        34.0,
        1.0,
        0.0,
        false,
        0,
      )
    } else if roll < 96 {
      let x = road_spawn_x(game.distance, game.time_s, game.stage, y)
      spawn_entity(
        game,
        item_battery,
        x,
        y + randf(-18.0, 18.0),
        randf(-28.0, 28.0),
        randf(-12.0, 18.0),
        38.0,
        38.0,
        1.0,
        0.0,
        false,
        0,
      )
    } else {
      let x = road_spawn_x(game.distance, game.time_s, game.stage, y)
      spawn_entity(
        game,
        item_hackcell,
        x,
        y + randf(-14.0, 14.0),
        randf(-20.0, 20.0),
        randf(-10.0, 14.0),
        34.0,
        34.0,
        1.0,
        0.0,
        false,
        0,
      )
    }
  }
}

///|
fn spawn_step(game : Game, dt : Float) -> Unit {
  game.next_spawn_y = game.next_spawn_y + game.scroll_speed * dt

  let mut spawn_count = 0
  while game.next_spawn_y >= 0.0 && spawn_count < 18 {
    game.next_spawn_y = game.next_spawn_y -
      randf(spawn_spacing_min, spawn_spacing_max)
    spawn_enemy_pack(game, game.next_spawn_y)
    spawn_count = spawn_count + 1
  }
}

///|
fn apply_hack_pulse(game : Game) -> Unit {
  game.hack_cd = hack_cd_time
  game.hack_t = hack_time

  spawn_ring(game, game.hero.x, game.hero.y, 14.0, 0.9, 2)
  burst(game, game.hero.x, game.hero.y, 24, 2)

  let rr2 = hack_radius * hack_radius
  let kill2 = hack_pulse_kill * hack_pulse_kill

  for entity in game.entities {
    if not(entity.active) {
      continue
    }

    let d2 = dist2(
      game.hero.x,
      game.hero.y,
      entity.x,
      entity.y,
    )
    if d2 > rr2 {
      continue
    }

    entity.cloak = false

    if entity_is_hostile(entity.kind) && d2 <= kill2 {
      let kind = entity.kind
      let x = entity.x
      let y = entity.y
      entity.active = false
      add_score(game, if kind == foe_truck { 140 } else { 88 })
      push_combo(game)
      burst(game, x, y, 18, 1)
      spawn_ring(game, x, y, 10.0, 0.52, 1)
      game.kills = game.kills + 1
    }
  }

  for bullet in game.bullets {
    if not(bullet.active) || bullet.from_player {
      continue
    }

    let d2 = dist2(
      game.hero.x,
      game.hero.y,
      bullet.x,
      bullet.y,
    )
    if d2 <= rr2 {
      bullet.active = false
      emit_spark(
        game,
        bullet.x,
        bullet.y,
        randf(-90.0, 90.0),
        randf(-90.0, 90.0),
        randf(0.2, 0.45),
        randf(1.2, 3.4),
        2,
      )
    }
  }
}

///|
fn shoot_player_bullet(game : Game) -> Unit {
  let spread : Float = if game.boost_t > 0.0 { 16.0 } else { 8.0 }

  spawn_bullet(
    game,
    true,
    game.hero.x - 10.0,
    game.hero.y - game.hero.h * 0.44,
    randf(-spread, spread),
    -bullet_speed,
    bullet_life,
    8.0,
    0,
  )
  spawn_bullet(
    game,
    true,
    game.hero.x + 10.0,
    game.hero.y - game.hero.h * 0.44,
    randf(-spread, spread),
    -bullet_speed,
    bullet_life,
    8.0,
    0,
  )

  if game.stage >= 4 && chance(28) {
    spawn_bullet(
      game,
      true,
      game.hero.x,
      game.hero.y - game.hero.h * 0.54,
      randf(-6.0, 6.0),
      -bullet_speed * 1.08,
      bullet_life,
      6.0,
      1,
    )
  }

  game.hero.muzzle_t = 0.12
}

///|
fn apply_player_input(game : Game, dt : Float) -> Unit {
  if game.input_boost_press && game.boost_cd <= 0.0 && game.energy >= 14.0 {
    game.boost_t = boost_time
    game.boost_cd = boost_cd_time
    game.energy = maxf(0.0, game.energy - 12.0)
    game.hero.invuln = maxf(game.hero.invuln, 0.22)

    let mut dx = game.input_x
    let mut dy = game.input_y
    let n2 = dx * dx + dy * dy
    if n2 <= 0.001 {
      dx = 0.0
      dy = -1.0
    } else {
      let inv : Float = Float::from_int(1) / sqrtf(n2)
      dx = dx * inv
      dy = dy * inv
    }

    game.hero.vx = game.hero.vx + dx * boost_speed_bonus
    game.hero.vy = game.hero.vy + dy * boost_speed_bonus * 0.7

    spawn_ring(game, game.hero.x, game.hero.y, 18.0, 0.58, 0)
    burst(game, game.hero.x, game.hero.y, 16, 0)
  }

  if game.input_hack_press && game.hack_cd <= 0.0 && game.energy >= 18.0 {
    game.energy = maxf(0.0, game.energy - 18.0)
    apply_hack_pulse(game)
  }

  if game.input_fire_hold && game.fire_cd <= 0.0 {
    shoot_player_bullet(game)
    game.fire_cd = if game.boost_t > 0.0 {
      fire_cooldown_base * 0.62
    } else {
      fire_cooldown_base
    }
  }

  game.hero.vx = game.hero.vx + game.input_x * player_accel_x * dt
  game.hero.vy = game.hero.vy + game.input_y * player_accel_y * dt

  if game.boost_t > 0.0 {
    game.hero.vy = game.hero.vy - 150.0 * dt
    emit_image(
      game,
      game.hero.x,
      game.hero.y + 18.0,
      game.hero.w,
      game.hero.h,
      game.hero.heading,
      randf(0.14, 0.26),
      1,
    )
  }

  let drag_mul = clampf(1.0 - player_drag * dt, 0.0, 1.0)
  game.hero.vx = game.hero.vx * drag_mul
  game.hero.vy = game.hero.vy * drag_mul

  game.hero.vx = clampf(game.hero.vx, -player_max_speed_x, player_max_speed_x)
  game.hero.vy = clampf(game.hero.vy, -player_max_speed_y, player_max_speed_y)

  game.hero.x = game.hero.x + game.hero.vx * dt
  game.hero.y = game.hero.y + game.hero.vy * dt

  game.hero.y = clampf(
    game.hero.y,
    Float::from_int(ui_panel_h + 56),
    Float::from_int(screen_h) - 80.0,
  )
}

///|
fn constrain_player_to_road(game : Game) -> Unit {
  let d = game.distance + (Float::from_int(screen_h) - game.hero.y)
  let edges = road_edges(game.stage, d, game.time_s)
  let left = edges.0
  let right = edges.1

  let rr = player_hit_radius(game.hero)

  if game.hero.x - rr < left {
    game.hero.x = left + rr
    game.hero.vx = absf(game.hero.vx) * 0.2
    damage_player(game, 10.0)
  }

  if game.hero.x + rr > right {
    game.hero.x = right - rr
    game.hero.vx = -absf(game.hero.vx) * 0.2
    damage_player(game, 10.0)
  }
}

///|
fn entity_fire(game : Game, e : Entity) -> Unit {
  if e.kind == foe_bike {
    spawn_bullet(
      game,
      false,
      e.x,
      e.y + e.h * 0.4,
      randf(-120.0, 120.0),
      enemy_bullet_speed,
      2.2,
      9.0,
      0,
    )
  } else if e.kind == foe_drone {
    let dx = game.hero.x - e.x
    let dy = game.hero.y - e.y
    let n2 = maxf(dx * dx + dy * dy, 1.0)
    let inv = Float::from_int(1) / sqrtf(n2)
    spawn_bullet(
      game,
      false,
      e.x,
      e.y,
      dx * inv * enemy_bullet_speed,
      dy * inv * enemy_bullet_speed,
      2.5,
      11.0,
      1,
    )
  } else if e.kind == foe_truck {
    spawn_bullet(
      game,
      false,
      e.x - 18.0,
      e.y + e.h * 0.32,
      -60.0,
      enemy_bullet_speed * 0.86,
      2.6,
      12.0,
      2,
    )
    spawn_bullet(
      game,
      false,
      e.x + 18.0,
      e.y + e.h * 0.32,
      60.0,
      enemy_bullet_speed * 0.86,
      2.6,
      12.0,
      2,
    )
  }
}

///|
fn kill_entity(game : Game, i : Int, bonus : Int, burst_kind : Int) -> Unit {
  let x = game.entities[i].x
  let y = game.entities[i].y
  game.entities[i].active = false
  add_score(game, bonus)
  push_combo(game)
  game.kills = game.kills + 1
  burst(game, x, y, 16 + randi(0, 8), burst_kind)
  spawn_ring(game, x, y, 10.0, 0.56, burst_kind)
}

///|
fn collect_pickup(game : Game, kind : Int) -> Unit {
  if kind == item_credit {
    game.credits = game.credits + 1
    add_score(game, 60)
    push_combo(game)
  } else if kind == item_battery {
    game.energy = minf(player_energy_max, game.energy + energy_pickup)
    add_score(game, 40)
  } else {
    game.hack_cd = maxf(0.0, game.hack_cd - 1.1)
    game.energy = minf(player_energy_max, game.energy + 12.0)
    add_score(game, 78)
    push_combo(game)
  }
}

///|
fn update_entities(game : Game, dt : Float) -> Unit {
  let ram_hit = game.boost_t > 0.0

  for i in 0..<game.entities.length() {
    if not(game.entities[i].active) {
      continue
    }

    game.entities[i].x = game.entities[i].x + game.entities[i].vx * dt
    game.entities[i].y = game.entities[i].y +
      (game.scroll_speed + game.entities[i].vy) * dt
    game.entities[i].spin = game.entities[i].spin + dt * 1.9
    game.entities[i].shot_cd = game.entities[i].shot_cd - dt

    if game.entities[i].kind == foe_bike {
      game.entities[i].x = game.entities[i].x +
        sinf(game.entities[i].spin * 2.2) * 34.0 * dt
    } else if game.entities[i].kind == foe_drone {
      game.entities[i].y = game.entities[i].y +
        cosf(game.entities[i].spin * 2.8) * 26.0 * dt
    } else if game.entities[i].kind == foe_truck {
      game.entities[i].x = game.entities[i].x +
        sinf(game.entities[i].spin * 1.4) * 18.0 * dt
    } else if game.entities[i].kind == foe_laser {
      game.entities[i].w = 118.0 + sinf(game.entities[i].spin * 3.4) * 26.0
      game.entities[i].h = 18.0 + sinf(game.entities[i].spin * 4.2) * 4.0
    } else {
      game.entities[i].x = game.entities[i].x +
        sinf(game.entities[i].spin * 2.6) * 16.0 * dt
    }

    let out = game.entities[i].y > Float::from_int(screen_h) + 220.0 ||
      game.entities[i].x < -260.0 ||
      game.entities[i].x > Float::from_int(screen_w) + 260.0
    if out {
      game.entities[i].active = false
      continue
    }

    if entity_is_hostile(game.entities[i].kind) &&
      game.entities[i].shot_cd <= 0.0 {
      entity_fire(game, game.entities[i])
      game.entities[i].shot_cd = if game.entities[i].kind == foe_bike {
        randf(0.74, 1.44)
      } else if game.entities[i].kind == foe_drone {
        randf(0.48, 1.02)
      } else if game.entities[i].kind == foe_truck {
        randf(1.18, 2.1)
      } else {
        randf(1.0, 1.8)
      }
    }

    let d2 = dist2(
      game.hero.x,
      game.hero.y,
      game.entities[i].x,
      game.entities[i].y,
    )
    let rr = player_hit_radius(game.hero) + entity_hit_radius(game.entities[i])

    if d2 <= rr * rr {
      let kind = game.entities[i].kind
      if is_pickup(kind) {
        game.entities[i].active = false
        collect_pickup(game, kind)
        burst(game, game.hero.x, game.hero.y, 10, 2)
      } else if ram_hit {
        kill_entity(game, i, game.entities[i].reward, 0)
      } else {
        let dmg : Float = if kind == foe_truck {
          24.0
        } else if kind == foe_laser {
          16.0
        } else {
          14.0
        }
        damage_player(game, dmg)
        if kind != foe_laser {
          game.entities[i].active = false
        }
      }
    }
  }
}

///|
fn update_bullets(game : Game, dt : Float) -> Unit {
  for bullet in game.bullets {
    if not(bullet.active) {
      continue
    }

    bullet.x = bullet.x + bullet.vx * dt
    bullet.y = bullet.y +
      (bullet.vy + game.scroll_speed * 0.1) * dt
    bullet.life = bullet.life - dt

    let dead = bullet.life <= 0.0 ||
      bullet.y < -120.0 ||
      bullet.y > Float::from_int(screen_h) + 120.0 ||
      bullet.x < -120.0 ||
      bullet.x > Float::from_int(screen_w) + 120.0
    if dead {
      bullet.active = false
      continue
    }

    if bullet.from_player {
      let mut hit = false
      for j in 0..<game.entities.length() {
        if not(game.entities[j].active) || is_pickup(game.entities[j].kind) {
          continue
        }

        let d2 = dist2(
          bullet.x,
          bullet.y,
          game.entities[j].x,
          game.entities[j].y,
        )
        let rr = entity_hit_radius(game.entities[j]) + 8.0
        if d2 <= rr * rr {
          game.entities[j].hp = game.entities[j].hp - bullet.dmg
          bullet.active = false
          hit = true

          emit_spark(
            game,
            game.entities[j].x,
            game.entities[j].y,
            randf(-90.0, 90.0),
            randf(-90.0, 90.0),
            randf(0.18, 0.42),
            randf(1.0, 3.2),
            0,
          )

          if game.entities[j].hp <= 0.0 {
            kill_entity(game, j, game.entities[j].reward, 0)
          }
          break
        }
      }

      if hit {
        continue
      }
    } else {
      let d2 = dist2(
        bullet.x,
        bullet.y,
        game.hero.x,
        game.hero.y,
      )
      let rr = player_hit_radius(game.hero) + 8.0
      if d2 <= rr * rr {
        bullet.active = false
        damage_player(game, bullet.dmg)
        continue
      }
    }
  }
}

///|
fn update_effects(game : Game, dt : Float) -> Unit {
  for spark in game.sparks {
    if not(spark.active) {
      continue
    }

    spark.x = spark.x + spark.vx * dt
    spark.y = spark.y +
      (spark.vy + game.scroll_speed * 0.16) * dt
    spark.life = spark.life - dt

    if spark.life <= 0.0 {
      spark.active = false
    }
  }

  for ring in game.rings {
    if not(ring.active) {
      continue
    }

    ring.life = ring.life - dt
    ring.r = ring.r +
      (130.0 + Float::from_int(ring.kind) * 52.0) * dt
    if ring.life <= 0.0 {
      ring.active = false
    }
  }

  for image in game.images {
    if not(image.active) {
      continue
    }

    image.y = image.y + game.scroll_speed * 0.26 * dt
    image.life = image.life - dt
    if image.life <= 0.0 {
      image.active = false
    }
  }
}

///|
fn emit_ambient_traffic_glow(game : Game, dt : Float) -> Unit {
  let tries = clampi((dt * 230.0).to_int(), 1, 10)
  let mut i = 0
  while i < tries {
    if chance(32) {
      let y = randf(
        Float::from_int(ui_panel_h),
        Float::from_int(screen_h) + 12.0,
      )
      let depth = game.distance + (Float::from_int(screen_h) - y)
      let edges = road_edges(game.stage, depth, game.time_s)
      let side : Float = if chance(50) {
        Float::from_int(-1)
      } else {
        Float::from_int(1)
      }
      let x = if side < 0.0 {
        edges.0 + randf(8.0, 30.0)
      } else {
        edges.1 - randf(8.0, 30.0)
      }

      emit_spark(
        game,
        x,
        y,
        side * randf(4.0, 20.0),
        randf(-20.0, 34.0),
        randf(0.5, 1.4),
        randf(1.0, 2.8),
        if chance(40) {
          2
        } else {
          0
        },
      )
    }
    i = i + 1
  }
}

///|
fn update_timers(game : Game, dt : Float) -> Unit {
  game.hero.invuln = maxf(0.0, game.hero.invuln - dt)
  game.hero.hurt_t = maxf(0.0, game.hero.hurt_t - dt)
  game.hero.muzzle_t = maxf(0.0, game.hero.muzzle_t - dt)
  game.hero.engine_t = game.hero.engine_t + dt

  game.fire_cd = maxf(0.0, game.fire_cd - dt)
  game.boost_cd = maxf(0.0, game.boost_cd - dt)
  game.boost_t = maxf(0.0, game.boost_t - dt)
  game.hack_cd = maxf(0.0, game.hack_cd - dt)
  game.hack_t = maxf(0.0, game.hack_t - dt)

  game.flash_t = maxf(0.0, game.flash_t - dt)
  game.shake_t = maxf(0.0, game.shake_t - dt)

  if game.combo_t > 0.0 {
    game.combo_t = game.combo_t - dt
    if game.combo_t <= 0.0 {
      reset_combo(game)
    }
  }
}

///|
fn update_play(game : Game, dt : Float) -> Unit {
  game.scroll_speed = base_scroll_speed +
    Float::from_int(game.stage - 1) * stage_scroll_gain +
    minf(70.0, game.distance * 0.006)
  game.distance = game.distance + game.scroll_speed * dt

  apply_player_input(game, dt)
  constrain_player_to_road(game)

  spawn_step(game, dt)
  update_entities(game, dt)
  update_bullets(game, dt)
  update_effects(game, dt)

  game.energy = maxf(
    0.0,
    game.energy -
    energy_drain_base * dt -
    absf(game.hero.vx) / player_max_speed_x * 1.2 * dt,
  )
  if game.boost_t > 0.0 {
    game.energy = maxf(0.0, game.energy - energy_drain_boost * dt)
  }

  game.shield = maxf(0.0, game.shield - shield_damage_decay * dt * 0.03)

  emit_ambient_traffic_glow(game, dt)

  if game.energy <= 0.0 {
    damage_player(game, 100.0)
  }

  if game.state == state_play && game.distance >= game.stage_goal {
    game.state = state_stage_clear
    game.result_t = 0.0
    add_score(game, 320 + game.stage * 120)
    game.shield = minf(player_shield_max, game.shield + 14.0)
    game.energy = minf(player_energy_max, game.energy + 20.0)
    spawn_ring(game, game.hero.x, game.hero.y, 18.0, 0.9, 2)
    burst(game, game.hero.x, game.hero.y, 28, 2)
  }
}

///|
fn update_title(game : Game, dt : Float) -> Unit {
  game.scroll_speed = 96.0
  game.distance = game.distance + game.scroll_speed * dt * 0.7

  emit_ambient_traffic_glow(game, dt)
  update_effects(game, dt)

  if game.input_restart_press {
    start_run(game)
  }
}

///|
fn update_stage_clear(game : Game, dt : Float) -> Unit {
  game.result_t = game.result_t + dt
  game.scroll_speed = maxf(90.0, game.scroll_speed - 140.0 * dt)

  update_effects(game, dt)
  emit_ambient_traffic_glow(game, dt)

  if chance(24) {
    emit_spark(
      game,
      game.hero.x + randf(-30.0, 30.0),
      game.hero.y + randf(-30.0, 30.0),
      randf(-44.0, 44.0),
      randf(-80.0, -16.0),
      randf(0.26, 0.62),
      randf(2.0, 4.2),
      2,
    )
  }

  if game.input_restart_press || game.result_t >= stage_clear_delay {
    start_stage(game, game.stage + 1)
  }
}

///|
fn update_game_over(game : Game, dt : Float) -> Unit {
  game.result_t = game.result_t + dt
  game.scroll_speed = maxf(52.0, game.scroll_speed - 120.0 * dt)

  update_effects(game, dt)
  emit_ambient_traffic_glow(game, dt)

  if game.input_restart_press {
    init_title_scene(game)
  }
}

///|
fn update_game(game : Game, dt : Float) -> Unit {
  game.time_s = game.time_s + dt
  game.hint_t = game.hint_t + dt

  update_timers(game, dt)

  if game.state == state_title {
    update_title(game, dt)
  } else if game.state == state_play {
    update_play(game, dt)
  } else if game.state == state_stage_clear {
    update_stage_clear(game, dt)
  } else {
    update_game_over(game, dt)
  }

  if game.score > game.best_score {
    game.best_score = game.score
  }
}
