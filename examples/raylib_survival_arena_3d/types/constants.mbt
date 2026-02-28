// Screen
///|
pub let screen_width : Int = 1280

///|
pub let screen_height : Int = 720

// Arena dimensions

///|
pub let arena_width : Float = 60.0

///|
pub let arena_depth : Float = 60.0

///|
pub let arena_wall_height : Float = 4.0

///|
pub let arena_wall_thickness : Float = 1.0

// Pillar

///|
pub let pillar_count : Int = 8

///|
pub let pillar_radius : Float = 1.2

///|
pub let pillar_height : Float = 5.0

// Crate

///|
pub let crate_count : Int = 6

///|
pub let crate_size : Float = 1.5

// Ramp dimensions

///|
pub let ramp_count : Int = 4

///|
pub let ramp_width : Float = 4.0

///|
pub let ramp_length : Float = 6.0

///|
pub let ramp_height : Float = 2.5

// Low wall (half-cover)

///|
pub let low_wall_count : Int = 6

///|
pub let low_wall_width : Float = 4.0

///|
pub let low_wall_height : Float = 1.5

///|
pub let low_wall_depth : Float = 0.6

// Game states

///|
pub let state_menu : Int = 0

///|
pub let state_playing : Int = 1

///|
pub let state_wave_complete : Int = 2

///|
pub let state_paused : Int = 3

///|
pub let state_game_over : Int = 4

// Weapon types

///|
pub let weapon_pistol : Int = 0

///|
pub let weapon_shotgun : Int = 1

///|
pub let weapon_rifle : Int = 2

///|
pub let weapon_sniper : Int = 3

///|
pub let weapon_rocket : Int = 4

///|
pub let weapon_minigun : Int = 5

///|
pub let weapon_count : Int = 6

// Weapon fire rates (seconds between shots)

///|
pub let rate_pistol : Float = 0.35

///|
pub let rate_shotgun : Float = 0.85

///|
pub let rate_rifle : Float = 0.09

///|
pub let rate_sniper : Float = 1.2

///|
pub let rate_rocket : Float = 1.5

///|
pub let rate_minigun : Float = 0.06

// Weapon damage

///|
pub let dmg_pistol : Float = 15.0

///|
pub let dmg_shotgun : Float = 8.0

///|
pub let dmg_rifle : Float = 8.0

///|
pub let dmg_sniper : Float = 80.0

///|
pub let dmg_rocket : Float = 80.0

///|
pub let dmg_minigun : Float = 6.0

// Weapon ammo (starting)

///|
pub let ammo_pistol : Int = 999

///|
pub let ammo_shotgun : Int = 20

///|
pub let ammo_rifle : Int = 90

///|
pub let ammo_sniper : Int = 10

///|
pub let ammo_rocket : Int = 5

///|
pub let ammo_minigun : Int = 200

// Weapon max reserve ammo

///|
pub let max_ammo_shotgun : Int = 60

///|
pub let max_ammo_rifle : Int = 240

///|
pub let max_ammo_sniper : Int = 30

///|
pub let max_ammo_rocket : Int = 15

///|
pub let max_ammo_minigun : Int = 600

// Weapon projectile speed

///|
pub let speed_pistol : Float = 60.0

///|
pub let speed_shotgun : Float = 50.0

///|
pub let speed_rifle : Float = 80.0

///|
pub let speed_sniper : Float = 120.0

///|
pub let speed_rocket : Float = 25.0

///|
pub let speed_minigun : Float = 70.0

// Shotgun pellets

///|
pub let shotgun_pellets : Int = 8

///|
pub let shotgun_spread : Float = 0.12

// Sniper penetration count

///|
pub let sniper_penetration : Int = 3

// Rocket splash

///|
pub let rocket_splash_radius : Float = 5.0

// Minigun spin-up time

///|
pub let minigun_spinup_time : Float = 0.6

///|
pub let minigun_max_spread : Float = 0.08

///|
pub let minigun_min_spread : Float = 0.02

// Weapon reload times

///|
pub let reload_pistol : Float = 1.0

///|
pub let reload_shotgun : Float = 2.2

///|
pub let reload_rifle : Float = 1.8

///|
pub let reload_sniper : Float = 2.5

///|
pub let reload_rocket : Float = 3.0

///|
pub let reload_minigun : Float = 4.0

// Weapon magazine sizes

///|
pub let mag_pistol : Int = 12

///|
pub let mag_shotgun : Int = 6

///|
pub let mag_rifle : Int = 30

///|
pub let mag_sniper : Int = 5

///|
pub let mag_rocket : Int = 1

///|
pub let mag_minigun : Int = 100

// Weapon upgrade cost multiplier per level

///|
pub let upgrade_cost_mult : Int = 75

// Max upgrade level per stat

///|
pub let max_upgrade_level : Int = 3

// Enemy types

///|
pub let enemy_zombie : Int = 0

///|
pub let enemy_runner : Int = 1

///|
pub let enemy_brute : Int = 2

///|
pub let enemy_spitter : Int = 3

///|
pub let enemy_exploder : Int = 4

///|
pub let enemy_necromancer : Int = 5

///|
pub let enemy_shielded : Int = 6

///|
pub let enemy_boss : Int = 7

// Player

///|
pub let player_height : Float = 1.8

///|
pub let player_speed : Float = 8.0

///|
pub let player_sprint_mult : Float = 1.6

///|
pub let player_crouch_mult : Float = 0.5

///|
pub let player_crouch_height : Float = 1.1

///|
pub let player_radius : Float = 0.5

///|
pub let player_max_hp : Float = 100.0

///|
pub let player_max_armor : Float = 100.0

///|
pub let player_mouse_sensitivity : Float = 0.003

///|
pub let player_damage_cooldown : Float = 0.3

// Camera

///|
pub let camera_fovy : Float = 70.0

// Pool sizes

///|
pub let max_enemies : Int = 128

///|
pub let max_projectiles : Int = 256

///|
pub let max_particles : Int = 512

///|
pub let max_pickups : Int = 32

///|
pub let max_traps : Int = 12

///|
pub let max_barricades : Int = 16

///|
pub let max_kill_feed : Int = 5

// Wave timing

///|
pub let wave_shop_time : Float = 15.0

///|
pub let spawn_interval : Float = 0.6

///|
pub let max_waves : Int = 30

// Spawn distance from center range

///|
pub let spawn_min_dist : Float = 25.0

///|
pub let spawn_max_dist : Float = 28.0

// Shop costs

///|
pub let cost_heal : Int = 50

///|
pub let cost_armor : Int = 40

///|
pub let cost_shotgun_ammo : Int = 30

///|
pub let cost_rifle_ammo : Int = 25

///|
pub let cost_sniper_ammo : Int = 50

///|
pub let cost_rocket_ammo : Int = 60

///|
pub let cost_minigun_ammo : Int = 45

///|
pub let cost_damage_up : Int = 100

///|
pub let cost_speed_up : Int = 80

///|
pub let cost_buy_sniper : Int = 200

///|
pub let cost_buy_rocket : Int = 300

///|
pub let cost_buy_minigun : Int = 400

///|
pub let cost_barricade : Int = 60

///|
pub let cost_trap_spike : Int = 80

///|
pub let cost_trap_flame : Int = 120

///|
pub let cost_trap_electric : Int = 150

// Pickup types

///|
pub let pickup_health : Int = 0

///|
pub let pickup_ammo : Int = 1

///|
pub let pickup_speed_boost : Int = 2

///|
pub let pickup_damage_boost : Int = 3

///|
pub let pickup_shield : Int = 4

///|
pub let pickup_nuke : Int = 5

// Pickup durations

///|
pub let pickup_speed_duration : Float = 10.0

///|
pub let pickup_damage_duration : Float = 10.0

///|
pub let pickup_shield_duration : Float = 8.0

// Arena trap types

///|
pub let trap_spike : Int = 0

///|
pub let trap_flame : Int = 1

///|
pub let trap_electric : Int = 2

// Trap stats

///|
pub let trap_spike_damage : Float = 30.0

///|
pub let trap_spike_cooldown : Float = 3.0

///|
pub let trap_flame_damage : Float = 15.0

///|
pub let trap_flame_cooldown : Float = 0.5

///|
pub let trap_flame_duration : Float = 2.0

///|
pub let trap_electric_damage : Float = 10.0

///|
pub let trap_electric_cooldown : Float = 4.0

///|
pub let trap_electric_stun : Float = 1.5

// Barricade

///|
pub let barricade_max_hp : Float = 150.0

///|
pub let barricade_size : Float = 2.0

// Combo system

///|
pub let combo_timeout : Float = 3.0

///|
pub let combo_base_mult : Float = 1.0

///|
pub let combo_increment : Float = 0.25

///|
pub let combo_max_mult : Float = 4.0

// Headshot

///|
pub let headshot_mult : Float = 2.5

///|
pub let headshot_head_ratio : Float = 0.2

// Gravity for projectiles

///|
pub let gravity : Float = 9.8

// Exploder

///|
pub let exploder_radius : Float = 4.0

///|
pub let exploder_damage : Float = 40.0

// Necromancer

///|
pub let necro_revive_range : Float = 12.0

///|
pub let necro_revive_cooldown : Float = 8.0

// Shield enemy

///|
pub let shield_block_angle : Float = 1.2

// Score bonuses

///|
pub let bonus_headshot : Int = 25

///|
pub let bonus_double_kill : Int = 50

///|
pub let bonus_triple_kill : Int = 100

///|
pub let bonus_multi_kill : Int = 200

// Kill feed

///|
pub let kill_feed_duration : Float = 3.0

// Particle types (used as kind tag)

///|
pub let particle_blood : Int = 0

///|
pub let particle_muzzle : Int = 1

///|
pub let particle_explosion : Int = 2

///|
pub let particle_shell : Int = 3

///|
pub let particle_spark : Int = 4

///|
pub let particle_heal : Int = 5

// PI constant

///|
pub let pi : Float = 3.14159265

// Minimap

///|
pub let minimap_size : Int = 140

///|
pub let minimap_x : Int = 1120

///|
pub let minimap_y : Int = 60

// Difficulty scaling per wave

///|
pub let difficulty_hp_scale : Float = 0.06

///|
pub let difficulty_speed_scale : Float = 0.02

///|
pub let difficulty_damage_scale : Float = 0.04
