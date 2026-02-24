///|
fn save_storage_value(position : Int, value : Int) -> Bool {
  let data_size = (position + 1) * 4
  let file_data = @raylib.load_file_data("storage.data")
  let new_size = if file_data.length() < data_size {
    data_size
  } else {
    file_data.length()
  }
  let arr : FixedArray[Byte] = FixedArray::make(new_size, b'\x00')
  for i in 0..<file_data.length() {
    arr[i] = file_data[i]
  }
  let offset = position * 4
  arr[offset] = (value & 0xFF).to_byte()
  arr[offset + 1] = ((value >> 8) & 0xFF).to_byte()
  arr[offset + 2] = ((value >> 16) & 0xFF).to_byte()
  arr[offset + 3] = ((value >> 24) & 0xFF).to_byte()
  let new_data = FixedArray::unsafe_reinterpret_as_bytes(arr)
  let success = @raylib.save_file_data("storage.data", new_data, new_size)
  success
}

///|
fn load_storage_value(position : Int) -> Int {
  let data_size = (position + 1) * 4
  let file_data = @raylib.load_file_data("storage.data")
  if file_data.length() < data_size {
    return 0
  }
  let offset = position * 4
  file_data[offset].to_int() |
  (file_data[offset + 1].to_int() << 8) |
  (file_data[offset + 2].to_int() << 16) |
  (file_data[offset + 3].to_int() << 24)
}

///|
fn main {
  @raylib.init_window(
    800, 450, "raylib [core] example - storage save/load values",
  )
  let mut score = 0
  let mut hiscore = 0
  let mut frames_counter = 0
  @raylib.set_target_fps(60)
  while not(@raylib.window_should_close()) {
    if @raylib.is_key_pressed(@raylib.KeyR) {
      score = @raylib.get_random_value(1000, 2000)
      hiscore = @raylib.get_random_value(2000, 4000)
    }
    if @raylib.is_key_pressed(@raylib.KeyEnter) {
      let _ = save_storage_value(0, score)
      let _ = save_storage_value(1, hiscore)
    } else if @raylib.is_key_pressed(@raylib.KeySpace) {
      score = load_storage_value(0)
      hiscore = load_storage_value(1)
    }
    frames_counter += 1
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.draw_text("SCORE: \{score}", 280, 130, 40, @raylib.maroon)
    @raylib.draw_text("HI-SCORE: \{hiscore}", 210, 200, 50, @raylib.black)
    @raylib.draw_text("frames: \{frames_counter}", 10, 10, 20, @raylib.lime)
    @raylib.draw_text(
      "Press R to generate random numbers", 220, 40, 20, @raylib.lightgray,
    )
    @raylib.draw_text(
      "Press ENTER to SAVE values", 250, 310, 20, @raylib.lightgray,
    )
    @raylib.draw_text(
      "Press SPACE to LOAD values", 252, 350, 20, @raylib.lightgray,
    )
    @raylib.end_drawing()
  }
  @raylib.close_window()
}
