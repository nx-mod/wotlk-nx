#!/bin/sh
# Publishes a release the self-updater takes (crates/benilla-horizon/update.c): target/wotlk-nx.nro, built by
#   WOTLKNX_BUILD_NUMBER=<N> sh switch/build-benilla.sh -j2
# is packed stored (zip -0, which the console unpacks as it downloads) as wotlk-nx-switch.zip and published as GitHub
# release build-<N> on nx-mod/wotlk-nx, at HEAD, which must be pushed. Usage: switch/release.sh <N> <notes file>
set -e
N=$1
NOTES=$2
[ -n "$N" ] && [ -f "$NOTES" ] || { echo "usage: $0 <build number> <notes file>"; exit 1; }
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"
BUILT=$(cat target/wotlk-nx.build 2>/dev/null || echo none)
[ "$BUILT" = "$N" ] || { echo "target/wotlk-nx.nro is build $BUILT, not $N: build it with WOTLKNX_BUILD_NUMBER=$N"; exit 1; }
HEAD=$(git rev-parse HEAD)
git branch -r --contains "$HEAD" | grep -q origin/ || { echo "HEAD $HEAD is not pushed to origin"; exit 1; }
rm -f target/wotlk-nx-switch.zip
(cd target && zip -0 -X wotlk-nx-switch.zip wotlk-nx.nro)
gh release create "build-$N" target/wotlk-nx-switch.zip --repo nx-mod/wotlk-nx --target "$HEAD" \
  --title "wotlk-nx build $N" --notes-file "$NOTES"
