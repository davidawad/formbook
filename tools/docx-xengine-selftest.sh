#!/usr/bin/env sh
set -eu
cd "$(dirname "$0")/.."
export LUA_PATH="$PWD/lib/?.lua;$PWD/lib/?/init.lua;;"
printf '' | pandoc --from markdown --to native --lua-filter tools/docx-xengine-selftest.lua >/dev/null
printf 'DOCX XENGINE SELFTEST OK\n'
