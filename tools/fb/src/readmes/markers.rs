//! Generated text lives between `<!-- fb:generated:start -->` and `<!-- fb:generated:end -->`; every byte
//! outside the markers belongs to people and is kept. A README without markers (first run) is split
//! into the lines the generator wrote and the hand-written runs between them; the hand-written runs are
//! kept, in order, after the end marker.
pub const START: &str = "<!-- fb:generated:start -->";
pub const END: &str = "<!-- fb:generated:end -->";

/// Checklist wording written by tools/gen_readmes.py before the text keys (fb-9qhl): still generated.
const RENAMED: [(&str, &str); 2] = [
    (
        "`exemplars/` has at least 2 filed PDFs (different filers)",
        "`exemplars/SOURCE.md` names at least 2 filed exemplars (different filers)",
    ),
    (
        "overlay PDF present (`samples/*-overlay.pdf`)",
        "overlay present (`samples/OVERLAY-*.txt`)",
    ),
];

/// The new file text for a README whose generated part is `generated`, given its current text.
pub fn place(current: Option<&str>, generated: &str) -> Result<String, String> {
    match current.map(|s| (s, s.find(START), s.find(END))) {
        None => Ok(wrap(generated)),
        Some((s, Some(a), Some(b))) if a < b => {
            Ok(format!("{}{START}\n{generated}{}", &s[..a], &s[b..]))
        }
        Some((s, None, None)) => Ok(wrap(generated) + &hand_written(s, generated).concat()),
        Some(_) => Err(format!("unbalanced {START} / {END} markers")),
    }
}

fn wrap(generated: &str) -> String {
    format!("{START}\n{generated}{END}\n")
}

/// The hand-written runs of `old` (lines the generator did not write), each as "\n<run>\n", trimmed of
/// blank lines at both ends. Generated lines are matched by kind, so a line whose value changed since
/// (a status, a checklist mark, a table row) still counts as generated.
pub fn hand_written(old: &str, generated: &str) -> Vec<String> {
    let e: Vec<&str> = old.lines().collect();
    let g: Vec<&str> = generated.lines().collect();
    let matched = lcs_matched(
        &e.iter().map(|l| kind(l)).collect::<Vec<_>>(),
        &g.iter().map(|l| kind(l)).collect::<Vec<_>>(),
    );
    let runs = e
        .iter()
        .zip(&matched)
        .fold(vec![Vec::new()], |mut runs: Vec<Vec<&str>>, (l, m)| {
            match (m, runs.last_mut()) {
                (false, Some(run)) => run.push(l),
                _ => runs.push(Vec::new()),
            }
            runs
        });
    runs.iter()
        .map(|run| trim_blank(run))
        .filter(|run| !run.is_empty())
        .map(|run| format!("\n{}\n", run.join("\n")))
        .collect()
}

fn trim_blank<'a>(run: &'a [&'a str]) -> &'a [&'a str] {
    let start = run
        .iter()
        .position(|l| !l.trim().is_empty())
        .unwrap_or(run.len());
    let end = run
        .iter()
        .rposition(|l| !l.trim().is_empty())
        .map_or(start, |i| i + 1);
    &run[start..end]
}

/// The comparison key of a line: lines with values that change between runs compare by their fixed part.
pub fn kind(line: &str) -> String {
    let fixed = [
        "- Status: **",
        "Engines: typst `",
        "- CourtListener: ",
        "- Level: ",
        "- Circuit: ",
        "- State / territory: ",
        "- Parent: ",
        "- Legacy aliases: ",
        "Courts under `",
    ];
    if let Some(p) = fixed.iter().find(|p| line.starts_with(*p)) {
        return (*p).to_string();
    }
    if let Some(desc) = line
        .strip_prefix("- [x] ")
        .or_else(|| line.strip_prefix("- [ ] "))
    {
        let desc = RENAMED
            .iter()
            .find(|(old, _)| *old == desc)
            .map_or(desc, |(_, new)| new);
        return format!("- [?] {desc}");
    }
    // a court table row: "| [Name](link) | `alias` | ..." keys on its alias cell
    match (line.starts_with("| ["), line.find(" | `")) {
        (true, Some(i)) => line[i..]
            .split(" | ")
            .nth(1)
            .map_or(line.to_string(), |a| format!("| row {a}")),
        _ => line.to_string(),
    }
}

/// For each element of `a`, whether a longest common subsequence with `b` uses it.
fn lcs_matched(a: &[String], b: &[String]) -> Vec<bool> {
    let (n, m) = (a.len(), b.len());
    let mut t = vec![vec![0u32; m + 1]; n + 1];
    (0..n).rev().for_each(|i| {
        (0..m).rev().for_each(|j| {
            t[i][j] = if a[i] == b[j] {
                t[i + 1][j + 1] + 1
            } else {
                t[i + 1][j].max(t[i][j + 1])
            };
        })
    });
    let mut used = vec![false; n];
    let (mut i, mut j) = (0, 0);
    while i < n && j < m {
        if a[i] == b[j] {
            used[i] = true;
            i += 1;
            j += 1;
        } else if t[i + 1][j] >= t[i][j + 1] {
            i += 1;
        } else {
            j += 1;
        }
    }
    used
}

#[cfg(test)]
mod tests {
    use super::*;

    const GEN: &str = "# C\n\n- Status: **todo** (0%)\n- [ ] `rules.md` present\n\nEngines: typst `—`.\n\n`done` is set\n";

    #[test]
    fn new_file_is_wrapped() {
        assert_eq!(
            place(None, "x\n").as_deref(),
            Ok("<!-- fb:generated:start -->\nx\n<!-- fb:generated:end -->\n")
        );
    }

    #[test]
    fn outside_bytes_are_kept() {
        let cur = "top\n<!-- fb:generated:start -->\nold\n<!-- fb:generated:end -->\n\n## Typeface\n\nmine";
        assert_eq!(
            place(Some(cur), "new\n").as_deref(),
            Ok("top\n<!-- fb:generated:start -->\nnew\n<!-- fb:generated:end -->\n\n## Typeface\n\nmine")
        );
    }

    #[test]
    fn unbalanced_markers_fail() {
        assert!(place(
            Some("<!-- fb:generated:end -->\n<!-- fb:generated:start -->\n"),
            "x\n"
        )
        .is_err());
        assert!(place(Some("<!-- fb:generated:start -->\n"), "x\n").is_err());
    }

    #[test]
    fn first_run_keeps_hand_sections_after_the_block() {
        let old = "# C\n\n- Status: **in progress** (13%)\n- Typeface: none named.\n- [x] `rules.md` present\n\nEngines: typst `built`.\n\nTypeface: EB Garamond.\n\n## Typeface\n\n| a | b |\n\n`done` is set\n";
        let out = place(Some(old), GEN).unwrap_or_default();
        assert_eq!(
            out,
            format!("{START}\n{GEN}{END}\n\n- Typeface: none named.\n\nTypeface: EB Garamond.\n\n## Typeface\n\n| a | b |\n")
        );
        // and the second run changes nothing
        assert_eq!(place(Some(&out), GEN).as_deref(), Ok(out.as_str()));
    }

    #[test]
    fn first_run_on_pure_generated_text_adds_only_markers() {
        assert_eq!(place(Some(GEN), GEN).as_deref(), Ok(wrap(GEN).as_str()));
    }

    #[test]
    fn kinds() {
        assert_eq!(
            kind("- [x] overlay PDF present (`samples/*-overlay.pdf`)"),
            kind("- [ ] overlay present (`samples/OVERLAY-*.txt`)")
        );
        assert_eq!(kind("- [x] a"), kind("- [ ] a"));
        assert_eq!(
            kind("| [A](a) | `a` | todo |"),
            kind("| [A2](b) | `a` | pass |")
        );
        assert_ne!(
            kind("| [A](a) | `a` | todo |"),
            kind("| [A](a) | `b` | todo |")
        );
        assert_eq!(
            kind("| `adversary-complaint/` | none |"),
            "| `adversary-complaint/` | none |"
        );
    }
}
