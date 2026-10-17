// Memorandum in support of a motion for the U.S. District Court for the Eastern District of Virginia (vaed).
// Rules (E.D. Va. Local Civil Rules, amended Dec. 1, 2024): L.R. 7(F)(1) (a brief accompanies each motion),
// 7(F)(3) (all briefs, including footnotes, in 12 point Roman, one-inch margins, double-spaced; opening
// brief not more than 30 pages), 7(B) (attorney's office address and telephone). Fed. R. Civ. P. 7(b)(1),
// 12(b)(6) (the motion this memorandum supports). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter and body, never from here.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif"        // Times New Roman substitute per docs/FONTS.md, vendored in fonts/ (README.md, Known gaps)
#let type-size = 12pt                   // L.R. 7(F)(3): 12 point Roman, footnotes included (set below)
#let margin-in = 1in                    // L.R. 7(F)(3): one-inch margins
#let body-leading = 1.345em             // double spacing: Liberation Serif's line box is 0.655em, so 1.345em gives a 24 pt baseline pitch at 12 pt
#let single-leading = 0.5em             // single spacing for the caption, block lists, and signature block: about 13.8 pt pitch
#let para-indent = 0.5in                // first-line indent of body text
#let max-pages = 30                     // L.R. 7(F)(3): an opening brief shall not exceed 30 pages (exhibits and affidavits excluded)
#let caption-w = 3.3in                  // width of the party box in the caption

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\\r?\\n([\\s\\S]*?)\\r?\\n---[ \\t]*\\r?\\n"))
  if m == none { panic("vaed-motion-brief: the sample must start with a YAML frontmatter block") }
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

/// The signature block (L.R. 7(B): office address and telephone are in the lines), kept together.
#let signature-block(sig) = block(breakable: false, width: 100%, {
  v(body-leading)
  set par(leading: single-leading, spacing: single-leading)
  if sig.at("date", default: none) != none {
    "Date: " + sig.date
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

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let vaed-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin-in,
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  set par(leading: body-leading, spacing: body-leading, justify: false, first-line-indent: 0in)
  // Footnotes are part of the brief and carry the same 12 point type (L.R. 7(F)(3)).
  show footnote.entry: set text(size: type-size)

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

  // Title of the paper: centered, bold, underlined (as the filed captions carry it).
  align(center, underline(strong(meta.brief_title)))
  v(body-leading)

  // Body: headings and paragraphs (no numbered allegations in a brief). The last paragraph is kept on the
  // page with the signature block, so a signature never stands alone on a page.
  let all = chunks(body)
  let sig = meta.at("signature", default: none)
  let sig-done = false
  for (i, c) in all.enumerate() {
    let hd = heading-of(c)
    if hd != none {
      if hd.level == 1 {
        block(width: 100%, sticky: true, align(center, strong(upper(hd.text))))
      } else if hd.level == 2 {
        let (label, rest) = label-of(hd.text)
        block(width: 100%, sticky: true, if label == none {
          strong(inl(rest))
        } else {
          grid(columns: (0.5in, 1fr), strong(label), strong(inl(rest)))
        })
      } else {
        let (label, rest) = label-of(hd.text)
        block(width: 100%, sticky: true, pad(left: 0.5in, if label == none {
          strong(inl(rest))
        } else {
          grid(columns: (0.5in, 1fr), strong(label), strong(inl(rest)))
        }))
      }
    } else if sig != none and i == all.len() - 1 {
      block(breakable: false, {
        h(para-indent)
        inl(c)
        parbreak()
        signature-block(sig)
      })
      sig-done = true
    } else {
      h(para-indent)
      inl(c)
    }
    parbreak()
  }

  // Signature block (if the last paragraph did not carry it), then the certificate of service on its own page.
  if sig != none and not sig-done {
    signature-block(sig)
  }
  if meta.at("certificate", default: none) != none {
    let cert = meta.certificate
    pagebreak(weak: true)
    align(center, strong(upper(cert.title)))
    v(body-leading)
    h(para-indent)
    inl(cert.text)
    parbreak()
    block(breakable: false, width: 100%, {
      set par(leading: single-leading, spacing: single-leading)
      for l in cert.served {
        l
        linebreak()
      }
      v(single-leading)
    })
    if meta.at("signature", default: none) != none {
      signature-block(meta.signature)
    }
  }

  // The 30-page cap (L.R. 7(F)(3)): the build fails if the brief runs longer.
  context {
    let pages = counter(page).final().first()
    if pages > max-pages {
      panic("vaed-motion-brief: " + str(pages) + " pages exceed the " + str(max-pages) + "-page limit of Local Civil Rule 7(F)(3)")
    }
  }
}
