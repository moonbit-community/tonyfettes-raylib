///|
let asset_root = "raylib_tank_1990/_asset_candidates"

///|
let shooter_tile_dir = "\{asset_root}/kenney_top-down-shooter/PNG/Tiles"

///|
let tank_dir = "\{asset_root}/kenney_top-down-tanks-redux/PNG/Default size"

///|
let particle_dir = "\{asset_root}/kenney_particle-pack/PNG (Transparent)"

///|
let ui_blue_dir = "\{asset_root}/kenney_ui-pack/PNG/Blue/Default"

///|
let ui_extra_dir = "\{asset_root}/kenney_ui-pack/PNG/Extra/Default"

///|
let ui_font_path = "\{asset_root}/kenney_ui-pack/Font/Kenney Future.ttf"

///|
priv struct RenderAssets {
  mut loaded : Bool
  mut ui_font : @raylib.Font?
  mut ui_panel_card : @raylib.Texture?
  mut ui_panel_line : @raylib.Texture?
  mut ui_menu_button : @raylib.Texture?
  mut ui_menu_button_focus : @raylib.Texture?
  mut ui_icon_arrow_up : @raylib.Texture?
  mut ui_icon_arrow_down : @raylib.Texture?
  mut ui_icon_play : @raylib.Texture?
  mut tile_brick : Array[@raylib.Texture]
  mut tile_steel : Array[@raylib.Texture]
  mut tile_water : Array[@raylib.Texture]
  mut tile_bush : Array[@raylib.Texture]
  mut tile_ice : Array[@raylib.Texture]
  mut tracks_small : @raylib.Texture?
  mut enemy_marker : @raylib.Texture?
  mut body_p1 : @raylib.Texture?
  mut body_p2 : @raylib.Texture?
  mut body_enemy_basic : @raylib.Texture?
  mut body_enemy_fast : @raylib.Texture?
  mut body_enemy_heavy : @raylib.Texture?
  mut body_enemy_sniper : @raylib.Texture?
  mut turret_p1 : Array[@raylib.Texture]
  mut turret_p2 : Array[@raylib.Texture]
  mut turret_enemy_basic : @raylib.Texture?
  mut turret_enemy_fast : @raylib.Texture?
  mut turret_enemy_heavy : @raylib.Texture?
  mut turret_enemy_sniper : @raylib.Texture?
  mut bullet_p1 : @raylib.Texture?
  mut bullet_p2 : @raylib.Texture?
  mut bullet_enemy : @raylib.Texture?
  mut explosion_frames : Array[@raylib.Texture]
  mut smoke_frames : Array[@raylib.Texture]
  mut fx_muzzle : @raylib.Texture?
  mut fx_smoke : @raylib.Texture?
  mut fx_trace : @raylib.Texture?
  mut fx_spark : @raylib.Texture?
}

///|
fn RenderAssets::new() -> RenderAssets {
  {
    loaded: false,
    ui_font: None,
    ui_panel_card: None,
    ui_panel_line: None,
    ui_menu_button: None,
    ui_menu_button_focus: None,
    ui_icon_arrow_up: None,
    ui_icon_arrow_down: None,
    ui_icon_play: None,
    tile_brick: [],
    tile_steel: [],
    tile_water: [],
    tile_bush: [],
    tile_ice: [],
    tracks_small: None,
    enemy_marker: None,
    body_p1: None,
    body_p2: None,
    body_enemy_basic: None,
    body_enemy_fast: None,
    body_enemy_heavy: None,
    body_enemy_sniper: None,
    turret_p1: [],
    turret_p2: [],
    turret_enemy_basic: None,
    turret_enemy_fast: None,
    turret_enemy_heavy: None,
    turret_enemy_sniper: None,
    bullet_p1: None,
    bullet_p2: None,
    bullet_enemy: None,
    explosion_frames: [],
    smoke_frames: [],
    fx_muzzle: None,
    fx_smoke: None,
    fx_trace: None,
    fx_spark: None,
  }
}

///|
let assets : RenderAssets = RenderAssets::new()

///|
fn load_texture_opt(path : String) -> @raylib.Texture? {
  let texture = @raylib.load_texture(path)
  if @raylib.is_texture_valid(texture) {
    @raylib.set_texture_filter(texture, @raylib.TextureFilterPoint)
    Some(texture)
  } else {
    None
  }
}

///|
fn load_texture_list(
  prefix : String,
  files : Array[String],
) -> Array[@raylib.Texture] {
  let textures : Array[@raylib.Texture] = []
  for i = 0; i < files.length(); i = i + 1 {
    let path = "\{prefix}/\{files[i]}"
    match load_texture_opt(path) {
      Some(texture) => textures.push(texture)
      None => ()
    }
  }
  textures
}

///|
fn unload_texture_opt(texture : @raylib.Texture?) -> Unit {
  match texture {
    Some(tex) => @raylib.unload_texture(tex)
    None => ()
  }
}

///|
fn unload_texture_list(textures : Array[@raylib.Texture]) -> Unit {
  for i = 0; i < textures.length(); i = i + 1 {
    @raylib.unload_texture(textures[i])
  }
}

///|
pub fn init_assets() -> Unit {
  if assets.loaded {
    return
  }

  assets.tile_brick = load_texture_list(shooter_tile_dir, [
    "tile_109.png", "tile_111.png", "tile_115.png", "tile_116.png", "tile_118.png",
    "tile_120.png", "tile_123.png", "tile_124.png",
  ])
  assets.tile_steel = load_texture_list(shooter_tile_dir, [
    "tile_57.png", "tile_58.png", "tile_59.png", "tile_60.png", "tile_89.png", "tile_90.png",
    "tile_91.png", "tile_92.png",
  ])
  assets.tile_water = load_texture_list(shooter_tile_dir, [
    "tile_197.png", "tile_198.png", "tile_199.png", "tile_200.png", "tile_211.png",
    "tile_212.png", "tile_213.png", "tile_214.png",
  ])
  assets.tile_bush = load_texture_list(shooter_tile_dir, [
    "tile_440.png", "tile_441.png", "tile_443.png", "tile_475.png", "tile_477.png",
    "tile_478.png", "tile_927.png", "tile_928.png",
  ])
  assets.tile_ice = load_texture_list(shooter_tile_dir, [
    "tile_235.png", "tile_236.png", "tile_237.png", "tile_238.png", "tile_271.png",
    "tile_272.png", "tile_273.png", "tile_274.png",
  ])

  assets.body_p1 = load_texture_opt("\{tank_dir}/tankBody_blue.png")
  assets.body_p2 = load_texture_opt("\{tank_dir}/tankBody_sand.png")
  assets.body_enemy_basic = load_texture_opt("\{tank_dir}/tankBody_green.png")
  assets.body_enemy_fast = load_texture_opt("\{tank_dir}/tankBody_red.png")
  assets.body_enemy_heavy = load_texture_opt(
    "\{tank_dir}/tankBody_darkLarge.png",
  )
  assets.body_enemy_sniper = load_texture_opt("\{tank_dir}/tankBody_bigRed.png")

  assets.turret_p1 = load_texture_list(tank_dir, [
    "tankBlue_barrel1.png", "tankBlue_barrel2.png", "tankBlue_barrel3.png",
  ])
  assets.turret_p2 = load_texture_list(tank_dir, [
    "tankSand_barrel1.png", "tankSand_barrel2.png", "tankSand_barrel3.png",
  ])
  assets.turret_enemy_basic = load_texture_opt(
    "\{tank_dir}/tankGreen_barrel1.png",
  )
  assets.turret_enemy_fast = load_texture_opt("\{tank_dir}/tankRed_barrel2.png")
  assets.turret_enemy_heavy = load_texture_opt(
    "\{tank_dir}/tankDark_barrel3.png",
  )
  assets.turret_enemy_sniper = load_texture_opt(
    "\{tank_dir}/tankRed_barrel3.png",
  )

  assets.tracks_small = load_texture_opt("\{tank_dir}/tracksSmall.png")
  assets.enemy_marker = load_texture_opt("\{tank_dir}/tank_red.png")

  assets.bullet_p1 = load_texture_opt("\{tank_dir}/bulletBlue2.png")
  assets.bullet_p2 = load_texture_opt("\{tank_dir}/bulletSand2.png")
  assets.bullet_enemy = load_texture_opt("\{tank_dir}/bulletRed2.png")

  assets.explosion_frames = load_texture_list(tank_dir, [
    "explosion1.png", "explosion2.png", "explosion3.png", "explosion4.png", "explosion5.png",
  ])
  assets.smoke_frames = load_texture_list(tank_dir, [
    "explosionSmoke1.png", "explosionSmoke2.png", "explosionSmoke3.png", "explosionSmoke4.png",
    "explosionSmoke5.png",
  ])

  assets.fx_muzzle = load_texture_opt("\{particle_dir}/muzzle_01.png")
  assets.fx_smoke = load_texture_opt("\{particle_dir}/smoke_01.png")
  assets.fx_trace = load_texture_opt("\{particle_dir}/trace_01.png")
  assets.fx_spark = load_texture_opt("\{particle_dir}/spark_01.png")

  assets.ui_panel_card = load_texture_opt(
    "\{ui_blue_dir}/button_rectangle_depth_flat.png",
  )
  assets.ui_panel_line = load_texture_opt(
    "\{ui_blue_dir}/button_rectangle_depth_line.png",
  )
  assets.ui_menu_button = load_texture_opt(
    "\{ui_blue_dir}/button_rectangle_gloss.png",
  )
  assets.ui_menu_button_focus = load_texture_opt(
    "\{ui_blue_dir}/button_rectangle_depth_gradient.png",
  )
  assets.ui_icon_arrow_up = load_texture_opt(
    "\{ui_extra_dir}/icon_arrow_up_light.png",
  )
  assets.ui_icon_arrow_down = load_texture_opt(
    "\{ui_extra_dir}/icon_arrow_down_light.png",
  )
  assets.ui_icon_play = load_texture_opt("\{ui_extra_dir}/icon_play_light.png")

  let ui_font = @raylib.load_font_ex(ui_font_path, 48)
  if @raylib.is_font_valid(ui_font) {
    @raylib.set_font_texture_filter(ui_font, @raylib.TextureFilterBilinear)
    assets.ui_font = Some(ui_font)
  }

  assets.loaded = true
}

///|
pub fn unload_assets() -> Unit {
  if not(assets.loaded) {
    return
  }

  unload_texture_list(assets.tile_brick)
  unload_texture_list(assets.tile_steel)
  unload_texture_list(assets.tile_water)
  unload_texture_list(assets.tile_bush)
  unload_texture_list(assets.tile_ice)

  unload_texture_opt(assets.body_p1)
  unload_texture_opt(assets.body_p2)
  unload_texture_opt(assets.body_enemy_basic)
  unload_texture_opt(assets.body_enemy_fast)
  unload_texture_opt(assets.body_enemy_heavy)
  unload_texture_opt(assets.body_enemy_sniper)

  unload_texture_list(assets.turret_p1)
  unload_texture_list(assets.turret_p2)
  unload_texture_opt(assets.turret_enemy_basic)
  unload_texture_opt(assets.turret_enemy_fast)
  unload_texture_opt(assets.turret_enemy_heavy)
  unload_texture_opt(assets.turret_enemy_sniper)

  unload_texture_opt(assets.tracks_small)
  unload_texture_opt(assets.enemy_marker)

  unload_texture_opt(assets.bullet_p1)
  unload_texture_opt(assets.bullet_p2)
  unload_texture_opt(assets.bullet_enemy)

  unload_texture_list(assets.explosion_frames)
  unload_texture_list(assets.smoke_frames)

  unload_texture_opt(assets.fx_muzzle)
  unload_texture_opt(assets.fx_smoke)
  unload_texture_opt(assets.fx_trace)
  unload_texture_opt(assets.fx_spark)

  unload_texture_opt(assets.ui_panel_card)
  unload_texture_opt(assets.ui_panel_line)
  unload_texture_opt(assets.ui_menu_button)
  unload_texture_opt(assets.ui_menu_button_focus)
  unload_texture_opt(assets.ui_icon_arrow_up)
  unload_texture_opt(assets.ui_icon_arrow_down)
  unload_texture_opt(assets.ui_icon_play)

  match assets.ui_font {
    Some(font) => @raylib.unload_font(font)
    None => ()
  }

  assets.tile_brick = []
  assets.tile_steel = []
  assets.tile_water = []
  assets.tile_bush = []
  assets.tile_ice = []

  assets.turret_p1 = []
  assets.turret_p2 = []
  assets.explosion_frames = []
  assets.smoke_frames = []

  assets.ui_font = None
  assets.ui_panel_card = None
  assets.ui_panel_line = None
  assets.ui_menu_button = None
  assets.ui_menu_button_focus = None
  assets.ui_icon_arrow_up = None
  assets.ui_icon_arrow_down = None
  assets.ui_icon_play = None

  assets.tracks_small = None
  assets.enemy_marker = None

  assets.body_p1 = None
  assets.body_p2 = None
  assets.body_enemy_basic = None
  assets.body_enemy_fast = None
  assets.body_enemy_heavy = None
  assets.body_enemy_sniper = None

  assets.turret_enemy_basic = None
  assets.turret_enemy_fast = None
  assets.turret_enemy_heavy = None
  assets.turret_enemy_sniper = None

  assets.bullet_p1 = None
  assets.bullet_p2 = None
  assets.bullet_enemy = None

  assets.fx_muzzle = None
  assets.fx_smoke = None
  assets.fx_trace = None
  assets.fx_spark = None

  assets.loaded = false
}

///|
fn pick_texture(
  textures : Array[@raylib.Texture],
  seed : Int,
) -> @raylib.Texture? {
  let len = textures.length()
  if len == 0 {
    return None
  }
  let idx = if seed >= 0 { seed % len } else { -seed % len }
  Some(textures[idx])
}

///|
fn pick_turret(
  textures : Array[@raylib.Texture],
  level : Int,
) -> @raylib.Texture? {
  let len = textures.length()
  if len == 0 {
    return None
  }
  let idx = @types.clampi(level, 0, len - 1)
  Some(textures[idx])
}

///|
pub fn tile_texture(
  tile : Int,
  tx : Int,
  ty : Int,
  frame_counter : Int,
) -> @raylib.Texture? {
  if tile == @types.tile_brick {
    pick_texture(assets.tile_brick, tx * 31 + ty * 17)
  } else if tile == @types.tile_steel {
    pick_texture(assets.tile_steel, tx * 13 + ty * 19)
  } else if tile == @types.tile_water {
    pick_texture(assets.tile_water, frame_counter / 8 + tx * 7 + ty * 11)
  } else if tile == @types.tile_bush {
    pick_texture(assets.tile_bush, tx * 5 + ty * 9)
  } else if tile == @types.tile_ice {
    pick_texture(assets.tile_ice, tx * 3 + ty * 7)
  } else {
    None
  }
}

///|
pub fn player_body_texture(index : Int) -> @raylib.Texture? {
  if index == 0 {
    assets.body_p1
  } else {
    assets.body_p2
  }
}

///|
pub fn player_turret_texture(
  index : Int,
  weapon_level : Int,
) -> @raylib.Texture? {
  if index == 0 {
    pick_turret(assets.turret_p1, weapon_level)
  } else {
    pick_turret(assets.turret_p2, weapon_level)
  }
}

///|
pub fn enemy_body_texture(kind : Int) -> @raylib.Texture? {
  if kind == @types.enemy_fast {
    assets.body_enemy_fast
  } else if kind == @types.enemy_heavy {
    assets.body_enemy_heavy
  } else if kind == @types.enemy_sniper {
    assets.body_enemy_sniper
  } else {
    assets.body_enemy_basic
  }
}

///|
pub fn enemy_turret_texture(kind : Int) -> @raylib.Texture? {
  if kind == @types.enemy_fast {
    assets.turret_enemy_fast
  } else if kind == @types.enemy_heavy {
    assets.turret_enemy_heavy
  } else if kind == @types.enemy_sniper {
    assets.turret_enemy_sniper
  } else {
    assets.turret_enemy_basic
  }
}

///|
pub fn bullet_texture(team : Int) -> @raylib.Texture? {
  if team == @types.team_enemy {
    assets.bullet_enemy
  } else if team == @types.team_player2 {
    assets.bullet_p2
  } else {
    assets.bullet_p1
  }
}

///|
pub fn tracks_texture() -> @raylib.Texture? {
  assets.tracks_small
}

///|
pub fn enemy_marker_texture() -> @raylib.Texture? {
  assets.enemy_marker
}

///|
pub fn explosion_frame(index : Int) -> @raylib.Texture? {
  pick_texture(assets.explosion_frames, index)
}

///|
pub fn smoke_frame(index : Int) -> @raylib.Texture? {
  pick_texture(assets.smoke_frames, index)
}

///|
pub fn fx_muzzle_texture() -> @raylib.Texture? {
  assets.fx_muzzle
}

///|
pub fn fx_smoke_texture() -> @raylib.Texture? {
  assets.fx_smoke
}

///|
pub fn fx_trace_texture() -> @raylib.Texture? {
  assets.fx_trace
}

///|
pub fn fx_spark_texture() -> @raylib.Texture? {
  assets.fx_spark
}

///|
pub fn ui_panel_card_texture() -> @raylib.Texture? {
  assets.ui_panel_card
}

///|
pub fn ui_panel_line_texture() -> @raylib.Texture? {
  assets.ui_panel_line
}

///|
pub fn ui_menu_button_texture() -> @raylib.Texture? {
  assets.ui_menu_button
}

///|
pub fn ui_menu_button_focus_texture() -> @raylib.Texture? {
  assets.ui_menu_button_focus
}

///|
pub fn ui_icon_arrow_up_texture() -> @raylib.Texture? {
  assets.ui_icon_arrow_up
}

///|
pub fn ui_icon_arrow_down_texture() -> @raylib.Texture? {
  assets.ui_icon_arrow_down
}

///|
pub fn ui_icon_play_texture() -> @raylib.Texture? {
  assets.ui_icon_play
}

///|
pub fn ui_font() -> @raylib.Font? {
  assets.ui_font
}

///|
pub fn draw_texture_centered(
  texture : @raylib.Texture,
  center_x : Float,
  center_y : Float,
  width : Float,
  height : Float,
  rotation : Float,
  tint : @raylib.Color,
) -> Unit {
  let src = @raylib.Rectangle::new(
    0.0,
    0.0,
    Float::from_int(@raylib.get_texture_width(texture)),
    Float::from_int(@raylib.get_texture_height(texture)),
  )
  let dst = @raylib.Rectangle::new(
    center_x - width * 0.5,
    center_y - height * 0.5,
    width,
    height,
  )
  @raylib.draw_texture_pro(
    texture,
    src,
    dst,
    @raylib.Vector2::new(width * 0.5, height * 0.5),
    rotation,
    tint,
  )
}

///|
pub fn draw_texture_centered_opt(
  texture : @raylib.Texture?,
  center_x : Float,
  center_y : Float,
  width : Float,
  height : Float,
  rotation : Float,
  tint : @raylib.Color,
) -> Bool {
  match texture {
    Some(tex) => {
      draw_texture_centered(
        tex, center_x, center_y, width, height, rotation, tint,
      )
      true
    }
    None => false
  }
}

///|
pub fn draw_texture_box_opt(
  texture : @raylib.Texture?,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
  tint : @raylib.Color,
) -> Bool {
  draw_texture_centered_opt(
    texture,
    Float::from_int(x + width / 2),
    Float::from_int(y + height / 2),
    Float::from_int(width),
    Float::from_int(height),
    0.0,
    tint,
  )
}

///|
pub fn draw_text_shadow(
  text : String,
  x : Int,
  y : Int,
  size : Int,
  color : @raylib.Color,
) -> Unit {
  match assets.ui_font {
    Some(font) => {
      let pos_shadow = @raylib.Vector2::new(
        Float::from_int(x + 2),
        Float::from_int(y + 2),
      )
      let pos = @raylib.Vector2::new(Float::from_int(x), Float::from_int(y))
      @raylib.draw_text_ex(
        font,
        text,
        pos_shadow,
        Float::from_int(size),
        1.0,
        @raylib.black,
      )
      @raylib.draw_text_ex(font, text, pos, Float::from_int(size), 1.0, color)
    }
    None => @types.draw_shadow_text(text, x, y, size, color)
  }
}

///|
pub fn draw_text_centered(
  text : String,
  center_x : Int,
  y : Int,
  size : Int,
  color : @raylib.Color,
) -> Unit {
  match assets.ui_font {
    Some(font) => {
      let measure = @raylib.measure_text_ex(
        font,
        text,
        Float::from_int(size),
        1.0,
      )
      let x = center_x - measure.x.to_int() / 2
      draw_text_shadow(text, x, y, size, color)
    }
    None => @types.draw_centered_text(text, center_x, y, size, color)
  }
}
