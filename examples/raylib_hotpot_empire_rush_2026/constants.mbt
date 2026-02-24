///|
let screen_w : Int = 1680

///|
let screen_h : Int = 960

///|
let target_fps : Int = 120

///|
let state_title : Int = 0

///|
let state_playing : Int = 1

///|
let state_paused : Int = 2

///|
let state_game_over : Int = 3

///|
let station_cols : Int = 4

///|
let station_rows : Int = 3

///|
let station_tile_w : Int = 232

///|
let station_tile_h : Int = 178

///|
let station_gap : Int = 14

///|
let kitchen_left : Int = 52

///|
let kitchen_top : Int = 130

///|
let station_none : Int = -1

///|
let station_broth : Int = 0

///|
let station_protein : Int = 1

///|
let station_veg : Int = 2

///|
let station_spice : Int = 3

///|
let station_prep : Int = 4

///|
let station_pot : Int = 5

///|
let station_serve : Int = 6

///|
let station_rush : Int = 7

///|
let station_trash : Int = 8

///|
let station_queue : Int = 9

///|
let station_reputation : Int = 10

///|
let station_storage : Int = 11

///|
let ingredient_none : Int = 0

///|
let ingredient_protein : Int = 1

///|
let ingredient_veg : Int = 2

///|
let broth_count : Int = 3

///|
let protein_count : Int = 3

///|
let veg_count : Int = 3

///|
let spice_levels : Int = 3

///|
let max_orders : Int = 6

///|
let reputation_max : Float = 100.0

///|
let reputation_start : Float = 72.0

///|
let rep_gain_served : Float = 4.0

///|
let rep_loss_timeout : Float = 9.5

///|
let rep_loss_wrong_serve : Float = 7.0

///|
let rep_loss_discard_pot : Float = 3.0

///|
let score_base_serve : Int = 120

///|
let combo_keep_time : Float = 4.2

///|
let prep_target_base : Float = 3.2

///|
let cook_target_base : Float = 6.4

///|
let boost_meter_max : Float = 100.0

///|
let boost_cost : Float = 35.0

///|
let boost_duration : Float = 2.8

///|
let boost_charge_per_s : Float = 11.0

///|
let boost_speed_mult : Float = 1.9

///|
let rush_cooldown : Float = 7.0

///|
let msg_ttl : Float = 2.4

///|
fn kitchen_w() -> Int {
  station_cols * station_tile_w + (station_cols - 1) * station_gap
}

///|
fn kitchen_h() -> Int {
  station_rows * station_tile_h + (station_rows - 1) * station_gap
}

///|
fn station_x(col : Int) -> Int {
  kitchen_left + col * (station_tile_w + station_gap)
}

///|
fn station_y(row : Int) -> Int {
  kitchen_top + row * (station_tile_h + station_gap)
}

///|
fn panel_x() -> Int {
  kitchen_left + kitchen_w() + 36
}

///|
fn panel_w() -> Int {
  screen_w - panel_x() - 44
}

///|
fn station_at(x : Int, y : Int) -> Int {
  if y == 0 {
    if x == 0 {
      station_broth
    } else if x == 1 {
      station_protein
    } else if x == 2 {
      station_veg
    } else if x == 3 {
      station_spice
    } else {
      station_none
    }
  } else if y == 1 {
    if x == 0 {
      station_prep
    } else if x == 1 {
      station_pot
    } else if x == 2 {
      station_serve
    } else if x == 3 {
      station_rush
    } else {
      station_none
    }
  } else if y == 2 {
    if x == 0 {
      station_trash
    } else if x == 1 {
      station_queue
    } else if x == 2 {
      station_reputation
    } else if x == 3 {
      station_storage
    } else {
      station_none
    }
  } else {
    station_none
  }
}

///|
fn station_name(station : Int) -> String {
  if station == station_broth {
    "Broth Kettle"
  } else if station == station_protein {
    "Protein Crate"
  } else if station == station_veg {
    "Veg Basket"
  } else if station == station_spice {
    "Chili Rack"
  } else if station == station_prep {
    "Prep Board"
  } else if station == station_pot {
    "Hotpot Base"
  } else if station == station_serve {
    "Serve Counter"
  } else if station == station_rush {
    "Rush Bell"
  } else if station == station_trash {
    "Waste Bin"
  } else if station == station_queue {
    "Queue Monitor"
  } else if station == station_reputation {
    "Street Cred"
  } else {
    "Dry Storage"
  }
}

///|
fn broth_name(kind : Int) -> String {
  if kind == 0 {
    "Mala"
  } else if kind == 1 {
    "Tomato"
  } else {
    "Mushroom"
  }
}

///|
fn protein_name(kind : Int) -> String {
  if kind == 0 {
    "Beef"
  } else if kind == 1 {
    "Lamb"
  } else {
    "Tofu"
  }
}

///|
fn veg_name(kind : Int) -> String {
  if kind == 0 {
    "Lotus"
  } else if kind == 1 {
    "Spinach"
  } else {
    "Enoki"
  }
}

///|
fn spice_name(level : Int) -> String {
  if level <= 0 {
    "Mild"
  } else if level == 1 {
    "Bold"
  } else {
    "Inferno"
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
fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}
