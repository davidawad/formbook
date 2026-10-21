//! The mutants of `fb selftest`, kept as data: each breaks ONE thing in a scratch copy of the court folder.

#[derive(Debug, Clone, Copy, PartialEq)]
pub enum Kind {
    Content,
    Layout,
    /// latex/template.tex changed; rendered and checked with the latex engine
    Latex,
    /// latex/template.tex changed; the latex render itself must fail with `want` in its message (the stock
    /// pdflatex check). `texinputs`: the render runs with TEXINPUTS pointing at the scratch latex/ folder.
    LatexBuild {
        texinputs: bool,
    },
    /// rendered with the docx engine, then the .docx itself is broken (selftest/docx.rs): `part` None cuts the
    /// archive in half, Some(part) applies `expr` to that part; checked with `--engine docx`
    Docx {
        part: Option<&'static str>,
    },
}

pub struct Mutant {
    pub name: &'static str,
    pub want: &'static str,
    pub kind: Kind,
    pub expr: &'static str,
}

/// content mutants: PDF built from changed markdown, compared with the original; layout mutants: template
/// changed, markdown unchanged.
pub const MUTANTS: &[Mutant] = &[
    Mutant {
        name: r"drop-paragraph",
        want: r"CA9-TOOL-001",
        kind: Kind::Content,
        expr: r"/^90\\\. The administrative record/d",
    },
    Mutant {
        name: r"drop-dash-paragraph",
        want: r"CA9-TOOL-001",
        kind: Kind::Content,
        expr: r"/^\\- The District has never explained/d",
    },
    Mutant {
        name: r"alter-word",
        want: r"CA9-TOOL-001",
        kind: Kind::Content,
        expr: r"s/The word “shall” forecloses/The word “may” forecloses/",
    },
    Mutant {
        name: r"lose-italics",
        want: r"CA9-TOOL-003",
        kind: Kind::Content,
        expr: r"s/\*Brightwater\* held that/Brightwater held that/",
    },
    Mutant {
        name: r"alter-footnote",
        want: r"CA9-TOOL-004",
        kind: Kind::Content,
        expr: r"s/The order was not preceded by notice/The order was preceded by notice/",
    },
    Mutant {
        name: r"lose-footnote-text",
        want: r"CA9-TOOL-004",
        kind: Kind::Content,
        expr: r"s/ The point is reserved for any remand\.//",
    },
    Mutant {
        name: r"single-spaced",
        want: r"CA9-FORM-003",
        kind: Kind::Layout,
        expr: r"s/^#let pitch-double = 29.4pt/#let pitch-double = 17pt/",
    },
    Mutant {
        name: r"small-type",
        want: r"CA9-FORM-004",
        kind: Kind::Layout,
        expr: r"s/^#let type-size = 14pt/#let type-size = 12pt/",
    },
    Mutant {
        name: r"narrow-margins",
        want: r"CA9-FORM-002",
        kind: Kind::Layout,
        expr: r"s/^#let page-margin = 1in/#let page-margin = 0.8in/",
    },
    Mutant {
        name: r"left-aligned-headings",
        want: r"CA9-FORM-009",
        kind: Kind::Layout,
        expr: r"s/      align(center, text(size: heading-size, ..edges(pitch-heading), strong(upper(it.body)))))/      align(left, text(size: heading-size, ..edges(pitch-heading), strong(upper(it.body)))))/",
    },
    Mutant {
        name: r"wrong-font",
        want: r"CA9-FORM-007",
        kind: Kind::Layout,
        // ca9 declares Liberation Serif as its vendored serif face; mutate that declaration explicitly.
        expr: r#"s|^#let font-family = .*"Liberation Serif".*$|#let font-family = "DejaVu Sans Mono"|"#,
    },
    Mutant {
        name: r"footnotes-small",
        want: r"CA9-FORM-004",
        kind: Kind::Layout,
        expr: r"s/shared-footnote-body(note.body, num, type-size,/shared-footnote-body(note.body, num, 11pt,/",
    },
    Mutant {
        name: r"no-footnote-size",
        want: r"CA9-FORM-004",
        kind: Kind::Layout,
        // typst's own footnote entry (0.85 em) instead of the template's 14 pt one
        expr: r"s/^    shared-footnote-body(note.body, num, type-size, single-leading, 7pt)$/    it/",
    },
    Mutant {
        name: r"wrong-word-count",
        want: r"CA9-CERT-002",
        kind: Kind::Layout,
        expr: r"s/^  certificate-of-compliance(meta, words)$/  certificate-of-compliance(meta, words + 7)/",
    },
    Mutant {
        name: r"argument-numbering",
        want: r"CA9-CONT-012",
        kind: Kind::Layout,
        expr: r#"s/if h.level == 2 { numbering("I.", n) }/if h.level == 2 { numbering("A.", n) }/"#,
    },
    Mutant {
        name: r"case-text-in-template",
        want: r"CA9-TOOL-002",
        kind: Kind::Layout,
        expr: r"s|^// U.S. Court of Appeals for the Ninth Circuit: principal (opening) brief\.|& Theresa Sweet, et al.,|",
    },
    Mutant {
        name: r"toa-tag-before-citation",
        want: r"CA9-TOOL-006",
        kind: Kind::Layout,
        expr: r"s/tag-after-first-word(it.body, \[#metadata(it.dest.slice(4))<toa-hit>\]).first()/{ [#metadata(it.dest.slice(4))<toa-hit>]; it.body }/",
    },
    Mutant {
        name: r"toa-wrong-page",
        want: r"CA9-TOOL-006",
        kind: Kind::Layout,
        expr: r#"s/let page-text = shared-authority-page-labels(hits, key, passim-threshold)/let page-text = hits.filter(h => h.value == key).map(h => str(counter(page).at(h.location()).first() + 1)).dedup().join(", ")/"#,
    },
    Mutant {
        name: r"toa-page-wraps-alone",
        want: r"CA9-TOOL-007",
        kind: Kind::Layout,
        // the page list drops below its entry's last line, onto a line of its own (fb-595.53, the ca5 reply-brief
        // latex TOA)
        expr: r"s/^    align(right + bottom, page),$/    align(right + bottom, pad(top: 2em, page)),/",
    },
    Mutant {
        name: r"toa-entry-on-heading-rule",
        want: r"CA9-TOOL-007",
        kind: Kind::Layout,
        // the first entry rises against the Page(s) underline: one-line entries, a group heading shorter than its line
        expr: r"s/^            linebreak()$/            [ ]/;s/below: 2\.8pt, sticky: true, {/below: 0pt, sticky: true, height: 12pt, {/;s/0\.35in, 9\.8pt)$/0.35in, 0pt)/",
    },
    Mutant {
        name: r"typst-metric-times",
        want: r"CA9-FORM-007",
        kind: Kind::Layout,
        // the metric-compatible Times that latex may embed is not accepted from typst (fb-595.45)
        expr: r#"s|^#let font-family = .*"Liberation Serif".*$|#let font-family = "TeX Gyre Termes"|"#,
    },
    Mutant {
        name: r"latex-not-times",
        want: r"CA9-FORM-007",
        kind: Kind::Latex,
        expr: r"s/^\\usepackage{newtxtext,newtxmath}$/\\usepackage{lmodern}/",
    },
    Mutant {
        name: r"latex-kerning",
        want: r"XENG-003",
        kind: Kind::Latex,
        // kerning and ligatures back on: newtx's kerns shift words, and lines no longer break where typst breaks them
        // (Gate 4 CROSS-ENGINE, fb-595.54)
        expr: r"s/\\pdfnoligatures\\font//",
    },
    Mutant {
        name: r"latex-repo-local-file",
        want: r"stock pdflatex check",
        kind: Kind::LatexBuild { texinputs: true },
        // builds only where TEXINPUTS reaches the template folder; a stranger's stock pdflatex has no such file
        expr: r"s/^\\makeatletter$/\\makeatletter\\IfFileExists{ca9.lua}{}{\\errmessage{needs a repo-local file}}/",
    },
    Mutant {
        name: r"latex-repo-path",
        want: r"stock pdflatex check",
        kind: Kind::LatexBuild { texinputs: false },
        expr: r"s/^\\makeatletter$/\\makeatletter % fonts: $fontdir$/",
    },
    Mutant {
        name: r"docx-corrupt-zip",
        want: r"DEF-DOCX-OPEN",
        kind: Kind::Docx { part: None },
        expr: r"",
    },
    Mutant {
        name: r"docx-dangling-footer",
        want: r"DEF-DOCX-OPEN",
        kind: Kind::Docx {
            part: Some("word/document.xml"),
        },
        // fb-595.64: a section names a footer id the package does not declare (there, pandoc had renumbered the
        // reference document's rIdFooter1; ca9's reference declares that id, so the mutant names one nobody does)
        expr: r#"s/r:id="rIdFtrPage"/r:id="rIdFtrUndeclared"/g"#,
    },
];
