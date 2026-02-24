///|
struct Entity {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut w : Float
  mut h : Float
  mut hp : Float
  mut shot_cd : Float
  mut spin : Float
  mut cloak : Bool
  mut reward : Int
}

///|
struct Bullet {
  mut active : Bool
  mut from_player : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut life : Float
  mut dmg : Float
  mut kind : Int
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
struct GlowRing {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut r : Float
  mut life : Float
  mut kind : Int
}

///|
struct Afterimage {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut w : Float
  mut h : Float
  mut rot : Float
  mut life : Float
  mut kind : Int
}

///|
struct Player {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut w : Float
  mut h : Float
  mut heading : Float
  mut invuln : Float
  mut hurt_t : Float
  mut muzzle_t : Float
  mut engine_t : Float
}

///|
struct Game {
  entities : Array[Entity]
  bullets : Array[Bullet]
  sparks : Array[Spark]
  rings : Array[GlowRing]
  images : Array[Afterimage]
  hero : Player
  mut state : Int
  mut stage : Int
  mut distance : Float
  mut stage_goal : Float
  mut score : Int
  mut best_score : Int
  mut credits : Int
  mut kills : Int
  mut combo : Int
  mut combo_t : Float
  mut shield : Float
  mut energy : Float
  mut fire_cd : Float
  mut boost_cd : Float
  mut boost_t : Float
  mut hack_cd : Float
  mut hack_t : Float
  mut time_s : Float
  mut flash_t : Float
  mut shake_t : Float
  mut result_t : Float
  mut hint_t : Float
  mut scroll_speed : Float
  mut next_spawn_y : Float
  mut input_x : Float
  mut input_y : Float
  mut input_fire_hold : Bool
  mut input_boost_press : Bool
  mut input_hack_press : Bool
  mut input_restart_press : Bool
  mut touch_mode : Bool
  mut touch_boost_prev : Bool
  mut touch_hack_prev : Bool
  mut touch_restart_prev : Bool
}

///|
fn Entity::new() -> Entity {
  {
    active: false,
    kind: foe_bike,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    w: 0.0,
    h: 0.0,
    hp: 0.0,
    shot_cd: 0.0,
    spin: 0.0,
    cloak: false,
    reward: 0,
  }
}

///|
fn Bullet::new() -> Bullet {
  {
    active: false,
    from_player: true,
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
fn Spark::new() -> Spark {
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
fn GlowRing::new() -> GlowRing {
  { active: false, x: 0.0, y: 0.0, r: 0.0, life: 0.0, kind: 0 }
}

///|
fn Afterimage::new() -> Afterimage {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    w: 0.0,
    h: 0.0,
    rot: 0.0,
    life: 0.0,
    kind: 0,
  }
}

///|
fn Player::new() -> Player {
  {
    x: Float::from_int(screen_w / 2),
    y: Float::from_int(screen_h) * 0.76,
    vx: 0.0,
    vy: 0.0,
    w: player_w,
    h: player_h,
    heading: 0.0,
    invuln: 0.0,
    hurt_t: 0.0,
    muzzle_t: 0.0,
    engine_t: 0.0,
  }
}

///|
fn Game::new() -> Game {
  {
    entities: Array::makei(max_entities, fn(_i) { Entity::new() }),
    bullets: Array::makei(max_bullets, fn(_i) { Bullet::new() }),
    sparks: Array::makei(max_sparks, fn(_i) { Spark::new() }),
    rings: Array::makei(max_glow_rings, fn(_i) { GlowRing::new() }),
    images: Array::makei(max_afterimages, fn(_i) { Afterimage::new() }),
    hero: Player::new(),
    state: state_title,
    stage: 1,
    distance: 0.0,
    stage_goal: stage_distance_base,
    score: 0,
    best_score: 0,
    credits: 0,
    kills: 0,
    combo: 0,
    combo_t: 0.0,
    shield: player_shield_max,
    energy: player_energy_max,
    fire_cd: 0.0,
    boost_cd: 0.0,
    boost_t: 0.0,
    hack_cd: 0.0,
    hack_t: 0.0,
    time_s: 0.0,
    flash_t: 0.0,
    shake_t: 0.0,
    result_t: 0.0,
    hint_t: 0.0,
    scroll_speed: base_scroll_speed,
    next_spawn_y: spawn_start_y,
    input_x: 0.0,
    input_y: 0.0,
    input_fire_hold: false,
    input_boost_press: false,
    input_hack_press: false,
    input_restart_press: false,
    touch_mode: false,
    touch_boost_prev: false,
    touch_hack_prev: false,
    touch_restart_prev: false,
  }
}
