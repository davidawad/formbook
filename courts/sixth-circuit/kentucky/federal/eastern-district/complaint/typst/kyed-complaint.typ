// U.S. District Court, Eastern District of Kentucky: complaint.
//
// Rule-driven and content-agnostic. Requirement IDs (KYED-...) refer to ../README.md, which quotes the
// rule text (Fed. R. Civ. P. 8(a), 10(a), 10(b); E.D. Ky. LR 5.2(a)). No case-specific text, no
// coordinates measured off the exemplar, no forced line breaks. The body is markdown rendered by
// cmarker; the caption, signature and metadata come from the YAML frontmatter of the same file.

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // KYED-FORM-002: proportionally spaced font; Times New Roman (vendored) per docs/FONTS.md
#let type-size = 12pt                   // KYED-FORM-002: at least 12-point type.
#let margin-all = 1in                   // KYED-FORM-001: at least one inch on all sides.
#let text-width = 8.5in - 2 * margin-all
#let footer-distance = 0.5in            // the page number's line box ends half an inch above the page edge (Word's footer distance)
#let para-indent = 0.5in                // first-line indent; a numbered paragraph's number starts here
#let number-box = 0.5in                 // the paragraph number's box: the text starts 1 in from the margin (docx: a tab)
#let letter-box = 0.5in                 // a lettered item's label box after the indent, the text hanging after it
#let quote-indent = 0.75in              // a block quotation's indent on both sides
#let caption-right = 2.4in              // the caption's right column (JURY DEMAND)
#let caption-gutter = 0.25in            // between the party column and the right column
#let versus-indent = 1.2in              // "v." between the parties
#let designation-pad = 0.3in            // a party's designation, right-aligned this far in from the column's edge
#let rule-stroke = 0.75pt               // the caption's rules above and below the parties (docx: w:sz 6)
#let sig-indent = 3.4in                 // KYED-SIG-001: the signature block's column, the right 3.1 in of the page

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/kyed-complaint.lua sets the same twips, 20 x pt).
#let pitch-body = 24pt                  // KYED-FORM-001: text double spaced; body, headings, lettered items
#let pitch-single = 13.8pt              // KYED-FORM-001: headings aside, block quotes and the caption single spaced
#let court-below = 24pt                 // the court title to the civil action number
#let rule-space = 12pt                  // the caption's rules to the text inside and outside them
#let desig-above = 6pt                  // a party's names to its designation
#let versus-space = 12pt                // above and below "v."
#let title-above = 24pt                 // the caption to the title of the paper
#let title-below = 12pt                 // the title to the text
#let quote-space = 12pt                 // above and below a block quotation
#let sig-above = 24pt                   // the last paragraph to the signature block
#let sig-gap = 12pt                     // between the groups of the signature block

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Inline markdown (italics, bold, etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// Inline content without the paragraph breaks cmarker may put around it.
#let unloose(body) = {
  if type(body) != content or body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

#let need(meta, key) = {
  if key not in meta { panic("kyed-complaint: missing required frontmatter field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("kyed-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One line paragraph (single pitch where the caller sets it), with an explicit space above it.
#let sline(above: 0pt, left: 0pt, right: 0pt, align-to: left, c) = block(width: 100%, above: above, below: 0pt,
  align(align-to, pad(left: left, right: right, par(first-line-indent: 0pt, unloose(c)))))

// ---------------------------------------------------------------------------
// Caption (KYED-FIRST-001, KYED-FIRST-002)
// ---------------------------------------------------------------------------

/// Court title, centered and bold, one line per entry in the frontmatter `court` list.
#let court-title(meta) = for l in need(meta, "court") { sline(align-to: center, strong(upper(l))) }

/// Parties: each party's names, then its designation right-aligned; "v." between the parties.
#let party-column(meta) = for (i, p) in need(meta, "caption").enumerate() {
  if i > 0 { sline(above: versus-space, left: versus-indent)[v.] }
  for (j, n) in p.names.enumerate() { sline(above: if i > 0 and j == 0 { versus-space } else { 0pt }, inl(n)) }
  if p.designation != "" { sline(above: desig-above, right: designation-pad, align-to: right, inl(p.designation)) }
}

/// The civil action number and the e-filing legend centered above the caption; the parties and, on the right,
/// JURY DEMAND between two rules (docx: a table row with a top and a bottom border).
#let caption(meta) = {
  sline(above: court-below, align-to: center)[Civil Action No. #need(meta, "case_number")]
  if meta.at("electronically_filed", default: false) == true { sline(align-to: center)[ELECTRONICALLY FILED] }
  block(width: 100%, above: rule-space, below: 0pt, stroke: (top: rule-stroke, bottom: rule-stroke),
    inset: (top: rule-space, bottom: rule-space),
    grid(
      columns: (text-width - caption-right - caption-gutter, caption-gutter, caption-right),
      party-column(meta),
      [],
      if meta.at("jury_demand", default: false) == true { sline[JURY DEMAND] },
    ))
}

// ---------------------------------------------------------------------------
// Body (KYED-CONT-001: numbered paragraphs, KYED-CONT-002: lettered lists)
// ---------------------------------------------------------------------------

/// Heading levels, on the body pitch with no space of their own: 1 centered bold capitals (a section), 2 centered
/// bold (a count), 3 bold at the margin. Sticky, so a heading never ends a page.
#let heading-block(level, t) = block(above: 0pt, below: 0pt, width: 100%, sticky: true, {
  set align(center) if level <= 2
  par(first-line-indent: 0pt, strong(if level == 1 { upper(unloose(inl(t))) } else { unloose(inl(t)) }))
})

/// A body paragraph at the body pitch, its first line indented half an inch.
#let body-par(c, sticky: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: sticky, par(unloose(c)))

/// A numbered paragraph (Fed. R. Civ. P. 10(b)): the template numbers, the sample does not.
#let numbered-para(t, c, sticky: false) = {
  c.step()
  body-par(sticky: sticky)[#box(width: number-box, context [#c.display().])#unloose(inl(t))]
}

/// A lettered item (a), (b), ...: the label in its box after the indent, the text hanging after it.
#let lettered-item(i, t, sticky: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: sticky,
  par(first-line-indent: 0pt, hanging-indent: para-indent + letter-box,
    [#h(para-indent)#box(width: letter-box, "(" + numbering("a", i) + ")")#unloose(inl(t))]))

// Markdown marker for an unnumbered paragraph (the opening sentence, the WHEREFORE lead-in, the jury demand).
#let unnumbered-marker = "~ "

/// Numbered paragraphs (Fed. R. Civ. P. 10(b)). Each blank-line-separated chunk of markdown is one unit: a heading,
/// a list, a block quote (`> `), an unnumbered paragraph (`~ `), or a numbered paragraph. The last one keeps with the
/// signature block after it (docx: keep with next), so the signature never stands on a page alone.
#let body-flow(body) = {
  let para-counter = counter("allegation")
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for (k, chunk) in chunks.enumerate() {
    let t = chunk.trim()
    let last = k == chunks.len() - 1
    if t.starts-with("#") {
      let m = t.match(regex("^(#+)[ \\t]+([\\s\\S]*)$"))
      heading-block(m.captures.at(0).len(), m.captures.at(1))
    } else if t.match(regex("^\\d+\\.[ \\t]")) != none {
      let items = t.split(regex("(?m)^\\d+\\.[ \\t]+")).map(s => s.trim()).filter(s => s != "")
      for (i, item) in items.enumerate() { lettered-item(i + 1, item, sticky: last and i == items.len() - 1) }
    } else if t.starts-with(">") {
      // A block quotation: single spaced, indented both sides, not numbered (the quoted policy clause).
      block(width: 100%, above: quote-space, below: quote-space, sticky: last, pad(x: quote-indent, {
        set text(..edges(pitch-single))
        par(first-line-indent: 0pt, unloose(inl(t.replace(regex("(?m)^>[ \t]?"), ""))))
      }))
    } else if t.starts-with(unnumbered-marker) {
      body-par(inl(t.slice(unnumbered-marker.len()).trim()), sticky: last)
    } else {
      numbered-para(t, para-counter, sticky: last)
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (KYED-SIG-001: Fed. R. Civ. P. 11(a) name, address, phone, email, bar number)
// ---------------------------------------------------------------------------

/// Single spaced in the right column, kept on one page: "Respectfully submitted,", the preamble (the firm), the s/
/// line and the signer's lines.
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, above: sig-above, below: 0pt, breakable: false, {
    set text(..edges(pitch-single))
    sline(left: sig-indent)[Respectfully submitted,]
    for (i, l) in sig.at("preamble", default: ()).enumerate() {
      sline(above: if i == 0 { sig-gap } else { 0pt }, left: sig-indent, inl(l))
    }
    sline(above: sig-gap, left: sig-indent)[s/#sig.signer]
    for l in sig.at("lines", default: ()) { sline(left: sig-indent, inl(l)) }
  })
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let kyed-complaint(meta, md) = {
  for k in ("court", "caption", "case_number", "title", "signature") {
    let _ = need(meta, k)
  }

  set page(
    paper: "us-letter",
    margin: margin-all,
    // the page number in a single-pitch line box that ends footer-distance above the page edge (Word: the footer
    // distance)
    footer-descent: margin-all - footer-distance - pitch-single,
    footer: context align(center, text(size: type-size, ..edges(pitch-single), counter(page).display())),
  )
  set document(title: need(meta, "title") + ", No. " + str(need(meta, "case_number")))
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  // Every body paragraph opens with the half-inch indent (after a heading too).
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch. Lettered items are laid out here (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)

  // ---- first page: court title, caption, title of the paper ----
  {
    set text(..edges(pitch-single))
    court-title(meta)
    caption(meta)
    sline(above: title-above, align-to: center, strong(upper(need(meta, "title"))))
  }
  v(title-below, weak: false)

  // ---- body ----
  body-flow(md)

  signature-block(meta)
}
