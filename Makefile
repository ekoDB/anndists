# Makefile for anndists (ekoDB fork)

CARGO := cargo

# Color codes for pretty output
CYAN := \033[36m
GREEN := \033[32m
YELLOW := \033[33m
RED := \033[31m
BOLD := \033[1m
RESET := \033[0m

# ASCII Banner
BANNER := "$(BOLD) ██████═╗ ██╗  ██╗  ██████╗  ████████╗ ████████╗$(RESET)\n$(BOLD)██╔═══██╝ ██║ ██╔╝ ██╔═══██╗  ██╔═══██║ ██╔═══██╗$(RESET)\n$(BOLD)████████╗ █████╔╝  ██║   ██║  ██║   ██║████████╔╝$(RESET)\n$(BOLD)██╔═════╝ ██╔═██╗  ██║   ██║  ██║   ██║ ██╔═══██╗$(RESET)\n$(BOLD)████████╗ ██║  ██╗ ╚██████╔╝ ████████║ ████████╔╝$(RESET)\n$(BOLD)╚═══════╝ ╚═╝  ╚═╝  ╚═════╝  ╚═══════╝ ╚═══════╝$(RESET)"

SUBTITLE := \
	"          📐  anndists  •  Distance Kernels (ekoDB fork)" "\n"

.PHONY: all setup build build-release test test-x86 check fmt fmt-md lint lint-fix docs clean deps-check deps-update audit install-hooks versions set-version bump-version help

all: build

help:
	@echo ""
	@echo $(BANNER)
	@echo ""
	@echo $(SUBTITLE)
	@echo ""
	@echo "$(CYAN)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(RESET)"
	@echo "📌 $(CYAN)BUILD & TEST$(RESET)"
	@echo "$(CYAN)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(RESET)"
	@echo "  🧰 $(GREEN)make setup$(RESET)              - One-time dev setup (rustup target, cargo tools, git hooks)"
	@echo "  🛠️  $(GREEN)make build$(RESET)              - Debug build"
	@echo "  🚀 $(GREEN)make build-release$(RESET)      - Release build"
	@echo "  🧪 $(GREEN)make test$(RESET)               - Tests (default + simdeez_f, matches CI)"
	@echo "  💻 $(GREEN)make test-x86$(RESET)           - Run the x86-gated SIMD tests under Rosetta (Apple Silicon)"
	@echo "  ✅ $(GREEN)make check$(RESET)              - Check compilation without building"
	@echo ""
	@echo "$(CYAN)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(RESET)"
	@echo "🔧 $(CYAN)CODE QUALITY$(RESET)"
	@echo "$(CYAN)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(RESET)"
	@echo "  🖌️  $(GREEN)make fmt$(RESET)                - Format all code (Rust + Markdown)"
	@echo "  📝 $(GREEN)make fmt-md$(RESET)             - Format Markdown files only"
	@echo "  🔍 $(GREEN)make lint$(RESET)               - fmt --check + clippy -D warnings (matches CI)"
	@echo "  🔧 $(GREEN)make lint-fix$(RESET)           - Run clippy with auto-fix"
	@echo "  📚 $(GREEN)make docs$(RESET)               - Build crate documentation"
	@echo "  🧹 $(GREEN)make clean$(RESET)              - Remove build artifacts"
	@echo ""
	@echo "$(CYAN)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(RESET)"
	@echo "📦 $(CYAN)DEPENDENCIES$(RESET)"
	@echo "$(CYAN)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(RESET)"
	@echo "  📋 $(GREEN)make deps-check$(RESET)         - Check for outdated dependencies"
	@echo "  📦 $(GREEN)make deps-update$(RESET)        - Upgrade dependencies (bumps Cargo.toml)"
	@echo "  🔒 $(GREEN)make audit$(RESET)              - Audit dependencies for vulnerabilities"
	@echo "  🪝 $(GREEN)make install-hooks$(RESET)      - Install the pre-commit git hook (lint + test)"
	@echo ""
	@echo "$(CYAN)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(RESET)"
	@echo "🔢 $(CYAN)VERSIONING$(RESET)"
	@echo "$(CYAN)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(RESET)"
	@echo "  📋 $(GREEN)make versions$(RESET)           - Show crate version"
	@echo "  🔢 $(GREEN)make set-version VERSION=x.y.z$(RESET) - Set crate version + refresh Cargo.lock"
	@echo "  🚀 $(GREEN)make bump-version VERSION=x.y.z$(RESET) - Cap a release: collapse CHANGELOG [Unreleased], set-version, print the commit subject"

# One-time developer setup: everything the other targets rely on. Idempotent.
setup:
	@echo "🧰 $(CYAN)Setting up the development environment...$(RESET)"
	@if [ "$$(uname -s)" = "Darwin" ]; then \
		echo "$(CYAN)Adding x86_64-apple-darwin target (for make test-x86)...$(RESET)"; \
		rustup target add x86_64-apple-darwin; \
	fi
	@if ! command -v cargo-audit >/dev/null 2>&1; then \
		echo "$(CYAN)Installing cargo-audit...$(RESET)"; \
		cargo install cargo-audit; \
	fi
	@if ! command -v cargo-upgrade >/dev/null 2>&1; then \
		echo "$(CYAN)Installing cargo-edit (provides cargo upgrade)...$(RESET)"; \
		cargo install cargo-edit; \
	fi
	@$(MAKE) install-hooks
	@echo "✅ $(GREEN)Setup complete!$(RESET)"

build:
	$(CARGO) build

build-release:
	$(CARGO) build --release

# Matches .github/workflows/rust.yml exactly: green here means green in CI.
test:
	$(CARGO) test --locked
	$(CARGO) test --locked --features simdeez_f

# The SIMD implementations and their tests are x86-gated, so plain `make test`
# on Apple Silicon compiles them out. This runs them under Rosetta (SSE2; the
# runtime dispatcher exercises the same function bodies as AVX2). Requires the
# x86_64-apple-darwin target: rustup target add x86_64-apple-darwin
test-x86:
	@if [ "$$(uname -s)" != "Darwin" ]; then \
		echo "$(YELLOW)test-x86 targets Rosetta on macOS; on an x86_64 host plain 'make test' already covers this.$(RESET)"; \
		exit 1; \
	fi
	$(CARGO) test --locked --features simdeez_f --target x86_64-apple-darwin

check:
	$(CARGO) check --all-targets
	$(CARGO) check --all-targets --features simdeez_f

fmt: fmt-md
	$(CARGO) fmt

fmt-md:
	@echo "$(CYAN)Formatting Markdown...$(RESET)"
	@if command -v prettier > /dev/null; then \
		prettier --write *.md 2>/dev/null || true; \
	else \
		echo "$(YELLOW)prettier not installed - skipping Markdown formatting$(RESET)"; \
	fi

# Matches .github/workflows/rust.yml exactly: green here means green in CI.
# The nightly-only stdsimd feature is intentionally not linted.
lint:
	$(CARGO) fmt --check
	$(CARGO) clippy --locked --all-targets -- -D warnings
	$(CARGO) clippy --locked --all-targets --features simdeez_f -- -D warnings

lint-fix: fmt
	$(CARGO) clippy --locked --all-targets --features simdeez_f --fix --allow-dirty --allow-staged -- -D warnings

docs:
	$(CARGO) doc --no-deps --features simdeez_f

clean:
	$(CARGO) clean

deps-check:
	@echo "$(CYAN)Checking for outdated dependencies...$(RESET)"
	@if command -v cargo-outdated >/dev/null 2>&1; then \
		$(CARGO) outdated -R; \
	else \
		echo "$(YELLOW)cargo-outdated not installed.$(RESET)"; \
		echo "$(YELLOW)Run 'cargo install cargo-outdated' to install it.$(RESET)"; \
	fi

deps-update:
	@if ! command -v cargo-upgrade >/dev/null 2>&1; then \
		echo "$(YELLOW)Installing cargo-edit (provides cargo upgrade)...$(RESET)"; \
		cargo install cargo-edit; \
	fi
	@echo "📦 $(CYAN)Upgrading dependencies...$(RESET)"
	cargo upgrade
	$(CARGO) update

audit:
	@echo "$(CYAN)Auditing dependencies for vulnerabilities...$(RESET)"
	@if command -v cargo-audit >/dev/null 2>&1; then \
		$(CARGO) audit; \
	else \
		echo "$(YELLOW)cargo-audit not installed.$(RESET)"; \
		echo "$(YELLOW)Run 'cargo install cargo-audit' to install it.$(RESET)"; \
	fi

install-hooks:
	@echo "🪝 $(CYAN)Installing Git hooks...$(RESET)"
	@if [ -f scripts/pre-commit ]; then \
		cp scripts/pre-commit .git/hooks/pre-commit; \
		chmod +x .git/hooks/pre-commit; \
		echo "✅ $(GREEN)Git hooks installed!$(RESET)"; \
	else \
		echo "$(YELLOW)scripts/pre-commit not found, skipping...$(RESET)"; \
	fi

versions:
	@grep '^version =' Cargo.toml | head -1

# Usage: make set-version VERSION=0.2.1
# Remember to convert the CHANGELOG [Unreleased] block to a dated version
# block in the same commit, and tag vX.Y.Z on master after merge.
set-version:
	@if [ -z "$(VERSION)" ]; then \
		echo "$(RED)Error: VERSION is required. Usage: make set-version VERSION=0.2.1$(RESET)"; \
		exit 1; \
	fi
	@# Semver-strict validation so a VERSION value can't smuggle quotes or
	@# whitespace into the awk replacement below.
	@if ! echo "$(VERSION)" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?(\+[0-9A-Za-z.-]+)?$$'; then \
		echo "$(RED)Error: VERSION must be semver (x.y.z[-prerelease][+build]). Got: $(VERSION)$(RESET)"; \
		exit 1; \
	fi
	@echo "$(CYAN)Setting Cargo.toml to $(VERSION)...$(RESET)"
	@awk -v version='$(VERSION)' 'BEGIN{done=0} /^version = "[^"]+"$$/ && !done {print "version = \"" version "\""; done=1; next} {print}' Cargo.toml > Cargo.toml.tmp && mv Cargo.toml.tmp Cargo.toml
	@echo "$(CYAN)Refreshing Cargo.lock...$(RESET)"
	@$(CARGO) update -p anndists --precise $(VERSION) 2>/dev/null || $(CARGO) check --quiet
	@echo "$(GREEN)Version set:$(RESET)"
	@grep '^version =' Cargo.toml | head -1

# Usage: make bump-version VERSION=0.3.0
#
# Caps a release in one step: collapses CHANGELOG.md's "[Unreleased]" heading
# into a dated version block, reuses set-version for Cargo.toml + Cargo.lock,
# and prints the exact commit subject this org's shared public-repo release
# automation's release-cap detector matches (a subject of exactly
# "chore(<scope>): vX.Y.Z", scope optional, plain version) to cut the tag once
# that commit reaches master. This repo has no pre-release ladder -- it
# releases directly when a change is ready, so VERSION must be a plain x.y.z;
# a pre-release/build-metadata suffix is refused outright, since that detector
# never matches one anyway and a half-applied "pre-release" CHANGELOG entry
# would just be dead weight.
#
# Edits files only. Never commits, tags, or pushes -- review the diff (git
# diff), then commit CHANGELOG.md, Cargo.toml and Cargo.lock together by hand.
bump-version:
	@if [ -z "$(VERSION)" ]; then \
		echo "$(RED)Error: VERSION is required. Usage: make bump-version VERSION=0.3.0$(RESET)"; \
		exit 1; \
	fi
	@if ! echo "$(VERSION)" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$$'; then \
		echo "$(RED)Error: bump-version only cuts a plain release (x.y.z, no pre-release/build suffix).$(RESET)"; \
		echo "$(RED)This repo has no pre-release ladder, and a pre-release subject never satisfies the release-cap detector. Got: $(VERSION)$(RESET)"; \
		echo "$(YELLOW)For a scratch/local version bump that must not be read as a release cap, use 'make set-version VERSION=$(VERSION)' instead (it does not touch CHANGELOG.md).$(RESET)"; \
		exit 1; \
	fi
	@if ! grep -q '^## \[Unreleased\]$$' CHANGELOG.md; then \
		echo "$(RED)Error: CHANGELOG.md has no '## [Unreleased]' block to collapse.$(RESET)"; \
		exit 1; \
	fi
	@echo "$(CYAN)Collapsing CHANGELOG.md [Unreleased] into [$(VERSION)]...$(RESET)"
	@sed -i.bak "s/^## \[Unreleased\]$$/## [$(VERSION)] - $$(date -u +%Y-%m-%d)/" CHANGELOG.md && rm -f CHANGELOG.md.bak
	@$(MAKE) --no-print-directory set-version VERSION=$(VERSION)
	@echo ""
	@echo "$(GREEN)✅ CHANGELOG.md collapsed and Cargo.toml/Cargo.lock set to $(VERSION).$(RESET)"
	@echo "$(YELLOW)Review the diff (git diff), then commit CHANGELOG.md, Cargo.toml and Cargo.lock together as:$(RESET)"
	@echo ""
	@echo "    chore(*): v$(VERSION)"
	@echo ""
	@echo "$(YELLOW)That exact subject is required verbatim -- it is what this org's shared public-repo release$(RESET)"
	@echo "$(YELLOW)automation matches to cut the v$(VERSION) tag and publish the Release once the commit reaches master.$(RESET)"
	@echo "$(YELLOW)This target never commits, tags, or pushes -- do that by hand after reviewing the diff.$(RESET)"
