const os = require('os');
const fs = require('fs');
const path = require('path');
const platform = process.env.RAYLIB_PLATFORM || os.platform();

const modSource = fs.readFileSync(path.join(__dirname, 'moon.mod'), 'utf8');
// The prebuild output only needs the required top-level module name, so avoid
// adding a parser dependency for the rest of the moon.mod configuration.
const moduleName = modSource.match(/^name\s*=\s*"([^"]+)"\s*$/m)?.[1];
if (!moduleName) {
  throw new Error('moon.mod must define a top-level name');
}
const pkg = moduleName + '/internal/raylib';

let link_config = { package: pkg };
let stub_cc_flags = '-DPLATFORM_DESKTOP_GLFW';

if (platform === 'darwin') {
  link_config.link_flags = '-framework OpenGL -framework Cocoa -framework IOKit -framework CoreAudio -framework CoreVideo -framework AudioToolbox -framework CoreFoundation';
  // -ObjC tells clang to treat all source files as Objective-C, needed for
  // GLFW's Cocoa backend. Unlike -xobjective-c, -ObjC works regardless of
  // position on the command line.
  stub_cc_flags += ' -ObjC';
} else if (platform === 'linux') {
  link_config.link_libs = ['GL', 'm', 'pthread', 'dl', 'rt', 'X11'];
  stub_cc_flags += ' -D_GLFW_X11';
} else if (platform === 'win32') {
  link_config.link_libs = ['opengl32', 'gdi32', 'winmm', 'user32', 'shell32'];
} else if (platform === 'android') {
  link_config.link_libs = ['log', 'android', 'OpenSLES', 'EGL', 'GLESv2', 'm', 'dl'];
  stub_cc_flags = '-DPLATFORM_ANDROID -DGRAPHICS_API_OPENGL_ES2';
} else if (platform === 'drm') {
  link_config.link_libs = ['drm', 'gbm', 'EGL', 'GLESv2', 'm', 'pthread', 'dl', 'rt'];
  stub_cc_flags = '-DPLATFORM_DRM -DGRAPHICS_API_OPENGL_ES2';
} else if (platform === 'web') {
  // Emscripten handles linking; no link_libs needed
  stub_cc_flags = '-DPLATFORM_WEB -DGRAPHICS_API_OPENGL_ES2';
} else {
  throw new Error(`Unsupported platform: ${platform}`);
}

const output = {
  vars: { RAYLIB_STUB_CC_FLAGS: stub_cc_flags },
  link_configs: [link_config],
};
console.log(JSON.stringify(output));
