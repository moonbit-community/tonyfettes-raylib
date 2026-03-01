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
pub fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
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
pub fn sinf(v : Float) -> Float {
  Float::from_double(@math.sin(v.to_double()))
}

///|
pub fn week_duration_for(week : Int) -> Float {
  let raw = week_duration_base - Float::from_int(week - 1) * week_duration_drop
  maxf(week_duration_min, raw)
}

///|
pub fn upkeep_for(week : Int) -> Float {
  week_upkeep_base + Float::from_int(week - 1) * week_upkeep_growth
}

///|
pub fn incident_gap_for(week : Int) -> Float {
  let raw = incident_gap_base - Float::from_int(week - 1) * incident_gap_drop
  maxf(incident_gap_min, raw)
}

///|
pub fn incident_severity_for(week : Int) -> Float {
  incident_severity_base + Float::from_int(week - 1) * incident_severity_growth
}

///|
pub fn room_name(room : Int) -> String {
  if room == room_rest {
    "Rest"
  } else if room == room_train {
    "Train"
  } else if room == room_sparring {
    "Spar"
  } else {
    "Defense"
  }
}
