if (typeof Module !== 'object') Module = {};

const __previousPreRun = Module.preRun;
Module.preRun = Module.preRun || [];

if (typeof __previousPreRun === 'function') {
  Module.preRun.unshift(__previousPreRun);
} else if (Array.isArray(__previousPreRun)) {
  Module.preRun.unshift(...__previousPreRun);
}

Module.preRun.push(function () {
  if (typeof Browser !== 'object' || typeof Browser.createContext !== 'function') return;

  const originalCreateContext = Browser.createContext;

  Browser.createContext = function (canvas, useWebGL, setInModule, webGLContextAttributes) {
    if (useWebGL) {
      const contextAttributes = webGLContextAttributes ? { ...webGLContextAttributes } : {};
      // Emscripten GLFW defaults to WebGL2 when available. Force WebGL1 because
      // raylib's PLATFORM_WEB + OpenGL ES2 path is stable on that context profile.
      contextAttributes.majorVersion = 1;
      return originalCreateContext.call(Browser, canvas, useWebGL, setInModule, contextAttributes);
    }

    return originalCreateContext.call(Browser, canvas, useWebGL, setInModule, webGLContextAttributes);
  };
});
