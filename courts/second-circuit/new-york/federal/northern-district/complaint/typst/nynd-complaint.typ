// Complaint for the United States District Court for the Northern District of New York (nynd).
// Rules: N.D.N.Y. L.R. 10.1(a) (form: 12-point type, one-inch margins, double-spaced body, consecutive
// pages), 10.1(c)(1) (caption: court, action, civil action number, judges' initials, nature of paper),
// 10.1(c)(2) (filer identification: signature, typed name, bar roll number, office address, telephone,
// e-mail); Fed. R. Civ. P. 8(a), 10(a)-(b) (numbered paragraphs), 38(b) (jury demand). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif"     // L.R. 10.1 names no typeface; Times New Roman substitute per docs/FONTS.md, vendored in fonts/
#let type-size = 12pt                // L.R. 10.1(a)(1): at least 12-point type, text and footnotes
#let margin = 1in                    // L.R. 10.1(a)(2): one-inch margins on all four sides
#let body-leading = 1.345em          // L.R. 10.1(a)(3): double-spaced body; 24 pt baseline pitch at 12 pt (as in the cand template)
#let single-leading = 0.5em          // L.R. 10.1(a)(4): block quotations and footnotes may be single-spaced; caption and signature are single-spaced
#let pitch = 24pt                     // one double-spaced line: the unit of vertical space between blocks
#let para-indent = 0.5in             // first-line indent; the paragraph number sits at the indent, the text one tab later
#let caption-left = 3.6in            // width of the party column in the caption

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nynd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, section signs, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Vertical space of a given height that is a block (so it never merges into a paragraph).
#let gap(h) = block(width: 100%, height: h, above: 0pt, below: 0pt)

// ---------------------------------------------------------------------------
// Caption (L.R. 10.1(c)(1))
// ---------------------------------------------------------------------------

/// The party names, with "-against-" between parties and each designation under its names.
#let parties-block(caption) = stack(dir: ttb, spacing: 0pt,
  ..caption.parties.enumerate().map(((k, p)) => {
    let names = stack(dir: ttb, spacing: single-leading, ..p.names.map(n => inl(n)))
    let party = stack(dir: ttb, spacing: single-leading, names, pad(left: 2in, inl(p.designation)))
    if k == 0 {
      party
    } else {
      stack(dir: ttb, spacing: 0pt, gap(pitch * 0.5), pad(left: 0.5in, inl(caption.between)), gap(pitch * 0.5), party)
    }
  }),
)

#let caption(meta) = {
  assert(meta.at("judges", default: "") != "",
    message: "nynd-complaint: L.R. 10.1(c)(1) requires the assigned judge's initials in the caption (frontmatter: judges)")
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading,
    [UNITED STATES DISTRICT COURT],
    [NORTHERN DISTRICT OF NEW YORK],
  )
  gap(pitch)
  grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.3in,
    block(width: caption-left, stroke: (bottom: 0.75pt), inset: (bottom: 10pt), parties-block(meta.caption)),
    block(inset: (left: 0.1in), stack(dir: ttb, spacing: 0pt,
      [#meta.case_number (#meta.judges)],
      gap(pitch * 2),
      text(weight: "bold", upper(meta.brief_title)),
    )),
  )
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (Fed. R. Civ. P. 10(b)), headings, lists, quotations
// ---------------------------------------------------------------------------

/// A markdown chunk beginning with "{unnumbered}" is an unnumbered paragraph (e.g. the prayer lead-in);
/// one wrapped in parentheses is a centered, unnumbered subtitle (e.g. "(Against Defendants ...)").
#let marker-free(t) = t.slice(t.position("}") + 1).trim()

/// Numbered allegations: each blank-line-separated chunk that is neither a heading, a list, a quotation
/// nor a marked paragraph is one numbered paragraph. Numbering is applied per chunk, not with a `show par`
/// rule: a show rule that re-wraps paragraph content recurses without end in typst 0.15.
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      // A heading is one fixed line (see the show rules below), so it never collapses onto the next paragraph.
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Lettered list (prayer items); a list may break across pages.
      block(width: 100%, above: 0pt, below: 0pt, {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        gap(body-leading)
      })
    } else if t.starts-with("{unnumbered}") {
      block(width: 100%, above: 0pt, below: body-leading,
        [#h(para-indent)#inl(marker-free(t))])
    } else if t.starts-with("(") and t.ends-with(")") {
      block(width: 100%, above: 0pt, below: body-leading, sticky: true, align(center, inl(t)))
    } else {
      para-counter.step()
      block(width: 100%, above: 0pt, below: body-leading, context [#h(para-indent)#box(width: 0.5in)[#(para-counter.display()).]#inl(t)])
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (L.R. 10.1(c)(2): signature, typed name, bar roll number, office address, telephone, e-mail)
// ---------------------------------------------------------------------------
#let signature-block(sig) = {
  for s in sig.signers {
    assert(s.at("bar_roll", default: "") != "",
      message: "nynd-complaint: L.R. 10.1(c)(2) requires the bar roll number of each signing attorney (frontmatter: signature.signers[].bar_roll)")
  }
  block(width: 100%, above: pitch, below: 0pt, breakable: false, grid(
    columns: (1fr, 3.2in),
    column-gutter: 0.2in,
    [Dated: #sig.dated],
    {
      set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
      stack(dir: ttb, spacing: single-leading,
        text(weight: "bold", upper(sig.firm)),
        gap(pitch),
        [By: #box(width: 2.6in, line(length: 100%, stroke: 0.5pt))],
        ..sig.signers.map(s => stack(dir: ttb, spacing: single-leading,
          inl(s.name),
          inl(s.bar_roll),
          inl(s.email),
        )),
        gap(single-leading),
        ..sig.address.map(a => inl(a)),
        inl(sig.phone),
        gap(single-leading),
        text(style: "italic", inl(sig.role)),
      )
    },
  ))
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------
#let nynd-complaint(meta, body) = {
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: margin,
    footer: context align(center, text(size: type-size, counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  set footnote.entry(separator: line(length: 1.5in, stroke: 0.5pt))
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(leading: single-leading)
  show quote.where(block: true): it => block(width: 100%, inset: (left: 1in, right: 1in), above: pitch * 0.5, below: pitch * 0.5, {
    set par(leading: single-leading)
    it.body
  })

  // Headings: level 1 is a centered section in capitals; level 2 a centered bold heading; level 3 a bold left heading.
  show heading.where(level: 1): it => block(width: 100%, above: 0pt, below: 0pt, height: pitch, sticky: true,
    align(horizon + center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, above: 0pt, below: 0pt, height: pitch, sticky: true,
    align(horizon + center, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => block(width: 100%, above: 0pt, below: 0pt, height: pitch, sticky: true,
    align(horizon, text(weight: "bold", it.body)))

  caption(meta)
  gap(pitch * 2)

  if "lead_in" in meta and meta.lead_in != none {
    block(width: 100%, above: 0pt, below: body-leading, [#h(para-indent)#inl(meta.lead_in)])
  }

  // Body: numbered allegations, the prayer's lettered items (a., b., ...), then the signature block.
  set enum(numbering: "a.", indent: 0.5in, body-indent: 0.5in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.5in, spacing: body-leading)
  allegations(body, para-counter)

  signature-block(meta.signature)
}
