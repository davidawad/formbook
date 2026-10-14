// Memorandum of law supporting a motion, for the United States Bankruptcy Court, D. Connecticut (ctb).
// Rules: Local Bankr. R. 9013-1 (motions conform to FRBP 9013); Local Bankr. R. 7007-1 (adversary motion practice
// follows D. Conn. L. Civ. R. 7) and 7007-2(a) (a brief is at most 25 pages, excluding the table of contents and
// table of authorities; a reply at most 10); D. Conn. L. Civ. R. 7(a)(1)-(2) (oral argument indicated in the lower
// margin of the first page); D. Conn. L. Civ. R. 7(a)(5) (text at least 12 point, footnotes at least 10 point);
// Local Bankr. R. 5005-1 adopting D. Conn. L. Civ. R. 10 (double spacing, 8 1/2 x 11, margins of at least 1 inch,
// page numbers after page 1, docket number with judge initials, signature block); FRBP 9004(a)-(b) (caption).
// See ../README.md. Content-agnostic: every case-specific word comes from the sample's frontmatter.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"      // no typeface rule in the bankruptcy local rules; vendored in fonts/ (README.md, gap 2)
#let type-size = 12pt                  // D. Conn. L. Civ. R. 7(a)(5), applied by Local Bankr. R. 7007-1: text at least 12 point
#let body-leading = 1.35em             // L. Civ. R. 10: double-spaced. EB Garamond's line box is 0.65em, so 0.65em + 1.35em = 2.0em = 24 pt
#let single-leading = 0.5em            // single spacing for the caption, the tables and the signature blocks
#let margin = 1in                      // L. Civ. R. 10: left and right margins of at least 1 inch
#let para-indent = 0.5in               // first-line indent of numbered paragraphs
#let caption-left = 3.4in              // width of the left (party) column of the caption

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ctb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline and block markdown (case names in italics, quotations).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// Lines stacked with single spacing (no forced breaks: each item is its own block).
#let lines(items) = stack(dir: ttb, spacing: single-leading, ..items)

// ---------------------------------------------------------------------------
// Cover: caption (FRBP 9004(b), Official Form 416A), title, oral-argument legend in the lower margin
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
}

#let cover(meta) = {
  caption(meta)
  v(body-leading)
  align(center, text(weight: "bold", md(meta.title)))
  // Local Civ. R. 7(a)(1): whether oral argument is requested, in the lower margin of the first page.
  if meta.at("oral_argument", default: none) != none {
    place(bottom + left, dy: -0.4in, text(weight: "bold", if meta.oral_argument == "requested" {
      [ORAL ARGUMENT REQUESTED]
    } else {
      [ORAL ARGUMENT NOT REQUESTED]
    }))
  }
}

// ---------------------------------------------------------------------------
// Table of contents (generated from the headings) and table of authorities (from the frontmatter)
// ---------------------------------------------------------------------------

#let toc() = {
  align(center, text(weight: "bold", [TABLE OF CONTENTS]))
  v(body-leading)
  align(right, text(size: 10pt, [Page]))
  outline(title: none, depth: 2, indent: 0pt)
}

#let toa(meta) = {
  align(center, text(weight: "bold", [TABLE OF AUTHORITIES]))
  v(body-leading)
  align(right, text(size: 10pt, [Page(s)]))
  for cat in meta.authorities {
    block(above: body-leading, below: body-leading * 0.5, sticky: true, text(weight: "bold", upper(cat.category)))
    for a in cat.items {
      block(width: 100%, below: body-leading * 0.5, breakable: false, grid(
        columns: (1fr, auto),
        column-gutter: 0.3in,
        md(a.cite),
        [#a.pages],
      ))
    }
  }
}

// ---------------------------------------------------------------------------
// Body: headings, numbered paragraphs, lettered sub-items, lists
// ---------------------------------------------------------------------------

/// Blank-line-separated chunks of the markdown body.
#let body-chunks(body) = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")

/// A heading is a typst heading, so the table of contents can list it. The heading body is plain text (the
/// outline needs an inline entry); the layout is in main.typ's heading show rule. `#` = a major part, centred
/// bold; `##` = an argument heading, bold and left, which may run to two lines.
#let section-heading(level, t) = {
  let s = t.trim()
  if level == 1 {
    heading(level: 1, numbering: none, text(weight: "bold", s.slice(1).trim()))
  } else {
    heading(level: 2, numbering: none, text(weight: "bold", s.slice(2).trim()))
  }
}

/// Renders the body. Paragraphs before the first heading are unnumbered; every later paragraph is numbered
/// 1, 2, ... (the template numbers, the sample does not). Lettered sub-items (a., b., ...) are not numbered.
#let body-text(body) = {
  let numbered = false
  for c in body-chunks(body) {
    let t = c.trim()
    if t.starts-with("#") {
      numbered = true
      if t.starts-with("##") {
        section-heading(2, t)
      } else {
        section-heading(1, t)
      }
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      block(width: 100%, {
        set par(leading: body-leading)
        md(t)
        v(body-leading * 0.5)
      })
    } else if t.starts-with(regex("^[a-z]\\.[ \\t]")) {
      // Lettered sub-item: indented, not numbered as a paragraph (the letter is part of the text).
      block(width: 100%, inset: (left: 0.5in), md(t))
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
// Signature blocks (D. Conn. L. Civ. R. 10: name, office address, telephone and email under the signature;
// federal bar numbers beneath the names). One block per signing firm, side by side.
// ---------------------------------------------------------------------------

#let signature(meta) = {
  let blocks = meta.signature.esigners
  let cols = blocks.map(b => 1fr)
  block(width: 100%, above: body-leading, breakable: false, {
    text(weight: "bold", [RESPECTFULLY SUBMITTED,])
    v(body-leading * 0.5)
    grid(
      columns: cols,
      column-gutter: 0.3in,
      ..blocks.map(b => lines((
        upper(b.firm),
        [/s/ #b.esigner],
        ..b.lines.map(l => [#l]),
      ))),
    )
  })
}
