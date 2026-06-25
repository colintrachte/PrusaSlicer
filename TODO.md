# PrusaSlicer Fork — Prioritized TODO

Generated from analysis of parent repo (prusa3d/PrusaSlicer) open issues,
open PRs, and closed-without-merge PRs. Current fork version: 2.9.6-rc1.

---

## Critical — Security Vulnerabilities (Dependencies)

These exist identically in the upstream prusa3d/PrusaSlicer repo and must be coordinated carefully.
All are in `deps/` — each upgrade requires: (1) new URL, (2) verified SHA256 hash, (3) full deps rebuild, (4) retest.

- [x] **Upgrade OpenSSL `1.1.0l` → `3.4.6` LTS** (`deps/+OpenSSL/OpenSSL.cmake`) — Updated URL and SHA256; removed `no-ssl3-method` (deprecated in 3.x). Linux-only dep; PrusaSlicer's EVP usage already uses 1.1.0+ API so no source changes needed.
- [x] **Upgrade CURL `7.75.0` → `8.21.0`** (`deps/+CURL/CURL.cmake`) — Updated URL and SHA256. API-compatible upgrade; existing cmake flags unchanged.
- [x] **Upgrade libpng `1.6.35` → `1.6.58`** (`deps/+PNG/PNG.cmake`) — Updated URL and SHA256; updated PNGLIB_RELEASE in CMakeLists.txt.patched. **Note:** `PNG.patch` (macOS only) targets line numbers in 1.6.35 source — will need revision before a macOS deps build.

---

## Critical — Crashes / Data Loss

- [x] **Merge PR #15462** — Fix build with Catch2 v3 (include `catch_interfaces_capture.hpp`). Applied.
- [ ] **Investigate crash #14622** — "Slicing Specific File Hard Crashes PrusaSlicer". Requires repro file from reporter; triage stack trace when available.
- [ ] **Investigate Arachne crash #14421** — Crash when slicing with 0.20mm layer height. Possibly related to closed-without-merge PRs #14006/14007/14008 (Arachne central-node and zero-width-bead fixes). Review those PRs.
- [ ] **Investigate sequential-print arrange crash #14624** — Arrange tool failure when using "Complete Individual Objects". Three related sequential-print bugs: #14442 (freezes slicing), #14447 (collision with fan shroud), #14535 (error messages not shown).

---

## High — Major Bugs / Broken Functionality

- [x] **Merge PR #15442** — Fix #14449: persist download path regardless of URL registration state. Applied.
- [x] **Merge PR #15448** — Trim whitespace from printhost API keys to avoid Prusa-Link HTTP 415 error. Applied.
- [x] **Fix search box typing (#14131)** — Removed spurious `TriggerSearch()` from `wxEVT_LEFT_DOWN` in `TopBar.cpp`.
- [ ] **Merge PR #11441** — Fix Z-lift regression: when Z is lifted, never move lower until unlift. `GCode/GCodeWriter.cpp` — single file. Impact 3 (potential nozzle crash / layer damage). Cherry-pick.
- [ ] **Merge PR #9737** — Fix MMU purge temperature ordering: purge should happen at the higher temp to prevent under-extrusion. `GCode/WipeTower.cpp/.hpp` — Impact 3 (invalid G-code / print failure). Cherry-pick. Relevant for future INDX.
- [ ] **Merge PR #15142** — Fix zero-length segment assertion crashes in Arachne/EdgeGrid. Covers open bugs #14421, #14622 (crash slicing specific files). `EdgeGrid.hpp`, `GCode/CoolingBuffer.cpp`, `Polyline.cpp`, `GUI/DoubleSliderForLayers.cpp` — Impact 3. Cherry-pick.
- [ ] **Fix search box typing v2 (#15148)** — Second code path causing can't-type-in-search-box on Windows (different from #14131). `GUI/TopBar.cpp` — single file. Cherry-pick.
- [ ] **Fix scarf seam Z-height on support layers (#14647)** — Scarf seam start Z-height wrong on layers with support. Affects print quality.
- [ ] **Fix blob in vase mode (#14472)** — Blob appears above 4th layer in Vase Mode (26 comments, wide impact). Investigate wipe/retract path in vase mode spiral generation.
- [ ] **Fix wipe-while-retracting on MK3S+ (#14475)** — Significant problems with wipe-while-retracting. Likely in GCode retraction path.
- [x] **Fix Prusa Link credential persistence (#12843)** — Fixed copy-paste bug and logic error in `PhysicalPrinterDialog.cpp`.
- [x] **Fix extra-length-on-restart not working (#11178)** — Fixed `m_restart_extra` always set in `Extruder::retract()` regardless of `to_retract`. `src/libslic3r/Extruder.cpp`
- [x] **Review Arachne closed PRs (#14006, #14007, #14008)** — Applied all three: logical condition fix, micro-bead guard, twin-edge ordering fix.

---

## Medium — Quality of Life / Feature Improvements

- [x] **Merge PR #15474** — Organic supports with variable layer height. Applied: removed validation gate, refactored `layer_z()` family to `TreeSupportSettings` methods.
- [x] **Merge PR #15446** — Render color changes in G-code thumbnails. Applied: 5-file change propagating color changes through thumbnail pipeline.
- [ ] **Merge PR #10263** — Fix layer-2 temperature transition ordering: temperature command should fall between layer-change custom G-codes, not before them. `GCode.cpp` — single file. Cherry-pick.
- [ ] **Merge PR #10122** — Fix Max Volumetric Speed calculation ignoring Extrusion Multiplier. Speed underestimated when EM > 1.0. `GCode.cpp` — single file. Cherry-pick.
- [ ] **Merge PR #14864** — Add cooling wait option before filament unload on color/tool change. `GCode/WipeTower.cpp/.hpp`, `PrintConfig.cpp/.hpp`, `Tab.cpp` — Impact 2. Cherry-pick.
- [ ] **Merge PR #15026** — Add organic support base layer option. Improves support adhesion and separation. `Support/OrganicSupport.cpp`, `TreeSupportCommon.cpp/.hpp`, `PrintConfig.cpp/.hpp`, others — includes tests. Cherry-pick.
- [ ] **Merge PR #8167** — Ask OctoPrint to auto-select newly uploaded file. Removes manual step for headless setups. `slic3r/Utils/OctoPrint.cpp` — single file. Cherry-pick.
- [ ] **Merge PR #15451** — Local import server for browser-based CAD packages (Onshape etc.). Open PR, no conflicts. Needs security review of local HTTP endpoint before merge.
- [ ] **SKIP PR #15229** — Advanced fuzzy skin from OrcaSlicer: adds unmaintained `libnoise` dependency (no commits since ~2010) + competitor port without full license audit. Hard skip per policy.
- [ ] **Sequential print GCode viewer collision review (#14681)** — When collision is detected, make it easy to identify the problem in GCode viewer. Enhancement on top of existing sequential-print bug cluster.
- [ ] **Fix search settings behavior (#14576)** — Strange behavior in settings search. Related to #14131 (can't type). May share root cause.
- [ ] **Add seam visibility toggle in preview (#12981)** — Allow toggling seam visibility in 3D preview (9 comments, popular request).
- [ ] **Sequential arrangement consider supports (#14262)** — Sequential printing arrangement does not account for support material extent when checking collisions.
- [ ] **Evaluate macOS deps build doc PR (#14691)** — Closed without merge. Adds troubleshooting steps for macOS dependency build. Low risk to cherry-pick.
- [x] **Increase shrinkage compensation range (#14644)** — Expanded ±10% → ±50% in `PrintConfig.cpp`.
- [ ] **Wipe tower usability with small Z heights (#14529)** — Improvement ideas have been proposed; review and implement viable options.

---

## Low — Cosmetic / Minor Enhancements

- [ ] **Brighter preview colors (#2164)** — 30 comments, long-standing volunteer request. Improve color contrast/brightness in 3D preview rendering.
- [ ] **MKS preview encoding (#6859)** — Add MKS-preview thumbnail encoding for G-code (8 comments, volunteer needed).
- [ ] **Wayland/XWayland support on Linux (#8284)** — PrusaSlicer uses XWayland and ignores GDK_BACKEND. 22 comments, volunteer needed.
- [x] **Notification on G-code generation completion (#11970)** — Added `wxNotificationMessage` in `Plater::on_process_completed()` when window is inactive.
- [ ] **Seam preview default on (#12981)** — Show seams in preview by default or allow toggle (also listed under Medium).
- [ ] **Spelling/grammar in docs and source comments** — Phase 3 baseline pass (see Phase 3 below).

---

## Phase 3 Baseline — Safe Fixes (Non-Blocking)

- [x] Fix typo "Prerequisities" → "Prerequisites" in Windows and Linux build docs
- [x] Fix typo "respository" → "repository" in Windows build doc
- [x] Fix broken markdown link in macOS build doc
- [x] Fix grammar in CONTRIBUTING.md
- [x] Fix 75+ spelling errors across 38 source files and deps/

---

## Notes

- **Parent repo**: https://github.com/prusa3d/PrusaSlicer
- **Our fork**: https://github.com/colintrachte/PrusaSlicer
- **Do NOT touch**: `bundled_deps/`, `deps/`, `sandboxes/`, `resources/localization/` (managed by translation team), generated binary assets
- **Build**: CMake + MSVC 2019/2022 (Windows); also Linux/macOS via Ninja/Make
- **Test framework**: Catch2 (tests in `tests/`)
- **CI**: GitHub Actions (`.github/workflows/`; references Prusa-Development private actions org)
