pub(all) struct Platform {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut z : Float
  mut w : Float
  mut h : Float
  mut d : Float
  // Movement
  mut move_speed : Float
  mut move_range : Float
  mut move_timer : Float
  mut base_x : Float
  mut base_y : Float
  mut base_z : Float
  // Falling
  mut fall_timer : Float
  mut falling : Bool
  mut touched : Bool
  // Crumbling
  mut crumble_timer : Float
  mut crumbling : Bool
  // Phasing
  mut phase_timer : Float
  mut phase_visible : Bool
  // Rotation angle
  mut rot_angle : Float
  // Color
  mut r : Int
  mut g : Int
  mut b : Int
}

pub fn Platform::inactive() -> Platform {
  {
    active: false, kind: plat_static, x: 0.0, y: 0.0, z: 0.0,
    w: 2.0, h: 0.3, d: 2.0, move_speed: 2.0, move_range: 3.0,
    move_timer: 0.0, base_x: 0.0, base_y: 0.0, base_z: 0.0,
    fall_timer: 0.0, falling: false, touched: false,
    crumble_timer: 0.0, crumbling: false,
    phase_timer: 0.0, phase_visible: true, rot_angle: 0.0,
    r: 100, g: 100, b: 120,
  }
}

pub(all) struct Enemy {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut z : Float
  mut vx : Float
  mut vy : Float
  mut vz : Float
  mut base_x : Float
  mut base_y : Float
  mut base_z : Float
  mut patrol_range : Float
  mut patrol_dir : Float
  mut timer : Float
  mut health : Int
  mut stunned : Bool
  mut stun_timer : Float
  mut anim_timer : Float
  mut size : Float
  mut r : Int
  mut g : Int
  mut b : Int
}

pub fn Enemy::inactive() -> Enemy {
  {
    active: false, kind: enemy_patrol, x: 0.0, y: 0.0, z: 0.0,
    vx: 0.0, vy: 0.0, vz: 0.0,
    base_x: 0.0, base_y: 0.0, base_z: 0.0,
    patrol_range: 3.0, patrol_dir: 1.0, timer: 0.0,
    health: 1, stunned: false, stun_timer: 0.0, anim_timer: 0.0,
    size: enemy_size, r: 200, g: 60, b: 60,
  }
}

pub(all) struct Collectible {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut z : Float
  mut bob_timer : Float
  mut spin_timer : Float
  mut collected : Bool
  mut magnet_target : Bool
}

pub fn Collectible::inactive() -> Collectible {
  {
    active: false, kind: collect_gem, x: 0.0, y: 0.0, z: 0.0,
    bob_timer: 0.0, spin_timer: 0.0, collected: false, magnet_target: false,
  }
}

pub(all) struct PowerUp {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut z : Float
  mut bob_timer : Float
  mut spin_timer : Float
  mut collected : Bool
}

pub fn PowerUp::inactive() -> PowerUp {
  {
    active: false, kind: powerup_double_jump, x: 0.0, y: 0.0, z: 0.0,
    bob_timer: 0.0, spin_timer: 0.0, collected: false,
  }
}

pub(all) struct Hazard {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut z : Float
  mut w : Float
  mut h : Float
  mut d : Float
  mut timer : Float
  mut phase : Float
  mut on : Bool
  mut base_x : Float
  mut base_y : Float
  mut move_range : Float
  mut move_speed : Float
}

pub fn Hazard::inactive() -> Hazard {
  {
    active: false, kind: hazard_spike, x: 0.0, y: 0.0, z: 0.0,
    w: 1.0, h: 1.0, d: 1.0, timer: 0.0, phase: 0.0, on: true,
    base_x: 0.0, base_y: 0.0, move_range: 0.0, move_speed: 0.0,
  }
}

pub(all) struct Checkpoint {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut z : Float
  mut activated : Bool
  mut anim_timer : Float
}

pub fn Checkpoint::inactive() -> Checkpoint {
  { active: false, x: 0.0, y: 0.0, z: 0.0, activated: false, anim_timer: 0.0 }
}

pub(all) struct Particle {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut z : Float
  mut vx : Float
  mut vy : Float
  mut vz : Float
  mut life : Float
  mut max_life : Float
  mut r : Int
  mut g : Int
  mut b : Int
  mut size : Float
  mut kind : Int
}

pub fn Particle::inactive() -> Particle {
  {
    active: false, x: 0.0, y: 0.0, z: 0.0,
    vx: 0.0, vy: 0.0, vz: 0.0, life: 0.0, max_life: 1.0,
    r: 255, g: 255, b: 255, size: 0.05, kind: 0,
  }
}

pub(all) struct Decoration {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut z : Float
  mut scale : Float
  mut rot_y : Float
  mut r : Int
  mut g : Int
  mut b : Int
}

pub fn Decoration::inactive() -> Decoration {
  {
    active: false, kind: deco_tree, x: 0.0, y: 0.0, z: 0.0,
    scale: 1.0, rot_y: 0.0, r: 100, g: 160, b: 60,
  }
}

pub(all) struct Projectile {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut z : Float
  mut vx : Float
  mut vy : Float
  mut vz : Float
  mut life : Float
  mut r : Int
  mut g : Int
  mut b : Int
}

pub fn Projectile::inactive() -> Projectile {
  {
    active: false, kind: proj_enemy_shot, x: 0.0, y: 0.0, z: 0.0,
    vx: 0.0, vy: 0.0, vz: 0.0, life: 0.0, r: 255, g: 100, b: 50,
  }
}

pub(all) struct ScoreFly {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut value : Int
  mut timer : Float
  mut max_time : Float
}

pub fn ScoreFly::inactive() -> ScoreFly {
  { active: false, x: 0.0, y: 0.0, value: 0, timer: 0.0, max_time: 1.0 }
}

pub(all) struct Game {
  mut state : Int

  // Player
  mut px : Float
  mut py : Float
  mut pz : Float
  mut vx : Float
  mut vy : Float
  mut vz : Float
  mut grounded : Bool
  mut coyote_timer : Float
  mut jump_buffer_timer : Float
  mut on_ice : Bool
  mut lives : Int
  mut score : Int
  mut gems_collected : Int
  mut gems_total : Int
  mut stars_collected : Int
  mut facing_x : Float
  mut facing_z : Float

  // Double jump
  mut has_double_jump : Bool
  mut double_jumped : Bool
  mut can_wall_jump : Bool
  mut wall_dir : Float
  mut wall_slide : Bool

  // Dash
  mut dash_timer : Float
  mut dash_cooldown_timer : Float
  mut dash_dir_x : Float
  mut dash_dir_z : Float
  mut dashing : Bool

  // Invincibility
  mut invincible_timer : Float

  // Power-ups
  mut powerup_type : Int
  mut powerup_timer : Float
  mut has_shield : Bool

  // Combo
  mut combo_count : Int
  mut combo_timer : Float
  mut combo_mult : Float

  // Deaths in level
  mut level_deaths : Int
  mut level_time : Float

  // Coins collected
  mut coins_collected : Int
  mut keys_collected : Int
  mut total_coins : Int
  mut total_keys : Int

  // Checkpoint
  mut checkpoint_x : Float
  mut checkpoint_y : Float
  mut checkpoint_z : Float
  mut checkpoint_active : Bool

  // Camera
  mut cam_x : Float
  mut cam_y : Float
  mut cam_z : Float
  mut cam_angle : Float
  mut cam_dist : Float
  mut cam_shake : Float
  mut cam_shake_timer : Float

  // Level
  mut current_world : Int
  mut current_level : Int
  mut goal_x : Float
  mut goal_y : Float
  mut goal_z : Float

  // Entity pools
  platforms : Array[Platform]
  collectibles : Array[Collectible]
  hazards : Array[Hazard]
  checkpoints : Array[Checkpoint]
  particles : Array[Particle]
  enemies : Array[Enemy]
  powerups : Array[PowerUp]
  decorations : Array[Decoration]
  projectiles : Array[Projectile]
  score_flies : Array[ScoreFly]

  // UI
  mut menu_cursor : Int
  mut menu_blink : Float
  mut complete_timer : Float
  mut death_timer : Float
  mut world_select_cursor : Int
  mut level_select_cursor : Int
  mut pause_cursor : Int
  mut ui_fade : Float
  mut world_intro_timer : Float

  // Player animation
  mut anim_walk_timer : Float
  mut anim_land_squash : Float
  mut anim_jump_stretch : Float

  // Level stars earned (0-3 per level)
  level_stars : Array[Int]

  // RNG
  mut rng_state : Int
  mut frame_counter : Int
}

pub fn Game::new() -> Game {
  {
    state: state_menu,
    px: 0.0, py: 2.0, pz: 0.0,
    vx: 0.0, vy: 0.0, vz: 0.0,
    grounded: false, coyote_timer: 0.0, jump_buffer_timer: 0.0,
    on_ice: false, lives: player_max_lives, score: 0, gems_collected: 0, gems_total: 0,
    stars_collected: 0,
    facing_x: 0.0, facing_z: -1.0,
    has_double_jump: false, double_jumped: false,
    can_wall_jump: false, wall_dir: 0.0, wall_slide: false,
    dash_timer: 0.0, dash_cooldown_timer: 0.0,
    dash_dir_x: 0.0, dash_dir_z: 0.0, dashing: false,
    invincible_timer: 0.0,
    powerup_type: -1, powerup_timer: 0.0, has_shield: false,
    combo_count: 0, combo_timer: 0.0, combo_mult: 1.0,
    level_deaths: 0, level_time: 0.0,
    coins_collected: 0, keys_collected: 0, total_coins: 0, total_keys: 0,
    checkpoint_x: 0.0, checkpoint_y: 2.0, checkpoint_z: 0.0,
    checkpoint_active: false,
    cam_x: 0.0, cam_y: 5.0, cam_z: 8.0, cam_angle: 0.0,
    cam_dist: camera_dist, cam_shake: 0.0, cam_shake_timer: 0.0,
    current_world: 0, current_level: 0,
    goal_x: 0.0, goal_y: 0.0, goal_z: 0.0,
    platforms: Array::make(max_platforms, Platform::inactive()),
    collectibles: Array::make(max_collectibles, Collectible::inactive()),
    hazards: Array::make(max_hazards, Hazard::inactive()),
    checkpoints: Array::make(max_checkpoints, Checkpoint::inactive()),
    particles: Array::make(max_particles, Particle::inactive()),
    enemies: Array::make(max_enemies, Enemy::inactive()),
    powerups: Array::make(max_powerups, PowerUp::inactive()),
    decorations: Array::make(max_decorations, Decoration::inactive()),
    projectiles: Array::make(max_projectiles, Projectile::inactive()),
    score_flies: Array::make(32, ScoreFly::inactive()),
    menu_cursor: 0, menu_blink: 0.0, complete_timer: 0.0, death_timer: 0.0,
    world_select_cursor: 0, level_select_cursor: 0,
    pause_cursor: 0, ui_fade: 0.0, world_intro_timer: 0.0,
    anim_walk_timer: 0.0, anim_land_squash: 0.0, anim_jump_stretch: 0.0,
    level_stars: Array::make(total_levels, 0),
    rng_state: 54321, frame_counter: 0,
  }
}
