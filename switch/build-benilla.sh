#!/bin/sh
# Builds wotlk-nx.nro: benilla-wotlk's player build for the Switch (the `switch` profile, Cargo.toml).
# Copy it to sdmc:/wotlk-nx/ with your 3.3.5a client's Data folder at sdmc:/wotlk-nx/Data.
set -e
ROOT=$(cd "$(dirname "$0")/.." && pwd)
. "$ROOT/switch/env.sh"
cd "$ROOT"
# WOTLKNX_SHIP=1: the release profile, every dependency in one codegen unit (Cargo.toml's switch-ship); build it -j1.
PROFILE=switch
[ "$WOTLKNX_SHIP" = 1 ] && PROFILE=switch-ship
cargo build -p benilla --no-default-features --profile $PROFILE $BUILD_STD "$@"
T=/opt/devkitpro/tools/bin
# An NRO without an asset section (no --nacp) is refused at load by Sphaira/hbl (2026-10-20).
# A release (switch/release.sh) passes WOTLKNX_BUILD_NUMBER, which the self-updater compares with GitHub's latest.
VERSION=${WOTLKNX_BUILD_NUMBER:+build $WOTLKNX_BUILD_NUMBER}
$T/nacptool --create "wotlk-nx" "nx-mod" "${VERSION:-dev}" target/wotlk-nx.nacp
$T/elf2nro target/aarch64-nintendo-switch-newlib/$PROFILE/benilla.elf target/wotlk-nx.nro --nacp=target/wotlk-nx.nacp
# Which build target/wotlk-nx.nro is, for switch/release.sh; none for a build without a number.
printf '%s\n' "${WOTLKNX_BUILD_NUMBER:-0}" > target/wotlk-nx.build
echo "target/wotlk-nx.nro"
