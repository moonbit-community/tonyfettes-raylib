///|
struct Clue {
  x : Int
  y : Int
  suspect : Int
  chain : Int
  mut discovered : Bool
  mut glow_t : Float
}

///|
struct Suspect {
  name : String
  home_x : Int
  home_y : Int
  mut deduction_unlocked : Bool
  mut suspicion : Float
}

///|
struct Incident {
  mut active : Bool
  mut x : Int
  mut y : Int
  mut culprit : Int
  mut timer : Float
  mut severity : Int
  mut pulse_t : Float
}

///|
struct DistrictPulse {
  mut heat : Float
  drift : Float
}

///|
struct Game {
  clues : Array[Clue]
  suspects : Array[Suspect]
  incidents : Array[Incident]
  pulses : Array[DistrictPulse]
  chain_progress : Array[Int]
  evidence_score : Array[Int]
  mut state : Int
  mut cursor_x : Int
  mut cursor_y : Int
  mut marked_suspect : Int
  mut trust : Float
  mut score : Int
  mut best_score : Int
  mut case_time : Float
  mut spawn_t : Float
  mut focus_t : Float
  mut focus_cd : Float
  mut city_time : Float
  mut solved_incidents : Int
  mut failed_incidents : Int
  mut wrong_accusations : Int
  mut clue_found : Int
  mut message : String
  mut message_t : Float
  mut input_dx : Int
  mut input_dy : Int
  mut input_inspect_press : Bool
  mut input_cancel_press : Bool
  mut input_focus_press : Bool
  mut input_pause_press : Bool
  mut input_restart_press : Bool
}

///|
fn suspect_name(index : Int) -> String {
  if index == 0 {
    "Mara Quill"
  } else if index == 1 {
    "Ivo Vance"
  } else if index == 2 {
    "Sera Nox"
  } else {
    "Dax Rill"
  }
}

///|
fn suspect_home_x(index : Int) -> Int {
  if index == 0 {
    1
  } else if index == 1 {
    city_cols - 2
  } else if index == 2 {
    1
  } else {
    city_cols - 2
  }
}

///|
fn suspect_home_y(index : Int) -> Int {
  if index == 0 {
    1
  } else if index == 1 {
    1
  } else if index == 2 {
    city_rows - 2
  } else {
    city_rows - 2
  }
}

///|
fn is_reserved_cell(cell_x : Int, cell_y : Int) -> Bool {
  let mut i = 0
  while i < suspect_count {
    if cell_x == suspect_home_x(i) && cell_y == suspect_home_y(i) {
      return true
    }
    i = i + 1
  }
  false
}

///|
fn Clue::new(index : Int) -> Clue {
  let suspect = index % suspect_count
  let chain = index / suspect_count % chains_per_suspect
  let step = index / (suspect_count * chains_per_suspect)

  let mut x = (index * 7 + suspect * 3 + chain * 5 + step * 2 + 1) % city_cols
  let mut y = (index * 11 + suspect * 2 + chain * 4 + step * 3 + 2) % city_rows

  let mut tries = 0
  while tries < district_count && is_reserved_cell(x, y) {
    x = (x + 3 + tries) % city_cols
    y = (y + 1 + tries) % city_rows
    tries = tries + 1
  }

  { x, y, suspect, chain, discovered: false, glow_t: 0.0 }
}

///|
fn Suspect::new(index : Int) -> Suspect {
  {
    name: suspect_name(index),
    home_x: suspect_home_x(index),
    home_y: suspect_home_y(index),
    deduction_unlocked: false,
    suspicion: 0.0,
  }
}

///|
fn Incident::new() -> Incident {
  {
    active: false,
    x: 0,
    y: 0,
    culprit: 0,
    timer: 0.0,
    severity: 1,
    pulse_t: 0.0,
  }
}

///|
fn DistrictPulse::new(index : Int) -> DistrictPulse {
  let drift_seed = Float::from_int((index * 71 + 17) % 1000) / 1000.0
  { heat: 0.0, drift: drift_seed * tau }
}

///|
fn Game::new() -> Game {
  {
    clues: Array::makei(clue_count, fn(i) { Clue::new(i) }),
    suspects: Array::makei(suspect_count, fn(i) { Suspect::new(i) }),
    incidents: Array::makei(max_incidents, fn(_i) { Incident::new() }),
    pulses: Array::makei(district_count, fn(i) { DistrictPulse::new(i) }),
    chain_progress: Array::make(suspect_count * chains_per_suspect, 0),
    evidence_score: Array::make(suspect_count, 0),
    state: state_title,
    cursor_x: city_cols / 2,
    cursor_y: city_rows / 2,
    marked_suspect: -1,
    trust: trust_max,
    score: 0,
    best_score: 0,
    case_time: time_limit_s,
    spawn_t: 2.5,
    focus_t: 0.0,
    focus_cd: 0.0,
    city_time: 0.0,
    solved_incidents: 0,
    failed_incidents: 0,
    wrong_accusations: 0,
    clue_found: 0,
    message: "Press J to open the case file.",
    message_t: 99.0,
    input_dx: 0,
    input_dy: 0,
    input_inspect_press: false,
    input_cancel_press: false,
    input_focus_press: false,
    input_pause_press: false,
    input_restart_press: false,
  }
}
