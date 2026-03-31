///|
test "AutomationEvent::to_bytes/from_bytes round-trip" {
  let e : AutomationEvent = { frame: 42, type_: 3, params: [10, 20, 30, 40] }
  let bytes = AutomationEvent::to_bytes(e)
  let e2 = AutomationEvent::from_bytes(bytes)
  assert_eq(e2.frame, 42)
  assert_eq(e2.type_, 3)
  assert_eq(e2.params[0], 10)
  assert_eq(e2.params[1], 20)
  assert_eq(e2.params[2], 30)
  assert_eq(e2.params[3], 40)
}
