// Brief in support of a motion, for the United States District Court for the Western District of Arkansas (arwd).
// Rules: Local Rule 7.2(a) (a motion is accompanied by a brief of relevant facts and applicable law), 7.2(e)
// (a motion to dismiss is set out in a separate pleading accompanied by a separate brief), 5.5(a) (type not
// less than elite, double space, letter size, one side), 5.5(c)(1) (signature block); Fed. R. Civ. P. 12(b)
// (the defenses a motion may raise). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a convention; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // LR 5.5(a): a proportional serif; EB Garamond is the vendored face
#let type-size = 12pt                   // LR 5.5(a): "type not less than elite" (elite = 12 cpi); 12 pt here
#let page-w = 8.5in                     // LR 5.5(a): letter size
#let page-h = 11in
#let margin = 1in                       // convention (no margin rule in LR 5.5); the exemplar is 1 inch
#let body-leading = 1.65em              // LR 5.5(a): double space; 27.6 pt baseline pitch at 12 pt (measured, README.md)
#let single-leading = 0.5em             // counsel block, caption, court title, quotations, signature: single spaced
#let pitch = 0.65em + body-leading      // one double-spaced line: the EB Garamond line (0.65 em) plus the leading
#let para-indent = 0.5in                // first-line indent of body paragraphs (convention)
#let caption-left = 3.6in               // width of the party column of the caption (convention)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("arwd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in italics, smart quotes).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// A block of markdown (headings, paragraphs, lists, quotations).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// "Page n of N", centered in the bottom margin.
#let footer-page() = align(center, text(size: type-size, context [Page #counter(page).display() of #counter(page).final().first()]))

// ---------------------------------------------------------------------------
// First page: court, caption, title of the paper
// ---------------------------------------------------------------------------

/// The court title, single spaced and centered: one line per entry of `court`, then `division`.
#let court-title(meta) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  // One stack for every line, so the division is spaced like the lines above it.
  let lines = meta.court
  if "division" in meta { lines.push(meta.division) }
  align(center, stack(dir: ttb, spacing: single-leading, ..lines.map(i => upper(i))))
}

/// The caption: party names on the left with their designation on the right; "v." and the case number
/// share the row between the two parties. Single spaced.
#let caption(meta) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  let cells = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 {
      cells += ([v.], [CASE NO. #meta.case_number])
    }
    for (i, n) in p.names.enumerate() {
      cells += (inl(n), if i == 0 { align(right, inl(p.designation)) } else { [] })
    }
  }
  grid(columns: (caption-left, 1fr), column-gutter: 0.2in, row-gutter: single-leading, ..cells)
}

/// The title of the paper: centered and bold.
#let title-block(meta) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  align(center, text(weight: "bold", inl(meta.title)))
}

// ---------------------------------------------------------------------------
// Body, signature and certificate
// ---------------------------------------------------------------------------

/// The body, one chunk at a time. Vertical rhythm: every block is followed by `body-leading`, so the next
/// line lands one pitch below it; a heading is set off by one blank line above and below and is kept with
/// the chunk after it. Paragraphs are not numbered (a brief is not Fed. R. Civ. P. 10(b)).
#let body-chunks(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let flow = ()
  // The last chunk is returned as `tail`, so the caller can keep it with the signature block (the closing
  // paragraph and the signature stay on one page, as in the exemplar).
  let tail = ()
  let pending = []
  let has-pending = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      // Stacked headings (one heading under another) are one line apart; otherwise a blank line above.
      if has-pending { pending += v(body-leading) } else { pending += v(pitch) }
      pending += md(t)
      has-pending = true
      continue
    }
    let piece = if t.starts-with(">") {
      // A quotation: single spaced and indented on both sides (no rule; the exemplar's quotation).
      {
        show quote.where(block: true): it => {
          set par(leading: single-leading, first-line-indent: 0pt)
          pad(left: 0.5in, right: 0.5in, it.body)
        }
        md(t)
        v(body-leading)
      }
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list may break across pages; items are one pitch apart.
      {
        set par(leading: body-leading)
        md(t)
        v(body-leading)
      }
    } else {
      block(width: 100%, {
        set par(leading: body-leading, first-line-indent: 0pt)
        h(para-indent)
        md(t)
      })
      v(body-leading)
    }
    // A heading is kept with the first line of the chunk after it (a sticky block), and one blank line
    // separates the heading from that chunk.
    let items = if has-pending {
      (block(width: 100%, sticky: true, { pending; v(pitch + body-leading) }), piece)
    } else {
      (piece,)
    }
    flow += tail
    tail = items
    pending = []
    has-pending = false
  }
  if has-pending {
    flow += tail
    tail = (block(width: 100%, pending),)
  }
  (flow, tail)
}

/// The closing and signature block: the closing line ("Respectfully submitted,"), the party or firm lines,
/// "/s/" over the signer's name, and the signer's address, telephone, email, Arkansas Supreme Court ID
/// (LR 5.5(c)(1), when it applies) and role. A date line on the left when the frontmatter gives one.
#let signature-block(meta) = {
  v(body-leading)
  block(breakable: false, grid(
    columns: (2.6in, 1fr),
    column-gutter: 0.2in,
    if "date" in meta [Dated: #meta.date] else [],
    {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      if "closing" in meta {
        line-stack((meta.closing,))
        v(single-leading * 2)
      }
      if "firm" in meta.signature {
        line-stack(meta.signature.firm)
        v(single-leading * 2)
      }
      line-stack(("By: /s/ " + meta.signature.signer,) + meta.signature.lines)
    },
  ))
}

/// The certificate of service (when the frontmatter has one): its heading, the sentence the filer wrote,
/// the names and address served, and the signature. Kept on one page.
#let certificate(meta) = if "certificate" in meta {
  let c = meta.certificate
  block(breakable: false, width: 100%, {
    v(pitch)
    align(center, text(weight: "bold", "CERTIFICATE OF SERVICE"))
    v(body-leading)
    block(width: 100%, {
      set par(leading: body-leading, first-line-indent: 0pt)
      h(para-indent)
      md(c.body)
    })
    v(body-leading)
    pad(left: 0.5in, line-stack(c.served))
    v(body-leading)
    grid(
      columns: (2.6in, 1fr),
      column-gutter: 0.2in,
      [],
      {
        set par(leading: single-leading, spacing: 0pt, justify: false)
        line-stack(("/s/ " + meta.signature.signer, meta.signature.signer))
      },
    )
  })
}

#let arwd-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    footer: footer-page(),
    footer-descent: 0.4in,
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 is a centered bold section in capitals; level 2 a centered bold sub-heading as typed;
  // level 3 a bold left-aligned sub-heading. Spacing comes from the body (see body-chunks).
  show heading.where(level: 1): it => block(width: 100%, sticky: true, above: 0pt, below: 0pt,
    align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, sticky: true, above: 0pt, below: 0pt,
    align(center, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => block(width: 100%, sticky: true, above: 0pt, below: 0pt,
    text(weight: "bold", it.body))

  // First page: court title, caption, title of the paper.
  court-title(meta)
  v(pitch)
  caption(meta)
  v(pitch)
  title-block(meta)
  v(body-leading)

  set enum(numbering: "1.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  // The closing paragraph is kept on the page with the signature block.
  let (flow, tail) = body-chunks(body)
  for x in flow { x }
  block(breakable: false, width: 100%, {
    for x in tail { x }
    signature-block(meta)
  })
  certificate(meta)
}
