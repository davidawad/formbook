// Complaint for the U.S. District Court for the Southern District of Ohio (ohsd).
// Rules: S.D. Ohio Civ. R. 5.1(a) (8 1/2 x 11 paper, double-spaced, consecutive page numbers, one-inch
// margins on all sides); Fed. R. Civ. P. 10(a) (caption: court, title, file number), 10(b) (numbered
// paragraphs). See ../README.md for the rule text and the layout choices.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // S.D. Ohio Civ. R. 5.1 sets no typeface; EB Garamond is the only serif vendored in fonts/
#let type-size = 12pt                   // S.D. Ohio Civ. R. 5.1 sets no point size; 12 pt is the working standard (README.md)
#let page-w = 8.5in                     // Civ. R. 5.1(a): 8 1/2 by 11 inch paper
#let page-h = 11in
#let margin = 1in                       // Civ. R. 5.1(a): one-inch margins on all sides (the electronic-filing rule)
#let body-leading = 1.35em              // double spacing: 24 pt baseline pitch at 12 pt in EB Garamond (line box 0.65em); README.md
#let single-leading = 0.5em             // single spacing for the caption party block, counsel and signature
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-left = 3.3in               // width of the party column of the caption
#let text-width = page-w - 2 * margin

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ohsd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, case names in italics, and so on).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line per item: the caption, counsel and signature blocks.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

/// The court's name is set as three centred lines, each its own block, so the division line can be
/// absent or long without a forced break anywhere in the template.
#let court-title(meta) = {
  let lines = ("UNITED STATES DISTRICT COURT", "SOUTHERN DISTRICT OF OHIO")
  if "division" in meta { lines.push(meta.division) }
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..lines.map(l => align(center, text(weight: "bold", l))))
}

/// The caption: the parties on the left (a right rule and a bottom rule, as in S.D. Ohio filings),
/// the case number, the judge and the title of the paper on the right.
#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.2in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 10pt), {
    // Each party: its names, then its designation; one "v." after the first party (the plaintiff side).
    let rows = ()
    for (k, p) in meta.caption.parties.enumerate() {
      if k == 1 { rows.push("v.") }
      rows += p.names + (p.designation,)
    }
    line-stack(rows)
  }),
  block(inset: (left: 0.1in), {
    let rows = ("Case No. " + meta.case_number,)
    if "judge" in meta and meta.judge != none { rows.push(meta.judge) }
    line-stack(rows)
    v(body-leading * 0.5)
    text(weight: "bold", inl(meta.brief_title))
    if "legend" in meta and meta.legend != none {
      v(body-leading * 0.5)
      text(weight: "bold", upper(meta.legend))
    }
  }),
)

#let cover(meta) = {
  court-title(meta)
  v(body-leading)
  caption(meta)
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Body, signature, certificate
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(width: text-width, breakable: false, grid(
  columns: (2.9in, 1fr),
  column-gutter: 0.2in,
  if "date" in meta { [Dated: #meta.date] } else { [] },
  {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    [Respectfully submitted,]
    v(body-leading)
    line-stack(meta.signature.lines)
  },
))

/// Walk the markdown body chunk by chunk (blank-line-separated). Headings are set by the show rules
/// below. A chunk that starts with a capital letter and a full stop ("A. ") is a lettered item (the prayer
/// for relief) and is set unnumbered and indented. Every other chunk is a body paragraph: numbered
/// (Fed. R. Civ. P. 10(b)) when the complaint is numbered, and numbering stops after any heading that the
/// sample lists in `unnumbered` (for example the prayer for relief and the jury demand).
/// The last chunk is set in one unbreakable block with `closing` (the signature block), so the signature
/// never stands alone on a page.
#let body-chunks(body, meta, closing) = {
  let para-counter = counter("allegation")
  let numbered-now = meta.numbered
  let unnumbered = if "unnumbered" in meta { meta.unnumbered } else { () }
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for (i, c) in chunks.enumerate() {
    let t = c.trim()
    let end = if i == chunks.len() - 1 { closing } else { none }
    if t.starts-with("#") {
      let title = t.replace(regex("^#+[ \\t]*"), "").trim()
      numbered-now = meta.numbered and not unnumbered.contains(title)
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.match(regex("^[A-Z]\\. ")) != none {
      block(width: text-width, below: body-leading, breakable: end == none, inset: (left: 0.5in), {
        set par(leading: body-leading, first-line-indent: 0pt)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        if end != none { v(body-leading); end }
      })
    } else if numbered-now {
      para-counter.step()
      block(width: text-width, below: body-leading, breakable: end == none, {
        set par(leading: body-leading, first-line-indent: 0pt)
        context [#h(para-indent)#para-counter.display().#h(0.3in)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)]
        if end != none { v(body-leading); end }
      })
    } else {
      block(width: text-width, below: body-leading, breakable: end == none, {
        set par(leading: body-leading, first-line-indent: 0pt)
        h(para-indent)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        if end != none { v(body-leading); end }
      })
    }
  }
}

#let ohsd-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    numbering: "1",
    footer: context align(center, counter(page).display()),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 centred bold capitals; level 2 centred bold; level 3 bold italic, left.
  // A heading never ends a page: it is sticky to the paragraph after it.
  // Every block is followed by body-leading, so consecutive one-line blocks keep the 24 pt pitch.
  show heading.where(level: 1): it => block(width: text-width, sticky: true, above: body-leading, below: body-leading,
    align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: text-width, sticky: true, above: 0pt, below: body-leading,
    align(center, text(size: type-size, weight: "bold", it.body)))
  show heading.where(level: 3): it => block(width: text-width, sticky: true, above: 0pt, below: body-leading,
    text(size: type-size, weight: "bold", style: "italic", it.body))

  cover(meta)
  let last-chunk = body.trim().split(regex("\\r?\\n[ \\t]*\\r?\\n")).last()
  assert(not last-chunk.starts-with("#"), message: "ohsd-complaint: the body must end with a paragraph (the signature is set with it)")
  body-chunks(body, meta, signature-block(meta))

  // The certificate is one unbreakable block (heading, text, signature), so its heading stays with its text.
  if "certificate" in meta {
    v(body-leading)
    block(width: text-width, breakable: false, {
      align(center, text(weight: "bold", "CERTIFICATE OF SERVICE"))
      v(body-leading)
      set par(leading: body-leading, first-line-indent: 0pt)
      h(para-indent)
      inl(meta.certificate.text)
    })
    v(body-leading)
    block(width: text-width, breakable: false, grid(
      columns: (2.9in, 1fr),
      column-gutter: 0.2in,
      [],
      line-stack(meta.certificate.lines),
    ))
  }
}
