# Post Office Sorter 2026

A fast-paced sorting game where you operate a mail sorting gate on a conveyor belt. Packages with color-coded destinations (A/B/C/D) slide across four lanes -- position the sorter gate to intercept packages and ensure they match the correct lane mapping.

## Build and Run

```bash
cd examples && moon build --target native raylib_post_office_sorter_2026/
cd examples && ./_build/native/debug/build/raylib_post_office_sorter_2026/raylib_post_office_sorter_2026.exe
```

## Controls

- **W/S or Up/Down Arrow Keys**: Move the sorter gate between lanes
- **A/D or Left/Right Arrow Keys**: Shift the sorter gate position left/right
- **1/2/3/4**: Remap the selected lane's output destination (A/B/C/D)
- **R**: Restart

## How to Play

Packages labeled A through D spawn on the left and slide rightward across four lanes. Position the sorter gate on the correct lane to intercept them. Each lane has a configurable destination mapping -- use number keys 1-4 to assign which destination code (A/B/C/D) that lane sorts to. Correctly matched packages earn 28 points; wrong matches cost 18 points and a life; missed packages cost 12 points and a life. You have 5 lives before the sorting line shuts down.
