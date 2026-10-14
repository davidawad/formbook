// U.S. Bankruptcy Court, E.D. Oklahoma: brief in support of a motion (doc type `motion-brief`).
//
// Rule-driven and content-agnostic. Governing rules are cited in ../README.md:
//   LBR 9004-1 (paper: type size incl. footnotes, margins, double spacing of pleadings and briefs),
//   FRBP 9013 (motions in writing, grounds stated), LBR 9013-1 (motion papers; text not verified).
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of the
// same sample file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"        // vendored in /fonts; no system font is ever used
#let type-size = 12pt                    // LBR 9004-1(A): no less than 12 point, footnotes included
#let page-margin = 1in                   // LBR 9004-1(A): margins no less than one inch
#let double-leading = 1.65em             // LBR 9004-1(A): briefs double spaced; 27.6 pt baseline pitch
#let single-leading = 0.65em             // caption, counsel and signature blocks, block quotes, headings
#let para-indent = 0.5in                 // first-line indent of body paragraphs (both exemplars)
#let caption-left = 3.5in                // width of the debtor column of the caption

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Numbered paragraphs (the Chapter 13 trustee's brief numbers its facts and discussion). The
/// numbers typed in the markdown are not used: each paragraph takes the next number, and the count
/// runs across the whole brief.
#let para-no = counter("para-no")

/// cmarker calls `scope.enum` with the item bodies of every ordered list.
#let numbered-items(..items) = {
  for it in items.pos() {
    para-no.step()
    context block(width: 100%)[
      #set par(first-line-indent: 0pt)
      #h(para-indent)#para-no.display("1.")#h(0.5em)#it
    ]
  }
}

/// cmarker calls `scope.list` with the item bodies of every bulleted list. Bulleted lists in a brief
/// are set off from the text: indented, single spaced.
#let bullet-items(..items) = {
  block(width: 100%, above: 0.6em, below: 1.0em, {
    set par(leading: single-leading, first-line-indent: 0pt)
    for it in items.pos() {
      pad(left: 1in, it)
    }
  })
}

/// A run of single-spaced lines (counsel, signature, certificate signature): one paragraph with a
/// line break between lines, so the single leading applies between them.
#let lines-block(lines) = block(breakable: false, width: 100%, {
  set par(leading: single-leading, first-line-indent: 0pt)
  for (i, l) in lines.enumerate() {
    [#l]
    if i < lines.len() - 1 { linebreak() }
  }
})

/// Render an inline markdown string as inline content.
#let inl(s) = cmarker.render(
  s,
  raw-typst: false,
  smart-punctuation: true,
  scope: (enum: numbered-items, list: bullet-items),
)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("okeb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("okeb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

// ---------------------------------------------------------------------------
// Caption (both filed exemplars: court name in two lines, debtor column, case number and chapter)
// ---------------------------------------------------------------------------

#let caption(meta) = {
  set par(leading: single-leading, first-line-indent: 0pt)
  align(center)[
    #block[#strong[IN THE UNITED STATES BANKRUPTCY COURT]]
    #block[#strong[FOR THE EASTERN DISTRICT OF OKLAHOMA]]
  ]
  v(1.8em)
  table(
    columns: (caption-left, 1fr),
    stroke: none,
    inset: (x: 0pt, y: 0pt),
    align: top,
    table.vline(x: 1, stroke: 0.8pt),
    [
      #block(width: 100%, inset: (right: 0.2in))[
        In re:
        #v(0.9em)
        #let debtors = need(meta, "debtor")
        #for n in (if type(debtors) == str { (debtors,) } else { debtors }) {
          pad(left: 0.5in)[#n]
          v(0.2em)
        }
        #pad(left: 2.2in)[#need(meta, "debtor_role")]
      ]
    ],
    [
      #pad(left: 0.3in)[
        Case No. #need(meta, "case_number")#if "judge" in meta and meta.judge != "" [-#meta.judge]
        #v(1.2em)
        Chapter #need(meta, "chapter")
      ]
    ],
  )
  v(2.0em)
  block(width: 100%, sticky: true, below: 1.2em, {
    set par(leading: single-leading, first-line-indent: 0pt)
    align(center, strong(upper(need(meta, "title"))))
  })
  // Cover counsel block, when the filer puts one on the first page (optional).
  if "counsel" in meta {
    pad(left: 3.25in, lines-block(meta.counsel))
    v(0.6em)
  }
}

// ---------------------------------------------------------------------------
// Signature block (LBR 9004-1(C): name, bar number, address, email, telephone, fax, party)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, width: 100%, {
    set par(leading: single-leading, first-line-indent: 0pt)
    if "date" in meta [
      #block[Dated: #meta.date]
      #v(1.2em)
    ]
    pad(left: 3.25in)[
      #block[Respectfully submitted,]
      #v(1.6em)
      #block[/s/ #sig.electronic]
      #v(0.4em)
      #lines-block(sig.lines)
    ]
  })
}

// ---------------------------------------------------------------------------
// Certificate of service or of mailing (optional; follows the signature block, as in both exemplars)
// ---------------------------------------------------------------------------

#let certificate-block(meta) = {
  if "certificate" in meta {
    let c = meta.certificate
    v(1.4em)
    block(width: 100%, sticky: true, below: 1.2em, {
      set par(leading: single-leading, first-line-indent: 0pt)
      align(center, strong(upper(c.title)))
    })
    block(width: 100%, {
      set par(leading: double-leading)
      inl(c.body)
    })
    block(breakable: false, width: 100%, {
      pad(left: 3.25in)[
        #block[/s/ #c.electronic]
        #v(0.4em)
        #lines-block(c.lines)
      ]
    })
  }
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let okeb-motion-brief(meta, body) = {
  set document(title: need(meta, "title"))
  set page(
    paper: "us-letter",
    margin: page-margin,
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(
    leading: double-leading,
    first-line-indent: (amount: para-indent, all: true),
    justify: false,
  )

  // LBR 9004-1(A): footnotes are 12 point too, and single spaced.
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(leading: single-leading, first-line-indent: 0pt)

  // Block quotations: single spaced and indented on both sides.
  show quote.where(block: true): it => block(width: 100%, above: 0.6em, below: 1.2em, {
    set par(leading: single-leading, first-line-indent: 0pt)
    pad(x: 0.5in, it.body)
  })

  // Headings: level 1 is centered bold capitals; levels 2 and 3 are bold, single spaced, and
  // start at the margin (level 3 is indented as a sub-point).
  show heading.where(level: 1): it => block(width: 100%, sticky: true, above: 1.4em, below: 1.2em, {
    set par(leading: single-leading, first-line-indent: 0pt)
    align(center, text(size: type-size, strong(upper(it.body))))
  })
  show heading.where(level: 2): it => block(width: 100%, sticky: true, above: 1.2em, below: 1.0em, {
    set par(leading: single-leading, first-line-indent: 0pt)
    text(size: type-size, strong(it.body))
  })
  show heading.where(level: 3): it => block(width: 100%, sticky: true, above: 1.0em, below: 1.0em, {
    set par(leading: single-leading, first-line-indent: 0pt)
    pad(left: 0.5in, text(size: type-size, strong(it.body)))
  })

  caption(meta)
  body

  v(1.4em)
  signature-block(meta)
  certificate-block(meta)
}
