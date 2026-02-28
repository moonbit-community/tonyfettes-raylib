///|
pub(all) struct StageProfile {
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
pub fn StageProfile::new(
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
pub fn default_stage_profile() -> StageProfile {
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
