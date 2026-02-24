if (typeof Module !== "object") Module = {};

(function () {
  const __previousPreRun = Module.preRun;
  Module.preRun = Module.preRun || [];

  if (typeof __previousPreRun === "function") {
    Module.preRun.unshift(__previousPreRun);
  } else if (Array.isArray(__previousPreRun)) {
    Module.preRun.unshift(...__previousPreRun);
  }

  let installScheduled = false;

  function scheduleInstall() {
    if (installScheduled) return;
    installScheduled = true;

    if (typeof document !== "object") return;

    if (document.readyState === "loading") {
      document.addEventListener("DOMContentLoaded", installTouchControls, { once: true });
    } else {
      installTouchControls();
    }
  }

  Module.preRun.push(scheduleInstall);
  scheduleInstall();

  function installTouchControls() {
    if (typeof window !== "object" || typeof document !== "object") return;

    let hasTouch = false;
    try {
      hasTouch = "ontouchstart" in window || navigator.maxTouchPoints > 0;
      if (!hasTouch && window.matchMedia) {
        hasTouch = window.matchMedia("(pointer: coarse)").matches;
      }
    } catch (_) {
      hasTouch = false;
    }

    if (!hasTouch) return;
    if (document.getElementById("moonbit-touch-overlay")) return;

    const canvas = Module.canvas || document.getElementById("canvas");
    if (!canvas) return;

    const KEY_INFO = {
      13: { key: "Enter", code: "Enter" },
      16: { key: "Shift", code: "ShiftLeft" },
      27: { key: "Escape", code: "Escape" },
      32: { key: " ", code: "Space" },
      37: { key: "ArrowLeft", code: "ArrowLeft" },
      38: { key: "ArrowUp", code: "ArrowUp" },
      39: { key: "ArrowRight", code: "ArrowRight" },
      40: { key: "ArrowDown", code: "ArrowDown" },
      65: { key: "a", code: "KeyA" },
      68: { key: "d", code: "KeyD" },
      74: { key: "j", code: "KeyJ" },
      75: { key: "k", code: "KeyK" },
      76: { key: "l", code: "KeyL" },
      83: { key: "s", code: "KeyS" },
      87: { key: "w", code: "KeyW" },
    };

    const CONTROL_KEYS = {
      up: [87, 38],
      down: [83, 40],
      left: [65, 37],
      right: [68, 39],
      actionA: [74, 32],
      actionB: [75, 13],
      actionC: [76, 16],
      menu: [27],
    };

    const keyRefCounts = new Map();

    function dispatchKey(type, keyCode) {
      const keyDef = KEY_INFO[keyCode] || { key: "", code: "" };

      let event;
      try {
        event = new KeyboardEvent(type, {
          key: keyDef.key,
          code: keyDef.code,
          bubbles: true,
          cancelable: true,
        });
      } catch (_) {
        event = new Event(type, { bubbles: true, cancelable: true });
      }

      try {
        Object.defineProperty(event, "keyCode", { get: () => keyCode });
        Object.defineProperty(event, "which", { get: () => keyCode });
      } catch (_) {}

      try {
        if (!("key" in event)) event.key = keyDef.key;
        if (!("code" in event)) event.code = keyDef.code;
      } catch (_) {}

      window.dispatchEvent(event);
    }

    function keyDown(keyCode) {
      const count = keyRefCounts.get(keyCode) || 0;
      keyRefCounts.set(keyCode, count + 1);
      if (count === 0) {
        dispatchKey("keydown", keyCode);
      }
    }

    function keyUp(keyCode) {
      const count = keyRefCounts.get(keyCode) || 0;
      if (count <= 1) {
        keyRefCounts.delete(keyCode);
        dispatchKey("keyup", keyCode);
      } else {
        keyRefCounts.set(keyCode, count - 1);
      }
    }

    function releaseAllKeys() {
      for (const keyCode of keyRefCounts.keys()) {
        dispatchKey("keyup", keyCode);
      }
      keyRefCounts.clear();
      for (const active of document.querySelectorAll(".moonbit-touch-btn.active")) {
        active.classList.remove("active");
      }
    }

    function ensureCanvasFocus() {
      try {
        canvas.focus();
      } catch (_) {}
    }

    function preventTouchScroll(event) {
      event.preventDefault();
    }

    if (!document.getElementById("moonbit-touch-style")) {
      const style = document.createElement("style");
      style.id = "moonbit-touch-style";
      style.textContent = `
        body.moonbit-touch-enabled {
          margin: 0 !important;
          overflow: hidden;
          background: #000;
          overscroll-behavior: none;
          touch-action: none;
        }

        body.moonbit-touch-enabled #controls,
        body.moonbit-touch-enabled #output,
        body.moonbit-touch-enabled #emscripten_logo,
        body.moonbit-touch-enabled #spinner,
        body.moonbit-touch-enabled #status,
        body.moonbit-touch-enabled #progress {
          display: none !important;
        }

        body.moonbit-touch-enabled .emscripten_border {
          border: 0 !important;
        }

        body.moonbit-touch-enabled canvas.emscripten {
          display: block;
          width: 100vw !important;
          height: 100vh !important;
          max-width: 100vw !important;
          max-height: 100vh !important;
          margin: 0 !important;
          touch-action: none;
        }

        #moonbit-touch-overlay {
          position: fixed;
          inset: 0;
          z-index: 9999;
          pointer-events: none;
          user-select: none;
          -webkit-user-select: none;
          -webkit-touch-callout: none;
        }

        .moonbit-touch-pad {
          position: absolute;
          bottom: calc(16px + env(safe-area-inset-bottom));
          width: 168px;
          height: 168px;
        }

        .moonbit-touch-pad.left {
          left: calc(14px + env(safe-area-inset-left));
        }

        .moonbit-touch-pad.right {
          right: calc(14px + env(safe-area-inset-right));
        }

        .moonbit-touch-btn {
          pointer-events: auto;
          position: absolute;
          border: 1px solid rgba(255, 255, 255, 0.34);
          background: rgba(19, 24, 37, 0.48);
          color: #f4f8ff;
          font-weight: 700;
          border-radius: 999px;
          width: 52px;
          height: 52px;
          font-size: 19px;
          display: flex;
          align-items: center;
          justify-content: center;
          touch-action: none;
          backdrop-filter: blur(2px);
          -webkit-tap-highlight-color: transparent;
        }

        .moonbit-touch-btn.small {
          width: 42px;
          height: 42px;
          font-size: 15px;
        }

        .moonbit-touch-btn.active {
          transform: scale(0.96);
          background: rgba(67, 113, 186, 0.72);
          border-color: rgba(173, 213, 255, 0.86);
        }

        .moonbit-touch-btn.up {
          left: 58px;
          top: 0;
        }

        .moonbit-touch-btn.left {
          left: 0;
          top: 58px;
        }

        .moonbit-touch-btn.down {
          left: 58px;
          top: 116px;
        }

        .moonbit-touch-btn.right {
          left: 116px;
          top: 58px;
        }

        .moonbit-touch-btn.actionA {
          right: 0;
          top: 58px;
        }

        .moonbit-touch-btn.actionB {
          right: 58px;
          top: 0;
        }

        .moonbit-touch-btn.actionC {
          right: 116px;
          top: 58px;
        }

        .moonbit-touch-btn.menu {
          right: 58px;
          top: 116px;
        }

        #moonbit-touch-hint {
          position: fixed;
          left: 50%;
          bottom: calc(8px + env(safe-area-inset-bottom));
          transform: translateX(-50%);
          padding: 3px 8px;
          border-radius: 8px;
          border: 1px solid rgba(255, 255, 255, 0.2);
          background: rgba(8, 11, 18, 0.58);
          color: rgba(245, 249, 255, 0.84);
          font-size: 11px;
          z-index: 10000;
          pointer-events: none;
          white-space: nowrap;
        }

        @media (max-width: 480px) {
          .moonbit-touch-pad {
            width: 152px;
            height: 152px;
          }

          .moonbit-touch-btn {
            width: 46px;
            height: 46px;
            font-size: 17px;
          }

          .moonbit-touch-btn.up {
            left: 53px;
            top: 0;
          }

          .moonbit-touch-btn.left {
            left: 0;
            top: 53px;
          }

          .moonbit-touch-btn.down {
            left: 53px;
            top: 106px;
          }

          .moonbit-touch-btn.right {
            left: 106px;
            top: 53px;
          }

          .moonbit-touch-btn.actionA {
            right: 0;
            top: 53px;
          }

          .moonbit-touch-btn.actionB {
            right: 53px;
            top: 0;
          }

          .moonbit-touch-btn.actionC {
            right: 106px;
            top: 53px;
          }

          .moonbit-touch-btn.menu {
            right: 53px;
            top: 106px;
          }
        }
      `;
      document.head.appendChild(style);
    }

    document.body.classList.add("moonbit-touch-enabled");
    canvas.tabIndex = 0;
    canvas.style.touchAction = "none";
    canvas.addEventListener("touchstart", preventTouchScroll, { passive: false });
    canvas.addEventListener("touchmove", preventTouchScroll, { passive: false });

    const overlay = document.createElement("div");
    overlay.id = "moonbit-touch-overlay";
    overlay.innerHTML = `
      <div class="moonbit-touch-pad left">
        <button class="moonbit-touch-btn up" data-control="up" aria-label="Move Up">▲</button>
        <button class="moonbit-touch-btn left" data-control="left" aria-label="Move Left">◀</button>
        <button class="moonbit-touch-btn down" data-control="down" aria-label="Move Down">▼</button>
        <button class="moonbit-touch-btn right" data-control="right" aria-label="Move Right">▶</button>
      </div>
      <div class="moonbit-touch-pad right">
        <button class="moonbit-touch-btn actionA" data-control="actionA" aria-label="Action A">A</button>
        <button class="moonbit-touch-btn actionB" data-control="actionB" aria-label="Action B">B</button>
        <button class="moonbit-touch-btn actionC" data-control="actionC" aria-label="Action C">C</button>
        <button class="moonbit-touch-btn menu small" data-control="menu" aria-label="Menu">II</button>
      </div>
    `;
    overlay.addEventListener("contextmenu", (event) => event.preventDefault());
    document.body.appendChild(overlay);

    if (!document.getElementById("moonbit-touch-hint")) {
      const hint = document.createElement("div");
      hint.id = "moonbit-touch-hint";
      hint.textContent = "Touch controls: D-pad + A/B/C + II(menu)";
      document.body.appendChild(hint);
    }

    function installControlHandlers(button, controlName) {
      const mappedKeys = CONTROL_KEYS[controlName] || [];
      const activePointers = new Set();

      function press(pointerId) {
        if (activePointers.has(pointerId)) return;
        activePointers.add(pointerId);
        button.classList.add("active");
        ensureCanvasFocus();
        for (const keyCode of mappedKeys) keyDown(keyCode);
      }

      function release(pointerId) {
        if (!activePointers.has(pointerId)) return;
        activePointers.delete(pointerId);
        for (const keyCode of mappedKeys) keyUp(keyCode);
        if (activePointers.size === 0) {
          button.classList.remove("active");
        }
      }

      if (window.PointerEvent) {
        button.addEventListener(
          "pointerdown",
          (event) => {
            press(event.pointerId);
            try {
              button.setPointerCapture(event.pointerId);
            } catch (_) {}
            event.preventDefault();
          },
          { passive: false },
        );

        button.addEventListener(
          "pointerup",
          (event) => {
            release(event.pointerId);
            event.preventDefault();
          },
          { passive: false },
        );

        button.addEventListener(
          "pointercancel",
          (event) => {
            release(event.pointerId);
            event.preventDefault();
          },
          { passive: false },
        );

        button.addEventListener(
          "pointerleave",
          (event) => {
            if (event.buttons === 0) {
              release(event.pointerId);
            }
          },
          { passive: false },
        );
      } else {
        button.addEventListener(
          "touchstart",
          (event) => {
            for (const touch of event.changedTouches) {
              press(`t${touch.identifier}`);
            }
            event.preventDefault();
          },
          { passive: false },
        );

        button.addEventListener(
          "touchend",
          (event) => {
            for (const touch of event.changedTouches) {
              release(`t${touch.identifier}`);
            }
            event.preventDefault();
          },
          { passive: false },
        );

        button.addEventListener(
          "touchcancel",
          (event) => {
            for (const touch of event.changedTouches) {
              release(`t${touch.identifier}`);
            }
            event.preventDefault();
          },
          { passive: false },
        );
      }
    }

    for (const button of overlay.querySelectorAll("[data-control]")) {
      const controlName = button.getAttribute("data-control");
      installControlHandlers(button, controlName);
    }

    window.addEventListener("blur", releaseAllKeys);
    window.addEventListener("pagehide", releaseAllKeys);
    document.addEventListener("visibilitychange", () => {
      if (document.hidden) {
        releaseAllKeys();
      }
    });
  }
})();
