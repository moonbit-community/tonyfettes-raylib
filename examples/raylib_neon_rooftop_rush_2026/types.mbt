///|
struct Segment {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut w : Float
  mut h : Float
  mut skin : Int
  mut neon : Int
  mut window_seed : Int
}

///|
struct Obstacle {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut w : Float
  mut h : Float
  mut vx : Float
  mut phase : Float
  mut hit_lock : Float
}

///|
struct Chip {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut bob_t : Float
  mut spin_t : Float
}

///|
struct Anchor {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut glow_t : Float
}

///|
struct Particle {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut life : Float
  mut size : Float
  mut kind : Int
}

///|
struct Ghost {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut w : Float
  mut h : Float
  mut life : Float
  mut hue : Float
}

///|
struct Player {
  mut x : Float
  mut y : Float
  mut w : Float
  mut h : Float
  mut vy : Float
  mut grounded : Bool
  mut coyote_t : Float
  mut jump_buf_t : Float
  mut air_jumps : Int
  mut slide_t : Float
  mut grapple_t : Float
  mut grapple_target_y : Float
  mut invuln_t : Float
  mut hurt_t : Float
  mut anim_t : Float
  mut floor_y : Float
}

///|
struct Game {
  segments : Array[Segment]
  obstacles : Array[Obstacle]
  chips : Array[Chip]
  anchors : Array[Anchor]
  particles : Array[Particle]
  ghosts : Array[Ghost]
  hero : Player
  mut state : Int
  mut title_t : Float
  mut stage_intro_t : Float
  mut time_s : Float
  mut speed : Float
  mut distance : Float
  mut score : Int
  mut best_score : Int
  mut chips_collected : Int
  mut combo : Int
  mut combo_t : Float
  mut stage : Int
  mut stage_goal : Float
  mut stage_progress : Float
  mut health : Float
  mut stamina : Float
  mut shake_t : Float
  mut flash_t : Float
  mut last_segment_end : Float
  mut hint_t : Float
  mut result_t : Float
  mut stage_clear_bonus : Int
  mut input_jump_press : Bool
  mut input_jump_hold : Bool
  mut input_slide_hold : Bool
  mut input_grapple_press : Bool
  mut input_pause_press : Bool
  mut input_restart_press : Bool
  mut touch_mode : Bool
  mut touch_count : Int
  mut touch_jump_prev : Bool
  mut touch_grapple_prev : Bool
  mut touch_restart_prev : Bool
  mut pointer_x : Float
  mut pointer_y : Float
}

///|
fn Segment::new() -> Segment {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    w: 0.0,
    h: 0.0,
    skin: 0,
    neon: 0,
    window_seed: 0,
  }
}

///|
fn Obstacle::new() -> Obstacle {
  {
    active: false,
    kind: obstacle_vent,
    x: 0.0,
    y: 0.0,
    w: 0.0,
    h: 0.0,
    vx: 0.0,
    phase: 0.0,
    hit_lock: 0.0,
  }
}

///|
fn Chip::new() -> Chip {
  { active: false, x: 0.0, y: 0.0, bob_t: 0.0, spin_t: 0.0 }
}

///|
fn Anchor::new() -> Anchor {
  { active: false, x: 0.0, y: 0.0, glow_t: 0.0 }
}

///|
fn Particle::new() -> Particle {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    life: 0.0,
    size: 0.0,
    kind: 0,
  }
}

///|
fn Ghost::new() -> Ghost {
  { active: false, x: 0.0, y: 0.0, w: 0.0, h: 0.0, life: 0.0, hue: 0.0 }
}

///|
fn Player::new() -> Player {
  {
    x: player_spawn_x,
    y: player_spawn_y,
    w: 64.0,
    h: 88.0,
    vy: 0.0,
    grounded: false,
    coyote_t: 0.0,
    jump_buf_t: 0.0,
    air_jumps: 1,
    slide_t: 0.0,
    grapple_t: 0.0,
    grapple_target_y: 0.0,
    invuln_t: 0.0,
    hurt_t: 0.0,
    anim_t: 0.0,
    floor_y: 460.0,
  }
}

///|
fn Game::new() -> Game {
  {
    segments: Array::makei(max_segments, fn(_i) { Segment::new() }),
    obstacles: Array::makei(max_obstacles, fn(_i) { Obstacle::new() }),
    chips: Array::makei(max_chips, fn(_i) { Chip::new() }),
    anchors: Array::makei(max_anchors, fn(_i) { Anchor::new() }),
    particles: Array::makei(max_particles, fn(_i) { Particle::new() }),
    ghosts: Array::makei(96, fn(_i) { Ghost::new() }),
    hero: Player::new(),
    state: state_title,
    title_t: 0.0,
    stage_intro_t: stage_intro_time,
    time_s: 0.0,
    speed: base_scroll_speed,
    distance: 0.0,
    score: 0,
    best_score: 0,
    chips_collected: 0,
    combo: 0,
    combo_t: 0.0,
    stage: 1,
    stage_goal: stage_base_goal,
    stage_progress: 0.0,
    health: 100.0,
    stamina: 100.0,
    shake_t: 0.0,
    flash_t: 0.0,
    last_segment_end: 0.0,
    hint_t: 0.0,
    result_t: 0.0,
    stage_clear_bonus: 0,
    input_jump_press: false,
    input_jump_hold: false,
    input_slide_hold: false,
    input_grapple_press: false,
    input_pause_press: false,
    input_restart_press: false,
    touch_mode: false,
    touch_count: 0,
    touch_jump_prev: false,
    touch_grapple_prev: false,
    touch_restart_prev: false,
    pointer_x: 0.0,
    pointer_y: 0.0,
  }
}
