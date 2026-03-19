///|
/// Wave type, wrapping the internal FFI wave resource.
struct Wave(@ffi.Wave)

///|
/// Check if wave data is valid (data loaded and parameters).
#as_free_fn(is_wave_valid)
pub fn Wave::is_valid(self : Wave) -> Bool {
  @ffi.is_wave_valid(self.0)
}

///|
/// Load sound from wave data.
#as_free_fn(load_sound_from_wave)
pub fn Wave::load_sound(self : Wave) -> Sound {
  @ffi.load_sound_from_wave(self.0)
}

///|
/// Unload wave data.
#as_free_fn(unload_wave)
pub fn Wave::unload(self : Wave) -> Unit {
  @ffi.unload_wave(self.0)
}

///|
/// Copy a wave to a new wave.
#as_free_fn(wave_copy)
pub fn Wave::copy(self : Wave) -> Wave {
  @ffi.wave_copy(self.0)
}

///|
/// Crop a wave to defined frames range.
#as_free_fn(wave_crop)
pub fn Wave::crop(self : Wave, init_frame : Int, final_frame : Int) -> Unit {
  @ffi.wave_crop(self.0, init_frame, final_frame)
}

///|
/// Convert wave data to desired format.
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
/// Wave samples data, wrapping a float array.
pub struct WaveSamples {
  priv samples : FloatArray
}

///|
/// Get the number of samples.
pub fn WaveSamples::length(self : WaveSamples) -> Int {
  self.samples.length()
}

///|
/// Get sample value at index.
pub fn WaveSamples::op_get(self : WaveSamples, index : Int) -> Float {
  self.samples[index]
}

///|
/// Set sample value at index.
pub fn WaveSamples::op_set(
  self : WaveSamples,
  index : Int,
  value : Float,
) -> Unit {
  self.samples[index] = value
}

///|
/// Unload samples data loaded with load_wave_samples.
#as_free_fn(unload_wave_samples)
pub fn WaveSamples::unload(self : WaveSamples) -> Unit {
  @ffi.unload_wave_samples(self.samples.0)
}

///|
/// Load samples data from wave as a 32-bit float data array.
#as_free_fn(load_wave_samples)
pub fn Wave::load_samples(self : Wave) -> WaveSamples {
  let count = self.frame_count() * self.channels()
  { samples: FloatArray(@ffi.load_wave_samples(self.0), count) }
}

///|
/// Get wave frame count.
#as_free_fn(get_wave_frame_count)
pub fn Wave::frame_count(self : Wave) -> Int {
  @ffi.get_wave_frame_count(self.0)
}

///|
/// Get wave sample rate.
#as_free_fn(get_wave_sample_rate)
pub fn Wave::sample_rate(self : Wave) -> Int {
  @ffi.get_wave_sample_rate(self.0)
}

///|
/// Get wave sample size.
#as_free_fn(get_wave_sample_size)
pub fn Wave::sample_size(self : Wave) -> Int {
  @ffi.get_wave_sample_size(self.0)
}

///|
/// Get wave channels count.
#as_free_fn(get_wave_channels)
pub fn Wave::channels(self : Wave) -> Int {
  @ffi.get_wave_channels(self.0)
}

///|
/// Load wave data from file.
#as_free_fn(load_wave)
pub fn Wave::load(file_name : String) -> Wave {
  @ffi.load_wave(@utf8.encode(file_name))
}

///|
/// Load wave from memory buffer, file_type refers to extension (e.g. ".wav").
#as_free_fn(load_wave_from_memory)
pub fn Wave::load_from_memory(
  file_type : String,
  file_data : Bytes,
  data_size : Int,
) -> Wave {
  @ffi.load_wave_from_memory(@utf8.encode(file_type), file_data, data_size)
}

///|
/// Export wave data to file, returns true on success.
#as_free_fn(export_wave)
pub fn Wave::export_(self : Wave, file_name : String) -> Bool {
  @ffi.export_wave(self.0, @utf8.encode(file_name))
}

///|
/// Export wave sample data to code (.h), returns true on success.
#as_free_fn(export_wave_as_code)
pub fn Wave::export_as_code(self : Wave, file_name : String) -> Bool {
  @ffi.export_wave_as_code(self.0, @utf8.encode(file_name))
}
