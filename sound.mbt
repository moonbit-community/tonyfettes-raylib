///|
/// Sound type, wrapping the internal FFI sound resource.
struct Sound(@ffi.Sound)

///|
/// Unload sound.
#as_free_fn(unload_sound)
pub fn Sound::unload(self : Sound) -> Unit {
  @ffi.unload_sound(self.0)
}

///|
/// Play a sound.
#as_free_fn(play_sound)
pub fn Sound::play(self : Sound) -> Unit {
  @ffi.play_sound(self.0)
}

///|
/// Stop playing a sound.
#as_free_fn(stop_sound)
pub fn Sound::stop(self : Sound) -> Unit {
  @ffi.stop_sound(self.0)
}

///|
/// Pause a sound.
#as_free_fn(pause_sound)
pub fn Sound::pause(self : Sound) -> Unit {
  @ffi.pause_sound(self.0)
}

///|
/// Resume a paused sound.
#as_free_fn(resume_sound)
pub fn Sound::resume_(self : Sound) -> Unit {
  @ffi.resume_sound(self.0)
}

///|
/// Check if a sound is currently playing.
#as_free_fn(is_sound_playing)
pub fn Sound::is_playing(self : Sound) -> Bool {
  @ffi.is_sound_playing(self.0)
}

///|
/// Check if a sound is valid (data loaded and buffers initialized).
#as_free_fn(is_sound_valid)
pub fn Sound::is_valid(self : Sound) -> Bool {
  @ffi.is_sound_valid(self.0)
}

///|
/// Create a new sound that shares the same sample data as the source sound, does not own the sound data.
#as_free_fn(load_sound_alias)
pub fn Sound::load_alias(self : Sound) -> Sound {
  @ffi.load_sound_alias(self.0)
}

///|
/// Unload a sound alias (does not deallocate sample data).
#as_free_fn(unload_sound_alias)
pub fn Sound::unload_alias(self : Sound) -> Unit {
  @ffi.unload_sound_alias(self.0)
}

///|
/// Set volume for a sound (1.0 is max level).
#as_free_fn(set_sound_volume)
pub fn Sound::set_volume(self : Sound, volume : Float) -> Unit {
  @ffi.set_sound_volume(self.0, volume)
}

///|
/// Set pitch for a sound (1.0 is base level).
#as_free_fn(set_sound_pitch)
pub fn Sound::set_pitch(self : Sound, pitch : Float) -> Unit {
  @ffi.set_sound_pitch(self.0, pitch)
}

///|
/// Set pan for a sound (0.5 is center).
#as_free_fn(set_sound_pan)
pub fn Sound::set_pan(self : Sound, pan : Float) -> Unit {
  @ffi.set_sound_pan(self.0, pan)
}

///|
/// Load sound from file.
#as_free_fn(load_sound)
pub fn Sound::load(file_name : String) -> Sound {
  @ffi.load_sound(@utf8.encode(file_name))
}

///|
/// Update sound buffer with new data.
#as_free_fn(update_sound)
pub fn Sound::update(self : Sound, data : Bytes, sample_count : Int) -> Unit {
  @ffi.update_sound(self.0, data, sample_count)
}
