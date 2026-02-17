# Raylib MoonBit Binding — API Coverage & Progress Report

*Generated: 2026-02-18 | raylib version: 5.5 | Target: native only*

## Executive Summary

| Metric | Count | Percentage |
|--------|------:|------------|
| Raylib C API functions (RLAPI) | 581 | — |
| MoonBit FFI bindings (`extern "c"`) | ~583 | — |
| Bindable API covered | ~545 / ~549 | **~99%** |
| rlgl functions bound | ~50 | — |
| Intentionally not bound | ~32 | — |
| Official raylib examples | 209 | — |
| Examples ported to MoonBit | 147 | **~70%** |

The binding covers virtually all of the raylib 5.5 API that is meaningful to bind
from a GC-managed language. The remaining unbound functions are either
callback-based (requiring function pointers), C text utilities (redundant with
MoonBit's `String`), or C memory management (redundant with MoonBit's GC).
Audio processor callbacks have been bound using MoonBit's `FuncRef` mechanism.

In addition to the core raylib API, ~50 rlgl low-level OpenGL abstraction layer
functions are bound, covering geometry submission, matrix stack, framebuffer
management, shader management, texture management, and state control.

---

## 1. API Binding Coverage by Module

### 1.1 Core: Window Management (rcore)

| Status | Function | Notes |
|--------|----------|-------|
| Bound | `InitWindow`, `CloseWindow`, `WindowShouldClose` | |
| Bound | `IsWindowReady/Fullscreen/Hidden/Minimized/Maximized/Focused/Resized/State` | |
| Bound | `SetWindowState`, `ClearWindowState`, `ToggleFullscreen`, `ToggleBorderlessWindowed` | |
| Bound | `MaximizeWindow`, `MinimizeWindow`, `RestoreWindow` | |
| Bound | `SetWindowIcon`, `SetWindowTitle`, `SetWindowPosition` | |
| Bound | `SetWindowMonitor`, `SetWindowMinSize`, `SetWindowMaxSize` | |
| Bound | `SetWindowSize`, `SetWindowOpacity`, `SetWindowFocused` | |
| Bound | `GetScreenWidth/Height`, `GetRenderWidth/Height` | |
| Bound | `GetMonitorCount/Width/Height/PhysicalWidth/PhysicalHeight/RefreshRate/Position/Name` | |
| Bound | `GetCurrentMonitor`, `GetWindowPosition`, `GetWindowScaleDPI` | |
| Bound | `SetClipboardText`, `GetClipboardText`, `GetClipboardImage` | |
| Bound | `EnableEventWaiting`, `DisableEventWaiting` | |
| Bound | `ShowCursor`, `HideCursor`, `IsCursorHidden`, `EnableCursor`, `DisableCursor`, `IsCursorOnScreen` | |
| **Missing** | `SetWindowIcons` | Takes `Image *` array — requires array-of-opaque-pointer support |
| **Missing** | `GetWindowHandle` | Returns `void *` — not useful from MoonBit |

### 1.2 Core: Drawing Lifecycle & Rendering

| Status | Function | Notes |
|--------|----------|-------|
| Bound | `ClearBackground`, `BeginDrawing`, `EndDrawing` | |
| Bound | `BeginMode2D/3D`, `EndMode2D/3D` | |
| Bound | `BeginTextureMode`, `EndTextureMode` | |
| Bound | `BeginShaderMode`, `EndShaderMode` | |
| Bound | `BeginBlendMode`, `EndBlendMode` | |
| Bound | `BeginScissorMode`, `EndScissorMode` | |
| Bound | `BeginVrStereoMode`, `EndVrStereoMode` | |
| Bound | `LoadVrStereoConfig`, `UnloadVrStereoConfig` | |

### 1.3 rlgl Low-Level OpenGL Abstraction

| Status | Function | Notes |
|--------|----------|-------|
| Bound | `rlSetBlendMode`, `rlSetBlendFactors`, `rlDrawRenderBatchActive` | Custom blend modes |
| Bound | `rlBegin`, `rlEnd` | Immediate-mode geometry submission |
| Bound | `rlVertex2f`, `rlVertex3f` | Vertex position |
| Bound | `rlTexCoord2f` | Texture coordinates |
| Bound | `rlColor4ub` | Vertex color |
| Bound | `rlNormal3f` | Vertex normal |
| Bound | `rlSetTexture` | Bind texture for geometry |
| Bound | `rlPushMatrix`, `rlPopMatrix` | Matrix stack |
| Bound | `rlTranslatef`, `rlRotatef`, `rlScalef`, `rlMultMatrixf` | Matrix transforms |
| Bound | `rlEnableBackfaceCulling`, `rlDisableBackfaceCulling` | Culling state |
| Bound | `rlCheckRenderBatchLimit` | Batch overflow check |
| Bound | `rlEnableDepthTest`, `rlDisableDepthTest` | Depth test state |
| Bound | `rlEnableDepthMask`, `rlDisableDepthMask` | Depth write state |
| Bound | `rlEnableColorBlend`, `rlDisableColorBlend` | Color blend state |
| Bound | `rlActiveTextureSlot` | Multi-texture slot selection |
| Bound | `rlEnableTexture`, `rlDisableTexture` | Texture binding |
| Bound | `rlEnableShader`, `rlDisableShader` | Shader binding |
| Bound | `rlEnableFramebuffer`, `rlDisableFramebuffer` | FBO binding |
| Bound | `rlActiveDrawBuffers` | MRT draw buffer count |
| Bound | `rlViewport` | Viewport configuration |
| Bound | `rlClearScreenBuffers` | Clear all buffers |
| Bound | `rlLoadFramebuffer`, `rlFramebufferComplete`, `rlFramebufferAttach`, `rlUnloadFramebuffer` | FBO lifecycle |
| Bound | `rlLoadTextureDepth`, `rlLoadTexture`, `rlUnloadTexture` | Texture management |
| Bound | `rlGetLocationUniform` | Shader uniform location (wrapper: String→Bytes) |
| Bound | `rlSetUniform`, `rlSetUniformSampler` | Shader uniform setting |
| Bound | `rlGetShaderIdDefault` | Default shader ID |
| Bound | `rlGetMatrixModelview`, `rlGetMatrixProjection` | Matrix getters (wrapper: Bytes→Matrix) |
| Bound | `rlLoadDrawQuad`, `rlLoadDrawCube` | Built-in geometry |
| Bound | `rlGetFramebufferWidth`, `rlGetFramebufferHeight` | Framebuffer dimensions |
| Bound | `rlBindFramebuffer`, `rlBlitFramebuffer` | Low-level FBO ops |

**rlgl constants:**

| Constant | Value | Notes |
|----------|-------|-------|
| `rl_lines` | 0x0001 | Line draw mode |
| `rl_triangles` | 0x0004 | Triangle draw mode |
| `rl_quads` | 0x0007 | Quad draw mode |
| `rl_read_framebuffer` | 0x8CA8 | Read FBO target |
| `rl_draw_framebuffer` | 0x8CA9 | Draw FBO target |
| `rl_attachment_color_channel0..3` | 0–3 | Color attachment slots |
| `rl_attachment_depth` | 100 | Depth attachment |
| `rl_attachment_stencil` | 200 | Stencil attachment |
| `rl_attachment_cubemap_positive/negative_x/y/z` | 0–5 | Cubemap face attachments |
| `rl_attachment_texture2d` | 100 | Texture2D attachment type |
| `rl_attachment_renderbuffer` | 200 | Renderbuffer attachment type |

### 1.4 Core: Shader Management

| Status | Function | Notes |
|--------|----------|-------|
| Bound | `LoadShader`, `LoadShaderFromMemory`, `IsShaderValid`, `UnloadShader` | |
| Bound | `GetShaderLocation`, `GetShaderLocationAttrib` | |
| Bound | `SetShaderValue`, `SetShaderValueV`, `SetShaderValueMatrix`, `SetShaderValueTexture` | |

### 1.5 Core: Screen-Space & Camera

| Status | Function | Notes |
|--------|----------|-------|
| Bound | `GetScreenToWorldRay`, `GetScreenToWorldRayEx` | |
| Bound | `GetWorldToScreen`, `GetWorldToScreenEx`, `GetWorldToScreen2D` | |
| Bound | `GetScreenToWorld2D` | |
| Bound | `GetCameraMatrix`, `GetCameraMatrix2D` | |

### 1.6 Core: Timing & Frame Control

| Status | Function | Notes |
|--------|----------|-------|
| Bound | `SetTargetFPS`, `GetFrameTime`, `GetTime`, `GetFPS` | |
| Bound | `SwapScreenBuffer`, `PollInputEvents`, `WaitTime` | |

### 1.7 Core: Misc Utilities

| Status | Function | Notes |
|--------|----------|-------|
| Bound | `SetRandomSeed`, `GetRandomValue`, `LoadRandomSequence`, `UnloadRandomSequence` | |
| Bound | `TakeScreenshot`, `SetConfigFlags`, `OpenURL` | |
| Bound | `TraceLog`, `SetTraceLogLevel` | |
| Bound | `CompressData`, `DecompressData`, `EncodeDataBase64`, `DecodeDataBase64` | |
| Bound | `ComputeCRC32`, `ComputeMD5`, `ComputeSHA1` | |
| N/A | `MemAlloc`, `MemRealloc`, `MemFree` | C memory management — MoonBit uses GC |
| N/A | `SetTraceLogCallback` | Requires C function pointer callback |
| N/A | `SetLoadFileDataCallback`, `SetSaveFileDataCallback` | Requires C function pointer callback |
| N/A | `SetLoadFileTextCallback`, `SetSaveFileTextCallback` | Requires C function pointer callback |

### 1.8 Core: File System

| Status | Function | Notes |
|--------|----------|-------|
| Bound | `LoadFileData`, `SaveFileData`, `ExportDataAsCode` | |
| Bound | `LoadFileText`, `SaveFileText` | |
| Bound | `FileExists`, `DirectoryExists`, `IsFileExtension`, `GetFileLength` | |
| Bound | `GetFileExtension/Name/NameWithoutExt`, `GetDirectoryPath`, `GetPrevDirectoryPath` | |
| Bound | `GetWorkingDirectory`, `GetApplicationDirectory` | |
| Bound | `MakeDirectory`, `ChangeDirectory`, `IsPathFile`, `IsFileNameValid` | |
| Bound | `LoadDirectoryFiles`, `LoadDirectoryFilesEx`, `UnloadDirectoryFiles` | |
| Bound | `IsFileDropped`, `LoadDroppedFiles`, `UnloadDroppedFiles` | |
| Bound | `GetFileModTime` | |
| N/A | `UnloadFileData`, `UnloadFileText` | GC-managed — freed automatically |

### 1.9 Core: Automation Events

| Status | Function | Notes |
|--------|----------|-------|
| Bound | `LoadAutomationEventList`, `UnloadAutomationEventList`, `ExportAutomationEventList` | |
| Bound | `SetAutomationEventList`, `SetAutomationEventBaseFrame` | |
| Bound | `StartAutomationEventRecording`, `StopAutomationEventRecording` | |
| Bound | `PlayAutomationEvent` | |

### 1.10 Core: Input — Keyboard

| Status | Function | Notes |
|--------|----------|-------|
| Bound | `IsKeyPressed`, `IsKeyPressedRepeat`, `IsKeyDown`, `IsKeyReleased`, `IsKeyUp` | |
| Bound | `GetKeyPressed`, `GetCharPressed`, `SetExitKey` | |

### 1.11 Core: Input — Gamepad

| Status | Function | Notes |
|--------|----------|-------|
| Bound | `IsGamepadAvailable`, `GetGamepadName` | |
| Bound | `IsGamepadButtonPressed/Down/Released/Up`, `GetGamepadButtonPressed` | |
| Bound | `GetGamepadAxisCount`, `GetGamepadAxisMovement` | |
| Bound | `SetGamepadMappings`, `SetGamepadVibration` | |

### 1.12 Core: Input — Mouse

| Status | Function | Notes |
|--------|----------|-------|
| Bound | `IsMouseButtonPressed/Down/Released/Up` | |
| Bound | `GetMouseX/Y`, `GetMousePosition`, `GetMouseDelta` | |
| Bound | `SetMousePosition`, `SetMouseOffset`, `SetMouseScale` | |
| Bound | `GetMouseWheelMove`, `GetMouseWheelMoveV`, `SetMouseCursor` | |

### 1.13 Core: Input — Touch & Gestures

| Status | Function | Notes |
|--------|----------|-------|
| Bound | `GetTouchX/Y`, `GetTouchPosition`, `GetTouchPointId`, `GetTouchPointCount` | |
| Bound | `SetGesturesEnabled`, `IsGestureDetected`, `GetGestureDetected` | |
| Bound | `GetGestureHoldDuration`, `GetGestureDragVector/Angle`, `GetGesturePinchVector/Angle` | |

### 1.14 Core: Camera

| Status | Function | Notes |
|--------|----------|-------|
| Bound | `UpdateCamera`, `UpdateCameraPro` | |

### 1.15 Shapes (rshapes)

| Status | Function | Notes |
|--------|----------|-------|
| Bound | `SetShapesTexture`, `GetShapesTexture`, `GetShapesTextureRectangle` | |
| Bound | `DrawPixel/V`, `DrawLine/V/Ex/Strip/Bezier` | |
| Bound | `DrawCircle/V/Sector/SectorLines/Gradient/Lines/LinesV` | |
| Bound | `DrawEllipse/Lines`, `DrawRing/Lines` | |
| Bound | `DrawRectangle/V/Rec/Pro/GradientV/H/Ex/Lines/LinesEx/Rounded/RoundedLines/RoundedLinesEx` | |
| Bound | `DrawTriangle/Lines/Fan/Strip`, `DrawPoly/Lines/LinesEx` | |
| Bound | `DrawSplineLinear/Basis/CatmullRom/BezierQuadratic/BezierCubic` | |
| Bound | `DrawSplineSegmentLinear/Basis/CatmullRom/BezierQuadratic/BezierCubic` | |
| Bound | `GetSplinePointLinear/Basis/CatmullRom/BezierQuad/BezierCubic` | |
| Bound | All `CheckCollision*` functions (Recs, Circles, CircleRec, CircleLine, PointRec, PointCircle, PointTriangle, PointLine, PointPoly, Lines) | |
| Bound | `GetCollisionRec` | |

**Shapes: 100% coverage**

### 1.16 Textures (rtextures)

| Status | Function | Notes |
|--------|----------|-------|
| Bound | `LoadImage/Raw/Anim/AnimFromMemory/FromMemory/FromTexture/FromScreen` | |
| Bound | `IsImageValid`, `UnloadImage`, `ExportImage/ToMemory/AsCode` | |
| Bound | `GenImageColor/GradientLinear/Radial/Square/Checked/WhiteNoise/PerlinNoise/Cellular/Text` | |
| Bound | `ImageCopy`, `ImageFromImage`, `ImageFromChannel` | |
| Bound | `ImageText/TextEx` | |
| Bound | `ImageFormat`, `ImageToPOT`, `ImageCrop`, `ImageAlphaCrop/Clear/Mask/Premultiply` | |
| Bound | `ImageBlurGaussian`, `ImageKernelConvolution` | |
| Bound | `ImageResize/NN/Canvas`, `ImageMipmaps`, `ImageDither` | |
| Bound | `ImageFlipVertical/Horizontal`, `ImageRotate/CW/CCW` | |
| Bound | `ImageColorTint/Invert/Grayscale/Contrast/Brightness/Replace` | |
| Bound | `LoadImageColors`, `LoadImagePalette` | |
| Bound | `GetImageAlphaBorder`, `GetImageColor` | |
| Bound | All `ImageDraw*` functions (Pixel/V, Line/V/Ex, Circle/V/Lines/LinesV, Rectangle/V/Rec/Lines, Triangle/Ex/Lines/Fan/Strip, Draw, Text/TextEx) | |
| Bound | `LoadTexture/FromImage/Cubemap`, `IsTextureValid`, `UnloadTexture` | |
| Bound | `LoadRenderTexture`, `IsRenderTextureValid`, `UnloadRenderTexture` | |
| Bound | `UpdateTexture/Rec`, `GenTextureMipmaps`, `SetTextureFilter/Wrap` | |
| Bound | `DrawTexture/V/Ex/Rec/Pro/NPatch` | |
| Bound | All `Color*` functions (IsEqual, ToInt, Normalize, FromNormalized, ToHSV, FromHSV, Tint, Brightness, Contrast, Alpha, AlphaBlend, Lerp) | |
| Bound | `Fade`, `GetColor`, `GetPixelDataSize` | |
| N/A | `UnloadImageColors`, `UnloadImagePalette` | GC-managed |
| **Missing** | `GetPixelColor`, `SetPixelColor` | Low-level pixel buffer access |

**Additional RenderTexture helpers (MoonBit-side):**

| Function | Notes |
|----------|-------|
| `draw_render_texture_rec/ex/pro` | Draw RenderTexture using its internal texture |
| `set_render_texture_filter` | Set filter on RenderTexture's internal texture |
| `get_render_texture_width/height` | Access RenderTexture dimensions |
| `get_render_texture_texture` | Extract Texture from RenderTexture |
| `get_texture_width/height` | Access Texture dimensions |
| `image_width/height` | Access Image dimensions |
| `image_frame_count` | Get animated image frame count |
| `load_render_texture_depth_tex` | RenderTexture with writable depth texture (for depth-writing shaders) |
| `load_shadowmap_render_texture` | Depth-only FBO for shadow mapping |
| `get_render_texture_fbo_id` | Get raw OpenGL FBO ID |
| `get_render_texture_depth_id` | Get raw depth texture/renderbuffer ID |
| `texture_from_id` | Create non-owning Texture from raw GL texture ID |

**Textures: ~99% coverage** (2 low-level functions missing)

### 1.17 Text (rtext)

| Status | Function | Notes |
|--------|----------|-------|
| Bound | `GetFontDefault`, `LoadFont/Ex/FromImage/FromMemory`, `IsFontValid`, `UnloadFont` | |
| Bound | `GetFontBaseSize` | Returns font base size |
| Bound | `LoadFontData`, `GenImageFontAtlas`, `UnloadFontData` | |
| Bound | `ExportFontAsCode` | |
| Bound | `DrawFPS`, `DrawText/Ex/Pro/Codepoint/Codepoints` | |
| Bound | `SetTextLineSpacing`, `MeasureText/Ex` | |
| Bound | `GetGlyphIndex/Info/AtlasRec` | |
| Bound | `LoadUTF8`, `LoadCodepoints`, `GetCodepointCount/Codepoint/Next/Previous`, `CodepointToUTF8` | |
| N/A | `UnloadUTF8`, `UnloadCodepoints` | GC-managed |
| N/A | `TextCopy/IsEqual/Length/Format/Subtext/Replace/Insert/Join/Split/Append/FindIndex` | Redundant with MoonBit `String` |
| N/A | `TextToUpper/Lower/Pascal/Snake/Camel/Integer/Float` | Redundant with MoonBit `String` |

**Additional Text helpers (MoonBit-side):**

| Function | Notes |
|----------|-------|
| `load_font_ex_codepoints` | Load font with specific codepoint array |
| `build_font_from_data` | Construct Font from LoadFontData + GenImageFontAtlas + LoadTextureFromImage |

**Text: 100% of meaningful API covered** (18 C string utilities skipped by design)

### 1.18 Models (rmodels)

| Status | Function | Notes |
|--------|----------|-------|
| Bound | `DrawLine3D`, `DrawPoint3D`, `DrawCircle3D`, `DrawTriangle3D`, `DrawTriangleStrip3D` | |
| Bound | `DrawCube/V/Wires/WiresV`, `DrawSphere/Ex/Wires` | |
| Bound | `DrawCylinder/Ex/Wires/WiresEx`, `DrawCapsule/Wires` | |
| Bound | `DrawPlane`, `DrawRay`, `DrawGrid`, `DrawBoundingBox` | |
| Bound | `LoadModel/FromMesh`, `IsModelValid`, `UnloadModel`, `GetModelBoundingBox` | |
| Bound | `DrawModel/Ex/Wires/WiresEx/Points/PointsEx` | |
| Bound | `DrawBillboard/Rec/Pro` | |
| Bound | `UploadMesh`, `UpdateMeshBuffer`, `UnloadMesh` | |
| Bound | `DrawMesh/Instanced`, `GetMeshBoundingBox`, `GenMeshTangents` | |
| Bound | `ExportMesh/AsCode` | |
| Bound | `GenMeshPoly/Plane/Cube/Sphere/HemiSphere/Cylinder/Cone/Torus/Knot/Heightmap/Cubicmap` | |
| Bound | `LoadMaterials`, `LoadMaterialDefault`, `IsMaterialValid`, `UnloadMaterial` | |
| Bound | `SetMaterialTexture`, `SetModelMeshMaterial` | |
| Bound | `LoadModelAnimations`, `UpdateModelAnimation/Bones`, `UnloadModelAnimation/s` | |
| Bound | `IsModelAnimationValid` | |
| Bound | `CheckCollisionSpheres/Boxes/BoxSphere` | |
| Bound | `GetRayCollisionSphere/Box/Mesh/Triangle/Quad` | |

**Additional Model/Mesh helpers (MoonBit-side):**

| Function | Notes |
|----------|-------|
| `set_model_transform/get_model_transform` | Access Model transform matrix |
| `get_model_mesh_count/get_model_mesh` | Access Model meshes by index |
| `set_model_material_shader` | Set shader on a model's material |
| `set_model_material_texture` | Set texture on a model's material map |
| `set_material_map_color` | Set color on a material map |
| `set_material_map_value` | Set float value on a material map (metalness, roughness, etc.) |
| `get_model_bone_count/bone_parent` | Access model skeleton hierarchy |
| `get_model_bone_name` | Get bone name by index |
| `get_model_bind_pose_translation/rotation` | Access bind pose transforms |
| `get_model_animation_frame_pose_*` | Access animation frame pose data |
| `gen_mesh_from_points` | Generate mesh from vertex+color point cloud data |
| `mesh_setup_texcoords2` | Upload secondary UV coordinates for lightmapping |

**Models: 100% coverage**

### 1.19 Audio (raudio)

| Status | Function | Notes |
|--------|----------|-------|
| Bound | `InitAudioDevice`, `CloseAudioDevice`, `IsAudioDeviceReady` | |
| Bound | `SetMasterVolume`, `GetMasterVolume` | |
| Bound | `LoadWave/FromMemory`, `IsWaveValid`, `UnloadWave` | |
| Bound | `LoadSound/FromWave/Alias`, `IsSoundValid`, `UpdateSound`, `UnloadSound/Alias` | |
| Bound | `ExportWave/AsCode` | |
| Bound | `PlaySound`, `StopSound`, `PauseSound`, `ResumeSound`, `IsSoundPlaying` | |
| Bound | `SetSoundVolume/Pitch/Pan` | |
| Bound | `WaveCopy/Crop/Format`, `LoadWaveSamples` | |
| Bound | `LoadMusicStream/FromMemory`, `IsMusicValid`, `UnloadMusicStream` | |
| Bound | `PlayMusicStream`, `IsMusicStreamPlaying`, `UpdateMusicStream` | |
| Bound | `StopMusicStream`, `PauseMusicStream`, `ResumeMusicStream` | |
| Bound | `SeekMusicStream`, `SetMusicVolume/Pitch/Pan` | |
| Bound | `GetMusicTimeLength/Played` | |
| Bound | `LoadAudioStream`, `IsAudioStreamValid`, `UnloadAudioStream` | |
| Bound | `UpdateAudioStream`, `IsAudioStreamProcessed` | |
| Bound | `PlayAudioStream`, `PauseAudioStream`, `ResumeAudioStream` | |
| Bound | `IsAudioStreamPlaying`, `StopAudioStream` | |
| Bound | `SetAudioStreamVolume/Pitch/Pan`, `SetAudioStreamBufferSizeDefault` | |
| Bound | `AttachAudioStreamProcessor`, `DetachAudioStreamProcessor` | Via `FuncRef` callback mechanism |
| Bound | `AttachAudioMixedProcessor`, `DetachAudioMixedProcessor` | Via `FuncRef` callback mechanism |
| N/A | `UnloadWaveSamples` | GC-managed |
| N/A | `SetAudioStreamCallback` | Requires C function pointer callback (different from processors) |

**Additional Audio helpers (MoonBit-side):**

| Function | Notes |
|----------|-------|
| `audio_buffer_get_sample/set_sample` | Direct AudioBuffer sample access for processor callbacks |
| `attach/detach_music_stream_processor` | Convenience: attach processor to Music's internal AudioStream |
| `AudioBuffer` type | Opaque type passed to audio processor callbacks |

**Audio: 100% of bindable API covered** (only `SetAudioStreamCallback` remains N/A)

### 1.20 Additional MoonBit-side APIs

These are pure MoonBit implementations not directly wrapping a single raylib function:

| Module | APIs |
|--------|------|
| `vector.mbt` | `Vector2`, `Vector3`, `Vector4` structs + `to_bytes`/`from_bytes` |
| `vector2_math.mbt` | Full Vector2 math (add, subtract, scale, normalize, rotate, lerp, distance, angle, etc.) |
| `vector3_math.mbt` | Full Vector3 math (add, subtract, cross, normalize, transform, etc.) |
| `quaternion_math.mbt` | Full quaternion math (identity, multiply, slerp, from_euler, to_matrix, etc.) |
| `matrix.mbt` | Full 4x4 matrix math (identity, determinant, invert, translate, rotate, perspective, ortho, look_at, decompose, etc.) |
| `rectangle.mbt` | `Rectangle` struct + serialization |
| `camera.mbt` | `Camera2D`, `Camera3D` structs + constants |
| `ray.mbt` | `Ray`, `BoundingBox`, `RayCollision` structs |
| `color.mbt` | `Color` struct + 25 color constants |
| `drawing.mbt` | `VrDeviceInfo` struct + VrStereoConfig field accessors |

---

## 2. Unbound Functions Summary

### 2.1 Cannot bind (require C function pointers) — 6 functions

| Function | Reason |
|----------|--------|
| `SetTraceLogCallback` | Takes `TraceLogCallback` (function pointer) |
| `SetLoadFileDataCallback` | Takes `LoadFileDataCallback` |
| `SetSaveFileDataCallback` | Takes `SaveFileDataCallback` |
| `SetLoadFileTextCallback` | Takes `LoadFileTextCallback` |
| `SetSaveFileTextCallback` | Takes `SaveFileTextCallback` |
| `SetAudioStreamCallback` | Takes `AudioCallback` (different from processors) |

### 2.2 Redundant with MoonBit standard library — 21 functions

| Category | Functions |
|----------|-----------|
| C string utilities | `TextCopy`, `TextIsEqual`, `TextLength`, `TextFormat`, `TextSubtext`, `TextReplace`, `TextInsert`, `TextJoin`, `TextSplit`, `TextAppend`, `TextFindIndex` |
| C string case conversion | `TextToUpper`, `TextToLower`, `TextToPascal`, `TextToSnake`, `TextToCamel` |
| C string parsing | `TextToInteger`, `TextToFloat` |
| C memory management | `MemAlloc`, `MemRealloc`, `MemFree` |

### 2.3 Redundant with GC — 5 functions

| Function | Reason |
|----------|--------|
| `UnloadFileData` | Data returned as MoonBit `Bytes`, GC-managed |
| `UnloadFileText` | Data returned as MoonBit `Bytes`, GC-managed |
| `UnloadImageColors` | Data returned as MoonBit `Bytes`, GC-managed |
| `UnloadImagePalette` | Data returned as MoonBit `Bytes`, GC-managed |
| `UnloadWaveSamples` | Data returned as MoonBit `Bytes`, GC-managed |

### 2.4 Truly missing (could be bound) — 4 functions

| Function | Reason not bound | Priority |
|----------|-----------------|----------|
| `SetWindowIcons` | Takes `Image *` array (multiple opaque pointers) | Low |
| `GetWindowHandle` | Returns `void *` (platform-specific handle) | Low |
| `GetPixelColor` | Low-level raw pixel buffer access | Low |
| `SetPixelColor` | Low-level raw pixel buffer access | Low |

---

## 3. Example Porting Progress

### 3.1 Overview

| Category | Official | Ported | Coverage |
|----------|---------|--------|----------|
| Core | 48 | 32 | 67% |
| Shapes | 39 | 18 | 46% |
| Textures | 30 | 25 | 83% |
| Text | 16 | 12 | 75% |
| Models | 27 | 22 | 81% |
| Shaders | 33 | 27 | 82% |
| Audio | 9 | 7 | 78% |
| Other (custom) | — | 5 | — |
| **Total** | **~202** | **147** | **~73%** |

*Note: 5 extra examples not in official set: `demo`, `easings_testbed`, `minesweeper`,
`raymath_vector_angle`, `core_input_gamepad_info`.*

### 3.2 Ported Examples

#### Core (32/48)

- [x] core_2d_camera
- [x] core_2d_camera_mouse_zoom
- [x] core_2d_camera_platformer
- [x] core_2d_camera_split_screen
- [x] core_3d_camera_first_person
- [x] core_3d_camera_free
- [x] core_3d_camera_mode
- [x] core_3d_camera_split_screen
- [x] core_3d_picking
- [x] core_automation_events
- [x] core_basic_screen_manager
- [x] core_basic_window
- [x] core_custom_frame_control
- [x] core_drop_files
- [x] core_input_gamepad
- [x] core_input_gamepad_info (extra)
- [x] core_input_gestures
- [x] core_input_keys
- [x] core_input_mouse
- [x] core_input_mouse_wheel
- [x] core_input_multitouch
- [x] core_input_virtual_controls
- [x] core_random_sequence
- [x] core_random_values
- [x] core_scissor_test
- [x] core_smooth_pixelperfect
- [x] core_storage_values
- [x] core_vr_simulator
- [x] core_window_flags
- [x] core_window_letterbox
- [x] core_window_should_close
- [x] core_world_screen
- [ ] core_3d_camera_fps
- [ ] core_clipboard_text
- [ ] core_compute_hash
- [ ] core_custom_logging
- [ ] core_delta_time
- [ ] core_directory_files
- [ ] core_highdpi_demo
- [ ] core_highdpi_testbed
- [ ] core_input_actions
- [ ] core_input_gestures_testbed
- [ ] core_keyboard_testbed
- [ ] core_monitor_detector
- [ ] core_render_texture
- [ ] core_screen_recording
- [ ] core_text_file_loading
- [ ] core_undo_redo
- [ ] core_viewport_scaling

#### Shapes (18/39)

- [x] shapes_basic_shapes
- [x] shapes_bouncing_ball
- [x] shapes_collision_area
- [x] shapes_colors_palette
- [x] shapes_draw_circle_sector
- [x] shapes_draw_rectangle_rounded
- [x] shapes_draw_ring
- [x] shapes_easings_ball_anim
- [x] shapes_easings_box_anim
- [x] shapes_easings_rectangle_array
- [x] shapes_following_eyes
- [x] shapes_lines_bezier
- [x] shapes_logo_raylib
- [x] shapes_logo_raylib_anim
- [x] shapes_rectangle_advanced
- [x] shapes_rectangle_scaling
- [x] shapes_splines_drawing
- [x] shapes_top_down_lights
- [ ] shapes_ball_physics
- [ ] shapes_bullet_hell
- [ ] shapes_clock_of_clocks
- [ ] shapes_dashed_line
- [ ] shapes_digital_clock
- [ ] shapes_double_pendulum
- [ ] shapes_hilbert_curve
- [ ] shapes_kaleidoscope
- [ ] shapes_lines_drawing
- [ ] shapes_math_angle_rotation
- [ ] shapes_math_sine_cosine
- [ ] shapes_mouse_trail
- [ ] shapes_penrose_tile
- [ ] shapes_pie_chart
- [ ] shapes_recursive_tree
- [ ] shapes_rlgl_color_wheel
- [ ] shapes_rlgl_triangle
- [ ] shapes_rounded_rectangle_drawing
- [ ] shapes_simple_particles
- [ ] shapes_starfield_effect
- [ ] shapes_triangle_strip
- [ ] shapes_vector_angle

#### Textures (25/30)

- [x] textures_background_scrolling
- [x] textures_blend_modes
- [x] textures_bunnymark
- [x] textures_draw_tiled
- [x] textures_fog_of_war
- [x] textures_gif_player
- [x] textures_image_channel
- [x] textures_image_drawing
- [x] textures_image_generation
- [x] textures_image_kernel
- [x] textures_image_loading
- [x] textures_image_processing
- [x] textures_image_rotate
- [x] textures_image_text
- [x] textures_logo_raylib
- [x] textures_mouse_painting
- [x] textures_npatch_drawing
- [x] textures_particles_blending
- [x] textures_polygon
- [x] textures_raw_data
- [x] textures_sprite_anim (= textures_sprite_animation)
- [x] textures_sprite_button
- [x] textures_sprite_explosion
- [x] textures_srcrec_dstrec
- [x] textures_to_image
- [ ] textures_cellular_automata
- [ ] textures_framebuffer_rendering
- [ ] textures_screen_buffer
- [ ] textures_sprite_stacking
- [ ] textures_textured_curve

#### Text (12/16)

- [x] text_codepoints_loading
- [x] text_draw_3d (= text_3d_drawing)
- [x] text_font_filters
- [x] text_font_loading
- [x] text_font_sdf
- [x] text_font_spritefont
- [x] text_format_text
- [x] text_input_box
- [x] text_raylib_fonts (= text_sprite_fonts)
- [x] text_rectangle_bounds
- [x] text_unicode (= text_unicode_emojis)
- [x] text_writing_anim
- [ ] text_inline_styling
- [ ] text_strings_management
- [ ] text_unicode_ranges
- [ ] text_words_alignment

#### Models (22/27)

- [x] models_animation (= models_animation_playing)
- [x] models_billboard (= models_billboard_rendering)
- [x] models_bone_socket
- [x] models_box_collisions
- [x] models_cubicmap (= models_cubicmap_rendering)
- [x] models_draw_cube_texture (= models_textured_cube)
- [x] models_first_person_maze
- [x] models_geometric_shapes
- [x] models_gpu_skinning (= models_animation_gpu_skinning)
- [x] models_heightmap (= models_heightmap_rendering)
- [x] models_loading
- [x] models_loading_gltf
- [x] models_loading_m3d
- [x] models_loading_vox
- [x] models_mesh_generation
- [x] models_mesh_picking
- [x] models_orthographic_projection
- [x] models_point_rendering
- [x] models_rlgl_solar_system
- [x] models_skybox (= models_skybox_rendering)
- [x] models_waving_cubes
- [x] models_yaw_pitch_roll
- [ ] models_basic_voxel
- [ ] models_decals
- [ ] models_directional_billboard
- [ ] models_rotating_cube
- [ ] models_tesseract_view

#### Shaders (27/33)

- [x] shaders_basic_lighting
- [x] shaders_basic_pbr
- [x] shaders_custom_uniform
- [x] shaders_deferred_render (= shaders_deferred_rendering)
- [x] shaders_eratosthenes (= shaders_eratosthenes_sieve)
- [x] shaders_fog (= shaders_fog_rendering)
- [x] shaders_hot_reloading
- [x] shaders_hybrid_render (= shaders_hybrid_rendering)
- [x] shaders_julia_set
- [x] shaders_lightmap (= shaders_lightmap_rendering)
- [x] shaders_mesh_instancing
- [x] shaders_model_shader
- [x] shaders_multi_sample2d
- [x] shaders_palette_switch
- [x] shaders_postprocessing
- [x] shaders_raymarching (= shaders_raymarching_rendering)
- [x] shaders_shadowmap (= shaders_shadowmap_rendering)
- [x] shaders_shapes_textures
- [x] shaders_simple_mask
- [x] shaders_spotlight (= shaders_spotlight_rendering)
- [x] shaders_texture_drawing (= shaders_texture_rendering)
- [x] shaders_texture_outline
- [x] shaders_texture_tiling
- [x] shaders_texture_waves
- [x] shaders_vertex_displacement
- [x] shaders_write_depth (= shaders_depth_writing)
- [ ] shaders_ascii_rendering
- [ ] shaders_color_correction
- [ ] shaders_depth_rendering
- [ ] shaders_game_of_life
- [ ] shaders_mandelbrot_set
- [ ] shaders_normalmap_rendering
- [ ] shaders_rounded_rectangle

#### Audio (7/9)

- [x] audio_mixed_processor
- [x] audio_module_playing
- [x] audio_music_stream
- [x] audio_raw_stream
- [x] audio_sound_loading
- [x] audio_sound_multi
- [x] audio_stream_effects
- [ ] audio_sound_positioning
- [ ] audio_spectrum_visualizer

#### Other / Custom (5)

- [x] demo
- [x] easings_testbed
- [x] minesweeper
- [x] raymath_vector_angle
- [x] core_input_gamepad_info

### 3.3 Examples Not Portable

| Example | Reason |
|---------|--------|
| `core_custom_logging` | Requires `SetTraceLogCallback` (C function pointer) |
| `core_loading_thread` | Requires pthreads / C threading |

Most unported examples are **not blocked by missing API** — they simply haven't been
ported yet. Many are newer raylib examples without vendored C source in this repository.

---

## 4. Struct & Type Coverage

### 4.1 Value Types (serialized via Bytes)

| Type | Status | Fields |
|------|--------|--------|
| `Color` | Complete | r, g, b, a (4 bytes) |
| `Vector2` | Complete | x, y (8 bytes) |
| `Vector3` | Complete | x, y, z (12 bytes) |
| `Vector4` | Complete | x, y, z, w (16 bytes) |
| `Rectangle` | Complete | x, y, width, height (16 bytes) |
| `Matrix` | Complete | 4x4 float (64 bytes) |
| `Camera2D` | Complete | offset, target, rotation, zoom |
| `Camera3D` | Complete | position, target, up, fovy, projection |
| `Ray` | Complete | position, direction |
| `BoundingBox` | Complete | min, max |
| `RayCollision` | Complete | hit, distance, point, normal |
| `AutomationEvent` | Complete | frame, type, params |
| `VrDeviceInfo` | Complete | hResolution, vResolution, etc. |
| `GlyphInfo` | Complete | value, offsetX/Y, advanceX, image |
| `NPatchInfo` | Complete | source, left, top, right, bottom, layout |

### 4.2 Opaque Resource Types (GC-managed via external objects)

| Type | Status | Load | Unload | Valid |
|------|--------|------|--------|-------|
| `Image` | Complete | Multiple loaders | Auto (GC) | `IsImageValid` |
| `Texture` | Complete | `LoadTexture/FromImage` | Auto (GC) | `IsTextureValid` |
| `RenderTexture` | Complete | `LoadRenderTexture` | Auto (GC) | `IsRenderTextureValid` |
| `Font` | Complete | Multiple loaders | Auto (GC) | `IsFontValid` |
| `Sound` | Complete | `LoadSound/FromWave/Alias` | Auto (GC) | `IsSoundValid` |
| `Wave` | Complete | `LoadWave/FromMemory` | Auto (GC) | `IsWaveValid` |
| `Music` | Complete | `LoadMusicStream/FromMemory` | Auto (GC) | `IsMusicValid` |
| `Model` | Complete | `LoadModel/FromMesh` | Auto (GC) | `IsModelValid` |
| `Shader` | Complete | `LoadShader/FromMemory` | Auto (GC) | `IsShaderValid` |
| `Mesh` | Complete | `GenMesh*` | `UnloadMesh` | — |
| `Material` | Complete | `LoadMaterial*` | `UnloadMaterial` | `IsMaterialValid` |
| `AudioStream` | Complete | `LoadAudioStream` | Auto (GC) | `IsAudioStreamValid` |
| `AudioBuffer` | Complete | Passed to processor callbacks | — | — |
| `AutomationEventList` | Complete | `LoadAutomationEventList` | Auto (GC) | — |
| `FilePathList` | Complete | `LoadDirectoryFiles` | `UnloadDirectoryFiles` | — |
| `VrStereoConfig` | Complete | `LoadVrStereoConfig` | `UnloadVrStereoConfig` | — |
| `GlyphInfoArray` | Complete | `LoadFontData` | `UnloadFontData` | — |
| `MaterialsArray` | Complete | `LoadMaterials` | `UnloadMaterialsArray` | — |
| `ModelAnimations` | Complete | `LoadModelAnimations` | `UnloadModelAnimations` | — |

---

## 5. Enum / Constant Coverage

| Category | Status | Location |
|----------|--------|----------|
| Color constants (25) | Complete | `color.mbt` |
| Key codes (`KEY_*`) | Complete | `input.mbt` |
| Mouse buttons (`MOUSE_BUTTON_*`) | Complete | `input.mbt` |
| Mouse cursor styles | Complete | `input.mbt` |
| Gamepad buttons/axes | Complete | `input.mbt` |
| Gesture types | Complete | `input.mbt` |
| ConfigFlags | Complete | `window.mbt` |
| TraceLogLevel | Complete | `window.mbt` |
| BlendMode | Complete | `drawing.mbt` |
| Camera mode/projection | Complete | `camera.mbt` |
| Pixel formats (10 uncompressed) | Complete | `textures.mbt` |
| Texture filter modes | Complete | `textures.mbt` |
| Texture wrap modes | Complete | `textures.mbt` |
| Cubemap layout modes | Complete | `textures.mbt` |
| Material map types (11) | Complete | `models.mbt` |
| Shader uniform types | Complete | `drawing.mbt` |
| Font data types | Complete | `text.mbt` |
| rlgl draw modes | Complete | `drawing.mbt` |
| rlgl framebuffer attachment types | Complete | `drawing.mbt` |
| Shader location indices | — | Not yet exposed as named constants (use raw int) |

---

## 6. Recommendations

### Medium Priority
1. **Port remaining examples** — ~55 unported examples remain. Most are newer raylib
   examples without vendored C source in this repository. The vendored examples are
   now fully ported (except 2 blocked by C function pointer requirements).
2. **Expose shader location constants** — Shader location indices are currently raw integers.
   Named constants would improve usability.

### Low Priority
3. **Bind `GetPixelColor`/`SetPixelColor`** — Needed only for raw pixel buffer manipulation.
4. **Bind `SetWindowIcons`** — Requires array-of-opaque-pointer support.
