///|
struct Music(@ffi.Music)

///|
#as_free_fn(unload_music_stream)
pub fn Music::unload(self : Music) -> Unit {
  @ffi.unload_music_stream(self.0)
}

///|
#as_free_fn(play_music_stream)
pub fn Music::play(self : Music) -> Unit {
  @ffi.play_music_stream(self.0)
}

///|
#as_free_fn(stop_music_stream)
pub fn Music::stop(self : Music) -> Unit {
  @ffi.stop_music_stream(self.0)
}

///|
#as_free_fn(pause_music_stream)
pub fn Music::pause(self : Music) -> Unit {
  @ffi.pause_music_stream(self.0)
}

///|
#as_free_fn(resume_music_stream)
pub fn Music::resume_(self : Music) -> Unit {
  @ffi.resume_music_stream(self.0)
}

///|
#as_free_fn(update_music_stream)
pub fn Music::update(self : Music) -> Unit {
  @ffi.update_music_stream(self.0)
}

///|
#as_free_fn(is_music_stream_playing)
pub fn Music::is_playing(self : Music) -> Bool {
  @ffi.is_music_stream_playing(self.0)
}

///|
#as_free_fn(is_music_valid)
pub fn Music::is_valid(self : Music) -> Bool {
  @ffi.is_music_valid(self.0)
}

///|
#as_free_fn(set_music_volume)
pub fn Music::set_volume(self : Music, volume : Float) -> Unit {
  @ffi.set_music_volume(self.0, volume)
}

///|
#as_free_fn(set_music_pitch)
pub fn Music::set_pitch(self : Music, pitch : Float) -> Unit {
  @ffi.set_music_pitch(self.0, pitch)
}

///|
#as_free_fn(set_music_pan)
pub fn Music::set_pan(self : Music, pan : Float) -> Unit {
  @ffi.set_music_pan(self.0, pan)
}

///|
#as_free_fn(seek_music_stream)
pub fn Music::seek(self : Music, position : Float) -> Unit {
  @ffi.seek_music_stream(self.0, position)
}

///|
#as_free_fn(get_music_time_length)
pub fn Music::time_length(self : Music) -> Float {
  @ffi.get_music_time_length(self.0)
}

///|
#as_free_fn(get_music_time_played)
pub fn Music::time_played(self : Music) -> Float {
  @ffi.get_music_time_played(self.0)
}

///|
#as_free_fn(load_music_stream)
pub fn Music::load(file_name : String) -> Music {
  @ffi.load_music_stream(@utf8.encode(file_name))
}

///|
#as_free_fn(load_music_stream_from_memory)
pub fn Music::load_from_memory(
  file_type : String,
  data : Bytes,
  data_size : Int,
) -> Music {
  @ffi.load_music_stream_from_memory(@utf8.encode(file_type), data, data_size)
}
