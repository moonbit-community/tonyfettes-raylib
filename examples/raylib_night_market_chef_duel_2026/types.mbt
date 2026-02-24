///|
struct Order {
  mut active : Bool
  mut dish : Int
  mut patience : Float
  mut patience_max : Float
  mut reward : Int
  mut ticket_no : Int
}

///|
struct InputState {
  mut move_x : Int
  mut move_y : Int
  mut press_j : Bool
  mut press_k : Bool
  mut press_space : Bool
  mut press_pause : Bool
  mut press_restart : Bool
  mut press_start : Bool
}

///|
struct CookingState {
  mut active : Bool
  mut dish : Int
  mut lane : Int
  mut stage : Int
  mut prep_progress : Float
  mut cook_progress : Float
}

///|
struct Game {
  orders : Array[Order]
  input : InputState
  cooking : CookingState
  mut state : Int
  mut cursor : Int
  mut selected_order : Int
  mut ready_dish : Int
  mut ready_quality : Float
  mut score : Int
  mut best_score : Int
  mut combo : Int
  mut combo_timer : Float
  mut served_orders : Int
  mut failed_orders : Int
  mut next_order_id : Int
  mut spawn_t : Float
  mut elapsed_t : Float
  mut boost_t : Float
  mut boost_cd : Float
  mut flash_t : Float
  mut shake_t : Float
}

///|
fn Order::new() -> Order {
  {
    active: false,
    dish: dish_skewers,
    patience: 0.0,
    patience_max: 0.0,
    reward: 0,
    ticket_no: 0,
  }
}

///|
fn InputState::new() -> InputState {
  {
    move_x: 0,
    move_y: 0,
    press_j: false,
    press_k: false,
    press_space: false,
    press_pause: false,
    press_restart: false,
    press_start: false,
  }
}

///|
fn CookingState::new() -> CookingState {
  {
    active: false,
    dish: dish_none,
    lane: lane_grill,
    stage: cook_stage_prep,
    prep_progress: 0.0,
    cook_progress: 0.0,
  }
}

///|
fn Game::new() -> Game {
  {
    orders: Array::makei(max_orders, fn(_i) { Order::new() }),
    input: InputState::new(),
    cooking: CookingState::new(),
    state: state_title,
    cursor: node_prep,
    selected_order: -1,
    ready_dish: dish_none,
    ready_quality: 0.0,
    score: 0,
    best_score: 0,
    combo: 0,
    combo_timer: 0.0,
    served_orders: 0,
    failed_orders: 0,
    next_order_id: 1,
    spawn_t: 0.6,
    elapsed_t: 0.0,
    boost_t: 0.0,
    boost_cd: 0.0,
    flash_t: 0.0,
    shake_t: 0.0,
  }
}
