// Complaint for the U.S. District Court for the District of Wyoming (wyd).
// Rules: D. Wyo. Local Civil Rule 10.1(a) (typed, double spaced, one side, 8 1/2 x 11, one-inch margins on
// all sides, not less than 12 point) and 10.1(b) (caption per Fed. R. Civ. P. 10(a) plus an attorney
// information block); Fed. R. Civ. P. 10(a) (caption) and 10(b) (numbered paragraphs). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif"   // Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                   // LR 10.1(a): not less than 12 point
#assert(type-size >= 12pt, message: "wyd-complaint: D. Wyo. LR 10.1(a) requires type not less than 12 point")
#let page-w = 8.5in                     // LR 10.1(a): 8 1/2 x 11 inch paper
#let page-h = 11in
#let margin = 1in                       // LR 10.1(a): one inch margin on all sides
#let text-width = page-w - 2 * margin
// Double spacing (LR 10.1(a)): Liberation Serif's line box is 0.655 em, so a 1.345 em leading gives a
// 2 em (24 pt) baseline pitch at 12 pt.
#let body-leading = 1.345em
#let single-leading = 0.495em           // single spacing (a 1.15 em pitch) for the attorney block, caption and signature
#let para-indent = 0.5in                // first-line indent of numbered allegations
#let caption-left = 3.1in               // party column of the caption
#let caption-mid = 0.35in               // ")" column
#let court-name = ("IN THE UNITED STATES DISTRICT COURT", "FOR THE DISTRICT OF WYOMING")

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wyd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *pro hac vice*, italic case names, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let letter(i) = "abcdefghijklmnopqrstuvwxyz".at(i)

// ---------------------------------------------------------------------------
// First page: attorney information block (LR 10.1(b)), court name, caption, title
// ---------------------------------------------------------------------------

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

/// Attorney information block: one column per firm group, each line single spaced.
#let attorney-block(meta) = {
  let cols = meta.attorney.map(group => line-stack(group))
  grid(columns: meta.attorney.map(_ => 1fr), column-gutter: 0.3in, ..cols)
}

#let court-title() = {
  set par(leading: single-leading, spacing: 0pt)
  v(1.5em)
  align(center, text(weight: "bold", court-name.at(0)))
  v(single-leading)
  align(center, text(weight: "bold", court-name.at(1)))
}

/// Caption (Fed. R. Civ. P. 10(a)): party names with designations on the left, a ")" column, and the case
/// number and jury legend on the right. One grid row per caption line, so a long name that wraps
/// pushes its own row down and the ")" column follows it. "vs." sits between the parties.
#let caption(meta) = {
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows += ("", "vs.", "") }
    rows += p.names + (p.designation,)
  }
  let case-no = if "case_number" in meta and meta.case_number != none and meta.case_number != "" {
    meta.case_number
  } else {
    "____________"
  }
  let right = (text("Case No. " + case-no),) + ([],) * (rows.len() - 1)
  if "jury_demand" in meta and meta.jury_demand {
    right.at(2) = text(weight: "bold", "JURY TRIAL DEMANDED")
  }
  let cells = ()
  for (i, r) in rows.enumerate() {
    cells += (inl(r), [)], right.at(i))
  }
  set par(leading: single-leading, spacing: 0pt, justify: false)
  grid(
    columns: (caption-left, caption-mid, 1fr),
    row-gutter: single-leading,
    ..cells,
  )
}

#let first-page(meta) = {
  attorney-block(meta)
  court-title()
  v(1.5em)
  caption(meta)
  v(1.5em)
  align(center, text(weight: "bold", upper(meta.title)))
  v(0.5em)
}

// ---------------------------------------------------------------------------
// Body: numbered allegations (Fed. R. Civ. P. 10(b))
// ---------------------------------------------------------------------------

/// Signature block: date, "/s/" line and signer, the firm lines, then the role, as in the filed exemplar.
#let signature-block(meta) = {
  v(body-leading)
  block(width: text-width, breakable: false, {
    [Dated: #meta.date]
    v(body-leading)
    // The signature sits in the right half of the page, as in the filed exemplar; the firm line must not wrap.
    pad(left: 2.5in, {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      [Respectfully submitted,]
      v(single-leading * 2)
      line-stack(("/s/ " + meta.signature.signer,) + meta.signature.lines)
      v(single-leading * 2)
      line-stack(meta.signature.role)
    })
  })
}

/// Walks the markdown body. Blank-line-separated chunks: a `#` heading (centered caps), a list (lettered
/// items), or a paragraph (numbered, except a paragraph before the first heading, one starting with
/// WHEREFORE, and any paragraph in the prayer for relief). Each paragraph is one block, so the paragraphs
/// never share a line; a heading stays with the chunk after it.
#let body-chunks(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let seen-heading = false
  let para-no = 0
  let in-prayer = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      seen-heading = true
      let level = t.match(regex("^#+")).end
      let title = t.slice(level).trim()
      in-prayer = lower(title).contains("prayer")
      v(body-leading * 0.5)
      if level == 1 {
        block(width: text-width, sticky: true,
          align(center, text(weight: "bold", upper(title))))
      } else if level == 2 {
        block(width: text-width, sticky: true,
          align(center, text(weight: "bold", title)))
      } else {
        block(width: text-width, sticky: true,
          align(center, text(style: "italic", title)))
      }
      v(body-leading * 0.5)
    } else if t.starts-with(regex("^\\d+\\.[ \\t]")) {
      // Lettered items: (a), (b), ...; a list may break across pages. A line that does not start with a
      // number continues the item above it.
      let parts = ()
      for line in t.split(regex("\\r?\\n")).filter(l => l.trim() != "") {
        let m = line.match(regex("^\\d+\\.[ \\t]+([\\s\\S]*)$"))
        if m != none {
          parts.push(m.captures.at(0))
        } else {
          parts.at(-1) = parts.at(-1) + " " + line.trim()
        }
      }
      for (i, it) in parts.enumerate() {
        block(width: text-width, pad(left: para-indent, grid(columns: (0.5in, 1fr), [(#letter(i))], {
          set par(leading: body-leading)
          inl(it)
        })))
      }
    } else if t.starts-with("WHEREFORE") or not seen-heading or in-prayer {
      block(width: text-width, {
        set par(leading: body-leading)
        h(para-indent)
        inl(t)
      })
    } else {
      para-no += 1
      block(width: text-width, {
        set par(leading: body-leading)
        h(para-indent)
        [#para-no.]
        h(0.25in)
        inl(t)
      })
    }
  }
}

#let wyd-complaint(meta, body) = {


  set page(
    paper: "us-letter",
    margin: margin,
    numbering: "1",
    number-align: center + bottom,
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, first-line-indent: 0pt, justify: false)

  first-page(meta)
  v(body-leading)
  body-chunks(body)
  signature-block(meta)
}
