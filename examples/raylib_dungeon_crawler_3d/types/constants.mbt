// Screen
///|
pub let screen_width : Int = 1024

///|
pub let screen_height : Int = 768

// Grid dimensions

///|
pub let grid_w : Int = 32

///|
pub let grid_h : Int = 32

///|
pub let grid_total : Int = 1024 // grid_w * grid_h

///|
pub let cell_size : Float = 2.0

///|
pub let wall_height : Float = 3.0

// Tile types

///|
pub let tile_empty : Int = 0

///|
pub let tile_wall : Int = 1

///|
pub let tile_floor : Int = 2

///|
pub let tile_door : Int = 3

///|
pub let tile_stairs : Int = 4

///|
pub let tile_chest : Int = 5

///|
pub let tile_trap : Int = 6

///|
pub let tile_shrine : Int = 7

///|
pub let tile_shop : Int = 8

///|
pub let tile_locked_door : Int = 9

///|
pub let tile_boss_door : Int = 10

///|
pub let tile_secret_door : Int = 11

// Enemy types

///|
pub let enemy_none : Int = 0

///|
pub let enemy_skeleton : Int = 1

///|
pub let enemy_archer : Int = 2

///|
pub let enemy_golem : Int = 3

///|
pub let enemy_wraith : Int = 4

///|
pub let enemy_dragon_boss : Int = 5

///|
pub let enemy_slime : Int = 6

///|
pub let enemy_bat : Int = 7

///|
pub let enemy_spider : Int = 8

///|
pub let enemy_minotaur : Int = 9

///|
pub let enemy_lich : Int = 10

///|
pub let enemy_mimic : Int = 11

// Enemy states

///|
pub let ai_idle : Int = 0

///|
pub let ai_patrol : Int = 1

///|
pub let ai_chase : Int = 2

///|
pub let ai_attack : Int = 3

///|
pub let ai_flee : Int = 4

///|
pub let ai_dead : Int = 5

///|
pub let ai_special : Int = 6

// Loot types

///|
pub let loot_none : Int = 0

///|
pub let loot_health_potion : Int = 1

///|
pub let loot_damage_boost : Int = 2

///|
pub let loot_armor : Int = 3

///|
pub let loot_mana_potion : Int = 4

///|
pub let loot_speed_potion : Int = 5

///|
pub let loot_strength_potion : Int = 6

///|
pub let loot_gold_pile : Int = 7

///|
pub let loot_key : Int = 8

///|
pub let loot_boss_key : Int = 9

// Weapon types

///|
pub let weapon_sword : Int = 0

///|
pub let weapon_axe : Int = 1

///|
pub let weapon_mace : Int = 2

///|
pub let weapon_dagger : Int = 3

///|
pub let weapon_staff : Int = 4

///|
pub let weapon_bow : Int = 5

// Armor types

///|
pub let armor_none : Int = 0

///|
pub let armor_robes : Int = 1

///|
pub let armor_leather : Int = 2

///|
pub let armor_chain : Int = 3

///|
pub let armor_plate : Int = 4

// Spell types

///|
pub let spell_none : Int = 0

///|
pub let spell_fireball : Int = 1

///|
pub let spell_ice_bolt : Int = 2

///|
pub let spell_heal : Int = 3

///|
pub let spell_shield : Int = 4

///|
pub let spell_lightning : Int = 5

///|
pub let spell_teleport : Int = 6

// Trap types

///|
pub let trap_spike : Int = 0

///|
pub let trap_arrow : Int = 1

///|
pub let trap_flame : Int = 2

///|
pub let trap_poison : Int = 3

///|
pub let trap_pitfall : Int = 4

///|
pub let trap_teleporter : Int = 5

// Item rarity

///|
pub let rarity_common : Int = 0

///|
pub let rarity_uncommon : Int = 1

///|
pub let rarity_rare : Int = 2

///|
pub let rarity_epic : Int = 3

///|
pub let rarity_legendary : Int = 4

// Floor themes

///|
pub let theme_crypt : Int = 0

///|
pub let theme_sewer : Int = 1

///|
pub let theme_cavern : Int = 2

///|
pub let theme_library : Int = 3

///|
pub let theme_prison : Int = 4

///|
pub let theme_throne_room : Int = 5

///|
pub let theme_mine : Int = 6

///|
pub let theme_temple : Int = 7

///|
pub let theme_abyss : Int = 8

///|
pub let theme_final_chamber : Int = 9

// Game states

///|
pub let state_menu : Int = 0

///|
pub let state_playing : Int = 1

///|
pub let state_paused : Int = 2

///|
pub let state_game_over : Int = 3

///|
pub let state_level_up : Int = 4

///|
pub let state_floor_complete : Int = 5

///|
pub let state_inventory : Int = 6

///|
pub let state_shop : Int = 7

///|
pub let state_shrine : Int = 8

///|
pub let state_boss_intro : Int = 9

///|
pub let state_spellbook : Int = 10

///|
pub let state_class_select : Int = 11

// Player classes

///|
pub let class_warrior : Int = 0

///|
pub let class_rogue : Int = 1

///|
pub let class_mage : Int = 2

// Pools

///|
pub let max_enemies : Int = 64

///|
pub let max_projectiles : Int = 128

///|
pub let max_particles : Int = 256

///|
pub let max_loot : Int = 32

///|
pub let max_floors : Int = 10

///|
pub let max_inventory : Int = 20

///|
pub let max_spells : Int = 6

///|
pub let max_messages : Int = 8

///|
pub let max_traps : Int = 24

///|
pub let max_shop_items : Int = 6

///|
pub let max_torches : Int = 32

// BSP dungeon generation

///|
pub let min_room_size : Int = 4

///|
pub let max_room_size : Int = 10

///|
pub let max_rooms : Int = 12

///|
pub let corridor_width : Int = 1

// Player defaults

///|
pub let player_speed : Float = 6.0

///|
pub let player_sprint_mult : Float = 1.5

///|
pub let player_start_hp : Int = 100

///|
pub let player_start_mana : Int = 50

///|
pub let player_start_atk : Int = 10

///|
pub let player_start_def : Int = 5

///|
pub let player_start_str : Int = 8

///|
pub let player_start_dex : Int = 8

///|
pub let player_start_int_stat : Int = 8

///|
pub let player_eye_height : Float = 1.6

// Combat

///|
pub let sword_range : Float = 2.5

///|
pub let sword_cooldown : Float = 0.4

///|
pub let sword_damage_mult : Float = 1.0

///|
pub let axe_range : Float = 2.2

///|
pub let axe_cooldown : Float = 0.7

///|
pub let axe_damage_mult : Float = 1.4

///|
pub let mace_range : Float = 2.0

///|
pub let mace_cooldown : Float = 0.6

///|
pub let mace_damage_mult : Float = 1.2

///|
pub let dagger_range : Float = 1.8

///|
pub let dagger_cooldown : Float = 0.25

///|
pub let dagger_damage_mult : Float = 0.7

///|
pub let staff_range : Float = 2.8

///|
pub let staff_cooldown : Float = 0.5

///|
pub let staff_damage_mult : Float = 0.5

///|
pub let bow_range : Float = 15.0

///|
pub let bow_cooldown : Float = 0.8

///|
pub let bow_damage_mult : Float = 0.9

///|
pub let archer_range : Float = 12.0

///|
pub let archer_shoot_cooldown : Float = 2.0

///|
pub let projectile_speed : Float = 8.0

///|
pub let projectile_lifetime : Float = 3.0

///|
pub let enemy_melee_range : Float = 2.0

///|
pub let enemy_attack_cooldown : Float = 1.2

///|
pub let enemy_sight_range : Float = 10.0

///|
pub let enemy_move_speed : Float = 2.0

///|
pub let wraith_move_speed : Float = 4.0

///|
pub let golem_move_speed : Float = 1.2

///|
pub let bat_move_speed : Float = 5.0

///|
pub let slime_move_speed : Float = 1.5

///|
pub let spider_move_speed : Float = 3.0

///|
pub let minotaur_charge_speed : Float = 8.0

// Spell costs and values

///|
pub let fireball_mana_cost : Int = 15

///|
pub let fireball_damage : Int = 25

///|
pub let fireball_radius : Float = 2.5

///|
pub let ice_bolt_mana_cost : Int = 10

///|
pub let ice_bolt_damage : Int = 15

///|
pub let ice_bolt_slow_duration : Float = 3.0

///|
pub let heal_mana_cost : Int = 20

///|
pub let heal_amount : Int = 40

///|
pub let shield_mana_cost : Int = 12

///|
pub let shield_duration : Float = 8.0

///|
pub let shield_defense_bonus : Int = 10

///|
pub let lightning_mana_cost : Int = 25

///|
pub let lightning_damage : Int = 35

///|
pub let lightning_chain_range : Float = 4.0

///|
pub let teleport_mana_cost : Int = 8

// Trap values

///|
pub let spike_damage : Int = 15

///|
pub let arrow_trap_damage : Int = 20

///|
pub let flame_damage : Int = 25

///|
pub let poison_damage_per_sec : Int = 5

///|
pub let poison_duration : Float = 5.0

///|
pub let pitfall_damage : Int = 30

///|
pub let trap_cooldown : Float = 3.0

// XP and leveling

///|
pub let xp_per_skeleton : Int = 20

///|
pub let xp_per_archer : Int = 30

///|
pub let xp_per_golem : Int = 50

///|
pub let xp_per_wraith : Int = 40

///|
pub let xp_per_dragon : Int = 200

///|
pub let xp_per_slime : Int = 10

///|
pub let xp_per_bat : Int = 15

///|
pub let xp_per_spider : Int = 25

///|
pub let xp_per_minotaur : Int = 60

///|
pub let xp_per_lich : Int = 80

///|
pub let xp_per_mimic : Int = 45

///|
pub let xp_per_level : Int = 100

///|
pub let hp_per_level : Int = 15

///|
pub let mana_per_level : Int = 8

///|
pub let atk_per_level : Int = 3

///|
pub let def_per_level : Int = 2

// Loot values

///|
pub let health_potion_heal : Int = 40

///|
pub let mana_potion_restore : Int = 30

///|
pub let damage_boost_amount : Int = 5

///|
pub let armor_boost_amount : Int = 3

///|
pub let speed_potion_duration : Float = 10.0

///|
pub let strength_potion_duration : Float = 10.0

///|
pub let strength_potion_bonus : Int = 8

///|
pub let gold_pile_min : Int = 10

///|
pub let gold_pile_max : Int = 50

// Armor defense values

///|
pub let robes_defense : Int = 2

///|
pub let leather_defense : Int = 5

///|
pub let chain_defense : Int = 8

///|
pub let plate_defense : Int = 12

// Shop prices

///|
pub let price_health_potion : Int = 25

///|
pub let price_mana_potion : Int = 30

///|
pub let price_weapon_upgrade : Int = 80

///|
pub let price_armor_upgrade : Int = 100

///|
pub let price_spell_scroll : Int = 60

///|
pub let price_key : Int = 40

// Shrine buffs

///|
pub let shrine_hp_bonus : Int = 20

///|
pub let shrine_mana_bonus : Int = 15

///|
pub let shrine_atk_bonus : Int = 5

///|
pub let shrine_def_bonus : Int = 3

///|
pub let shrine_options : Int = 3

// Minimap

///|
pub let minimap_size : Int = 160

///|
pub let minimap_x : Int = 854 // screen_width - minimap_size - 10

///|
pub let minimap_y : Int = 10

///|
pub let minimap_cell : Int = 5

// UI

///|
pub let menu_blink_speed : Float = 3.5

// Sword swing animation

///|
pub let swing_duration : Float = 0.3

// Camera

///|
pub let camera_fovy : Float = 60.0

// Pi constant

///|
pub let pi : Float = 3.14159265

// Mana regen

///|
pub let mana_regen_rate : Float = 1.5

// Boss intro duration

///|
pub let boss_intro_duration : Float = 3.0

// Inventory UI

///|
pub let inv_slot_size : Int = 50

///|
pub let inv_cols : Int = 5

///|
pub let inv_rows : Int = 4

///|
pub let inv_start_x : Int = 212

///|
pub let inv_start_y : Int = 184
