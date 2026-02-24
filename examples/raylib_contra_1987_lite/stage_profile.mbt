///|
struct StageProfile {
  title : String
  subtitle : String
  enemy_bonus : Int
  spawn_scale : Float
  drop_bonus : Int
  sky_top : @raylib.Color
  sky_bottom : @raylib.Color
  fog_alpha : Float
  ui_accent : @raylib.Color
}

///|
fn StageProfile::new(
  title : String,
  subtitle : String,
  enemy_bonus : Int,
  spawn_scale : Float,
  drop_bonus : Int,
  sky_top : @raylib.Color,
  sky_bottom : @raylib.Color,
  fog_alpha : Float,
  ui_accent : @raylib.Color,
) -> StageProfile {
  {
    title,
    subtitle,
    enemy_bonus,
    spawn_scale,
    drop_bonus,
    sky_top,
    sky_bottom,
    fog_alpha,
    ui_accent,
  }
}

///|
fn default_stage_profile() -> StageProfile {
  StageProfile::new(
    "Border Skirmish",
    "Standard armored engagement",
    0,
    1.0,
    0,
    @raylib.Color::new(14, 20, 31, 255),
    @raylib.Color::new(8, 10, 15, 255),
    0.06,
    @raylib.gold,
  )
}

///|
fn get_stage_profile(index : Int) -> StageProfile {
  match index % level_count {
    0 =>
      StageProfile::new(
        "Rust Outpost",
        "Hostile armor columns detected",
        1,
        Float::from_int(112) / 100.0,
        -2,
        @raylib.Color::new(30, 42, 70, 255),
        @raylib.Color::new(15, 21, 35, 255),
        Float::from_int(5) / 100.0,
        @raylib.Color::new(120, 160, 120, 255),
      )
    1 =>
      StageProfile::new(
        "Neon Outpost",
        "Fortify routes and hold pressure",
        0,
        Float::from_int(112) / 100.0,
        -1,
        @raylib.Color::new(35, 49, 81, 255),
        @raylib.Color::new(17, 24, 40, 255),
        Float::from_int(6) / 100.0,
        @raylib.Color::new(129, 173, 137, 255),
      )
    2 =>
      StageProfile::new(
        "Frost Bastion",
        "Enemy scouts probing weak lanes",
        0,
        Float::from_int(112) / 100.0,
        0,
        @raylib.Color::new(40, 56, 92, 255),
        @raylib.Color::new(20, 28, 46, 255),
        Float::from_int(7) / 100.0,
        @raylib.Color::new(138, 186, 154, 255),
      )
    3 =>
      StageProfile::new(
        "Ember Bastion",
        "Heavy units entering from north",
        1,
        Float::from_int(111) / 100.0,
        1,
        @raylib.Color::new(45, 63, 103, 255),
        @raylib.Color::new(22, 31, 51, 255),
        Float::from_int(8) / 100.0,
        @raylib.Color::new(147, 199, 171, 255),
      )
    4 =>
      StageProfile::new(
        "Shadow Delta",
        "Fogged battlefield, short visibility",
        0,
        Float::from_int(111) / 100.0,
        2,
        @raylib.Color::new(50, 70, 114, 255),
        @raylib.Color::new(25, 35, 57, 255),
        Float::from_int(9) / 100.0,
        @raylib.Color::new(156, 92, 68, 255),
      )
    5 =>
      StageProfile::new(
        "Storm Delta",
        "Expect fast flanking squads",
        0,
        Float::from_int(111) / 100.0,
        3,
        @raylib.Color::new(55, 77, 125, 255),
        @raylib.Color::new(27, 38, 62, 255),
        Float::from_int(10) / 100.0,
        @raylib.Color::new(165, 105, 85, 255),
      )
    6 =>
      StageProfile::new(
        "Echo Citadel",
        "Breakthrough attempt in progress",
        1,
        Float::from_int(110) / 100.0,
        4,
        @raylib.Color::new(60, 84, 136, 255),
        @raylib.Color::new(30, 42, 68, 255),
        Float::from_int(11) / 100.0,
        @raylib.Color::new(174, 118, 102, 255),
      )
    7 =>
      StageProfile::new(
        "Iron Citadel",
        "Hold the line around command base",
        0,
        Float::from_int(110) / 100.0,
        -2,
        @raylib.Color::new(65, 91, 147, 255),
        @raylib.Color::new(32, 45, 73, 255),
        Float::from_int(12) / 100.0,
        @raylib.Color::new(183, 131, 119, 255),
      )
    8 =>
      StageProfile::new(
        "Azure Depot",
        "Sniper platoon deployment confirmed",
        1,
        Float::from_int(110) / 100.0,
        -1,
        @raylib.Color::new(70, 98, 38, 255),
        @raylib.Color::new(35, 49, 19, 255),
        Float::from_int(5) / 100.0,
        @raylib.Color::new(192, 144, 136, 255),
      )
    9 =>
      StageProfile::new(
        "Dust Depot",
        "Salvage crews report minefields",
        2,
        Float::from_int(109) / 100.0,
        0,
        @raylib.Color::new(75, 105, 49, 255),
        @raylib.Color::new(37, 52, 24, 255),
        Float::from_int(6) / 100.0,
        @raylib.Color::new(201, 157, 153, 255),
      )
    10 =>
      StageProfile::new(
        "Rust Crossing",
        "Recon drones indicate mixed armor",
        1,
        Float::from_int(109) / 100.0,
        1,
        @raylib.Color::new(80, 112, 60, 255),
        @raylib.Color::new(40, 56, 30, 255),
        Float::from_int(7) / 100.0,
        @raylib.Color::new(210, 170, 170, 255),
      )
    11 =>
      StageProfile::new(
        "Neon Crossing",
        "Prepare for prolonged engagement",
        1,
        Float::from_int(109) / 100.0,
        2,
        @raylib.Color::new(85, 19, 71, 255),
        @raylib.Color::new(42, 9, 35, 255),
        Float::from_int(8) / 100.0,
        @raylib.Color::new(219, 183, 67, 255),
      )
    12 =>
      StageProfile::new(
        "Frost Relay",
        "Hostile armor columns detected",
        2,
        Float::from_int(108) / 100.0,
        3,
        @raylib.Color::new(90, 26, 82, 255),
        @raylib.Color::new(45, 13, 41, 255),
        Float::from_int(9) / 100.0,
        @raylib.Color::new(228, 196, 84, 255),
      )
    13 =>
      StageProfile::new(
        "Ember Relay",
        "Fortify routes and hold pressure",
        1,
        Float::from_int(108) / 100.0,
        4,
        @raylib.Color::new(95, 33, 93, 255),
        @raylib.Color::new(47, 16, 46, 255),
        Float::from_int(10) / 100.0,
        @raylib.Color::new(237, 89, 101, 255),
      )
    14 =>
      StageProfile::new(
        "Shadow Keep",
        "Enemy scouts probing weak lanes",
        1,
        Float::from_int(108) / 100.0,
        -2,
        @raylib.Color::new(100, 40, 104, 255),
        @raylib.Color::new(50, 20, 52, 255),
        Float::from_int(11) / 100.0,
        @raylib.Color::new(126, 102, 118, 255),
      )
    15 =>
      StageProfile::new(
        "Storm Keep",
        "Heavy units entering from north",
        2,
        Float::from_int(107) / 100.0,
        -1,
        @raylib.Color::new(15, 47, 115, 255),
        @raylib.Color::new(7, 23, 57, 255),
        Float::from_int(12) / 100.0,
        @raylib.Color::new(135, 115, 135, 255),
      )
    16 =>
      StageProfile::new(
        "Echo Trench",
        "Fogged battlefield, short visibility",
        2,
        Float::from_int(107) / 100.0,
        0,
        @raylib.Color::new(20, 54, 126, 255),
        @raylib.Color::new(10, 27, 63, 255),
        Float::from_int(5) / 100.0,
        @raylib.Color::new(144, 128, 152, 255),
      )
    17 =>
      StageProfile::new(
        "Iron Trench",
        "Expect fast flanking squads",
        2,
        Float::from_int(107) / 100.0,
        1,
        @raylib.Color::new(25, 61, 137, 255),
        @raylib.Color::new(12, 30, 68, 255),
        Float::from_int(6) / 100.0,
        @raylib.Color::new(153, 141, 169, 255),
      )
    18 =>
      StageProfile::new(
        "Azure Station",
        "Breakthrough attempt in progress",
        3,
        Float::from_int(106) / 100.0,
        2,
        @raylib.Color::new(30, 68, 148, 255),
        @raylib.Color::new(15, 34, 74, 255),
        Float::from_int(7) / 100.0,
        @raylib.Color::new(162, 154, 66, 255),
      )
    19 =>
      StageProfile::new(
        "Dust Station",
        "Hold the line around command base",
        2,
        Float::from_int(106) / 100.0,
        3,
        @raylib.Color::new(35, 75, 39, 255),
        @raylib.Color::new(17, 37, 19, 255),
        Float::from_int(8) / 100.0,
        @raylib.Color::new(171, 167, 83, 255),
      )
    20 =>
      StageProfile::new(
        "Rust Junction",
        "Sniper platoon deployment confirmed",
        2,
        Float::from_int(106) / 100.0,
        4,
        @raylib.Color::new(40, 82, 50, 255),
        @raylib.Color::new(20, 41, 25, 255),
        Float::from_int(9) / 100.0,
        @raylib.Color::new(180, 180, 100, 255),
      )
    21 =>
      StageProfile::new(
        "Neon Junction",
        "Salvage crews report minefields",
        3,
        Float::from_int(105) / 100.0,
        -2,
        @raylib.Color::new(45, 89, 61, 255),
        @raylib.Color::new(22, 44, 30, 255),
        Float::from_int(10) / 100.0,
        @raylib.Color::new(189, 193, 117, 255),
      )
    22 =>
      StageProfile::new(
        "Frost Frontline",
        "Recon drones indicate mixed armor",
        2,
        Float::from_int(105) / 100.0,
        -1,
        @raylib.Color::new(50, 96, 72, 255),
        @raylib.Color::new(25, 48, 36, 255),
        Float::from_int(11) / 100.0,
        @raylib.Color::new(198, 86, 134, 255),
      )
    23 =>
      StageProfile::new(
        "Ember Frontline",
        "Prepare for prolonged engagement",
        2,
        Float::from_int(105) / 100.0,
        0,
        @raylib.Color::new(55, 103, 83, 255),
        @raylib.Color::new(27, 51, 41, 255),
        Float::from_int(12) / 100.0,
        @raylib.Color::new(207, 99, 151, 255),
      )
    24 =>
      StageProfile::new(
        "Shadow Watchpoint",
        "Hostile armor columns detected",
        4,
        Float::from_int(104) / 100.0,
        1,
        @raylib.Color::new(60, 110, 94, 255),
        @raylib.Color::new(30, 55, 47, 255),
        Float::from_int(5) / 100.0,
        @raylib.Color::new(216, 112, 168, 255),
      )
    25 =>
      StageProfile::new(
        "Storm Watchpoint",
        "Fortify routes and hold pressure",
        3,
        Float::from_int(104) / 100.0,
        2,
        @raylib.Color::new(65, 117, 105, 255),
        @raylib.Color::new(32, 58, 52, 255),
        Float::from_int(6) / 100.0,
        @raylib.Color::new(225, 125, 65, 255),
      )
    26 =>
      StageProfile::new(
        "Echo Arsenal",
        "Enemy scouts probing weak lanes",
        3,
        Float::from_int(104) / 100.0,
        3,
        @raylib.Color::new(70, 24, 116, 255),
        @raylib.Color::new(35, 12, 58, 255),
        Float::from_int(7) / 100.0,
        @raylib.Color::new(234, 138, 82, 255),
      )
    27 =>
      StageProfile::new(
        "Iron Arsenal",
        "Heavy units entering from north",
        4,
        Float::from_int(103) / 100.0,
        4,
        @raylib.Color::new(75, 31, 127, 255),
        @raylib.Color::new(37, 15, 63, 255),
        Float::from_int(8) / 100.0,
        @raylib.Color::new(123, 151, 99, 255),
      )
    28 =>
      StageProfile::new(
        "Azure Outpost",
        "Fogged battlefield, short visibility",
        3,
        Float::from_int(103) / 100.0,
        -2,
        @raylib.Color::new(80, 38, 138, 255),
        @raylib.Color::new(40, 19, 69, 255),
        Float::from_int(9) / 100.0,
        @raylib.Color::new(132, 164, 116, 255),
      )
    29 =>
      StageProfile::new(
        "Dust Outpost",
        "Expect fast flanking squads",
        3,
        Float::from_int(103) / 100.0,
        -1,
        @raylib.Color::new(85, 45, 149, 255),
        @raylib.Color::new(42, 22, 74, 255),
        Float::from_int(10) / 100.0,
        @raylib.Color::new(141, 177, 133, 255),
      )
    30 =>
      StageProfile::new(
        "Rust Bastion",
        "Breakthrough attempt in progress",
        4,
        Float::from_int(102) / 100.0,
        0,
        @raylib.Color::new(90, 52, 40, 255),
        @raylib.Color::new(45, 26, 20, 255),
        Float::from_int(11) / 100.0,
        @raylib.Color::new(150, 190, 150, 255),
      )
    31 =>
      StageProfile::new(
        "Neon Bastion",
        "Hold the line around command base",
        3,
        Float::from_int(102) / 100.0,
        1,
        @raylib.Color::new(95, 59, 51, 255),
        @raylib.Color::new(47, 29, 25, 255),
        Float::from_int(12) / 100.0,
        @raylib.Color::new(159, 83, 167, 255),
      )
    32 =>
      StageProfile::new(
        "Frost Delta",
        "Sniper platoon deployment confirmed",
        4,
        Float::from_int(102) / 100.0,
        2,
        @raylib.Color::new(100, 66, 62, 255),
        @raylib.Color::new(50, 33, 31, 255),
        Float::from_int(5) / 100.0,
        @raylib.Color::new(168, 96, 64, 255),
      )
    33 =>
      StageProfile::new(
        "Ember Delta",
        "Salvage crews report minefields",
        5,
        Float::from_int(101) / 100.0,
        3,
        @raylib.Color::new(15, 73, 73, 255),
        @raylib.Color::new(7, 36, 36, 255),
        Float::from_int(6) / 100.0,
        @raylib.Color::new(177, 109, 81, 255),
      )
    34 =>
      StageProfile::new(
        "Shadow Citadel",
        "Recon drones indicate mixed armor",
        4,
        Float::from_int(101) / 100.0,
        4,
        @raylib.Color::new(20, 80, 84, 255),
        @raylib.Color::new(10, 40, 42, 255),
        Float::from_int(7) / 100.0,
        @raylib.Color::new(186, 122, 98, 255),
      )
    35 =>
      StageProfile::new(
        "Storm Citadel",
        "Prepare for prolonged engagement",
        4,
        Float::from_int(101) / 100.0,
        -2,
        @raylib.Color::new(25, 87, 95, 255),
        @raylib.Color::new(12, 43, 47, 255),
        Float::from_int(8) / 100.0,
        @raylib.Color::new(195, 135, 115, 255),
      )
    36 =>
      StageProfile::new(
        "Echo Depot",
        "Hostile armor columns detected",
        5,
        Float::from_int(100) / 100.0,
        -1,
        @raylib.Color::new(30, 94, 106, 255),
        @raylib.Color::new(15, 47, 53, 255),
        Float::from_int(9) / 100.0,
        @raylib.Color::new(204, 148, 132, 255),
      )
    37 =>
      StageProfile::new(
        "Iron Depot",
        "Fortify routes and hold pressure",
        4,
        Float::from_int(100) / 100.0,
        0,
        @raylib.Color::new(35, 101, 117, 255),
        @raylib.Color::new(17, 50, 58, 255),
        Float::from_int(10) / 100.0,
        @raylib.Color::new(213, 161, 149, 255),
      )
    38 =>
      StageProfile::new(
        "Azure Crossing",
        "Enemy scouts probing weak lanes",
        4,
        Float::from_int(100) / 100.0,
        1,
        @raylib.Color::new(40, 108, 128, 255),
        @raylib.Color::new(20, 54, 64, 255),
        Float::from_int(11) / 100.0,
        @raylib.Color::new(222, 174, 166, 255),
      )
    39 =>
      StageProfile::new(
        "Dust Crossing",
        "Heavy units entering from north",
        5,
        Float::from_int(99) / 100.0,
        2,
        @raylib.Color::new(45, 115, 139, 255),
        @raylib.Color::new(22, 57, 69, 255),
        Float::from_int(12) / 100.0,
        @raylib.Color::new(231, 187, 63, 255),
      )
    40 =>
      StageProfile::new(
        "Rust Relay",
        "Fogged battlefield, short visibility",
        5,
        Float::from_int(99) / 100.0,
        3,
        @raylib.Color::new(50, 22, 30, 255),
        @raylib.Color::new(25, 11, 15, 255),
        Float::from_int(5) / 100.0,
        @raylib.Color::new(120, 80, 80, 255),
      )
    41 =>
      StageProfile::new(
        "Neon Relay",
        "Expect fast flanking squads",
        5,
        Float::from_int(99) / 100.0,
        4,
        @raylib.Color::new(55, 29, 41, 255),
        @raylib.Color::new(27, 14, 20, 255),
        Float::from_int(6) / 100.0,
        @raylib.Color::new(129, 93, 97, 255),
      )
    42 =>
      StageProfile::new(
        "Frost Keep",
        "Breakthrough attempt in progress",
        6,
        Float::from_int(98) / 100.0,
        -2,
        @raylib.Color::new(60, 36, 52, 255),
        @raylib.Color::new(30, 18, 26, 255),
        Float::from_int(7) / 100.0,
        @raylib.Color::new(138, 106, 114, 255),
      )
    43 =>
      StageProfile::new(
        "Ember Keep",
        "Hold the line around command base",
        5,
        Float::from_int(98) / 100.0,
        -1,
        @raylib.Color::new(65, 43, 63, 255),
        @raylib.Color::new(32, 21, 31, 255),
        Float::from_int(8) / 100.0,
        @raylib.Color::new(147, 119, 131, 255),
      )
    44 =>
      StageProfile::new(
        "Shadow Trench",
        "Sniper platoon deployment confirmed",
        5,
        Float::from_int(98) / 100.0,
        0,
        @raylib.Color::new(70, 50, 74, 255),
        @raylib.Color::new(35, 25, 37, 255),
        Float::from_int(9) / 100.0,
        @raylib.Color::new(156, 132, 148, 255),
      )
    45 =>
      StageProfile::new(
        "Storm Trench",
        "Salvage crews report minefields",
        6,
        Float::from_int(97) / 100.0,
        1,
        @raylib.Color::new(75, 57, 85, 255),
        @raylib.Color::new(37, 28, 42, 255),
        Float::from_int(10) / 100.0,
        @raylib.Color::new(165, 145, 165, 255),
      )
    46 =>
      StageProfile::new(
        "Echo Station",
        "Recon drones indicate mixed armor",
        5,
        Float::from_int(97) / 100.0,
        2,
        @raylib.Color::new(80, 64, 96, 255),
        @raylib.Color::new(40, 32, 48, 255),
        Float::from_int(11) / 100.0,
        @raylib.Color::new(174, 158, 62, 255),
      )
    47 =>
      StageProfile::new(
        "Iron Station",
        "Prepare for prolonged engagement",
        5,
        Float::from_int(97) / 100.0,
        3,
        @raylib.Color::new(85, 71, 107, 255),
        @raylib.Color::new(42, 35, 53, 255),
        Float::from_int(12) / 100.0,
        @raylib.Color::new(183, 171, 79, 255),
      )
    48 =>
      StageProfile::new(
        "Azure Junction",
        "Hostile armor columns detected",
        7,
        Float::from_int(96) / 100.0,
        4,
        @raylib.Color::new(90, 78, 118, 255),
        @raylib.Color::new(45, 39, 59, 255),
        Float::from_int(5) / 100.0,
        @raylib.Color::new(192, 184, 96, 255),
      )
    49 =>
      StageProfile::new(
        "Dust Junction",
        "Fortify routes and hold pressure",
        6,
        Float::from_int(96) / 100.0,
        -2,
        @raylib.Color::new(95, 85, 129, 255),
        @raylib.Color::new(47, 42, 64, 255),
        Float::from_int(6) / 100.0,
        @raylib.Color::new(201, 197, 113, 255),
      )
    50 =>
      StageProfile::new(
        "Rust Frontline",
        "Enemy scouts probing weak lanes",
        6,
        Float::from_int(96) / 100.0,
        -1,
        @raylib.Color::new(100, 92, 140, 255),
        @raylib.Color::new(50, 46, 70, 255),
        Float::from_int(7) / 100.0,
        @raylib.Color::new(210, 90, 130, 255),
      )
    51 =>
      StageProfile::new(
        "Neon Frontline",
        "Heavy units entering from north",
        7,
        Float::from_int(95) / 100.0,
        0,
        @raylib.Color::new(15, 99, 31, 255),
        @raylib.Color::new(7, 49, 15, 255),
        Float::from_int(8) / 100.0,
        @raylib.Color::new(219, 103, 147, 255),
      )
    52 =>
      StageProfile::new(
        "Frost Watchpoint",
        "Fogged battlefield, short visibility",
        6,
        Float::from_int(95) / 100.0,
        1,
        @raylib.Color::new(20, 106, 42, 255),
        @raylib.Color::new(10, 53, 21, 255),
        Float::from_int(9) / 100.0,
        @raylib.Color::new(228, 116, 164, 255),
      )
    53 =>
      StageProfile::new(
        "Ember Watchpoint",
        "Expect fast flanking squads",
        6,
        Float::from_int(95) / 100.0,
        2,
        @raylib.Color::new(25, 113, 53, 255),
        @raylib.Color::new(12, 56, 26, 255),
        Float::from_int(10) / 100.0,
        @raylib.Color::new(237, 129, 61, 255),
      )
    54 =>
      StageProfile::new(
        "Shadow Arsenal",
        "Breakthrough attempt in progress",
        7,
        Float::from_int(94) / 100.0,
        3,
        @raylib.Color::new(30, 20, 64, 255),
        @raylib.Color::new(15, 10, 32, 255),
        Float::from_int(11) / 100.0,
        @raylib.Color::new(126, 142, 78, 255),
      )
    55 =>
      StageProfile::new(
        "Storm Arsenal",
        "Hold the line around command base",
        6,
        Float::from_int(94) / 100.0,
        4,
        @raylib.Color::new(35, 27, 75, 255),
        @raylib.Color::new(17, 13, 37, 255),
        Float::from_int(12) / 100.0,
        @raylib.Color::new(135, 155, 95, 255),
      )
    56 =>
      StageProfile::new(
        "Echo Outpost",
        "Sniper platoon deployment confirmed",
        7,
        Float::from_int(94) / 100.0,
        -2,
        @raylib.Color::new(40, 34, 86, 255),
        @raylib.Color::new(20, 17, 43, 255),
        Float::from_int(5) / 100.0,
        @raylib.Color::new(144, 168, 112, 255),
      )
    57 =>
      StageProfile::new(
        "Iron Outpost",
        "Salvage crews report minefields",
        8,
        Float::from_int(93) / 100.0,
        -1,
        @raylib.Color::new(45, 41, 97, 255),
        @raylib.Color::new(22, 20, 48, 255),
        Float::from_int(6) / 100.0,
        @raylib.Color::new(153, 181, 129, 255),
      )
    58 =>
      StageProfile::new(
        "Azure Bastion",
        "Recon drones indicate mixed armor",
        7,
        Float::from_int(93) / 100.0,
        0,
        @raylib.Color::new(50, 48, 108, 255),
        @raylib.Color::new(25, 24, 54, 255),
        Float::from_int(7) / 100.0,
        @raylib.Color::new(162, 194, 146, 255),
      )
    59 =>
      StageProfile::new(
        "Dust Bastion",
        "Prepare for prolonged engagement",
        7,
        Float::from_int(93) / 100.0,
        1,
        @raylib.Color::new(55, 55, 119, 255),
        @raylib.Color::new(27, 27, 59, 255),
        Float::from_int(8) / 100.0,
        @raylib.Color::new(171, 87, 163, 255),
      )
    60 =>
      StageProfile::new(
        "Rust Delta",
        "Hostile armor columns detected",
        8,
        Float::from_int(92) / 100.0,
        2,
        @raylib.Color::new(60, 62, 130, 255),
        @raylib.Color::new(30, 31, 65, 255),
        Float::from_int(9) / 100.0,
        @raylib.Color::new(180, 100, 60, 255),
      )
    61 =>
      StageProfile::new(
        "Neon Delta",
        "Fortify routes and hold pressure",
        7,
        Float::from_int(92) / 100.0,
        3,
        @raylib.Color::new(65, 69, 141, 255),
        @raylib.Color::new(32, 34, 70, 255),
        Float::from_int(10) / 100.0,
        @raylib.Color::new(189, 113, 77, 255),
      )
    62 =>
      StageProfile::new(
        "Frost Citadel",
        "Enemy scouts probing weak lanes",
        7,
        Float::from_int(92) / 100.0,
        4,
        @raylib.Color::new(70, 76, 32, 255),
        @raylib.Color::new(35, 38, 16, 255),
        Float::from_int(11) / 100.0,
        @raylib.Color::new(198, 126, 94, 255),
      )
    63 =>
      StageProfile::new(
        "Ember Citadel",
        "Heavy units entering from north",
        8,
        Float::from_int(91) / 100.0,
        -2,
        @raylib.Color::new(75, 83, 43, 255),
        @raylib.Color::new(37, 41, 21, 255),
        Float::from_int(12) / 100.0,
        @raylib.Color::new(207, 139, 111, 255),
      )
    64 =>
      StageProfile::new(
        "Shadow Depot",
        "Fogged battlefield, short visibility",
        8,
        Float::from_int(91) / 100.0,
        -1,
        @raylib.Color::new(80, 90, 54, 255),
        @raylib.Color::new(40, 45, 27, 255),
        Float::from_int(5) / 100.0,
        @raylib.Color::new(216, 152, 128, 255),
      )
    65 =>
      StageProfile::new(
        "Storm Depot",
        "Expect fast flanking squads",
        8,
        Float::from_int(91) / 100.0,
        0,
        @raylib.Color::new(85, 97, 65, 255),
        @raylib.Color::new(42, 48, 32, 255),
        Float::from_int(6) / 100.0,
        @raylib.Color::new(225, 165, 145, 255),
      )
    66 =>
      StageProfile::new(
        "Echo Crossing",
        "Breakthrough attempt in progress",
        9,
        Float::from_int(90) / 100.0,
        1,
        @raylib.Color::new(90, 104, 76, 255),
        @raylib.Color::new(45, 52, 38, 255),
        Float::from_int(7) / 100.0,
        @raylib.Color::new(234, 178, 162, 255),
      )
    67 =>
      StageProfile::new(
        "Iron Crossing",
        "Hold the line around command base",
        8,
        Float::from_int(90) / 100.0,
        2,
        @raylib.Color::new(95, 111, 87, 255),
        @raylib.Color::new(47, 55, 43, 255),
        Float::from_int(8) / 100.0,
        @raylib.Color::new(123, 191, 179, 255),
      )
    68 =>
      StageProfile::new(
        "Azure Relay",
        "Sniper platoon deployment confirmed",
        8,
        Float::from_int(90) / 100.0,
        3,
        @raylib.Color::new(100, 18, 98, 255),
        @raylib.Color::new(50, 9, 49, 255),
        Float::from_int(9) / 100.0,
        @raylib.Color::new(132, 84, 76, 255),
      )
    69 =>
      StageProfile::new(
        "Dust Relay",
        "Salvage crews report minefields",
        9,
        Float::from_int(89) / 100.0,
        4,
        @raylib.Color::new(15, 25, 109, 255),
        @raylib.Color::new(7, 12, 54, 255),
        Float::from_int(10) / 100.0,
        @raylib.Color::new(141, 97, 93, 255),
      )
    70 =>
      StageProfile::new(
        "Rust Keep",
        "Recon drones indicate mixed armor",
        8,
        Float::from_int(89) / 100.0,
        -2,
        @raylib.Color::new(20, 32, 120, 255),
        @raylib.Color::new(10, 16, 60, 255),
        Float::from_int(11) / 100.0,
        @raylib.Color::new(150, 110, 110, 255),
      )
    71 =>
      StageProfile::new(
        "Neon Keep",
        "Prepare for prolonged engagement",
        8,
        Float::from_int(89) / 100.0,
        -1,
        @raylib.Color::new(25, 39, 131, 255),
        @raylib.Color::new(12, 19, 65, 255),
        Float::from_int(12) / 100.0,
        @raylib.Color::new(159, 123, 127, 255),
      )
    72 =>
      StageProfile::new(
        "Frost Trench",
        "Hostile armor columns detected",
        10,
        Float::from_int(88) / 100.0,
        0,
        @raylib.Color::new(30, 46, 142, 255),
        @raylib.Color::new(15, 23, 71, 255),
        Float::from_int(5) / 100.0,
        @raylib.Color::new(168, 136, 144, 255),
      )
    73 =>
      StageProfile::new(
        "Ember Trench",
        "Fortify routes and hold pressure",
        9,
        Float::from_int(88) / 100.0,
        1,
        @raylib.Color::new(35, 53, 33, 255),
        @raylib.Color::new(17, 26, 16, 255),
        Float::from_int(6) / 100.0,
        @raylib.Color::new(177, 149, 161, 255),
      )
    74 =>
      StageProfile::new(
        "Shadow Station",
        "Enemy scouts probing weak lanes",
        9,
        Float::from_int(88) / 100.0,
        2,
        @raylib.Color::new(40, 60, 44, 255),
        @raylib.Color::new(20, 30, 22, 255),
        Float::from_int(7) / 100.0,
        @raylib.Color::new(186, 162, 178, 255),
      )
    75 =>
      StageProfile::new(
        "Storm Station",
        "Heavy units entering from north",
        10,
        Float::from_int(87) / 100.0,
        3,
        @raylib.Color::new(45, 67, 55, 255),
        @raylib.Color::new(22, 33, 27, 255),
        Float::from_int(8) / 100.0,
        @raylib.Color::new(195, 175, 75, 255),
      )
    76 =>
      StageProfile::new(
        "Echo Junction",
        "Fogged battlefield, short visibility",
        9,
        Float::from_int(87) / 100.0,
        4,
        @raylib.Color::new(50, 74, 66, 255),
        @raylib.Color::new(25, 37, 33, 255),
        Float::from_int(9) / 100.0,
        @raylib.Color::new(204, 188, 92, 255),
      )
    77 =>
      StageProfile::new(
        "Iron Junction",
        "Expect fast flanking squads",
        9,
        Float::from_int(87) / 100.0,
        -2,
        @raylib.Color::new(55, 81, 77, 255),
        @raylib.Color::new(27, 40, 38, 255),
        Float::from_int(10) / 100.0,
        @raylib.Color::new(213, 81, 109, 255),
      )
    78 =>
      StageProfile::new(
        "Azure Frontline",
        "Breakthrough attempt in progress",
        10,
        Float::from_int(86) / 100.0,
        -1,
        @raylib.Color::new(60, 88, 88, 255),
        @raylib.Color::new(30, 44, 44, 255),
        Float::from_int(11) / 100.0,
        @raylib.Color::new(222, 94, 126, 255),
      )
    79 =>
      StageProfile::new(
        "Dust Frontline",
        "Hold the line around command base",
        9,
        Float::from_int(86) / 100.0,
        0,
        @raylib.Color::new(65, 95, 99, 255),
        @raylib.Color::new(32, 47, 49, 255),
        Float::from_int(12) / 100.0,
        @raylib.Color::new(231, 107, 143, 255),
      )
    80 =>
      StageProfile::new(
        "Rust Watchpoint",
        "Sniper platoon deployment confirmed",
        10,
        Float::from_int(86) / 100.0,
        1,
        @raylib.Color::new(70, 102, 110, 255),
        @raylib.Color::new(35, 51, 55, 255),
        Float::from_int(5) / 100.0,
        @raylib.Color::new(120, 120, 160, 255),
      )
    81 =>
      StageProfile::new(
        "Neon Watchpoint",
        "Salvage crews report minefields",
        11,
        Float::from_int(85) / 100.0,
        2,
        @raylib.Color::new(75, 109, 121, 255),
        @raylib.Color::new(37, 54, 60, 255),
        Float::from_int(6) / 100.0,
        @raylib.Color::new(129, 133, 177, 255),
      )
    82 =>
      StageProfile::new(
        "Frost Arsenal",
        "Recon drones indicate mixed armor",
        10,
        Float::from_int(85) / 100.0,
        3,
        @raylib.Color::new(80, 116, 132, 255),
        @raylib.Color::new(40, 58, 66, 255),
        Float::from_int(7) / 100.0,
        @raylib.Color::new(138, 146, 74, 255),
      )
    83 =>
      StageProfile::new(
        "Ember Arsenal",
        "Prepare for prolonged engagement",
        10,
        Float::from_int(85) / 100.0,
        4,
        @raylib.Color::new(85, 23, 143, 255),
        @raylib.Color::new(42, 11, 71, 255),
        Float::from_int(8) / 100.0,
        @raylib.Color::new(147, 159, 91, 255),
      )
    84 =>
      StageProfile::new(
        "Shadow Outpost",
        "Hostile armor columns detected",
        11,
        Float::from_int(84) / 100.0,
        -2,
        @raylib.Color::new(90, 30, 34, 255),
        @raylib.Color::new(45, 15, 17, 255),
        Float::from_int(9) / 100.0,
        @raylib.Color::new(156, 172, 108, 255),
      )
    85 =>
      StageProfile::new(
        "Storm Outpost",
        "Fortify routes and hold pressure",
        10,
        Float::from_int(84) / 100.0,
        -1,
        @raylib.Color::new(95, 37, 45, 255),
        @raylib.Color::new(47, 18, 22, 255),
        Float::from_int(10) / 100.0,
        @raylib.Color::new(165, 185, 125, 255),
      )
    86 =>
      StageProfile::new(
        "Echo Bastion",
        "Enemy scouts probing weak lanes",
        10,
        Float::from_int(84) / 100.0,
        0,
        @raylib.Color::new(100, 44, 56, 255),
        @raylib.Color::new(50, 22, 28, 255),
        Float::from_int(11) / 100.0,
        @raylib.Color::new(174, 198, 142, 255),
      )
    87 =>
      StageProfile::new(
        "Iron Bastion",
        "Heavy units entering from north",
        11,
        Float::from_int(83) / 100.0,
        1,
        @raylib.Color::new(15, 51, 67, 255),
        @raylib.Color::new(7, 25, 33, 255),
        Float::from_int(12) / 100.0,
        @raylib.Color::new(183, 91, 159, 255),
      )
    88 =>
      StageProfile::new(
        "Azure Delta",
        "Fogged battlefield, short visibility",
        11,
        Float::from_int(83) / 100.0,
        2,
        @raylib.Color::new(20, 58, 78, 255),
        @raylib.Color::new(10, 29, 39, 255),
        Float::from_int(5) / 100.0,
        @raylib.Color::new(192, 104, 176, 255),
      )
    89 =>
      StageProfile::new(
        "Dust Delta",
        "Expect fast flanking squads",
        11,
        Float::from_int(83) / 100.0,
        3,
        @raylib.Color::new(25, 65, 89, 255),
        @raylib.Color::new(12, 32, 44, 255),
        Float::from_int(6) / 100.0,
        @raylib.Color::new(201, 117, 73, 255),
      )
    90 =>
      StageProfile::new(
        "Rust Citadel",
        "Breakthrough attempt in progress",
        12,
        Float::from_int(82) / 100.0,
        4,
        @raylib.Color::new(30, 72, 100, 255),
        @raylib.Color::new(15, 36, 50, 255),
        Float::from_int(7) / 100.0,
        @raylib.Color::new(210, 130, 90, 255),
      )
    91 =>
      StageProfile::new(
        "Neon Citadel",
        "Hold the line around command base",
        11,
        Float::from_int(82) / 100.0,
        -2,
        @raylib.Color::new(35, 79, 111, 255),
        @raylib.Color::new(17, 39, 55, 255),
        Float::from_int(8) / 100.0,
        @raylib.Color::new(219, 143, 107, 255),
      )
    92 =>
      StageProfile::new(
        "Frost Depot",
        "Sniper platoon deployment confirmed",
        11,
        Float::from_int(82) / 100.0,
        -1,
        @raylib.Color::new(40, 86, 122, 255),
        @raylib.Color::new(20, 43, 61, 255),
        Float::from_int(9) / 100.0,
        @raylib.Color::new(228, 156, 124, 255),
      )
    93 =>
      StageProfile::new(
        "Ember Depot",
        "Salvage crews report minefields",
        12,
        Float::from_int(81) / 100.0,
        0,
        @raylib.Color::new(45, 93, 133, 255),
        @raylib.Color::new(22, 46, 66, 255),
        Float::from_int(10) / 100.0,
        @raylib.Color::new(237, 169, 141, 255),
      )
    94 =>
      StageProfile::new(
        "Shadow Crossing",
        "Recon drones indicate mixed armor",
        11,
        Float::from_int(81) / 100.0,
        1,
        @raylib.Color::new(50, 100, 144, 255),
        @raylib.Color::new(25, 50, 72, 255),
        Float::from_int(11) / 100.0,
        @raylib.Color::new(126, 182, 158, 255),
      )
    95 =>
      StageProfile::new(
        "Storm Crossing",
        "Prepare for prolonged engagement",
        11,
        Float::from_int(81) / 100.0,
        2,
        @raylib.Color::new(55, 107, 35, 255),
        @raylib.Color::new(27, 53, 17, 255),
        Float::from_int(12) / 100.0,
        @raylib.Color::new(135, 195, 175, 255),
      )
    _ => default_stage_profile()
  }
}
