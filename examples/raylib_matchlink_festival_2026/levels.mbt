///|
fn configure_level(id : Int) -> (Int, Int, Int, Float, Int, Int, String) {
  if id == 0 {
    (8, 6, 8, 118.0, 4, 4, "Harbor Warmup")
  } else if id == 1 {
    (10, 6, 10, 122.0, 4, 4, "Lantern Dock")
  } else if id == 2 {
    (10, 8, 12, 132.0, 4, 4, "Night Market")
  } else if id == 3 {
    (12, 8, 14, 142.0, 4, 3, "River Festival")
  } else if id == 4 {
    (12, 9, 16, 152.0, 3, 3, "Golden Pier")
  } else if id == 5 {
    (14, 8, 18, 156.0, 3, 3, "Dragon Stage")
  } else if id == 6 {
    (14, 9, 20, 168.0, 3, 2, "Moonlight Parade")
  } else if id == 7 {
    (14, 10, 22, 176.0, 2, 2, "Fireworks Run")
  } else if id == 8 {
    (16, 10, 24, 186.0, 2, 2, "Festival Grand Hall")
  } else {
    (16, 12, 26, 210.0, 2, 2, "Master Lantern Grid")
  }
}
