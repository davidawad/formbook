#!/bin/sh
# Install the formbook toolchain without root (boxes have no apt): micromamba + conda-forge into a
# private prefix, then verify every tool and print its version.
# Usage: sh tools/bootstrap.sh [--check]     (--check verifies only; installs nothing)
# Idempotent: rerun to repair or re-pin. Exits non-zero if any tool is missing or has the wrong version.
# Install root: $FORMBOOK_HOME (default $HOME/.local/share/formbook). Put the tools on PATH with the
# export line this script prints at the end.
set -eu
TYPST_VERSION=0.15.0
MAMBA_VERSION=2.9.0
MAMBA_SHA256=8761c382127e6363bd9e0a2451aa3ef90d071a79133f736e2f759a3bf13040dd
BASE=${FORMBOOK_HOME:-$HOME/.local/share/formbook}
ENV_PREFIX=$BASE/env
MAMBA_ROOT=$BASE/mamba-root
MM=$BASE/bin/micromamba
# typst is pinned exactly: the court templates are written and checked against this release.
SPECS="typst==$TYPST_VERSION poppler imagemagick gawk jq go-yq pandoc tectonic"
CHECK_ONLY=0
if [ "${1:-}" = --check ]; then
  CHECK_ONLY=1
fi

if [ "$CHECK_ONLY" = 0 ]; then
  if [ ! -x "$MM" ]; then
    TMP=$(mktemp -d)
    trap 'rm -rf "$TMP"' EXIT
    mkdir -p "$BASE/bin"
    curl -fsSL -o "$TMP/micromamba.tar.bz2" \
      "https://conda.anaconda.org/conda-forge/linux-64/micromamba-$MAMBA_VERSION-0.tar.bz2"
    echo "$MAMBA_SHA256  $TMP/micromamba.tar.bz2" | sha256sum -c - >/dev/null ||
      {
        echo "bootstrap: micromamba $MAMBA_VERSION checksum mismatch" >&2
        exit 1
      }
    tar -xjf "$TMP/micromamba.tar.bz2" -C "$TMP" bin/micromamba
    mv "$TMP/bin/micromamba" "$MM"
  fi
  # install is a no-op when the prefix already satisfies the specs; create only for a fresh prefix.
  if [ -d "$ENV_PREFIX/conda-meta" ]; then
    VERB=install
  else
    VERB=create
  fi
  # shellcheck disable=SC2086 # SPECS is a list of match specs, split on purpose
  "$MM" "$VERB" -y --no-rc -r "$MAMBA_ROOT" -p "$ENV_PREFIX" -c conda-forge --override-channels $SPECS
fi

# The env wins over any system copy (the box has /usr/bin/pandoc and /usr/bin/jq).
PATH="$ENV_PREFIX/bin:$PATH"
export PATH

FAIL=0
echo "bootstrap: toolchain prefix $ENV_PREFIX"
# probe <tool> <version args...>: a tool passes if it is on PATH and its version probe exits 0.
probe() {
  NAME=$1
  shift
  if ! command -v "$NAME" >/dev/null 2>&1; then
    echo "MISSING  $NAME"
    FAIL=$((FAIL + 1))
    return 1
  fi
  if OUT=$("$@" 2>&1); then
    echo "ok       $(printf '%s\n' "$OUT" | head -n 1)  [$(command -v "$NAME")]"
    return 0
  fi
  echo "BROKEN   $NAME: version probe exited non-zero: $(printf '%s\n' "$OUT" | head -n 1)"
  FAIL=$((FAIL + 1))
  return 1
}
# presence <tool>: for tools this script does not install.
presence() {
  if command -v "$1" >/dev/null 2>&1; then
    echo "ok       $1  [$(command -v "$1")] (not installed by this script)"
  else
    echo "MISSING  $1 (not installed by this script)"
    FAIL=$((FAIL + 1))
  fi
}

if probe typst typst --version; then
  TYPST_GOT=$(typst --version | awk '{print $2}')
  if [ "$TYPST_GOT" != "$TYPST_VERSION" ]; then
    echo "WRONG    typst is $TYPST_GOT, pinned $TYPST_VERSION"
    FAIL=$((FAIL + 1))
  fi
fi
probe pdfinfo pdfinfo -v || true
for T in pdffonts pdftotext pdftohtml pdfimages pdftoppm; do
  probe "$T" "$T" -v || true
done
probe magick magick -version || true
probe gawk gawk --version || true
probe jq jq --version || true
if probe yq yq --version; then
  # the python yq also answers to "yq"; the template scripts need mikefarah's go-yq.
  case $(yq --version 2>&1) in
  *mikefarah*) ;;
  *)
    echo "WRONG    yq is not mikefarah go-yq"
    FAIL=$((FAIL + 1))
    ;;
  esac
fi
probe pandoc pandoc --version || true
probe tectonic tectonic --version || true
probe soffice soffice --version || true
presence cargo
presence br

echo
if ! command -v soffice >/dev/null 2>&1; then
  echo "note: LibreOffice (soffice) has no conda-forge package; the docx engine needs it installed another way"
fi
if [ "$FAIL" -gt 0 ]; then
  echo "bootstrap: $FAIL tool(s) missing or wrong (see lines above)" >&2
  exit 1
fi
echo "bootstrap: all tools present"
echo "bootstrap: put them on PATH with: export PATH=\"$ENV_PREFIX/bin:\$PATH\""
