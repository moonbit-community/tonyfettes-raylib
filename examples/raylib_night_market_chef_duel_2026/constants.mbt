///|
let screen_w : Int = 1280

///|
let screen_h : Int = 720

///|
let target_fps : Int = 120

///|
let hud_h : Int = 112

///|
let state_title : Int = 0

///|
let state_play : Int = 1

///|
let state_paused : Int = 2

///|
let state_game_over : Int = 3

///|
let dish_none : Int = -1

///|
let dish_skewers : Int = 0

///|
let dish_noodles : Int = 1

///|
let dish_squid : Int = 2

///|
let dish_fried_rice : Int = 3

///|
let lane_grill : Int = 0

///|
let lane_wok : Int = 1

///|
let cook_stage_prep : Int = 0

///|
let cook_stage_heat : Int = 1

///|
let max_orders : Int = 6

///|
let fail_limit : Int = 6

///|
let combo_window : Float = 5.0

///|
let spawn_interval_start : Float = 3.4

///|
let spawn_interval_min : Float = 1.15

///|
let patience_base : Float = 19.0

///|
let patience_floor : Float = 8.5

///|
let prep_press_gain : Float = 0.9

///|
let heat_press_gain : Float = 1.0

///|
let boost_time : Float = 1.15

///|
let boost_cooldown : Float = 5.0

///|
let boost_prep_rate : Float = 1.7

///|
let boost_heat_rate : Float = 1.1

///|
let orders_x : Float = 206.0

///|
let orders_y0 : Float = 176.0

///|
let orders_gap : Float = 76.0

///|
let prep_x : Float = 592.0

///|
let prep_y : Float = 224.0

///|
let grill_x : Float = 470.0

///|
let grill_y : Float = 454.0

///|
let wok_x : Float = 716.0

///|
let wok_y : Float = 454.0

///|
let pass_x : Float = 1030.0

///|
let pass_y : Float = 312.0

///|
let node_prep : Int = max_orders

///|
let node_grill : Int = max_orders + 1

///|
let node_wok : Int = max_orders + 2

///|
let node_pass : Int = max_orders + 3

///|
let node_count : Int = max_orders + 4

///|
fn order_node_y(slot : Int) -> Float {
  orders_y0 + Float::from_int(clampi(slot, 0, max_orders - 1)) * orders_gap
}

///|
fn node_pos(node : Int) -> (Float, Float) {
  if node < max_orders {
    (orders_x, order_node_y(node))
  } else if node == node_prep {
    (prep_x, prep_y)
  } else if node == node_grill {
    (grill_x, grill_y)
  } else if node == node_wok {
    (wok_x, wok_y)
  } else {
    (pass_x, pass_y)
  }
}

///|
fn node_name(node : Int) -> String {
  if node < max_orders {
    "Order #" + (node + 1).to_string()
  } else if node == node_prep {
    "Prep"
  } else if node == node_grill {
    "Grill"
  } else if node == node_wok {
    "Wok"
  } else {
    "Serve Pass"
  }
}

///|
fn dish_name(dish : Int) -> String {
  if dish == dish_skewers {
    "Skewers"
  } else if dish == dish_noodles {
    "Noodles"
  } else if dish == dish_squid {
    "Char Squid"
  } else if dish == dish_fried_rice {
    "Fried Rice"
  } else {
    "None"
  }
}

///|
fn dish_lane(dish : Int) -> Int {
  if dish == dish_skewers || dish == dish_squid {
    lane_grill
  } else {
    lane_wok
  }
}

///|
fn dish_base_reward(dish : Int) -> Int {
  if dish == dish_skewers {
    120
  } else if dish == dish_noodles {
    140
  } else if dish == dish_squid {
    170
  } else if dish == dish_fried_rice {
    160
  } else {
    90
  }
}

///|
fn dish_prep_need(dish : Int) -> Float {
  if dish == dish_skewers {
    3.2
  } else if dish == dish_noodles {
    3.8
  } else if dish == dish_squid {
    4.2
  } else if dish == dish_fried_rice {
    3.5
  } else {
    3.0
  }
}

///|
fn dish_cook_need(dish : Int) -> Float {
  if dish == dish_skewers {
    3.6
  } else if dish == dish_noodles {
    3.2
  } else if dish == dish_squid {
    4.0
  } else if dish == dish_fried_rice {
    3.7
  } else {
    3.0
  }
}

///|
fn clampi(v : Int, lo : Int, hi : Int) -> Int {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
fn clampf(v : Float, lo : Float, hi : Float) -> Float {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
fn maxi(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}

///|
fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
fn randf(lo : Float, hi : Float) -> Float {
  let r = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
fn randi(lo : Int, hi : Int) -> Int {
  @raylib.get_random_value(lo, hi)
}

///|
fn sinf(v : Float) -> Float {
  Float::from_double(@math.sin(v.to_double()))
}

///|
fn cosf(v : Float) -> Float {
  Float::from_double(@math.cos(v.to_double()))
}
