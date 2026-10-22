// Memorandum brief in support of a motion for the U.S. District Court for the Southern District of Mississippi (mssd).
// Rules: L.U.Civ.R. 7(b)(2) (the memorandum is a separate docket item from the motion), 7(b)(5)(A) (8 1/2 x 11, double
// spaced, margins of at least 1 inch on all four sides, page numbers only in the margins), 7(b)(5)(B) (proportional serif
// face, 12-point text, footnotes 11-point or larger), 7(b)(5)(C) (case names italic or underlined), 11(a) (counsel's
// name, address, telephone, fax, e-mail and bar number); the 35-page limit of 7(b)(5) is asserted at the end.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or to a choice recorded in README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // 7(b)(5)(B): a proportional serif face; Times New Roman, the house standard and the exemplar's face (data/exemplar-fonts.json)
#let type-size = 12pt                   // L.U.Civ.R. 7(b)(5)(B): text 12-point or larger
#let footnote-size = 11pt               // 7(b)(5)(B): footnotes 11-point or larger
#let margin = 1in                       // 7(b)(5)(A): at least 1 inch on all four sides
#let para-indent = 0.5in                // first-line indent of body paragraphs; the label box of list items
#let caption-left = 3.6in               // the party column of the caption
#let caption-gutter = 0.1in             // between the party column and the case-number column
#let sig-left = 3in                     // the counsel block stands in the right half of the page
#let note-gap = 7pt                     // between footnotes
#let note-clearance = 12.6pt            // between the body and the footnote rule

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // a single line: 1.15 x the type size (Word's single line in this face)
#let pitch-double = 2 * pitch-single    // 7(b)(5)(A): double spacing, 27.6 pt (the exemplar's measured pitch)
#let pitch-note = 1.15 * footnote-size  // a footnote line (7(b)(5)(A): footnotes may be single-spaced): 12.65 pt
#let heading-space = pitch-single       // above and below a heading (7(b)(5)(A): headings may be single-spaced)

// The signature fields L.U.Civ.R. 11(a) requires. The template refuses to render without them.
#let required-signature-keys = ("signer", "bar_no", "firm", "address", "telephone", "fax", "email")

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mssd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in italics, smart quotes).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt, hanging-indent: 0pt)
  body
})

/// A body paragraph at the double pitch with the first-line indent.
#let body-par(content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), content))

/// A level-1 heading's look: centered, bold, underlined capitals (the certificate's heading too).
#let section-title(c) = align(center, text(weight: "bold", underline(upper(c))))

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title(meta) = for l in meta.court {
  line-block(align(center, text(weight: "bold", upper(l))))
}

/// The caption: each party's names, then its designation; "v." between the parties, a blank line above and below
/// it. "CIVIL ACTION NO." and the case number stand at the right, from the line of the first "v." (the exemplars'
/// layout), so that both columns keep one line grid.
#let caption(meta) = {
  let rows = ()
  let v-row = none
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 {
      if v-row == none { v-row = rows.len() + 1 }
      rows.push((text: "v.", above: pitch-single))
      rows.push((text: none, above: pitch-single))
    }
    for n in p.names + (p.designation,) { rows.push((text: n, above: 0pt)) }
  }
  if v-row == none { v-row = 0 }
  block(width: 100%, above: pitch-double, below: pitch-double, grid(
    columns: (caption-left, 1fr),
    column-gutter: caption-gutter,
    {
      let pending = 0pt
      for r in rows {
        if r.text == none { pending = r.above } else {
          line-block(above: calc.max(pending, r.above), inl(r.text))
          pending = 0pt
        }
      }
    },
    pad(top: v-row * pitch-single, {
      line-block("CIVIL ACTION NO.")
      line-block(inl(meta.case_number))
    }),
  ))
}

#let cover(meta) = {
  court-title(meta)
  caption(meta)
  line-block(below: heading-space, align(center, underline(text(weight: "bold", upper(meta.brief_title)))))
}

// ---------------------------------------------------------------------------
// Signature and certificate
// ---------------------------------------------------------------------------

/// "Respectfully submitted, this the <date>", then counsel's block (L.U.Civ.R. 11(a)) in the right half of the
/// page; it never breaks across a page.
#let signature-block(meta) = {
  let s = meta.signature
  for k in required-signature-keys {
    assert(k in s, message: "mssd-motion-brief: signature." + k + " is required (L.U.Civ.R. 11(a))")
  }
  block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
    if "date" in s {
      line-block(below: pitch-single, par(first-line-indent: (amount: para-indent, all: true),
        [Respectfully submitted, this the #inl(s.date)]))
    }
    pad(left: sig-left, {
      line-block(inl(s.firm))
      for a in s.address { line-block(inl(a)) }
      line-block[Telephone: #s.telephone]
      line-block[Facsimile: #s.fax]
      line-block(above: pitch-single)[s/ #inl(s.signer)]
      line-block[#upper(s.signer), #s.bar_no]
      line-block[Email: #s.email]
    })
  })
}

/// Certificate of service (optional): the heading, one indented paragraph, the "s/" signature; kept whole.
#let certificate-block(meta) = if "certificate" in meta {
  let c = meta.certificate
  block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
    line-block(below: heading-space, section-title("Certificate of Service"))
    body-par(inl(c.text))
    block(width: 100%, above: pitch-single, below: 0pt, pad(left: sig-left, {
      line-block[s/ #inl(c.signer)]
      line-block[#upper(c.signer), #c.bar_no]
    }))
  })
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// Body text. Each blank-line-separated chunk of markdown is one of:
///   - a footnote definition (`[^id]: text`): collected, and placed at each `[^id]` reference;
///   - a heading (`#`, `##`);
///   - a list (`1.`, `-`);
///   - a paragraph: set with a first-line indent, double-spaced.
/// The last paragraph stays on the page with the signature block (`tail`): a signature alone on a page is not allowed.
/// Footnotes are split out here because cmarker 0.1.10 resolves a note only inside one render call.
#let brief-body(body, tail) = {
  let all = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let defs = (:)
  let chunks = ()
  for c in all {
    let m = c.match(regex("^\\[\\^(\\w+)\\]:\\s*([\\s\\S]*)$"))
    if m != none { defs.insert(m.captures.at(0), m.captures.at(1)) } else { chunks.push(c) }
  }
  let tail-used = false
  for (i, t) in chunks.enumerate() {
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      md(t)
    } else {
      // Split the paragraph at footnote references: text, the footnote, text again.
      let pieces = ()
      let at = 0
      for m in t.matches(regex("\\[\\^(\\w+)\\]")) {
        pieces.push(t.slice(at, m.start))
        pieces.push((note: m.captures.at(0)))
        at = m.end
      }
      pieces.push(t.slice(at))
      // A paragraph that anchors a footnote has no widow or orphan control: typst would move a line away from the
      // note it has already placed (the note stays behind on the page before), and Word keeps a note with its line;
      // so the line stays where it fits, in both engines (docx: style Body Text Noted).
      let noted = pieces.any(p => type(p) == dictionary)
      set text(costs: (widow: 0%, orphan: 0%)) if noted
      let para = body-par(for p in pieces {
        if type(p) == dictionary { footnote(inl(defs.at(p.note))) } else if p != "" {
          // cmarker trims a piece's outer spaces: the space after a note mark (or before it) is kept here
          if p.first() == " " [ ]
          md(p)
          if p.len() > 1 and p.last() == " " [ ]
        }
      })
      if i == chunks.len() - 1 {
        block(breakable: false, width: 100%, above: 0pt, below: 0pt, { para; tail })
        tail-used = true
      } else { para }
    }
  }
  if not tail-used { tail }
}

#let mssd-motion-brief(meta, body) = {
  // Page numbers centered in the bottom margin (7(b)(5)(A)), in a single-spaced line box (Word's footer at the same place).
  set page(
    paper: "us-letter",
    margin: margin,
    numbering: "1",
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (7(b)(5)(A): double spaced); list items as a label box (para-indent) with the text hanging.
  show: xengine.with(pitch: pitch-double, list-indent: para-indent)

  // Footnotes single-spaced at 11 pt (7(b)(5)(B)): the mark, a space, the note; the rule as long as Word's separator
  // in LibreOffice (30 % of the measure).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: footnote-size, ..edges(pitch-note))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)   // the entry does not inherit the body's leading
    [#super(num)#h(0.25em)#note.body]
  }

  // Headings single-spaced: level 1 centered, bold, underlined capitals; level 2 bold at the left; kept with the
  // block after them.
  show heading: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt)
    let b = if it.level == 1 { section-title(it.body) } else { text(weight: "bold", it.body) }
    block(sticky: true, width: 100%, above: heading-space, below: heading-space, b)
  }

  cover(meta)
  brief-body(body, signature-block(meta))
  certificate-block(meta)
  // L.U.Civ.R. 7(b)(5): the movant's original and rebuttal memoranda together may not exceed 35 pages.
  context {
    let pages = counter(page).final().first()
    assert(pages <= 35, message: "mssd-motion-brief: the memorandum is " + str(pages) + " pages; L.U.Civ.R. 7(b)(5) allows 35")
  }
}
