# Changelog

All notable changes to this project are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Releases are tagged `vX.Y.Z` on master; unreleased work accumulates under `[Unreleased]` and is converted to a dated version block at release. This repository is an ekoDB-maintained fork of [jean-pierreBoth/anndists](https://github.com/jean-pierreBoth/anndists), forked at version 0.1.4.

## [Unreleased]

### Fixed

- **Out-of-bounds panic in the SIMD L1/L2 residual loops** (#3). `distance_l1_f32_simdeez` and `distance_l2_f32_simdeez` iterated their post-vectorization residual loops over `0..va.len()` instead of `0..a.len()`, indexing past the already-consumed remainder slice; any input at least one SIMD width long panicked on x86 with the `simdeez_f` feature. Matches the upstream fix (jean-pierreBoth/anndists@b23a61d). A regression test sweeps input lengths 1..=40 against scalar reference results.

### Added

- **GitHub Actions CI** (#2). rustfmt check, clippy `-D warnings`, and `cargo test --locked` for both default features and `--features simdeez_f`, pinned to Rust 1.95.0 on x86_64. The nightly-only `stdsimd` feature is out of scope.
- **Pull request template** with a reviewer checklist.

### Changed

- **`Cargo.lock` is now tracked** (required for reproducible `--locked` CI; consumers are unaffected since this crate is consumed as a pinned git dependency) and refreshed to the latest compatible versions.
- **Lint cleanups** (behavior-preserving): needless borrows removed from the simdeez `load_from_slice` calls, the `disteez` import and SIMD test module gated by target arch (their call sites are x86-only), identical avx2/sse2 branches in `DistDot` collapsed (the generated function dispatches on the detected instruction set internally), and test-only fixes (useless `into_iter` on ranges, manual slice copy, unneeded `return`, unnecessary casts).
