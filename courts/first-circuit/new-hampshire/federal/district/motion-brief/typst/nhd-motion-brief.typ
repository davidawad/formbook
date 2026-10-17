// Motion to dismiss with accompanying memorandum of law for the U.S. District Court for the District of
// New Hampshire (nhd). Rules: LR 7.1(a) (the word "motion" in the title; memorandum with the motion),
// LR 7.1(a)(3) (25-page limit for a dispositive memorandum), LR 7.1(g) (a Rule 12(b) motion is dispositive);
// LR 5.1(a) (8 1/2 x 11 paper, 12-point proportionally spaced type, one-inch margins, double spaced except
// quotations, page numbers at the bottom center); LR 5.1(b) (attorney identification in the signature
// section); LR 5.1(c) (caption, description of the filing, docket number with the judge's initials);
// LR 5.1(d) and Fed. R. Civ. P. 5(d)(1) (certificate of service). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // Times New Roman substitute per docs/FONTS.md, vendored in fonts/ (Times itself cannot be vendored)
#let type-size = 12pt                   // LR 5.1(a): proportionally spaced font, no less than 12 point
#let margin = 1in                       // LR 5.1(a): no less than one-inch margins
#let body-leading = 1.645em             // LR 5.1(a): double spaced = 2 x single (1.15em = 13.8 pt); Liberation Serif line box 0.655em, so 27.6 pt pitch
#let single-leading = 0.5em             // caption, counsel, signature: single spaced
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let text-width = 8.5in - 2 * margin
#let sig-indent = 3.25in                // signature block starts at the right half of the page

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nhd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Single-spaced lines (caption, counsel, signature). Plain text: no markdown in these fields.
#let lines(items) = {
  set par(leading: single-leading)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => [#i]))
}

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title() = align(center, stack(dir: ttb, spacing: single-leading,
  text(weight: "bold", [IN THE UNITED STATES DISTRICT COURT]),
  text(weight: "bold", [FOR THE DISTRICT OF NEW HAMPSHIRE]),
))

/// The caption: party names on the left, a column of ")" marks, and the docket number beside the
/// middle line. Each row is one single line, so the column of ")" marks lines up with the names.
#let caption(meta) = {
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names + (p.designation,)
  }
  let mid = calc.floor(rows.len() / 2)
  let cells = ()
  for (i, r) in rows.enumerate() {
    cells.push([#r])
    cells.push([)])
    cells.push(if i == mid { [#meta.case_number] } else { [] })
  }
  grid(columns: (3.7in, 0.3in, 1fr), row-gutter: single-leading, ..cells)
}

// ---------------------------------------------------------------------------
// Body: headings, paragraphs (unnumbered), lettered lists
// ---------------------------------------------------------------------------

/// Body text. Each blank-line-separated chunk of markdown is one of:
///   `#` to `####` heading (level 1 centered; 2 and 3 flush left, indented by level; 4 italic);
///   `1.` list (rendered as (a), (b), ...);
///   anything else: one paragraph with a first-line indent.
/// A heading is kept with the chunk after it, so it never ends a page.
/// Headings are typst headings with plain text (no markup in this contract); the space above each heading
/// is strong spacing placed inside the kept block, because weak spacing is dropped at the top of a block.
#let body-text(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let pending = []
  let has-pending = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      let m = t.match(regex("^(#+)[ \\t]+([\\s\\S]*)$"))
      pending += v(body-leading)
      pending += heading(level: m.captures.at(0).len(), [#m.captures.at(1)])
      has-pending = true
      continue
    }
    let piece = if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      block(width: 100%, spacing: 0pt, {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      })
    } else {
      block(width: 100%, spacing: 0pt, {
        set par(leading: body-leading)
        h(para-indent)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      })
    }
    if has-pending {
      block(breakable: false, width: 100%, { pending; piece })
    } else {
      piece
    }
    pending = []
    has-pending = false
  }
  if pending != [] { block(breakable: false, width: 100%, pending) }
}

// ---------------------------------------------------------------------------
// Signature section (LR 5.1(b): name, address, telephone, e-mail and NH bar number)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = meta.signature
  let groups = (
    lines((sig.intro,)),
    if "party" in sig { lines(sig.party) } else { none },
    if "date" in sig { lines((sig.date,)) } else { none },
    lines(("/s/ " + sig.signer,)),
    ..sig.blocks.map(b => lines(b)),
  ).filter(g => g != none)
  block(width: 100%, breakable: false, {
    v(body-leading)
    pad(left: sig-indent, stack(dir: ttb, spacing: body-leading, ..groups))
  })
}

// LR 5.1(d) and Fed. R. Civ. P. 5(d)(1): the certificate of service, personally signed by counsel.
#let certificate-block(meta) = {
  let cert = meta.certificate
  block(width: 100%, breakable: false, {
    v(body-leading)
    heading(level: 1, [Certificate of Service])
    block(width: 100%, {
      set par(leading: body-leading)
      h(para-indent)
      cert.text
    })
    v(body-leading)
    pad(left: sig-indent, lines(cert.signer))
  })
}

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

#let nhd-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    footer: context align(center, text(size: type-size, counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in)

  // Headings: level 1 centered bold caps; level 2 bold, flush left; level 3 bold, indented; level 4 bold italic.
  show heading.where(level: 1): it => {
    align(center, text(size: type-size, weight: "bold", upper(it.body)))
    v(body-leading)
  }
  show heading.where(level: 2): it => {
    text(size: type-size, weight: "bold", it.body)
    v(body-leading)
  }
  show heading.where(level: 3): it => {
    pad(left: 0.5in, text(size: type-size, weight: "bold", it.body))
    v(body-leading)
  }
  show heading.where(level: 4): it => {
    pad(left: 1in, text(size: type-size, weight: "bold", style: "italic", it.body))
    v(body-leading)
  }

  court-title()
  v(body-leading)
  caption(meta)
  v(body-leading)
  align(center, text(weight: "bold", upper(meta.title)))
  v(body-leading)

  body-text(body)

  signature-block(meta)

  if "certificate" in meta {
    certificate-block(meta)
  }
}
