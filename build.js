const os = require('os');
const platform = os.platform();

const pkg = 'tonyfettes/raylib/internal/raylib';

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
} else {
  throw new Error(`Unsupported platform: ${platform}`);
}

const output = {
  vars: { RAYLIB_STUB_CC_FLAGS: stub_cc_flags },
  link_configs: [link_config],
};
console.log(JSON.stringify(output));
