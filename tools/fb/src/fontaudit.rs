//! The exemplar-font audit behind `data/exemplar-fonts.json` (`fb fonts audit|audit-additions`): which face sets
//! the body of each FILED-EXAMPLE, and whether a vendored or pinned face matches it metric-exact, approximately, or
//! not at all (and why not).
use crate::{fail, Res};
use serde_json::Value;
use std::collections::{BTreeMap, HashMap};
use std::path::Path;
use std::process::Command;

/// The name with a `ABCDEF+` subset tag removed.
pub fn unsubset(name: &str) -> &str {
    let b = name.as_bytes();
    if b.len() > 7 && b[..6].iter().all(u8::is_ascii_uppercase) && b[6] == b'+' {
        &name[7..]
    } else {
        name
    }
}

/// A font name reduced to its family: subset tag, `*` (Acrobat's synthesized-font mark), style after `,` or `-`,
/// spaces, the TrueType/PostScript `PS`/`MT`/`PSMT` tails, style words, `Identity-H` and trailing digits removed,
/// lowercased. `TimesNewRomanPS-BoldMT`, `Times New Roman,Bold`, `ABCDEF+TimesNewRomanPSMT2` and
/// `*TimesNewRoman-4801-Identity-H` are all `timesnewroman`. Unnamed fonts (`CIDFont+F1`) keep their name.
pub fn family_key(name: &str) -> String {
    let name = unsubset(name.trim()).trim_start_matches('*');
    let lower = name.to_ascii_lowercase();
    if lower.starts_with("cidfont+") {
        return lower;
    }
    let mut n = name.split(',').next().unwrap_or(name);
    // `Times-Roman`, `TimesNewRomanPS-BoldMT`, `Arial-20776-Identity-H`: the family is before the first hyphen
    if let Some((head, _)) = n.split_once('-') {
        if !head.is_empty() {
            n = head;
        }
    }
    let mut k: String = n
        .chars()
        .filter(|c| !matches!(c, ' ' | '_' | '-'))
        .collect::<String>()
        .to_ascii_lowercase();
    loop {
        let before = k.len();
        k = k.trim_end_matches(|c: char| c.is_ascii_digit()).to_string();
        for tail in [
            "identityh",
            "bolditalic",
            "boldoblique",
            "semibold",
            "regular",
            "italic",
            "oblique",
            "bold",
            "psmt",
            "mt",
            "ps",
        ] {
            if k.len() > tail.len() + 3 {
                if let Some(s) = k.strip_suffix(tail) {
                    k = s.to_string();
                }
            }
        }
        if k.len() == before {
            return k;
        }
    }
}

/// The audit verdict for a body family key: (class, face, why, reason). `face` is the face the template declares.
pub fn classify(key: &str) -> (&'static str, &'static str, String, &'static str) {
    let has = |s: &str| key.contains(s);
    let ok = |face: &'static str, why: &str| ("metric-exact", face, why.to_string(), "");
    let near = |face: &'static str, why: &str| ("approximate", face, why.to_string(), "");
    if has("timesnewroman") || has("liberationserif") || has("tinos") {
        ok(
            "Times New Roman",
            "Times New Roman itself (pinned install, docs/FONTS.md)",
        )
    } else if has("times") || has("nimbusrom") || has("termes") {
        ok(
            "TeX Gyre Termes",
            "Adobe Times metrics (Nimbus Roman lineage)",
        )
    } else if has("arial")
        || has("helvetica")
        || has("liberationsans")
        || has("arimo")
        || has("nimbussan")
    {
        ok("Liberation Sans", "Arial/Helvetica metrics")
    } else if has("couriernew") || has("liberationmono") || has("cousine") {
        ok("Liberation Mono", "Courier New metrics")
    } else if has("courier") || has("nimbusmon") {
        ok("TeX Gyre Cursor", "Adobe Courier metrics")
    } else if key == "georgia" || has("gelasio") {
        ok("Gelasio", "Georgia metrics")
    } else if has("georgia") {
        near(
            "Gelasio",
            "Georgia Pro; Gelasio has the Georgia widths, Pro's extended set differs",
        )
    } else if has("cambria") || has("caladea") {
        ok("Caladea", "Cambria metrics")
    } else if has("calibri") || has("carlito") {
        ok("Carlito", "Calibri metrics")
    } else if has("newcenturyschlbk") || has("centuryschl") || has("schola") {
        ok("TeX Gyre Schola", "Adobe New Century Schoolbook metrics")
    } else if has("centuryschoolbook") {
        near(
            "TeX Gyre Schola",
            "Monotype Century Schoolbook; Schola has the Adobe NCS widths",
        )
    } else if has("palatino") || has("bookantiqua") || has("pagella") || has("palladio") {
        near(
            "TeX Gyre Pagella",
            "Palatino lineage; widths differ slightly",
        )
    } else if has("bookman") || has("bonum") {
        near(
            "TeX Gyre Bonum",
            "ITC Bookman lineage; Bookman Old Style widths differ",
        )
    } else if key.is_empty() {
        (
            "impossible",
            "",
            "no text layer (scanned image)".into(),
            "scanned-no-text",
        )
    } else if key.starts_with("cidfont+") || unnamed(key) {
        (
            "impossible",
            "",
            format!("unnamed font {key}: its FontDescriptor matches no known face signature"),
            "unnamed-font",
        )
    } else if let Some(face) = COMMERCIAL.iter().find(|(k, _)| has(k)).map(|(_, f)| *f) {
        (
            "impossible",
            "",
            format!("{face}: no redistributable metric-compatible face"),
            "commercial-face",
        )
    } else {
        (
            "impossible",
            "",
            format!("unrecognised face name {key}: no known metric-compatible face"),
            "unknown-face",
        )
    }
}

/// Faces with no vendored metric-compatible substitute (family-key fragment, display name).
const COMMERCIAL: [(&str, &str); 24] = [
    ("garamond", "Garamond"),
    ("calisto", "Calisto MT"),
    ("centuryexpanded", "Century Expanded"),
    ("century", "Century (Monotype)"),
    ("equity", "Equity"),
    ("charter", "Charter"),
    ("segoe", "Segoe UI"),
    ("constantia", "Constantia"),
    ("roboto", "Roboto"),
    ("arnopro", "Arno Pro"),
    ("baskerville", "Baskerville"),
    ("baskoldface", "Baskerville Old Face"),
    ("goudy", "Goudy Old Style"),
    ("proximanova", "Proxima Nova"),
    ("leelawadee", "Leelawadee UI"),
    ("aptos", "Aptos"),
    ("minion", "Minion Pro"),
    ("plantagenet", "Plantagenet Cherokee"),
    ("verdana", "Verdana"),
    ("tahoma", "Tahoma"),
    ("candara", "Candara"),
    ("corbel", "Corbel"),
    ("bembo", "Bembo"),
    ("sabon", "Sabon"),
];

/// Names a PDF producer made up for an embedded font (Word's `WrdEmbedSub`, `ZC00000tmp`, `F1`, `T1_0`, `TT1`).
fn unnamed(key: &str) -> bool {
    key.starts_with("wrdembed")
        || key.starts_with("zc0000")
        || matches!(key, "f" | "t" | "tt" | "c" | "ff")
}

/// FontDescriptor (Ascent, Descent, CapHeight) of the faces whose name Microsoft Print to PDF and similar
/// producers strip (`CIDFont+F1`), as measured on exemplars that also carry the named face. Bold styles share the
/// regular's ascent and descent; their cap height may differ by a few units.
const SIGNATURES: [((i64, i64, i64), &str, &str); 6] = [
    ((891, -216, 662), "timesnewroman", "Times New Roman"),
    ((905, -211, 716), "arial", "Arial"),
    ((832, -300, 571), "couriernew", "Courier New"),
    ((916, -219, 692), "georgia", "Georgia"),
    ((861, -263, 629), "garamond", "Garamond"),
    ((985, -215, 722), "centuryschoolbook", "Century Schoolbook"),
];

fn find(hay: &[u8], needle: &[u8], from: usize) -> Option<usize> {
    hay.get(from..)?
        .windows(needle.len())
        .position(|w| w == needle)
        .map(|p| p + from)
}

/// The PDF dictionary `<< ... >>` around byte `pos`.
fn enclosing_dict(b: &[u8], pos: usize) -> &[u8] {
    let (mut i, mut depth, mut start) = (pos, 0, None);
    while i > 1 && pos - i < 8000 {
        i -= 1;
        if b[i] == b'>' && b[i - 1] == b'>' {
            depth += 1;
            i -= 1;
        } else if b[i] == b'<' && b[i - 1] == b'<' {
            if depth == 0 {
                start = Some(i - 1);
                break;
            }
            depth -= 1;
            i -= 1;
        }
    }
    let Some(start) = start else { return &[] };
    let (mut j, mut depth) = (start + 2, 1);
    while j + 1 < b.len() && j - start < 16000 {
        if b[j] == b'<' && b[j + 1] == b'<' {
            depth += 1;
            j += 1;
        } else if b[j] == b'>' && b[j + 1] == b'>' {
            depth -= 1;
            if depth == 0 {
                return &b[start..j + 2];
            }
            j += 1;
        }
        j += 1;
    }
    &[]
}

fn dict_int(dict: &[u8], key: &[u8]) -> Option<i64> {
    let mut at = 0;
    while let Some(p) = find(dict, key, at) {
        at = p + key.len();
        // `/Descent` must not match `/DescentX`
        if dict.get(at).is_some_and(u8::is_ascii_alphanumeric) {
            continue;
        }
        let rest = std::str::from_utf8(&dict[at..dict.len().min(at + 24)]).unwrap_or("");
        let num: String = rest
            .trim_start()
            .chars()
            .take_while(|c| c.is_ascii_digit() || matches!(c, '-' | '.'))
            .collect();
        return num.parse::<f64>().ok().map(|v| v.round() as i64);
    }
    None
}

/// The inflated object streams of `pdf` (FontDescriptors of PDF 1.5+ files live there).
fn object_streams(pdf: &[u8]) -> Vec<Vec<u8>> {
    let mut out = Vec::new();
    let mut at = 0;
    while let Some(p) = find(pdf, b"/ObjStm", at) {
        at = p + 7;
        let Some(s) = find(pdf, b"stream", at) else {
            break;
        };
        let mut s = s + 6;
        while matches!(pdf.get(s), Some(b'\r' | b'\n')) {
            s += 1;
        }
        let Some(e) = find(pdf, b"endstream", s) else {
            break;
        };
        if let Ok(v) = miniz_oxide::inflate::decompress_to_vec_zlib(&pdf[s..e]) {
            out.push(v);
        }
        at = e;
    }
    out
}

/// (Ascent, Descent, CapHeight) of each FontDescriptor in `pdf`, by FontName with its subset tag removed.
pub fn descriptor_metrics(pdf: &[u8]) -> HashMap<String, (i64, i64, i64)> {
    let mut out = HashMap::new();
    let streams = object_streams(pdf);
    for src in std::iter::once(pdf).chain(streams.iter().map(Vec::as_slice)) {
        let mut at = 0;
        while let Some(p) = find(src, b"/FontName", at) {
            at = p + 9;
            let rest = &src[at..src.len().min(at + 200)];
            let rest = rest.trim_ascii_start();
            let Some(rest) = rest.strip_prefix(b"/") else {
                continue;
            };
            let end = rest
                .iter()
                .position(|c| c.is_ascii_whitespace() || b"/<>[]()".contains(c))
                .unwrap_or(rest.len());
            let name = String::from_utf8_lossy(&rest[..end]).to_string();
            let dict = enclosing_dict(src, p);
            if let (Some(a), Some(d), Some(c)) = (
                dict_int(dict, b"/Ascent"),
                dict_int(dict, b"/Descent"),
                dict_int(dict, b"/CapHeight"),
            ) {
                out.entry(unsubset(&name).to_string()).or_insert((a, d, c));
            }
        }
    }
    out
}

/// The family an unnamed font's descriptor identifies, with the face name for the `why`.
pub fn by_signature(m: (i64, i64, i64)) -> Option<(&'static str, &'static str)> {
    SIGNATURES
        .iter()
        .find(|(s, _, _)| s.0 == m.0 && s.1 == m.1 && (s.2 - m.2).abs() <= 20)
        .map(|(_, k, f)| (*k, *f))
}

fn attr(line: &str, key: &str) -> Option<String> {
    let needle = format!("{key}=\"");
    let start = line.find(&needle)? + needle.len();
    let end = line[start..].find('"')? + start;
    Some(line[start..end].to_string())
}

fn run(cmd: &str, args: &[&str], pdf: &Path) -> Res<String> {
    let out = Command::new(cmd)
        .args(args)
        .arg(pdf)
        .output()
        .map_err(|e| fail(2, format!("{cmd}: {e}")))?;
    Ok(String::from_utf8_lossy(&out.stdout).into_owned())
}

/// `cmd args pdf -`: a poppler tool writing to stdout.
fn run_out(cmd: &str, args: &[&str], pdf: &Path) -> Res<String> {
    let out = Command::new(cmd)
        .args(args)
        .arg(pdf)
        .arg("-")
        .output()
        .map_err(|e| fail(2, format!("{cmd}: {e}")))?;
    Ok(String::from_utf8_lossy(&out.stdout).into_owned())
}

/// Pages, and pages that carry an image covering most of the page (a scan), from `pdfinfo` and `pdfimages -list`.
fn scanned_pages(pdf: &Path, info: &str) -> Res<(usize, usize)> {
    let pages: usize = info
        .lines()
        .find_map(|l| l.strip_prefix("Pages:"))
        .and_then(|v| v.trim().parse().ok())
        .unwrap_or(0);
    let list = run("pdfimages", &["-list"], pdf)?;
    let mut scanned = std::collections::BTreeSet::new();
    for line in list.lines().skip(2) {
        let f: Vec<&str> = line.split_whitespace().collect();
        if f.len() < 14 {
            continue;
        }
        let num = |i: usize| f[i].parse::<f64>().unwrap_or(0.0);
        let (w, h, xppi, yppi) = (num(3), num(4), num(12), num(13));
        let (a, b) = (w / xppi.max(1.0), h / yppi.max(1.0));
        if a.max(b) >= 8.0 && a.min(b) >= 6.0 {
            scanned.insert(f[0].to_string());
        }
    }
    Ok((pages, scanned.len()))
}

/// The audit record of one exemplar PDF.
pub fn audit_record(pdf: &Path) -> Res<Value> {
    let font_text = run("pdffonts", &[], pdf)?;
    let fonts: Vec<String> = font_text
        .lines()
        .skip(2)
        .filter_map(|line| line.split_whitespace().next())
        .map(|n| unsubset(n).to_string())
        .collect::<std::collections::BTreeSet<_>>()
        .into_iter()
        .collect();
    let bytes = std::fs::read(pdf).map_err(|e| fail(2, format!("{}: {e}", pdf.display())))?;
    let metrics = if fonts.iter().any(|f| {
        let k = family_key(f);
        k.starts_with("cidfont+") || unnamed(&k)
    }) {
        descriptor_metrics(&bytes)
    } else {
        HashMap::new()
    };
    // family key of each font name; an unnamed font takes the family its descriptor identifies
    let mut named = HashMap::<String, String>::new();
    let mut resolve = |name: &str| -> String {
        named
            .entry(name.to_string())
            .or_insert_with(|| {
                let k = family_key(name);
                if k.starts_with("cidfont+") || unnamed(&k) {
                    if let Some((fam, _)) =
                        metrics.get(unsubset(name)).and_then(|m| by_signature(*m))
                    {
                        return fam.to_string();
                    }
                }
                k
            })
            .clone()
    };
    let xml = run("pdftohtml", &["-xml", "-i", "-q", "-stdout"], pdf)?;
    let mut ids = HashMap::new();
    let mut usage = BTreeMap::<String, usize>::new();
    let mut raw_name = HashMap::<String, String>::new();
    let mut total = 0usize;
    for line in xml.lines() {
        if line.contains("<fontspec ") {
            if let (Some(id), Some(family)) = (attr(line, "id"), attr(line, "family")) {
                let k = resolve(&family);
                raw_name.entry(k.clone()).or_insert(family);
                ids.insert(id, k);
            }
        } else if line.contains("<text ") {
            if let Some(key) = attr(line, "font").and_then(|id| ids.get(&id)) {
                let text = line.split_once('>').map(|(_, body)| body).unwrap_or("");
                // the body of the line without its markup (<b>, <i>, <a>)
                let mut visible = 0;
                let mut tag = false;
                for c in text.chars() {
                    match c {
                        '<' => tag = true,
                        '>' => tag = false,
                        c if !tag && c.is_alphanumeric() => visible += 1,
                        _ => {}
                    }
                }
                if visible > 0 {
                    *usage.entry(key.clone()).or_default() += visible;
                    total += visible;
                }
            }
        }
    }
    let info = run("pdfinfo", &[], pdf)?;
    // pdftohtml drops invisible text (render mode 3, an OCR layer); pdftotext keeps it
    let all_text = run_out("pdftotext", &["-q"], pdf)?
        .chars()
        .filter(|c| c.is_alphanumeric())
        .count();
    // pdftohtml refuses a copy-protected file; pdftotext does not, and the embedded fonts name the body face
    let locked = total == 0 && info.contains("copy:no");
    if locked {
        for line in font_text.lines().skip(2) {
            let f: Vec<&str> = line.split_whitespace().collect();
            if f.len() >= 7 && f[f.len() - 5] == "yes" {
                *usage.entry(resolve(f[0])).or_default() += 1;
                raw_name.entry(resolve(f[0])).or_insert(f[0].to_string());
            }
        }
        total = all_text;
    }
    let variants: usize = usage.values().sum();
    let (body, share) = usage
        .iter()
        .max_by_key(|(_, n)| *n)
        .map(|(body, n)| {
            let of = if locked { variants } else { total };
            (body.clone(), *n as f64 / of.max(1) as f64)
        })
        .unwrap_or_default();
    let (pages, scans) = scanned_pages(pdf, &info)?;
    let hidden = all_text.saturating_sub(total);
    // a scan: most pages are a page-size image, or the visible text is no more than a filing stamp
    let sparse = total < 300 * pages.max(1);
    let scan = sparse && (total == 0 || (pages > 0 && scans * 5 >= pages * 4) || hidden > total);
    let (class, face, mut why, reason) = if scan && hidden > 200 * pages.max(1) {
        (
            "impossible",
            "",
            format!("scanned image with an OCR text layer ({pages} pages, {scans} page-size images, the visible text is a stamp)"),
            "scanned-ocr",
        )
    } else if scan || total == 0 {
        (
            "impossible",
            "",
            "no text layer (scanned image)".to_string(),
            "scanned-no-text",
        )
    } else {
        classify(&body)
    };
    if locked {
        why = format!(
            "{why} (text copy-protected: the body is the embedded family with the most styles)"
        );
    }
    if reason.is_empty() || reason == "commercial-face" {
        if let Some(raw) = raw_name.get(&body) {
            let k = family_key(raw);
            if (k.starts_with("cidfont+") || unnamed(&k)) && k != body {
                let m = metrics[unsubset(raw)];
                why = format!(
                    "{why} (unnamed font {} identified by its FontDescriptor: Ascent {} Descent {} CapHeight {} is the {} signature)",
                    unsubset(raw),
                    m.0,
                    m.1,
                    m.2,
                    by_signature(m).map_or("", |s| s.1)
                );
            }
        }
    }
    let mut rec = serde_json::json!({
        "body": body,
        "body_share": (share * 1000.0).round() / 1000.0,
        "class": class,
        "face": face,
        "why": why,
    });
    if !reason.is_empty() {
        rec["reason"] = reason.into();
    }
    rec["fonts"] = fonts.into();
    Ok(rec)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn family_keys_fold_name_variants() {
        for n in [
            "TimesNewRomanPSMT",
            "ABCDEF+TimesNewRomanPS-BoldMT",
            "Times New Roman,Bold",
            "TimesNewRomanPSMT2",
            "*TimesNewRoman-4801-Identity-H",
            "TimesNewRoman,Italic",
        ] {
            assert_eq!(family_key(n), "timesnewroman", "{n}");
        }
        assert_eq!(family_key("Times-Roman"), "times");
        assert_eq!(family_key("ArialMT"), "arial");
        assert_eq!(family_key("*Arial-20776-Identity-H"), "arial");
        assert_eq!(family_key("CourierNewPSMT"), "couriernew");
        assert_eq!(family_key("BookmanOldStyle2"), "bookmanoldstyle");
        assert_eq!(family_key("EquityTextA Regular"), "equitytexta");
        assert_eq!(family_key("NewCenturySchlbk-Roman"), "newcenturyschlbk");
        assert_eq!(family_key("CIDFont+F1"), "cidfont+f1");
    }

    #[test]
    fn classify_maps_faces_and_reasons() {
        assert_eq!(classify("timesnewroman").1, "Times New Roman");
        assert_eq!(classify("times").1, "TeX Gyre Termes");
        assert_eq!(classify("arial").0, "metric-exact");
        assert_eq!(classify("helvetica").1, "Liberation Sans");
        assert_eq!(classify("georgia").1, "Gelasio");
        assert_eq!(classify("centuryschoolbook").0, "approximate");
        assert_eq!(classify("bookmanoldstyle").1, "TeX Gyre Bonum");
        assert_eq!(classify("garamond").3, "commercial-face");
        assert_eq!(classify("centuryexpandedbt").3, "commercial-face");
        assert_eq!(classify("cidfont+f1").3, "unnamed-font");
        assert_eq!(classify("wrdembedsub").3, "unnamed-font");
        assert_eq!(classify("").3, "scanned-no-text");
        assert_eq!(classify("zzzface").3, "unknown-face");
    }

    #[test]
    fn descriptors_identify_stripped_names() {
        let pdf = b"1 0 obj\n<</Type/FontDescriptor/FontName/CIDFont+F1/Flags 32/FontBBox[-568 -216 2046 693]/Ascent 891/Descent -216/CapHeight 662/StemV 80/Style<</Panose<0>>>/FontFile2 7 0 R>>\nendobj\n2 0 obj << /FontName /ABCDEF+Georgia /Ascent 916 /Descent -219 /CapHeight 692.0 >> endobj";
        let m = descriptor_metrics(pdf);
        assert_eq!(m["CIDFont+F1"], (891, -216, 662));
        assert_eq!(
            by_signature(m["CIDFont+F1"]).map(|s| s.0),
            Some("timesnewroman")
        );
        assert_eq!(m["Georgia"], (916, -219, 692));
        assert_eq!(
            by_signature((891, -216, 677)).map(|s| s.0),
            Some("timesnewroman")
        );
        assert_eq!(by_signature((905, -211, 715)).map(|s| s.0), Some("arial"));
        assert_eq!(by_signature((948, -256, 706)), None);
        let mut z =
            b"9 0 obj <</Type/ObjStm/N 1/First 4/Filter/FlateDecode/Length 99>>stream\n".to_vec();
        z.extend(miniz_oxide::deflate::compress_to_vec_zlib(
            b"3 0 <</FontName/CIDFont+F2/Ascent 916/Descent -219/CapHeight 692>>",
            6,
        ));
        z.extend(b"\nendstream endobj");
        assert_eq!(descriptor_metrics(&z)["CIDFont+F2"], (916, -219, 692));
    }
}
