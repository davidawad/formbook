// Florida Second District Court of Appeal (fladistctapp2): petition under Rules 9.030(b)(2) and 9.100.
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next to it
// (Florida Rules of Appellate Procedure: Rule 9.045 as amended by No. SC2025-1458, effective July 1, 2026;
// Rule 9.100 and Rule 9.210(a)(1) as the court-hosted compilation states them; see ../README.md and ../../rules.md).
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the sample.
//
// Rule IDs (FLADISTCTAPP2-*) are the rows of ../../rules.md.

#import "@preview/cmarker:0.1.10"
#import "../../../../../../../lib/typst/tables.typ": leader-row

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = "Liberation Sans"       // FLADISTCTAPP2-FORM-003: Arial 14-point (Rule 9.045(b)). Liberation Sans is the vendored metric twin of Arial (docs/FONTS.md).
#let type-size = 14pt                      // FLADISTCTAPP2-FORM-003: body, footnotes, quotations and headings are all 14-point (FORM-005, FORM-006).
#let body-leading = 1.63em                 // FLADISTCTAPP2-FORM-004: double-spaced body. Calibrated on the render: the baseline pitch is about 2.3 em (the double line of Arial), the value Word gives for double spacing.
#let body-spacing = 2.35em                 // space between paragraphs: the filed exemplar sets a paragraph break about 10 pt deeper than a double line (measured: 32.5 pt line pitch, 42.5 pt paragraph pitch); spacing adds to the 9.6 pt natural line height.
#let single-leading = 0.48em              // FORM-005 and FORM-006: quotations, footnotes and headings may be single-spaced (about 1.15 em pitch).
#let page-margin = 1in                     // FLADISTCTAPP2-FORM-002: at least one inch on all sides.
#let para-indent = 0.5in
#let toc-depth = 4                    // the contents list the numbered subheadings (1., 2.) as the exemplar does
#let sig-indent = 3.2in                    // signature block and closing date line start right of centre (style; exemplars do the same).
#let word-limit = 13000                    // FLADISTCTAPP2-LEN-003: computer-generated petition, Rule 9.100(g).
#let court-lines = ("IN THE DISTRICT COURT OF APPEAL", "OF THE STATE OF FLORIDA", "SECOND DISTRICT")   // FLADISTCTAPP2-COV-001: name of the court, as the exemplar sets it on three lines.
#let word-count-cite = "Rule 9.045 and Rule 9.100(g)"   // FLADISTCTAPP2-CERT-001, CERT-003.
// Vertical spacing (named here so the template body carries no literal spacing).
#let gap-cover = 0.1in                     // cover: between the cover blocks
#let gap-cover-tight = 0.05in             // cover: between the two caption sides and the "v."
#let gap-group = 0.4em                    // counsel: between counsel groups
#let gap-firm = 0.8em                     // signature: after the firm name
#let gap-signers = 0.9em                  // signature: between signers
#let gap-sig-lines = 0.6em                // signature: before the lines beneath the signers
#let gap-sig-date = 0.4em                 // closing: after the signature line
#let gap-toc = 0.5em                      // table of contents: below its title
#let gap-closing = 0.3in                  // closing: before the signature block

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("fladistctapp2-petition: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("fladistctapp2-petition: missing required metadata field `" + key + "`") }
  meta.at(key)
}

// ---------------------------------------------------------------------------
// Word count (FLADISTCTAPP2-CERT-003, LEN-002). The count is taken from the markdown body:
// the cover, tables, certificates and signature block are generated outside the body and so
// are excluded; headings, footnotes and block quotations are in the body and are counted.
// Markup characters are removed; a token counts when it has a letter or a digit.
// ---------------------------------------------------------------------------

#let count-words(s) = s.split(regex("\\s+")).filter(w => w.find(regex("[A-Za-z0-9]")) != none).len()

#let body-plain(body) = {
  // footnote references and definitions, then link targets (toa:key), then markup characters
  let s = body.replace(regex("\\[\\^[^\\]]*\\]:?"), " ")
  s = s.replace(regex("\\(toa:[^)]*\\)"), " ")
  s.replace(regex("[\\[\\]\\*_>#`]"), " ")
}

#let body-words(body) = count-words(body-plain(body))

// ---------------------------------------------------------------------------
// Cover, counsel and signature blocks
// ---------------------------------------------------------------------------

/// One caption side: centred names, then the designation (FLADISTCTAPP2-COV-001).
#let caption-side(side) = {
  align(center, {
    set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    stack(dir: ttb, spacing: single-leading, ..side.names.map(inl), emph(side.designation))
  })
}

/// Counsel group: names (bold) then the lines beneath, centred on the cover.
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  stack(dir: ttb, spacing: single-leading, ..g.names.map(n => strong(n)), ..g.at("lines", default: ()).map(inl))
  v(gap-group)
}

/// Counsel groups in two columns (the first takes the first half of the groups), so the cover stays on one page.
#let counsel-columns(groups) = {
  let half = calc.ceil(groups.len() / 2)
  grid(
    columns: (1fr, 1fr), column-gutter: 0.3in,
    stack(dir: ttb, spacing: 0pt, ..groups.slice(0, half).map(counsel-group)),
    stack(dir: ttb, spacing: 0pt, ..groups.slice(half).map(counsel-group)),
  )
}

/// Signers of the signature block. Rule 9.045 and 9.210 leave the form to the filer: "/s/" and the
/// typed name, underlined, with the typed name again below it, then the lines beneath.
#let signers(sig) = {
  if "signers" in sig { sig.signers } else { ((name: need(sig, "signer"), lines: ()),) }
}

#let signer-entry(s) = {
  let rows = (underline[/s/ #emph(s.name)], [#s.name]) + s.at("lines", default: ()).map(inl)
  stack(dir: ttb, spacing: single-leading, ..rows)
}

#let signature-block(sig, first-only: false) = {
  let all = signers(sig)
  let list = if first-only { (all.first(),) } else { all }
  block(width: 100%, breakable: false, pad(left: sig-indent, {
    set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    if "firm" in sig {
      strong(sig.firm)
      v(gap-firm)
    }
    for (i, s) in list.enumerate() {
      if i > 0 { v(gap-signers) }
      signer-entry(s)
    }
    if sig.at("lines", default: ()).len() > 0 {
      v(gap-sig-lines)
      stack(dir: ttb, spacing: single-leading, ..sig.lines.map(inl))
    }
  }))
}

/// The signature block after the conclusion and on each certificate. The filed exemplar sets no date
/// line and no "Respectfully submitted," before it, so neither is printed.
#let closing-block(meta) = block(width: 100%, breakable: false, {
  signature-block(need(meta, "signature"))
})

// ---------------------------------------------------------------------------
// Table of citations (FLADISTCTAPP2-SEC-001 (2)). Each entry carries `find`: a string that appears in
// every citation of the authority in the body (e.g. the volume and reporter). A show rule on that
// string drops a marker after each occurrence; the table lists the pages of the markers.
// ---------------------------------------------------------------------------

#let toa-marker(key) = [#metadata(key)<fladistctapp2-toa>]

#let mark-authorities(meta, content) = {
  let out = content
  for group in meta.at("authorities", default: ()) {
    for e in group.entries {
      if "find" in e {
        let key = e.find
        out = {
          show key: it => it + toa-marker(key)
          out
        }
      }
    }
  }
  out
}

#let toa-pages(key) = context {
  let pages = query(<fladistctapp2-toa>)
    .filter(m => m.value == key)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
  if pages.len() == 0 { [--] } else { pages.map(str).join(", ") }
}

#let citations-table(meta) = {
  heading(level: 1, outlined: true, numbering: none)[Table of Citations]
  for group in meta.authorities {
    block(above: 1.2em, below: 0.8em, sticky: true, strong(group.heading))
    for e in group.entries {
      block(above: 0.9em, below: 0.9em, breakable: false,
        leader-row(inl(e.cite), if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") },
          hang: 1.5em, dot-gap: 2pt, lead-gap: 0.4em, gutter: 4pt, min-leader: 1em, leading: single-leading))
    }
  }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let fladistctapp2-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // FLADISTCTAPP2-FORM-001: letter. FLADISTCTAPP2-FORM-007 and LEN-002: pages not excluded from the
  // word count are numbered consecutively. The numbering runs from the cover (page 1, not printed) so
  // every printed number is the page's position in the document (the choice made for this template).
  set page(paper: "us-letter", margin: page-margin, numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-spacing, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Heading levels in the markdown body (the markdown carries the typed numerals, "I.", "A.", as the
  // filed exemplar does): level 1 is a section, centred and capitals; level 2 and 3 are bold, left.
  show heading.where(level: 1): it => block(width: 100%, above: 1.6em, below: 1.2em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, text(weight: "bold", upper(it.body)))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1.2em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 4): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]

  // Block quotations: indented, single-spaced; FLADISTCTAPP2-FORM-005 (same size as the body).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnote reference markers are raised less than the default superscript, so that the marker on the first
  // line of a page does not rise above the one-inch top margin; its top sits at the body's cap height.
  show super: it => text(baseline: -0.4em, size: 0.65em, it.body)
  // Footnotes: 14 point like the text (FORM-005), single-spaced. Citations in footnotes count toward the table.
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)
  }

  // ---- Cover (FLADISTCTAPP2-COV-001: court, style and case number, lower tribunal, party, type of brief, counsel) ----
  page(numbering: none)[
    #align(center, {
      set par(leading: single-leading, first-line-indent: 0pt, spacing: 0.4em)
      stack(dir: ttb, spacing: single-leading, ..court-lines.map(line => text(weight: "bold", line)))
    })
    #v(gap-cover)
    #align(center, text(weight: "bold", "Case No. " + str(need(meta, "case_number"))))
    #if "trial_court_case" in meta {
      align(center, {
        set par(leading: single-leading, first-line-indent: 0pt)
        inl(meta.trial_court_case)
      })
    }
    #v(gap-cover)
    #caption-side(meta.caption.at(0))
    #v(gap-cover-tight)
    #align(center)[v.]
    #v(gap-cover-tight)
    #caption-side(meta.caption.at(1))
    #v(gap-cover)
    #if "proceeding" in meta {
      align(center, {
        set par(leading: single-leading, first-line-indent: 0pt)
        inl(meta.proceeding)
      })
    }
    #v(1fr)
    #align(center, {
      set par(leading: single-leading, first-line-indent: 0pt)
      text(weight: "bold", upper(inl(need(meta, "brief_title"))))
    })
    #v(1fr)
    #align(center, {
      set par(leading: single-leading, first-line-indent: 0pt)
      // Two columns of counsel so the cover stays on one page (COV-002); the first column takes the first half of the groups.
      counsel-columns(need(meta, "counsel"))
      if "phone" in meta { inl(meta.phone) }
    })
  ]

  // ---- Table of contents (FLADISTCTAPP2-SEC-001 (1)) ----
  if meta.at("toc", default: true) {
    page[
      #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt, justify: false)
      #align(center, text(weight: "bold")[TABLE OF CONTENTS])
      #v(gap-toc)
      #show outline.entry: it => block(above: 0.7em, below: 0.7em, it)
      #outline(title: none, depth: toc-depth, indent: 1.5em)
    ]
  }

  // ---- Table of citations (FLADISTCTAPP2-SEC-001 (2)) ----
  if "authorities" in meta {
    page(citations-table(meta))
  }

  // ---- Body: the sections of SEC-001 (3) to (6), in the markdown order ----
  pagebreak(weak: true)
  let words = body-words(body)
  assert(
    words <= word-limit,
    message: "FLADISTCTAPP2-LEN-003: the petition has " + str(words) + " words; the limit is " + str(word-limit),
  )
  mark-authorities(meta, cmarker.render(body, raw-typst: false, smart-punctuation: true))

  // ---- Date, counsel's signature (after the conclusion) ----
  v(gap-closing)
  closing-block(meta)

  // ---- Certificate of service (FLADISTCTAPP2-CERT-004; SEC-001 (7)) ----
  if "service" in meta {
    let svc = meta.service
    pagebreak(weak: true)
    heading(level: 1, outlined: true, numbering: none)[Certificate of Service]
    for p in svc.at("paragraphs", default: ()) { par(inl(p)) }
    for r in svc.at("recipients", default: ()) {
      block(above: 1em, below: 1em, breakable: false, pad(left: 0.5in, {
        set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
        stack(dir: ttb, spacing: single-leading, ..r.map(inl))
      }))
    }
    v(gap-sig-date)
    closing-block(meta)
  }

  // ---- Certificate of compliance (FLADISTCTAPP2-CERT-001, CERT-002: immediately after the service certificate) ----
  pagebreak(weak: true)
  heading(level: 1, outlined: true, numbering: none)[Certificate of Compliance]
  par(inl(
    "Counsel certifies that this petition meets the typeface and length requirements of " + word-count-cite
      + " governing this court. The petition is set in Arial 14-point type. Excluding the cover, the tables, the certificates and the signature block, it contains "
      + str(words) + " words, as counted by the word-processing system that prepared it.",
  ))
  v(gap-sig-date)
  closing-block(meta)
}
