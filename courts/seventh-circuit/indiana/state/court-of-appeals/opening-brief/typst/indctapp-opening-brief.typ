// Indiana Court of Appeals (indctapp): appellant's brief, appellee's brief and reply brief (Ind. App. R. 43, 44, 46).
//
// Content-agnostic: every number is a named parameter and traces to the rule cited beside it (Indiana Rules of
// Appellate Procedure, effective 2025-01-01; ../../rules.md, INDCTAPP-FORM-*, -CONT-*). No case-specific text, no
// measured coordinates, no forced line breaks. The metadata is the sample's YAML frontmatter; the body is markdown
// rendered by cmarker: `#` a section (centred, bold), `##` an argument heading, `###` a sub-heading.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // INDCTAPP-FORM-002/003 (App. R. 43(D)): Times New Roman.
#let type-size = 12pt                      // INDCTAPP-FORM-002 (App. R. 43(D)): 12-point or larger, text and footnotes.
#let body-leading = 1.6em                  // INDCTAPP-FORM-004 (App. R. 43(E)): double-spaced; with the 1.15 em line box this is two lines' pitch.
#let single-leading = 0.45em               // INDCTAPP-FORM-004: footnotes, tables, blocked quotations single-spaced (>= 4 pt between lines).
#let margin-all = 1in                      // INDCTAPP-FORM-006 (App. R. 43(G)): all four margins at least one inch.
#let header-ascent = 0.3in                 // INDCTAPP-FORM-007 (App. R. 43(H)): running header at the left, above the text.
#let para-indent = 0.5in
#let toc-depth = 3
#let counsel-indent = 2.2in                // INDCTAPP-FORM-008: the counsel block sits right of the left margin on the front page.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("indctapp-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("indctapp-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// A caption line: a leading "~" indents it.
#let cap-line(s) = {
  let n = s.len() - s.trim("~", at: start).len()
  if n > 0 { h(0.5in * n) + inl(s.slice(n)) } else { inl(s) }
}

/// Front page caption. `parens`: the parties and the lower court in two columns with a column of parentheses
/// between; `rule`: the same two columns divided by a vertical rule.
#let caption-block(meta, style) = {
  let cap = need(meta, "caption")
  set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
  if style == "rule" {
    grid(columns: (1fr, 1fr), column-gutter: 0pt,
      block(inset: (right: 0.2in), stroke: (right: 0.5pt), width: 100%)[
        #for l in cap.left [ #cap-line(l) \ ]
      ],
      block(inset: (left: 0.2in), width: 100%)[
        #for l in cap.right [ #cap-line(l) \ ]
      ])
  } else {
    let n = cap.left.len()
    grid(columns: (1fr, 0.3in, 1fr), row-gutter: single-leading,
      ..for i in range(n) {
        (cap-line(cap.left.at(i)), [)], if i < cap.right.len() { cap-line(cap.right.at(i)) } else { [] })
      })
  }
}

#let signature-block(sig) = {
  block(width: 100%, breakable: false, pad(left: 3in)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #for (i, l) in sig.lines.enumerate() [ #if i > 0 [ \ ] #inl(l) ]
  ])
}

// Table of authorities: each entry's `find` string, wherever it occurs in the body, drops a marker; the table lists
// the pages of the markers (INDCTAPP-CONT-004: every page on which the authority is cited).
#let toa-marker(key) = [#metadata(key)<indctapp-toa>]

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
  let pages = query(<indctapp-toa>)
    .filter(m => m.value == key)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
  if pages.len() == 0 { [--] } else if pages.len() > 4 { [passim] } else { pages.map(str).join(", ") }
}

#let authorities-table(meta) = {
  align(center, text(weight: "bold")[Table of Authorities])
  set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 1.5em, justify: false)
  for group in meta.authorities {
    block(above: 1.2em, below: 0.8em, sticky: true, align(center, emph(group.heading)))
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

#let indctapp-brief(meta, body, caption-style: "parens") = {
  set document(title: need(meta, "brief_title"))
  // INDCTAPP-FORM-001, -005, -006, -007: letter; every page numbered at the bottom from the front page (1); every page
  // after the front page carries the left-aligned running header naming the filer and the document.
  set page(
    paper: "us-letter",
    margin: margin-all,
    header-ascent: header-ascent,
    header: context {
      if counter(page).get().first() > 1 {
        set par(leading: 0.3em, first-line-indent: 0pt)
        set text(size: type-size)
        align(left, need(meta, "running_header").map(l => inl(l)).join(linebreak()))
      }
    },
    footer: context align(center, counter(page).display()),
    numbering: "1",
  )
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 1em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, text(size: type-size, weight: "bold", it.body))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1.2em, below: 0.9em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(size: type-size, weight: "bold", it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #pad(left: 0.5in, text(size: type-size, weight: "bold", style: "italic", it.body))
  ]
  // Blocked and indented quotations: single-spaced (INDCTAPP-FORM-004).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  show footnote.entry: it => {
    set par(leading: single-leading, first-line-indent: 0pt)
    pad(bottom: 0.25em, mark-authorities(meta, it))
  }

  // ---- Front page (INDCTAPP-FORM-008, App. R. 43(I)) ----
  page[
    #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    #align(center, text(weight: "bold")[
      #for l in need(meta, "court_lines") [ #l \ ]
      #if "case_number" in meta [ #meta.case_number ]
    ])
    #v(0.35in)
    #text(weight: if caption-style == "rule" or not meta.at("caption_bold", default: true) { "regular" } else { "bold" }, caption-block(meta, caption-style))
    #v(0.45in)
    #align(center, {
      let t = text(weight: "bold", upper(need(meta, "brief_title")))
      if meta.at("title_underline", default: false) { underline(t) } else { t }
    })
    #v(if caption-style == "rule" { 1fr } else { 0.2in })
    #pad(left: meta.at("counsel_indent", default: 2.2) * 1in, {
      for g in need(meta, "counsel") {
        for l in g [ #inl(l) \ ]
        v(0.8em)
      }
    })
  ]

  // ---- Tables (INDCTAPP-CONT-003, -004) ----
  page[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, text(weight: "bold")[Table of Contents])
    #v(0.5em)
    #show outline.entry: it => block(above: 0.9em, below: 0.9em, it)
    #outline(title: none, depth: toc-depth, indent: 1.5em)
    #if "authorities" in meta [
      #pagebreak(weak: true)
      #authorities-table(meta)
    ]
  ]

  // ---- Body ----
  mark-authorities(meta, cmarker.render(body, raw-typst: false, smart-punctuation: true))

  // ---- Conclusion signature (INDCTAPP-CONT-013) ----
  v(0.3in)
  signature-block(need(meta, "signature"))

  // ---- Word count certificate (INDCTAPP-LEN-003, App. R. 44(F)) ----
  if "word_count" in meta {
    pagebreak(weak: true)
    align(center, text(weight: "bold")[#meta.at("word_count_title", default: "Word Count Verification")])
    par(inl(meta.word_count))
    v(0.4em)
    signature-block(meta.at("cert_signature", default: need(meta, "signature")))
  }

  // ---- Certificate of service (INDCTAPP-SVC-001, App. R. 24(D)) ----
  if "service" in meta {
    let svc = meta.service
    v(1em)
    align(center, text(weight: "bold")[#meta.at("service_title", default: "Certificate of Service")])
    for p in svc.paragraphs { par(inl(p)) }
    for r in svc.at("recipients", default: ()) {
      block(above: 1em, below: 1em, breakable: false, pad(left: 1in)[
        #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
        #for l in r [ #inl(l) \ ]
      ])
    }
    v(0.4em)
    signature-block(meta.at("cert_signature", default: need(meta, "signature")))
  }
}
