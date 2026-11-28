//! A judge's facts laid over a court's layout (docs/JUDGES.md). The court's layout already sets what the local rule
//! requires; a judge's order can ask for more. Each fact is one of:
//!   satisfied   the court's layout already meets it: nothing changes
//!   applied     the layout changes (a footnote size, a word limit, the certificate's wording)
//!   note        the render cannot enforce it (a page limit): the filer checks
//!   CONFLICT    it would change what this layer does not change (the body's size, its face): the build stops
//!   UNVERIFIED  it would change the layout but its sentence was not found in the court's document: the build stops
//!               unless the filer passes --allow-unverified
//! Floors never lower a size the local rule set: a judge's "no less than 12 point" leaves a 14-point court at 14.
use super::{Fact, Profile};
use serde::Deserialize;
use serde_yaml::Value;

/// The papers a limit can be for.
pub const PAPERS: [&str; 3] = ["memorandum", "opposition", "reply"];

#[derive(Debug, Clone, Copy, PartialEq)]
pub enum Status {
    Satisfied,
    Applied,
    Note,
    Conflict,
    Unverified,
}

#[derive(Debug, Clone, PartialEq)]
pub struct Line {
    pub status: Status,
    pub text: String,
    /// The sentence of the order the line rests on.
    pub quote: Option<String>,
    /// The document the sentence is from: shown where the line changes the layout or stops the build, so the filer
    /// can read the sentence in its context.
    pub url: Option<String>,
}

impl std::fmt::Display for Line {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        let tag = match self.status {
            Status::Satisfied => "satisfied ",
            Status::Applied => "applied   ",
            Status::Note => "note      ",
            Status::Conflict => "CONFLICT  ",
            Status::Unverified => "UNVERIFIED",
        };
        write!(f, "{tag} {}", self.text)?;
        if let Some(q) = &self.quote {
            write!(f, "\n             \u{201C}{q}\u{201D}")?;
        }
        match (&self.url, self.status) {
            (Some(u), Status::Applied | Status::Conflict | Status::Unverified) => {
                write!(f, "\n             {u}")
            }
            _ => Ok(()),
        }
    }
}

/// How a court's layout states the basis of its word limit, and how it states a limit a judge's order set
/// (`<court>/judges/_court.yaml`, with the rule that gives both forms).
#[derive(Debug, Clone, Deserialize)]
pub struct Basis {
    /// The words of the layout's certificate that cite the local rule's limit.
    pub find: String,
    /// The words that cite a court order instead; `{word_limit_order_date}` is the filing's frontmatter field.
    pub court_order: String,
    pub rule: String,
}

/// A court's own settings for the judge layer.
#[derive(Debug, Clone, Default, Deserialize)]
pub struct CourtLayer {
    #[serde(default)]
    pub words_basis: Option<Basis>,
}

pub struct Ctx<'a> {
    /// `memorandum`, `opposition` or `reply`.
    pub paper: &'a str,
    /// The face the court's template sets.
    pub face: &'a str,
    /// The frontmatter's `word_limit_order_date`: the date of the order that set the limit, as the certificate cites it.
    pub order_date: Option<&'a str>,
    pub allow_unverified: bool,
    pub court: &'a CourtLayer,
}

pub struct Outcome {
    pub layout: Value,
    pub lines: Vec<Line>,
}

impl Outcome {
    /// Whether a line stops the build.
    pub fn blocked(&self) -> bool {
        self.lines
            .iter()
            .any(|l| matches!(l.status, Status::Conflict | Status::Unverified))
    }
}

/// A paper with its article ("an opposition").
fn a(paper: &str) -> String {
    format!(
        "{} {paper}",
        if paper.starts_with(['a', 'e', 'i', 'o', 'u']) {
            "an"
        } else {
            "a"
        }
    )
}

fn pts(x: f64) -> String {
    crate::enginegen::gen::fmt(x)
}

fn num(f: &Fact) -> Option<f64> {
    f.value.as_f64()
}

fn get(l: &Value, path: &[&str]) -> Option<f64> {
    path.iter()
        .try_fold(l, |v, k| v.get(k))
        .and_then(Value::as_f64)
}

fn set(l: &mut Value, path: &[&str], v: Value) {
    let mut cur = l;
    for (i, k) in path.iter().enumerate() {
        let Some(m) = cur.as_mapping_mut() else {
            return;
        };
        if i + 1 == path.len() {
            m.insert(Value::from(*k), v);
            return;
        }
        cur = m
            .entry(Value::from(*k))
            .or_insert_with(|| Value::Mapping(Default::default()));
    }
}

/// Where `needle` stands in `s`, letters compared without their case (ASCII case, so byte offsets hold).
fn find_ci(s: &str, needle: &str, from: usize) -> Option<usize> {
    if needle.is_empty() {
        return None;
    }
    let (h, n) = (s.as_bytes(), needle.as_bytes());
    (from..=h.len().saturating_sub(n.len()))
        .find(|&i| h.len() >= n.len() && h[i..i + n.len()].eq_ignore_ascii_case(n))
}

/// Every string of the layout with `find` (matched as `mentions` matches it) replaced by `to`; the number of
/// replacements.
fn replace_text(v: &mut Value, find: &str, to: &str) -> usize {
    match v {
        Value::String(s) => {
            let mut out = String::new();
            let (mut from, mut n) = (0, 0);
            while let Some(i) = find_ci(s, find, from) {
                out.push_str(&s[from..i]);
                out.push_str(to);
                from = i + find.len();
                n += 1;
            }
            if n > 0 {
                out.push_str(&s[from..]);
                *s = out;
            }
            n
        }
        Value::Sequence(xs) => xs.iter_mut().map(|x| replace_text(x, find, to)).sum(),
        Value::Mapping(m) => m.iter_mut().map(|(_, x)| replace_text(x, find, to)).sum(),
        _ => 0,
    }
}

/// Whether a string of the layout holds `needle`, case aside.
fn mentions(v: &Value, needle: &str) -> bool {
    match v {
        Value::String(s) => find_ci(s, needle, 0).is_some(),
        Value::Sequence(xs) => xs.iter().any(|x| mentions(x, needle)),
        Value::Mapping(m) => m.iter().any(|(_, x)| mentions(x, needle)),
        _ => false,
    }
}

/// A footnote's single-spaced line: 1.15 times its size, to a twentieth of a point (Word's unit).
fn note_pitch(size: f64) -> f64 {
    (size * 1.15 * 20.0).round() / 20.0
}

struct Run<'a> {
    layout: Value,
    lines: Vec<Line>,
    ctx: &'a Ctx<'a>,
}

impl Run<'_> {
    fn say(&mut self, status: Status, f: &Fact, text: String) {
        let unverified = if f.verified {
            ""
        } else {
            " [sentence not verified in the court's document]"
        };
        self.lines.push(Line {
            status,
            text: format!("{text}{unverified}"),
            quote: Some(f.quote.clone()),
            url: f.url.clone(),
        });
    }

    /// Whether a change the fact asks for may be made: an unverified fact stops unless allowed.
    fn may_change(&mut self, f: &Fact, what: &str) -> bool {
        if f.verified || self.ctx.allow_unverified {
            return true;
        }
        self.unverified(f, what);
        false
    }

    fn unverified(&mut self, f: &Fact, what: &str) {
        self.lines.push(Line {
            status: Status::Unverified,
            quote: Some(f.quote.clone()),
            url: f.url.clone(),
            text: format!(
                "{what}: the sentence was not found in the court's document; read the order{} and pass --allow-unverified",
                if f.url.is_some() { " at the URL below" } else { "" }
            ),
        });
    }

    /// Every footnote fact of the profile, together: each is a size the footnotes must be (`same_as_body`,
    /// `exact_pt`) or a floor (`min_pt`, `max_smaller_pt`). The footnotes take the one exact size, else the highest
    /// floor (never lower than the court's); sizes that cannot all hold are a conflict. One line a fact.
    fn footnotes(&mut self, p: &Profile) {
        let body = get(&self.layout, &["size"]).unwrap_or(12.0);
        let now = get(&self.layout, &["footnote", "size"]).unwrap_or(body);
        // (fact, exact size or floor, is it exact, why)
        let mut rules: Vec<(&Fact, f64, bool, String)> = Vec::new();
        if let Some(f) = p.fact("footnote.same_as_body") {
            rules.push((f, body, true, "the judge: the body's size".into()));
        }
        if let Some((f, n)) = p
            .fact("footnote.exact_pt")
            .and_then(|f| num(f).map(|n| (f, n)))
        {
            rules.push((f, n, true, "the judge: exactly that".into()));
        }
        if let Some((f, n)) = p
            .fact("footnote.min_pt")
            .and_then(|f| num(f).map(|n| (f, n)))
        {
            rules.push((
                f,
                n,
                false,
                format!("the judge: no less than {} pt", pts(n)),
            ));
        }
        if let Some((f, n)) = p
            .fact("footnote.max_smaller_pt")
            .and_then(|f| num(f).map(|n| (f, n)))
        {
            rules.push((
                f,
                body - n,
                false,
                format!("the judge: no more than {} pt under the body's", pts(n)),
            ));
        }
        if rules.is_empty() {
            return;
        }
        let mut exacts: Vec<f64> = rules.iter().filter(|r| r.2).map(|r| r.1).collect();
        exacts.dedup();
        let floor = rules
            .iter()
            .filter(|r| !r.2)
            .map(|r| r.1)
            .fold(f64::MIN, f64::max);
        let distinct = exacts.windows(2).any(|w| w[0] != w[1]);
        if distinct || exacts.first().is_some_and(|&e| e < floor) {
            for (f, n, exact, why) in &rules {
                let what = if *exact { "exactly" } else { "at least" };
                self.say(Status::Conflict, f, format!("footnotes {what} {} pt ({why}): the judge's footnote rules cannot all hold; read the order", pts(*n)));
            }
            return;
        }
        let to = exacts.first().copied().unwrap_or_else(|| now.max(floor));
        let holds_now = |n: f64, exact: bool| if exact { now == n } else { now >= n };
        if to == now {
            for (f, _, _, why) in &rules {
                self.say(
                    Status::Satisfied,
                    f,
                    format!("footnotes {} pt ({why})", pts(now)),
                );
            }
            return;
        }
        // the change rests on the facts the court's size does not already meet
        let what = |why: &str| {
            format!(
                "footnotes {} pt, not the court layout's {} pt ({why})",
                pts(to),
                pts(now)
            )
        };
        let blocked: Vec<usize> = (0..rules.len())
            .filter(|&i| {
                !holds_now(rules[i].1, rules[i].2)
                    && !rules[i].0.verified
                    && !self.ctx.allow_unverified
            })
            .collect();
        if !blocked.is_empty() {
            for (i, (f, _, _, why)) in rules.iter().enumerate() {
                if blocked.contains(&i) {
                    self.unverified(f, &what(why));
                } else {
                    self.say(
                        Status::Satisfied,
                        f,
                        format!("footnotes {} pt ({why})", pts(now)),
                    );
                }
            }
            return;
        }
        set(&mut self.layout, &["footnote", "size"], Value::from(to));
        let pitch = if to == body {
            Value::from("single")
        } else {
            Value::from(note_pitch(to))
        };
        set(&mut self.layout, &["footnote", "pitch"], pitch);
        for (f, n, exact, why) in &rules {
            if holds_now(*n, *exact) {
                self.say(
                    Status::Satisfied,
                    f,
                    format!("footnotes {} pt ({why})", pts(to)),
                );
            } else {
                self.say(Status::Applied, f, what(why));
            }
        }
    }

    fn body(&mut self, p: &Profile) {
        let size = get(&self.layout, &["size"]).unwrap_or(12.0);
        if let Some((f, n)) = p.fact("body.exact_pt").and_then(|f| num(f).map(|n| (f, n))) {
            if n == size {
                self.say(
                    Status::Satisfied,
                    f,
                    format!("body {} pt (the judge: exactly {} pt)", pts(size), pts(n)),
                );
            } else {
                self.say(Status::Conflict, f, format!("the judge orders a body of exactly {} pt and the court's layout sets {} pt: a body size is a new layout, not a judge's layer", pts(n), pts(size)));
            }
        }
        if let Some((f, n)) = p.fact("body.min_pt").and_then(|f| num(f).map(|n| (f, n))) {
            if size >= n {
                self.say(
                    Status::Satisfied,
                    f,
                    format!(
                        "body {} pt (the judge: no less than {} pt)",
                        pts(size),
                        pts(n)
                    ),
                );
            } else {
                self.say(Status::Conflict, f, format!("the judge orders a body of no less than {} pt and the court's layout sets {} pt: a body size is a new layout, not a judge's layer", pts(n), pts(size)));
            }
        }
        if let Some(f) = p.fact("body.face") {
            let want = f.value.as_str().unwrap_or("");
            if want.eq_ignore_ascii_case(self.ctx.face) {
                self.say(
                    Status::Satisfied,
                    f,
                    format!("face {} (the judge orders it)", self.ctx.face),
                );
            } else {
                self.say(
                    Status::Conflict,
                    f,
                    format!(
                        "the judge orders {want} and the court's template sets {}",
                        self.ctx.face
                    ),
                );
            }
        }
    }

    fn words(&mut self, p: &Profile) {
        let paper = self.ctx.paper;
        // a reply has its own limit or the court's; an opposition its own, else the memorandum's
        let fact = match paper {
            "reply" => p.fact("words.reply"),
            "opposition" => p
                .fact("words.opposition")
                .or_else(|| p.fact("words.memorandum")),
            _ => p.fact("words.memorandum"),
        };
        let Some((f, limit)) = fact.and_then(|f| num(f).map(|n| (f, n))) else {
            return;
        };
        if self.layout.get("words").is_none() {
            return self.say(Status::Note, f, format!("the judge limits {} to {} words; this court's layout counts no words, so the render does not enforce it", a(paper), pts(limit)));
        }
        let court = get(&self.layout, &["words", "limit"]);
        if court == Some(limit) {
            return self.say(
                Status::Satisfied,
                f,
                format!(
                    "{} of at most {} words (the court's limit and the judge's)",
                    a(paper),
                    pts(limit)
                ),
            );
        }
        let was = court.map_or("none".to_string(), pts);
        let what = format!(
            "{} of at most {} words (the court layout's limit: {was})",
            a(paper),
            pts(limit)
        );
        if !self.may_change(f, &what) {
            return;
        }
        set(
            &mut self.layout,
            &["words", "limit"],
            Value::from(limit as u64),
        );
        self.say(Status::Applied, f, what);
        // the certificate states which limit the count meets
        let Some(b) = self.ctx.court.words_basis.clone() else {
            return self.say(Status::Note, f, "the certificate's wording is the court layout's: check that it names the limit the judge set".into());
        };
        if !mentions(&self.layout, &b.find) {
            return self.say(Status::Note, f, format!("the certificate's wording is the court layout's (its words on the local rule's limit were not found; {})", b.rule));
        }
        match self.ctx.order_date {
            Some(_) => {
                if replace_text(&mut self.layout, &b.find, &b.court_order) == 0 {
                    return self.say(Status::Conflict, f, format!("the certificate's words on the local rule's limit could not be replaced with the court order's ({})", b.rule));
                }
                self.say(Status::Applied, f, format!("the certificate cites the court order that set the limit ({})", b.rule));
            }
            None if court.is_some_and(|c| limit > c) => self.say(Status::Conflict, f, format!("the judge's limit is over the local rule's, so the certificate must cite the order: set `word_limit_order_date` in the frontmatter ({})", b.rule)),
            None => self.say(Status::Note, f, format!("the certificate still cites the local rule's limit, which a count under the judge's lower limit also meets; set `word_limit_order_date` in the frontmatter to cite the judge's order instead ({})", b.rule)),
        }
    }

    fn rest(&mut self, p: &Profile) {
        for paper in PAPERS {
            if let Some((f, n)) = p
                .fact(&format!("pages.{paper}"))
                .and_then(|f| num(f).map(|n| (f, n)))
            {
                if paper == self.ctx.paper
                    || (paper == "memorandum"
                        && self.ctx.paper == "opposition"
                        && p.fact("pages.opposition").is_none())
                {
                    self.say(Status::Note, f, format!("the judge limits {} to {} pages: the render does not count them, so count the pages the limit covers", a(self.ctx.paper), pts(n)));
                }
            }
        }
        if let Some(f) = p.fact("certificate.required") {
            if mentions(&self.layout, "certificate of compliance") {
                self.say(
                    Status::Satisfied,
                    f,
                    "a certificate of compliance (the court's layout sets one)".into(),
                );
            } else {
                self.say(Status::Note, f, "the judge orders a certificate of compliance and the court's layout sets none: add it".into());
            }
        }
    }
}

/// The court's resolved `layout` under the judge's facts, for one paper.
pub fn apply(layout: &Value, p: &Profile, ctx: &Ctx) -> Outcome {
    let mut r = Run {
        layout: layout.clone(),
        lines: Vec::new(),
        ctx,
    };
    r.body(p);
    r.footnotes(p);
    r.words(p);
    r.rest(p);
    if r.lines.is_empty() {
        r.lines.push(Line {
            status: Status::Note,
            text:
                "the feed states no type size or length for this judge: the court's layout stands"
                    .into(),
            quote: None,
            url: None,
        });
    }
    Outcome {
        layout: r.layout,
        lines: r.lines,
    }
}

#[cfg(test)]
mod tests {
    use super::super::{Judge, Source};
    use super::*;

    fn y(s: &str) -> Value {
        serde_yaml::from_str(s).unwrap()
    }

    fn profile(facts: &[(&str, Value, bool)]) -> Profile {
        Profile {
            judge: Judge {
                slug: "doe-jane".into(),
                name: "Jane Doe".into(),
                title: String::new(),
                court: "cacd".into(),
            },
            source: Source {
                provider: "p".into(),
                page: "p".into(),
                feed: "f".into(),
                last_verified: None,
                court_page: None,
            },
            facts: facts
                .iter()
                .map(|(id, v, verified)| Fact {
                    id: id.to_string(),
                    value: v.clone(),
                    quote: "q".into(),
                    field: "f".into(),
                    url: Some("https://c/x.pdf".into()),
                    verified: *verified,
                    pdf_sha256: None,
                    matched: None,
                })
                .collect(),
            checklist: vec![],
            review: vec![],
        }
    }

    const LAYOUT: &str = "size: 14\nfootnote: {size: 14, pitch: single, gap: 7}\nwords: {limit: 7000, given: word_count}\nafter_tail:\n  - {text: CERTIFICATE OF COMPLIANCE}\n  - {text: \"this brief contains {xd.words} words, which complies with the word limit of L.R. 11-6.1.\"}\n";

    fn court() -> CourtLayer {
        CourtLayer {
            words_basis: Some(Basis {
                find: "complies with the word limit of L.R. 11-6.1.".into(),
                court_order:
                    "complies with the word limit set by court order dated {word_limit_order_date}."
                        .into(),
                rule: "L.R. 11-6.2".into(),
            }),
        }
    }

    fn run(p: &Profile, paper: &str, date: Option<&str>, allow: bool) -> Outcome {
        let c = court();
        apply(
            &y(LAYOUT),
            p,
            &Ctx {
                paper,
                face: "Times New Roman",
                order_date: date,
                allow_unverified: allow,
                court: &c,
            },
        )
    }

    fn statuses(o: &Outcome) -> Vec<Status> {
        o.lines.iter().map(|l| l.status).collect()
    }

    #[test]
    fn what_the_court_already_sets_changes_nothing() {
        let p = profile(&[
            ("body.min_pt", Value::from(14.0), true),
            ("footnote.same_as_body", Value::from(true), true),
            ("words.memorandum", Value::from(7000.0), true),
            ("words.reply", Value::from(4200.0), true),
            ("certificate.required", Value::from(true), true),
        ]);
        let o = run(&p, "memorandum", None, false);
        assert_eq!(statuses(&o), [Status::Satisfied; 4]);
        assert_eq!(o.layout, y(LAYOUT));
        assert!(!o.blocked());
        // an opposition takes the memorandum's limit
        assert_eq!(
            statuses(&run(&p, "opposition", None, false)),
            [Status::Satisfied; 4]
        );
    }

    #[test]
    fn a_reply_takes_the_judges_lower_limit_and_the_certificate_follows_the_date() {
        let p = profile(&[("words.reply", Value::from(4200.0), true)]);
        let o = run(&p, "reply", None, false);
        assert_eq!(statuses(&o), [Status::Applied, Status::Note]);
        assert_eq!(get(&o.layout, &["words", "limit"]), Some(4200.0));
        assert!(mentions(&o.layout, "word limit of l.r. 11-6.1"));
        let o = run(&p, "reply", Some("March 3, 2026"), false);
        assert_eq!(statuses(&o), [Status::Applied, Status::Applied]);
        assert!(mentions(
            &o.layout,
            "set by court order dated {word_limit_order_date}."
        ));
        assert!(!mentions(&o.layout, "word limit of l.r. 11-6.1"));
        // a limit over the local rule's needs the order's date
        let p = profile(&[("words.memorandum", Value::from(9000.0), true)]);
        let o = run(&p, "memorandum", None, false);
        assert_eq!(statuses(&o), [Status::Applied, Status::Conflict]);
        assert!(o.blocked());
    }

    #[test]
    fn footnotes_change_and_floors_never_lower() {
        let o = run(
            &profile(&[("footnote.exact_pt", Value::from(12.0), true)]),
            "memorandum",
            None,
            false,
        );
        assert_eq!(statuses(&o), [Status::Applied]);
        assert_eq!(get(&o.layout, &["footnote", "size"]), Some(12.0));
        assert_eq!(get(&o.layout, &["footnote", "pitch"]), Some(13.8));
        let o = run(
            &profile(&[
                ("body.min_pt", Value::from(12.0), true),
                ("footnote.min_pt", Value::from(10.0), true),
            ]),
            "memorandum",
            None,
            false,
        );
        assert_eq!(statuses(&o), [Status::Satisfied, Status::Satisfied]);
        assert_eq!(o.layout, y(LAYOUT));
        // no more than two points under the body's: 14 already is
        let o = run(
            &profile(&[("footnote.max_smaller_pt", Value::from(2.0), true)]),
            "memorandum",
            None,
            false,
        );
        assert_eq!(statuses(&o), [Status::Satisfied]);
    }

    #[test]
    fn a_body_size_or_face_the_layout_does_not_set_stops_the_build() {
        let o = run(
            &profile(&[("body.exact_pt", Value::from(12.0), true)]),
            "memorandum",
            None,
            false,
        );
        assert_eq!(statuses(&o), [Status::Conflict]);
        let o = run(
            &profile(&[("body.min_pt", Value::from(15.0), true)]),
            "memorandum",
            None,
            false,
        );
        assert_eq!(statuses(&o), [Status::Conflict]);
        let o = run(
            &profile(&[("body.face", Value::from("Courier New"), true)]),
            "memorandum",
            None,
            false,
        );
        assert_eq!(statuses(&o), [Status::Conflict]);
        assert_eq!(o.layout, y(LAYOUT));
    }

    #[test]
    fn an_unverified_fact_changes_nothing_unless_allowed() {
        let p = profile(&[
            ("footnote.exact_pt", Value::from(12.0), false),
            ("body.min_pt", Value::from(14.0), false),
        ]);
        let o = run(&p, "memorandum", None, false);
        assert_eq!(statuses(&o), [Status::Satisfied, Status::Unverified]);
        assert!(o.blocked());
        assert_eq!(o.layout, y(LAYOUT));
        let o = run(&p, "memorandum", None, true);
        assert_eq!(statuses(&o), [Status::Satisfied, Status::Applied]);
        assert!(!o.blocked());
    }

    #[test]
    fn page_limits_and_layouts_without_a_count_are_notes() {
        let p = profile(&[
            ("pages.memorandum", Value::from(25.0), true),
            ("words.reply", Value::from(4200.0), true),
        ]);
        let c = CourtLayer::default();
        let o = apply(
            &y("size: 12\n"),
            &p,
            &Ctx {
                paper: "reply",
                face: "Times New Roman",
                order_date: None,
                allow_unverified: false,
                court: &c,
            },
        );
        assert_eq!(statuses(&o), [Status::Note]);
        let o = apply(
            &y("size: 12\n"),
            &p,
            &Ctx {
                paper: "opposition",
                face: "Times New Roman",
                order_date: None,
                allow_unverified: false,
                court: &c,
            },
        );
        assert_eq!(statuses(&o), [Status::Note]);
        assert!(o.lines[0].text.contains("25 pages"));
    }

    #[test]
    fn a_line_that_changes_or_stops_shows_where_its_sentence_is() {
        let p = profile(&[
            ("words.reply", Value::from(4200.0), true),
            ("body.exact_pt", Value::from(12.0), true),
        ]);
        let o = run(&p, "reply", None, false);
        let shown: Vec<String> = o.lines.iter().map(|l| l.to_string()).collect();
        // CONFLICT (body), applied (words), note (certificate)
        assert_eq!(
            statuses(&o),
            [Status::Conflict, Status::Applied, Status::Note]
        );
        assert!(shown[0].contains("https://c/x.pdf"), "{}", shown[0]);
        assert!(shown[1].contains("https://c/x.pdf"), "{}", shown[1]);
        assert!(!shown[2].contains("https://c/x.pdf"), "{}", shown[2]);
        let o = run(
            &profile(&[("words.reply", Value::from(4200.0), false)]),
            "reply",
            None,
            false,
        );
        assert_eq!(statuses(&o), [Status::Unverified]);
        assert!(o.lines[0].to_string().contains("https://c/x.pdf"));
    }

    #[test]
    fn every_footnote_fact_is_weighed_and_rules_that_cannot_all_hold_conflict() {
        // a floor and an exact size that agree: the exact size, one line each
        let p = profile(&[
            ("footnote.exact_pt", Value::from(12.0), true),
            ("footnote.min_pt", Value::from(10.0), true),
        ]);
        let o = run(&p, "memorandum", None, false);
        assert_eq!(statuses(&o), [Status::Applied, Status::Satisfied]);
        assert_eq!(get(&o.layout, &["footnote", "size"]), Some(12.0));
        // the body's size and a smaller exact size: no layout meets both
        let p = profile(&[
            ("footnote.same_as_body", Value::from(true), true),
            ("footnote.exact_pt", Value::from(12.0), true),
        ]);
        let o = run(&p, "memorandum", None, false);
        assert_eq!(statuses(&o), [Status::Conflict, Status::Conflict]);
        assert_eq!(o.layout, y(LAYOUT));
        // an exact size under a floor
        let p = profile(&[
            ("footnote.exact_pt", Value::from(10.0), true),
            ("footnote.min_pt", Value::from(12.0), true),
        ]);
        assert_eq!(
            statuses(&run(&p, "memorandum", None, false)),
            [Status::Conflict, Status::Conflict]
        );
        // two floors: the higher one, never lower than the court's
        let p = profile(&[
            ("footnote.min_pt", Value::from(12.0), true),
            ("footnote.max_smaller_pt", Value::from(1.0), true),
        ]);
        let o = run(&p, "memorandum", None, false);
        assert_eq!(statuses(&o), [Status::Satisfied, Status::Satisfied]);
        assert_eq!(o.layout, y(LAYOUT));
        // a change resting on an unverified fact stops; a fact the court already meets does not
        let p = profile(&[
            ("footnote.exact_pt", Value::from(12.0), false),
            ("footnote.min_pt", Value::from(10.0), true),
        ]);
        let o = run(&p, "memorandum", None, false);
        assert_eq!(statuses(&o), [Status::Unverified, Status::Satisfied]);
        assert_eq!(o.layout, y(LAYOUT));
    }

    #[test]
    fn the_certificate_is_matched_and_replaced_the_same_way() {
        let p = profile(&[("words.reply", Value::from(4200.0), true)]);
        let layout = y("size: 14\nwords: {limit: 7000}\nafter_tail:\n  - {text: \"this brief contains {xd.words} words, which Complies With The Word Limit Of L.R. 11-6.1.\"}\n");
        let c = court();
        let ctx = Ctx {
            paper: "reply",
            face: "Times New Roman",
            order_date: Some("March 3, 2026"),
            allow_unverified: false,
            court: &c,
        };
        let o = apply(&layout, &p, &ctx);
        assert_eq!(statuses(&o), [Status::Applied, Status::Applied]);
        assert!(mentions(&o.layout, "set by court order dated"));
        assert!(!mentions(&o.layout, "11-6.1"));
        // the words are not there: a note, and nothing claims to be applied
        let layout = y("size: 14\nwords: {limit: 7000}\nafter_tail:\n  - {text: \"complies with L.R. 11-6.1\"}\n");
        let o = apply(&layout, &p, &ctx);
        assert_eq!(statuses(&o), [Status::Applied, Status::Note]);
        assert!(!mentions(&o.layout, "court order"));
        let mut v = Value::from("A b A");
        assert_eq!(replace_text(&mut v, "a", "x"), 2);
        assert_eq!(v, Value::from("x b x"));
    }
}
