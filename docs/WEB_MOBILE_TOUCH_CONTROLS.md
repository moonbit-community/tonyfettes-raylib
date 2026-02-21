# Web Mobile Touch Controls

WebAssembly runs on mobile browsers, but most of these MoonBit + raylib games are keyboard-driven.
To make mobile playable, web builds now inject a touch overlay (`tools/web_mobile_touch.post.js`) and map buttons to keyboard events.

## Touch To Keyboard Mapping

- `D-pad Up` -> `W` + `ArrowUp`
- `D-pad Left` -> `A` + `ArrowLeft`
- `D-pad Down` -> `S` + `ArrowDown`
- `D-pad Right` -> `D` + `ArrowRight`
- `A` button -> `J` + `Space`
- `B` button -> `K` + `Enter`
- `C` button -> `L` + `Shift`
- `II` button -> `Esc` (menu/pause)

Each touch press sends `keydown`, and release sends `keyup`.
Multiple simultaneous touches are supported.

## Build Notes

- Generic web build entrypoint: `tools/build_web_native_emcc.sh`
- Mobile touch patch is injected via:
  - `--post-js tools/web_mobile_touch.post.js`

## Quick Local Validation

```bash
tools/build_web_tank_1990.sh
python3 -m http.server 8080
# open http://127.0.0.1:8080/_build/web/raylib_tank_1990/raylib_tank_1990.html on a phone
```
