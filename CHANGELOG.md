# PrusaSlicer Fork Changelog

Fork of [prusa3d/PrusaSlicer](https://github.com/prusa3d/PrusaSlicer) maintained by Colin Trachte.
Base version: **2.9.6-rc1**

---

## Inprocessing Pass — 2026-06-23

### Bug Fixes

- **Fix download path not persisting after restart** (resolves upstream #14449)
  Decoupled download path persistence from URL registration. The configured download path
  is now always saved when valid, even if the "register URL handler" checkbox is unchecked.
  `src/slic3r/GUI/ConfigWizard.cpp`, `.hpp`

- **Fix Prusa-Link HTTP 415 error from API keys with whitespace** (upstream PR #15448)
  API keys are now trimmed of leading/trailing whitespace when used in HTTP requests
  (`OctoPrint` constructor) and also when typed in the Physical Printer dialog.
  `src/slic3r/Utils/OctoPrint.cpp`, `src/slic3r/GUI/PhysicalPrinterDialog.cpp`

- **Fix test build with Catch2 v3** (upstream PR #15462)
  Added missing `catch2/interfaces/catch_interfaces_capture.hpp` include required by
  Catch2 v3 to compile `sla_test_utils.cpp`.
  `tests/sla_print/sla_test_utils.cpp`

### Correctness / Naming Fixes

- **Rename `on_login_code_recieved` → `on_login_code_received`** (typo fix)
  Corrected misspelling in the login callback method name across 6 files:
  `UserAccount.hpp/.cpp`, `UserAccountCommunication.hpp/.cpp`, `GUI_App.cpp`, `Plater.cpp`

- **Rename `prorgess_fn` → `progress_fn`** across all print host implementations
  Corrected the parameter name in the `upload()` virtual method and all 16 implementing
  files: `OctoPrint`, `PrusaLink`, `Moonraker`, `Duet`, `FlashAir`, `Repetier`, `MKS`,
  `AstroBox`, `PrintHost`. Purely cosmetic/IDE-aid fix; no behavior change.

### Documentation Fixes

- Fixed typo "Prerequisities" → "Prerequisites" in Windows and Linux build docs
- Fixed typo "respository" → "repository" in Windows build doc
- Fixed broken markdown link `[Troubleshooting](#troubleshooting)](#troubleshooting)` in macOS build doc
- Fixed grammar "you will need couple of other tools" → "you will need a couple of other tools" in macOS build doc
- Fixed grammar "excellent on article on" → "excellent article on" in CONTRIBUTING.md

### Observability / Logging Improvements

- **App startup**: Log PrusaSlicer version and data directory at startup (`GUI_App::on_init_inner`)
- **App shutdown**: Log "PrusaSlicer shutdown" on exit (`GUI_App::~GUI_App`)
- **Config load**: Log path at start and success at end of `AppConfig::load()`
- **Config save**: Log path on successful save in `AppConfig::save()`
- **Slicing pipeline**: Log "Background slicing started/finished/cancelled/failed" in `BackgroundSlicingProcess::thread_proc()`
- **Print host upload**: Log destination host and filename at start of `PrintHostJobQueue::perform_job()`

### Spelling / Comment Quality (38 source files)

Corrected recurring misspellings in source comments (no behavior change):
- `occured` → `occurred` (8 files)
- `neccessar(y/ily)` → `necessar(y/ily)` (22 files)
- `unneccessar(y)` → `unnecessar(y)` (4 files)
- `succesful(ly)` → `successful(ly)` (7 files)
- `recieved` → `received` (3 files, beyond the method rename)
- `seperat(ed/ely)` → `separat(ed/ely)` (4 files)
- `accomodat(e)` → `accommodat(e)` (2 files)
- `recomend(ed)` → `recommend(ed)` (2 files)
- `istalled` → `installed` (1 file)
- `procced` → `proceed` (1 file)
- `Prerequisities` → `Prerequisites` (1 file — `src/libslic3r/Emboss.cpp`)

Also fixed typos in `deps/CMakeLists.txt`:
- `unfortunatelly` → `unfortunately`
- `succesfully` → `successfully`

### Platform Scripts (New Files)

- **`setup.ps1`** — Windows PowerShell build script: checks prerequisites (CMake, git, Visual Studio), wraps `build_win.bat` with clear error messages and help text.
- **`run.ps1`** — Windows PowerShell launcher: finds and runs the built `prusa-slicer.exe`, `prusa-slicer-console.exe`, or `prusa-gcodeviewer.exe`.
- **`setup.sh`** — Linux/macOS build script: checks prerequisites, builds deps, configures and compiles PrusaSlicer with Ninja or Make.
- **`run.sh`** — Linux/macOS launcher: finds and runs the built binary.

---

## Bug Fixes & Feature Merges — 2026-06-23 (Session 2)

### Arachne / Wall Generation Fixes (closed upstream PRs #14006, #14007, #14008)

- **Fix always-false condition in `SkeletalTrapezoidation`** (upstream PR #14006)
  `edge.to->isLocalMaximum() && !edge.to->isLocalMaximum()` was logically impossible.
  Fixed to `!edge.from->isLocalMaximum() && !edge.to->isLocalMaximum()`.
  `src/libslic3r/Arachne/SkeletalTrapezoidation.cpp`

- **Prevent generation of micro single-beads** (upstream PR #14007)
  Added a guard in `generateLocalMaximaSingleBeads()` to skip beads narrower than 5µm,
  preventing micro-extrusions that caused surface defects.
  `src/libslic3r/Arachne/SkeletalTrapezoidation.cpp`

- **Fix twin-edge upward ordering** (upstream PR #14008)
  Replaced verbose 4-branch `isUpward()` logic with correct C++17 `std::optional` comparison
  that guarantees twin edges evaluate oppositely, preventing edge-ordering inconsistencies.
  `src/libslic3r/Arachne/SkeletalTrapezoidationGraph.cpp`

### Bug Fixes

- **Fix search box keyboard input on Windows Surface** (upstream issue #14131)
  Removed spurious `TriggerSearch()` call from `wxEVT_LEFT_DOWN` handler which was causing
  focus state changes that blocked keyboard input on Surface/touch devices.
  `src/slic3r/GUI/TopBar.cpp`

- **Fix extra-length-on-restart ignored after wipe** (upstream issue #11178)
  `Extruder::retract()` only set `m_restart_extra` when `to_retract > 0`. When a wipe path
  has already performed the full retraction via `extrude()` calls, the subsequent `retract()`
  found nothing left to retract and `m_restart_extra` stayed 0, so `unretract()` added no
  restart extra. Fix: unconditionally update `m_restart_extra`.
  `src/libslic3r/Extruder.cpp`

- **Expand shrinkage compensation range to ±50%** (upstream issue #14644)
  Previous ±10% range was insufficient for engineering filaments (e.g., BASF Ultrafuse
  Metal 316L requires ~20% XY and ~26% Z compensation). Range expanded to ±50% for both
  `filament_shrinkage_compensation_xy` and `filament_shrinkage_compensation_z`.
  `src/libslic3r/PrintConfig.cpp`

- **Fix Prusa Link credentials not persisting** (upstream issue #12843)
  Corrected copy-paste bug where both conditions checked `printhost_password` instead of
  `printhost_user`. On keychain load failure, only the password placeholder is cleared;
  the username (stored as plaintext in config) is preserved.
  `src/slic3r/GUI/PhysicalPrinterDialog.cpp`

### Features / Merged PRs

- **Color changes rendered in G-code thumbnails** (upstream PR #15446)
  Thumbnails now display the model's color-change layers using z-range segmented rendering
  with the mm_gouraud shader. Color changes are propagated through `ThumbnailsParams`,
  `BackgroundSlicingProcess::render_thumbnails()`, `Plater::generate_thumbnails()`,
  and applied in `GLCanvas3D::_render_thumbnail_internal()`.
  Files: `ThumbnailData.hpp`, `BackgroundSlicingProcess.cpp`, `Plater.cpp`,
  `GLCanvas3D.cpp`, `GLModel.cpp`

- **OS notification when slicing completes** (upstream issue #11970)
  When G-code generation finishes and the PrusaSlicer window is not in focus, the OS
  now shows a system notification ("G-code generation finished.") via `wxNotificationMessage`.
  `src/slic3r/GUI/Plater.cpp`

- **Organic supports work with variable layer height** (upstream PR #15474)
  Removed the validation gate in `Print::validate()` that blocked variable layer height
  with organic supports. Refactored `layer_z()`, `layer_idx_ceil()`, `layer_idx_floor()`
  from standalone free functions to methods on `TreeSupportSettings` that use actual
  per-layer Z values from the `PrintObject` when available, enabling correct branch
  positioning with non-uniform layer heights.
  Files: `Print.cpp`, `Slicing.hpp`, `Slicing.cpp`, `TreeSupportCommon.hpp`,
  `TreeSupportCommon.cpp`, `OrganicSupport.cpp`, `TreeModelVolumes.cpp`

---

## Security Dependency Upgrades — 2026-06-24

### Dependencies Updated

- **libpng 1.6.35 → 1.6.58** (`deps/+PNG/PNG.cmake`, `deps/+PNG/CMakeLists.txt.patched`)
  Updated download URL and SHA256 hash. Updated `PNGLIB_RELEASE` version constant in the
  patched CMakeLists. The 1.6.x API is fully backward-compatible.
  **macOS caveat:** `deps/+PNG/PNG.patch` targets specific line numbers in 1.6.35 sources
  and will need revision before a macOS deps rebuild.

- **CURL 7.75.0 → 8.21.0** (`deps/+CURL/CURL.cmake`)
  Updated download URL (tag `curl-8_21_0`) and SHA256 hash. All existing cmake flags
  (`HTTP_ONLY`, `USE_OPENSSL`, `CMAKE_USE_SCHANNEL`, etc.) remain unchanged and are
  compatible with CURL 8.x.

- **OpenSSL 1.1.0l → 3.4.6 LTS** (`deps/+OpenSSL/OpenSSL.cmake`)
  Updated download URL to the official OpenSSL release asset and SHA256 from the published
  `.sha256` file. Removed `no-ssl3-method` configure flag (SSLv3 is already disabled by
  default in OpenSSL 3.x). Linux-only dependency. PrusaSlicer's OpenSSL usage
  (`UserAccountCommunication.cpp`, `Http.cpp`) already uses the 1.1.0+ `EVP_MD_CTX_new`/
  `EVP_MD_CTX_free` API — no source code changes required.

---

## Remaining Work (see TODO.md)

### Critical — Security
- Deps upgraded (libpng 1.6.58, CURL 8.21.0, OpenSSL 3.4.6). Full deps rebuild + retest required.
- `deps/+PNG/PNG.patch` (macOS only) needs revision for libpng 1.6.58 before macOS deps build.

### Critical — Crashes
- Investigate crash slicing specific files (#14622)
- Investigate Arachne crash with 0.20mm layers (#14421) — Arachne PRs now applied, may be resolved
- Investigate sequential-print arrange crash (#14624, #14442, #14447, #14535)

### High — Bugs
- Fix scarf seam Z-height on support layers (#14647)
- Fix blob in vase mode above layer 4 (#14472)
- Fix wipe-while-retracting on MK3S+ (#14475)

### Medium — Features / PRs to Merge
- PR #15451: Local import server for browser-based CAD packages (requires security review)
- PR #15229: Advanced fuzzy skin features from OrcaSlicer (evaluate)
