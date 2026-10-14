// Adversary complaint for the U.S. Bankruptcy Court, W.D. Pennsylvania (pawb).
// Rules: Fed. R. Bankr. P. 7010 (FRCP 10 applies; caption per Official Form 416D), 7008(a) (consent statement),
// W.PA LBR 7010-1 (caption: Form 416D plus the judge's initials after the case number), LBR 5005-13(b)
// (8.5 x 11 paper, sequential page numbers, paragraph numbers, 12-point type or larger including footnotes,
// text-searchable PDF), LBR 5005-6(d) (signature block). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // vendored in fonts/; the only font typst may see (--ignore-system-fonts)
#let type-size = 13pt                   // LBR 5005-13(b)(4): "no smaller than 12 Courier or an equivalent font size", footnotes included
#let page-w = 8.5in                     // LBR 5005-13(b)(1): 8.5 by 11 inch paper
#let page-h = 11in
#let margin = 1in                       // convention (both exemplars); no W.PA rule sets margins
#let body-leading = 1.35em              // double spacing (EB Garamond line box 0.65em; see the cand complaint README)
#let single-leading = 0.5em             // single spacing: caption, counsel and signature blocks, footnotes
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let caption-left = 3.4in               // width of the debtor and party column of the caption
#let text-width = page-w - 2 * margin

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("pawb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Sequential page numbers, centered in the bottom margin (LBR 5005-13(b)(2)); page 1 is numbered too.
#let page-footer() = context align(center, text(size: type-size, counter(page).display()))

// ---------------------------------------------------------------------------
// Cover: court title, Form 416D caption, title of the paper
// ---------------------------------------------------------------------------

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => text(i)))
}

#let caption(meta) = {
  align(center, {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    text(weight: "bold", [IN THE UNITED STATES BANKRUPTCY COURT])
    linebreak()
    text(weight: "bold", [FOR THE WESTERN DISTRICT OF PENNSYLVANIA])
  })
  v(1.5em)
  // Form 416D layout: a boxed left column (debtor, then the parties) and a right column (case number and
  // chapter, then the adversary number). Each row is one grid row, so the boxes meet with no gap.
  let parties = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { parties.push(v(single-leading)) }
    for n in p.names { parties.push(text(n) + linebreak()) }
    parties.push(h(1.5in) + text(p.designation))
  }
  set par(leading: single-leading, spacing: 0pt, justify: false)
  grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.25in,
    block(width: caption-left, stroke: (right: 0.75pt, top: 0.75pt), inset: (right: 10pt, top: 6pt), {
      [In re:]
      linebreak()
      [#meta.debtor.name]
      linebreak()
      [#h(1.5in)#meta.debtor.designation]
    }),
    block(inset: (top: 6pt), [Case No. #meta.bankruptcy_case]
      + linebreak() + [#meta.chapter]),
    block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, top: 1em, bottom: 6pt), {
      parties.join()
    }),
    block(inset: (top: 1.5em), if "adversary_number" in meta and meta.adversary_number != "" {
      [Adv. Proc. No. #meta.adversary_number]
    } else {
      [Adv. Proc. No. \_\_\_\_\_\_\_\_\_\_\_\_\_\_]
    }),
  )
  v(1.5em)
  align(center, text(weight: "bold", inl(meta.title)))
  v(1em)
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs, headings, unnumbered lead-in, prayers and certificate
// ---------------------------------------------------------------------------

/// Signature block: "/s/" above the name, then the name, Bar ID and address, phone and e-mail (LBR 5005-6(d)).
#let signature-block(meta) = block(breakable: false, width: text-width, {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  v(body-leading)
  [Respectfully submitted,]
  v(body-leading)
  [Date: #meta.date]
  v(body-leading)
  for (k, b) in meta.signature.blocks.enumerate() {
    if k > 0 { v(body-leading) }
    line-stack(("/s/ " + b.signer, upper(b.signer), b.pa_id) + b.lines)
  }
})

/// Numbered paragraphs (Fed. R. Bankr. P. 7010 applies FRCP 10(b); LBR 5005-13(b)(3)).
/// The text before the first heading is the unnumbered lead-in; a WHEREFORE clause is unnumbered (as in the
/// exemplar). Each blank-line-separated chunk of markdown is one paragraph. A chunk with hard line breaks
/// (an address or a signature block) is set single-spaced and unindented. Numbering is applied per chunk,
/// not with a `show par` rule, which recurses in typst 0.15.
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let started = false
  let certificate = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      // Headings are sticky blocks (see the show rules), so a heading stays with the paragraph after it.
      started = true
      certificate = t.starts-with("# CERTIFICATE")
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.contains("\\\n") {
      [#set par(leading: single-leading, spacing: 1.15em, justify: false)
       #cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)#parbreak()]
    } else {
      // Paragraphs are plain flow content: a block per paragraph collapses the leading between blocks.
      let numbered = started and not certificate and not t.starts-with("WHEREFORE")
      if numbered {
        [#para-counter.step()#context [#h(para-indent)#para-counter.display().#h(0.3in)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)]#parbreak()]
      } else {
        [#h(para-indent)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)#parbreak()]
      }
    }
  }
}

#let pawb-adversary-complaint(meta, body) = {
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: margin,
    footer: page-footer(),
  )
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  // Paragraph spacing equals the leading, so consecutive paragraphs keep the double-spaced pitch (spacing 0pt collapses it to single).
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: true)
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em, justify: false)

  // Headings: level 1 is a centered bold caps heading (COUNT headings, CERTIFICATE OF SERVICE); level 2 a
  // centered bold heading; level 3 a bold italic heading at the margin. Each stays on the page with its paragraph.
  // Headings are not justified or hyphenated.
  show heading.where(level: 1): it => block(width: text-width, above: 1.35em, below: 0.6em, sticky: true,
    align(center, par(justify: false, text(weight: "bold", size: type-size, hyphenate: false, upper(it.body)))))
  show heading.where(level: 2): it => block(width: text-width, above: 1.35em, below: 0.6em, sticky: true,
    align(center, par(justify: false, text(weight: "bold", size: type-size, hyphenate: false, it.body))))
  show heading.where(level: 3): it => block(width: text-width, above: 1em, below: 0.6em, sticky: true,
    par(justify: false, text(weight: "bold", style: "italic", size: type-size, hyphenate: false, it.body)))

  caption(meta)

  // The certificate of service follows the signature block (exemplar order), so the body is split at it.
  let parts = body.split("# CERTIFICATE")
  let main = parts.at(0)
  let certificate = if parts.len() > 1 { "# CERTIFICATE" + parts.slice(1).join("# CERTIFICATE") } else { "" }

  // Body: numbered paragraphs; markdown lists become (a), (b), ...
  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  allegations(main, para-counter)

  signature-block(meta)

  if certificate != "" {
    pagebreak()
    allegations(certificate, para-counter)
  }
}
