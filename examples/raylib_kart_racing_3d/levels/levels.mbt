// Track waypoint data for each cup+race combination
// Returns array of (x, y, z) tuples forming a closed loop track
// Cup 0-3, Race 0-3 within each cup (4 races per cup, 16 tracks total)

///|
pub fn get_track_waypoints(
  cup : Int,
  race : Int,
) -> Array[(Float, Float, Float)] {
  let track_id = cup * 4 + race
  if track_id == 0 {
    // Mushroom Cup Race 1: Green Meadow Oval - simple beginner track
    [
      (0.0, 0.0, 0.0),
      (20.0, 0.0, 0.0),
      (35.0, 0.0, 10.0),
      (40.0, 0.0, 25.0),
      (35.0, 0.0, 40.0),
      (20.0, 0.0, 45.0),
      (0.0, 0.0, 45.0),
      (-15.0, 0.0, 40.0),
      (-20.0, 0.0, 25.0),
      (-15.0, 0.0, 10.0),
    ]
  } else if track_id == 1 {
    // Mushroom Cup Race 2: Crosswind Figure-8
    [
      (0.0, 0.0, 0.0),
      (15.0, 0.0, -5.0),
      (30.0, 0.0, 0.0),
      (40.0, 0.0, 15.0),
      (30.0, 0.0, 30.0),
      (15.0, 0.0, 25.0),
      (0.0, 0.0, 30.0),
      (-15.0, 0.0, 40.0),
      (-25.0, 0.0, 30.0),
      (-20.0, 0.0, 15.0),
      (-10.0, 0.0, 5.0),
    ]
  } else if track_id == 2 {
    // Mushroom Cup Race 3: Sunny Circuit - basic circuit with gentle curves
    [
      (0.0, 0.0, 0.0),
      (25.0, 0.0, 0.0),
      (40.0, 0.0, 8.0),
      (45.0, 0.0, 20.0),
      (40.0, 0.0, 35.0),
      (25.0, 0.0, 42.0),
      (10.0, 0.0, 42.0),
      (-5.0, 0.0, 35.0),
      (-10.0, 0.0, 20.0),
      (-5.0, 0.0, 8.0),
    ]
  } else if track_id == 3 {
    // Mushroom Cup Race 4: Beach Loop - seaside track
    [
      (0.0, 0.0, 0.0),
      (20.0, 0.0, 5.0),
      (35.0, 0.0, 0.0),
      (45.0, 0.0, 10.0),
      (50.0, 0.0, 25.0),
      (40.0, 0.0, 38.0),
      (25.0, 0.0, 45.0),
      (10.0, 0.0, 40.0),
      (-5.0, 0.0, 30.0),
      (-10.0, 0.0, 15.0),
    ]
  } else if track_id == 4 {
    // Star Cup Race 1: Mountain Pass - elevation changes
    [
      (0.0, 0.0, 0.0),
      (15.0, 2.0, 5.0),
      (25.0, 4.0, 15.0),
      (30.0, 6.0, 28.0),
      (20.0, 4.0, 40.0),
      (5.0, 2.0, 45.0),
      (-10.0, 3.0, 38.0),
      (-15.0, 1.0, 25.0),
      (-10.0, 0.0, 12.0),
    ]
  } else if track_id == 5 {
    // Star Cup Race 2: Castle Circuit - sharp corners
    [
      (0.0, 0.0, 0.0),
      (30.0, 0.0, 0.0),
      (30.0, 0.0, 15.0),
      (10.0, 0.0, 15.0),
      (10.0, 0.0, 30.0),
      (40.0, 0.0, 30.0),
      (40.0, 0.0, 45.0),
      (0.0, 0.0, 45.0),
      (0.0, 0.0, 30.0),
      (-15.0, 0.0, 30.0),
      (-15.0, 0.0, 15.0),
      (0.0, 0.0, 15.0),
    ]
  } else if track_id == 6 {
    // Star Cup Race 3: S-Curve Challenge - technical handling
    [
      (0.0, 0.0, 0.0),
      (20.0, 0.0, 8.0),
      (5.0, 0.0, 18.0),
      (25.0, 0.0, 28.0),
      (10.0, 0.0, 38.0),
      (30.0, 0.0, 48.0),
      (40.0, 0.0, 40.0),
      (35.0, 0.0, 25.0),
      (40.0, 0.0, 10.0),
      (25.0, 0.0, -5.0),
    ]
  } else if track_id == 7 {
    // Star Cup Race 4: Bridge Run - bridges over gaps
    [
      (0.0, 0.0, 0.0),
      (20.0, 1.0, 0.0),
      (35.0, 3.0, 8.0),
      (40.0, 1.0, 20.0),
      (35.0, 3.0, 32.0),
      (20.0, 1.0, 40.0),
      (5.0, 3.0, 38.0),
      (-5.0, 1.0, 25.0),
      (-10.0, 2.0, 12.0),
    ]
  } else if track_id == 8 {
    // Crown Cup Race 1: Technical Circuit - chicanes and tight turns
    [
      (0.0, 0.0, 0.0),
      (25.0, 0.0, -5.0),
      (50.0, 0.0, 0.0),
      (55.0, 0.0, 15.0),
      (45.0, 0.0, 20.0),
      (50.0, 0.0, 30.0),
      (55.0, 0.0, 45.0),
      (30.0, 0.0, 50.0),
      (5.0, 0.0, 45.0),
      (-5.0, 0.0, 30.0),
      (-10.0, 0.0, 15.0),
    ]
  } else if track_id == 9 {
    // Crown Cup Race 2: Desert Storm - wide with sand traps
    [
      (0.0, 0.0, 0.0),
      (30.0, 0.0, -8.0),
      (55.0, 0.0, 5.0),
      (60.0, 0.0, 25.0),
      (50.0, 1.0, 40.0),
      (30.0, 0.0, 50.0),
      (10.0, 0.0, 48.0),
      (-10.0, 0.0, 35.0),
      (-15.0, 0.0, 18.0),
      (-5.0, 0.0, 5.0),
    ]
  } else if track_id == 10 {
    // Crown Cup Race 3: Ice Track - slippery surfaces
    [
      (0.0, 0.0, 0.0),
      (15.0, 1.0, -5.0),
      (35.0, 2.0, 0.0),
      (40.0, 1.0, 15.0),
      (30.0, 0.0, 28.0),
      (15.0, 1.0, 35.0),
      (0.0, 2.0, 30.0),
      (-10.0, 1.0, 18.0),
      (-5.0, 0.0, 8.0),
    ]
  } else if track_id == 11 {
    // Crown Cup Race 4: Night City - urban circuit
    [
      (0.0, 0.0, 0.0),
      (20.0, 0.0, 0.0),
      (20.0, 0.0, 20.0),
      (40.0, 0.0, 20.0),
      (40.0, 0.0, 0.0),
      (55.0, 0.0, 0.0),
      (55.0, 0.0, 40.0),
      (35.0, 0.0, 40.0),
      (35.0, 0.0, 50.0),
      (0.0, 0.0, 50.0),
      (0.0, 0.0, 30.0),
      (-10.0, 0.0, 15.0),
    ]
  } else if track_id == 12 {
    // Special Cup Race 1: Rainbow Road - elevated winding
    [
      (0.0, 5.0, 0.0),
      (20.0, 6.0, -10.0),
      (40.0, 4.0, 0.0),
      (50.0, 7.0, 15.0),
      (45.0, 5.0, 35.0),
      (30.0, 8.0, 45.0),
      (10.0, 6.0, 50.0),
      (-5.0, 4.0, 40.0),
      (-15.0, 7.0, 25.0),
      (-10.0, 5.0, 10.0),
    ]
  } else if track_id == 13 {
    // Special Cup Race 2: Volcano - dangerous terrain
    [
      (0.0, 0.0, 0.0),
      (15.0, 2.0, -8.0),
      (35.0, 4.0, -5.0),
      (45.0, 6.0, 10.0),
      (40.0, 3.0, 25.0),
      (50.0, 5.0, 38.0),
      (35.0, 2.0, 48.0),
      (15.0, 4.0, 45.0),
      (-5.0, 1.0, 35.0),
      (-10.0, 3.0, 18.0),
    ]
  } else if track_id == 14 {
    // Special Cup Race 3: Underwater Tunnel - enclosed sections
    [
      (0.0, 0.0, 0.0),
      (25.0, -1.0, 5.0),
      (40.0, -2.0, 15.0),
      (45.0, -1.0, 30.0),
      (35.0, 0.0, 42.0),
      (20.0, -1.0, 50.0),
      (5.0, -2.0, 45.0),
      (-10.0, -1.0, 35.0),
      (-15.0, 0.0, 20.0),
      (-5.0, -1.0, 8.0),
    ]
  } else {
    // Special Cup Race 4: Grand Prix - the ultimate track
    [
      (0.0, 0.0, 0.0),
      (20.0, 2.0, -10.0),
      (40.0, 0.0, 0.0),
      (50.0, 3.0, 15.0),
      (45.0, 1.0, 30.0),
      (55.0, 4.0, 42.0),
      (40.0, 2.0, 52.0),
      (20.0, 5.0, 55.0),
      (5.0, 3.0, 48.0),
      (-10.0, 1.0, 35.0),
      (-15.0, 3.0, 20.0),
      (-5.0, 1.0, 8.0),
    ]
  }
}

// Get track segment metadata for each waypoint pair

///|
pub fn get_track_segments(
  cup : Int,
  race : Int,
) -> Array[(Int, Int, Float, Bool)] {
  // Returns array of (seg_type, surface_type, width_mult, is_ramp)
  let track_id = cup * 4 + race
  if track_id == 0 {
    // Green Meadow Oval - all normal road
    [
      (0, 0, 1.0, false),
      (1, 0, 1.0, false),
      (1, 0, 1.0, false),
      (1, 0, 1.0, false),
      (1, 0, 1.0, false),
      (0, 0, 1.0, false),
      (1, 0, 1.0, false),
      (1, 0, 1.0, false),
      (1, 0, 1.0, false),
      (0, 0, 1.0, false),
    ]
  } else if track_id == 1 {
    // Figure-8
    [
      (0, 0, 1.0, false),
      (1, 0, 1.0, false),
      (2, 0, 0.9, false),
      (1, 0, 1.0, false),
      (2, 0, 0.9, false),
      (1, 0, 1.0, false),
      (2, 0, 1.0, false),
      (1, 0, 1.0, false),
      (1, 0, 1.0, false),
      (0, 0, 1.0, false),
      (1, 0, 1.0, false),
    ]
  } else if track_id == 2 {
    // Sunny Circuit - with one boost pad
    [
      (0, 0, 1.1, false),
      (0, 3, 1.0, false),
      (1, 0, 1.0, false),
      (1, 0, 1.0, false),
      (1, 0, 1.0, false),
      (0, 0, 1.1, false),
      (1, 0, 1.0, false),
      (1, 0, 1.0, false),
      (0, 0, 1.0, false),
      (1, 0, 1.0, false),
    ]
  } else if track_id == 3 {
    // Beach Loop - some dirt/sand sections
    [
      (0, 0, 1.0, false),
      (0, 1, 1.0, false),
      (1, 0, 1.0, false),
      (1, 0, 1.0, false),
      (0, 1, 1.2, false),
      (1, 0, 1.0, false),
      (1, 0, 1.0, false),
      (0, 0, 1.0, false),
      (1, 0, 1.0, false),
      (0, 0, 1.0, false),
    ]
  } else if track_id == 4 {
    // Mountain Pass - narrow with ramps
    [
      (0, 0, 0.9, false),
      (1, 0, 0.8, false),
      (0, 0, 0.9, true),
      (1, 0, 0.8, false),
      (2, 0, 0.9, false),
      (0, 1, 1.0, false),
      (1, 0, 0.9, false),
      (0, 0, 0.9, false),
      (1, 0, 1.0, false),
    ]
  } else if track_id == 5 {
    // Castle Circuit - sharp turns
    [
      (0, 0, 1.0, false),
      (2, 0, 0.9, false),
      (0, 0, 0.8, false),
      (2, 0, 0.9, false),
      (0, 0, 1.0, false),
      (2, 0, 0.9, false),
      (0, 0, 1.0, false),
      (2, 0, 0.9, false),
      (0, 0, 0.8, false),
      (2, 0, 0.9, false),
      (0, 0, 1.0, false),
      (2, 0, 0.9, false),
    ]
  } else if track_id == 6 {
    // S-Curve Challenge - alternating curves
    [
      (3, 0, 1.0, false),
      (3, 0, 0.9, false),
      (3, 0, 1.0, false),
      (3, 0, 0.9, false),
      (3, 0, 1.0, false),
      (1, 0, 1.0, false),
      (0, 3, 1.0, false),
      (0, 0, 1.0, false),
      (1, 0, 1.0, false),
      (0, 0, 1.0, false),
    ]
  } else if track_id == 7 {
    // Bridge Run - elevated sections
    [
      (0, 0, 1.0, false),
      (7, 0, 0.8, false),
      (1, 0, 1.0, false),
      (7, 0, 0.8, false),
      (1, 0, 1.0, false),
      (7, 0, 0.8, false),
      (1, 0, 1.0, false),
      (0, 0, 1.0, false),
      (1, 0, 1.0, false),
    ]
  } else if track_id == 8 {
    // Technical Circuit - chicanes
    [
      (0, 0, 1.0, false),
      (4, 0, 0.9, false),
      (0, 0, 1.0, false),
      (2, 0, 0.9, false),
      (4, 0, 0.9, false),
      (0, 3, 1.0, false),
      (1, 0, 1.0, false),
      (0, 0, 1.1, false),
      (1, 0, 1.0, false),
      (0, 0, 1.0, false),
      (1, 0, 1.0, false),
    ]
  } else if track_id == 9 {
    // Desert Storm - dirt and sand traps
    [
      (0, 1, 1.2, false),
      (0, 0, 1.0, false),
      (1, 1, 1.1, false),
      (0, 0, 1.0, false),
      (1, 1, 1.0, false),
      (0, 0, 1.0, false),
      (1, 1, 1.1, false),
      (0, 0, 1.0, false),
      (0, 1, 1.2, false),
      (1, 0, 1.0, false),
    ]
  } else if track_id == 10 {
    // Ice Track - icy surfaces
    [
      (0, 5, 1.0, false),
      (1, 5, 0.9, false),
      (0, 0, 1.0, false),
      (1, 5, 0.9, false),
      (0, 0, 1.0, false),
      (1, 5, 1.0, false),
      (0, 0, 0.9, false),
      (1, 5, 1.0, false),
      (0, 0, 1.0, false),
    ]
  } else if track_id == 11 {
    // Night City - urban sharp corners
    [
      (0, 0, 1.0, false),
      (2, 0, 0.9, false),
      (0, 0, 1.0, false),
      (2, 0, 0.9, false),
      (0, 0, 1.0, false),
      (2, 0, 0.9, false),
      (0, 3, 1.1, false),
      (2, 0, 0.9, false),
      (0, 0, 1.0, false),
      (2, 0, 0.9, false),
      (0, 0, 1.0, false),
      (1, 0, 1.0, false),
    ]
  } else if track_id == 12 {
    // Rainbow Road - narrow, elevated
    [
      (0, 0, 0.7, false),
      (1, 0, 0.7, false),
      (0, 0, 0.7, true),
      (1, 0, 0.7, false),
      (2, 0, 0.7, false),
      (1, 3, 0.7, false),
      (0, 0, 0.7, false),
      (2, 0, 0.7, false),
      (1, 0, 0.7, false),
      (0, 0, 0.7, false),
    ]
  } else if track_id == 13 {
    // Volcano - narrow with hazards
    [
      (0, 0, 0.9, false),
      (1, 1, 0.8, false),
      (0, 0, 0.9, true),
      (1, 0, 0.9, false),
      (2, 0, 0.8, false),
      (0, 1, 0.9, false),
      (1, 0, 0.9, false),
      (0, 0, 1.0, false),
      (1, 0, 0.9, false),
      (0, 0, 0.9, false),
    ]
  } else if track_id == 14 {
    // Underwater Tunnel - enclosed sections
    [
      (0, 0, 1.0, false),
      (6, 0, 0.9, false),
      (6, 0, 0.9, false),
      (1, 0, 1.0, false),
      (6, 0, 0.9, false),
      (1, 0, 1.0, false),
      (6, 0, 0.9, false),
      (6, 0, 0.9, false),
      (0, 0, 1.0, false),
      (1, 0, 1.0, false),
    ]
  } else {
    // Grand Prix - varied terrain
    [
      (0, 0, 1.0, false),
      (1, 0, 0.9, false),
      (0, 3, 1.0, false),
      (2, 0, 0.9, true),
      (0, 0, 1.0, false),
      (1, 1, 0.9, false),
      (2, 0, 0.8, false),
      (0, 0, 1.0, true),
      (1, 0, 0.9, false),
      (0, 0, 1.0, false),
      (1, 0, 0.9, false),
      (0, 0, 1.0, false),
    ]
  }
}

// Track names

///|
pub fn get_track_name(cup : Int, race : Int) -> String {
  let track_id = cup * 4 + race
  if track_id == 0 {
    "Green Meadow Oval"
  } else if track_id == 1 {
    "Crosswind Circuit"
  } else if track_id == 2 {
    "Sunny Circuit"
  } else if track_id == 3 {
    "Beach Loop"
  } else if track_id == 4 {
    "Mountain Pass"
  } else if track_id == 5 {
    "Castle Circuit"
  } else if track_id == 6 {
    "S-Curve Challenge"
  } else if track_id == 7 {
    "Bridge Run"
  } else if track_id == 8 {
    "Technical Circuit"
  } else if track_id == 9 {
    "Desert Storm"
  } else if track_id == 10 {
    "Ice Track"
  } else if track_id == 11 {
    "Night City"
  } else if track_id == 12 {
    "Rainbow Road"
  } else if track_id == 13 {
    "Volcano Run"
  } else if track_id == 14 {
    "Deep Trench"
  } else {
    "Grand Prix"
  }
}

// Cup names

///|
pub fn get_cup_name(cup : Int) -> String {
  if cup == 0 {
    "Mushroom Cup"
  } else if cup == 1 {
    "Star Cup"
  } else if cup == 2 {
    "Crown Cup"
  } else {
    "Special Cup"
  }
}

// Cup difficulty levels (AI difficulty for each cup)

///|
pub fn get_cup_difficulty(cup : Int) -> Int {
  if cup == 0 {
    0 // Easy
  } else if cup == 1 {
    1 // Medium
  } else if cup == 2 {
    2 // Hard
  } else {
    3 // Expert
  }
}

// Track theme index

///|
pub fn get_track_theme(cup : Int, race : Int) -> Int {
  let track_id = cup * 4 + race
  if track_id == 0 {
    return 0
  } // Circuit
  if track_id == 1 {
    return 0
  } // Circuit
  if track_id == 2 {
    return 0
  } // Circuit
  if track_id == 3 {
    return 1
  } // Beach
  if track_id == 4 {
    return 2
  } // Mountain
  if track_id == 5 {
    return 3
  } // Castle
  if track_id == 6 {
    return 0
  } // Circuit
  if track_id == 7 {
    return 2
  } // Mountain
  if track_id == 8 {
    return 0
  } // Circuit
  if track_id == 9 {
    return 4
  } // Desert
  if track_id == 10 {
    return 5
  } // Ice
  if track_id == 11 {
    return 6
  } // Night
  if track_id == 12 {
    return 0
  } // Circuit (rainbow)
  if track_id == 13 {
    return 7
  } // Volcano
  if track_id == 14 {
    return 0
  } // Circuit (underwater)
  0 // Circuit (Grand Prix)
}

// Track ground colors for variety

///|
pub fn get_track_ground_color(cup : Int, race : Int) -> (Int, Int, Int) {
  let theme = get_track_theme(cup, race)
  if theme < @types.theme_ground_colors.length() {
    @types.theme_ground_colors[theme]
  } else {
    (80, 160, 60)
  }
}

// Track road colors

///|
pub fn get_track_road_color(cup : Int, race : Int) -> (Int, Int, Int) {
  let track_id = cup * 4 + race
  if track_id == 9 {
    (180, 150, 90) // Desert sandy road
  } else if track_id == 10 {
    (160, 180, 200) // Ice track pale blue
  } else if track_id == 11 {
    (50, 50, 55) // Night city dark asphalt
  } else if track_id == 12 {
    (140, 100, 200) // Rainbow road purple
  } else if track_id == 13 {
    (80, 50, 40) // Volcano dark rock
  } else if track_id == 14 {
    (60, 80, 100) // Underwater blue-gray
  } else {
    (90, 85, 75) // Default road
  }
}

// Track sky colors

///|
pub fn get_track_sky_color(cup : Int, race : Int) -> (Int, Int, Int) {
  let theme = get_track_theme(cup, race)
  if theme < @types.theme_sky_colors.length() {
    @types.theme_sky_colors[theme]
  } else {
    (100, 180, 255)
  }
}

// Lap count per track (most are 3, some special tracks differ)

///|
pub fn get_track_laps(cup : Int, race : Int) -> Int {
  let track_id = cup * 4 + race
  if track_id == 12 || track_id == 15 {
    2 // Rainbow Road and Grand Prix have fewer laps (longer tracks)
  } else {
    3
  }
}

// AI racing line offset per track (how far off center the ideal line is)

///|
pub fn get_ai_line_offset(cup : Int, race : Int, waypoint_idx : Int) -> Float {
  let track_id = cup * 4 + race
  // Alternate slightly left/right for more natural driving
  let base : Float = if waypoint_idx % 4 == 0 {
    1.0
  } else if waypoint_idx % 4 == 2 {
    -1.0
  } else {
    0.0
  }
  // More deviation on wider tracks
  if track_id == 0 || track_id == 2 || track_id == 3 {
    base * 1.5
  } else if track_id == 12 || track_id == 13 {
    base * 0.5 // Narrow tracks - stay centered
  } else {
    base * 1.0
  }
}

// Cup race count descriptions

///|
pub fn get_cup_description(cup : Int) -> String {
  if cup == 0 {
    "4 beginner tracks"
  } else if cup == 1 {
    "4 intermediate tracks"
  } else if cup == 2 {
    "4 advanced tracks"
  } else {
    "4 expert tracks"
  }
}

// Track description for preview

///|
pub fn get_track_description(cup : Int, race : Int) -> String {
  let track_id = cup * 4 + race
  if track_id == 0 {
    "A gentle oval to learn the basics"
  } else if track_id == 1 {
    "A figure-8 with crossing paths"
  } else if track_id == 2 {
    "Smooth curves and a boost pad"
  } else if track_id == 3 {
    "Coastal road with sandy edges"
  } else if track_id == 4 {
    "Climb the mountain with ramps"
  } else if track_id == 5 {
    "Sharp corners in the castle walls"
  } else if track_id == 6 {
    "Weaving S-curves test your skill"
  } else if track_id == 7 {
    "Cross elevated bridges"
  } else if track_id == 8 {
    "Chicanes demand precision"
  } else if track_id == 9 {
    "Sand and dirt slow you down"
  } else if track_id == 10 {
    "Icy surfaces reduce grip"
  } else if track_id == 11 {
    "Urban streets at night"
  } else if track_id == 12 {
    "Elevated narrow rainbow road"
  } else if track_id == 13 {
    "Volcanic terrain with ramps"
  } else if track_id == 14 {
    "Tunnel sections underwater"
  } else {
    "The ultimate test of skill"
  }
}

// Track decoration data: returns array of (deco_type, x_offset, z_offset, scale)
// x_offset is relative to track edge, z_offset is along segment

///|
pub fn get_track_decoration_data(
  cup : Int,
  race : Int,
) -> Array[(Int, Float, Float, Float)] {
  let track_id = cup * 4 + race
  if track_id == 0 {
    // Green Meadow - scattered trees and grandstand
    [
      (@types.deco_tree_green, 6.0, 0.0, 1.0),
      (@types.deco_tree_green, 7.0, 0.3, 1.2),
      (@types.deco_tree_green, -6.5, 0.5, 0.9),
      (@types.deco_rock_small, 5.5, 0.7, 0.8),
      (@types.deco_grandstand, -8.0, 0.2, 1.5),
      (@types.deco_sign_board, 5.0, 0.0, 1.0),
      (@types.deco_barrier_metal, 5.0, 0.4, 1.0),
      (@types.deco_barrier_metal, -5.0, 0.6, 1.0),
      (@types.deco_tree_green, -7.0, 0.8, 1.1),
      (@types.deco_tree_green, 8.0, 0.9, 0.8),
    ]
  } else if track_id == 1 {
    // Crosswind Circuit - mixed decorations
    [
      (@types.deco_tree_green, 6.0, 0.1, 1.0),
      (@types.deco_rock_small, -6.0, 0.2, 0.9),
      (@types.deco_barrier_metal, 5.5, 0.4, 1.0),
      (@types.deco_tree_green, -7.0, 0.5, 1.1),
      (@types.deco_sign_board, 6.0, 0.6, 1.0),
      (@types.deco_tree_green, 7.0, 0.8, 0.9),
      (@types.deco_barrier_metal, -5.5, 0.9, 1.0),
      (@types.deco_rock_small, 8.0, 0.3, 0.7),
    ]
  } else if track_id == 2 {
    // Sunny Circuit - grandstands and trees
    [
      (@types.deco_grandstand, -8.0, 0.0, 1.5),
      (@types.deco_grandstand, 8.0, 0.5, 1.3),
      (@types.deco_tree_green, 6.0, 0.2, 1.0),
      (@types.deco_tree_green, -6.0, 0.4, 1.2),
      (@types.deco_sign_board, 5.5, 0.1, 1.0),
      (@types.deco_barrier_metal, 5.0, 0.6, 1.0),
      (@types.deco_barrier_metal, -5.0, 0.8, 1.0),
      (@types.deco_tree_green, 7.0, 0.7, 0.8),
      (@types.deco_rock_small, -7.0, 0.3, 0.9),
    ]
  } else if track_id == 3 {
    // Beach Loop - palm trees and rocks
    [
      (@types.deco_tree_palm, 6.0, 0.0, 1.2),
      (@types.deco_tree_palm, -6.5, 0.2, 1.0),
      (@types.deco_tree_palm, 7.0, 0.4, 1.3),
      (@types.deco_rock_small, -5.5, 0.5, 0.8),
      (@types.deco_rock_large, 8.0, 0.6, 1.0),
      (@types.deco_tree_palm, -7.0, 0.8, 1.1),
      (@types.deco_sign_board, 5.5, 0.3, 1.0),
      (@types.deco_barrier_tire, -5.0, 0.9, 1.0),
    ]
  } else if track_id == 4 {
    // Mountain Pass - pine trees and large rocks
    [
      (@types.deco_tree_pine, 5.5, 0.0, 1.0),
      (@types.deco_tree_pine, -6.0, 0.15, 1.2),
      (@types.deco_rock_large, 7.0, 0.3, 1.0),
      (@types.deco_tree_pine, -5.5, 0.45, 0.9),
      (@types.deco_rock_small, 6.0, 0.6, 0.8),
      (@types.deco_tree_pine, 8.0, 0.75, 1.1),
      (@types.deco_barrier_metal, -5.0, 0.5, 1.0),
      (@types.deco_rock_large, -7.0, 0.9, 1.2),
    ]
  } else if track_id == 5 {
    // Castle Circuit - barriers and buildings
    [
      (@types.deco_barrier_metal, 5.0, 0.0, 1.0),
      (@types.deco_building_small, -7.0, 0.1, 1.2),
      (@types.deco_barrier_metal, -5.0, 0.25, 1.0),
      (@types.deco_building_tall, 8.0, 0.4, 1.5),
      (@types.deco_sign_board, -6.0, 0.55, 1.0),
      (@types.deco_barrier_metal, 5.0, 0.7, 1.0),
      (@types.deco_building_small, -8.0, 0.85, 1.0),
      (@types.deco_rock_small, 6.0, 0.3, 0.8),
    ]
  } else if track_id == 6 {
    // S-Curve Challenge - trees and signs
    [
      (@types.deco_tree_green, 6.0, 0.0, 1.0),
      (@types.deco_sign_board, -5.5, 0.15, 1.0),
      (@types.deco_tree_green, 7.0, 0.3, 1.1),
      (@types.deco_sign_board, -6.0, 0.45, 1.0),
      (@types.deco_tree_green, 6.5, 0.6, 0.9),
      (@types.deco_sign_board, -5.5, 0.75, 1.0),
      (@types.deco_barrier_metal, 5.0, 0.5, 1.0),
      (@types.deco_rock_small, -7.0, 0.9, 0.8),
    ]
  } else if track_id == 7 {
    // Bridge Run - rocks and metal barriers
    [
      (@types.deco_tree_pine, 6.0, 0.0, 1.0),
      (@types.deco_barrier_metal, -5.0, 0.15, 1.0),
      (@types.deco_rock_large, 8.0, 0.3, 1.1),
      (@types.deco_barrier_metal, 5.0, 0.5, 1.0),
      (@types.deco_tree_pine, -6.0, 0.65, 1.2),
      (@types.deco_rock_small, 7.0, 0.8, 0.9),
      (@types.deco_barrier_metal, -5.0, 0.9, 1.0),
    ]
  } else if track_id == 9 {
    // Desert Storm - cacti and rocks
    [
      (@types.deco_cactus, 6.0, 0.0, 1.0),
      (@types.deco_cactus, -6.5, 0.15, 0.8),
      (@types.deco_rock_large, 8.0, 0.3, 1.2),
      (@types.deco_cactus, -5.5, 0.45, 1.1),
      (@types.deco_rock_small, 7.0, 0.6, 0.9),
      (@types.deco_cactus, 6.5, 0.75, 0.7),
      (@types.deco_sign_board, -6.0, 0.9, 1.0),
      (@types.deco_rock_small, -7.0, 0.5, 0.8),
    ]
  } else if track_id == 10 {
    // Ice Track - snow mounds and pines
    [
      (@types.deco_snow_mound, 6.0, 0.0, 1.2),
      (@types.deco_tree_pine, -6.0, 0.15, 1.0),
      (@types.deco_snow_mound, 7.0, 0.3, 0.9),
      (@types.deco_tree_pine, -7.0, 0.45, 1.1),
      (@types.deco_barrier_metal, 5.0, 0.6, 1.0),
      (@types.deco_snow_mound, -6.5, 0.75, 1.0),
      (@types.deco_tree_pine, 8.0, 0.9, 0.8),
    ]
  } else if track_id == 11 {
    // Night City - lamp posts and buildings
    [
      (@types.deco_lamp_post, 5.5, 0.0, 1.0),
      (@types.deco_building_small, -7.0, 0.1, 1.2),
      (@types.deco_lamp_post, -5.5, 0.2, 1.0),
      (@types.deco_building_tall, 8.0, 0.35, 1.5),
      (@types.deco_lamp_post, 5.5, 0.5, 1.0),
      (@types.deco_building_small, -8.0, 0.65, 1.3),
      (@types.deco_lamp_post, -5.5, 0.8, 1.0),
      (@types.deco_barrier_tire, 5.0, 0.9, 1.0),
      (@types.deco_sign_board, -6.0, 0.4, 1.0),
    ]
  } else if track_id == 13 {
    // Volcano - lava rocks
    [
      (@types.deco_lava_rock, 6.0, 0.0, 1.1),
      (@types.deco_lava_rock, -6.5, 0.15, 0.9),
      (@types.deco_rock_large, 8.0, 0.3, 1.2),
      (@types.deco_lava_rock, -5.5, 0.45, 1.0),
      (@types.deco_rock_small, 7.0, 0.6, 0.8),
      (@types.deco_lava_rock, 6.5, 0.75, 1.3),
      (@types.deco_barrier_metal, -5.0, 0.9, 1.0),
    ]
  } else {
    // Default decorations for tracks without specific data
    [
      (@types.deco_tree_green, 6.0, 0.0, 1.0),
      (@types.deco_rock_small, -6.0, 0.25, 0.9),
      (@types.deco_tree_green, 7.0, 0.5, 1.1),
      (@types.deco_barrier_metal, -5.0, 0.75, 1.0),
      (@types.deco_sign_board, 5.5, 0.4, 1.0),
    ]
  }
}

// AI waypoint target offsets per track - lateral offset for each waypoint
// Positive = right side, negative = left side of track centerline

///|
pub fn get_ai_waypoint_offsets(cup : Int, race : Int) -> Array[Float] {
  let track_id = cup * 4 + race
  if track_id == 0 {
    // Green Meadow - gentle racing line
    [0.0, 1.0, 1.5, 0.5, -0.5, -1.5, -1.0, 0.0, 0.5, 1.0]
  } else if track_id == 1 {
    // Crosswind - alternating line
    [0.0, -1.0, 1.0, -1.5, 1.5, -1.0, 1.0, -0.5, 0.5, 0.0, -0.5]
  } else if track_id == 2 {
    // Sunny Circuit - smooth line
    [0.0, 0.5, 1.0, 0.5, -0.5, -1.0, -0.5, 0.5, 1.0, 0.5]
  } else if track_id == 3 {
    // Beach Loop - wide sweeping
    [0.0, 1.5, 0.5, -0.5, -1.0, 1.0, 0.5, -0.5, -1.5, 0.0]
  } else if track_id == 4 {
    // Mountain Pass - tight line
    [0.0, 0.5, -0.5, 0.5, -0.5, 0.0, 0.5, -0.5, 0.0]
  } else if track_id == 5 {
    // Castle Circuit - inside lines
    [0.0, -1.5, 1.5, -1.5, 1.5, -1.5, 1.5, -1.5, 1.5, -1.0, 1.0, 0.0]
  } else if track_id == 6 {
    // S-Curve - alternating
    [0.0, -1.5, 1.5, -1.5, 1.5, -1.0, 0.0, 0.5, -0.5, 0.0]
  } else if track_id == 7 {
    // Bridge Run - centered (narrow)
    [0.0, 0.0, 0.3, 0.0, -0.3, 0.0, 0.3, 0.0, 0.0]
  } else if track_id == 8 {
    // Technical Circuit - precision line
    [0.0, -1.0, 1.0, 1.5, -1.5, 0.0, 0.5, -0.5, 1.0, -1.0, 0.0]
  } else if track_id == 9 {
    // Desert Storm - wide arcs
    [0.0, 1.0, -1.0, 0.5, -0.5, 1.0, -1.0, 0.5, -0.5, 0.0]
  } else if track_id == 10 {
    // Ice Track - conservative
    [0.0, 0.3, -0.3, 0.3, -0.3, 0.3, -0.3, 0.3, 0.0]
  } else if track_id == 11 {
    // Night City - sharp inside lines
    [0.0, -1.0, 1.0, -1.0, 1.0, -1.0, 0.5, -1.0, 0.5, -0.5, 0.0, 0.5]
  } else if track_id == 12 {
    // Rainbow Road - very centered (narrow)
    [0.0, 0.2, -0.2, 0.2, -0.2, 0.0, 0.2, -0.2, 0.0, 0.0]
  } else if track_id == 13 {
    // Volcano - moderate line
    [0.0, 0.5, -0.5, 0.5, -0.5, 0.5, -0.5, 0.5, -0.5, 0.0]
  } else if track_id == 14 {
    // Deep Trench - centered
    [0.0, 0.3, 0.0, -0.3, 0.0, 0.3, 0.0, -0.3, 0.0, 0.0]
  } else {
    // Grand Prix - aggressive line
    [0.0, -1.0, 0.5, 1.5, -0.5, -1.0, 1.0, -0.5, 0.5, -1.0, 0.5, 0.0]
  }
}

// Track record holder names (fictional)

///|
pub fn get_track_record_holder(cup : Int, race : Int) -> String {
  let track_id = cup * 4 + race
  if track_id == 0 {
    "Speedster"
  } else if track_id == 1 {
    "TurnKing"
  } else if track_id == 2 {
    "SunRider"
  } else if track_id == 3 {
    "WaveRunner"
  } else if track_id == 4 {
    "Climber"
  } else if track_id == 5 {
    "KnightRacer"
  } else if track_id == 6 {
    "Slalom"
  } else if track_id == 7 {
    "BridgeMaster"
  } else if track_id == 8 {
    "Precision"
  } else if track_id == 9 {
    "DuneKing"
  } else if track_id == 10 {
    "IceDancer"
  } else if track_id == 11 {
    "NightOwl"
  } else if track_id == 12 {
    "StarRider"
  } else if track_id == 13 {
    "LavaSurfer"
  } else if track_id == 14 {
    "DeepDiver"
  } else {
    "Champion"
  }
}

// Get track record time for display

///|
pub fn get_track_record_time(cup : Int, race : Int) -> Float {
  let track_id = cup * 4 + race
  if track_id < @types.track_record_times.length() {
    @types.track_record_times[track_id]
  } else {
    999.0
  }
}

// Get track difficulty rating (1-5)

///|
pub fn get_track_difficulty(cup : Int, race : Int) -> Int {
  let track_id = cup * 4 + race
  if track_id < @types.track_difficulty_ratings.length() {
    @types.track_difficulty_ratings[track_id]
  } else {
    3
  }
}

// Get track length estimate (sum of waypoint segment distances)

///|
pub fn get_track_length_estimate(cup : Int, race : Int) -> Float {
  let wps = get_track_waypoints(cup, race)
  let count = wps.length()
  if count < 2 {
    return 0.0
  }
  let mut total : Float = 0.0
  for i in 0..<count {
    let cur = wps[i]
    let next_idx = (i + 1) % count
    let next = wps[next_idx]
    let dx = next.0 - cur.0
    let dy = next.1 - cur.1
    let dz = next.2 - cur.2
    total = total + (dx * dx + dy * dy + dz * dz).sqrt()
  }
  total
}

// Get track surface variety description

///|
pub fn get_track_surface_info(cup : Int, race : Int) -> String {
  let track_id = cup * 4 + race
  if track_id == 0 || track_id == 2 {
    "Smooth asphalt"
  } else if track_id == 1 {
    "Mixed surface"
  } else if track_id == 3 {
    "Road with sand patches"
  } else if track_id == 4 || track_id == 7 {
    "Narrow mountain road"
  } else if track_id == 5 {
    "Castle cobblestone"
  } else if track_id == 6 {
    "Winding road with boost"
  } else if track_id == 8 {
    "Technical surface"
  } else if track_id == 9 {
    "Sandy desert road"
  } else if track_id == 10 {
    "Icy with low grip"
  } else if track_id == 11 {
    "Night city asphalt"
  } else if track_id == 12 {
    "Narrow rainbow surface"
  } else if track_id == 13 {
    "Volcanic rock"
  } else if track_id == 14 {
    "Underwater tunnel"
  } else {
    "Championship surface"
  }
}

// Get number of item boxes on track

///|
pub fn get_track_item_box_count(cup : Int, race : Int) -> Int {
  let track_id = cup * 4 + race
  if track_id == 0 || track_id == 2 || track_id == 3 {
    8
  } else if track_id == 1 || track_id == 6 {
    10
  } else if track_id == 4 || track_id == 7 || track_id == 12 {
    6
  } else if track_id == 5 || track_id == 8 || track_id == 11 {
    10
  } else if track_id == 9 || track_id == 10 {
    8
  } else if track_id == 13 || track_id == 14 {
    8
  } else {
    12
  }
}

// Get track elevation change description

///|
pub fn get_track_elevation_info(cup : Int, race : Int) -> String {
  let track_id = cup * 4 + race
  if track_id == 0 ||
    track_id == 1 ||
    track_id == 2 ||
    track_id == 5 ||
    track_id == 8 ||
    track_id == 11 {
    "Flat"
  } else if track_id == 3 || track_id == 6 || track_id == 9 {
    "Gentle hills"
  } else if track_id == 4 || track_id == 7 || track_id == 10 {
    "Moderate hills"
  } else if track_id == 12 || track_id == 15 {
    "High elevation"
  } else if track_id == 13 {
    "Steep climbs"
  } else if track_id == 14 {
    "Below sea level"
  } else {
    "Varied"
  }
}

// Get theme-specific sky gradient secondary color for rendering

///|
pub fn get_sky_gradient_color(cup : Int, race : Int) -> (Int, Int, Int) {
  let theme = get_track_theme(cup, race)
  if theme == @types.theme_circuit {
    (180, 220, 255)
  } else if theme == @types.theme_beach {
    (200, 230, 255)
  } else if theme == @types.theme_mountain {
    (180, 200, 230)
  } else if theme == @types.theme_castle {
    (120, 130, 170)
  } else if theme == @types.theme_desert {
    (240, 220, 160)
  } else if theme == @types.theme_ice {
    (210, 230, 250)
  } else if theme == @types.theme_night {
    (10, 12, 30)
  } else if theme == @types.theme_volcano {
    (160, 90, 50)
  } else {
    (180, 220, 255)
  }
}

// Get horizon fog color per theme

///|
pub fn get_fog_color(cup : Int, race : Int) -> (Int, Int, Int) {
  let theme = get_track_theme(cup, race)
  if theme == @types.theme_circuit {
    (200, 220, 240)
  } else if theme == @types.theme_beach {
    (220, 230, 240)
  } else if theme == @types.theme_mountain {
    (180, 190, 210)
  } else if theme == @types.theme_castle {
    (100, 110, 140)
  } else if theme == @types.theme_desert {
    (230, 210, 160)
  } else if theme == @types.theme_ice {
    (220, 230, 240)
  } else if theme == @types.theme_night {
    (15, 18, 35)
  } else if theme == @types.theme_volcano {
    (140, 80, 50)
  } else {
    (200, 220, 240)
  }
}
