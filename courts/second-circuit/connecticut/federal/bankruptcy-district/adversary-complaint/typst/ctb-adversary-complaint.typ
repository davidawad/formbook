// Adversary complaint for the United States Bankruptcy Court, D. Connecticut (ctb).
// Rules: FRBP 7010 (caption and form of an adversary pleading: Fed. R. Civ. P. 10 applies, and the caption
// must substantially conform to Official Form 416A); FRBP 9004(a)-(b) (legibility; the caption elements);
// FRBP 7008(a) (jurisdiction allegation and the statement on final orders); FRCP 10(b) (numbered paragraphs);
// D. Conn. Local Bankr. R. 5005-1 (adopts D. Conn. L. Civ. R. 10: double spacing, 8 1/2 x 11, margins of at
// least 1 inch, page numbers after page 1, docket number with judge initials, signature block, date in caption).
// See ../README.md. Content-agnostic: every case-specific word comes from the sample's frontmatter.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")      // no typeface rule in the bankruptcy local rules; Times New Roman substitute per docs/FONTS.md, vendored in fonts/ (README.md, gap 2)
#let type-size = 12pt                  // D. Conn. L. Civ. R. 7(a)(5), applied by Local Bankr. R. 7007-1: text at least 12 point
#let body-leading = 1.345em            // L. Civ. R. 10: double-spaced. Liberation Serif's line box is 0.655em, so 0.655em + 1.345em = 2.0em = 24 pt
#let single-leading = 0.5em            // single spacing for the caption, the signature block and the block quotes
#let margin = 1in                      // L. Civ. R. 10: left and right margins of at least 1 inch
#let para-indent = 0.5in               // first-line indent of numbered paragraphs
#let caption-left = 3.4in              // width of the left (party) column of the caption

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ctb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline and block markdown (case names in italics, quotations).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// Lines stacked with single spacing (no forced breaks: each item is its own block).
#let lines(items) = stack(dir: ttb, spacing: single-leading, ..items)

// ---------------------------------------------------------------------------
// Caption (FRBP 9004(b), Official Form 416A: court, title, case number, document character)
// ---------------------------------------------------------------------------

#let caption(meta) = {
  align(center, text(weight: "bold", lines((
    upper(meta.court),
    upper(meta.district),
    upper(meta.division),
  ))))
  v(body-leading)
  grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.2in,
    block(width: caption-left, stroke: (bottom: 0.75pt, right: 0.75pt), inset: (bottom: 8pt, right: 10pt), {
      lines((
        [In re:],
        block(inset: (left: 0.5in), [#meta.debtors]),
        block(inset: (left: 2.5in), [Debtors.]),
      ))
    }),
    block(inset: (left: 0.1in), {
      let rows = ([Chapter #meta.chapter], [#meta.main_case])
      if meta.at("jointly_administered", default: false) { rows.push([(Jointly Administered)]) }
      lines(rows)
    }),
  )
  v(body-leading * 0.5)
  grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.2in,
    block(width: caption-left, stroke: (bottom: 0.75pt, right: 0.75pt), inset: (bottom: 8pt, right: 10pt), {
      let rows = ()
      for (k, p) in meta.caption.parties.enumerate() {
        if k > 0 { rows.push(block(inset: (left: 2.0in), [v.])) }
        rows += p.names.map(n => [#n])
        rows.push(block(inset: (left: 2.5in), [#p.designation]))
      }
      lines(rows)
    }),
    block(inset: (left: 0.1in), lines((
      [Adv. Pro. No. #meta.adv_number (#meta.judge)],
      [Dated: #meta.date],
    ))),
  )
  v(body-leading)
  align(center, text(weight: "bold", md(meta.title)))
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Body: headings, numbered paragraphs, lists (Fed. R. Civ. P. 10(b) via FRBP 7010)
// ---------------------------------------------------------------------------

/// Blank-line-separated chunks of the markdown body.
#let body-chunks(body) = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")

/// A heading is one block with the chunk after it (`sticky`): it never ends a page.
/// `#` = centred bold caps (section); `##` = bold, left (lettered sub-section); `###` = centred bold (claim).
#let section-heading(level, t) = {
  let s = t.trim()
  if level == 1 {
    block(width: 100%, above: body-leading, below: body-leading, sticky: true,
      align(center, text(weight: "bold", upper(md(s.slice(1).trim())))))
  } else if level == 2 {
    block(width: 100%, above: body-leading, below: body-leading, sticky: true,
      text(weight: "bold", md(s.slice(2).trim())))
  } else {
    block(width: 100%, above: body-leading, below: body-leading, sticky: true,
      align(center, text(weight: "bold", md(s.slice(3).trim()))))
  }
}

/// Renders the body. Paragraphs before the first heading are the unnumbered lead-in, and so are the
/// paragraphs under the prayer for relief ("WHEREFORE"); every other paragraph is numbered 1, 2, ...
/// (the template numbers, the sample does not).
#let body-text(body) = {
  let numbered = false
  for c in body-chunks(body) {
    let t = c.trim()
    if t.starts-with("#") {
      // A section heading starts a numbered run, except the prayer for relief, which is not numbered.
      numbered = not t.contains("PRAYER")
      if t.starts-with("###") {
        section-heading(3, t)
      } else if t.starts-with("##") {
        section-heading(2, t)
      } else {
        section-heading(1, t)
      }
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Lists may break across pages. Items are spaced by body-leading, so each one fills whole lines.
      block(width: 100%, {
        set par(leading: body-leading)
        md(t)
        v(body-leading * 0.5)
      })
    } else if numbered {
      counter("para").step()
      block(width: 100%, {
        h(para-indent)
        context counter("para").display("1.")
        h(0.1in)
        md(t)
      })
    } else {
      block(width: 100%, {
        h(para-indent)
        md(t)
      })
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (D. Conn. L. Civ. R. 10: name, office address, telephone, email under the signature;
// federal bar number beneath the signature)
// ---------------------------------------------------------------------------

#let signature(meta) = {
  let s = meta.signature
  let rows = (upper(s.party), [By: /s/ #s.esigner])
  for signer in s.signers {
    rows.push([#signer.at(0)])
    rows.push([#signer.at(1)])
  }
  rows += s.firm.map(l => [#l])
  rows.push([#s.role])
  block(width: 100%, above: body-leading, breakable: false, grid(
    columns: (3.0in, 1fr),
    column-gutter: 0.2in,
    lines(([Dated: #meta.date], [#s.dated_place])),
    lines(rows),
  ))
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let ctb-adversary-complaint(meta, body) = {
  caption(meta)
  body-text(body)
  signature(meta)
}
