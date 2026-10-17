// Motion brief (memorandum of law in support of a motion) for the United States Bankruptcy Court for the
// District of Puerto Rico (prb). Rules (see ../README.md): LBR 9013-2(a) (supporting memorandum with points and
// authorities, citing the Code, the Rules, the LBRs and controlling authority), LBR 9013-1(c)(1) (response-time
// NOTICE, at least 11 point, in single or double space), LBR 9013-1(c)(2) (14, 21 or 30 day periods),
// LBR 1005-1(a) (case name, number, judge's initials and chapter on every paper), 1005-1(b) (8 1/2 x 11 inch pdf),
// 1005-1(c) (signature block), LBR 9013-3(a) (certificate of service). Not generated: the notice of motion,
// certifications, proposed order and the certificate of service's list of parties (separate papers or
// frontmatter, see README.md).
// Content-agnostic: every case-specific word comes from the sample's frontmatter and body, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a convention; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif"        // no typeface rule in the PR bankruptcy LBRs; Times New Roman substitute per docs/FONTS.md (convention)
#let type-size = 12pt                   // convention (the exemplar sets 12 pt); LBR 9013-1(c)(1) needs 11 pt minimum for the notice
#let page-w = 8.5in                     // LBR 1005-1(b): 8 1/2 x 11 inch
#let page-h = 11in
#let margin = 1in                       // convention (the exemplar has one-inch margins)
#let body-leading = 1.345em             // double spacing: Liberation Serif's line box is 0.655em, so 1.345em gives a 24 pt baseline pitch at 12 pt (measured, README.md)
#let pitch = 24pt                        // one double-spaced row: body-leading on a 12 pt line box
#let single-leading = 0.5em             // single spacing for the caption, the notice, quotations and the signature block
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-left = 3.4in               // width of the left (parties) column of the caption
#let text-width = page-w - 2 * margin
#let response-periods = (14, 21, 30)    // LBR 9013-1(c)(1) and (c)(2): days allowed to respond

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("prb-motion-brief: the sample must start with a YAML frontmatter block") }
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
  assert("bankruptcy_case" in meta, message: "prb-motion-brief: LBR 1005-1(a) requires the bankruptcy case number and judge's initials in the frontmatter (bankruptcy_case)")
  assert("chapter" in meta, message: "prb-motion-brief: LBR 1005-1(a) requires the chapter in the frontmatter (chapter)")
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
// Body: unnumbered paragraphs with footnotes, headings, block quotations
// ---------------------------------------------------------------------------

/// Footnote definitions are `[^n]: text` chunks; they are removed from the body and returned by number.
/// Returns (body without definitions, dictionary of number -> text).
#let split-footnotes(body) = {
  let defs = (:)
  let kept = ()
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")) {
    let m = c.trim().match(regex("^\\[\\^(\\d+)\\]:[ \\t]*([\\s\\S]*)$"))
    if m != none {
      defs.insert(m.captures.at(0), m.captures.at(1).trim())
    } else {
      kept.push(c)
    }
  }
  (kept.join("\n\n"), defs)
}

/// One paragraph's inline markdown. Each `[^n]` marker becomes a typst footnote whose text is definition n.
/// Typst numbers footnotes in order of appearance, so the sample's numbers must run in order too.
#let para-content(t, defs) = {
  let pos = 0
  let out = []
  for m in t.matches(regex("\\[\\^(\\d+)\\]")) {
    let n = m.captures.at(0)
    assert(n in defs, message: "prb-motion-brief: footnote [^" + n + "] has no definition in the sample")
    out += inl(t.slice(pos, m.start))
    out += footnote(inl(defs.at(n)))
    pos = m.end
  }
  out + inl(t.slice(pos))
}

/// Body blocks: each blank-line-separated chunk of markdown is a heading, a block quotation or one paragraph.
/// Paragraphs are not numbered (a memorandum of law, unlike a complaint, does not number its paragraphs).
#let body-blocks(body, defs) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      heading-block(cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1))
    } else if t.starts-with(">") {
      // Block quotation: single spaced and indented from both margins, then a double-spaced row below it.
      block(width: text-width, breakable: true, {
        set par(leading: single-leading, spacing: 0pt, justify: false)
        show quote.where(block: true): it => pad(x: 0.5in, it.body)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading - single-leading)
      })
    } else {
      on-grid({
        set par(leading: body-leading)
        h(para-indent)
        para-content(t, defs)
      })
    }
  }
}

// ---------------------------------------------------------------------------
// Notice of response time (LBR 9013-1(c)), certificate of service (LBR 9013-3(a)), signature (LBR 1005-1(c))
// ---------------------------------------------------------------------------

/// LBR 9013-1(c)(1): the notice is required on an initial motion and may be single or double spaced, in at
/// least 11 point type. The period is 14 days unless (c)(2) substitutes another; the text follows the rule.
#let response-notice(meta) = {
  let days = meta.at("response_days", default: 14)
  assert(days in response-periods, message: "prb-motion-brief: LBR 9013-1(c)(2) gives a response period of 14, 21 or 30 days (response_days)")
  let words = (
    "14": "fourteen (14)",
    "21": "twenty-one (21)",
    "30": "thirty (30)",
  ).at(str(days))
  block(width: text-width, breakable: false, {
    set par(leading: single-leading, spacing: 0pt, justify: true)
    v(body-leading)
    align(center, text(weight: "bold", "NOTICE"))
    v(single-leading)
    [Within #words days after service as evidenced by the certification, and an additional three (3) days pursuant to Fed. R. Bank. P. 9006(f) if you were served by mail, any party against whom this paper has been served, or any other party to the action who objects to the relief sought herein, shall serve and file an objection or other appropriate response to this paper with the clerk's office of the United States Bankruptcy Court for the District of Puerto Rico. If no objection or other response is filed within the time allowed herein, the paper will be deemed unopposed and may be granted unless: (i) the requested relief is forbidden by law; (ii) the requested relief is against public policy; or (iii) in the opinion of the court, the interest of justice requires otherwise.]
  })
}

#let certificate-of-service(meta) = if "certificate" in meta {
  block(width: text-width, breakable: false, {
    set par(leading: body-leading, spacing: 0pt, justify: false)
    v(body-leading)
    on-grid({
      set par(leading: body-leading)
      text(weight: "bold", "CERTIFICATE OF SERVICE: ")
      inl(meta.certificate)
    })
  })
}

#let signature-block(meta) = {
  assert("signature" in meta, message: "prb-motion-brief: the frontmatter needs a signature block (LBR 1005-1(c))")
  assert("signer" in meta.signature, message: "prb-motion-brief: the signature block needs the signer's name (LBR 5005-4(b)(2)(C)(ii): /s/ name)")
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

#let prb-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    footer: footer-number(),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  // Footnotes: the same size as the text (convention; the exemplar's footnotes are the text size).
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em)

  // Headings: level 1 is a bold capitals section; level 2 bold; level 3 bold italic (the exemplar's sub-point).
  show heading.where(level: 1): it => heading-block(text(size: type-size, weight: "bold", upper(it.body)))
  show heading.where(level: 2): it => heading-block(text(size: type-size, weight: "bold", it.body))
  show heading.where(level: 3): it => heading-block(text(size: type-size, weight: "bold", style: "italic", it.body))

  cover(meta)

  on-grid(text(weight: "bold", "TO THE HONORABLE COURT:"))

  let (text-body, defs) = split-footnotes(body)

  if "lead_in" in meta {
    on-grid({
      set par(leading: body-leading)
      h(para-indent)
      inl(meta.lead_in)
    })
  }

  body-blocks(text-body, defs)

  response-notice(meta)
  certificate-of-service(meta)
  signature-block(meta)
}
