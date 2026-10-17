// Adversary complaint for the United States Bankruptcy Court for the District of Alaska (akb).
// Rules: Fed. R. Bankr. P. 7010 (Fed. R. Civ. P. 10 applies; caption substantially conforms to Official Form 416D),
// 7008(a) (jurisdiction allegation; statement whether the pleader consents to entry of final orders),
// 9004(a)-(b) (legible; caption); D. Alaska LBR 9004-1 (letter size, margins, double spacing, 12-point
// type, page numbers, counsel block) and LBR 7003-1, 7012-1. See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")    // LBR 9004-1(a)(7): 12 point or 10 pitch; only vendored fonts
#let type-size = 12pt
#let pitch = 24pt                   // LBR 9004-1(a)(4): double spacing
#let page-w = 8.5in                 // LBR 9004-1(a)(1): letter size
#let page-h = 11in
#let margin = 1in                   // LBR 9004-1(a)(2): not less than 1 inch on all four sides
#let text-width = page-w - 2 * margin
#let body-leading = 1.35em          // 0.65em line box + 1.35em = 2em, which is 24 pt at 12 pt (see README)
#let single-leading = 0.5em         // about 13.8 pt at 12 pt: counsel, caption, signature, quotations
#let para-indent = 0.5in
#let caption-left = 3.3in           // party column of the caption (Official Form 416D layout)
#let caption-gutter = 0.25in

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("akb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, section signs, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line per item, stacked.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Page number centered at the foot of each page (LBR 9004-1(a)(5)).
#let footer-page = context align(center, text(size: type-size, counter(page).display()))

// ---------------------------------------------------------------------------
// Cover: attorney block (top left), court title, caption, title of the paper
// ---------------------------------------------------------------------------

/// The attorney block sits at the top of the page, at least one inch down (LBR 9004-1(c)(2)(A)).
#let counsel-block(meta) = line-stack(meta.counsel)

/// Court title (FRBP 9004(b)(1)): two single-spaced lines, centered.
#let court-title() = {
  v(pitch)
  set par(leading: single-leading, spacing: 0pt)
  align(center, stack(dir: ttb, spacing: single-leading,
    text(weight: "bold", "IN THE UNITED STATES BANKRUPTCY COURT"),
    text(weight: "bold", "FOR THE DISTRICT OF ALASKA"),
  ))
  v(pitch)
}

/// Caption (FRBP 9004(b)(2)-(3), Official Form 416D): each party group is a left cell, ruled below,
/// with the case numbers beside it in the right cell; "v." sits between the groups.
#let caption(meta) = {
  let cells = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 {
      cells += (pad(left: 1.2in, top: 4pt, bottom: 4pt, "v."), [])
    }
    let lead = if "lead" in p { (p.lead,) } else { () }
    cells += (
      block(width: 100%, inset: (bottom: 6pt, right: 10pt), stroke: (bottom: 0.75pt), {
        set par(leading: single-leading, spacing: 0pt, justify: false)
        stack(dir: ttb, spacing: single-leading,
          ..lead.map(i => inl(i)),
          ..p.names.map(i => inl(i)),
          align(right, inl(p.designation)),
        )
      }),
      block(inset: (left: 0.1in), {
        let rights = if "right" in p { p.right } else { () }
        line-stack(rights)
      }),
    )
  }
  grid(columns: (caption-left, 1fr), column-gutter: caption-gutter, row-gutter: 0pt, ..cells)
}

/// Title of the paper: bold, centered; the subtitle (e.g. the Code sections) below it.
#let title-block(meta) = {
  v(pitch)
  set par(leading: single-leading, spacing: 0pt, justify: false)
  align(center, text(weight: "bold", upper(meta.brief_title)))
  if "brief_subtitle" in meta and meta.brief_subtitle != none {
    v(single-leading)
    align(center, inl(meta.brief_subtitle))
  }
  v(pitch)
}

#let cover(meta) = {
  counsel-block(meta)
  court-title()
  caption(meta)
  title-block(meta)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// Numbered allegations (Fed. R. Civ. P. 10(b), applied by FRBP 7010). Each blank-line-separated chunk of
/// markdown that is a paragraph is one numbered paragraph. Headings, tables, table captions and lists are
/// not numbered. Numbering is applied per chunk, not with a `show par` rule (typst 0.15 recurses on that).
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      // A heading: its show rule makes it a block with space above and below.
      set par(leading: body-leading)
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with("|") {
      // Tables are unnumbered. Rules are thin; the header row is bold.
      show table: set table(stroke: 0.5pt, inset: 5pt)
      set par(leading: single-leading)
      block(breakable: false, width: 100%, above: pitch * 0.5, below: pitch * 0.5,
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1))
    } else if t.starts-with(regex("^Table \\d")) {
      // A table caption, centered and bold, unnumbered.
      set par(leading: single-leading)
      block(breakable: false, width: 100%, above: pitch * 0.5, below: pitch * 0.5, align(center, text(weight: "bold", inl(t))))
    } else if t.starts-with(">") {
      // A block quotation: unnumbered; its show rule (below) sets the single spacing and indent.
      set par(leading: single-leading)
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Relief items are lettered (A., B., ...), as in the filed complaint. Items are spaced double.
      block(width: 100%, above: 0pt, below: body-leading, {
        set par(leading: body-leading)
        set enum(numbering: "A.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
        set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
    } else {
      para-counter.step()
      // below: the leading again, so the next paragraph starts one double-spaced line below this one.
      block(width: 100%, above: 0pt, below: body-leading, {
        set par(leading: body-leading)
        context [#h(para-indent)#para-counter.display("1.") #h(0.2in)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)]
      })
    }
  }
}

/// The statement of consent (FRBP 7008(a); LBR 7012-1). Required in every complaint; unnumbered.
#let consent-block(meta) = {
  assert("consent" in meta, message: "akb-adversary-complaint: FRBP 7008(a) and LBR 7012-1 require a consent statement (frontmatter: consent)")
  v(pitch)
  set par(leading: body-leading)
  block(breakable: false, width: 100%, {
    text(weight: "bold", "STATEMENT REGARDING CONSENT")
    linebreak()
    h(para-indent)
    inl(meta.consent)
  })
}

/// Signature block (LBR 9004-1(a)(9): names typed beneath signatures). Date at left when given.
#let signature-block(meta) = {
  v(pitch)
  block(breakable: false, grid(
    columns: (caption-left, 1fr),
    column-gutter: caption-gutter,
    if "date" in meta and meta.date != none [Dated: #meta.date] else [],
    {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      line-stack(meta.signature.firm)
      v(single-leading)
      line-stack(meta.signature.lines)
      v(pitch * 0.5)
      line-stack(("/s/ " + meta.signature.signer, meta.signature.signer))
    },
  ))
}

#let akb-adversary-complaint(meta, body) = {
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: margin,
    footer: footer-page,
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 centered and bold, in capitals; level 2 bold; level 3 bold italic. Each is its own
  // block with a full double line above it, kept with the paragraph after it.
  show heading.where(level: 1): it => block(width: 100%, above: pitch, below: pitch * 0.5, sticky: true,
    align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, above: pitch * 0.5, below: pitch * 0.5, sticky: true,
    text(weight: "bold", it.body))
  show heading.where(level: 3): it => block(width: 100%, above: pitch * 0.5, below: pitch * 0.5, sticky: true,
    text(weight: "bold", style: "italic", it.body))

  // Quotations are single-spaced and indented (LBR 9004-1(a)(4): quotations over fifty words).
  show quote.where(block: true): it => block(width: 100%, inset: (left: 0.5in, right: 0.5in), above: 0pt, below: body-leading, {
    set par(leading: single-leading)
    it.body
  })

  cover(meta)

  if "lead_in" in meta {
    block(width: 100%, above: pitch, below: 0pt, {
      set par(leading: body-leading)
      h(para-indent)
      inl(meta.lead_in)
    })
  }

  allegations(body, para-counter)

  consent-block(meta)
  signature-block(meta)
}
