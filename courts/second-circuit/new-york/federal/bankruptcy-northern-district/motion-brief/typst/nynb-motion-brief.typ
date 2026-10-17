// Memorandum of law in support of a motion, U.S. Bankruptcy Court, N.D.N.Y. (nynb).
// Rules: FRBP 9013 (a request for an order must be made by written motion); LBR 9013-1(a)(1) (the relief, the party
// against whom it is sought and the rule or statute relied on are stated plainly), (c) (certificate of service),
// (g)(1) (hearing date, time and location above the case number), (h) (chambers copy marked "ECF CASE – CHAMBERS
// COPY"); LBR 9004-1(a) (form), (c) (caption), (d) (noncompliance); FRBP 7012(b) when the motion is in an adversary
// proceeding (Fed. R. Civ. P. 12(b) applies). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see ../README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif"     // Times New Roman substitute per docs/FONTS.md, vendored in fonts/; --ignore-system-fonts means no other substitute
#let type-size = 12pt                // LBR 9004-1(a)(1)(A): minimum 12-point, text and footnotes
#let pitch = 24pt                    // LBR 9004-1(a)(1)(B): double-spaced body (baseline pitch, measured)
#let page-w = 8.5in                  // LBR 9004-1(a)(2)(C): letter size
#let page-h = 11in
#let margin = 1in                    // LBR 9004-1(a)(2)(A): one-inch margin on all four sides
#let text-width = page-w - 2 * margin
#let body-leading = 1.345em          // 0.655em line box + 1.345em leading = 2.0em = 24 pt at 12 pt
#let single-leading = 0.5em          // 0.65em + 0.5em = 1.15em = 13.8 pt: caption, counsel, block quotes, signature
#let para-indent = 0.5in             // first line of each body paragraph (memorandum text is not numbered)
#let caption-left = 3.4in            // width of the party column of the caption
#let caption-gutter = 0.25in

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nynb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, section symbols, case names).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Single-spaced stack of lines (caption, counsel, signature).
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false, first-line-indent: 0pt)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Caption and cover (LBR 9004-1(c); FRBP 9004(b); LBR 9013-1(g)(1); LBR 9013-1(h))
// ---------------------------------------------------------------------------

#let counsel-block(meta) = if "counsel" in meta and meta.counsel != none {
  block(width: text-width, line-stack(meta.counsel))
  v(pitch)
}

#let court-title() = stack(dir: ttb, spacing: single-leading,
  align(center, text(weight: "bold", "UNITED STATES BANKRUPTCY COURT")),
  align(center, text(weight: "bold", "NORTHERN DISTRICT OF NEW YORK")),
)

/// The bankruptcy caption: debtor on the left; hearing (when given) and case number and chapter on the right.
/// The hearing lines sit above the case number, as LBR 9013-1(g)(1) requires for answering papers.
#let bankruptcy-caption(meta) = {
  let debtor = (("In re:",) + meta.debtor.names + ("(" + meta.debtor.tin + ")",) + ("Debtor.",))
  grid(
    columns: (caption-left, 1fr),
    column-gutter: caption-gutter,
    block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 10pt),
      line-stack(debtor)),
    block(inset: (left: 0.1in), line-stack(
      (if "hearing" in meta and meta.hearing != none {
        ("Hearing: " + meta.hearing.date, "Time: " + meta.hearing.time, "Location: " + meta.hearing.location)
      } else { () })
      + ("Case No. " + meta.case_number, "Chapter " + str(meta.chapter)))),
  )
}

/// The adversary caption, shown only when the motion is filed in an adversary proceeding.
#let adversary-caption(meta) = if "adversary" in meta and meta.adversary != none {
  let rows = ()
  for (k, p) in meta.adversary.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names + (p.designation,)
  }
  grid(
    columns: (caption-left, 1fr),
    column-gutter: caption-gutter,
    block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 10pt),
      line-stack(rows)),
    block(inset: (left: 0.1in), line-stack(("Adv. Pro. No. " + meta.adversary.number,))),
  )
}

#let cover(meta) = {
  // The chambers-copy legend (LBR 9013-1(h)) is marked on the first page, above the counsel block.
  if "chambers_copy" in meta and meta.chambers_copy {
    align(right, text(weight: "bold", "ECF CASE – CHAMBERS COPY"))
    v(single-leading)
  }
  counsel-block(meta)
  court-title()
  v(pitch)
  bankruptcy-caption(meta)
  if "adversary" in meta and meta.adversary != none {
    v(single-leading)
    adversary-caption(meta)
  }
  v(pitch)
  align(center, text(weight: "bold", meta.title))
  v(pitch)
}

// ---------------------------------------------------------------------------
// Body: unnumbered memorandum paragraphs, headings, block quotations
// ---------------------------------------------------------------------------

/// Each blank-line-separated chunk of markdown is one unit. "#" is a centred heading (PRELIMINARY STATEMENT,
/// ARGUMENT); "##" is a bold heading flush left (a POINT heading); "###" is bold italic flush left. A chunk
/// starting with ">" is a block quotation, single-spaced and indented on both sides (LBR 9004-1(a)(1)(B)).
/// Every other chunk is one paragraph with a first-line indent. The leading after each unit is added by hand:
/// typst puts leading only between the lines of a paragraph, not after its last line.
#let body-content(body) = {
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let out = []
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      let level = t.match(regex("^#+")).text.len()
      let words = t.slice(level).trim()
      out += v(pitch)
      if level == 1 {
        out += block(width: text-width, sticky: true,
          align(center, text(weight: "bold", inl(words))))
      } else if level == 2 {
        out += block(width: text-width, sticky: true, par(first-line-indent: 0pt, text(weight: "bold", inl(words))))
      } else {
        out += block(width: text-width, sticky: true,
          par(first-line-indent: 0pt, text(weight: "bold", style: "italic", inl(words))))
      }
      out += v(body-leading)
    } else if t.starts-with(">") {
      out += block(width: text-width, breakable: true, inset: (x: 0.5in), {
        set par(leading: single-leading, first-line-indent: 0pt)
        inl(t)
      })
      out += v(body-leading)
    } else {
      out += block(width: text-width, breakable: true, [#h(para-indent)#inl(t)])
      out += v(body-leading)
    }
  }
  out
}

// ---------------------------------------------------------------------------
// Signature block and certificate of service (LBR 9013-1(c))
// ---------------------------------------------------------------------------

#let signature(meta) = block(width: text-width, breakable: false, {
  v(pitch)
  grid(
    columns: (3in, 1fr),
    column-gutter: caption-gutter,
    [Dated: #meta.dated],
    line-stack(("Respectfully submitted,",) + meta.signature.firm + ("",
      "By: /s/ " + meta.signature.signer) + meta.signature.lines),
  )
})

/// The certificate of service follows the signature block. Its manner of service is stated by the sample
/// (LBR 9013-1(c): "the manner in which service or notice was accomplished on each party").
#let certificate(meta) = if "certificate" in meta and meta.certificate != none {
  block(width: text-width, breakable: true, {
    v(pitch)
    block(width: text-width, sticky: true, align(center, text(weight: "bold",
      meta.certificate.at("title", default: "CERTIFICATE OF SERVICE"))))
    v(body-leading)
    set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
    for p in meta.certificate.paragraphs {
      [#h(para-indent)#inl(p)]
      v(body-leading)
    }
    block(width: text-width, breakable: false, grid(
      columns: (3in, 1fr),
      column-gutter: caption-gutter,
      // A sworn affidavit of service may carry no date line of its own (the jurat carries the date).
      if "dated" in meta.certificate [Dated: #meta.certificate.dated] else [],
      line-stack(("", "/s/ " + meta.certificate.signer)),
    ))
  })
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let nynb-motion-brief(meta, body) = {
  set document(title: meta.title)
  set page(
    paper: "us-letter",
    margin: margin,
    numbering: "1",
    number-align: center + bottom,
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us")
  cover(meta)
  body-content(body)
  signature(meta)
  certificate(meta)
}
