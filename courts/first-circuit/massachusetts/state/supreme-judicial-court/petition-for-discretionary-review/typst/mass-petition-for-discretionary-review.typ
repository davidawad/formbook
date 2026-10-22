// Supreme Judicial Court of Massachusetts: petition-for-discretionary-review template (application for direct
// appellate review, MRAP 11). Requirement IDs (MA-...) refer to ../../rules.md.
// Rule-driven and content-agnostic: no case-specific text, no coordinates measured off a filing, no forced
// line breaks. The body is Markdown rendered by cmarker; cover, counsel, authorities and certificates come from
// the YAML frontmatter of the INPUT (keys documented in usage/INPUT-petition-for-discretionary-review.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters: the only numbers in this file. Each traces to a rule or a style choice.
// ---------------------------------------------------------------------------

#let font-family = "Times New Roman"  // FONT STANDARD: Times New Roman for every template (MA-FORM-002 names it as the example face)
#let type-size = 14pt                 // MA-FORM-002: proportionally spaced font of 14 point or larger, footnotes included (MRAP 20(a)(4)(B))
#let body-leading = 0.65em            // MA-FORM-004: double spacing, not more than 3 lines per vertical inch and not more than 27 lines per page (MRAP 20(a)(4)(C)); style: pitch of about 24.6 pt
#let single-leading = 0.3em           // single spacing for cover, counsel, signature, headings, footnotes and quotations (MRAP 20(a)(4)(C), style choice)
#let para-spacing = 0.65em            // space between paragraphs equals one double-spaced line (style choice)
#let para-indent = 0.5in              // first-line indent (style choice)
#let page-margin = 1in                // MA-FORM-003: top, left and right margins of at least 1 inch (MRAP 20(a)(4)(A))
#let page-margin-bottom = 1.05in      // MA-FORM-003: at least 1 inch; a 0.05 in allowance keeps footnote descenders inside the margin line
#let toc-depth = 3

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("mass-petition-for-discretionary-review: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mass-petition-for-discretionary-review: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let lines-of(items, bold: false) = stack(
  dir: ttb,
  spacing: 0.3em,
  ..items.map(l => if bold { text(weight: "bold", [#l]) } else { [#l] }),
)

// ---------------------------------------------------------------------------
// Cover (MA-COVER-001: court and case number; case title; nature of the proceeding and the lower court;
// title of the document; filer names, BBO numbers, addresses, telephone; office name). MA-COVER-002: page 1.
// ---------------------------------------------------------------------------

#let counsel-grid(groups) = grid(
  columns: (1fr,) * calc.min(groups.len(), 2),
  column-gutter: 1.2em,
  row-gutter: 1.2em,
  ..groups.map(g => stack(
    dir: ttb,
    spacing: 0.3em,
    ..g.at("names").map(n => [#n]),
    ..g.at("lines").map(l => [#l]),
  )),
)

#let cover(meta) = {
  set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
  align(center, lines-of(need(meta, "court"), bold: true))
  v(1.2em)
  grid(
    columns: (1fr, auto),
    align(left)[#if "venue" in meta [#meta.at("venue")]],
    align(right, lines-of(need(meta, "docket"))),
  )
  v(1.5em)
  align(center, lines-of(need(meta, "case_title")))
  v(2.4em)
  align(center)[#text(weight: "bold")[#need(meta, "title")]]
  v(0.6em)
  align(center)[#need(meta, "proceeding")]
  v(1.5em)
  if "filed_by" in meta {
    align(center, lines-of(meta.at("filed_by")))
    v(1.5em)
  }
  set align(left)
  counsel-grid(need(meta, "counsel"))
  if "counsel_for" in meta {
    v(1.5em)
    align(center)[#meta.at("counsel_for")]
  }
  if "date" in meta {
    v(1.5em)
    align(center)[#meta.at("date")]
  }
}

// ---------------------------------------------------------------------------
// Table of contents (MRAP 16(a)(1)-(2) as applied to applications by MRAP 11(b)) and table of authorities.
// A citation is marked in the body as a Markdown link to toa:<key>; the link text is the citation as printed.
// The authority list in frontmatter (key, category, text) gives the entries; pages come from the rendered body.
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
// Signature block (MA-SIG-001, MRAP 16(a)(12)) and certificates (MA-CERT-001, MA-CERT-002).
// ---------------------------------------------------------------------------

#let signature(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false)[
    #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    #v(1.2em)
    Respectfully submitted,
    #v(0.8em)
    #block(width: 5in)[
      #lines-of(sig.at("party", default: ()))
      #v(1.2em)
      #block(width: 100%)[/s/ #sig.at("signer")]
      #lines-of(sig.at("lines", default: ()))
    ]
    #if "date" in meta [ #v(1.2em) Dated: #meta.at("date") ]
  ]
}

#let certificate(c) = {
  block(breakable: true)[
    #set par(leading: body-leading, spacing: para-spacing, first-line-indent: 0pt)
    #v(1.2em)
    #align(center)[#text(weight: "bold")[#c.at("heading")]]
    #v(0.6em)
    #inl(c.at("text"))
    #if "served" in c [
      #v(0.6em)
      #set par(leading: single-leading, spacing: single-leading)
      #lines-of(c.at("served"))
    ]
    #if "signer" in c [
      #v(1.2em)
      #set par(leading: single-leading, spacing: single-leading)
      #block(width: 5in)[
        /s/ #c.at("signer")
        #lines-of(c.at("lines", default: ()))
      ]
    ]
  ]
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let mass-petition-for-discretionary-review(meta, body) = {
  set document(title: need(meta, "title"), author: "")
  set page(paper: "us-letter", margin: (top: page-margin, left: page-margin, right: page-margin, bottom: page-margin-bottom), numbering: none)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(justify: false, leading: body-leading, spacing: para-spacing, first-line-indent: para-indent)

  // Headings: level 1 centered bold; level 2 bold, left; single-spaced (MRAP 20(a)(4)(C) allows argument headings).
  show heading.where(level: 1): it => {
    v(para-spacing)
    block(sticky: true, width: 100%, par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt, align(center, text(weight: "bold", it.body))))
    v(para-spacing)
  }
  show heading.where(level: 2): it => {
    v(para-spacing)
    block(sticky: true, par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt, text(weight: "bold", it.body)))
    v(para-spacing)
  }
  show heading.where(level: 3): it => {
    v(para-spacing)
    block(sticky: true, par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt, text(weight: "bold", style: "italic", it.body)))
    v(para-spacing)
  }

  // Indented quotations are single-spaced (MRAP 20(a)(4)(C)).
  show quote.where(block: true): it => pad(left: 0.5in, right: 0.5in, bottom: para-spacing, {
    set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    it.body
  })

  // Footnotes keep the 14-point size (MRAP 20(a)(4)(B)) and may be single-spaced (MRAP 20(a)(4)(C)).
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)

  // Printed filing carries no hyperlink targets. A toa: link keeps its text and records one citation for the TOA.
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      [#it.body#metadata(it.dest.slice(4))<toa-cite>]
    } else {
      it.body
    }
  }

  // Cover (paginated as page 1 per MA-COVER-002, printed without a number).
  cover(meta)
  pagebreak()

  // Every page after the cover is numbered in Arabic numerals in the margin, counting the cover as page 1 (MA-FORM-005).
  set page(numbering: "1")
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

  // Signature block, then the certificates in the order the filing uses: compliance, then service.
  signature(meta)
  for c in meta.at("certificates", default: ()) {
    pagebreak(weak: true)
    certificate(c)
  }
}
