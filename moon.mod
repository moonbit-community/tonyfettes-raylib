name = "tonyfettes/raylib"

version = "0.5.0"

readme = "README.md"

repository = "https://github.com/moonbit-community/tonyfettes-raylib"

license = "MIT"

keywords = [ ]

description = "MoonBit bindings for raylib"

source = "."

preferred_target = "native"

options(
  "--moonbit-unstable-prebuild": "build.js",
)
