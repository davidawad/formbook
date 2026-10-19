# formbook task runner. Every recipe is a straight pipeline into `fb` (tools/fb, Rust): no branching here. Names inside a doc folder's usage/ come from `fb usage`.
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
    {{fb}} usage inputs {{DIR}} | xargs -n1 {{fb}} overlay {{DIR}}

# overlay every doc folder that has a usage/ dir
overlay-all:
    find courts -type d -name usage | sed 's|/usage$||' | sort | xargs -n1 {{just_executable()}} overlay

# run the eval-loop gates of DIR (fb check)
check DIR:
    {{fb}} check {{DIR}}

# run the gates of every doc folder that has a checks.yaml
check-all:
    find courts -name checks.yaml | sed 's|/checks.yaml$||' | sort | xargs -n1 {{fb}} check

# judge every doc folder under DIR that has an INPUT (fb check: its checks.yaml, else data/checks-default.yaml), then regenerate the tracker
eval DIR:
    {{fb}} eval {{DIR}}

# `just eval` over every court
eval-all:
    {{fb}} eval courts

# mutation-test the checker of court folder DIR: every mutant must be caught (fb check-selftest)
check-selftest DIR:
    {{fb}} check-selftest {{DIR}}

# measured diff (fb diff) of each typst render of DIR against its same-id FILED-EXAMPLE
diff DIR:
    {{fb}} usage pairs {{DIR}} | xargs -n2 {{fb}} diff

# repo-wide lints: audited font faces, usage/ path validity
lint:
    {{fb}} lint fonts
    {{fb}} lint paths

lint-metadata sample:
    {{fb}} lint metadata "{{sample}}"

# regenerate data/worklist.json; ARGS: --stdout | --check (fb worklist)
worklist *ARGS:
    {{fb}} worklist {{ARGS}}

# claim one court: ARGS = <alias> | --next | --random [--dry-run] (fb claim)
claim *ARGS:
    {{fb}} claim {{ARGS}}

# contribute: pick | claim <id> | brief <id> | verify <id> | submit <id> (fb contribute)
contribute *ARGS:
    {{fb}} contribute {{ARGS}}

# locate a court folder and the doc types that have a template: ARGS = <alias|text> [doctype]
find *ARGS:
    {{fb}} find {{ARGS}}

# start a filing from a doc type's sample input
new-filing ALIAS DOCTYPE OUT:
    {{fb}} new-filing {{ALIAS}} {{DOCTYPE}} {{OUT}}

# render a markdown file that lives outside the court folder: DIR is a doc-type folder; OUT defaults next to MD
render-filing DIR MD *OUT:
    {{fb}} render-filing {{DIR}} {{MD}} {{OUT}}

# install and verify the pinned toolchain without root: ARGS = [--check]
bootstrap *ARGS:
    {{fb}} bootstrap {{ARGS}}

# regenerate the images in docs/showcase/
showcase:
    {{fb}} showcase
