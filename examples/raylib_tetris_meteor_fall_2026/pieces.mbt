///|
fn normalize_rot(rot : Int) -> Int {
  let mut r = rot % 4
  if r < 0 {
    r = r + 4
  }
  r
}

///|
fn make_cell(x : Int, y : Int) -> Cell {
  { x, y }
}

///|
fn piece_cell(kind : Int, rot : Int, block : Int) -> Cell {
  let r = normalize_rot(rot)
  match kind {
    // I
    0 =>
      match r {
        0 | 2 =>
          match block {
            0 => make_cell(-2, 0)
            1 => make_cell(-1, 0)
            2 => make_cell(0, 0)
            _ => make_cell(1, 0)
          }
        _ =>
          match block {
            0 => make_cell(0, -1)
            1 => make_cell(0, 0)
            2 => make_cell(0, 1)
            _ => make_cell(0, 2)
          }
      }
    // O
    1 =>
      match block {
        0 => make_cell(0, 0)
        1 => make_cell(1, 0)
        2 => make_cell(0, 1)
        _ => make_cell(1, 1)
      }
    // T
    2 =>
      match r {
        0 =>
          match block {
            0 => make_cell(-1, 0)
            1 => make_cell(0, 0)
            2 => make_cell(1, 0)
            _ => make_cell(0, 1)
          }
        1 =>
          match block {
            0 => make_cell(0, -1)
            1 => make_cell(0, 0)
            2 => make_cell(0, 1)
            _ => make_cell(1, 0)
          }
        2 =>
          match block {
            0 => make_cell(-1, 0)
            1 => make_cell(0, 0)
            2 => make_cell(1, 0)
            _ => make_cell(0, -1)
          }
        _ =>
          match block {
            0 => make_cell(0, -1)
            1 => make_cell(0, 0)
            2 => make_cell(0, 1)
            _ => make_cell(-1, 0)
          }
      }
    // S
    3 =>
      match r {
        0 | 2 =>
          match block {
            0 => make_cell(-1, 1)
            1 => make_cell(0, 1)
            2 => make_cell(0, 0)
            _ => make_cell(1, 0)
          }
        _ =>
          match block {
            0 => make_cell(0, -1)
            1 => make_cell(0, 0)
            2 => make_cell(1, 0)
            _ => make_cell(1, 1)
          }
      }
    // Z
    4 =>
      match r {
        0 | 2 =>
          match block {
            0 => make_cell(-1, 0)
            1 => make_cell(0, 0)
            2 => make_cell(0, 1)
            _ => make_cell(1, 1)
          }
        _ =>
          match block {
            0 => make_cell(1, -1)
            1 => make_cell(1, 0)
            2 => make_cell(0, 0)
            _ => make_cell(0, 1)
          }
      }
    // J
    5 =>
      match r {
        0 =>
          match block {
            0 => make_cell(-1, 0)
            1 => make_cell(0, 0)
            2 => make_cell(1, 0)
            _ => make_cell(-1, 1)
          }
        1 =>
          match block {
            0 => make_cell(0, -1)
            1 => make_cell(0, 0)
            2 => make_cell(0, 1)
            _ => make_cell(1, 1)
          }
        2 =>
          match block {
            0 => make_cell(-1, 0)
            1 => make_cell(0, 0)
            2 => make_cell(1, 0)
            _ => make_cell(1, -1)
          }
        _ =>
          match block {
            0 => make_cell(0, -1)
            1 => make_cell(0, 0)
            2 => make_cell(0, 1)
            _ => make_cell(-1, -1)
          }
      }
    // L
    _ =>
      match r {
        0 =>
          match block {
            0 => make_cell(-1, 0)
            1 => make_cell(0, 0)
            2 => make_cell(1, 0)
            _ => make_cell(1, 1)
          }
        1 =>
          match block {
            0 => make_cell(0, -1)
            1 => make_cell(0, 0)
            2 => make_cell(0, 1)
            _ => make_cell(1, -1)
          }
        2 =>
          match block {
            0 => make_cell(-1, 0)
            1 => make_cell(0, 0)
            2 => make_cell(1, 0)
            _ => make_cell(-1, -1)
          }
        _ =>
          match block {
            0 => make_cell(0, -1)
            1 => make_cell(0, 0)
            2 => make_cell(0, 1)
            _ => make_cell(-1, 1)
          }
      }
  }
}

///|
fn piece_color(id : Int) -> @raylib.Color {
  match id {
    1 => @raylib.skyblue
    2 => @raylib.yellow
    3 => @raylib.purple
    4 => @raylib.lime
    5 => @raylib.red
    6 => @raylib.blue
    7 => @raylib.orange
    _ => @raylib.darkgray
  }
}
