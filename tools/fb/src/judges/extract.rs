//! Typed formatting facts read out of the free text of a judge's standing order, as a judge feed quotes it
//! (docs/JUDGES.md). Pure text in, facts out: every fact carries the one sentence it was read from, so
//! `verify.rs` can find that sentence in the court's own PDF and a person can audit it.
//!
//! The reader is deliberately narrow. It takes a number only next to its unit (`14 point`, `7,000 words`,
//! `25 pages`) and only in a sentence that states a rule (`no less than`, `shall not exceed`, `only`); anything
//! else is left alone. A sentence that mentions a size or a limit and yields no fact is returned in `review`.
use serde_yaml::Value;

/// One fact: its id (`body.min_pt`, `footnote.exact_pt`, `words.reply`, ..), its value and the sentence stating it.
#[derive(Debug, Clone, PartialEq)]
pub struct Found {
    pub id: String,
    pub value: Value,
    pub quote: String,
}

fn found(id: &str, value: impl Into<Value>, quote: &str) -> Found {
    // a whole number is written as one (14, not 14.0)
    let value = match value.into() {
        Value::Number(n) if n.as_f64().is_some_and(|x| x.fract() == 0.0 && x >= 0.0) => {
            Value::from(n.as_f64().unwrap_or(0.0) as u64)
        }
        v => v,
    };
    Found {
        id: id.to_string(),
        value,
        quote: clean_quote(quote),
    }
}

/// A token of a sentence: a number (digits, or number words up to ninety-nine) or a lower-case word.
#[derive(Debug, Clone, PartialEq)]
enum Tok {
    Num(f64),
    Word(String),
}

fn word_number(w: &str) -> Option<f64> {
    const UNITS: [&str; 20] = [
        "zero",
        "one",
        "two",
        "three",
        "four",
        "five",
        "six",
        "seven",
        "eight",
        "nine",
        "ten",
        "eleven",
        "twelve",
        "thirteen",
        "fourteen",
        "fifteen",
        "sixteen",
        "seventeen",
        "eighteen",
        "nineteen",
    ];
    const TENS: [&str; 8] = [
        "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety",
    ];
    UNITS
        .iter()
        .position(|u| *u == w)
        .map(|i| i as f64)
        .or_else(|| {
            TENS.iter()
                .position(|t| *t == w)
                .map(|i| (i as f64 + 2.0) * 10.0)
        })
}

/// The tokens of `s`: lower case, punctuation as space, a comma inside digits dropped ("7,000"), number words read
/// ("twenty-five" is 25) and a number said twice ("fourteen (14)") kept once.
fn tokens(s: &str) -> Vec<Tok> {
    let chars: Vec<char> = s.to_lowercase().chars().collect();
    let mut flat = String::new();
    for (i, &c) in chars.iter().enumerate() {
        let digit = |j: usize| chars.get(j).is_some_and(|c| c.is_ascii_digit());
        if c.is_alphanumeric() || c == '\'' || c == '\u{2019}' {
            flat.push(c);
        } else if c == ',' && i > 0 && digit(i - 1) && digit(i + 1) {
            // "7,000"
        } else if c == '.' && i > 0 && digit(i - 1) && digit(i + 1) {
            flat.push('.');
        } else {
            flat.push(' ');
        }
    }
    let mut out: Vec<Tok> = Vec::new();
    for w in flat.split_whitespace() {
        let t = match w.parse::<f64>() {
            Ok(n) => Tok::Num(n),
            Err(_) => match word_number(w) {
                Some(n) => Tok::Num(n),
                None => Tok::Word(w.to_string()),
            },
        };
        match (out.last(), &t) {
            // "twenty five" is 25
            (Some(Tok::Num(a)), Tok::Num(b))
                if *a >= 20.0 && a % 10.0 == 0.0 && *a < 100.0 && *b < 10.0 && *b > 0.0 =>
            {
                let n = a + b;
                out.pop();
                out.push(Tok::Num(n));
            }
            // "fourteen (14)"
            (Some(Tok::Num(a)), Tok::Num(b)) if a == b => {}
            _ => out.push(t),
        }
    }
    out
}

fn is(t: Option<&Tok>, w: &str) -> bool {
    matches!(t, Some(Tok::Word(x)) if x == w)
}

fn has(ts: &[Tok], w: &str) -> bool {
    ts.iter().any(|t| matches!(t, Tok::Word(x) if x == w))
}

fn has_prefix(ts: &[Tok], p: &str) -> bool {
    ts.iter()
        .any(|t| matches!(t, Tok::Word(x) if x.starts_with(p)))
}

/// Where the words `seq` stand in a row in `ts`.
fn find_seq(ts: &[Tok], seq: &[&str]) -> Option<usize> {
    (0..ts.len().saturating_sub(seq.len() - 1))
        .find(|&i| seq.iter().enumerate().all(|(k, w)| is(ts.get(i + k), w)))
}

fn has_seq(ts: &[Tok], seq: &[&str]) -> bool {
    find_seq(ts, seq).is_some()
}

/// Words a period follows without ending a sentence: rule and reporter cites, case names, titles, addresses.
const ABBREVIATIONS: [&str; 78] = [
    "l.r", "fed", "r", "civ", "p", "no", "nos", "e.g", "i.e", "u.s", "cal", "v", "vs", "cf", "id",
    "see", "f", "supp", "cir", "inc", "co", "corp", "ltd", "app", "so", "mut", "auto", "ins",
    "cas", "bros", "mfg", "sys", "serv", "servs", "tech", "univ", "cty", "dist", "div", "c.d",
    "n.d", "s.d", "e.d", "w.d", "m.d", "d", "rev", "stat", "u.s.c", "c.f.r", "reg", "sec", "para",
    "ex", "exh", "dkt", "doc", "jr", "sr", "hon", "mr", "ms", "mrs", "dr", "st", "ave", "blvd",
    "ste", "tel", "et", "al", "seq", "ed", "op", "crim", "evid", "bankr", "proc",
];

/// The sentences of `text`: split at a period, question mark or line break followed by a capital, a quotation mark or
/// a digit, but not after an abbreviation ("L.R. 11-6.1", "Fed. R. Civ. P. 56") or a single letter ("SO III.C").
pub fn sentences(text: &str) -> Vec<String> {
    let mut out = Vec::new();
    for para in text.split('\n') {
        let chars: Vec<char> = para.chars().collect();
        let mut start = 0;
        let mut i = 0;
        while i < chars.len() {
            let c = chars[i];
            let ends = c == '.' || c == '?' || c == '!';
            // a closing quotation mark stays with its sentence
            let mut j = i + 1;
            while j < chars.len() && matches!(chars[j], '"' | '\u{201D}' | '\'' | '\u{2019}' | ')')
            {
                j += 1;
            }
            let spaced = chars.get(j).is_some_and(|c| c.is_whitespace());
            let mut k = j;
            while k < chars.len() && chars[k].is_whitespace() {
                k += 1;
            }
            let opens = chars.get(k).is_some_and(|c| {
                c.is_uppercase() || c.is_ascii_digit() || matches!(c, '"' | '\u{201C}' | '(')
            });
            if ends && spaced && opens {
                let before: String = chars[start..i].iter().collect();
                let last = before
                    .rsplit(|c: char| c.is_whitespace() || c == '(')
                    .next()
                    .unwrap_or("")
                    .trim_start_matches(['"', '\u{201C}'])
                    .to_lowercase();
                let abbreviation = c == '.'
                    && (ABBREVIATIONS.contains(&last.as_str())
                        // "Eng'g", "Cont'l", "Ass'n"
                        || last.contains(['\'', '\u{2019}'])
                        || (last.chars().count() == 1 && last.chars().all(char::is_alphabetic)));
                if !abbreviation {
                    out.push(chars[start..j].iter().collect::<String>());
                    start = k;
                    i = k;
                    continue;
                }
            }
            i += 1;
        }
        out.push(chars[start..].iter().collect::<String>());
    }
    out.into_iter()
        .map(|s| s.split_whitespace().collect::<Vec<_>>().join(" "))
        .filter(|s| !s.is_empty())
        .collect()
}

/// A sentence as the order states it: without the feed's label before the quotation (`SO III.C: "`) and without the
/// quotation marks around it.
pub fn clean_quote(s: &str) -> String {
    let mut t = s.trim();
    let open = |c: char| c == '"' || c == '\u{201C}';
    if let Some(i) = t.find(open) {
        let label = t[..i].trim_end();
        if i <= 80 && (label.is_empty() || label.ends_with(':')) {
            t = &t[i + t[i..].chars().next().map_or(1, char::len_utf8)..];
        }
    }
    t.trim()
        .trim_end_matches(['"', '\u{201D}'])
        .trim()
        .to_string()
}

/// Whether the words state a floor ("no less than", "at least", "or larger", "minimum").
fn floor(ts: &[Tok]) -> bool {
    has_seq(ts, &["no", "less", "than"])
        || has_seq(ts, &["not", "less", "than"])
        || has_seq(ts, &["no", "smaller", "than"])
        || has_seq(ts, &["not", "smaller", "than"])
        || has_seq(ts, &["at", "least"])
        || has_seq(ts, &["or", "larger"])
        || has_seq(ts, &["or", "greater"])
        || has(ts, "minimum")
}

/// Whether the words state an exact value ("only", "must be", "shall be").
fn exact(ts: &[Tok]) -> bool {
    has(ts, "only")
        || has_seq(ts, &["must", "be"])
        || has_seq(ts, &["shall", "be"])
        || has_seq(ts, &["is", "required"])
}

/// A type size in `ts`: a number of 8 to 18 before "point" or "pt" (not "12-point spacing", a gap), or right after a
/// floor's "than" or "least" in words about a size or a font.
fn type_size(ts: &[Tok]) -> Option<f64> {
    let sized = |n: f64| (8.0..=18.0).contains(&n);
    for (i, t) in ts.iter().enumerate() {
        let Tok::Num(n) = t else { continue };
        if !sized(*n) {
            continue;
        }
        let unit =
            is(ts.get(i + 1), "point") || is(ts.get(i + 1), "pt") || is(ts.get(i + 1), "points");
        if unit && !is(ts.get(i + 2), "spacing") {
            return Some(*n);
        }
        let after_floor = i > 0
            && (is(ts.get(i - 1), "than") || is(ts.get(i - 1), "least") || is(ts.get(i - 1), "of"));
        let about = has(ts, "size") || has(ts, "font") || has(ts, "typeface");
        if !unit && after_floor && about && floor(ts) {
            return Some(*n);
        }
    }
    None
}

/// The facts of a body clause: its size (a floor or an exact value) and a face the order mandates. `ordered`: the
/// sentence is an instruction ("Use 14-point font"), so a size it names is exact.
fn body_clause(
    ts: &[Tok],
    sentence_names_courier: bool,
    ordered: bool,
    quote: &str,
    out: &mut Vec<Found>,
) {
    // what is said of Courier (a monospaced alternative) is not the proportional body's rule
    let prop = match ts
        .iter()
        .position(|t| matches!(t, Tok::Word(w) if w == "courier" || w == "monospaced"))
    {
        Some(i) => &ts[..i],
        None => ts,
    };
    if let Some(n) = type_size(prop) {
        if floor(prop) {
            out.push(found("body.min_pt", n, quote));
        } else if exact(prop) || ordered {
            out.push(found("body.exact_pt", n, quote));
        }
    }
    let times = has_seq(ts, &["times", "new", "roman"]) || has_seq(ts, &["times", "roman"]);
    let mandated = has_seq(ts, &["must", "use"])
        || has_seq(ts, &["shall", "use"])
        || has_seq(ts, &["must", "be", "used"])
        || has_seq(ts, &["shall", "be", "used"])
        || has_seq(ts, &["use", "only"])
        || has_seq(ts, &["only", "use"]);
    if times && mandated && !sentence_names_courier {
        out.push(found("body.face", "Times New Roman", quote));
    }
}

/// The fact of a footnote clause: the body's size, a size of its own, or a size relative to the body's.
fn footnote_clause(ts: &[Tok], ordered: bool, quote: &str, out: &mut Vec<Found>) {
    // "no more than one size smaller than text size", "no less than two sizes smaller than text size"
    if has(ts, "smaller") && (has(ts, "text") || has(ts, "body")) {
        let k = ts.iter().enumerate().find_map(|(i, t)| match t {
            Tok::Num(n)
                if (1.0..=4.0).contains(n)
                    && (is(ts.get(i + 1), "size") || is(ts.get(i + 1), "sizes")) =>
            {
                Some(*n)
            }
            _ => None,
        });
        if let Some(k) = k {
            out.push(found("footnote.max_smaller_pt", k, quote));
        }
        return;
    }
    let same = (has(ts, "same") && has(ts, "size"))
        || has_seq(ts, &["apply", "to", "footnoted"])
        || has_seq(ts, &["apply", "to", "footnotes"]);
    if same {
        out.push(found("footnote.same_as_body", true, quote));
        return;
    }
    if let Some(n) = type_size(ts) {
        if floor(ts) {
            out.push(found("footnote.min_pt", n, quote));
        } else if exact(ts)
            || ordered
            || has_seq(ts, &["shall", "be", "in"])
            || has_seq(ts, &["must", "be", "in"])
        {
            out.push(found("footnote.exact_pt", n, quote));
        }
    }
}

/// The label a sentence opens with ("SO III.C:", "For MSJ:", "Discovery Motion Practice:"), and whether it narrows
/// what follows to one kind of motion or case: a limit said of summary judgment or of discovery motions is not the
/// judge's limit for every memorandum.
fn scope_label(s: &str) -> Option<bool> {
    let at = s.find(':')?;
    let label = &s[..at];
    if at > 60 || label.split_whitespace().count() > 8 {
        return None;
    }
    let ts = tokens(label);
    const NARROW: [&str; 14] = [
        "msj",
        "summary",
        "discovery",
        "limine",
        "expedited",
        "class",
        "daubert",
        "criminal",
        "patent",
        "habeas",
        "social",
        "markman",
        "erisa",
        "opt",
    ];
    Some(NARROW.iter().any(|w| has(&ts, w)) || has_seq(&ts, &["ex", "parte"]))
}

/// The sentences of `text` that state a general rule: those under a narrowing label (scope_label), to the end of
/// their line or the next label, are returned apart.
fn general(text: &str) -> (Vec<String>, Vec<String>) {
    let (mut keep, mut narrowed) = (Vec::new(), Vec::new());
    for line in text.split('\n') {
        let mut narrow = false;
        for s in sentences(line) {
            if let Some(n) = scope_label(&s) {
                narrow = n;
            }
            if narrow {
                narrowed.push(s);
            } else {
                keep.push(s);
            }
        }
    }
    (keep, narrowed)
}

/// The type facts of a judge's text on fonts and footnotes, and the sentences that name a size without yielding one.
pub fn fonts(text: &str) -> (Vec<Found>, Vec<String>) {
    let mut out = Vec::new();
    let mut review = Vec::new();
    for s in general(text).0 {
        let before = out.len();
        let all = tokens(&s);
        let courier = has(&all, "courier");
        // an instruction: "Use 14-point font in the body of the briefing and 11-point font for footnotes."
        let ordered = is(all.first(), "use");
        let sizes = all
            .iter()
            .enumerate()
            .filter(|(i, t)| matches!(t, Tok::Num(_)) && is(all.get(i + 1), "point"))
            .count();
        // one size for the body and one for the footnotes, joined by "and": two clauses
        let parts: Vec<&str> = if sizes == 2 && has_prefix(&all, "footnote") && !s.contains(';') {
            s.split(" and ").collect()
        } else {
            s.split(';').collect()
        };
        for clause in parts {
            let ts = tokens(clause);
            let with_notes = has_seq(&ts, &["including", "for", "footnotes"])
                || has_seq(&ts, &["including", "footnotes"])
                || has_seq(&ts, &["including", "in", "footnotes"]);
            if with_notes && type_size(&ts).is_some() {
                // "Use only 14-point Times New Roman font, including for footnotes."
                body_clause(&ts, courier, ordered, &s, &mut out);
                out.push(found("footnote.same_as_body", true, &s));
            } else if has_prefix(&ts, "footnote") {
                footnote_clause(&ts, ordered, &s, &mut out);
            } else {
                body_clause(&ts, courier, ordered, &s, &mut out);
            }
        }
        let names_size = all.iter().enumerate().any(|(i, t)| {
            matches!(t, Tok::Num(n) if (8.0..=18.0).contains(n))
                && (is(all.get(i + 1), "point") || is(all.get(i + 1), "pt"))
        });
        if out.len() == before && names_size {
            review.push(clean_quote(&s));
        }
    }
    (dedupe(out, &mut review), review)
}

const LIMIT_PHRASES: [&[&str]; 7] = [
    &["not", "exceed"],
    &["not", "to", "exceed"],
    &["no", "more", "than"],
    &["limited", "to"],
    &["no", "longer", "than"],
    &["maximum", "of"],
    &["not", "be", "longer", "than"],
];

/// Papers whose limits are never the memorandum's, the opposition's or the reply's.
const OTHER_PAPERS: [&str; 10] = [
    "supplemental",
    "joint",
    "stipulation",
    "statement",
    "introductory",
    "objection",
    "sur",
    "surreply",
    "amicus",
    "letter",
];

/// Papers that are not a motion's unless the sentence also names the memorandum ("no memorandum of points and
/// authorities, pretrial brief, trial brief, or posttrial brief").
const TRIAL_PAPERS: [&str; 7] = [
    "trial",
    "pretrial",
    "posttrial",
    "postrial",
    "exhibit",
    "declaration",
    "appendix",
];

/// The paper a limit's subject names: the first of reply, opposition and memorandum it names; else a brief or a
/// motion is the memorandum.
fn paper(subject: &[Tok]) -> Option<&'static str> {
    if OTHER_PAPERS.iter().any(|w| has_prefix(subject, w)) {
        return None;
    }
    if !has_prefix(subject, "memorand") && TRIAL_PAPERS.iter().any(|w| has_prefix(subject, w)) {
        return None;
    }
    for t in subject {
        let Tok::Word(w) = t else { continue };
        if w.starts_with("repl") {
            return Some("reply");
        } else if w.starts_with("opposi") {
            return Some("opposition");
        } else if w.starts_with("memorand") {
            return Some("memorandum");
        }
    }
    (has_prefix(subject, "brief") || has_prefix(subject, "motion")).then_some("memorandum")
}

/// The unit after the number at `i` ("words", "pages"), a describing word between them allowed ("25 substantive pages").
fn unit(ts: &[Tok], i: usize) -> Option<&'static str> {
    let at = |k: usize| match ts.get(k) {
        Some(Tok::Word(w)) if w == "words" || w == "word" => Some("words"),
        Some(Tok::Word(w)) if w == "pages" || w == "page" => Some("pages"),
        _ => None,
    };
    at(i + 1).or_else(|| {
        (is(ts.get(i + 1), "substantive") || is(ts.get(i + 1), "total"))
            .then(|| at(i + 2))
            .flatten()
    })
}

/// The length facts of a judge's text on page and word limits: `words.<paper>` and `pages.<paper>` for the papers
/// `memorandum`, `opposition` and `reply`, and `certificate.required` where a certificate of compliance is ordered.
pub fn lengths(text: &str) -> (Vec<Found>, Vec<String>) {
    let mut out = Vec::new();
    let mut review = Vec::new();
    let (keep, narrowed) = general(text);
    for s in narrowed {
        let ts = tokens(&s);
        if LIMIT_PHRASES.iter().any(|p| has_seq(&ts, p)) && (has(&ts, "words") || has(&ts, "pages"))
        {
            review.push(format!("(of one kind of motion) {}", clean_quote(&s)));
        }
    }
    for s in keep {
        let ts = tokens(&s);
        if has_seq(&ts, &["certificate", "of", "compliance"])
            && (has(&ts, "must") || has(&ts, "shall") || has(&ts, "required"))
        {
            out.push(found("certificate.required", true, &s));
        }
        // the limit phrases of the sentence, in order
        let mut marks: Vec<(usize, usize)> = Vec::new();
        for p in LIMIT_PHRASES {
            let mut from = 0;
            while let Some(i) = find_seq(&ts[from..], p) {
                marks.push((from + i, from + i + p.len()));
                from += i + p.len();
            }
        }
        marks.sort();
        marks.dedup_by(|b, a| b.0 < a.1);
        let by_hand = has(&ts, "handwritten") || has(&ts, "typewriter") || has(&ts, "typewritten");
        let before = out.len();
        for (n, &(at, end)) in marks.iter().enumerate() {
            let subject = &ts[if n == 0 { 0 } else { marks[n - 1].1 }..at];
            let until = marks.get(n + 1).map_or(ts.len(), |m| m.0);
            let Some(paper) = paper(subject) else {
                continue;
            };
            for i in end..until {
                let Some(Tok::Num(v)) = ts.get(i) else {
                    continue;
                };
                match unit(&ts, i) {
                    Some("words") if (500.0..=30000.0).contains(v) => {
                        out.push(found(&format!("words.{paper}"), *v, &s));
                    }
                    // a page limit in a sentence on handwritten or typewritten briefs is theirs
                    Some("pages") if !by_hand && (1.0..=150.0).contains(v) => {
                        out.push(found(&format!("pages.{paper}"), *v, &s));
                    }
                    _ => {}
                }
            }
        }
        // an instruction: "Limit any motion, response, brief, or memorandum to 6,250 words; limit any reply to 2,500 words."
        for i in 0..ts.len() {
            let noun = i > 0
                && matches!(ts.get(i - 1), Some(Tok::Word(w)) if ["page", "word", "the", "this", "that", "a", "length", "time"].contains(&w.as_str()));
            if !is(ts.get(i), "limit") || noun {
                continue;
            }
            let Some(to) = (i + 1..ts.len().min(i + 12))
                .find(|&j| is(ts.get(j), "to") && matches!(ts.get(j + 1), Some(Tok::Num(_))))
            else {
                continue;
            };
            let (Some(paper), Some(Tok::Num(v))) = (paper(&ts[i + 1..to]), ts.get(to + 1)) else {
                continue;
            };
            match unit(&ts, to + 1) {
                Some("words") if (500.0..=30000.0).contains(v) => {
                    out.push(found(&format!("words.{paper}"), *v, &s))
                }
                Some("pages") if !by_hand && (1.0..=150.0).contains(v) => {
                    out.push(found(&format!("pages.{paper}"), *v, &s))
                }
                _ => {}
            }
        }
        if out.len() == before
            && !marks.is_empty()
            && (has(&ts, "words") || has(&ts, "pages"))
            && !by_hand
        {
            review.push(clean_quote(&s));
        }
    }
    (dedupe(out, &mut review), review)
}

/// One fact an id: the same value stated twice is one fact; two values for one id are no fact at all, and both
/// sentences go to `review`.
fn dedupe(found: Vec<Found>, review: &mut Vec<String>) -> Vec<Found> {
    let mut out: Vec<Found> = Vec::new();
    let mut dropped: Vec<String> = Vec::new();
    for f in found {
        if dropped.contains(&f.id) {
            review.push(format!("{} (two values): {}", f.id, f.quote));
            continue;
        }
        match out.iter().position(|o| o.id == f.id) {
            None => out.push(f),
            Some(i) if out[i].value == f.value => {}
            Some(i) => {
                let old = out.remove(i);
                review.push(format!("{} (two values): {}", old.id, old.quote));
                review.push(format!("{} (two values): {}", f.id, f.quote));
                dropped.push(f.id);
            }
        }
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;

    fn ids(f: &[Found]) -> Vec<(String, Value)> {
        f.iter().map(|x| (x.id.clone(), x.value.clone())).collect()
    }

    fn v(id: &str, n: f64) -> (String, Value) {
        (id.to_string(), Value::from(n as u64))
    }

    fn flag(id: &str) -> (String, Value) {
        (id.to_string(), Value::from(true))
    }

    #[test]
    fn sentences_keep_rule_numbers_and_labels_whole() {
        let s = sentences(
            "SO III.C: \"Memoranda shall not exceed 7,000 words. See Local Rule 11-6.1. A brief prepared using a typewriter may not exceed 25 pages.\" Fed. R. Civ. P. 56 governs.",
        );
        assert_eq!(
            s,
            [
                "SO III.C: \"Memoranda shall not exceed 7,000 words.",
                "See Local Rule 11-6.1.",
                "A brief prepared using a typewriter may not exceed 25 pages.\"",
                "Fed. R. Civ. P. 56 governs.",
            ]
        );
        assert_eq!(
            clean_quote(&s[0]),
            "Memoranda shall not exceed 7,000 words."
        );
        // a citation is one sentence
        let c = sentences("Sanctions may be imposed. See Mission Power Eng'g Co. v. Cont'l Cas. Co., 883 F. Supp. 488 (C.D. Cal. 1995). Foltz v. State Farm Mut. Auto. Ins. Co., 331 F.3d 1122, 1135 (9th Cir. 2003).");
        assert_eq!(c.len(), 3, "{c:?}");
        assert_eq!(
            clean_quote(&s[2]),
            "A brief prepared using a typewriter may not exceed 25 pages."
        );
    }

    #[test]
    fn a_floor_for_times_beside_courier_is_the_body_floor_and_no_face() {
        let (f, r) = fonts("SO III.C: \"Pursuant to Local Rule 11-3.1.1, either a proportionally spaced or monospaced face may be used. Typeface shall comply with Local Rule 11-3.1.1. Times New Roman font must be no less than fourteen (14) point, and Courier font must be no less than twelve (12) point. Footnotes shall be in the same font and the same size as the body of the memorandum.\"");
        assert_eq!(
            ids(&f),
            [v("body.min_pt", 14.0), flag("footnote.same_as_body")]
        );
        assert_eq!(f[0].quote, "Times New Roman font must be no less than fourteen (14) point, and Courier font must be no less than twelve (12) point.");
        assert!(r.is_empty());
    }

    #[test]
    fn exact_sizes_faces_and_footnote_sizes() {
        // an exact body size, a mandated face, an exact footnote size
        let (f, _) = fonts("Times New Roman font must be used, and the font size must be 14 point. Footnotes shall be in 12-point font and shall be used sparingly.");
        assert_eq!(
            ids(&f),
            [
                v("body.exact_pt", 14.0),
                ("body.face".to_string(), Value::from("Times New Roman")),
                v("footnote.exact_pt", 12.0)
            ]
        );
        // "only", footnotes included; a gap between footnotes is not a size
        let (f, _) = fonts("Use only 14-point Times New Roman font, including for footnotes. Footnotes shall be separated by 12-point spacing.");
        assert_eq!(
            ids(&f),
            [
                v("body.exact_pt", 14.0),
                ("body.face".to_string(), Value::from("Times New Roman")),
                flag("footnote.same_as_body")
            ]
        );
        // floors for both, split at the semicolon
        let (f, _) = fonts("All briefing must use Times New Roman font. Text must be no less than twelve (12) point font; footnotes shall be no less than ten (10) point font.");
        assert_eq!(
            ids(&f),
            [
                ("body.face".to_string(), Value::from("Times New Roman")),
                v("body.min_pt", 12.0),
                v("footnote.min_pt", 10.0)
            ]
        );
        // two faces allowed: no face is mandated
        let (f, _) = fonts("All briefing must use Times New Roman or Courier font. Text must be no less than twelve (12) point font.");
        assert_eq!(ids(&f), [v("body.min_pt", 12.0)]);
    }

    #[test]
    fn relative_footnotes_floors_without_a_unit_and_silence() {
        let (f, _) = fonts("Footnotes shall be in typeface no less than two sizes smaller than text size (e.g., if text size is 14, font size shall be no smaller than 12) and shall be used sparingly.");
        assert_eq!(ids(&f), [v("footnote.max_smaller_pt", 2.0)]);
        let (f, _) = fonts("NOTE: If Times Roman font is used, the size must be no less than 14; if Courier is used, the size must be no less than 12. Footnotes shall be in typeface no more than one size smaller than text size and shall be used sparingly.");
        assert_eq!(
            ids(&f),
            [v("body.min_pt", 14.0), v("footnote.max_smaller_pt", 1.0)]
        );
        let (f, _) = fonts("All papers filed with the Court must conform to Local Rule 11-3.1.1, which generally requires typeface of 14 point or larger for Times New Roman and 12 point or larger for Courier.");
        assert_eq!(ids(&f), [v("body.min_pt", 14.0)]);
        let (f, r) = fonts("Silent on font formatting.");
        assert!(f.is_empty() && r.is_empty());
        let (f, _) = fonts("A mandatory chambers copy must comply with Local Rule 11-3 (i.e. font size, page numbering, exhibit tabbing, etc.) but need not be blue-backed.");
        assert!(f.is_empty());
    }

    #[test]
    fn word_limits_by_paper_and_typewriter_pages_left_out() {
        let (f, r) = lengths("Memoranda of points and authorities shall not exceed 7,000 words. See Local Rule 11-6.1. A handwritten brief or a brief prepared using a typewriter may not exceed 25 pages, excluding the caption. All submitted briefs must be accompanied by a Certificate of Compliance as set forth in Local Rule 11-6.2. Replies shall not exceed 4,200 words or fifteen (15) pages for handwritten briefs and briefs prepared using a typewriter. Only in rare instances and for good cause shown will the court grant an application to extend these word or page limitations.");
        assert_eq!(
            ids(&f),
            [
                v("words.memorandum", 7000.0),
                flag("certificate.required"),
                v("words.reply", 4200.0)
            ]
        );
        assert!(r.is_empty());
    }

    #[test]
    fn page_limits_other_papers_and_two_values() {
        let (f, _) = lengths("Memoranda of points and authorities in support of or in opposition to motions shall not exceed 25 pages. Replies shall not exceed 12 pages.");
        assert_eq!(
            ids(&f),
            [v("pages.memorandum", 25.0), v("pages.reply", 12.0)]
        );
        // a supplemental memorandum's limit is not the memorandum's; a contents threshold is no limit
        let (f, _) = lengths("Unless otherwise ordered by the Court, a supplemental memorandum may not exceed five pages in length. Any brief exceeding ten pages must have a table of contents.");
        assert!(f.is_empty());
        // one id, two values: neither is a fact
        let (f, r) =
            lengths("Briefs shall not exceed 20 pages. Motions shall not exceed 25 pages.");
        assert!(f.is_empty());
        assert_eq!(r.len(), 2);
    }

    #[test]
    fn the_paper_is_the_first_one_named_and_narrow_labels_are_set_apart() {
        // the local rule restated for every paper is the memorandum's limit, not the reply's
        let (f, _) = lengths("All other memorandums of points and authorities, pretrial briefs, trial briefs, and posttrial briefs (including motions, oppositions, and replies) may not exceed 7,000 words.");
        assert_eq!(ids(&f), [v("words.memorandum", 7000.0)]);
        let (f, _) = lengths(
            "Oppositions shall not exceed 25 pages and any reply shall not exceed 10 pages.",
        );
        assert_eq!(
            ids(&f),
            [v("pages.opposition", 25.0), v("pages.reply", 10.0)]
        );
        let (f, _) = lengths("Notwithstanding L.R. 11-6.1 & 11-6.2, Memoranda of Points and Authorities in support of or in opposition to motions shall not exceed 25 substantive pages. Reply briefs may not exceed 3,000 words, excluding indices and exhibits. A handwritten or typewritten reply brief may not exceed 10 pages.");
        assert_eq!(
            ids(&f),
            [v("pages.memorandum", 25.0), v("words.reply", 3000.0)]
        );
        // a limit under a label for one kind of motion is not the general limit
        let (f, r) = lengths("G.4. Replies shall not exceed 4,000 words. For MSJ: A.6. Replies shall not exceed ten (10) pages.");
        assert_eq!(ids(&f), [v("words.reply", 4000.0)]);
        assert_eq!(
            r,
            ["(of one kind of motion) Replies shall not exceed ten (10) pages."]
        );
        let (f, r) = lengths("Discovery Motion Practice: No discovery motion may exceed 10 pages. The opposition may not exceed 10 pages unless leave of Court is obtained in advance. Any reply is limited to 5 pages.");
        assert!(f.is_empty());
        assert_eq!(r.len(), 2);
        // instructions: limits and sizes
        let t = "Limit any motion, response, brief, or memorandum to 6,250 words; limit any reply to 2,500 words. Use 14-point font in the body of the briefing and 11-point font for footnotes. Requests to extend the page limit to 30 pages are disfavored.";
        let (f, _) = lengths(t);
        assert_eq!(
            ids(&f),
            [v("words.memorandum", 6250.0), v("words.reply", 2500.0)]
        );
        let (f, _) = fonts(t);
        assert_eq!(
            ids(&f),
            [v("body.exact_pt", 14.0), v("footnote.exact_pt", 11.0)]
        );
        // a word limit that lists footnotes is no footnote rule
        let (f, _) = fonts("Memoranda must not exceed 7,000 words, including headings, footnotes, and quotations\u{2026} footnotes must be no less than twelve (12) point font.");
        assert_eq!(ids(&f), [v("footnote.min_pt", 12.0)]);
    }
}
