///|
struct AutomationEventList(@ffi.AutomationEventList)

// Re-export passthrough functions for automation events

///|
pub using @ffi {
  set_automation_event_base_frame,
  start_automation_event_recording,
  stop_automation_event_recording,
}

///|
/// Unload automation events list from file.
#as_free_fn(unload_automation_event_list)
pub fn AutomationEventList::unload(self : AutomationEventList) -> Unit {
  @ffi.unload_automation_event_list(self.0)
}

///|
/// Get the number of automation events in the list.
#as_free_fn(automation_event_list_count)
pub fn AutomationEventList::count(self : AutomationEventList) -> Int {
  @ffi.automation_event_list_count(self.0)
}

///|
/// Set automation event list to record to.
#as_free_fn(set_automation_event_list)
pub fn AutomationEventList::set(self : AutomationEventList) -> Unit {
  @ffi.set_automation_event_list(self.0)
}

// AutomationEvent value type: frame(uint), type(uint), params[4](int)
// Total: 24 bytes

///|
/// Automation event with frame, type, and parameters.
pub struct AutomationEvent {
  frame : Int
  type_ : Int
  params : FixedArray[Int] // length 4
} derive(Debug)

///|
/// Deserialize an AutomationEvent from a Bytes buffer.
pub fn AutomationEvent::from_bytes(b : Bytes) -> AutomationEvent {
  {
    frame: read_int(b, 0),
    type_: read_int(b, 4),
    params: [read_int(b, 8), read_int(b, 12), read_int(b, 16), read_int(b, 20)],
  }
}

///|
/// Serialize an AutomationEvent to a Bytes buffer.
pub fn AutomationEvent::to_bytes(e : AutomationEvent) -> Bytes {
  let buf = @buffer.new(size_hint=24)
  buf.write_int_le(e.frame)
  buf.write_int_le(e.type_)
  for i in 0..<4 {
    buf.write_int_le(e.params[i])
  }
  buf.to_bytes()
}

// ============================================================================
// Automation events (wrappers)
// ============================================================================

///|
/// Load automation events list from file, NULL for empty list, capacity = MAX_AUTOMATION_EVENTS.
#as_free_fn(load_automation_event_list)
pub fn AutomationEventList::load(file_name : String) -> AutomationEventList {
  AutomationEventList(@ffi.load_automation_event_list(@utf8.encode(file_name)))
}

///|
/// Export automation events list as text file.
#as_free_fn(export_automation_event_list)
pub fn AutomationEventList::export_(
  self : AutomationEventList,
  file_name : String,
) -> Bool {
  @ffi.export_automation_event_list(self.0, @utf8.encode(file_name))
}

///|
/// Play a recorded automation event.
pub fn play_automation_event(event : AutomationEvent) -> Unit {
  @ffi.play_automation_event(event.to_bytes())
}

///|
/// Get an automation event from the list by index.
#as_free_fn(automation_event_list_get)
pub fn AutomationEventList::get(
  self : AutomationEventList,
  index : Int,
) -> AutomationEvent {
  AutomationEvent::from_bytes(@ffi.automation_event_list_get(self.0, index))
}
