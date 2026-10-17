// Complaint for the United States District Court for the Western District of Tennessee (tnwd).
// Rules: W.D. Tenn. LR 7.1(a)-(d) (paper, margins, double spacing, 12 point type, the JURY DEMAND legend),
// LR 3.1 (civil cover sheet: a separate filing, not generated); LR 11.1(b) (signature block);
// Fed. R. Civ. P. 7(a), 8(a), 10(a)-(c) (caption, numbered paragraphs). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or to the word-processor double spacing; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")  // vendored (fonts/liberation-serif); the W.D. Tenn. e-filing manual allows Times New Roman (README.md, typeface row)
#let type-size = 12pt                  // LR 7.1(b): no smaller than 12 point, footnotes included
#let page-w = 8.5in                    // LR 7.1(a): 8 1/2 by 11 inch white paper
#let page-h = 11in
#let margin = 1in                      // LR 7.1(a): one-inch margins on all sides
#let text-width = page-w - 2 * margin
#let line-box = 7.86pt                 // Liberation Serif natural line box at 12 pt (leading 0, measured with typst 0.15.0)
#let pitch = 27.6pt                    // LR 7.1(b): double-spaced; 2 x 1.15 x 12 pt, the word-processor double
#let single-pitch = 13.8pt             // single spacing: caption, quotations, signature, footnotes
#let body-leading = pitch - line-box   // the gap between lines of a double-spaced paragraph
#let single-leading = single-pitch - line-box
#let para-indent = 0.5in               // first-line indent of numbered paragraphs
#let number-gap = 0.5in                // from the paragraph number to its text
#let caption-party-width = 3.3in       // the party column; the ")" column follows it
#let caption-gap = 0.4in

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("tnwd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, italic case names, footnote marks).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Blank-line-separated chunks of the body. A footnote definition joins the chunk that cites it.
#let chunks-of(body) = {
  let out = ()
  for t in body.replace("\r\n", "\n").split("\n\n") {
    let s = t.trim()
    if s == "" { continue }
    if s.starts-with("[^") and out.len() > 0 {
      out.at(-1) = out.at(-1) + "\n\n" + s
    } else {
      out.push(s)
    }
  }
  out
}

// ---------------------------------------------------------------------------
// Body blocks
// ---------------------------------------------------------------------------

/// A heading: centered bold capitals for level 1; bold at the left for level 2; bold italic for level 3.
/// It never ends a page (sticky), and it is set single-spaced with a blank double-spaced line above.
#let heading-block(level, s) = block(width: text-width, sticky: true, above: pitch, below: body-leading, {
  set par(leading: single-leading)
  if level == 1 {
    align(center, strong(inl(s)))
  } else if level == 2 {
    strong(inl(s))
  } else {
    strong(emph(inl(s)))
  }
})

/// A body paragraph before the first heading: the lead-in, not numbered.
#let lead-para(t) = block(width: text-width, below: body-leading, [#h(para-indent)#inl(t)])

/// A numbered allegation (FRCP 10(b): numbered paragraphs). The number is counted by the template.
#let numbered-para(t) = {
  counter("para").step()
  block(width: text-width, below: body-leading, context [
    #h(para-indent)#counter("para").display()\.#h(number-gap - 0.2em)#inl(t)
  ])
}

/// A block quotation: single-spaced, indented on both sides.
#let quote-block(t) = pad(left: 0.5in, right: 0.5in, block(width: text-width - 1in, below: body-leading, {
  set par(leading: single-leading)
  inl(t.split("\n").map(l => l.trim().replace(regex("^>\\s?"), "")).join("\n"))
}))

/// A lettered list (the prayer for relief): (a), (b), ... hung from a half-inch indent.
#let list-block(t) = {
  let items = t.split("\n").map(l => l.trim()).filter(l => l != "")
  for (i, it) in items.enumerate() {
    let m = it.match(regex("^\\d+\\.\\s+(.*)$"))
    assert(m != none, message: "tnwd-complaint: a list item must start with a number and a period")
    let letter = "abcdefghijklmnopqrstuvwxyz".at(i)
    block(width: text-width, below: body-leading, pad(left: 0.5in, grid(
      columns: (0.5in, 1fr),
      [(#letter)],
      inl(m.captures.at(0)),
    )))
  }
}

/// Body content: the chunks in order. Paragraphs before the first heading are the lead-in (unnumbered), and so is
/// any paragraph that starts with "[unnumbered] " (the WHEREFORE paragraph, the jury demand sentence).
#let body-content(chunks) = {
  let first = chunks.position(t => t.starts-with("#"))
  for (i, t) in chunks.enumerate() {
    if t.starts-with("#") {
      let level = t.match(regex("^#+")).text.len()
      heading-block(level, t.slice(level).trim())
    } else if t.starts-with(">") {
      quote-block(t)
    } else if t.match(regex("^\\d+\\.\\s")) != none {
      list-block(t)
    } else if t.starts-with("[unnumbered]") {
      lead-para(t.slice(12).trim())
    } else if first != none and i > first {
      numbered-para(t)
    } else {
      lead-para(t)
    }
  }
}

// ---------------------------------------------------------------------------
// Caption, title, signature, verification
// ---------------------------------------------------------------------------

/// The court title, single-spaced, centered (the first page of a W.D. Tenn. filing).
#let court-title(division) = block(width: text-width, breakable: false, {
  set par(leading: single-leading)
  align(center, [
    IN THE UNITED STATES DISTRICT COURT \
    FOR THE WESTERN DISTRICT OF TENNESSEE
    #if division != none and division != "" [\ #division]
  ])
})

/// The left side of the caption: each side's names, then its designation, with "v." between the sides.
#let caption-parties(sides) = block(width: caption-party-width, {
  set par(leading: single-leading, spacing: single-leading)
  for (i, side) in sides.enumerate() {
    if i > 0 {
      v(single-pitch)
      [v.]
      v(single-pitch)
    }
    for name in side.names {
      block(width: caption-party-width, inl(name))
    }
    pad(left: 1.25in, inl(side.designation))
  }
})

/// The caption: parties, a column of ")" marks as tall as the parties, then the case number and the
/// JURY DEMAND legend opposite the style of the case on the first page (LR 7.1(c)).
#let caption(sides, case-number, jury) = context {
  let left = caption-parties(sides)
  let rows = int(calc.round((measure(left).height + single-leading) / single-pitch))
  let right = block(width: 100%, {
    set par(leading: single-leading)
    v(single-pitch * 2)
    if case-number != "" [Case No. #case-number] else [Case No. #box(width: 1.6in, line(length: 100%, stroke: 0.5pt))]
    if jury {
      v(single-pitch * 2)
      [JURY DEMAND]
    }
  })
  grid(
    columns: (caption-party-width, caption-gap, 1fr),
    align: top,
    left,
    stack(dir: ttb, spacing: 0pt, ..range(rows).map(_ => block(height: single-pitch, [)]))),
    right,
  )
}

/// The signature block (LR 11.1(b)): "s/" then the filing user's name, the attorney's bar number, the firm,
/// street address, city, state and ZIP, telephone and primary e-mail. Set in the right half of the page.
#let signature-block(sig, date) = block(width: text-width, breakable: false, above: pitch, {
  set par(leading: single-leading)
  if date != none and date != "" [Dated: #date]
  v(pitch)
  pad(left: 3.25in, {
    [Respectfully submitted,]
    v(pitch)
    if sig.at("firm", default: none) != none [#sig.firm]
    v(single-pitch)
    [s/ #sig.signer \ ]
    [
      Attorney Bar No. #sig.bar_number \
      #for l in sig.lines [#l \ ]
    ]
  })
})

/// A verification (28 U.S.C. § 1746), one per verifying party: unnumbered, with a signature line.
#let verifications-block(list) = {
  for ver in list {
    block(width: text-width, breakable: false, above: pitch, {
      set par(leading: single-leading)
      align(center, strong[VERIFICATION])
      v(pitch)
      block(width: text-width, below: body-leading, [#h(para-indent)I, #ver.name, declare under penalty of perjury that the foregoing is true and correct.])
      v(pitch)
      pad(left: 3.25in, [
        #line(length: 2.75in, stroke: 0.5pt) \
        #ver.name \
        #if ver.at("executed", default: none) != none [Executed on: #ver.executed]
      ])
    })
  }
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let tnwd-complaint(meta, body) = {
  set document(title: meta.at("title", default: "Complaint"))
  set page(width: page-w, height: page-h, margin: margin, numbering: "1", number-align: center)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, justify: false)
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading)
    it
  }

  court-title(meta.at("court_division", default: none))
  v(pitch)
  caption(meta.caption, meta.at("case_number", default: ""), meta.at("jury_demand", default: false))
  v(pitch)
  align(center, strong(meta.title))
  v(pitch)
  body-content(chunks-of(body))
  signature-block(meta.signature, meta.at("date", default: none))
  if "verifications" in meta { verifications-block(meta.verifications) }
}
