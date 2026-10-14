// U.S. Bankruptcy Court, N.D. Alabama: motion with memorandum (one filed document, no table of contents).
//
// Rule-driven and content-agnostic. The rules that bear on the form are cited in ../README.md
// (requirement IDs ALNB-...). No case-specific text, no coordinates measured off any filed motion,
// no forced line breaks. The markdown body is rendered by cmarker; the metadata comes from the YAML
// frontmatter of the same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let doc-kind = "motion-brief"
#let court-lines = (                      // caption header, centered; the Bankruptcy Court's name as filed.
  "IN THE UNITED STATES BANKRUPTCY COURT",
  "FOR THE NORTHERN DISTRICT OF ALABAMA",
  "NORTHERN DIVISION",
)
#let font-family = "EB Garamond"          // vendored in /fonts. No N.D. Ala. rule names a typeface (see README).
#let type-size = 12pt                     // no N.D. Ala. size rule (see README); 12 pt is what both exemplars use.
#let body-leading = 0.94em                // double spacing: about twice the single-spaced pitch (see single-leading).
#let single-leading = 0.12em              // headings, quotations, footnotes, caption, signature, certificate.
#let page-margin = 1in                    // 1 inch on all four sides.
#let para-indent = 0.5in
#let heading-tab = 0.5in

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("alnb-motion: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("alnb-motion: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// ---------------------------------------------------------------------------
// Caption (Bankruptcy Court header, the party block with its ")" column, the title)
// ---------------------------------------------------------------------------

/// Each row of `caption:` is one line: `l` (left text), `i` (indent in half inches), `r` (right text).
#let caption(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  set text(size: type-size)
  let rows = need(meta, "caption")
  grid(
    columns: (3.3in, 0.4in, 2.7in),
    row-gutter: 0pt,
    ..rows.map(r => (
      pad(left: r.at("i", default: 0) * 0.5in, r.at("l", default: "")),
      align(center, ")"),
      r.at("r", default: ""),
    )).flatten(),
  )
}

#let court-header() = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center)[#for l in court-lines { strong(l); linebreak() }]
  v(1.2em)
}

#let plain-title(meta) = {
  let t = need(meta, "title").replace("*", "")
  t + ", Adv. No. " + need(meta, "adversary_number")
}

// ---------------------------------------------------------------------------
// Headings: the labels are typed in the markdown (I., A., 1.) so the text is what the filer wrote.
// ---------------------------------------------------------------------------

#let style-heading(it) = {
  set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, justify: false)
  if it.level == 1 {
    // Section headings (CERTIFICATE OF SERVICE): bold capitals, centered.
    block(width: 100%, sticky: true, above: 1.2em, below: 1em,
      align(center, strong(upper(it.body))))
  } else if it.level == 2 {
    // Point headings (I. PRELIMINARY STATEMENT): bold capitals, flush left.
    block(width: 100%, sticky: true, above: 1.2em, below: 1em, strong(upper(it.body)))
  } else {
    // Sub-headings (A. ...): bold, the text hangs under the text after the label.
    block(width: 100%, sticky: true, above: 1em, below: 0.9em,
      par(hanging-indent: heading-tab, strong(it.body)))
  }
}

// ---------------------------------------------------------------------------
// Signature block and certificate (FRBP 9013; Local Rule 9013-3)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: 1.4em, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(
      columns: (1fr, 3.1in),
      [Dated: #need(meta, "date")],
      [
        Respectfully submitted,
        #v(1.2em)
        /s/ #sig.signer
        #linebreak()
        #upper(sig.signer)
        #for l in sig.at("title", default: ()) { linebreak(); l }
        #for l in sig.at("lines", default: ()) { linebreak(); l }
      ],
    )
  })
}

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

#let alnb-motion(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("caption", "title", "signature", "date", "word_processor", "typeface") {
    let _ = need(meta, k)
  }

  // ---- split off the certificate of service: it starts on a new page ----
  let cert = md.match(regex("(?mi)^#[ \t]+certificate of service[ \t]*$"))
  let body-md = if cert == none { md } else { md.slice(0, cert.start) }
  let cert-md = if cert == none { none } else { md.slice(cert.start) }
  if cert == none {
    panic("alnb-motion: N.D. Ala. motions need a `# CERTIFICATE OF SERVICE` section; the sample has none")
  }

  // ---- document-wide settings ----
  set document(
    title: plain-title(meta),
    author: need(meta, "signature").signer,
  )
  set page(paper: "us-letter", margin: page-margin, numbering: "1", number-align: center)
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: "ascender", bottom-edge: "descender",
  )
  set par(
    leading: body-leading, spacing: body-leading,
    first-line-indent: (amount: para-indent, all: true), justify: false,
  )
  set heading(numbering: none)
  set footnote.entry(
    gap: 0.5em, clearance: 0.9em, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt),
  )
  show footnote.entry: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, spacing: 0.5em)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }
  show quote.where(block: true): it => block(above: 1em, below: 1em, pad(left: para-indent, right: para-indent, {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.9em)
    it.body
  }))
  // Never break inside a token of adjacent parentheses ("60(b)(5)") or between a section sign and its number.
  show regex("\\S*\\)\\(\\S*"): it => box(it)
  show regex("[§¶] \\S+"): it => box(it)
  show heading: style-heading

  // ---- first page: court, caption, title ----
  court-header()
  caption(meta)
  v(1.2em)
  align(center, strong(upper(inl(need(meta, "title")))))
  v(0.6em)

  // ---- body ----
  let render(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)
  // The last paragraph (the WHEREFORE clause) stays with the signature block; footnote definitions
  // travel with the text that references them.
  let fn = body-md.match(regex("(?m)^\\[\\^[^\\]]+\\]:"))
  let main = if fn == none { body-md.trim(at: end) } else { body-md.slice(0, fn.start).trim(at: end) }
  let notes = if fn == none { "" } else { body-md.slice(fn.start) }
  let breaks = main.matches(regex("\n[ \t]*\n"))
  let cut = if breaks.len() > 0 { breaks.last().end } else { 0 }
  render(main.slice(0, cut) + "\n\n" + notes)
  block(breakable: false, {
    render(main.slice(cut))
    signature-block(meta)
  })

  // ---- certificate of service (Local Rule 9013-3: lists the names and addresses of all parties served) ----
  pagebreak(weak: true)
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 1em, justify: false)
  render(cert-md)
}
