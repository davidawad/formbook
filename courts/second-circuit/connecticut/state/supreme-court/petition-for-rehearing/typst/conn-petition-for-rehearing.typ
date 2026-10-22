// Connecticut Supreme Court: conn-petition-for-rehearing template. Requirement IDs (CONN-...) refer to ../../rules.md.
// Rule-driven and content-agnostic: no case-specific text, no coordinates measured off a filing, no forced
// line breaks. The body is Markdown rendered by cmarker; cover, counsel, authorities and certifications come from
// the YAML frontmatter of the INPUT (keys documented in the frontmatter of usage/INPUT-*.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters: the only numbers in this file. Each traces to a rule or a style choice.
// ---------------------------------------------------------------------------

#let font-family = "Times New Roman"  // CONN-FORM-002: a serif face (P.B. 67-2A(b)); Times New Roman for every template
#let type-size = 12pt                 // CONN-FORM-002: 12-point serif, footnotes included
#let head-size = 14pt                 // CONN-FORM-002: headings in 14-point serif
#let body-leading = 0.575em           // CONN-FORM-004: line spacing of 1.5 (a single line is about 1.15 em in this face)
#let single-leading = 0.3em           // cover, counsel, signature and certification blocks only (style choice)
#let para-spacing = 0.575em           // one line at 1.5 spacing between paragraphs (style choice)
#let para-indent = 0.5in              // first-line indent (style choice)
#let page-margin = 1.5in              // CONN-FORM-003: 1 and 1/2 inches on all sides (P.B. 67-2A(b))
#let toc-depth = 3

// Per-document constants, set in each doc folder's copy of this file.
#let doc-noun = "motion"                            // the filing's own name in the certifications
#let word-rule = "Practice Book § 66-2(b)"           // the length rule the word-count certification cites
#let redaction-cert = false                          // CONN-CERT-002 (P.B. 67-2A(f)(2)): briefs only

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("conn-petition-for-rehearing: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("conn-petition-for-rehearing: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A field that may be one string or a list of lines.
#let as-lines(v) = if type(v) == str { (v,) } else { v }

#let lines-of(items, bold: false) = stack(
  dir: ttb,
  spacing: 0.3em,
  ..as-lines(items).map(l => if bold { text(weight: "bold", [#l]) } else { [#l] }),
)

// ---------------------------------------------------------------------------
// Cover (CONN-COVER-001, P.B. 67-2A(d): court, docket, case name, nature of the brief, counsel)
// ---------------------------------------------------------------------------

#let counsel-grid(groups) = grid(
  columns: (1fr,) * calc.min(groups.len(), 2),
  column-gutter: 1.2em,
  row-gutter: 1.2em,
  ..groups.map(g => stack(
    dir: ttb,
    spacing: 0.3em,
    ..if "role" in g { ([#text(style: "italic")[#g.at("role")]],) } else { () },
    ..as-lines(g.at("names")).map(n => [#n]),
    ..as-lines(g.at("lines")).map(l => [#l]),
  )),
)

#let cover(meta) = {
  set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
  align(center, lines-of(need(meta, "court"), bold: true))
  v(1.2em)
  align(center)[#need(meta, "docket")]
  v(1.5em)
  align(center, lines-of(need(meta, "case_title")))
  v(1.5em)
  align(center)[#text(weight: "bold")[#need(meta, "title")]]
  v(1.5em)
  set align(left)
  counsel-grid(need(meta, "counsel"))
}

// Caption at the head of the first page, for a filing without a separate cover (P.B. 66-2).
#let caption(meta) = {
  set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
  align(center, lines-of(need(meta, "court"), bold: true))
  v(1.2em)
  grid(
    columns: (1fr, auto),
    align(left, lines-of(need(meta, "case_title"))),
    align(right + top, [#need(meta, "docket")]),
  )
  v(1.5em)
  align(center)[#text(weight: "bold")[#need(meta, "title")]]
  v(1.5em)
}

// ---------------------------------------------------------------------------
// Table of contents (P.B. 67-4(a), 67-5(a)) and table of authorities (P.B. 67-4(c), 67-5(c), 67-11).
// A citation is marked in the body as a Markdown link to toa:<key>; the link text is the citation as printed.
// The authority list in frontmatter (key, category, text) gives the entries; pages come from the rendered body.
// ---------------------------------------------------------------------------

#let toc-page() = {
  align(center)[#text(size: head-size, weight: "bold")[TABLE OF CONTENTS]]
  v(1em)
  outline(title: none, depth: toc-depth, indent: 2em)
}

#let toa-page(meta) = {
  align(center)[#text(size: head-size, weight: "bold")[TABLE OF AUTHORITIES]]
  v(1em)
  context {
    let cites = query(<toa-cite>)
    for (cat, title) in (
      ("cases", "Cases"),
      ("constitutional", "Constitutional Provisions"),
      ("statutes", "Statutes"),
      ("rules", "Rules"),
      ("other", "Other Authorities"),
    ) {
      let items = meta.at("authorities", default: ()).filter(a => a.at("category") == cat)
      if items.len() > 0 {
        block(sticky: true)[#text(weight: "bold")[#title]]
        v(0.4em)
        for a in items {
          let ps = cites.filter(c => c.value == a.at("key")).map(c => c.location().page()).dedup()
          let pg = if ps.len() == 0 { "NOT CITED" } else if ps.len() > 5 { "passim" } else { ps.map(str).join(", ") }
          grid(
            columns: (1fr, auto),
            column-gutter: 0.3in,
            block(inl(a.at("text"))),
            align(top + right)[#pg],
          )
          v(0.5em)
        }
        v(0.6em)
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block and certifications (P.B. 67-4(i), 67-2A(f), 62-7(b), 62-8)
// ---------------------------------------------------------------------------

#let signature(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false)[
    #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    #v(1.2em)
    Respectfully submitted,
    #v(0.8em)
    #block(width: 4in)[
      #lines-of(sig.at("party", default: ()))
      #v(1.2em)
      #block(width: 100%)[/s/ #sig.at("signer")]
      #lines-of(sig.at("lines", default: ()))
      #v(0.6em)
      #need(meta, "date")
    ]
  ]
}

#let certification(heading, body) = block(breakable: true)[
  #set par(leading: body-leading, spacing: para-spacing, first-line-indent: 0pt)
  #v(1.2em)
  #align(center)[#text(weight: "bold")[#heading]]
  #v(0.6em)
  #body
]

#let certifications(meta) = {
  let date = need(meta, "date")
  // Word count (P.B. 67-2A(f)(3)); the template supplies the wording, the INPUT supplies the count.
  certification([CERTIFICATION OF WORD COUNT], [
    The undersigned certifies that this #doc-noun complies with the word limit of #word-rule
    and contains #str(need(meta, "word_count")) words, counted as that section directs.
  ])
  // Redaction (P.B. 67-2A(f)(2)).
  if redaction-cert {
    certification([CERTIFICATION OF REDACTION], [
      The undersigned certifies that this #doc-noun and any appendix have been redacted, or do not contain any
      names or other personal identifying information that is prohibited from disclosure by rule, statute,
      court order or case law.
    ])
  }
  // Service (P.B. 62-7(b)): names and email addresses of the counsel served.
  certification([CERTIFICATION OF SERVICE], [
    The undersigned certifies that a copy of this #doc-noun has been delivered electronically on #date to each
    counsel of record listed below, in compliance with Practice Book § 62-7.
    #v(0.6em)
    #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    #lines-of(need(meta, "service"))
    #v(1.2em)
    #block(width: 4in)[/s/ #need(meta, "signature").at("signer")]
  ])
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let conn-petition-for-rehearing(meta, body) = {
  set document(title: need(meta, "title"), author: "")
  set page(
    paper: "us-letter",
    margin: page-margin,
    // CONN-FORM-007: one pagination scheme from the cover on, centered, "Page X of XX".
    footer: context align(center, text(size: type-size)[
      Page #counter(page).display() of #counter(page).final().first()
    ]),
  )
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(justify: false, leading: body-leading, spacing: para-spacing, first-line-indent: para-indent)

  // Headings: 14-point serif, same 1.5 line spacing as the text. Level 1 centered; levels 2 and 3 left.
  show heading.where(level: 1): it => {
    v(para-spacing)
    block(sticky: true, width: 100%, align(center, text(size: head-size, weight: "bold", it.body)))
    v(para-spacing)
  }
  show heading.where(level: 2): it => {
    v(para-spacing)
    block(sticky: true, par(first-line-indent: 0pt, text(size: head-size, weight: "bold", it.body)))
    v(para-spacing)
  }
  show heading.where(level: 3): it => {
    v(para-spacing)
    block(sticky: true, par(first-line-indent: 0pt, text(size: head-size, weight: "bold", style: "italic", it.body)))
    v(para-spacing)
  }

  show heading.where(level: 4): it => {
    v(para-spacing)
    block(sticky: true, par(first-line-indent: 0pt, text(size: head-size, weight: "bold", it.body)))
    v(para-spacing)
  }

  show heading.where(level: 5): it => {
    v(para-spacing)
    block(sticky: true, par(first-line-indent: 0pt, text(size: head-size, weight: "bold", it.body)))
    v(para-spacing)
  }

  show heading.where(level: 6): it => {
    v(para-spacing)
    block(sticky: true, par(first-line-indent: 0pt, text(size: head-size, weight: "bold", it.body)))
    v(para-spacing)
  }

  // Block quotations are indented on both sides at the same line spacing (CONN-FORM-004).
  show quote.where(block: true): it => pad(left: 0.5in, right: 0.5in, bottom: para-spacing, it.body)

  // Footnotes keep the 12-point size and the uniform line spacing (CONN-FORM-002, CONN-FORM-004).
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(leading: body-leading, first-line-indent: 0pt)

  // Printed filing carries no hyperlink targets for toa: links; a toa: link keeps its text and records one
  // citation for the table of authorities. Other links are text (P.B. 67-2A(a)).
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      [#it.body#metadata(it.dest.slice(4))<toa-cite>]
    } else {
      it.body
    }
  }

  // Cover (CONN-COVER-001), numbered "Page 1 of N" like every page (CONN-FORM-007). A motion may
  // open with a caption on its first page instead (cover: false), as P.B. 66-2 does not require a cover.
  if meta.at("cover", default: true) {
    cover(meta)
    pagebreak()
  } else {
    caption(meta)
  }

  if meta.at("toc", default: true) {
    toc-page()
    if "authorities" in meta {
      pagebreak()
      toa-page(meta)
    }
    pagebreak()
  }

  // Body.
  cmarker.render(body, raw-typst: false, smart-punctuation: true)

  // Signature, then the certifications (P.B. 67-4(i), 67-2A(f)).
  signature(meta)
  certifications(meta)
}
