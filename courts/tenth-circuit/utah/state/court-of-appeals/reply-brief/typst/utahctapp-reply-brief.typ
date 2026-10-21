// UTAH COURT OF APPEALS (utahctapp): Utah Court of Appeals reply brief (reply-brief).
//
// Content-agnostic. Every number is a named parameter below and traces to the court's brief
// checklists (Utah Rules of Appellate Procedure 24, 26, 27, as summarised in the Utah Courts
// Checklist for Briefs, revised December 2025, and the Checklist for Reply Briefs, revised
// May 2026; see ../../rules.md). No case-specific text, no coordinates measured off any filed
// brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the
// sample (schema: usage/INPUT-*.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")     // Times New Roman is the standard face (docs/FONTS.md); Liberation Serif is its metric-compatible substitute.
#let type-size = 14pt                    // Checklist: 13-point or larger for text and footnotes; the exemplars use 14-point, which is followed.
#let caption-size = 13pt                 // Checklist: the same 13-point minimum applies to the cover.
#let body-leading = 1.65em                 // Checklist: double spaced; 1 1/2 line spacing is not acceptable.
#let single-leading = 0.45em               // Checklist: block quotations and footnotes may be single spaced; headings are single spaced in the exemplars.
#let cover-leading = 0.3em                 // cover lines are set tighter so the cover stays on one page.
#let top-margin = 1in                      // Checklist: margins at least one inch on the top, bottom and both sides.
#let side-margin = 1in                     // Checklist: at least one inch on each side.
#let bottom-margin = 1.05in                // Checklist: at least one inch; a little more keeps footnote descenders clear of the 1 in line.
#let para-indent = 0.5in
#let toc-depth = 3
#let sig-indent = 3.2in                    // signature block starts right of centre.
#let court-name = "UTAH COURT OF APPEALS"                 // Checklist: "In the Utah Court of Appeals" (or Supreme Court) names the court on the cover.
#let court-address = ("PO Box 140230", "Salt Lake City, UT 84114-0230")        // Clerk's office mailing address (utcourts.gov appellate hours and location page).
#let use-box = (width: 2.6in, height: 1.2in)       // Case number box on the right of the caption.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("utahctapp-reply-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("utahctapp-reply-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Signature block (Checklist; the exemplars use "s/" and the typed name, then the attorney lines).
#let signature-block(sig) = {
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #underline[s/ #inl(sig.signer)]
    #for l in sig.at("lines", default: ()) [ #linebreak() #inl(l) ]
    #if "role" in sig [ #linebreak() #strong(sig.role) ]
  ])
}

// Table of authorities. Each entry carries `find`: a string that appears in every citation of
// the authority in the body. A show rule on that string drops a marker after each occurrence;
// the table lists the pages of the markers.
#let toa-marker(key) = [#metadata(key)<utahctapp-toa>]

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
  let pages = query(<utahctapp-toa>)
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
// Cover (Checklist: basic document information, preferred caption)
// ---------------------------------------------------------------------------

#let cover(meta) = {
  set par(leading: cover-leading, first-line-indent: 0pt, spacing: 0.5em)
  set text(size: caption-size)
  grid(
    columns: (1fr, use-box.width),
    column-gutter: 0.3in,
    [
      #court-name \
      #court-address.at(0) \
      #court-address.at(1)
      #v(0.8em)
      #for l in need(meta, "lower_court") [ #inl(l) \ ]
      #v(0.8em)
      #for p in need(meta, "parties") {
        if "designation" in p [ #emph(inl(p.designation)) \ ]
        if "names" in p {
          for n in p.names [ #inl(n) \ ]
        }
        v(0.4em)
      }
    ],
    box(width: use-box.width, height: use-box.height, stroke: 0.75pt, inset: 8pt, align(bottom)[
      #set par(leading: cover-leading, first-line-indent: 0pt)
      #align(center)[CASE NUMBER] \
      #v(0.6em)
       \
      #strong(inl(need(meta, "case_number")))
    ]),
  )
  v(0.8em)
  // Counsel groups in two columns so the cover stays on one page (Checklist).
  grid(
    columns: (1fr, 1fr),
    column-gutter: 0.3in,
    row-gutter: 0.6em,
    ..for c in need(meta, "counsel") {
      (block(breakable: false, [
        #set par(leading: cover-leading, first-line-indent: 0pt)
        #if "heading" in c [ #emph(inl(c.heading)) \ ]
        #for l in c.lines [ #inl(l) \ ]
      ]),)
    }
  )
  line(length: 100%, stroke: 0.75pt)
  align(center, block(above: 0.8em, below: 0.8em)[
    #text(weight: "bold", size: 16pt, upper(inl(need(meta, "brief_title"))))
  ])
  line(length: 100%, stroke: 0.75pt)
}

// ---------------------------------------------------------------------------
// Certificate of compliance (Checklist): the attorney certifies the word limit.
// The word count is the filer's own count, carried in the frontmatter (compliance.words).
// ---------------------------------------------------------------------------

#let compliance-page(meta) = {
  let c = meta.compliance
  heading(level: 1)[Certificate of Compliance]
  par(first-line-indent: (amount: para-indent, all: true))[
    I certify that this brief complies with the requirements of #c.at("rules", default: "$rphrase"), including:
  ]
  block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    Word Limits: My brief has #c.words words, which is less than the #c.limit word limit. This brief does not contain any non-public information (URAP 21).
    #if "extra" in c [ \ #inl(c.extra) ]
  ]
  par(first-line-indent: (amount: para-indent, all: true))[I understand that my brief may be rejected if I fail to comply with these rules.]
  v(0.4em)
  signature-block(need(meta, "signature"))
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let utahctapp-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // Pages: the cover is unnumbered, the tables are roman, the body is arabic from 1.
  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: side-margin, right: side-margin),
    numbering: none,
    number-align: center + bottom,
  )
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Heading levels in the markdown body: level 1 is a section (centred, capitals, bold);
  // level 2 is a point heading (bold, left); level 3 is a sub-point (bold italic, left).
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

  // Block quotations: indented, single-spaced (Checklist).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: 14 pt like the text (Checklist), single-spaced (Checklist).
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)  // citations in footnotes count toward the table of authorities
  }

  // ---- Cover (unnumbered) ----
  page[#cover(meta)]

  // Checklist and 28 (exemplars): the certificate of compliance sits either right behind the
  // cover (position: front, roman) or as the first body page (position: body, arabic). Default: body.
  let cert-front = meta.at("compliance", default: (:)).at("position", default: "body") == "front"
  if cert-front and "compliance" in meta {
    page(numbering: "i", compliance-page(meta))
  }

  // ---- Table of contents and table of authorities (roman numerals) ----
  if meta.at("toc", default: true) {
    page(numbering: "i")[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #align(center, text(weight: "bold")[TABLE OF CONTENTS])
      #v(0.5em)
      #show outline.entry: it => block(above: 0.9em, below: 0.9em, it)
      #outline(title: none, depth: toc-depth, indent: 1.5em)
    ]
  }
  if "authorities" in meta {
    page(numbering: "i", authorities-table(meta))
  }

  // ---- Body (arabic from 1) ----
  pagebreak(weak: true)
  set page(numbering: "1")
  counter(page).update(1)

  if "compliance" in meta and not cert-front {
    compliance-page(meta)
    pagebreak()
  }

  mark-authorities(meta, cmarker.render(body, raw-typst: false, smart-punctuation: true))

  // ---- Signature block after the conclusion ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #if "date" in meta { par(first-line-indent: (amount: para-indent, all: true), inl(meta.date)) }
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]

  // ---- Certificate of service (last page, when the filing has one) ----
  if "service" in meta {
    let svc = meta.service
    pagebreak(weak: true)
    heading(level: 1)[Certificate of Service]
    for p in svc.at("paragraphs", default: ()) { par(first-line-indent: (amount: para-indent, all: true), inl(p)) }
    v(0.4em)
    signature-block(svc.signature)
  }
}
