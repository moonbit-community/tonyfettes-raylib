name = "tonyfettes/raylib"

version = "0.3.1"

readme = "README.md"

repository = "https://github.com/moonbit-community/tonyfettes-raylib"

license = "MIT"

keywords = [ ]

description = "MoonBit bindings for raylib"

source = "."

preferred_target = "native"

options(
  exclude: [
    "examples",
    "moon.work",
    "/external",
    "publish",
    "docs",
    "tools",
    "scripts",
    "CLAUDE.md",
    "CONTRIBUTING.md",
    "WORKFLOW.md",
    "setup.sh",
    "clean.sh",
  ],
  "--moonbit-unstable-prebuild": "build.js",
)
