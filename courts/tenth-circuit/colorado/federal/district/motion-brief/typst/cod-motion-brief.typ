// Motion to dismiss with its memorandum, for the U.S. District Court for the District of Colorado (cod).
// Rules: D.C.COLO.LCivR 10.1 (paper, margins, font, double spacing, one side); 7.1 (motions: separate document,
// the rule the motion is filed under, citations to page or subsection, concision; 7.1(a) and (b)(2) conferral
// exception for Rule 12 motions); 5.1(a) (CM/ECF format); Fed. R. Civ. P. 7(b)(1), 12(b)(6). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif"   // no typeface rule in 10.1(d); Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                   // LCivR 10.1(d): not less than 12-point font, footnotes included
#let page-w = 8.5in                     // LCivR 10.1(b): 8 1/2 by 11 inch white paper
#let page-h = 11in
#let margin-top = 1.5in                 // LCivR 10.1(c): 1 1/2 inches at the top
#let margin-side = 1in                  // LCivR 10.1(c): 1 inch at the left and right
#let margin-bottom = 1in                // LCivR 10.1(c): 1 inch at the bottom
#let body-leading = 1.345em             // LCivR 10.1(e): double spaced (about 24 pt baseline pitch at 12 pt, see README)
#let single-leading = 0.65em            // single spacing for the caption, signature, block quotations and footnotes
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let court-lines = (
  "IN THE UNITED STATES DISTRICT COURT",
  "FOR THE DISTRICT OF COLORADO",
)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("cod-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Lines of a caption or signature block, single spaced (one item per line; no forced line breaks).
#let lines(items, indent: 0pt) = stack(
  dir: ttb,
  spacing: single-leading - 0.1em,
  ..items.map(l => pad(left: indent, [#l])),
)

/// The caption (Fed. R. Civ. P. 10(a)): court, civil action number, parties, title of the paper.
#let caption(sides, case-number, title) = {
  set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
  align(center, lines(court-lines))
  v(body-leading)
  [Civil Action No. #if case-number != none and case-number != "" { case-number } else { "__________________" }]
  v(body-leading)
  for (i, side) in sides.enumerate() {
    if i > 0 {
      v(body-leading / 2)
      [v.]
      v(body-leading / 2)
    }
    lines(side.names)
    lines((side.designation,), indent: 0.5in)
  }
  v(body-leading)
  align(center, strong(title))
  v(body-leading)
}

/// The signature block (LCivR 5.1; Fed. R. Civ. P. 11(a)). `sig.intro` is a list of lines (the date and
/// "Respectfully submitted"); each signer prints "s/ Name" (or `sig_line`), the name, then `lines`.
#let signature(sig) = block(width: 100%, sticky: true, {
  set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
  v(body-leading)
  lines(sig.intro)
  for s in sig.signers {
    v(body-leading)
    lines((
      if "sig_line" in s { s.sig_line } else { "s/ " + s.name },
      s.name,
    ) + s.at("lines", default: ()))
  }
  if "role" in sig { v(body-leading); lines((sig.role,)) }
})

/// A certificate (LCivR 7.1(a) conferral, or service): a centered, unnumbered heading, then its body.
#let certificate(heading-text, body) = block(width: 100%, sticky: true, {
  set par(first-line-indent: 0pt)
  v(body-leading)
  align(center, strong(heading-text))
  v(body-leading)
  body
})

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

/// `meta`: the frontmatter (see README.md, markdown contract). `body`: the markdown after it.
#let cod-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    width: page-w,
    height: page-h,
    margin: (top: margin-top, bottom: margin-bottom, left: margin-side, right: margin-side),
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, fill: black, lang: "en")
  set par(justify: false, leading: body-leading, spacing: body-leading, first-line-indent: para-indent)
  set block(spacing: body-leading)
  show footnote.entry: set text(size: type-size)
  show quote.where(block: true): it => pad(left: 1in, right: 1in, block(width: 100%, {
    set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    text(size: type-size, it.body)
  }))

  // Sections (markdown headings) are numbered by the template: level 1 "I." centered capitals;
  // level 2 "A."; level 3 "1."; level 4 "a.". The sample never types the numbers.
  let sec = state("sec", (0, 0, 0, 0))
  show heading: it => {
    let lvl = it.level
    [#sec.update(s => s.enumerate().map(((i, v)) => if i == lvl - 1 { v + 1 } else if i >= lvl { 0 } else { v }))#context {
      let n = sec.get().at(lvl - 1)
      let mark = if lvl == 1 { numbering("I.", n) } else if lvl == 2 { numbering("A.", n) } else if lvl == 3 { numbering("1.", n) } else { numbering("a.", n) }
      block(width: 100%, sticky: true, above: body-leading, below: body-leading, text(size: type-size, if lvl == 1 {
        align(center, strong([#mark #upper(it.body)]))
      } else {
        pad(left: (lvl - 2) * 0.5in, grid(columns: (0.5in, 1fr), strong(mark), strong(it.body)))
      }))
    }]
  }

  caption(meta.caption, meta.at("case_number", default: none), meta.title)

  // Opening paragraph (the motion's "Defendants ... submit their Motion ... and state as follows:"), if any.
  if "lead_in" in meta { cmarker.render(meta.lead_in, raw-typst: false) }

  if "conferral" in meta {
    certificate(meta.at("conferral_heading", default: "CERTIFICATE OF COMPLIANCE"),
      cmarker.render(meta.conferral, raw-typst: false))
  }

  cmarker.render(body, raw-typst: false)

  signature(meta.signature)

  // Certificate of service (Fed. R. Civ. P. 5(b)): the text, the party block (single spaced), the signer line.
  if "service" in meta {
    certificate(meta.service.at("heading", default: "CERTIFICATE OF SERVICE"), {
      cmarker.render(meta.service.text, raw-typst: false)
      if "party_lines" in meta.service {
        v(single-leading)
        lines(meta.service.party_lines, indent: 0.5in)
      }
      if "signer_lines" in meta.service {
        v(body-leading)
        lines(meta.service.signer_lines)
      }
    })
  }
}
