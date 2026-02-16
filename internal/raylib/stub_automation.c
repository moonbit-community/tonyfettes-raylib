#include "stub_internal.h"

// ============================================================================
// AutomationEventList wrapper
// ============================================================================

typedef struct {
  AutomationEventList list;
  int freed;
} AutomationEventListWrapper;

static void
automation_event_list_destructor(void *ptr) {
  AutomationEventListWrapper *w = (AutomationEventListWrapper *)ptr;
  if (!w->freed) {
    UnloadAutomationEventList(w->list);
  }
}

AutomationEventListWrapper *
moonbit_raylib_load_automation_event_list(moonbit_bytes_t fileName) {
  AutomationEventListWrapper *w = (AutomationEventListWrapper *)moonbit_make_external_object(
    automation_event_list_destructor, sizeof(AutomationEventListWrapper));
  w->list = LoadAutomationEventList((const char *)fileName);
  w->freed = 0;
  return w;
}

void
moonbit_raylib_unload_automation_event_list(AutomationEventListWrapper *w) {
  if (w && !w->freed) {
    UnloadAutomationEventList(w->list);
    w->freed = 1;
  }
}

int
moonbit_raylib_export_automation_event_list(AutomationEventListWrapper *w, moonbit_bytes_t fileName) {
  return (int)ExportAutomationEventList(w->list, (const char *)fileName);
}

void
moonbit_raylib_set_automation_event_list(AutomationEventListWrapper *w) {
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
moonbit_raylib_automation_event_list_count(AutomationEventListWrapper *w) {
  return (int)w->list.count;
}

// Accessor: get event at index (returns 24 bytes)
moonbit_bytes_t
moonbit_raylib_automation_event_list_get(AutomationEventListWrapper *w, int index) {
  moonbit_bytes_t result = moonbit_make_bytes(sizeof(AutomationEvent), 0);
  if (index >= 0 && index < (int)w->list.count) {
    memcpy(result, &w->list.events[index], sizeof(AutomationEvent));
  }
  return result;
}
