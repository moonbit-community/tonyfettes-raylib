const os = require('os');
const path = require('path');
const { execSync } = require('child_process');

const platform = os.platform();
const pkg = 'tonyfettes/raylib/internal/raylib';
const raylibDir = path.join(__dirname, 'internal', 'raylib');

let link_config = { package: pkg };

if (platform === 'darwin') {
  // Pre-compile rglfw.c as Objective-C (required for GLFW's Cocoa backend).
  // Moon places stub-cc-flags after the source file, so -xobjective-c cannot
  // be used there. Instead we compile rglfw.c separately and link the object.
  const cc = process.env.MOON_CC || process.env.CC || 'cc';
  const objFile = path.join(raylibDir, 'rglfw_prebuilt.o');
  execSync(
    `"${cc}" -c -xobjective-c -DPLATFORM_DESKTOP_GLFW -g -fwrapv -fno-strict-aliasing "${path.join(raylibDir, 'rglfw.c')}" -o "${objFile}"`,
    { stdio: 'inherit' }
  );
  link_config.link_flags = `${objFile} -framework OpenGL -framework Cocoa -framework IOKit -framework CoreAudio -framework CoreVideo -framework AudioToolbox -framework CoreFoundation`;
} else if (platform === 'linux') {
  link_config.link_libs = ['GL', 'm', 'pthread', 'dl', 'rt', 'X11'];
} else if (platform === 'win32') {
  link_config.link_libs = ['opengl32', 'gdi32', 'winmm', 'user32', 'shell32'];
} else {
  throw new Error(`Unsupported platform: ${platform}`);
}

const output = { link_configs: [link_config] };
console.log(JSON.stringify(output));
