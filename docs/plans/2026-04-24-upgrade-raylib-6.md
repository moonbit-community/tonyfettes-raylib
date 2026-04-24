# Upgrade Vendored raylib to 6.0

> **For Codex:** Use the MoonBit workflow for any implementation work: inspect package boundaries first, keep public API changes deliberate, run `moon check`, `moon test`, `moon fmt`, and `moon info` before handoff.

**Goal:** Upgrade the vendored raylib source from 5.5 to raylib 6.0 while preserving the existing MoonBit API wherever practical. Treat the C/FFI layer as the migration boundary: hard-migrate internal stubs to raylib 6.0, then add compatibility wrappers and `#deprecated` guidance only at the MoonBit public API layer.

**Upstream target:** raylib 6.0, released 2026-04-23. Primary references:

- https://github.com/raysan5/raylib/releases/tag/6.0
- https://github.com/raysan5/raylib/blob/6.0/CHANGELOG
- https://github.com/raysan5/raylib/blob/6.0/src/raylib.h
- https://github.com/raysan5/raylib/blob/6.0/src/rlgl.h
- https://github.com/raysan5/raylib/blob/6.0/src/config.h

**Current local state:** The repo vendors raylib 5.5 under `internal/raylib`. Local build metadata still compiles `utils.c`, and the stubs directly access raylib C structs such as `Model`, `Mesh`, and `ModelAnimation`.

---

## Compatibility Policy

### Preserve public MoonBit APIs where possible

Most downstream users should not need immediate source edits. Preserve existing high-level names by remapping their implementation to the raylib 6.0 layout:

- `Model::bone_count`, `Model::bone_parent`, `Model::bone_name`, `Model::bind_pose_translation`, `Model::bind_pose_rotation`
- `ModelAnimations` loading/count/unload APIs
- Existing high-level `Model::update_animation`
- Existing filesystem, compression, text, drawing, shader, texture, and audio wrappers when the upstream API is unchanged

### Add deprecations for renamed or semantically shifted APIs

Use `#deprecated` for old public MoonBit names that can be implemented safely but no longer match raylib 6.0 naming or semantics. Add a replacement path in the doc comment. Candidate compatibility shims:

- Keep animation accessors using `frame` terminology as deprecated if new APIs expose `keyframe` terminology.
- Keep `Model::update_animation_bones` only if it can safely forward to `UpdateModelAnimation()`. Mark it deprecated because raylib 6.0 removed `UpdateModelAnimationBones()`.
- Keep old low-level `rlgl` helper names only if their old semantics can be reproduced exactly. Otherwise break them clearly.

### Hard-break only where compatibility would lie

Internal C stubs must hard-migrate. Do not try to fake compatibility inside C with old struct fields or removed symbols. Public hard breaks are acceptable for:

- `draw_circle_gradient`: change the public MoonBit signature directly to `draw_circle_gradient(center : Vector2, radius : Float, inner : Color, outer : Color)` to match raylib 6.0. Do not add a `_v`, `_ex`, or version-suffixed compatibility function.
- Removed low-level `rlgl` symbols whose old behavior cannot be reproduced safely
- APIs exposing exact animation internals if the raylib 6.0 structure changes the data model
- Any function where keeping the old name would imply a behavior raylib 6.0 no longer provides

---

## Migration Risks

### Risk 1: `utils` module removal

raylib 6.0 folds filesystem/logging utility functionality into `rcore`. This repo currently compiles `utils.c` from:

- `internal/raylib/moon.pkg`
- `CMakeLists.txt`

Expected work:

- Remove `utils.c` from native stub/source lists after vendoring 6.0.
- Remove or replace local `internal/raylib/utils.c` and `internal/raylib/utils.h` only after confirming no local stubs include them directly.
- Keep MoonBit `utils.mbt` public wrappers if the underlying C functions still exist in `rcore`.

### Risk 2: `ModelSkeleton` and animation redesign

raylib 5.5 had fields directly on `Model`:

```c
int boneCount;
BoneInfo *bones;
Transform *bindPose;
```

raylib 6.0 moves them under:

```c
ModelSkeleton skeleton;
ModelAnimPose currentPose;
Matrix *boneMatrices;
```

Expected C stub changes:

- `model->boneCount` -> `model->skeleton.boneCount`
- `model->bones` -> `model->skeleton.bones`
- `model->bindPose` -> `model->skeleton.bindPose`
- Audit all direct `Mesh` animation fields. raylib 6.0 renames `boneIds` to `boneIndices` and moves runtime matrices from mesh-level storage to model-level `boneMatrices`.

raylib 6.0 also changes `ModelAnimation`:

- `frameCount` -> `keyframeCount`
- `framePoses` -> `keyframePoses`
- `UpdateModelAnimation(Model, ModelAnimation, int)` -> `UpdateModelAnimation(Model, ModelAnimation, float)`
- `UpdateModelAnimationBones()` is removed
- `UpdateModelAnimationEx()` is added for animation blending

Expected MoonBit compatibility:

- Preserve old model bone accessors by reading `Model.skeleton`.
- Preserve old animation count/unload behavior.
- Add 6.0-native keyframe APIs.
- Deprecate old frame-named APIs if they remain as aliases.

### Risk 3: `rlgl` shader API rename

raylib 6.0 changes the low-level shader API shape:

- `rlCompileShader` becomes `rlLoadShader`
- `rlLoadShaderCode(vs, fs)` becomes `rlLoadShaderProgram(vsCode, fsCode)`
- Existing `rlLoadShaderProgram(vShaderId, fShaderId)` behavior moves to `rlLoadShaderProgramEx(vsId, fsId)`
- `rlUnloadShader()` is added for shader objects
- `rlGetProcAddress()` is added

Expected work:

- Update `internal/raylib/core.mbt` extern declarations.
- Update `internal/raylib/stub_rlgl.c`.
- Update public `rl/` wrappers if they expose old names.
- Add compatibility aliases only when exact behavior is obvious.

### Risk 4: Signature-level public changes

Known raylib 6.0 signature changes that touch this repo:

- `DrawCircleGradient(int centerX, int centerY, ...)` -> `DrawCircleGradient(Vector2 center, ...)`
- `DecodeDataBase64(const unsigned char *data, ...)` -> `DecodeDataBase64(const char *text, ...)`
- `EncodeDataBase64()` now explicitly returns a NULL-terminated string including terminator in `outputSize`
- `SetSoundPan`, `SetMusicPan`, and `SetAudioStreamPan` comments now describe `-1.0..1.0` instead of `0.0..1.0`; verify behavior and docs

Expected work:

- Update C stubs to match exact 6.0 signatures.
- Ensure every MoonBit `String` passed to a 6.0 `const char *` API is NUL-terminated before C reads it.
- Preserve MoonBit return values without embedded NUL terminators where current API users expect clean strings.

### Risk 5: Build config redesign

raylib 6.0 config flags use explicit `0/1` values more consistently. GPU skinning config changed from local 5.5-era `RL_SUPPORT_MESH_GPU_SKINNING` assumptions to `SUPPORT_GPU_SKINNING`.

Expected work:

- Diff local `internal/raylib/config.h` against raylib 6.0 `src/config.h`.
- Decide whether this binding keeps GPU skinning enabled. Upstream 6.0 defaults it off.
- Convert local config overrides to 6.0-style flags.
- Avoid enabling new platform backends in the first pass.

### Risk 6: Platform backend churn

raylib 6.0 adds `PLATFORM_MEMORY`, `PLATFORM_DESKTOP_WIN32`, `PLATFORM_WEB_EMSCRIPTEN`, and `PLATFORM_WEB_RGFW`.

Initial policy:

- Keep existing platform selection: `PLATFORM_DESKTOP_GLFW`, `PLATFORM_WEB`, `PLATFORM_ANDROID`, `PLATFORM_DRM`.
- Do not switch Web to `PLATFORM_WEB_EMSCRIPTEN` in the first upgrade.
- Do not adopt `PLATFORM_MEMORY` until native/OpenGL parity is green.
- Treat new Win32 backend as a follow-up, not part of the core upgrade.

---

## Task 0: Baseline and Pre-Upgrade Safety Tests

**Purpose:** Record the current 5.5 behavior and add any missing characterization tests before vendoring raylib 6.0. These tests are the safety net for behavior the upgrade intends to preserve.

**Commands:**

```bash
git status --short
moon check --target native
moon test --target native
moon info
```

**Add or confirm pre-upgrade characterization tests:**

These should pass on raylib 5.5 before Task 1 starts and should continue to pass after the 6.0 migration unless the plan explicitly documents a hard break.

- `utils_test.mbt`: Base64 encode/decode round trip. Avoid invalid decode input before checking 5.5 behavior; it may be implementation-defined.
- `models_lifetime_test.mbt`: Load/unload models and animation arrays without leaks/crashes.
- `material_test.mbt`: Material map accessor round trips.
- `mesh_test.mbt`: Mesh field accessor round trips that do not rely on 6.0-only names.
- `shader_wbtest.mbt` or a shader example build: Existing low-level shader wrappers compile.
- `windowed_smoke_test.mbt`: Window/render dimensions are nonzero and sane, not exact high-DPI pixel assertions.

Do not write a pre-upgrade test for the new `draw_circle_gradient(Vector2, ...)` signature; the old signature is intentionally hard-broken during the upgrade.

**Pre-upgrade safety command:**

```bash
moon test --target native utils_test.mbt models_lifetime_test.mbt material_test.mbt mesh_test.mbt windowed_smoke_test.mbt
```

**Targeted smoke examples:**

```bash
moon build --target native examples/core/core_basic_window
moon build --target native examples/shapes/shapes_basic_shapes
moon build --target native examples/textures/textures_image_processing
moon build --target native examples/shaders/shaders_basic_lighting
moon build --target native examples/models/models_animation
moon build --target native examples/models/models_bone_socket
moon build --target native examples/audio/audio_sound_loading
```

**Deliverables:**

- Baseline command results in the PR description or upgrade log.
- Note any currently failing tests before the raylib source replacement.
- Confirm whether untracked docs/examples are user work and leave them untouched.

---

## Task 1: Vendor raylib 6.0 Source

**Purpose:** Replace upstream raylib C sources while preserving this repo's MoonBit stubs.

**Files to replace from upstream `src/`:**

- `internal/raylib/raylib.h`
- `internal/raylib/raymath.h`
- `internal/raylib/rlgl.h`
- `internal/raylib/config.h`
- `internal/raylib/rcore.c`
- `internal/raylib/rshapes.c`
- `internal/raylib/rtextures.c`
- `internal/raylib/rtext.c`
- `internal/raylib/rmodels.c`
- `internal/raylib/raudio.c`
- `internal/raylib/rgestures.h`
- `internal/raylib/rcamera.h`
- `internal/raylib/platforms/*`
- `internal/raylib/external/*`

**Special handling:**

- Do not overwrite `stub_*.c`, `stub_internal.h`, or `*.mbt` binding files from upstream.
- Remove `internal/raylib/utils.c` and `internal/raylib/utils.h` only after build metadata is updated.
- Add new required 6.0 files such as `rlsw.h` if the vendored source includes or requires them, even if software rendering is not enabled yet.
- Keep local external dependencies complete enough for all enabled formats in `config.h`.

**Verification:**

```bash
rg -n '#define RAYLIB_VERSION|#define RLGL_VERSION' internal/raylib/raylib.h internal/raylib/rlgl.h
rg -n 'utils\\.c|utils\\.h' internal/raylib CMakeLists.txt internal/raylib/moon.pkg
```

Expected version output:

- `RAYLIB_VERSION_MAJOR 6`
- `RAYLIB_VERSION_MINOR 0`
- `RAYLIB_VERSION "6.0"`
- `RLGL_VERSION "6.0"`

---

## Task 2: Update Build Metadata

**Purpose:** Make the vendored 6.0 C sources compile as a library before fixing binding semantics.

**Files:**

- Modify: `internal/raylib/moon.pkg`
- Modify: `CMakeLists.txt`
- Modify: `build.js`
- Modify: `internal/raylib/config.h` if local config flags need preservation

**Steps:**

1. Remove `utils.c` from `internal/raylib/moon.pkg`.
2. Remove `${RAYLIB_SRC_DIR}/utils.c` from `CMakeLists.txt`.
3. Keep `rglfw.c` desktop-only unless raylib 6.0 changed the expected inclusion model.
4. Keep `build.js` default as `-DPLATFORM_DESKTOP_GLFW`.
5. Keep web as `-DPLATFORM_WEB -DGRAPHICS_API_OPENGL_ES2` for first pass.
6. Keep Android and DRM definitions unchanged unless the 6.0 compile errors require updates.
7. Reconcile `SUPPORT_GPU_SKINNING`; decide explicitly whether it should be `1` or `0`.

**Do not do yet:**

- Do not enable `GRAPHICS_API_OPENGL_SOFTWARE`.
- Do not add `PLATFORM_MEMORY`.
- Do not switch to native Win32 backend.
- Do not switch web to `PLATFORM_WEB_EMSCRIPTEN`.

**Verification:**

```bash
moon check --target native
```

Expected result: compile errors will likely remain in stubs, but errors should no longer be about missing `utils.c`.

---

## Task 3: Hard-Migrate C Stubs to raylib 6.0

**Purpose:** Fix C compile errors and ABI mismatches without changing the public MoonBit API yet.

### 3.1 Model and animation stubs

**Files:**

- Modify: `internal/raylib/stub_models.c`
- Modify: `internal/raylib/models.mbt` if extern signatures change
- Modify: `model.mbt` and `models.mbt` only if public wrappers need type/signature changes

**Required changes:**

- Replace direct model skeleton fields:
  - `m->data->boneCount` -> `m->data->skeleton.boneCount`
  - `m->data->bones` -> `m->data->skeleton.bones`
  - `m->data->bindPose` -> `m->data->skeleton.bindPose`
- Replace animation fields:
  - `anim.frameCount` -> `anim.keyframeCount`
  - `anim.framePoses` -> `anim.keyframePoses`
- Update `UpdateModelAnimation()` call to pass `float frame`.
- Remove direct call to `UpdateModelAnimationBones()`.
- Add wrapper for `UpdateModelAnimationEx()` if exposing animation blending in this release.
- Audit mesh animation accessors:
  - `Mesh.boneIds` likely becomes `Mesh.boneIndices`
  - `Mesh.boneMatrices` likely moves away from `Mesh`; use `Model.boneMatrices` where appropriate

**Compatibility implementation choices:**

- Existing `get_model_animation_frame_count()` can return `keyframeCount` for now.
- Existing frame pose accessors can read `keyframePoses`.
- Existing `update_model_animation_bones()` can call `UpdateModelAnimation()` if behavior is close enough, but the public wrapper must be deprecated.
- If mesh bone matrix access cannot be preserved safely, make that a documented hard break.

**Targeted tests/examples:**

```bash
moon test --target native models_lifetime_test.mbt
moon build --target native examples/models/models_animation
moon build --target native examples/models/models_bone_socket
moon build --target native examples/models/models_gpu_skinning
```

### 3.2 Shape signature stubs

**Files:**

- Modify: `internal/raylib/stub_shapes.c`
- Modify: `internal/raylib/shapes.mbt`
- Modify: `shapes.mbt`

**Required change:**

- Update `DrawCircleGradient` stub to construct/pass `Vector2 center`.

**Public API decision:**

- Hard-break `draw_circle_gradient` to take `Vector2 center`.
- Fix all in-repo callers.
- Document downstream migration as `draw_circle_gradient(x, y, radius, inner, outer)` -> `draw_circle_gradient(Vector2::new(...), radius, inner, outer)`.
- Do not add `draw_circle_gradient_v`, `draw_circle_gradient_ex`, or `draw_circle_gradient_v6`.

**Targeted tests/examples:**

```bash
moon test --target native shapes_test.mbt
moon build --target native examples/shapes/shapes_basic_shapes
```

### 3.3 Base64 and C-string ABI fixes

**Purpose:** Fix existing wrappers affected by raylib 6.0's stricter string signatures. This task should not add broad new text APIs; those belong in Task 4 after the upgrade compiles.

**Files:**

- Modify: `internal/raylib/stub_utils.c`
- Modify: `utils.mbt` if public docs or behavior need updates

**Required changes:**

- Ensure `DecodeDataBase64()` receives NUL-terminated text.
- Keep `EncodeDataBase64()` result excluding the final NUL in MoonBit return values unless changing public behavior deliberately.
- Audit any existing stub that casts `moonbit_bytes_t` to `const char *` and passes it to a raylib 6.0 API that now explicitly expects a NUL-terminated string.

**Concrete Base64 migration:**

- Current local `encode_data_base64(data : Bytes) -> String` can keep the same MoonBit API.
- Current local `decode_data_base64(data : String) -> Bytes` can keep the same MoonBit API.
- The C stub should create/pass a NUL-terminated buffer for decode if MoonBit's encoded bytes do not guarantee one.
- The C stub should free raylib-allocated buffers with `RL_FREE`/`MemFree` according to the 6.0 implementation.

**Not part of this task:**

- Do not add `ComputeSHA256()` here unless it is required to fix compilation. Add it in Task 4 as a new 6.0 API.
- Do not add `LoadTextLines()`, `TextInsertAlloc()`, `TextReplaceAlloc()`, or other new text APIs here. Add them in Task 4 after ownership policy is decided.

**Tests:**

```bash
moon test --target native utils_test.mbt
```

### 3.4 rlgl shader stubs

**Files:**

- Modify: `internal/raylib/core.mbt`
- Modify: `internal/raylib/stub_rlgl.c`
- Modify: `rl/rl.mbt`
- Modify: `rl/pkg.generated.mbti` after `moon info`

**Required changes:**

- `rlCompileShader(code, type)` -> use `rlLoadShader(code, type)`.
- Old `rlLoadShaderCode(vs, fs)` -> use `rlLoadShaderProgram(vsCode, fsCode)`.
- Old `rlLoadShaderProgram(vsId, fsId)` -> use `rlLoadShaderProgramEx(vsId, fsId)`.
- Add `rlUnloadShader(id)`.
- Add `rlGetProcAddress(name)` only if useful and safely representable in MoonBit.

**Compatibility implementation:**

- Keep public old names as deprecated wrappers if no ambiguity.
- For functions whose C symbol no longer exists, use C stubs to adapt old public names to new 6.0 calls.

**Targeted tests/examples:**

```bash
moon build --target native examples/shaders/shaders_basic_lighting
moon build --target native examples/shaders/shaders_rlgl_compute
```

### 3.5 Window, platform, and high-DPI behavior

**Files:**

- Inspect: `window.mbt`
- Inspect: `internal/raylib/stub_window.c`
- Inspect: `examples/core/core_window_flags/main.mbt`

**Required checks:**

- `GetRenderWidth()` and `GetRenderHeight()` behavior changed around active FBOs and high-DPI scaling. Keep tests tolerant where they only assert nonzero dimensions.
- Fullscreen behavior changed. Add manual test notes rather than brittle automated tests.
- Confirm `FLAG_WINDOW_HIGHDPI` constant value remains correct.

**Targeted tests/examples:**

```bash
moon test --target native window_test.mbt windowed_smoke_test.mbt
moon build --target native examples/core/core_window_flags
```

---

## Task 4: Restore MoonBit Compatibility Layer

**Purpose:** Once C stubs compile, make downstream migration graceful.

**Files likely touched:**

- `model.mbt`
- `models.mbt`
- `shapes.mbt`
- `shader.mbt`
- `utils.mbt`
- `rl/rl.mbt`
- `pkg.generated.mbti`
- `rl/pkg.generated.mbti`

**Work items:**

1. Add 6.0-native public APIs where useful:
   - `Model::update_animation_ex` or equivalent for animation blending
   - Keyframe-named animation accessors
   - New filesystem APIs: `file_rename`, `file_remove`, `file_copy`, `file_move`, `file_text_replace`, `file_text_find_index`
   - New text APIs: `load_text_lines`, `unload_text_lines`, `measure_text_codepoints`, allocation-returning text helpers if ownership can be represented safely
   - `compute_sha256`
2. Mark compatibility wrappers as deprecated with direct replacement guidance.
3. Avoid exposing raw `ModelSkeleton` immediately unless there is a clear MoonBit-level design.
4. Prefer opaque wrappers over public mutable records for new 6.0 structs.
5. Regenerate and review `.mbti` with `moon info`.

**Deprecation candidates:**

- `Model::update_animation_bones`
- Any public animation function using `frame` when it now means `keyframe`
- Old low-level `rlgl` shader names that no longer match upstream naming

**Public hard-break review:**

Before finalizing, explicitly list any removed or changed public APIs in the PR description. If an old API can be implemented without lying about semantics, keep it deprecated for one release.

---

## Task 5: Add Post-Upgrade 6.0 Tests

**Purpose:** Add tests for new or intentionally changed raylib 6.0 behavior after the C stubs compile. Pre-upgrade characterization tests belong in Task 0.

**Add or extend tests:**

- `shapes_test.mbt`: `draw_circle_gradient(Vector2, radius, inner, outer)` compiles and runs.
- `utils_test.mbt`: Base64 invalid decode input does not read past the end of the provided string; SHA256 test if exposed.
- Model animation tests: `keyframe` accessors work if exposed, and compatibility `frame` accessors still read the same data if retained.
- Animation blending test or example build if `UpdateModelAnimationEx()` is exposed.
- `mesh_test.mbt`: 6.0 mesh animation fields, especially `boneIndices`, are accessed correctly if exposed.
- `shader_wbtest.mbt`: 6.0 `rlLoadShader`, `rlLoadShaderProgram`, `rlLoadShaderProgramEx`, and `rlUnloadShader` wrappers compile if exposed.
- `windowed_smoke_test.mbt`: High-DPI/window render dimensions remain sane under 6.0.

**Manual examples to run after compile green:**

```bash
moon build --target native examples/core/core_basic_window
moon build --target native examples/core/core_window_flags
moon build --target native examples/shapes/shapes_basic_shapes
moon build --target native examples/textures/textures_image_processing
moon build --target native examples/text/text_font_loading
moon build --target native examples/shaders/shaders_basic_lighting
moon build --target native examples/models/models_animation
moon build --target native examples/models/models_bone_socket
moon build --target native examples/models/models_gpu_skinning
moon build --target native examples/audio/audio_sound_loading
```

**Optional ASan pass:**

```bash
python3 scripts/run-asan.py
```

Use this especially after model/animation and text allocation changes.

---

## Task 6: Web, Android, and DRM Follow-Up

**Purpose:** Keep the core native upgrade manageable, then validate platform-specific paths.

### Web

Initial target remains `PLATFORM_WEB` with Emscripten GLFW. Validate existing build scripts first:

```bash
RAYLIB_PLATFORM=web moon check --target wasm-gc
```

Then run at least one existing web build script from `tools/`.

Do not switch to `PLATFORM_WEB_EMSCRIPTEN` until:

- Native tests are green.
- Existing `PLATFORM_WEB` build still works or the break is understood.
- Browser input/canvas behavior is manually checked.

### Android

Validate compile with existing Gradle or MoonBit integration. Watch for raylib 6.0 Android `fopen` wrapping changes.

Key risk:

- Upstream moved Android file wrapping toward linker `--wrap=fopen`. Check whether this repo's Android packaging needs linker flags.

### DRM

Keep `PLATFORM_DRM` as-is initially. raylib 6.0 changed DRM page flipping/cache behavior. Validate on real hardware if this target matters.

---

## Task 7: Documentation and Release Notes

**Purpose:** Make downstream migration explicit.

**Files:**

- `README.md`
- `CHANGELOG.md` if present or release notes in PR body
- Public API docs/comments near deprecated wrappers

**Document:**

- Vendored raylib is now 6.0.
- Compatibility wrappers retained for one release.
- Deprecated APIs and exact replacements.
- Any hard breaks with reason.
- Platform backends intentionally not adopted yet: `PLATFORM_MEMORY`, `PLATFORM_DESKTOP_WIN32`, `PLATFORM_WEB_EMSCRIPTEN`.
- Known behavior changes:
  - Random generation uses less biased `GetRandomValue()`.
  - Fullscreen/high-DPI behavior changed.
  - Animation update path changed.
  - Pan APIs use `-1.0..1.0` semantics in upstream docs.

---

## Acceptance Criteria

The upgrade is complete when:

- `internal/raylib/raylib.h` and `internal/raylib/rlgl.h` report version 6.0.
- `utils.c` is no longer compiled.
- `moon check --target native` passes.
- `moon test --target native` passes or all pre-existing failures are documented.
- `moon fmt` and `moon info` have been run.
- `.mbti` changes are reviewed and contain only intended public API changes.
- Model animation examples build and at least one is manually smoke-tested.
- Shader examples build after rlgl migration.
- Deprecated compatibility wrappers exist for avoidable downstream breaks.
- Any unavoidable hard breaks are documented with replacement guidance.

---

## Suggested PR Structure

Ship this as one green upgrade PR. Do not open or merge intermediate PRs that leave the repo uncompilable or partially migrated.

Use internal commits or PR sections to keep review manageable:

1. Add/confirm pre-upgrade characterization tests.
2. Vendor raylib 6.0 and update build metadata.
3. Fix C stubs for compile compatibility.
4. Restore MoonBit compatibility wrappers and deprecations.
5. Add selected new raylib 6.0 APIs.
6. Add post-upgrade 6.0 tests and platform validation fixes.

The final PR must pass native `moon check`, `moon test`, `moon fmt`, and `moon info`. If web, Android, or DRM validation cannot be completed in the same PR, document that as a follow-up risk, but keep the native package green.
