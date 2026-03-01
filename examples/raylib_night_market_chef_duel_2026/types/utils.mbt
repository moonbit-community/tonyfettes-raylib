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
pub fn dish_name(dish : Dish) -> String {
  match dish {
    Skewers => "Skewers"
    Noodles => "Noodles"
    Squid => "Char Squid"
    FriedRice => "Fried Rice"
    DishNone => "None"
  }
}

///|
pub fn dish_lane(dish : Dish) -> Lane {
  match dish {
    Skewers | Squid => Grill
    Noodles | FriedRice | DishNone => Wok
  }
}

///|
pub fn dish_base_reward(dish : Dish) -> Int {
  match dish {
    Skewers => 120
    Noodles => 140
    Squid => 170
    FriedRice => 160
    DishNone => 90
  }
}

///|
pub fn dish_prep_need(dish : Dish) -> Float {
  match dish {
    Skewers => 3.2
    Noodles => 3.8
    Squid => 4.2
    FriedRice => 3.5
    DishNone => 3.0
  }
}

///|
pub fn dish_cook_need(dish : Dish) -> Float {
  match dish {
    Skewers => 3.6
    Noodles => 3.2
    Squid => 4.0
    FriedRice => 3.7
    DishNone => 3.0
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
