// Complaint for the U.S. District Court for the Southern District of Iowa (iasd).
// Rules: Local Rules of the Northern and Southern Districts of Iowa, effective Dec. 7, 2020: LR 10(a) 8 1/2 x 11 paper;
// LR 10(b)(1)-(3) double spaced, one side, top margin of at least 1 inch; LR 10(b) documents of more than one page
// numbered at the bottom; LR 10(d) caption with district, division, case number, party names (Fed. R. Civ. P. 10(a)),
// a designation of the content and the filing party; LR 11 signature block (name, firm, address, telephone, email).
// Fed. R. Civ. P. 10(b) (numbered paragraphs), 38(b) (jury demand). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // no typeface rule in the S.D. Iowa Local Rules; tier 2. EB Garamond is the only serif in fonts/ (the exemplar is Times New Roman)
#let type-size = 12pt                   // no size rule in the Local Rules; tier 2: 12 point, as in the exemplar
#let pitch = 24pt                       // LR 10(b)(1): double spaced; 24 pt baseline pitch at 12 pt
#let page-w = 8.5in                     // LR 10(a): 8 1/2 by 11 inch paper
#let page-h = 11in
#let margin-top = 1in                   // LR 10(b)(3): top margin of at least 1 inch
#let margin-bottom = 1in                // tier 2: not stated by the Local Rules
#let margin-left = 1in                  // tier 2
#let margin-right = 1in                 // tier 2
#let text-width = page-w - margin-left - margin-right
#let body-leading = 1.35em              // double spacing: EB Garamond's line box is 0.65em, so 1.35em leading is a 24 pt baseline pitch at 12 pt (README.md, measured)
#let single-leading = 0.5em             // about 13.8 pt pitch: caption, block quotations, signature block
#let para-indent = 0.5in                // first-line indent of numbered paragraphs (tier 2)
#let caption-left = 3.25in              // width of the party column of the caption (tier 2)
#let letters = ("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t")
// Headings after which paragraphs are not numbered (the relief and the jury demand are not allegations).
#let unnumbered-after = ("REQUESTED RELIEF", "JURY DEMAND")

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("iasd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A required frontmatter field: a missing one fails the build, it is never silently left out.
#let need(meta, k) = {
  if k not in meta { panic("iasd-complaint: frontmatter field `" + k + "` is required") }
  meta.at(k)
}

/// Inline markdown (for names with *et al.*, section signs, and so on). A section or paragraph sign is
/// kept on the line of its number (no-break space).
#let inl(s) = cmarker.render(
  s.replace("§ ", "§\u{a0}").replace("¶ ", "¶\u{a0}"),
  raw-typst: false, smart-punctuation: true,
)

/// Single-spaced lines: one block per item, stacked at the single-spacing pitch.
#let lines-block(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false, first-line-indent: 0pt)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (LR 10(d))
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  let lines = (
    "IN THE UNITED STATES DISTRICT COURT",
    "FOR THE SOUTHERN DISTRICT OF IOWA",
    upper(need(meta, "division")),
  )
  align(center, lines-block(lines.map(l => "**" + l + "**")))
}

#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.2in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 10pt), {
    // Each party: its names, then its designation; the versus line between the parties.
    let rows = ()
    for (k, p) in need(meta, "caption").parties.enumerate() {
      if k > 0 { rows += (need(meta, "caption").at("versus", default: "v."),) }
      rows += p.names + (p.designation,)
    }
    lines-block(rows)
  }),
  block(inset: (left: 0.1in), {
    lines-block(("Case No. " + need(meta, "case_number"),))
    v(pitch * 0.5)
    text(weight: "bold", upper(need(meta, "title")))
  }),
)

// ---------------------------------------------------------------------------
// Body: headings, numbered paragraphs, lettered lists, block quotations
// ---------------------------------------------------------------------------

/// Blank-line-separated chunks of the markdown body, in order.
#let chunks-of(body) = body.split("\n\n").map(s => s.trim()).filter(s => s != "")

/// A heading: centered bold capitals (level 1), centered bold (level 2), bold at the margin (level 3).
/// Sticky, so a heading never ends a page.
#let heading-block(level, t) = {
  let c = if level == 1 {
    align(center, strong(upper(inl(t))))
  } else if level == 2 {
    align(center, strong(inl(t)))
  } else {
    strong(inl(t))
  }
  block(width: 100%, above: pitch * 0.5, below: pitch * 0.5, sticky: true, c)
}

#let body-blocks(body) = {
  let out = ()
  let n = 0                             // paragraph number (LR 10(b): numbered paragraphs)
  let numbered = true
  for chunk in chunks-of(body) {
    if chunk.starts-with("###") {
      out.push(heading-block(3, chunk.slice(3).trim()))
    } else if chunk.starts-with("##") {
      out.push(heading-block(2, chunk.slice(2).trim()))
    } else if chunk.starts-with("#") {
      let t = chunk.slice(1).trim()
      if upper(t) in unnumbered-after { numbered = false }
      out.push(heading-block(1, t))
    } else if chunk.starts-with(">") {
      // A block quotation: single spaced, indented on both sides.
      let t = chunk.split("\n").map(l => l.replace(regex("^>\\s?"), "")).join("\n")
      out.push(pad(left: 0.5in, right: 0.5in, block(width: 100%, above: 0pt, below: pitch * 0.5, {
        set par(leading: single-leading, first-line-indent: 0pt)
        inl(t)
      })))
    } else if chunk.starts-with("1. ") {
      // A list: lettered (a), (b), ... by the template; each item is one markdown line.
      for (i, l) in chunk.split("\n").filter(l => l.trim() != "").enumerate() {
        let t = l.replace(regex("^\\s*\\d+\\.\\s+"), "")
        out.push(block(width: 100%, above: 0pt, below: 0pt, [#h(para-indent) (#letters.at(i))#h(0.25in)#inl(t)]))
      }
    } else if numbered {
      n += 1
      out.push(block(width: 100%, above: 0pt, below: 0pt, [#h(para-indent) #n. #h(0.25in) #inl(chunk)]))
    } else {
      out.push(block(width: 100%, above: 0pt, below: 0pt, [#h(para-indent) #inl(chunk)]))
    }
  }
  out
}

// ---------------------------------------------------------------------------
// Signature block (LR 11): name, firm, address, telephone, email, under the signature
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, above: pitch, sticky: true, {
    if "date" in sig { lines-block((sig.date,)) }
    v(pitch * 0.5)
    pad(left: caption-left + 0.2in, lines-block(sig.lines))
  })
  if "filing_note" in meta {
    v(pitch)
    lines-block((meta.filing_note,))
  }
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let iasd-complaint(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("division", "caption", "case_number", "title", "signature") {
    let _ = need(meta, k)
  }

  // ---- document-wide settings ----
  set page(
    paper: "us-letter",
    margin: (top: margin-top, bottom: margin-bottom, left: margin-left, right: margin-right),
    numbering: "1",
    number-align: center + bottom,
  )
  set document(title: need(meta, "title") + ", No. " + need(meta, "case_number"))
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: "ascender", bottom-edge: "descender",
  )
  set par(
    leading: body-leading, spacing: 0pt,
    first-line-indent: 0pt, justify: false,
  )

  court-title(meta)
  v(pitch)
  caption(meta)
  v(pitch)

  if "lead_in" in meta and meta.lead_in != none {
    block(width: 100%, above: 0pt, below: 0pt, [#h(para-indent) #inl(meta.lead_in)])
  }
  for b in body-blocks(md) { b }
  signature-block(meta)
}
