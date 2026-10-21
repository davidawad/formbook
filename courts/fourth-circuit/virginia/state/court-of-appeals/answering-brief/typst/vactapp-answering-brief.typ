// Court of Appeals of Virginia (vactapp): opening brief of appellant. The same template serves the
// brief of appellee, the reply brief, motions and amicus briefs, each in its own doc folder
// (typst/vactapp-<doctype>.typ); only the frontmatter and the heading text differ.
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next to it
// (Rules of the Supreme Court of Virginia, Part Five A, vacourts.gov, rulesofcourt.pdf; see ../../rules.md).
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the INPUT
// (schema: ../../README.md, "Frontmatter").

#import "@preview/cmarker:0.1.10"
#import "../../../../../../../lib/typst/tables.typ": leader-row

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // Rule 5A:4(a): a font style on the Court's list (fontlist.pdf); Times New Roman is listed. Liberation Serif is its metric twin (docs/FONTS.md).
#let type-size = 14pt                     // Rule 5A:4(a): at least 14-point, footnotes included; text may not be reduced.
#let body-leading = 1.65em                // Rule 5A:4(a): double-spaced. About 2 x the single line of this face at 14 pt.
#let single-leading = 0.45em              // Rule 5A:4(a) excepts headings, assignments of error, quotations over 49 words, and footnotes.
#let page-margin = 1in                    // Rule 5A:4(a): at least one inch on all four sides.
#let para-indent = 0.5in                  // Tier 2: first-line indent of body paragraphs, as in the exemplars.
#let toc-depth = 3
#let sig-indent = 3.2in                   // Tier 2: counsel block and signature set right of centre, as in the exemplars.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("vactapp-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("vactapp-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One caption side: centred names, then the designation (italic, as in the exemplars).
#let caption-side(side) = {
  align(center)[
    #set par(leading: single-leading, spacing: 0.4em, first-line-indent: 0pt)
    #for n in side.names [ #inl(n) \ ]
    #emph(side.designation)
  ]
}

/// Thousands separators for the word count in the certificate.
#let commas(n) = {
  let s = str(n)
  let out = ""
  let count = 0
  for ch in s.clusters().rev() {
    if count > 0 and calc.rem(count, 3) == 0 { out = "," + out }
    out = ch + out
    count += 1
  }
  out
}

/// Counsel group: names (bold) then the lines beneath.
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for n in g.names [ #inl(n) \ ]
  for l in g.lines [ #inl(l) \ ]
  v(0.6em)
}

/// Signers of the signature block (Rule 5A:20(g), 5A:21(g)): "/s/" and the typed name, then bar number,
/// address, telephone, facsimile (if any) and e-mail.
#let signers(sig) = {
  if "signers" in sig { sig.signers } else { ((name: need(sig, "signer"), lines: ()),) }
}

#let signer-entry(s) = {
  underline[/s/ #emph(s.name)] + linebreak()
  [#s.name]
  for l in s.at("lines", default: ()) { linebreak() + inl(l) }
}

#let signature-block(sig) = {
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #if "firm" in sig [ #strong(sig.firm) #v(0.8em) ]
    #for (i, s) in signers(sig).enumerate() {
      if i > 0 { v(0.9em) }
      signer-entry(s)
    }
    #if sig.at("lines", default: ()).len() > 0 {
      v(0.6em)
      for l in sig.lines [ #inl(l) \ ]
    }
  ])
}

/// Table of authorities. Each entry carries `find`: a string that appears in every citation of the
/// authority in the body (e.g. the reporter cite "883 S.E.2d"). A show rule on that string drops a
/// marker after each occurrence; the table lists the pages of the markers.
#let toa-marker(key) = [#metadata(key)<vactapp-toa>]

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
  let pages = query(<vactapp-toa>)
    .filter(m => m.value == key)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
  if pages.len() == 0 { [--] } else { pages.map(str).join(", ") }
}

#let authorities-table(meta) = {
  heading(level: 1, outlined: false)[Table of Authorities]
  set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 1.5em, justify: false)
  for group in meta.authorities {
    block(above: 1.2em, below: 0.8em, sticky: true, strong(group.heading))
    for e in group.entries {
      block(above: 0.9em, below: 0.9em, breakable: false,
        leader-row(inl(e.cite), if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") },
          hang: 1.5em, dot-gap: 2pt, lead-gap: 0.4em, gutter: 4pt, min-leader: 1em))
    }
  }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let vactapp-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // Tier 2 convention in the exemplars: cover unnumbered; table pages roman; body arabic from 1.
  set page(paper: "us-letter", margin: (x: page-margin, top: page-margin, bottom: page-margin + 4pt), numbering: none)  // 4 pt extra at the foot: footnote descents stay inside the 1 in margin
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Heading levels in the markdown body: level 1 is a section (centred, capitals, bold);
  // level 2 and 3 are sub-headings (bold, left).
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

  // Block quotations: indented, single-spaced (Rule 5A:4(a): quotations over 49 words).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: 14 pt like the text (Rule 5A:4(a)), single-spaced (excepted by the same rule).
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)  // citations in footnotes count toward the table of authorities
  }

  // ---- Cover (Rule 5A:4(b)) ----
  page(numbering: none)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center)[
      #text(weight: "bold")[IN THE COURT OF APPEALS OF VIRGINIA] \
      #v(0.3in)
      #text(weight: "bold")[RECORD NO. #need(meta, "record_number")]
    ]
    #v(0.3in)
    #for (i, side) in meta.caption.enumerate() {
      if i > 0 { v(0.2in); align(center)[v.]; v(0.2in) }
      caption-side(side)
    }
    #v(0.4in)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #text(weight: "bold", upper(inl(need(meta, "brief_title"))))
    ]
    #v(1fr)
    #{
      set par(leading: single-leading, first-line-indent: 0pt)
      pad(left: sig-indent, {
        for g in need(meta, "counsel") { counsel-group(g) }
        if "counsel_for" in meta [ #emph(inl(meta.counsel_for)) \ ]
        if "date" in meta { inl(meta.date) }
      })
    }
    #v(0.3in)  // keeps the last cover line inside the 1 in bottom margin (Rule 5A:4(a))
  ]

  // ---- Front matter (roman numerals, Tier 2) ----
  set page(numbering: "i")
  counter(page).update(1)

  // ---- Table of contents (Rule 5A:20(a), 5A:21(a)) ----
  if meta.at("toc", default: true) {
    page[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #align(center, text(weight: "bold")[TABLE OF CONTENTS])
      #v(0.5em)
      #show outline.entry: it => block(above: 0.9em, below: 0.9em, it)
      #outline(title: none, depth: toc-depth, indent: 1.5em)
    ]
  }

  // ---- Table of authorities (Rule 5A:20(a), 5A:21(a): cases alphabetical, year of each citation) ----
  if "authorities" in meta {
    page(authorities-table(meta))
  }

  // ---- Body (arabic numerals from 1) ----
  set page(numbering: "1", number-align: center + bottom)
  counter(page).update(1)
  mark-authorities(meta, cmarker.render(body, raw-typst: false, smart-punctuation: true))

  // ---- Signature block (Rule 5A:20(g), 5A:21(g), 5A:22 has none beyond the certificate) ----
  if "signature" in meta {
    v(0.3in)
    signature-block(meta.signature)
  }

  // ---- Certificate (Rule 5A:20(h), 5A:21(h), 5A:22(c); word count Rule 5A:4(d)) ----
  if "certificate" in meta {
    let c = meta.certificate
    pagebreak(weak: true)
    heading(level: 1)[Certificate]
    if "service" in c { par(inl(c.service)) }
    if "oral_argument" in c { par(inl(c.oral_argument)) }
    if "words" in c { par(inl("This brief contains " + commas(c.words) + " words, excluding the cover page, table of contents, table of authorities, signature blocks, and this certificate. Headings, footnotes, and quotations are included in the count.")) }
    if "date" in c { par(inl(c.date)) }
    v(0.4em)
    if "signature" in meta { signature-block(meta.signature) }
  }
}
