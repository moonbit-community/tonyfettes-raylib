// ============================================================================
// Image loading
// ============================================================================

#borrow(file_name)
extern "c" fn load_image_ffi(file_name : Bytes) -> Image = "moonbit_LoadImage"

pub fn load_image(file_name : String) -> Image {
  load_image_ffi(@utf8.encode(file_name))
}

#borrow(image)
extern "c" fn unload_image_ffi(image : Image) = "moonbit_UnloadImage"

pub fn unload_image(image : Image) -> Unit {
  unload_image_ffi(image)
}

#borrow(color)
extern "c" fn gen_image_color_ffi(width : Int, height : Int, color : Bytes) -> Image = "moonbit_GenImageColor"

pub fn gen_image_color(width : Int, height : Int, color : Color) -> Image {
  gen_image_color_ffi(width, height, color.to_bytes())
}

#borrow(col1, col2)
extern "c" fn gen_image_checked_ffi(width : Int, height : Int, checks_x : Int, checks_y : Int, col1 : Bytes, col2 : Bytes) -> Image = "moonbit_GenImageChecked"

pub fn gen_image_checked(width : Int, height : Int, checks_x : Int, checks_y : Int, col1 : Color, col2 : Color) -> Image {
  gen_image_checked_ffi(width, height, checks_x, checks_y, col1.to_bytes(), col2.to_bytes())
}

// ============================================================================
// Texture loading
// ============================================================================

#borrow(file_name)
extern "c" fn load_texture_ffi(file_name : Bytes) -> Texture = "moonbit_LoadTexture"

pub fn load_texture(file_name : String) -> Texture {
  load_texture_ffi(@utf8.encode(file_name))
}

#borrow(image)
extern "c" fn load_texture_from_image_ffi(image : Image) -> Texture = "moonbit_LoadTextureFromImage"

pub fn load_texture_from_image(image : Image) -> Texture {
  load_texture_from_image_ffi(image)
}

#borrow(texture)
extern "c" fn is_texture_valid_ffi(texture : Texture) -> Bool = "moonbit_IsTextureValid"

pub fn is_texture_valid(texture : Texture) -> Bool {
  is_texture_valid_ffi(texture)
}

#borrow(texture)
extern "c" fn unload_texture_ffi(texture : Texture) = "moonbit_UnloadTexture"

pub fn unload_texture(texture : Texture) -> Unit {
  unload_texture_ffi(texture)
}

extern "c" fn load_render_texture_ffi(width : Int, height : Int) -> RenderTexture = "moonbit_LoadRenderTexture"

pub fn load_render_texture(width : Int, height : Int) -> RenderTexture {
  load_render_texture_ffi(width, height)
}

#borrow(target)
extern "c" fn is_render_texture_valid_ffi(target : RenderTexture) -> Bool = "moonbit_IsRenderTextureValid"

pub fn is_render_texture_valid(target : RenderTexture) -> Bool {
  is_render_texture_valid_ffi(target)
}

#borrow(target)
extern "c" fn unload_render_texture_ffi(target : RenderTexture) = "moonbit_UnloadRenderTexture"

pub fn unload_render_texture(target : RenderTexture) -> Unit {
  unload_render_texture_ffi(target)
}

// ============================================================================
// Texture drawing
// ============================================================================

#borrow(texture, tint)
extern "c" fn draw_texture_ffi(texture : Texture, pos_x : Int, pos_y : Int, tint : Bytes) = "moonbit_DrawTexture"

pub fn draw_texture(texture : Texture, pos_x : Int, pos_y : Int, tint : Color) -> Unit {
  draw_texture_ffi(texture, pos_x, pos_y, tint.to_bytes())
}

#borrow(texture, position, tint)
extern "c" fn draw_texture_v_ffi(texture : Texture, position : Bytes, tint : Bytes) = "moonbit_DrawTextureV"

pub fn draw_texture_v(texture : Texture, position : Vector2, tint : Color) -> Unit {
  draw_texture_v_ffi(texture, position.to_bytes(), tint.to_bytes())
}

#borrow(texture, position, tint)
extern "c" fn draw_texture_ex_ffi(texture : Texture, position : Bytes, rotation : Float, scale : Float, tint : Bytes) = "moonbit_DrawTextureEx"

pub fn draw_texture_ex(texture : Texture, position : Vector2, rotation : Float, scale : Float, tint : Color) -> Unit {
  draw_texture_ex_ffi(texture, position.to_bytes(), rotation, scale, tint.to_bytes())
}

#borrow(texture, source, position, tint)
extern "c" fn draw_texture_rec_ffi(texture : Texture, source : Bytes, position : Bytes, tint : Bytes) = "moonbit_DrawTextureRec"

pub fn draw_texture_rec(texture : Texture, source : Rectangle, position : Vector2, tint : Color) -> Unit {
  draw_texture_rec_ffi(texture, source.to_bytes(), position.to_bytes(), tint.to_bytes())
}

#borrow(texture, source, dest, origin, tint)
extern "c" fn draw_texture_pro_ffi(texture : Texture, source : Bytes, dest : Bytes, origin : Bytes, rotation : Float, tint : Bytes) = "moonbit_DrawTexturePro"

pub fn draw_texture_pro(texture : Texture, source : Rectangle, dest : Rectangle, origin : Vector2, rotation : Float, tint : Color) -> Unit {
  draw_texture_pro_ffi(texture, source.to_bytes(), dest.to_bytes(), origin.to_bytes(), rotation, tint.to_bytes())
}
