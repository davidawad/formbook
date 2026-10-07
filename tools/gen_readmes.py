#!/usr/bin/env python3
"""Generate every README.md in the tree plus the index block of the top README.

Usage: gen_readmes.py <manifest.txt> <rows.txt>
  manifest.txt  from tools/manifest.sh (supplies the six presence flags)
  rows.txt      from tools/tracker.bend, section "rows" (alias|status|pct)
Completion LOGIC lives in tracker.bend; this only lays results out as markdown.
"""
import json, os, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
idx = json.load(open(os.path.join(ROOT, "data", "index.json")))
courts = idx["courts"]
flags = {}
for line in open(sys.argv[1]):
    p = line.rstrip("\n").split("|")
    if len(p) >= 7:
        flags[p[0]] = (p[5], p[6])
rows = {}
for line in open(sys.argv[2]):
    p = line.rstrip("\n").split("|")
    if len(p) == 3:
        rows[p[0]] = (p[1], p[2])

FLAGS = [("rules", "`rules.md` present"), ("exemplar", "`exemplars/` has a .pdf"),
         ("sample", "`samples/` has a .md"), ("typst", "`typst/` has a .typ"),
         ("latex", "`latex/` has a .tex"), ("render", "`samples/` has a .pdf")]


def write(rel, text):
    with open(os.path.join(ROOT, rel), "w") as f:
        f.write(text)


def relto(frm_dir, to):
    return os.path.relpath(to, frm_dir) if frm_dir else to


def row(a, frm_dir):
    c = courts[a]
    st, pct = rows[a]
    link = relto(frm_dir, c["path"])
    return "| [%s](%s) | `%s` | %s | %s | %s |" % (c["name"].strip(), link, a, c["level"], st, pct)


HEAD = "| Court | Alias | Level | Status | % |\n|---|---|---|---|---:|"
table = lambda aliases, d: HEAD + "\n" + "\n".join(row(a, d) for a in aliases) if aliases else ""

paths = {c["path"]: a for a, c in courts.items()}

# ---- leaf READMEs --------------------------------------------------------
for a, c in courts.items():
    d = c["path"]
    depth = d.count("/") + 1
    up = "../" * depth
    st, pct = rows[a]
    manual, fl = flags[a]
    cl = c["courtlistener_id"]
    cl_line = ("[%s](https://www.courtlistener.com/?court=%s)" % (cl, cl)) if cl else "none (not a CourtListener id)"
    out = ["# %s" % c["name"].strip(), "",
           "- Alias: `%s`" % a,
           "- CourtListener: %s" % cl_line,
           "- Level: %s" % c["level"]]
    if c["circuit"]:
        out.append("- Circuit: `%s`" % c["circuit"])
    if c["state"]:
        out.append("- State / territory: %s" % c["state"])
    if c["parent_alias"]:
        out.append("- Parent: `%s`" % c["parent_alias"])
    leg = [l for l, t in idx["legacy_aliases"].items() if t == a]
    if leg:
        out.append("- Legacy aliases: " + ", ".join("`%s`" % l for l in leg))
    out += ["- Status: **%s** (%s%%); manual status in `court.json`: `%s`" % (st, pct, manual), "",
            "## Checklist", ""]
    for i, (k, desc) in enumerate(FLAGS):
        out.append("- [%s] %s" % ("x" if fl[i] == "1" else " ", desc))
    out += ["", "`done` is set by a human in `court.json` (`\"status\": \"done\"`); nothing automated writes it.",
            "A court is `up for review` when rules, sample, typst and render are all present.", "",
            "## Folders", "",
            "- `typst/` Typst templates (primary)", "- `latex/` LaTeX templates (where needed)",
            "- `exemplars/` real filed examples (PDF)", "- `samples/` our sample inputs (.md) and rendered output (.pdf)"]
    # hand-written court documentation (markdown contract, decisions, known defects) lives in
    # README.extra.md and is appended verbatim, so regenerating never destroys it
    extra = os.path.join(ROOT, d, "README.extra.md")
    if os.path.exists(extra):
        out += ["", open(extra).read().rstrip("\n")]
    kids = [x for x, cc in courts.items() if cc["path"].startswith(d + "/")]
    if kids:
        out += ["", "## Subdivisions", "", table(kids, d)]
    out += ["", "[Formbook index](%sREADME.md) | [Status table](%sSTATUS.md)" % (up, up), ""]
    write(os.path.join(d, "README.md"), "\n".join(out))

# ---- non-leaf READMEs ----------------------------------------------------
dirs = set()
for p in paths:
    parts = p.split("/")
    for i in range(1, len(parts)):
        dirs.add("/".join(parts[:i]))
for d in sorted(dirs):
    if d in paths:
        continue  # a leaf; already written
    desc = [a for a, c in courts.items() if c["path"].startswith(d + "/")]
    depth = d.count("/") + 1
    up = "../" * depth
    title = d.split("/")[-1].replace("-", " ")
    out = ["# %s" % title.title() if d != "courts" else "# Courts", "",
           "Courts under `%s` (%d)." % (d, len(desc)), "", table(desc, d), "",
           "[Formbook index](%sREADME.md)" % up, ""]
    write(os.path.join(d, "README.md"), "\n".join(out))

# ---- top-level index block -----------------------------------------------
order = []
for a, c in courts.items():
    if c["group"] not in order:
        order.append(c["group"])
blk = []
for g in order:
    members = [a for a, c in courts.items() if c["group"] == g]
    blk += ["## %s" % g, ""]
    states = []
    for a in members:
        s = courts[a]["state"]
        if s and s not in states:
            states.append(s)
    top = [a for a in members if not courts[a]["state"]]
    if top:
        blk += [table(top, ""), ""]
    for s in states:
        blk += ["### %s" % s, "", table([a for a in members if courts[a]["state"] == s], ""), ""]
if idx["unplaced"]:
    blk += ["## Unplaced", "",
            "In scope but with a location the circuit map cannot place; no folder is created until a human decides.", "",
            "| Alias | Name | courts-db location |", "|---|---|---|"]
    blk += ["| `%s` | %s | %s |" % (u["alias"], u["name"], u["location"]) for u in idx["unplaced"]]
    blk += [""]
text = "\n".join(blk)

rp = os.path.join(ROOT, "README.md")
s = open(rp).read()
a, b = s.index("<!-- index:start -->"), s.index("<!-- index:end -->")
open(rp, "w").write(s[:a] + "<!-- index:start -->\n" + text + "\n" + s[b:])
print("readmes written for %d leaves, %d folders" % (len(courts), len(dirs - set(paths))))
