///|
struct Enemy {
  mut active : Bool
  mut kind : Int
  mut ring : Int
  mut angle : Float
  mut ang_v : Float
  mut hp : Float
  mut fire_cd : Float
  mut phase_mask : Int
  mut size : Float
  mut spin : Float
}

///|
struct Bullet {
  mut active : Bool
  mut ring_f : Float
  mut angle : Float
  mut vr : Float
  mut va : Float
  mut life : Float
  mut dmg : Float
  mut kind : Int
}

///|
struct EnemyBullet {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut life : Float
  mut dmg : Float
  mut kind : Int
}

///|
struct Flare {
  mut active : Bool
  mut ring : Int
  mut angle : Float
  mut span : Float
  mut spin_v : Float
  mut t : Float
  mut danger : Float
}

///|
struct Particle {
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
struct Shock {
  mut active : Bool
  mut ring : Int
  mut a0 : Float
  mut a1 : Float
  mut life : Float
  mut beta : Bool
}

///|
struct Player {
  mut ring : Int
  mut ring_f : Float
  mut angle : Float
  mut ang_v : Float
  mut switch_cd : Float
  mut shot_cd : Float
  mut beam_cd : Float
  mut invuln : Float
  mut hurt_t : Float
  mut anim_t : Float
}

///|
struct Game {
  enemies : Array[Enemy]
  bullets : Array[Bullet]
  enemy_bullets : Array[EnemyBullet]
  flares : Array[Flare]
  particles : Array[Particle]
  shocks : Array[Shock]
  player : Player
  mut state : Int
  mut stage : Int
  mut stage_time_left : Float
  mut stage_goal : Int
  mut stage_kills : Int
  mut stage_bonus : Int
  mut score : Int
  mut best_score : Int
  mut combo : Int
  mut combo_t : Float
  mut hp : Float
  mut phase : Float
  mut phase_beta : Bool
  mut flash_t : Float
  mut shake_t : Float
  mut time_s : Float
  mut hint_t : Float
  mut result_t : Float
  mut wave_timer : Float
  mut flare_timer : Float
  mut input_turn : Float
  mut input_ring_move : Int
  mut input_fire_hold : Bool
  mut input_beam_press : Bool
  mut input_restart_press : Bool
  mut input_pause_press : Bool
  mut touch_mode : Bool
  mut touch_count : Int
  mut pointer_x : Float
  mut pointer_y : Float
  mut touch_in_prev : Bool
  mut touch_out_prev : Bool
  mut touch_beam_prev : Bool
  mut touch_restart_prev : Bool
}

///|
fn Enemy::new() -> Enemy {
  {
    active: false,
    kind: 0,
    ring: 0,
    angle: 0.0,
    ang_v: 0.0,
    hp: 0.0,
    fire_cd: 0.0,
    phase_mask: 0,
    size: 0.0,
    spin: 0.0,
  }
}

///|
fn Bullet::new() -> Bullet {
  {
    active: false,
    ring_f: 0.0,
    angle: 0.0,
    vr: 0.0,
    va: 0.0,
    life: 0.0,
    dmg: 0.0,
    kind: 0,
  }
}

///|
fn EnemyBullet::new() -> EnemyBullet {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    life: 0.0,
    dmg: 0.0,
    kind: 0,
  }
}

///|
fn Flare::new() -> Flare {
  {
    active: false,
    ring: 0,
    angle: 0.0,
    span: 0.0,
    spin_v: 0.0,
    t: 0.0,
    danger: 0.0,
  }
}

///|
fn Particle::new() -> Particle {
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
}

///|
fn Shock::new() -> Shock {
  { active: false, ring: 0, a0: 0.0, a1: 0.0, life: 0.0, beta: false }
}

///|
fn Player::new() -> Player {
  {
    ring: 1,
    ring_f: 1.0,
    angle: -1.2,
    ang_v: 0.0,
    switch_cd: 0.0,
    shot_cd: 0.0,
    beam_cd: 0.0,
    invuln: 0.0,
    hurt_t: 0.0,
    anim_t: 0.0,
  }
}

///|
fn Game::new() -> Game {
  {
    enemies: Array::makei(max_enemies, fn(_i) { Enemy::new() }),
    bullets: Array::makei(max_bullets, fn(_i) { Bullet::new() }),
    enemy_bullets: Array::makei(max_enemy_bullets, fn(_i) { EnemyBullet::new() }),
    flares: Array::makei(max_flares, fn(_i) { Flare::new() }),
    particles: Array::makei(max_particles, fn(_i) { Particle::new() }),
    shocks: Array::makei(max_shocks, fn(_i) { Shock::new() }),
    player: Player::new(),
    state: state_title,
    stage: 1,
    stage_time_left: stage_time,
    stage_goal: 24,
    stage_kills: 0,
    stage_bonus: 0,
    score: 0,
    best_score: 0,
    combo: 0,
    combo_t: 0.0,
    hp: 100.0,
    phase: player_phase_max,
    phase_beta: false,
    flash_t: 0.0,
    shake_t: 0.0,
    time_s: 0.0,
    hint_t: 0.0,
    result_t: 0.0,
    wave_timer: 0.4,
    flare_timer: 3.2,
    input_turn: 0.0,
    input_ring_move: 0,
    input_fire_hold: false,
    input_beam_press: false,
    input_restart_press: false,
    input_pause_press: false,
    touch_mode: false,
    touch_count: 0,
    pointer_x: 0.0,
    pointer_y: 0.0,
    touch_in_prev: false,
    touch_out_prev: false,
    touch_beam_prev: false,
    touch_restart_prev: false,
  }
}
