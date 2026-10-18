# formbook task runner. Every recipe is a straight pipeline into `fb` (tools/fb, Rust) or an existing
# tools/*.sh script: no branching here. Names inside a doc folder's usage/ come from `fb usage`.
# A DIR is a doc folder: a court folder (has court.json) or a doc-type folder under one.

set shell := ["bash", "-euo", "pipefail", "-c"]

export FB_ROOT := justfile_directory()

fb := "cargo run -q --release --manifest-path tools/fb/Cargo.toml --"

# list the recipes
default:
    @{{just_executable()}} --list

# render every usage/INPUT-<id>.md of DIR to usage/OUTPUT-<id>.typst.pdf (fb render; <id> = <doctype>[-<n>])
render DIR:
    {{fb}} usage inputs {{absolute_path(DIR)}} | xargs -I{} {{fb}} usage input {{absolute_path(DIR)}} {} | xargs -I{} {{fb}} render {{absolute_path(DIR)}} {}

# render every doc folder that has a usage/ dir
render-all:
    find courts -type d -name usage | sed 's|/usage$||' | sort | xargs -n1 {{just_executable()}} render

# overlay each typst render of DIR on its same-id FILED-EXAMPLE, into .overlay/<DIR>/ (gitignored)
overlay DIR:
    {{fb}} usage inputs {{DIR}} | xargs -n1 sh tools/overlay.sh {{DIR}}

# overlay every doc folder that has a usage/ dir
overlay-all:
    find courts -type d -name usage | sed 's|/usage$||' | sort | xargs -n1 {{just_executable()}} overlay

# run the eval-loop gates of DIR (tools/check.sh -> fb check)
check DIR:
    sh tools/check.sh {{DIR}}

# run the gates of every doc folder that has a checks.yaml
check-all:
    find courts -name checks.yaml | sed 's|/checks.yaml$||' | sort | xargs -n1 sh tools/check.sh

# measured diff (fb diff) of each typst render of DIR against its same-id FILED-EXAMPLE
diff DIR:
    {{fb}} usage pairs {{DIR}} | xargs -n2 {{fb}} diff

# repo-wide lints: audited font faces, usage/ path validity
lint:
    {{fb}} lint fonts
    {{fb}} lint paths
