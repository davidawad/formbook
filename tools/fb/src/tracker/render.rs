//! Aggregation per group and the markdown tables, as tools/tracker.bend prints them.
//!
//! Counters are u32 with wrapping arithmetic (Bend's U32 is a 32-bit word). Groups are runs of
//! equal group names in input order: a name that reappears later opens a second group.

use super::parse::{complete, Court, DocType, Status};

/// Per-group counts of courts.
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub struct Agg {
    pub n: u32,
    pub todo: u32,
    pub prog: u32,
    pub rev: u32,
    pub done: u32,
    pub sum: u32,
    pub tp: u32,
    pub lp: u32,
    pub dp: u32,
}

/// Per-group counts of doc types: items present, complete, gates pass.
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub struct DAgg {
    pub n: u32,
    pub items: [u32; 4],
    pub complete: u32,
    pub gates: u32,
}

fn add(a: u32, b: u32) -> u32 {
    a.wrapping_add(b)
}

fn pass(c: char) -> u32 {
    u32::from(c == '2')
}

impl Agg {
    pub fn bump(self, c: &Court) -> Agg {
        let [tp, lp, dp] = c.engines.map_or([0; 3], |e| e.map(pass));
        let isst = |s: Status| u32::from(c.status == s);
        Agg {
            n: add(self.n, 1),
            todo: add(self.todo, isst(Status::Todo)),
            prog: add(self.prog, isst(Status::InProgress)),
            rev: add(self.rev, isst(Status::Review)),
            done: add(self.done, isst(Status::Done)),
            sum: add(self.sum, c.pct),
            tp: add(self.tp, tp),
            lp: add(self.lp, lp),
            dp: add(self.dp, dp),
        }
    }

    pub fn merge(self, b: Agg) -> Agg {
        Agg {
            n: add(self.n, b.n),
            todo: add(self.todo, b.todo),
            prog: add(self.prog, b.prog),
            rev: add(self.rev, b.rev),
            done: add(self.done, b.done),
            sum: add(self.sum, b.sum),
            tp: add(self.tp, b.tp),
            lp: add(self.lp, b.lp),
            dp: add(self.dp, b.dp),
        }
    }
}

impl DAgg {
    pub fn bump(self, d: &DocType) -> DAgg {
        DAgg {
            n: add(self.n, 1),
            items: std::array::from_fn(|i| add(self.items[i], d.bits[i])),
            complete: add(self.complete, complete(&d.bits)),
            gates: add(self.gates, d.bits[4]),
        }
    }

    pub fn merge(self, b: DAgg) -> DAgg {
        DAgg {
            n: add(self.n, b.n),
            items: std::array::from_fn(|i| add(self.items[i], b.items[i])),
            complete: add(self.complete, b.complete),
            gates: add(self.gates, b.gates),
        }
    }
}

/// Folds items into runs of equal group name, in input order.
pub fn groups<'a, T, A: Default + Copy>(
    xs: &'a [T],
    group: impl Fn(&'a T) -> &'a str,
    bump: impl Fn(A, &T) -> A,
) -> Vec<(&'a str, A)> {
    xs.iter().fold(Vec::new(), |mut acc: Vec<(&str, A)>, x| {
        let g = group(x);
        match acc.last_mut() {
            Some((name, a)) if *name == g => *a = bump(*a, x),
            _ => acc.push((g, bump(A::default(), x))),
        }
        acc
    })
}

/// `n / d` as a percentage with one decimal, truncated (integer arithmetic; d = 0 counts as 1).
pub fn pct1(n: u32, d: u32) -> String {
    let q = n.wrapping_mul(1000) / d.max(1);
    format!("{}.{}", q / 10, q % 10)
}

fn aggrow(label: &str, a: &Agg) -> String {
    format!(
        "| {label} | {} | {} | {} | {} | {} | {}% | {}% | {} | {} | {} | {}% |",
        a.n,
        a.done,
        a.rev,
        a.prog,
        a.todo,
        pct1(a.done, a.n),
        pct1(a.rev, a.n),
        a.tp,
        a.lp,
        a.dp,
        pct1(a.sum, a.n.wrapping_mul(100))
    )
}

fn daggrow(label: &str, a: &DAgg) -> String {
    let [t, s, r, e] = a.items;
    format!(
        "| {label} | {} | {t} | {s} | {r} | {e} | {} | {}% | {} |",
        a.n,
        a.complete,
        pct1(a.complete, a.n),
        a.gates
    )
}

/// Header, separator, one row per group, then the total.
fn table<A: Copy>(
    head: &str,
    sep: &str,
    gs: &[(&str, A)],
    total: A,
    row: impl Fn(&str, &A) -> String,
) -> Vec<String> {
    [head.to_string(), sep.to_string()]
        .into_iter()
        .chain(gs.iter().map(|(g, a)| row(g, a)))
        .chain([row("**Total**", &total)])
        .collect()
}

pub fn summary(cs: &[Court]) -> Vec<String> {
    let gs = groups(cs, |c| c.group.as_str(), Agg::bump);
    let total = gs.iter().fold(Agg::default(), |t, (_, a)| t.merge(*a));
    table(
        "| Group | Courts | Done | Up for review | In progress | Todo | % done | % up for review | Typst pass | LaTeX pass | DOCX pass | Avg checklist % |",
        "|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|",
        &gs,
        total,
        aggrow,
    )
}

pub fn dsummary(ds: &[DocType]) -> Vec<String> {
    let gs = groups(ds, |d| d.group.as_str(), DAgg::bump);
    let total = gs.iter().fold(DAgg::default(), |t, (_, a)| t.merge(*a));
    table(
        "| Group | Doc types | Template | Sample | Render | Exemplar | Typst complete | % complete | Gates pass |",
        "|---|---:|---:|---:|---:|---:|---:|---:|---:|",
        &gs,
        total,
        daggrow,
    )
}

/// Engine cell: '2' pass, '1' built, anything else "—".
pub fn cell(c: char) -> &'static str {
    match c {
        '2' => "pass",
        '1' => "built",
        _ => "—",
    }
}

fn engines(c: &Court, sep: &str) -> String {
    let [t, l, d] = c.engines.map_or(["—"; 3], |e| e.map(cell));
    [t, l, d].join(sep)
}

fn with_head(head: &str, sep: &str, rows: impl Iterator<Item = String>) -> Vec<String> {
    [head.to_string(), sep.to_string()]
        .into_iter()
        .chain(rows)
        .collect()
}

pub fn status(cs: &[Court]) -> Vec<String> {
    let row = |c: &Court| {
        format!(
            "| [{}]({}) | {} | {} | {} | {} |",
            c.name,
            c.path,
            c.alias,
            c.status.name(),
            engines(c, " | "),
            c.pct
        )
    };
    with_head(
        "| Court | Alias | Status | Typst | LaTeX | DOCX | % |",
        "|---|---|---|---|---|---|---:|",
        cs.iter().map(row),
    )
}

pub fn rows(cs: &[Court]) -> Vec<String> {
    cs.iter()
        .map(|c| {
            format!(
                "{}|{}|{}|{}|{}",
                c.alias,
                c.status.name(),
                c.pct,
                engines(c, "|"),
                c.items
            )
        })
        .collect()
}

fn yes(b: u32) -> &'static str {
    if b == 1 {
        "yes"
    } else {
        "—"
    }
}

/// A count cell: the character itself, "—" for '0', "9+" for '9' (capped count).
pub fn num(c: char) -> String {
    match c {
        '0' => "—".into(),
        '9' => "9+".into(),
        _ => c.to_string(),
    }
}

/// "**complete**", or the missing items in checklist order.
pub fn verdict(bits: &[u32; 5]) -> String {
    const NAMES: [&str; 4] = ["template", "sample", "render", "exemplar"];
    if complete(bits) == 1 {
        return "**complete**".into();
    }
    let missing: Vec<&str> = NAMES
        .iter()
        .zip(bits)
        .filter(|(_, &b)| b != 1)
        .map(|(n, _)| *n)
        .collect();
    format!("missing {}", missing.join(", "))
}

fn dtrow(d: &DocType) -> String {
    let [t, _, r, _, g] = d.bits;
    format!(
        "| {} | [{}]({}) | {} | {} | {} | {} | {} | {} |",
        d.alias,
        d.doctype,
        d.path,
        yes(t),
        num(d.samples),
        yes(r),
        num(d.exemplars),
        if g == 1 { "pass" } else { "—" },
        verdict(&d.bits)
    )
}

pub fn doctypes(ds: &[DocType]) -> Vec<String> {
    with_head(
        "| Alias | Doc type | Template | Samples | Render | Exemplars | Gates | Typst |",
        "|---|---|---|---:|---|---:|---|---|",
        ds.iter().map(dtrow),
    )
}
