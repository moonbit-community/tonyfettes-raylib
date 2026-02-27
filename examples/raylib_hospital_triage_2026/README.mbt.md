# Hospital Triage 2026

A time-management game where you play as a nurse triaging patients across four hospital wards. Prioritize critical cases before they worsen and leave untreated.

## Build and Run

```bash
cd examples && moon build --target native raylib_hospital_triage_2026/
cd examples && ./_build/native/debug/build/raylib_hospital_triage_2026/raylib_hospital_triage_2026.exe
```

## Controls

- **A/D or Left/Right**: Move between wards
- **Space or Enter**: Admit the closest patient in the current ward
- **R**: Restart shift

## How to Play

Patients arrive continuously in 4 wards with varying severity levels: Mild (green), Medium (orange), and Critical (red). Move the nurse between wards and admit patients to the treatment bed. Each treatment takes time based on severity -- critical patients take longest but award the most points.

Patients who wait too long or walk off-screen are lost, costing lives (critical patients cost 2 lives). Successfully treating patients adds bonus time. Survive until the 150-second shift timer runs out, or lose when lives hit zero.
