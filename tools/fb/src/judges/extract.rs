//! Typed formatting facts read out of the free text of a judge's standing order, as a judge feed quotes it
//! (docs/JUDGES.md). Pure text in, facts out: every fact carries the one sentence it was read from, so
//! `verify.rs` can find that sentence in the court's own PDF and a person can audit it.
//!
//! The reader is deliberately narrow. It takes a number only next to its unit (`14 point`, `7,000 words`,
//! `25 pages`) and only in a sentence that states a rule (`no less than`, `shall not exceed`, `only`); anything
//! else is left alone. A limit is the limit of the papers its subject names (`Opposition and reply briefs`), and
//! a subject that names one kind of motion (`motions for summary judgment`, `Daubert motions`) is no general limit.
//! A sentence that mentions a size or a limit and yields no fact is returned in `review`.
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

/// What a number that its words and its digits disagree on ("twenty (25)") reads as: no number at all.
const MISMATCH: &str = "#mismatch";

/// The tokens of `s`: lower case, punctuation as space, a comma inside digits dropped ("7,000"), number words read
/// ("twenty-five" is 25) and a number said twice ("fourteen (14)") kept once. A number in words followed by digits in
/// parentheses that disagree ("twenty (25)") is no number.
fn tokens(s: &str) -> Vec<Tok> {
    let chars: Vec<char> = s.to_lowercase().chars().collect();
    // the words, each with whether a parenthesis opens right before it
    let mut words: Vec<(String, bool)> = Vec::new();
    let mut cur = String::new();
    let mut paren = false;
    for (i, &c) in chars.iter().enumerate() {
        let digit = |j: usize| chars.get(j).is_some_and(|c| c.is_ascii_digit());
        if c.is_alphanumeric() || c == '\'' || c == '\u{2019}' {
            cur.push(c);
            continue;
        }
        if c == ',' && i > 0 && digit(i - 1) && digit(i + 1) {
            // "7,000"
            continue;
        }
        if c == '.' && i > 0 && digit(i - 1) && digit(i + 1) {
            cur.push('.');
            continue;
        }
        if !cur.is_empty() {
            words.push((std::mem::take(&mut cur), paren));
            paren = false;
        }
        if c == '(' {
            paren = true;
        } else if !c.is_whitespace() {
            paren = false;
        }
    }
    if !cur.is_empty() {
        words.push((cur, paren));
    }
    let mut out: Vec<Tok> = Vec::new();
    // whether each number of `out` was written in words
    let mut wordy: Vec<bool> = Vec::new();
    for (w, paren) in words {
        let (t, in_words) = match w.parse::<f64>() {
            Ok(n) => (Tok::Num(n), false),
            Err(_) => match word_number(&w) {
                Some(n) => (Tok::Num(n), true),
                None => (Tok::Word(w), false),
            },
        };
        let last_wordy = wordy.last().copied().unwrap_or(false);
        match (out.last(), &t) {
            // "twenty five" is 25
            (Some(Tok::Num(a)), Tok::Num(b))
                if last_wordy
                    && in_words
                    && *a >= 20.0
                    && a % 10.0 == 0.0
                    && *a < 100.0
                    && *b < 10.0
                    && *b > 0.0 =>
            {
                let n = a + b;
                out.pop();
                out.push(Tok::Num(n));
            }
            // "fourteen (14)"
            (Some(Tok::Num(a)), Tok::Num(b)) if a == b => {}
            // "twenty (25)": the words and the digits disagree, so neither is the number
            (Some(Tok::Num(_)), Tok::Num(_)) if paren && last_wordy && !in_words => {
                out.pop();
                wordy.pop();
                out.push(Tok::Word(MISMATCH.into()));
                wordy.push(false);
            }
            _ => {
                out.push(t);
                wordy.push(in_words);
            }
        }
    }
    out
}

fn is(t: Option<&Tok>, w: &str) -> bool {
    matches!(t, Some(Tok::Word(x)) if x == w)
}

fn word(t: Option<&Tok>) -> &str {
    match t {
        Some(Tok::Word(w)) => w,
        _ => "",
    }
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

/// Whether a line opens a list item ("- ", "â¢ ", "(a) ", "3. ", "iv. ").
fn list_item(line: &str) -> bool {
    let t = line.trim_start();
    if t.starts_with([
        '-', '*', '\u{2022}', '\u{25CF}', '\u{25AA}', '\u{2013}', '\u{2014}',
    ]) {
        return true;
    }
    if let Some(rest) = t.strip_prefix('(') {
        return rest.find(')').is_some_and(|close| {
            close > 0 && close <= 4 && rest[..close].chars().all(char::is_alphanumeric)
        });
    }
    let head: String = t.chars().take_while(|c| c.is_alphanumeric()).collect();
    let rest = &t[head.len()..];
    let short = !head.is_empty()
        && (head.chars().all(|c| c.is_ascii_digit())
            || head.chars().count() == 1
            || head
                .chars()
                .all(|c| "ivxlc".contains(c.to_ascii_lowercase())));
    short && head.chars().count() <= 4 && (rest.starts_with(". ") || rest.starts_with(") "))
}

/// Whether a line ends a sentence: sentence punctuation (`.` `?` `!` `:` `;`), closing marks aside.
fn ends_sentence(line: &str) -> bool {
    line.trim_end()
        .trim_end_matches(['"', '\u{201D}', '\'', '\u{2019}', ')', ']'])
        .ends_with(['.', '?', '!', ':', ';'])
}

/// The paragraphs of `text`: a feed's text is often hard-wrapped mid-sentence, so a line break ends a paragraph only
/// after sentence punctuation, at a blank line, before a list item or after one where a capital opens the next line;
/// other lines are joined ("sur-" / "reply" without a space).
pub fn paragraphs(text: &str) -> Vec<String> {
    let mut out = Vec::new();
    let mut cur = String::new();
    for raw in text.lines() {
        let line = raw.trim();
        if line.is_empty() {
            if !cur.is_empty() {
                out.push(std::mem::take(&mut cur));
            }
            continue;
        }
        if cur.is_empty() {
            cur = line.to_string();
        } else if ends_sentence(&cur)
            || list_item(line)
            || (list_item(&cur) && line.starts_with(char::is_uppercase))
        {
            out.push(std::mem::replace(&mut cur, line.to_string()));
        } else if cur.ends_with('-')
            && cur.chars().rev().nth(1).is_some_and(char::is_alphabetic)
            && line.chars().next().is_some_and(char::is_lowercase)
        {
            cur.push_str(line);
        } else {
            cur.push(' ');
            cur.push_str(line);
        }
    }
    if !cur.is_empty() {
        out.push(cur);
    }
    out
}

/// The sentences of one paragraph.
fn split_paragraph(para: &str) -> Vec<String> {
    let mut out = Vec::new();
    let chars: Vec<char> = para.chars().collect();
    let mut start = 0;
    let mut i = 0;
    while i < chars.len() {
        let c = chars[i];
        let ends = c == '.' || c == '?' || c == '!';
        // a closing quotation mark stays with its sentence
        let mut j = i + 1;
        while j < chars.len()
            && matches!(chars[j], '"' | '\u{201D}' | '\'' | '\u{2019}' | ')' | ']')
        {
            j += 1;
        }
        let spaced = chars.get(j).is_some_and(|c| c.is_whitespace());
        let mut k = j;
        while k < chars.len() && chars[k].is_whitespace() {
            k += 1;
        }
        let opens = chars.get(k).is_some_and(|c| {
            c.is_uppercase() || c.is_ascii_digit() || matches!(c, '"' | '\u{201C}' | '(' | '[')
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
    out
}

/// The sentences of `text`: its paragraphs (lines joined) split at a period, question mark or exclamation mark
/// followed by a capital, a quotation mark, a bracket or a digit, but not after an abbreviation ("L.R. 11-6.1",
/// "Fed. R. Civ. P. 56") or a single letter ("SO III.C").
pub fn sentences(text: &str) -> Vec<String> {
    paragraphs(text)
        .iter()
        .flat_map(|p| split_paragraph(p))
        .map(|s| s.split_whitespace().collect::<Vec<_>>().join(" "))
        .filter(|s| !s.is_empty())
        .collect()
}

/// A sentence as the order states it: without the feed's label before the quotation (`SO III.C: "`) and without the
/// quotation marks around it, and without a list item's bullet ("- ", "• ").
pub fn clean_quote(s: &str) -> String {
    let mut t = s.trim();
    if let Some(rest) = t.strip_prefix(['-', '*', '\u{2022}', '\u{25CF}', '\u{25AA}']) {
        if rest.starts_with(char::is_whitespace) {
            t = rest.trim_start();
        }
    }
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

/// Whether the words state an exact value ("only", "must be", "shall be", "should also be").
fn exact(ts: &[Tok]) -> bool {
    has(ts, "only")
        || has_seq(ts, &["must", "be"])
        || has_seq(ts, &["shall", "be"])
        || has_seq(ts, &["should", "be"])
        || has_seq(ts, &["must", "also", "be"])
        || has_seq(ts, &["shall", "also", "be"])
        || has_seq(ts, &["should", "also", "be"])
        || has_seq(ts, &["is", "required"])
}

/// Whether the number at `i` is a type size: 8 to 18 before "point", "pt" or "font" (not "12-point spacing", a gap),
/// or after "size" ("size 12 font", "size 13 or larger").
fn size_at(ts: &[Tok], i: usize) -> Option<f64> {
    let Some(Tok::Num(n)) = ts.get(i) else {
        return None;
    };
    if !(8.0..=18.0).contains(n) {
        return None;
    }
    let next = word(ts.get(i + 1));
    if matches!(next, "point" | "pt" | "points" | "font") && !is(ts.get(i + 2), "spacing") {
        return Some(*n);
    }
    let sized = i > 0 && is(ts.get(i - 1), "size");
    (sized && !matches!(next, "x" | "by" | "inch" | "inches")).then_some(*n)
}

/// A type size in `ts` (size_at), or a number right after a floor's "than" or "least" in words about a size or a
/// font.
fn type_size(ts: &[Tok]) -> Option<f64> {
    for (i, t) in ts.iter().enumerate() {
        if let Some(n) = size_at(ts, i) {
            return Some(n);
        }
        let Tok::Num(n) = t else { continue };
        if !(8.0..=18.0).contains(n) {
            continue;
        }
        let after_floor = i > 0
            && (is(ts.get(i - 1), "than") || is(ts.get(i - 1), "least") || is(ts.get(i - 1), "of"));
        let about = has(ts, "size") || has(ts, "font") || has(ts, "typeface");
        if after_floor && about && floor(ts) {
            return Some(*n);
        }
    }
    None
}

/// Words that name a face other than Times New Roman, or leave the face open.
fn other_face(w: &str) -> bool {
    matches!(
        w,
        "courier"
            | "monospaced"
            | "monospace"
            | "antiqua"
            | "century"
            | "schoolbook"
            | "garamond"
            | "arial"
            | "palatino"
            | "cambria"
            | "calibri"
            | "georgia"
            | "helvetica"
            | "bookman"
            | "baskerville"
            | "equivalent"
            | "similar"
            | "comparable"
    )
}

/// The words of a body clause that are said of Times New Roman (or of a face not named): what is said of another face
/// ("Courier font must be no less than twelve (12) point") is not the proportional body's rule.
fn times_part(ts: &[Tok]) -> &[Tok] {
    let times =
        find_seq(ts, &["times", "new", "roman"]).or_else(|| find_seq(ts, &["times", "roman"]));
    let alt_after = |from: usize| {
        (from..ts.len())
            .find(|&i| other_face(word(ts.get(i))))
            .unwrap_or(ts.len())
    };
    match times {
        Some(t) if alt_after(0) < t => &ts[t..alt_after(t)],
        _ => &ts[..alt_after(0)],
    }
}

/// The facts of a body clause: its size (a floor or an exact value) and a face the order mandates. `ordered`: the
/// sentence is an instruction ("Use 14-point font") or a limit ("limited to 25 pages, 12-point type font"), so a
/// size it names is exact. The body's rule found, for the footnotes that follow it, is returned.
fn body_clause(
    ts: &[Tok],
    alternatives: bool,
    ordered: bool,
    quote: &str,
    out: &mut Vec<Found>,
) -> Option<(&'static str, f64)> {
    let prop = times_part(ts);
    let mut rule = None;
    if let Some(n) = type_size(prop) {
        if floor(prop) {
            out.push(found("body.min_pt", n, quote));
            rule = Some(("min", n));
        } else if exact(prop) || ordered {
            out.push(found("body.exact_pt", n, quote));
            rule = Some(("exact", n));
        }
    }
    // a mandatory sentence that puts the text in Times New Roman and names no other face: "must use", "shall be
    // used", "shall be double-spaced in Times New Roman 12-point typeface", "filed in 12-point Times New Roman font";
    // not "Times New Roman font must be no less than 14 point", a rule on the size
    let times =
        find_seq(ts, &["times", "new", "roman"]).or_else(|| find_seq(ts, &["times", "roman"]));
    let put_in = times.is_some_and(|t| {
        let mut k = t;
        while k > 0
            && (matches!(ts.get(k - 1), Some(Tok::Num(_))) || size_word(word(ts.get(k - 1))))
        {
            k -= 1;
        }
        k > 0 && matches!(word(ts.get(k - 1)), "in" | "be" | "use")
    });
    let used = has_seq(ts, &["must", "use"])
        || has_seq(ts, &["shall", "use"])
        || has_seq(ts, &["must", "be", "used"])
        || has_seq(ts, &["shall", "be", "used"])
        || has_seq(ts, &["use", "only"])
        || has_seq(ts, &["only", "use"]);
    let mandatory = has(ts, "must") || has(ts, "shall") || has(ts, "required") || ordered;
    let permissive = has(ts, "may") || has(ts, "acceptable") || has(ts, "preferred");
    if times.is_some() && (used || (put_in && mandatory)) && !permissive && !alternatives {
        out.push(found("body.face", "Times New Roman", quote));
    }
    rule
}

/// The words of a size before a face's name ("12-point", "size 12").
fn size_word(w: &str) -> bool {
    matches!(w, "point" | "pt" | "size" | "type")
}

/// The fact of a footnote clause: the body's size, a size of its own, or a size relative to the body's. `body`: the
/// body's rule stated before it in the same text, which "these typeface requirements apply to footnotes" carries
/// over (a floor stays a floor).
fn footnote_clause(
    ts: &[Tok],
    ordered: bool,
    body: Option<(&'static str, f64)>,
    quote: &str,
    out: &mut Vec<Found>,
    review: &mut Vec<String>,
) {
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
    if has(ts, "same") && has(ts, "size") {
        out.push(found("footnote.same_as_body", true, quote));
        return;
    }
    if has_seq(ts, &["apply", "to", "footnoted"]) || has_seq(ts, &["apply", "to", "footnotes"]) {
        match body {
            Some(("min", n)) => out.push(found("footnote.min_pt", n, quote)),
            Some(_) => out.push(found("footnote.same_as_body", true, quote)),
            None => review.push(format!(
                "(the body's rule it carries over was not read) {}",
                clean_quote(quote)
            )),
        }
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

/// Whether a clause is about footnotes: a footnote word before its size, or right after it ("11-point font for
/// footnotes"), not one far off ("a minimum 12-point font, and ... 1/2-inch margins for footnotes").
fn about_footnotes(ts: &[Tok]) -> bool {
    let Some(note) = ts
        .iter()
        .position(|t| matches!(t, Tok::Word(w) if w.starts_with("footnote")))
    else {
        return false;
    };
    match (0..ts.len()).find(|&i| size_at(ts, i).is_some()) {
        Some(s) => note < s || note <= s + 4,
        None => true,
    }
}

/// Words a narrowing label or a narrow subject names: one kind of motion or case.
fn narrow_word(ts: &[Tok], i: usize) -> bool {
    let w = word(ts.get(i));
    let next = word(ts.get(i + 1));
    match w {
        "msj" | "daubert" | "limine" | "discovery" | "expert" | "experts" | "markman"
        | "habeas" | "erisa" | "remand" | "arbitration" | "sanctions" | "reconsideration"
        | "injunction" | "injunctive" | "patent" | "criminal" | "bankruptcy" | "dismiss"
        | "amend" | "class" | "sentencing" | "suppress" | "compel" | "slapp" | "fees"
        | "restraining" | "collective" | "opt" | "objection" | "objections" | "recommendation" => {
            true
        }
        "motion" | "motions" => next == "for" && is(ts.get(i + 2), "leave"),
        "dispositive" => !is(ts.get(i.wrapping_sub(1)), "non"),
        "summary" => next == "judgment" || next == "judgments",
        "claim" => next == "construction",
        "social" => next == "security",
        "default" => next == "judgment",
        "ex" => next == "parte",
        "posttrial" => next.starts_with("motion"),
        "post" | "new" => next == "trial" && word(ts.get(i + 2)).starts_with("motion"),
        "judgment" => next == "on" && is(ts.get(i + 2), "the") && is(ts.get(i + 3), "pleadings"),
        _ => false,
    }
}

fn narrow(ts: &[Tok]) -> bool {
    (0..ts.len()).any(|i| narrow_word(ts, i))
}

/// Whether a sentence is a heading in title case ("Motions for Summary Judgment."): every word of four letters or
/// more capitalized, at most eight words, no rule stated.
fn heading(s: &str) -> bool {
    let words: Vec<&str> = s
        .split_whitespace()
        .map(|w| w.trim_matches(|c: char| !c.is_alphanumeric()))
        .filter(|w| !w.is_empty())
        .collect();
    !words.is_empty()
        && words.len() <= 8
        && words
            .iter()
            .filter(|w| w.chars().count() >= 4)
            .all(|w| w.chars().next().is_some_and(char::is_uppercase))
        && words.iter().any(|w| w.chars().count() >= 4)
}

/// The labels of a sentence (`SO III.C:`, `For MSJ:`, `Discovery Motion Practice:`, `MSJ Â§1.c Word Limit:` after
/// another label), and whether any narrows what follows to one kind of motion or case: a limit said of summary
/// judgment or of discovery motions is not the judge's limit for every memorandum. A heading sentence in title case
/// counts as a label.
fn scope_label(s: &str) -> Option<bool> {
    let mut any = None;
    let mut from = 0;
    for (at, _) in s.match_indices(':') {
        let seg = &s[from..at];
        // the label starts after the last sentence mark or bracket before the colon
        let label = seg
            .rfind(['[', '.', ';'])
            .map_or(seg, |i| &seg[i + 1..])
            .trim();
        from = at + 1;
        if label.is_empty() || label.len() > 60 || label.split_whitespace().count() > 8 {
            continue;
        }
        let ts = tokens(label);
        let n = narrow(&ts);
        any = Some(any.unwrap_or(false) || n);
    }
    if any.is_none() && heading(s) {
        let ts = tokens(s);
        if !LIMIT_PHRASES.iter().any(|p| has_seq(&ts, p)) {
            return Some(narrow(&ts));
        }
    }
    any
}

/// A sentence without the labels it opens with ("Motions â General Requirements. c. Length and Format of Motion
/// Papers: Replies must not exceed 15 pages."): the words of a label are no part of a rule's subject. Text before a
/// colon that states a limit is no label.
fn without_labels(s: &str) -> &str {
    let mut t = s;
    while let Some(at) = t.find(':') {
        let seg = &t[..at];
        let label = seg
            .rfind(['[', '.', ';'])
            .map_or(seg, |i| &seg[i + 1..])
            .trim();
        let rest = t[at + 1..].trim_start();
        let ts = tokens(seg);
        if label.is_empty()
            || label.len() > 60
            || label.split_whitespace().count() > 8
            || rest.is_empty()
            || limits(&ts)
        {
            break;
        }
        t = rest;
    }
    t
}

/// The sentences of `text` that state a general rule: those under a narrowing label (scope_label), to the end of
/// their paragraph or the next label, are returned apart.
fn general(text: &str) -> (Vec<String>, Vec<String>) {
    let (mut keep, mut narrowed) = (Vec::new(), Vec::new());
    for para in paragraphs(text) {
        let mut narrow = false;
        for s in sentences(&para) {
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

/// Whether the words name a type size (the review list's test).
fn names_size(ts: &[Tok]) -> bool {
    (0..ts.len()).any(|i| size_at(ts, i).is_some())
}

/// The type facts of a judge's text on fonts and footnotes, and the sentences that name a size without yielding one.
pub fn fonts(text: &str) -> (Vec<Found>, Vec<String>) {
    let mut out = Vec::new();
    let mut review = Vec::new();
    // the body's rule read so far: "These typeface requirements apply to footnoted material" carries it over
    let mut body: Option<(&'static str, f64)> = None;
    for s in general(text).0 {
        let before = out.len();
        // the rule without its labels; the quote stays the whole sentence
        let r = without_labels(&s);
        let all = tokens(r);
        let alternatives = all
            .iter()
            .any(|t| matches!(t, Tok::Word(w) if other_face(w)))
            || has_seq(&all, &["such", "as"]);
        // an instruction ("Use 14-point font in the body of the briefing and 11-point font for footnotes.") or a
        // limit ("limited to 25 double-spaced pages with 13-point font"): a size it names is required
        let ordered = is(all.first(), "use") || limits(&all);
        let sizes: Vec<usize> = (0..all.len())
            .filter(|&i| size_at(&all, i).is_some())
            .collect();
        let notes = has_prefix(&all, "footnote");
        let lower = r.to_ascii_lowercase();
        // one size for the body and one for the footnotes: two clauses, at " and " or where the footnotes begin
        let parts: Vec<&str> = if sizes.len() == 2 && notes && !r.contains(';') {
            if r.contains(" and ") {
                r.split(" and ").collect()
            } else {
                match lower.find("footnote") {
                    Some(at) if r.is_char_boundary(at) => vec![&r[..at], &r[at..]],
                    _ => vec![r],
                }
            }
        } else {
            r.split(';').collect()
        };
        let split = parts.len() > 1;
        for clause in parts {
            let ts = tokens(clause);
            // a clause of a split sentence takes the sentence's force when it states none of its own; under a
            // floor it is ambiguous ("no less than 12 point and footnotes 10 point")
            let own = floor(&ts) || exact(&ts);
            if split && !own && floor(&all) && type_size(&ts).is_some() {
                continue;
            }
            let ordered = ordered || (split && !own && exact(&all));
            let with_notes = has_seq(&ts, &["including", "for", "footnotes"])
                || has_seq(&ts, &["including", "footnotes"])
                || has_seq(&ts, &["including", "in", "footnotes"]);
            if with_notes && type_size(&ts).is_some() {
                // "Use only 14-point Times New Roman font, including for footnotes."; "All written text, including
                // footnotes and quotations, shall be no less than 12-point type"
                match body_clause(&ts, alternatives, ordered, &s, &mut out) {
                    Some(("min", n)) => {
                        out.push(found("footnote.min_pt", n, &s));
                        body = Some(("min", n));
                    }
                    Some(r) => {
                        out.push(found("footnote.same_as_body", true, &s));
                        body = Some(r);
                    }
                    None => {}
                }
            } else if about_footnotes(&ts) {
                footnote_clause(&ts, ordered, body, &s, &mut out, &mut review);
            } else if let Some(r) = body_clause(&ts, alternatives, ordered, &s, &mut out) {
                body = Some(r);
            }
        }
        if out.len() == before && names_size(&all) {
            review.push(clean_quote(&s));
        }
    }
    (dedupe(out, &mut review), review)
}

const LIMIT_PHRASES: [&[&str]; 10] = [
    &["not", "exceed"],
    &["not", "to", "exceed"],
    &["cannot", "exceed"],
    &["no", "more", "than"],
    &["limited", "to"],
    &["no", "longer", "than"],
    &["maximum", "of"],
    &["not", "be", "longer", "than"],
    &["not", "total", "more", "than"],
    &["not", "be", "more", "than"],
];

/// A limit stated of a negated subject: "no supporting or opposing memorandum shall exceed 7,000 words".
const NEGATED_LIMITS: [&[&str]; 6] = [
    &["shall", "exceed"],
    &["may", "exceed"],
    &["will", "exceed"],
    &["should", "exceed"],
    &["can", "exceed"],
    &["must", "exceed"],
];

/// Whether the words state a limit.
fn limits(ts: &[Tok]) -> bool {
    LIMIT_PHRASES.iter().any(|p| has_seq(ts, p))
        || (has(ts, "no") && NEGATED_LIMITS.iter().any(|p| has_seq(ts, p)))
        || is(ts.first(), "limit")
}

/// The paper a word of a subject names, as a noun ("replies", "opposition", "response", "brief") or as a word before
/// one ("opening", "supporting", "opposing"): `Main` a paper a limit can be for, `Other` a paper that is never the
/// memorandum's, the opposition's or the reply's.
#[derive(Debug, Clone, Copy, PartialEq)]
enum Named {
    Main(&'static str),
    Other,
}

/// Words before a paper that make it another paper ("supplemental memorandum", "sur-reply", "trial brief").
const OTHER_MODIFIERS: [&str; 16] = [
    "supplemental",
    "joint",
    "stipulation",
    "introductory",
    "objection",
    "sur",
    "amicus",
    "letter",
    "trial",
    "pretrial",
    "posttrial",
    "postrial",
    "pre",
    "post",
    "further",
    "additional",
];

/// Words a paper that is an object follows ("in opposition to the motion", "raised in the response").
const PREPOSITIONS: [&str; 17] = [
    "in",
    "to",
    "of",
    "for",
    "on",
    "with",
    "by",
    "from",
    "after",
    "under",
    "against",
    "regarding",
    "within",
    "upon",
    "at",
    "accompanying",
    "than",
];

/// Words that may stand between a preposition and its object ("to any motion", "in the original motion").
const DETERMINERS: [&str; 17] = [
    "the",
    "a",
    "an",
    "any",
    "each",
    "its",
    "their",
    "his",
    "her",
    "all",
    "other",
    "original",
    "underlying",
    "pending",
    "same",
    "such",
    "every",
];

/// Words that end a subject once it has named a paper: a verb, or a clause that says more of it ("Reply briefs,
/// addressing only issues raised in the brief in opposition, ...").
const STOPS: [&str; 34] = [
    "addressing",
    "filed",
    "served",
    "submitted",
    "without",
    "within",
    "after",
    "before",
    "regarding",
    "concerning",
    "including",
    "excluding",
    "if",
    "unless",
    "when",
    "which",
    "that",
    "who",
    "whose",
    "where",
    "are",
    "is",
    "was",
    "may",
    "shall",
    "must",
    "will",
    "should",
    "can",
    "cannot",
    "be",
    "accompanying",
    "per",
    "raising",
];

/// Nouns that, standing right before a limit, are what the limit is of ("a concise summary, no longer than 3 pages").
const FOREIGN: [&str; 22] = [
    "summary",
    "table",
    "contents",
    "exhibit",
    "exhibits",
    "declaration",
    "declarations",
    "attachment",
    "attachments",
    "appendix",
    "appendices",
    "statement",
    "statements",
    "footnote",
    "footnotes",
    "letter",
    "index",
    "section",
    "introduction",
    "argument",
    "request",
    "requests",
];

fn generic(w: &str) -> bool {
    w.starts_with("memorand") || w.starts_with("brief") || w == "motion" || w == "motions"
}

fn paper_word(w: &str) -> bool {
    generic(w)
        || w.starts_with("repl")
        || w.starts_with("surrepl")
        || w.starts_with("opposi")
        || w == "response"
        || w == "responses"
        || matches!(
            w,
            "opening" | "primary" | "initial" | "principal" | "supporting" | "moving" | "opposing"
        )
}

/// The papers a limit's subject names, in order: a fact is the limit of each. "Opposition and reply briefs" are the
/// opposition and the reply; "briefs in support of and in opposition to a motion" are the memorandum (an
/// opposition takes the memorandum's limit); "the memorandum in opposition to the motion" is the opposition. A
/// paper that is an object ("in opposition to the motion": the motion) names nothing; nor does a word for another
/// paper ("supplemental", "sur-reply").
fn named(subject: &[Tok]) -> Vec<Named> {
    // a letter brief or a response to a letter is another paper altogether
    if subject
        .iter()
        .any(|t| matches!(t, Tok::Word(w) if w == "letter" || w == "letters"))
    {
        return vec![Named::Other];
    }
    // a trial's papers are not a motion's unless the memorandum is named ("no memorandum of points and authorities,
    // pretrial brief, trial brief, or posttrial brief"; "Any opposition(s) shall be e-filed seven (7) days before the
    // Final Pretrial Conference and shall not exceed 10 pages")
    let trial = subject.iter().any(|t| {
        matches!(t, Tok::Word(w) if matches!(w.as_str(), "trial" | "pretrial" | "posttrial" | "postrial"))
    });
    if trial && !has_prefix(subject, "memorand") {
        return vec![Named::Other];
    }
    let mut out: Vec<Named> = Vec::new();
    let mut support = false;
    // the token whose paper was pushed last
    let mut last_pushed: Option<usize> = None;
    let mut i = 0;
    while i < subject.len() {
        let w = word(subject.get(i));
        let next = word(subject.get(i + 1));
        let main = out.iter().any(|n| matches!(n, Named::Main(_)));
        if main && STOPS.contains(&w) {
            break;
        }
        if w == "in" && next == "support" {
            support = true;
            // "a reply in support of any Motion" is the reply
            let of_paper = i > 0
                && paper_word(word(subject.get(i - 1)))
                && matches!(out.last(), Some(Named::Main("reply" | "opposition")));
            if !of_paper && !out.contains(&Named::Main("memorandum")) {
                out.push(Named::Main("memorandum"));
            }
            i += 2;
            continue;
        }
        if w == "in" && next.starts_with("opposi") {
            // a memorandum in opposition is the opposition; beside "in support of", the memorandum's twin
            if !support {
                let after_noun =
                    i > 0 && generic(word(subject.get(i - 1))) && last_pushed == Some(i - 1);
                if after_noun && out.last() == Some(&Named::Main("memorandum")) {
                    out.pop();
                }
                if !out.contains(&Named::Main("opposition")) {
                    out.push(Named::Main("opposition"));
                }
            }
            i += 2;
            continue;
        }
        if w == "in" && next.starts_with("repl") {
            out.push(Named::Main("reply"));
            i += 2;
            continue;
        }
        if !paper_word(w) {
            i += 1;
            continue;
        }
        let prev = word(subject.get(i.wrapping_sub(1)));
        // an object: a preposition before it, determiners aside
        let mut k = i;
        while k > 0 && DETERMINERS.contains(&word(subject.get(k - 1))) {
            k -= 1;
        }
        let object = k > 0 && PREPOSITIONS.contains(&word(subject.get(k - 1)));
        if object {
            i += 1;
            continue;
        }
        let kind = if w.starts_with("surrepl") || OTHER_MODIFIERS.contains(&prev) {
            Named::Other
        } else if w.starts_with("repl") {
            Named::Main("reply")
        } else if w.starts_with("opposi") || w == "response" || w == "responses" || w == "opposing"
        {
            Named::Main("opposition")
        } else {
            Named::Main("memorandum")
        };
        // a word before a paper ("opening", "opposing") names one only right before its noun, or before another such
        // word and its noun ("supporting or opposing memorandum", "opening and opposition briefs"): "opposing counsel"
        // and "the moving party's reply memorandum" name no paper by it
        let modifier = matches!(
            w,
            "opening" | "primary" | "initial" | "principal" | "supporting" | "moving" | "opposing"
        );
        let noun_next = generic(word(subject.get(i + 1)))
            || (matches!(word(subject.get(i + 1)), "or" | "and")
                && paper_word(word(subject.get(i + 2)))
                && generic(word(subject.get(i + 3))));
        if modifier && !noun_next {
            i += 1;
            continue;
        }
        // the noun of "reply briefs", "opposition brief", "supplemental briefing": the word before named the paper
        if generic(w) && paper_word(prev) && !generic(prev) {
            i += 1;
            continue;
        }
        if generic(w) && OTHER_MODIFIERS.contains(&prev) {
            out.push(Named::Other);
            i += 1;
            continue;
        }
        if !out.contains(&kind) || kind == Named::Other {
            out.push(kind);
            last_pushed = Some(i);
        }
        i += 1;
    }
    out
}

fn mains(named: &[Named]) -> Vec<&'static str> {
    let mut out = Vec::new();
    for n in named {
        if let Named::Main(p) = n {
            if !out.contains(p) {
                out.push(*p);
            }
        }
    }
    out
}

/// The unit after the number at `i` ("words", "pages"), up to two describing words between them allowed ("25
/// substantive pages", "25 double-spaced pages", "25 total pages").
fn unit(ts: &[Tok], i: usize) -> Option<&'static str> {
    let at = |k: usize| match ts.get(k) {
        Some(Tok::Word(w)) if w == "words" || w == "word" => Some("words"),
        Some(Tok::Word(w)) if w == "pages" || w == "page" => Some("pages"),
        _ => None,
    };
    let describes = |k: usize| {
        matches!(
            word(ts.get(k)),
            "substantive" | "total" | "double" | "spaced" | "single" | "typed" | "numbered"
        )
    };
    let mut k = i + 1;
    while k < i + 3 && describes(k) {
        k += 1;
    }
    at(k)
}

/// A clause before a limit that sets aside what it names ("Except for summary judgment and class certification
/// motions, ...", "With the exceptions of motions in limine, ..."): taken out, to the next comma, unless it states
/// a limit of its own ("except that replies may not exceed 10 pages").
fn without_exceptions(s: &str) -> String {
    let lower = s.to_ascii_lowercase();
    let mut cut: Vec<(usize, usize)> = Vec::new();
    for starter in [
        "except for ",
        "except ",
        "with the exceptions of ",
        "with the exception of ",
        "other than ",
        "besides ",
        "aside from ",
    ] {
        for (at, _) in lower.match_indices(starter) {
            let boundary = at == 0 || !lower.as_bytes()[at - 1].is_ascii_alphanumeric();
            if !boundary || cut.iter().any(|&(a, b)| at >= a && at < b) {
                continue;
            }
            let rest = &lower[at..];
            let end = at + rest.find([',', ';', ')']).unwrap_or(rest.len());
            if !LIMIT_PHRASES
                .iter()
                .any(|p| has_seq(&tokens(&lower[at..end]), p))
            {
                cut.push((at, end));
            }
        }
    }
    cut.sort();
    let mut out = String::new();
    let mut from = 0;
    for (a, b) in cut {
        if a >= from {
            out.push_str(&s[from..a]);
            from = b;
        }
    }
    out.push_str(&s[from..]);
    out
}

/// Whether a certificate of compliance is ordered: "a certificate of compliance is required", "Counsel shall
/// certify compliance with the word count", "Provide a certificate of word count".
fn certificate(ts: &[Tok]) -> bool {
    let named = has_seq(ts, &["certificate", "of", "compliance"])
        || has_seq(ts, &["certification", "of", "compliance"])
        || has_seq(ts, &["certify", "compliance"])
        || has_seq(ts, &["certificate", "of", "word", "count"])
        || has_seq(ts, &["certification", "of", "word", "count"]);
    let ordered = has(ts, "must")
        || has(ts, "shall")
        || has(ts, "required")
        || matches!(word(ts.first()), "provide" | "include" | "attach" | "file");
    named && ordered && !has(ts, "if") && !has(ts, "may")
}

/// The length facts of a judge's text on page and word limits: `words.<paper>` and `pages.<paper>` for the papers
/// `memorandum`, `opposition` and `reply`, and `certificate.required` where a certificate of compliance is ordered.
pub fn lengths(text: &str) -> (Vec<Found>, Vec<String>) {
    let mut out = Vec::new();
    let mut review = Vec::new();
    let (keep, narrowed) = general(text);
    let limitish = |ts: &[Tok]| limits(ts) && (has(ts, "words") || has(ts, "pages"));
    for s in narrowed {
        if limitish(&tokens(&s)) {
            review.push(format!("(of one kind of motion) {}", clean_quote(&s)));
        }
    }
    for s in keep {
        let ts = tokens(&without_exceptions(without_labels(&s)));
        // a limit of one kind of motion ("Daubert motions may not exceed 10 pages per expert") is not the general
        // limit
        if narrow(&ts) {
            if limitish(&ts) {
                review.push(format!("(of one kind of motion) {}", clean_quote(&s)));
            }
            continue;
        }
        if certificate(&ts) {
            out.push(found("certificate.required", true, &s));
        }
        let by_hand = has(&ts, "handwritten") || has(&ts, "typewriter") || has(&ts, "typewritten");
        let before = out.len();
        let push = |paper: &str, v: f64, unit: Option<&str>, out: &mut Vec<Found>| match unit {
            Some("words") if (500.0..=30000.0).contains(&v) => {
                out.push(found(&format!("words.{paper}"), v, &s))
            }
            // a page limit in a sentence on handwritten or typewritten briefs is theirs
            Some("pages") if !by_hand && (1.0..=150.0).contains(&v) => {
                out.push(found(&format!("pages.{paper}"), v, &s))
            }
            _ => {}
        };
        // a list item: "Opening brief: 25 pages or 6,250 words", "Response/opposition: 25 pages or 6,250 words"
        if let Some((label, rest)) = s.split_once(':') {
            let (lt, rt) = (tokens(label), tokens(rest));
            let papers = named(&lt);
            let only_limits = !rt.is_empty()
                && rt.iter().enumerate().all(|(i, t)| match t {
                    Tok::Num(_) => unit(&rt, i).is_some(),
                    Tok::Word(w) => matches!(
                        w.as_str(),
                        "pages" | "page" | "words" | "word" | "or" | "and" | "double" | "spaced"
                    ),
                });
            if lt.len() <= 4 && only_limits && !papers.contains(&Named::Other) {
                for paper in mains(&papers) {
                    for (i, t) in rt.iter().enumerate() {
                        if let Tok::Num(v) = t {
                            push(paper, *v, unit(&rt, i), &mut out);
                        }
                    }
                }
            }
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
        // "N pages or fewer" after "must be", "shall be", "should be"
        for i in 2..ts.len() {
            let modal = matches!(word(ts.get(i - 2)), "must" | "shall" | "should")
                && is(ts.get(i - 1), "be");
            if modal && unit(&ts, i).is_some() {
                let mut k = i + 1;
                while k < ts.len() && !is(ts.get(k), "or") && k < i + 4 {
                    k += 1;
                }
                if is(ts.get(k), "or") && matches!(word(ts.get(k + 1)), "fewer" | "less") {
                    marks.push((i - 2, i));
                }
            }
        }
        marks.sort();
        marks.dedup_by(|b, a| b.0 < a.1);
        // "no ... shall exceed": a limit only where the subject since the last limit is negated
        let mut negated: Vec<(usize, usize)> = Vec::new();
        for p in NEGATED_LIMITS {
            let mut from = 0;
            while let Some(i) = find_seq(&ts[from..], p) {
                negated.push((from + i, from + i + p.len()));
                from += i + p.len();
            }
        }
        for (a, b) in negated {
            if marks.iter().any(|m| a < m.1 && m.0 < b) {
                continue;
            }
            let prev_end = marks
                .iter()
                .filter(|m| m.1 <= a)
                .map(|m| m.1)
                .max()
                .unwrap_or(0);
            if has(&ts[prev_end..a], "no") {
                marks.push((a, b));
                marks.sort();
            }
        }
        let respectively = has(&ts, "respectively");
        let mut last: Vec<&'static str> = Vec::new();
        for (n, &(at, end)) in marks.iter().enumerate() {
            let subject = &ts[if n == 0 { 0 } else { marks[n - 1].1 }..at];
            let until = marks.get(n + 1).map_or(ts.len(), |m| m.0);
            let names = named(subject);
            let near = &subject[subject.len().saturating_sub(3)..];
            let foreign = near
                .iter()
                .any(|t| matches!(t, Tok::Word(w) if FOREIGN.contains(&w.as_str())));
            let mut papers = mains(&names);
            if foreign {
                // "a concise summary, no longer than 3 pages": the summary's limit
                last.clear();
                continue;
            }
            if papers.is_empty() {
                // "Any reply brief is limited to the issues raised ..., and shall not exceed fifteen pages": the
                // subject is the last limit's, unless another paper is named or the clause is a condition
                if names.is_empty() && n > 0 && !has(subject, "unless") {
                    papers = last.clone();
                } else {
                    last.clear();
                    continue;
                }
            }
            if n > 0 && has(subject, "unless") {
                // "shall not exceed 25 pages, unless counsel includes a certification that the brief contains no
                // more than 8,750 words": a condition, not a limit
                continue;
            }
            last = papers.clone();
            let nums: Vec<usize> = (end..until)
                .filter(|&i| matches!(ts.get(i), Some(Tok::Num(_))))
                .collect();
            if respectively {
                // "Replies and sur-replies must be limited to ten (10) and seven (7) pages, respectively."
                let unit_of = nums.last().and_then(|&i| unit(&ts, i));
                if nums.len() == names.len() {
                    for (name, &i) in names.iter().zip(&nums) {
                        if let (Named::Main(p), Some(Tok::Num(v))) = (name, ts.get(i)) {
                            push(p, *v, unit_of, &mut out);
                        }
                    }
                }
                continue;
            }
            for paper in &papers {
                for &i in &nums {
                    if let Some(Tok::Num(v)) = ts.get(i) {
                        push(paper, *v, unit(&ts, i), &mut out);
                    }
                }
            }
        }
        // an instruction: "Limit any motion, response, brief, or memorandum to 6,250 words; limit any reply to 2,500
        // words."; "limiting those to 4,200 words rather than 7,000 words"
        for i in 0..ts.len() {
            let noun = i > 0
                && matches!(ts.get(i - 1), Some(Tok::Word(w)) if ["page", "word", "the", "this", "that", "a", "length", "time"].contains(&w.as_str()));
            if !(is(ts.get(i), "limit") || is(ts.get(i), "limiting")) || noun {
                continue;
            }
            let Some(to) = (i + 1..ts.len().min(i + 12))
                .find(|&j| is(ts.get(j), "to") && matches!(ts.get(j + 1), Some(Tok::Num(_))))
            else {
                continue;
            };
            let Some(Tok::Num(v)) = ts.get(to + 1) else {
                continue;
            };
            let names = named(&ts[i + 1..to]);
            let mut papers = mains(&names);
            let pronoun = ts[i + 1..to]
                .iter()
                .all(|t| matches!(t, Tok::Word(w) if matches!(w.as_str(), "those" | "them" | "these" | "it" | "such")));
            if papers.is_empty() && names.is_empty() && pronoun && i + 1 < to {
                // the paper named nearest before: "an additional limitation on reply briefs, limiting those to"
                papers = (0..i)
                    .rev()
                    .find_map(|k| {
                        let w = word(ts.get(k));
                        if !paper_word(w) {
                            return None;
                        }
                        let w = if generic(w) && paper_word(word(ts.get(k.wrapping_sub(1)))) {
                            word(ts.get(k - 1))
                        } else {
                            w
                        };
                        match named(&[Tok::Word(w.to_string()), Tok::Word("briefs".into())]).first()
                        {
                            Some(Named::Main(p)) => Some(vec![*p]),
                            _ => Some(vec![]),
                        }
                    })
                    .unwrap_or_default();
            }
            if names.contains(&Named::Other) && papers.is_empty() {
                continue;
            }
            for paper in papers {
                push(paper, *v, unit(&ts, to + 1), &mut out);
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
        // the negated limit ("No discovery motion may exceed") is a limit too, of one kind of motion
        assert_eq!(r.len(), 3);
        // instructions: limits and sizes
        let t = "Limit any motion, response, brief, or memorandum to 6,250 words; limit any reply to 2,500 words. Use 14-point font in the body of the briefing and 11-point font for footnotes. Requests to extend the page limit to 30 pages are disfavored.";
        let (f, _) = lengths(t);
        assert_eq!(
            ids(&f),
            [
                v("words.memorandum", 6250.0),
                v("words.opposition", 6250.0),
                v("words.reply", 2500.0)
            ]
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

    fn w(id: &str, n: f64) -> (String, Value) {
        v(id, n)
    }

    #[test]
    fn hard_wrapped_lines_are_joined_into_their_sentences() {
        // pa-ed-slomsky: the feed breaks the line mid-sentence; the fragment about the opposition is no subject
        let (f, _) = lengths("Reply briefs, addressing only issues raised in the brief in opposition and not\nrepeating arguments in the initial brief, may be filed within seven days of service of the\nopponent\u{2019}s brief in opposition and shall be limited to ten pages. No further briefs may be\nfiled.");
        assert_eq!(ids(&f), [w("pages.reply", 10.0)]);
        assert!(f[0]
            .quote
            .starts_with("Reply briefs, addressing only issues"));
        // pa-ed-mj-toplin: the whole sentence is the quote; "sur-" / "reply" joins without a space
        let t = "Memoranda must not exceed twenty-five (25) pages in length (excluding table of \ncontents and appendices), must be double spaced and must use 12-point font. \nMemoranda over fifteen (15) pages in length must include a table of contents and \ntable of authorities.";
        let (f, _) = lengths(t);
        assert_eq!(ids(&f), [w("pages.memorandum", 25.0)]);
        assert_eq!(f[0].quote, "Memoranda must not exceed twenty-five (25) pages in length (excluding table of contents and appendices), must be double spaced and must use 12-point font.");
        let (f, _) = fonts(t);
        assert_eq!(ids(&f), [w("body.exact_pt", 12.0)]);
        assert_eq!(
            sentences("counsel desiring to file a sur-\nreply must first seek permission."),
            ["counsel desiring to file a sur-reply must first seek permission."]
        );
        // a list item and a blank line end a sentence
        assert_eq!(
            sentences(
                "Page limits, absent leave:\n- Opening brief: 25 pages\n- Reply: 10 pages\n\nNext"
            ),
            [
                "Page limits, absent leave:",
                "- Opening brief: 25 pages",
                "- Reply: 10 pages",
                "Next"
            ]
        );
    }

    #[test]
    fn a_floor_carries_over_to_footnotes() {
        // ca-cd court-michelle
        let (f, _) = fonts("Pursuant to the Local Rules, either a proportionally spaced or monospaced font may be used.  A proportionally spaced face must be 14-point or larger, or as the Court may otherwise order.  A monospaced face may not contain more than 10\u{bd} characters per inch.  These typeface requirements apply to footnoted material.");
        assert_eq!(
            ids(&f),
            [w("body.min_pt", 14.0), w("footnote.min_pt", 14.0)]
        );
        // ca-nd-freeman: all text, footnotes included, no less than 12 point
        let (f, _) = fonts("All written text, including footnotes and quotations, shall be no less than 12-point type and shall be double-spaced.");
        assert_eq!(
            ids(&f),
            [w("body.min_pt", 12.0), w("footnote.min_pt", 12.0)]
        );
        // with no body rule before it, nothing to carry over
        let (f, r) = fonts("These typeface requirements apply to footnoted material.");
        assert!(f.is_empty());
        assert_eq!(r.len(), 1);
    }

    #[test]
    fn a_footnote_word_far_from_the_size_is_not_a_footnote_rule() {
        // tx-sd-dj-tipton
        let (f, _) = fonts("Style. Use American letter-size paper, a minimum 12-point font, and a minimum of 1-inch margins with 1/2-inch margins for footnotes, page numbers and any headers or footers. Double space except for lengthy quotations, headings, and footnotes.");
        assert_eq!(ids(&f), [w("body.min_pt", 12.0)]);
        // two sizes and footnotes without " and ": the body's and the footnotes'
        let (f, _) = fonts("Typeface must be Times New Roman, 12 point, footnotes 10 point.");
        assert_eq!(
            ids(&f),
            [
                w("body.exact_pt", 12.0),
                ("body.face".to_string(), Value::from("Times New Roman")),
                w("footnote.exact_pt", 10.0)
            ]
        );
        // under a floor the second size is ambiguous: no footnote fact
        let (f, _) = fonts("Text must be no less than 12 point, footnotes 10 point.");
        assert_eq!(ids(&f), [w("body.min_pt", 12.0)]);
    }

    #[test]
    fn sizes_named_in_other_words_and_inside_a_limit() {
        // pa-ed-sanchez
        let (f, _) = fonts("All papers submitted to the Court shall be formatted in Times New Roman size 12 font with one-inch margins and double-spaced. Footnotes should also be in size 12 font.");
        assert_eq!(
            ids(&f),
            [
                w("body.exact_pt", 12.0),
                ("body.face".to_string(), Value::from("Times New Roman")),
                w("footnote.exact_pt", 12.0)
            ]
        );
        // tx-sd-dj-ganjei: the floor for Times New Roman, not the other faces'; acceptable faces mandate none
        let (f, _) = fonts("Acceptable fonts are Times New Roman size 13 or larger, Book Antiqua size 12 or larger, and Century Schoolbook size 12 or larger.");
        assert_eq!(ids(&f), [w("body.min_pt", 13.0)]);
        // a size inside a limit is required: tx-sd-mj-bennett, tx-sd-mj-palermo, tx-sd-dj-kazen, pa-ed-kearney,
        // pa-ed-beetlestone
        for (t, n) in [
            ("Without leave of court, all motions are limited to 25 double-spaced pages with 13-point font and 1\" margins.", 13.0),
            ("Without leave of Court, all memoranda of law are limited to 25 pages, 14-point type-font, double-spaced, with 1\" margins.", 14.0),
            ("Without leave of Court, all memoranda of law are limited to 25 pages, 12-point type font, double-spaced, with 1\" margins.", 12.0),
            ("Memoranda filed in support of, or in opposition to, a motion is limited to twenty pages of double-spaced twelve-point font.", 12.0),
            ("Briefs and Memoranda: Any brief or memorandum filed in support of or in opposition to a motion must be limited to thirty (30) pages of double-spaced 12-font text, excluding the table of contents and any attachments or addenda.", 12.0),
        ] {
            assert_eq!(ids(&fonts(t).0), [w("body.exact_pt", n)], "{t}");
        }
        let (f, _) = lengths("Without leave of court, all motions are limited to 25 double-spaced pages with 13-point font and 1\" margins.");
        assert_eq!(ids(&f), [w("pages.memorandum", 25.0)]);
    }

    #[test]
    fn a_face_is_mandated_only_by_a_mandatory_sentence_naming_one_face() {
        let face = || ("body.face".to_string(), Value::from("Times New Roman"));
        // fl-sd-gayles, fl-sd-ruiz-ii; pa-ed-weilheimer
        let (f, _) = fonts("Unless otherwise specified by the Court, every motion, response, and reply shall be double-spaced in Times New Roman 12-point typeface.");
        assert_eq!(ids(&f), [w("body.exact_pt", 12.0), face()]);
        let (f, _) = fonts("All documents shall be filed in 12-point Times New Roman font, double spaced with one-inch margins and numbered pages.");
        assert_eq!(ids(&f), [w("body.exact_pt", 12.0), face()]);
        // a rule on the size of Times New Roman is no mandate of the face
        let (f, _) = fonts("Times New Roman font must be no less than fourteen (14) point.");
        assert_eq!(ids(&f), [w("body.min_pt", 14.0)]);
        let (f, _) = fonts("Counsel may use Times New Roman 12-point font.");
        assert!(!ids(&f).contains(&face()));
    }

    #[test]
    fn negated_subjects_and_other_verbs() {
        // ca-cd blumenfeld-stanley
        let (f, _) = lengths("6. General Motion Requirements. c. Length, Footnotes, and Format of Motion Papers. i. Length. Unless otherwise expressly permitted, no supporting or opposing memorandum shall exceed 7,000 words (or 25 pages, double spaced, if handwritten), and no reply memorandum shall exceed 4,000 words (or 15 pages, double spaced, if handwritten) \u{2014} excluding only indices and exhibits. Counsel shall certify compliance with the word count pursuant to Local Rule 11-6.2. Good cause to extend these limitations will rarely be found.");
        assert_eq!(
            ids(&f),
            [
                w("words.memorandum", 7000.0),
                w("words.opposition", 7000.0),
                w("words.reply", 4000.0),
                flag("certificate.required")
            ]
        );
        // tx-sd-mj-ho
        let (f, _) = lengths("Primary briefs cannot exceed 6,500 words, and reply briefs are limited to 2,500 words. The word count limit includes headings and footnotes, but excludes the caption of the case, title of the document, table of contents, table of authorities, signature blocks, and certificates.");
        assert_eq!(
            ids(&f),
            [w("words.memorandum", 6500.0), w("words.reply", 2500.0)]
        );
        // pa-ed-bartle; tx-sd-dj-lake; "shall not total more than" (pa-ed-sanchez, pa-ed-perez)
        let (f, _) = lengths("Except with leave of Court for good cause shown, no supporting brief and no brief in opposition shall exceed twenty-five (25) pages and no reply brief shall exceed fifteen (15) pages.");
        assert_eq!(
            ids(&f),
            [
                w("pages.memorandum", 25.0),
                w("pages.opposition", 25.0),
                w("pages.reply", 15.0)
            ]
        );
        let (f, _) = lengths("Without leave of court no motion, memorandum of law, or brief may exceed 25 total pages. This 25-page limitation includes all statements of fact and all factual and legal arguments. Motions, memoranda of law, and briefs that are 10 pages or less must contain items (3), (4), (5), (6), (7), and (8) listed below.");
        assert_eq!(ids(&f), [w("pages.memorandum", 25.0)]);
        let (f, _) = lengths("Any motion and its supporting memorandum of law, as well as opposition briefs, shall not total more than 20 pages.");
        assert_eq!(
            ids(&f),
            [w("pages.memorandum", 20.0), w("pages.opposition", 20.0)]
        );
        // "may exceed" without a negated subject is no limit (pa-ed-murphy)
        let (f, r) = lengths("Counsel may exceed the page limits (e.g., to include figures or diagrams) without leave if an appropriate word count certification is included.");
        assert!(f.is_empty() && r.is_empty());
        // "N pages or fewer" after "must be" (tx-sd-dj-ellison)
        let (f, _) = lengths("The Court will accept replies without leave of Court with the following stipulations: (A) The Reply should be filed within seven (7) days of the date the Response was filed. (B) The Reply must be ten (10) pages or fewer.");
        assert_eq!(ids(&f), [w("pages.reply", 10.0)]);
    }

    #[test]
    fn certificates_ordered_in_other_words() {
        for t in [
            "A certification of compliance is required as set forth in Local Rule 11-6.2.",
            "PROVIDE A CERTIFICATE OF WORD COUNT FOLLOWING THE SIGNATURE BLOCK.",
            "Provide a certificate of word count following the signature block.",
        ] {
            assert_eq!(ids(&lengths(t).0), [flag("certificate.required")], "{t}");
        }
        // a certificate that may be given is not ordered
        assert!(lengths("A party may include a certificate of compliance.")
            .0
            .is_empty());
    }

    #[test]
    fn each_paper_a_subject_names_and_only_those() {
        let (f, _) = lengths("Opposition and reply briefs shall not exceed 3,500 words.");
        assert_eq!(
            ids(&f),
            [w("words.opposition", 3500.0), w("words.reply", 3500.0)]
        );
        let (f, _) =
            lengths("The memorandum in opposition to the motion shall not exceed 10 pages.");
        assert_eq!(ids(&f), [w("pages.opposition", 10.0)]);
        // the memorandum, which an opposition may accompany: ca-nd-lin, ca-nd-tigar, pa-ed-gallagher, pa-ed-wolson
        let (f, _) = lengths("For all other motions, the briefs in support of and in opposition to the motions may not exceed 15 pages, and reply briefs may not exceed 10 pages.");
        assert_eq!(
            ids(&f),
            [w("pages.memorandum", 15.0), w("pages.reply", 10.0)]
        );
        let (f, _) = lengths("For all other types of motions, the opening and opposition briefs must be no more than 15 pages, and the reply brief must be no more than 10 pages.");
        assert_eq!(
            ids(&f),
            [
                w("pages.memorandum", 15.0),
                w("pages.opposition", 15.0),
                w("pages.reply", 10.0)
            ]
        );
        let (f, _) = lengths("Opening briefs filed in support of and in opposition to a motion should be limited to twenty pages. This includes the table of contents and any attachments or addenda.");
        assert_eq!(ids(&f), [w("pages.memorandum", 20.0)]);
        // a condition is no limit (pa-ed-wolson)
        let (f, _) = lengths("Opening briefs in support of and in opposition to a motion shall not exceed 25 pages, unless counsel includes a certification that the brief contains no more than 8,750 words.");
        assert_eq!(ids(&f), [w("pages.memorandum", 25.0)]);
        // ca-nd-white: the general limit for every brief, the summary-judgment heading set apart
        let (f, r) = lengths("Motions. Except for motions for summary judgment and claim construction briefs, all briefs, whether in support of, in opposition to, or in reply to any motion may not exceed fifteen (15) pages in length. The title page, indices of cases, table of contents, and exhibits are not included in this page limitation. Motions for Summary Judgment. All issues shall be contained within one motion, shall not exceed twenty-five (25) pages in length, and shall conform with Civil Local Rule 7-2.");
        assert_eq!(
            ids(&f),
            [w("pages.memorandum", 15.0), w("pages.reply", 15.0)]
        );
        assert_eq!(r.len(), 1, "{r:?}");
        // ca-nd-donato: an exception set aside, the narrow sentence after it
        let (f, r) = lengths("Except for summary judgment and class certification motions, opening and opposition briefs may not exceed 15 pages, and reply briefs may not exceed 10 pages. For summary judgment and class certification motions, opening and opposition briefs may not exceed 25 pages, and reply briefs may not exceed 15 pages.");
        assert_eq!(
            ids(&f),
            [
                w("pages.memorandum", 15.0),
                w("pages.opposition", 15.0),
                w("pages.reply", 10.0)
            ]
        );
        assert_eq!(r.len(), 1);
        // the coordinated verb keeps its subject; the papers raised in it are objects (pa-ed-mj-arteaga)
        let (f, _) = lengths("Memoranda must not exceed 30 pages in length (excluding table of contents and appendices), must be double spaced and must use 12-point font. Memoranda over 15 pages in length must include a table of contents and table of authorities. Any reply brief is limited to the issues raised in the response, may not raise theories or issues not discussed in the original motion, and shall not exceed fifteen pages absent leave of Court.");
        assert_eq!(
            ids(&f),
            [w("pages.memorandum", 30.0), w("pages.reply", 15.0)]
        );
        // a summary's limit is the summary's (tx-sd-dj-hittner)
        let (f, _) = lengths("Each memorandum or brief filed in the Court shall be limited to 20 pages. Any memorandum that is more than 15 pages must be accompanied by a concise summary, no longer than 3 pages, narrowing the points in the brief.");
        assert_eq!(ids(&f), [w("pages.memorandum", 20.0)]);
        // a reply in support of a motion is the reply
        let (f, _) = lengths("A party desiring to file a reply in support of any Motion may do so within seven (7) days of service of the brief responding to the Motion, limited to 15 pages.");
        assert_eq!(ids(&f), [w("pages.reply", 15.0)]);
    }

    #[test]
    fn replies_beside_sur_replies_and_supplemental_briefs() {
        // pa-ed-henry, pa-ed-scott
        let (f, _) = lengths("Reply or supplemental briefings must not exceed ten (10) pages and must be limited to new concerns raised by the response brief.");
        assert_eq!(ids(&f), [w("pages.reply", 10.0)]);
        // pa-ed-gallagher, pa-ed-marston: respectively
        let (f, _) = lengths("Replies and sur-replies, where granted, must be limited to ten and seven pages, respectively.");
        assert_eq!(ids(&f), [w("pages.reply", 10.0)]);
        let (f, _) = lengths("Replies and sur-replies must be limited to ten (10) and seven (7) pages, respectively.");
        assert_eq!(ids(&f), [w("pages.reply", 10.0)]);
        // pa-ed-younge; a sur-reply's own limit is no reply's
        let (f, _) = lengths("Reply briefs and sur-reply briefs, addressing only issues raised in the brief in opposition and not repeating arguments in briefs that were previously filed by the movant, may be filed within seven days of service of the opponent's brief in opposition/reply and shall be limited to ten pages. The sur-reply brief may not exceed five (5) pages.");
        assert_eq!(ids(&f), [w("pages.reply", 10.0)]);
        let (f, _) = lengths("Replies shall not exceed 10 pages or 3,500 words, and sur-replies shall not exceed seven pages or 2,450 words.");
        assert_eq!(ids(&f), [w("pages.reply", 10.0), w("words.reply", 3500.0)]);
    }

    #[test]
    fn one_kind_of_motion_is_no_general_limit() {
        for t in [
            // pa-ed-henry: dispositive motions, and "twenty (25)"
            "Any dispositive motion and its supporting memorandum of law must not exceed twenty (25) pages.",
            // ca-nd-freeman
            "Daubert motions may not exceed 10 pages per expert, and each side is limited to a total of 25 pages for Daubert motions.",
            "Memoranda in support of motions for summary judgment shall not exceed 30 pages.",
            "Briefs on discovery motions shall not exceed 5 pages.",
            "A motion for leave to file a surreply must be filed within seven days of the filing of the reply brief and must be no more than 5 pages.",
            // ca-cd valenzuela-cynthia: a label anywhere before the sentence
            "Only rarely and for good cause shown will the Court grant an application to extend these page limitations. [See Judge Valenzuela's Order Re: Motions for Summary Judgment regarding the length and format of motions for summary judgment: MSJ \u{a7}1.c Word Limit: Each separately represented party shall be limited to 7,000 words, exclusive of tables of contents and authorities.]",
        ] {
            let (f, r) = lengths(t);
            assert!(f.is_empty(), "{t}: {f:?}");
            assert!(r.iter().any(|r| r.starts_with("(of one kind of motion)")), "{t}: {r:?}");
        }
        // besides one kind of motion, the general limit (ca-cd hsu-wesley; pa-ed-weilheimer)
        let (f, _) = lengths("Memoranda of points and authorities in support of or in opposition to motions (besides motions in limine) shall not exceed 7,000 words.");
        assert_eq!(ids(&f), [w("words.memorandum", 7000.0)]);
        let (f, _) = lengths("With the exceptions of motions in limine, briefs and memoranda filed in support of or in opposition to a motion are limited to 25 pages in length.");
        assert_eq!(ids(&f), [w("pages.memorandum", 25.0)]);
        // a number whose words and digits disagree is no number
        let (f, r) = lengths(
            "Any motion and its supporting memorandum of law must not exceed twenty (25) pages.",
        );
        assert!(f.is_empty());
        assert_eq!(r.len(), 1);
        // a label's words are no part of the subject (ca-cd birotte-andre)
        let (f, _) = lengths("Motions \u{2013} General Requirements. c. Length and Format of Motion Papers: Replies must not exceed 15 pages.");
        assert_eq!(ids(&f), [w("pages.reply", 15.0)]);
    }

    #[test]
    fn list_items_and_limits_said_of_those_papers() {
        // pa-ed-murphy
        let (f, _) = lengths("Page limits, absent leave:\n- Opening brief: 25 pages or 6,250 words\n- Response/opposition: 25 pages or 6,250 words\n- Reply: 10 pages or 2,500 words\nCounsel may exceed the page limits (e.g., to include figures or diagrams) without leave if an appropriate word count certification is included.");
        assert_eq!(
            ids(&f),
            [
                w("pages.memorandum", 25.0),
                w("words.memorandum", 6250.0),
                w("pages.opposition", 25.0),
                w("words.opposition", 6250.0),
                w("pages.reply", 10.0),
                w("words.reply", 2500.0)
            ]
        );
        assert_eq!(f[0].quote, "Opening brief: 25 pages or 6,250 words");
        // ca-cd staton-josephine: "limiting those" is the reply briefs named before
        let (f, _) = lengths("8.c. Limitations on Briefing. Limitations on the length of briefs are specified in Local Civil Rule 11-6.1. A certification of compliance is required as set forth in Local Rule 11-6.2. In addition, because reply briefs should by their nature be shorter than motion and opposition briefs, the Court imposes an additional limitation on reply briefs, limiting those to 4,200 words rather than 7,000 words.");
        assert_eq!(
            ids(&f),
            [flag("certificate.required"), w("words.reply", 4200.0)]
        );
        // a response to a letter is no opposition (nj-d-dj-ohearn); objections to a report are another proceeding
        for t in [
            "Within seven (7) days after receipt of this letter, all adversaries must submit a written response, not to exceed three (3) single-spaced pages.",
            "Objections to a Magistrate Judge's Report and Recommendation and Responses to those Objections shall be limited to fifteen (15) pages, absent special permission of the Court.",
        ] {
            assert!(lengths(t).0.is_empty(), "{t}");
        }
    }
}
