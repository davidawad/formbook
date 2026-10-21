// Appellate Court of Maryland (mdctspecapp): reply-brief.
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next to it
// (Maryland Rules 1-301(c), 8-112, 8-503, 8-504, Rules Orders of Apr. 21, 2023 (ro215) and the
// Title 1 and 8 Rules Order (ro223); Supreme Court administrative order on approved fonts, Sept. 27,
// 2023; see ../../rules.md). No case-specific text, no coordinates measured off any filed brief, no
// forced line breaks. The markdown body is rendered by cmarker; the cover, caption, counsel,
// authorities and certificates come from the YAML frontmatter of the sample (usage/INPUT-opening-brief.md).

#import "@preview/cmarker:0.1.10"
#import "../../../../../../../lib/typst/tables.typ": leader-page as shared-leader-page

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")     // Rule 8-112(c)(1): Times New Roman is on the Supreme Court's approved list (admin. order Sept. 27, 2023, para. 3); Liberation Serif is its metric-compatible substitute (docs/FONTS.md).
#let type-size = 13pt                      // Rule 8-112(c)(1): proportionally spaced type in text and footnotes not smaller than 13 point.
#let body-leading = 1.65em                 // Rule 8-112(c)(2): double spacing between lines. Baseline pitch about 2 x the single-spaced line of this face.
#let single-leading = 0.45em               // Rule 8-112(c)(2) exclusions: headings, indented quotations and footnotes may be single-spaced.
#let page-margin = 1in                     // Rule 1-301(c) and Rule 8-112: at least one inch at top, bottom and each side.
#let para-indent = 0.5in
#let toc-depth = 3
#let sig-indent = 3.2in                    // signature block starts right of centre (style; exemplars do the same).
// Rule 8-503(g): the certificate is in the form the Appellate Court publishes ("substantially in the following form").
#let word-count-heading = "CERTIFICATION OF WORD COUNT AND COMPLIANCE WITH RULE 8-112"

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mdctspecapp-reply-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("mdctspecapp-reply-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One caption side: centred names, then the designation.
#let caption-side(side) = {
  align(center)[
    #set par(leading: single-leading, spacing: 0.4em)
    #for n in side.names [ #inl(n) \ ]
    #emph(side.designation)
  ]
}

/// Counsel group: names (bold) then the lines beneath.
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for n in g.names [ #strong(n) \ ]
  for l in g.lines [ #inl(l) \ ]
  v(0.6em)
}

/// Signers of the signature block. Rule 8-504(a): the signature block follows the body; "/s/" and the typed name.
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
      for l in sig.lines [ #inl(l) \ ]
    }
  ])
}

/// Table of authorities. Each entry carries `find`: a string that appears in every citation of
/// the authority in the body (e.g. the case name as written). A show rule on that string drops a
/// marker after each occurrence; the table lists the pages of the markers.
#let toa-marker(key) = [#metadata(key)<mdctspecapp-toa>]

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
  let pages = query(<mdctspecapp-toa>)
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
        #inl(e.cite)#shared-leader-page(if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") }, 2pt, gap: 4pt)
      ]
    }
  }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let mdctspecapp-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // Rule 8-112 and Rule 8-504: pages numbered consecutively; the cover is page 1 and is not numbered.
  set page(paper: "us-letter", margin: page-margin, numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Heading levels in the markdown body: level 1 is a section (centred, capitals, bold);
  // level 2 and 3 are sub-headings (bold, left).
  show heading.where(level: 1): it => block(width: 100%, above: 1.6em, below: 1.2em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, text(weight: "bold", it.body))
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

  // Block quotations: indented, single-spaced (Rule 8-112(c)(2) exclusion).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: at the same 13 point size as the text (Rule 8-112(c)(1)), single-spaced (Rule 8-112(c)(2)).
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)  // citations in footnotes count toward the table of authorities
  }

  // ---- Cover (Rule 8-504: caption and title; the cover color is a physical card stock, not a template property) ----
  page[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center)[
      #text(weight: "bold")[IN THE APPELLATE COURT OF MARYLAND] \
      #v(0.3in)
      #if "sept_term" in meta [ #meta.sept_term \ #v(0.2in) ]
      #text(weight: "bold")[No. #need(meta, "case_number")]
    ]
    #v(0.3in)
    #caption-side(meta.caption.at(0))
    #v(0.2in)
    #align(center)[v.]
    #v(0.2in)
    #caption-side(meta.caption.at(1))
    #v(0.3in)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #if "proceeding" in meta { inl(meta.proceeding) }
    ]
    #v(1fr)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #text(weight: "bold", size: 16pt, upper(inl(need(meta, "brief_title"))))
      #if "oral_argument" in meta [ \ #v(0.3in) #text(weight: "bold", inl(meta.oral_argument)) ]
    ]
    #v(1fr)
    #{
      set par(leading: single-leading, first-line-indent: 0pt)
      pad(left: sig-indent, {
        for g in need(meta, "counsel") { counsel-group(g) }
      })
    }
    #if "date" in meta [ #v(0.3in) #align(center)[Filed: #inl(meta.date)] ]
  ]

  // ---- Table of contents (Rule 8-504(a)(1)) ----
  if meta.at("toc", default: true) {
    page[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #align(center, text(weight: "bold")[TABLE OF CONTENTS])
      #v(0.5em)
      #show outline.entry: it => block(above: 0.9em, below: 0.9em, it)
      #outline(title: none, depth: toc-depth, indent: 1.5em)
    ]
  }

  // ---- Table of authorities (Rule 8-504(a)(1)) ----
  if "authorities" in meta {
    page(authorities-table(meta))
  }

  // ---- Body ----
  mark-authorities(meta, cmarker.render(body, raw-typst: false, smart-punctuation: true))

  // ---- Signature block (Rule 8-504), with the Rule 8-503(g) certificate just above it ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #if "date" in meta { par(first-line-indent: (amount: para-indent, all: true), inl(meta.date)) }
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]

  // ---- Certificate of word count and compliance (Rule 8-503(g)) ----
  pagebreak(weak: true)
  heading(level: 1)[#word-count-heading]
  par(first-line-indent: (amount: para-indent, all: true))[
    This brief contains #if "word_count" in meta [#meta.word_count] else [\_\_\_\_] words, excluding the parts of the brief exempted from the word count by Rule 8-503. This brief complies with the font, spacing, and type size requirements stated in Rule 8-112.
  ]
  v(0.4em)
  signature-block(need(meta, "signature"), first-only: true)

  // ---- Certificate of service ----
  if "service" in meta {
    let svc = meta.service
    pagebreak(weak: true)
    heading(level: 1)[Certificate of Service]
    for p in svc.at("paragraphs", default: ()) { par(inl(p)) }
    for r in svc.at("recipients", default: ()) {
      block(above: 1em, below: 1em, breakable: false, pad(left: 1in)[
        #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
        #for l in r [ #inl(l) \ ]
      ])
    }
    if "closing" in svc { par(inl(svc.closing)) }
    v(0.4em)
    signature-block(need(meta, "signature"), first-only: svc.at("first_signer_only", default: true))
  }
}
