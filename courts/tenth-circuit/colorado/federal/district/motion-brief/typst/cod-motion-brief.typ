// Motion to dismiss with its memorandum, for the U.S. District Court for the District of Colorado (cod).
// Rules: D.C.COLO.LCivR 10.1 (paper, margins, font, double spacing, one side); 7.1 (motions: separate document,
// the rule the motion is filed under, citations to page or subsection, concision; 7.1(a) and (b)(2) conferral
// exception for Rule 12 motions); 5.1(a) (CM/ECF format); Fed. R. Civ. P. 7(b)(1), 12(b)(6). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter and body, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Sans"   // no typeface rule in 10.1(d); matches the audited exemplar (Arial; docs/FONTS.md, data/exemplar-fonts.json)
#let type-size = 12pt                   // LCivR 10.1(d): not less than 12-point font, footnotes included
#let margin-top = 1.5in                 // LCivR 10.1(c): 1 1/2 inches at the top
#let margin-side = 1in                  // LCivR 10.1(c): 1 inch at the left and right
#let margin-bottom = 1in                // LCivR 10.1(c): 1 inch at the bottom
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let designation-indent = 0.5in         // a party's designation ("Plaintiff,") in the caption
#let heading-label = 0.5in              // headings below level 1: the label's box, the title hanging after it
#let quote-indent = 1in                 // block quotations: indented 1 inch on each side
#let service-indent = 0.5in             // the party lines of the certificate of service
#let signature-indent = 3in             // the signer and role lines stand this far from the left margin
#let note-gap = 7pt                     // between two footnotes (Word: Footnote Text's space after)
#let note-clearance = 7.5pt             // from the text to the footnote rule (the space LibreOffice keeps above it)

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt                // LCivR 10.1(e): double spaced, 2 x the type size
#let pitch-single = 13.8pt              // single spacing (caption, headings, quotations, footnotes, signature): 1.15 x

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("cod-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in italics, footnote references, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line block (a paragraph of its own), with explicit space above it. An empty line keeps its
/// height.
#let line-block(above: 0pt, indent: 0pt, body) = block(width: 100%, above: above, below: 0pt,
  height: if body == "" or body == [] { pitch-single } else { auto }, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: indent, if type(body) == str { inl(body) } else { body })
})

/// A paragraph at the double pitch, indented, as a block of its own (explicit space above it). `keep`: kept whole on
/// the page of the block after it.
#let body-block(content, above: 0pt, keep: false) = block(width: 100%, above: above, below: 0pt, sticky: keep,
  breakable: not keep, [#content#parbreak()])

/// A centered bold heading of the paper's own (a certificate), single-spaced, a single line above and below it,
/// sticky.
#let title-block(c, above: pitch-single) = block(width: 100%, above: above, below: pitch-single, sticky: true, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  align(center, strong(inl(c)))
})

// ---------------------------------------------------------------------------
// Caption (Fed. R. Civ. P. 10(a)): court, civil action number, parties, title of the paper. No separate cover
// page; pages are numbered in the footer, set in #cod-motion-brief below.
// ---------------------------------------------------------------------------

/// The court in two centered bold lines; a double line below them "Civil Action No." (a blank to fill in when the
/// sample has no number); a double line below that the parties: each party's names, a blank line and its designation
/// half an inch in, "v." between the parties with a blank line on each side; a double line below them the title,
/// centered and bold. Single lines; never split.
#let caption(meta) = block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
  line-block(align(center, strong[IN THE UNITED STATES DISTRICT COURT]))
  line-block(align(center, strong[FOR THE DISTRICT OF COLORADO]))
  let cn = meta.at("case_number", default: none)
  if cn == none or cn == "" { cn = "_" * 18 }
  line-block(above: pitch-double, [#("Civil Action No. " + cn)])   // text, not markdown (a run of underscores)
  for (k, p) in meta.caption.enumerate() {
    if k > 0 {
      line-block("")
      line-block[v.]
      line-block("")
    }
    for (j, n) in p.names.enumerate() { line-block(above: if k == 0 and j == 0 { pitch-double } else { 0pt }, n) }
    line-block("")
    line-block(indent: designation-indent, p.designation)
  }
  line-block(above: pitch-double, align(center, strong(inl(meta.title))))
})

// ---------------------------------------------------------------------------
// Body: headings, paragraphs, quotations, footnotes
// ---------------------------------------------------------------------------

/// A section heading, numbered by the template (level 1 "I.", 2 "A.", 3 "1.", 4 "a."), single-spaced, a single line
/// above and below it, sticky so it never ends a page: level 1 centered bold capitals; deeper levels bold, the label
/// in a half-inch box and the title hanging after it, level 2 at the margin and each level after it half an inch
/// further in.
#let heading-block(level, mark, c, above: pitch-single) = block(width: 100%, above: above, below: pitch-single,
  sticky: true, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if level == 1 { align(center, strong(upper([#mark #inl(c)]))) }
  else {
    pad(left: (level - 2) * heading-label, par(hanging-indent: heading-label,
      strong[#box(width: heading-label, mark)#inl(c)]))
  }
})

/// A block quotation: its paragraphs single-spaced, indented on both sides, a single line above, below and between
/// them.
#let quotation(t, keep: false) = {
  let src = t.split("\n").map(l => l.replace(regex("^[ \\t]*>[ \\t]?"), "")).join("\n")
  let paras = src.split(regex("\\n[ \\t]*\\n")).map(c => c.trim()).filter(c => c != "")
  for (k, q) in paras.enumerate() {
    let last = k == paras.len() - 1
    block(width: 100%, above: pitch-single, below: if last { pitch-single } else { 0pt },
      sticky: keep and last, breakable: not (keep and last), {
      set text(..edges(pitch-single))
      set par(first-line-indent: 0pt)
      pad(left: quote-indent, right: quote-indent, inl(q))
    })
  }
}

/// The body in order (README.md, markdown contract): headings numbered by the template, `>` quotations, and
/// paragraphs (indented, double-spaced). The footnote definitions (`[^n]: ...`, anywhere in the body) go with the
/// chunk that refers to them, as each chunk is rendered by a cmarker call of its own. `first`: the space above the
/// first block. The last block is kept whole with the signature block.
#let argument(body, first: 0pt) = {
  let defs = (:)
  let chunks = ()
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "") {
    let d = c.match(regex("^\\[\\^([^\\]]+)\\]:"))
    if d != none { defs.insert(d.captures.at(0), c) } else { chunks.push(c) }
  }
  let with-notes(t) = {
    let s = t
    for m in t.matches(regex("\\[\\^([^\\]]+)\\]")) {
      let id = m.captures.at(0)
      if id in defs { s += "\n\n" + defs.at(id) }
    }
    s
  }
  let md(t) = cmarker.render(with-notes(t), raw-typst: false, smart-punctuation: true)
  let sec = (0, 0, 0, 0)
  for (k, t) in chunks.enumerate() {
    let keep = k == chunks.len() - 1
    let above = if k == 0 { first } else { 0pt }
    let h = t.match(regex("^(#+)\\s+(.*)$"))
    if h != none {
      let lvl = calc.min(h.captures.at(0).len(), 4)
      sec = sec.enumerate().map(((i, v)) => if i == lvl - 1 { v + 1 } else if i >= lvl { 0 } else { v })
      let mark = numbering(("I.", "A.", "1.", "a.").at(lvl - 1), sec.at(lvl - 1))
      heading-block(lvl, mark, h.captures.at(1), above: calc.max(above, pitch-single))
    } else if t.starts-with(">") {
      quotation(t, keep: keep)
    } else if keep or above > 0pt {
      body-block(md(t), above: above, keep: keep)
    } else {
      // Not a block: inside a block, typst places a footnote on a later page than its reference. The paragraph break
      // ends it (each chunk is its own paragraph; without the break typst runs two chunks into one).
      [#md(t)#parbreak()]
    }
  }
}

/// Signature block (LCivR 5.1; Fed. R. Civ. P. 11(a)), a double line below the body: the intro lines ("Respectfully
/// submitted this ... day of ...") at the margin; each signer a blank line below, "s/ Name" (or the sample's
/// `sig_line`), the name and the contact lines; a blank line and the role. The signer and role lines stand 3 in from
/// the left margin. Single-spaced, never split.
#let signature(sig) = block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
  for l in sig.at("intro", default: ()) { line-block(l) }
  if "firm" in sig {
    line-block("")
    line-block(indent: signature-indent, sig.firm)
  }
  for s in sig.signers {
    line-block("")
    line-block(indent: signature-indent, s.at("sig_line", default: "s/ " + s.name))
    line-block(indent: signature-indent, s.name)
    for l in s.at("lines", default: ()) { line-block(indent: signature-indent, l) }
  }
  if "role" in sig {
    line-block("")
    line-block(indent: signature-indent, sig.role)
  }
})

/// Certificate of service (Fed. R. Civ. P. 5(b); LCivR 5.1(d)), a double line below the signature: the centered bold
/// heading, the text (a paragraph at the double pitch), the party lines half an inch in a single line below it, and
/// a double line below them the signer's lines 3 in from the margin. Never split.
#let service(s) = block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
  title-block(s.at("heading", default: "CERTIFICATE OF SERVICE"), above: 0pt)
  body-block(inl(s.text))
  for (k, l) in s.at("party_lines", default: ()).enumerate() {
    line-block(above: if k == 0 { pitch-single } else { 0pt }, indent: service-indent, l)
  }
  for (k, l) in s.at("signer_lines", default: ()).enumerate() {
    line-block(above: if k == 0 { pitch-double } else { 0pt }, indent: signature-indent, l)
  }
})

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

/// `meta`: the frontmatter (see README.md, markdown contract). `body`: the markdown after it.
#let cod-motion-brief(meta, body) = {
  // Pages numbered at the bottom, centered; the number in a single-spaced line box, so it sits where Word's footer
  // sets it.
  set page(paper: "us-letter",
    margin: (top: margin-top, bottom: margin-bottom, left: margin-side, right: margin-side),
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("1"))))
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (LCivR 10.1(e): double spaced).
  show: xengine.with(pitch: pitch-double)
  // Footnote marks always synthesized (raised, 58 %), as Word sets them: Liberation Sans has superscript glyphs for
  // some digits (4, 5), which typst would take instead.
  set super(typographic: false)
  // A doubled section sign stays with its number (xengine binds a single sign), as the docx filter binds it.
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // Footnotes at the text size (LCivR 10.1(d)), single lines, under a 30 % rule, 7 pt between notes; the mark and a
  // space before the text (Word's footnote).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  caption(meta)

  // The opening paragraph ("Defendants ... submit their Motion ... and state as follows:"), a double line below the
  // caption; then the certificate of conferral the sample supplies (LCivR 7.1(a); not required for a Rule 12 motion,
  // 7.1(b)(2)).
  let opened = false
  if "lead_in" in meta {
    body-block(inl(meta.lead_in), above: pitch-double)
    opened = true
  }
  if "conferral" in meta {
    title-block(meta.at("conferral_heading", default: "CERTIFICATE OF COMPLIANCE"),
      above: if opened { pitch-single } else { pitch-double })
    body-block(inl(meta.conferral))
    opened = true
  }

  argument(body, first: if opened { 0pt } else { pitch-double })
  signature(meta.signature)
  if "service" in meta { service(meta.service) }
}
