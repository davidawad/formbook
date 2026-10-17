// Motion with incorporated memorandum (or memorandum in support of motion) for the United States Bankruptcy
// Court, Southern District of Florida, filed in an adversary proceeding.
// Rules (verified 2026-10-14; see ../README.md): Fed. R. Bankr. P. 9004(b) (caption), 9013 (a motion must state
// its grounds with particularity and the relief requested), 7010 (adversary caption); S.D. Fla. Bankr. L.R.
// 9004-1(a)(2)-(4) (1-inch margins, 12-point type, double spacing except captions, headings, quotations over
// 50 words, footnotes, signature blocks and certificates), 9004-1(d) (no incorporation by reference of other
// filed documents), 9004-1(e)(2) (adversary caption form), 9013-1(a) (conferral certification).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // L.R. 9004-1(a)(3): 12-point font, no face named; Times New Roman substitute per docs/FONTS.md
#let type-size = 12pt                   // L.R. 9004-1(a)(3)
#let footnote-size = 10pt               // L.R. 9004-1(a)(3): footnotes may be 10-point
#let margin = 1in                       // L.R. 9004-1(a)(2): at least one inch on every side
#let page-w = 8.5in                     // US Letter
#let text-width = page-w - 2 * margin
#let body-leading = 1.345em             // L.R. 9004-1(a)(4): double spacing; with Liberation Serif's 0.655em line box this is a 24 pt pitch at 12 pt
#let single-leading = 0.495em            // single spacing for caption, signature block, quotations and certificate
#let pitch-gap = 24pt                   // one double-spaced line: the unit of vertical space between parts of the cover and signature
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-left = 3.4in               // width of the party column of the caption
#let quote-inset = 0.5in                // block quotations are indented on both sides

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("flsb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

/// A heading kept with the paragraph after it (a heading never ends a page).
#let heading-block(c) = block(width: text-width, above: 0.5 * pitch-gap, below: body-leading, sticky: true, c)

// ---------------------------------------------------------------------------
// Caption (L.R. 9004-1(e)(2)): court, division, debtor and case, party and adversary number
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  align(center, text(weight: "bold", stack(dir: ttb, spacing: single-leading,
    "UNITED STATES BANKRUPTCY COURT",
    meta.district,
  )))
  v(pitch-gap)
  // The division is printed as a blank line when the sample does not name one (L.R. 9004-1(e)(2)).
  let division = if "division" in meta { upper(meta.division) } else { "___________" }
  align(center, text(weight: "bold", division + " DIVISION"))
}

#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.2in,
  block(width: caption-left, {
    set par(leading: single-leading, spacing: 0pt)
    line-stack(("In re:", ..meta.debtor.names, meta.debtor.designation))
    v(pitch-gap * 0.5)
    line-stack(("_" * 36 + "/",))
    v(pitch-gap * 0.5)
    let rows = ()
    for (k, p) in meta.parties.enumerate() {
      if k > 0 { rows.push("v.") }
      rows += p.names + (p.designation,)
    }
    line-stack(rows)
    v(pitch-gap * 0.5)
    line-stack(("_" * 36 + "/",))
  }),
  block({
    set par(leading: single-leading, spacing: 0pt)
    line-stack(("Case No. " + meta.case_number, "Chapter " + meta.chapter))
    v(pitch-gap * 2)
    line-stack(("Adv. Case No. " + meta.adv_number,))
  }),
)

#let cover(meta) = {
  court-title(meta)
  v(pitch-gap)
  caption(meta)
  v(pitch-gap)
  align(center, text(weight: "bold", inl(meta.title)))
  v(pitch-gap)
}

// ---------------------------------------------------------------------------
// Body. Paragraphs are double-spaced with a first-line indent and not numbered. Headings are typed by the author
// (I., A., (i)); block quotations are single-spaced; lettered or roman parentheticals are indented.
// ---------------------------------------------------------------------------

/// Footnote definitions ("[^key]: text") of the body, by key.
#let footnote-defs(body) = {
  let defs = ()
  for line in body.split("\n") {
    let m = line.match(regex("^\\[\\^([^\\]]+)\\]:[ \\t]*(.*)$"))
    if m != none { defs.push((key: m.captures.at(0), text: m.captures.at(1))) }
  }
  defs
}

/// cmarker numbers footnotes per render call, so a paragraph is rendered together with the definitions it cites.
#let with-defs(t, defs) = {
  let extra = defs.filter(d => t.contains("[^" + d.key + "]")).map(d => "[^" + d.key + "]: " + d.text)
  t + if extra.len() > 0 { "\n\n" + extra.join("\n\n") } else { "" }
}

#let memorandum-body(body) = {
  let defs = footnote-defs(body)
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let live = chunks.filter(c => not c.trim().starts-with("[^"))
  let pending = []
  let has-pending = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with("[^") { continue }
    let piece = none
    if t.starts-with("#") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
      continue
    } else if t.starts-with(">") {
      piece = block(width: text-width, above: pitch-gap * 0.5, below: pitch-gap * 0.5,
        inset: (left: quote-inset, right: quote-inset), {
        set par(leading: single-leading, spacing: 0pt)
        cmarker.render(with-defs(t, defs), raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
    } else if t.starts-with(regex("^\\([a-z]+\\)[ \\t]")) {
      piece = block(width: text-width, inset: (left: 0.5in), below: body-leading, {
        set par(leading: body-leading, spacing: 0pt)
        cmarker.render(with-defs(t, defs), raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
    } else {
      // The last paragraph of the memorandum sticks to the signature block, so a signature never stands alone.
      piece = block(width: text-width, above: 0pt, below: body-leading, sticky: c == live.last(), {
        set par(leading: body-leading, spacing: 0pt)
        h(para-indent)
        cmarker.render(with-defs(t, defs), raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
    }
    if has-pending {
      block(width: text-width, below: body-leading, sticky: c == live.last(), { pending; piece })
    } else {
      piece
    }
    pending = []
    has-pending = false
  }
  if pending != [] { block(breakable: false, width: text-width, pending) }
}

// ---------------------------------------------------------------------------
// Signature, certificate of conferral (L.R. 9013-1(a)) and certificate of service
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(width: text-width, breakable: false, above: pitch-gap, pad(left: 3in, {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  [Respectfully submitted,]
  v(pitch-gap * 0.5)
  line-stack(meta.signature.firm)
  v(pitch-gap * 0.5)
  line-stack(("By: /s/ " + meta.signature.signer,) + meta.signature.lines)
}))

#let conferral-block(meta) = if "conferral" in meta and meta.conferral != none {
  block(width: text-width, breakable: false, above: pitch-gap, {
    align(center, text(weight: "bold", "CERTIFICATE OF CONFERRAL"))
    v(body-leading)
    set par(leading: body-leading, spacing: 0pt)
    h(para-indent)
    inl(meta.conferral)
  })
}

#let certificate-block(meta) = if "certificate" in meta and meta.certificate != none {
  let c = meta.certificate
  block(width: text-width, breakable: false, above: pitch-gap, {
    align(center, text(weight: "bold", "CERTIFICATE OF SERVICE"))
    v(body-leading)
    set par(leading: single-leading, spacing: 0pt)
    h(para-indent)
    [I HEREBY CERTIFY that a true and correct copy of the foregoing was served electronically via CM/ECF, Email, and/or via U.S. Mail, as indicated on the attached service list on this #c.date.]
    v(pitch-gap * 0.5)
    pad(left: 3in, line-stack(("By: /s/ " + c.signer, c.signer)))
    v(pitch-gap)
    align(center, text(weight: "bold", "SERVICE LIST"))
    v(pitch-gap * 0.5)
    line-stack(c.service_list)
  })
}

#let flsb-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    numbering: "1",
    number-align: center,
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  set footnote.entry(separator: line(length: 1.5in, stroke: 0.5pt))
  show footnote.entry: set text(size: footnote-size)

  // Headings: level 1 is a centered bold section; level 2 a bold sub-heading; level 3 bold italic.
  show heading.where(level: 1): it => heading-block(align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => heading-block(text(weight: "bold", it.body))
  show heading.where(level: 3): it => heading-block(text(weight: "bold", style: "italic", it.body))

  cover(meta)
  memorandum-body(body)
  signature-block(meta)
  conferral-block(meta)
  certificate-block(meta)
}
