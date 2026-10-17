// U.S. Bankruptcy Court, Western District of Tennessee: motion memorandum of law (FRBP 9013, TNWB LBR 9013-1, LBR 7016-1).
//
// Rule-driven and content-agnostic. No case-specific text, no coordinates measured off the exemplar,
// no forced line breaks. The body is markdown rendered by cmarker; the metadata is the YAML
// frontmatter of the sample (schema: ../README.md, "Markdown contract"). Requirement IDs (TNWB-...)
// refer to ../README.md.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule, to the exemplar's convention,
// or is a stated choice in ../README.md)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")     // TNWB-FORM-001: serif; Times New Roman substitute per docs/FONTS.md
#let type-size = 12pt                      // TNWB-FORM-001: exemplar convention (12 pt)
// Line pitch = natural line height (about 7.8 pt for this face at 12 pt) + leading.
#let body-leading = 1.345em                // double spacing: 24 pt baseline pitch
#let single-leading = 0.6em                // single spacing: about 14 pt pitch
#let page-margin = 1in                     // TNWB-FORM-002: exemplar convention, no court rule found
#let para-indent = 0.5in                   // body paragraphs: first-line indent
#let signature-indent = 3in
#let footnote-size = 10pt

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics, links, footnote references) as content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("tnwb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("tnwb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Blank-line separated blocks of the body, in order.
#let blocks-of(body) = body.trim(at: end).split(regex("\n[ \t]*\n")).filter(b => b.len() > 0)

/// One block of text. The gap below it equals the leading, so the pitch between blocks is the
/// same as the pitch between lines (a block with no gap would overlap the next one).
#let blk(lead: body-leading, sticky: false, content) = block(width: 100%, spacing: 0pt, below: lead, sticky: sticky, content)

// ---------------------------------------------------------------------------
// Court heading and caption (TNWB-CAP-*; FRBP 7010 and Official Form 416 caption contents)
// ---------------------------------------------------------------------------

#let court-heading(meta) = {
  let lines = ("UNITED STATES BANKRUPTCY COURT", "WESTERN DISTRICT OF TENNESSEE")
  if "division" in meta { lines.push(upper(meta.division)) }
  for l in lines {
    blk(lead: single-leading, align(center, strong(l)))
  }
  v(body-leading)
}

/// Two-column caption with a section mark column: each row is (left, right) content.
#let caption-table(rows) = {
  set par(leading: single-leading)
  let cells = ()
  for (l, r) in rows {
    cells.push(l)
    cells.push(align(center)[§])
    cells.push(r)
  }
  table(
    columns: (1.2fr, 0.4in, 1fr),
    stroke: none,
    inset: 0pt,
    row-gutter: single-leading,
    align: (left, center, left),
    ..cells,
  )
}

#let caption(meta) = {
  let debtor = need(meta, "debtor")
  let chapter = need(meta, "chapter")
  let plaintiffs = need(meta, "plaintiffs")
  let defendants = need(meta, "defendants")

  // Debtor side: "IN RE:" then the debtor's name(s); case number and chapter on the right.
  let debtor-left = ("IN RE:", "") + debtor + ("", "DEBTOR.")
  let debtor-right = ("CASE NO.: " + need(meta, "case_number"), "") + chapter
  let debtor-rows = range(calc.max(debtor-left.len(), debtor-right.len())).map(i => (
    debtor-left.at(i, default: ""),
    debtor-right.at(i, default: ""),
  ))

  // Adversary side: the parties, with the adversary number on the first row.
  let adv-left = plaintiffs + ("Plaintiff,", "", "vs.", "") + defendants + ("Defendants.",)
  let adv-right = ("ADVERSARY PROCEEDING NO.: " + need(meta, "adversary_number"),)
  let adv-rows = range(adv-left.len()).map(i => (
    adv-left.at(i),
    adv-right.at(i, default: ""),
  ))

  v(body-leading)
  caption-table(debtor-rows + ((("", "")),) + adv-rows)
  v(single-leading)
  line(length: 100%, stroke: 0.6pt)
}

// ---------------------------------------------------------------------------
// Body: paragraphs (unnumbered), headings, tables, quotations, footnotes
// ---------------------------------------------------------------------------

/// Render a body (markdown string) as the memorandum's paragraphs. `tail` (the signature block) is
/// kept in one unbreakable block with the last paragraph, so the signature never stands alone.
#let memo-body(body, tail: none) = {
  let blocks = blocks-of(body)

  // Footnote definitions are blocks of their own; they are rendered where they are referenced.
  let notes = (:)
  for b in blocks {
    if b.starts-with("[^") {
      let m = b.match(regex("^\\[\\^([^\\]]+)\\]:\\s*([\\s\\S]*)$"))
      notes.insert(m.captures.at(0), m.captures.at(1))
    }
  }
  let with-notes(b) = {
    let keys = b.matches(regex("\\[\\^([^\\]]+)\\]")).map(m => m.captures.at(0)).dedup()
    b + keys.map(k => "\n\n[^" + k + "]: " + notes.at(k)).join()
  }

  // The last body block (footnote definitions do not count) stays with the signature block.
  let last-idx = blocks.enumerate().filter(p => not p.at(1).starts-with("[^")).last().at(0)
  let tail-used = false
  for (idx, b) in blocks.enumerate() {
    let last = idx == last-idx
    if b.starts-with("[^") {
      // rendered at the reference
    } else if b.match(regex("^#{1,3} ")) != none {
      let m = b.match(regex("^(#{1,3}) +([\\s\\S]*)$"))
      let lvl = m.captures.at(0).len()
      let txt = m.captures.at(1)
      if lvl == 1 {
        block(above: body-leading, below: body-leading, width: 100%, sticky: true)[
          #align(center, strong(upper(inl(txt))))
        ]
      } else if lvl == 2 {
        block(below: body-leading, width: 100%, sticky: true)[
          #align(center, strong(inl(txt)))
        ]
      } else {
        block(below: body-leading, width: 100%, sticky: true)[
          #strong(inl(txt))
        ]
      }
    } else if b.starts-with("|") {
      // Tables: centered, single-spaced, ruled. A table that breaks across pages repeats its header row.
      blk(align(center, block(width: 80%)[
        #set par(leading: single-leading)
        #show table: set table(stroke: 0.4pt, inset: (x: 8pt, y: 3pt), align: (left, right))
        #inl(b)
      ]))
    } else if b.starts-with(">") {
      // Block quotations: indented, single-spaced (FRAP-style convention; see README).
      let txt = b.split("\n").map(l => l.trim(">", at: start).trim()).join(" ")
      block(width: 100%, inset: (left: 0.5in, right: 0.5in), below: body-leading)[
        #set par(leading: single-leading)
        #inl(with-notes(txt))
      ]
    } else {
      let piece = blk(h(para-indent) + inl(with-notes(b)))
      if last and tail != none {
        tail-used = true
        block(breakable: false, width: 100%)[#piece #tail]
      } else {
        piece
      }
    }
  }
  // The signature block must never be dropped: if the last body block was a heading, table or
  // quotation, it follows that block.
  if not tail-used and tail != none { tail }
}

// ---------------------------------------------------------------------------
// Signature block (LBR 1001-3(h): signature, address, telephone, email, state bar number)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let s = need(meta, "signature")
  block(breakable: false, width: 100%)[
    #blk(lead: single-leading, sticky: true, h(para-indent) + s.closing)
    #v(single-leading)
    #pad(left: signature-indent)[
      #blk(lead: single-leading, sticky: true, strong(s.firm))
      #blk(lead: single-leading, sticky: true, [/s/ #s.signer])
      #blk(lead: single-leading, sticky: true, s.at("name_line", default: s.signer))
      #for line in s.lines { blk(lead: single-leading, sticky: true, line) }
      #blk(lead: single-leading, emph(s.role))
    ]
  ]
}

// ---------------------------------------------------------------------------
// Certificate of service (FRBP 9013(b) service; wording of the exemplar's certificate)
// ---------------------------------------------------------------------------

#let certificate-of-service(meta) = {
  let svc = need(meta, "service")
  let s = need(meta, "signature")
  block(breakable: false, width: 100%)[
    #blk(lead: body-leading, sticky: true, align(center, strong[CERTIFICATE OF SERVICE]))
    #blk(lead: body-leading, sticky: true, h(para-indent) + [I hereby certify that on the #svc.date, the foregoing document has been served by electronic means via the Court’s electronic filing system, unless otherwise indicated below:])
    #v(single-leading)
    #grid(
      columns: (1fr, 1fr),
      column-gutter: 0.3in,
      row-gutter: body-leading,
      ..svc.parties.map(lines => block(width: 100%)[
        #for line in lines { blk(lead: single-leading, line) }
      ]),
    )
    #v(body-leading)
    #pad(left: signature-indent)[
      #blk(lead: single-leading, [/s/ #s.signer])
    ]
  ]
}

// ---------------------------------------------------------------------------
// Document
// ---------------------------------------------------------------------------

#let memorandum(meta, body) = {
  set document(title: need(meta, "title"))
  set page(
    paper: "us-letter",
    margin: page-margin,
    numbering: "1",
    number-align: center + bottom,
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us")
  set par(justify: false, leading: body-leading, first-line-indent: 0pt, spacing: 0pt)
  show footnote.entry: set text(size: footnote-size)

  court-heading(meta)
  caption(meta)
  block(above: body-leading, below: body-leading, width: 100%, sticky: true)[
    #align(center, strong(upper(need(meta, "title"))))
  ]
  memo-body(body, tail: signature-block(meta))
  if "service" in meta {
    v(body-leading)
    certificate-of-service(meta)
  }
}
