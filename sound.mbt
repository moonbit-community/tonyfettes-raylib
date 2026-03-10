///|
struct Sound(@ffi.Sound)

///|
#as_free_fn(unload_sound)
pub fn Sound::unload(self : Sound) -> Unit {
  @ffi.unload_sound(self.0)
}

///|
#as_free_fn(play_sound)
pub fn Sound::play(self : Sound) -> Unit {
  @ffi.play_sound(self.0)
}

///|
#as_free_fn(stop_sound)
pub fn Sound::stop(self : Sound) -> Unit {
  @ffi.stop_sound(self.0)
}

///|
#as_free_fn(pause_sound)
pub fn Sound::pause(self : Sound) -> Unit {
  @ffi.pause_sound(self.0)
}

///|
#as_free_fn(resume_sound)
pub fn Sound::resume_(self : Sound) -> Unit {
  @ffi.resume_sound(self.0)
}

///|
#as_free_fn(is_sound_playing)
pub fn Sound::is_playing(self : Sound) -> Bool {
  @ffi.is_sound_playing(self.0)
}

///|
#as_free_fn(is_sound_valid)
pub fn Sound::is_valid(self : Sound) -> Bool {
  @ffi.is_sound_valid(self.0)
}

///|
#as_free_fn(load_sound_alias)
pub fn Sound::load_alias(self : Sound) -> Sound {
  @ffi.load_sound_alias(self.0)
}

///|
#as_free_fn(unload_sound_alias)
pub fn Sound::unload_alias(self : Sound) -> Unit {
  @ffi.unload_sound_alias(self.0)
}

///|
#as_free_fn(set_sound_volume)
pub fn Sound::set_volume(self : Sound, volume : Float) -> Unit {
  @ffi.set_sound_volume(self.0, volume)
}

///|
#as_free_fn(set_sound_pitch)
pub fn Sound::set_pitch(self : Sound, pitch : Float) -> Unit {
  @ffi.set_sound_pitch(self.0, pitch)
}

///|
#as_free_fn(set_sound_pan)
pub fn Sound::set_pan(self : Sound, pan : Float) -> Unit {
  @ffi.set_sound_pan(self.0, pan)
}

///|
#as_free_fn(load_sound)
pub fn Sound::load(file_name : String) -> Sound {
  @ffi.load_sound(@utf8.encode(file_name))
}

///|
#as_free_fn(update_sound)
pub fn Sound::update(self : Sound, data : Bytes, sample_count : Int) -> Unit {
  @ffi.update_sound(self.0, data, sample_count)
}
