#!/usr/bin/env python3
"""Build (or refresh) the formbook court tree from data/ (reproducible).

Reads data/courts-db.json, data/scope.json, data/circuits.json. Creates every
leaf court folder (court.json, empty typst/ latex/ with .gitkeep;
no empty usage/: it appears with the first file it holds) and writes data/index.json (alias -> path). Existing court.json files
keep their manual fields (status, reviewed_by, notes); nothing here ever writes
status "done".
"""
import json, os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
D = lambda *p: os.path.join(ROOT, *p)
db = json.load(open(D("data", "courts-db.json")))
scope = json.load(open(D("data", "scope.json")))
circ = json.load(open(D("data", "circuits.json")))

byid = {c["id"]: c for c in db}
active = lambda c: any(d.get("end") is None for d in c["dates"])
KEBAB = lambda s: re.sub(r"-+", "-", re.sub(r"[^a-z0-9]+", "-", s.lower())).strip("-")
OVR = scope["slug_overrides"]
CL = lambda a: None if a is None else "https://www.courtlistener.com/?court=" + a


def slugify(name, drop=()):
    s = name.strip()
    for ph in list(drop) + ["United States", "U S", "Department of Justice"]:
        s = re.sub(r"(?<!\w)" + re.escape(ph) + r"(?!\w)", " ", s, flags=re.I)
    s = KEBAB(s)
    s = re.sub(r"-appellate-district$", "-district", s)
    s = re.sub(r"^the-", "", s)
    while True:  # drop dangling connectives left by removed place names
        t = re.sub(r"-(of|the|for)$", "", s)
        if t == s:
            break
        s = t
    return s


# ---- location -> (circuit, state) --------------------------------------
loc_map = {}
for c in circ["circuits"]:
    for j in c["jurisdictions"]:
        loc_map[j["name"]] = (c, j)
for k, v in circ["location_aliases"].items():
    loc_map[k] = loc_map[v]
STATE_STRIP = {"District of Columbia": ["District of Columbia", "Washington D.C.", "D.C."]}

entries, unplaced = [], []


def add(**e):
    e.setdefault("courtlistener_id", e["alias"])
    e.setdefault("parent_alias", None)
    e.setdefault("legacy_aliases", [])
    e.setdefault("notes", scope["note_overrides"].get(e["alias"], ""))
    entries.append(e)


def cname(c):
    return c["name"].strip()


# ---- groups: scotus, federal-circuit, military, national ----------------
for g in scope["groups"]:
    for i in g["ids"]:
        c = byid[i]
        assert active(c), i
        if g["key"] == "scotus":
            parts = ["courts", g["folder"]]
            level = "supreme"
        else:
            slug = OVR.get(i) or ("court-of-appeals" if i == "cafc" else slugify(cname(c)))
            parts = ["courts", g["folder"], slug]
            level = scope["levels"][i]
        add(alias=i, name=cname(c), level=level, group=g["name"], group_key=g["key"],
            circuit=("cafc" if g["key"] == "federal-circuit" else None), state=None,
            kind="national", parts=parts)

# ---- circuits -----------------------------------------------------------
def circ_root(c):
    return ["courts", c["slug"]]


for c in circ["circuits"]:
    a = c["alias"]
    assert active(byid[a]), a
    add(alias=a, name=cname(byid[a]), level="appellate", group=c["name"], group_key=a,
        circuit=a, state=None, kind="circuit", parts=circ_root(c) + ["court-of-appeals"])
    bap = "bap" + a[2:]
    if a.startswith("ca") and bap in scope["allow"]["bankruptcy_appellate_panels"]:
        assert active(byid[bap]), bap
        add(alias=bap, name=cname(byid[bap]), level="bap", group=c["name"], group_key=a,
            circuit=a, state=None, kind="circuit", parts=circ_root(c) + ["bankruptcy-appellate-panel"])


def place(cid, kind, level, slug, note=None):
    c = byid[cid]
    loc = c["location"]
    if loc not in loc_map:
        unplaced.append({"alias": cid, "name": cname(c), "location": loc})
        return
    ci, j = loc_map[loc]
    add(alias=cid, name=cname(c), level=level, group=ci["name"], group_key=ci["alias"],
        circuit=ci["alias"], state=j["name"], kind=kind,
        parts=circ_root(ci) + [j["slug"], kind, slug])


DIRS = {"northern": "northern", "southern": "southern", "eastern": "eastern",
        "western": "western", "middle": "middle", "central": "central",
        "n": "northern", "s": "southern", "e": "eastern", "w": "western",
        "m": "middle", "c": "central"}


def district_slug(c, prefix):
    n = c["name"].replace(c["location"], "")  # "Northern Mariana Islands" is not a direction
    m = re.search(r"\b(Northern|Southern|Eastern|Western|Middle|Central)\b", n) or re.search(r"\b([NSEWMC])\.D\.", n)
    return prefix + (DIRS[m.group(1).lower()] + "-district" if m else "district")


den = scope["deny"]
denied = lambda i: i in den["ids"] or any(i.startswith(p) for p in den["id_prefixes"])
placed_ids = {e["alias"] for e in entries}

for i in sorted(byid):
    c = byid[i]
    if not active(c) or denied(i) or i in placed_ids or c["system"] in ("tribal", "international", "colonial"):
        continue
    if c["system"] == "federal" and c["type"] == "trial" and i not in scope["rules"][0]["exclude_ids"]:
        place(i, "federal", "district", district_slug(c, ""))
    elif c["system"] == "federal" and c["type"] == "bankruptcy" and not i.startswith("bap"):
        place(i, "federal", "bankruptcy", district_slug(c, "bankruptcy-"))

sup = re.compile(scope["state_supreme"]["name_regex"])
state_ids = [i for i in sorted(byid) if active(byid[i]) and not denied(i)
             and byid[i]["system"] == "state" and byid[i]["type"] == "appellate"]
state_ids += scope["allow"]["extra_territorial_appellate"]
for i in state_ids:
    c = byid[i]
    assert active(c), i
    loc = c["location"]
    drop = STATE_STRIP.get(loc_map[loc][1]["name"], [loc]) if loc in loc_map else [loc]
    lv = "state-supreme" if (i in scope["state_supreme"]["extra_ids"] or sup.search(cname(c))) else "state-appellate"
    place(i, "state", lv, OVR.get(i) or slugify(cname(c), drop))

for t in scope["state_trial_allow"]:
    c = byid[t["id"]]
    assert active(c)
    n0 = len(entries)
    place(t["id"], "state", "state-trial", slugify(cname(c), [t["location"]]))
    parent = entries[n0]
    for s in t["subdivisions"]:
        add(alias=s["alias"], courtlistener_id=s["courtlistener_id"], name=s["name"], level="state-trial",
            group=parent["group"], group_key=parent["group_key"], circuit=parent["circuit"],
            state=parent["state"], kind="state", parts=parent["parts"] + [s["slug"]],
            parent_alias=s["parent_alias"], legacy_aliases=s["legacy_aliases"], notes=s["notes"])

# ---- order, uniqueness --------------------------------------------------
gorder = {g["key"]: n for n, g in enumerate(scope["groups"])}
for n, c in enumerate(circ["circuits"]):
    gorder[c["alias"]] = len(scope["groups"]) + n
KORDER = {"national": 0, "circuit": 0, "federal": 1, "state": 2}
entries.sort(key=lambda e: (gorder[e["group_key"]], KORDER[e["kind"]], e["state"] or "", e["parts"]))
seen = {}
for e in entries:
    p = "/".join(e["parts"])
    e["path"] = p
    if p in seen:
        sys.exit("slug collision: %s and %s -> %s" % (seen[p], e["alias"], p))
    seen[p] = e["alias"]
if len({e["alias"] for e in entries}) != len(entries):
    sys.exit("duplicate alias")

# ---- write tree ---------------------------------------------------------
LEVELS = {"supreme", "appellate", "bap", "district", "bankruptcy", "national", "military", "agency",
          "state-supreme", "state-appellate", "state-trial"}
for e in entries:
    assert e["level"] in LEVELS, e
    d = D(e["path"])
    for sub in ("typst", "latex"):
        os.makedirs(os.path.join(d, sub), exist_ok=True)
        gk = os.path.join(d, sub, ".gitkeep")
        if not os.path.exists(gk):
            open(gk, "w").close()
    cj = os.path.join(d, "court.json")
    cur = {"status": "todo", "reviewed_by": None, "notes": e["notes"]}
    if os.path.exists(cj):
        old = json.load(open(cj))
        for k in cur:
            cur[k] = old.get(k, cur[k])
    doc = {"alias": e["alias"], "courtlistener_id": e["courtlistener_id"], "name": e["name"],
           "level": e["level"], "circuit": e["circuit"], "state": e["state"], "path": e["path"],
           "status": cur["status"], "reviewed_by": cur["reviewed_by"], "notes": cur["notes"],
           "parent_alias": e["parent_alias"], "legacy_aliases": e["legacy_aliases"]}
    with open(cj, "w") as f:
        json.dump(doc, f, indent=2, ensure_ascii=False)
        f.write("\n")

index = {
    "_comment": "GENERATED by tools/gen_tree.py. Programmatic alias -> path lookup: .courts[alias].path (relative to repo root); .legacy_aliases maps old aliases to current ones.",
    "courts": {e["alias"]: {k: e[k] for k in ("path", "name", "level", "courtlistener_id", "circuit", "state", "group", "group_key", "kind", "parent_alias")} for e in entries},
    "legacy_aliases": {l: e["alias"] for e in entries for l in e["legacy_aliases"]},
    "unplaced": sorted(unplaced, key=lambda u: u["alias"]),
}
with open(D("data", "index.json"), "w") as f:
    json.dump(index, f, indent=1, ensure_ascii=False)
    f.write("\n")
print("leaves:", len(entries), "unplaced:", [u["alias"] for u in unplaced])
