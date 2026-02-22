///|
struct Breach {
  room : Int
  mut severity : Float
  mut raider_cd : Float
  mut ember_cd : Float
}

///|
struct Raider {
  active : Bool
  mut room : Int
  mut x : Float
  mut y : Float
  mut hp : Float
  max_hp : Float
  mut panic_t : Float
  mut attack_cd : Float
}

///|
struct Flame {
  active : Bool
  room : Int
  x : Float
  y : Float
  mut intensity : Float
  mut spread_cd : Float
}

///|
struct Keeper {
  mut room : Int
  mut x : Float
  mut y : Float
  mut facing_x : Float
  mut facing_y : Float
  mut stamina : Float
  mut extinguisher_mode : Bool
  mut action_cd : Float
  mut shield_cd : Float
  mut shield_t : Float
  mut ink_shields : Float
}

///|
struct Game {
  breaches : Array[Breach]
  raiders : Array[Raider]
  flames : Array[Flame]
  keeper : Keeper
  mut state : Int
  mut wave : Int
  mut wave_t : Float
  mut wave_goal_t : Float
  mut breach_event_cd : Float
  mut scroll_integrity : Float
  mut seal_charges : Int
  mut score : Int
  mut best_score : Int
  mut raiders_defeated : Int
  mut flames_cleared : Int
  mut seals_done : Int
  mut time_s : Float
  mut message : String
  mut message_t : Float
  mut input_x : Float
  mut input_y : Float
  mut input_action_press : Bool
  mut input_cancel_press : Bool
  mut input_shield_press : Bool
  mut input_pause_press : Bool
  mut input_restart_press : Bool
}

///|
fn Breach::new(room : Int) -> Breach {
  { room, severity: 0.0, raider_cd: randf(0.8, 1.6), ember_cd: randf(0.7, 1.4) }
}

///|
fn Raider::new() -> Raider {
  {
    active: false,
    room: 0,
    x: 0.0,
    y: 0.0,
    hp: 0.0,
    max_hp: 1.0,
    panic_t: 0.0,
    attack_cd: 0.0,
  }
}

///|
fn Flame::new() -> Flame {
  { active: false, room: 0, x: 0.0, y: 0.0, intensity: 0.0, spread_cd: 0.0 }
}

///|
fn Keeper::new() -> Keeper {
  {
    room: vault_room,
    x: chamber_center_x(),
    y: chamber_center_y(),
    facing_x: 1.0,
    facing_y: 0.0,
    stamina: keeper_stamina_max,
    extinguisher_mode: false,
    action_cd: 0.0,
    shield_cd: 0.0,
    shield_t: 0.0,
    ink_shields: ink_shield_stock_start,
  }
}

///|
fn Game::new() -> Game {
  {
    breaches: Array::makei(chamber_count, fn(room) { Breach::new(room) }),
    raiders: Array::makei(max_raiders, fn(_i) { Raider::new() }),
    flames: Array::makei(max_flames, fn(_i) { Flame::new() }),
    keeper: Keeper::new(),
    state: state_title,
    wave: 1,
    wave_t: 0.0,
    wave_goal_t: wave_duration(1),
    breach_event_cd: 1.4,
    scroll_integrity: scroll_integrity_max,
    seal_charges: seal_charges_start,
    score: 0,
    best_score: 0,
    raiders_defeated: 0,
    flames_cleared: 0,
    seals_done: 0,
    time_s: 0.0,
    message: "Press J to begin guarding the dragon scroll vault.",
    message_t: 99.0,
    input_x: 0.0,
    input_y: 0.0,
    input_action_press: false,
    input_cancel_press: false,
    input_shield_press: false,
    input_pause_press: false,
    input_restart_press: false,
  }
}
