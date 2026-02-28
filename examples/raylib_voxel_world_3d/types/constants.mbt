// Screen
///|
pub let screen_width : Int = 1280

///|
pub let screen_height : Int = 720

// Game states

///|
pub let state_menu : Int = 0

///|
pub let state_playing : Int = 1

///|
pub let state_paused : Int = 2

///|
pub let state_inventory : Int = 3

///|
pub let state_crafting : Int = 4

///|
pub let state_game_over : Int = 5

// Block types

///|
pub let block_air : Int = 0

///|
pub let block_dirt : Int = 1

///|
pub let block_grass : Int = 2

///|
pub let block_stone : Int = 3

///|
pub let block_wood : Int = 4

///|
pub let block_leaves : Int = 5

///|
pub let block_water : Int = 6

///|
pub let block_sand : Int = 7

///|
pub let block_glass : Int = 8

///|
pub let block_brick : Int = 9

///|
pub let block_ore_iron : Int = 10

///|
pub let block_ore_gold : Int = 11

///|
pub let block_ore_diamond : Int = 12

///|
pub let block_snow : Int = 13

///|
pub let block_gravel : Int = 14

///|
pub let block_planks : Int = 15

///|
pub let block_cobblestone : Int = 16

///|
pub let block_torch : Int = 17

///|
pub let block_bedrock : Int = 18

///|
pub let block_flower_red : Int = 19

///|
pub let block_flower_yellow : Int = 20

///|
pub let block_tall_grass : Int = 21

///|
pub let block_cactus : Int = 22

///|
pub let block_clay : Int = 23

///|
pub let block_count : Int = 24

// Biome types

///|
pub let biome_plains : Int = 0

///|
pub let biome_forest : Int = 1

///|
pub let biome_desert : Int = 2

///|
pub let biome_mountains : Int = 3

///|
pub let biome_tundra : Int = 4

///|
pub let biome_swamp : Int = 5

///|
pub let biome_count : Int = 6

// Tool types

///|
pub let tool_hand : Int = 0

///|
pub let tool_wooden_pickaxe : Int = 1

///|
pub let tool_stone_pickaxe : Int = 2

///|
pub let tool_iron_pickaxe : Int = 3

///|
pub let tool_wooden_axe : Int = 4

///|
pub let tool_stone_axe : Int = 5

///|
pub let tool_iron_axe : Int = 6

///|
pub let tool_wooden_shovel : Int = 7

///|
pub let tool_stone_shovel : Int = 8

///|
pub let tool_iron_shovel : Int = 9

///|
pub let tool_wooden_sword : Int = 10

///|
pub let tool_stone_sword : Int = 11

///|
pub let tool_iron_sword : Int = 12

///|
pub let tool_count : Int = 13

// Chunk dimensions

///|
pub let chunk_x : Int = 16

///|
pub let chunk_y : Int = 64

///|
pub let chunk_z : Int = 16

// World dimensions (in chunks)

///|
pub let world_chunks_x : Int = 8

///|
pub let world_chunks_z : Int = 8

// Render distance (in chunks from player)

///|
pub let render_distance : Int = 3

// Player

///|
pub let player_height : Float = 1.7

///|
pub let player_eye_height : Float = 1.6

///|
pub let player_speed : Float = 5.0

///|
pub let player_sprint_mult : Float = 1.6

///|
pub let player_radius : Float = 0.3

///|
pub let player_jump_force : Float = 7.5

///|
pub let player_mouse_sensitivity : Float = 0.003

///|
pub let player_max_health : Int = 20

///|
pub let player_max_hunger : Int = 20

///|
pub let player_max_air : Int = 10

// Camera

///|
pub let camera_fovy : Float = 70.0

// Physics

///|
pub let gravity : Float = 18.0

///|
pub let terminal_velocity : Float = 30.0

// Interaction

///|
pub let reach_distance : Float = 6.0

///|
pub let ray_step : Float = 0.02

// Day/night cycle

///|
pub let day_length : Float = 120.0

///|
pub let dawn_start : Float = 0.0

///|
pub let dawn_end : Float = 0.1

///|
pub let morning_end : Float = 0.25

///|
pub let day_end : Float = 0.45

///|
pub let dusk_end : Float = 0.55

///|
pub let late_dusk_end : Float = 0.65

// PI constant

///|
pub let pi : Float = 3.14159265

///|
pub let two_pi : Float = 6.2831853

// Terrain generation

///|
pub let base_height : Int = 20

///|
pub let terrain_amplitude : Float = 12.0

///|
pub let terrain_frequency : Float = 0.04

///|
pub let tree_frequency : Float = 0.03

// Caves

///|
pub let cave_frequency : Float = 0.08

///|
pub let cave_threshold : Float = 0.55

///|
pub let cave_min_height : Int = 5

///|
pub let cave_max_height : Int = 40

// Ore generation

///|
pub let ore_iron_min_y : Int = 2

///|
pub let ore_iron_max_y : Int = 45

///|
pub let ore_iron_chance : Float = 0.03

///|
pub let ore_gold_min_y : Int = 2

///|
pub let ore_gold_max_y : Int = 28

///|
pub let ore_gold_chance : Float = 0.015

///|
pub let ore_diamond_min_y : Int = 2

///|
pub let ore_diamond_max_y : Int = 16

///|
pub let ore_diamond_chance : Float = 0.006

// Inventory

///|
pub let inventory_slots : Int = 36

///|
pub let hotbar_slots : Int = 9

///|
pub let inventory_cols : Int = 9

///|
pub let inventory_rows : Int = 4

///|
pub let stack_max : Int = 64

// Lighting

///|
pub let max_light_level : Int = 15

///|
pub let torch_light_level : Int = 14

///|
pub let sun_light_level : Int = 15

///|
pub let min_ambient_light : Float = 0.15

// Entities

///|
pub let entity_max : Int = 32

///|
pub let entity_pig : Int = 1

///|
pub let entity_cow : Int = 2

///|
pub let entity_chicken : Int = 3

///|
pub let entity_zombie : Int = 4

///|
pub let entity_skeleton : Int = 5

///|
pub let entity_spider : Int = 6

// Entity AI states

///|
pub let ai_idle : Int = 0

///|
pub let ai_wander : Int = 1

///|
pub let ai_flee : Int = 2

///|
pub let ai_chase : Int = 3

///|
pub let ai_attack : Int = 4

// Entity stats

///|
pub let pig_health : Int = 10

///|
pub let cow_health : Int = 10

///|
pub let chicken_health : Int = 4

///|
pub let zombie_health : Int = 20

///|
pub let skeleton_health : Int = 20

///|
pub let spider_health : Int = 16

///|
pub let zombie_damage : Int = 3

///|
pub let skeleton_damage : Int = 2

///|
pub let spider_damage : Int = 2

// Entity movement

///|
pub let entity_speed_passive : Float = 1.5

///|
pub let entity_speed_hostile : Float = 2.8

///|
pub let entity_spawn_radius : Float = 30.0

///|
pub let entity_despawn_radius : Float = 60.0

///|
pub let entity_attack_range : Float = 1.8

// Particles

///|
pub let particle_max : Int = 64

///|
pub let particle_lifetime : Float = 1.0

///|
pub let particle_gravity : Float = 12.0

///|
pub let particle_speed : Float = 4.0

// Mining speeds (seconds to break with hand)

///|
pub let mine_speed_dirt : Float = 0.5

///|
pub let mine_speed_grass : Float = 0.6

///|
pub let mine_speed_sand : Float = 0.5

///|
pub let mine_speed_gravel : Float = 0.6

///|
pub let mine_speed_stone : Float = 2.0

///|
pub let mine_speed_cobblestone : Float = 2.0

///|
pub let mine_speed_wood : Float = 1.5

///|
pub let mine_speed_planks : Float = 1.0

///|
pub let mine_speed_leaves : Float = 0.3

///|
pub let mine_speed_glass : Float = 0.4

///|
pub let mine_speed_brick : Float = 2.5

///|
pub let mine_speed_ore : Float = 3.0

///|
pub let mine_speed_bedrock : Float = 999.0

// Crafting recipe IDs

///|
pub let recipe_planks : Int = 0

///|
pub let recipe_sticks : Int = 1

///|
pub let recipe_crafting_table : Int = 2

///|
pub let recipe_wooden_pickaxe : Int = 3

///|
pub let recipe_stone_pickaxe : Int = 4

///|
pub let recipe_iron_pickaxe : Int = 5

///|
pub let recipe_wooden_axe : Int = 6

///|
pub let recipe_wooden_shovel : Int = 7

///|
pub let recipe_wooden_sword : Int = 8

///|
pub let recipe_furnace : Int = 9

///|
pub let recipe_torch : Int = 10

///|
pub let recipe_brick : Int = 11

///|
pub let recipe_glass : Int = 12

///|
pub let recipe_count : Int = 13

// Fog

///|
pub let fog_start_distance : Float = 32.0

///|
pub let fog_end_distance : Float = 52.0

///|
pub let fog_density : Float = 0.02

// Water

///|
pub let water_spread_interval : Float = 0.5

///|
pub let water_level : Int = 16

// Hunger

///|
pub let hunger_drain_rate : Float = 0.015

///|
pub let hunger_sprint_drain : Float = 0.04

///|
pub let hunger_heal_threshold : Int = 16

///|
pub let hunger_starve_threshold : Int = 0

///|
pub let starve_damage_interval : Float = 2.0

// Fall damage

///|
pub let fall_damage_threshold : Float = 4.0

///|
pub let fall_damage_multiplier : Float = 1.0

// Respawn

///|
pub let respawn_invulnerability : Float = 3.0

// Block physics

///|
pub let gravity_block_interval : Float = 0.15
