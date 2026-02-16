// Re-export opaque types and passthrough functions for automation events

///|
pub using @raylib {
  type AutomationEventList,
  unload_automation_event_list,
  set_automation_event_list,
  set_automation_event_base_frame,
  start_automation_event_recording,
  stop_automation_event_recording,
  automation_event_list_count,
}

// AutomationEvent value type: frame(uint), type(uint), params[4](int)
// Total: 24 bytes

///|
pub struct AutomationEvent {
  frame : Int
  type_ : Int
  params : FixedArray[Int] // length 4
} derive(Show)

///|
pub fn AutomationEvent::from_bytes(b : Bytes) -> AutomationEvent {
  {
    frame: read_int(b, 0),
    type_: read_int(b, 4),
    params: [read_int(b, 8), read_int(b, 12), read_int(b, 16), read_int(b, 20)],
  }
}

///|
pub fn AutomationEvent::to_bytes(e : AutomationEvent) -> Bytes {
  let arr = FixedArray::make(24, b'\x00')
  let (a, b, c, d) = write_int(e.frame)
  arr[0] = a
  arr[1] = b
  arr[2] = c
  arr[3] = d
  let (a, b, c, d) = write_int(e.type_)
  arr[4] = a
  arr[5] = b
  arr[6] = c
  arr[7] = d
  for i in 0..<4 {
    let (a, b, c, d) = write_int(e.params[i])
    arr[8 + i * 4] = a
    arr[8 + i * 4 + 1] = b
    arr[8 + i * 4 + 2] = c
    arr[8 + i * 4 + 3] = d
  }
  FixedArray::unsafe_reinterpret_as_bytes(arr)
}

// ============================================================================
// Automation events (wrappers)
// ============================================================================

///|
pub fn load_automation_event_list(file_name : String) -> AutomationEventList {
  @raylib.load_automation_event_list(@utf8.encode(file_name))
}

///|
pub fn export_automation_event_list(
  list : AutomationEventList,
  file_name : String,
) -> Bool {
  @raylib.export_automation_event_list(list, @utf8.encode(file_name))
}

///|
pub fn play_automation_event(event : AutomationEvent) -> Unit {
  @raylib.play_automation_event(event.to_bytes())
}

///|
pub fn automation_event_list_get(
  list : AutomationEventList,
  index : Int,
) -> AutomationEvent {
  AutomationEvent::from_bytes(@raylib.automation_event_list_get(list, index))
}
