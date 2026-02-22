///|
struct InputState {
  mut move_x : Int
  mut move_y : Int
  mut press_interact : Bool
  mut press_serve_cancel : Bool
  mut press_boost : Bool
  mut press_pause : Bool
  mut press_restart : Bool
  mut press_start : Bool
}

///|
fn InputState::new() -> InputState {
  {
    move_x: 0,
    move_y: 0,
    press_interact: false,
    press_serve_cancel: false,
    press_boost: false,
    press_pause: false,
    press_restart: false,
    press_start: false,
  }
}

///|
struct Order {
  mut active : Bool
  mut id : Int
  mut broth : Int
  mut protein : Int
  mut veg : Int
  mut spice : Int
  mut patience : Float
  mut max_patience : Float
  mut pulse : Float
}

///|
fn Order::new(id : Int) -> Order {
  {
    active: false,
    id,
    broth: 0,
    protein: 0,
    veg: 0,
    spice: 0,
    patience: 0.0,
    max_patience: 0.0,
    pulse: 0.0,
  }
}

///|
struct Item {
  mut kind : Int
  mut flavor : Int
  mut prepped : Bool
}

///|
fn Item::empty() -> Item {
  { kind: ingredient_none, flavor: 0, prepped: false }
}

///|
struct PrepState {
  mut active : Bool
  mut kind : Int
  mut flavor : Int
  mut progress : Float
  mut target : Float
  mut output_ready : Bool
  mut out_kind : Int
  mut out_flavor : Int
}

///|
fn PrepState::new() -> PrepState {
  {
    active: false,
    kind: ingredient_none,
    flavor: 0,
    progress: 0.0,
    target: prep_target_base,
    output_ready: false,
    out_kind: ingredient_none,
    out_flavor: 0,
  }
}

///|
struct PotState {
  mut broth : Int
  mut protein : Int
  mut veg : Int
  mut spice : Int
  mut cooking : Bool
  mut progress : Float
  mut target : Float
  mut ready : Bool
}

///|
fn PotState::new() -> PotState {
  {
    broth: -1,
    protein: -1,
    veg: -1,
    spice: 0,
    cooking: false,
    progress: 0.0,
    target: cook_target_base,
    ready: false,
  }
}

///|
struct Game {
  input : InputState
  orders : Array[Order]
  prep : PrepState
  pot : PotState
  hand : Item
  mut state : Int
  mut cursor_x : Int
  mut cursor_y : Int
  mut score : Int
  mut best_score : Int
  mut combo : Int
  mut combo_t : Float
  mut reputation : Float
  mut boost_meter : Float
  mut boost_t : Float
  mut rush_cd : Float
  mut spawn_cd : Float
  mut order_serial : Int
  mut elapsed : Float
  mut served : Int
  mut failed : Int
  mut next_protein_pick : Int
  mut next_veg_pick : Int
  mut msg : String
  mut msg_t : Float
  mut flash_t : Float
}

///|
fn Game::new() -> Game {
  {
    input: InputState::new(),
    orders: Array::makei(max_orders, fn(i) { Order::new(i + 1) }),
    prep: PrepState::new(),
    pot: PotState::new(),
    hand: Item::empty(),
    state: state_title,
    cursor_x: 1,
    cursor_y: 1,
    score: 0,
    best_score: 0,
    combo: 0,
    combo_t: 0.0,
    reputation: reputation_start,
    boost_meter: boost_meter_max,
    boost_t: 0.0,
    rush_cd: 0.0,
    spawn_cd: 1.0,
    order_serial: 1,
    elapsed: 0.0,
    served: 0,
    failed: 0,
    next_protein_pick: 0,
    next_veg_pick: 0,
    msg: "",
    msg_t: 0.0,
    flash_t: 0.0,
  }
}
