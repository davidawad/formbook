//! Rule (a): no case text in a template. Every run of N or more words of a template file that also
//! occurs in a filed exemplar's text is reported, unless each N-word window of it also occurs in the
//! court's rules.md (rule text is the source of legally required wording). Windows without a word
//! (no token of three or more letters, e.g. `#1#2#3#4#5` macro arguments) are not text and are skipped.
//! The detail says in how many exemplars the run occurs: a run in every exemplar, from different
//! filers, is usually mandated form wording that rules.md should quote; a run in one is likely case text.
use super::Finding;
use std::collections::{HashMap, HashSet};

pub const N: usize = 5;

/// Lowercased alphanumeric runs with their 1-based line numbers.
pub fn tokens(text: &str) -> Vec<(String, usize)> {
    let mut out = Vec::new();
    for (i, line) in text.lines().enumerate() {
        out.extend(
            line.split(|c: char| !c.is_alphanumeric())
                .filter(|w| !w.is_empty())
                .map(|w| (w.to_lowercase(), i + 1)),
        );
    }
    out
}

/// Every N-word window of a text, joined by spaces.
pub fn grams(text: &str) -> HashSet<String> {
    let t: Vec<String> = tokens(text).into_iter().map(|t| t.0).collect();
    t.windows(N).map(|w| w.join(" ")).collect()
}

/// The windows of every exemplar, with the number of exemplars each occurs in.
#[derive(Default)]
pub struct Corpus {
    pub count: HashMap<String, usize>,
    pub docs: usize,
}

impl Corpus {
    pub fn add(&mut self, text: &str) {
        self.docs += 1;
        for g in grams(text) {
            *self.count.entry(g).or_default() += 1;
        }
    }
}

fn wordy(w: &[(String, usize)]) -> bool {
    w.iter()
        .any(|t| t.0.chars().filter(|c| c.is_alphabetic()).count() >= 3)
}

/// Findings for one template file: maximal runs of consecutive flagged windows.
pub fn check(file: &str, text: &str, ex: &Corpus, rules: &HashSet<String>) -> Vec<Finding> {
    let t = tokens(text);
    let hits: Vec<usize> = t
        .windows(N)
        .map(|w| {
            let g = w.iter().map(|x| x.0.as_str()).collect::<Vec<_>>().join(" ");
            match wordy(w) && !rules.contains(&g) {
                true => ex.count.get(&g).copied().unwrap_or(0),
                false => 0,
            }
        })
        .collect();
    let mut out = Vec::new();
    let mut i = 0;
    while i < hits.len() {
        if hits[i] == 0 {
            i += 1;
            continue;
        }
        let start = i;
        let mut least = usize::MAX;
        while i < hits.len() && hits[i] > 0 {
            least = least.min(hits[i]);
            i += 1;
        }
        let words: Vec<&str> = t[start..i - 1 + N].iter().map(|x| x.0.as_str()).collect();
        let shown = match words.len() > 24 {
            true => format!("{} ... ({} words)", words[..24].join(" "), words.len()),
            false => words.join(" "),
        };
        out.push(Finding {
            kind: "ngram",
            file: file.to_string(),
            line: t[start].1,
            detail: format!(
                "\"{shown}\" occurs in {least} of {} filed exemplars",
                ex.docs
            ),
        });
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn case_text_is_found_and_rule_text_allowed() {
        let mut ex = Corpus::default();
        ex.add("The district court erred in granting the preliminary injunction.\nCERTIFICATE OF COMPLIANCE pursuant to Fed. R. App. P. 32");
        ex.add("Certificate of compliance pursuant to Fed. R. App. P. 32 and 1 2 3 4 5 6");
        let rules = grams("Form 8. Certificate of Compliance pursuant to Fed. R. App. P. 32(g)");
        let tpl = "#let x = 1pt\n// the district court erred in\n// granting the preliminary injunction\n#heading[Certificate of compliance pursuant to Fed. R. App. P. 32]\n#let y = court erred\n\\def\\a#1#2#3#4#5#6{}";
        let f = check("typst/a.typ", tpl, &ex, &rules);
        assert_eq!(f.len(), 1, "{f:?}");
        assert_eq!(f[0].line, 2);
        assert_eq!(
            f[0].detail,
            "\"the district court erred in granting the preliminary injunction\" occurs in 1 of 2 filed exemplars"
        );
        // four shared words are not a finding
        assert!(check("t", "district court erred in", &ex, &rules).is_empty());
        // without the rule text, the shared form wording is reported with its exemplar count
        let f = check("t", "pursuant to Fed. R. App. P.", &ex, &HashSet::new());
        assert!(
            f[0].detail.ends_with("occurs in 2 of 2 filed exemplars"),
            "{f:?}"
        );
        assert_eq!(tokens("Ab-c 9TH\nx").len(), 4);
    }
}
