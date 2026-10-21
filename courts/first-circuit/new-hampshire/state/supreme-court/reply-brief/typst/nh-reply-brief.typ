// Supreme Court of New Hampshire: NAME-reply-brief template. Requirement IDs (NH-...) refer to ../../rules.md.
// Rule-driven and content-agnostic: no case-specific text, no coordinates measured off a filing, no forced
// line breaks. The body is Markdown rendered by cmarker; cover, counsel, authorities and certificates come from
// the YAML frontmatter of the INPUT (keys documented in the frontmatter of usage/INPUT-*.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters: the only numbers in this file. Each traces to a rule or a style choice.
// ---------------------------------------------------------------------------

#let font-family = "Times New Roman"  // FONT STANDARD: Times New Roman for every template (no court rule names another face)
#let type-size = 13pt                    // NH-FORM-001: standard typewriter characters or 13-point font
#let body-leading = 0.575em              // NH-FORM-002: line spacing of 1.5 (a single line is about 1.15 em in this face)
#let single-leading = 0.3em                // cover, counsel and signature blocks only (style choice; not text of the filing)
#let para-spacing = 0.575em              // space between paragraphs: one line at 1.5 spacing (style choice)
#let para-indent = 0.5in                 // first-line indent (style choice)
#let page-margin = 1.5in                 // NH-FORM-004: at least one and one-half inches on all sides (SCR 16(1))
#let toc-depth = 3

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("nh-reply-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nh-reply-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let lines-of(items, bold: false) = stack(
  dir: ttb,
  spacing: 0.3em,
  ..items.map(l => if bold { text(weight: "bold", [#l]) } else { [#l] }),
)

// ---------------------------------------------------------------------------
// Cover (NH-COV-001, SCR 16(2): court, docket, case title, proceeding, document title, counsel)
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
  align(center)[#need(meta, "docket")]
  v(1.5em)
  align(center, lines-of(need(meta, "case_title")))
  v(1.2em)
  align(center)[#need(meta, "proceeding")]
  v(2.4em)
  align(center)[#text(weight: "bold")[#need(meta, "title")]]
  v(1.5em)
  if "filed_by" in meta {
    align(center, lines-of(meta.at("filed_by")))
    v(1.5em)
  }
  set align(left)
  counsel-grid(need(meta, "counsel"))
  if "argument" in meta {
    v(1.5em)
    align(center)[#meta.at("argument")]
  }
}

// ---------------------------------------------------------------------------
// Table of contents (SCR 16(3)(a), 10(b)) and table of authorities (SCR 16(3)(a)).
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
// Signature block, certificates (SCR 16(10), 26(7), 16(3)(i))
// ---------------------------------------------------------------------------

#let signature(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false)[
    #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    #v(1.2em)
    #if "date" in meta [ #meta.at("date") #v(0.8em) ]
    Respectfully submitted,
    #v(0.8em)
    #block(width: 4in)[
      #lines-of(sig.at("party", default: ()))
      #v(1.2em)
      #block(width: 100%)[/s/ #sig.at("signer")]
      #lines-of(sig.at("lines", default: ()))
    ]
  ]
}

#let certificate(c) = {
  block(breakable: true)[
    #set par(leading: body-leading, spacing: para-spacing, first-line-indent: 0pt)
    #v(1.2em)
    #align(center)[#text(weight: "bold")[#c.at("heading")]]
    #v(0.6em)
    #inl(c.at("text"))
    #if "lines" in c [
      #v(0.6em)
      #set par(leading: single-leading, spacing: single-leading)
      #lines-of(c.at("lines"))
    ]
    #if "signer" in c [
      #v(1.2em)
      #set par(leading: single-leading, spacing: single-leading)
      #block(width: 4in)[/s/ #c.at("signer")]
    ]
  ]
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let nh-reply-brief(meta, body) = {
  set document(title: need(meta, "title"), author: "")
  set page(paper: "us-letter", margin: page-margin, numbering: none)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(justify: false, leading: body-leading, spacing: para-spacing, first-line-indent: para-indent)

  // Headings: level 1 centered bold; level 2 bold; level 3 bold italic. Same 1.5 line spacing as the text.
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

  // Block quotations are indented on both sides at the same line spacing.
  show quote.where(block: true): it => pad(left: 0.5in, right: 0.5in, bottom: para-spacing, it.body)

  // Footnotes keep the filing's 13-point size (SCR 16(11)) and its line spacing.
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(leading: body-leading, first-line-indent: 0pt)

  // Printed filing carries no hyperlink targets (SUP-EF 11(f) keeps record references only). A toa: link keeps
  // its text and records one citation for the table of authorities.
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      [#it.body#metadata(it.dest.slice(4))<toa-cite>]
    } else {
      it.body
    }
  }

  // Cover (no page number).
  cover(meta)
  pagebreak()

  // Every page after the cover is numbered in Arabic numerals (NH-FORM-006).
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

  // Certificates that precede the signature (appealed decisions, word count, compliance).
  let certs = meta.at("certificates", default: ())
  for c in certs.filter(c => c.at("type") != "service") { certificate(c) }
  signature(meta)
  for c in certs.filter(c => c.at("type") == "service") { certificate(c) }
}
