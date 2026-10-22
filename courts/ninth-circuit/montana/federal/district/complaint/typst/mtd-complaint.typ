// U.S. District Court, District of Montana: complaint.
//
// Rule-driven and content-agnostic. Rule IDs (MT-...) refer to ../README.md, which quotes the rule
// text: D. Mont. L.R. 1.5 (form of documents), 3.1 (filing a new case), 38.1 (jury demand); Fed. R.
// Civ. P. 8, 10 and 11. No case-specific text, no coordinates measured off the exemplar, no forced
// line breaks. The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter
// of the same file (schema: ../README.md).
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // MT-FONT-001: the rules name no face; Times New Roman, the house face (docs/FONTS.md), metric-compatible substitute vendored in /fonts
#let type-size = 14pt                   // MT-FORM-002: typewritten in 14-point font (L.R. 1.5(a)(2)), footnotes included
#let margin = 1in                       // MT-FORM-001 (L.R. 1.5(a)(1)): one-inch margins
#let para-indent = 0.5in                // first-line indent of paragraphs; the paragraph number's box after it
#let caption-left = 3.4in               // width of the party column of the caption
#let caption-pad = 0.2in                // the caption's text keeps this far from its rule
#let designation-indent = 1.4in         // a party's designation stands this far in
#let counsel-gutter = 0.3in             // between the two columns of counsel
#let sig-left = 3.4in                   // the signature grid: the date column, then the signature column

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 16pt                // a single line at 14 pt (counsel, court title, caption, signature, footnotes)
#let pitch-double = 2 * pitch-single    // MT-FORM-003 (L.R. 1.5(a)(2)): double-spaced
#let gap-half = pitch-single            // half a double line: between counsel groups, around "v.", before a designation
#let note-gap = 7pt                     // between two footnotes
#let note-clearance = 3.5pt             // from the last text line to the separator (with note-gap, the space LibreOffice keeps)

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mtd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, italic role lines, etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

#let need(meta, key) = {
  if key not in meta { panic("mtd-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: below,
  pad(left: left, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    body
  }))

// ---------------------------------------------------------------------------
// Cover: counsel block (upper left), court title, caption, title of the paper (Appendix C, Form A)
// ---------------------------------------------------------------------------

/// Where the counsel groups split into two columns: the first `k` groups on the left, so that the taller column
/// has as few lines as possible (the first such split). One group stands in the left column alone.
#let counsel-split(groups) = {
  let n = groups.len()
  if n < 2 { return n }
  let lines(gs) = gs.map(g => g.len()).sum(default: 0) + calc.max(gs.len() - 1, 0)
  let best = 1
  for k in range(1, n) {
    if calc.max(lines(groups.slice(0, k)), lines(groups.slice(k))) < calc.max(lines(groups.slice(0, best)), lines(groups.slice(best))) {
      best = k
    }
  }
  best
}

#let counsel-column(groups) = for (i, g) in groups.enumerate() {
  for (j, l) in g.enumerate() { line-block(above: if i > 0 and j == 0 { gap-half } else { 0pt }, inl(l)) }
}

/// The counsel groups in two columns, the role (italic) at the foot of the left column, half a double line below it.
#let counsel-block(meta) = {
  let groups = need(meta, "counsel")
  let k = counsel-split(groups)
  block(width: 100%, above: 0pt, below: 0pt, grid(
    columns: (1fr, 1fr), column-gutter: counsel-gutter,
    {
      counsel-column(groups.slice(0, k))
      line-block(above: gap-half, emph(inl(need(meta, "counsel_role"))))
    },
    counsel-column(groups.slice(k)),
  ))
}

/// One centred line each: the court, the district, the division (Appendix C, Form A; MT-DIV-001).
#let court-title(meta) = {
  let lines = ("IN THE UNITED STATES DISTRICT COURT", "FOR THE DISTRICT OF MONTANA", upper(need(meta, "division")))
  for (i, l) in lines.enumerate() { line-block(above: if i == 0 { pitch-double } else { 0pt }, align(center, strong(l))) }
}

#let caption-table(meta) = {
  let sides = need(meta, "caption")
  let case-no = need(meta, "case_number")
  block(width: 100%, above: gap-half, below: 0pt, grid(
    columns: (caption-left, 1fr),
    stroke: (x, y) => if x == 0 { (right: 0.75pt, bottom: 0.75pt) } else { none },
    pad(right: caption-pad, bottom: gap-half, {
      for (i, side) in sides.enumerate() {
        if i > 0 { line-block(above: gap-half, below: gap-half)[v.] }
        for n in side.names { line-block(inl(n)) }
        line-block(above: gap-half, left: designation-indent, inl(side.designation))
      }
    }),
    pad(left: caption-pad, {
      // An empty case number leaves a blank for the clerk.
      line-block[Case No. #if case-no == "" { "_" * 14 } else { case-no }]
      line-block(above: pitch-double, strong(upper(inl(need(meta, "title")))))
    }),
  ))
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs, headings, lettered prayer, signature
// ---------------------------------------------------------------------------

/// Signature block: the date, the firm, and "/s/" over the printed name (L.R. 1.5(b), 11.1).
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  let right = ()
  if "firm" in sig { right.push(line-block(strong(upper(inl(sig.firm))))) }
  right.push(line-block(above: if "firm" in sig { pitch-double } else { 0pt })[/s/ #sig.signer])
  right.push(line-block(inl(sig.signer)))
  for l in sig.at("lines", default: ()) { right.push(line-block(inl(l))) }
  block(width: 100%, breakable: false, above: pitch-double, below: 0pt, grid(
    columns: (sig-left, 1fr),
    line-block[DATED: #need(meta, "date")],
    right.join(),
  ))
}

/// A body paragraph at the double pitch, first line indented: unnumbered, or numbered (the label in a box of the
/// paragraph indent after the first-line indent, then the text).
#let body-par(label, content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true),
    if label == none { content } else { [#box(width: para-indent, label)#content] }))

/// Numbered paragraphs (Fed. R. Civ. P. 10(b)). Each blank-line-separated chunk of markdown that is neither a
/// heading nor a list is one numbered paragraph; the template numbers them, so the author types no numbers.
/// Headings and lists are not numbered; a chunk that starts with "~ " is printed unnumbered (the prayer's
/// lead-in, the jury demand). Numbering is applied per chunk, not with a `show par` rule (a show rule that
/// re-wraps paragraph content recurses without end in typst 0.15). Returns the blocks, in order.
#let chunks(body) = {
  let cs = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // A footnote definition is not a paragraph of its own: its text is printed at the reference. cmarker binds a
  // reference only to a definition in the same call, so every chunk that holds a reference is rendered with all
  // the definitions.
  let defs = cs.map(c => c.trim()).filter(t => t.starts-with("[^")).join("\n\n")
  let with-notes(t) = if defs != none and t.contains("[^") { t + "\n\n" + defs } else { t }
  let n = 0
  let out = ()
  for c in cs {
    let t = c.trim()
    if t.starts-with("[^") {
      continue
    } else if t.starts-with("#") {
      out.push(md(t))
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // The prayer's items, lettered A., B., ... as the paragraphs are numbered.
      let items = t.split(regex("(?m)^(\\d+\\.|[-*+])[ \\t]+")).filter(s => s.trim() != "")
      for (i, it) in items.enumerate() {
        out.push(body-par(numbering("A.", i + 1), inl(with-notes(it.trim().replace(regex("\\s*\\n\\s*"), " ")))))
      }
    } else if t.starts-with("~ ") {
      out.push(body-par(none, inl(with-notes(t.slice(2).trim()))))
    } else {
      n += 1
      out.push(body-par([#n.], inl(with-notes(t))))
    }
  }
  out
}

#let mtd-complaint(meta, body) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "division", "counsel", "counsel_role", "caption", "title", "signature", "date") {
    let _ = need(meta, k)
  }
  // L.R. 38.1: a pleading that incorporates a jury demand must say so in its title.
  if meta.at("jury_demand", default: false) {
    assert(upper(meta.title).contains("JURY TRIAL"), message: "mtd-complaint: L.R. 38.1: the title must indicate the jury demand")
  }
  assert(need(meta, "caption").len() >= 2, message: "mtd-complaint: FRCP 10(a): the title must name all parties on both sides")

  // ---- document-wide settings ----
  // MT-FORM-004 (L.R. 1.5(a)(3)): consecutively numbered at the bottom of every page, the cover page 1, centered in
  // a single line box where Word's footer sets it.
  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set document(title: need(meta, "title"), author: need(meta, "signature").signer)
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (double-spaced).
  show: xengine.with(pitch: pitch-double, list-indent: none)
  // A doubled sign stays with its number too ("§§ 2201"; xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)

  // Footnotes (MT-FORM-002): 14 pt, single-spaced; the mark, a space, the note (Word's footnote).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 2in, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    [#super(num)#h(0.25em)#note.body]
  }

  // Headings at the body pitch, kept with the text after them: level 1 centered bold capitals; level 2 bold at the
  // margin; level 3 bold italic.
  show heading: it => block(sticky: true, width: 100%, above: 0pt, below: 0pt, {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    if it.level == 1 { align(center, strong(upper(it.body))) } else if it.level == 2 { strong(it.body) } else {
      strong(emph(it.body))
    }
  })

  // ---- cover (page 1): counsel, court, caption and title ----
  counsel-block(meta)
  court-title(meta)
  caption-table(meta)
  pagebreak()

  // The lead-in (FRCP 10(b) does not number it) is printed unnumbered before the numbered paragraphs.
  if "lead_in" in meta { body-par(none, inl(meta.lead_in)) }

  // The body, then the signature block. The last chunk (the jury demand) and the signature block stay on one page,
  // so a signature never stands alone at the top of a page.
  let cs = chunks(body)
  for c in cs.slice(0, -1) { c }
  block(width: 100%, breakable: false, above: 0pt, below: 0pt, { cs.last(); signature-block(meta) })
}
