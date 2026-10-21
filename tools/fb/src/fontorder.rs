//! LibreOffice writes each embedded font as a run of objects (the font program and its /Length, the descriptor,
//! the ToUnicode map, the font dictionary), one run after another, in an order that follows heap addresses: two
//! renders of the same .docx can number and place the runs differently (the page content names them /F1, /F2,
//! ... and does not change). `canonical` puts the runs in /BaseFont order and renumbers their objects to match,
//! in place: the runs keep their total length, every renumbered object keeps its digit count, and the moved
//! objects' cross-reference entries are rewritten, so no other byte moves. A PDF of any other shape is left alone.
use std::collections::{BTreeMap, BTreeSet};

pub(crate) fn find(hay: &[u8], needle: &[u8], from: usize) -> Option<usize> {
    hay.get(from..)?
        .windows(needle.len())
        .position(|w| w == needle)
        .map(|p| p + from)
}

pub(crate) fn number(bytes: &[u8]) -> Option<usize> {
    std::str::from_utf8(bytes).ok()?.trim().parse().ok()
}

/// The cross-reference table's offset, and per in-use object (offset, where its 10-digit offset field starts).
pub(crate) type Xref = (usize, BTreeMap<usize, (usize, usize)>);

/// Offsets of the in-use objects from the classic cross-reference table (one `0 N` subsection), and where
/// each entry's 10-digit offset field starts.
pub(crate) fn xref(pdf: &[u8]) -> Option<Xref> {
    let sx = pdf.windows(9).rposition(|w| w == b"startxref")?;
    let rest = &pdf[sx + 9..];
    let digits: Vec<u8> = rest
        .iter()
        .skip_while(|b| b.is_ascii_whitespace())
        .take_while(|b| b.is_ascii_digit())
        .copied()
        .collect();
    let at = number(&digits)?;
    if pdf.get(at..at + 4)? != b"xref" {
        return None;
    }
    let mut i = at + 4;
    while pdf.get(i)?.is_ascii_whitespace() {
        i += 1;
    }
    let eol = find(pdf, b"\n", i)?;
    let head = std::str::from_utf8(&pdf[i..eol]).ok()?;
    let mut it = head.split_whitespace();
    let (first, count): (usize, usize) = (it.next()?.parse().ok()?, it.next()?.parse().ok()?);
    if first != 0 || it.next().is_some() {
        return None;
    }
    let mut objs = BTreeMap::new();
    for n in 0..count {
        let e = eol + 1 + n * 20;
        let entry = pdf.get(e..e + 20)?;
        if entry[17] == b'n' {
            objs.insert(n, (number(&entry[..10])?, e));
        }
    }
    Some((at, objs))
}

/// The dictionary part of an object (everything before its stream data, if any).
pub(crate) fn dict_part(obj: &[u8]) -> &[u8] {
    match find(obj, b"stream", 0) {
        Some(s) if !obj[..s].ends_with(b"end") => &obj[..s],
        _ => obj,
    }
}

/// (start, end, object number) of every `N 0 R` reference in `bytes`.
fn refs(bytes: &[u8]) -> Vec<(usize, usize, usize)> {
    let mut out = vec![];
    let mut from = 0;
    while let Some(p) = find(bytes, b" 0 R", from) {
        from = p + 4;
        let start = bytes[..p]
            .iter()
            .rposition(|b| !b.is_ascii_digit())
            .map_or(0, |q| q + 1);
        let after = bytes.get(p + 4);
        if start < p && !after.is_some_and(u8::is_ascii_alphanumeric) {
            if let Some(n) = number(&bytes[start..p]) {
                out.push((start, p, n));
            }
        }
    }
    out
}

/// Rewrite the references (and the `N 0 obj` header) in the dictionary part of `obj` through `map`.
fn renumber(obj: &mut [u8], map: &BTreeMap<usize, usize>) {
    let end = dict_part(obj).len();
    let mut spans = refs(&obj[..end]);
    if let Some(h) = find(obj, b" 0 obj", 0) {
        if let Some(n) = number(&obj[..h]) {
            spans.push((0, h, n));
        }
    }
    for (s, e, n) in spans {
        if let Some(m) = map.get(&n) {
            obj[s..e].copy_from_slice(m.to_string().as_bytes());
        }
    }
}

/// Put LibreOffice's font runs in /BaseFont order; true when the PDF changed.
pub fn canonical(pdf: &mut [u8]) -> bool {
    try_canonical(pdf).unwrap_or(false)
}

fn try_canonical(pdf: &mut [u8]) -> Option<bool> {
    let (xref_at, objs) = xref(pdf)?;
    // each object's bytes run to the next object (or the cross-reference table)
    let mut by_offset: Vec<(usize, usize)> = objs.iter().map(|(&n, &(o, _))| (o, n)).collect();
    by_offset.sort_unstable();
    let mut span = BTreeMap::new();
    for (k, &(o, n)) in by_offset.iter().enumerate() {
        let end = by_offset.get(k + 1).map_or(xref_at, |&(next, _)| next);
        if end <= o {
            return None;
        }
        span.insert(n, (o, end));
    }
    let body = |n: usize| -> &[u8] { &pdf[span[&n].0..span[&n].1] };
    // font dictionaries and the objects each one reaches
    let mut fonts: Vec<(Vec<u8>, Vec<usize>)> = vec![];
    for &n in objs.keys() {
        let d = dict_part(body(n));
        if find(d, b"/Type/Font", 0).is_none() {
            continue;
        }
        let Some(b) = find(d, b"/BaseFont/", 0) else {
            continue;
        };
        let name: Vec<u8> = d[b + 10..]
            .iter()
            .take_while(|c| !c.is_ascii_whitespace() && !b"/<>[]()".contains(c))
            .copied()
            .collect();
        let mut seen = BTreeSet::from([n]);
        let mut todo = vec![n];
        while let Some(m) = todo.pop() {
            for (_, _, r) in refs(dict_part(body(m))) {
                if !span.contains_key(&r) {
                    return None;
                }
                if seen.insert(r) {
                    todo.push(r);
                }
            }
        }
        fonts.push((name, seen.into_iter().collect()));
    }
    if fonts.len() < 2 {
        return Some(false);
    }
    // the runs must be disjoint, numbered consecutively, and laid out in number order, one after another
    fonts.sort_by_key(|f| f.1[0]);
    let lo = fonts[0].1[0];
    let mut next = lo;
    for (_, run) in &fonts {
        for &n in run {
            if n != next || (n > lo && span[&(n - 1)].1 != span[&n].0) {
                return None;
            }
            next += 1;
        }
    }
    let (start, end) = (span[&lo].0, span[&(next - 1)].1);
    let mut sorted = fonts.clone();
    sorted.sort_by(|a, b| a.0.cmp(&b.0));
    if sorted.windows(2).any(|w| w[0].0 == w[1].0) {
        return None;
    }
    if sorted
        .iter()
        .map(|f| f.1[0])
        .eq(fonts.iter().map(|f| f.1[0]))
    {
        return Some(false);
    }
    let mut map = BTreeMap::new();
    let mut k = lo;
    for (_, run) in &sorted {
        for &n in run {
            if n.to_string().len() != k.to_string().len() {
                return None;
            }
            map.insert(n, k);
            k += 1;
        }
    }
    // the new run region, and every other object's references
    let mut region = Vec::with_capacity(end - start);
    let mut offsets = BTreeMap::new();
    for (_, run) in &sorted {
        for &n in run {
            offsets.insert(map[&n], start + region.len());
            let mut obj = body(n).to_vec();
            renumber(&mut obj, &map);
            region.extend_from_slice(&obj);
        }
    }
    let rest: Vec<usize> = objs
        .keys()
        .copied()
        .filter(|n| !map.contains_key(n))
        .collect();
    pdf[start..end].copy_from_slice(&region);
    for n in rest {
        let (s, e) = span[&n];
        renumber(&mut pdf[s..e], &map);
    }
    for (n, o) in offsets {
        let field = objs[&n].1;
        pdf[field..field + 10].copy_from_slice(format!("{o:010}").as_bytes());
    }
    Some(true)
}

#[cfg(test)]
mod tests {
    use super::*;

    /// A PDF with a catalog (1), a font resource dictionary (2), `null` filler and one 3-object run per font from
    /// object `first` on, in `order`.
    fn pdf_from(first: usize, order: &[&str]) -> Vec<u8> {
        let mut objs: Vec<String> = vec![];
        let mut res = String::new();
        for (k, name) in order.iter().enumerate() {
            let base = first + k * 3;
            let font = (*name).to_string();
            let key = format!("F{}", font.as_bytes()[0] - b'A' + 1);
            objs.push(format!(
                "<</Length {} 0 R>>\nstream\n{font}{font} 0 R\nendstream",
                base + 1
            ));
            objs.push(format!("{}", 70 + k));
            objs.push(format!(
                "<</Type/Font/Subtype/TrueType/BaseFont/{font}/FontFile2 {base} 0 R>>"
            ));
            res.push_str(&format!("/{key} {} 0 R", base + 2));
        }
        let mut out = b"%PDF-1.4\n".to_vec();
        let mut offs = vec![];
        let mut all = vec![
            "<</Type/Catalog/Fonts 2 0 R>>".to_string(),
            format!("<<{res}>>"),
        ];
        all.extend((3..first).map(|_| "null".to_string()));
        all.extend(objs);
        for (k, o) in all.iter().enumerate() {
            offs.push(out.len());
            out.extend_from_slice(format!("{} 0 obj\n{o}\nendobj\n\n", k + 1).as_bytes());
        }
        let x = out.len();
        out.extend_from_slice(
            format!("xref\n0 {}\n0000000000 65535 f \n", all.len() + 1).as_bytes(),
        );
        for o in offs {
            out.extend_from_slice(format!("{o:010} 00000 n \n").as_bytes());
        }
        out.extend_from_slice(
            format!(
                "trailer\n<</Size {}/Root 1 0 R>>\nstartxref\n{x}\n%%EOF\n",
                all.len() + 1
            )
            .as_bytes(),
        );
        out
    }

    fn pdf(order: &[&str]) -> Vec<u8> {
        pdf_from(11, order)
    }

    #[test]
    fn font_runs_in_any_order_come_out_the_same() {
        let want = pdf(&["BAAAAA+Bold", "CAAAAA+Regular", "DAAAAA+Italic"]);
        let mut a = want.clone();
        assert!(!canonical(&mut a));
        assert_eq!(a, want);
        for order in [
            ["CAAAAA+Regular", "BAAAAA+Bold", "DAAAAA+Italic"],
            ["DAAAAA+Italic", "CAAAAA+Regular", "BAAAAA+Bold"],
        ] {
            let mut b = pdf(&order);
            assert_eq!(b.len(), want.len());
            assert!(canonical(&mut b));
            // the resource dictionary keys keep naming the same fonts; only the numbers move
            let s = String::from_utf8(b.clone()).unwrap();
            assert!(s.contains("/F2 13 0 R"), "{s}");
            assert_eq!(xref(&b).unwrap().1.len(), 19);
            let (_, objs) = xref(&b).unwrap();
            for (n, (o, _)) in objs {
                assert!(s[o..].starts_with(&format!("{n} 0 obj")), "{n} at {o}");
            }
        }
    }

    #[test]
    fn stream_data_is_never_renumbered() {
        let mut b = pdf(&["CAAAAA+Regular", "BAAAAA+Bold"]);
        assert!(canonical(&mut b));
        let s = String::from_utf8(b).unwrap();
        assert!(s.contains("stream\nBAAAAA+BoldBAAAAA+Bold 0 R\nendstream"));
    }

    #[test]
    fn other_shapes_are_left_alone() {
        let mut b = pdf(&["CAAAAA+Regular", "BAAAAA+Bold"]);
        let x = String::from_utf8(b.clone())
            .unwrap()
            .replace("xref\n0 ", "xref\n1 ");
        let mut y = x.clone().into_bytes();
        assert!(!canonical(&mut y));
        assert_eq!(y, x.into_bytes());
        b.truncate(20);
        assert!(!canonical(&mut b));
        // 9 would become 10: the numbers must keep their digit count
        let src = pdf_from(3, &["DAAAAA+Italic", "CAAAAA+Regular", "BAAAAA+Bold"]);
        let mut z = src.clone();
        assert!(!canonical(&mut z));
        assert_eq!(z, src);
    }
}
