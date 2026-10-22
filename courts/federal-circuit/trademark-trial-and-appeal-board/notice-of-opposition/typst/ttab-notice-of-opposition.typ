// Trademark Trial and Appeal Board: notice of opposition (combined or single).
//
// Rule-driven and content-agnostic. Rule IDs (TTAB-NOP-...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed notice, no forced line breaks.
// The body is rendered by cmarker; the caption, applications and signature come from the
// YAML frontmatter of the same sample (schema: ../README.md, "Markdown contract").
// Paragraph numbers are typed in the markdown, as filed; the template does not number them.
//
// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing). docx/ttab-notice.lua and docx/make-reference.sh
// set the same pitches and spaces (twips = 20 x pt), so the docx breaks every line and page where this does.

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers here; each traces to a rule or a stated choice)
// ---------------------------------------------------------------------------

// TTAB-FORM-006: the rule names no face. The Brink exemplar is set mostly in Adobe Times (the font audit,
// data/exemplar-fonts.json, maps it to the vendored TeX Gyre Termes, which has its metrics); the docx names the same.
#let font-family = "TeX Gyre Termes"
#let type-size = 12pt                       // TTAB-NOP-FORM-001: at least 11-point (37 CFR 2.126(a)(1))
#let pitch-double = 24pt                    // TTAB-NOP-FORM-002: double-spaced, twice the type size
#let pitch-single = 13.8pt                  // caption, headings, signature block, slip sheets: single-spaced
#let page-margin = 1in                      // TTAB-NOP-FORM-003: convention for 8.5 x 11 paper (tier 2)
#let para-indent = 0.5in
#let label-col = 2.2in                      // the labels of the applications block
#let caption-cols = (3.4in, 0.35in, 2.4in)  // names, the ")" column, the opposition number
#let designation-indent = 2.1in             // "Opposer," under the names
#let versus-indent = 1.2in                  // "v." between the sides
#let sig-indent = 3in                       // the signature block
#let top-gap = 4pt                          // above the first line: the face's ascender, as LibreOffice embeds it
                                            // (about 14.6 pt at 12 pt), is taller than the 11.04 pt of the line
                                            // box above the baseline; the docx sets the same space before

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("ttab-notice-of-opposition: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ttab-notice-of-opposition: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-spaced paragraph with explicit spaces above and below.
#let line-par(body, above: 0pt, below: 0pt, indent: 0pt, centered: false) = block(width: 100%, above: above,
  below: below, pad(left: indent, if centered { align(center, par(first-line-indent: 0pt, body)) }
    else { par(first-line-indent: 0pt, body) }))

// ---------------------------------------------------------------------------
// Front matter of the filing: the USPTO heading, the applications, the caption, the title
// ---------------------------------------------------------------------------

/// TBMP 309.02(a): the heading the Board requires at the top of the complaint.
#let board-heading() = {
  line-par(strong[IN THE UNITED STATES PATENT AND TRADEMARK OFFICE], centered: true)
  line-par(strong[BEFORE THE TRADEMARK TRIAL AND APPEAL BOARD], centered: true)
}

/// TBMP 309.02(a): identification of the application(s) opposed. Each row: the label in a column of
/// `label-col`, the value after it, wrapped lines hanging at the column.
#let applications-block(meta) = {
  let apps = meta.at("applications", default: ())
  for app in apps {
    let rows = (
      ([In re Application of:], inl(app.applicant)),
      ([Serial No.:], [#app.serial]),
      ([Mark:], inl(app.mark)),
      ([Application Date:], [#app.application_date]),
      ([Publication Date:], [#app.publication_date]),
    )
    block(breakable: false, above: 14.4pt, below: 4.8pt, {
      for (i, (label, value)) in rows.enumerate() {
        block(above: if i == 0 { 0pt } else { 4.2pt }, below: 0pt,
          par(first-line-indent: 0pt, hanging-indent: label-col, { box(width: label-col, label); value }))
      }
    })
  }
}

/// The party caption: names on the left, a column of ")" for each line, and the opposition number
/// on the right, on the middle line. Every row is one single-spaced line, so the parentheses line up with the
/// names by construction.
#let caption-table(meta) = {
  let sides = need(meta, "caption")
  let rows = ()
  for (i, side) in sides.enumerate() {
    for name in side.names { rows.push((0pt, inl(name))) }
    rows.push((designation-indent, inl(side.designation)))
    if i < sides.len() - 1 {
      rows.push((0pt, []))
      rows.push((versus-indent, [v.]))
      rows.push((0pt, []))
    }
  }
  let number = if "opposition_no" in meta { meta.opposition_no } else { "______________" }
  let mid = calc.quo(rows.len(), 2)
  let cells = ()
  for (i, (ind, r)) in rows.enumerate() {
    cells.push(pad(left: ind, par(first-line-indent: 0pt, r)))
    cells.push(align(center, par(first-line-indent: 0pt, [)])))
    cells.push(if i == mid { par(first-line-indent: 0pt, [Opposition No. #number]) } else { [] })
  }
  block(above: 14.4pt, below: 0pt, grid(columns: caption-cols, rows: pitch-single, ..cells))
}

// ---------------------------------------------------------------------------
// Signature and exhibits
// ---------------------------------------------------------------------------

/// Signature block (37 CFR 2.193(c): the electronic signature is "/Name/"). It is not split across pages.
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: 19.2pt, below: 0pt, {
    if "date" in meta { line-par[Date: #inl(meta.date)] }
    line-par([Respectfully submitted,], indent: sig-indent)
    line-par([By: /#sig.signer/], above: 14.4pt, indent: sig-indent)
    for l in sig.lines { line-par(inl(l), indent: sig-indent) }
  })
}

/// One slip sheet per exhibit, on its own page: "EXHIBIT 1" with its description underneath, centered on the page.
#let exhibit-slip-sheets(meta) = {
  for ex in meta.at("exhibits", default: ()) {
    let parts = ex.split(":")
    let label = parts.at(0).trim()
    let desc = parts.slice(1).join(":").trim()
    pagebreak()
    block(height: 1fr, width: 100%, above: 0pt, below: 0pt, align(horizon, {
      line-par(strong(upper(label)), centered: true)
      if desc != "" { line-par(inl(desc), centered: true) }
    }))
  }
}

// ---------------------------------------------------------------------------
// The notice
// ---------------------------------------------------------------------------

#let ttab-notice-of-opposition(meta, md) = {
  set document(title: need(meta, "title"))
  set page(paper: "us-letter", margin: page-margin,
    footer: context align(center, text(size: type-size, ..edges(pitch-single), counter(page).display())))
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  // Body text is double-spaced, and the first line of each paragraph is indented.
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, no kerning, ligatures or hyphenation, line boxes of the body pitch.
  show: xengine.with(pitch: pitch-double, list-indent: para-indent)
  // Headings in a notice: count headings are centered and bold, in capitals, at the body size.
  show heading: it => {
    set text(size: type-size, weight: "bold", ..edges(pitch-single))
    block(width: 100%, sticky: true, above: 16.8pt, below: 12pt,
      align(center, par(first-line-indent: 0pt, upper(it.body))))
  }

  {
    set text(..edges(pitch-single))
    v(top-gap, weak: false)
    board-heading()
    applications-block(meta)
    caption-table(meta)
    line-par(strong(upper(inl(need(meta, "title")))), above: 14.4pt, below: 7.2pt, centered: true)
  }

  // The signature block never stands alone on a page: the notice's last paragraph is kept together with it
  // (unless that last block is a heading or a list).
  let text-md = md.trim(at: end)
  let breaks = text-md.matches(regex("\n[ \t]*\n"))
  let cut = if breaks.len() > 0 { breaks.last().end } else { 0 }
  let tail = text-md.slice(cut)
  let keep = tail.len() > 0 and not tail.starts-with("#") and tail.match(regex("^\\s*([-*+]|\\d+[.)])\\s")) == none
  let render(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)
  let sig = { set text(..edges(pitch-single)); signature-block(meta) }
  if keep {
    render(text-md.slice(0, cut))
    block(breakable: false, above: 0pt, below: 0pt, { render(tail); sig })
  } else {
    render(text-md)
    sig
  }
  {
    set text(..edges(pitch-single))
    exhibit-slip-sheets(meta)
  }
}
