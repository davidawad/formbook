//! Tests of the shared document model itself (lib/typst/xdoc.typ, lib/pandoc/xdoc.lua, lib/latex/xdoc.lua,
//! lib/docx/xdoc.lua): a small layout and sample run through each engine's half of the model, the typst side with
//! `typst eval` / `typst compile`, the LaTeX and Word sides with pandoc and the generated filters (no pdflatex or
//! LibreOffice: the tests read the LaTeX source and the Word XML the filters write). A test whose tools are not on
//! PATH is skipped (it prints why).
use super::gen;
use std::path::{Path, PathBuf};
use std::process::Command;

/// A doc folder for one test under tools/fb/target/model-tests/ (inside the repo: typst reads only below its root).
pub struct Fx {
    pub root: PathBuf,
    pub dir: PathBuf,
}

fn root() -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("../..")
        .canonicalize()
        .unwrap()
}

fn have(tools: &[&str]) -> bool {
    let missing: Vec<&&str> = tools.iter().filter(|t| !crate::proc::have(t)).collect();
    if !missing.is_empty() {
        eprintln!("model test skipped: {missing:?} not on PATH");
    }
    missing.is_empty()
}

const MAIN: &str = r#"#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter
#let (meta, body) = split-frontmatter(read("../usage/INPUT.md"))
#xdoc(yaml("layout.yaml") + (font: ("Liberation Serif",)), meta, body)
"#;

/// A fixture `name` with this layout and sample (frontmatter and body), its engines generated for Times New Roman
/// (or `face`); None (skipped) when `tools` are missing.
pub fn fx(name: &str, layout: &str, sample: &str, tools: &[&str]) -> Option<Fx> {
    fx_face(name, layout, sample, tools, "Times New Roman")
}

pub fn fx_face(name: &str, layout: &str, sample: &str, tools: &[&str], face: &str) -> Option<Fx> {
    if !have(tools) {
        return None;
    }
    let root = root();
    let dir = root.join("tools/fb/target/model-tests").join(name);
    let _ = std::fs::remove_dir_all(&dir);
    for d in ["typst", "usage", "latex", "docx"] {
        std::fs::create_dir_all(dir.join(d)).unwrap();
    }
    std::fs::write(dir.join("typst/layout.yaml"), layout).unwrap();
    let font = match face {
        "Times New Roman" => "(\"Liberation Serif\",)".to_string(),
        f => format!("(\"{f}\",)"),
    };
    std::fs::write(
        dir.join("typst/main.typ"),
        MAIN.replace("(\"Liberation Serif\",)", &font),
    )
    .unwrap();
    std::fs::write(dir.join("usage/INPUT.md"), sample).unwrap();
    let l: serde_yaml::Value = serde_yaml::from_str(layout).unwrap();
    for (rel, text) in gen::generate(&l, face).unwrap() {
        std::fs::write(dir.join(rel), text).unwrap();
    }
    crate::docxpass::write_meta(&dir.join("usage/INPUT.md"), &dir).unwrap();
    Some(Fx { root, dir })
}

impl Fx {
    fn typst(&self, args: &[&str]) -> std::process::Output {
        Command::new("typst")
            .args(args)
            .arg("--root")
            .arg(&self.root)
            .arg("--font-path")
            .arg(self.root.join("fonts"))
            .arg("--ignore-system-fonts")
            .arg("--package-cache-path")
            .arg(self.root.join("vendor/typst-packages"))
            .output()
            .unwrap()
    }

    /// A typst expression evaluated in the context of the rendered fixture (`typst eval --in`), as JSON.
    pub fn typst_eval(&self, expr: &str) -> Result<String, String> {
        let main = self.dir.join("typst/main.typ");
        let o = self.typst(&["eval", expr, "--in", main.to_str().unwrap()]);
        if o.status.success() {
            Ok(String::from_utf8_lossy(&o.stdout).trim().to_string())
        } else {
            Err(String::from_utf8_lossy(&o.stderr).into_owned())
        }
    }

    /// The typst render's text, page by page (pdftotext -layout; pages split at form feeds).
    pub fn typst_pages(&self) -> Result<Vec<String>, String> {
        let main = self.dir.join("typst/main.typ");
        let pdf = self.dir.join("out.pdf");
        let o = self.typst(&["compile", main.to_str().unwrap(), pdf.to_str().unwrap()]);
        if !o.status.success() {
            return Err(String::from_utf8_lossy(&o.stderr).into_owned());
        }
        let t = Command::new("pdftotext")
            .arg("-layout")
            .arg(&pdf)
            .arg("-")
            .output()
            .unwrap();
        let text = String::from_utf8_lossy(&t.stdout).into_owned();
        let mut pages: Vec<String> = text.split('\u{c}').map(str::to_string).collect();
        if pages.last().is_some_and(|p| p.trim().is_empty()) {
            pages.pop();
        }
        Ok(pages)
    }

    fn pandoc(&self, to: &str, filter: &str) -> Result<String, String> {
        let o = Command::new("pandoc")
            .current_dir(&self.dir)
            .env(
                "LUA_PATH",
                crate::sharedlib::lua_path(&self.root, std::env::var("LUA_PATH").ok().as_deref()),
            )
            .env("FORMBOOK_META", self.dir.join("meta.json"))
            .env("FORMBOOK_NEEDLES", self.dir.join("needles.tsv"))
            .env("FORMBOOK_FINAL", self.dir.join("final.xml"))
            .env("FORMBOOK_FOOTERS", self.dir.join("footers.tsv"))
            .env("FORMBOOK_PAGES", "")
            .args(["--from", crate::docxref::MODEL_FROM, "--to", to])
            .arg(format!("--lua-filter={filter}"))
            .arg("usage/INPUT.md")
            .output()
            .unwrap();
        if o.status.success() {
            Ok(String::from_utf8_lossy(&o.stdout).into_owned())
        } else {
            Err(String::from_utf8_lossy(&o.stderr).into_owned())
        }
    }

    /// The LaTeX body lib/latex/xdoc.lua writes for the fixture.
    pub fn latex(&self) -> Result<String, String> {
        self.pandoc("latex", "latex/xdoc.lua")
    }

    /// The document lib/docx/xdoc.lua writes, as pandoc's native AST (the Word XML in its raw blocks).
    pub fn docx(&self) -> Result<String, String> {
        self.pandoc("native", "docx/xdoc.lua")
    }

    /// A file the docx filter wrote beside the fixture (needles.tsv, final.xml, footers.tsv).
    pub fn written(&self, name: &str) -> Option<String> {
        std::fs::read_to_string(self.dir.join(name)).ok()
    }
}

const PAGE: &str = "size: 12\npitch: {body: 27.6, single: 13.8}\nmargin: {top: 72, bottom: 72, left: 72, right: 72}\nindent: 36\n";

/// The layout of the tests: a 12-point page with `extra`.
pub fn layout(extra: &str) -> String {
    format!("{PAGE}{extra}")
}

#[test]
fn a_cover_without_tables_is_set_and_numbered_apart_in_every_engine() {
    let l = layout(
        "page_number: {align: center, front: lower-roman}\ncover:\n  - {text: \"{court}\", align: center}\n",
    );
    let Some(f) = fx(
        "cover-no-tables",
        &l,
        "---\ncourt: COURT OF TESTS\n---\nThe body.\n",
        &["typst", "pandoc", "pdftotext"],
    ) else {
        return;
    };
    // typst: the cover on page 1 without a number, the body on page 2 numbered 1
    let pages = f.typst_pages().unwrap();
    assert_eq!(pages.len(), 2);
    assert!(
        pages[0].contains("COURT OF TESTS") && !pages[0].contains('1'),
        "{pages:?}"
    );
    assert!(pages[1].contains("The body.") && pages[1].trim_end().ends_with('1'));
    // LaTeX: the cover, then the body numbered from 1 in arabic (no roman tables between)
    let tex = f.latex().unwrap();
    let cover = tex.find("COURT OF TESTS").unwrap();
    let arabic = tex.find("\\pagenumbering{arabic}").unwrap();
    assert!(cover < arabic && arabic < tex.find("The body.").unwrap());
    assert!(!tex.contains("\\pagenumbering{roman}"));
    // Word: the cover in a section of its own without a footer, the body's section numbered from 1
    let doc = f.docx().unwrap();
    assert!(
        doc.contains(">COURT<") && doc.find(">COURT<") < doc.find("rIdXdNone"),
        "{doc}"
    );
    assert!(doc.contains("rIdXdNone"));
    let last = f.written("final.xml").unwrap();
    assert!(last.contains(r#"w:fmt="decimal" w:start="1""#), "{last}");
}

impl Fx {
    /// The typst render's lines per page (docxpages.rs bbox_lines: each line's words and yMax).
    pub fn typst_lines(&self) -> Result<Vec<crate::docxpages::PageLines>, String> {
        self.typst_pages()?;
        let t = Command::new("pdftotext")
            .arg("-bbox-layout")
            .arg(self.dir.join("out.pdf"))
            .arg("-")
            .output()
            .unwrap();
        Ok(crate::docxpages::bbox_lines(&String::from_utf8_lossy(
            &t.stdout,
        )))
    }

    /// The docx filter's document after a pass whose pages file (`id <TAB> page <TAB> label`) is `pages`.
    pub fn docx_after(&self, pages: &str) -> Result<String, String> {
        let p = self.dir.join("pages.tsv");
        std::fs::write(&p, pages).unwrap();
        let o = Command::new("pandoc")
            .current_dir(&self.dir)
            .env(
                "LUA_PATH",
                crate::sharedlib::lua_path(&self.root, std::env::var("LUA_PATH").ok().as_deref()),
            )
            .env("FORMBOOK_META", self.dir.join("meta.json"))
            .env("FORMBOOK_NEEDLES", self.dir.join("needles.tsv"))
            .env("FORMBOOK_FINAL", self.dir.join("final.xml"))
            .env("FORMBOOK_FOOTERS", self.dir.join("footers.tsv"))
            .env("FORMBOOK_PAGES", &p)
            .args([
                "--from",
                crate::docxref::MODEL_FROM,
                "--to",
                "native",
                "--lua-filter=docx/xdoc.lua",
            ])
            .arg("usage/INPUT.md")
            .output()
            .unwrap();
        if o.status.success() {
            Ok(String::from_utf8_lossy(&o.stdout).into_owned())
        } else {
            Err(String::from_utf8_lossy(&o.stderr).into_owned())
        }
    }
}

/// The yMax of the line holding `word` (reduced) on a page.
fn y_of(p: &crate::docxpages::PageLines, word: &str) -> f64 {
    let at = p
        .text
        .find(word)
        .unwrap_or_else(|| panic!("{word} not in {}", p.text));
    p.ymax[at]
}

/// The heights (twips) of the exact one-line spacers of a docx document, in order.
fn spacers(doc: &str) -> Vec<i64> {
    let open = r#"<w:p><w:pPr><w:spacing w:before=\"0\" w:after=\"0\" w:line=\""#;
    let close = r#"\" w:lineRule=\"exact\"/></w:pPr></w:p>"#;
    doc.match_indices(open)
        .filter_map(|(i, m)| {
            let rest = &doc[i + m.len()..];
            let e = rest.find(close)?;
            rest[..e].parse().ok()
        })
        .collect()
}

const FILL_COVER: &str = "page_number: {align: center, from: 2}\ncover:\n  - {text: \"{court}\", align: center, below: 30}\n  - {fill: 1}\n  - {text: \"{title}\", align: center, above: 20}\n  - {fill: 2}\n  - {text: \"{counsel}\", above: 40}\n";

#[test]
fn a_fill_shares_out_the_rest_of_the_page_by_weight() {
    let Some(f) = fx(
        "fill",
        &layout(FILL_COVER),
        "---\ncourt: COURT OF TESTS\ntitle: THE TITLE\ncounsel: Counsel for Appellant\n---\nThe body.\n",
        &["typst", "pandoc", "pdftotext"],
    ) else {
        return;
    };
    // typst: the counsel line ends the text block (720 pt), the title a third of the way down the rest; the blocks'
    // own space next to a fill is dropped
    let lines = f.typst_lines().unwrap();
    let (court, title, counsel) = (
        y_of(&lines[0], "courtoftests"),
        y_of(&lines[0], "thetitle"),
        y_of(&lines[0], "counselforappellant"),
    );
    let pitch = 13.8;
    assert!(
        (counsel + 0.2 * pitch - 2.6 - 720.0).abs() < 0.5,
        "{counsel}"
    );
    let free = (counsel - court) - 2.0 * pitch;
    assert!(
        ((title - court - pitch) - free / 3.0).abs() < 0.5,
        "{court} {title} {counsel}"
    );
    assert!(lines[1].text.contains("thebody"));
    // LaTeX: fill glue by weight, the neighbours' space dropped
    let tex = f.latex().unwrap();
    assert!(
        tex.contains("\\vskip0pt plus 1fill") && tex.contains("\\vskip0pt plus 2fill"),
        "{tex}"
    );
    assert!(!tex.contains("\\addvspace{30bp}") && !tex.contains("\\addvspace{20bp}"));
    // Word: one-twip spacers and the position needles on the first pass; on the next, the measured rest of the page
    let doc = f.docx().unwrap();
    assert_eq!(spacers(&doc), [1, 1], "{doc}");
    let needles = f.written("needles.tsv").unwrap();
    assert!(
        needles.contains("T1\tT\tcourtoftests\t")
            && needles.contains("Y1.1:2\tY\tnselforappellant\t"),
        "{needles}"
    );
    // the first line's yMax 2.6 pt under its baseline: the descent; the last line measured at 100.5 with 2 twips
    // of fills above it: its box ends at 100.5 - 2.6 + 2.76 - 0.1 = 100.56, which leaves 720 - 100.56 - 0.5
    let doc = f.docx_after("T1\t1\t85.64\nY1.1:2\t1\t100.5\n").unwrap();
    let free: f64 = 720.0 - 100.56 - 0.5;
    let want: Vec<i64> = [1.0f64, 2.0]
        .iter()
        .map(|w| (free * w / 3.0 * 20.0).floor() as i64)
        .collect();
    let got = spacers(&doc);
    assert!(
        got.len() == 2 && (got[0] - want[0]).abs() <= 1 && (got[1] - want[1]).abs() <= 1,
        "{got:?} {want:?}"
    );
    let needles = f.written("needles.tsv").unwrap();
    assert!(
        needles.contains(&format!("Y1.1:{}\tY", got[0] + got[1])),
        "{needles}"
    );
}

#[test]
fn a_fill_stands_only_in_a_page_s_own_blocks_before_a_break() {
    let col = layout("cover:\n  - columns:\n      - blocks:\n          - {fill: 1}\n");
    let Some(f) = fx(
        "fill-col",
        &col,
        "---\nx: 1\n---\nBody.\n",
        &["typst", "pandoc", "pdftotext"],
    ) else {
        return;
    };
    assert!(f.typst_pages().unwrap_err().contains("not in a column"));
    assert!(f.latex().unwrap_err().contains("not in a column"));
    assert!(f.docx().unwrap_err().contains("not in a column"));
    let open = layout("front:\n  - {text: \"a\"}\n  - {fill: 1}\n  - {text: \"b\"}\n");
    let f = fx(
        "fill-open",
        &open,
        "---\nx: 1\n---\nBody.\n",
        &["typst", "pandoc"],
    )
    .unwrap();
    assert!(f
        .typst_pages()
        .unwrap_err()
        .contains("followed by a {break: true}"));
    assert!(f
        .latex()
        .unwrap_err()
        .contains("followed by a {break: true}"));
    assert!(f
        .docx()
        .unwrap_err()
        .contains("followed by a {break: true}"));
}

#[test]
fn a_fill_on_a_cover_before_tables() {
    let l = layout(&format!(
        "{FILL_COVER}contents: {{title: Contents, depth: 1, col: 36}}\n"
    ));
    let Some(f) = fx(
        "fill-tables",
        &l,
        "---\ncourt: COURT OF TESTS\ntitle: THE TITLE\ncounsel: Counsel for Appellant\n---\n# Argument\n\nThe body.\n",
        &["typst", "pandoc", "pdftotext"],
    ) else {
        return;
    };
    assert_eq!(f.typst_pages().unwrap().len(), 3);
    assert!(f.latex().unwrap().contains("\\vskip0pt plus 2fill"));
    assert_eq!(spacers(&f.docx().unwrap())[..2], [1, 1]);
    let needles = f.written("needles.tsv").unwrap();
    let (start, top) = (
        needles.find("start\tB").unwrap(),
        needles.find("T1\tT").unwrap(),
    );
    assert!(
        start < top && needles.contains("\nh1\tB\targument"),
        "{needles}"
    );
}

/// A typst expression evaluated with the repo's libraries in reach (`typst eval`), as JSON.
fn typst_expr(expr: &str) -> String {
    let root = root();
    let o = Command::new("typst")
        .args(["eval", "--root"])
        .arg(&root)
        .arg("--package-cache-path")
        .arg(root.join("vendor/typst-packages"))
        .arg(expr)
        .output()
        .unwrap();
    assert!(o.status.success(), "{}", String::from_utf8_lossy(&o.stderr));
    String::from_utf8_lossy(&o.stdout).trim().to_string()
}

/// A Lua chunk run by `pandoc lua` with the repo's lib/ on the path, its output.
fn lua(chunk: &str) -> String {
    let root = root();
    // a file of its own per chunk: the tests run in parallel
    static N: std::sync::atomic::AtomicUsize = std::sync::atomic::AtomicUsize::new(0);
    let n = N.fetch_add(1, std::sync::atomic::Ordering::Relaxed);
    let f = root.join(format!(
        "tools/fb/target/model-tests/chunk-{}-{n}.lua",
        std::process::id()
    ));
    std::fs::create_dir_all(f.parent().unwrap()).unwrap();
    std::fs::write(&f, chunk).unwrap();
    let o = Command::new("pandoc")
        .arg("lua")
        .arg(&f)
        .env(
            "LUA_PATH",
            crate::sharedlib::lua_path(&root, std::env::var("LUA_PATH").ok().as_deref()),
        )
        .output()
        .unwrap();
    assert!(o.status.success(), "{}", String::from_utf8_lossy(&o.stderr));
    String::from_utf8_lossy(&o.stdout).trim().to_string()
}

const WORDS_SAMPLE: &str = "---\nx: 1\n---\nPreamble words here.\n\n# Questions Presented\n\n1. Is *this* counted?[^q]\n\n# Statement of the Case\n\nThe _case_ began [here](http://x.y) on Jan. 1.[^s]\n\n> A quoted line.\n\n# Argument\n\n- One item\n- Two\\* items\n\n# Conclusion\n\nAffirm.\n\n# Certificate of Service\n\nServed.\n\n[^q]: Not counted at all.\n[^s]: Counted note\n    words.\n";

#[test]
fn the_word_count_is_the_template_s_own_in_every_engine() {
    // 3 (preamble) + 14 (Statement: its heading, the text without the link target, the quotation) + 5 (Argument:
    // heading, the list without markers, the escaped star dropped) + 3 (the note it calls); Questions Presented
    // excluded with its note, Conclusion after `through`, the certificate in the tail
    let l = layout("words: {exclude: [\"Questions Presented\"], through: Argument}\ntail: {at: Certificate}\nclosing:\n  - {text: \"This brief has {xd.words} words.\"}\n");
    let Some(f) = fx("words", &l, WORDS_SAMPLE, &["typst", "pandoc", "pdftotext"]) else {
        return;
    };
    let text = f.typst_pages().unwrap().join("");
    assert!(text.contains("This brief has 25 words."), "{text}");
    assert!(f.latex().unwrap().contains("This brief has 25 words."));
    let doc = f.docx().unwrap();
    assert!(doc.contains(">25</w:t>") || doc.contains(" 25 "), "{doc}");
    // over the limit: every engine stops
    let l = layout("words: {exclude: [\"Questions Presented\"], through: Argument, limit: 24}\ntail: {at: Certificate}\n");
    let f = fx("words-limit", &l, WORDS_SAMPLE, &["typst", "pandoc"]).unwrap();
    assert!(f
        .typst_pages()
        .unwrap_err()
        .contains("25 words, over the limit of 24"));
    assert!(f
        .latex()
        .unwrap_err()
        .contains("25 words, over the limit of 24"));
    assert!(f
        .docx()
        .unwrap_err()
        .contains("25 words, over the limit of 24"));
    // `from` starts at a section; a heading no section has is an error
    let l = layout("words: {from: Statement, through: Statement}\n");
    let f = fx("words-from", &l, WORDS_SAMPLE, &["typst", "pandoc"]).unwrap();
    let (c, _) = (f.latex().unwrap(), f.typst_pages().unwrap());
    assert!(!c.is_empty());
    let l = layout("words: {from: Nowhere}\n");
    let f = fx("words-none", &l, WORDS_SAMPLE, &["typst", "pandoc"]).unwrap();
    assert!(f
        .typst_pages()
        .unwrap_err()
        .contains("no level-1 heading starts with `Nowhere`"));
    assert!(f
        .latex()
        .unwrap_err()
        .contains("no level-1 heading starts with `Nowhere`"));
}

#[test]
fn the_word_counters_agree() {
    if !have(&["typst", "pandoc"]) {
        return;
    }
    let cases = [
        "Hello *big* _world_ [link](http://x) [^1]\n# Head\n- item one\n1. two\n> quote \\* x",
        "snake_case stays one; __init__ too; “_quoted_” and (_paren_) _end_",
        "a\u{00A0}b c<br>d <!-- x\ny --> e",
        "  10) ten\n   + plus\n#Hashtag\n## Two words",
    ];
    for c in cases {
        let esc = c
            .replace('\\', "\\\\")
            .replace('"', "\\\"")
            .replace('\n', "\\n");
        let t = typst_expr(&format!(
            "import \"/lib/typst/xdoc.typ\": count-words; count-words(\"{esc}\")"
        ));
        let l = lua(&format!(
            "local xd = require(\"pandoc.xdoc\")\nprint(xd.count_words(\"{}\"))",
            c.replace('\\', "\\\\")
                .replace('"', "\\\"")
                .replace('\n', "\\n")
        ));
        assert_eq!(t, l, "{c:?}");
    }
    assert_eq!(
        typst_expr("import \"/lib/typst/xdoc.typ\": group-digits; (group-digits(1234567), group-digits(999))"),
        "[\"1,234,567\",\"999\"]"
    );
    assert_eq!(
        lua("local xd = require(\"pandoc.xdoc\")\nprint(xd.group_digits(1234567), xd.group_digits(999))"),
        "1,234,567\t999"
    );
}

#[test]
fn schola_is_set_at_the_vendored_advances_in_latex_and_word() {
    let l = layout("heading:\n  - {bold: true}\nclosing:\n  - {text: \"Signed (by counsel)\"}\n");
    let gen: serde_yaml::Value = serde_yaml::from_str(&l).unwrap();
    let files = gen::generate(&gen, "TeX Gyre Schola").unwrap();
    let tex = &files[0].1;
    assert!(tex.contains("\\usepackage{tgschola}") && tex.contains("\\usepackage{xeschola}"));
    assert!(
        tex.contains("\\xeglyph{...}{860}{1000}{860}{1000}"),
        "the ellipsis at Schola's advance"
    );
    assert!(tex.contains("\\let\\xeglyph\\xeglyphcentered"));
    assert!(files[1].1.contains("[\"latex_glyphs\"] = \"schola\""));
    assert!(!files[3].1.contains("latex_glyphs") && files[3].1.contains("[\"digit\"] = 0.556"));
    // Times New Roman keeps its generated files as they were: no glyph filter, Word's own advances
    let tnr = gen::generate(&gen, "Times New Roman").unwrap();
    assert!(!tnr[1].1.contains("latex_glyphs") && !tnr[3].1.contains("face_advances"));
    let Some(f) = fx_face(
        "schola",
        &l,
        "---\nx: 1\n---\n# Heading (one)\n\nA [b] paragraph (two).[^1] \u{2026}\n\n> Quoted (three).\n\n- Item (four)\n\n[^1]: Note (five).\n",
        &["typst", "pandoc"],
        "TeX Gyre Schola",
    ) else {
        return;
    };
    let tex = f.latex().unwrap();
    // every parenthesis of the heading, body, note, quotation, list and closing at the vendored advance
    assert_eq!(tex.matches("\\xeglyph{(}{483}").count(), 6, "{tex}");
    assert!(tex.contains("\\xeglyph{[}{452}") && tex.contains("\\xeflush{}"));
    assert!(tex.contains("\\xd@ellipsis{}"));
    assert!(f.typst_pages().is_ok());
}

#[test]
fn empty_and_false_are_not_set() {
    let l = layout(
        "front:\n  - when: yes\n    blocks: [{text: \"A-yes\"}]\n  - when: no\n    blocks: [{text: \"B-no\"}]\n  - when: blank\n    blocks: [{text: \"C-blank\"}]\n  - when: none\n    blocks: [{text: \"D-none\"}]\n  - when: absent\n    default: true\n    blocks: [{text: \"E-default\"}]\n  - unless: no\n    blocks: [{text: \"F-unless\"}]\n  - unless: yes\n    blocks: [{text: \"G-unless\"}]\n  - {text: \"H-{blank}\", optional: true}\n  - {text: \"I-{yes}\", optional: true}\n  - {text: \"J-{blank}end\"}\n",
    );
    let Some(f) = fx(
        "when",
        &l,
        "---\nyes: x\nno: false\nblank: \"\"\nnone: []\n---\nBody.\n",
        &["typst", "pandoc", "pdftotext"],
    ) else {
        return;
    };
    let want = ["A-yes", "E-default", "F-unless", "I-x", "J-end"];
    let not = ["B-no", "C-blank", "D-none", "G-unless", "H-"];
    let text = f.typst_pages().unwrap().join("");
    let tex = f.latex().unwrap();
    let doc = f
        .docx()
        .unwrap()
        .replace("</w:t></w:r><w:r><w:t xml:space=\\\"preserve\\\">", "");
    for (engine, out) in [("typst", &text), ("latex", &tex), ("docx", &doc)] {
        for w in want {
            assert!(out.contains(w), "{engine}: {w} missing in {out}");
        }
        for n in not {
            assert!(!out.contains(n), "{engine}: {n} set in {out}");
        }
    }
}

#[test]
fn a_ruled_box_of_fixed_size_in_every_engine() {
    let l = layout(
        "cover:\n  - columns:\n      - blocks: [{text: \"{court}\"}]\n      - width: 187.2\n        blocks:\n          - box:\n              - {text: \"COURT USE ONLY\", align: center}\n              - {text: \"Case Number: {case_number}\", above: 7.2}\n            height: 129.6\n            stroke: 0.75\n            inset: 8\n            valign: bottom\n    gutter: 21.6\n  - box: [{text: \"Counsel\"}]\n    stroke: {right: 0.5, bottom: 0.5}\n    inset: {right: 7.2, bottom: 7.2}\n    width: 252\n    above: 14.4\n",
    );
    let Some(f) = fx(
        "box",
        &l,
        "---\ncourt: COURT OF TESTS\ncase_number: 2024CA1\n---\nBody.\n",
        &["typst", "pandoc", "pdftotext"],
    ) else {
        return;
    };
    // typst: the box's text at its foot, 8 pt in from the box's edges (the column starts 72 + 396 - 187.2)
    let lines = f.typst_lines().unwrap();
    let foot = y_of(&lines[0], "casenumber2024ca1");
    let pitch = 13.8;
    assert!(
        (foot + 0.2 * pitch - 2.6 - (72.0 + 129.6 - 8.0)).abs() < 0.5,
        "{foot}"
    );
    // LaTeX: a \vbox of the box's height less its rules, the rules inside it, the blocks inset
    let tex = f.latex().unwrap();
    assert!(
        tex.contains("\\vbox to\\dimexpr129.6bp-0.75bp-0.75bp\\relax"),
        "{tex}"
    );
    assert!(tex.contains("\\vrule width0.75bp") && tex.contains("\\hrule height0.75bp"));
    assert!(tex.contains("\\dimen0=252bp") && tex.contains("\\vrule width0bp"));
    // Word: a one-cell table with the box's borders, its insets as cell margins, an exact row height at its foot
    let doc = f.docx().unwrap();
    assert!(
        doc.contains(r#"<w:trHeight w:val=\"2592\" w:hRule=\"exact\"/>"#),
        "{doc}"
    );
    assert!(doc.contains(r#"<w:vAlign w:val=\"bottom\"/>"#));
    assert!(
        doc.contains(r#"<w:left w:val=\"single\" w:sz=\"6\""#)
            && doc.contains(r#"<w:left w:val=\"nil\"/>"#)
    );
    assert!(doc.contains(r#"<w:right w:w=\"144\" w:type=\"dxa\"/>"#));
}

#[test]
fn the_last_paragraph_is_kept_with_the_closing() {
    let closing = "keep_with_closing: true\nclosing:\n  - group:\n      - {text: \"Respectfully submitted,\"}\n      - {text: \"{signer}\"}\n    above: 27.6\n";
    // a body whose last paragraph ends page 1 with room for one more line: the closing does not fit after it
    let filler: String = (0..22)
        .map(|i| format!("Paragraph {i} of the body.\n\n"))
        .collect();
    let sample = format!("---\nsigner: A. Lawyer\n---\n{filler}The last paragraph.\n");
    let Some(f) = fx(
        "keep",
        &layout(closing),
        &sample,
        &["typst", "pandoc", "pdftotext"],
    ) else {
        return;
    };
    let pages = f.typst_pages().unwrap();
    assert_eq!(pages.len(), 2, "{pages:?}");
    assert!(
        pages[1].contains("The last paragraph.") && pages[1].contains("Respectfully submitted,")
    );
    assert!(!pages[0].contains("The last paragraph."));
    // LaTeX: no break inside the paragraph or after it
    let tex = f.latex().unwrap();
    let at = tex.find("\\interlinepenalty=10000").unwrap();
    assert!(tex[at..].find("The last paragraph.").unwrap() < tex[at..].find("\\nobreak").unwrap());
    // Word: the paragraph in Body Text Keep, the spacer before the closing's table kept with it
    let doc = f.docx().unwrap();
    assert!(
        doc.contains(r#"( "custom-style" , "Body Text Keep" )"#),
        "{doc}"
    );
    assert!(doc.contains(
        r#"<w:keepNext/><w:keepLines/><w:spacing w:before=\"0\" w:after=\"0\" w:line=\"552\""#
    ));
    let gen: serde_yaml::Value = serde_yaml::from_str(&layout(closing)).unwrap();
    assert!(gen::generate(&gen, "Times New Roman").unwrap()[2]
        .1
        .contains("BodyTextKeep"));
    // a last paragraph that calls a footnote is not kept (as the old templates did)
    let sample = "---\nsigner: A. Lawyer\n---\nFirst.\n\nThe last.[^1]\n\n[^1]: A note.\n";
    let f = fx("keep-note", &layout(closing), sample, &["typst", "pandoc"]).unwrap();
    assert!(!f.latex().unwrap().contains("\\interlinepenalty=10000"));
    assert!(!f.docx().unwrap().contains("Body Text Keep"));
}

#[test]
fn a_column_of_parentheses_as_tall_as_the_caption() {
    let l = layout(
        "cover:\n  - columns:\n      - blocks:\n          - each: parties\n            blocks:\n              - {text: \"{name}\"}\n              - {text: \"{role}\", left: 36, above: 3.45}\n      - {width: 14.4, repeat: \")\"}\n      - blocks: [{text: \"No. {case_number}\"}]\n",
    );
    let Some(f) = fx(
        "repeat",
        &l,
        "---\nparties:\n  - {name: \"STATE OF TESTS,\", role: \"Respondent,\"}\n  - {name: \"A PARTY WHOSE NAME IS LONG ENOUGH TO WRAP IN THE COLUMN,\", role: \"Petitioner.\"}\ncase_number: 1\n---\nBody.\n",
        &["typst", "pandoc", "pdftotext"],
    ) else {
        return;
    };
    // typst: 5 lines and 2 x 3.45 pt (0.5 line) of the caption: ceil(5.5 - 0.01) = 6 parentheses
    let text = f.typst_pages().unwrap().join("");
    assert_eq!(text.matches(')').count(), 6, "{text}");
    // LaTeX: the other columns' tallest height (\dimen2) over the pitch, rounded up, in a \loop
    let tex = f.latex().unwrap();
    assert!(
        tex.contains("\\dimen4=\\dimexpr\\dimen2+13.8bp-0.01bp\\relax") && tex.contains("\\loop"),
        "{tex}"
    );
    assert!(tex.contains("\\dimen2=\\dimexpr\\ht0+\\dp0\\relax"));
    // Word: a paragraph of the caption each until measured, bookmarks at the column's first and last lines
    let doc = f.docx().unwrap();
    let rows = |d: &str| d.matches(">)</w:t>").count();
    assert_eq!(rows(&doc), 4, "{doc}");
    assert!(doc.contains(r#"w:name=\"xdr1c1a\""#) && doc.contains(r#"w:name=\"xdr1c1z1\""#));
    let needles = f.written("needles.tsv").unwrap();
    assert!(
        needles.contains("xdr1c1a\tD\txdr1c1a\t") && needles.contains("xdr1c1z1\tD\txdr1c1z1\t")
    );
    // measured: the first line's top at 72, the last's at 141: 69 + 13.8 = 82.8 pt, 6 lines
    let doc = f
        .docx_after("xdr1c1a\t1\t72.000\nxdr1c1z1\t1\t141.000\n")
        .unwrap();
    assert_eq!(rows(&doc), 6);
}

#[test]
fn named_destinations_give_their_line() {
    let listing = "Page  Destination                 Name\n   1 [ XYZ   72  720 null      ] \"xdr1c1a\"\n   2 [ XYZ  130  558 null      ] \"xdr1c1z1\"\n";
    let raw = b"<</Dests<</xdr1c1a[1 0 R/XYZ 72 720 0]/xdr1c1z1[5 0 R/XYZ 130.3 557.6 0]>>>>";
    let d = crate::docxpages::dests(listing, raw, 792.0);
    assert_eq!(d["xdr1c1a"], (1, 72.0));
    assert_eq!(d["xdr1c1z1"].0, 2);
    assert!((d["xdr1c1z1"].1 - 234.4).abs() < 1e-9);
    let got = crate::docxpages::lookup_all("xdr1c1z1\tD\txdr1c1z1\t\n", &[], &[], &d).unwrap();
    assert_eq!(got, "xdr1c1z1\t2\t234.400\n");
}

#[test]
fn an_empty_paragraph_is_a_line_in_every_engine() {
    let l = layout("front:\n  - {text: \"{lines}\"}\n  - {text: \"After.\"}\n  - {break: true}\n");
    let Some(f) = fx(
        "empty",
        &l,
        "---\nlines: [\"First counsel\", \"\", \"Second counsel\"]\n---\nBody.\n",
        &["typst", "pandoc", "pdftotext"],
    ) else {
        return;
    };
    // typst: the empty item keeps a line of 13.8 pt between the two counsel
    let lines = f.typst_lines().unwrap();
    let (a, b) = (
        y_of(&lines[0], "firstcounsel"),
        y_of(&lines[0], "secondcounsel"),
    );
    assert!((b - a - 2.0 * 13.8).abs() < 0.1, "{a} {b}");
    // LaTeX: a paragraph holding an empty box; Word: an empty paragraph (a line of its exact pitch)
    assert!(f
        .latex()
        .unwrap()
        .contains("\\noindent\\xe@lines{12}{13.8}"));
    assert!(f.latex().unwrap().contains(" \\mbox{}\\par"));
    let doc = f.docx().unwrap();
    assert!(
        doc.contains(r#"<w:jc w:val=\"left\"/></w:pPr></w:p>"#),
        "{doc}"
    );
}

#[test]
fn headings_numbered_by_the_template() {
    let l = layout("heading:\n  - {bold: true}\n  - {bold: true, number: \"I.\", label_box: 36}\n  - {bold: true, number: \"A.\", label_box: 36}\n  - {number: \"I\", number_prefix: \"POINT \", label_line: true}\ncontents: {title: Contents, depth: 3, col: 36}\n");
    let Some(f) = fx(
        "numbered",
        &l,
        "---\nx: 1\n---\n# Argument\n\n## First\n\n### Sub one\n\n### Sub two\n\n## Second\n\n### Sub three\n\n# Conclusion\n\n#### Point\n\nEnd.\n",
        &["typst", "pandoc", "pdftotext"],
    ) else {
        return;
    };
    // typst: the labels in the body and in the contents; a level restarts under the one above it
    let text = f.typst_pages().unwrap().join("\n");
    for want in [
        "I.  First",
        "A.  Sub one",
        "B.  Sub two",
        "II.  Second",
        "A.  Sub three",
        "POINT I",
    ] {
        let squeeze = |s: &str| s.split_whitespace().collect::<Vec<_>>().join(" ");
        assert!(
            squeeze(&text).contains(&squeeze(want)),
            "{want} not in {text}"
        );
    }
    // the pandoc engines count alike
    let tex = f.latex().unwrap();
    for want in [
        "\\hbox to36bp{II.\\hfil}Second",
        "\\hbox to36bp{A.\\hfil}Sub three",
        "\\hangindent=36bp",
        "POINT I\\par",
    ] {
        assert!(tex.contains(want), "{want} not in {tex}");
    }
    let doc = f.docx().unwrap();
    assert!(
        doc.contains(r#">II.</w:t></w:r><w:r><w:tab/></w:r>"#),
        "{doc}"
    );
    assert!(doc.contains(r#"<w:ind w:left=\"720\" w:hanging=\"720\""#));
    assert!(doc.contains(">POINT I</w:t>"));
}

#[test]
fn the_numbering_patterns_agree() {
    if !have(&["typst", "pandoc"]) {
        return;
    }
    let cases = [
        ("I.", 14),
        ("A.", 28),
        ("a.", 27),
        ("1.", 9),
        ("(1)", 3),
        ("(a)", 2),
        ("i.", 49),
    ];
    let t = typst_expr(&format!(
        "({},)",
        cases
            .map(|(p, n)| format!("numbering(\"{p}\", {n})"))
            .join(", ")
    ));
    let l = lua(&format!(
        "local xd = require(\"pandoc.xdoc\")\nprint(pandoc.json.encode({{ {} }}))",
        cases
            .map(|(p, n)| format!("xd.numbering(\"{p}\", {n})"))
            .join(", ")
    ));
    assert_eq!(t, l);
}

const KEYED: &str = "contents: {title: Contents, depth: 1, col: 36}\nauthorities:\n  title: Authorities\n  col: 56\n  passim: 3\n  page_heading: \"Page(s)\"\n  kinds:\n    - {kind: case, title: Cases, italic: true}\n    - {kind: statute, title: Statutes}\n";

const KEYED_SAMPLE: &str = "---\nauthorities:\n  zeta: {kind: case, name: \"Zeta v. Alpha\", cite: \"1 U.S. 1 (1800)\"}\n  beta: {kind: case, name: \"Beta v. Gamma\", cite: \"2 U.S. 2 (1801)\"}\n  stat: {kind: statute, name: \"\", cite: \"42 U.S.C. 1983\"}\n  unused: {kind: case, name: \"Unused v. Uncited\", cite: \"3 U.S. 3\"}\n---\n# Argument\n\nSee [*Zeta v. Alpha*, 1 U.S. 1](toa:zeta) and [Beta v. Gamma](toa:beta).[^1] Under [§ 1983](toa:stat), more.\n\n[^1]: Again [*Zeta*](toa:zeta) here.\n";

#[test]
fn keyed_authorities_from_links() {
    let Some(f) = fx(
        "keyed",
        &layout(KEYED),
        KEYED_SAMPLE,
        &["typst", "pandoc", "pdftotext"],
    ) else {
        return;
    };
    // typst: the groups in order, sorted (Beta before Zeta), the uncited entry left out, an empty name dropped
    let pages = f.typst_pages().unwrap();
    let toa = &pages[1];
    let squeeze = |s: &str| s.split_whitespace().collect::<Vec<_>>().join(" ");
    let t = squeeze(toa);
    assert!(t.contains("Cases Page(s)") && t.contains("Statutes"), "{t}");
    let (beta, zeta) = (
        t.find("Beta v. Gamma").unwrap(),
        t.find("Zeta v. Alpha").unwrap(),
    );
    assert!(
        beta < zeta && !t.contains("Unused") && t.contains("42 U.S.C. 1983") && !t.contains(", 42")
    );
    // LaTeX: the marks after each link's first word, numbered by the sorted order (Beta 1, Unused 2, Zeta 3, § 1983 4)
    let tex = f.latex().unwrap();
    for want in [
        "Zeta\\xd@amark{3}",
        "Beta\\xd@amark{1}",
        "\\xd@amark{4}",
        "\\xd@apagesp{3}{3}",
        "\\hfill Page(s)",
    ] {
        assert!(tex.contains(want), "{want} not in {tex}");
    }
    assert!(!tex.contains("\\xd@apagesp{2}") && !tex.contains("toa:"));
    // Word: a needle per link, its find the citation, its text the words after the link
    let _ = f.docx().unwrap();
    let needles = f.written("needles.tsv").unwrap();
    assert!(
        needles.contains("a3.1\tB\tzetavalpha1us1andbetavgamma"),
        "{needles}"
    );
    assert!(needles.contains("a3.2\tN\tzetahere\tzeta"));
    // a link with no entry stops every engine
    let f = fx(
        "keyed-missing",
        &layout(KEYED),
        &KEYED_SAMPLE.replace("toa:beta", "toa:nobody"),
        &["typst", "pandoc"],
    )
    .unwrap();
    assert!(f
        .typst_pages()
        .unwrap_err()
        .contains("`toa:nobody` has no entry"));
    assert!(f.latex().unwrap_err().contains("`toa:nobody` has no entry"));
}

#[test]
fn a_url_breaks_at_the_same_places_in_every_engine() {
    if !have(&["typst", "pandoc"]) {
        return;
    }
    // the pieces: typst and Lua cut alike
    for url in [
        "https://www.cbp.gov/border-security/x.pdf?a=1&b_c=2#f",
        "(http://www.acog.org/~/media/Statements%20of%20Policy/2013.pdf).",
        "www.example.org/a",
        "https://www.vanityfair.com/x/2020/03/the-wire-hbo?srslttid=AfmBO_Y!9-2024/U.S.%20B",
    ] {
        let t = typst_expr(&format!(
            "import \"/lib/typst/xdoc.typ\": url-pieces, URL; let m = \"{url}\".match(URL); url-pieces(m.text).join(\"|\")"
        ));
        let l = lua(&format!(
            "local xd = require(\"pandoc.xdoc\")\nlocal _, p = xd.url_pieces(\"{url}\")\nprint(pandoc.json.encode(table.concat(p, \"|\")))"
        ));
        assert_eq!(t, l, "{url}");
    }
    let l = layout("");
    let f = fx(
        "url",
        &l,
        "---\nx: 1\n---\nSee https://www.cbp.gov/border-security/along-us-borders here.[^1]\n\n[^1]: And www.example.org/a-b.\n",
        &["typst", "pandoc", "pdftotext"],
    )
    .unwrap();
    // typst: the URL whole in the PDF text (its zero-width spaces leave no trace)
    assert!(f.typst_pages().unwrap()[0]
        .contains("https://www.cbp.gov/border-security/along-us-borders"));
    // LaTeX: \allowbreak between the pieces, in notes too; Word: a zero-width space there
    let tex = f.latex().unwrap();
    assert!(
        tex.contains("gov/\\allowbreak{}border-\\allowbreak{}security/"),
        "{tex}"
    );
    assert!(tex.contains("example.\\allowbreak{}org/"));
    let doc = f.docx().unwrap();
    assert!(
        doc.contains("gov/\u{200B}border-\u{200B}security/") || doc.contains("gov/\\8203border"),
        "{doc}"
    );
}

#[test]
fn keyed_frontmatter_without_a_keyed_table_leaves_the_links() {
    // a layout with no authorities.kinds: the links stay as they were, no engine stops
    let Some(f) = fx(
        "keyed-none",
        &layout(""),
        KEYED_SAMPLE,
        &["typst", "pandoc"],
    ) else {
        return;
    };
    assert!(f.typst_pages().is_ok());
    assert!(!f.latex().unwrap().contains("xd@amark"));
    assert!(f.docx().is_ok());
    // a keyed table without kinds says what is missing
    let l = layout("authorities: {title: Authorities}\n");
    let f = fx("keyed-nokinds", &l, KEYED_SAMPLE, &["typst", "pandoc"]).unwrap();
    assert!(f
        .latex()
        .unwrap_err()
        .contains("authorities.kinds names their groups"));
}

#[test]
fn certificates_set_by_the_layout_are_headings_and_follow_the_tail() {
    let l = layout("heading:\n  - {bold: true, upper: true}\ncontents: {title: Contents, depth: 1, col: 36}\nclosing:\n  - {text: \"Signed.\"}\n  - {text: \"Certificate of Compliance\", heading: 1}\n  - {text: \"It complies.\"}\ntail: {at: Appendix}\nafter_tail:\n  - {text: \"Certificate of Service\", heading: 1}\n  - {text: \"Served.\"}\n");
    let Some(f) = fx(
        "lheads",
        &l,
        "---\nx: 1\n---\n# Argument\n\nText.\n\n# Appendix\n\nThe appendix.\n",
        &["typst", "pandoc", "pdftotext"],
    ) else {
        return;
    };
    // typst: the contents lists every heading in document order, the layout's in their own words
    let text = f.typst_pages().unwrap().join("\n");
    let order: Vec<usize> = [
        "Argument",
        "Certificate of Compliance",
        "Appendix",
        "Certificate of Service",
    ]
    .iter()
    .map(|w| text.find(w).unwrap_or_else(|| panic!("{w} in {text}")))
    .collect();
    assert!(order.windows(2).all(|p| p[0] < p[1]), "{text}");
    assert!(
        text.contains("CERTIFICATE OF SERVICE")
            && text.rfind("Served.") > text.rfind("The appendix.")
    );
    // LaTeX: the layout headings marked and bookmarked as headings 2 and 4, the contents rows in their order
    let tex = f.latex().unwrap();
    for want in [
        "\\xd@hmark{2}\\pdfbookmark[0]{Certificate of Compliance}",
        "\\xd@hmark{4}\\pdfbookmark[0]{Certificate of Service}",
        "{Certificate of Service}{\\xd@hpage{4}}",
    ] {
        assert!(tex.contains(want), "{want} not in {tex}");
    }
    assert!(tex.find("The appendix.") < tex.find("Served."));
    // Word: a needle for each, in the same order
    let _ = f.docx().unwrap();
    let needles = f.written("needles.tsv").unwrap();
    assert!(
        needles.contains("h2\tB\tcertificateofcompliance")
            && needles.contains("h4\tB\tcertificateofservice"),
        "{needles}"
    );
}

#[test]
fn an_item_by_index_its_number_and_a_value_test() {
    let l = layout("front:\n  - {text: \"First: {lines.0}; second: {signers.1.name}\"}\n  - each: questions\n    blocks: [{text: \"{#}. {.}\"}]\n  - when: position\n    is: front\n    blocks: [{text: \"AT-FRONT\"}]\n  - when: position\n    is: body\n    blocks: [{text: \"AT-BODY\"}]\n  - unless: position\n    is: body\n    blocks: [{text: \"NOT-BODY\"}]\n  - {text: \"{lines.9}\", optional: true}\n  - {break: true}\n");
    let Some(f) = fx(
        "index",
        &l,
        "---\nlines: [\"A. Lawyer\", \"Bar No. 1\"]\nsigners: [{name: \"One\"}, {name: \"Two\"}]\nquestions: [\"Is it?\", \"Was it?\"]\nposition: front\n---\nBody.\n",
        &["typst", "pandoc", "pdftotext"],
    ) else {
        return;
    };
    let want = [
        "First: A. Lawyer; second: Two",
        "1. Is it?",
        "2. Was it?",
        "AT-FRONT",
        "NOT-BODY",
    ];
    let text = f.typst_pages().unwrap().join("\n");
    let tex = f.latex().unwrap();
    let doc = f
        .docx()
        .unwrap()
        .replace("</w:t></w:r><w:r><w:t xml:space=\\\"preserve\\\">", "");
    for (engine, out) in [("typst", &text), ("latex", &tex), ("docx", &doc)] {
        for w in want {
            assert!(out.contains(w), "{engine}: {w} missing in {out}");
        }
        assert!(!out.contains("AT-BODY"), "{engine}");
    }
}

#[test]
fn underlined_text_may_break_in_latex() {
    let l = layout("closing:\n  - {text: \"/s/ {signer}, Bar No. 1, Attorney for *the* Appellant\", underline: true, left: 216}\n");
    let Some(f) = fx(
        "underline",
        &l,
        "---\nsigner: A. Lawyer\n---\nBody under 42 U.S.C. §§ 1983 and 1988.\n",
        &["typst", "pandoc", "pdftotext"],
    ) else {
        return;
    };
    // typst wraps the line under the measure, the doubled section sign whole with its number
    let text = f.typst_pages().unwrap().join("\n");
    assert!(text.contains("§§ 1983"));
    let squeeze: String = text.split_whitespace().collect::<Vec<_>>().join(" ");
    assert!(squeeze.contains("Attorney for the Appellant"), "{text}");
    // LaTeX: whole when it fits, else word by word with underlined spaces that may break
    let tex = f.latex().unwrap();
    assert!(tex.contains("\\xd@ulp{"), "{tex}");
    assert!(
        tex.contains("\\xd@ul{Lawyer,}\\allowbreak\\xd@ulsp{}\\xd@ul{Bar}"),
        "{tex}"
    );
    assert!(tex.contains("\\xd@ul{{{\\xd@em the}}}"), "{tex}");
}

/// fb-595.54.13's tests of the features it added to the model (heading numbers boxed in the `hang`, `{body_words}`,
/// a field's default, CommonMark lists, a URL's breaks), on the merged model.
mod numbers_counts_urls {
    use super::{have, lua, root};
    use std::process::Command;

    const SAMPLE: &str = "---\ntitle: x\n---\n\n# Argument\n\n## First point\n\nA b-c d.[^1] see https://a.org/b/c-d/2015/11/x.\n\n### Sub\n\n## Second point\n\n# Conclusion\n\n— end\n\n# Certificate of Service\n\nNot counted here.\n\n[^1]: A note.\n";

    #[test]
    fn pandoc_side_numbers_counts_and_breaks() {
        if !have(&["pandoc"]) {
            return;
        }
        let out = lua(&format!(
            r#"local xd = require("pandoc.xdoc")
local src = {src:?}
local doc = pandoc.read(src, "markdown+smart")
local spec = {{ heading = {{ {{ align = "center" }}, {{ number = "I.", hang = 36 }}, {{ number = "A.", hang = 36 }} }} }}
local labels, n = xd.heading_labels(spec, doc.blocks), 0
local t = {{}}
for _, b in ipairs(doc.blocks) do
  if b.t == "Header" then n = n + 1; t[#t + 1] = labels[n] or "-" end
end
print(table.concat(t, " "))
print(xd.numbering("(a)", 28), xd.numbering("i.", 4), xd.numbering("1.", 12))
print(xd.plain_words(src, "Certificate"), xd.plain_words(src, nil))
local _, pieces = xd.url_pieces("https://a.org/b/c-d/2015/")
print(table.concat(pieces, "|"))
print(xd.lookup({{ a = {{}} }}, "a.b|___"), xd.lookup({{ a = {{ b = "x" }} }}, "a.b|___"))
local ls = xd.commonmark_lists(pandoc.read("a. one\n\nb. two\n\n(1) three\n\n1. four\n\nx\n\nc. five\nd. six\n", "markdown").blocks)
local u = {{}}
for _, b in ipairs(ls) do u[#u + 1] = b.t .. ":" .. pandoc.utils.stringify(b) end
print(table.concat(u, " "))"#,
            src = SAMPLE
        ));
        let lines: Vec<&str> = out.lines().collect();
        // level 1 unnumbered, level 2 I. II. (reset by no level-1 heading between them), level 3 A.
        assert_eq!(lines[0], "- I. A. II. - -");
        assert_eq!(lines[1], "(ab)\tiv.\t12.");
        // the body before the certificate: "#" and "—" alone are no words; with the certificate and the note 22
        assert_eq!(lines[2], "13\t22");
        // after the scheme's "//", a dot before a letter or digit, a hyphen before a letter (lib/pandoc/xdoc.lua url_pieces)
        assert_eq!(lines[3], "https://|a.|org/|b/|c-|d/|2015/");
        // a missing field's default; lists CommonMark does not read are paragraphs with their markers
        assert_eq!(lines[4], "___\tx");
        assert_eq!(
            lines[5],
            "Para:a. one Para:b. two Para:(1) three OrderedList:four Para:x Para:c. five d. six"
        );
    }

    #[test]
    fn typst_side_agrees() {
        if !have(&["typst", "pdftotext"]) {
            return;
        }
        let root = root();
        // a root of its own holding a copy of lib/typst (the doc imports "/lib/typst/xdoc.typ")
        let dir = crate::proc::TempDir::new("model-typst").unwrap();
        let lib = dir.path().join("lib/typst");
        std::fs::create_dir_all(&lib).unwrap();
        for e in std::fs::read_dir(root.join("lib/typst")).unwrap() {
            let p = e.unwrap().path();
            std::fs::copy(&p, lib.join(p.file_name().unwrap())).unwrap();
        }
        let layout = "size: 12\npitch: {body: 27.6, single: 13.8}\nmargin: {top: 72, bottom: 72, left: 72, right: 72}\nindent: 36\nheading:\n  - {align: center, bold: true}\n  - {bold: true, number: \"I.\", hang: 36}\n  - {bold: true, number: \"A.\", hang: 36}\ncontents: {title: \"Contents\", depth: 3, col: 36}\nclosing:\n  - {text: \"Words: {body_words}. {missing|___} {title|no}.\"}\ntail: {at: \"Certificate\"}\n";
        std::fs::write(dir.path().join("INPUT.md"), SAMPLE).unwrap();
        std::fs::write(dir.path().join("layout.yaml"), layout).unwrap();
        let main = dir.path().join("main.typ");
        std::fs::write(
            &main,
            "#import \"/lib/typst/xdoc.typ\": xdoc, split-frontmatter\n#let (meta, body) = split-frontmatter(read(\"INPUT.md\"))\n#xdoc(yaml(\"layout.yaml\") + (font: (\"Liberation Serif\",)), meta, body)\n",
        )
        .unwrap();
        let pdf = dir.path().join("out.pdf");
        let o = Command::new("typst")
            .args(["compile", "--root"])
            .arg(dir.path())
            .arg("--font-path")
            .arg(root.join("fonts"))
            .arg("--ignore-system-fonts")
            .arg("--package-cache-path")
            .arg(root.join("vendor/typst-packages"))
            .arg(&main)
            .arg(&pdf)
            .output()
            .unwrap();
        assert!(o.status.success(), "{}", String::from_utf8_lossy(&o.stderr));
        let t = Command::new("pdftotext")
            .arg(&pdf)
            .arg("-")
            .output()
            .unwrap();
        let text = String::from_utf8_lossy(&t.stdout).replace('\u{200b}', "");
        // the same numbers in the headings and the contents, the same count as the pandoc side
        assert!(
            text.contains("I.\tFirst point") || text.contains("I. First point"),
            "{text}"
        );
        assert!(text.contains("II."), "{text}");
        assert!(text.contains("A."), "{text}");
        assert!(text.contains("Words: 13. ___ x."), "{text}");
        assert!(text.contains("https://a.org/b/c-d/2015/11/x."), "{text}");
    }

    #[test]
    fn a_numbered_heading_has_one_symbol_and_a_boxed_label_a_left_heading() {
        let l: serde_yaml::Value = serde_yaml::from_str(
            "heading:\n  - {align: center}\n  - {number: \"I.\", hang: 36}\n  - {number: \"I.A\", hang: 36}\n  - {number: \"1.\"}\n  - {number: \"a.\", hang: 36, align: center}\n  - {number: \"a.\", label_box: 36, label_line: true, align: center}\n  - {number: \"1.\", align: center}\n",
        )
        .unwrap();
        let mut errs = Vec::new();
        super::gen::validate_numbers(&l, &mut errs);
        assert_eq!(errs.len(), 2, "{errs:?}");
        assert!(errs[0].contains("heading[2].number") && errs[0].contains("one counting symbol"));
        assert!(errs[1].contains("heading[4].number") && errs[1].contains("left-aligned"));
    }
}

#[test]
fn legal_paper_in_every_engine() {
    // a cover numbered apart: the filter writes its own sections
    let l = layout(
        "paper: legal\npage_number: {align: center, from: 1, front: lower-roman}\ncover:\n  - {text: Cover}\n",
    );
    let Some(f) = fx(
        "legal",
        &l,
        "---\nx: 1\n---\nBody.\n",
        &["typst", "pandoc", "pdfinfo"],
    ) else {
        return;
    };
    // typst: 8.5 x 14 in
    f.typst_pages().unwrap();
    let info = Command::new("pdfinfo")
        .arg(f.dir.join("out.pdf"))
        .output()
        .unwrap();
    let info = String::from_utf8_lossy(&info.stdout);
    assert!(info.contains("612 x 1008 pts"), "{info}");
    // LaTeX: geometry's legalpaper; Word: a 20160-twip page in the reference and in the sections the filter writes
    let tex = std::fs::read_to_string(f.dir.join("latex/template.tex")).unwrap();
    assert!(tex.contains("\\usepackage[legalpaper,top="), "{tex}");
    let refx = std::fs::read_to_string(f.dir.join("docx/reference.xml")).unwrap();
    assert!(refx.contains(r#"<w:pgSz w:w="12240" w:h="20160"/>"#));
    let doc = f.docx().unwrap();
    assert!(
        doc.contains(r#"w:h=\"20160\""#) && !doc.contains("15840"),
        "{doc}"
    );
    // letter is the default; anything else is an error
    let l: serde_yaml::Value = serde_yaml::from_str(&layout("")).unwrap();
    assert_eq!(gen::paper(&l).unwrap(), ("letterpaper", 15840));
    let l: serde_yaml::Value = serde_yaml::from_str(&layout("paper: a4\n")).unwrap();
    assert!(gen::generate(&l, "Times New Roman")
        .unwrap_err()
        .contains("`paper`"));
}

#[test]
fn pages_before_the_tables_are_numbered_with_them() {
    let l = layout(
        "page_number: {align: center, from: 1, front: lower-roman}\ncover:\n  - {text: \"{court}\", align: center}\nbefore_tables:\n  - {text: \"Disclosure Statement\", heading: 1}\n  - {text: \"{party} has no parent.\"}\nbody_before_tables: {until: \"{body_start}\"}\ncontents: {title: Contents, depth: 1, col: 36}\nheading:\n  - {bold: true, align: center}\n",
    );
    let Some(f) = fx(
        "before-tables",
        &l,
        "---\ncourt: COURT OF TESTS\nparty: Acme\nbody_start: Argument\n---\n# Introduction\n\nIntro words.\n\n# Argument\n\nBody words.\n",
        &["typst", "pandoc", "pdftotext"],
    ) else {
        return;
    };
    // typst: the cover; the disclosure (i) and the introduction (ii) before the contents (iii), which lists all three
    // with their pages; the argument from 1
    let pages = f.typst_pages().unwrap();
    assert_eq!(pages.len(), 5, "{pages:?}");
    let num = |p: &str| {
        p.trim_end()
            .rsplit(char::is_whitespace)
            .next()
            .unwrap_or("")
            .to_string()
    };
    assert!(pages[0].contains("COURT OF TESTS"));
    assert!(
        pages[1].contains("Acme has no parent.") && num(&pages[1]) == "i",
        "{pages:?}"
    );
    assert!(
        pages[2].contains("Intro words.") && num(&pages[2]) == "ii",
        "{pages:?}"
    );
    let toc = &pages[3];
    assert!(toc.contains("Contents") && num(toc) == "iii", "{toc}");
    for (row, page) in [
        ("Disclosure Statement", "i"),
        ("Introduction", "ii"),
        ("Argument", "1"),
    ] {
        let line = toc
            .lines()
            .find(|l| l.contains(row))
            .unwrap_or_else(|| panic!("{row}: {toc}"));
        assert!(line.trim_end().ends_with(page), "{line}");
    }
    assert!(
        pages[4].contains("Body words.") && num(&pages[4]) == "1",
        "{pages:?}"
    );
    // LaTeX: roman from the disclosure, the introduction, then the contents, arabic for the argument
    let tex = f.latex().unwrap();
    let at = |s: &str| tex.find(s).unwrap_or_else(|| panic!("{s}: {tex}"));
    assert!(at("\\pagenumbering{roman}") < at("Disclosure Statement"));
    assert!(at("has no parent") < at("Intro words") && at("Intro words") < at("bfseries Contents"));
    assert!(at("\\pagenumbering{arabic}") < at("Body words"));
    // Word: the tables' section starts at the disclosure; the introduction before the contents
    let doc = f.docx().unwrap();
    assert!(doc.find(">Intro<") < doc.find(">Contents<"), "{doc}");
    let needles = f.written("needles.tsv").unwrap();
    let front = needles.lines().find(|l| l.starts_with("front\t")).unwrap();
    assert!(front.contains("disclosurestatement"), "{needles}");
}

#[test]
fn the_body_splits_before_the_tables_alike() {
    let body =
        "Lead.\n\n# One\n\nA.\n\n# Two\n\nB.\n\n{{contents}}\n\n# Three\n\nC.[^1]\n\n[^1]: Note.\n";
    let cases = [
        ("{count: 1}", "{}"),
        ("{count: \"{n}\"}", "{n: 2}"),
        ("{until: Two}", "{}"),
        ("{until: \"{start}\"}", "{start: Three}"),
        ("{marker: \"{{contents}}\"}", "{}"),
        ("{until: \"{start}\"}", "{}"),
        ("{until: Nowhere}", "{}"),
    ];
    if !have(&["typst", "pandoc"]) {
        return;
    }
    for (b, meta) in cases {
        let esc = body
            .replace('\\', "\\\\")
            .replace('"', "\\\"")
            .replace('\n', "\\n");
        let t = typst_expr(&format!(
            "import \"/lib/typst/xdoc.typ\": split-head; let (p, m) = split-head(yaml(bytes(\"body_before_tables: {b}\")), yaml(bytes(\"{m}\")), \"{esc}\"); (p.split(\"\\n\\n\").filter(x => x.starts-with(\"# \")).map(x => x.slice(2)), m.split(\"\\n\\n\").filter(x => x.starts-with(\"# \")).map(x => x.slice(2)))",
            b = b.replace('"', "\\\""),
            m = meta.replace('"', "\\\""),
        ));
        let l = lua(&format!(
            "local xd = require(\"pandoc.xdoc\")\nlocal spec = pandoc.json.decode([[{{\"body_before_tables\": {bj}}}]])\nlocal meta = pandoc.json.decode([[{mj}]])\nlocal p, m = xd.split_head(spec, pandoc.read(\"{esc}\", \"markdown\").blocks, meta)\nlocal function hs(bs) local o = {{}} for _, x in ipairs(bs) do if x.t == \"Header\" then o[#o + 1] = pandoc.utils.stringify(x) end end return o end\nprint(pandoc.json.encode({{ hs(p), hs(m) }}))",
            bj = yaml_json(b),
            mj = yaml_json(meta),
        ));
        assert_eq!(
            t.replace([' ', '\n'], "")
                .replace(",)", ")")
                .replace('(', "[")
                .replace(')', "]"),
            l.replace("{}", "[]"),
            "{b} {meta}"
        );
    }
}

/// A YAML flow value as JSON.
fn yaml_json(y: &str) -> String {
    let v: serde_yaml::Value = serde_yaml::from_str(y).unwrap();
    serde_json::to_string(&v).unwrap()
}

#[test]
fn no_break_before_a_closing_mark_after_a_space() {
    // typst never breaks before ". , : ; ! ? ) ] }" even after a space (LB13); LaTeX and Word bind the space alike
    let l = layout("");
    let Some(f) = fx(
        "no-break-punct",
        &l,
        "---\nx: 1\n---\nThe following means . . . . Id. and so , then ) x.\n",
        &["pandoc"],
    ) else {
        return;
    };
    let tex = f.latex().unwrap().replace('\n', " ");
    assert!(
        tex.contains(
            "means\\nobreak\\space{}.\\nobreak\\space{}.\\nobreak\\space{}.\\nobreak\\space{}. Id."
        ),
        "{tex}"
    );
    assert!(
        tex.contains("so\\nobreak\\space{}, then\\nobreak\\space{}) x."),
        "{tex}"
    );
    // Word: the body's Strs (pandoc's writer), a four-per-em space and a word joiner before each dot (Times New
    // Roman; LibreOffice breaks a run of no-break spaces that overflows)
    let doc: String = f.docx().unwrap().split_whitespace().collect();
    assert!(
        doc.contains(r#"Str"means",Str"\8197\8288",Str".",Str"\8197\8288",Str".""#),
        "{doc}"
    );
}

#[test]
fn justified_text_stretches_spaces_only() {
    let l = layout("justify: true\nheading:\n  - {bold: true}\nquote: {left: 36, right: 36}\n");
    let Some(f) = fx(
        "justify",
        &l,
        "---\nx: 1\n---\n# A heading\n\nBody words here.[^1]\n\n> A quotation.\n\n[^1]: A note.\n",
        &["typst", "pandoc", "pdftotext"],
    ) else {
        return;
    };
    f.typst_pages().unwrap();
    // typst: the body, its quotations and notes justified with spaces that never shrink; a heading not
    assert_eq!(
        f.typst_eval("import \"/lib/typst/xdoc.typ\": justified; justified((justify: true))")
            .unwrap()
            .replace([' ', '\n'], ""),
        r#"{"justify":true,"justification-limits":{"spacing":{"min":"100%","max":"100000%"},"tracking":{"min":"0pt","max":"0pt"}}}"#
    );
    // LaTeX: the template's hook (fil stretch in the body only), the body flagged, a heading ragged in its group
    let tpl = std::fs::read_to_string(f.dir.join("latex/template.tex")).unwrap();
    assert!(
        tpl.contains("\\ifxd@just\\spaceskip=\\fontdimen2\\font plus 1fil"),
        "{tpl}"
    );
    assert!(
        tpl.contains("\\parfillskip=0pt plus 1fill\n")
            && tpl.contains("\\rightskip=0pt\\relax\\parfillskip=0pt plus 1fill")
    );
    let tex = f.latex().unwrap();
    let on = tex.find("\\xd@justtrue\\selectfont").unwrap();
    let head = tex.find("A heading").unwrap();
    assert!(
        on < head && tex[..head].rfind("\\xd@justfalse\\spaceskip=0pt") > Some(on),
        "{tex}"
    );
    assert!(
        !tex.contains("plus 1fil\\parindent=0pt"),
        "a ragged quotation: {tex}"
    );
    // Word: Body Text (the recipe) and the quotation and note styles justified
    let refx = std::fs::read_to_string(f.dir.join("docx/reference.xml")).unwrap();
    assert!(refx.contains(" justify=\"true\">"));
    for id in ["XdQuoteOnly", "FootnoteText", "XdTail", "XdList1"] {
        let at = refx.find(&format!("w:styleId=\"{id}\"")).unwrap();
        let end = at + refx[at..].find("</w:style>").unwrap();
        assert!(refx[at..end].contains("<w:jc w:val=\"both\"/>"), "{id}");
    }
    // ragged by default: none of it
    let l: serde_yaml::Value = serde_yaml::from_str(&layout("")).unwrap();
    let files = gen::generate(&l, "Times New Roman").unwrap();
    assert!(files
        .iter()
        .all(|(_, t)| !t.contains("xdjustify") && !t.contains("w:val=\"both\"")));
}

#[test]
fn emphasis_inside_italic_text_is_upright() {
    // typst's emph toggles italics; LaTeX (\xd@em) and Word toggle alike
    let l = layout("heading:\n  - {italic: true}\n");
    let Some(f) = fx(
        "emph-toggle",
        &l,
        "---\nx: 1\n---\n# The *Smith* rule\n\nBody *word*.\n",
        &["pandoc"],
    ) else {
        return;
    };
    let tex = f.latex().unwrap();
    assert!(
        tex.contains("{\\xd@em Smith}") && tex.contains("{\\xd@em word}"),
        "{tex}"
    );
    // Word: the heading's runs italic, the emphasized one not
    let doc = f.docx().unwrap();
    let at = doc.find(">Smith<").unwrap();
    let run = &doc[doc[..at].rfind("<w:r>").unwrap()..at];
    assert!(!run.contains("<w:i/>"), "{run}");
    let the = doc.find(">The<").unwrap();
    assert!(doc[doc[..the].rfind("<w:r>").unwrap()..the].contains("<w:i/>"));
}

#[test]
fn characters_pdflatex_lacks_are_set_at_the_typst_advance() {
    let Some(f) = fx(
        "specials",
        &layout(""),
        "---\nx: 1\n---\nHawai\u{2bb}i, 5 \u{2212} 3 \u{2192} x.\n",
        &["pandoc"],
    ) else {
        return;
    };
    // Times New Roman: each character a Type 1 glyph of newtx in a box of Liberation Serif's advance per shape
    let tex = f.latex().unwrap();
    assert!(
        tex.contains("Hawai\\xd@glyph{02BB}{\\textquoteleft}{0.333}{0.333}{0.333}{0.333}i"),
        "{tex}"
    );
    assert!(
        tex.contains("\\xd@glyph{2212}{$-$}{0.564}{0.5698}{0.6748}{0.606}"),
        "{tex}"
    );
    assert!(
        tex.contains("\\xd@glyph{2192}{$\\rightarrow$}{1}{1}{1}{1}"),
        "{tex}"
    );
    // another face: no Times advances (the characters as they are)
    let Some(g) = fx_face(
        "specials-schola",
        &layout(""),
        "---\nx: 1\n---\nHawai\u{2bb}i.\n",
        &["pandoc"],
        "TeX Gyre Schola",
    ) else {
        return;
    };
    assert!(!g.latex().unwrap().contains("xd@glyph"));
}

#[test]
fn links_as_their_text_when_the_court_bars_hyperlinks() {
    let sample = "---\nx: 1\n---\nSee [the Court](https://x.org/a) here.[^1]\n\n[^1]: And [this](http://y.org/b).\n";
    let Some(f) = fx(
        "unlink",
        &layout("links: false\n"),
        sample,
        &["typst", "pandoc", "pdftotext"],
    ) else {
        return;
    };
    // typst: the text, no link annotation in the PDF
    assert!(f.typst_pages().unwrap()[0].contains("See the Court here."));
    let pdf = std::fs::read(f.dir.join("out.pdf")).unwrap();
    assert!(!String::from_utf8_lossy(&pdf).contains("/URI"));
    // LaTeX and Word: no link left
    let tex = f.latex().unwrap();
    assert!(
        !tex.contains("\\href") && tex.contains("See the Court here."),
        "{tex}"
    );
    assert!(!f.docx().unwrap().contains("Link"));
    // links stay by default
    let Some(g) = fx(
        "unlink-default",
        &layout(""),
        sample,
        &["typst", "pandoc", "pdftotext"],
    ) else {
        return;
    };
    g.typst_pages().unwrap();
    let pdf = std::fs::read(g.dir.join("out.pdf")).unwrap();
    assert!(String::from_utf8_lossy(&pdf).contains("/URI"));
    assert!(g.latex().unwrap().contains("\\href"));
    assert!(g.docx().unwrap().contains("Link"));
}

#[test]
fn a_heading_is_kept_whole_and_with_a_list_after_it() {
    let Some(f) = fx(
        "heading-keep",
        &layout("heading:\n  - {bold: true}\n"),
        "---\nx: 1\n---\n# A heading\n\n- one\n- two\n\nText.\n\n- three\n",
        &["typst", "pandoc"],
    ) else {
        return;
    };
    // LaTeX: the heading's lines never split, the list after it not split from it; a list after text as before
    let tex = f.latex().unwrap();
    let h = tex.find("A heading").unwrap();
    assert!(
        tex[..h].rfind("\\interlinepenalty=10000").is_some(),
        "{tex}"
    );
    assert_eq!(tex.matches("\\@beginparpenalty=10000").count(), 1, "{tex}");
    assert!(tex.find("\\@beginparpenalty=10000") < tex.find("one"));
    // typst: a kept block is not breakable
    let src = std::fs::read_to_string(f.root.join("lib/typst/xdoc.typ")).unwrap();
    assert!(src.contains("breakable: not st.at(\"keep\", default: false)"));
}

#[test]
fn a_markdown_value_is_paragraphs_in_every_engine() {
    let l =
        layout("closing:\n  - {markdown: \"{certificate}\", indent: 36, gap: 12, pitch: body}\n");
    let Some(f) = fx(
        "markdown-value",
        &l,
        "---\ncertificate: |\n  I certify *one*\n  thing.\n\n  And a second.\n\n\n  1. A third, as written.\n---\nBody.\n",
        &["typst", "pandoc", "pdftotext"],
    ) else {
        return;
    };
    // typst and Lua split alike
    let t = f
        .typst_eval("import \"/lib/typst/xdoc.typ\": md-paragraphs; md-paragraphs((\"a\\nb\\n\\n c \\n\\n\\n\\nd\",))")
        .unwrap();
    let l = lua("local xd = require(\"pandoc.xdoc\")\nprint(pandoc.json.encode(xd.md_paragraphs({ \"a\\nb\\n\\n c \\n\\n\\n\\nd\" })))");
    assert_eq!(t.replace([' ', '\n'], ""), l.replace(' ', ""));
    assert_eq!(l, r#"["a b","c","d"]"#);
    // three paragraphs: typst sets them apart, LaTeX three groups, Word three paragraphs
    let page = &f.typst_pages().unwrap()[0];
    assert!(
        page.contains("I certify one thing.")
            && page.contains("And a second.")
            && page.contains("1. A third, as written."),
        "{page}"
    );
    let tex = f.latex().unwrap();
    assert!(
        tex.contains("thing.\\par") || tex.contains("thing.\n\\par"),
        "{tex}"
    );
    assert_eq!(tex.matches("\\addvspace{12bp}").count(), 2, "{tex}");
    let doc = f.docx().unwrap();
    assert_eq!(doc.matches(r#"w:before=\"240\""#).count(), 2, "{doc}");
}

#[test]
fn a_coloured_cover_in_every_engine() {
    let l = layout("page_number: {align: center, from: 1, front: lower-roman}\ncover:\n  - {text: \"COURT\", align: center}\ncover_fill: \"#f5deb3\"\n");
    let Some(f) = fx(
        "cover-fill",
        &l,
        "---\nx: 1\n---\nBody.\n",
        &["typst", "pandoc"],
    ) else {
        return;
    };
    // typst: a page background (the pages before the tables)
    assert!(f
        .typst_eval("import \"/lib/typst/xdoc.typ\": cover-fill; \"background\" in cover-fill((cover_fill: \"#f5deb3\"))")
        .unwrap()
        .contains("true"));
    // LaTeX: the cover's pages coloured, none after; xcolor only for a coloured cover
    let tex = f.latex().unwrap();
    let (on, off) = (
        tex.find("\\pagecolor[HTML]{F5DEB3}").unwrap(),
        tex.find("\\nopagecolor").unwrap(),
    );
    assert!(
        on < tex.find("COURT").unwrap() && tex.find("COURT").unwrap() < off,
        "{tex}"
    );
    let tpl = std::fs::read_to_string(f.dir.join("latex/template.tex")).unwrap();
    assert!(tpl.contains("\\usepackage{xcolor}"));
    // Word: one page-sized rectangle behind the cover's first paragraph
    let doc = f.docx().unwrap();
    assert_eq!(
        doc.matches("srgbClr val=\\\"F5DEB3\\\"").count(),
        1,
        "{doc}"
    );
    assert!(
        doc.contains("behindDoc=\\\"1\\\"")
            && doc.contains("cx=\\\"7772400\\\" cy=\\\"10058400\\\"")
    );
    // none without one
    let l: serde_yaml::Value = serde_yaml::from_str(&layout("")).unwrap();
    assert!(gen::generate(&l, "Times New Roman")
        .unwrap()
        .iter()
        .all(|(_, t)| !t.contains("xcolor")));
}

#[test]
fn a_list_inside_a_quotation_in_every_engine() {
    let l = layout("quote: {left: 72, right: 72, above: 12, below: 12, gap: 12, pitch: single}\n");
    let Some(f) = fx(
        "quote-list",
        &l,
        "---\nx: 1\n---\n> A rule:\n>\n> 1. one;\n> 2. two.\n\nAfter.\n",
        &["pandoc"],
    ) else {
        return;
    };
    // LaTeX: the list in the quotation's group, its first level's margins the quotation's indents
    let tex = f.latex().unwrap();
    let at = tex
        .find("\\setlist[1]{leftmargin=108bp,rightmargin=72bp}")
        .unwrap();
    assert!(
        at < tex.find("one;").unwrap() && tex[at..].find("\\endgroup").is_some(),
        "{tex}"
    );
    // Word: the items in the quotation's list style, the space below the quotation pending after its list
    let doc = f.docx().unwrap();
    assert!(doc.contains("XdQuoteList1"), "{doc}");
    let refx = std::fs::read_to_string(f.dir.join("docx/reference.xml")).unwrap();
    assert!(
        refx.contains(r#"w:styleId="XdQuoteList1""#)
            && refx.contains(r#"<w:ind w:left="2160" w:right="1440" w:hanging="720"/>"#)
    );
}

#[test]
fn an_authorities_group_in_capitals_in_every_engine() {
    let l =
        layout("authorities: {title: Authorities, col: 56, group: {bold: true, upper: true}}\n");
    let Some(f) = fx(
        "toa-upper",
        &l,
        "---\nauthorities:\n  - heading: Cases\n    entries:\n      - {cite: \"Doe v. Roe\", find: \"Doe\"}\n---\nDoe v. Roe holds.\n",
        &["pandoc"],
    ) else {
        return;
    };
    assert!(f.latex().unwrap().contains("CASES"));
    assert!(f.docx().unwrap().contains(">CASES<"));
}

#[test]
fn page_x_of_n_in_every_engine() {
    let l = layout("page_number: {align: center, from: 1, text: \"Page {page} of {pages}\"}\n");
    let Some(f) = fx(
        "page-of",
        &l,
        "---\nx: 1\n---\nBody.\n",
        &["typst", "pandoc", "pdftotext"],
    ) else {
        return;
    };
    assert!(f.typst_pages().unwrap()[0].contains("Page 1 of 1"));
    let tpl = std::fs::read_to_string(f.dir.join("latex/template.tex")).unwrap();
    assert!(
        tpl.contains("\\hfil{}Page \\thepage{} of \\pageref*{xd@lastpage}\\hfil"),
        "{tpl}"
    );
    assert!(f.latex().unwrap().contains("\\label{xd@lastpage}"));
    let refx = std::fs::read_to_string(f.dir.join("docx/reference.xml")).unwrap();
    assert!(
        refx.contains(r#"<w:t xml:space="preserve">Page </w:t>"#) && refx.contains(" NUMPAGES "),
        "{refx}"
    );
    assert_eq!(
        super::word::page_text_runs("p {page}/{pages} {x}", "SECTIONPAGES")
            .matches("fldCharType=\"begin\"")
            .count(),
        2
    );
}

#[test]
fn the_space_between_body_paragraphs_in_every_engine() {
    let l = layout("paragraph_gap: 7.8\nheading:\n  - {bold: true, above: 12, below: 12}\n");
    let Some(f) = fx(
        "paragraph-gap",
        &l,
        "---\nx: 1\n---\n# Heading\n\nOne.\n\nTwo.\n\n- item\n\nThree.\n",
        &["pandoc"],
    ) else {
        return;
    };
    // LaTeX: the gap between One and Two, Two and the list, the list and Three; not after the heading
    let tex = f.latex().unwrap();
    assert_eq!(tex.matches("\\addvspace{7.8bp}").count(), 3, "{tex}");
    assert!(tex.find("\\addvspace{7.8bp}") > tex.find("One."));
    // Word: the Gap styles after a paragraph or list, the plain ones after the heading
    let doc = f.docx().unwrap();
    assert_eq!(doc.matches("Body Text Gap").count(), 2, "{doc}");
    assert_eq!(doc.matches("XdList1Gap").count(), 1, "{doc}");
    let refx = std::fs::read_to_string(f.dir.join("docx/reference.xml")).unwrap();
    assert!(refx.contains(r#"w:styleId="BodyTextGap""#) && refx.contains(r#"w:before="156""#));
}

#[test]
fn a_newline_in_a_value_starts_a_line_in_every_engine() {
    let l = layout("front:\n  - {text: \"{title}\", align: center}\n  - {break: true}\n");
    let Some(f) = fx(
        "value-newline",
        &l,
        "---\ntitle: |\n  BRIEF OF APPELLEE\n  ON APPEAL\n---\nBody.\n",
        &["typst", "pandoc", "pdftotext"],
    ) else {
        return;
    };
    // typst: two lines; Lua: two paragraphs, as "<br>" gives (the block scalar's last newline dropped)
    let page = &f.typst_pages().unwrap()[0];
    let lines: Vec<&str> = page
        .lines()
        .map(str::trim)
        .filter(|l| !l.is_empty())
        .collect();
    assert_eq!(&lines[..2], ["BRIEF OF APPELLEE", "ON APPEAL"], "{page}");
    let l = lua("local xd = require(\"pandoc.xdoc\")\nprint(pandoc.json.encode(xd.expand(\"{t}\", { t = \"A\\nB\\n\" }, false)), pandoc.json.encode(xd.expand(\"{t}\", { t = \"A\\n\\nB\" }, false, true)))");
    assert_eq!(l, "[\"A\",\"B\"]\t[\"A\\n\\nB\"]");
    assert!(f.latex().unwrap().contains("ON APPEAL"));
}

#[test]
fn a_heading_needle_reads_the_list_numbers_after_it() {
    let l = layout("contents: {title: Contents, depth: 1, col: 36}\nheading:\n  - {bold: true}\n");
    let Some(f) = fx(
        "needle-list",
        &l,
        "---\nx: 1\n---\n# Issues\n\n3. Whether the court erred.\n4. Whether it did not.\n",
        &["pandoc"],
    ) else {
        return;
    };
    f.docx().unwrap();
    let needles = f.written("needles.tsv").unwrap();
    let h = needles.lines().find(|l| l.starts_with("h1\t")).unwrap();
    assert!(h.contains("issues3whetherthecourterred"), "{needles}");
}

#[test]
fn a_find_ends_where_its_word_ends() {
    let l = layout("authorities: {title: Authorities, col: 56}\n");
    let Some(f) = fx(
        "find-word",
        &l,
        "---\nauthorities:\n  - heading: Constitution\n    entries:\n      - {cite: \"Art. V\", find: \"Art. V\"}\n---\nArt. V applies. Art. VII does not. See Art. V, again.\n",
        &["pandoc"],
    ) else {
        return;
    };
    // two marks (not three: "Art. VII" holds no "Art. V" word)
    assert_eq!(f.latex().unwrap().matches("\\xd@amark{1}").count(), 2);
    f.docx().unwrap();
    let needles = f.written("needles.tsv").unwrap();
    assert_eq!(
        needles.lines().filter(|l| l.starts_with("a1.")).count(),
        2,
        "{needles}"
    );
}

#[test]
fn a_mark_at_a_paragraph_s_end_stays_on_its_word_s_page() {
    // the paragraph that ends with the find ends page 1 (23 lines of 27.6 pt on 648 pt): the table lists page 1 only
    let l = layout("page_number: {align: center, from: 1, front: lower-roman}\nauthorities: {title: Authorities, col: 56}\n");
    let mut sample = String::from("---\nauthorities:\n  - heading: Cases\n    entries:\n      - {cite: \"Doe v. Roe\", find: \"Doe\"}\n---\n");
    for i in 1..=22 {
        sample.push_str(&format!("Line {i}.\n\n"));
    }
    sample.push_str("See Doe\n\nAnd a line on page 2.\n");
    let Some(f) = fx("mark-end", &l, &sample, &["typst", "pdftotext"]) else {
        return;
    };
    let pages = f.typst_pages().unwrap();
    let toa = pages.iter().find(|p| p.contains("Authorities")).unwrap();
    let row = toa.lines().find(|l| l.contains("Doe v. Roe")).unwrap();
    assert!(row.trim_end().ends_with(" 1"), "{row}");
    assert!(
        pages
            .iter()
            .any(|p| p.contains("See Doe") && !p.contains("page 2")),
        "{pages:?}"
    );
}

#[test]
fn the_checks_a_court_asks_stop_the_render_in_every_engine() {
    let l =
        layout("checks: {footnotes: false, sections: [\"Preliminary Statement\", \"Argument\"]}\n");
    let ok =
        "---\nx: 1\n---\n# PRELIMINARY STATEMENT\n\nA.\n\n# Questions\n\nB.\n\n# Argument\n\nC.\n";
    let Some(f) = fx("checks-ok", &l, ok, &["typst", "pandoc", "pdftotext"]) else {
        return;
    };
    assert!(f.typst_pages().is_ok() && f.latex().is_ok() && f.docx().is_ok());
    let order = "---\nx: 1\n---\n# Argument\n\nC.\n\n# Preliminary Statement\n\nA.\n";
    let note =
        "---\nx: 1\n---\n# Preliminary Statement\n\nA.[^1]\n\n# Argument\n\nC.\n\n[^1]: No.\n";
    for (name, sample, why) in [
        ("checks-order", order, "out of order"),
        ("checks-note", note, "no footnote"),
    ] {
        let f = fx(name, &l, sample, &["typst", "pandoc", "pdftotext"]).unwrap();
        assert!(f.typst_pages().unwrap_err().contains(why), "{name}");
        assert!(f.latex().unwrap_err().contains(why), "{name}");
        assert!(f.docx().unwrap_err().contains(why), "{name}");
    }
}

#[test]
fn a_value_of_underscores_is_its_characters() {
    let l =
        layout("front:\n  - {text: \"{line}\"}\n  - {text: \"By {name}\"}\n  - {break: true}\n");
    let Some(f) = fx(
        "underscores",
        &l,
        "---\nline: \"__________________\"\nname: \"* * *\"\n---\nBody.\n",
        &["typst", "pandoc", "pdftotext"],
    ) else {
        return;
    };
    assert!(f.typst_pages().unwrap()[0].contains("__________________"));
    assert!(f.latex().unwrap().contains("\\_\\_\\_"));
    let l = lua("local xd = require(\"pandoc.xdoc\")\nprint(pandoc.utils.stringify(xd.inlines(\"___\")), pandoc.utils.stringify(xd.inlines(\"- - -\")))");
    assert_eq!(l, "___\t- - -");
}

#[test]
fn a_hard_line_break_stays_inside_its_paragraph_in_latex() {
    let Some(f) = fx(
        "hard-break",
        &layout(""),
        "---\nx: 1\n---\nFirst\\\nsecond.\n",
        &["pandoc"],
    ) else {
        return;
    };
    // not \\ (under \raggedright it ends the paragraph: the next line indented)
    assert!(f.latex().unwrap().contains("First\\hfill\\break{}second."));
}

#[test]
fn tex_gyre_bonum_in_latex_and_word() {
    let l: serde_yaml::Value = serde_yaml::from_str(&layout("")).unwrap();
    let files = gen::generate(&l, "TeX Gyre Bonum").unwrap();
    let get = |n: &str| files.iter().find(|(p, _)| p == n).unwrap().1.clone();
    // tgbonum (the vendored Bonum's advances), the ellipsis three periods of 0.32 em kerned to 1 em
    let tpl = get("latex/template.tex");
    assert!(tpl.contains("\\usepackage{tgbonum}"), "{tpl}");
    assert!(tpl.contains(".\\kern0.02em.\\kern0.02em."), "{tpl}");
    // Word measures a page list with Bonum's advances
    assert!(get("docx/xdoc.lua").contains(r#"["digit"] = 0.62"#));
    assert_eq!(gen::latex_bias("TeX Gyre Bonum"), 0.0);
}

#[test]
fn eb_garamond_in_latex_and_word() {
    let l: serde_yaml::Value = serde_yaml::from_str(&layout("")).unwrap();
    let files = gen::generate(&l, "EB Garamond").unwrap();
    let get = |n: &str| files.iter().find(|(p, _)| p == n).unwrap().1.clone();
    // lining tabular figures, the ellipsis at the vendored advance in each shape, the regular T in a box
    let tpl = get("latex/template.tex");
    assert!(
        tpl.contains("\\usepackage[lining,tabular]{ebgaramond}"),
        "{tpl}"
    );
    assert!(tpl.contains("\\xd@glyph{2026}{.\\hfil.\\hfil.}{0.686}{0.746}{0.671}{0.764}"));
    let lua = get("latex/xdoc.lua");
    assert!(
        lua.contains("latex_specials") && lua.contains("\"0054\""),
        "{lua}"
    );
    assert!(get("docx/xdoc.lua").contains(r#"["digit"] = 0.48"#));
}

#[test]
fn a_cover_that_opens_with_columns_starts_the_numbering_at_its_text() {
    let l = layout("cover:\n  - columns:\n      - {width: 200, blocks: [{text: \"STATE OF TESTS\"}]}\n      - {blocks: [{text: \"No. 1\"}]}\ncontents: {title: Contents, depth: 1, col: 36}\nheading:\n  - {bold: true}\n");
    let Some(f) = fx(
        "cover-cols",
        &l,
        "---\nx: 1\n---\n# Argument\n\nBody.\n",
        &["pandoc"],
    ) else {
        return;
    };
    f.docx().unwrap();
    let needles = f.written("needles.tsv").unwrap();
    assert!(
        needles
            .lines()
            .any(|l| l.starts_with("start\tB\tstateoftests")),
        "{needles}"
    );
}

#[test]
fn a_table_of_contents_a_field_switches() {
    let l = layout(
        "contents: {title: Contents, depth: 1, col: 36, when: toc}\nheading:\n  - {bold: true}\n",
    );
    for (name, toc, want) in [("toc-off", "false", false), ("toc-on", "true", true)] {
        let sample = format!("---\ntoc: {toc}\n---\n# Argument\n\nBody.\n");
        let Some(f) = fx(name, &l, &sample, &["typst", "pandoc", "pdftotext"]) else {
            return;
        };
        let pages = f.typst_pages().unwrap();
        assert_eq!(
            pages.iter().any(|p| p.contains("Contents")),
            want,
            "{name} {pages:?}"
        );
        assert_eq!(f.latex().unwrap().contains("Contents"), want, "{name}");
        assert_eq!(f.docx().unwrap().contains(">Contents<"), want, "{name}");
    }
}

#[test]
fn an_authority_cited_two_ways() {
    let l = layout("authorities: {title: Authorities, col: 56}\n");
    let Some(f) = fx(
        "finds",
        &l,
        "---\nauthorities:\n  - heading: Constitution\n    entries:\n      - {cite: \"Wash. Const. art. I, § 3\", finds: [\"art. I, § 3\", \"art. I, §§ 3\"]}\n---\nUnder art. I, § 3 and art. I, §§ 3-4.\n",
        &["typst", "pandoc", "pdftotext"],
    ) else {
        return;
    };
    assert_eq!(f.latex().unwrap().matches("\\xd@amark{1}").count(), 2);
    f.docx().unwrap();
    assert_eq!(
        f.written("needles.tsv")
            .unwrap()
            .lines()
            .filter(|l| l.starts_with("a1."))
            .count(),
        2
    );
    assert!(f.typst_pages().is_ok());
}

#[test]
fn blocks_and_sections_between_the_tables() {
    let l = layout("page_number: {align: center, from: 1, front: lower-roman}\ncontents: {title: Contents, depth: 1, col: 36}\nbetween_tables:\n  - {text: \"Statement of Compliance\", heading: 1}\n  - {text: \"It complies.\"}\nbody_before_tables: {until: Argument, place: between}\nauthorities: {title: Authorities, col: 56}\nheading:\n  - {bold: true}\n");
    let sample = "---\nauthorities:\n  - heading: Cases\n    entries:\n      - {cite: \"Doe v. Roe\", find: \"Doe\"}\n---\n# Points on Appeal\n\nDoe.\n\n# Argument\n\nBody.\n";
    let Some(f) = fx(
        "between-tables",
        &l,
        sample,
        &["typst", "pandoc", "pdftotext"],
    ) else {
        return;
    };
    // typst: contents, the statement, the points, the authorities, the argument, each on its page
    let pages = f.typst_pages().unwrap();
    let order = ["It complies.", "Doe.", "Authorities", "Body."]
        .map(|s| pages.iter().position(|p| p.contains(s)).unwrap());
    assert!(order.windows(2).all(|w| w[0] < w[1]), "{order:?} {pages:?}");
    // LaTeX and Word in the same order
    let tex = f.latex().unwrap();
    let t = [
        "bfseries Contents",
        "It complies.",
        "Doe.",
        "bfseries Authorities",
        "Body.",
    ]
    .map(|s| tex.find(s).unwrap_or(usize::MAX));
    assert!(t.windows(2).all(|w| w[0] < w[1]), "{t:?}");
    let doc = f.docx().unwrap();
    let d = [
        ">Contents<",
        ">complies.<",
        "Str \"Doe.\"",
        ">Authorities<",
        "Str \"Body.\"",
    ]
    .map(|s| doc.find(s).unwrap_or(usize::MAX));
    assert!(d.windows(2).all(|w| w[0] < w[1]), "{d:?}");
}

#[test]
fn a_group_or_row_inside_a_column_takes_the_column_s_width() {
    let l = layout("front:\n  - columns:\n      - {width: 200, blocks: [{group: [{text: \"In a group.\"}]}]}\n      - {blocks: [{columns: [{blocks: [{text: \"L\"}]}, {blocks: [{text: \"R\"}]}], gutter: 12}]}\n    gutter: 24\n  - {break: true}\n");
    let Some(f) = fx("cell-width", &l, "---\nx: 1\n---\nBody.\n", &["pandoc"]) else {
        return;
    };
    // LaTeX: the group and the nested row at the container's \hsize, not the text's width
    let tex = f.latex().unwrap();
    assert!(tex.contains("\\vtop{\\hsize=\\hsize"), "{tex}");
    assert!(tex.contains("\\dimexpr(\\hsize-12bp)/2\\relax"), "{tex}");
    // Word: the group a table of the column's 200 pt (4000 twips)
    let doc = f.docx().unwrap();
    assert!(
        doc.contains(r#"<w:tblW w:w=\"4000\" w:type=\"dxa\"/>"#),
        "{doc}"
    );
}

#[test]
fn the_contents_on_the_cover_s_page() {
    let l = layout("cover:\n  - {text: \"COMPLAINT\", align: center}\ncontents: {title: Contents, depth: 1, col: 36, break: false}\nheading:\n  - {bold: true, above: 27.6}\n");
    let Some(f) = fx(
        "contents-cover",
        &l,
        "---\nx: 1\n---\n# Parties\n\nThe parties.\n",
        &["typst", "pandoc", "pdftotext"],
    ) else {
        return;
    };
    let pages = f.typst_pages().unwrap();
    assert!(
        pages[0].contains("COMPLAINT") && pages[0].contains("Contents"),
        "{pages:?}"
    );
    let tex = f.latex().unwrap();
    let (c, t) = (
        tex.find("COMPLAINT").unwrap(),
        tex.find("bfseries Contents").unwrap(),
    );
    assert!(!tex[c..t].contains("\\clearpage"), "{tex}");
    let doc = f.docx().unwrap();
    let (c, t) = (
        doc.find(">COMPLAINT<").unwrap(),
        doc.find(">Contents<").unwrap(),
    );
    assert!(!doc[c..t].contains("pageBreakBefore"), "{doc}");
    // numbered apart from the cover, the tables need a page of their own
    let l = layout("page_number: {align: center, front: lower-roman}\ncover:\n  - {text: \"X\"}\ncontents: {title: Contents, break: false}\n");
    let g = fx(
        "contents-cover-front",
        &l,
        "---\nx: 1\n---\n# A\n\nB.\n",
        &["typst", "pdftotext"],
    )
    .unwrap();
    assert!(g
        .typst_pages()
        .unwrap_err()
        .contains("contents.break: false"));
}

#[test]
fn a_cover_counted_in_the_tables_numbering() {
    for (mode, cover_label) in [("counted", false), ("numbered", true)] {
        let l = layout(&format!("page_number: {{align: center, from: 1, front: lower-roman, cover: {mode}}}\ncover:\n  - {{text: COVER, align: center}}\ncontents: {{title: Contents, depth: 1, col: 36}}\nheading:\n  - {{bold: true}}\n"));
        let Some(f) = fx(
            &format!("cover-{mode}"),
            &l,
            "---\nx: 1\n---\n# Argument\n\nBody.\n",
            &["typst", "pandoc", "pdftotext"],
        ) else {
            return;
        };
        let pages = f.typst_pages().unwrap();
        assert_eq!(
            pages[0].trim_end().ends_with('i'),
            cover_label,
            "{mode} {pages:?}"
        );
        assert!(pages[1].trim_end().ends_with("ii"), "{mode} {pages:?}");
        // LaTeX: roman from the cover, not again at the tables
        let tex = f.latex().unwrap();
        assert_eq!(tex.matches("\\pagenumbering{roman}").count(), 1, "{tex}");
        assert!(tex.find("\\pagenumbering{roman}") < tex.find("COVER"));
        // Word: the cover's section starts the roman numbering, the tables' goes on; the lookup's section at the cover
        let doc = f.docx().unwrap();
        assert!(
            doc.contains(r#"w:fmt=\"lowerRoman\" w:start=\"1\""#)
                && doc.contains(r#"w:fmt=\"lowerRoman\"/>"#),
            "{doc}"
        );
        assert!(f
            .written("needles.tsv")
            .unwrap()
            .contains("#section\tstart\tlower-roman"));
    }
}

#[test]
fn a_quotation_inside_italics_in_a_heading_keeps_its_curly_quotes() {
    let l = layout("heading:\n  - {bold: true}\n");
    let Some(f) = fx(
        "heading-quote",
        &l,
        "---\nx: 1\n---\n# The *\"Smith\" rule*\n\nBody.\n",
        &["pandoc"],
    ) else {
        return;
    };
    let tex = f.latex().unwrap();
    assert!(
        tex.contains("{\\xd@em \\textquotedblleft{}Smith\\textquotedblright{}"),
        "{tex}"
    );
    assert!(!tex.contains("Smith''"));
}

#[test]
fn an_absent_optional_block_adds_no_space() {
    // the first line where it is without the optional block (typst set the missing block's space above)
    let with = layout("front:\n  - {text: \"{missing}\", optional: true, above: 50}\n  - {text: \"Next line.\", above: 10}\n  - {break: true}\n");
    let without = layout("front:\n  - {text: \"Next line.\", above: 10}\n  - {break: true}\n");
    let mut ys = vec![];
    for (name, l) in [("optional-absent", with), ("optional-none", without)] {
        let Some(f) = fx(name, &l, "---\nx: 1\n---\nBody.\n", &["typst", "pdftotext"]) else {
            return;
        };
        ys.push(y_of(&f.typst_lines().unwrap()[0], "nextline"));
    }
    assert!((ys[0] - ys[1]).abs() < 0.01, "{ys:?}");
}

#[test]
fn a_heading_right_after_a_paragraph_line_is_a_heading_in_every_engine() {
    // CommonMark (typst) reads it as a heading; pandoc's markdown wanted a blank line before it (MODEL_FROM)
    let l = layout("heading:\n  - {bold: true}\n");
    let Some(f) = fx(
        "heading-no-blank",
        &l,
        "---\nx: 1\n---\nA paragraph line.\n# Certificate of Service\n\nServed.\n",
        &["pandoc"],
    ) else {
        return;
    };
    assert!(f.latex().unwrap().contains("\\xd@hmark{1}"));
}

#[test]
fn the_token_after_a_section_sign_is_never_broken() {
    let Some(f) = fx(
        "sign-token",
        &layout(""),
        "---\nx: 1\n---\nUnder § 807-1-A4(2)(b) and ¶¶ 37-39 here.\n",
        &["pandoc"],
    ) else {
        return;
    };
    // LaTeX: the token in an \mbox (typst boxes "[§¶] \S+"); Word: a word joiner after each hyphen of it
    let tex = f.latex().unwrap();
    assert!(tex.contains("§~\\mbox{807\\mbox{-}1-A4(2)(b)}"), "{tex}");
    assert!(tex.contains("¶¶~\\mbox{37\\mbox{-}39}"), "{tex}");
    let doc = f.docx().unwrap();
    assert!(doc.contains(r#"Str "807-\8288\&1-\8288A4"#), "{doc}");
}

// ---------------------------------------------------------------------------------------------------------------
// fb-595.54.82 serial lane 2: the features ported from the Wisconsin fan-out (fb-595.54.16)

#[test]
fn between_blocks_read_the_item_before_and_the_next_one() {
    // "v." only before an item whose `versus` is set (`next.versus`); a field of the item before decides a `when`
    let l = layout("cover:\n  - each: caption\n    between:\n      - {when: next.versus, blocks: [{text: \"v.\", align: center}]}\n      - {when: and, blocks: [{text: \"and\"}]}\n    blocks:\n      - {text: \"{name}\"}\n  - {break: true}\n");
    let Some(f) = fx(
        "between-next",
        &l,
        "---\ncaption:\n  - {name: ALPHA, and: true}\n  - {name: BETA}\n  - {name: GAMMA, versus: true}\n---\nThe body.\n",
        &["typst", "pandoc", "pdftotext"],
    ) else {
        return;
    };
    let words = |s: &str| s.split_whitespace().collect::<Vec<_>>().join(" ");
    let text = words(&f.typst_pages().unwrap()[0]);
    assert!(text.contains("ALPHA and BETA v. GAMMA"), "{text}");
    let tex = f.latex().unwrap();
    let (a, n, b, v, g) = (
        tex.find("ALPHA").unwrap(),
        tex.find("and").unwrap(),
        tex.find("BETA").unwrap(),
        tex.find("v.").unwrap(),
        tex.find("GAMMA").unwrap(),
    );
    assert!(a < n && n < b && b < v && v < g, "{tex}");
    assert_eq!(tex.matches("v.").count(), 1);
    let doc = f.docx().unwrap();
    assert_eq!(doc.matches(">v.<").count(), 1, "{doc}");
}

#[test]
fn a_word_count_of_listed_sections_a_stated_count_and_a_frontmatter_limit() {
    // `sections`: the Statement and the Argument (any case), 14 + 5 words and the one note the Statement calls (3)
    let l = layout("words: {sections: [statement of the case, argument]}\ntail: {at: Certificate}\nclosing:\n  - {text: \"This brief has {xd.words} words.\"}\n");
    let Some(f) = fx(
        "words-sections",
        &l,
        WORDS_SAMPLE,
        &["typst", "pandoc", "pdftotext"],
    ) else {
        return;
    };
    let text = f.typst_pages().unwrap().join("");
    assert!(text.contains("This brief has 22 words."), "{text}");
    assert!(f.latex().unwrap().contains("This brief has 22 words."));
    // `given`: the frontmatter states the count; `limit_field`: the frontmatter's limit, over the layout's
    let sample = WORDS_SAMPLE.replace("x: 1", "x: 1\ncertified: 4271\nword_limit: 21");
    let l = layout("words: {sections: [argument], given: certified, limit: 9000, limit_field: word_limit}\nclosing:\n  - {text: \"This brief has {xd.words} words.\"}\n");
    let f = fx(
        "words-given",
        &l,
        &sample,
        &["typst", "pandoc", "pdftotext"],
    )
    .unwrap();
    assert!(f
        .typst_pages()
        .unwrap_err()
        .contains("4271 words, over the limit of 21"));
    assert!(f
        .latex()
        .unwrap_err()
        .contains("4271 words, over the limit of 21"));
    let sample = WORDS_SAMPLE.replace("x: 1", "x: 1\ncertified: 4271");
    let f = fx(
        "words-given-ok",
        &l,
        &sample,
        &["typst", "pandoc", "pdftotext"],
    )
    .unwrap();
    assert!(f
        .typst_pages()
        .unwrap()
        .join("")
        .contains("This brief has 4,271 words."));
    assert!(f.latex().unwrap().contains("This brief has 4,271 words."));
}

#[test]
fn a_contents_switch_takes_its_default_when_the_field_is_missing() {
    let l = layout("contents: {title: Contents, depth: 1, col: 36, when: toc, default: true}\n");
    for (name, front, shown) in [
        ("toc-default-on", "x: 1", true),
        ("toc-default-off", "toc: false", false),
    ] {
        let Some(f) = fx(
            name,
            &l,
            &format!("---\n{front}\n---\n# Argument\n\nThe body.\n"),
            &["typst", "pandoc", "pdftotext"],
        ) else {
            return;
        };
        let text = f.typst_pages().unwrap().join("");
        assert_eq!(text.contains("Contents"), shown, "{name}: {text}");
        assert_eq!(f.latex().unwrap().contains("Contents"), shown, "{name}");
        assert_eq!(f.docx().unwrap().contains(">Contents<"), shown, "{name}");
    }
}

#[test]
fn a_listed_authority_on_passim_pages_or_more_is_passim() {
    let l = layout("authorities:\n  title: Authorities\n  col: 56\n  passim: 2\n");
    let body = "Smith v. Jones held it.\n\n".repeat(60);
    let Some(f) = fx(
        "passim-list",
        &l,
        &format!("---\nauthorities:\n  - heading: Cases\n    entries:\n      - {{cite: \"Smith v. Jones\", find: \"Smith v. Jones\"}}\n---\n{body}"),
        &["typst", "pandoc", "pdftotext"],
    ) else {
        return;
    };
    let pages = f.typst_pages().unwrap();
    assert!(pages.len() > 2 && pages[0].contains("passim"), "{pages:?}");
    assert!(f.latex().unwrap().contains("\\xd@apagesp{1}{2}"));
    // Word: the list from the pages pass, "passim" in italics
    f.docx().unwrap();
    let doc = f.docx_after("a1.1\t2\t1\na1.2\t3\t2\n").unwrap();
    assert!(doc.contains(">passim<"), "{doc}");
}

#[test]
fn a_page_list_wider_than_the_line_wraps_and_leaves_the_citation_its_line() {
    // typst: the page column never takes the citation's own width (fb-595.87: "G.L. c. 239, § 8A" on 22 pages was
    // set a word a line, its last word printed into the pages, DEF-FORM-004)
    let l = layout("authorities:\n  title: Authorities\n  col: 56\n");
    let pages = (1..=70)
        .map(|n| n.to_string())
        .collect::<Vec<_>>()
        .join(", ");
    let Some(f) = fx(
        "wide-page-list",
        &l,
        &format!("---\nauthorities:\n  - heading: Statutes\n    entries:\n      - {{cite: \"G.L. c. 239, § 8A\", pages: \"{pages}\"}}\n---\n# Argument\n\nThe body.\n"),
        &["typst", "pdftotext"],
    ) else {
        return;
    };
    let pages = f.typst_pages().unwrap();
    let toa: Vec<&str> = pages[0].lines().map(str::trim).collect();
    assert!(
        toa.iter()
            .any(|t| t.starts_with("G.L. c. 239, § 8A") && t.contains(" 1, 2, 3, ")),
        "{toa:?}"
    );
    assert!(
        toa.iter().any(|t| t.trim_end().ends_with("69, 70")),
        "{toa:?}"
    );
}

#[test]
fn the_model_s_inline_rules_in_latex_and_word() {
    let l = layout("");
    let Some(f) = fx(
        "inline-rules",
        &l,
        "---\nx: 1\n---\nRuns a----b and c---d. Signed by /s/ Jane. He said—“go.” See ¶ 63.[^1] At https://a.org/x?p=1&q=2.\n\nAn *emphasised note*[^2] here.\n\n[^1]: The note.\n[^2]: Another.\n",
        &["pandoc"],
    ) else {
        return;
    };
    let tex = f.latex().unwrap().replace('\n', " ");
    // four hyphens are two en dashes (CommonMark), three an em dash
    assert!(
        tex.contains("a\\textendash\\allowbreak{}\\textendash\\allowbreak{}b"),
        "{tex}"
    );
    // no break before a spaced slash; none between an em dash and the quotation mark after it
    assert!(tex.contains("by\\nobreak\\space{}/s/"), "{tex}");
    assert!(
        tex.contains("said\\allowbreak\\textemdash{}\\textquotedblleft{}"),
        "{tex}"
    );
    // the note after "¶ 63." is not held in the sign's \mbox (LaTeX loses a note in a box)
    assert!(tex.contains("\\mbox{63.}\\footnote{"), "{tex}");
    // a URL's query string breaks after "&"
    assert!(
        tex.contains("p=1&\\allowbreak{}q=2") || tex.contains("p=1\\&\\allowbreak{}q=2"),
        "{tex}"
    );
    // a paragraph whose note is inside emphasis has no widow or club penalty
    let at = tex.find("An ").unwrap();
    assert!(
        tex[..at]
            .rfind("\\widowpenalty=0")
            .is_some_and(|w| w > tex[..at].rfind("Jane").unwrap()),
        "{tex}"
    );
    // Word (Times New Roman): a four-per-em space and a word joiner before the slash
    let doc: String = f.docx().unwrap().split_whitespace().collect();
    assert!(doc.contains(r#"Str"by",Str"\8197\8288",Str"/s/"#), "{doc}");
    assert!(doc.contains("a\\8211\\8211b"), "{doc}");
    // a face whose space is not a quarter em: a no-break space
    let f = fx_face(
        "inline-rules-arial",
        &l,
        "---\nx: 1\n---\nSigned by /s/ Jane.\n",
        &["pandoc"],
        "Liberation Sans",
    )
    .unwrap();
    let doc: String = f.docx().unwrap().split_whitespace().collect();
    assert!(doc.contains(r#"Str"by",Str"\160",Str"/s/"#), "{doc}");
}

#[test]
fn an_empty_latex_column_keeps_its_width() {
    let l = layout("closing:\n  - columns:\n      - {width: 230.4, blocks: []}\n      - blocks: [{text: \"Signed\"}]\n");
    let Some(f) = fx(
        "empty-column",
        &l,
        "---\nx: 1\n---\nThe body.\n",
        &["pandoc"],
    ) else {
        return;
    };
    assert!(f
        .latex()
        .unwrap()
        .contains("\\hsize=230.4bp\\linewidth=\\hsize\\hrule height0pt width\\hsize"));
}

#[test]
fn an_authority_needle_takes_the_words_before_it_when_few_follow() {
    let Some(f) = fx(
        "needle-before",
        &layout("authorities: {title: Authorities, col: 56}\n"),
        "---\nauthorities:\n  - heading: Statutes\n    entries:\n      - {cite: \"Wis. Stat. § 6.855\", find: \"6.855\"}\n---\nThe clerk must follow Wis. Stat. § 6.855.\n",
        &["pandoc"],
    ) else {
        return;
    };
    f.docx().unwrap();
    let needles = f.written("needles.tsv").unwrap();
    let line = needles.lines().find(|l| l.starts_with("a1.1\t")).unwrap();
    assert!(line.contains("theclerkmustfollowwisstat6855"), "{needles}");
}

// fb-595.54.82 serial lane 2: the features ported from the Ohio fan-out (fb-595.54.15)

#[test]
fn columns_at_given_widths_and_a_list_split_in_two() {
    // `widths`: the width of each place in a row; `split`: the first N items (a frontmatter field) in the first column,
    // the rest in the second, `gap` apart; `each.gap`: the least space between two items
    let l = layout("cover:\n  - columns: {each: counsel, widths: [100, 200], blocks: [{text: \"{name}\"}]}\n  - columns: {each: counsel, split: left, gap: 6, blocks: [{text: \"{name}\"}]}\n  - each: counsel\n    gap: 12\n    blocks: [{text: \"{name}\"}]\n  - {break: true}\n");
    let Some(f) = fx(
        "columns-split",
        &l,
        "---\nleft: 1\ncounsel:\n  - {name: ALPHA}\n  - {name: BETA}\n  - {name: GAMMA}\n---\nThe body.\n",
        &["typst", "pandoc", "pdftotext"],
    ) else {
        return;
    };
    // the split: ALPHA alone at the left, BETA and GAMMA one under the other at the right
    let page = f.typst_pages().unwrap()[0].clone();
    let words: Vec<&str> = page
        .lines()
        .map(str::trim)
        .filter(|l| !l.is_empty())
        .collect();
    assert!(
        words
            .iter()
            .any(|l| l.starts_with("ALPHA") && l.ends_with("BETA")),
        "{words:?}"
    );
    assert!(
        words.iter().filter(|l| **l == "GAMMA").count() == 2,
        "{words:?}"
    );
    // LaTeX: the widths given, two columns for the split
    let tex = f.latex().unwrap();
    assert!(
        tex.contains("\\hsize=100bp") && tex.contains("\\hsize=200bp"),
        "{tex}"
    );
    // Word: the column widths in twips
    let doc = f.docx().unwrap();
    assert!(
        doc.contains(r#"w:w=\"2000\""#) && doc.contains(r#"w:w=\"4000\""#),
        "{doc}"
    );
    // the each gap: 12 pt above the second and third items (240 twips), none above the first
    assert!(doc.matches(r#"w:before=\"240\""#).count() >= 2, "{doc}");
}

#[test]
fn a_note_s_paragraph_keeps_its_widow_rule_with_footnote_widows() {
    let l = layout("footnote: {size: 12, widows: true}\n");
    let Some(f) = fx(
        "note-widows",
        &l,
        "---\nx: 1\n---\nA paragraph.[^1]\n\n[^1]: The note.\n",
        &["pandoc"],
    ) else {
        return;
    };
    assert!(!f.latex().unwrap().contains("\\widowpenalty=0"));
    assert!(!f.docx().unwrap().contains("Body Text Note"));
    let f = fx(
        "note-no-widows",
        &layout(""),
        "---\nx: 1\n---\nA paragraph.[^1]\n\n[^1]: The note.\n",
        &["pandoc"],
    )
    .unwrap();
    assert!(f.latex().unwrap().contains("\\widowpenalty=0"));
    assert!(f.docx().unwrap().contains("Body Text Note"));
}

#[test]
fn latex_slashes_closing_hyphens_and_spaced_asterisks() {
    let Some(f) = fx(
        "latex-inline-15",
        &layout(""),
        "---\nx: 1\n---\nFiled on CM/ECF as a full- or part-time (pre-) job. Omitted * * * here, and /s/ Jane.\n",
        &["pandoc"],
    ) else {
        return;
    };
    let tex = f.latex().unwrap().replace('\n', " ");
    assert!(tex.contains("CM/\\allowbreak{}ECF"), "{tex}");
    assert!(!tex.contains("/\\allowbreak{}s/"), "{tex}");
    assert!(tex.contains("(pre\\mbox{-})"), "{tex}");
    assert!(tex.contains("/ActualText<FEFF002A0020>"), "{tex}");
}

#[test]
fn a_typst_mark_after_a_section_sign_stays_on_its_line() {
    // a find that ends in a sign's token ("§ 1."): the mark before the sign, not in xengine's box (set a line below,
    // after the paragraph when it ends one)
    let Some(f) = fx(
        "sign-mark",
        &layout("authorities: {title: Authorities, col: 56}\n"),
        "---\nauthorities:\n  - heading: Other\n    entries:\n      - {cite: C, find: \"art. XVI, § 1\"}\n---\nThe title on the ballot itself, R.C. 3519.21; Ohio Const., art. XVI, § 1.\n\nNext paragraph.\n",
        &["typst", "pdftotext"],
    ) else {
        return;
    };
    f.typst_pages().unwrap();
    let pos = f
        .typst_eval("query(<xd-toa>).map(m => m.location().position().y.pt())")
        .unwrap();
    let ys: Vec<f64> = serde_json::from_str(&pos).unwrap();
    let lines = f.typst_lines().unwrap();
    let p = &lines[1];
    // on the line of "§ 1." (its yMax is the line's foot, the mark at most a line box above it)
    let y = y_of(p, "artxvi1");
    assert!(ys[0] < y && ys[0] > y - 14.0, "{ys:?} {y}");
}

#[test]
fn a_hyphen_before_a_digit_in_a_url_is_held_by_a_word_joiner_in_word() {
    let Some(f) = fx(
        "url-hyphen",
        &layout(""),
        "---\nx: 1\n---\nSee https://a.gov/x/672548a6-97ff-46e8/Untitled-Petition.aspx here.\n",
        &["pandoc"],
    ) else {
        return;
    };
    let doc = f.docx().unwrap();
    assert!(
        doc.contains("672548a6-\u{2060}97ff")
            || doc.contains("672548a6-\\8288\\&97ff")
            || doc.contains("672548a6-\\8288"),
        "{doc}"
    );
    assert!(!doc.contains("noBreakHyphen"), "{doc}");
}

// fb-595.54.82 serial lane 2: the features ported from the Kansas fan-out (fb-595.54.14)

#[test]
fn a_body_table_is_set_as_rules_and_rows_in_every_engine() {
    let l = layout("table: {pad: 3.6, gutter: 14.4, above: 14.4, below: 14.4, stroke: 0.5}\n");
    let Some(f) = fx(
        "body-table",
        &l,
        "---\nx: 1\n---\nBefore.\n\n| Year | Gap |\n|---|---|\n| 2012 | 10.7% |\n| 2022 | 22.4% |\n\nAfter.\n",
        &["typst", "pandoc", "pdftotext"],
    ) else {
        return;
    };
    let words = |s: &str| s.split_whitespace().collect::<Vec<_>>().join(" ");
    let text = words(&f.typst_pages().unwrap()[0]);
    assert!(
        text.contains("Before. Year Gap 2012 10.7% 2022 22.4% After."),
        "{text}"
    );
    // LaTeX: four rules (above, between the rows, below) and a row of two columns per table row
    let tex = f.latex().unwrap();
    assert_eq!(tex.matches("\\hrule height 0.5bp").count(), 4, "{tex}");
    assert!(
        tex.contains("{\\bfseries") || tex.contains("\\bfseries"),
        "{tex}"
    );
    // Word: the same rules as bordered paragraphs, the rows as one-row tables
    let doc = f.docx().unwrap();
    assert_eq!(doc.matches("<w:pBdr>").count(), 4, "{doc}");
    assert!(doc.matches("<w:tbl>").count() >= 3, "{doc}");
}

#[test]
fn a_rule_of_zero_is_space_alone_and_lines_take_their_style() {
    let l = layout("closing:\n  - {rule: 0, above: 21.6}\n  - {text: \"{service.paragraphs}\", indent: 36, lines: {indent: 0, left: 36, above: 7.2}}\n");
    let Some(f) = fx(
        "rule-zero-lines",
        &l,
        "---\nservice:\n  paragraphs:\n    - \"Served by mail on:\"\n    - \"Jane Roe\\n1 Main St.\\nTopeka, KS\"\n    - \"And by e-mail.\"\n---\nThe body.\n",
        &["typst", "pandoc", "pdftotext"],
    ) else {
        return;
    };
    let lines = f.typst_lines().unwrap();
    let p = &lines[0];
    // the address one line per line at its own indent, 7.2 pt above it and above the value after it
    let (a, b, c) = (
        y_of(p, "janeroe"),
        y_of(p, "1mainst"),
        y_of(p, "andbyemail"),
    );
    assert!(
        (b - a - 13.8).abs() < 0.1 && (c - y_of(p, "topekaks") - 13.8 - 7.2).abs() < 0.1,
        "{a} {b} {c}"
    );
    let tex = f.latex().unwrap();
    assert!(tex.contains("width 0pt"), "{tex}");
    let doc = f.docx().unwrap();
    assert_eq!(doc.matches("<w:pBdr>").count(), 0, "{doc}");
    assert!(
        doc.contains(r#"w:left=\"720\""#) && doc.contains(r#"w:before=\"144\""#),
        "{doc}"
    );
}

#[test]
fn a_note_mark_is_attached_and_an_apostrophe_after_emphasis_is_closing() {
    let Some(f) = fx(
        "attach-notes",
        &layout(""),
        "---\nx: 1\n---\nThe system. [^1] And *Rucho*'s holding \u{2013}\u{201C}quoted\u{201D}.\n\n- one\n- two\n\n[^1]: A note.\n",
        &["typst", "pandoc", "pdftotext"],
    ) else {
        return;
    };
    let text = f.typst_pages().unwrap().join("");
    assert!(text.contains("Rucho\u{2019}s"), "{text}");
    let tex = f.latex().unwrap().replace('\n', " ");
    assert!(tex.contains("system.\\footnote{"), "{tex}");
    assert!(tex.contains("\\textendash{}\\textquotedblleft{}"), "{tex}");
    let doc = f.docx().unwrap();
    assert!(!doc.contains("Str \"system.\" , Space , Note"), "{doc}");
    // LaTeX lists: no break bonus at a list's start, end and items (lib/latex/xdoc.sty)
    let sty = std::fs::read_to_string(f.root.join("lib/latex/xdoc.sty")).unwrap();
    assert!(sty.contains("\\@beginparpenalty=0 \\@endparpenalty=0 \\@itempenalty=0"));
}

/// A footnote in a paragraph a template wraps in a block (`block(width: 100%, above: 0pt, below: 0pt, par(..))`, the
/// fifth-circuit motion briefs' body paragraphs) starts on the page of its mark: when the mark's line and the note do
/// not both fit, both move on (typst kept the note on the page the line was first laid on: lawb motion-brief note 7
/// on page 4, its mark on page 5; lib/typst/xengine.typ unwrap-note-par, fb-595.54.11.1). The paragraph is set at
/// offsets down a page of its own (one point apart) where the mark's line meets the foot of the page.
/// (A note too long for the rest of its mark's page may still follow on the next page, as before.)
#[test]
fn a_note_never_starts_on_a_page_before_its_mark() {
    let abc = "aaa bbb ccc ddd eee fff ggg hhh iii jjj kkk lll mmm nnn ooo ppp qqq rrr sss ttt uuu vvv www xxx yyy zzz";
    let (to_t, from_u) = abc.split_at(abc.find(" uuu").unwrap());
    let para = format!("A{} {to_t}#footnote[Note C.]{from_u} {abc} {abc} {abc}", &abc[1..]);
    if !have(&["typst"]) {
        return;
    }
    let root = root();
    let dir = root.join("tools/fb/target/model-tests/note-before-mark");
    let _ = std::fs::remove_dir_all(&dir);
    std::fs::create_dir_all(&dir).unwrap();
    let main = format!(
        r#"#import "/lib/typst/xengine.typ": xengine, edges
#set page(paper: "us-letter", margin: 1in)
#set text(font: "Liberation Serif", size: 12pt)
#set par(first-line-indent: (amount: 0.5in, all: true))
#show: xengine.with(pitch: 24pt, list-indent: none)
#set footnote.entry(gap: 6pt, clearance: 8pt, indent: 0pt)
#show footnote.entry: it => {{
  set text(..edges(14pt))
  set par(first-line-indent: 0pt)
  context [#metadata((mark: it.note.location().page(), entry: here().page()))<entry>]
  it
}}
#for n in range(568, 580) {{
  pagebreak(weak: true)
  context [#metadata(here().page())<start>]
  v(n * 1pt)
  block(width: 100%, above: 0pt, below: 0pt, par[{p}])
  parbreak()
  lorem(40)
}}
"#,
        p = para
    );
    std::fs::write(dir.join("main.typ"), main).unwrap();
    let query = |sel: &str| {
        let o = Command::new("typst")
            .args(["query", "--root"])
            .arg(&root)
            .arg("--font-path")
            .arg(root.join("fonts"))
            .arg("--ignore-system-fonts")
            .arg(dir.join("main.typ"))
            .args([sel, "--field", "value"])
            .output()
            .unwrap();
        assert!(o.status.success(), "{}", String::from_utf8_lossy(&o.stderr));
        serde_json::from_slice::<Vec<serde_json::Value>>(&o.stdout).unwrap()
    };
    let entries = query("<entry>");
    let starts = query("<start>");
    assert_eq!(entries.len(), starts.len());
    for e in &entries {
        assert!(e["entry"].as_i64() >= e["mark"].as_i64(), "a note starts on a page before its mark: {e}");
    }
    // the fixture moves some mark's line (and its note) to the page after its paragraph's first line
    assert!(
        entries.iter().zip(&starts).any(|(e, s)| e["mark"].as_i64() > s.as_i64()),
        "no trial moved a mark's line on: {entries:?}"
    );
}
