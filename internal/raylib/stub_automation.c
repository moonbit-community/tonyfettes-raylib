#include "stub_internal.h"

// ============================================================================
// AutomationEventList wrapper
// ============================================================================

MoonBitAutomationEventList *
moonbit_raylib_load_automation_event_list(moonbit_bytes_t fileName) {
  MoonBitAutomationEventList *w = (MoonBitAutomationEventList *)moonbit_make_bytes(sizeof(MoonBitAutomationEventList), 0);
  w->list = LoadAutomationEventList((const char *)fileName);
  return w;
}

void
moonbit_raylib_unload_automation_event_list(MoonBitAutomationEventList *w) {
  UnloadAutomationEventList(w->list);
}

int
moonbit_raylib_export_automation_event_list(MoonBitAutomationEventList *w, moonbit_bytes_t fileName) {
  return (int)ExportAutomationEventList(w->list, (const char *)fileName);
}

void
moonbit_raylib_set_automation_event_list(MoonBitAutomationEventList *w) {
  SetAutomationEventList(&w->list);
}

// PlayAutomationEvent takes AutomationEvent by value (24 bytes)
void
moonbit_raylib_play_automation_event(moonbit_bytes_t event_bytes) {
  AutomationEvent event;
  memcpy(&event, event_bytes, sizeof(AutomationEvent));
  PlayAutomationEvent(event);
}

// Accessor: get event count
int
moonbit_raylib_automation_event_list_count(MoonBitAutomationEventList *w) {
  return (int)w->list.count;
}

// Accessor: get event at index (returns 24 bytes)
moonbit_bytes_t
moonbit_raylib_automation_event_list_get(MoonBitAutomationEventList *w, int index) {
  moonbit_bytes_t result = moonbit_make_bytes(sizeof(AutomationEvent), 0);
  if (index >= 0 && index < (int)w->list.count) {
    memcpy(result, &w->list.events[index], sizeof(AutomationEvent));
  }
  return result;
}
