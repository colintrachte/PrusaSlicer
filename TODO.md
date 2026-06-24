# PrusaSlicer Fork — Prioritized TODO

Generated from analysis of parent repo (prusa3d/PrusaSlicer) open issues,
open PRs, and closed-without-merge PRs. Current fork version: 2.9.6-rc1.

---

## Critical — Security Vulnerabilities (Dependencies)

These exist identically in the upstream prusa3d/PrusaSlicer repo and must be coordinated carefully.
All are in `deps/` — each upgrade requires: (1) new URL, (2) verified SHA256 hash, (3) full deps rebuild, (4) retest.

- [ ] **Upgrade OpenSSL `1.1.0l` → `3.4.x` LTS** (`deps/+OpenSSL/OpenSSL.cmake`) — OpenSSL 1.1.0 reached EOL 2019-09-11. The 1.1.0 branch has had no security patches for years. Migrating to OpenSSL 3.x requires updating CURL to ≥7.80.0 first (OpenSSL 3 support added there). OpenSSL 3 API has breaking changes — grep for `EVP_MD_CTX_cleanup`, `RSA_*`, `DSA_*` usage and update to non-deprecated replacements. Target: OpenSSL 3.4.x LTS (EOL 2030-09).
- [ ] **Upgrade CURL `7.75.0` → `8.x`** (`deps/+CURL/CURL.cmake`) — CURL 7.75.0 is from February 2021 and has numerous CVEs patched in later releases. CURL 8.x is the current stable branch. This upgrade enables OpenSSL 3.x support. Verify API compatibility by checking `CURLOPT_*` usage in `src/slic3r/Utils/Http.cpp`.
- [ ] **Upgrade libpng `1.6.35` → `1.6.43+`** (`deps/+PNG/PNG.cmake`) — libpng 1.6.35 from 2018 has several CVE fixes in later 1.6.x releases. API is backward-compatible; only URL and SHA256 hash need updating in the cmake file.

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
- [ ] **Merge PR #15451** — Local import server for browser-based CAD packages (Onshape etc.). Open PR, no conflicts. Needs security review of local HTTP endpoint before merge.
- [ ] **Evaluate PR #15229** — Advanced fuzzy skin (Perlin/Billow/Voronoi noise) ported from OrcaSlicer. Closed without merge. Review for quality and conflicts.
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
