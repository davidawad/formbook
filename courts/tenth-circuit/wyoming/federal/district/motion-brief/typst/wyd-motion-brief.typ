// Memorandum in support of a motion for the U.S. District Court for the District of Wyoming (wyd).
// Rules: D. Wyo. Local Civil Rule 10.1 (typed, double spaced, one side, 8 1/2 x 11, one-inch margins on
// all sides, type not less than 12 point; caption and signature block per the court's usual practice),
// Fed. R. Civ. P. 10(a) (caption); page limit and reply rules: LR 7.1 (not verified, see ../README.md).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see ../README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // vendored in fonts/eb-garamond/; no system font is ever used
#let type-size = 13pt                   // LR 10.1: not less than 12 point. 13 pt matches Times 12 visually
#assert(type-size >= 12pt, message: "wyd-motion-brief: D. Wyo. LR 10.1 requires type not less than 12 point")
#let page-w = 8.5in                     // LR 10.1: 8 1/2 x 11 inch paper
#let page-h = 11in
#let margin = 1in                       // LR 10.1: one inch margin on all sides
#let text-width = page-w - 2 * margin
#let body-leading = 1.05em              // double spacing, same ratio as the wyd complaint template
#let single-leading = 0.3em             // single spacing for the caption, headings, signature and block quotes
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-left = 3.1in               // party column of the caption
#let caption-mid = 0.35in               // ")" column
#let court-name = ("IN THE UNITED STATES DISTRICT COURT", "FOR THE DISTRICT OF WYOMING")

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wyd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italic case names, section symbols, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let letter(i) = "abcdefghijklmnopqrstuvwxyz".at(i)

// ---------------------------------------------------------------------------
// First page: court name, caption, attorney block, title
// ---------------------------------------------------------------------------

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

#let court-title() = {
  set par(leading: single-leading, spacing: 0pt)
  align(center, text(weight: "bold", court-name.at(0)))
  v(single-leading)
  align(center, text(weight: "bold", court-name.at(1)))
}

/// Caption (Fed. R. Civ. P. 10(a)): party names with designations on the left, a ")" column, and the case
/// number on the right. One grid row per caption line; "vs." sits between the parties.
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
  court-title()
  v(1.5em)
  caption(meta)
  v(1.5em)
  align(center, text(weight: "bold", upper(meta.title)))
  v(0.5em)
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// Signature block: "DATED" line, "Respectfully submitted," then the "/s/" line and signer, the firm lines,
/// then the role, in the right half of the page as in the filed exemplar.
#let signature-block(meta) = {
  v(body-leading)
  block(width: text-width, breakable: false, {
    [DATED this #meta.date.]
    v(body-leading)
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

/// Walks the markdown body. Blank-line-separated chunks: a `#` heading (centered bold caps), a `##` heading
/// (bold, hanging indent: "A. ..."), a numbered list (hanging numbers), or a paragraph (first-line indent).
/// A heading stays with the chunk after it.
#let body-chunks(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("## ") {
      // Argument headings ("A. ...") hang: the letter stays at the margin, the title wraps under the text.
      let title = t.slice(3).trim()
      let m = title.match(regex("^([A-Z])\\.[ \\t]+([\\s\\S]*)$"))
      v(body-leading * 0.5)
      block(width: text-width, sticky: true, if m != none {
        grid(columns: (0.5in, 1fr), text(weight: "bold", m.captures.at(0) + "."), {
          set par(leading: single-leading)
          text(weight: "bold", inl(m.captures.at(1)))
        })
      } else {
        text(weight: "bold", inl(title))
      })
      v(body-leading * 0.5)
    } else if t.starts-with("#") {
      let level = t.match(regex("^#+")).end
      let title = t.slice(level).trim()
      v(body-leading * 0.5)
      block(width: text-width, sticky: true,
        align(center, text(weight: "bold", upper(title))))
      v(body-leading * 0.5)
    } else if t.starts-with(regex("^\\d+\\.[ \\t]")) {
      // Numbered items keep their number at the margin of a 0.5 in hanging indent. A line that does not
      // start with a number continues the item above it.
      let parts = ()
      for line in t.split(regex("\\r?\\n")).filter(l => l.trim() != "") {
        let m = line.match(regex("^(\\d+)\\.[ \\t]+([\\s\\S]*)$"))
        if m != none {
          parts.push((m.captures.at(0), m.captures.at(1)))
        } else {
          parts.at(-1) = (parts.at(-1).at(0), parts.at(-1).at(1) + " " + line.trim())
        }
      }
      for it in parts {
        block(width: text-width, pad(left: para-indent, grid(columns: (0.5in, 1fr), [#it.at(0).], {
          set par(leading: body-leading)
          inl(it.at(1))
        })))
      }
    } else {
      block(width: text-width, {
        set par(leading: body-leading)
        h(para-indent)
        inl(t)
      })
    }
  }
}

#let wyd-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    numbering: "1",
    number-align: center + bottom,
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, first-line-indent: 0pt, justify: false)

  // The certificate of service follows the signature block, as in the filed exemplar.
  let parts = body.split("# CERTIFICATE OF SERVICE")
  let main = parts.at(0)
  let cert = if parts.len() > 1 { "# CERTIFICATE OF SERVICE" + parts.at(1) } else { none }

  first-page(meta)
  v(body-leading)
  body-chunks(main)
  signature-block(meta)
  if cert != none {
    body-chunks(cert)
    v(body-leading)
    block(width: text-width, breakable: false, pad(left: 2.5in, {
      line-stack(("/s/ " + meta.signature.signer, meta.signature.signer))
    }))
  }
}
