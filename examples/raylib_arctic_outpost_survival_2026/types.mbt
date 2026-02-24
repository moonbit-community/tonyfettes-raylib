///|
struct Enemy {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut r : Float
  mut hp : Float
  mut kind : Int
  mut phase : Float
}

///|
struct Pickup {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut kind : Int
  mut phase : Float
}

///|
struct Bullet {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut life : Float
  mut power : Float
  mut kind : Int
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
struct Game {
  enemies : Array[Enemy]
  pickups : Array[Pickup]
  bullets : Array[Bullet]
  particles : Array[Particle]
  mut state : Int
  mut player_x : Float
  mut player_y : Float
  mut player_vx : Float
  mut player_vy : Float
  mut aim_x : Float
  mut aim_y : Float
  mut move_x : Float
  mut move_y : Float
  mut lives : Int
  mut suit_hp : Float
  mut core_heat : Float
  mut fuel : Float
  mut ammo : Int
  mut overdrive_t : Float
  mut fire_cd : Float
  mut repair_cd : Float
  mut score : Int
  mut best_score : Int
  mut wave : Int
  mut combo : Int
  mut combo_t : Float
  mut spawn_t : Float
  mut pickup_t : Float
  mut storm_t : Float
  mut game_t : Float
  mut ui_t : Float
  mut hint_left : Int
  mut hint_t : Float
  mut hint_x : Float
  mut hint_y : Float
  mut msg : String
  mut msg_t : Float
  mut shake_t : Float
  mut touch_cd : Float
  mut win : Bool
}

///|
fn Enemy::new() -> Enemy {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    r: 0.0,
    hp: 0.0,
    kind: enemy_wolf,
    phase: 0.0,
  }
}

///|
fn Pickup::new() -> Pickup {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    kind: pickup_fuel,
    phase: 0.0,
  }
}

///|
fn Bullet::new() -> Bullet {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    life: 0.0,
    power: 0.0,
    kind: bullet_normal,
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
fn Game::new() -> Game {
  {
    enemies: Array::makei(max_enemies, fn(_i) { Enemy::new() }),
    pickups: Array::makei(max_pickups, fn(_i) { Pickup::new() }),
    bullets: Array::makei(max_bullets, fn(_i) { Bullet::new() }),
    particles: Array::makei(max_particles, fn(_i) { Particle::new() }),
    state: state_title,
    player_x: Float::from_int(world_x0 + world_w / 2),
    player_y: Float::from_int(world_y0 + world_h - 180),
    player_vx: 0.0,
    player_vy: 0.0,
    aim_x: core_x(),
    aim_y: core_y(),
    move_x: 0.0,
    move_y: 0.0,
    lives: 3,
    suit_hp: 100.0,
    core_heat: 100.0,
    fuel: 100.0,
    ammo: 160,
    overdrive_t: 0.0,
    fire_cd: 0.0,
    repair_cd: 0.0,
    score: 0,
    best_score: 0,
    wave: 1,
    combo: 0,
    combo_t: 0.0,
    spawn_t: 0.0,
    pickup_t: 0.0,
    storm_t: 0.0,
    game_t: 0.0,
    ui_t: 0.0,
    hint_left: 3,
    hint_t: 0.0,
    hint_x: core_x(),
    hint_y: core_y(),
    msg: "",
    msg_t: 0.0,
    shake_t: 0.0,
    touch_cd: 0.0,
    win: false,
  }
}
