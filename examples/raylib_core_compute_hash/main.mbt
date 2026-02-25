///|
fn string_to_bytes(s : String) -> Bytes {
  let arr : Array[Byte] = []
  for i in 0..<s.length() {
    let c = s[i].to_int()
    // Simple ASCII-to-byte conversion (sufficient for this example)
    arr.push((c & 0xFF).to_byte())
  }
  Bytes::from_array(arr)
}

///|
fn int_to_hex(n : Int) -> String {
  let hex = "0123456789ABCDEF"
  let mut result = ""
  let u = n.reinterpret_as_uint()
  for i = 7; i >= 0; i = i - 1 {
    let shift = i * 4
    let nibble = ((u >> shift) & 0xFU).reinterpret_as_int()
    result = result + hex[nibble].to_string()
  }
  result
}

///|
fn bytes_to_hex(data : Bytes) -> String {
  let hex = "0123456789ABCDEF"
  let mut result = ""
  for i in 0..<data.length() {
    let b = data[i].to_int().reinterpret_as_uint()
    let hi = ((b >> 4) & 0xFU).reinterpret_as_int()
    let lo = (b & 0xFU).reinterpret_as_int()
    result = result + hex[hi].to_string() + hex[lo].to_string()
  }
  result
}

///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [core] example - compute hash",
  )

  // UI controls variables
  let text_input : Ref[String] = {
    val: "The quick brown fox jumps over the lazy dog.",
  }
  let mut text_box_edit_mode = false
  let mut btn_compute_hashes = false

  // Data hash values
  let mut hash_crc32 = "00000000"
  let mut hash_md5 = "00000000"
  let mut hash_sha1 = "00000000"

  // Base64 encoded data
  let mut base64_text = ""

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    if btn_compute_hashes {
      let data = string_to_bytes(text_input.val)

      // Encode data to Base64 string
      base64_text = @raylib.encode_data_base64(data)

      // Compute CRC32 hash code (4 bytes)
      let crc32 = @raylib.compute_crc32(data)
      hash_crc32 = int_to_hex(crc32)

      // Compute MD5 hash code (16 bytes)
      let md5 = @raylib.compute_md5(data)
      hash_md5 = bytes_to_hex(md5)

      // Compute SHA1 hash code (20 bytes)
      let sha1 = @raylib.compute_sha1(data)
      hash_sha1 = bytes_to_hex(sha1)
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    @raygui.gui_set_style(@raygui.ControlDefault, @raygui.TextSize, 20)
    @raygui.gui_set_style(@raygui.ControlDefault, @raygui.TextSpacing, 2)
    @raygui.gui_label(
      @raylib.Rectangle::new(40.0, 26.0, 720.0, 32.0),
      "INPUT DATA (TEXT):",
    )
    @raygui.gui_set_style(@raygui.ControlDefault, @raygui.TextSpacing, 1)
    @raygui.gui_set_style(@raygui.ControlDefault, @raygui.TextSize, 10)

    if @raygui.gui_text_box(
        @raylib.Rectangle::new(40.0, 64.0, 720.0, 32.0),
        text_input,
        95,
        text_box_edit_mode,
      ) {
      text_box_edit_mode = not(text_box_edit_mode)
    }

    btn_compute_hashes = @raygui.gui_button(
      @raylib.Rectangle::new(40.0, 104.0, 720.0, 32.0),
      "COMPUTE INPUT DATA HASHES",
    )

    @raygui.gui_set_style(@raygui.ControlDefault, @raygui.TextSize, 20)
    @raygui.gui_set_style(@raygui.ControlDefault, @raygui.TextSpacing, 2)
    @raygui.gui_label(
      @raylib.Rectangle::new(40.0, 160.0, 720.0, 32.0),
      "INPUT DATA HASH VALUES:",
    )
    @raygui.gui_set_style(@raygui.ControlDefault, @raygui.TextSpacing, 1)
    @raygui.gui_set_style(@raygui.ControlDefault, @raygui.TextSize, 10)

    @raygui.gui_set_style(@raygui.ControlTextbox, @raygui.TextReadonly, 1)

    @raygui.gui_label(
      @raylib.Rectangle::new(40.0, 200.0, 120.0, 32.0),
      "CRC32 [32 bit]:",
    )
    let crc32_ref : Ref[String] = { val: hash_crc32 }
    @raygui.gui_text_box(
      @raylib.Rectangle::new(160.0, 200.0, 600.0, 32.0),
      crc32_ref,
      120,
      false,
    )
    |> ignore

    @raygui.gui_label(
      @raylib.Rectangle::new(40.0, 236.0, 120.0, 32.0),
      "MD5 [128 bit]:",
    )
    let md5_ref : Ref[String] = { val: hash_md5 }
    @raygui.gui_text_box(
      @raylib.Rectangle::new(160.0, 236.0, 600.0, 32.0),
      md5_ref,
      120,
      false,
    )
    |> ignore

    @raygui.gui_label(
      @raylib.Rectangle::new(40.0, 272.0, 120.0, 32.0),
      "SHA1 [160 bit]:",
    )
    let sha1_ref : Ref[String] = { val: hash_sha1 }
    @raygui.gui_text_box(
      @raylib.Rectangle::new(160.0, 272.0, 600.0, 32.0),
      sha1_ref,
      120,
      false,
    )
    |> ignore

    @raygui.gui_label(
      @raylib.Rectangle::new(40.0, 308.0, 120.0, 32.0),
      "SHA256 [256 bit]:",
    )
    let sha256_ref : Ref[String] = { val: "N/A (not available in raylib 5.5)" }
    @raygui.gui_text_box(
      @raylib.Rectangle::new(160.0, 308.0, 600.0, 32.0),
      sha256_ref,
      120,
      false,
    )
    |> ignore

    // Use draw_text for the focused-style bonus label since GuiState
    // constructors are not accessible from outside the raygui package
    @raylib.draw_text(
      "BONUS - BASE64 ENCODED STRING:", 40, 350, 10, @raylib.blue,
    )
    @raygui.gui_label(
      @raylib.Rectangle::new(40.0, 380.0, 120.0, 32.0),
      "BASE64 ENCODING:",
    )
    let base64_ref : Ref[String] = { val: base64_text }
    @raygui.gui_text_box(
      @raylib.Rectangle::new(160.0, 380.0, 600.0, 32.0),
      base64_ref,
      120,
      false,
    )
    |> ignore

    @raygui.gui_set_style(@raygui.ControlTextbox, @raygui.TextReadonly, 0)

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
