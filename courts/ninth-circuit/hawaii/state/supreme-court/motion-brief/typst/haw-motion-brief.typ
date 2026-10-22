// Supreme Court of the State of Hawai'i (haw): motion and supporting memorandum.
//
// Content-agnostic. The parameters below are the ones HRAP 32(b) (12-point Times New Roman or its
// metric twin; footnotes and quotations in the same size as the text; double spacing except headings,
// quotations and footnotes) and HRAP 32(a) (8-1/2 x 11, one-inch margins; flyleaf with a 3-inch top
// margin) set, see ../../rules.md (HAW-FORM-001..006, HAW-FLY-001/002, HAW-SIG-001, HAW-MOT-001/002).
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the sample.
// The flyleaf (cover) is generated from the metadata; the body is the motion and memorandum itself.
// No table of contents or authorities is generated: the exemplar has none (HAW-BRIEF-003 does not
// apply to motions).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // HRAP 32(b) and HAW-FORM-003; Liberation Serif is the metric twin (docs/FONTS.md).
#let type-size = 12pt                    // HAW-FORM-003: 12 point; footnotes and quotations at the same size (HAW-FORM-004).
#let body-leading = 1.61em               // HAW-FORM-005: double spacing. Typst adds the leading to the natural 12 pt line (8.3 pt here): 1.61 em gives a 27.6 pt pitch.
#let single-leading = 0.46em            // single spacing: 8.3 pt natural line plus 0.46 em gives a 13.8 pt pitch.
#let page-margin = 1in                   // HAW-FORM-001: not less than one inch all round.
#let flyleaf-top = 3in                   // HAW-FLY-002: 3-inch top margin on the flyleaf (the 3x3 top-right option is not used).
#let para-indent = 0.5in
#let sig-indent = 3.2in                  // signature block starts right of centre, as the exemplar does.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("haw-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("haw-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One caption side (parties): centred names, then the designation.
#let caption-side(side) = {
  set par(leading: single-leading, spacing: 0.9em, first-line-indent: 0pt, justify: false)
  for n in side.names [ #inl(n) \ ]
  emph(side.designation)
}

/// Counsel group: names (bold) then the lines beneath.
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for n in g.names [ #strong(n) \ ]
  for l in g.lines [ #inl(l) \ ]
  v(0.6em)
}

/// Signature block: the firm or office lines (plain), "By /s/ name" over the typed name, then the lines beneath.
#let signature-block(sig) = {
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #if "pre" in sig [ #for l in sig.pre [ #inl(l) \ ] #v(0.6em) ]
    By #underline[/s/ #inl(sig.signer)] \
    #if "signer_name" in sig [ #inl(sig.signer_name) \ ]
    #if "lines" in sig {
      v(0.6em)
      for l in sig.lines [ #inl(l) \ ]
    }
  ])
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let haw-motion-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  set page(paper: "us-letter", margin: page-margin, numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Heading levels in the body: level 1 is a section (centred, capitals, bold);
  // level 2 and 3 are sub-headings (bold, left, hanging). Headings are single spaced (HAW-FORM-005).
  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 1.2em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, text(weight: "bold", upper(it.body)))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1.0em, below: 1.0em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1.0em, below: 1.0em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", style: "italic", it.body)
  ]
  show heading.where(level: 4): it => block(width: 100%, above: 1.0em, below: 1.0em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]

  // Block quotations: indented both sides, single spaced, same size as the text (HAW-FORM-004).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.4em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: text size, single spaced.
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    pad(bottom: 0.25em, it)
  }

  // ---- Flyleaf (HRAP 32(a); HAW-FLY-001, HAW-FLY-002) ----
  // The flyleaf has a 3-inch top margin; the page's other margins stay one inch. It is one page:
  // left column the parties and counsel, right column the case numbers, judges and the document title.
  page(margin: (top: flyleaf-top, rest: page-margin), numbering: none)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center)[#text(weight: "bold")[#need(meta, "case_number")]]
    #v(0.3in)
    #align(center)[#text(weight: "bold")[#need(meta, "court_title")]]
    #v(0.3in)
    #grid(
      columns: (3.0in, 3.5in),
      gutter: 0pt,
      [
        #caption-side(need(meta, "caption").at(0))
        #v(0.3em)
        #align(left)[v.]
        #v(0.3em)
        #caption-side(meta.caption.at(1))
        #v(0.2in)
        #{
          set par(leading: single-leading, first-line-indent: 0pt)
          if "department" in meta [ #meta.department \ ]
          for g in need(meta, "counsel") { counsel-group(g) }
        }
      ],
      pad(left: 0.2in, [
        #set par(leading: single-leading, first-line-indent: 0pt)
        #if "trial_case_number" in meta [ #meta.trial_case_number \ ]
        #if "civil_action" in meta [ #meta.civil_action \ ]
        #v(0.6em)
        #for l in need(meta, "judge_lines") [ #inl(l) \ ]
        #v(1.2em)
        #text(weight: "bold", upper(inl(need(meta, "brief_title"))))
        #if "attached" in meta {
          v(0.5em)
          for a in meta.attached [ #upper(inl(a)) \ ]
        }
      ]),
    )
  ]

  // ---- Body (the motion, then the memorandum) ----
  // Page numbers start at 1 on the first page after the flyleaf.
  counter(page).update(1)
  cmarker.render(body, raw-typst: false, smart-punctuation: true)

  // ---- Date and signature block, after the conclusion (HAW-SIG-001) ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #if "date" in meta { par(first-line-indent: 0pt, inl(meta.date)) }
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]
}
