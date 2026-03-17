///|
struct AudioStream(@ffi.AudioStream)

///|
#as_free_fn(load_audio_stream)
pub fn AudioStream::load(
  sample_rate : Int,
  sample_size : Int,
  channels : Int,
) -> AudioStream {
  @ffi.load_audio_stream(sample_rate, sample_size, channels)
}

///|
#as_free_fn(is_audio_stream_valid)
pub fn AudioStream::is_valid(self : AudioStream) -> Bool {
  @ffi.is_audio_stream_valid(self.0)
}

///|
#as_free_fn(unload_audio_stream)
pub fn AudioStream::unload(self : AudioStream) -> Unit {
  @ffi.unload_audio_stream(self.0)
}

///|
#as_free_fn(update_audio_stream)
pub fn AudioStream::update(
  self : AudioStream,
  data : Bytes,
  frame_count : Int,
) -> Unit {
  @ffi.update_audio_stream(self.0, data, frame_count)
}

///|
#as_free_fn(is_audio_stream_processed)
pub fn AudioStream::is_processed(self : AudioStream) -> Bool {
  @ffi.is_audio_stream_processed(self.0)
}

///|
#as_free_fn(play_audio_stream)
pub fn AudioStream::play(self : AudioStream) -> Unit {
  @ffi.play_audio_stream(self.0)
}

///|
#as_free_fn(pause_audio_stream)
pub fn AudioStream::pause(self : AudioStream) -> Unit {
  @ffi.pause_audio_stream(self.0)
}

///|
#as_free_fn(resume_audio_stream)
pub fn AudioStream::resume_(self : AudioStream) -> Unit {
  @ffi.resume_audio_stream(self.0)
}

///|
#as_free_fn(is_audio_stream_playing)
pub fn AudioStream::is_playing(self : AudioStream) -> Bool {
  @ffi.is_audio_stream_playing(self.0)
}

///|
#as_free_fn(stop_audio_stream)
pub fn AudioStream::stop(self : AudioStream) -> Unit {
  @ffi.stop_audio_stream(self.0)
}

///|
#as_free_fn(set_audio_stream_volume)
pub fn AudioStream::set_volume(self : AudioStream, volume : Float) -> Unit {
  @ffi.set_audio_stream_volume(self.0, volume)
}

///|
#as_free_fn(set_audio_stream_pitch)
pub fn AudioStream::set_pitch(self : AudioStream, pitch : Float) -> Unit {
  @ffi.set_audio_stream_pitch(self.0, pitch)
}

///|
#as_free_fn(set_audio_stream_pan)
pub fn AudioStream::set_pan(self : AudioStream, pan : Float) -> Unit {
  @ffi.set_audio_stream_pan(self.0, pan)
}

///|
#as_free_fn(attach_audio_stream_processor)
pub fn AudioStream::attach_processor(
  self : AudioStream,
  processor : FuncRef[(AudioBuffer, UInt) -> Unit],
) -> Unit {
  @ffi.attach_audio_stream_processor(self.0, processor)
}

///|
#as_free_fn(detach_audio_stream_processor)
pub fn AudioStream::detach_processor(
  self : AudioStream,
  processor : FuncRef[(AudioBuffer, UInt) -> Unit],
) -> Unit {
  @ffi.detach_audio_stream_processor(self.0, processor)
}

///|
pub fn attach_music_stream_processor(
  music : Music,
  processor : FuncRef[(AudioBuffer, UInt) -> Unit],
) -> Unit {
  @ffi.attach_music_stream_processor(music.0, processor)
}

///|
pub fn detach_music_stream_processor(
  music : Music,
  processor : FuncRef[(AudioBuffer, UInt) -> Unit],
) -> Unit {
  @ffi.detach_music_stream_processor(music.0, processor)
}
