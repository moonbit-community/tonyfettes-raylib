///|
pub fn order_node_y(slot : Int) -> Float {
  orders_y0 + Float::from_int(clampi(slot, 0, max_orders - 1)) * orders_gap
}

///|
pub fn node_pos(node : Int) -> (Float, Float) {
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
pub fn node_name(node : Int) -> String {
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
pub fn dish_name(dish : Int) -> String {
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
pub fn dish_lane(dish : Int) -> Int {
  if dish == dish_skewers || dish == dish_squid {
    lane_grill
  } else {
    lane_wok
  }
}

///|
pub fn dish_base_reward(dish : Int) -> Int {
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
pub fn dish_prep_need(dish : Int) -> Float {
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
pub fn dish_cook_need(dish : Int) -> Float {
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
pub fn clampi(v : Int, lo : Int, hi : Int) -> Int {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
pub fn clampf(v : Float, lo : Float, hi : Float) -> Float {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub fn maxi(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
pub fn randf(lo : Float, hi : Float) -> Float {
  let r = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
pub fn randi(lo : Int, hi : Int) -> Int {
  @raylib.get_random_value(lo, hi)
}

///|
pub fn sinf(v : Float) -> Float {
  Float::from_double(@math.sin(v.to_double()))
}

///|
pub fn cosf(v : Float) -> Float {
  Float::from_double(@math.cos(v.to_double()))
}
