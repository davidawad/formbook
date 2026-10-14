// U.S. District Court, District of Massachusetts: memorandum of law supporting a motion (Fed. R. Civ. P. 7(b),
// 12(b)(6); D. Mass. L.R. 5.1, 7.1(a)(2), 7.1(b)(1), 7.1(b)(4)). Requirement IDs (MAD-...) and the rule text are
// in ../README.md. Content-agnostic: every case-specific word comes from the sample's frontmatter or markdown body,
// never from this file. The markdown body is rendered by cmarker. No forced line breaks, no coordinates measured
// off the exemplar.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a named style choice; see ../README.md)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"     // MAD-FORM-002: L.R. 5.1 sets no typeface; EB Garamond is the serif vendored in fonts/
#let type-size = 13pt                // style choice: 13 pt EB Garamond is about the apparent size of 12 pt Times (README)
#let body-leading = 1.2em            // MAD-FORM-001: double spacing, 24 pt between baselines at 13 pt (EB Garamond line box 0.65 em + 1.2 em) (L.R. 5.1(a)(2))
#let single-leading = 0.45em         // single spacing: caption, quotations, footnotes, signature block, certificates (exempt under L.R. 5.1(a)(2))
#let para-gap = 0.65em               // gap between paragraphs (a zero gap makes typst 0.15 stack paragraphs on top of each other)
#let page-margin = 1in               // style choice (the rules set paper size only, L.R. 5.1(a)(2))
#let para-indent = 0.5in             // first-line indent of body paragraphs
#let caption-left = 3.5in            // width of the party column of the caption (wide enough that a party name does not wrap a word)
#let sig-indent = 3.0in              // left edge of the signature block
#let footer-size = 12pt
#let footnote-size = 12pt            // footnotes are single-spaced; size is a style choice

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mad-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, smart quotes) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// A stack of single-spaced lines (counsel, party names, signature lines).
#let lines(items) = stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))

// ---------------------------------------------------------------------------
// Caption (MAD-CAP-001..003: court name, title, civil action number)
// ---------------------------------------------------------------------------

#let court-title() = align(center, stack(dir: ttb, spacing: single-leading,
  text(weight: "bold", "IN THE UNITED STATES DISTRICT COURT"),
  text(weight: "bold", "FOR THE DISTRICT OF MASSACHUSETTS"),
))

#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.25in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 10pt), {
    // Each party: its names, then its designation, indented; "v." between the parties.
    let rows = ()
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 {
        rows.push(block(height: 0.6em))
        rows.push(pad(left: 0.5in, inl("v.")))
        rows.push(block(height: 0.6em))
      }
      for n in p.names { rows.push(inl(n)) }
      rows.push(block(height: 0.6em))
      rows.push(pad(left: 1.25in, inl(p.designation)))
    }
    stack(dir: ttb, spacing: single-leading, ..rows)
  }),
  block(inset: (left: 0.1in), {
    set par(leading: single-leading, spacing: para-gap, justify: false)
    [Civil Action No. #meta.case_number]
  }),
)

// ---------------------------------------------------------------------------
// Body: headings, paragraphs, quotations
// ---------------------------------------------------------------------------

/// Body paragraphs are not numbered (a memorandum, unlike a complaint, has no numbered paragraphs).
/// Each blank-line-separated chunk is one paragraph with a first-line indent; a heading is kept in one
/// unbreakable block with the chunk after it, so a heading never ends a page; a `>` chunk is a quotation.
/// Numbering is not used here, so there is no counter: the chunk loop is the whole layout.
#let paragraphs(body) = {
  // Footnote definitions (`[^key]: text`, one line each) are collected here and attached to the chunk that
  // cites them: cmarker resolves a reference only against a definition in the same render call, and the body
  // is rendered one chunk at a time.
  let defs = (:)
  for m in body.matches(regex("(?m)^\\[\\^([^\\]]+)\\]:[ \\t]*(.*)$")) {
    defs.insert(m.captures.at(0), m.captures.at(1))
  }
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "" and not c.trim().starts-with("[^"))
  let pending = []
  let has-pending = false
  for c in chunks {
    let t = c.trim()
    for (k, v) in defs {
      if t.contains("[^" + k + "]") { t = t + "\n\n[^" + k + "]: " + v }
    }
    let piece = none
    if t.starts-with("#") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
      continue
    } else if t.starts-with(">") {
      // A quotation: single-spaced and indented (L.R. 5.1(a)(2) exempts quotations).
      piece = cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list, spaced like body text. It may break across pages.
      piece = {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      }
    } else {
      piece = block(width: 100%, {
        set par(leading: body-leading)
        h(para-indent)
        inl(t)
      })
    }
    if has-pending {
      block(breakable: false, width: 100%, { pending; piece })
    } else {
      piece
    }
    pending = []
    has-pending = false
  }
  if pending != [] { block(breakable: false, width: 100%, pending) }
}

// ---------------------------------------------------------------------------
// Signature, certificates
// ---------------------------------------------------------------------------

/// The signature block (MAD-SIG-001: the board of bar overseers number under each attorney's name, L.R. 5.1(a)(1)).
#let signature(meta) = {
  let sig = meta.signature
  block(breakable: false, width: 100%, {
    set par(leading: single-leading, spacing: para-gap, justify: false)
    v(body-leading)
    [DATED: #meta.date]
    v(body-leading)
    pad(left: sig-indent, stack(dir: ttb, spacing: body-leading,
      lines(sig.lead),
      stack(dir: ttb, spacing: body-leading,
        inl("By: /s/ " + sig.signer),
        stack(dir: ttb, spacing: body-leading, ..sig.attorneys.map(a => lines((
          a.name + " (BBO# " + a.bbo + ")",
          a.email,
        )))),
        lines(sig.firm),
      ),
    ))
  })
}

/// Certificate of service (MAD-CERT-001). Fed. R. Civ. P. 5(d)(1)(B): no certificate is required when the paper
/// is served by filing it with the court's electronic-filing system; the certificate is rendered when the sample has one.
#let service-block(meta) = {
  if "service" in meta {
    let svc = meta.service
    block(breakable: false, width: 100%, {
      set par(leading: single-leading, spacing: para-gap, justify: true)
      v(body-leading)
      align(center, text(weight: "bold", "CERTIFICATE OF SERVICE"))
      v(body-leading)
      block(width: 100%, {
        set par(leading: body-leading)
        h(para-indent)
        [I hereby certify that on #svc.date, a true copy of the foregoing document was electronically filed through the Court's ECF system on all counsel of record:]
      })
      v(body-leading)
      stack(dir: ttb, spacing: body-leading, ..svc.counsel.map(c => lines(c)))
      v(body-leading)
      lines(("/s/ " + meta.signature.signer, meta.signature.signer))
    })
  }
}

/// Certificate of consultation (MAD-CERT-002: L.R. 7.1(a)(2)). Rendered when the sample carries `consultation`.
#let consultation-block(meta) = {
  if "consultation" in meta {
    block(breakable: false, width: 100%, {
      set par(leading: body-leading)
      v(body-leading)
      align(center, text(weight: "bold", "CERTIFICATE OF CONSULTATION"))
      v(body-leading)
      h(para-indent)
      inl(meta.consultation)
    })
  }
}

// ---------------------------------------------------------------------------
// Entry
// ---------------------------------------------------------------------------

#let mad-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: page-margin,
    footer: context align(center, text(size: footer-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: para-gap, first-line-indent: 0pt, justify: true)

  // Headings: level 1 centered bold capitals; level 2 bold, left, hanging (the argument's I., II., ...);
  // level 3 bold, left (a sub-heading).
  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 0.9em, sticky: true,
    align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, above: 1.0em, below: 0.9em, sticky: true,
    par(hanging-indent: 0.5in, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => block(width: 100%, above: 0.9em, below: 0.9em, sticky: true,
    par(hanging-indent: 0.5in, text(weight: "bold", it.body)))

  // Quotations: single-spaced, indented 0.5 in on both sides.
  show quote.where(block: true): it => pad(left: 0.5in, right: 0.5in, top: 0.3em, bottom: body-leading,
    {
      set par(leading: single-leading, justify: true)
      it.body
    })

  // Footnotes: single-spaced.
  show footnote.entry: set text(size: footnote-size)
  show footnote.entry: set par(leading: single-leading, justify: true)

  court-title()
  v(body-leading * 2)
  caption(meta)
  v(body-leading * 2)
  block(width: 100%, {
    set par(leading: single-leading, justify: false)
    align(center, text(weight: "bold", upper(meta.title)))
  })
  v(body-leading)

  paragraphs(body)

  signature(meta)
  service-block(meta)
  consultation-block(meta)
}
