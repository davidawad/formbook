//! A quoted sentence checked against the court's own document (docs/JUDGES.md): the feed is the index, the order the
//! court hosts is the authority. A source PDF is fetched once into `out/judges-cache/`, read with pdftotext and
//! normalized (pleading-paper line numbers and running footers taken out, lines joined, quotation marks and spaces
//! made plain); a quote is verified when its normalized text is in the document's.
use sha2::{Digest, Sha256};
use std::path::{Path, PathBuf};
use std::process::Command;
use unicode_normalization::UnicodeNormalization;

/// A source document as it is compared.
pub struct Corpus {
    pub sha256: String,
    pub text: String,
}

/// Text as it is compared: compatibility forms folded (ligatures, wide spaces), quotation marks and dashes made
/// ASCII, lower case, every run of white space one space.
pub fn normalize(s: &str) -> String {
    let mut out = String::with_capacity(s.len());
    let mut space = true;
    for c in s.nfkc() {
        let c = match c {
            '\u{2018}' | '\u{2019}' | '\u{201B}' | '\u{2032}' => '\'',
            '\u{201C}' | '\u{201D}' | '\u{201F}' | '\u{2033}' => '"',
            '\u{2010}'..='\u{2015}' | '\u{2212}' => '-',
            '\u{00AD}' => continue,
            c => c,
        };
        if c.is_whitespace() {
            if !space {
                out.push(' ');
            }
            space = true;
        } else {
            out.extend(c.to_lowercase());
            space = false;
        }
    }
    out.trim_end().to_string()
}

/// A line without the pleading-paper number at its left (1 to 28, then two spaces or the line's end).
fn without_line_number(line: &str) -> &str {
    let t = line.trim_start();
    let digits = t.chars().take_while(char::is_ascii_digit).count();
    if digits == 0 || digits > 2 {
        return line;
    }
    let n: u32 = t[..digits].parse().unwrap_or(0);
    let rest = &t[digits..];
    if (1..=28).contains(&n) && (rest.is_empty() || rest.starts_with("  ")) {
        rest
    } else {
        line
    }
}

fn masked(line: &str) -> String {
    line.split_whitespace()
        .collect::<Vec<_>>()
        .join(" ")
        .chars()
        .map(|c| if c.is_ascii_digit() { '#' } else { c })
        .collect()
}

/// The first lines (or the last) that at least two pages and half of them share, digits aside.
fn repeated(pages: &[Vec<&str>], last: bool, n: usize) -> Vec<String> {
    let mut seen: Vec<(String, usize)> = Vec::new();
    for p in pages {
        let line = if last { p.last() } else { p.first() };
        if let Some(l) = line {
            let m = masked(l);
            match seen.iter_mut().find(|(s, _)| *s == m) {
                Some(e) => e.1 += 1,
                None => seen.push((m, 1)),
            }
        }
    }
    seen.into_iter()
        .filter(|(_, k)| *k >= 2 && *k * 2 >= n)
        .map(|(s, _)| s)
        .collect()
}

/// The text of a PDF (`pdftotext -layout`, pages parted by form feeds) as one normalized run: each page without its
/// line numbers and without a first or last line that most pages repeat (a running header or footer, digits aside),
/// a line ending in a hyphen joined to the next without a space ("Local Rule 5-" / "4.2").
pub fn pdf_text(raw: &str) -> String {
    let pages: Vec<Vec<&str>> = raw
        .split('\u{000C}')
        .map(|p| {
            p.lines()
                .map(without_line_number)
                .filter(|l| !l.trim().is_empty())
                .collect()
        })
        .collect();
    let n = pages.iter().filter(|p| !p.is_empty()).count();
    let heads = repeated(&pages, false, n);
    let feet = repeated(&pages, true, n);
    let mut out = String::new();
    for p in &pages {
        for (i, l) in p.iter().enumerate() {
            let m = masked(l);
            if (i == 0 && heads.contains(&m)) || (i + 1 == p.len() && feet.contains(&m)) {
                continue;
            }
            let l = l.trim();
            if out.ends_with('-')
                && out
                    .chars()
                    .rev()
                    .nth(1)
                    .is_some_and(|c| c.is_alphanumeric())
            {
                out.push_str(l);
            } else {
                out.push(' ');
                out.push_str(l);
            }
        }
    }
    normalize(&out)
}

/// Whether the document holds the quote: each part of it between ellipses (the feed's elisions) that is long enough
/// to mean something, in order.
pub fn holds(text: &str, quote: &str) -> bool {
    let q = normalize(quote).replace('\u{2026}', "...");
    let parts: Vec<&str> = q
        .split("...")
        .map(|p| p.trim().trim_matches('"').trim())
        .filter(|p| !p.is_empty())
        .collect();
    if parts.is_empty() || parts.iter().any(|p| p.chars().count() < 12) {
        return false;
    }
    let mut from = 0;
    for p in parts {
        match text[from..].find(p) {
            Some(i) => from += i + p.len(),
            None => return false,
        }
    }
    true
}

/// Whether the document holds a fact's sentence: the whole of it, as one run, and not as the tail of a longer sentence
/// or a sentence under a label (the document's text before it ends in `,`, `;` or `:`). A quote the feed elided
/// ("..." or "…") is never a fact's proof: its pieces could be stitched from far-apart text. Any occurrence that
/// passes is enough.
pub fn holds_fact(text: &str, quote: &str) -> bool {
    if quote.contains('\u{2026}') || quote.contains("...") {
        return false;
    }
    let q = normalize(quote);
    let q = q.trim().trim_matches('"').trim();
    if q.chars().count() < 12 || q.contains("...") {
        return false;
    }
    let mut from = 0;
    while let Some(i) = text[from..].find(q) {
        let at = from + i;
        let before = text[..at].trim_end().chars().next_back();
        if !matches!(before, Some(',' | ';' | ':')) {
            return true;
        }
        from = at + q.chars().next().map_or(1, char::len_utf8);
    }
    false
}

/// A URL without its fragment (`#page=6`).
pub fn bare(url: &str) -> &str {
    url.split('#').next().unwrap_or(url)
}

/// The host of an http(s) URL.
pub fn host(url: &str) -> Option<&str> {
    let rest = url
        .strip_prefix("https://")
        .or_else(|| url.strip_prefix("http://"))?;
    let h = rest.split(['/', '?', '#']).next()?;
    Some(
        h.rsplit('@')
            .next()
            .unwrap_or(h)
            .split(':')
            .next()
            .unwrap_or(h),
    )
}

/// Whether the URL is an https URL on one of the court hosts a source list names (`uscourts.gov` covers
/// `apps.cacd.uscourts.gov`).
pub fn court_hosted(url: &str, hosts: &[String]) -> bool {
    if !url.starts_with("https://") {
        return false;
    }
    host(url).is_some_and(|h| {
        let h = h.to_lowercase();
        hosts
            .iter()
            .any(|d| h == *d || h.ends_with(&format!(".{d}")))
    })
}

/// The SHA-256 of bytes, in hex.
pub fn sha256(bytes: &[u8]) -> String {
    Sha256::digest(bytes)
        .iter()
        .map(|x| format!("{x:02x}"))
        .collect()
}

/// The cache file of a URL.
fn cached(cache: &Path, url: &str) -> PathBuf {
    cache.join(format!("{}.pdf", &sha256(url.as_bytes())[..24]))
}

/// The file of a court-hosted document, from the cache or fetched into it: over https only, redirects included, and
/// only when the URL the fetch ended at is court-hosted too. `sync` empties the cache first unless `--cached`.
pub fn fetch(url: &str, cache: &Path, hosts: &[String]) -> Result<PathBuf, String> {
    let url = bare(url);
    if !court_hosted(url, hosts) {
        return Err("not a court-hosted https URL".into());
    }
    let file = cached(cache, url);
    if file.is_file() {
        return Ok(file);
    }
    std::fs::create_dir_all(cache).map_err(|e| format!("{}: {e}", cache.display()))?;
    let tmp = file.with_extension("part");
    let out = Command::new("curl")
        .args([
            "-fsSL",
            "--proto",
            "=https",
            "--proto-redir",
            "=https",
            "--retry",
            "2",
            "--max-time",
            "120",
            "-w",
            "%{url_effective}",
            "-o",
        ])
        .arg(&tmp)
        .arg(url)
        .output()
        .map_err(|e| format!("curl: {e}"))?;
    if !out.status.success() {
        let _ = std::fs::remove_file(&tmp);
        return Err(format!(
            "not fetched (curl exit {})",
            out.status.code().unwrap_or(-1)
        ));
    }
    let effective = String::from_utf8_lossy(&out.stdout).trim().to_string();
    if !court_hosted(&effective, hosts) {
        let _ = std::fs::remove_file(&tmp);
        return Err(format!("redirected off the court's host, to {effective}"));
    }
    std::fs::rename(&tmp, &file).map_err(|e| e.to_string())?;
    Ok(file)
}

/// Markup as its text: tags out, the common entities read.
pub fn strip_tags(html: &str) -> String {
    let mut out = String::with_capacity(html.len());
    let mut tag = false;
    for c in html.chars() {
        match c {
            '<' => tag = true,
            '>' if tag => {
                tag = false;
                out.push(' ');
            }
            c if !tag => out.push(c),
            _ => {}
        }
    }
    for (e, c) in [
        ("&nbsp;", " "),
        ("&quot;", "\""),
        ("&#39;", "'"),
        ("&apos;", "'"),
        ("&rsquo;", "'"),
        ("&lsquo;", "'"),
        ("&rdquo;", "\""),
        ("&ldquo;", "\""),
        ("&ndash;", "-"),
        ("&mdash;", "-"),
        ("&sect;", "\u{00A7}"),
        ("&lt;", "<"),
        ("&gt;", ">"),
        ("&amp;", "&"),
    ] {
        out = out.replace(e, c);
    }
    out
}

/// Every string of a JSON value, in order.
fn strings(v: &serde_json::Value, out: &mut Vec<String>) {
    match v {
        serde_json::Value::String(s) => out.push(s.clone()),
        serde_json::Value::Array(a) => a.iter().for_each(|x| strings(x, out)),
        serde_json::Value::Object(o) => o.values().for_each(|x| strings(x, out)),
        _ => {}
    }
}

fn run_text(cmd: &mut Command, what: &str) -> Result<String, String> {
    let out = cmd.output().map_err(|e| format!("{what}: {e}"))?;
    if !out.status.success() {
        return Err(format!("{what} failed"));
    }
    Ok(String::from_utf8_lossy(&out.stdout).into_owned())
}

/// The court-hosted document at `url` (fragment aside), read and normalized: a PDF (pdftotext), a Word file
/// (pandoc), or a page or API answer of the court (its markup's text, every string of its JSON).
pub fn load(url: &str, cache: &Path, hosts: &[String]) -> Result<Corpus, String> {
    let file = fetch(url, cache, hosts)?;
    let bytes = std::fs::read(&file).map_err(|e| format!("{}: {e}", file.display()))?;
    let lead = String::from_utf8_lossy(&bytes[..bytes.len().min(512)])
        .trim_start()
        .to_lowercase();
    let text = if bytes.starts_with(b"%PDF") {
        pdf_text(&run_text(
            Command::new("pdftotext")
                .args(["-layout", "-enc", "UTF-8"])
                .arg(&file)
                .arg("-"),
            "pdftotext",
        )?)
    } else if bytes.starts_with(b"PK\x03\x04") {
        normalize(&run_text(
            Command::new("pandoc")
                .args(["-f", "docx", "-t", "plain", "--wrap=none"])
                .arg(&file),
            "pandoc",
        )?)
    } else if lead.starts_with('{') || lead.starts_with('[') {
        let v: serde_json::Value =
            serde_json::from_slice(&bytes).map_err(|e| format!("not JSON: {e}"))?;
        let mut all = Vec::new();
        strings(&v, &mut all);
        normalize(
            &all.iter()
                .map(|s| strip_tags(s))
                .collect::<Vec<_>>()
                .join("\n"),
        )
    } else if lead.contains("<html") || lead.contains("<!doctype html") {
        normalize(&strip_tags(&String::from_utf8_lossy(&bytes)))
    } else {
        return Err("not a PDF, a Word file or a page".into());
    };
    Ok(Corpus {
        sha256: sha256(&bytes),
        text,
    })
}

/// The documents a court's own index lists for a judge (`documents: [{id, ..}]` of the API answer at `api`), as
/// URLs under `file_prefix`: where a quote is looked up when the document the feed cites has been replaced.
pub fn listed_documents(
    api: &str,
    file_prefix: &str,
    cache: &Path,
    hosts: &[String],
) -> Vec<String> {
    let Ok(file) = fetch(api, cache, hosts) else {
        return vec![];
    };
    let Some(v) = std::fs::read(&file)
        .ok()
        .and_then(|b| serde_json::from_slice::<serde_json::Value>(&b).ok())
    else {
        return vec![];
    };
    v["documents"]
        .as_array()
        .into_iter()
        .flatten()
        .filter_map(|d| d["id"].as_str())
        .filter(|id| !id.is_empty() && id.chars().all(|c| c.is_ascii_alphanumeric() || c == '-'))
        .take(30)
        .map(|id| format!("{file_prefix}{id}"))
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn pleading_numbers_footers_and_hyphen_breaks_are_read_through() {
        let raw = "17   as set forth in Local Rule 11-6.2. Replies shall not exceed 4,200 words or fifteen\n18   (15) pages for handwritten briefs. \u{201C}Chambers\u{201D} copies under Local Rule 5-\n\n     Rev. 2/1/25                                6\n\u{000C}1    4.2 are exempt.\n2            D.    Citations to Case Law\n\n     Rev. 2/1/25                                7\n";
        let t = pdf_text(raw);
        assert_eq!(
            t,
            "as set forth in local rule 11-6.2. replies shall not exceed 4,200 words or fifteen (15) pages for handwritten briefs. \"chambers\" copies under local rule 5-4.2 are exempt. d. citations to case law"
        );
        assert!(holds(
            &t,
            "Replies shall not exceed 4,200 words or fifteen (15) pages for handwritten briefs."
        ));
        assert!(holds(&t, "\u{201C}Replies shall not exceed 4,200 words... copies under Local Rule 5-4.2 are exempt.\u{201D}"));
        assert!(!holds(&t, "Replies shall not exceed 4,000 words"));
        // out of order, or too short to mean anything
        assert!(!holds(
            &t,
            "copies under Local Rule 5-4.2 ... Replies shall not exceed"
        ));
        assert!(!holds(&t, "replies"));
    }

    #[test]
    fn a_fact_needs_its_whole_sentence_standing_on_its_own() {
        // C.D. Cal. text: a fact sentence must be in the document as one run
        let t = pdf_text("Replies shall not exceed 4,200 words or fifteen (15) pages for handwritten briefs. For MSJ: Replies shall not exceed ten (10) pages. Memoranda of points and authorities in support of motions for summary judgment, and oppositions shall not exceed 25 pages.\n");
        assert!(holds_fact(
            &t,
            "Replies shall not exceed 4,200 words or fifteen (15) pages for handwritten briefs."
        ));
        // stitched from two places: never a fact, though the checklist matcher takes it
        let stitched = "Replies shall not exceed 4,200 words ... shall not exceed 25 pages.";
        assert!(holds(&t, stitched));
        assert!(!holds_fact(&t, stitched));
        assert!(!holds_fact(
            &t,
            "Replies shall not exceed 4,200 words\u{2026} for handwritten briefs."
        ));
        // under a label ("For MSJ:"), or the tail of a longer sentence (after a comma)
        assert!(!holds_fact(&t, "Replies shall not exceed ten (10) pages."));
        assert!(!holds_fact(
            &t,
            "and oppositions shall not exceed 25 pages."
        ));
        // one occurrence standing on its own is enough
        let t2 = pdf_text("For MSJ: Replies shall not exceed ten (10) pages. B. Replies shall not exceed ten (10) pages.\n");
        assert!(holds_fact(&t2, "Replies shall not exceed ten (10) pages."));
        assert!(!holds_fact(&t2, "not exceed"));
    }

    #[test]
    fn a_numbered_list_keeps_its_numbers() {
        assert_eq!(
            without_line_number("12           Memoranda"),
            "           Memoranda"
        );
        assert_eq!(
            without_line_number("1. email the Courtroom Deputy"),
            "1. email the Courtroom Deputy"
        );
        assert_eq!(without_line_number("29   text"), "29   text");
        assert_eq!(without_line_number("7"), "");
    }

    #[test]
    fn markup_is_read_as_text() {
        assert_eq!(
            normalize(&strip_tags("<div><p>Counsel&rsquo;s papers must be&nbsp;14-point &amp; double-spaced.</p></div>")),
            "counsel's papers must be 14-point & double-spaced."
        );
    }

    #[test]
    fn hosts() {
        let courts = vec!["uscourts.gov".to_string()];
        assert!(court_hosted(
            "https://apps.cacd.uscourts.gov/JpsApi/file/f7#page=6",
            &courts
        ));
        assert!(court_hosted("https://uscourts.gov/x.pdf", &courts));
        assert!(!court_hosted(
            "https://lawsnap.com/data/ca-cd-judges.json",
            &courts
        ));
        assert!(!court_hosted(
            "https://evil-uscourts.gov.example.com/x.pdf",
            &courts
        ));
        assert!(!court_hosted("https://example.com/uscourts.gov", &courts));
        // https only
        assert!(!court_hosted(
            "http://apps.cacd.uscourts.gov/JpsApi/file/f7",
            &courts
        ));
        assert!(!court_hosted("ftp://uscourts.gov/x.pdf", &courts));
        // a URL off the court's host is never fetched
        assert!(fetch(
            "http://www.cacd.uscourts.gov/x.pdf",
            Path::new("/nonexistent"),
            &courts
        )
        .is_err());
        assert_eq!(bare("https://a/b.pdf#page=2"), "https://a/b.pdf");
    }
}
