// Floor configuration: difficulty scaling
// Returns (num_rooms, num_skeletons, num_archers, num_golems, num_wraiths, has_boss, num_loot)

pub fn get_floor_config(floor : Int) -> (Int, Int, Int, Int, Int, Bool, Int) {
  if floor == 0 {
    // Floor 1: Tutorial - crypt
    (4, 3, 0, 0, 0, false, 3)
  } else if floor == 1 {
    // Floor 2: Archers appear - sewer
    (5, 3, 2, 0, 0, false, 3)
  } else if floor == 2 {
    // Floor 3: More enemies - cavern
    (5, 4, 2, 0, 0, false, 4)
  } else if floor == 3 {
    // Floor 4: Golems appear - library
    (6, 3, 2, 1, 0, false, 4)
  } else if floor == 4 {
    // Floor 5: Boss floor - prison
    (6, 4, 3, 1, 0, true, 5)
  } else if floor == 5 {
    // Floor 6: Wraiths appear - throne room
    (7, 3, 2, 1, 2, false, 5)
  } else if floor == 6 {
    // Floor 7: Harder - mine
    (7, 4, 3, 2, 2, false, 5)
  } else if floor == 7 {
    // Floor 8: Intense - temple
    (8, 5, 3, 2, 3, false, 6)
  } else if floor == 8 {
    // Floor 9: Brutal - abyss
    (8, 5, 4, 3, 3, false, 6)
  } else {
    // Floor 10: Dragon boss - final chamber
    (9, 4, 3, 2, 2, true, 8)
  }
}

// Extended enemy config per floor
// Returns (num_slimes, num_bats, num_spiders, num_minotaurs, num_lichs)
pub fn get_extended_enemy_config(floor : Int) -> (Int, Int, Int, Int, Int) {
  if floor == 0 {
    (2, 1, 0, 0, 0)
  } else if floor == 1 {
    (2, 2, 0, 0, 0)
  } else if floor == 2 {
    (1, 2, 2, 0, 0)
  } else if floor == 3 {
    (1, 1, 2, 0, 0)
  } else if floor == 4 {
    (0, 2, 2, 1, 0)
  } else if floor == 5 {
    (0, 1, 2, 1, 0)
  } else if floor == 6 {
    (0, 2, 2, 1, 1)
  } else if floor == 7 {
    (0, 1, 3, 2, 1)
  } else if floor == 8 {
    (0, 2, 2, 2, 2)
  } else {
    (0, 1, 2, 1, 2)
  }
}

// Floor theme mapping (matches theme_* constants in types)
pub fn get_floor_theme(floor : Int) -> Int {
  // theme values: crypt=0, sewer=1, cavern=2, library=3, prison=4,
  // throne_room=5, mine=6, temple=7, abyss=8, final_chamber=9
  floor
}

// Floor names
pub fn get_floor_name(floor : Int) -> String {
  if floor == 0 {
    "The Crypt"
  } else if floor == 1 {
    "Flooded Sewers"
  } else if floor == 2 {
    "Crystal Caverns"
  } else if floor == 3 {
    "Forbidden Library"
  } else if floor == 4 {
    "The Iron Prison"
  } else if floor == 5 {
    "Throne of Shadows"
  } else if floor == 6 {
    "Abandoned Mine"
  } else if floor == 7 {
    "Sunken Temple"
  } else if floor == 8 {
    "The Abyss"
  } else {
    "Dragon's Sanctum"
  }
}

// Enemy stat scaling by floor
pub fn get_enemy_hp_scale(floor : Int) -> Int {
  10 + floor * 5
}

pub fn get_enemy_atk_scale(floor : Int) -> Int {
  3 + floor * 2
}

pub fn get_enemy_def_scale(floor : Int) -> Int {
  1 + floor
}

// Theme wall colors (r, g, b)
pub fn get_theme_wall_color(theme : Int) -> (Int, Int, Int) {
  if theme == 0 {
    // crypt
    (40, 35, 50)
  } else if theme == 1 {
    // sewer
    (30, 45, 35)
  } else if theme == 2 {
    // cavern
    (55, 45, 35)
  } else if theme == 3 {
    // library
    (50, 35, 25)
  } else if theme == 4 {
    // prison
    (45, 45, 50)
  } else if theme == 5 {
    // throne room
    (55, 30, 30)
  } else if theme == 6 {
    // mine
    (50, 40, 30)
  } else if theme == 7 {
    // temple
    (45, 45, 55)
  } else if theme == 8 {
    // abyss
    (20, 15, 30)
  } else {
    // final chamber
    (60, 25, 25)
  }
}

// Theme floor colors (r, g, b)
pub fn get_theme_floor_color(theme : Int) -> (Int, Int, Int) {
  if theme == 0 {
    (55, 50, 65)
  } else if theme == 1 {
    (40, 55, 50)
  } else if theme == 2 {
    (65, 55, 45)
  } else if theme == 3 {
    (60, 45, 35)
  } else if theme == 4 {
    (55, 55, 60)
  } else if theme == 5 {
    (70, 40, 40)
  } else if theme == 6 {
    (60, 50, 40)
  } else if theme == 7 {
    (60, 60, 70)
  } else if theme == 8 {
    (30, 25, 40)
  } else {
    (75, 35, 35)
  }
}

// Theme ceiling colors (r, g, b)
pub fn get_theme_ceiling_color(theme : Int) -> (Int, Int, Int) {
  if theme == 0 {
    (30, 28, 38)
  } else if theme == 1 {
    (25, 35, 30)
  } else if theme == 2 {
    (40, 35, 28)
  } else if theme == 3 {
    (35, 28, 20)
  } else if theme == 4 {
    (35, 35, 40)
  } else if theme == 5 {
    (45, 25, 25)
  } else if theme == 6 {
    (38, 32, 25)
  } else if theme == 7 {
    (38, 38, 48)
  } else if theme == 8 {
    (15, 10, 22)
  } else {
    (50, 20, 20)
  }
}

// Trap count per floor
pub fn get_floor_trap_count(floor : Int) -> Int {
  if floor == 0 {
    1
  } else if floor <= 2 {
    2
  } else if floor <= 4 {
    3
  } else if floor <= 6 {
    4
  } else if floor <= 8 {
    5
  } else {
    6
  }
}

// Which trap types are available per floor
// trap_spike=0, trap_arrow=1, trap_flame=2, trap_poison=3, trap_pitfall=4
pub fn get_available_trap_type(floor : Int, roll : Int) -> Int {
  if floor <= 1 {
    0
  } else if floor <= 3 {
    if roll % 2 == 0 { 0 } else { 1 }
  } else if floor <= 5 {
    let r = roll % 3
    if r == 0 { 0 } else if r == 1 { 1 } else { 2 }
  } else if floor <= 7 {
    let r = roll % 4
    if r == 0 { 0 } else if r == 1 { 1 } else if r == 2 { 2 } else { 3 }
  } else {
    let r = roll % 5
    if r == 0 {
      0
    } else if r == 1 {
      1
    } else if r == 2 {
      2
    } else if r == 3 {
      3
    } else {
      4
    }
  }
}

// Loot rarity weights per floor (common, uncommon, rare, epic, legendary)
pub fn get_rarity_weight_common(floor : Int) -> Int {
  if floor <= 2 { 60 } else if floor <= 5 { 45 } else { 30 }
}

pub fn get_rarity_weight_uncommon(floor : Int) -> Int {
  if floor <= 2 { 30 } else if floor <= 5 { 30 } else { 25 }
}

pub fn get_rarity_weight_rare(floor : Int) -> Int {
  if floor <= 2 { 8 } else if floor <= 5 { 18 } else { 25 }
}

pub fn get_rarity_weight_epic(floor : Int) -> Int {
  if floor <= 2 { 2 } else if floor <= 5 { 6 } else { 15 }
}

pub fn get_rarity_weight_legendary(floor : Int) -> Int {
  if floor <= 2 { 0 } else if floor <= 5 { 1 } else { 5 }
}

// Boss definitions
pub fn get_boss_name(floor : Int) -> String {
  if floor == 4 {
    "Warden of Iron"
  } else if floor == 9 {
    "Azhrakul the Undying"
  } else {
    "Unknown Boss"
  }
}

pub fn get_boss_hp(floor : Int) -> Int {
  if floor == 4 {
    150 + get_enemy_hp_scale(floor) * 3
  } else if floor == 9 {
    300 + get_enemy_hp_scale(floor) * 4
  } else {
    100 + get_enemy_hp_scale(floor) * 2
  }
}

pub fn get_boss_atk(floor : Int) -> Int {
  if floor == 4 {
    12 + get_enemy_atk_scale(floor) * 2
  } else if floor == 9 {
    20 + get_enemy_atk_scale(floor) * 3
  } else {
    10 + get_enemy_atk_scale(floor)
  }
}

pub fn get_boss_def(floor : Int) -> Int {
  if floor == 4 {
    6 + get_enemy_def_scale(floor) * 2
  } else if floor == 9 {
    10 + get_enemy_def_scale(floor) * 3
  } else {
    4 + get_enemy_def_scale(floor)
  }
}

// Shop inventory generation
// loot_health_potion=1, loot_mana_potion=4, loot_damage_boost=2,
// loot_armor=3, loot_key=8, loot_speed_potion=5
pub fn get_shop_item_type(slot : Int) -> Int {
  if slot == 0 {
    1
  } else if slot == 1 {
    4
  } else if slot == 2 {
    2
  } else if slot == 3 {
    3
  } else if slot == 4 {
    8
  } else {
    5
  }
}

pub fn get_shop_item_price(slot : Int) -> Int {
  if slot == 0 {
    25
  } else if slot == 1 {
    30
  } else if slot == 2 {
    80
  } else if slot == 3 {
    100
  } else if slot == 4 {
    40
  } else {
    60
  }
}

pub fn get_shop_item_name(slot : Int) -> String {
  if slot == 0 {
    "Health Potion"
  } else if slot == 1 {
    "Mana Potion"
  } else if slot == 2 {
    "ATK Scroll"
  } else if slot == 3 {
    "DEF Scroll"
  } else if slot == 4 {
    "Key"
  } else {
    "Speed Potion"
  }
}

// Shrine buff options
pub fn get_shrine_buff_name(option : Int) -> String {
  if option == 0 {
    "Vitality (+20 Max HP)"
  } else if option == 1 {
    "Wisdom (+15 Max Mana)"
  } else if option == 2 {
    "Power (+5 ATK)"
  } else {
    "Unknown"
  }
}

// XP required for each level
pub fn get_xp_for_level(level : Int) -> Int {
  100 + (level - 1) * 50
}

// Number of locked doors per floor
pub fn get_locked_door_count(floor : Int) -> Int {
  if floor <= 1 { 0 } else if floor <= 4 { 1 } else if floor <= 7 { 2 } else { 3 }
}

// Whether this floor has a shop
pub fn floor_has_shop(floor : Int) -> Bool {
  floor == 2 || floor == 5 || floor == 7
}

// Whether this floor has a shrine
pub fn floor_has_shrine(floor : Int) -> Bool {
  floor == 1 || floor == 3 || floor == 6 || floor == 8
}

// Number of torches per room for a theme
pub fn get_torches_per_room(theme : Int) -> Int {
  if theme == 0 {
    2
  } else if theme == 1 {
    1
  } else if theme == 2 {
    1
  } else if theme == 3 {
    3
  } else if theme == 4 {
    2
  } else if theme == 5 {
    4
  } else if theme == 6 {
    2
  } else if theme == 7 {
    3
  } else if theme == 8 {
    1
  } else {
    4
  }
}
