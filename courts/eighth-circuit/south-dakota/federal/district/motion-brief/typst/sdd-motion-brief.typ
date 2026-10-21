// Brief in support of a motion for the U.S. District Court for the District of South Dakota (sdd).
// Rules: D.S.D. Civ. LR 7.1(B) (movant's brief: legal arguments, authorities, and the Federal Rules relied on;
// a motion raising a question of law needs one), LR 7.1(B)(1) (25 pages or 12,000 words; a certificate of
// compliance beyond 25 pages), LR 83.4 (form of papers: 8 1/2 x 11 inch, double-spaced text, headings
// single-spaced, margins at least one inch on all four sides, type at least 12 point), LR 10.1 (caption;
// signature block), LR 5.1(A)(3) (certificate of service unless CM/ECF gives notice), LR 5.1(A)(4) ("/s/").
// See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/word-compat.typ": word-compat

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // vendored in fonts/ (the only font the build can use)
#let type-size = 12pt                   // LR 83.4: type must be at least 12 point
#let pitch = 24pt                       // LR 83.4: double-spaced text; the baseline pitch at 12 pt
#let page-w = 8.5in                     // LR 83.4: 8 1/2 by 11 inch paper
#let page-h = 11in
#let margin = 1in                       // LR 83.4: at least one inch on all four sides
#let text-width = page-w - 2 * margin
#let body-leading = 1.35em              // EB Garamond's line box is 0.65em, so 1.35em leading gives a 24 pt pitch at 12 pt
#let single-leading = 0.5em             // single spacing (headings, caption, signature, footnotes): about 13.8 pt
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-left = 3.25in              // width of the party column of the caption

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("sdd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for case names, *Id.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// A heading: kept with the paragraph after it, so a heading never ends a page (LR 83.4: single-spaced).
#let heading-block(c) = block(width: text-width, above: 12pt, below: 12pt, sticky: true, c)

/// Lines stacked at single spacing; each item is its own block, so no forced line breaks are needed.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// The page number, centered in the bottom margin.
#let footer-block() = align(center, text(size: type-size, context counter(page).display()))

// ---------------------------------------------------------------------------
// Cover: court title, caption (parties on the left, case number and title on the right)
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(leading: single-leading, spacing: 0pt)
  stack(dir: ttb, spacing: single-leading,
    align(center, text(weight: "bold", "IN THE UNITED STATES DISTRICT COURT")),
    align(center, text(weight: "bold", "FOR THE DISTRICT OF SOUTH DAKOTA")),
    if "division" in meta and meta.division != none {
      align(center, text(weight: "bold", upper(meta.division)))
    },
  )
}

#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.25in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 12pt, bottom: 10pt), {
    // Each party: its names, then its designation; "v." between the parties.
    let rows = ()
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { rows.push("v.") }
      rows += p.names + (p.designation,)
    }
    line-stack(rows)
  }),
  block(inset: (left: 0.15in), {
    line-stack(("Case No. " + meta.case_number,))
    v(pitch * 0.5)
    text(weight: "bold", inl(meta.brief_title))
  }),
)

#let cover(meta) = {
  court-title(meta)
  v(pitch)
  caption(meta)
  v(pitch)
}

// ---------------------------------------------------------------------------
// Body, footnotes, signature, certificate of service
// ---------------------------------------------------------------------------

/// Signature block (LR 10.1(B)): the firm, then "By: /s/" and the typed name, address, telephone and e-mail.
#let signature-block(meta) = {
  let sig = meta.signature
  block(width: text-width, above: pitch, breakable: false, grid(
    columns: (2.6in, 1fr),
    column-gutter: 0.2in,
    [Dated: #meta.date],
    {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      if "firm" in sig {
        line-stack(sig.firm)
        v(pitch * 0.5)
      }
      line-stack(("By: /s/ " + sig.signer, sig.signer) + sig.lines)
    },
  ))
}

/// Certificate of service (LR 5.1(A)(3)): on its own page, with the persons served and the manner of service.
#let certificate-block(cert) = {
  pagebreak(weak: true)
  heading-block(align(center, text(weight: "bold", "CERTIFICATE OF SERVICE")))
  block(width: text-width, breakable: false, {
    h(para-indent)
    cert.text
  })
  v(pitch * 0.5)
  for r in cert.recipients {
    block(width: text-width, breakable: false, above: 0pt, below: pitch * 0.5, line-stack(r))
  }
  block(width: text-width, breakable: false, grid(
    columns: (2.6in, 1fr),
    column-gutter: 0.2in,
    [],
    line-stack(("By: /s/ " + cert.signer, cert.signer)),
  ))
}

/// Body text. Each blank-line-separated chunk of markdown is one of:
///   - a footnote definition (`[^id]: text`): collected, and placed at each `[^id]` reference;
///   - a heading (`#`, `##`, `###`): centered caps, bold, or bold italic; kept with the chunk after it;
///   - a list (`1.`, `-`): lettered (a), (b), ... ;
///   - a paragraph: set with a first-line indent, double-spaced, unnumbered (LR 83.4).
/// Numbering is a plain code-level pass, not a counter, for the reason given in sdd-complaint.typ.
/// Footnotes are split out here because cmarker 0.1.10 has no footnote support.
#let allegations(body, tail) = {
  let all = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // Footnote definitions are removed from the flow and kept by id.
  let defs = (:)
  let chunks = ()
  for c in all {
    let m = c.trim().match(regex("^\\[\\^(\\w+)\\]:\\s*([\\s\\S]*)$"))
    if m != none {
      defs.insert(m.captures.at(0), m.captures.at(1))
    } else {
      chunks.push(c)
    }
  }
  let pending = []
  let tail-used = false
  for (i, c) in chunks.enumerate() {
    let t = c.trim()
    if t.starts-with("#") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      pending
      pending = []
      set par(leading: body-leading)
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      v(body-leading)
    } else {
      pending
      pending = []
      // Split the paragraph at footnote references: text, then the footnote, then text again.
      let pieces = ()
      let at = 0
      for m in t.matches(regex("\\[\\^(\\w+)\\]")) {
        pieces.push(t.slice(at, m.start))
        pieces.push((note: m.captures.at(0)))
        at = m.end
      }
      pieces.push(t.slice(at))
      let para = {
        set par(leading: body-leading)
        if pieces.len() == 1 {
          [#h(para-indent)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)]
        } else {
          h(para-indent)
          for p in pieces {
            if type(p) == dictionary {
              footnote({
                set par(leading: single-leading, spacing: 0pt)
                set text(size: type-size)
                inl(defs.at(p.note))
              })
            } else if p != "" {
              cmarker.render(p, raw-typst: false, smart-punctuation: true, h1-level: 1)
            }
          }
        }
      }
      // The last paragraph stays on the page with the signature block: a signature alone on a page is not allowed.
      if i == chunks.len() - 1 {
        block(breakable: false, width: text-width, { para; tail })
        tail-used = true
      } else {
        para
      }
    }
  }
  pending
  if not tail-used { tail }
}

#let sdd-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    footer: footer-block(),
    footer-descent: 0pt,
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)
  // Word paragraph composition (lib/typst/word-compat.typ); the INPUT's `word:` map sets justify/shrink.
  show: word-compat.with(meta.at("word", default: (:)))
  set table(stroke: 0.5pt, inset: 5pt)
  show table: set text(size: type-size)
  // Footnotes are single-spaced and at the text size (LR 83.4).
  set footnote.entry(separator: line(length: 1.5in, stroke: 0.5pt))

  // Headings: level 1 is a centered section in caps; level 2 a bold sub-heading; level 3 bold italic.
  show heading.where(level: 1): it => heading-block(align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => heading-block(text(weight: "bold", it.body))
  show heading.where(level: 3): it => heading-block(text(weight: "bold", style: "italic", it.body))

  cover(meta)

  allegations(body, signature-block(meta))

  if "certificate_of_service" in meta and meta.certificate_of_service != none {
    certificate-block(meta.certificate_of_service)
  }
}
