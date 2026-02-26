///|
struct Enemy {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut hp : Float
  mut max_hp : Float
  mut radius : Float
  mut speed : Float
  mut state : Int
  mut state_t : Float
  mut telegraph_total_t : Float
  mut visual_phase : Float
}

///|
struct Game {
  enemies : Array[Enemy]
  mut state : Int
  mut player_x : Float
  mut player_y : Float
  mut player_vx : Float
  mut player_vy : Float
  mut facing_x : Float
  mut facing_y : Float
  mut move_x : Float
  mut move_y : Float
  mut health : Float
  mut stamina : Float
  mut invuln_t : Float
  mut parry_t : Float
  mut dash_t_left : Float
  mut dash_dir_x : Float
  mut dash_dir_y : Float
  mut attack_cd : Float
  mut attack_anim_t : Float
  mut attack_kind : Int
  mut wave : Int
  mut wave_enemies_total : Int
  mut wave_spawned : Int
  mut wave_defeated : Int
  mut spawn_cd : Float
  mut wave_gap_t : Float
  mut stage_score : Int
  mut last_stage_bonus : Int
  mut combo : Int
  mut combo_t : Float
  mut score : Int
  mut best_score : Int
  mut game_t : Float
  mut ui_t : Float
  mut shake_t : Float
  mut message : String
  mut message_t : Float
}

///|
fn Enemy::new() -> Enemy {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    hp: 0.0,
    max_hp: 0.0,
    radius: 20.0,
    speed: 0.0,
    state: enemy_state_seek,
    state_t: 0.0,
    telegraph_total_t: 0.0,
    visual_phase: 0.0,
  }
}

///|
fn Game::new() -> Game {
  {
    enemies: Array::makei(max_enemy_slots, fn(_i) { Enemy::new() }),
    state: state_title,
    player_x: arena_center_x(),
    player_y: arena_center_y() + 130.0,
    player_vx: 0.0,
    player_vy: 0.0,
    facing_x: 1.0,
    facing_y: 0.0,
    move_x: 0.0,
    move_y: 0.0,
    health: player_max_health,
    stamina: player_max_stamina,
    invuln_t: 0.0,
    parry_t: 0.0,
    dash_t_left: 0.0,
    dash_dir_x: 1.0,
    dash_dir_y: 0.0,
    attack_cd: 0.0,
    attack_anim_t: 0.0,
    attack_kind: attack_none,
    wave: 1,
    wave_enemies_total: 0,
    wave_spawned: 0,
    wave_defeated: 0,
    spawn_cd: 0.0,
    wave_gap_t: 0.0,
    stage_score: 0,
    last_stage_bonus: 0,
    combo: 0,
    combo_t: 0.0,
    score: 0,
    best_score: 0,
    game_t: 0.0,
    ui_t: 0.0,
    shake_t: 0.0,
    message: "",
    message_t: 0.0,
  }
}
