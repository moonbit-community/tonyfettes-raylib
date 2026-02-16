// ============================================================================
// Automation events
// ============================================================================

///|
#borrow(file_name)
pub extern "c" fn load_automation_event_list(
  file_name : Bytes,
) -> AutomationEventList = "moonbit_raylib_load_automation_event_list"

///|
#borrow(list)
pub extern "c" fn unload_automation_event_list(list : AutomationEventList) = "moonbit_raylib_unload_automation_event_list"

///|
#borrow(list, file_name)
pub extern "c" fn export_automation_event_list(
  list : AutomationEventList,
  file_name : Bytes,
) -> Bool = "moonbit_raylib_export_automation_event_list"

///|
#borrow(list)
pub extern "c" fn set_automation_event_list(list : AutomationEventList) = "moonbit_raylib_set_automation_event_list"

///|
pub extern "c" fn set_automation_event_base_frame(frame : Int) = "SetAutomationEventBaseFrame"

///|
pub extern "c" fn start_automation_event_recording() = "StartAutomationEventRecording"

///|
pub extern "c" fn stop_automation_event_recording() = "StopAutomationEventRecording"

///|
#borrow(event)
pub extern "c" fn play_automation_event(event : Bytes) = "moonbit_raylib_play_automation_event"

///|
#borrow(list)
pub extern "c" fn automation_event_list_count(
  list : AutomationEventList,
) -> Int = "moonbit_raylib_automation_event_list_count"

///|
#borrow(list)
pub extern "c" fn automation_event_list_get(
  list : AutomationEventList,
  index : Int,
) -> Bytes = "moonbit_raylib_automation_event_list_get"
