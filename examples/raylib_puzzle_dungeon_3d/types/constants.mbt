// Screen

///|
pub let screen_width : Int = 1024

///|
pub let screen_height : Int = 768

// Grid dimensions

///|
pub let grid_w : Int = 12

///|
pub let grid_h : Int = 12

///|
pub let cell_size : Float = 1.0

// World counts

///|
pub let num_worlds : Int = 5

///|
pub let floors_per_world : Int = 6

// Animation

///|
pub let move_anim_duration : Float = 0.12

///|
pub let push_anim_duration : Float = 0.15

///|
pub let fall_anim_duration : Float = 0.3

///|
pub let slide_anim_duration : Float = 0.08

///|
pub let gate_anim_duration : Float = 0.4

///|
pub let teleport_anim_duration : Float = 0.25

///|
pub let bridge_anim_duration : Float = 0.35

///|
pub let rotate_anim_duration : Float = 0.3

///|
pub let laser_pulse_speed : Float = 4.0

///|
pub let conveyor_anim_speed : Float = 3.0

///|
pub let spike_cycle_time : Float = 2.0

// Scoring

///|
pub let max_stars : Int = 3

///|
pub let star_threshold_2 : Int = 15

///|
pub let star_threshold_3 : Int = 8

// Camera

///|
pub let camera_height : Float = 12.0

///|
pub let camera_dist : Float = 10.0

///|
pub let camera_fovy : Float = 20.0

// Pools

///|
pub let max_particles : Int = 512

///|
pub let max_undo : Int = 200

///|
pub let max_entities : Int = 64

///|
pub let max_floors : Int = 30

///|
pub let max_laser_segments : Int = 32

///|
pub let max_decorations : Int = 48

// UI

///|
pub let menu_blink_speed : Float = 3.5

///|
pub let transition_time : Float = 0.5

///|
pub let tutorial_fade_speed : Float = 2.0

///|
pub let star_anim_delay : Float = 0.3

// Level dimensions for undo state

///|
pub let grid_total : Int = 144 // grid_w * grid_h

// Particle constants

///|
pub let particle_gravity : Float = 6.0

///|
pub let particle_drag : Float = 0.98

///|
pub let teleport_particle_count : Int = 16

///|
pub let gate_particle_count : Int = 12

///|
pub let complete_particle_count : Int = 32

///|
pub let collect_particle_count : Int = 12

///|
pub let laser_particle_count : Int = 4

// World theme: Dungeon colors

///|
pub let dungeon_floor_r : Int = 80

///|
pub let dungeon_floor_g : Int = 90

///|
pub let dungeon_floor_b : Int = 110

///|
pub let dungeon_wall_r : Int = 45

///|
pub let dungeon_wall_g : Int = 50

///|
pub let dungeon_wall_b : Int = 65

///|
pub let dungeon_accent_r : Int = 160

///|
pub let dungeon_accent_g : Int = 130

///|
pub let dungeon_accent_b : Int = 80

///|
pub let dungeon_bg_r : Int = 15

///|
pub let dungeon_bg_g : Int = 20

///|
pub let dungeon_bg_b : Int = 35

// World theme: Ice colors

///|
pub let ice_floor_r : Int = 180

///|
pub let ice_floor_g : Int = 210

///|
pub let ice_floor_b : Int = 235

///|
pub let ice_wall_r : Int = 120

///|
pub let ice_wall_g : Int = 150

///|
pub let ice_wall_b : Int = 180

///|
pub let ice_accent_r : Int = 100

///|
pub let ice_accent_g : Int = 200

///|
pub let ice_accent_b : Int = 255

///|
pub let ice_bg_r : Int = 20

///|
pub let ice_bg_g : Int = 30

///|
pub let ice_bg_b : Int = 50

// World theme: Lava colors

///|
pub let lava_floor_r : Int = 100

///|
pub let lava_floor_g : Int = 60

///|
pub let lava_floor_b : Int = 50

///|
pub let lava_wall_r : Int = 70

///|
pub let lava_wall_g : Int = 35

///|
pub let lava_wall_b : Int = 30

///|
pub let lava_accent_r : Int = 255

///|
pub let lava_accent_g : Int = 120

///|
pub let lava_accent_b : Int = 30

///|
pub let lava_bg_r : Int = 30

///|
pub let lava_bg_g : Int = 10

///|
pub let lava_bg_b : Int = 5

// World theme: Garden colors

///|
pub let garden_floor_r : Int = 70

///|
pub let garden_floor_g : Int = 120

///|
pub let garden_floor_b : Int = 65

///|
pub let garden_wall_r : Int = 55

///|
pub let garden_wall_g : Int = 85

///|
pub let garden_wall_b : Int = 50

///|
pub let garden_accent_r : Int = 200

///|
pub let garden_accent_g : Int = 230

///|
pub let garden_accent_b : Int = 100

///|
pub let garden_bg_r : Int = 10

///|
pub let garden_bg_g : Int = 25

///|
pub let garden_bg_b : Int = 15

// World theme: Void colors

///|
pub let void_floor_r : Int = 50

///|
pub let void_floor_g : Int = 40

///|
pub let void_floor_b : Int = 80

///|
pub let void_wall_r : Int = 30

///|
pub let void_wall_g : Int = 25

///|
pub let void_wall_b : Int = 55

///|
pub let void_accent_r : Int = 180

///|
pub let void_accent_g : Int = 100

///|
pub let void_accent_b : Int = 255

///|
pub let void_bg_r : Int = 8

///|
pub let void_bg_g : Int = 5

///|
pub let void_bg_b : Int = 20

// Common colors

///|
pub let color_floor_r : Int = 80

///|
pub let color_floor_g : Int = 90

///|
pub let color_floor_b : Int = 110

///|
pub let color_wall_r : Int = 45

///|
pub let color_wall_g : Int = 50

///|
pub let color_wall_b : Int = 65

///|
pub let color_plate_r : Int = 200

///|
pub let color_plate_g : Int = 180

///|
pub let color_plate_b : Int = 50

///|
pub let color_exit_r : Int = 50

///|
pub let color_exit_g : Int = 200

///|
pub let color_exit_b : Int = 100

///|
pub let color_ice_r : Int = 150

///|
pub let color_ice_g : Int = 210

///|
pub let color_ice_b : Int = 240

///|
pub let color_block_r : Int = 180

///|
pub let color_block_g : Int = 120

///|
pub let color_block_b : Int = 60

///|
pub let color_diamond_r : Int = 100

///|
pub let color_diamond_g : Int = 200

///|
pub let color_diamond_b : Int = 255

///|
pub let color_key_r : Int = 255

///|
pub let color_key_g : Int = 215

///|
pub let color_key_b : Int = 0

///|
pub let color_conveyor_r : Int = 150

///|
pub let color_conveyor_g : Int = 150

///|
pub let color_conveyor_b : Int = 170

///|
pub let color_bridge_r : Int = 140

///|
pub let color_bridge_g : Int = 100

///|
pub let color_bridge_b : Int = 60

///|
pub let color_gate_r : Int = 160

///|
pub let color_gate_g : Int = 160

///|
pub let color_gate_b : Int = 180

///|
pub let color_mirror_r : Int = 200

///|
pub let color_mirror_g : Int = 220

///|
pub let color_mirror_b : Int = 255

///|
pub let color_laser_r : Int = 255

///|
pub let color_laser_g : Int = 50

///|
pub let color_laser_b : Int = 50

///|
pub let color_target_r : Int = 255

///|
pub let color_target_g : Int = 200

///|
pub let color_target_b : Int = 80

///|
pub let color_rotate_r : Int = 130

///|
pub let color_rotate_g : Int = 100

///|
pub let color_rotate_b : Int = 170

// Tutorial messages

///|
pub let tutorial_msg_move : String = "Use WASD or Arrow keys to move"

///|
pub let tutorial_msg_push : String = "Walk into a block to push it"

///|
pub let tutorial_msg_plate : String = "Push blocks onto golden plates to open the exit"

///|
pub let tutorial_msg_undo : String = "Press Z to undo your last move"

///|
pub let tutorial_msg_ice : String = "Ice is slippery - you slide until hitting something"

///|
pub let tutorial_msg_teleport : String = "Step on a portal to teleport to its pair"

///|
pub let tutorial_msg_switch : String = "Switches toggle spikes on and off"

///|
pub let tutorial_msg_conveyor : String = "Conveyors push blocks in their direction each turn"

///|
pub let tutorial_msg_mirror : String = "Mirrors reflect laser beams at 90 degrees"

///|
pub let tutorial_msg_bridge : String = "Switches can raise and lower bridges"

///|
pub let tutorial_msg_gate : String = "Gates open when all plates are filled"

///|
pub let tutorial_msg_cracked : String = "Cracked floors collapse after you step off them"

///|
pub let tutorial_msg_diamond : String = "Collect all gems to open the exit"

///|
pub let tutorial_msg_complete : String = "Reach the green exit portal to complete the floor"

// Achievement thresholds

///|
pub let achievement_first_clear : Int = 0

///|
pub let achievement_world_1 : Int = 1

///|
pub let achievement_world_2 : Int = 2

///|
pub let achievement_world_3 : Int = 3

///|
pub let achievement_world_4 : Int = 4

///|
pub let achievement_world_5 : Int = 5

///|
pub let achievement_all_stars : Int = 6

///|
pub let achievement_speed_run : Int = 7

///|
pub let achievement_no_undo : Int = 8

///|
pub let max_achievements : Int = 9

// World names

///|
pub let world_name_0 : String = "Stone Dungeon"

///|
pub let world_name_1 : String = "Frozen Cavern"

///|
pub let world_name_2 : String = "Magma Fortress"

///|
pub let world_name_3 : String = "Verdant Garden"

///|
pub let world_name_4 : String = "The Void"
