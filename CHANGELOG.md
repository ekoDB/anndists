# Changelog

All notable changes to this project are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Releases are tagged `vX.Y.Z` on master; unreleased work accumulates under `[Unreleased]` and is converted to a dated version block at release. This repository is an ekoDB-maintained fork of [jean-pierreBoth/anndists](https://github.com/jean-pierreBoth/anndists), forked at version 0.1.4.

## [Unreleased]

### Changed

- **`rust-toolchain.toml` comment no longer names internal repositories.** The comment explaining the pin referred to two internal ekoDB repositories by name in a file that is readable by anyone; it now refers to the other ekoDB Rust repos generically. Comment text only: the pinned toolchain (1.95.0), the `rustfmt` and `clippy` components, and the `minimal` profile are all unchanged.

## [0.2.0] - 2026-07-02

First versioned release of the ekoDB fork. Upstream had already published 0.1.5 with different content, so the fork jumps to a fresh minor to avoid same-number confusion.

### Fixed

- **Out-of-bounds panic in the SIMD L1/L2 residual loops** (#3). `distance_l1_f32_simdeez` and `distance_l2_f32_simdeez` iterated their post-vectorization residual loops over `0..va.len()` instead of `0..a.len()`, indexing past the already-consumed remainder slice; any input at least one SIMD width long panicked on x86 with the `simdeez_f` feature. Matches the upstream fix (jean-pierreBoth/anndists@b23a61d). A regression test sweeps input lengths 1..=40 against scalar reference results.

### Added

- **GitHub Actions CI** (#2). rustfmt check, clippy `-D warnings`, and `cargo test --locked` for both default features and `--features simdeez_f`, pinned to Rust 1.95.0 on x86_64. The nightly-only `stdsimd` feature is out of scope.
- **Pull request template** with a reviewer checklist.
- **Makefile** with the standard targets used across ekoDB Rust repos (`setup`, `build`, `test`, `fmt`, `lint`, `deps-check`, `deps-update`, `audit`, `set-version`); `make lint` and `make test` run exactly what CI runs, and `make test-x86` runs the x86-gated SIMD tests under Rosetta on Apple Silicon.
- **Fork documentation in README**: what the crate is used for, why the fork exists, the relationship to upstream, and the development workflow, plus a CI badge.
- **Pre-commit git hook** (`scripts/pre-commit`, installed via `make install-hooks`) running the CI-matching lint and tests before every commit.

### Changed

- **Fork metadata in Cargo.toml**: version 0.2.0, `repository` now points at the fork, ekoDB added to authors, description marks the crate as the ekoDB-maintained fork.
- **`Cargo.lock` is now tracked** (required for reproducible `--locked` CI; consumers are unaffected since this crate is consumed as a pinned git dependency) and refreshed to the latest compatible versions.
- **Lint cleanups** (behavior-preserving): needless borrows removed from the simdeez `load_from_slice` calls, the `disteez` import and SIMD test module gated by target arch (their call sites are x86-only), identical avx2/sse2 branches in `DistDot` collapsed (the generated function dispatches on the detected instruction set internally), and test-only fixes (useless `into_iter` on ranges, manual slice copy, unneeded `return`, unnecessary casts).
