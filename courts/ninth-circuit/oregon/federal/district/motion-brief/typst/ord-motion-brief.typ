// Motion with memorandum for the U.S. District Court for the District of Oregon (ord).
// Rules: LR 10-1 (double spacing, 12-point minimum for all typewritten material including footers and footnotes,
// one-inch margins, no page numbers down the left margin, footer with a description and consecutive page numbers);
// LR 10-2 (counsel information upper left, court title centered, party names, case number at the center of the
// page, title); LR 7-1 (conferral certification in the first paragraph; the memorandum is combined with the motion
// in one document; table of contents and table of authorities for a memorandum over 20 pages, not generated here);
// LR 7-2(b) (35 pages or 11,000 words; not counted here). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // vendored in fonts/ (the only serif face vendored; no rule names a face)
#let type-size = 13pt                   // LR 10-1(c) floor is 12 pt; 13 pt because EB Garamond's x-height is smaller than Times 12 pt (README)
#let footer-size = 12pt                 // LR 10-1(c): the footer is typewritten material, so it is 12 pt too
#let pitch = 24pt                       // LR 10-1(b): double spacing; 27 lines fill the 9-inch text height exactly
#let page-w = 8.5in
#let page-h = 11in
#let margin = 1in                       // LR 10-1(d): one inch on all four sides
#let text-width = page-w - 2 * margin
#let body-leading = 15.55pt             // 24 pt baseline pitch at 13 pt: EB Garamond's line box is 0.65 em (README, measured)
#let single-leading = 0.35em            // single spacing for counsel, caption, signature, and quotations (about 1.0 em per line)
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-split = text-width / 2     // LR 10-2(f): the case number starts at the center of the page
#let caption-gap = 0.3in                // space between the party column and the center line

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ord-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for case names with italics, section symbols, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Fill whole double-spaced lines: the block is rounded up to a multiple of `pitch`, so whatever follows it
/// stays on the grid of double-spaced lines.
#let on-grid(c) = context {
  let h = measure(width: text-width, c).height
  block(width: text-width, height: calc.ceil(h / pitch) * pitch, above: 0pt, below: 0pt, c)
}

/// One single-spaced line per item; blank items keep their line.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => if i.trim() == "" { v(type-size * 0.65) } else { inl(i) }))
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// LR 10-1(e)(1): a footer on every page with a brief description of the document and the page number.
#let footer-block(title) = context {
  set text(size: footer-size)
  align(left, [Page #counter(page).display() - #upper(title)])
}

// ---------------------------------------------------------------------------
// Cover: counsel (upper left, LR 10-2(a)), court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let counsel-block(meta) = context {
  // LR 10-2(b): the court title is centered at least one inch below the counsel information.
  let h = measure(width: text-width, line-stack(meta.counsel)).height
  block(width: text-width, height: calc.ceil((h + 1in) / pitch) * pitch, above: 0pt, below: 0pt,
    line-stack(meta.counsel))
}

#let court-title(meta) = {
  on-grid(align(center, text(weight: "bold", upper(meta.court.at(0)))))
  for line in meta.court.slice(1) {
    on-grid(align(center, text(weight: "bold", upper(line))))
  }
  if "division" in meta {
    on-grid(align(center, text(weight: "bold", upper(meta.division))))
  }
}

#let caption(meta) = on-grid(grid(
  columns: (caption-split, 1fr),
  column-gutter: 0pt,
  block(width: caption-split - caption-gap, {
    // Each party: its names, then its designation; "vs." between the parties (LR 10-2(d)).
    let rows = ()
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { rows.push("vs.") }
      rows += p.names + (p.designation,)
    }
    line-stack(rows)
  }),
  block(width: 100%, {
    set par(leading: single-leading, spacing: 0pt)
    // LR 10-2(f): the case number, on the first line of the caption, starting at the center of the page.
    line-stack(("Case No. " + meta.case_number,))
    // LR 10-2(g): the document title is at least two lines below the case number, single-spaced, capitalized.
    v(pitch)
    text(weight: "bold", inl(upper(meta.brief_title)))
    if "legend" in meta and meta.legend != none {
      v(pitch * 0.5)
      inl(meta.legend)
    }
  }),
))

#let cover(meta) = {
  counsel-block(meta)
  court-title(meta)
  v(pitch * 0.5)
  caption(meta)
}

// ---------------------------------------------------------------------------
// Signature and certificate of service
// ---------------------------------------------------------------------------

// Unbreakable: the firm block never splits, so no line of a signature is left alone on a page.
#let signature-block(meta) = block(breakable: false, width: text-width, on-grid(grid(
  columns: (2.9in, 1fr),
  column-gutter: 0.2in,
  [DATED: #meta.date],
  {
    line-stack(meta.signature.firm)
    v(pitch * 0.5)
    line-stack(("By: /s/ " + meta.signature.signer,) + meta.signature.lines)
  },
)))

/// Certificate of service: the form wording, with the document title, the date, the parties served and the method
/// filled from the sample. Generated, not written by the author.
#let certificate-of-service(meta) = {
  let cos = meta.certificate_of_service
  on-grid(align(center, text(weight: "bold", "CERTIFICATE OF SERVICE")))
  on-grid({
    set par(leading: body-leading)
    h(para-indent)
    [The undersigned declares under penalty of perjury, under the laws of the State of Oregon, that on #cos.date, I arranged for service of the foregoing #upper(meta.brief_title) on the party to this action as follows:]
  })
  v(pitch * 0.5)
  on-grid(grid(columns: (0.5in, 1fr), [], line-stack(cos.served)))
  v(pitch * 0.5)
  on-grid(grid(columns: (0.5in, 1fr), [], [by: #cos.method]))
  v(pitch)
  on-grid(grid(columns: (2.9in, 1fr), column-gutter: 0.2in, [], line-stack(("s/ " + meta.signature.signer,) + (meta.signature.signer,))))
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// Body text. Each blank-line-separated chunk of markdown is a heading, a block quotation, or a paragraph
/// (first-line indent; motions are not numbered).
#let body-text(body, tail) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for (k, c) in chunks.enumerate() {
    let t = c.trim()
    if t.starts-with("#") {
      // A heading sticks to the block after it, so it is never left at the foot of a page.
      block(sticky: true, width: text-width, on-grid(cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)))
    } else if t.starts-with(">") {
      // Quotations are exempt from double spacing (LR 10-1(b)); single-spaced, indented, and kept whole.
      on-grid({
        set par(leading: single-leading)
        pad(left: 0.5in, right: 0.5in, cmarker.render(t.replace(regex("^>\\s?"), "").replace(regex("\\n>\\s?"), "\n"), raw-typst: false, smart-punctuation: true))
      })
    } else {
      // A paragraph may break across pages. Each of its lines is one double-spaced pitch, so it stays on the grid.
      // Leading sits between lines, so the block adds one more leading below: N lines fill N pitches.
      let para = block(width: text-width, above: 0pt, below: body-leading, {
        set par(leading: body-leading)
        h(para-indent)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
      // The last paragraph stays on the page with the signature block, so a signature is never left alone.
      if k == chunks.len() - 1 {
        block(breakable: false, width: text-width, { para; tail })
      } else {
        para
      }
    }
  }
}

#let ord-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    footer: footer-block(meta.footer_title),
    footer-descent: 0.5in,
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 is a centered section; level 2 a bold sub-heading; level 3 a bold sub-sub-heading, indented.
  show heading.where(level: 1): it => align(center, text(weight: "bold", upper(it.body)))
  show heading.where(level: 2): it => text(weight: "bold", it.body)
  show heading.where(level: 3): it => pad(left: 0.5in, text(weight: "bold", it.body))

  cover(meta)
  pagebreak()

  body-text(body, {
    v(pitch)
    signature-block(meta)
  })

  if "certificate_of_service" in meta {
    pagebreak()
    certificate-of-service(meta)
  }
}
