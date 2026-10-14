// Adversary complaint for the United States Bankruptcy Court for the District of Puerto Rico (prb).
// Rules (see ../README.md): FRBP 7010 (FRCP 10 applies; the caption substantially conforms to Form 416A),
// FRCP 10(a) (caption; the title names all parties) and 10(b) (numbered paragraphs), FRBP 9004(b) (caption),
// LBR 1005-1(a) (bankruptcy case name, number, judge's initials and chapter on every paper), 1005-1(b)
// (8 1/2 x 11 inch pdf), 1005-1(c) (signature block). Not generated: the B1040 cover sheet (LBR 7003-1)
// and the summons (LBR 7004-2), which are separate filings.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a convention; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // no typeface rule in the PR bankruptcy LBRs; vendored serif (convention)
#let type-size = 12pt                   // convention (both exemplars set 12 pt); LBR 9013-1(c)(1) needs 11 pt minimum for notices
#let page-w = 8.5in                     // LBR 1005-1(b): 8 1/2 x 11 inch
#let page-h = 11in
#let margin = 1in                       // convention (both exemplars have one-inch margins)
#let body-leading = 1.35em              // double spacing: EB Garamond's line box is 0.65em, so 1.35em gives a 24 pt baseline pitch at 12 pt (measured, README.md)
#let pitch = 24pt                        // one double-spaced row: body-leading on a 12 pt line box
#let single-leading = 0.5em             // single spacing for the caption, the title block and the signature block
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let caption-left = 3.4in               // width of the left (parties) column of the caption
#let text-width = page-w - 2 * margin

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("prb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for case names, *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Single-spaced lines, one item per line.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

/// A block of whole double-spaced rows: its height is rounded up to a multiple of `pitch`, so whatever
/// follows it stays on the same 24 pt grid (a one-line block would otherwise be only one line box high).
#let on-grid(c) = context {
  let h = measure(width: text-width, c).height
  block(width: text-width, height: calc.ceil(h / pitch) * pitch, above: 0pt, below: 0pt, c)
}

/// A heading: whole rows (a long heading may wrap), kept with the paragraph after it, so it never ends a page.
#let heading-block(c) = context {
  let h = measure(width: text-width, c).height
  block(width: text-width, height: calc.ceil(h / pitch) * pitch, above: 0pt, below: 0pt, sticky: true, c)
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Page number, centered in the footer.
#let footer-number() = context align(center, text(size: type-size, counter(page).display()))

// ---------------------------------------------------------------------------
// Caption: court, debtor, parties, case number, chapter, adversary number, title
// ---------------------------------------------------------------------------

#let court-title(meta) = align(center, {
  for (k, line) in meta.court.enumerate() {
    if k > 0 { linebreak() }
    text(weight: "bold", upper(line))
  }
})

#let caption(meta) = {
  assert("bankruptcy_case" in meta, message: "prb-adversary-complaint: LBR 1005-1(a) requires the bankruptcy case number and judge's initials in the frontmatter (bankruptcy_case)")
  assert("chapter" in meta, message: "prb-adversary-complaint: LBR 1005-1(a) requires the chapter in the frontmatter (chapter)")
  grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.2in,
    block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 10pt), {
      // "In re:" and the debtor, then a rule, then the parties; "v." between the parties.
      set par(leading: single-leading, spacing: 0pt, justify: false)
      line-stack(("In re:",) + meta.debtor.names + (meta.debtor.designation,))
      v(single-leading)
      line(length: 100%, stroke: 0.75pt)
      v(single-leading)
      let rows = ()
      for (k, p) in meta.parties.enumerate() {
        if k > 0 { rows.push("v.") }
        rows += p.names + (p.designation,)
      }
      line-stack(rows)
    }),
    block(inset: (left: 0.15in), {
      // An adversary number that is not yet assigned prints as a blank to fill in (the exemplar leaves it blank).
      let adv = meta.at("adversary", default: "")
      set par(leading: single-leading, spacing: 0pt, justify: false)
      line-stack((
        "Bankr. Case No. " + meta.bankruptcy_case,
        meta.chapter,
        "Adv. Proceeding No. " + if adv == "" { "__________" } else { adv },
      ))
    }),
  )
}

#let cover(meta) = {
  court-title(meta)
  v(body-leading)
  caption(meta)
  v(body-leading)
  align(center, text(weight: "bold", inl(meta.title)))
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs, headings, lettered prayer items
// ---------------------------------------------------------------------------

/// Numbered paragraphs (FRCP 10(b)). Each blank-line-separated chunk of markdown that is neither a heading
/// nor a list is one numbered paragraph. Headings and lists are not numbered. Numbering is applied per chunk,
/// not with a `show par` rule: a show rule that re-wraps paragraph content recurses without end in typst 0.15.
#let body-chunks(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let pending = []
  let has-pending = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Prayer items: lettered A., B., ... A list may break across pages; a heading in front of it stays with its first line.
      let items = {
        set par(leading: body-leading)
        set enum(numbering: "A.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      }
      if has-pending {
        block(breakable: false, width: text-width, { pending; items })
      } else {
        items
      }
      pending = []
      has-pending = false
    } else {
      // Each paragraph is its own block: inline pieces would merge into one paragraph and overlap.
      // A paragraph that starts with "(unnumbered) " (for example the WHEREFORE lead-in of the prayer) is not numbered.
      let numbered = not t.starts-with("(unnumbered) ")
      let text-md = if numbered { t } else { t.slice(13) }
      if numbered { para-counter.step() }
      let piece = on-grid({
        set par(leading: body-leading)
        h(para-indent)
        if numbered {
          context [#(para-counter.display()).#h(0.3in)#cmarker.render(text-md, raw-typst: false, smart-punctuation: true, h1-level: 1)]
        } else {
          cmarker.render(text-md, raw-typst: false, smart-punctuation: true, h1-level: 1)
        }
      })
      if has-pending {
        block(breakable: false, width: text-width, { pending; piece })
      } else {
        piece
      }
      pending = []
      has-pending = false
    }
  }
  if pending != [] { block(breakable: false, width: text-width, pending) }
}

#let signature-block(meta) = {
  assert("signature" in meta, message: "prb-adversary-complaint: the frontmatter needs a signature block (LBR 1005-1(c))")
  assert("signer" in meta.signature, message: "prb-adversary-complaint: the signature block needs the signer's name (LBR 5005-4(b)(2)(C)(ii): /s/ name)")
  v(body-leading)
  block(breakable: false, width: text-width, {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    [Respectfully submitted,]
    v(body-leading)
    [#meta.signature.date]
    v(body-leading)
    pad(left: 3.0in, line-stack(("/s/ " + meta.signature.signer,) + meta.signature.lines))
  })
}

#let prb-adversary-complaint(meta, body) = {
  let para-counter = counter("paragraph")

  set page(
    paper: "us-letter",
    margin: margin,
    footer: footer-number(),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 is a bold capitals section ("I. INTRODUCTION"); level 2 bold; level 3 bold italic.
  show heading.where(level: 1): it => heading-block(text(size: type-size, weight: "bold", upper(it.body)))
  show heading.where(level: 2): it => heading-block(text(size: type-size, weight: "bold", it.body))
  show heading.where(level: 3): it => heading-block(text(size: type-size, weight: "bold", style: "italic", it.body))

  cover(meta)

  on-grid(text(weight: "bold", "TO THE HONORABLE COURT:"))

  if "lead_in" in meta {
    on-grid({
      set par(leading: body-leading)
      h(para-indent)
      inl(meta.lead_in)
    })
  }

  body-chunks(body, para-counter)

  signature-block(meta)
}
