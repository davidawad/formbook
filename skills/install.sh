#!/bin/sh
# Install the formbook agent skill: sh skills/install.sh <skills-dir>   (e.g. ~/.claude/skills)
set -eu

[ $# -eq 1 ] || {
  echo "Usage: sh skills/install.sh <skills-dir>"
  echo "Example: sh skills/install.sh ~/.claude/skills"
  exit 1
}

here=$(cd "$(dirname "$0")" && pwd)
src="$here/formbook"
dest="$1/formbook"

[ -f "$src/SKILL.md" ] || { echo "Cannot find $src/SKILL.md" >&2; exit 1; }

mkdir -p "$1"
if [ -e "$dest" ]; then
  echo "Replacing the existing copy at $dest"
  rm -rf "$dest"
fi
cp -R "$src" "$dest"

echo "Installed the formbook skill to $dest"
echo "Restart your agent, then ask it to format a court filing, or type /formbook."
echo "The skill renders with the templates in a formbook checkout: $(dirname "$here")"
