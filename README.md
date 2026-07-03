# anndists

[![Rust](https://github.com/ekoDB/anndists/actions/workflows/rust.yml/badge.svg)](https://github.com/ekoDB/anndists/actions/workflows/rust.yml)

## About this fork

This is the [ekoDB](https://ekodb.io)-maintained fork of [jean-pierreBoth/anndists](https://github.com/jean-pierreBoth/anndists). The crate provides the distance kernels (L1, L2, Cosine, Dot, Hamming, and others, with SIMD implementations for the hot paths) consumed by the [ekoDB fork of hnsw_rs](https://github.com/ekoDB/hnswlib-rs), which together power vector search in the ekoDB database.

**Why a fork.** These distance functions sit on the hottest path of a database, so we need direct control over the exact code in the stack: the ability to pin and audit every revision and land fixes on our own schedule. The fork carries an out-of-bounds fix in the SIMD L1/L2 residual loops (with a regression test) and runs every change through CI (rustfmt, clippy `-D warnings`, tests for both default and `simdeez_f` feature sets).

**Relationship to upstream.** The fork tracks upstream selectively: relevant upstream fixes are applied here (see [CHANGELOG.md](./CHANGELOG.md)), and the crate name and public API stay upstream-compatible. Releases are tagged `vX.Y.Z` on master.

**Development.** Run `make setup` once (toolchain target, cargo tools, git hooks), then `make help` lists all targets; `make lint` and `make test` run exactly what CI runs, and `make install-hooks` installs a pre-commit hook that runs both. On Apple Silicon, the SIMD code is compiled out of plain `make test`; use `make test-x86` to run the x86-gated SIMD tests under Rosetta.

---

This crate provides distances computations used in some related crates [hnsw_rs](https://crates.io/crates/hnsw_rs), [annembed](https://crates.io/crates/annembed) and [coreset](https://github.com/jean-pierreBoth/coreset)

All distances implement the trait **Distance**:

```rust
pub trait Distance<T: Send + Sync> {
    fn eval(&self, va: &[T], vb: &[T]) -> f32;
}
```

## Functionalities

The crate provides:

- usual distances as L1, L2, Cosine, Jaccard, Hamming for vectors of standard numeric types, Levenshtein distance on u16.

- Hellinger distance and Jeffreys divergence between probability distributions (f32 and f64). It must be noted that the Jeffreys divergence
  (a symetrized Kullback-Leibler divergence) do not satisfy the triangle inequality. (Neither Cosine distance !).

- Jensen-Shannon distance between probability distributions (f32 and f64). It is defined as the **square root** of the Jensen-Shannon divergence and is a bounded metric. See [Nielsen F. in Entropy 2019, 21(5), 485](https://doi.org/10.3390/e21050485).

- A Trait to enable the user to implement its own distances.
  It takes as data slices of types T satisfying T:Serialize+Clone+Send+Sync. It is also possible to use C extern functions or closures.

- Simd implementation is provided for the most often used case.

## Implementation

Simd support is provided with the [simdeez](https://crates.io/crates/simdeez) crate on Intel and partial implementation with **std::simd** for general case.

## Building

### Simd

- The simd provided by the simdeez crate is accessible with the feature "simdeez_f" for x86_64 processors.
  Compile with **cargo build --release --features "simdeez_f"** ....
  To compile this crate on a M1 chip just do not activate this feature.

- It is nevertheless possible to experiment with std::simd. Compiling with the feature stdsimd
  (**cargo build --release --features "stdsimd"**), activates the portable_simd feature on rust nightly. **This requires nightly compiler**.
  Only the Hamming distance with the u32x16 and u64x8 types and DistL1,DistL2 and DistDot on f32\*16 are provided for now.

## Benchmarks and Examples

The speed is illustated in the [hnsw_rs](https://crates.io/crates/hnsw_rs), [annembed](https://crates.io/crates/annembed) crates

## Changes

Version 0.1.3: switched to edition=2024

Version 0.1.4: simdeez switched to 2.0.0. Added _distance_jaccard_u16_32_simd_ (contribution from Jianshu Zhao)

## Contributions

Petter Egesund added the DistLevenshtein distance.

## License

Licensed under either of

- Apache License, Version 2.0, [LICENSE-APACHE](LICENSE-APACHE) or <http://www.apache.org/licenses/LICENSE-2.0>
- MIT license [LICENSE-MIT](LICENSE-MIT) or <http://opensource.org/licenses/MIT>

at your option.
