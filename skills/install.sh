#!/bin/sh
# Install the formbook agent skills: sh skills/install.sh <skills-dir>   (e.g. ~/.claude/skills)
# Copies every skill folder here (formbook, formbook-review); an older copy is replaced.
set -eu

[ $# -eq 1 ] || {
  echo "Usage: sh skills/install.sh <skills-dir>"
  echo "Example: sh skills/install.sh ~/.claude/skills"
  exit 1
}

here=$(cd "$(dirname "$0")" && pwd)
mkdir -p "$1"

for src in "$here"/*/; do
  src=${src%/}
  [ -f "$src/SKILL.md" ] || continue
  name=$(basename "$src")
  dest="$1/$name"
  if [ -e "$dest" ]; then
    echo "Replacing the existing copy at $dest"
    rm -rf "$dest"
  fi
  cp -R "$src" "$dest"
  echo "Installed the $name skill to $dest"
done

echo "Restart your agent, then ask it to format a court filing (/formbook) or to review a court's templates (/formbook-review)."
echo "The skills render with the templates in a formbook checkout: $(dirname "$here")"
