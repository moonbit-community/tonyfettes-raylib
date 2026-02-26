///|
struct Bullet {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut ttl : Float
}

///|
fn Bullet::new() -> Bullet {
  { active: false, x: 0.0, y: 0.0, vx: 0.0, vy: 0.0, ttl: 0.0 }
}

///|
struct Rock {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut radius : Float
  mut size : Int
}

///|
fn Rock::new() -> Rock {
  { active: false, x: 0.0, y: 0.0, vx: 0.0, vy: 0.0, radius: 0.0, size: 0 }
}

///|
struct Game {
  mut ship_x : Float
  mut ship_y : Float
  mut ship_vx : Float
  mut ship_vy : Float
  mut ship_angle : Float
  mut fire_cooldown : Float
  mut ship_invuln : Float
  bullets : Array[Bullet]
  rocks : Array[Rock]
  mut score : Int
  mut lives : Int
  mut wave : Int
  mut game_over : Bool
}

///|
fn Game::new() -> Game {
  {
    ship_x: Float::from_int(screen_width) * 0.5,
    ship_y: Float::from_int(screen_height) * 0.5,
    ship_vx: 0.0,
    ship_vy: 0.0,
    ship_angle: -pi * 0.5,
    fire_cooldown: 0.0,
    ship_invuln: 0.0,
    bullets: Array::make(bullet_max, Bullet::new()),
    rocks: Array::make(rock_max, Rock::new()),
    score: 0,
    lives: 3,
    wave: 1,
    game_over: false,
  }
}
