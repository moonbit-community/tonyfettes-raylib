///|
struct Node {
  active : Bool
  gx : Int
  gy : Int
  mut level : Int
  mut facing : Int
  mut cooldown : Float
  mut pulse : Float
}

///|
struct Enemy {
  mut active : Bool
  kind : Int
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut hp : Float
  max_hp : Float
  speed : Float
  radius : Float
  reward : Int
  gate_damage : Float
  mut phase : Float
}

///|
struct Bolt {
  mut active : Bool
  mut x : Float
  mut y : Float
  vx : Float
  vy : Float
  mut life : Float
  dmg : Float
}

///|
struct PulseFx {
  mut active : Bool
  x : Float
  y : Float
  mut radius : Float
  mut life : Float
  max_life : Float
  kind : Int
}

///|
struct Game {
  nodes : Array[Node]
  enemies : Array[Enemy]
  bolts : Array[Bolt]
  pulses : Array[PulseFx]
  mut state : Int
  mut score : Int
  mut best_score : Int
  mut kills : Int
  mut wave : Int
  mut pending_spawns : Int
  mut spawn_cd : Float
  mut wave_delay : Float
  mut gate_hp : Float
  mut energy : Float
  mut barrier_charge : Float
  mut barrier_flash : Float
  mut combo : Int
  mut combo_timer : Float
  mut time_s : Float
  mut shake_t : Float
  mut cursor_x : Int
  mut cursor_y : Int
  mut cursor_dir : Int
  mut status_text : String
  mut status_t : Float
  mut input_move_x : Int
  mut input_move_y : Int
  mut input_place_press : Bool
  mut input_cancel_press : Bool
  mut input_barrier_press : Bool
  mut input_pause_press : Bool
  mut input_restart_press : Bool
}

///|
fn Node::new() -> Node {
  {
    active: false,
    gx: 0,
    gy: 0,
    level: 1,
    facing: dir_up,
    cooldown: 0.0,
    pulse: 0.0,
  }
}

///|
fn Enemy::new() -> Enemy {
  {
    active: false,
    kind: enemy_kind_skitter,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    hp: 0.0,
    max_hp: 0.0,
    speed: 0.0,
    radius: 12.0,
    reward: 0,
    gate_damage: 0.0,
    phase: 0.0,
  }
}

///|
fn Bolt::new() -> Bolt {
  { active: false, x: 0.0, y: 0.0, vx: 0.0, vy: 0.0, life: 0.0, dmg: 0.0 }
}

///|
fn PulseFx::new() -> PulseFx {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    radius: 0.0,
    life: 0.0,
    max_life: 0.0,
    kind: 0,
  }
}

///|
fn Game::new() -> Game {
  let nodes = Array::makei(max_nodes, fn(_i) { Node::new() })
  let enemies = Array::makei(max_enemies, fn(_i) { Enemy::new() })
  let bolts = Array::makei(max_bolts, fn(_i) { Bolt::new() })
  let pulses = Array::makei(max_pulses, fn(_i) { PulseFx::new() })

  {
    nodes,
    enemies,
    bolts,
    pulses,
    state: state_title,
    score: 0,
    best_score: 0,
    kills: 0,
    wave: 0,
    pending_spawns: 0,
    spawn_cd: 0.0,
    wave_delay: 0.0,
    gate_hp: gate_hp_max,
    energy: energy_start,
    barrier_charge: 0.0,
    barrier_flash: 0.0,
    combo: 0,
    combo_timer: 0.0,
    time_s: 0.0,
    shake_t: 0.0,
    cursor_x: gate_gx + 1,
    cursor_y: gate_gy,
    cursor_dir: dir_left,
    status_text: "Press J to begin defense",
    status_t: 0.0,
    input_move_x: 0,
    input_move_y: 0,
    input_place_press: false,
    input_cancel_press: false,
    input_barrier_press: false,
    input_pause_press: false,
    input_restart_press: false,
  }
}
