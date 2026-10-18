#!/usr/bin/env bash
# contribute-lib.sh: shared helpers and the verify step of tools/contribute.sh, which sources it.
# Not run on its own: it reads REMOTE, BASE, SLUG_DEFAULT and WL, set by contribute.sh before sourcing.
# Strict mode. pipefail only where the shell has it (bash, macOS sh); Debian's dash lacks it.
# shellcheck shell=sh disable=SC3040
set -e -u; (set -o pipefail) 2> /dev/null && set -o pipefail

# recursive delete of one directory; an empty path aborts instead of deleting the wrong thing
safe_rmdir() { rm -r -f -- "${1:?safe_rmdir: empty path}"; }

die() {
  echo "contribute.sh: $*" >&2
  exit 1
}
usage() {
  sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//' >&2
  exit 2
}
have() { command -v "$1" > /dev/null 2>&1; }

repo_slug() {
  u=$(git remote get-url "$REMOTE" 2> /dev/null || true)
  s=$(printf '%s' "$u" | sed -n 's#.*github\.com[:/]\([^/]*/[^/]*\)$#\1#p' | sed 's#\.git$##')
  printf '%s' "${s:-$SLUG_DEFAULT}"
}

# ---------------------------------------------------------------- worklist access
# The worklist from origin/master when reachable (so everyone sees the same list), else the local file.
# shellcheck disable=SC2153 # BASE is set by contribute.sh before it sources this file
load_worklist() {
  OUT=$1
  if [ "${OFFLINE:-0}" != 1 ] && git fetch -q "$REMOTE" "$BASE" 2> /dev/null &&
    git show "$REMOTE/$BASE:$WL" > "$OUT" 2> /dev/null; then
    return 0
  fi
  [ -f "$WL" ] || die "no $WL here and $REMOTE/$BASE is unreachable; run: sh tools/worklist.sh"
  cp "$WL" "$OUT"
}

unit_json() { # $1 id, $2 worklist file
  jq -c --arg id "$1" 'first(.units[] | select(.id == $id))' "$2"
}

# The unit's current state from the tree on disk: new | new-template | add-exemplar | deepen | complete
unit_state() { # $1 court_path, $2 doctype
  d="$1/$2"
  [ -d "$d" ] || {
    echo new
    return
  }
  t=0
  for f in "$d"/typst/*.typ; do [ -f "$f" ] && t=1; done
  [ "$t" = 1 ] || {
    echo new-template
    return
  }
  n=0
  for f in "$d"/usage/SAMPLE-*.pdf; do [ -f "$f" ] && n=$((n + 1)); done
  [ "$n" -gt 0 ] || {
    echo add-exemplar
    return
  }
  min=$(jq -r --arg d "$2" '.doctypes[$d].min_pages // 2' data/doctypes.json)
  pg=$(max_pages "$d")
  if [ "$pg" -gt 0 ] && [ "$pg" -lt "$min" ]; then echo deepen; else echo complete; fi
}

max_pages() {
  best=0
  have pdfinfo || {
    echo 0
    return
  }
  for o in "$1"/usage/OUTPUT-*.typst.pdf; do
    [ -f "$o" ] || continue
    p=$(pdfinfo "$o" 2> /dev/null | awk '/^Pages:/ {print $2}') || p=""
    [ -n "$p" ] && [ "$p" -gt "$best" ] && best=$p
  done
  echo "$best"
}

# ids already taken: remote contrib/* branches, remote court/<alias> branches (whole court claimed),
# and open PR head branches named contrib/* (fork claims). Prints "id <x>" and "court <alias>" lines.
claimed_set() {
  if [ "${OFFLINE:-0}" = 1 ]; then return 0; fi
  git ls-remote --heads "$REMOTE" 'refs/heads/contrib/*' 'refs/heads/court/*' 2> /dev/null |
    sed -n 's#.*refs/heads/contrib/\(.*\)#id \1#p; s#.*refs/heads/court/\(.*\)#court \1#p'
  if have gh; then
    gh pr list --repo "$(repo_slug)" --state open --limit 300 --json headRefName -q '.[].headRefName' 2> /dev/null |
      sed -n 's#^contrib/\(.*\)#id \1#p; s#^court/\(.*\)#court \1#p' || true
  fi
}

is_claimed() { # $1 id $2 alias, claimed list in $CLAIMED_FILE
  grep -qxF "id $1" "$CLAIMED_FILE" || grep -qxF "court $2" "$CLAIMED_FILE"
}

# ---------------------------------------------------------------- verify
PASSN=0
FAILN=0
ok() {
  PASSN=$((PASSN + 1))
  printf 'PASS  %s\n' "$*"
}
bad() {
  FAILN=$((FAILN + 1))
  printf 'FAIL  %s\n' "$*"
}

cmd_verify() {
  ID=""
  VBASE=""
  while [ $# -gt 0 ]; do
    case $1 in
      --base)
        VBASE=$2
        shift
        ;;
      -*) usage ;;
      *) ID=$1 ;;
    esac
    shift
  done
  [ -n "$ID" ] || usage
  TMP=$(mktemp -d) || exit 1
  trap 'safe_rmdir "$TMP"' EXIT
  OFFLINE=1
  load_worklist "$TMP/wl.json"
  U=$(unit_json "$ID" "$TMP/wl.json")
  if [ -z "$U" ]; then
    # a finished unit leaves the worklist; fall back to parsing "<alias>.<doctype>" against the index
    AL=${ID%%.*}
    DT=${ID#*.}
    CP=$(jq -r --arg a "$AL" '.courts[$a].path // empty' data/index.json)
    [ -n "$CP" ] || die "unknown unit or court alias: $ID"
  else
    AL=$(printf '%s' "$U" | jq -r .alias)
    CP=$(printf '%s' "$U" | jq -r .court_path)
    DT=$(printf '%s' "$U" | jq -r .doctype)
  fi
  F=$CP/$DT
  MIN=$(jq -r --arg d "$DT" '.doctypes[$d].min_pages // 2' data/doctypes.json)
  echo "verify $ID  ($F/)"

  # 1. layout
  [ -d "$F" ] || {
    bad "layout: folder $F/ does not exist"
    echo "RESULT: FAIL ($FAILN failed)"
    exit 1
  }
  if [ -s "$F/README.md" ]; then ok "layout: README.md"; else bad "layout: README.md missing or empty"; fi
  if [ -s "$F/typst/main.typ" ]; then ok "layout: typst/main.typ"; else bad "layout: typst/main.typ missing"; fi
  nt=0
  for f in "$F"/typst/*.typ; do [ -f "$f" ] && nt=$((nt + 1)); done
  if [ "$nt" -ge 2 ]; then ok "layout: typst template file(s) beside main.typ"; else bad "layout: expected typst/main.typ plus a template file (found $nt .typ files)"; fi
  ne=0
  for f in "$F"/usage/SAMPLE-*.pdf; do [ -f "$f" ] && ne=$((ne + 1)); done
  if [ "$ne" -ge 1 ]; then ok "layout: $ne SAMPLE pdf(s)"; else bad "layout: no usage/SAMPLE-*.pdf (a template without a filed exemplar is BLOCKED, not done)"; fi
  if [ -s "$F/usage/SOURCE.md" ]; then
    ok "layout: usage/SOURCE.md"
    for f in "$F"/usage/SAMPLE-*.pdf; do
      [ -f "$f" ] || continue
      b=$(basename "$f")
      grep -qF "$b" "$F/usage/SOURCE.md" || bad "source: $b is not described in usage/SOURCE.md"
    done
    if grep -q 'https\?://' "$F/usage/SOURCE.md"; then ok "source: SOURCE.md records a URL"; else bad "source: SOURCE.md has no http(s) URL for the SAMPLE"; fi
  else
    [ "$ne" -ge 1 ] && bad "layout: usage/SOURCE.md missing (every SAMPLE needs its public source URL)"
  fi
  ni=0
  for f in "$F"/usage/INPUT-*.md; do [ -f "$f" ] && ni=$((ni + 1)); done
  if [ "$ni" -ge 1 ]; then ok "layout: $ni usage/INPUT-*.md"; else bad "layout: no usage/INPUT-*.md"; fi

  # 2. render each INPUT; OUTPUT committed (overlays are generated into the gitignored .overlay/, not checked)
  if have typst; then
    for f in "$F"/usage/INPUT-*.md; do
      [ -f "$f" ] || continue
      sid=$(basename "$f" .md)
      sid=${sid#INPUT-}
      if sh tools/render.sh "$F" "usage/INPUT-$sid.md" "$TMP/out-$sid.pdf" > "$TMP/render.log" 2>&1; then
        ok "render: INPUT-$sid.md compiles with no typst warnings"
      else
        bad "render: INPUT-$sid.md failed: $(tail -3 "$TMP/render.log" | tr '\n' ' ')"
      fi
      if [ -s "$F/usage/OUTPUT-$sid.typst.pdf" ]; then ok "layout: OUTPUT-$sid.typst.pdf committed"; else bad "layout: usage/OUTPUT-$sid.typst.pdf missing for INPUT-$sid.md"; fi
    done
  else
    bad "render: typst not on PATH (run tools/bootstrap.sh and add its bin/ to PATH)"
  fi

  # 3. deepen: page count
  pg=$(max_pages "$F")
  if have pdfinfo; then
    UK=$(printf '%s' "$U" | jq -r '.kind // empty' 2> /dev/null || true)
    if [ "$pg" -ge "$MIN" ]; then
      ok "depth: longest OUTPUT is $pg pages (>= $MIN)"
    elif [ "$UK" = deepen ]; then
      bad "depth: longest OUTPUT is $pg pages; a deepen unit must reach $MIN+"
    else
      printf 'NOTE  depth: longest OUTPUT is %s pages; a realistic %s is %s+ (not required for kind %s)\n' "$pg" "$DT" "$MIN" "${UK:-this unit}"
    fi
  fi

  # 4. no case-specific text in typst/
  probes=$TMP/probes
  : > "$probes"
  for f in "$F"/usage/INPUT-*.md; do
    [ -f "$f" ] || continue
    # frontmatter string values that identify a case: contain a digit, or are an ALL-CAPS party name
    awk 'NR == 1 && $0 == "---" {fm = 1; next} fm && $0 == "---" {exit} fm {print}' "$f" |
      sed -n 's/^[^:]*:[[:space:]]*"\(.*\)"[[:space:]]*,\{0,1\}$/\1/p; s/^[[:space:]]*-[[:space:]]*"\(.*\)"[[:space:]]*$/\1/p' |
      awk 'length($0) >= 8 && (/[0-9]/ || /^[A-Z][A-Z .,&-]*[A-Z]\.?,?$/)' >> "$probes" || true
    # body: any 8-word run of the sample's prose
    awk 'BEGIN{fm=0} NR==1 && $0=="---"{fm=1; next} fm && $0=="---"{fm=0; next} !fm && NF>=10 {print $1" "$2" "$3" "$4" "$5" "$6" "$7" "$8}' "$f" >> "$probes"
  done
  sort -u "$probes" | grep -v '^$' > "$TMP/probes.u" || true
  hits=""
  if [ -s "$TMP/probes.u" ]; then
    hits=$(cat "$F"/typst/*.typ 2> /dev/null | grep -F -f "$TMP/probes.u" | head -3 || true)
  fi
  dockets=$(cat "$F"/typst/*.typ 2> /dev/null | grep -En '[0-9]{1,2}:[0-9]{2}-(cv|cr|bk|ap|mc)-[0-9]+|No\. [0-9]{2}-[0-9]{3,}' | head -3 || true)
  if [ -z "$hits" ] && [ -z "$dockets" ]; then
    ok "content: no case-specific text found in typst/"
  else
    [ -n "$hits" ] && bad "content: typst/ contains text copied from a sample: $(printf '%s' "$hits" | head -1 | cut -c1-120)"
    [ -n "$dockets" ] && bad "content: typst/ contains a docket number: $(printf '%s' "$dockets" | head -1 | cut -c1-120)"
  fi

  # 5. scope: nothing changed outside the unit's folder
  if git rev-parse -q --verify "$REMOTE/$BASE" > /dev/null; then B=$REMOTE/$BASE; elif git rev-parse -q --verify "$BASE" > /dev/null; then B=$BASE; else B=""; fi
  [ -n "$VBASE" ] && B=$VBASE
  if [ -n "$B" ]; then
    {
      git diff --name-only "$B"...HEAD 2> /dev/null || true
      git diff --name-only HEAD 2> /dev/null || true
      git ls-files --others --exclude-standard 2> /dev/null || true
    } | sort -u | grep -v '^$' > "$TMP/changed" || true
    stray=$(grep -v "^$F/" "$TMP/changed" | head -5 || true)
    if [ -z "$stray" ]; then
      ok "scope: only $F/ changed vs $B ($(wc -l < "$TMP/changed" | tr -d ' ') files)"
    else
      bad "scope: files outside $F/ changed: $(printf '%s' "$stray" | tr '\n' ' ')"
    fi
    if grep -q 'court\.json$' "$TMP/changed" 2> /dev/null; then
      bad "scope: a court.json changed (status done is set by the maintainer only)"
    fi
  else
    bad "scope: cannot find $REMOTE/$BASE or $BASE to diff against (pass --base REF)"
  fi

  if [ "$FAILN" -eq 0 ]; then
    echo "RESULT: PASS ($PASSN checks)"
  else
    echo "RESULT: FAIL ($FAILN failed, $PASSN passed)"
    exit 1
  fi
}
