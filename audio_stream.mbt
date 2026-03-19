///|
/// AudioStream type, wrapping the internal FFI audio stream resource.
struct AudioStream(@ffi.AudioStream)

///|
/// Load audio stream (to stream raw audio PCM data).
#as_free_fn(load_audio_stream)
pub fn AudioStream::load(
  sample_rate : Int,
  sample_size : Int,
  channels : Int,
) -> AudioStream {
  @ffi.load_audio_stream(sample_rate, sample_size, channels)
}

///|
/// Check if an audio stream is valid (buffers initialized).
#as_free_fn(is_audio_stream_valid)
pub fn AudioStream::is_valid(self : AudioStream) -> Bool {
  @ffi.is_audio_stream_valid(self.0)
}

///|
/// Unload audio stream and free memory.
#as_free_fn(unload_audio_stream)
pub fn AudioStream::unload(self : AudioStream) -> Unit {
  @ffi.unload_audio_stream(self.0)
}

///|
/// Update audio stream buffers with data.
#as_free_fn(update_audio_stream)
pub fn AudioStream::update(
  self : AudioStream,
  data : Bytes,
  frame_count : Int,
) -> Unit {
  @ffi.update_audio_stream(self.0, data, frame_count)
}

///|
/// Check if any audio stream buffers requires refill.
#as_free_fn(is_audio_stream_processed)
pub fn AudioStream::is_processed(self : AudioStream) -> Bool {
  @ffi.is_audio_stream_processed(self.0)
}

///|
/// Play audio stream.
#as_free_fn(play_audio_stream)
pub fn AudioStream::play(self : AudioStream) -> Unit {
  @ffi.play_audio_stream(self.0)
}

///|
/// Pause audio stream.
#as_free_fn(pause_audio_stream)
pub fn AudioStream::pause(self : AudioStream) -> Unit {
  @ffi.pause_audio_stream(self.0)
}

///|
/// Resume audio stream.
#as_free_fn(resume_audio_stream)
pub fn AudioStream::resume_(self : AudioStream) -> Unit {
  @ffi.resume_audio_stream(self.0)
}

///|
/// Check if audio stream is playing.
#as_free_fn(is_audio_stream_playing)
pub fn AudioStream::is_playing(self : AudioStream) -> Bool {
  @ffi.is_audio_stream_playing(self.0)
}

///|
/// Stop audio stream.
#as_free_fn(stop_audio_stream)
pub fn AudioStream::stop(self : AudioStream) -> Unit {
  @ffi.stop_audio_stream(self.0)
}

///|
/// Set volume for audio stream (1.0 is max level).
#as_free_fn(set_audio_stream_volume)
pub fn AudioStream::set_volume(self : AudioStream, volume : Float) -> Unit {
  @ffi.set_audio_stream_volume(self.0, volume)
}

///|
/// Set pitch for audio stream (1.0 is base level).
#as_free_fn(set_audio_stream_pitch)
pub fn AudioStream::set_pitch(self : AudioStream, pitch : Float) -> Unit {
  @ffi.set_audio_stream_pitch(self.0, pitch)
}

///|
/// Set pan for audio stream (0.5 is centered).
#as_free_fn(set_audio_stream_pan)
pub fn AudioStream::set_pan(self : AudioStream, pan : Float) -> Unit {
  @ffi.set_audio_stream_pan(self.0, pan)
}

///|
/// Attach audio stream processor to stream, receives the samples as floats.
#as_free_fn(attach_audio_stream_processor)
pub fn AudioStream::attach_processor(
  self : AudioStream,
  processor : FuncRef[(AudioBuffer, UInt) -> Unit],
) -> Unit {
  @ffi.attach_audio_stream_processor(self.0, processor)
}

///|
/// Detach audio stream processor from stream.
#as_free_fn(detach_audio_stream_processor)
pub fn AudioStream::detach_processor(
  self : AudioStream,
  processor : FuncRef[(AudioBuffer, UInt) -> Unit],
) -> Unit {
  @ffi.detach_audio_stream_processor(self.0, processor)
}

///|
/// Attach audio stream processor to a music stream, receives the samples as floats.
pub fn attach_music_stream_processor(
  music : Music,
  processor : FuncRef[(AudioBuffer, UInt) -> Unit],
) -> Unit {
  @ffi.attach_music_stream_processor(music.0, processor)
}

///|
/// Detach audio stream processor from a music stream.
pub fn detach_music_stream_processor(
  music : Music,
  processor : FuncRef[(AudioBuffer, UInt) -> Unit],
) -> Unit {
  @ffi.detach_music_stream_processor(music.0, processor)
}
