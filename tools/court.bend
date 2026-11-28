# court.bend: select a formbook court (and doc type) by query, and warn when its rules are stale (fb-595.103).
#
# Usage: bend tools/court.bend <query> [doctype] [--max-age DAYS] [--today YYYY-MM-DD] [--strict]
#   query      a court alias, a legacy alias, or a case-insensitive substring of the court's name or folder path
#   doctype    a doc-type folder under the court (motion-brief, opening-brief, ...)
#   --max-age  days after the rules' verified date before the warning (default 180)
#   --today    the date to measure from (default: `date +%F`)
#   --strict   a warning exits 1
# Reads data/courts.tsv (written by `fb tracker`); run from the repo root. Prints, tab-separated: alias, name,
# template folder (the court folder, or <court folder>/<doctype>), verified date. Exit 0 on a match, 1 on a
# warning under --strict, 2 on no match, an ambiguous query or bad arguments (candidates are listed on stderr).
import Base

type Court is Data:
  Court{alias: String, path: String, name: String, verified: String, doctypes: String, legacy: String}

type Opts is Data:
  Opts{query: String, doctype: String, max_age: U32, today: String, strict: Bool, bad: String}

# Small helpers
# -------------

def or_empty(m: Maybe<&2, String>) -> String:
  match m:
    case None{}:
      ""
    case Some{s}:
      s

def or_zero(m: Maybe<&2, U32>) -> U32:
  match m:
    case None{}:
      0
    case Some{n}:
      n

def has_item(xs: List<&2, String>, +x: String) -> Bool:
  match xs:
    case Nil{}:
      False{}
    case Con{h, t}:
      String.eq(h, x) || has_item(t, x)

# Parsing data/courts.tsv
# -----------------------

def field(+xs: List<&2, String>, n: Nat) -> String:
  or_empty(List.get(&2, String, xs, n))

def court_of(+xs: List<&2, String>) -> Court:
  Court{field(xs, 0n), field(xs, 1n), field(xs, 2n), field(xs, 3n), field(xs, 4n), field(xs, 5n)}

def is_row(+line: String) -> Bool:
  Bool.not(String.is_empty(line)) && Bool.not(String.starts_with(line, "#"))

def courts_of(lines: List<&2, String>) -> List<&2, Court>:
  match lines:
    case Nil{}:
      Nil{}
    case Con{+h, t}:
      +rest = courts_of(t)
      Bool.pick(List<&2, Court>, is_row(h), court_of(String.split(h, '\t')) <> rest, rest)

# Matching
# --------

def exact(+c: Court, +q: String) -> Bool:
  match c:
    case Court{+alias, path, name, verified, doctypes, +legacy}:
      String.eq(alias, q) || has_item(String.split(legacy, ','), q)

def loose(+c: Court, +q: String) -> Bool:
  match c:
    case Court{alias, +path, +name, verified, doctypes, legacy}:
      +lq = String.to_lower(q)
      String.contains(String.to_lower(name), lq) || String.contains(String.to_lower(path), lq)

# kind: True = exact alias or legacy alias, False = name or path substring
def pick(cs: List<&2, Court>, +q: String, +kind: Bool) -> List<&2, Court>:
  match cs:
    case Nil{}:
      Nil{}
    case Con{+h, t}:
      +rest = pick(t, q, kind)
      Bool.pick(List<&2, Court>, Bool.pick(Bool, kind, exact(h, q), loose(h, q)), h <> rest, rest)

def select(+cs: List<&2, Court>, +q: String) -> List<&2, Court>:
  +ex = pick(cs, q, True{})
  Bool.pick(List<&2, Court>, List.is_empty(&2, Court, ex), pick(cs, q, False{}), ex)

# Dates
# -----

def num(s: String) -> U32:
  or_zero(U32.read(s))

# days before month m (1..12) in a common year
def month_days(+m: U32) -> U32:
  or_zero(List.get(&2, U32, [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334], U32.to_nat((m - 1 : U32))))

# a day count for YYYY-MM-DD; only differences of two counts are used
def days(+s: String) -> U32:
  +y = num(String.take(s, 4n))
  +m = num(String.take(String.drop(s, 5n), 2n))
  +ly = Bool.pick(U32, (m <= 2 : U32), (y - 1 : U32), y)
  (365 * y + ly / 4 - ly / 100 + ly / 400 + month_days(m) + num(String.drop(s, 8n)) : U32)

def is_date(+s: String) -> Bool:
  Nat.is_eq(String.length(s), 10n) && (num(String.take(s, 4n)) > 0 : U32)

# Arguments
# ---------

# one token with no option pending
def step0(strict: Bool, max: Bool, today: Bool, +h: String, o: Opts) -> Nat & Opts:
  match strict max today o:
    case True{} _ _ Opts{query, doctype, max_age, day, s, bad}:
      (0n, Opts{query, doctype, max_age, day, True{}, bad})
    case False{} True{} _ o:
      (1n, o)
    case False{} False{} True{} o:
      (2n, o)
    case False{} False{} False{} Opts{+query, +doctype, max_age, day, s, bad}:
      +opt = String.starts_with(h, "--")
      +first = String.is_empty(query)
      +second = String.is_empty(doctype)
      (0n, Opts{
        Bool.pick(String, Bool.not(opt) && first, h, query),
        Bool.pick(String, Bool.not(opt) && Bool.not(first) && second, h, doctype),
        max_age, day, s,
        Bool.pick(String, opt, "unknown option " ++ h,
          Bool.pick(String, Bool.not(first) && Bool.not(second), "too many arguments: " ++ h, bad))})

# one token: pending 1 = the value of --max-age, 2 = the value of --today
def step(pending: Nat, +h: String, o: Opts) -> Nat & Opts:
  match pending o:
    case 0n o:
      step0(String.eq(h, "--strict"), String.eq(h, "--max-age"), String.eq(h, "--today"), h, o)
    case 1n Opts{query, doctype, max_age, day, s, bad}:
      +n = U32.read(h)
      (0n, Opts{query, doctype, or_zero(n), day, s,
        Bool.pick(String, Maybe.is_some(&2, U32, n), bad, "--max-age wants a number of days, not " ++ h)})
    case 2n+p Opts{query, doctype, max_age, day, s, bad}:
      (0n, Opts{query, doctype, max_age, h, s,
        Bool.pick(String, is_date(h), bad, "--today wants YYYY-MM-DD, not " ++ h)})

def step_pair(st: Nat & Opts, +h: String) -> Nat & Opts:
  match st:
    case (pending, o):
      step(pending, h, o)

def finish(st: Nat & Opts) -> Opts:
  match st:
    case (pending, Opts{query, doctype, max_age, day, s, bad}):
      Opts{query, doctype, max_age, day, s, Bool.pick(String, Nat.is_eq(pending, 0n), bad, "an option wants a value")}

def opts(args: List<String>, st: Nat & Opts) -> Opts:
  match args:
    case Nil{}:
      finish(st)
    case Con{h, t}:
      opts(t, step_pair(st, h))

# Output
# ------

def rows(cs: List<&2, Court>) -> String:
  match cs:
    case Nil{}:
      ""
    case Con{Court{alias, path, name, verified, doctypes, legacy}, t}:
      "  " ++ alias ++ "\t" ++ name ++ "\t" ++ path ++ "\n" ++ rows(t)

# the template folder, or why there is none
def folder2(empty: Bool, has: Bool, +c: Court, +dt: String) -> Result<&2, &2, String, String>:
  match empty has c:
    case True{} _ Court{alias, path, name, verified, doctypes, legacy}:
      Done{path}
    case False{} True{} Court{alias, path, name, verified, doctypes, legacy}:
      Done{path ++ "/" ++ dt}
    case False{} False{} Court{alias, path, name, verified, doctypes, legacy}:
      Fail{alias ++ " has no doc type " ++ dt ++ " (it has: " ++ doctypes ++ ")"}

def folder(+c: Court, +dt: String) -> Result<&2, &2, String, String>:
  match c:
    case Court{alias, path, name, verified, +doctypes, legacy}:
      folder2(String.is_empty(dt), has_item(String.split(doctypes, ','), dt), c, dt)

# the warning, empty when the rules are fresh
def warning(+c: Court, +today: String, +max: U32) -> String:
  match c:
    case Court{+alias, path, name, +verified, doctypes, legacy}:
      +age = (days(today) - days(verified) : U32)
      Bool.pick(String, is_date(verified),
        Bool.pick(String, (age > max : U32),
          "WARN: " ++ alias ++ " rules last verified " ++ verified ++ " (" ++ U32.show(age) ++
            " days ago, threshold " ++ U32.show(max) ++ "); re-check before filing",
          ""),
        "WARN: " ++ alias ++ " has no verified date in its rules.md; verify the rules before filing")

def emit(r: Result<&2, &2, String, String>, +c: Court, +o: Opts) -> IO(Unit):
  match r c o:
    case Fail{e} _ _:
      IO.die(Unit, 2, e)
    case Done{dir} Court{alias, path, name, verified, doctypes, legacy} Opts{query, doctype, max_age, day, strict, bad}:
      +w = warning(c, day, max_age)
      do IO<Unit>:
        IO.print(alias ++ "\t" ++ name ++ "\t" ++ dir ++ "\t" ++ verified)
        Bool.pick(IO(Unit), String.is_empty(w), IO.pure(Unit, Unit{}),
          IO.bind(Unit, Unit, IO.print_err(w), u => Bool.pick(IO(Unit), strict, IO.exit(1), IO.pure(Unit, Unit{}))))

def choose(cs: List<&2, Court>, +o: Opts) -> IO(Unit):
  match cs o:
    case Nil{} Opts{query, doctype, max_age, day, strict, bad}:
      IO.die(Unit, 2, "no court matches " ++ query ++ " (see data/courts.tsv)")
    case Con{+h, Nil{}} Opts{query, +doctype, max_age, day, strict, bad}:
      emit(folder(h, doctype), h, o)
    case Con{h, Con{h2, t}} Opts{query, doctype, max_age, day, strict, bad}:
      do IO<Unit>:
        IO.print_err(query ++ " matches more than one court; use an alias:")
        IO.write(rows(h <> h2 <> t))
        IO.exit(2)

# Reading
# -------

def close_with(r: File & Result<&1, &1, U32 & String, String>) -> IO(String):
  match r:
    case (f, res):
      IO.bind(Unit, String, File.close(f), u => IO.pass(String, res))

def read_all(path: String) -> IO(String):
  do IO<String>:
    f : File <- IO.try(File, File.open(path, "r"))
    r : File & Result<&1, &1, U32 & String, String> <- File.read(f, 16777216)
    text : String <- close_with(r)
    return text

def first_out(r: U32 & (String & String)) -> String:
  match r:
    case (code, (out, err)):
      String.trim(out)

def date_now() -> IO(String):
  do IO<String>:
    r : U32 & (String & String) <- IO.try(U32 & (String & String), Process.run("date", ["+%F"], "", 4096, 5000))
    return first_out(r)

def today_or(+t: String) -> IO(String):
  Bool.pick(IO(String), String.is_empty(t), date_now(), IO.pure(String, t))

def run(o: Opts) -> IO(Unit):
  match o:
    case Opts{+query, doctype, max_age, +day, strict, +bad}:
      Bool.pick(IO(Unit), Bool.not(String.is_empty(bad)), IO.die(Unit, 2, "court.bend: " ++ bad),
        Bool.pick(IO(Unit), String.is_empty(query),
          IO.die(Unit, 2, "usage: bend tools/court.bend <query> [doctype] [--max-age DAYS] [--today YYYY-MM-DD] [--strict]"),
          do IO<Unit>:
            d : String <- today_or(day)
            text : String <- read_all("data/courts.tsv")
            choose(select(courts_of(String.lines(text)), query), Opts{query, doctype, max_age, d, strict, bad})))

def main() -> IO(Unit):
  do IO<Unit>:
    args : List<String> <- IO.args()
    run(opts(List.tail(&1, String, args), (0n, Opts{"", "", 180, "", False{}, ""})))
