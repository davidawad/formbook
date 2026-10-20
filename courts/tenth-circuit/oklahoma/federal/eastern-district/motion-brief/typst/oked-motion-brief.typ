// Motion with brief for the U.S. District Court for the Eastern District of Oklahoma (oked).
// Rules: LCvR 7.1(b) (a brief may be combined with the motion if the title says so), LCvR 7.1(c)
// (briefs over 15 pages need an indexed table of contents and table of authorities, and the form of
// LCvR 5.2(a)), LCvR 5.2(a) (paper, 12-point print style including footnotes, 1-inch margins, line
// spacing of at least 1.5 except blocked quotations and footnotes). Fed. R. Civ. P. 7(b) and 10(a).
// See ../README.md for each choice and its source.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // LCvR 5.2(a) names no typeface; Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                   // LCvR 5.2(a): print style, footnotes included, not smaller than 12 point
#let page-margin = 1in                  // LCvR 5.2(a): margins at least 1 inch on the top, bottom and sides
#let line-pitch = 24pt                  // double spacing: LCvR 5.2(a) requires at least 1.5; the exemplar is double
#let body-leading = 1.345em             // Liberation Serif line box is 0.655em, so 1.345em leading is a 24 pt pitch at 12 pt
#let single-leading = 0.495em            // caption, headings' second lines, signature block, footnotes (README, gap 1)
#let single-pitch = 13.8pt              // one single-spaced caption row (fixed so the box and the right column line up)
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let number-width = 0.5in               // a numbered paragraph's number sits in the first half inch
#let caption-box-width = 3.5in          // the party box, as in the exemplar caption
#let heading-tab = 0.5in                // label column of level 2 and 3 headings

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("oked-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in italics, footnote references).
// A paragraph sign keeps its number: a non-breaking space follows it, so "¶ 6" cannot break across lines.
#let inl(s) = cmarker.render(s.replace("¶ ", "¶\u{a0}"), raw-typst: false, smart-punctuation: true)

/// Single-spaced text: caption, signature block, footnotes, block quotations.
#let single(c) = block(width: 100%, above: 0pt, below: 0pt, {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  c
})

// ---------------------------------------------------------------------------
// Cover: court name, boxed caption with the case number and judge, title (LCvR 7.1(b))
// ---------------------------------------------------------------------------

#let court-title(meta) = single(align(center, strong(upper(stack(dir: ttb, spacing: single-leading, ..meta.court)))))

/// The party box: each party's names one line at a time, the designation indented, "v." between the sides.
#let caption-box(meta) = {
  let items = ()
  for (i, p) in meta.caption.plaintiffs.enumerate() {
    for l in p.names { items.push(block(height: single-pitch, inl(l))) }
    if "designation" in p { items.push(block(height: single-pitch, pad(left: 1.9in, emph(inl(p.designation))))) }
  }
  items.push(block(height: single-pitch, []))
  items.push(block(height: single-pitch, pad(left: 1.1in, [v.])))
  items.push(block(height: single-pitch, []))
  for p in meta.caption.defendants {
    for l in p.names { items.push(block(height: single-pitch, inl(l))) }
    if "designation" in p { items.push(block(height: single-pitch, pad(left: 1.9in, emph(inl(p.designation))))) }
  }
  block(width: caption-box-width, stroke: 0.75pt, inset: (x: 0.1in, y: 0.12in), {
    set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
    stack(dir: ttb, spacing: 0pt, ..items)
  })
}

#let cover(meta) = {
  court-title(meta)
  v(line-pitch)
  single(grid(
    columns: (caption-box-width, 0.3in, 1fr),
    caption-box(meta),
    [],
    block(width: 100%, {
      // The case number and the judge sit at the top of the right column, as in the exemplar.
      v(single-pitch * 2)
      block(height: single-pitch, [Case No. #meta.case_number])
      if "judge" in meta { block(height: single-pitch, inl(meta.judge)) }
    }),
  ))
  v(line-pitch)
  block(width: 100%, above: 0pt, below: 0pt, align(center, strong(upper(meta.brief_title))))
  v(line-pitch * 0.5)
}

// ---------------------------------------------------------------------------
// Headings and body
// ---------------------------------------------------------------------------

/// Level 1: centered bold capitals. Level 2: "I." with a hanging label. Level 3: "A." in the same way.
/// Level 2 and 3 labels are counted here, not in the text, so the sample types no numbers.
#let heading-block(level, label, text) = block(width: 100%, above: line-pitch * 0.5, below: body-leading, sticky: true, {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  if level == 1 {
    align(center, strong(upper(text)))
  } else if level == 2 {
    grid(columns: (heading-tab, 1fr), label, strong(text))
  } else {
    grid(columns: (heading-tab * 2, 1fr), pad(left: heading-tab, label), strong(text))
  }
})

/// Markdown body, chunk by chunk (blank-line separated). A chunk is a heading (`#`, `##`, `###`), a
/// block quotation (`>`), a numbered paragraph (marked `<!--numbered-->`, as the facts are in the exemplar),
/// or a paragraph. Argument paragraphs are not numbered (the exemplar does not number them).
#let body(md) = {
  let chunks = md.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // Footnote definitions (`[^label]: text`) must be in the same render call as their references, so each
  // paragraph that has a reference is rendered with all the definitions appended (they are not printed twice).
  let defs = chunks.filter(c => c.trim().starts-with("[^")).join("\n\n")
  let n = 0
  let h2 = 0
  let h3 = 0
  let out = []
  for c in chunks {
    let t = c.trim()
    if t.starts-with("[^") { continue }
    if t.starts-with("#") {
      let m = t.match(regex("^(#+) +([\\s\\S]*)$"))
      if m == none { panic("oked-motion-brief: a heading needs text: " + t) }
      let level = m.captures.at(0).len()
      let text = m.captures.at(1).trim()
      if level == 2 {
        h2 += 1
        h3 = 0
        out += heading-block(2, numbering("I.", h2), text)
      } else if level == 3 {
        h3 += 1
        out += heading-block(3, numbering("A.", h3), text)
      } else {
        out += heading-block(1, "", text)
      }
    } else if t.starts-with(">") {
      let lines = t.split("\n").map(l => {
        let s = l.trim(at: start)
        if s.starts-with(">") { s.slice(1).trim(at: start) } else { s }
      })
      out += block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, breakable: false, {
        pad(left: 1in, right: 0.5in, single(inl(lines.join("\n"))))
      })
    } else {
      let numbered = t.starts-with("<!--numbered-->")
      let text = if numbered { t.slice("<!--numbered-->".len()).trim(at: start) } else { t }
      let label = if numbered {
        n += 1
        [#n.]
      } else { [] }
      out += block(width: 100%, above: 0pt, below: body-leading, {
        set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
        h(para-indent)
        if numbered { box(width: number-width)[#label] }
        if text.contains("[^") { cmarker.render(text + "\n\n" + defs, raw-typst: false, smart-punctuation: true) } else { inl(text) }
      })
    }
  }
  out
}

// ---------------------------------------------------------------------------
// Signature block: the date on the left, the signature on the right (exemplar layout)
// ---------------------------------------------------------------------------

#let signature-block(sig, date: none, attorneys: none) = block(breakable: false, above: line-pitch, {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  grid(columns: (3in, 1fr), if date != none { [Date: #date] } else { [] }, {
    [Respectfully submitted,]
    v(line-pitch * 0.5)
    [/s/ #sig.signer]
    linebreak()
    for l in sig.lines { inl(l); linebreak() }
    if attorneys != none {
      v(line-pitch * 0.5)
      attorneys
    }
  })
})

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

#let oked-motion-brief(meta, md) = {
  for k in ("court", "case_number", "caption", "brief_title", "signature") {
    if k not in meta { panic("oked-motion-brief: missing required metadata field `" + k + "`") }
  }

  set page(
    paper: "us-letter",
    margin: page-margin,
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set document(title: meta.brief_title + ", No. " + meta.case_number, author: meta.signature.signer)
  set text(font: font-family, size: type-size, lang: "en", region: "us", hyphenate: false, fallback: false)
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em)

  cover(meta)

  // The body up to the certificate of service, then the signature, then the certificate on its own page.
  let parts = md.split(regex("\\r?\\n# CERTIFICATE OF SERVICE[ \\t]*\\r?\\n"))
  // The last paragraph (with its heading, if it has one) is kept on the page with the signature block.
  let all = parts.at(0).split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let defs = all.filter(c => c.trim().starts-with("[^"))
  let text = all.filter(c => not c.trim().starts-with("[^"))
  let k = if text.len() >= 2 and text.at(text.len() - 2).trim().starts-with("#") { 2 } else { 1 }
  let head = text.slice(0, text.len() - k) + defs
  let tail = text.slice(text.len() - k) + defs
  body(head.join("\n\n"))
  block(breakable: false, {
    body(tail.join("\n\n"))
    signature-block(meta.signature, date: meta.at("date", default: none), attorneys: meta.at("attorneys_for", default: none))
  })

  if parts.len() > 1 {
    pagebreak()
    block(width: 100%, above: 0pt, below: line-pitch * 0.5, align(center, strong(upper("Certificate of Service"))))
    body(parts.at(1))
    if "certificate" in meta {
      signature-block(meta.certificate, attorneys: meta.certificate.at("attorneys_for", default: none))
    }
  }
}
