#!/usr/bin/env bash
set -euo pipefail

# DREAM LAND // ONE-FILE LINUX INSTALLER
# Usage:
#   bash install-dreamland-linux.sh DreamLand-Linux-4.0-x86_64.zip
#   bash install-dreamland-linux.sh DreamLand-Linux-4.0-x86_64.tar.gz
# Or place this script beside one DreamLand-Linux archive and run it with no args.

say() { printf '%s\n' "$*"; }
die() { printf 'INSTALL ERROR // %s\n' "$*" >&2; exit 1; }

archive="${1:-}"

if [[ -z "$archive" ]]; then
  shopt -s nullglob
  found=(DreamLand-Linux*.zip DreamLand-Linux*.tar.gz DreamLand-Linux*.tgz)
  shopt -u nullglob
  (( ${#found[@]} == 1 )) || die "give me one .zip/.tar.gz file, or place exactly one DreamLand-Linux archive beside this script"
  archive="${found[0]}"
fi

[[ -f "$archive" ]] || die "archive not found: $archive"

work="$(mktemp -d "${TMPDIR:-/tmp}/dreamland-install.XXXXXX")"
trap 'rm -rf "$work"' EXIT

say "DREAM LAND // unpacking $(basename "$archive")"
case "$archive" in
  *.tar.gz|*.tgz)
    command -v tar >/dev/null 2>&1 || die "tar is required for .tar.gz archives"
    tar -xzf "$archive" -C "$work"
    ;;
  *.zip)
    if command -v unzip >/dev/null 2>&1; then
      unzip -q "$archive" -d "$work"
    elif command -v python3 >/dev/null 2>&1; then
      python3 - "$archive" "$work" <<'PY'
import sys, zipfile
with zipfile.ZipFile(sys.argv[1]) as z:
    z.extractall(sys.argv[2])
PY
    else
      die "install unzip or python3 to unpack .zip archives"
    fi
    ;;
  *)
    die "supported archives: .zip, .tar.gz, .tgz"
    ;;
esac

# Find the package root even if the archive contains a top-level directory.
installer="$(find "$work" -maxdepth 3 -type f -name install.sh -print -quit)"
[[ -n "$installer" ]] || die "this archive does not contain Dream Land install.sh"
root="$(dirname "$installer")"

# ZIP archives do not always preserve executable mode bits.
chmod +x "$root"/*.sh 2>/dev/null || true

say "DREAM LAND // installing for ${USER:-$(id -un)}"
(
  cd "$root"
  bash ./install.sh
)

prefix="${PREFIX:-$HOME/.local}"
say ""
say "INSTALL COMPLETE // DREAM LAND"
say "RUN             // $prefix/bin/dream"
say "COMPILER        // $prefix/bin/dreamcc"
say "VM              // $prefix/bin/dreamvm"

case ":${PATH:-}:" in
  *":$prefix/bin:"*) ;;
  *)
    say ""
    say "Your shell PATH does not currently include $prefix/bin"
    say "ONE LINE       // export PATH=\"$prefix/bin:\$PATH\""
    ;;
esac
