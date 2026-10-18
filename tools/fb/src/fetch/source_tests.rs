use super::*;

const KV: &str = "# Exemplar source

## Primary exemplar

| Field | Value |
|---|---|
| File | `FILED-EXAMPLE-sweet-v-mcmahon-26-1136-opening-brief.pdf` |
| URL | https://example.org/a/ED-Opening-Brief.pdf |
| Docket | https://www.courtlistener.com/docket/1/x/ |
| SHA-256 | `ED832E885DADABF60DDAF2C8C960C758B2DF5D2B5B2FAE437DF4EF95AB16ABD1` |

## Second filer

| Field | Value |
|---|---|
| File | `FILED-EXAMPLE-aca-connects-21-15430-opening-brief.pdf` |
| Docket page | https://www.courtlistener.com/docket/2/ |
| URL fetched from | https://cdn.ca9.uscourts.gov/datastore/21-15430-Opening-brief.pdf |
| Date retrieved | 2026-10-17 |
";

const LIST: &str = "# Exemplar source

- File: `FILED-EXAMPLE-gideon-4-25-cv-00450-motion-brief.pdf`
- Court: United States District Court
- Fetched from: https://storage.courtlistener.com/recap/x/gov.uscourts.oknd.74003.43.0.pdf (CourtListener RECAP; docket https://www.courtlistener.com/docket/74003/)
- Date fetched: 2026-10-14

Second filer: not collected; unlike FILED-EXAMPLE-gideon-4-25-cv-00450-motion-brief.pdf, see README.
";

const HEAD: &str = "# Exemplars

### FILED-EXAMPLE-one-1-brief.pdf

- **Filer:** Someone
- **URL:** <https://example.org/one.pdf>
- **SHA-256:** `aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa`

### FILED-EXAMPLE-two-2-brief.pdf

- **Filer:** Someone else
- **URL:** https://example.org/download?id=2
";

const WIDE: &str = "# Exemplars

| File | Case | URL | Date fetched |
|---|---|---|---|
| `FILED-EXAMPLE-banks-25-3320-answering-brief.pdf` | Banks | https://storage.example/banks.pdf | 2026-10-14 |
| `FILED-EXAMPLE-burnett-24-2143-answering-brief.pdf` | Burnett | https://storage.example/burnett.pdf | 2026-10-14 |

How it was found: https://www.courtlistener.com/api/rest/v4/search/?q=x
";

#[test]
fn key_value_tables() {
    let e = parse(KV);
    assert_eq!(e.len(), 2);
    assert_eq!(
        e[0].name,
        "FILED-EXAMPLE-sweet-v-mcmahon-26-1136-opening-brief.pdf"
    );
    assert_eq!(
        e[0].url.as_deref(),
        Some("https://example.org/a/ED-Opening-Brief.pdf")
    );
    assert_eq!(
        e[0].sha.as_deref(),
        Some("ed832e885dadabf60ddaf2c8c960c758b2df5d2b5b2fae437df4ef95ab16abd1")
    );
    // the docket page comes first but the labelled PDF URL wins; no hash recorded
    assert_eq!(
        e[1].url.as_deref(),
        Some("https://cdn.ca9.uscourts.gov/datastore/21-15430-Opening-brief.pdf")
    );
    assert_eq!(e[1].sha, None);
}

#[test]
fn list_and_mentions() {
    let e = parse(LIST);
    assert_eq!(
        e.len(),
        1,
        "a later prose mention is not a new record: {e:?}"
    );
    assert_eq!(
        e[0].url.as_deref(),
        Some("https://storage.courtlistener.com/recap/x/gov.uscourts.oknd.74003.43.0.pdf")
    );
}

#[test]
fn headings_and_bold_items() {
    let e = parse(HEAD);
    assert_eq!(e.len(), 2);
    assert_eq!(e[0].url.as_deref(), Some("https://example.org/one.pdf"));
    assert_eq!(e[0].sha.as_deref(), Some(&"a".repeat(64)[..]));
    assert_eq!(
        e[1].url.as_deref(),
        Some("https://example.org/download?id=2")
    );
    assert_eq!(e[1].sha, None);
}

#[test]
fn wide_table_rows() {
    let e = parse(WIDE);
    assert_eq!(e.len(), 2);
    assert_eq!(
        e[0].url.as_deref(),
        Some("https://storage.example/banks.pdf")
    );
    assert_eq!(
        e[1].url.as_deref(),
        Some("https://storage.example/burnett.pdf")
    );
}

#[test]
fn names_on_a_line() {
    assert_eq!(
        names("see `FILED-EXAMPLE-a-1.pdf` and FILED-EXAMPLE-b.pdf. Not FILED-EXAMPLE-c.txt"),
        vec!["FILED-EXAMPLE-a-1.pdf", "FILED-EXAMPLE-b.pdf"]
    );
}

#[test]
fn record_hash_in_table_style() {
    let e = parse(KV);
    let h = "b".repeat(64);
    let out = record_sha(KV, &e[1], &h);
    assert!(out.contains(&format!(
        "| URL fetched from | https://cdn.ca9.uscourts.gov/datastore/21-15430-Opening-brief.pdf |\n| SHA-256 | `{h}` |\n| Date retrieved |"
    )));
    let again = parse(&out);
    assert_eq!(again[1].sha.as_deref(), Some(h.as_str()));
    assert_eq!(again[0].sha, e[0].sha);
}

#[test]
fn record_hash_in_list_style() {
    let h = "c".repeat(64);
    let e = parse(LIST);
    let out = record_sha(LIST, &e[0], &h);
    assert!(out.contains(&format!("docket/74003/)\n- SHA-256: `{h}`\n- Date fetched")));
    assert_eq!(parse(&out)[0].sha.as_deref(), Some(h.as_str()));

    let e = parse(HEAD);
    let out = record_sha(HEAD, &e[1], &h);
    assert!(
        out.ends_with(&format!("id=2\n- **SHA-256:** `{h}`\n")),
        "{out}"
    );
    let again = parse(&out);
    assert_eq!(again[1].sha.as_deref(), Some(h.as_str()));
    assert_eq!(again[0].sha.as_deref(), Some(&"a".repeat(64)[..]));
}

#[test]
fn record_hash_after_wide_table() {
    let h = "d".repeat(64);
    let e = parse(WIDE);
    let out = record_sha(WIDE, &e[0], &h);
    assert!(out.contains(&format!(
        "2026-10-14 |\n\nSHA-256 of `FILED-EXAMPLE-banks-25-3320-answering-brief.pdf`: `{h}`\n\nHow"
    )));
    let again = parse(&out);
    assert_eq!(again[0].sha.as_deref(), Some(h.as_str()));
    assert_eq!(again[1].sha, None);
    assert_eq!(again.len(), 2);
}

#[test]
fn mentions_and_paths() {
    let text = "| Field | Value |\n|---|---|\n| File | `FILED-EXAMPLE-trek-complaint.pdf` |\n| URL | https://x.org/t.pdf |\n\nNote: `FILED-EXAMPLE-trek-25-1-complaint.pdf` is a copy (sha256 `eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee`).\n\n`../../usage/FILED-EXAMPLE-other.pdf` is not an exemplar.\n";
    let e = parse(text);
    assert_eq!(e.len(), 2, "{e:?}");
    assert!(e[0].listed);
    assert_eq!(e[0].sha, None, "the copy's hash is not the record's");
    assert_eq!(e[1].name, "FILED-EXAMPLE-trek-25-1-complaint.pdf");
    assert!(!e[1].listed);
    assert_eq!(e[1].url, None);
    assert_eq!(e[1].sha.as_deref(), Some(&"e".repeat(64)[..]));
}

#[test]
fn every_recorded_hash_is_kept() {
    let text = "## 2. FILED-EXAMPLE-sakar-1-trial-brief.pdf\n\n- URL fetched: https://x.org/b.pdf (bundle sha256 1111111111111111111111111111111111111111111111111111111111111111)\n- sha256 (extract): 2222222222222222222222222222222222222222222222222222222222222222\n";
    let e = parse(text);
    assert_eq!(e.len(), 1);
    assert_eq!(e[0].shas, vec!["1".repeat(64), "2".repeat(64)]);
    assert_eq!(e[0].url.as_deref(), Some("https://x.org/b.pdf"));
}

#[test]
fn excerpts() {
    assert!(excerpt_hint(
        "pages 1-19 of 42 (unaltered pages of the filed PDF)"
    ));
    assert!(excerpt_hint(
        "## Exemplar 2: `x.pdf` (12 pages; excerpt, used by the sample)"
    ));
    assert!(excerpt_hint("- sha256 (extract): abc"));
    assert!(!excerpt_hint(
        "Text layer: yes (text extracted with pdftotext; 14 pages of argument)"
    ));
    assert!(!excerpt_hint("54 pages of 12-point text"));
    let e = parse("### FILED-EXAMPLE-h-1.pdf (12 pages; excerpt)\n\n- URL: https://x.org/all.pdf\n\n### FILED-EXAMPLE-k-2.pdf\n\n- URL: https://x.org/k.pdf\n");
    assert!(e[0].excerpt);
    assert!(!e[1].excerpt);
}
