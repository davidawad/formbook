// U.S. District Court, Eastern District of Kentucky: memorandum in support of a motion (Fed. R. Civ. P.
// 12(b)), with optional certificate of service.
//
// Rule-driven and content-agnostic. Requirement IDs (KYED-...) refer to ../README.md, which quotes the
// rule text (E.D. Ky. LR 5.2(a), 7.1; Fed. R. Civ. P. 5(d)(1)(B), 7(b), 12(b)). No case-specific text,
// no coordinates measured off the exemplar, no forced line breaks. The body is markdown rendered by
// cmarker; the caption, signature and certificate come from the YAML frontmatter of the same file.

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // KYED-FORM-002: proportionally spaced font; Times New Roman (vendored) per docs/FONTS.md
#let type-size = 12pt                   // KYED-FORM-002: at least 12-point type, footnotes included.
#let margin-all = 1in                   // KYED-FORM-001: at least one inch on all sides.
#let footer-distance = 0.5in            // the page number's line box ends half an inch above the page edge (Word's footer distance)
#let para-indent = 0.5in                // first-line indent of body paragraphs.
#let heading-step = 0.5in               // headings 2 to 4: each level half an inch further in, the text hanging this much
#let quote-indent = 0.75in              // a block quotation's indent on both sides
#let versus-indent = 1.2in              // "v." between the parties
#let designation-pad = 0.3in            // a party's designation, right-aligned this far in from the margin
#let rule-stroke = 0.75pt               // the caption's rules above and below the parties (docx: w:sz 6)
#let sig-indent = 3.4in                 // KYED-SIG-001: the signature block's column, the right 3.1 in of the page

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/kyed-motion-brief.lua sets the same twips,
// 20 x pt).
#let pitch-body = 24pt                  // KYED-FORM-001: text double spaced; body text and level-1 headings
#let pitch-single = 13.8pt              // KYED-FORM-001: headings, block quotes and footnotes single spaced; caption, signature
#let court-below = 24pt                 // the court title to the case number
#let rule-space = 12pt                  // the caption's rules to the text inside and outside them
#let desig-above = 6pt                  // a party's names to its designation
#let versus-space = 12pt                // above and below "v."
#let title-above = 24pt                 // the caption to the title of the paper
#let title-below = 12pt                 // the title to the text
#let heading-space = 12pt               // above and below a heading of levels 2 to 4
#let quote-space = 12pt                 // above and below a block quotation
#let note-gap = 4pt                     // between two footnotes
#let note-clearance = 12pt              // the body text to the footnote rule
#let sig-above = 24pt                   // the last paragraph to the signature block
#let sig-gap = 12pt                     // between the groups of the signature block
#let cert-text-below = 12pt             // certificate: its text to the first service block
#let service-gap = 9pt                  // certificate: between two service blocks

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
  if key not in meta { panic("kyed-motion-brief: missing required frontmatter field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("kyed-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One line paragraph (single pitch where the caller sets it), with an explicit space above it.
#let sline(above: 0pt, left: 0pt, right: 0pt, align-to: left, c) = block(width: 100%, above: above, below: 0pt,
  align(align-to, pad(left: left, right: right, par(first-line-indent: 0pt, unloose(c)))))

// ---------------------------------------------------------------------------
// First page: court title, caption, title of the paper (KYED-FIRST-001, KYED-FIRST-002)
// ---------------------------------------------------------------------------

/// Court title, centered and bold, one line per entry in the frontmatter `court` list.
#let court-title(meta) = for l in need(meta, "court") { sline(align-to: center, strong(upper(l))) }

/// The case number centered above the caption; the parties between two rules (docx: paragraph borders): each
/// party's names, then its designation right-aligned, "v." between the parties.
#let caption(meta) = {
  let label = meta.at("case_label", default: "Civil Action No.")
  sline(above: court-below, align-to: center)[#label #need(meta, "case_number")]
  block(width: 100%, above: rule-space, below: 0pt, stroke: (top: rule-stroke, bottom: rule-stroke),
    inset: (top: rule-space, bottom: rule-space),
    for (i, p) in need(meta, "caption").enumerate() {
      if i > 0 { sline(above: versus-space, left: versus-indent)[v.] }
      for (j, n) in p.names.enumerate() { sline(above: if i > 0 and j == 0 { versus-space } else { 0pt }, inl(n)) }
      // right-aligned without typst's hanging punctuation ("Plaintiff,"), as Word sets it
      if p.designation != "" { sline(above: desig-above, right: designation-pad, align-to: right, text(overhang: false, inl(p.designation))) }
    })
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// Headings, typed by the author with their own numbers ("I.", "A.", "1.", "a."). Level 1: centered bold capitals on
/// the body pitch with no space of its own. Levels 2 to 4: single spaced, bold (4 bold italic), half an inch further
/// in per level below 2, the text hanging half an inch, heading-space above and below. Sticky, so a heading never
/// ends a page.
#let heading-block(level, t) = if level == 1 {
  block(width: 100%, above: 0pt, below: 0pt, sticky: true,
    align(center, par(first-line-indent: 0pt, strong(upper(unloose(inl(t)))))))
} else {
  // an author's number "1." is text, not a list item, to cmarker
  let body = strong(unloose(inl(t.replace(regex("^(\\d+)\\."), m => m.captures.at(0) + "\\."))))
  block(width: 100%, above: heading-space, below: heading-space, sticky: true, {
    set text(..edges(pitch-single))
    pad(left: heading-step * (calc.min(level, 4) - 2),
      par(first-line-indent: 0pt, hanging-indent: heading-step, if level >= 4 { emph(body) } else { body }))
  })
}

/// A body paragraph at the body pitch, its first line indented half an inch.
#let body-par(c, sticky: false, note: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: sticky, {
  // a paragraph that anchors a footnote has no widow or orphan control (docx: the "Note" styles), as Word and LaTeX
  // do not keep its lines together against the note
  set text(costs: (widow: 0%, orphan: 0%)) if note
  par(unloose(c))
})

/// The footnote definitions of the body ("[^n]: text"), one string each. They are appended to the chunk that refers to
/// them, because cmarker resolves a reference only against the definitions in the same string.
#let footnote-definitions(body) = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c.starts-with("[^"))

/// The memorandum in document order: headings, paragraphs, block quotations. The conclusion's paragraphs keep with
/// what follows them, so the conclusion stays with the signature block (KYED-SIG-001).
#let body-flow(body) = {
  let defs = footnote-definitions(body)
  // the definitions of the notes this chunk refers to (an unreferenced definition would print as a block)
  let with-notes(t) = {
    let refs = t.matches(regex("\\[\\^([^\\]]+)\\]")).map(m => m.captures.at(0))
    let own = defs.filter(d => refs.any(r => d.starts-with("[^" + r + "]:")))
    if own.len() == 0 { t } else { t + "\n\n" + own.join("\n\n") }
  }
  let in-conclusion = false
  for chunk in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "") {
    let t = chunk.trim()
    if t.starts-with("[^") {
      // A footnote definition is rendered with the paragraph that refers to it.
    } else if t.starts-with("#") {
      let m = t.match(regex("^(#+)[ \\t]+([\\s\\S]*)$"))
      let level = m.captures.at(0).len()
      if level == 1 { in-conclusion = upper(m.captures.at(1).trim()) == "CONCLUSION" }
      heading-block(level, m.captures.at(1))
    } else if t.starts-with(">") {
      block(width: 100%, above: quote-space, below: quote-space, sticky: in-conclusion, pad(x: quote-indent, {
        set text(..edges(pitch-single))
        par(first-line-indent: 0pt, unloose(inl(with-notes(t.replace(regex("(?m)^>[ \t]?"), "")))))
      }))
    } else {
      body-par(inl(with-notes(t)), sticky: in-conclusion, note: t.contains("[^"))
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (KYED-SIG-001) and certificate of service (KYED-SIG-002)
// ---------------------------------------------------------------------------

/// "Dated:" at the margin and "Respectfully submitted," in the right column (docx: a tab at the signature indent),
/// then the preamble, the signature line and the signer's lines, single spaced and kept on one page.
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, above: sig-above, below: 0pt, breakable: false, {
    set text(..edges(pitch-single))
    sline[#box(width: sig-indent)[Dated: #need(meta, "date")]Respectfully submitted,]
    for (i, l) in sig.at("preamble", default: ()).enumerate() {
      sline(above: if i == 0 { sig-gap } else { 0pt }, left: sig-indent, inl(l))
    }
    sline(above: sig-gap, left: sig-indent, inl(sig.sign_line))
    for l in sig.at("lines", default: ()) { sline(left: sig-indent, inl(l)) }
  })
}

/// Optional certificate of service: starts on a new page, as the exemplar does. Not required here:
/// Fed. R. Civ. P. 5(d)(1)(B) says none is needed for a paper served through the court's e-filing
/// system, so the sample supplies it only because the exemplar carries one.
#let certificate-block(meta) = {
  let c = meta.at("certificate", default: none)
  if c == none { return }
  pagebreak(weak: true)
  block(width: 100%, above: 0pt, below: 0pt, sticky: true,
    align(center, par(first-line-indent: 0pt, strong[CERTIFICATE OF SERVICE])))
  body-par(inl(c.text))
  set text(..edges(pitch-single))
  for (i, s) in c.services.enumerate() {
    block(width: 100%, breakable: false, above: if i == 0 { cert-text-below } else { service-gap }, below: 0pt,
      for l in s { sline(inl(l)) })
  }
  block(width: 100%, breakable: false, above: sig-above, below: 0pt, {
    sline(left: sig-indent, inl(c.sign_line))
    sline(left: sig-indent, inl(c.designation))
  })
}

// ---------------------------------------------------------------------------
// The memorandum
// ---------------------------------------------------------------------------

#let kyed-motion-brief(meta, md) = {
  for k in ("court", "caption", "case_number", "title", "date", "signature") {
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
  // body pitch, footnote marks at 58 %, a section sign kept with its number.
  show: xengine.with(pitch: pitch-body, list-indent: none, )
  // A doubled sign stays with its number ("¶¶ 133-134"): xengine binds one sign, and typst would break between two.
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // Footnotes: single spaced at the form size (KYED-FORM-002), the mark and a space before the text.
  set footnote.entry(separator: line(length: 30%, stroke: 0.5pt), gap: note-gap, clearance: note-clearance, indent: 0pt)
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    // a note is kept whole (docx: Footnote Text keeps its lines together): typst would start a long note on the page
    // before its reference's line
    block(breakable: false, [#super(num)#h(0.25em)#note.body])
  }

  // ---- first page ----
  {
    set text(..edges(pitch-single))
    court-title(meta)
    caption(meta)
    sline(above: title-above, align-to: center, strong(upper(need(meta, "title"))))
  }
  v(title-below, weak: false)

  // ---- body (the memorandum text, rendered from markdown) ----
  body-flow(md)
  signature-block(meta)
  certificate-block(meta)
}
