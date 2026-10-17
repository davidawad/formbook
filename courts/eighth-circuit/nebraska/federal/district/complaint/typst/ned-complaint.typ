// Complaint for the U.S. District Court for the District of Nebraska (ned).
// Rules: Fed. R. Civ. P. 10(a) (caption: court name, title, file number, Rule 7(a) designation) and 10(b)
// (numbered paragraphs); NECivR 10.1(a)(3) (the caption shows the paper's description and any jury demand);
// NECivR 11.1(a)(1)(A) (electronic signature format). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or to a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // no face named by NECivR (checked 2026-10-14), so docs/FONTS.md keeps EB Garamond (README.md)
#let type-size = 12pt
#let pitch = 24pt                       // double-spaced baseline pitch (the body grid, a convention)
#let page-w = 8.5in                     // NECivR 10.1(b)(1): 8 1/2 by 11 inch paper (paper filings)
#let page-h = 11in
#let margin = 1in
#let text-width = page-w - 2 * margin
#let body-leading = 1.35em              // double spacing: 0.65em line box + 1.35em leading = 2em = 24 pt at 12 pt
#let single-leading = 0.55em            // single spacing for counsel, caption, signature: 1.2em = 14.4 pt at 12 pt
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let caption-left = 3.25in              // width of the party column of the caption
#let footer-size = 10pt

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ned-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italic, names with *et al.*, etc.).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// Single-spaced lines: one item per line, each item may wrap.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items)
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Footer on every page after the first: the paper's title, the page number, the case number.
#let footer-block(title, case-number) = context {
  if counter(page).get().first() > 1 {
    set text(size: footer-size)
    align(center, counter(page).display())
    v(3pt)
    grid(columns: (1fr, auto), upper(title), [Case No. #case-number])
  }
}

// ---------------------------------------------------------------------------
// Cover: counsel (top left), court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(leading: single-leading, spacing: 0pt)
  align(center, text(weight: "bold", "IN THE UNITED STATES DISTRICT COURT"))
  v(single-leading)
  align(center, text(weight: "bold", "FOR THE DISTRICT OF NEBRASKA"))
  if "division" in meta and meta.division != none {
    v(single-leading)
    align(center, text(weight: "bold", upper(meta.division)))
  }
}

#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.25in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt, top: 4pt), {
    // Each party: its names, then its designation, indented; "v." between the parties.
    let items = ()
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { items.push(md("v.")) }
      for n in p.names { items.push(md(n)) }
      items.push(pad(left: 1.5in, md(p.designation)))
    }
    line-stack(items)
  }),
  block(inset: (left: 0.1in), {
    set par(leading: single-leading, spacing: 0pt)
    [Case No. #meta.case_number]
    v(pitch * 0.5)
    text(weight: "bold", md(meta.brief_title))
    // NECivR 10.1(a)(3): a jury demand must be noted in the pleading caption.
    if "jury_demand" in meta and meta.jury_demand {
      v(pitch * 0.5)
      text(weight: "bold", "Jury Trial Demanded")
    }
    if "trial_location" in meta and meta.trial_location != none {
      v(single-leading)
      [Trial Location: #meta.trial_location]
    }
  }),
)

#let cover(meta) = {
  // Counsel block: upper left, single-spaced, as the filed exemplar has it. Not a rule of this court.
  line-stack(meta.counsel.map(md))
  v(pitch * 1.5)
  court-title(meta)
  v(pitch)
  caption(meta)
  v(pitch)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// Signature block in NECivR 11.1(a)(1)(A) order: "s/ name", bar number, attorney for, firm and contact lines.
#let signature-block(meta) = {
  let sig = meta.signature
  let lines = ("s/ " + sig.signer, "Bar Number: " + sig.bar_number, "Attorney for " + sig.attorney_for) + sig.firm
  block(width: text-width, breakable: false, above: pitch, grid(
    columns: (2.7in, 1fr),
    column-gutter: 0.2in,
    [Dated: #meta.date],
    {
      [Respectfully submitted,]
      v(pitch)
      line-stack(lines.map(md))
    },
  ))
}

/// A heading as its own sticky block. `gap` is the space below it: single spacing when another heading follows
/// (claim sub-lines stay together), otherwise one double-spaced line before the text it introduces.
/// Level 1: centered bold caps; level 2: centered bold; level 3: centered (a claim sub-line, no space above).
#let heading-block(t, gap) = {
  let lvl = t.match(regex("^#+")).text.len()
  let txt = t.replace(regex("^#+[ \\t]*"), "")
  if lvl == 1 {
    block(width: text-width, above: pitch, below: gap, sticky: true, align(center, text(weight: "bold", md(upper(txt)))))
  } else if lvl == 2 {
    block(width: text-width, above: pitch, below: gap, sticky: true, align(center, text(weight: "bold", md(txt))))
  } else {
    block(width: text-width, above: 0pt, below: gap, sticky: true, align(center, md(txt)))
  }
}

/// Numbered allegations (Fed. R. Civ. P. 10(b)). Each blank-line-separated chunk of markdown that is neither a
/// heading nor a list is one numbered paragraph; a chunk starting with "^ " is unnumbered (the WHEREFORE lead-in and
/// the jury demand are not numbered in the exemplar). Lists are lettered A., B., ... (the prayer).
/// Each chunk is its own block, so the next one starts on a new line. Numbers are plain integers, not counters:
/// a counter display inside a block measured one line short in typst 0.15 and the next paragraph overlapped it.
#let allegations(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let n = 0
  for (i, c) in chunks.enumerate() {
    let t = c.trim()
    let next = chunks.at(i + 1, default: "").trim()
    if t.starts-with("#") {
      let gap = if next.starts-with("#") { single-leading } else { single-leading + body-leading }
      heading-block(t, gap)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list may break across pages; its items are double-spaced, as the body is.
      block(width: text-width, below: body-leading, {
        set par(leading: body-leading)
        md(t)
      })
    } else if t.starts-with("^") {
      block(width: text-width, below: body-leading, {
        set par(leading: body-leading)
        h(para-indent)
        md(t.slice(1).trim())
      })
    } else {
      n += 1
      block(width: text-width, below: body-leading, {
        set par(leading: body-leading)
        h(para-indent)
        [#str(n).#h(0.3in)#md(t)]
      })
    }
  }
}

#let ned-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    footer: footer-block(meta.footer_title, meta.case_number),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  cover(meta)

  // Body: numbered allegations; markdown lists become A., B., ... (the prayer).
  set enum(numbering: "A.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  allegations(body)

  signature-block(meta)
}
