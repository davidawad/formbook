// Appellate Court of Connecticut: amicus-brief template (amicus curiae brief, Practice Book Sec. 67-7A; e-filed under Sec. 67-2A form rules).
// Requirement IDs (CONNAPPCT-...) refer to ../../rules.md. Rule-driven and content-agnostic: no case-specific text,
// no coordinates measured off a filing, no forced line breaks. The body is Markdown rendered by cmarker; cover,
// counsel, table of contents, table of authorities and certifications come from the YAML frontmatter of the INPUT
// (keys documented in the frontmatter of usage/INPUT-*.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters: the only numbers in this file. Each traces to a rule or a style choice.
// ---------------------------------------------------------------------------

#let font-family = "Times New Roman"  // FONT STANDARD: a serif face (CONNAPPCT-FORM-001); the repo standard face
#let type-size = 12pt                    // CONNAPPCT-FORM-001: body, footnotes and block quotes at 12 point
#let heading-size = 14pt                 // CONNAPPCT-FORM-002: headings at 14 point
#let body-leading = 0.575em              // CONNAPPCT-FORM-005: line spacing of 1.5 (a single line is about 1.15 em in this face)
#let single-leading = 0.3em              // cover, counsel and signature blocks only (style choice; not text of the filing)
#let para-spacing = 0.575em              // space between paragraphs: one line at 1.5 spacing (style choice)
#let para-indent = 0.5in                 // first-line indent (style choice)
#let page-margin = 1.5in                 // CONNAPPCT-FORM-003: one and one-half inches on all sides
#let toc-depth = 3

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("connappct-amicus-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("connappct-amicus-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let lines-of(items, bold: false) = stack(
  dir: ttb,
  spacing: 0.3em,
  ..items.map(l => if bold { text(weight: "bold", [#l]) } else { [#l] }),
)

// ---------------------------------------------------------------------------
// Cover (CONNAPPCT-COVER-001: court, docket, case name, nature of the brief, then the counsel who argues)
// ---------------------------------------------------------------------------

#let cover(meta) = {
  set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
  align(center, lines-of(need(meta, "court"), bold: true))
  v(1.2em)
  align(center)[#need(meta, "docket")]
  v(1.5em)
  align(center, lines-of(need(meta, "case_title")))
  v(1.5em)
  align(center)[#text(weight: "bold")[#need(meta, "title")]]
  v(2.2em)
  if "date" in meta [ #v(1em) #align(center)[#meta.at("date")] ]
  v(2.2em)
  align(left)[
    #lines-of(need(meta, "counsel"))
  ]
  if "argued_by" in meta [
    v(1.8em)
    align(left)[
      #text(weight: "bold")[To Be Argued By:]
      #v(0.4em)
      #lines-of(meta.at("argued_by"))
    ]
  ]
}

// ---------------------------------------------------------------------------
// Table of contents (CONNAPPCT-SEC-002) and table of authorities (CONNAPPCT-SEC-004).
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
    // Citations on the TOC page (its entries repeat heading text) are not body citations.
    let front = query(<toc-end>).first().location().page()
    let cites = query(<toa-cite>).filter(c => c.location().page() > front)
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
// Signature block (CONNAPPCT-SIG-001: after the conclusion, before the certification)
// ---------------------------------------------------------------------------

#let signature(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false)[
    #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    #v(1.2em)
    #meta.at("closing", default: "Respectfully submitted,")
    #v(0.8em)
    #block(width: 4in)[
      #lines-of(sig.at("party", default: ()))
      #v(1.2em)
      By: #box(width: 3in, line(length: 100%))
      #v(0.2em)
      #sig.at("signer")
      #lines-of(sig.at("lines", default: ()))
    ]
  ]
}

// ---------------------------------------------------------------------------
// Certifications (CONNAPPCT-CERT-001: redaction, service and word count; CONNAPPCT-CERT-002: signed by counsel)
// ---------------------------------------------------------------------------

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
      #block(width: 4in)[By: #box(width: 3in, line(length: 100%)) \ #c.at("signer")]
    ]
  ]
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let connappct-amicus-brief(meta, body) = {
  set document(title: need(meta, "title"), author: "")
  set page(
    paper: "us-letter",
    margin: page-margin,
    numbering: "1",
    footer: context align(center)[#text(size: type-size)[Page #counter(page).display() of #counter(page).final().first()]],
  )
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(justify: false, leading: body-leading, spacing: para-spacing, first-line-indent: para-indent)

  // Headings (CONNAPPCT-FORM-002): 14 point serif. Level 1 centered bold; level 2 bold; level 3 bold italic.
  show heading: set text(size: heading-size)
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

  // Block quotations: indented on both sides, at the same 1.5 line spacing (CONNAPPCT-FORM-005).
  show quote.where(block: true): it => pad(left: 0.5in, right: 0.5in, bottom: para-spacing, it.body)

  // Footnotes: 12 point, the same 1.5 line spacing as the text (CONNAPPCT-FORM-001, -005).
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(leading: body-leading, first-line-indent: 0pt)

  // Printed filing carries no hyperlink targets. A toa: link keeps its text and records one citation for the
  // table of authorities.
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      [#it.body#metadata(it.dest.slice(4))<toa-cite>]
    } else {
      it.body
    }
  }

  // Cover (numbered "Page 1 of N" as the first page of the single pagination scheme, CONNAPPCT-FORM-008).
  cover(meta)
  if meta.at("cover_page", default: true) { pagebreak() } else { v(1.5em) }

  // Order of Sec. 67-4(i): table of contents; statement of issues; table of authorities; statement of facts; argument.
  // The statement of issues comes from frontmatter key `issues` (Markdown) so it can sit between the two tables.
  if meta.at("toc", default: true) {
    toc-page()
    [#metadata(none)<toc-end>]
    pagebreak()
    if "issues" in meta {
      cmarker.render(meta.at("issues"), raw-typst: false, smart-punctuation: true)
      pagebreak()
    }
    if "authorities" in meta {
      toa-page(meta)
      pagebreak()
    }
  }

  // Body (statement of issues, statement of facts, argument, conclusion).
  cmarker.render(body, raw-typst: false, smart-punctuation: true)

  // Signature, then the certifications (CONNAPPCT-SIG-001, CONNAPPCT-CERT-001).
  signature(meta)
  for c in meta.at("certificates", default: ()) { certificate(c) }
}
