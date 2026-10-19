//! Parsing and scoring of the manifest lines (one per court, one per doc type).
//!
//! Mirrors tools/tracker.bend: lines split on '\n' only, fields on '|'; a court line needs at
//! least seven fields and a doc-type line at least five (extra fields are ignored, shorter lines
//! dropped). Flags are compared as characters (Unicode scalar values, as Bend's String holds them).
//! Overlays are no longer committed, so neither flag string carries an overlay character: courts have
//! seven checklist items, doc types four. A court's flags carry an eighth character (docs: '0' no doc folder
//! has an INPUT, '1' some do but not every one passes its typst eval, '2' every one with an INPUT passes and
//! at least one exists); a court is "up for review" when rules.md is present and docs is '2'.

/// Court status, in increasing order of completion.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Status {
    Todo,
    InProgress,
    Review,
    Done,
}

impl Status {
    pub fn name(self) -> &'static str {
        match self {
            Status::Done => "done",
            Status::Review => "up for review",
            Status::InProgress => "in progress",
            Status::Todo => "todo",
        }
    }
}

/// One court line. `engines` is `None` when the flags have fewer than seven characters: bend then
/// scores the court as todo/0 even when court.json says done, and prints no checklist items.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Court {
    pub alias: String,
    pub group: String,
    pub name: String,
    pub path: String,
    pub status: Status,
    pub pct: u32,
    pub engines: Option<[char; 3]>,
    pub items: String,
}

/// One doc-type line (its status: up for review when its typst stamp is valid, in progress when anything is
/// present, todo otherwise; "done" belongs to courts and is set by hand). `bits` = template, sample, render, exemplar, gates (0/1 each);
/// `samples` / `exemplars` are the raw count characters (INPUT files, FILED-EXAMPLEs named in SOURCE.md).
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct DocType {
    pub status: Status,
    pub alias: String,
    pub group: String,
    pub doctype: String,
    pub path: String,
    pub samples: char,
    pub exemplars: char,
    pub bits: [u32; 5],
}

fn is(c: char, k: char) -> u32 {
    u32::from(c == k)
}

/// 1 for any character other than '0'.
fn nz(c: char) -> u32 {
    1 - is(c, '0')
}

/// 1 for a count character of at least 2 (anything but '0' and '1').
fn ge2(c: char) -> u32 {
    1 - (is(c, '0') + is(c, '1'))
}

fn bit(x: u32) -> char {
    if x == 1 {
        '1'
    } else {
        '0'
    }
}

/// Court checklist items: rules, sources, inputs, typst, latex, docx, review.
pub const ITEMS: u32 = 7;

/// `round(items / 7 * 100)` with halves rounded up, as integer arithmetic.
pub fn percent(items: u32) -> u32 {
    (items * 200 + ITEMS) / (2 * ITEMS)
}

/// Status, percent, engine states and checklist bits from the manual field and the flags.
pub fn score(manual: &str, flags: &str) -> (Status, u32, Option<[char; 3]>, String) {
    let cs: Vec<char> = flags.chars().collect();
    let docs = cs.get(7).copied().unwrap_or('0');
    let [r, e, s, t, l, d, v] = match cs.get(..7) {
        Some(&[r, e, s, t, l, d, v]) => [r, e, s, t, l, d, v],
        _ => return (Status::Todo, 0, None, String::new()),
    };
    let xs = [
        is(r, '1'),
        ge2(e),
        ge2(s),
        is(t, '2'),
        is(l, '2'),
        is(d, '2'),
        is(v, '1'),
    ];
    let present: u32 = xs.iter().sum();
    let any = cs[..7].iter().any(|&c| c != '0') || docs != '0';
    let status = if manual == "done" {
        Status::Done
    } else if xs[0] == 1 && docs == '2' {
        Status::Review
    } else if any {
        Status::InProgress
    } else {
        Status::Todo
    };
    let pct = if status == Status::Done {
        100
    } else {
        percent(present)
    };
    (
        status,
        pct,
        Some([t, l, d]),
        xs.iter().map(|&x| bit(x)).collect(),
    )
}

pub fn court(line: &str) -> Option<Court> {
    let fs: Vec<&str> = line.split('|').collect();
    let [alias, group, _level, name, path, manual, flags] = match fs.get(..7) {
        Some(&[a, g, lv, n, p, m, f]) => [a, g, lv, n, p, m, f],
        _ => return None,
    };
    let (status, pct, engines, items) = score(manual, flags);
    Some(Court {
        alias: alias.into(),
        group: group.into(),
        name: name.into(),
        path: path.into(),
        status,
        pct,
        engines,
        items,
    })
}

/// Doc-type bits from the flags (template, inputs, render, sources; a fifth review character is
/// ignored); `None` (line dropped) for fewer than four characters.
pub fn doc_bits(flags: &str) -> Option<(char, char, [u32; 5])> {
    let cs: Vec<char> = flags.chars().take(4).collect();
    match cs[..] {
        [t, s, r, e] => Some((s, e, [is(t, '1'), nz(s), nz(r), nz(e), is(r, '2')])),
        _ => None,
    }
}

pub fn doctype(line: &str) -> Option<DocType> {
    let fs: Vec<&str> = line.split('|').collect();
    let [alias, group, doctype, path, flags] = match fs.get(..5) {
        Some(&[a, g, dt, p, f]) => [a, g, dt, p, f],
        _ => return None,
    };
    let (samples, exemplars, bits) = doc_bits(flags)?;
    Some(DocType {
        status: doc_status(&bits),
        alias: alias.into(),
        group: group.into(),
        doctype: doctype.into(),
        path: path.into(),
        samples,
        exemplars,
        bits,
    })
}

/// A doc folder's status from its bits (template, sample, render, exemplar, gates).
pub fn doc_status(bits: &[u32; 5]) -> Status {
    match (bits[4], bits[..4].iter().sum::<u32>()) {
        (1, _) => Status::Review,
        (_, 0) => Status::Todo,
        _ => Status::InProgress,
    }
}

/// 1 iff template, sample, render and exemplar are all present.
pub fn complete(bits: &[u32; 5]) -> u32 {
    bits[..4].iter().product()
}

pub fn courts(text: &str) -> Vec<Court> {
    text.split('\n').filter_map(court).collect()
}

pub fn doctypes(text: &str) -> Vec<DocType> {
    text.split('\n').filter_map(doctype).collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    fn st(manual: &str, flags: &str) -> (&'static str, u32, String) {
        let (s, p, _, it) = score(manual, flags);
        (s.name(), p, it)
    }

    #[test]
    fn status_rules() {
        assert_eq!(st("todo", "0000000"), ("todo", 0, "0000000".into()));
        assert_eq!(st("todo", "0100000"), ("in progress", 0, "0000000".into()));
        // up for review needs rules.md and docs '2' (every doc folder with an INPUT passes), not the court-root typst stamp
        assert_eq!(
            st("todo", "10020002"),
            ("up for review", 29, "1001000".into())
        );
        assert_eq!(
            st("todo", "10020001"),
            ("in progress", 29, "1001000".into())
        );
        assert_eq!(st("todo", "1002000"), ("in progress", 29, "1001000".into()));
        assert_eq!(st("todo", "00000002"), ("in progress", 0, "0000000".into()));
        assert_eq!(st("done", "00000000"), ("done", 100, "0000000".into()));
        assert_eq!(st("todo", "1020000"), ("in progress", 29, "1010000".into()));
        assert_eq!(st("todo", "0002000"), ("in progress", 14, "0001000".into()));
        assert_eq!(st("done", "0000000"), ("done", 100, "0000000".into()));
        assert_eq!(st("in progress", "0000000"), ("todo", 0, "0000000".into()));
        assert_eq!(st("Done", "1111111"), ("in progress", 29, "1000001".into()));
        // fewer than seven flags: todo, 0, no items, even when done
        assert_eq!(st("done", "192222"), ("todo", 0, String::new()));
        // a ninth character is ignored; any non-'0' character counts as present
        assert_eq!(st("todo", "000000009"), ("todo", 0, "0000000".into()));
        assert_eq!(st("todo", "00000001"), ("in progress", 0, "0000000".into()));
        assert_eq!(st("todo", "0x00000"), ("in progress", 14, "0100000".into()));
    }

    #[test]
    fn percent_rounds_halves_up() {
        let got: Vec<u32> = (0..=7).map(percent).collect();
        assert_eq!(got, [0, 14, 29, 43, 57, 71, 86, 100]);
        assert_eq!(
            st("todo", "19922212"),
            ("up for review", 100, "1111111".into())
        );
        assert_eq!(st("todo", "1290010"), ("in progress", 43, "1110000".into()));
    }

    #[test]
    fn source_counts() {
        let it = |e: char| st("todo", &format!("0{e}00000")).2;
        assert_eq!(
            [it('0'), it('1'), it('2'), it('9')],
            ["0000000", "0000000", "0100000", "0100000"]
        );
    }

    #[test]
    fn court_fields() {
        assert!(court("").is_none());
        assert!(court("a|g|l|n|p|todo").is_none());
        let c = court("a|g|l|n|p|todo|0001200|extra").unwrap();
        assert_eq!(c.engines, Some(['1', '2', '0']));
        assert_eq!((c.alias.as_str(), c.status), ("a", Status::InProgress));
        let e = court("a||l|n|p|done|").unwrap();
        assert_eq!(
            (e.group.as_str(), e.status, e.pct, e.engines),
            ("", Status::Todo, 0, None)
        );
    }

    #[test]
    fn doctype_bits() {
        assert_eq!(doc_bits("11110"), Some(('1', '1', [1, 1, 1, 1, 0])));
        assert_eq!(doc_bits("1929"), Some(('9', '9', [1, 1, 1, 1, 1])));
        assert_eq!(doc_bits("01001"), Some(('1', '0', [0, 1, 0, 0, 0])));
        assert_eq!(doc_bits("111"), None);
        assert!(doctype("a|g|dt|p").is_none());
        assert!(doctype("a|g|dt|p|111").is_none());
        assert_eq!(complete(&[1, 1, 1, 1, 0]), 1);
        assert_eq!(doc_status(&[0, 0, 0, 0, 0]), Status::Todo);
        assert_eq!(doc_status(&[0, 1, 0, 0, 0]), Status::InProgress);
        assert_eq!(doc_status(&[1, 1, 1, 1, 1]), Status::Review);
        assert_eq!(doc_status(&[0, 0, 0, 0, 1]), Status::Review);
        assert_eq!(complete(&[1, 1, 1, 0, 1]), 0);
    }
}
