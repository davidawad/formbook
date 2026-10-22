use super::families::*;
use super::*;

fn t(folder: &str, src: &str, stem: &str) -> Template {
    Template {
        folder: folder.into(),
        toks: tokens(src, stem),
    }
}

#[test]
fn tokens_drop_comments_and_parameters() {
    let a = tokens(
        "#let size = 14pt // rule 1\n#let x = \"Times\" /* c */\n#ga-brief(meta)",
        "ga-brief",
    );
    let b = tokens(
        "#let size = 12.5pt\n#let x = \"Gelasio\"\n#me-brief(meta)",
        "me-brief",
    );
    assert_eq!(a, b);
    assert_eq!(a[..4], ["#", "let", "size", "="]);
    assert!(
        a.contains(&"F".to_string())
            && a.contains(&"N".to_string())
            && a.contains(&"S".to_string())
    );
}

#[test]
fn tokens_keep_a_url_in_a_string() {
    assert_eq!(tokens("\"https://x.y\" a", ""), ["S", "a"]);
}

#[test]
fn jaccard_bounds() {
    let a = shingles(&tokens("a b c d e f g", ""));
    let b = shingles(&tokens("a b c d e f h", ""));
    assert_eq!(jaccard(&a, &a), 1.0);
    let j = jaccard(&a, &b);
    assert!(j > 0.3 && j < 1.0, "{j}");
}

#[test]
fn clusters_exact_and_near() {
    let base = "set page(margin: 1in) set text(font: \"X\", size: 12pt) let f(meta, body) = { caption(meta) body sig(meta) cert(meta) }";
    let ts = vec![
        t("a/state/x/brief", base, "x"),
        t("b/state/y/brief", &base.replace("12pt", "14pt"), "y"),
        t("c/state/z/motion", &format!("{base} let extra = 1"), "z"),
        t(
            "d/state/w/other",
            "grid(columns: 2) table(x) foo bar baz qux",
            "w",
        ),
    ];
    let exact = cluster(&ts, None);
    assert_eq!(exact.len(), 3);
    assert_eq!(exact[0], vec![0, 1]);
    let near = cluster(&ts, Some(0.7));
    assert_eq!(near.len(), 2);
    assert_eq!(near[0], vec![0, 1, 2]);
    assert_eq!(histogram(&near), vec![(3, 1), (1, 1)]);
}

#[test]
fn state_and_type_of_a_folder() {
    let (s, d) = state_and_type(Path::new(
        "courts/first-circuit/maine/state/sjc/reply-brief",
    ));
    assert_eq!((s.as_str(), d.as_str()), ("maine", "reply-brief"));
}

const LAYOUT: &str = "size: 13\npitch: {body: 29.9, single: 14.95}\nmargin: {top: 72, bottom: 72, left: 72, right: 72}\nindent: 36\nfront:\n  - {text: \"{court}\", align: center, bold: true}\n  - {rule: 0.5, above: 7.8}\n";

fn layout(s: &str) -> serde_yaml::Value {
    serde_yaml::from_str(s).unwrap()
}

#[test]
fn lengths_are_whole_twips_and_sizes_half_points() {
    use super::gen::*;
    assert_eq!(twips(29.9, "x"), Ok(598));
    assert!(twips(14.93, "pitch.single")
        .unwrap_err()
        .contains("whole number of twips"));
    let mut errs = Vec::new();
    validate(&layout("size: 13.3\npitch: {body: 29.91}\n"), "", &mut errs);
    assert_eq!(errs.len(), 2, "{errs:?}");
    assert!(errs[0].contains("`size`") && errs[1].contains("`pitch.body`"));
}

#[test]
fn the_layout_as_a_lua_table() {
    let l = layout("a: 1.5\nb: [x, \"q\\\"\"]\nc: {d: true, e: ~}\n");
    let s = super::gen::lua(&l, 0);
    assert_eq!(
        s,
        "{\n  [\"a\"] = 1.5,\n  [\"b\"] = {\n    \"x\",\n    \"q\\\"\",\n  },\n  [\"c\"] = {\n    [\"d\"] = true,\n  },\n}"
    );
}

#[test]
fn one_latex_face_per_typst_face() {
    use super::gen::latex_face;
    assert_eq!(
        latex_face("Times New Roman").unwrap().0,
        "\\usepackage{newtxtext,newtxmath}"
    );
    assert_eq!(latex_face("Times New Roman").unwrap().1, Some(1.0));
    assert!(latex_face("TeX Gyre Schola").is_err());
    assert!(latex_face("Comic Sans").is_err());
}

#[test]
fn the_page_number_sits_where_typst_sets_it() {
    // typst: the footer 30 % of the bottom margin below the text, the number in a single line box
    let (ps, skip, dist) = super::gen::footer(&layout(LAYOUT)).unwrap();
    assert_eq!(ps, 14.95);
    assert!((skip - (21.6 + 11.96)).abs() < 1e-9);
    assert!((dist - (50.4 - 14.95)).abs() < 1e-9);
}

#[test]
fn generates_the_four_engine_files() {
    let files = super::gen::generate(&layout(LAYOUT), "Times New Roman").unwrap();
    let names: Vec<&str> = files.iter().map(|(n, _)| n.as_str()).collect();
    assert_eq!(
        names,
        [
            "latex/template.tex",
            "latex/xdoc.lua",
            "docx/reference.xml",
            "docx/xdoc.lua"
        ]
    );
    let tex = &files[0].1;
    assert!(tex.contains("\\renewcommand\\normalsize{\\xe@lines{13}{29.9}}"));
    assert!(tex.contains("\\usepackage{newtxtext,newtxmath}"));
    assert!(tex.contains("footskip=33.56bp"));
    assert!(tex.contains("$body$") && tex.contains("\\usepackage{xengine}"));
    let xml = &files[2].1;
    assert!(xml.contains(r#"base="xengine" size="26" body="598" single="299" indent="720""#));
    assert!(xml.contains(r#"w:footer="709""#) && xml.contains("rIdFooter1"));
    assert!(files[3].1.contains("return require(\"docx.xdoc\")({"));
    assert!(files[1].1.contains("[\"rule\"] = 0.5,"));
    assert!(super::gen::generate(&layout("size: 13\n"), "Times New Roman").is_err());
}
