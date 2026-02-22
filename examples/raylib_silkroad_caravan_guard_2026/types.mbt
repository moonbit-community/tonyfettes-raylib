///|
struct Wagon {
  mut x : Float
  mut y : Float
  mut hp : Float
  max_hp : Float
  mut repair_cd : Float
}

///|
struct Raider {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut speed : Float
  mut hp : Float
  mut target_wagon : Int
  mut lane : Int
  mut attack_cd : Float
  mut flash_t : Float
  mut radius : Float
}

///|
struct Bullet {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut life : Float
  mut dmg : Float
}

///|
struct Dust {
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
struct Player {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut facing_x : Float
  mut facing_y : Float
  mut roll_t : Float
  mut roll_cd : Float
  mut roll_dx : Float
  mut roll_dy : Float
  mut shoot_cd : Float
  mut invuln_t : Float
  mut repair_t : Float
}

///|
struct Game {
  wagons : Array[Wagon]
  raiders : Array[Raider]
  bullets : Array[Bullet]
  dusts : Array[Dust]
  hero : Player
  mut state : Int
  mut score : Int
  mut best_score : Int
  mut kills : Int
  mut checkpoint : Int
  mut distance : Float
  mut checkpoint_start : Float
  mut next_checkpoint : Float
  mut morale : Float
  mut ammo : Int
  mut ammo_regen_t : Float
  mut repair_kits : Int
  mut spawn_t : Float
  mut time_s : Float
  mut flash_t : Float
  mut shake_t : Float
  mut message : String
  mut message_t : Float
  mut input_x : Float
  mut input_y : Float
  mut input_shoot_hold : Bool
  mut input_shoot_press : Bool
  mut input_repair_press : Bool
  mut input_roll_press : Bool
  mut input_pause_press : Bool
  mut input_restart_press : Bool
  mut input_confirm_press : Bool
}

///|
fn Wagon::new(index : Int) -> Wagon {
  {
    x: wagon_slot_x(index),
    y: wagon_slot_y(index),
    hp: wagon_hp_max,
    max_hp: wagon_hp_max,
    repair_cd: 0.0,
  }
}

///|
fn Raider::new() -> Raider {
  {
    active: false,
    kind: raider_skirmisher,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    speed: 0.0,
    hp: 0.0,
    target_wagon: 0,
    lane: 0,
    attack_cd: 0.0,
    flash_t: 0.0,
    radius: 16.0,
  }
}

///|
fn Bullet::new() -> Bullet {
  { active: false, x: 0.0, y: 0.0, vx: 0.0, vy: 0.0, life: 0.0, dmg: 0.0 }
}

///|
fn Dust::new() -> Dust {
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
fn Player::new() -> Player {
  {
    x: caravan_center_x - perimeter_outer_rx * 0.9,
    y: caravan_center_y,
    vx: 0.0,
    vy: 0.0,
    facing_x: 1.0,
    facing_y: 0.0,
    roll_t: 0.0,
    roll_cd: 0.0,
    roll_dx: 1.0,
    roll_dy: 0.0,
    shoot_cd: 0.0,
    invuln_t: 0.0,
    repair_t: 0.0,
  }
}

///|
fn Game::new() -> Game {
  let wagons = Array::makei(wagon_count, fn(i) { Wagon::new(i) })
  let raiders = Array::makei(max_raiders, fn(_i) { Raider::new() })
  let bullets = Array::makei(max_bullets, fn(_i) { Bullet::new() })
  let dusts = Array::makei(max_dust, fn(_i) { Dust::new() })

  {
    wagons,
    raiders,
    bullets,
    dusts,
    hero: Player::new(),
    state: state_title,
    score: 0,
    best_score: 0,
    kills: 0,
    checkpoint: 0,
    distance: 0.0,
    checkpoint_start: 0.0,
    next_checkpoint: checkpoint_span(0),
    morale: 74.0,
    ammo: 26,
    ammo_regen_t: ammo_regen_base,
    repair_kits: 3,
    spawn_t: 0.7,
    time_s: 0.0,
    flash_t: 0.0,
    shake_t: 0.0,
    message: "Press J to begin escort",
    message_t: 2.0,
    input_x: 0.0,
    input_y: 0.0,
    input_shoot_hold: false,
    input_shoot_press: false,
    input_repair_press: false,
    input_roll_press: false,
    input_pause_press: false,
    input_restart_press: false,
    input_confirm_press: false,
  }
}
