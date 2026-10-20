// Adversary complaint for the United States Bankruptcy Court, District of Nevada (nvb).
// Rules (quoted in ../README.md): LR 9004(a)-(c) and (g) (form: 8 1/2 by 11, double-spaced, every line
// numbered, 12 point or larger, consecutive page numbers, title page 1 1/2 inches from the top, attorney
// identification, "/s/" signatures); LR 7010(b) (caption includes the adversary proceeding); FRBP 7008(a)
// and LR 7008 (jurisdiction and consent statements); FRBP 7010 (form per Fed. R. Civ. P. 10: numbered
// paragraphs, separate claims). Content-agnostic: every case word comes from the sample's frontmatter.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")          // LR 9004(b): proportional font; vendored in fonts/
#let type-size = 13pt                     // LR 9004(b): at least 12 point. 13 pt is a style choice (EB Garamond sets smaller than Times at 12); see ../README.md.
#let pitch = 24pt                         // LR 9004(a): double-spaced; the numbered lines are this pitch
#let lines-per-page = 28                  // LR 9004(a): each printed line numbered in the left margin, 28 to a page
#let page-w = 8.5in                       // LR 9004(a): 8 1/2 by 11 inch paper
#let page-h = 11in
#let top-margin = 72pt                    // line 1 sits on the top margin
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 48 pt: holds the page number
#let left-margin = 1.5in                  // room for the line numbers
#let right-margin = 0.75in
#let text-width = page-w - left-margin - right-margin
#let title-page-lines = 2                 // LR 9004(a): the title page begins 1 1/2 in from the top; line 3 is 1 in + 48 pt = 1.67 in
#let body-leading = 15.55pt               // the gap that makes a line of 13 pt EB Garamond (line box 0.65em) a 24 pt pitch; measured in ../README.md
#let single-leading = 6.5pt                // counsel block, caption, signature block, quotations: single-spaced (LR 9004(a) exempts the caption and attorney identification)
#let para-indent = 0.5in                  // first-line indent of numbered paragraphs
#let caption-left = 3.2in                 // width of the party column of the caption
#let label-width = 0.5in                  // hanging width for list labels (a., (b) ...)
#let footer-size = 12pt                   // LR 9004(b): page numbers, printed consecutively

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nvb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, case names, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// A required frontmatter field: a missing one stops the build with its name.
#let need(meta, key) = {
  if key not in meta { panic("nvb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Fill whole numbered lines: a single-spaced block is rounded up to a multiple of `pitch`, so whatever
/// follows it stays on the grid of numbered lines.
#let on-grid(c, width: text-width) = context {
  let h = measure(width: width, c).height
  block(width: width, height: calc.ceil(h / pitch) * pitch, above: 0pt, below: 0pt, c)
}

/// One single-spaced line per item (counsel block, caption, signature block).
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => if i == "" { block(height: single-leading) } else { inl(i) }))
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Numbers 1 to 28 down the left margin, one per numbered line (LR 9004(a)).
#let line-numbers() = {
  for i in range(1, lines-per-page + 1) {
    place(top + left, dx: 0pt, dy: top-margin + (i - 1) * pitch,
      block(width: left-margin - 0.5in, height: pitch,
        align(right, text(size: 12pt, str(i)))))
  }
}

/// A single rule at the left edge of the text (pleading form).
#let pleading-rule() = place(top + left, dx: left-margin - 0.2in,
  line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))

/// Consecutive page numbers, centered below the 28th line (LR 9004(b)).
#let page-number() = place(top + left, dx: left-margin,
  dy: top-margin + lines-per-page * pitch + 8pt,
  block(width: text-width, align(center, text(size: footer-size, context counter(page).display()))))

// ---------------------------------------------------------------------------
// Cover: attorney identification, court title, caption
// ---------------------------------------------------------------------------

/// The attorney identification: one column per counsel group (LR 9004(g)). Single-spaced.
#let counsel-block(meta) = {
  let groups = need(meta, "counsel")
  let n = groups.len()
  on-grid(grid(
    columns: (1fr,) * n,
    column-gutter: 0.25in,
    ..groups.map(g => line-stack(need(g, "lines"))),
  ))
}

/// Court title (LR 9004(g)): the title is the same on every case caption of this court.
#let court-title() = {
  on-grid(align(center, text(weight: "bold", "UNITED STATES BANKRUPTCY COURT")))
  on-grid(align(center, text(weight: "bold", "DISTRICT OF NEVADA")))
}

/// The caption (LR 7010(b)): the debtor and the adversary parties on the left, the case number,
/// adversary number and title of the paper on the right.
#let caption(meta) = {
  let debtor = need(meta, "debtor")
  let left-rows = ()
  if "heading" in debtor { left-rows.push(debtor.heading) }
  left-rows += debtor.names
  left-rows.push(debtor.designation)
  if "caption_parties" in meta {
    left-rows.push("")
    for (k, p) in meta.caption_parties.enumerate() {
      if k > 0 { left-rows.push("v.") }
      left-rows += p.names + (p.designation,)
    }
  }
  on-grid(grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.2in,
    block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), line-stack(left-rows)),
    block(inset: (left: 0.1in), {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      line-stack(("Case No.: " + need(meta, "case_number"),) + if "chapter" in meta { (meta.chapter,) } else { () })
      v(pitch * 0.5)
      line-stack(("Adversary No.: " + if "adversary_number" in meta { meta.adversary_number } else { "" },))
      v(pitch * 0.5)
      text(weight: "bold", inl(need(meta, "title")))
      if "subtitle" in meta {
        linebreak()
        text(weight: "bold", inl(meta.subtitle))
      }
      if "jury_demand" in meta and meta.jury_demand {
        v(pitch * 0.5)
        text(weight: "bold", "DEMAND FOR JURY TRIAL")
      }
    }),
  ))
}

#let cover(meta) = {
  v(title-page-lines * pitch)
  counsel-block(meta)
  v(pitch)
  court-title()
  v(pitch)
  caption(meta)
}

// ---------------------------------------------------------------------------
// Body items: each item is a block that ends with one leading of space, so every item occupies a
// whole number of numbered lines and the next item starts on the grid. Items may break across pages.
// ---------------------------------------------------------------------------

#let body-item(c) = block(width: text-width, above: 0pt, below: 0pt, {
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)
  c
  v(body-leading)
})

/// A heading: one or more double-spaced lines, kept with the item after it (LR 9004(a) does not
/// exempt headings). Level 1 is a centered section (bold capitals); level 2 a centered bold sub-heading.
#let heading-item(level, text-md) = {
  let lab = text-md.match(regex("^([A-Z0-9]+\\.)\\s+(.*)$"))
  let label = if lab == none { none } else { lab.captures.at(0) }
  let words = if lab == none { text-md } else { lab.captures.at(1) }
  block(width: text-width, above: 0pt, below: 0pt, sticky: true, {
    set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)
    if level == 1 {
      align(center, text(weight: "bold", inl(upper(words))))
    } else if level == 2 {
      align(center, text(weight: "bold", inl(words)))
    } else {
      text(weight: "bold", inl(words))
    }
    v(body-leading)
  })
}

/// A block quotation: indented on both sides, single-spaced (LR 9004(a) exempts quotations).
#let quote-item(t) = {
  let text-md = t.split("\n").map(l => l.trim().trim(">").trim()).filter(l => l != "").join("\n\n")
  on-grid(width: text-width - 1in, pad(left: 0.5in, right: 0.5in, {
    set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt, justify: false)
    inl(text-md)
    v(single-leading)
  }))
}

/// Numbered paragraphs (Fed. R. Civ. P. 10(b)): the number is the template's, not the author's.
#let para-counter = counter("nvb-complaint-para")

#let numbered-item(t) = body-item({
  para-counter.step()
  h(para-indent)
  context [#para-counter.display().#h(0.3in)]
  inl(t)
})

/// An unnumbered paragraph (the lead-in, the prayer's introductory sentence): marked `[unnumbered]`.
#let plain-item(t) = body-item({
  h(para-indent)
  inl(t)
})

/// A markdown list: `1.` items are lettered (a., b., ...) as in the exemplars; `-` items have no marker
/// (the exemplar's indented lines under a paragraph). A list line that does not begin with a marker is
/// a continuation this template does not support, so it stops the build rather than being dropped.
#let list-items(t) = {
  let letters = "abcdefghijklmnopqrstuvwxyz"
  let idx = 0
  for line in t.split("\n") {
    let l = line.trim()
    if l == "" { continue }
    let num = l.match(regex("^(\\d+)\\.[ \\t]+(.*)$"))
    let bul = l.match(regex("^[-*+][ \\t]+(.*)$"))
    if num != none {
      let lab = letters.at(idx) + "."
      idx += 1
      body-item(grid(columns: (label-width, 1fr), [#lab], inl(num.captures.at(1))))
    } else if bul != none {
      body-item(pad(left: label-width, inl(bul.captures.at(0))))
    } else {
      panic("nvb-adversary-complaint: list continuation lines are not supported: " + l)
    }
  }
}

/// The whole body, chunk by chunk (blank-line separated). A chunk is a heading (one per line), a
/// quotation, a list, an unnumbered paragraph, or a numbered paragraph.
/// Chunks are rendered one at a time: a show rule that re-wraps paragraph content recurses without end
/// in typst 0.15, so the numbering is applied per chunk instead.
#let body-flow(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      for line in t.split("\n") {
        let l = line.trim()
        if l == "" { continue }
        if not l.starts-with("#") {
          panic("nvb-adversary-complaint: text directly under a heading is not supported: " + l)
        }
        let m = l.match(regex("^(#+)\\s+(.*)$"))
        heading-item(m.captures.at(0).len(), m.captures.at(1))
      }
    } else if t.starts-with(">") {
      quote-item(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      list-items(t)
    } else if t.starts-with("[unnumbered]") {
      plain-item(t.slice("[unnumbered]".len()).trim())
    } else {
      numbered-item(t)
    }
  }
}

// ---------------------------------------------------------------------------
// Signature (LR 9004(c)): the signer's name typed under "/s/ Name" in the signature space.
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let blocks = need(meta, "signature")
  let right = ()
  for s in blocks {
    right.push(line-stack(
      (if "firm" in s { (s.firm,) } else { () }) + ("", "/s/ " + need(s, "signer"), need(s, "signer")) + need(s, "lines"),
    ))
  }
  on-grid(grid(
    columns: (2.6in, 1fr),
    column-gutter: 0.2in,
    [Dated: #need(meta, "date")],
    stack(dir: ttb, spacing: pitch * 0.5, ..right),
  ))
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let nvb-adversary-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rule()
    },
    foreground: page-number(),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)

  cover(meta)
  v(pitch)
  if "lead_in" in meta { plain-item(meta.lead_in) }
  body-flow(body)
  v(pitch)
  signature-block(meta)
}
