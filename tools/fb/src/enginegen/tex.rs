//! The generated `latex/template.tex` of a folder on the shared document model (gen.rs): a pandoc template whose
//! `$body$` lib/latex/xdoc.lua writes. Every size and space in bp (= typst's pt), from the layout.
use super::gen::{fmt, footer, is_running, latex_face, num};
use serde_yaml::Value;

/// The footnote defaults of the model (lib/typst/xdoc.typ): 7 pt between two notes, `CLEARANCE` above the rule.
pub const NOTE_GAP: f64 = 7.0;
/// LibreOffice keeps 16.1 pt between the last line box of the text and the first note's: the note gap and 9.1 pt (measured
/// fb-595.54.13 with a one-line note under a page of text whose top margin moved 0.05 pt at a time; 12 and 14 pt notes,
/// body pitches 24 and 32.2 alike); typst and LaTeX keep the same (7.5 left a line on a page LibreOffice moved on).
pub const CLEARANCE: f64 = 9.1;

/// A list marker as LaTeX text.
fn tex_marker(m: &str) -> String {
    match m {
        "\u{2022}" => "\\textbullet".into(),
        "\u{2013}" => "\\textendash".into(),
        "\u{2014}" => "\\textemdash".into(),
        "-" => "-{}".into(),
        s => s
            .chars()
            .filter(|c| c.is_alphanumeric() || " .,;:()[]*+".contains(*c))
            .collect(),
    }
}

/// The bullets of the four list levels LaTeX nests (layout.yaml `list.markers`, the last repeated; typst xdoc the same).
fn markers(l: &Value) -> String {
    let ms: Vec<String> = l
        .get("list")
        .and_then(|x| x.get("markers"))
        .and_then(Value::as_sequence)
        .map(|s| s.iter().filter_map(Value::as_str).map(tex_marker).collect())
        .unwrap_or_default();
    if ms.is_empty() {
        return String::new();
    }
    (1..=4)
        .map(|lv| {
            format!(
                "\\setlist[itemize,{lv}]{{label={}}}\n",
                ms[(lv - 1).min(ms.len() - 1)]
            )
        })
        .collect()
}

pub fn template(l: &Value, face: &str) -> Result<String, String> {
    let (pkg, ellipsis) = latex_face(face)?;
    // three periods (newtx: 0.25 em each; latex_period) kerned to the face's ellipsis, read as one "…" (/ActualText)
    let ellipsis = match ellipsis {
        Some(adv) => format!(
            "\\newcommand\\xd@ellipsis{{\\pdfliteral page{{/Span<</ActualText<FEFF2026>>>BDC}}.\\kern{k}em.\\kern{k}em.\\pdfliteral page{{EMC}}}}",
            k = fmt((adv - 3.0 * super::gen::latex_period(face)) / 2.0)
        ),
        // Schola: three periods as one glyph at the vendored font's ellipsis advances (lib/latex/xeschola.lua's)
        // EB Garamond: three periods spread in a box of the vendored ellipsis's advance in the current shape (xdoc.sty)
        None if face == "EB Garamond" => "\\newcommand\\xd@ellipsis{\\xd@glyph{2026}{.\\hfil.\\hfil.}{0.686}{0.746}{0.671}{0.764}}".into(),
        None if super::gen::latex_glyphs(face) == Some("schola") => "% Schola: each glyph at the vendored advance where it stands (lib/latex/xeschola.sty)\n\\let\\xeglyph\\xeglyphcentered\n\\newcommand\\xd@ellipsis{\\pdfliteral page{/Span<</ActualText<FEFF2026>>>BDC}\\xeglyph{...}{860}{1000}{860}{1000}\\pdfliteral page{EMC}}".into(),
        None => "\\newcommand\\xd@ellipsis{\\textellipsis}".into(),
    };
    let size = num(l, "size", None)?;
    let body = num(l, "pitch.body", None)?;
    let (single, skip, _) = footer(l)?;
    let m = |s: &str| num(l, &format!("margin.{s}"), None);
    let indent = num(l, "indent", None)?;
    let list = num(l, "list_indent", Some(indent))?;
    let nsize = num(l, "footnote.size", Some(size))?;
    let npitch = match l.get("footnote").and_then(|f| f.get("pitch")) {
        Some(Value::String(s)) if s == "body" => body,
        Some(Value::Number(n)) => n.as_f64().unwrap_or(single),
        _ => single,
    };
    let gap = num(l, "footnote.gap", Some(NOTE_GAP))?;
    let clear = num(l, "footnote.clearance", Some(CLEARANCE))?;
    let from = num(l, "page_number.from", Some(1.0))?;
    let align = l
        .get("page_number")
        .and_then(|p| p.get("align"))
        .and_then(Value::as_str)
        .unwrap_or("center");
    // the number alone, or the layout's `page_number.text` ("Page {page} of {pages}": {pages} the last page's number,
    // \pageref* of the label lib/latex/xdoc.lua sets at the end)
    let shown = match l
        .get("page_number")
        .and_then(|p| p.get("text"))
        .and_then(Value::as_str)
    {
        // (after an \hfil: a brace ends the control word before the text)
        Some(t) => {
            "{}".to_string()
                + &t.replace('\\', "\\textbackslash{}")
                    .replace(['&', '%', '$', '#', '_'], "")
                    .replace("{pages}", "\\pageref*{xd@lastpage}")
                    .replace("{page}", "\\thepage{}")
        }
        None => "\\thepage".to_string(),
    };
    let running = l
        .get("page_number")
        .and_then(|p| p.get("text"))
        .and_then(Value::as_str)
        .is_some_and(is_running);
    let number = match align {
        // a running footer (frontmatter fields, lines at "<br>"): the lines lib/latex/xdoc.lua defines as \xd@foot,
        // each a box of the text's width, stacked from the number's baseline down
        _ if running => "\\vtop{\\csname xd@foot\\endcsname}".to_string(),
        "left" => format!("{shown}\\hfil"),
        "right" => format!("\\hfil{shown}"),
        _ => format!("\\hfil{shown}\\hfil"),
    };
    let style = if l.get("page_number").is_some_and(Value::is_null) {
        "empty"
    } else {
        "plain"
    };
    let _ = from; // pages before `from` are unnumbered: lib/latex/xdoc.lua sets \thispagestyle{empty}
    let (paper, _) = super::gen::paper(l)?;
    let justify = l.get("justify").and_then(Value::as_bool).unwrap_or(false);
    Ok(format!(
        r#"% {head}
% The shared document model in LaTeX (lib/latex/xdoc.lua writes $$body$$) on the cross-engine layout model
% (lib/latex/xengine.sty, inlined by fb render): first fit, exact line boxes, no kerning, ligatures or hyphenation,
% spaces with \addvspace. Sizes and spaces in bp, typst's pt.
\documentclass{{article}}
\usepackage[T1]{{fontenc}}
% the typst template's face, in the metrics typst and Word set (docs/EVAL-LOOP.md, step 0)
{pkg}
% the page (layout.yaml margin); the page number's baseline {skip} bp below the text, where typst sets it; the text
% block {bias} bp wider at the right than typst's, the measured drift of the face's advances (gen.rs latex_bias)
\usepackage[{paper},top={t}bp,bottom={b}bp,left={le}bp,right={r}bp,headheight=0pt,headsep=0pt,footskip={skip}bp]{{geometry}}
\usepackage{{enumitem}}
\usepackage[hidelinks]{{hyperref}}
{xcolor}\usepackage{{xengine}} % lib/latex/xengine.sty, inlined by fb render
\usepackage{{xdoc}} % lib/latex/xdoc.sty (page bookkeeping), inlined by fb render
\makeatletter
% the body: {size} bp type in {body} bp line boxes, the first line indented {indent} bp (layout.yaml size, pitch.body,
% indent)
\renewcommand\normalsize{{\xe@lines{{{size}}}{{{body}}}}}
\normalsize
\setlength{{\parindent}}{{{indent}bp}}
{justify}% the page number: centered (layout.yaml page_number) in a single line box
\def\ps@plain{{\let\@mkboth\@gobbletwo\let\@oddhead\@empty\let\@evenhead\@empty
  \def\@oddfoot{{\reset@font\xe@lines{{{size}}}{{{single}}}{number}}}\let\@evenfoot\@oddfoot}}
\pagestyle{{{style}}}
% lists: the number or bullet in a {list} bp box at the margin, the text hanging after it
\providecommand{{\tightlist}}{{\setlength{{\itemsep}}{{0pt}}\setlength{{\parskip}}{{0pt}}}}
\providecommand{{\pandocbounded}}[1]{{#1}}
\xe@lists{{{list}bp}}
{markers}% footnotes (layout.yaml footnote): {nsize} bp type in {npitch} bp line boxes, the mark and a space, {gap} bp above
% each note, {clear} bp from the text to a 30 % rule; marks at 58 % of the type size (of the note's in the note)
\renewcommand\footnotesize{{\xe@lines{{{nsize}}}{{{npitch}}}}}
\setlength{{\skip\footins}}{{{clear}bp}}
\renewcommand\footnoterule{{\vskip 0pt plus 1fill\kern-0.25bp\hrule width 0.3\textwidth height 0.5bp\kern-0.25bp}}
\xe@footnotemarks{{{size}}}
\renewcommand\@makefntext[1]{{\rightskip={fnright}\relax\parfillskip=0pt plus 1{fnfill}\relax\parskip={gap}bp\relax
  \vskip 0pt\noindent\raisebox{{{nraise}bp}}{{\fontsize{{{nmark}bp}}{{0bp}}\selectfont\@thefnmark}}\hskip 0.25em #1}}
% an ellipsis as typst and Word set it (lib/latex/xdoc.lua writes \xd@ellipsis for "…")
{ellipsis}
\makeatother
\begin{{document}}
\makeatletter
$body$
\makeatother
\end{{document}}
"#,
        head = super::gen::HEAD,
        t = fmt(m("top")?),
        b = fmt(m("bottom")?),
        le = fmt(m("left")?),
        r = fmt(m("right")? - super::gen::folder_latex_bias(l, face)),
        skip = fmt(skip),
        size = fmt(size),
        body = fmt(body),
        single = fmt(single),
        indent = fmt(indent),
        list = fmt(list),
        nsize = fmt(nsize),
        npitch = fmt(npitch),
        gap = fmt(gap),
        clear = fmt(clear),
        bias = fmt(super::gen::folder_latex_bias(l, face)),
        nraise = fmt(0.29 * nsize),
        nmark = fmt(0.58 * nsize),
        markers = markers(l),
        ellipsis = ellipsis,
        justify = if justify { JUSTIFY } else { "" },
        fnright = if justify { "0pt" } else { "0pt plus 1fil" },
        xcolor = if l.get("cover_fill").is_some() {
            "% a coloured cover (layout.yaml cover_fill): \\pagecolor on its pages (lib/latex/xdoc.lua)\n\\usepackage{xcolor}\n"
        } else {
            ""
        },
        fnfill = if justify { "fill" } else { "fil" },
    ))
}

/// Justified text (layout.yaml `justify: true`; lib/typst/xdoc.typ justified): every line of the body (lib/latex/xdoc.lua
/// sets it with \xd@justtrue) but a paragraph's last at the full measure. Its interword spaces stretch by 1fil and never
/// shrink: every line's badness is 0, so TeX's breaks stay the first-fit ones (a finite stretch large enough for that
/// overflows TeX's glue totals); the last line keeps its natural spaces (\parfillskip 1fill outranks them); the
/// layout's blocks (cover, headings, tables) set \xd@justfalse and stay ragged.
const JUSTIFY: &str = "% justified text (layout.yaml justify): in the body, spaces that stretch and never shrink; the lines break where\n% they do ragged\n\\newif\\ifxd@just\n\\AddToHook{selectfont}[xdjustify]{\\ifxd@just\\spaceskip=\\fontdimen2\\font plus 1fil\\relax\\fi}\n\\DeclareHookRule{selectfont}{xengine}{before}{xdjustify}\n\\@rightskip=0pt\\rightskip=0pt\\parfillskip=0pt plus 1fill\n";
