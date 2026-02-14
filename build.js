const os = require('os');
const platform = os.platform();

let link_config = { package: 'tonyfettes/raylib/internal/raylib' };

if (platform === 'darwin') {
  link_config.link_flags = '-framework OpenGL -framework Cocoa -framework IOKit -framework CoreAudio -framework CoreVideo -framework AudioToolbox -framework CoreFoundation';
} else if (platform === 'linux') {
  link_config.link_libs = ['GL', 'm', 'pthread', 'dl', 'rt', 'X11'];
} else if (platform === 'win32') {
  link_config.link_libs = ['opengl32', 'gdi32', 'winmm', 'user32', 'shell32'];
} else {
  throw new Error(`Unsupported platform: ${platform}`);
}

const output = { link_configs: [link_config] };
console.log(JSON.stringify(output));
