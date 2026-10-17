// Complaint for the U.S. District Court for the Eastern District of Virginia (vaed).
// Rules (E.D. Va. Local Civil Rules, amended Dec. 1, 2024): L.R. 7(B) (attorney's office address and
// telephone on every pleading); L.R. 7(F)(3) (12 point Roman, footnotes included, one-inch margins,
// double-spaced; the page cap is for briefs). Fed. R. Civ. P. 10(a) (caption), 10(b) (numbered paragraphs).
// See ../README.md. Content-agnostic: every case-specific word comes from the sample, never from here.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // Times New Roman substitute per docs/FONTS.md, vendored in fonts/ (README.md, Known gaps)
#let type-size = 12pt                   // L.R. 7(F)(3): 12 point Roman, footnotes and footer included
#let margin-in = 1in                    // L.R. 7(F)(3): one-inch margins
#let body-leading = 1.345em             // double spacing: Liberation Serif's line box is 0.655em, so 1.345em gives a 24 pt baseline pitch at 12 pt
#let single-leading = 0.5em             // single spacing for the caption and signature block: about 13.8 pt pitch
#let para-indent = 0.5in                // first-line indent; the number of a numbered paragraph sits here
#let caption-w = 3.3in                  // width of the party box in the caption

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\\r?\\n([\\s\\S]*?)\\r?\\n---[ \\t]*\\r?\\n"))
  if m == none { panic("vaed-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, bold) in a paragraph or heading.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Blank-line-separated chunks of the body, trimmed, without empty ones.
#let chunks(body) = body.split("\n\n").map(s => s.trim()).filter(s => s != "")

/// Heading level and text of a `#`-prefixed chunk, or none.
#let heading-of(c) = {
  let m = c.match(regex("^(#{1,3})\\s+(.*)$"))
  if m == none { none } else { (level: m.captures.at(0).len(), text: m.captures.at(1)) }
}

/// Split "I. Title" or "A. Title" into the label ("I.") and the rest, so the label hangs in the margin.
#let label-of(t) = {
  let m = t.match(regex("^([IVX]+|[A-Z]|\\d+)\\.\\s+(.*)$"))
  if m == none { (none, t) } else { (m.captures.at(0) + ".", m.captures.at(1)) }
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let vaed-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin-in,
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  set par(leading: body-leading, spacing: body-leading, justify: false, first-line-indent: 0in)

  // Court title, lines as the sample gives them: bold, single-spaced, centered.
  block(width: 100%, sticky: true, {
    set par(leading: single-leading, spacing: single-leading)
    for line in meta.court {
      align(center, strong(line))
      linebreak()
    }
  })
  v(single-leading * 2)

  // Caption: the party box on the left, the case number on the right (Fed. R. Civ. P. 10(a)).
  grid(
    columns: (caption-w, 1fr),
    gutter: 0.25in,
    block(width: caption-w, stroke: 0.8pt + black, inset: (x: 0.15in, y: 0.15in), {
      set par(leading: single-leading, spacing: single-leading)
      let parties = meta.caption.parties
      for (i, p) in parties.enumerate() {
        for line in p.lines {
          line
          linebreak()
        }
        if p.at("designation", default: none) != none {
          pad(left: 1.4in, p.designation)
          linebreak()
        }
        if i < parties.len() - 1 {
          v(single-leading)
          "v."
          linebreak()
          v(single-leading)
        }
      }
    }),
    align(horizon, meta.caption.case_number),
  )
  v(single-leading * 2)

  // Title of the paper: centered, bold.
  align(center, strong(meta.brief_title))
  v(body-leading)

  // The unnumbered lead-in paragraph (the "alleges as follows" paragraph), if the sample has one.
  if meta.at("lead_in", default: none) != none {
    h(para-indent)
    inl(meta.lead_in)
    parbreak()
  }

  // Body: headings, numbered paragraphs (Fed. R. Civ. P. 10(b)), and lettered prayer items.
  let n = 0
  for c in chunks(body) {
    let hd = heading-of(c)
    if hd != none {
      if hd.level == 1 {
        block(width: 100%, sticky: true, align(center, strong(upper(hd.text))))
      } else {
        let (label, rest) = label-of(hd.text)
        block(width: 100%, sticky: true, if label == none {
          strong(inl(rest))
        } else {
          grid(columns: (0.5in, 1fr), strong(label), strong(inl(rest)))
        })
      }
    } else if c.match(regex("^\\d+\\.\\s")) != none {
      // A markdown list: each item is a lettered prayer item (A., B., ...), hanging at the indent.
      let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".clusters()
      let k = 0
      for it in c.split("\n").map(s => s.trim()).filter(s => s != "") {
        let t = it.match(regex("^\\d+\\.\\s+(.*)$")).captures.at(0)
        grid(columns: (para-indent + 0.5in, 1fr), h(para-indent) + letters.at(k) + ".", inl(t))
        k += 1
      }
    } else if c.starts-with(">") {
      // An unnumbered body paragraph (e.g. the WHEREFORE paragraph before a prayer list): indented, no number.
      h(para-indent)
      inl(c.slice(1).trim())
    } else {
      // A numbered allegation: the number at the indent, then the text; wrapped lines return to the margin.
      n += 1
      h(para-indent)
      str(n) + "."
      h(0.25in)
      inl(c)
    }
    parbreak()
  }

  // Signature block: kept together, single-spaced (L.R. 7(B): office address and telephone in the lines).
  if meta.at("signature", default: none) != none {
    let sig = meta.signature
    block(breakable: false, width: 100%, {
      v(body-leading)
      set par(leading: single-leading, spacing: single-leading)
      if sig.at("date", default: none) != none {
        "Dated: " + sig.date
        linebreak()
        v(single-leading)
      }
      pad(left: 3.25in, block(width: 100%, {
        if sig.at("closing", default: none) != none {
          sig.closing
          linebreak()
          v(single-leading)
        }
        if sig.at("party", default: none) != none {
          sig.party
          linebreak()
          v(single-leading)
        }
        if sig.at("by", default: none) != none {
          sig.by
          linebreak()
          v(single-leading)
        }
        for l in sig.lines {
          l
          linebreak()
        }
      }))
    })
  }
}
