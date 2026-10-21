// Supreme Court of Nevada: motion and supporting memorandum (motion-brief).
//
// Content-agnostic. Every number is a named parameter below and traces to the Nevada Rules of Appellate Procedure
// (NRAP) cited next to it, as printed in ../../rules.md (rule IDs NEV-*). No coordinates measured off any filed
// document, no forced line breaks. The markdown body is rendered by cmarker; the metadata is the YAML frontmatter.
// The 14-point type size is also declared in ../../eval.yaml (NEV-FORM-004) so the checker reads it.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")     // NRAP 32(a)(5)(A) names Times New Roman; Liberation Serif is its metric-compatible substitute (docs/FONTS.md). NEV-FORM-004.
#let type-size = 14pt                      // NRAP 32(a)(5)(A): proportionally spaced type of 14 points or larger, footnotes included (NRAP 32(a)(5)(B)). NEV-FORM-004, NEV-MOT-007.
#let body-leading = 1.65em                 // NRAP 27(d)(1)(C), 32(a)(4): double-spaced. With typst's default line box this gives a
                                           // baseline pitch of about 32.3 pt = 2 x the 1.15 em single line of this face at 14 pt.
#let single-leading = 0.45em               // NRAP 32(a)(4): quotations of more than two lines, headings and footnotes may be single-spaced.
#let page-margin = (top: 1in, bottom: 1.1in, left: 1in, right: 1in)  // NRAP 27(d)(1)(E), 32(a)(4): at least one inch on all four sides. The bottom is 0.1 in deeper so 14 pt footnote descenders stay inside the 1 in line.
#let para-indent = 0.5in
#let toc-depth = 3
#let sig-indent = 3.2in                    // signature block starts right of centre (style; the filed motion does the same).
#let word-count-text(n) = [This motion contains #n words.]  // NRAP 27(d)(2)(C): a motion over the page limit states its word count.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nev-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("nev-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Caption column: the proceeding line, then each caption side (names, then designation).
/// Sides after the first are joined by "v." (the second side) and "and" (the rest).
#let caption-column(meta) = {
  set par(leading: single-leading, spacing: 0.4em, first-line-indent: 0pt)
  if "proceeding" in meta {
    inl(meta.proceeding)
    v(0.8em)
  }
  for (i, s) in meta.caption.enumerate() {
    if i > 0 {
      v(0.5em)
      if i == 1 [v.] else [and]
      v(0.5em)
    }
    for n in s.names [ #inl(n) \ ]
    emph(s.designation)
  }
}

/// Counsel group: names then the lines beneath, single-spaced, left aligned.
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for n in g.at("names", default: ()) [ #inl(n) \ ]
  for l in g.at("lines", default: ()) [ #inl(l) \ ]
  v(0.7em)
}

/// Signers of the signature block: "/s/" and the typed name, underlined,
/// with the typed name again below the underline; counsel lines follow.
#let signers(sig) = {
  if "signers" in sig { sig.signers } else { ((name: need(sig, "signer"), lines: ()),) }
}

#let signer-entry(s) = {
  underline[/s/ #s.name] + linebreak()
  [#s.name]
  for l in s.at("lines", default: ()) { linebreak() + inl(l) }
}

#let signature-block(sig, first-only: false) = {
  let all = signers(sig)
  let list = if first-only { (all.first(),) } else { all }
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #if "firm" in sig {
      if type(sig.firm) == str [ #strong(sig.firm) #v(0.8em) ] else [
        #for l in sig.firm [ #strong(l) \ ]
        #v(0.8em)
      ]
    }
    #for (i, s) in list.enumerate() {
      if i > 0 { v(0.9em) }
      signer-entry(s)
    }
    #if sig.at("lines", default: ()).len() > 0 {
      v(0.6em)
      for l in sig.lines [ #inl(l) \ ]
    }
  ])
}

/// Recipient groups of a certificate: each group is a list of lines, set single-spaced and indented.
#let recipient-groups(groups) = {
  for r in groups {
    block(above: 1em, below: 1em, breakable: false, pad(left: 1in)[
      #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
      #for l in r [ #inl(l) \ ]
    ])
  }
}

/// A certificate page: heading, paragraphs, recipient groups, closing paragraphs, closing recipient groups,
/// an optional date line, and the signature block. Used for the NRAP 27(e) certificate and the certificate of service.
#let certificate(c, default-sig) = {
  pagebreak(weak: true)
  // Printed as given (NRAP 27(e) Certificate keeps its lower-case "(e)"); not a level-1 heading, whose show rule upper-cases it.
  block(above: 0.4em, below: 1.2em, align(center, text(weight: "bold", c.at("heading", default: "CERTIFICATE OF SERVICE"))))
  for p in c.at("paragraphs", default: ()) { par(inl(p)) }
  recipient-groups(c.at("recipients", default: ()))
  for p in c.at("closing_paragraphs", default: ()) { par(inl(p)) }
  recipient-groups(c.at("closing_recipients", default: ()))
  if "date" in c { par(first-line-indent: (amount: para-indent, all: true), [DATED this #inl(c.date).]) }
  v(0.4em)
  signature-block(c.at("signature", default: default-sig), first-only: c.at("first_signer_only", default: true))
}

/// Table of authorities. Each entry carries `find`: a string that appears in every citation of
/// the authority in the body. A show rule on that string drops a marker after each occurrence;
/// the table lists the pages of the markers.
#let toa-marker(key) = [#metadata(key)<nev-toa>]

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
  let pages = query(<nev-toa>)
    .filter(m => m.value == key)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
  if pages.len() == 0 { [--] } else { pages.map(str).join(", ") }
}

#let authorities-table(meta) = {
  heading(level: 1, outlined: true)[Table of Authorities]
  set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 1.5em, justify: false)
  for group in meta.authorities {
    block(above: 1.2em, below: 0.8em, sticky: true, strong(group.heading))
    for e in group.entries {
      block(above: 0.9em, below: 0.9em, breakable: false)[
        #inl(e.cite) #box(width: 1fr, repeat[.#h(2pt)]) #h(4pt) #if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") }
      ]
    }
  }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let nev-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // NRAP 32(a)(4): page numbers at the bottom of each page; the cover is page 1.
  set page(paper: "us-letter", margin: page-margin, numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Heading levels in the markdown body: level 1 is a section (centred, capitals, bold);
  // level 2 and 3 are sub-headings (bold, left). The author types the section numbers.
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
    #text(weight: "bold", style: "italic", it.body)
  ]

  // Block quotations: indented, single-spaced (NRAP 32(a)(4)).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: 14 pt like the text (NRAP 32(a)(5)(B)), single-spaced (NRAP 32(a)(4)).
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)  // citations in footnotes count toward the table of authorities
  }

  // ---- Caption page (NRAP 27(d)(1)(B): court name, docket number, title of the case, descriptive title) ----
  page[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center)[#text(weight: "bold")[IN THE SUPREME COURT OF THE STATE OF NEVADA]]
    #v(0.3in)
    #grid(columns: (3.9in, 1fr), column-gutter: 0.25in,
      caption-column(meta),
      {
        set par(leading: single-leading, first-line-indent: 0pt)
        v(1.2em)
        inl(need(meta, "case_number"))
        v(1.6em)
        text(weight: "bold", inl(need(meta, "brief_title")))
        // NRAP 27(e)(2): an emergency motion states the date or event by which action is needed.
        if "emergency_statement" in meta {
          v(0.8em)
          text(weight: "bold", inl(meta.emergency_statement))
        }
      },
    )
    #v(1fr)
    // Counsel blocks sit at the foot of the caption page, two per row (filed Nevada captions do the same).
    #grid(columns: (1fr, 1fr), column-gutter: 0.3in, row-gutter: 0.25in,
      ..need(meta, "counsel").map(g => counsel-group(g)))
  ]

  // ---- Table of contents (only when the filing has one) ----
  if meta.at("toc", default: false) {
    page[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #align(center, text(weight: "bold")[TABLE OF CONTENTS])
      #v(0.5em)
      #show outline.entry: it => block(above: 0.9em, below: 0.9em, it)
      #outline(title: none, depth: toc-depth, indent: 1.5em)
    ]
  }

  // ---- Table of authorities (only when the metadata registers authorities) ----
  if "authorities" in meta {
    page(authorities-table(meta))
  }

  // ---- Body ----
  mark-authorities(meta, cmarker.render(body, raw-typst: false, smart-punctuation: true))

  // ---- Date, word-count certificate (NRAP 27(d)(2)(C), only when a count is stated), signature block ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #if "date" in meta { par(first-line-indent: (amount: para-indent, all: true), [DATED this #inl(meta.date).]) }
    #v(0.4em)
    #if "word_count" in meta {
      par(first-line-indent: (amount: para-indent, all: true))[#word-count-text(meta.word_count)]
      v(0.4em)
    }
    #signature-block(need(meta, "signature"))
  ]

  // ---- NRAP 27(e) certificate (emergency motions, NEV-MOT-010) ----
  if "emergency_certificate" in meta {
    certificate(meta.emergency_certificate, need(meta, "signature"))
  }

  // ---- Certificate of service ----
  if "service" in meta {
    certificate(meta.service, need(meta, "signature"))
  }
}
