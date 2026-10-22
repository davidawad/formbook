// Motion with memorandum for the U.S. Bankruptcy Court, District of New Mexico (nmb).
// Rules: Fed. R. Bankr. P. 9013 (motion states the grounds with particularity), 7010 and 9004 (caption as in the
// complaint), NM LBR 9013-1(a) (the title describes the relief sought), 9013-1(i) and 7007-1 (briefs optional in
// adversary proceedings unless ordered), 9013-1(j) (certificate of service for every motion), 9011-1(a) (contact
// block under the signature). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter and body, never from this file. No
// forced line breaks and no coordinates measured off a filed paper.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a stated convention; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // no typeface rule in FRBP or NM LBR (NMB-FORM-002); Times New Roman, the house standard and the exemplar's face (vendored metric twin)
#let type-size = 12pt                   // convention (no size rule); matches the filed exemplar's body
#let note-size = 10pt                   // footnotes and the page footer (convention)
#let margin = 1in                       // all four sides (convention; the rules give no margin)
#let para-indent = 0.5in                // first-line indent of paragraphs; lettered sub-items start this far in
#let item-label = 0.4in                 // a sub-item's letter in a box this wide, the text hanging after it
#let quote-indent = 0.75in              // block quotations, both sides
#let caption-left = 3.4in               // the parties box (and a contested matter's debtor box)
#let caption-gutter = 0.25in            // between the box and the case column
#let caption-pad = 9pt                  // a box's text this far off its rules
#let signature-indent = 3.25in          // the signature block stands this far from the left margin
#let signature-rule = 31                // underscores after "By: " (about 2.6 in at 12 pt)
#let rule = 0.75pt                      // the caption's rules
#let note-gap = 7pt                     // between two footnotes (Word: Footnote Text's space after)
#let note-clearance = 7.5pt             // from the text to the footnote rule (the space LibreOffice keeps above it)

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt                // double spacing, 2 x the type size (convention; no rule sets the spacing)
#let pitch-single = 15pt                // single-spaced material: court, caption, title, quotations, signature
#let pitch-note = 11.5pt                // footnotes and the footer, 10 pt type (1.15 x)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nmb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names, citations, amounts).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// A paragraph body with `[^n]` markers replaced by footnotes whose text is in the frontmatter. A space after a marker
/// is kept (cmarker drops a leading one).
#let with-notes(s, notes) = {
  let seg(t, pos) = (if pos > 0 and t.match(regex("^\\s")) != none { [ ] }) + inl(t)
  let ms = s.matches(regex("\\[\\^(\\d+)\\]"))
  let pos = 0
  let out = []
  for m in ms {
    out += seg(s.slice(pos, m.start), pos)
    out += footnote(inl(notes.at(m.captures.at(0))))
    pos = m.end
  }
  out + seg(s.slice(pos), pos)
}

/// One single-spaced line block (a paragraph of its own), with explicit space above it. The text is set as written
/// (frontmatter strings, not markdown). An empty line keeps its height.
#let line-block(above: 0pt, body) = block(width: 100%, above: above, below: 0pt,
  height: if body == "" or body == [] { pitch-single } else { auto }, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  body
})

// ---------------------------------------------------------------------------
// Page furniture: the paper's short title at the left, "Page X of Y" at the right, 10 pt, in a single line box
// ---------------------------------------------------------------------------

#let page-footer(title) = context {
  set text(size: note-size, ..edges(pitch-note))
  set par(first-line-indent: 0pt)
  grid(columns: (1fr, auto), title,
    [Page #counter(page).get().first() of #counter(page).final().first()])
}

// ---------------------------------------------------------------------------
// Caption (Fed. R. Bankr. P. 7010; Official Form 416 layout: court, debtor and case, parties and adversary number,
// title). Single-spaced, never split.
// ---------------------------------------------------------------------------

/// A box of caption lines ruled on `sides`, its text `caption-pad` inside the rules, and the case column beside it.
#let caption-box(left, right, sides) = block(width: 100%, breakable: false, above: pitch-single, below: 0pt, grid(
  columns: (caption-left, caption-gutter, 1fr),
  block(width: 100%, stroke: sides.map(s => (s, rule)).to-dict(),
    inset: sides.map(s => (s, caption-pad)).to-dict(), left.join()),
  [],
  pad(top: if "top" in sides { caption-pad } else { 0pt }, right.join()),   // beside the box's first line
))

#let caption(meta) = {
  for l in meta.court { line-block(align(center, strong(l))) }
  let parties = meta.at("parties", default: ())
  if parties.len() == 0 {
    // Contested matter in the main case (no adversary parties): the debtor in a box, the chapter and case number to
    // its right (the filed exemplar, p. 1).
    let side = ()
    if meta.at("chapter", default: none) != none { side.push(line-block(align(right, meta.chapter))) }
    side.push(line-block(align(right, meta.case_number)))
    caption-box(meta.debtor.map(line-block), side, ("top", "right", "bottom", "left"))
  } else {
    // The debtor's lines in the left half, the case number at the right of the first; then the parties box ruled at its
    // right and bottom, the adversary number beside its middle line.
    block(width: 100%, breakable: false, above: pitch-single, below: 0pt, grid(columns: (1fr, 1fr),
      meta.debtor.map(line-block).join(), line-block(align(right, meta.case_number))))
    let left = ()
    for (k, p) in parties.enumerate() {
      if k > 0 { left.push(line-block("")) }
      left += (line-block(p.names), line-block(p.role))
    }
    let side = range(calc.quo(left.len() - 1, 2)).map(_ => line-block("")) + (line-block(meta.adv_number),)
    caption-box(left, side, ("right", "bottom"))
  }
  // the title a double line below the caption, single-spaced, centered
  line-block(above: pitch-double, align(center, strong(meta.title)))
}

// ---------------------------------------------------------------------------
// Signature block (NM LBR 9011-1(a): name, address, telephone and e-mail below the signature line), single-spaced,
// never split, a double line below the last paragraph
// ---------------------------------------------------------------------------

#let signature(sig) = block(width: 100%, breakable: false, above: pitch-double, below: 0pt,
  pad(left: signature-indent, {
    line-block("Respectfully Submitted,")
    line-block(above: pitch-single, strong(sig.firm))
    line-block(above: pitch-double, "By: " + "_" * signature-rule)
    line-block(sig.signer)
    for l in sig.lines { line-block(l) }
    line-block(sig.email)
    line-block(sig.role)
  }))

// Certificate of service (NM LBR 9013-1(j)): present when the frontmatter carries a `certificate` block. Its heading a
// double line below the signature, the paragraph below it; never split.
#let certificate(c, notes) = block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
  block(width: 100%, above: 0pt, below: 0pt, align(center, par(first-line-indent: 0pt, strong("CERTIFICATE OF SERVICE"))))
  par(with-notes(c, notes))
})

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let nmb-motion-brief(meta, body) = {
  set page(paper: "us-letter", margin: margin, footer-descent: 24.5pt, footer: page-footer(meta.footer_title))
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (double spacing).
  show: xengine.with(pitch: pitch-double, list-indent: none)
  // A doubled section sign stays with its number (xengine binds a single sign), as the docx filter binds it.
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // Footnotes at 10 pt in single lines under a 30 % rule, 7 pt between notes; the mark and a space before the text
  // (Word's footnote).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: note-size, ..edges(pitch-note))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }
  let notes = meta.at("footnotes", default: (:))

  caption(meta)

  // Unnumbered lead-in paragraph, from the frontmatter, a double line below the title. Paragraphs are not wrapped in
  // blocks: inside a block, typst places a footnote on a later page than its reference.
  block(width: 100%, above: pitch-double, below: 0pt)
  [#with-notes(meta.lead_in, notes)#parbreak()]

  let chunks = body.replace("\r\n", "\n").split("\n\n").filter(c => c.trim() != "")
  let para = 0
  let letter = 0
  for chunk in chunks {
    let t = chunk.trim()

    // Heading: one or more '#', centered and bold at the body pitch, kept with the next block.
    let hm = t.match(regex("^(#+)\\s+([\\s\\S]*)$"))
    if hm != none {
      letter = 0
      block(width: 100%, sticky: true, above: 0pt, below: 0pt,
        align(center, par(first-line-indent: 0pt, strong(inl(hm.captures.at(1))))))
      continue
    }

    // Block quotation: lines starting with '>'; single-spaced, indented on both sides, a single line above and below
    // each quoted paragraph.
    if t.starts-with(">") {
      letter = 0
      let inner = t.split("\n").map(l => l.replace(regex("^>\\s?"), "")).join("\n")
      for q in inner.split(regex("\\n[ \\t]*\\n")).map(q => q.trim()).filter(q => q != "") {
        block(width: 100%, above: pitch-single, below: pitch-single, pad(left: quote-indent, right: quote-indent, {
          set text(..edges(pitch-single))
          par(first-line-indent: 0pt, inl(q))
        }))
      }
      continue
    }

    // Indented markdown list item: a sub-item of the numbered paragraph before it, lettered (a), (b), ...
    let lm = chunk.match(regex("^[ \t]+\\d+\\.\\s+"))
    if lm != none {
      letter += 1
      block(width: 100%, above: 0pt, below: 0pt, pad(left: para-indent,
        par(first-line-indent: 0pt, hanging-indent: item-label,
          [#box(width: item-label)[(#"abcdefghijklmnopqrstuvwxyz".at(letter - 1))]#with-notes(chunk.slice(lm.end).trim(), notes)])))
      continue
    }

    letter = 0

    // Numbered paragraph: the template numbers the paragraphs; typed numbers are dropped.
    let nm = t.match(regex("^\\d+\\.\\s+"))
    if nm != none {
      para += 1
      [#para. #with-notes(t.slice(nm.end), notes)#parbreak()]
      continue
    }

    // Anything else is an unnumbered paragraph: first-line indent, as the filed memorandum's introduction and argument.
    [#with-notes(t, notes)#parbreak()]
  }

  // The prayer, kept whole with the signature block.
  block(width: 100%, sticky: true, breakable: false, above: 0pt, below: 0pt, par(with-notes(meta.prayer, notes)))
  signature(meta.signature)
  if meta.at("certificate", default: none) != none {
    certificate(meta.certificate, notes)
  }
}
