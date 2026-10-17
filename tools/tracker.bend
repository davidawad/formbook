# Formbook completion tracker, in Bend (https://github.com/HigherOrderCO/Bend).
#
# Input : the manifest written by tools/manifest.sh (path = first CLI arg), one
#         line per court, fields separated by '|':
#           alias|group|level|name|path|manual|flags
#         flags is eight characters (see tools/manifest.sh), in order:
#           rules(0/1) exemplars(count) samples(count) typst latex docx(0 none,1 built,2 pass) overlay(0/1) review(0/1)
# Output: three sections on stdout, each opened by a "=== <name>" line:
#           summary  markdown aggregate table (per group + total)
#           status   markdown per-court table (STATUS.md body)
#           rows     alias|status|percent|typst|latex|docx|items lines (consumed by tools/gen_readmes.py);
#                    items = 8 bits, one per checklist item below
#           dsummary markdown aggregate of Typst doc-type completeness (per group + total)
#           doctypes markdown per-doc-type table (STATUS.md)
#         The doc-type input is the second CLI arg, written by tools/manifest.sh --doctypes:
#           alias|group|doctype|path|flags
#         flags is six characters: template(0/1) samples(count) render(0 none,1 rendered,2 gates pass)
#           exemplars(count) overlay(0/1) review(0/1)
#
# Rules:
#   done          iff court.json status == "done" (manual; nothing here ever writes it)
#   up for review iff rules.md is present and the typst engine passes (valid stamp)
#   in progress   iff anything is present (any flag character other than 0)
#   todo          otherwise
#   percent       = round(items present / 8 * 100), "done" forces 100. The 8 items: rules, exemplars >= 2,
#                   samples >= 2, typst pass, latex pass, docx pass, overlay pdf, review file
#   engine cell   0 -> "—" (no template), 1 -> "built" (template and rendered PDF), 2 -> "pass" (valid stamp)
#
# Doc types (Typst only): a doc type is "complete" iff all five items are present: typst template, a sample
# (samples/INPUT-*.md), a typst render (samples/OUTPUT-*.pdf), an exemplar (exemplars/*.pdf) and an overlay
# (samples/OVERLAY-*.pdf). "Gates" is pass iff tools/check.sh left a valid typst stamp; it is shown, not required.

import Base

type Row is Data:
  Row{alias: String, group: String, level: String, name: String, path: String, st: U32, pct: U32, ec: List<&2, Char>, it: List<&2, Char>}

type Agg is Data:
  Agg{n: U32, todo: U32, prog: U32, rev: U32, done: U32, sum: U32, tp: U32, lp: U32, dp: U32}

type Grp is Data:
  Grp{name: String, agg: Agg}

# one doc type: bits = template, sample, render, exemplar, overlay, gates (0/1 each)
type DRow is Data:
  DRow{alias: String, group: String, dt: String, path: String, ns: Char, ne: Char, bs: List<&2, U32>}

# n doc types; t s r e o = items present; c complete; g gates pass
type DAgg is Data:
  DAgg{n: U32, t: U32, s: U32, r: U32, e: U32, o: U32, c: U32, g: U32}

type DGrp is Data:
  DGrp{name: String, agg: DAgg}

# ---- file IO -------------------------------------------------------------

def fin(r: File & Result<&1, &1, U32 & String, String>) -> IO(String):
  (f, res) = r
  do IO<String>:
    File.close(f)
    IO.pass(String, res)

def slurp(path: String) -> IO(String):
  do IO<String>:
    f : File <- IO.try(File, File.open(path, "r"))
    r : File & Result<&1, &1, U32 & String, String> <- File.read(f, 16000000)
    fin(r)

# tail-recursive line splitter (String.lines recurses once per character and
# overflows the stack on a manifest of a few hundred lines)
def line(cs: List<&2, Char>) -> String:
  String.from_list(List.reverse(&2, Char, cs))

def lines_go(s: String, +cur: List<&2, Char>, +acc: List<&2, String>) -> List<&2, String>:
  match s:
    case SNil{}:
      List.reverse(&2, String, line(cur) <> acc)
    case SCon{+h, t}:
      +nl = Char.is_eq(h, '\n')
      lines_go(t, Bool.pick(List<&2, Char>, nl, Nil{}, h <> cur), Bool.pick(List<&2, String>, nl, line(cur) <> acc, acc))

# ---- per-court status ----------------------------------------------------

def isc(+c: Char, +k: Char) -> U32:
  Bool.to_u32(Char.is_eq(c, k))

def pick(b: Bool, x: U32, y: U32) -> U32:
  Bool.pick(U32, b, x, y)

# 1 for any character other than '0'
def nz(+c: Char) -> U32:
  (1 - isc(c, '0') : U32)

# 1 for a count character of at least 2 (not '0', not '1')
def ge2(+c: Char) -> U32:
  (1 - (isc(c, '0') + isc(c, '1')) : U32)

def bitc(+x: U32) -> Char:
  Bool.pick(Char, U32.is_eq(x, 1), '1', '0')

# cs = the eight flag chars. status: 0 todo, 1 in progress, 2 up for review, 3 done
def mk2(a: String, g: String, lv: String, nm: String, p: String, m: String, cs: List<&2, Char>) -> Row:
  match cs:
    case Con{+r, Con{+e, Con{+s, Con{+t, Con{+l, Con{+d, Con{+o, Con{+v, _}}}}}}}}:
      +x1 = isc(r, '1')
      +x2 = ge2(e)
      +x3 = ge2(s)
      +x4 = isc(t, '2')
      +x5 = isc(l, '2')
      +x6 = isc(d, '2')
      +x7 = isc(o, '1')
      +x8 = isc(v, '1')
      +n = (x1 + x2 + x3 + x4 + x5 + x6 + x7 + x8 : U32)
      +anyp = (nz(r) + nz(e) + nz(s) + nz(t) + nz(l) + nz(d) + nz(o) + nz(v) : U32)
      +review = (x1 * x4 : U32)
      +isdone = String.eq(m, "done")
      st = pick(isdone, 3, pick(U32.is_eq(review, 1), 2, pick(U32.is_gt(anyp, 0), 1, 0)))
      pct = pick(isdone, 100, U32.div((n * 100 + 4 : U32), 8))
      Row{a, g, lv, nm, p, st, pct, [t, l, d], [bitc(x1), bitc(x2), bitc(x3), bitc(x4), bitc(x5), bitc(x6), bitc(x7), bitc(x8)]}
    case _:
      Row{a, g, lv, nm, p, 0, 0, Nil{}, Nil{}}

def mk(a: String, g: String, lv: String, nm: String, p: String, m: String, f: String) -> Row:
  mk2(a, g, lv, nm, p, m, String.to_list(f))

def parse(fs: List<&2, String>) -> List<&2, Row>:
  match fs:
    case Con{a, Con{g, Con{lv, Con{nm, Con{p, Con{m, Con{f, _}}}}}}}:
      [mk(a, g, lv, nm, p, m, f)]
    case _:
      Nil{}

def rows(ls: List<&2, String>) -> List<&2, Row>:
  match ls:
    case Nil{}:
      Nil{}
    case Con{l, t}:
      List.append(&2, Row, parse(String.split(l, '|')), rows(t))

# ---- aggregation ---------------------------------------------------------

def zero() -> Agg:
  Agg{0, 0, 0, 0, 0, 0, 0, 0, 0}

def bump(a: Agg, +st: U32, +pct: U32, +tp: U32, +lp: U32, +dp: U32) -> Agg:
  match a:
    case Agg{n, todo, prog, rev, done, sum, t0, l0, d0}:
      Agg{(n + 1 : U32),
          (todo + pick(U32.is_eq(st, 0), 1, 0) : U32),
          (prog + pick(U32.is_eq(st, 1), 1, 0) : U32),
          (rev + pick(U32.is_eq(st, 2), 1, 0) : U32),
          (done + pick(U32.is_eq(st, 3), 1, 0) : U32),
          (sum + pct : U32),
          (t0 + tp : U32),
          (l0 + lp : U32),
          (d0 + dp : U32)}

def merge(a: Agg, b: Agg) -> Agg:
  match a b:
    case Agg{n, t, p, r, d, s, x, y, z} Agg{n2, t2, p2, r2, d2, s2, x2, y2, z2}:
      Agg{(n + n2 : U32), (t + t2 : U32), (p + p2 : U32), (r + r2 : U32), (d + d2 : U32), (s + s2 : U32), (x + x2 : U32), (y + y2 : U32), (z + z2 : U32)}

def put(same: Bool, g: String, st: U32, pct: U32, tp: U32, lp: U32, dp: U32, name: String, agg: Agg, rest: List<&2, Grp>) -> List<&2, Grp>:
  match same:
    case True{}:
      Grp{name, bump(agg, st, pct, tp, lp, dp)} <> rest
    case False{}:
      Grp{g, bump(zero(), st, pct, tp, lp, dp)} <> (Grp{name, agg} <> rest)

# groups are contiguous in the manifest; acc holds them newest-first
def push(+g: String, st: U32, pct: U32, tp: U32, lp: U32, dp: U32, acc: List<&2, Grp>) -> List<&2, Grp>:
  match acc:
    case Nil{}:
      [Grp{g, bump(zero(), st, pct, tp, lp, dp)}]
    case Con{Grp{+name, agg}, rest}:
      put(String.eq(name, g), g, st, pct, tp, lp, dp, name, agg, rest)

def groups(rs: List<&2, Row>, acc: List<&2, Grp>) -> List<&2, Grp>:
  match rs:
    case Nil{}:
      List.reverse(&2, Grp, acc)
    case Con{Row{a, g, lv, nm, p, st, pct, ec, it}, t}:
      match ec:
        case Con{+e0, Con{+e1, Con{+e2, _}}}:
          groups(t, push(g, st, pct, isc(e0, '2'), isc(e1, '2'), isc(e2, '2'), acc))
        case _:
          groups(t, push(g, st, pct, 0, 0, 0, acc))

def total(gs: List<&2, Grp>, acc: Agg) -> Agg:
  match gs:
    case Nil{}:
      acc
    case Con{Grp{name, agg}, t}:
      total(t, merge(acc, agg))

# ---- rendering -----------------------------------------------------------

# n/d as a percentage with one decimal (integer arithmetic)
def pct1(n: U32, +d: U32) -> String:
  +q = U32.div((n * 1000 : U32), pick(U32.is_eq(d, 0), 1, d))
  U32.show(U32.div(q, 10)) ++ "." ++ U32.show(U32.mod(q, 10))

def aggrow(label: String, a: Agg) -> String:
  match a:
    case Agg{+n, todo, prog, +rev, +done, +sum, tp, lp, dp}:
      "| " ++ label ++ " | " ++ U32.show(n) ++ " | " ++ U32.show(done) ++ " | " ++ U32.show(rev) ++ " | " ++ U32.show(prog) ++ " | " ++ U32.show(todo)
        ++ " | " ++ pct1(done, n) ++ "% | " ++ pct1(rev, n) ++ "% | " ++ U32.show(tp) ++ " | " ++ U32.show(lp) ++ " | " ++ U32.show(dp)
        ++ " | " ++ pct1(sum, (n * 100 : U32)) ++ "% |"

def grprow(g: Grp) -> String:
  match g:
    case Grp{name, agg}:
      aggrow(name, agg)

def smap(~A: Data, ~f: A -> String, xs: List<&2, A>) -> List<&2, String>:
  match xs:
    case Nil{}:
      Nil{}
    case Con{h, t}:
      f(h) <> smap(~A, ~f, t)

def summary(+gs: List<&2, Grp>) -> List<&2, String>:
  +t = total(gs, zero())
  "| Group | Courts | Done | Up for review | In progress | Todo | % done | % up for review | Typst pass | LaTeX pass | DOCX pass | Avg checklist % |" <>
  ("|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|" <>
   List.append(&2, String, smap(~Grp, ~(g => grprow(g)), gs), [aggrow("**Total**", t)]))

def stname(+st: U32) -> String:
  Bool.pick(String, U32.is_eq(st, 3), "done",
    Bool.pick(String, U32.is_eq(st, 2), "up for review",
      Bool.pick(String, U32.is_eq(st, 1), "in progress", "todo")))

def cell(+c: Char) -> String:
  Bool.pick(String, Char.is_eq(c, '2'), "pass", Bool.pick(String, Char.is_eq(c, '1'), "built", "—"))

def e3t(ec: List<&2, Char>) -> String:
  match ec:
    case Con{+t, Con{+l, Con{+d, _}}}:
      cell(t) ++ " | " ++ cell(l) ++ " | " ++ cell(d)
    case _:
      "— | — | —"

def e3r(ec: List<&2, Char>) -> String:
  match ec:
    case Con{+t, Con{+l, Con{+d, _}}}:
      cell(t) ++ "|" ++ cell(l) ++ "|" ++ cell(d)
    case _:
      "—|—|—"

def statusrow(r: Row) -> String:
  match r:
    case Row{a, g, lv, nm, p, st, pct, ec, it}:
      "| [" ++ nm ++ "](" ++ p ++ ") | " ++ a ++ " | " ++ stname(st) ++ " | " ++ e3t(ec) ++ " | " ++ U32.show(pct) ++ " |"

def status(rs: List<&2, Row>) -> List<&2, String>:
  "| Court | Alias | Status | Typst | LaTeX | DOCX | % |" <>
  ("|---|---|---|---|---|---|---:|" <> smap(~Row, ~(r => statusrow(r)), rs))

def rowline(r: Row) -> String:
  match r:
    case Row{a, g, lv, nm, p, st, pct, ec, it}:
      a ++ "|" ++ stname(st) ++ "|" ++ U32.show(pct) ++ "|" ++ e3r(ec) ++ "|" ++ String.from_list(it)

def rowsout(rs: List<&2, Row>) -> List<&2, String>:
  smap(~Row, ~(r => rowline(r)), rs)

# ---- doc types (Typst completeness) --------------------------------------

def dmk2(a: String, g: String, dt: String, p: String, cs: List<&2, Char>) -> List<&2, DRow>:
  match cs:
    case Con{+t, Con{+s, Con{+r, Con{+e, Con{+o, _}}}}}:
      [DRow{a, g, dt, p, s, e, [isc(t, '1'), nz(s), nz(r), nz(e), isc(o, '1'), isc(r, '2')]}]
    case _:
      Nil{}

def dparse(fs: List<&2, String>) -> List<&2, DRow>:
  match fs:
    case Con{a, Con{g, Con{dt, Con{p, Con{f, _}}}}}:
      dmk2(a, g, dt, p, String.to_list(f))
    case _:
      Nil{}

def drows(ls: List<&2, String>) -> List<&2, DRow>:
  match ls:
    case Nil{}:
      Nil{}
    case Con{l, t}:
      List.append(&2, DRow, dparse(String.split(l, '|')), drows(t))

def dzero() -> DAgg:
  DAgg{0, 0, 0, 0, 0, 0, 0, 0}

# 1 iff all five Typst items are present
def complete(bs: List<&2, U32>) -> U32:
  match bs:
    case Con{t, Con{s, Con{r, Con{e, Con{o, _}}}}}:
      (t * s * r * e * o : U32)
    case _:
      0

def dbump(a: DAgg, +bs: List<&2, U32>) -> DAgg:
  match a bs:
    case DAgg{n, t, s, r, e, o, c, g} Con{t1, Con{s1, Con{r1, Con{e1, Con{o1, Con{g1, _}}}}}}:
      DAgg{(n + 1 : U32), (t + t1 : U32), (s + s1 : U32), (r + r1 : U32), (e + e1 : U32), (o + o1 : U32), (c + complete(bs) : U32), (g + g1 : U32)}
    case a _:
      a

def dmerge(a: DAgg, b: DAgg) -> DAgg:
  match a b:
    case DAgg{n, t, s, r, e, o, c, g} DAgg{n2, t2, s2, r2, e2, o2, c2, g2}:
      DAgg{(n + n2 : U32), (t + t2 : U32), (s + s2 : U32), (r + r2 : U32), (e + e2 : U32), (o + o2 : U32), (c + c2 : U32), (g + g2 : U32)}

def dput(same: Bool, g: String, bs: List<&2, U32>, name: String, agg: DAgg, rest: List<&2, DGrp>) -> List<&2, DGrp>:
  match same:
    case True{}:
      DGrp{name, dbump(agg, bs)} <> rest
    case False{}:
      DGrp{g, dbump(dzero(), bs)} <> (DGrp{name, agg} <> rest)

def dpush(+g: String, bs: List<&2, U32>, acc: List<&2, DGrp>) -> List<&2, DGrp>:
  match acc:
    case Nil{}:
      [DGrp{g, dbump(dzero(), bs)}]
    case Con{DGrp{+name, agg}, rest}:
      dput(String.eq(name, g), g, bs, name, agg, rest)

def dgroups(rs: List<&2, DRow>, acc: List<&2, DGrp>) -> List<&2, DGrp>:
  match rs:
    case Nil{}:
      List.reverse(&2, DGrp, acc)
    case Con{DRow{a, g, dt, p, ns, ne, bs}, t}:
      dgroups(t, dpush(g, bs, acc))

def dtotal(gs: List<&2, DGrp>, acc: DAgg) -> DAgg:
  match gs:
    case Nil{}:
      acc
    case Con{DGrp{name, agg}, t}:
      dtotal(t, dmerge(acc, agg))

def daggrow(label: String, a: DAgg) -> String:
  match a:
    case DAgg{+n, t, s, r, e, o, +c, g}:
      "| " ++ label ++ " | " ++ U32.show(n) ++ " | " ++ U32.show(t) ++ " | " ++ U32.show(s) ++ " | " ++ U32.show(r)
        ++ " | " ++ U32.show(e) ++ " | " ++ U32.show(o) ++ " | " ++ U32.show(c) ++ " | " ++ pct1(c, n) ++ "% | " ++ U32.show(g) ++ " |"

def dgrprow(g: DGrp) -> String:
  match g:
    case DGrp{name, agg}:
      daggrow(name, agg)

def dsummary(+gs: List<&2, DGrp>) -> List<&2, String>:
  +t = dtotal(gs, dzero())
  "| Group | Doc types | Template | Sample | Render | Exemplar | Overlay | Typst complete | % complete | Gates pass |" <>
  ("|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|" <>
   List.append(&2, String, smap(~DGrp, ~(g => dgrprow(g)), gs), [daggrow("**Total**", t)]))

def yes(+b: U32) -> String:
  Bool.pick(String, U32.is_eq(b, 1), "yes", "—")

# a count cell: the digit, or "—" for none (9 means 9 or more)
def num(+c: Char) -> String:
  Bool.pick(String, Char.is_eq(c, '0'), "—", Bool.pick(String, Char.is_eq(c, '9'), "9+", String.from_list([c])))

def miss(+b: U32, w: String) -> List<&2, String>:
  Bool.pick(List<&2, String>, U32.is_eq(b, 1), Nil{}, [w])

def joinc(xs: List<&2, String>) -> String:
  match xs:
    case Nil{}:
      ""
    case Con{h, Nil{}}:
      h
    case Con{h, t}:
      h ++ ", " ++ joinc(t)

def verdict(bs: List<&2, U32>) -> String:
  match bs:
    case Con{+t, Con{+s, Con{+r, Con{+e, Con{+o, _}}}}}:
      Bool.pick(String, U32.is_eq((t * s * r * e * o : U32), 1), "**complete**",
        "missing " ++ joinc(List.append(&2, String, miss(t, "template"), List.append(&2, String, miss(s, "sample"),
          List.append(&2, String, miss(r, "render"), List.append(&2, String, miss(e, "exemplar"), miss(o, "overlay")))))))
    case _:
      "—"

def dcells(ns: Char, ne: Char, bs: List<&2, U32>) -> String:
  match bs:
    case Con{+t, Con{+s, Con{+r, Con{+e, Con{+o, Con{+g, _}}}}}}:
      yes(t) ++ " | " ++ num(ns) ++ " | " ++ yes(r) ++ " | " ++ num(ne) ++ " | " ++ yes(o) ++ " | " ++ Bool.pick(String, U32.is_eq(g, 1), "pass", "—")
    case _:
      "— | — | — | — | — | —"

def dtrow(r: DRow) -> String:
  match r:
    case DRow{a, g, dt, p, ns, +ne, +bs}:
      "| " ++ a ++ " | [" ++ dt ++ "](" ++ p ++ ") | " ++ dcells(ns, ne, bs) ++ " | " ++ verdict(bs) ++ " |"

def dtable(rs: List<&2, DRow>) -> List<&2, String>:
  "| Alias | Doc type | Template | Samples | Render | Exemplars | Overlay | Gates | Typst |" <>
  ("|---|---|---|---:|---|---:|---|---|---|" <> smap(~DRow, ~(r => dtrow(r)), rs))

# ---- main ----------------------------------------------------------------

# one print per line keeps every string short (long ++ chains overflow the stack)
def emit(ls: List<&2, String>) -> IO(Unit):
  match ls:
    case Nil{}:
      IO.pure(Unit, Unit{})
    case Con{h, t}:
      do IO<Unit>:
        IO.print(h)
        emit(t)

def report(+rs: List<&2, Row>, +ds: List<&2, DRow>) -> IO(Unit):
  do IO<Unit>:
    IO.print("=== summary")
    emit(summary(groups(rs, Nil{})))
    IO.print("=== status")
    emit(status(rs))
    IO.print("=== rows")
    emit(rowsout(rs))
    IO.print("=== dsummary")
    emit(dsummary(dgroups(ds, Nil{})))
    IO.print("=== doctypes")
    emit(dtable(ds))

def run2(m: String, d: String) -> IO(Unit):
  do IO<Unit>:
    text : String <- slurp(m)
    dtext : String <- slurp(d)
    report(rows(lines_go(text, Nil{}, Nil{})), drows(lines_go(dtext, Nil{}, Nil{})))

# args: [manifest [doctypes]]
def run(as: List<String>) -> IO(Unit):
  match as:
    case Con{m, Con{d, _}}:
      run2(m, d)
    case Con{m, Nil{}}:
      run2(m, "out/doctypes.txt")
    case Nil{}:
      run2("out/manifest.txt", "out/doctypes.txt")

def main() -> IO(Unit):
  do IO<Unit>:
    args : List<String> <- IO.args()
    run(args)
