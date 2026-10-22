// U.S. Bankruptcy Court, S.D. Georgia: motion with memorandum of law (FRBP 9013; FRBP 7012 for a
// Rule 12 motion in an adversary proceeding). One document: the motion and the memorandum together,
// as S.D. Ga. LR 7.1(b) allows (where the judge so directs; see ../README.md).
//
// Rule-driven and content-agnostic. Requirement IDs (GASB-...) refer to ../README.md, which quotes
// the rules and records the dates verified. No case-specific text, no coordinates measured off the
// exemplar, no forced line breaks. The markdown body is rendered by cmarker; the metadata comes
// from the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")    // Font: not set by any S.D. Ga. rule found (see ../README.md); Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                    // Convention: 12 pt, the size of the filed exemplars (no rule sets a size).
#let margins = (top: 1in, bottom: 1in, x: 1in)  // Style choice: no margin rule in the S.D. Ga. rules found; 1 inch is the usual floor.
#let para-indent = 0.5in
#let heading-tab = 0.5in                 // a heading's label box; each deeper level half an inch further in
#let item-box = 0.5in                    // a numbered list item: the number half an inch in, the text an inch in, hanging
#let page-number-size = 11pt
#let caption-left = 4.1in                // caption: the party column (about 3.4 : 2 of the text width)
#let caption-inset = 0.2in               // the party text stands off the caption's right rule, the case numbers off the rule
#let debtor-indent = 1.2in               // the debtor's role under "In re"
#let designation-indent = 1.8in          // a party's designation under its names
#let sig-column = 3.2in                  // signature: the right-hand column

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-body = 24pt                   // GASB-FORM-002: double-spaced (LR 10.1, incorporated by the Uniformity of Practice clause).
#let pitch-single = 13.8pt               // a single line: 1.15 x the type size (Word's single line in this face)
#let gap = pitch-body / 2                // between the caption's groups, around headings, in the signature and certificate

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("gasb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("gasb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-spaced paragraph with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: left, body)
})

// ---------------------------------------------------------------------------
// Headings: I., A., 1., a. (the author types no numbers; FRBP 9013 requires none)
// ---------------------------------------------------------------------------

/// Printed label of a heading: level 1 "I.", 2 "A.", 3 "1.", 4 "a.".
#let heading-num(..n) = {
  let lv = n.pos().len()
  let k = n.pos().last()
  if lv == 1 { numbering("I.", k) }
  else if lv == 2 { numbering("A.", k) }
  else if lv == 3 { numbering("1.", k) }
  else if lv == 4 { numbering("a.", k) }
  else { "" }
}

/// Left edge of a heading's label: level 1 at the margin, each deeper level half an inch in.
#let label-indent(level) = (level - 1) * heading-tab

// ---------------------------------------------------------------------------
// Caption (FRBP 9004(b); FRCP 10(a) through FRBP 7010)
// ---------------------------------------------------------------------------

/// Court title, centered, one line per entry of `court` (FRBP 9004(b)(1)).
#let court-title(meta) = for l in need(meta, "court") { line-block(align(center, strong(upper(inl(l))))) }

/// Left cell: the debtor ("In re") block with the trustee if any, then the adversary parties.
#let caption-left-cell(meta) = {
  for l in need(meta, "in_re") { line-block(inl(l)) }
  line-block(left: debtor-indent, below: gap, inl(meta.at("debtor_role", default: "Debtor.")))
  if "trustee" in meta {
    for (i, l) in meta.trustee.enumerate() { line-block(below: if i == meta.trustee.len() - 1 { gap } else { 0pt }, inl(l)) }
  }
  let sides = need(meta, "caption")
  for (i, side) in sides.enumerate() {
    for n in side.names { line-block(inl(n)) }
    line-block(left: designation-indent, inl(side.designation))
    if i < sides.len() - 1 { line-block(above: gap, below: gap, align(center)[v.]) }
  }
}

/// Right cell: chapter, case number, judge (if any) and adversary number (FRBP 9004(b)(3)).
/// A blank adversary number is printed as a blank to be filled in by the clerk.
#let caption-right-cell(meta) = {
  line-block(below: gap)[CHAPTER #need(meta, "chapter")]
  line-block(below: gap)[CASE NO. #need(meta, "case_number")]
  if "judge" in meta { line-block(below: gap, inl(meta.judge)) }
  let adv = meta.at("adversary_number", default: "")
  line-block[ADV. PRO. NO. #if adv == "" { "_" * 11 } else { adv }]
}

#let caption-table(meta) = block(above: pitch-body, below: pitch-body, grid(
  columns: (caption-left, 1fr),
  block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-inset, bottom: gap),
    caption-left-cell(meta)),
  pad(left: caption-inset, caption-right-cell(meta)),
))

// ---------------------------------------------------------------------------
// Signature block (LR 11.1: counsel name, address, telephone, State Bar number; FRBP 9011)
// ---------------------------------------------------------------------------

/// The date at the left, the firm and counsel in the right-hand column.
#let signature-grid(meta) = {
  let sig = need(meta, "signature")
  grid(
    columns: (1fr, sig-column),
    line-block[This #need(meta, "submitted_on").],
    {
      line-block(below: gap, strong(inl(sig.firm)))
      line-block[/s/ #sig.signer]
      line-block(inl(sig.signer))
      for l in sig.at("signer_lines", default: ()) { line-block(inl(l)) }
      line-block(above: gap, emph(inl(need(sig, "role"))))
      for l in need(sig, "address") { line-block(inl(l)) }
    },
  )
}

#let signature-block(meta) = block(width: 100%, breakable: false, above: pitch-body, below: 0pt, signature-grid(meta))

// ---------------------------------------------------------------------------
// Certificate of service (LR 5.1, as incorporated: date, method and address of service)
// ---------------------------------------------------------------------------

#let certificate-block(meta) = {
  let cert = need(meta, "certificate")
  block(width: 100%, breakable: false, above: 2 * pitch-body, below: 0pt, {
    line-block(below: gap, align(center, strong[CERTIFICATE OF SERVICE]))
    block(width: 100%, above: 0pt, below: 0pt, par[This is to certify that on this date, I caused a copy of the foregoing #inl(need(cert, "document")) to be served by #inl(need(cert, "method")), as set forth below:])
    let svc = need(cert, "service")
    for (i, l) in svc.enumerate() {
      line-block(above: if i == 0 { gap } else { 0pt }, align(center, inl(l)))
    }
    block(width: 100%, above: gap, below: 0pt, signature-grid(meta))
  })
}

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

#let gasb-motion-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "case_number", "chapter", "in_re", "caption", "title", "signature", "submitted_on", "certificate") {
    let _ = need(meta, k)
  }

  // ---- document-wide settings ----
  // LR 10.1: every page is numbered from the first, the caption page included; the number in a single-spaced line box.
  set page(paper: "us-letter", margin: margins, numbering: "1", footer-descent: 30%, footer: context align(center,
    text(size: page-number-size, ..edges(pitch-single), counter(page).display("1"))))
  set document(
    title: need(meta, "title") + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number ("§§ 1334"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)

  // Footnotes: 12 pt, single-spaced (the entry sets its own leading: it does not inherit the body's); the mark, a
  // space, the note (Word's footnote layout).
  set footnote.entry(gap: 7pt, clearance: 12.6pt, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    [#super(num) #note.body]
  }

  // Numbered list items (the relief requested): the number half an inch in, in a half-inch box, the text an inch
  // in on every line, at the body pitch.
  show enum: it => {
    let n = if it.start == auto { 1 } else { it.start }
    for item in it.children {
      if item.has("number") and item.number != none { n = item.number }
      block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: 0pt, hanging-indent: para-indent + item-box,
        [#h(para-indent)#box(width: item-box)[#n.]#item.body]))
      n += 1
    }
  }

  // Headings: the label in a half-inch box ((level - 1) half inches in), the bold title hanging after it,
  // single-spaced, half a body line above and below, kept with the text after them.
  // The numbering function is what steps the heading counter; the labels are drawn by the show rule below.
  set heading(numbering: heading-num)
  show heading: it => context {
    let nums = counter(heading).at(it.location()).slice(0, it.level)
    let lab = if it.numbering == none { "" } else { numbering(it.numbering, ..nums) }
    let ind = label-indent(it.level)
    block(width: 100%, above: gap, below: gap, sticky: true, {
      set text(size: type-size, ..edges(pitch-single))
      par(first-line-indent: 0pt, hanging-indent: ind + heading-tab, [#h(ind)#box(width: heading-tab, lab)#strong(it.body)])
    })
  }

  // ---- caption page: the motion starts on page 1 under the caption ----
  court-title(meta)
  caption-table(meta)
  line-block(below: gap, align(center, strong(upper(inl(need(meta, "title"))))))

  cmarker.render(md, raw-typst: false, smart-punctuation: true)
  signature-block(meta)
  certificate-block(meta)
}
