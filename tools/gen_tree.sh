#!/usr/bin/env bash
# Refresh the court folder metadata and template directories from data/index.json.
# Manual fields in existing court.json files are retained. This script never
# removes court content and never writes status "done".
set -euo pipefail

script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
root=$(CDPATH='' cd -- "$script_dir/.." && pwd)
index=$root/data/index.json
tmp_suffix=$$

if [ ! -f "$index" ]; then
  printf '%s\n' "gen_tree: missing $index" >&2
  exit 2
fi

# Keep the checked-in index normalized by jq's one-space JSON formatting.
index_tmp=$index.tmp.$tmp_suffix
jq --indent 1 . "$index" > "$index_tmp"
mv "$index_tmp" "$index"

count=0
while IFS= read -r alias; do
  path=$(jq -r --arg alias "$alias" '.courts[$alias].path' "$index")
  court=$root/$path
  mkdir -p "$court/typst" "$court/latex"
  : > "$court/typst/.gitkeep"
  : > "$court/latex/.gitkeep"

  current=$court/court.json
  if [ -f "$current" ]; then
    old=$(cat "$current")
  else
    old='{}'
  fi
  output=$court/court.json.tmp.$tmp_suffix
  jq --indent 2 -n \
    --slurpfile index "$index" \
    --arg alias "$alias" \
    --argjson old "$old" \
    --slurpfile scope "$root/data/scope.json" '
    ($index[0]) as $idx
    | ($idx.courts[$alias]) as $entry
    | {
        alias: $alias,
        courtlistener_id: $entry.courtlistener_id,
        name: $entry.name,
        level: $entry.level,
        circuit: $entry.circuit,
        state: $entry.state,
        path: $entry.path,
        status: (if ($old | has("status")) then $old.status else "todo" end),
        reviewed_by: (if ($old | has("reviewed_by")) then $old.reviewed_by else null end),
        notes: (if ($old | has("notes")) then $old.notes else ($scope[0].note_overrides[$alias] // "") end),
        parent_alias: $entry.parent_alias,
        legacy_aliases: ($old.legacy_aliases // [$idx.legacy_aliases | to_entries[] | select(.value == $alias) | .key])
      }
  ' > "$output"
  mv "$output" "$current"
  count=$((count + 1))
done <<EOF
$(jq -r '.courts | keys[]' "$index")
EOF

unplaced=$(jq -r '[.unplaced[].alias] | join(", ")' "$index")
printf 'leaves: %s unplaced: [%s]\n' "$count" "$unplaced"
