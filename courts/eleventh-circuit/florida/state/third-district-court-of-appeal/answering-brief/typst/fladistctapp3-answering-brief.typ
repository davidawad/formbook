// Third District Court of Appeal (fladistctapp3): briefs and petitions (answering-brief).
// Form: Fla. R. App. P. 9.045(b): Arial 14 point (Liberation Sans, metric-compatible), black, double-spaced;
// footnotes and quotations at 14 point; headings may be single-spaced; margins at least 1 inch
// (Fla. R. Gen. Prac. & Jud. Admin. 2.520(a)(3)). Certificate of compliance: Rule 9.045(e).
// See ../../rules.md for every requirement ID and source.
//
// Content-agnostic. Every number is a named parameter below. No case text, no coordinates measured off any
// filed paper, no forced line breaks. The markdown body is rendered by cmarker; the metadata is the YAML
// frontmatter of the sample.

#import "@preview/cmarker:0.1.10"
/// Repeating dot leader used in tables of contents and authorities.
#let dot-leader(gap) = box(width: 1fr, repeat[.#h(gap)])

/// A linked outline row. Its page number follows the leader on the final wrapped line.
/// Courts supply their own labels, indentation, display title, and page label.
#let outline-row(target, title, label, indent, label-width, page, leading, dot-gap,
  above: 0.35em, page-width: 2.6em) = link(target, block(
  width: 100%, above: above, below: 0pt,
  par(hanging-indent: indent + label-width, first-line-indent: 0pt,
    leading: leading, justify: false, {
      h(indent)
      if label != none { box(width: label-width, label) }
      title
      h(0.8em)
      dot-leader(dot-gap)
      box(width: page-width, align(right, page))
    }),
))

/// A linked outline row with a separate page column, for courts that keep page labels on the bottom edge.
#let grid-outline-row(target, title, label, indent, label-width, page, leading, dot-gap,
  above: 0.45em, page-gap: 0.4em, page-width: 2em) = link(target, block(
  width: 100%, above: above, below: 0pt,
  grid(columns: (1fr, auto), column-gutter: page-gap,
    par(hanging-indent: indent + label-width, first-line-indent: 0pt,
      leading: leading, justify: false, {
        h(indent)
        if label != none { box(width: label-width, label) }
        title
        h(0.2em)
        dot-leader(dot-gap)
      }),
    align(right + bottom, box(width: page-width, align(right, page))),
  ),
))

/// One table-of-contents or table-of-authorities entry whose page reference can never wrap alone (DEF-TOC-001).
/// The title wraps under `hang`, dot leaders fill the rest of its last line, and the page reference sits in its
/// own column, level with that last line. `page-width` (auto: the reference's own width) also narrows every
/// line of the title, as LaTeX's \@tocrmarg does. `leading: auto` inherits the paragraph leading. A
/// `min-leader` above 0pt keeps at least that much leader, glued to the title's last word and to the fill (the
/// word moves down with it when the line is full), so the entry always prints some dots.
#let leader-row(title, page, hang: 0pt, dot-gap: 0.16em, lead-gap: 0.6em, gutter: 0.3em, page-width: auto,
  leading: auto, min-leader: 0pt) = grid(
  columns: (1fr, page-width), column-gutter: gutter, align: (left, right + bottom),
  {
    set par(leading: leading) if leading != auto
    par(hanging-indent: hang, first-line-indent: 0pt, justify: false, {
      title
      if min-leader > 0pt {
        sym.wj
        box({ h(lead-gap); box(width: min-leader, repeat[.#h(dot-gap)]) })
        sym.wj
      } else {
        h(lead-gap)
      }
      dot-leader(dot-gap)
    })
  },
  page,
)

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = "Liberation Sans"        // Rule 9.045(b): Arial 14 point (docs/FONTS.md substitution table).
#let type-size = 14pt                       // Rule 9.045(b): 14 point, footnotes and quotations included.
#let body-leading = 1.2em                   // Rule 9.045(b): double-spaced text.
#let single-leading = 0.45em                // Rule 9.045(b): footnotes, quotations and headings may be single-spaced.
#let page-margin = (top: 1.05in, bottom: 1in, left: 1in, right: 1.1in)   // Rule 2.520(a)(3): at least 1 inch. Top and right are slightly deeper so footnote marks and justified overhang stay inside the margin.
#let para-indent = 0.5in
#let sig-indent = 2.5in   // narrower than the 3.2in opening-brief indent so the longest unbroken e-mail address in the service list stays inside the right margin
#let court-lines = ("IN THE DISTRICT COURT OF APPEAL OF FLORIDA", "THIRD DISTRICT")   // The court's name on the cover (Rule 9.210(a)(1)).

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("fladistctapp3: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("fladistctapp3: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One caption side: party names, then the designation indented beneath.
#let caption-side(side) = {
  set par(leading: single-leading, first-line-indent: 0pt, spacing: 0.5em)
  for n in side.names [ #inl(n) \ ]
  if side.designation != "" { pad(left: 1.2in)[#emph(inl(side.designation))] }
}

/// Counsel group for the cover: names and lines beneath.
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for n in g.names [ #inl(n) \ ]
  for l in g.lines [ #inl(l) \ ]
}

/// Signature block: "/s/" typed signature, then the counsel lines.
#let signature-block(sig) = block(width: 100%, breakable: false, pad(left: sig-indent)[
  #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt, justify: false)
  /s/ #inl(sig.signer) \
  #for l in sig.at("lines", default: ()) [ #inl(l) \ ]
])

/// Table of authorities. Each entry carries `find`: a plain-text string that appears in every citation of the
/// authority in the body. A show rule on that string drops a marker after each occurrence; the table lists the pages.
#let toa-marker(key) = [#metadata(key)<fl-toa>]

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
  let pages = query(<fl-toa>)
    .filter(m => m.value == key)
    .map(m => numbering(m.location().page-numbering(), ..counter(page).at(m.location())))
    .dedup()
  if pages.len() == 0 { [--] } else { pages.map(str).join(", ") }
}

#let authorities-table(meta) = {
  heading(level: 1, outlined: false, numbering: none)[Table of Citations]
  set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 1.5em, justify: false)
  for group in meta.authorities {
    block(above: 1.2em, below: 0.8em, sticky: true, strong(group.heading))
    for e in group.entries {
      block(above: 0.9em, below: 0.9em, breakable: false)[
        #leader-row(inl(e.cite), if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") }, hang: 1.5em, leading: single-leading, lead-gap: 0.6em, gutter: 0.3em, min-leader: 1.5em)
      ]
    }
  }
}

/// Words the filer's certificate of compliance counts (Rule 9.045(e)): the body from the first section through the
/// conclusion, headings, footnotes and quotations included; cover, tables, certificates and signature block excluded.
#let count-words(body) = {
  let t = body.replace(regex("\\[\\^[^\\]]*\\]"), " ").replace(regex("\\[([^\\]]*)\\]\\([^)]*\\)"), "$1")
  t.split(regex("\\s+")).filter(w => w.match(regex("[A-Za-z0-9]")) != none).len()
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let fladistctapp3-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  set page(paper: "us-letter", margin: page-margin, numbering: "i", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: true)

  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 1em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, justify: false)
    #align(center, text(weight: "bold", upper(it.body)))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, justify: false, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, justify: false, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 4): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, justify: false, hanging-indent: 0.5in)
    #text(weight: "bold", style: "italic", it.body)
  ]
  // Block quotations: indented, single-spaced, same size.
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt, justify: true)
    #it.body
  ]
  // Footnotes: the same size as the text, single-spaced.
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    it
  }

  // ---- Cover ----
  page(numbering: none)[
    #set par(leading: single-leading, first-line-indent: 0pt, justify: false)
    #align(center)[
      #text(weight: "bold", court-lines.at(0)) \
      #text(weight: "bold", court-lines.at(1)) \
      #v(0.2in)
      #if "case_number" in meta [ #need(meta, "case_number") \ ]
      #if "lt_case_number" in meta [ #meta.lt_case_number \ ]
    ]
    #v(0.2in)
    #for side in need(meta, "caption") [
      #caption-side(side)
      #v(0.15in)
    ]
    #v(0.2in)
    #align(center)[
      #if "proceeding" in meta [ #inl(meta.proceeding) \ ]
    ]
    #v(1fr)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #text(weight: "bold", upper(inl(need(meta, "brief_title"))))
    ]
    #v(1fr)
    #{
      set par(leading: single-leading, first-line-indent: 0pt)
      // unequal columns: the right column must fit the longest unbroken e-mail address on the cover
      grid(columns: (1fr, 1.4fr), gutter: 0.3in, ..need(meta, "counsel").map(g => counsel-group(g)))
    }
  ]

  // ---- Table of contents (generated from the headings) ----
  if meta.at("toc", default: true) {
    page[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #align(center, text(weight: "bold")[TABLE OF CONTENTS])
      #v(0.5em)
      #show outline.entry: it => block(width: 100%, above: 0.6em, below: 0.6em, pad(left: (it.level - 1) * 0.4in, link(it.element.location(), leader-row(it.element.body, it.page(), hang: 0.5in, leading: single-leading, lead-gap: 0.6em, gutter: 0.3em, min-leader: 1.5em))))
      #outline(title: none, depth: 3, indent: 0pt)
    ]
  }

  // ---- Table of citations ----
  if "authorities" in meta {
    page(authorities-table(meta))
  }

  // ---- Body ----
  pagebreak(weak: true)
  set page(numbering: "1")
  counter(page).update(1)
  mark-authorities(meta, cmarker.render(body, raw-typst: false, smart-punctuation: true))

  // ---- Signature block ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #pad(left: sig-indent)[#set par(first-line-indent: 0pt); Respectfully submitted,]
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]

  // ---- Certificate of compliance (Rule 9.045(e)) ----
  pagebreak(weak: true)
  heading(level: 1, numbering: none)[Certificate of Compliance]
  let words = count-words(body)
  par(first-line-indent: (amount: para-indent, all: true))[
    I certify that this #need(meta, "document_name") complies with the font and word count requirements of #need(meta, "compliance_rule"). This #need(meta, "document_name") is computer-generated, is set in Arial 14-point font, and contains #words words, excluding the parts of the document exempted by Rule 9.045(e).
  ]
  v(0.4em)
  signature-block(need(meta, "signature"))

  // ---- Certificate of service ----
  heading(level: 1, numbering: none)[Certificate of Service]
  par(first-line-indent: (amount: para-indent, all: true), inl(need(meta, "service")))
  v(0.4em)
  signature-block((signer: need(meta, "signature").signer, lines: need(meta, "signature").at("lines", default: ()).slice(0, 2)))
}
