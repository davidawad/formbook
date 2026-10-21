use super::*;

/// The IDs in another order (rotated by one): what a render whose subsets came out in another order writes.
pub(crate) fn rotate_ids(pdf: &mut Vec<u8>) -> bool {
    let rotate = |programs: &[Program]| -> Option<BTreeMap<usize, usize>> {
        let ids: Vec<usize> = programs.iter().map(|p| p.id).collect();
        (ids.len() >= 2).then(|| {
            programs
                .iter()
                .enumerate()
                .map(|(k, p)| (p.obj, ids[(k + 1) % ids.len()]))
                .collect()
        })
    };
    rewrite(pdf, &rotate).unwrap_or(false)
}

/// The (name, ID) of every program, in object order.
fn ids(pdf: &[u8]) -> Vec<(String, usize)> {
    parse(pdf)
        .unwrap()
        .programs
        .iter()
        .map(|p| (String::from_utf8_lossy(&p.name).into_owned(), p.id))
        .collect()
}

fn type1(name: &str, id: usize) -> (Vec<u8>, usize, usize) {
    let clear = format!(
        "%!FontType1-1.0: {name}\n/FontName /{name} def\n/UniqueID {id} def\ncurrentfile eexec\n"
    );
    let private = format!("HDE /Private 8 dict dup begin\n/UniqueID {id} def\n/lenIV 4 def\nend");
    let mut plain = clear.clone().into_bytes();
    plain.extend(encrypt(private.as_bytes()));
    plain.extend_from_slice(b"0000000000\ncleartomark\n");
    (plain, clear.len(), private.len())
}

/// A PDF: a catalog, then per font a FontFile object (with an indirect /Length for all but the last) and its
/// length object.
pub(crate) fn pdf(fonts: &[(&str, usize)]) -> Vec<u8> {
    let mut all = vec!["<</Type/Catalog>>".to_string()];
    let mut streams = vec![];
    for (k, (name, id)) in fonts.iter().enumerate() {
        let (plain, l1, l2) = type1(name, *id);
        let data = miniz_oxide::deflate::compress_to_vec_zlib(&plain, 1);
        let n = all.len() + 1;
        let length = if k + 1 < fonts.len() {
            format!("{} 0 R", n + 1)
        } else {
            data.len().to_string()
        };
        all.push(format!(
            "<</Length {length}/Filter/FlateDecode/Length1 {l1}/Length2 {l2}/Length3 0>>\nstream\n"
        ));
        streams.push((all.len() - 1, data.clone()));
        all.push(data.len().to_string());
    }
    let mut out = b"%PDF-1.4\n".to_vec();
    let mut offs = vec![];
    for (k, o) in all.iter().enumerate() {
        offs.push(out.len());
        out.extend_from_slice(format!("{} 0 obj\n{o}", k + 1).as_bytes());
        if let Some((_, d)) = streams.iter().find(|(i, _)| *i == k) {
            out.extend_from_slice(d);
            out.extend_from_slice(b"\nendstream");
        }
        out.extend_from_slice(b"\nendobj\n");
    }
    let x = out.len();
    out.extend_from_slice(format!("xref\n0 {}\n0000000000 65535 f \n", all.len() + 1).as_bytes());
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

fn well_formed(pdf: &[u8]) {
    let (at, objs) = xref(pdf).expect("a classic cross-reference table");
    assert!(pdf.ends_with(format!("startxref\n{at}\n%%EOF\n").as_bytes()));
    for (n, (o, _)) in objs {
        assert!(
            pdf[o..].starts_with(format!("{n} 0 obj").as_bytes()),
            "{n} at {o}"
        );
    }
}

#[test]
fn eexec_round_trips() {
    let p = b"HDE /Private 8 dict dup begin /UniqueID 4100001 def end".to_vec();
    assert_eq!(decrypt(&encrypt(&p)), p);
    assert_ne!(encrypt(&p), p);
}

#[test]
fn ids_in_any_order_come_out_the_same() {
    let want = pdf(&[
        ("Schola-Bold", 4100001),
        ("Schola-Italic", 4100002),
        ("Schola-Regular", 4100003),
    ]);
    // already in order: only compressed again (another compressor wrote it), and stable from then on
    let mut want = want;
    assert!(canonical(&mut want));
    well_formed(&want);
    let mut a = want.clone();
    assert!(!canonical(&mut a));
    assert_eq!(a, want);
    for order in [[4100003, 4100001, 4100002], [4100002, 4100003, 4100001]] {
        let mut b = pdf(&[
            ("Schola-Bold", order[0]),
            ("Schola-Italic", order[1]),
            ("Schola-Regular", order[2]),
        ]);
        assert!(canonical(&mut b));
        well_formed(&b);
        assert_eq!(
            ids(&b),
            [
                ("Schola-Bold".into(), 4100001),
                ("Schola-Italic".into(), 4100002),
                ("Schola-Regular".into(), 4100003)
            ]
        );
        // the private part carries the same ID, and the file is stable from here
        let p = parse(&b).unwrap().programs;
        let private = decrypt(&p[0].plain[p[0].l1..p[0].l1 + p[0].l2]);
        assert!(String::from_utf8_lossy(&private).contains("/UniqueID 4100001 def"));
        assert!(!canonical(&mut b));
        assert_eq!(b, want);
    }
}

#[test]
fn rotation_is_undone() {
    let want = pdf(&[("A", 4100001), ("B", 4100002), ("C", 4100003)]);
    let mut b = want.clone();
    assert!(rotate_ids(&mut b));
    well_formed(&b);
    assert_ne!(ids(&b), ids(&want));
    assert!(canonical(&mut b));
    assert_eq!(ids(&b), ids(&want));
    let mut want = want;
    canonical(&mut want);
    assert_eq!(b, want);
}

#[test]
fn other_shapes_are_left_alone() {
    for src in [
        pdf(&[("A", 4100002)]),
        pdf(&[("A", 4100002), ("B", 4100002)]),
        pdf(&[("A", 999), ("B", 41)]),
    ] {
        let mut b = src.clone();
        assert!(!canonical(&mut b));
        assert_eq!(b, src);
    }
    let mut b = pdf(&[("B", 4100001), ("A", 4100002)]);
    b.truncate(40);
    let t = b.clone();
    assert!(!canonical(&mut b));
    assert_eq!(b, t);
}
/// Two docx renders of the scotus merits-brief give the same .docx.pdf bytes, and a render whose Type 1 subsets
/// came out in another order (its UniqueIDs rotated, as LibreOffice does by heap order) normalizes to the same
/// bytes too; skipped, and logged to TEST_SKIP_LOG, without pandoc, zip, xmllint, pdftotext or LibreOffice.
#[test]
fn merits_brief_docx_pdf_is_reproducible() {
    let skip = |why: &str| {
        eprintln!("SKIP merits_brief_docx_pdf_is_reproducible: {why}");
        if let Some(log) = std::env::var_os("TEST_SKIP_LOG") {
            use std::io::Write;
            let mut f = std::fs::OpenOptions::new()
                .create(true)
                .append(true)
                .open(log)
                .unwrap();
            writeln!(
                f,
                "t1ids::tests::merits_brief_docx_pdf_is_reproducible: {why}"
            )
            .unwrap();
        }
    };
    let Ok(root) = crate::repo_root() else {
        return skip("no repo root");
    };
    let court = root.join("courts/supreme-court-of-the-united-states/merits-brief");
    if !court.join("usage/INPUT-merits-brief.md").is_file() {
        return skip("no merits-brief INPUT");
    }
    for tool in ["pandoc", "zip", "xmllint", "pdftotext"] {
        if !crate::proc::have(tool) {
            return skip(&format!("{tool} not installed"));
        }
    }
    if !crate::proc::have("soffice") && std::env::var_os("SOFFICE").is_none() {
        return skip("soffice not installed");
    }
    let tmp = std::env::temp_dir().join(format!("fb-t1ids-{}", std::process::id()));
    std::fs::create_dir_all(&tmp).unwrap();
    let sample = std::path::Path::new("usage/INPUT-merits-brief.md");
    let go = |n: &str| {
        let out = tmp.join(format!("{n}.docx.pdf"));
        crate::render::render_one(
            &root,
            "docx",
            &court,
            sample,
            &out,
            crate::render::Warnings::Allow,
        )
        .unwrap();
        std::fs::read(out).unwrap()
    };
    let (a, b) = (go("a"), go("b"));
    let _ = std::fs::remove_dir_all(&tmp);
    assert!(a == b, "two merits-brief .docx.pdf renders differ");
    assert!(
        parse(&a).unwrap().programs.len() >= 2,
        "expected LibreOffice Type 1 programs"
    );
    let mut c = a.clone();
    assert!(rotate_ids(&mut c));
    assert!(c != a);
    let epoch = crate::render::REPRO_EPOCH.parse().unwrap();
    crate::pdfrepro::normalize(&mut c, epoch);
    assert!(
        c == a,
        "a merits-brief render with its font IDs in another order normalizes to other bytes"
    );
}
