// Supreme Judicial Court of Massachusetts: petition-for-review template (application for direct appellate review,
// joint petition for transfer and similar). Requirement IDs (MA-...) refer to ../../rules.md. Rule-driven and
// content-agnostic: no case-specific text, no coordinates measured off a filing, no forced line breaks. The body is
// Markdown rendered by cmarker; cover, counsel, signature and certificates come from the YAML frontmatter of the
// INPUT (keys documented in ../README.md "Markdown contract" and in the frontmatter of usage/INPUT-*.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters: the only numbers in this file. Each traces to a rule or a style choice.
// ---------------------------------------------------------------------------

#let font-family = "Times New Roman"     // MRAP 20(a)(4)(B): a proportionally spaced face (Times New Roman as the named example)
#let type-size = 14pt                    // MRAP 20(a)(4)(B): 14 point or larger, footnotes included
// Typst leading is added to the face's own line height (about 0.69 em in this face): 1.36 em gives a line pitch of
// about 2.05 em (28.7 pt at 14 pt), double spacing that stays within 3 lines per inch and 27 lines per page.
#let body-leading = 1.36em               // MRAP 20(a)(4)(C): double-spaced text (not more than 3 lines per inch, 27 lines per page)
// 0.46 em gives a line pitch of about 1.15 em (16 pt): single spacing, not more than 6 lines per inch.
#let single-leading = 0.46em             // MRAP 20(a)(4)(C): single spacing for cover, signature, footnotes, indented quotations
#let para-spacing = body-leading          // style: paragraph gap equal to the leading, so baselines stay one double-spaced line apart as in the filed exemplar
#let para-indent = 0.5in                 // style: first-line indent
// MRAP 20(a)(4)(A): top, bottom, left and right margins at least 1 inch. The bottom margin is 0.1 inch deeper than
// 1 inch so that the descenders of the last footnote line stay inside the 1 inch margin line.
#let page-margin = (top: 1in, left: 1in, right: 1in, bottom: 1.1in)
#let toc-depth = 3

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("mass-petition-for-review: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mass-petition-for-review: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let lines-of(items, bold: false) = stack(
  dir: ttb,
  spacing: single-leading,
  ..items.map(l => if bold { text(weight: "bold", [#l]) } else { [#l] }),
)

// ---------------------------------------------------------------------------
// Cover (MRAP 20(a)(6)(B)(i)-(vi): court and case number, case title, nature of the proceeding and lower court,
// title of the document, filer names, BBO numbers, addresses and telephone numbers, office name).
// The cover is paginated as page 1 (MRAP 20(a)(6)(B)(vii), MA-COVER-002). Cover colour is not required for an
// electronically filed document (MRAP 20(a)(6)(A)), so the cover is white.
// ---------------------------------------------------------------------------

#let counsel-grid(groups) = grid(
  columns: (1fr,) * calc.min(groups.len(), 2),
  column-gutter: 1.2em,
  row-gutter: 1.2em,
  ..groups.map(g => stack(
    dir: ttb,
    spacing: single-leading,
    ..g.at("names").map(n => [#n]),
    ..g.at("lines").map(l => [#l]),
  )),
)

#let cover(meta) = {
  set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
  align(center, lines-of(need(meta, "court"), bold: true))
  v(1.2em)
  align(center)[#need(meta, "docket")]
  v(1.2em)
  align(center, lines-of(need(meta, "case_title")))
  v(1.2em)
  align(center)[#need(meta, "proceeding")]
  v(1.6em)
  align(center)[#text(weight: "bold")[#need(meta, "title")]]
  v(1.6em)
  set align(left)
  counsel-grid(need(meta, "counsel"))
  if "argument" in meta {
    v(1.2em)
    align(center)[#meta.at("argument")]
  }
}

// ---------------------------------------------------------------------------
// Table of contents and table of authorities. Generated only when the INPUT sets `toc: true` (the petition-for-review
// filed exemplar has neither). A citation is marked in the body as a Markdown link to toa:<key>.
// ---------------------------------------------------------------------------

#let toc-page() = {
  align(center)[#text(weight: "bold")[TABLE OF CONTENTS]]
  v(1em)
  outline(title: none, depth: toc-depth, indent: 2em)
}

#let toa-page(meta) = {
  align(center)[#text(weight: "bold")[TABLE OF AUTHORITIES]]
  v(1em)
  context {
    let cites = query(<toa-cite>)
    for (cat, title) in (
      ("cases", "Cases"),
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
// Signature blocks (MA-SIG-001, MRAP 16(a)(12)): one column per party block, the printed name of each signer with the
// BBO number, addresses and telephone beneath. A rule above a signer's name marks the place for the handwritten
// signature; a signer listed without `signed: true` is printed only.
// ---------------------------------------------------------------------------

#let signer-block(s) = stack(
  dir: ttb,
  spacing: single-leading,
  if s.at("signed", default: false) { v(1.4em); line(length: 100%, stroke: 0.5pt) } else { v(0.6em) },
  [#s.at("name")],
  ..s.at("lines", default: ()).map(l => [#l]),
)

#let signature(meta) = {
  let sig = need(meta, "signature")
  let blocks = sig.at("blocks", default: ())
  block(breakable: false)[
    #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    #v(body-leading)
    #if "intro" in sig [ #sig.intro \ ]
    #v(0.6em)
    #grid(
      columns: (1fr,) * calc.min(blocks.len(), 2),
      column-gutter: 0.4in,
      row-gutter: 1.2em,
      ..blocks.map(b => stack(
        dir: ttb,
        spacing: single-leading,
        ..b.at("party", default: ()).map(p => text(style: "italic")[#p]),
        ..b.at("signers", default: ()).map(s => signer-block(s)),
      )),
    )
  ]
}

// ---------------------------------------------------------------------------
// Certificates: a compliance certificate, if the INPUT gives one, precedes the signature; the certificate of service
// follows it (MRAP 13(e)(1)-(2), 16(a)(15) for service; MRAP 16(k), 20(a)(2)(F) for compliance).
// ---------------------------------------------------------------------------

#let certificate(c) = {
  block(breakable: false)[
    #set par(leading: body-leading, spacing: para-spacing, first-line-indent: para-indent)
    #v(body-leading)
    #align(center)[#text(weight: "bold")[#c.at("heading")]]
    #v(0.2em)
    #inl(c.at("text"))
    #if "date" in c [
      #set par(leading: single-leading, first-line-indent: 0pt)
      #v(body-leading)
      DATED: #c.at("date")
    ]
    #if "signer" in c [
      #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
      #v(1.4em)
      #block(width: 3.2in)[
        #line(length: 100%, stroke: 0.5pt)
        #c.at("signer")
      ]
    ]
  ]
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let mass-petition-for-review(meta, body) = {
  set document(title: need(meta, "title"), author: "")
  // MA-FORM-001 / MA-FORM-003: 8.5 x 11 inch paper, margins of at least 1 inch on all sides.
  // MA-FORM-005 / MA-COVER-002: pages are numbered in the margin from the cover (page 1), so the cover is numbered too.
  set page(paper: "us-letter", margin: page-margin, numbering: "1")
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(justify: false, leading: body-leading, spacing: para-spacing, first-line-indent: para-indent)

  // Headings: level 1 centered bold; level 2 bold; level 3 bold italic. Set at the body line spacing.
  show heading.where(level: 1): it => {
    v(para-spacing)
    block(sticky: true, width: 100%, align(center, text(weight: "bold", it.body)))
    v(para-spacing)
  }
  show heading.where(level: 2): it => {
    v(para-spacing)
    block(sticky: true, par(first-line-indent: 0pt, text(weight: "bold", it.body)))
    v(para-spacing)
  }
  show heading.where(level: 3): it => {
    v(para-spacing)
    block(sticky: true, par(first-line-indent: 0pt, text(weight: "bold", style: "italic", it.body)))
    v(para-spacing)
  }

  // Block quotations: indented on both sides, single-spaced, one double-spaced line after (MRAP 20(a)(4)(C)).
  show quote.where(block: true): it => pad(left: 0.5in, right: 0.5in, bottom: body-leading, {
    set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    it.body
  })

  // Footnotes keep the 14-point size (MRAP 20(a)(4)(B)) and are single-spaced (MRAP 20(a)(4)(C)).
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(leading: single-leading, first-line-indent: 0pt)

  // A toa: link keeps its text and records one citation for the table of authorities (only when toc is set).
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      [#it.body#metadata(it.dest.slice(4))<toa-cite>]
    } else {
      it.body
    }
  }

  // Cover, then the cover's page break.
  cover(meta)
  pagebreak()

  if meta.at("toc", default: false) {
    toc-page()
    if "authorities" in meta {
      pagebreak()
      toa-page(meta)
    }
    pagebreak()
  }

  // Body.
  cmarker.render(body, raw-typst: false, smart-punctuation: true)

  // Certificates that precede the signature (compliance), signature, then the certificate of service.
  let certs = meta.at("certificates", default: ())
  for c in certs.filter(c => c.at("type") != "service") { certificate(c) }
  signature(meta)
  for c in certs.filter(c => c.at("type") == "service") { certificate(c) }
}
