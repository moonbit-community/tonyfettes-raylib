// Level data generator
// Each level is defined by spawning platforms, collectibles, hazards procedurally
// 4 worlds x 5 levels = 20 total levels

///|
pub fn get_world_name(world : Int) -> String {
  if world == 0 {
    "Green Hills"
  } else if world == 1 {
    "Crystal Caves"
  } else if world == 2 {
    "Lava Peaks"
  } else {
    "Sky Fortress"
  }
}

///|
pub fn get_level_name(world : Int, level : Int) -> String {
  if world == 0 {
    if level == 0 {
      "Meadow Path"
    } else if level == 1 {
      "Forest Trail"
    } else if level == 2 {
      "Bouncy Grove"
    } else if level == 3 {
      "Hilltop Run"
    } else {
      "Canopy Heights"
    }
  } else if world == 1 {
    if level == 0 {
      "Ice Entry"
    } else if level == 1 {
      "Frozen Bridges"
    } else if level == 2 {
      "Crystal Passage"
    } else if level == 3 {
      "Sliding Cavern"
    } else {
      "Diamond Core"
    }
  } else if world == 2 {
    if level == 0 {
      "Ember Walk"
    } else if level == 1 {
      "Crumble Ridge"
    } else if level == 2 {
      "Lava Crossing"
    } else if level == 3 {
      "Flame Gauntlet"
    } else {
      "Volcano Summit"
    }
  } else if level == 0 {
    "Cloud Step"
  } else if level == 1 {
    "Wind Lifts"
  } else if level == 2 {
    "Storm Bridges"
  } else if level == 3 {
    "Lightning Run"
  } else {
    "Celestial Peak"
  }
}

// World color themes

///|
pub fn world_platform_color(world : Int) -> (Int, Int, Int) {
  if world == 0 {
    (80, 160, 60)
  } else if world == 1 {
    (80, 120, 180)
  } else if world == 2 {
    (160, 80, 40)
  } else {
    (140, 140, 160)
  }
}

///|
pub fn world_bg_color(world : Int) -> (Int, Int, Int) {
  if world == 0 {
    (100, 180, 255)
  } else if world == 1 {
    (20, 30, 60)
  } else if world == 2 {
    (60, 20, 10)
  } else {
    (180, 200, 240)
  }
}

// Decoration theme colors

///|
pub fn world_deco_color_1(world : Int) -> (Int, Int, Int) {
  if world == 0 {
    (60, 130, 40)
  } else if world == 1 {
    (100, 150, 255)
  } else if world == 2 {
    (80, 50, 30)
  } else {
    (240, 245, 255)
  }
}

///|
pub fn world_deco_color_2(world : Int) -> (Int, Int, Int) {
  if world == 0 {
    (100, 70, 40)
  } else if world == 1 {
    (60, 90, 180)
  } else if world == 2 {
    (255, 100, 20)
  } else {
    (200, 195, 210)
  }
}

// Platform layout data per level
// Returns array of (kind, x, y, z, w, d, move_range, move_speed)

///|
pub fn get_platform_data(
  world : Int,
  level : Int,
) -> Array[(Int, Float, Float, Float, Float, Float, Float, Float)] {
  let platforms : Array[(Int, Float, Float, Float, Float, Float, Float, Float)] = []
  // Start platform (always)
  platforms.push((0, 0.0, 0.0, 0.0, 4.0, 4.0, 0.0, 0.0))
  if world == 0 {
    build_forest_level(platforms, level)
  } else if world == 1 {
    build_crystal_level(platforms, level)
  } else if world == 2 {
    build_lava_level(platforms, level)
  } else {
    build_sky_level(platforms, level)
  }
  platforms
}

// ========== Forest World (World 0) ==========

///|
fn build_forest_level(
  platforms : Array[(Int, Float, Float, Float, Float, Float, Float, Float)],
  level : Int,
) -> Unit {
  if level == 0 {
    // Meadow Path - gentle introduction
    platforms.push((0, 0.0, 0.0, -5.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((0, 3.0, 0.5, -9.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((0, 0.0, 1.0, -13.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((0, -3.0, 1.5, -17.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((0, 0.0, 2.0, -21.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((0, 3.0, 2.5, -25.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((0, 6.0, 3.0, -28.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((0, 3.0, 3.5, -32.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((0, 0.0, 4.0, -36.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((0, -3.0, 4.5, -40.0, 3.0, 3.0, 0.0, 0.0))
    // Goal platform
    platforms.push((0, 0.0, 5.0, -45.0, 3.0, 3.0, 0.0, 0.0))
  } else if level == 1 {
    // Forest Trail - introduces bouncy platforms
    platforms.push((0, 0.0, 0.0, -5.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((0, 4.0, 0.5, -8.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((5, 7.0, 0.5, -12.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((0, 4.0, 3.0, -16.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((0, 0.0, 3.0, -20.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((5, -3.0, 3.0, -24.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((0, -3.0, 6.0, -28.0, 3.0, 2.5, 0.0, 0.0))
    platforms.push((0, 0.0, 6.5, -32.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((0, 3.0, 7.0, -36.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((5, 6.0, 7.0, -40.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((0, 3.0, 10.0, -44.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((0, 0.0, 10.5, -48.0, 3.0, 3.0, 0.0, 0.0))
  } else if level == 2 {
    // Bouncy Grove - lots of bouncy platforms with vertical gameplay
    platforms.push((0, 0.0, 0.0, -5.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((5, 3.0, 0.0, -9.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((0, 6.0, 3.0, -9.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((5, 3.0, 3.0, -13.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((0, 0.0, 6.0, -13.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((5, -3.0, 6.0, -17.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((0, -6.0, 9.0, -17.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((5, -3.0, 9.0, -21.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((0, 0.0, 12.0, -21.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((1, 3.0, 12.0, -25.0, 2.5, 2.5, 3.0, 2.0))
    platforms.push((0, 6.0, 13.0, -30.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((0, 3.0, 13.5, -35.0, 3.0, 3.0, 0.0, 0.0))
  } else if level == 3 {
    // Hilltop Run - moving platforms introduced
    platforms.push((0, 0.0, 0.0, -5.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((1, 4.0, 1.0, -8.0, 2.5, 2.5, 3.0, 1.5))
    platforms.push((0, 8.0, 2.0, -12.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((3, 8.0, 2.5, -17.0, 2.5, 2.5, 4.0, 1.5))
    platforms.push((0, 5.0, 3.0, -22.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((2, 2.0, 4.0, -26.0, 2.5, 2.5, 2.0, 1.0))
    platforms.push((0, 2.0, 6.0, -30.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((1, -1.0, 6.5, -34.0, 2.5, 2.5, 3.0, 2.0))
    platforms.push((0, -4.0, 7.0, -38.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((5, -1.0, 7.0, -42.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((0, -1.0, 10.0, -46.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((3, 2.0, 10.5, -50.0, 2.5, 2.5, 3.0, 1.5))
    platforms.push((0, 2.0, 11.0, -55.0, 3.0, 3.0, 0.0, 0.0))
  } else {
    // Canopy Heights - final forest level, challenge level
    platforms.push((0, 0.0, 0.0, -4.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((1, 3.0, 1.0, -8.0, 2.0, 2.0, 4.0, 2.0))
    platforms.push((5, 7.0, 1.0, -12.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((0, 7.0, 4.0, -16.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((3, 4.0, 5.0, -20.0, 2.0, 2.0, 4.0, 2.0))
    platforms.push((0, 0.0, 6.0, -24.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((2, -3.0, 7.0, -28.0, 2.0, 2.0, 3.0, 1.5))
    platforms.push((5, -6.0, 7.0, -32.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((0, -6.0, 10.0, -36.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((1, -3.0, 11.0, -40.0, 2.0, 2.0, 3.0, 2.0))
    platforms.push((0, 0.0, 12.0, -44.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((5, 3.0, 12.0, -48.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((0, 3.0, 15.0, -52.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((2, 0.0, 16.0, -56.0, 2.0, 2.0, 2.5, 1.5))
    platforms.push((0, 0.0, 18.0, -60.0, 3.0, 3.0, 0.0, 0.0))
  }
}

// ========== Crystal World (World 1) ==========

///|
fn build_crystal_level(
  platforms : Array[(Int, Float, Float, Float, Float, Float, Float, Float)],
  level : Int,
) -> Unit {
  if level == 0 {
    // Ice Entry - introduces ice platforms
    platforms.push((0, 0.0, 0.0, -5.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((6, 3.0, 0.5, -9.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((0, 6.0, 1.0, -13.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((6, 3.0, 1.5, -17.0, 3.5, 3.0, 0.0, 0.0))
    platforms.push((0, 0.0, 2.0, -21.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((6, -3.0, 2.5, -25.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((0, -6.0, 3.0, -29.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((6, -3.0, 3.5, -33.0, 3.5, 3.0, 0.0, 0.0))
    platforms.push((0, 0.0, 4.0, -37.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((0, 3.0, 4.5, -42.0, 3.0, 3.0, 0.0, 0.0))
  } else if level == 1 {
    // Frozen Bridges - ice + moving platforms
    platforms.push((6, 0.0, 0.0, -5.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((1, 4.0, 1.0, -9.0, 2.5, 2.5, 3.0, 1.5))
    platforms.push((6, 8.0, 1.5, -13.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((0, 5.0, 2.0, -17.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((1, 2.0, 2.5, -21.0, 2.5, 2.5, 4.0, 2.0))
    platforms.push((6, -2.0, 3.0, -25.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((3, -2.0, 3.5, -30.0, 2.5, 2.5, 3.0, 1.5))
    platforms.push((0, 2.0, 4.0, -34.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((6, 5.0, 4.5, -38.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((1, 2.0, 5.0, -42.0, 2.0, 2.0, 3.0, 2.0))
    platforms.push((0, 0.0, 5.5, -47.0, 3.0, 3.0, 0.0, 0.0))
  } else if level == 2 {
    // Crystal Passage - ice + bouncy combos
    platforms.push((6, 0.0, 0.0, -5.0, 3.0, 2.5, 0.0, 0.0))
    platforms.push((5, 4.0, 0.0, -9.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((6, 4.0, 3.0, -13.0, 3.0, 2.5, 0.0, 0.0))
    platforms.push((0, 0.0, 3.5, -17.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((5, -3.0, 3.5, -21.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((6, -3.0, 6.5, -25.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((1, 0.0, 7.0, -29.0, 2.5, 2.5, 3.0, 1.5))
    platforms.push((6, 4.0, 7.5, -33.0, 3.0, 2.5, 0.0, 0.0))
    platforms.push((5, 7.0, 7.5, -37.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((0, 7.0, 10.5, -41.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((6, 4.0, 11.0, -45.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((0, 0.0, 11.5, -50.0, 3.0, 3.0, 0.0, 0.0))
  } else if level == 3 {
    // Sliding Cavern - lots of ice, moving, and tricky jumps
    platforms.push((6, 0.0, 0.0, -5.0, 4.0, 3.0, 0.0, 0.0))
    platforms.push((6, 5.0, 0.5, -9.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((1, 9.0, 1.0, -13.0, 2.0, 2.0, 4.0, 2.0))
    platforms.push((6, 5.0, 2.0, -18.0, 3.5, 3.0, 0.0, 0.0))
    platforms.push((3, 1.0, 2.5, -22.0, 2.5, 2.5, 3.0, 1.5))
    platforms.push((6, -3.0, 3.0, -26.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((5, -6.0, 3.0, -30.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((6, -6.0, 6.0, -34.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((1, -3.0, 6.5, -38.0, 2.5, 2.5, 3.0, 2.0))
    platforms.push((0, 0.0, 7.0, -42.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((6, 4.0, 7.5, -46.0, 3.5, 3.0, 0.0, 0.0))
    platforms.push((2, 7.0, 8.5, -50.0, 2.0, 2.0, 3.0, 1.5))
    platforms.push((0, 4.0, 10.0, -54.0, 3.0, 3.0, 0.0, 0.0))
  } else {
    // Diamond Core - challenge level
    platforms.push((6, 0.0, 0.0, -4.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((1, 4.0, 1.0, -8.0, 2.0, 2.0, 4.0, 2.5))
    platforms.push((6, 8.0, 2.0, -12.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((5, 5.0, 2.0, -16.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((6, 2.0, 5.0, -20.0, 3.0, 2.5, 0.0, 0.0))
    platforms.push((3, -1.0, 5.5, -24.0, 2.0, 2.0, 4.0, 2.0))
    platforms.push((6, -5.0, 6.0, -28.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((1, -2.0, 7.0, -32.0, 2.0, 2.0, 3.0, 2.5))
    platforms.push((5, 2.0, 7.0, -36.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((6, 2.0, 10.0, -40.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((2, 5.0, 11.0, -44.0, 2.0, 2.0, 3.0, 2.0))
    platforms.push((0, 5.0, 13.0, -48.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((1, 2.0, 14.0, -52.0, 2.0, 2.0, 4.0, 2.5))
    platforms.push((6, -2.0, 15.0, -56.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((0, 0.0, 16.0, -61.0, 3.0, 3.0, 0.0, 0.0))
  }
}

// ========== Lava World (World 2) ==========

///|
fn build_lava_level(
  platforms : Array[(Int, Float, Float, Float, Float, Float, Float, Float)],
  level : Int,
) -> Unit {
  if level == 0 {
    // Ember Walk - introduces falling platforms
    platforms.push((0, 0.0, 0.0, -5.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((4, 3.0, 0.5, -9.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((0, 6.0, 1.0, -13.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((4, 3.0, 1.5, -17.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((0, 0.0, 2.0, -21.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((0, -3.0, 2.5, -25.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((4, -6.0, 3.0, -29.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((0, -3.0, 3.5, -33.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((0, 0.0, 4.0, -37.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((0, 3.0, 4.5, -42.0, 3.0, 3.0, 0.0, 0.0))
  } else if level == 1 {
    // Crumble Ridge - crumbling platforms
    platforms.push((0, 0.0, 0.0, -5.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((7, 4.0, 0.5, -9.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((0, 8.0, 1.0, -13.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((7, 5.0, 1.5, -17.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((4, 2.0, 2.0, -21.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((0, -1.0, 2.5, -25.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((7, -4.0, 3.0, -29.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((0, -7.0, 3.5, -33.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((7, -4.0, 4.0, -37.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((0, -1.0, 4.5, -41.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((4, 2.0, 5.0, -45.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((0, 0.0, 5.5, -50.0, 3.0, 3.0, 0.0, 0.0))
  } else if level == 2 {
    // Lava Crossing - falling + moving over lava
    platforms.push((0, 0.0, 0.0, -5.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((1, 4.0, 1.0, -9.0, 2.0, 2.0, 3.0, 2.0))
    platforms.push((4, 8.0, 1.5, -13.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((0, 5.0, 2.0, -17.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((7, 2.0, 2.5, -21.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((1, -1.0, 3.0, -25.0, 2.0, 2.0, 3.0, 1.5))
    platforms.push((4, -5.0, 3.5, -29.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((0, -2.0, 4.0, -33.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((3, 1.0, 4.5, -37.0, 2.0, 2.0, 3.0, 2.0))
    platforms.push((7, 4.0, 5.0, -41.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((0, 4.0, 5.5, -45.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((4, 1.0, 6.0, -49.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((0, 0.0, 6.5, -54.0, 3.0, 3.0, 0.0, 0.0))
  } else if level == 3 {
    // Flame Gauntlet - intense hazard level
    platforms.push((0, 0.0, 0.0, -4.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((4, 3.0, 0.5, -8.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((7, 6.0, 1.0, -12.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((0, 9.0, 1.5, -16.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((1, 6.0, 2.0, -20.0, 2.0, 2.0, 4.0, 2.5))
    platforms.push((4, 3.0, 2.5, -24.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((0, 0.0, 3.0, -28.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((7, -3.0, 3.5, -32.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((3, -6.0, 4.0, -36.0, 2.0, 2.0, 3.0, 2.0))
    platforms.push((0, -3.0, 5.0, -40.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((4, 0.0, 5.5, -44.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((7, 3.0, 6.0, -48.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((1, 6.0, 6.5, -52.0, 2.0, 2.0, 3.0, 2.0))
    platforms.push((0, 3.0, 7.0, -56.0, 3.0, 3.0, 0.0, 0.0))
  } else {
    // Volcano Summit - boss/challenge
    platforms.push((0, 0.0, 0.0, -4.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((4, 3.0, 1.0, -8.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((7, 6.0, 1.5, -12.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((1, 3.0, 2.0, -16.0, 2.0, 2.0, 4.0, 2.5))
    platforms.push((4, 0.0, 3.0, -20.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((0, -3.0, 4.0, -24.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((7, -6.0, 4.5, -28.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((3, -3.0, 5.0, -32.0, 2.0, 2.0, 4.0, 2.0))
    platforms.push((5, 0.0, 5.0, -36.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((0, 0.0, 8.0, -40.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((4, 3.0, 8.5, -44.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((7, 6.0, 9.0, -48.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((1, 3.0, 10.0, -52.0, 2.0, 2.0, 3.0, 2.5))
    platforms.push((0, 0.0, 11.0, -56.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((5, -3.0, 11.0, -60.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((0, -3.0, 14.0, -64.0, 3.0, 3.0, 0.0, 0.0))
  }
}

// ========== Sky World (World 3) ==========

///|
fn build_sky_level(
  platforms : Array[(Int, Float, Float, Float, Float, Float, Float, Float)],
  level : Int,
) -> Unit {
  if level == 0 {
    // Cloud Step - moving platforms focus
    platforms.push((0, 0.0, 0.0, -5.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((2, 3.0, 1.5, -9.0, 2.5, 2.5, 2.0, 1.0))
    platforms.push((0, 6.0, 3.0, -13.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((3, 3.0, 3.5, -18.0, 2.5, 2.5, 3.0, 1.5))
    platforms.push((0, 0.0, 4.0, -22.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((2, -3.0, 5.0, -26.0, 2.5, 2.5, 2.5, 1.0))
    platforms.push((0, -6.0, 7.0, -30.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((1, -3.0, 7.5, -34.0, 2.5, 2.5, 3.0, 2.0))
    platforms.push((0, 0.0, 8.0, -38.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((2, 3.0, 9.0, -42.0, 2.5, 2.5, 2.0, 1.0))
    platforms.push((0, 3.0, 11.0, -47.0, 3.0, 3.0, 0.0, 0.0))
  } else if level == 1 {
    // Wind Lifts - vertical moving platforms
    platforms.push((0, 0.0, 0.0, -5.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((2, 3.0, 2.0, -9.0, 2.5, 2.5, 3.0, 1.0))
    platforms.push((0, 3.0, 5.0, -14.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((2, 0.0, 6.0, -18.0, 2.0, 2.0, 3.0, 1.5))
    platforms.push((0, -3.0, 9.0, -22.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((2, -3.0, 10.0, -27.0, 2.5, 2.5, 4.0, 1.0))
    platforms.push((0, 0.0, 14.0, -31.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((1, 3.0, 14.5, -35.0, 2.5, 2.5, 3.0, 2.0))
    platforms.push((2, 6.0, 15.0, -39.0, 2.0, 2.0, 3.0, 1.0))
    platforms.push((0, 3.0, 18.0, -43.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((0, 0.0, 19.0, -48.0, 3.0, 3.0, 0.0, 0.0))
  } else if level == 2 {
    // Storm Bridges - moving + falling + ice
    platforms.push((0, 0.0, 0.0, -5.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((1, 4.0, 1.0, -9.0, 2.5, 2.5, 4.0, 2.0))
    platforms.push((4, 8.0, 2.0, -13.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((6, 5.0, 2.5, -17.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((3, 2.0, 3.0, -21.0, 2.0, 2.0, 4.0, 2.0))
    platforms.push((0, -2.0, 4.0, -26.0, 3.0, 3.0, 0.0, 0.0))
    platforms.push((2, -5.0, 5.0, -30.0, 2.0, 2.0, 3.0, 1.5))
    platforms.push((4, -5.0, 7.0, -34.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((0, -2.0, 8.0, -38.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((1, 1.0, 8.5, -42.0, 2.5, 2.5, 3.0, 2.0))
    platforms.push((7, 5.0, 9.0, -46.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((0, 2.0, 10.0, -50.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((0, 0.0, 10.5, -55.0, 3.0, 3.0, 0.0, 0.0))
  } else if level == 3 {
    // Lightning Run - everything combined, fast
    platforms.push((0, 0.0, 0.0, -4.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((1, 3.0, 1.0, -8.0, 2.0, 2.0, 4.0, 2.5))
    platforms.push((4, 7.0, 2.0, -12.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((5, 4.0, 2.0, -16.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((0, 4.0, 5.0, -20.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((3, 1.0, 5.5, -24.0, 2.0, 2.0, 4.0, 2.0))
    platforms.push((7, -2.0, 6.0, -28.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((2, -5.0, 7.0, -32.0, 2.0, 2.0, 3.0, 1.5))
    platforms.push((0, -5.0, 10.0, -36.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((1, -2.0, 10.5, -40.0, 2.0, 2.0, 3.0, 2.5))
    platforms.push((4, 2.0, 11.0, -44.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((5, 5.0, 11.0, -48.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((0, 5.0, 14.0, -52.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((3, 2.0, 14.5, -56.0, 2.0, 2.0, 4.0, 2.0))
    platforms.push((0, 0.0, 15.0, -61.0, 3.0, 3.0, 0.0, 0.0))
  } else {
    // Celestial Peak - final challenge level
    platforms.push((0, 0.0, 0.0, -4.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((2, 3.0, 2.0, -8.0, 2.0, 2.0, 3.0, 1.5))
    platforms.push((4, 3.0, 4.0, -12.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((1, 0.0, 5.0, -16.0, 2.0, 2.0, 4.0, 2.5))
    platforms.push((7, -4.0, 6.0, -20.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((5, -7.0, 6.0, -24.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((0, -7.0, 9.0, -28.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((3, -4.0, 9.5, -32.0, 2.0, 2.0, 4.0, 2.0))
    platforms.push((4, 0.0, 10.0, -36.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((2, 3.0, 11.0, -40.0, 2.0, 2.0, 3.0, 1.5))
    platforms.push((0, 3.0, 14.0, -44.0, 2.5, 2.5, 0.0, 0.0))
    platforms.push((1, 0.0, 15.0, -48.0, 2.0, 2.0, 4.0, 2.5))
    platforms.push((7, -4.0, 16.0, -52.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((5, -7.0, 16.0, -56.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((0, -7.0, 19.0, -60.0, 2.0, 2.0, 0.0, 0.0))
    platforms.push((2, -4.0, 20.0, -64.0, 2.0, 2.0, 3.0, 1.5))
    platforms.push((0, -4.0, 22.0, -69.0, 3.0, 3.0, 0.0, 0.0))
  }
}

// Collectible positions for a level

///|
pub fn get_collectible_data(
  world : Int,
  level : Int,
) -> Array[(Int, Float, Float, Float)] {
  let items : Array[(Int, Float, Float, Float)] = []
  let plats = get_platform_data(world, level)
  // Place gems on platforms and vary by world/level
  for i = 1; i < plats.length() - 1; i = i + 1 {
    let p = plats[i]
    // Gems on every 2nd or 3rd platform
    if i % 2 == 0 {
      items.push((0, p.1, p.2 + 1.5, p.3))
    }
    // Coins near some platforms
    if i % 3 == 1 {
      let coin_kind : Int = if level >= 3 {
        6
      } else if level >= 1 {
        5
      } else {
        4
      }
      items.push((coin_kind, p.1 + 1.0, p.2 + 1.2, p.3))
    }
    // Stars on every 6th platform
    if i % 6 == 0 {
      items.push((1, p.1, p.2 + 2.0, p.3))
    }
    // Life pickup in harder levels
    if level >= 3 && i % 8 == 4 {
      items.push((2, p.1, p.2 + 1.8, p.3))
    }
    ignore(i)
  }
  ignore(world)
  items
}

// Enemy data for a level
// Returns array of (kind, x, y, z, patrol_range)

///|
pub fn get_enemy_data(
  world : Int,
  level : Int,
) -> Array[(Int, Float, Float, Float, Float)] {
  let enemies : Array[(Int, Float, Float, Float, Float)] = []
  let plats = get_platform_data(world, level)
  // Enemies start appearing from level 1 onwards
  if level == 0 {
    return enemies
  }
  for i = 2; i < plats.length() - 2; i = i + 1 {
    let p = plats[i]
    // Patrol enemies on wider static platforms
    if p.0 == 0 && p.4 >= 2.5 && i % 4 == 2 {
      enemies.push((0, p.1, p.2 + 0.8, p.3, p.4 * 0.4))
    }
    // Bouncing enemies in lava world
    if world == 2 && i % 5 == 3 && p.0 == 0 {
      enemies.push((1, p.1, p.2 + 1.5, p.3, 0.0))
    }
    // Flying enemies in sky world
    if world == 3 && i % 4 == 1 {
      enemies.push((2, p.1, p.2 + 3.0, p.3, 3.0))
    }
    // Chase enemies in later levels
    if level >= 3 && i % 6 == 5 && p.0 == 0 {
      enemies.push((3, p.1, p.2 + 0.8, p.3, 0.0))
    }
    // Turret enemies in sky world level 3+
    if world == 3 && level >= 2 && i % 7 == 0 && p.0 == 0 {
      enemies.push((4, p.1, p.2 + 0.8, p.3, 0.0))
    }
    ignore(i)
  }
  enemies
}

// Hazard data for a level
// Returns array of (kind, x, y, z, w, h, d)

///|
pub fn get_hazard_data(
  world : Int,
  level : Int,
) -> Array[(Int, Float, Float, Float, Float, Float, Float)] {
  let hazards : Array[(Int, Float, Float, Float, Float, Float, Float)] = []
  let plats = get_platform_data(world, level)
  // Place hazards between platforms where gaps exist
  for i = 1; i < plats.length() - 1; i = i + 1 {
    let p = plats[i]
    // Spikes on ground in forest world
    if world == 0 && level >= 2 && i % 5 == 3 {
      hazards.push((0, p.1 + 1.5, p.2 + 0.5, p.3, 0.8, 0.6, 0.8))
    }
    // Lava pools in lava world
    if world == 2 && i % 3 == 1 && p.0 == 0 {
      let next_idx = i + 1
      if next_idx < plats.length() {
        let np = plats[next_idx]
        let mx : Float = (p.1 + np.1) * 0.5
        let mz : Float = (p.3 + np.3) * 0.5
        let min_y : Float = if p.2 < np.2 { p.2 } else { np.2 }
        let my : Float = min_y - 1.0
        hazards.push((1, mx, my, mz, 3.0, 0.3, 3.0))
      }
    }
    // Saw blades in crystal world
    if world == 1 && level >= 2 && i % 4 == 2 {
      hazards.push((2, p.1 + 2.0, p.2 + 1.0, p.3, 1.2, 0.3, 1.2))
    }
    // Fire jets in lava world
    if world == 2 && level >= 3 && i % 5 == 0 {
      hazards.push((4, p.1, p.2 + 0.5, p.3 + 1.5, 0.5, 2.0, 0.5))
    }
    // Pendulums in sky world
    if world == 3 && level >= 2 && i % 5 == 2 {
      hazards.push((5, p.1, p.2 + 2.5, p.3, 0.6, 0.6, 0.6))
    }
    ignore(i)
  }
  hazards
}

// Power-up data for a level
// Returns array of (kind, x, y, z)

///|
pub fn get_powerup_data(
  world : Int,
  level : Int,
) -> Array[(Int, Float, Float, Float)] {
  let powerups : Array[(Int, Float, Float, Float)] = []
  let plats = get_platform_data(world, level)
  // One power-up per level, placed on a platform roughly 40% through
  let pu_idx = plats.length() * 2 / 5
  if pu_idx > 0 && pu_idx < plats.length() {
    let p = plats[pu_idx]
    let kind : Int = if world == 0 {
      0
    } else if world == 1 {
      1
    } else if world == 2 {
      2
    } else {
      4
    }
    powerups.push((kind, p.1, p.2 + 2.0, p.3))
  }
  // Second power-up for levels 3+
  if level >= 3 {
    let pu_idx2 = plats.length() * 3 / 4
    if pu_idx2 > 0 && pu_idx2 < plats.length() {
      let p2 = plats[pu_idx2]
      let kind2 : Int = if world == 0 {
        1
      } else if world == 1 {
        2
      } else if world == 2 {
        0
      } else {
        3
      }
      powerups.push((kind2, p2.1, p2.2 + 2.0, p2.3))
    }
  }
  powerups
}

// Decoration data for a level
// Returns array of (kind, x, y, z, scale)

///|
pub fn get_decoration_data(
  world : Int,
  level : Int,
) -> Array[(Int, Float, Float, Float, Float)] {
  let decos : Array[(Int, Float, Float, Float, Float)] = []
  let plats = get_platform_data(world, level)
  for i = 0; i < plats.length(); i = i + 1 {
    let p = plats[i]
    // Only decorate static platforms
    if p.0 != 0 {
      continue i + 1
    }
    let y_top = p.2 + 0.15
    if world == 0 {
      // Forest: trees and bushes
      if i % 3 == 0 && p.4 >= 2.5 {
        decos.push((0, p.1 + p.4 * 0.3, y_top, p.3 + p.5 * 0.3, 1.0))
      }
      if i % 2 == 1 {
        decos.push((8, p.1 - p.4 * 0.2, y_top, p.3 - p.5 * 0.2, 0.6))
      }
      if i % 5 == 0 {
        decos.push((3, p.1 + 0.5, y_top, p.3 - 0.5, 0.5))
      }
    } else if world == 1 {
      // Crystal: crystals and stalagmites
      if i % 3 == 0 {
        decos.push((2, p.1 + p.4 * 0.3, y_top, p.3, 0.8))
      }
      if i % 4 == 1 {
        decos.push((5, p.1 - 0.5, y_top, p.3 + 0.5, 0.7))
      }
      if i % 5 == 2 {
        decos.push((9, p.1, y_top, p.3 - p.5 * 0.3, 0.5))
      }
    } else if world == 2 {
      // Lava: rocks and lava rocks
      if i % 3 == 0 {
        decos.push((1, p.1 + p.4 * 0.2, y_top, p.3, 0.8))
      }
      if i % 4 == 1 {
        decos.push((6, p.1 - 0.3, y_top, p.3 + 0.3, 0.6))
      }
    } else {
      // Sky: pillars and clouds
      if i % 3 == 0 && p.4 >= 2.5 {
        decos.push((4, p.1, y_top, p.3 + p.5 * 0.3, 1.0))
      }
      if i % 2 == 1 {
        decos.push((7, p.1 + 2.0, p.2 + 3.0, p.3, 1.5))
      }
    }
    ignore(i)
  }
  ignore(level)
  decos
}

// Goal position (last platform)

///|
pub fn get_goal_position(world : Int, level : Int) -> (Float, Float, Float) {
  let plats = get_platform_data(world, level)
  let last = plats[plats.length() - 1]
  (last.1, last.2 + 1.0, last.3)
}

// Get level difficulty rating (1-5)

///|
pub fn get_level_difficulty(world : Int, level : Int) -> Int {
  let base : Int = world + 1
  let lvl_add : Int = level / 2
  let v = base + lvl_add
  if v < 1 {
    1
  } else if v > 5 {
    5
  } else {
    v
  }
}

// Check if a level should have a key requirement

///|
pub fn level_has_key(world : Int, level : Int) -> Bool {
  level == 4 && world >= 1
}

// Get recommended star count to unlock a world

///|
pub fn world_unlock_stars(world : Int) -> Int {
  if world == 0 {
    0
  } else if world == 1 {
    5
  } else if world == 2 {
    12
  } else {
    20
  }
}
