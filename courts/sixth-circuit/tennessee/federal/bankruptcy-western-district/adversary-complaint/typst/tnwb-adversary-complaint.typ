// U.S. Bankruptcy Court, Western District of Tennessee: adversary complaint (FRBP 7001, 7010).
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
#let para-indent = 0.5in                   // allegations: number at the half inch
#let number-width = 0.5in
#let signature-indent = 3in
#let footnote-size = 10pt

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics, links, footnote references) as content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("tnwb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("tnwb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Blank-line separated blocks of the body, in order.
#let blocks-of(body) = body.trim(at: end).split(regex("\n[ \t]*\n")).filter(b => b.len() > 0)

/// Lettered prayer items: A., B., ...
#let letter(i) = numbering("A.", i + 1)

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
// Body: numbered allegations, headings, lists, tables, quotations, footnotes
// ---------------------------------------------------------------------------

/// Render a body (markdown string) as the pleading's paragraphs. `tail` (the signature block) is
/// kept in one unbreakable block with the last paragraph, so the signature never stands alone.
#let pleading-body(body, tail: none) = {
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

  let n = 0          // allegation number
  let first = true   // the introductory paragraph is not an allegation
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
    } else if b.starts-with("- ") {
      // Prayer items: one lettered item per list item; continuation lines join their item.
      let items = ()
      for line in b.split("\n") {
        if line.starts-with("- ") { items.push(line.slice(2)) }
        else if items.len() > 0 { items.at(items.len() - 1) = items.at(items.len() - 1) + " " + line.trim() }
      }
      for (i, it) in items.enumerate() {
        let piece = blk(grid(columns: (1in, 1fr), [#h(para-indent)#letter(i)], inl(with-notes(it))))
        if last and i == items.len() - 1 and tail != none {
          tail-used = true
          block(breakable: false, width: 100%)[#piece #tail]
        } else {
          piece
        }
      }
    } else if b.starts-with("|") {
      // Transfer tables: centered, single-spaced, ruled. A table that breaks across pages repeats its header row.
      blk(align(center, block(width: 80%)[
        #set par(leading: single-leading)
        #show table: set table(stroke: 0.4pt, inset: (x: 8pt, y: 3pt), align: (left, right))
        #inl(b)
      ]))
    } else if b.starts-with(">") {
      let txt = b.split("\n").map(l => l.trim(">", at: start).trim()).join(" ")
      block(width: 100%, inset: (left: 0.5in, right: 0.5in), below: body-leading)[
        #set par(leading: single-leading)
        #inl(with-notes(txt))
      ]
    } else {
      // Allegations are numbered from 1. Not numbered: the introduction, the prayer lead-in
      // ("WHEREFORE") and an editorial note in italics within square brackets (`*[...]*`).
      let piece = if first or b.starts-with("WHEREFORE") or b.starts-with("*[") {
        blk(h(para-indent) + inl(with-notes(b)))
      } else {
        n += 1
        blk(h(para-indent) + box(width: number-width)[#n.] + inl(with-notes(b)))
      }
      if last and tail != none {
        tail-used = true
        block(breakable: false, width: 100%)[#piece #tail]
      } else {
        piece
      }
      first = false
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
    #set par(leading: single-leading, first-line-indent: 0pt)
    #blk(h(para-indent) + s.closing)
    #pad(left: signature-indent)[
      #blk(lead: single-leading, strong(s.firm))
      #blk(lead: single-leading, [/s/ #s.signer])
      #blk(lead: single-leading, s.at("name_line", default: s.signer))
      #for line in s.lines { blk(lead: single-leading, line) }
      #blk(lead: single-leading, emph(s.role))
    ]
  ]
}

// ---------------------------------------------------------------------------
// Document
// ---------------------------------------------------------------------------

#let complaint(meta, body) = {
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
  pleading-body(body, tail: signature-block(meta))
}
