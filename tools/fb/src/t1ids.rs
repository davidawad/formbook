//! LibreOffice embeds each font subset of a docx render as a Type 1 program (a FlateDecode FontFile stream: a
//! cleartext part of /Length1 bytes, then /Length2 bytes of eexec-encrypted private part). Its subsetter stamps
//! every program with `/UniqueID 41000NN`, from a counter that runs in the order the subsets are emitted, and that
//! order follows heap addresses: two renders of the same .docx can hand the same three IDs to Regular, Bold and
//! Italic in another permutation (fb-595.71, the scotus merits-brief). `canonical` gives the IDs back in /FontName
//! order (the smallest to the first name), in the cleartext and the private part alike, re-encrypts and
//! re-compresses every program (one compressor for all, whether or not its ID moved) and lays the file out again
//! with a new cross-reference table. The IDs keep their digit count, so /Length1 and /Length2 hold; a PDF of any
//! other shape is left alone. The subset tags (BAAAAA+, ...) came out the same in every render
//! seen (the order of the runs themselves is fontorder.rs).
use crate::fontorder::{dict_part, find, number, xref, Xref};
use std::collections::BTreeMap;

/// Type 1 eexec decryption (Adobe Type 1 Font Format, 7.2): r = 55665, c1 = 52845, c2 = 22719.
fn decrypt(cipher: &[u8]) -> Vec<u8> {
    let mut r: u16 = 55665;
    cipher
        .iter()
        .map(|&c| {
            let p = c ^ (r >> 8) as u8;
            r = (u16::from(c).wrapping_add(r))
                .wrapping_mul(52845)
                .wrapping_add(22719);
            p
        })
        .collect()
}

fn encrypt(plain: &[u8]) -> Vec<u8> {
    let mut r: u16 = 55665;
    plain
        .iter()
        .map(|&p| {
            let c = p ^ (r >> 8) as u8;
            r = (u16::from(c).wrapping_add(r))
                .wrapping_mul(52845)
                .wrapping_add(22719);
            c
        })
        .collect()
}

/// (start, end) of the digits of the first `/UniqueID <n>` in `b`.
fn unique_id(b: &[u8]) -> Option<(usize, usize)> {
    let s = find(b, b"/UniqueID ", 0)? + 10;
    let e = s + b[s..].iter().take_while(|c| c.is_ascii_digit()).count();
    (e > s).then_some((s, e))
}

/// The integer after `/<key>` in a dictionary (and whether it is an indirect `N 0 R` reference).
fn key_int(dict: &[u8], key: &[u8]) -> Option<(usize, bool)> {
    let mut from = 0;
    loop {
        let at = find(dict, key, from)? + key.len();
        from = at;
        // `/Length` must not match `/Length1`
        if dict.get(at).is_some_and(u8::is_ascii_alphanumeric) {
            continue;
        }
        let rest = &dict[at..];
        let skip = rest.iter().take_while(|c| c.is_ascii_whitespace()).count();
        let digits = rest[skip..]
            .iter()
            .take_while(|c| c.is_ascii_digit())
            .count();
        let n = number(&rest[skip..skip + digits])?;
        return Some((n, rest[skip + digits..].starts_with(b" 0 R")));
    }
}

/// One embedded Type 1 program: its object, /FontName, current ID and inflated bytes.
struct Program {
    obj: usize,
    name: Vec<u8>,
    id: usize,
    /// where the compressed data starts and ends, inside the object's bytes
    data: (usize, usize),
    /// the object that holds /Length, when it is indirect
    length_obj: Option<usize>,
    plain: Vec<u8>,
    l1: usize,
    l2: usize,
}

fn program(n: usize, body: &[u8], lengths: &dyn Fn(usize) -> Option<usize>) -> Option<Program> {
    let d = dict_part(body);
    if find(d, b"/Length1", 0).is_none() || find(d, b"/Length2", 0).is_none() {
        return None;
    }
    // FlateDecode and nothing else
    let f = find(d, b"/Filter", 0)?;
    if !d[f + 7..].trim_ascii_start().starts_with(b"/FlateDecode")
        || find(d, b"/DecodeParms", 0).is_some()
    {
        return None;
    }
    let (len, indirect) = key_int(d, b"/Length")?;
    let (l1, _) = key_int(d, b"/Length1")?;
    let (l2, _) = key_int(d, b"/Length2")?;
    let size = if indirect { lengths(len)? } else { len };
    let mut start = d.len() + 6;
    start += match body.get(start..start + 2)? {
        b"\r\n" => 2,
        [b'\n', _] => 1,
        _ => return None,
    };
    let end = start + size;
    let plain = miniz_oxide::inflate::decompress_to_vec_zlib(body.get(start..end)?).ok()?;
    if l1 + l2 > plain.len() {
        return None;
    }
    let clear = &plain[..l1];
    let at = find(clear, b"/FontName /", 0)? + 11;
    let name: Vec<u8> = clear[at..]
        .iter()
        .take_while(|c| !c.is_ascii_whitespace() && !b"/<>[]()".contains(c))
        .copied()
        .collect();
    let (s, e) = unique_id(clear)?;
    let id = number(&clear[s..e])?;
    // the private part, when it repeats the ID, must agree
    if let Some((ps, pe)) = unique_id(&decrypt(&plain[l1..l1 + l2])) {
        let private = decrypt(&plain[l1..l1 + l2]);
        if number(&private[ps..pe]) != Some(id) {
            return None;
        }
    }
    Some(Program {
        obj: n,
        name,
        id,
        data: (start, end),
        length_obj: indirect.then_some(len),
        plain,
        l1,
        l2,
    })
}

/// The program with every `/UniqueID` set to `id` (same digit count), compressed again.
fn with_id(p: &Program, id: usize) -> Vec<u8> {
    let digits = id.to_string();
    let mut plain = p.plain.clone();
    let (s, e) = unique_id(&plain[..p.l1]).expect("checked in program()");
    plain[s..e].copy_from_slice(digits.as_bytes());
    let mut private = decrypt(&plain[p.l1..p.l1 + p.l2]);
    if let Some((s, e)) = unique_id(&private) {
        private[s..e].copy_from_slice(digits.as_bytes());
    }
    plain[p.l1..p.l1 + p.l2].copy_from_slice(&encrypt(&private));
    miniz_oxide::deflate::compress_to_vec_zlib(&plain, 6)
}

/// A file's cross-reference table, each object's (offset, end), and its programs in object order.
struct Parsed {
    xref: Xref,
    span: BTreeMap<usize, (usize, usize)>,
    programs: Vec<Program>,
}

/// None when the file is not of the expected shape.
fn parse(pdf: &[u8]) -> Option<Parsed> {
    let (xref_at, objs) = xref(pdf)?;
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
    let lengths = |m: usize| -> Option<usize> {
        let (s, e) = *span.get(&m)?;
        let b = &pdf[s..e];
        let at = find(b, b" obj", 0)? + 4;
        let digits: Vec<u8> = b[at..]
            .iter()
            .skip_while(|c| c.is_ascii_whitespace())
            .take_while(|c| c.is_ascii_digit())
            .copied()
            .collect();
        number(&digits)
    };
    let programs = span
        .iter()
        .filter_map(|(&n, &(s, e))| program(n, &pdf[s..e], &lengths))
        .collect();
    Some(Parsed {
        xref: (xref_at, objs),
        span,
        programs,
    })
}

/// Object number -> UniqueID for the programs of a file.
type Assign = dyn Fn(&[Program]) -> Option<BTreeMap<usize, usize>>;

/// Lay the file out again with the programs' IDs from `assign` (object number -> ID); true when it changed.
fn rewrite(pdf: &mut Vec<u8>, assign: &Assign) -> Option<bool> {
    let Parsed {
        xref: (xref_at, objs),
        span,
        programs,
    } = parse(pdf)?;
    let ids = assign(&programs)?;
    let mut bodies: BTreeMap<usize, Vec<u8>> = BTreeMap::new();
    for p in &programs {
        // every program is compressed again, so a render that needed no new IDs keeps no other compressor's bytes
        let (s, e) = span[&p.obj];
        let old = &pdf[s..e];
        let data = with_id(p, ids[&p.obj]);
        if data == old[p.data.0..p.data.1] {
            continue;
        }
        let mut body = old[..p.data.0].to_vec();
        body.extend_from_slice(&data);
        body.extend_from_slice(&old[p.data.1..]);
        match p.length_obj {
            Some(m) => {
                let (ls, le) = span[&m];
                let b = &pdf[ls..le];
                let at = find(b, b" obj", 0)? + 4;
                let ds = at
                    + b[at..]
                        .iter()
                        .take_while(|c| c.is_ascii_whitespace())
                        .count();
                let de = ds + b[ds..].iter().take_while(|c| c.is_ascii_digit()).count();
                let mut nb = b[..ds].to_vec();
                nb.extend_from_slice(data.len().to_string().as_bytes());
                nb.extend_from_slice(&b[de..]);
                bodies.insert(m, nb);
            }
            None => {
                let at = find(&body, b"/Length", 0)? + 7;
                let ds = at
                    + body[at..]
                        .iter()
                        .take_while(|c| c.is_ascii_whitespace())
                        .count();
                let de = ds + body[ds..].iter().take_while(|c| c.is_ascii_digit()).count();
                body.splice(ds..de, data.len().to_string().into_bytes());
            }
        }
        bodies.insert(p.obj, body);
    }
    if bodies.is_empty() {
        return Some(false);
    }
    let mut order: Vec<(usize, usize)> = span.iter().map(|(&n, &(s, _))| (s, n)).collect();
    order.sort_unstable();
    let mut out = pdf[..order[0].0].to_vec();
    let mut offsets = BTreeMap::new();
    for (s, n) in order {
        offsets.insert(n, out.len());
        match bodies.get(&n) {
            Some(b) => out.extend_from_slice(b),
            None => out.extend_from_slice(&pdf[s..span[&n].1]),
        }
    }
    let new_xref = out.len();
    let mut tail = pdf[xref_at..].to_vec();
    for (n, o) in offsets {
        let field = objs[&n].1 - xref_at;
        tail[field..field + 10].copy_from_slice(format!("{o:010}").as_bytes());
    }
    let sx = tail.windows(9).rposition(|w| w == b"startxref")? + 9;
    let ds = sx
        + tail[sx..]
            .iter()
            .take_while(|c| c.is_ascii_whitespace())
            .count();
    let de = ds + tail[ds..].iter().take_while(|c| c.is_ascii_digit()).count();
    tail.splice(ds..de, new_xref.to_string().into_bytes());
    out.extend_from_slice(&tail);
    *pdf = out;
    Some(true)
}

/// The IDs in /FontName order: the sorted IDs go to the programs sorted by (name, object number). None unless
/// there are two or more programs with distinct IDs of one digit count.
fn by_name(programs: &[Program]) -> Option<BTreeMap<usize, usize>> {
    let mut ids: Vec<usize> = programs.iter().map(|p| p.id).collect();
    ids.sort_unstable();
    ids.dedup();
    let width = ids.first()?.to_string().len();
    if ids.len() < 2
        || ids.len() != programs.len()
        || ids.iter().any(|i| i.to_string().len() != width)
    {
        return None;
    }
    let mut named: Vec<&Program> = programs.iter().collect();
    named.sort_by(|a, b| (&a.name, a.obj).cmp(&(&b.name, b.obj)));
    Some(named.iter().zip(ids).map(|(p, id)| (p.obj, id)).collect())
}

/// Give LibreOffice's Type 1 UniqueIDs back in /FontName order; true when the PDF changed.
pub fn canonical(pdf: &mut Vec<u8>) -> bool {
    rewrite(pdf, &by_name).unwrap_or(false)
}

#[cfg(test)]
#[path = "t1ids_tests.rs"]
mod tests;
