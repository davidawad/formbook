// Trademark Trial and Appeal Board: brief on the case (main, reply or rebuttal) at final hearing.
//
// Rule-driven and content-agnostic. Rule IDs (TTAB-TB-...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The body is rendered by cmarker; the caption, authorities registry, signature and certificate
// come from the YAML frontmatter of the same sample (schema: ../README.md, "Markdown contract").
//
// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing). docx/ttab-trial-brief.lua and docx/make-reference.sh
// set the same pitches and spaces (twips = 20 x pt), so the docx breaks every line and page where this does.

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (the only numbers here; each traces to a rule or a stated choice)
// ---------------------------------------------------------------------------

// TTAB-FORM-006: the rule names no face; Times New Roman in both text-layer trial-brief exemplars. typst falls back
// to the vendored Liberation Serif (the same metrics) where Times New Roman is not installed.
#let font-family = ("Times New Roman", "Liberation Serif")
#let type-size = 12pt                       // TTAB-TB-FORM-001: at least 11-point (37 CFR 2.126(a)(1), TBMP 801.03)
#let pitch-double = 24pt                    // TTAB-TB-FORM-002: double-spaced, twice the type size
#let pitch-single = 13.8pt                  // caption, headings, block quotations, footnotes, signature, authorities
#let page-margin = 1in                      // TTAB-TB-FORM-003: convention for 8.5 x 11 paper (tier 2)
#let para-indent = 0.5in
#let heading-hang = (0.5in, 1in)            // continuation lines of level-2 and level-3 headings
#let caption-cols = (3.4in, 0.35in, 2.4in)  // names, the ")" column, the proceeding numbers
#let designation-indent = 2.1in             // "Opposer," under the names
#let versus-indent = 1.2in                  // "v." between the sides
#let sig-indent = 3in                       // counsel block, signature block
#let toa-page-col = 56pt                    // TOA: the page list keeps the last 56 pt of the line (a longer list widens
                                            // its own row's column)
#let toa-hang = 0.5in
#let toa-tab-room = 4pt                     // the room LibreOffice keeps for a leader tab after the three spaces
#let passim-threshold = 7                   // an authority cited on this many pages or more prints "passim"

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("ttab-trial-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ttab-trial-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-spaced paragraph with explicit spaces above and below.
#let line-par(body, above: 0pt, below: 0pt, indent: 0pt, centered: false) = block(width: 100%, above: above,
  below: below, pad(left: indent, if centered { align(center, par(first-line-indent: 0pt, body)) }
    else { par(first-line-indent: 0pt, body) }))

// ---------------------------------------------------------------------------
// Caption page (TBMP 309.02(a) heading, party caption, opposition number, title, counsel)
// ---------------------------------------------------------------------------

#let board-heading() = {
  line-par(strong[IN THE UNITED STATES PATENT AND TRADEMARK OFFICE], centered: true)
  line-par(strong[BEFORE THE TRADEMARK TRIAL AND APPEAL BOARD], centered: true)
}

/// Party caption: one single-spaced row per line of names, a ")" column beside them, and the proceeding numbers on
/// the right, one every other row, centered against the caption.
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
  let right = need(meta, "caption_right")
  let step = if 2 * right.len() - 1 <= rows.len() { 2 } else { 1 }
  let used = step * (right.len() - 1) + 1
  let start = calc.max(0, calc.quo(rows.len() - used, 2))
  let n = calc.max(rows.len(), start + used)
  let cells = ()
  for i in range(n) {
    let (ind, r) = rows.at(i, default: (0pt, none))
    cells.push(pad(left: ind, par(first-line-indent: 0pt, if r == none { [] } else { r })))
    cells.push(align(center, par(first-line-indent: 0pt, if r == none { [] } else { [)] })))
    let k = i - start
    cells.push(if k >= 0 and calc.rem(k, step) == 0 and calc.quo(k, step) < right.len() {
      par(first-line-indent: 0pt, inl(right.at(calc.quo(k, step))))
    } else { [] })
  }
  block(above: 18pt, below: 0pt, grid(columns: caption-cols, rows: pitch-single, ..cells))
}

/// The caption page: heading, caption, title, the version line, and at its foot the counsel block and the date.
#let caption-page(meta) = {
  set text(..edges(pitch-single))
  board-heading()
  caption-table(meta)
  line-par(strong(inl(need(meta, "brief_title"))), above: 26.4pt, centered: true)
  if "version" in meta { line-par(inl(meta.version), above: 7.2pt, centered: true) }
  v(1fr)
  for (gi, g) in need(meta, "counsel").enumerate() {
    let lines = g.names + g.at("lines", default: ())
    block(breakable: false, above: if gi == 0 { 0pt } else { 6pt }, below: 0pt, {
      for l in lines { line-par(inl(l), indent: sig-indent) }
    })
  }
  line-par(inl(need(meta, "phone")), indent: sig-indent)
  line-par(inl(need(meta, "date")), above: 19.2pt)
}

// ---------------------------------------------------------------------------
// Table of authorities (37 CFR 2.128(b): an alphabetical index of the cases cited)
// ---------------------------------------------------------------------------

/// The page list of one authority, in the displayed (body) numbering. The body starts at the
/// <body-start> label; front matter is numbered in roman numerals and is not counted.
#let pages-for(key) = {
  let start = query(<body-start>).first().location().page()
  let found = ()
  for m in query(<toa-cite>) {
    if m.value.key == key {
      let p = m.location().page() - start + 1
      if p not in found { found.push(p) }
    }
  }
  found.sorted()
}

/// One entry: the name (if any), the citation, a dot leader and the pages. An authority that is not cited prints
/// nothing.
#let toa-entry(key, a) = context {
  let pages = pages-for(key)
  if pages.len() > 0 {
    let shown = if pages.len() >= passim-threshold { emph[passim] } else { [#pages.map(str).join(", ")] }
    listing-row(none, {
      if "name" in a { inl(a.name); [, ] }
      inl(a.cite)
      // LibreOffice moves the last word of a row to a new line unless about 4 pt more than the three spaces before
      // the leader tab are free before the page column (measured on this folder, fb-595.54.6): the same rule here
      h(toa-tab-room)
    }, shown, calc.max(toa-page-col, measure(shown).width), toa-hang, 10.2pt)
  }
}

/// Sort key for an authority: its name without emphasis markers, or the citation.
#let sort-key(a) = lower(a.at("sort", default: a.at("name", default: a.cite)).replace("*", ""))

#let toa-section(meta) = {
  let auth = need(meta, "authorities")
  heading(level: 1, numbering: none, outlined: false)[TABLE OF AUTHORITIES]
  block(width: 100%, above: 0pt, below: 0pt, align(right, par(first-line-indent: 0pt, strong[Page(s)])))
  let groups = (
    ("case", "Cases"),
    ("constitution", "Constitutional Provisions"),
    ("statute", "Statutes"),
    ("regulation", "Regulations"),
    ("rule", "Rules"),
    ("other", "Other Authorities"),
  )
  for (kind, label) in groups {
    let keys = auth.keys().filter(k => auth.at(k).kind == kind)
    keys = if kind == "case" { keys.sorted(key: k => sort-key(auth.at(k))) } else { keys.sorted() }
    if keys.len() == 0 { continue }
    block(width: 100%, sticky: true, above: 13.8pt, below: 0pt, par(first-line-indent: 0pt, strong(label)))
    for k in keys { toa-entry(k, auth.at(k)) }
  }
}

// ---------------------------------------------------------------------------
// Body styles
// ---------------------------------------------------------------------------

/// Level 1: a section, centered and bold. Level 2 and below: bold, left, with the typed label; level 3 italic too.
#let style-heading(it) = {
  set text(size: type-size, weight: "bold", ..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if it.level == 1 {
    block(width: 100%, sticky: true, above: 16.8pt, below: 12pt, align(center, par(it.body)))
  } else if it.level == 2 {
    block(width: 100%, sticky: true, above: 13.2pt, below: 12pt, par(hanging-indent: heading-hang.at(0), it.body))
  } else {
    block(width: 100%, sticky: true, above: 12pt, below: 10.8pt,
      par(hanging-indent: heading-hang.at(1), emph(it.body)))
  }
}

/// Signature block (37 CFR 2.193(c): the electronic signature is "s/Name"). It is not split across pages.
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  set text(..edges(pitch-single))
  block(breakable: false, above: 19.2pt, below: 0pt, {
    line-par(inl(sig.party), indent: sig-indent)
    line-par([By its attorneys,], indent: sig-indent)
    line-par([s/#sig.signer], above: 14.4pt, indent: sig-indent)
    for l in sig.lines { line-par(inl(l), indent: sig-indent) }
  })
}

/// Certificate of service (37 CFR 2.119(a) and (b): service by email, stating the date and manner).
#let certificate-of-service(meta) = {
  let c = need(meta, "service")
  pagebreak(weak: true)
  { set text(..edges(pitch-single)); line-par(strong[CERTIFICATE OF SERVICE], below: 16.8pt, centered: true) }
  block(above: 0pt, below: 0pt, par(first-line-indent: para-indent,
    [I hereby certify that a true and correct copy of the foregoing #inl(need(meta, "brief_title")) was filed electronically and served on this #inl(c.date), via email to:]))
  set text(..edges(pitch-single))
  for (i, r) in c.recipients.enumerate() { line-par(inl(r), above: if i == 0 { 7.2pt } else { 0pt }, indent: para-indent) }
  line-par([s/#c.signer], above: 24pt, indent: sig-indent)
  line-par([#c.signer], indent: sig-indent)
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let ttab-trial-brief(meta, md) = {
  let authorities = need(meta, "authorities")
  set document(title: need(meta, "brief_title").replace("*", ""))
  set page(paper: "us-letter", margin: page-margin, numbering: "i",
    footer: context align(center, text(size: type-size, ..edges(pitch-single), counter(page).display())))
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, no kerning, ligatures or hyphenation, line boxes of the body pitch,
  // footnote marks at 58 %.
  show: xengine.with(pitch: pitch-double, list-indent: para-indent)
  show heading: it => style-heading(it)
  // Block quotations: single-spaced, indented a half inch both sides, 14 pt above and below.
  show quote.where(block: true): it => block(above: 14pt, below: 14pt, pad(left: para-indent, right: para-indent, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    it.body
  }))
  // Footnotes: single-spaced at the body size, the mark and a space before the note, 7 pt between notes.
  set footnote.entry(gap: 7pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  // Every citation link to toa:KEY is tagged with its key, so the table of authorities can list
  // the pages on which it is cited. A key that is not in the authorities registry stops the build.
  show link: it => {
    let d = it.dest
    if type(d) == str and d.starts-with("toa:") {
      let key = d.slice(4)
      if key not in authorities { panic("ttab-trial-brief: `" + key + "` is not in authorities") }
      [#metadata((key: key)) <toa-cite>#it.body]
    } else { it }
  }

  // Front matter: the caption page, then the table of authorities, numbered i, ii, ...
  caption-page(meta)
  pagebreak()
  { set text(..edges(pitch-single)); toa-section(meta) }
  pagebreak()

  // Body: numbered from 1 again, as in a filed brief.
  set page(numbering: "1")
  counter(page).update(1)
  [#metadata("body") <body-start>]

  // The signature block never stands alone on a page: the brief's last paragraph is kept together with it
  // (unless that last block is a heading, a list or a footnote definition).
  let text-md = md.trim(at: end)
  let breaks = text-md.matches(regex("\n[ \t]*\n"))
  let cut = if breaks.len() > 0 { breaks.last().end } else { 0 }
  let tail = text-md.slice(cut)
  let keep = (tail.len() > 0 and not tail.starts-with("#") and not tail.starts-with("[^")
    and tail.match(regex("^\\s*([-*+]|\\d+[.)])\\s")) == none)
  let render(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)
  if keep {
    render(text-md.slice(0, cut))
    block(breakable: false, above: 0pt, below: 0pt, { render(tail); signature-block(meta) })
  } else {
    render(text-md)
    signature-block(meta)
  }
  certificate-of-service(meta)
}
