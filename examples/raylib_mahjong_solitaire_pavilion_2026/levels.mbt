///|
fn configure_level(
  id : Int,
) -> (Int, Int, Int, Float, Int, Int, Int, Int, String) {
  if id == 0 {
    (10, 6, 12, 120.0, 4, 4, 3, 0, "Courtyard Warmup")
  } else if id == 1 {
    (12, 6, 14, 126.0, 4, 4, 3, 1, "Bamboo Gate")
  } else if id == 2 {
    (12, 8, 16, 138.0, 4, 3, 3, 2, "Lantern Bridge")
  } else if id == 3 {
    (14, 8, 18, 146.0, 3, 3, 3, 3, "River Walk")
  } else if id == 4 {
    (14, 9, 20, 154.0, 3, 3, 3, 4, "Pavilion Hall")
  } else if id == 5 {
    (16, 8, 22, 164.0, 3, 3, 2, 5, "Moon Stage")
  } else if id == 6 {
    (16, 9, 24, 172.0, 2, 3, 2, 6, "Dragon Corridor")
  } else if id == 7 {
    (16, 10, 26, 182.0, 2, 2, 2, 7, "Opera Plaza")
  } else if id == 8 {
    (18, 10, 28, 196.0, 2, 2, 2, 8, "Imperial Garden")
  } else {
    (18, 12, 30, 220.0, 2, 2, 1, 9, "Master Solitaire")
  }
}
