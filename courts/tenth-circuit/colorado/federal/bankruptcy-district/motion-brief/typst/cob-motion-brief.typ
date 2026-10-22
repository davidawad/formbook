// United States Bankruptcy Court, District of Colorado: motion with memorandum (FRBP 9013).
//
// Rule-driven and content-agnostic. Requirement IDs (COB-...) refer to ../README.md and ../../rules.md, which quote
// the rule text. No case-specific text, no coordinates measured off the exemplar, no forced line breaks. The markdown
// body is split into blank-line blocks here (headings, block quotations, paragraphs with their footnotes); the
// metadata comes from the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")    // COB-FORM-002: no LBR names a face; Times New Roman, the house standard (vendored metric twin)
#let type-size = 12pt                    // COB-FORM-002: no LBR sets a size; 12 point, the D.C.COLO.LCivR 10.1 proxy (README), footnotes included.
#let margin-top = 1.5in                  // proxy D.C.COLO.LCivR 10.1: 1.5 in top, 1 in elsewhere (README).
#let margin-other = 1in
#let para-indent = 0.5in                 // first-line indent of body paragraphs
#let heading-tab = 0.5in                 // a numbered heading's label in a box of this width, the title hanging after it;
                                         // each level below 2 this much further in
#let quote-indent = 0.5in                // block quotations: this far in on both sides
#let caption-right = 2.6in               // the caption's case column
#let caption-gutter = 0.3in              // between the party column and the case column
#let name-indent = 0.4in                 // the debtor's names under "IN RE:"
#let designation-indent = 0.8in          // "Debtor.", "Plaintiff,", "Defendants." under the names
#let signature-column = 3.2in            // the signature column at the right; "Dated:" at the left margin
#let note-gap = 7pt                      // between two footnotes (Word: Footnote Text's space after)
#let note-clearance = 7.5pt              // from the text to the footnote rule (the space LibreOffice keeps above it)
#let footer-size = 11pt                  // the page number

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt                 // proxy D.C.COLO.LCivR 10.1: double spacing (2 x 12 pt)
#let pitch-single = 13.8pt               // single spacing (1.15 x 12 pt): court title, caption, title, headings,
                                         // quotations, footnotes, signature, page number

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Block markdown: a paragraph with the footnote definitions folded into it.
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

#let need(meta, key) = {
  if key not in meta { panic("cob-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("cob-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it. An empty line keeps
/// its height.
#let line-block(above: 0pt, below: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: below,
  height: if body == "" or body == [] { pitch-single } else { auto }, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: left, if type(body) == str { inl(body) } else { body })
})

// ---------------------------------------------------------------------------
// Caption (COB-RULE-004, -005: FRBP 9004(b), FRBP 7010 for adversary proceedings)
// ---------------------------------------------------------------------------

/// A caption block, never split: the party column at the left, the case column beside it.
#let caption-block(above, left, right) = block(width: 100%, above: above, below: 0pt, breakable: false,
  grid(columns: (1fr, caption-right), column-gutter: caption-gutter, left.join(), right.join()))

/// The court title, a single line below it the debtor block, a single line below that the adversary block (a motion
/// filed in an adversary proceeding), and the title of the paper a single line above and below.
#let caption(meta) = {
  for l in need(meta, "court") { line-block(align(center, strong(upper(inl(l))))) }

  // Debtor block: the bankruptcy case (FRBP 9004(b)(3)).
  let debtor = need(meta, "debtor")
  let left = (line-block[IN RE:], line-block(""))
  for n in debtor.names { left.push(line-block(left: name-indent, n)) }
  left += (line-block(""), line-block(left: designation-indent, debtor.at("designation", default: "Debtor.")))
  let right = (line-block[Case No. #debtor.case_number],)
  if "chapter" in debtor { right.push(line-block(debtor.chapter)) }
  caption-block(pitch-single, left, right)

  // Adversary block: each side's names and designation, a blank line between the sides.
  if "adversary" in meta {
    let adv = meta.adversary
    let left = ()
    for (i, side) in adv.parties.enumerate() {
      if i > 0 { left.push(line-block("")) }
      for n in side.names { left.push(line-block(n)) }
      left.push(line-block(left: designation-indent, side.designation))
    }
    caption-block(pitch-single, left, (line-block[Adv. Proc. No. #adv.case_number],))
  }

  // The title of the paper (FRBP 9004(b)(4)): bold, centered.
  line-block(above: pitch-single, below: pitch-single, align(center, strong(inl(need(meta, "title")))))
}

// ---------------------------------------------------------------------------
// Body: headings, paragraphs, quotations
// ---------------------------------------------------------------------------

/// Printed label of a numbered heading: level 2 "I.", level 3 "A.", level 4 "1.". Level 1 is unnumbered.
#let heading-label(level, k) = if level == 2 { numbering("I.", k) } else if level == 3 { numbering("A.", k) } else {
  numbering("1.", k) }

/// A heading, single-spaced, a single line above and below it, sticky so it never ends a page: level 1 centered bold
/// capitals; level 2 and deeper bold, the label in a box of heading-tab (each level a heading-tab further in), the
/// title hanging after it.
#let heading-block(level, c, label) = block(width: 100%, above: pitch-single, below: pitch-single, sticky: true, {
  set text(..edges(pitch-single))
  if level == 1 {
    set par(first-line-indent: 0pt)
    align(center, strong(upper(inl(c))))
  } else {
    pad(left: (level - 2) * heading-tab, par(first-line-indent: 0pt, hanging-indent: heading-tab,
      strong[#box(width: heading-tab, label)#inl(c)]))
  }
})

/// The body in order. A footnote definition (`[^n]: ...`, anywhere in the body) belongs to the paragraph that refers
/// to it: each chunk is rendered by its own cmarker call, so the definition is folded into the chunk that holds the
/// reference. The last block is kept whole with the signature block.
#let argument(body) = {
  let all = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let defs = all.filter(c => c.starts-with("[^"))
  let chunks = ()
  for c in all.filter(c => not c.starts-with("[^")) {
    for d in defs {
      let ref = d.slice(0, d.position("]") + 1)
      if c.contains(ref) { c += "\n\n" + d }
    }
    chunks.push(c)
  }
  let counts = (0, 0, 0, 0, 0)
  for (k, t) in chunks.enumerate() {
    let keep = k == chunks.len() - 1
    let h = t.match(regex("^(#+)\\s+(.*)$"))
    if h != none {
      let level = calc.min(h.captures.at(0).len(), 4)
      counts.at(level) += 1
      for j in range(level + 1, 5) { counts.at(j) = 0 }
      heading-block(level, h.captures.at(1), if level > 1 { heading-label(level, counts.at(level)) } else { none })
    } else if t.starts-with(">") {
      // Single-spaced, indented both sides, a single line above and below; one quoted paragraph.
      block(width: 100%, above: pitch-single, below: pitch-single, sticky: keep, breakable: not keep,
        pad(left: quote-indent, right: quote-indent, {
          set text(..edges(pitch-single))
          par(first-line-indent: 0pt, inl(t.split("\n").map(l => l.trim(">", at: start).trim()).join(" ")))
        }))
    } else if keep {
      block(width: 100%, above: 0pt, below: 0pt, sticky: true, breakable: false, [#md(t)#parbreak()])
    } else {
      // Not a block: inside a block, typst places a footnote on a later page than its reference. The paragraph break
      // ends it (each chunk is its own paragraph; without the break typst runs two chunks into one).
      [#md(t)#parbreak()]
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (COB-CERT-003: FRBP 9011(a), LBR 9011-4) and certificate of service (FRBP 9013(b))
// ---------------------------------------------------------------------------

/// "Dated:" at the left margin and, in a column at the right, "Respectfully submitted,", the firm, the "/s/" line and
/// the signer's lines, a blank line between the groups; single-spaced.
#let dated-column(date, right) = grid(columns: (1fr, signature-column), line-block("Dated: " + str(date)),
  right.join())

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  let right = (line-block[Respectfully submitted,], line-block(""))
  let firm = sig.at("firm", default: ())
  for l in firm { right.push(line-block(l)) }
  if firm.len() > 0 { right.push(line-block("")) }
  right.push(line-block("/s/ " + sig.signer))
  for l in sig.at("lines", default: ()) { right.push(line-block(l)) }
  block(width: 100%, above: pitch-double, below: 0pt, breakable: false,
    dated-column(need(meta, "date"), right))
}

/// A double line below the signature: the heading, a single line below it the certificate at the body pitch, a single
/// line below that the date and the "/s/" line; never split.
#let certificate(cert) = block(width: 100%, above: pitch-double, below: 0pt, breakable: false, {
  line-block(below: pitch-single, align(center, strong[CERTIFICATE OF SERVICE]))
  block(width: 100%, above: 0pt, below: pitch-single, par(first-line-indent: (amount: para-indent, all: true),
    inl(cert.text)))
  dated-column(cert.date, (line-block("/s/ " + cert.signer),))
})

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

#let cob-motion-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "debtor", "title", "signature", "date") {
    let _ = need(meta, k)
  }

  // Pages numbered at the foot, centered, in a single line box, where Word's footer sets it.
  set page(paper: "us-letter", margin: (top: margin-top, bottom: margin-other, x: margin-other),
    footer-descent: 30%,
    footer: context align(center, text(size: footer-size, ..edges(pitch-single), counter(page).display("1"))))
  set document(title: need(meta, "title"), author: need(meta, "signature").signer)
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (double spacing).
  show: xengine.with(pitch: pitch-double, list-indent: none)
  // A doubled section sign stays with its number (xengine binds a single sign), as the docx filter binds it.
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // Footnotes at the text size, single lines, under a 30 % rule, 7 pt between notes; the mark and a space before the
  // text (Word's footnote).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  // Caption and title on page 1; the memorandum continues on the same pages.
  caption(meta)
  argument(md)
  signature-block(meta)
  if "certificate" in meta { certificate(meta.certificate) }
}
