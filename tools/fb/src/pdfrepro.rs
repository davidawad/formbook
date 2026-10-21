//! Reproducible LibreOffice PDFs (the docx engine). LibreOffice writes the wall-clock time into the Info
//! dictionary's `/CreationDate` and derives the trailer `/ID` from it, although its XMP metadata already follows
//! SOURCE_DATE_EPOCH. Both are rewritten in place, each byte string the same length as before, so the
//! cross-reference offsets stay valid. Two renders of the same markdown are then the same bytes, and a Gate 2
//! review names a sha256 that the next `fb check` (which renders again) reproduces.

/// `YYYYMMDDHHMMSS` of a Unix time, UTC (days to civil date: H. Hinnant's algorithm).
fn stamp(epoch: i64) -> String {
    let days = epoch.div_euclid(86_400);
    let secs = epoch.rem_euclid(86_400);
    let z = days + 719_468;
    let era = z.div_euclid(146_097);
    let doe = z - era * 146_097;
    let yoe = (doe - doe / 1460 + doe / 36_524 - doe / 146_096) / 365;
    let doy = doe - (365 * yoe + yoe / 4 - yoe / 100);
    let mp = (5 * doy + 2) / 153;
    let d = doy - (153 * mp + 2) / 5 + 1;
    let m = if mp < 10 { mp + 3 } else { mp - 9 };
    let y = yoe + era * 400 + i64::from(m <= 2);
    format!(
        "{y:04}{m:02}{d:02}{:02}{:02}{:02}",
        secs / 3600,
        secs % 3600 / 60,
        secs % 60
    )
}

fn positions(hay: &[u8], needle: &[u8]) -> Vec<usize> {
    hay.windows(needle.len())
        .enumerate()
        .filter(|(_, w)| *w == needle)
        .map(|(i, _)| i + needle.len())
        .collect()
}

/// The hex digits of every `/ID [<..> <..>]` array: (start, end) of each string's digits.
fn id_strings(pdf: &[u8]) -> Vec<(usize, usize)> {
    let mut out = vec![];
    for mut i in positions(pdf, b"/ID") {
        while i < pdf.len() && pdf[i].is_ascii_whitespace() {
            i += 1;
        }
        if pdf.get(i) != Some(&b'[') {
            continue;
        }
        i += 1;
        for _ in 0..2 {
            while i < pdf.len() && pdf[i].is_ascii_whitespace() {
                i += 1;
            }
            if pdf.get(i) != Some(&b'<') {
                break;
            }
            let start = i + 1;
            let mut end = start;
            while end < pdf.len() && pdf[end].is_ascii_hexdigit() {
                end += 1;
            }
            if pdf.get(end) != Some(&b'>') {
                break;
            }
            out.push((start, end));
            i = end + 1;
        }
    }
    out
}

fn fnv1a(bytes: &[u8], seed: u64) -> u64 {
    bytes.iter().fold(seed, |h, &b| {
        (h ^ u64::from(b)).wrapping_mul(0x0100_0000_01b3)
    })
}

/// Rewrite the creation and modification dates (to `epoch`), the file identifier and the document checksum (to a
/// hash of the rest of the file) in place.
pub fn normalize(pdf: &mut [u8], epoch: i64) {
    let date = stamp(epoch);
    for key in [&b"/CreationDate(D:"[..], &b"/ModDate(D:"[..]] {
        for p in positions(pdf, key) {
            if p + 14 <= pdf.len() && pdf[p..p + 14].iter().all(u8::is_ascii_digit) {
                pdf[p..p + 14].copy_from_slice(date.as_bytes());
            }
        }
    }
    let mut ids = id_strings(pdf);
    // LibreOffice's trailer /DocChecksum (a name of hex digits) changes with the time stamp too
    for s in positions(pdf, b"/DocChecksum /") {
        let e = s + pdf[s..]
            .iter()
            .take_while(|b| b.is_ascii_hexdigit())
            .count();
        ids.push((s, e));
    }
    for &(s, e) in &ids {
        pdf[s..e].fill(b'0');
    }
    let hex = format!(
        "{:016X}{:016X}",
        fnv1a(pdf, 0xcbf2_9ce4_8422_2325),
        fnv1a(pdf, 0x6c62_272e_07bb_0142)
    );
    for &(s, e) in &ids {
        for (k, b) in pdf[s..e].iter_mut().enumerate() {
            *b = hex.as_bytes()[k % hex.len()];
        }
    }
}

/// `normalize` the PDF file at `path` with SOURCE_DATE_EPOCH, when it is set.
pub fn normalize_file(path: &std::path::Path) -> std::io::Result<()> {
    let Some(epoch) = std::env::var("SOURCE_DATE_EPOCH")
        .ok()
        .and_then(|s| s.parse::<i64>().ok())
    else {
        return Ok(());
    };
    let mut pdf = std::fs::read(path)?;
    normalize(&mut pdf, epoch);
    std::fs::write(path, pdf)
}

#[cfg(test)]
mod tests {
    use super::*;

    const PDF: &[u8] = b"%PDF-1.7\n<</Producer(x)/CreationDate(D:20261021115340Z')/ModDate(D:20261021115341Z')>>\ntrailer\n<</Size 3/ID [ <8EC0F1A7AFE1E755D91BDCEF9FDC4980>\n<8EC0F1A7AFE1E755D91BDCEF9FDC4980> ]\n/DocChecksum /A79913EA02C6202B223A8DFDC5128ABF\n>>\n";

    #[test]
    fn stamps_the_epoch_in_utc() {
        assert_eq!(stamp(1_767_225_600), "20260101000000");
        assert_eq!(stamp(0), "19700101000000");
        assert_eq!(stamp(951_782_400 + 3661), "20000229010101");
    }

    #[test]
    fn rewrites_dates_and_id_keeping_the_length() {
        let mut a = PDF.to_vec();
        normalize(&mut a, 1_767_225_600);
        assert_eq!(a.len(), PDF.len());
        let s = String::from_utf8(a.clone()).unwrap();
        assert!(s.contains("/CreationDate(D:20260101000000Z')"));
        assert!(s.contains("/ModDate(D:20260101000000Z')"));
        assert!(!s.contains("8EC0F1A7") && !s.contains("A79913EA"));
        // the same file with another wall-clock time and identifier normalizes to the same bytes
        let other = String::from_utf8(PDF.to_vec())
            .unwrap()
            .replace("20261021115340", "20261022090000")
            .replace(
                "8EC0F1A7AFE1E755D91BDCEF9FDC4980",
                "69C49929B18940BE5CB57D142BDE9A18",
            );
        let mut b = other.into_bytes();
        normalize(&mut b, 1_767_225_600);
        assert_eq!(a, b);
    }

    #[test]
    fn leaves_other_id_keys_alone() {
        let src = b"<</ID (id141)>> <</IDTree 3 0 R>>".to_vec();
        let mut a = src.clone();
        normalize(&mut a, 1_767_225_600);
        assert_eq!(a, src);
    }
}
