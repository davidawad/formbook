//! Parsing and scoring of the manifest lines (one per court, one per doc type).
//!
//! Mirrors tools/tracker.bend: lines split on '\n' only, fields on '|'; a court line needs at
//! least seven fields and a doc-type line at least five (extra fields are ignored, shorter lines
//! dropped). Flags are compared as characters (Unicode scalar values, as Bend's String holds them).

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

/// One court line. `engines` is `None` when the flags have fewer than eight characters: bend then
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

/// One doc-type line. `bits` = template, sample, render, exemplar, overlay, gates (0/1 each);
/// `samples` / `exemplars` are the raw count characters.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct DocType {
    pub alias: String,
    pub group: String,
    pub doctype: String,
    pub path: String,
    pub samples: char,
    pub exemplars: char,
    pub bits: [u32; 6],
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

/// `round(items / 8 * 100)` with halves rounded up, as integer arithmetic.
pub fn percent(items: u32) -> u32 {
    (items * 100 + 4) / 8
}

/// Status, percent, engine states and checklist bits from the manual field and the flags.
pub fn score(manual: &str, flags: &str) -> (Status, u32, Option<[char; 3]>, String) {
    let cs: Vec<char> = flags.chars().collect();
    let [r, e, s, t, l, d, o, v] = match cs.get(..8) {
        Some(&[r, e, s, t, l, d, o, v]) => [r, e, s, t, l, d, o, v],
        _ => return (Status::Todo, 0, None, String::new()),
    };
    let xs = [
        is(r, '1'),
        ge2(e),
        ge2(s),
        is(t, '2'),
        is(l, '2'),
        is(d, '2'),
        is(o, '1'),
        is(v, '1'),
    ];
    let present: u32 = xs.iter().sum();
    let any = cs[..8].iter().any(|&c| c != '0');
    let status = if manual == "done" {
        Status::Done
    } else if xs[0] * xs[3] == 1 {
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

/// Doc-type bits from the flags; `None` (line dropped) for fewer than five characters.
pub fn doc_bits(flags: &str) -> Option<(char, char, [u32; 6])> {
    let cs: Vec<char> = flags.chars().take(5).collect();
    match cs[..] {
        [t, s, r, e, o] => Some((
            s,
            e,
            [is(t, '1'), nz(s), nz(r), nz(e), is(o, '1'), is(r, '2')],
        )),
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
        alias: alias.into(),
        group: group.into(),
        doctype: doctype.into(),
        path: path.into(),
        samples,
        exemplars,
        bits,
    })
}

/// 1 iff template, sample, render, exemplar and overlay are all present.
pub fn complete(bits: &[u32; 6]) -> u32 {
    bits[..5].iter().product()
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
        assert_eq!(st("todo", "00000000"), ("todo", 0, "00000000".into()));
        assert_eq!(
            st("todo", "01000000"),
            ("in progress", 0, "00000000".into())
        );
        assert_eq!(
            st("todo", "10020000"),
            ("up for review", 25, "10010000".into())
        );
        assert_eq!(
            st("todo", "10200000"),
            ("in progress", 25, "10100000".into())
        );
        assert_eq!(
            st("todo", "00020000"),
            ("in progress", 13, "00010000".into())
        );
        assert_eq!(st("done", "00000000"), ("done", 100, "00000000".into()));
        assert_eq!(
            st("in progress", "00000000"),
            ("todo", 0, "00000000".into())
        );
        assert_eq!(
            st("Done", "11111111"),
            ("in progress", 38, "10000011".into())
        );
        // fewer than eight flags: todo, 0, no items, even when done
        assert_eq!(st("done", "1922222"), ("todo", 0, String::new()));
        // extra characters are ignored; any non-'0' character counts as present
        assert_eq!(st("todo", "000000001"), ("todo", 0, "00000000".into()));
        assert_eq!(
            st("todo", "0x000000"),
            ("in progress", 13, "01000000".into())
        );
    }

    #[test]
    fn percent_rounds_halves_up() {
        let got: Vec<u32> = (0..=8).map(percent).collect();
        assert_eq!(got, [0, 13, 25, 38, 50, 63, 75, 88, 100]);
        assert_eq!(
            st("todo", "19922211"),
            ("up for review", 100, "11111111".into())
        );
        assert_eq!(
            st("todo", "12900110"),
            ("in progress", 50, "11100010".into())
        );
    }

    #[test]
    fn exemplar_counts() {
        let it = |e: char| st("todo", &format!("0{e}000000")).2;
        assert_eq!(
            [it('0'), it('1'), it('2'), it('9')],
            ["00000000", "00000000", "01000000", "01000000"]
        );
    }

    #[test]
    fn court_fields() {
        assert!(court("").is_none());
        assert!(court("a|g|l|n|p|todo").is_none());
        let c = court("a|g|l|n|p|todo|00012000|extra").unwrap();
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
        assert_eq!(doc_bits("111110"), Some(('1', '1', [1, 1, 1, 1, 1, 0])));
        assert_eq!(doc_bits("19291"), Some(('9', '9', [1, 1, 1, 1, 1, 1])));
        assert_eq!(doc_bits("01000"), Some(('1', '0', [0, 1, 0, 0, 0, 0])));
        assert_eq!(doc_bits("1111"), None);
        assert!(doctype("a|g|dt|p").is_none());
        assert!(doctype("a|g|dt|p|1111").is_none());
        assert_eq!(complete(&[1, 1, 1, 1, 1, 0]), 1);
        assert_eq!(complete(&[1, 1, 1, 1, 0, 1]), 0);
    }
}
