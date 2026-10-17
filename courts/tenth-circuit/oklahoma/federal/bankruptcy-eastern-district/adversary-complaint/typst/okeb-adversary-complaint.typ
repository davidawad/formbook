// U.S. Bankruptcy Court, E.D. Oklahoma: complaint commencing an adversary proceeding.
//
// Rule-driven and content-agnostic. Governing rules are cited in ../README.md:
//   FRBP 7001 (adversary proceeding), FRBP 7010 (FRCP 10 applies; caption substantially conforms
//   to Official Form 416D), LBR 7001-1(A), LBR 9004-1 (paper, type size, margins, double spacing,
//   signature block), LBR 9004-2 (caption contents).
// No case-specific text, no coordinates measured off any filed complaint, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of the
// same sample file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = "Liberation Serif"   // Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                    // LBR 9004-1(A): no less than 12 point, footnotes included
#let page-margin = 1in                   // LBR 9004-1(A): margins no less than one inch
#let double-leading = 1.65em             // LBR 9004-1(A): double spaced; gives a 27.6 pt baseline pitch
#let single-leading = 0.65em             // caption, counsel and signature blocks, lists, headings
#let para-indent = 0.5in                 // first-line indent of unnumbered paragraphs (convention)
#let number-indent = 0.5in               // numbered allegations: the number starts half an inch in
#let caption-left = 3.5in                // width of the party column of the caption

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Numbered allegations (FRCP 10(b)) are numbered consecutively across the whole complaint.
/// The numbers typed in the markdown are not used: each paragraph takes the next number.
#let allegation = counter("allegation")

/// cmarker calls `scope.enum` with the item bodies of every ordered list.
#let numbered-items(..items) = {
  for it in items.pos() {
    allegation.step()
    context block(width: 100%)[
      #set par(first-line-indent: 0pt)
      #h(number-indent)#allegation.display("1.")#h(0.5em)#it
    ]
  }
}

/// cmarker calls `scope.list` with the item bodies of every bulleted list. The lists here are
/// the descriptions of property (one item per line), so they are indented and single spaced.
#let bullet-items(..items) = {
  block(width: 100%, above: 0.6em, below: 1.0em, {
    set par(leading: single-leading, first-line-indent: 0pt)
    for it in items.pos() {
      pad(left: 1in, it)
    }
  })
}

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
  if m == none { panic("okeb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("okeb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

// ---------------------------------------------------------------------------
// Caption (Official Form 416D, LBR 9004-2)
// ---------------------------------------------------------------------------

#let caption(meta) = {
  set par(leading: single-leading, first-line-indent: 0pt)
  align(center)[
    #block[#strong[UNITED STATES BANKRUPTCY COURT]]
    #block[#strong[EASTERN DISTRICT OF OKLAHOMA]]
  ]
  v(1.8em)
  table(
    columns: (caption-left, 1fr),
    stroke: none,
    inset: (x: 0pt, y: 0pt),
    align: top,
    table.vline(x: 1, stroke: 0.8pt),
    // Left: the debtor, then the parties to the adversary proceeding.
    [
      #block(width: 100%, inset: (right: 0.2in))[
        In re:
        #v(0.9em)
        #pad(left: 0.5in)[#need(meta, "debtor")]
        #v(0.2em)
        #pad(left: 2.2in)[Debtor.]
        #v(1.1em)
        #for (i, p) in need(meta, "parties").enumerate() {
          if i > 0 {
            pad(left: 1.2in)[v.]
            v(0.9em)
          }
          pad(left: 0.5in)[#p.names]
          v(0.2em)
          pad(left: 2.2in)[#p.role]
          v(0.9em)
        }
      ]
    ],
    // Right: case number and judge initials, chapter (directly under the case number), adversary number.
    [
      #pad(left: 0.3in)[
        #stack(
          dir: ttb,
          spacing: single-leading,
          [Case No. #need(meta, "case_number")#if "judge" in meta and meta.judge != "" [-#meta.judge]],
          [Chapter #need(meta, "chapter")],
        )
        #v(1.2em)
        Adv. Proc. No. #need(meta, "adversary_number")
      ]
    ],
  )
  v(2.2em)
}

// ---------------------------------------------------------------------------
// Signature block (LBR 9004-1(C): name, bar number, address, email, telephone, fax, party)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, width: 100%, {
    set par(leading: single-leading, first-line-indent: 0pt)
    set block(spacing: 0.35em)
    if "date" in meta [
      #block[Dated: #meta.date]
      #v(1.2em)
    ]
    pad(left: 3.25in)[
      #block[Respectfully submitted:]
      #v(1.6em)
      #block[s/ #sig.electronic]
      #v(0.4em)
      #for l in sig.lines { block[#l] }
    ]
  })
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let okeb-adversary-complaint(meta, body) = {
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

  // LBR 9004-1(A): footnotes are 12 point too.
  show footnote.entry: set text(size: type-size)

  // Section headings and count titles: bold capitals, centered, single spaced.
  show heading: it => block(width: 100%, sticky: true, above: 1.4em, below: 1.2em, {
    set par(leading: single-leading, first-line-indent: 0pt)
    align(center, text(size: type-size, strong(upper(it.body))))
  })

  caption(meta)
  block(width: 100%, sticky: true, below: 1.2em, {
    set par(leading: single-leading, first-line-indent: 0pt)
    align(center, strong(upper(need(meta, "title"))))
  })

  body

  v(1.4em)
  signature-block(meta)
}
