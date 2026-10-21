// Supreme Court of New Jersey: complaint in lieu of prerogative writs under the court's original jurisdiction
// (N.J. Const. art. II, sec. II, para. 7; R. 2:6-10 for the paper; R. 2:6-6(a) for the cover contents; rules.md NJ-FORM-*,
// NJ-COV-001, NJ-CONV-005). Content-agnostic: every number is a named parameter below, and every case word comes from the
// YAML frontmatter and the markdown body of the sample. The markdown body is rendered by cmarker.

#import "@preview/cmarker:0.1.10"

// ---- Rule 2:6-10: typography and paper ---------------------------------------------------------
// Typeface: Times New Roman or a similar face (rules.md NJ-FORM-003). Body and note type are set at 14 pt,
// stricter than the 12-point minimum; see the OPEN item in rules.md.
#let font-family = ("Times New Roman", "Liberation Serif")
#let body-size = 14pt
#let margin = 1in // rules.md NJ-FORM-004: approximately one inch
#let indent = 0.5in
// Measured on the render (14 pt Liberation Serif, typst 0.15): a leading of 1.6 em gives a 32 pt pitch (double),
// 0.46 em a 16 pt pitch (single).
#let leading-double = 1.6em // NJ-FORM-002: double-spaced text
#let leading-single = 0.46em // caption, counsel and signature lines, block quotations, headings

#let sig-indent = 3.2in // signature blocks start right of centre (the exemplar does the same)
#let versus = "vs." // caption connector, as printed in the exemplar

// Paragraph counter for the numbered paragraphs of the complaint (R. 2:6-10 paper; the exemplar numbers 1 to 78).
#let para-no = counter("nj-petition-para")

// ---- Helpers -------------------------------------------------------------------------------------
/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: false)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nj petition: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("nj petition: missing required metadata field `" + key + "`") }
  meta.at(key)
}

// Page number in the bottom margin, from the second page on: the first page carries the caption and no folio.
#let folio = context {
  if counter(page).get().first() > 1 {
    align(center, text(font: font-family, size: body-size, counter(page).display("1")))
  }
}

// A centred bold part heading (the body's level-1 headings, the trial counsel designation and each certification).
#let part-title(t) = block(width: 100%, above: 1.2em, below: 1em, sticky: true)[
  #set par(leading: leading-single, first-line-indent: 0pt)
  #align(center, text(weight: "bold", t))
]

// ---- Cover block: counsel, caption and title (Rule 2:6-6(a)) -------------------------------------
#let counsel-block(lines) = {
  set par(leading: leading-single, spacing: 0pt, first-line-indent: 0pt)
  set block(spacing: leading-single)
  for l in lines [ #block(width: 100%, inl(l)) ]
}

// One caption side: the party names, then the designation indented beneath them.
#let caption-side(side) = {
  set par(leading: leading-single, spacing: 0pt, first-line-indent: 0pt)
  set block(spacing: 0.9em)
  for n in side.names [ #block(width: 100%, n) ]
  block(width: 100%, pad(left: 1.8in, side.designation))
}

// The caption: the parties on the left under a rule, the court, docket number and title on the right.
#let caption(meta) = grid(
  columns: (1fr, 1fr),
  column-gutter: 0.2in,
  block(
    width: 100%,
    stroke: (right: 0.75pt, bottom: 0.75pt),
    inset: (right: 0.15in, bottom: 0.15in),
    {
      caption-side(meta.caption.at(0))
      block(width: 100%, pad(left: 1.2in, versus))
      caption-side(meta.caption.at(1))
    },
  ),
  block(width: 100%, inset: (left: 0.15in), {
    set par(leading: leading-single, first-line-indent: 0pt)
    [SUPREME COURT OF NEW JERSEY]
    v(1.2em)
    [DOCKET NO.: #meta.at("docket_number", default: "")]
    v(3.6em)
    align(center, text(weight: "bold", meta.brief_title))
    v(1.2em)
    align(center, text(weight: "bold", meta.subtitle))
  }),
)

// ---- Signature blocks ----------------------------------------------------------------------------
// The lines are the filer's own (firm, attorney, date, the "s/" signature); each prints on its own line.
#let signature-block(sig) = block(width: 100%, breakable: false, pad(left: sig-indent)[
  #set par(leading: leading-single, first-line-indent: 0pt, spacing: 0pt)
  #set block(spacing: leading-single)
  #for l in sig.lines [ #block(width: 100%, inl(l)) ]
])

// ---- Entry -------------------------------------------------------------------------------------
#let nj-petition-for-writ(meta, body) = {
  set document(title: need(meta, "brief_title"))
  set page(paper: "us-letter", margin: margin, numbering: "1", footer: folio, footer-descent: 0.4in)
  set text(font: font-family, size: body-size, lang: "en", hyphenate: false)
  set par(justify: false, leading: leading-double, spacing: leading-double, first-line-indent: (amount: indent, all: true))

  // Level-1 headings in the markdown body are part headings; the caption and the designation share their style.
  show heading.where(level: 1): it => part-title(upper(it.body))
  show heading.where(level: 2): it => block(width: 100%, above: 1.2em, below: 0.8em, sticky: true)[
    #set par(leading: leading-single, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set par(leading: leading-single, first-line-indent: 0pt)
    #text(weight: "bold", style: "italic", it.body)
  ]

  // Numbered paragraphs: the number sits at the paragraph indent, the text follows it.
  show enum.item: it => {
    para-no.step()
    block(width: 100%, breakable: true)[
      #set par(leading: leading-double, spacing: leading-double, first-line-indent: 0pt)
      #h(indent) #context numbering("1.", ..para-no.get()) #h(0.3em) #it.body
    ]
  }

  // Block quotations are indented and single-spaced.
  show quote.where(block: true): it => block(inset: (left: indent, right: indent), above: 0.8em, below: 1.2em)[
    #set par(leading: leading-single, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes are single-spaced.
  show footnote.entry: it => {
    set text(size: body-size)
    set par(leading: leading-single, first-line-indent: 0pt)
    it
  }

  // ---- Cover, caption and opening (the first page carries the counsel block and caption; the body follows on it) ----
  {
    set par(leading: leading-single, first-line-indent: 0pt)
    counsel-block(need(meta, "counsel"))
  }
  v(1.6em)
  caption(meta)
  v(1.2em)

  // ---- Body: the opening sentence and numbered paragraphs under the complaint's headings ----
  cmarker.render(body, raw-typst: false, smart-punctuation: false, h1-level: 1)

  // ---- Certifications and signatures, each after the body in the order given (R. 4:5-1; R. 1:38-7(b)) ----
  for c in meta.at("certifications", default: ()) {
    if "heading" in c { part-title(upper(c.heading)) }
    for p in c.at("paragraphs", default: ()) {
      par(first-line-indent: (amount: indent, all: true), inl(p))
    }
    if "signature" in c { signature-block(c.signature) }
  }

  // ---- Exhibits: each on its own page, the exhibit heading centred ----
  for ex in meta.at("exhibits", default: ()) {
    pagebreak()
    align(center + horizon)[
      #text(weight: "bold", upper(ex.heading))
      #if "note" in ex [
        #v(2em)
        #block(width: 80%, {
          set par(leading: leading-single, first-line-indent: 0pt)
          align(left, text(style: "italic", inl(ex.note)))
        })
      ]
    ]
  }
}
