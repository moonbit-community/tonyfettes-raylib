// Re-export passthrough functions from internal FFI layer

pub using @ffi {
  init_audio_device,
  close_audio_device,
  is_audio_device_ready,
  set_master_volume,
  get_master_volume,
  set_audio_stream_buffer_size_default,
  type AudioBuffer,
  audio_buffer_get_sample,
  audio_buffer_set_sample,
  attach_audio_mixed_processor,
  detach_audio_mixed_processor,
}
