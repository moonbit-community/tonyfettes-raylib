// Re-export passthrough functions from internal FFI layer

///|
// Audio device
pub using @ffi {
  init_audio_device,
  close_audio_device,
  is_audio_device_ready,
  set_master_volume,
  get_master_volume,
  // AudioStream (no resource type params)
  set_audio_stream_buffer_size_default,
  // AudioBuffer (re-exported type, used in processor callbacks from C)
  type AudioBuffer,
  audio_buffer_get_sample,
  audio_buffer_set_sample,
  // Audio mixed processor attach/detach (no resource type params except AudioBuffer in callback)
  attach_audio_mixed_processor,
  detach_audio_mixed_processor,
}
