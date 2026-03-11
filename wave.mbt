///|
struct Wave(@ffi.Wave)

///|
#as_free_fn(is_wave_valid)
pub fn Wave::is_valid(self : Wave) -> Bool {
  @ffi.is_wave_valid(self.0)
}

///|
#as_free_fn(load_sound_from_wave)
pub fn Wave::load_sound(self : Wave) -> Sound {
  @ffi.load_sound_from_wave(self.0)
}

///|
#as_free_fn(unload_wave)
pub fn Wave::unload(self : Wave) -> Unit {
  @ffi.unload_wave(self.0)
}

///|
#as_free_fn(wave_copy)
pub fn Wave::copy(self : Wave) -> Wave {
  @ffi.wave_copy(self.0)
}

///|
#as_free_fn(wave_crop)
pub fn Wave::crop(self : Wave, init_frame : Int, final_frame : Int) -> Unit {
  @ffi.wave_crop(self.0, init_frame, final_frame)
}

///|
#as_free_fn(wave_format)
pub fn Wave::format(
  self : Wave,
  sample_rate : Int,
  sample_size : Int,
  channels : Int,
) -> Unit {
  @ffi.wave_format(self.0, sample_rate, sample_size, channels)
}

///|
#as_free_fn(load_wave_samples)
pub fn Wave::load_samples(self : Wave) -> Bytes {
  @ffi.load_wave_samples(self.0)
}

///|
#as_free_fn(load_wave)
pub fn Wave::load(file_name : String) -> Wave {
  @ffi.load_wave(@utf8.encode(file_name))
}

///|
#as_free_fn(load_wave_from_memory)
pub fn Wave::load_from_memory(
  file_type : String,
  file_data : Bytes,
  data_size : Int,
) -> Wave {
  @ffi.load_wave_from_memory(@utf8.encode(file_type), file_data, data_size)
}

///|
#as_free_fn(export_wave)
pub fn Wave::export_(self : Wave, file_name : String) -> Bool {
  @ffi.export_wave(self.0, @utf8.encode(file_name))
}

///|
#as_free_fn(export_wave_as_code)
pub fn Wave::export_as_code(self : Wave, file_name : String) -> Bool {
  @ffi.export_wave_as_code(self.0, @utf8.encode(file_name))
}
