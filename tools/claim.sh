#!/bin/sh
# Claim one court for an agent without colliding with other agents.
#
# Usage: tools/claim.sh <alias> | --next | --random   [--dry-run]
#   <alias>    claim that court
#   --next     the highest-priority unclaimed court (order: data/priority.json)
#   --random   a random unclaimed court
#   --dry-run  decide and print, push nothing
#
# A claim is the atomic creation of the remote branch court/<alias> from origin/master. The push uses
# --force-with-lease=<ref>: (expect "does not exist"), so it fails if anyone created the branch first,
# and the next candidate is tried. A court is unclaimed when no remote court/<alias> branch exists,
# its court.json on origin/master is not "done", and it is not already up for review on origin/master
# (rules.md + typst template + usage/.check-typst.txt). Courts under "reference" in data/priority.json
# are never picked by --next/--random.
#
# Prints:  alias: <alias> / path: <court folder> / branch: court/<alias>
# Next steps (docs: AGENTS.md): git fetch origin court/<alias> && git worktree add .worktrees/<alias> court/<alias>
set -eu
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"

MODE=""
ALIAS=""
DRY=0
while [ $# -gt 0 ]; do
  case $1 in
    --next) MODE=next ;;
    --random) MODE=random ;;
    --dry-run) DRY=1 ;;
    -*)
      echo "claim.sh: unknown option $1" >&2
      exit 2
      ;;
    *)
      MODE=alias
      ALIAS=$1
      ;;
  esac
  shift
done
[ -n "$MODE" ] || {
  echo "usage: tools/claim.sh <alias> | --next | --random [--dry-run]" >&2
  exit 2
}

REMOTE=${CLAIM_REMOTE:-origin}
BASE=${CLAIM_BASE:-master}
git fetch -q "$REMOTE" "$BASE"
SHA=$(git rev-parse "$REMOTE/$BASE")
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
git ls-remote --heads "$REMOTE" 'refs/heads/court/*' | sed 's|.*refs/heads/court/||' > "$TMP/claimed"
git ls-tree -r --name-only "$REMOTE/$BASE" -- courts > "$TMP/tree"

path_of() { jq -r --arg a "$1" '.courts[$a].path // empty' data/index.json; }

# eligible <alias>: prints nothing and returns 0 if claimable, else prints the reason and returns 1
eligible() {
  a=$1
  p=$(path_of "$a")
  [ -n "$p" ] || {
    echo "no such court alias: $a"
    return 1
  }
  if grep -qxF "$a" "$TMP/claimed"; then
    echo "$a is already claimed (remote branch court/$a exists)"
    return 1
  fi
  grep -qxF "$p/court.json" "$TMP/tree" || {
    echo "$a: $p/court.json is not on $REMOTE/$BASE"
    return 1
  }
  st=$(git show "$REMOTE/$BASE:$p/court.json" | jq -r '.status // "todo"')
  [ "$st" != done ] || {
    echo "$a is done"
    return 1
  }
  if grep -qxF "$p/rules.md" "$TMP/tree" && grep -qxF "$p/usage/.check-typst.txt" "$TMP/tree" &&
    grep -q "^$p/typst/.*\.typ$" "$TMP/tree"; then
    echo "$a is already up for review on $BASE"
    return 1
  fi
  return 0
}

candidates() {
  case $MODE in
    alias) echo "$ALIAS" ;;
    next) jq -r --argjson r "$(jq -c '.reference // []' data/priority.json)" '.order[] | select(. as $a | $r | index($a) | not)' data/priority.json ;;
    random) jq -r --argjson r "$(jq -c '.reference // []' data/priority.json)" '.order[] | select(. as $a | $r | index($a) | not)' data/priority.json |
      awk 'BEGIN { srand() } { print rand() "\t" $0 }' | sort -n | cut -f2 ;;
  esac
}

last=""
for a in $(candidates); do
  if why=$(eligible "$a"); then
    if [ "$DRY" = 1 ]; then
      echo "alias: $a"
      echo "path: $(path_of "$a")"
      echo "branch: court/$a"
      echo "(dry run: nothing pushed)"
      exit 0
    fi
    if git push -q --force-with-lease="refs/heads/court/$a:" "$REMOTE" "$SHA:refs/heads/court/$a" 2> "$TMP/push.err"; then
      echo "alias: $a"
      echo "path: $(path_of "$a")"
      echo "branch: court/$a"
      echo "next: git fetch $REMOTE court/$a && git worktree add .worktrees/$a court/$a" >&2
      exit 0
    fi
    last="lost the race for $a: $(tail -1 "$TMP/push.err")"
    echo "claim.sh: $last; trying the next court" >&2
  else
    last=$why
    [ "$MODE" = alias ] && break
  fi
done
echo "claim.sh: nothing claimed. ${last:-no candidates}" >&2
exit 1
