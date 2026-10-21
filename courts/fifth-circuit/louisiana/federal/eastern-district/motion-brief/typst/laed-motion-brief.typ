// E.D. La. memorandum supporting a motion (FRCP 12(b)(6) and the like). Every number is a rule or a named default;
// nothing here is case-specific. Rules (verified 2026-10-14; see ../README.md):
//   E.D. La. LR 7.4 (a contested motion is accompanied by a separate memorandum with citations of authority),
//   LR 7.7 (a memorandum supporting a motion must not exceed 25 pages, excluding exhibits; checked below),
//   LR 10.1 (8-1/2 x 11 inch, double spaced, standard font, margins of at least one inch, page numbers from "2" on,
//     and a caption that shows the Section and the judge and magistrate judge),
//   FRCP 5(b)(2)(E) (electronic service, for the certificate), FRCP 10(a) (caption).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/word-compat.typ": word-compat

// ---------------------------------------------------------------------------
// Rule-driven parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif") // LR 10.1 "standard font"; Times New Roman substitute per docs/FONTS.md
#let type-size = 12pt              // LR 10.1 sets no point size; 12 pt, as in the filed exemplar
#let body-leading = 1.345em        // double spacing: the Liberation Serif line box is 0.655em, so 0.655em + 1.345em = 24 pt at 12 pt
#let single-leading = 0.495em       // single spacing (caption, signature, block quotations): about 13.8 pt
#let margin = 1in                  // LR 10.1: every margin no less than one inch
#let footer-descent = 0.6in        // LR 10.1: a page number is not less than 1/2 inch from the bottom edge
#let para-indent = 0.5in           // first-line indent of body paragraphs
#let caption-left = 3.25in         // width of the party column of the caption
#let sig-indent = 3.0in            // signature block starts at the right half of the page
#let memo-page-limit = 25          // LR 7.7: a memorandum supporting a motion, excluding exhibits

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("laed-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italic case names, and so on).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One line of a single-spaced stack (caption, counsel, signature): each line is its own block.
#let sline(c) = block(above: 0pt, below: single-leading, c)

/// A caption field the sample leaves empty (not yet assigned): a blank line to fill in.
#let or-blank(v) = if v == none or v == "" { "______________" } else { v }

/// Paragraphs of the body, split on blank lines.
#let body-chunks(body) = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")

// ---------------------------------------------------------------------------
// Caption: FRCP 10(a) and LR 10.1
// ---------------------------------------------------------------------------

#let court-title() = {
  block(above: 0pt, below: single-leading, align(center, text(weight: "bold", [UNITED STATES DISTRICT COURT])))
  block(above: 0pt, below: body-leading, align(center, text(weight: "bold", [EASTERN DISTRICT OF LOUISIANA])))
}

/// One caption field on the right: a label line, then its value (or a blank to fill in).
#let cap-field(label, v, above: single-leading) = {
  block(above: above, below: single-leading, label)
  block(above: 0pt, below: 0pt, or-blank(v))
}

// The party names are joined by VERSUS (the usage in the filed memorandum; no rule sets it).
#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.35in,
  {
    set par(leading: single-leading)
    rect(
      width: 100%,
      stroke: (right: 0.75pt + black, bottom: 0.75pt + black),
      inset: (right: 0.2in, bottom: 0.2in, top: 0pt, left: 0pt),
      {
        for (i, side) in meta.caption.enumerate() {
          if i > 0 {
            block(above: single-leading, below: single-leading, pad(left: 0.5in, [VERSUS]))
          }
          for n in side.names { sline(inl(n)) }
          block(above: single-leading, below: 0pt, pad(left: 1.5in, inl(side.designation)))
        }
      },
    )
  },
  // Each field is a label over its value, so a long case number or a magistrate's name never wraps mid-token.
  block(above: 0pt, below: 0pt, {
    cap-field("CIVIL ACTION NO.", meta.at("civil_action_no", default: none), above: 0pt)
    cap-field("SECTION:", meta.at("section", default: none))
    cap-field("JUDGE", meta.at("judge", default: none))
    cap-field("MAGISTRATE JUDGE", meta.at("magistrate", default: none))
  }),
)

#let title-block(meta) = {
  block(above: body-leading, below: 0pt, align(center, text(weight: "bold", meta.title)))
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// Heading levels: 1 centered bold (the author types it in capitals); 2 bold; 3 bold italic.
/// Sticky, so a heading never ends a page.
#let heading-block(level, t) = block(above: body-leading, below: 0pt, width: 100%, sticky: true, {
  if level == 1 {
    align(center, text(weight: "bold", inl(t)))
  } else if level == 2 {
    text(weight: "bold", inl(t))
  } else {
    text(weight: "bold", style: "italic", inl(t))
  }
})

/// A lettered item: the author types the label ("A." or "(a)"); the template only hangs it.
#let lettered-item(t) = {
  let m = t.match(regex("^(\\(?[A-Za-z]\\)?\\.?)[ \\t]+([\\s\\S]*)$"))
  grid(
    columns: (para-indent + 0.4in, 1fr),
    column-gutter: 0.1in,
    pad(left: para-indent, [#m.captures.at(0)]),
    inl(m.captures.at(1)),
  )
}

#let body-flow(body) = {
  for chunk in body-chunks(body) {
    let t = chunk.trim()
    if t.starts-with("#") {
      let m = t.match(regex("^(#+)[ \\t]+([\\s\\S]*)$"))
      heading-block(m.captures.at(0).len(), m.captures.at(1))
    } else if t.match(regex("^([A-Za-z]\\.|\\([A-Za-z]\\))[ \\t]")) != none {
      block(width: 100%, lettered-item(t))
    } else if t.starts-with(">") {
      // An indented, single-spaced block quotation (FRAP-style; the memorandum's quotations).
      block(width: 100%, pad(left: 0.5in, right: 0.5in, {
        set par(leading: single-leading)
        inl(t)
      }))
    } else {
      // A body paragraph: first-line indent, not numbered (memoranda are not paragraph-numbered).
      block(width: 100%, {
        h(para-indent)
        inl(t)
      })
    }
  }
}

/// Signature block (single spaced, right half of the page). "Dated" sits on the left if the sample gives a date.
#let signature-block(meta) = block(width: 100%, above: body-leading, breakable: false, {
  grid(
    columns: (sig-indent, 1fr),
    block(above: 0pt, below: 0pt, if meta.at("date", default: none) != none [Dated: #meta.date] else []),
    block(above: 0pt, below: 0pt, [Respectfully submitted,]),
  )
  for group in meta.signature {
    pad(left: sig-indent, block(above: body-leading, below: 0pt, {
      for n in group.names { sline(inl(n)) }
      for l in group.at("lines", default: ()) { sline(inl(l)) }
    }))
  }
})

/// Certificate of service (FRCP 5(b)(2)(E)). Shown only when the sample gives a `service` map.
#let certificate(meta) = {
  let s = meta.service
  block(above: body-leading, below: 0pt, width: 100%, sticky: true, align(center, text(weight: "bold", [CERTIFICATE OF SERVICE])))
  block(width: 100%, {
    h(para-indent)
    [I hereby certify that a copy of the foregoing has been served on all counsel of record via the Court’s Electronic Filing System.]
  })
  block(width: 100%, {
    h(para-indent)
    [This #s.date.]
  })
  pad(left: sig-indent, block(above: body-leading, below: 0pt, breakable: false, {
    sline([/s/ #s.signer])
  }))
}

// ---------------------------------------------------------------------------
// Document
// ---------------------------------------------------------------------------

#let laed-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: footer-descent,
    footer: context {
      let n = counter(page).get().first()
      if n > 1 { align(center, text(size: type-size, str(n))) }
    },
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  // Word paragraph composition (lib/typst/word-compat.typ); the INPUT's `word:` map sets justify/shrink.
  show: word-compat.with(meta.at("word", default: (:)))
  // Blocks are spaced by one double-spaced line, so the gap between paragraphs is the same as the gap between lines.
  // Single-spaced stacks (caption, counsel, signature) set their own spacing.
  set block(spacing: body-leading)

  court-title()
  block(above: body-leading, below: body-leading, caption(meta))
  title-block(meta)
  body-flow(body)
  signature-block(meta)
  if "service" in meta { certificate(meta) }

  // LR 7.7: the memorandum must not exceed 25 pages. A longer memorandum fails the build (it does not warn).
  context {
    let pages = counter(page).final().first()
    if pages > memo-page-limit {
      panic("LR 7.7: the memorandum is " + str(pages) + " pages; the limit is " + str(memo-page-limit) + " pages, excluding exhibits")
    }
  }
}
