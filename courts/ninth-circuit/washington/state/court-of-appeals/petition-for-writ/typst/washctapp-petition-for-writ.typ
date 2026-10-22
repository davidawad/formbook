// Court of Appeals of the State of Washington, personal restraint petition (RAP 16.3-16.7).
//
// Content-agnostic. Every number is a named parameter below and traces to the Washington rules cited next to it
// (RAP 16.7, 16.4, 18.17 and the court eval.yaml for type size and margins, as listed in rules.md); no coordinates
// measured off any filed petition, no forced line breaks. The markdown body is rendered by cmarker; the metadata
// is the YAML frontmatter of the sample (usage/INPUT-petition-for-writ.md and rules.md).

#import "@preview/cmarker:0.1.10"
#import "../../../../../../../lib/typst/tables.typ": leader-row

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // RAP 18.17(a)(2): 14-point serif equivalent to Times New Roman. Liberation Serif is the metric twin in fonts/ (docs/FONTS.md).
#let type-size = 14pt                      // RAP 18.17(a)(2): 14 point for all text, footnotes and block quotations (WASHCTAPP-FORM-004). Court eval.yaml: font.size_pt 14.
#let body-leading = 1.65em                 // RAP 18.17(a)(2): double spaced (WASHCTAPP-FORM-005).
#let single-leading = 0.45em               // Single spaced: footnotes, block quotations, headings, caption and counsel blocks (WASHCTAPP-FORM-005).
#let page-margin = (top: 1.5in, bottom: 1.6in, left: 2in, right: 1.5in)  // RAP 18.17(a)(1) (WASHCTAPP-FORM-002): 2 in left, 1.5 in right, top and bottom, at least. The bottom is 0.1 in deeper than the minimum so the descenders of the last line stay inside the margin.
#let para-indent = 0.5in
#let toc-depth = 5
#let sig-indent = 2.0in                    // signature and counsel blocks start right of centre (exemplar convention).
#let final-heading = "REQUEST FOR RELIEF"  // RAP 16.7(a)(5)-(6): the signed attorney block follows the conclusion and precedes the request for relief and the oath.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("washctapp-petition-for-writ: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("washctapp-petition-for-writ: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split the markdown body in two at the first heading that contains `key` (upper case).
/// The part from that heading on is set after the attorney's signature block.
#let split-at-heading(body, key) = {
  let lines = body.split("\n")
  let idx = lines.position(l => l.starts-with("#") and key in upper(l))
  if idx == none { (body, "") } else { (lines.slice(0, idx).join("\n"), lines.slice(idx).join("\n")) }
}

/// Lines of text, one per item, single spaced, with no extra space between them.
#let stacked(items, weight: "regular") = {
  for (i, it) in items.enumerate() {
    if i > 0 { v(single-leading) }
    block(width: 100%, text(weight: weight, it))
  }
}

/// One caption side: centred names, then the designation.
#let caption-side(side) = {
  align(center)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #stacked(side.names.map(n => inl(n)))
    #v(single-leading)
    #emph(side.designation)
  ]
}

/// Counsel group: names (bold) then the lines beneath.
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  stacked(g.names.map(n => strong(inl(n))))
  v(0.6em)
  stacked(g.lines.map(l => inl(l)))
}

/// Signers of the signature block: "/s/" and the typed name, underlined,
/// with the typed name again below the underline; counsel lines follow.
#let signers(sig) = {
  if "signers" in sig { sig.signers } else { ((name: need(sig, "signer"), lines: ()),) }
}

#let signer-entry(s) = {
  underline[/s/ #emph(s.name)] + linebreak()
  [#s.name]
  for l in s.at("lines", default: ()) { linebreak() + inl(l) }
}

#let signature-block(sig, first-only: false) = {
  let all = signers(sig)
  let list = if first-only { (all.first(),) } else { all }
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #if "firm" in sig [ #strong(sig.firm) #v(0.8em) ]
    #for (i, s) in list.enumerate() {
      if i > 0 { v(0.9em) }
      signer-entry(s)
    }
    #if sig.at("lines", default: ()).len() > 0 {
      v(0.6em)
      stacked(sig.lines.map(l => inl(l)))
    }
  ])
}

/// Table of authorities. Each entry carries `find`: a string that appears in every citation of
/// the authority in the body (e.g. "Crace"). A show rule on that string drops a marker after each
/// occurrence; the table lists the pages of the markers.
#let toa-marker(key) = [#metadata(key)<washctapp-toa>]

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
  let pages = query(<washctapp-toa>)
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
      block(above: 0.9em, below: 0.9em, breakable: false)[
        #leader-row(inl(e.cite), if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") }, hang: 1.5em)
      ]
    }
  }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let washctapp-petition-for-writ(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // RAP 18.17: pages are numbered at the bottom. The cover is not numbered; the front matter uses
  // lowercase Roman numerals; the petition from the first section on uses Arabic numerals.
  set page(paper: "us-letter", margin: page-margin, numbering: none, number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Heading levels in the markdown body: level 1 is a section (centred, capitals, bold).
  // Levels 2 to 5 are sub-headings, bold, indented one half inch per level below level 2.
  show heading.where(level: 1): it => block(width: 100%, above: 1.6em, below: 1.2em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, text(weight: "bold", upper(it.body)))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1.2em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #pad(left: 0pt, text(weight: "bold", it.body))
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #pad(left: 0.5in, text(weight: "bold", it.body))
  ]
  show heading.where(level: 4): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #pad(left: 1in, text(weight: "bold", it.body))
  ]
  show heading.where(level: 5): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #pad(left: 1.5in, text(weight: "bold", style: "italic", it.body))
  ]

  // Block quotations: indented, single-spaced (RAP 18.17(a)(2)).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: the same size and face as the text (RAP 18.17(a)(2)), single-spaced.
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)  // citations in footnotes count toward the table of authorities
  }

  // ---- Cover: Form 5 layout (RAP 16.7 and RAP Form 5; WASHCTAPP-COVER-001, -004) ----
  page[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center)[
      #stacked(need(meta, "court_heading"), weight: "bold")
      #v(0.3in)
      #need(meta, "case_number")
    ]
    #v(0.4in)
    #caption-side(meta.caption.at(0))
    #v(0.3in)
    #align(center)[v.]
    #v(0.3in)
    #caption-side(meta.caption.at(1))
    #v(1fr)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #text(weight: "bold", upper(inl(need(meta, "brief_title"))))
    ]
    #v(1fr)
    #align(right)[
      #block(width: 3.2in)[
        #for g in need(meta, "counsel") { counsel-group(g) }
      ]
    ]
  ]

  // ---- Front matter: lowercase Roman numerals ----
  set page(numbering: "i")

  // ---- Table of contents ----
  if meta.at("toc", default: true) {
    page[
      #counter(page).update(1)
      #set par(leading: single-leading, first-line-indent: 0pt)
      #align(center, text(weight: "bold")[TABLE OF CONTENTS])
      #v(0.5em)
      #show outline.entry: it => block(above: 0.9em, below: 0.9em, it)
      #outline(title: none, depth: toc-depth, indent: 1.5em)
    ]
  }

  // ---- Table of authorities ----
  if "authorities" in meta {
    page(authorities-table(meta))
  }

  // ---- Body: Arabic numerals from the first section of the petition ----
  set page(numbering: "1")
  counter(page).update(1)
  let (before, after) = split-at-heading(body, final-heading)
  mark-authorities(meta, cmarker.render(before, raw-typst: false, smart-punctuation: true))

  // ---- Attorney's date and signature after the conclusion (RAP 16.7(a)(6)) ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #if "date" in meta { par(first-line-indent: (amount: para-indent, all: true), inl(meta.date)) }
    #par(first-line-indent: (amount: para-indent, all: true))[Respectfully submitted,]
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]

  if after != "" {
    pagebreak(weak: true)
    mark-authorities(meta, cmarker.render(after, raw-typst: false, smart-punctuation: true))
  }

  // ---- Petitioner's oath, RAP 16.7(a)(6) ----
  if "oath" in meta {
    block(width: 100%, breakable: false)[
      #v(0.3in)
      #if "date" in meta.oath { par(first-line-indent: (amount: para-indent, all: true), inl(meta.oath.date)) }
      #v(0.4em)
      #signature-block((signer: meta.oath.signer))
    ]
  }

  // ---- Certificate of service, only when the frontmatter asks for one (RAP 18.5, 16.7) ----
  if "service" in meta {
    let svc = meta.service
    pagebreak(weak: true)
    heading(level: 1, outlined: false)[#svc.at("heading", default: "Certificate of Service")]
    for p in svc.at("paragraphs", default: ()) { par(inl(p)) }
    for r in svc.at("recipients", default: ()) {
      block(above: 1em, below: 1em, breakable: false, pad(left: 1in)[
        #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
        #stacked(r.map(l => inl(l)))
      ])
    }
    if "closing" in svc { par(inl(svc.closing)) }
    v(0.4em)
    signature-block(svc.at("signature", default: need(meta, "signature")), first-only: svc.at("first_signer_only", default: true))
  }
}
