// Private math helper functions shared by raymath implementations

///|
fn absf(x : Float) -> Float {
  x.abs()
}

///|
fn fabsf(x : Float) -> Float {
  x.abs()
}

///|
fn fmaxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
fn fminf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
fn floorf(x : Float) -> Float {
  Float::from_double(@math.floor(x.to_double()))
}

///|
fn sqrtf(x : Float) -> Float {
  x.sqrt()
}

///|
fn sinf(x : Float) -> Float {
  @math.sinf(x)
}

///|
fn cosf(x : Float) -> Float {
  @math.cosf(x)
}

///|
fn atan2f(y : Float, x : Float) -> Float {
  @math.atan2f(y, x)
}

///|
fn acosf(x : Float) -> Float {
  @math.acosf(x)
}

///|
fn asinf(x : Float) -> Float {
  @math.asinf(x)
}

///|
fn tanf(x : Float) -> Float {
  @math.tanf(x)
}
