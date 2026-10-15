// Complaint for the U.S. District Court for the District of Kansas (ksd).
// Rules: Fed. R. Civ. P. 10(a) (caption: court, title, file number, Rule 7(a) designation), 10(b) (numbered
// paragraphs, each limited as far as practicable to a single set of circumstances); D. Kan. Rule 5.1(a) (letter-size
// paper, double-spaced, no less than 12-point, Times New Roman or similar) and 5.1(b) (signature block with contact
// information). D. Kan. Rule 3.1 (civil cover sheet) is a separate filing and is not produced here. See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif"  // D. Kan. R. 5.1(a): "Times New Roman or similar"; docs/FONTS.md substitute (metric-compatible)
#let type-size = 12pt                // D. Kan. R. 5.1(a): no less than 12-point
#let footnote-size = 12pt            // D. Kan. R. 5.1(a): 10-point is the floor for footnotes; 12-point is used
#let margin = 1in                    // not set by the D. Kan. rules: one inch on every side (README)
#let single-leading = 0.5em          // single spacing: the 0.65em line box + 0.5em = 13.8 pt at 12 pt
#let single-pitch = 13.8pt           // the baseline pitch that single-leading gives at 12 pt
#let double-leading = 1.65em         // double spacing: 0.65em line box + 1.65em = 27.6 pt, twice the single pitch
#let para-indent = 0.5in             // first-line indent of numbered paragraphs
#let caption-left = 3.2in            // width of the party column of the caption

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ksd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, case names, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// A stack of single-spaced lines; an empty string is a blank line.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => if type(i) != str {
    i
  } else if i == "" {
    block(height: single-pitch, [])
  } else {
    inl(i)
  }))
}

// ---------------------------------------------------------------------------
// Cover: court name, caption, title
// ---------------------------------------------------------------------------

#let court-title() = {
  set par(leading: single-leading, spacing: 0pt)
  stack(dir: ttb, spacing: single-leading,
    align(center, text(weight: "bold", "IN THE UNITED STATES DISTRICT COURT")),
    align(center, text(weight: "bold", "FOR THE DISTRICT OF KANSAS")),
  )
}

/// The party column: each party's names, then its designation; "v." between the parties.
#let party-stack(parties) = {
  let rows = ()
  for (k, p) in parties.enumerate() {
    if k > 0 { rows.push(pad(left: 0.5in, [v.])) }
    for n in p.names { rows.push(inl(n)) }
    rows.push(pad(left: 1in, inl(p.designation)))
  }
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..rows)
}

/// The caption: parties, a column of ")" marks as tall as the party column, and the case number on the right.
#let caption(meta) = {
  let left = party-stack(meta.caption.parties)
  let right = {
    set par(leading: single-leading, spacing: 0pt)
    let number = if "case_number" in meta and meta.case_number != none and meta.case_number != "" {
      meta.case_number
    } else {
      "____________________"
    }
    let rows = ("Case No. " + number,)
    if "jury_demand" in meta and meta.jury_demand {
      rows.push("")
      rows.push(text(weight: "bold", "JURY DEMANDED"))
    }
    line-stack(rows)
  }
  grid(
    columns: (caption-left, 0.3in, 1fr),
    left,
    context {
      // one ")" per line of the party column (single pitch; the column is measured, not guessed)
      let h = measure(width: caption-left, left).height
      let n = int(calc.round((h + 6pt) / single-pitch))
      stack(dir: ttb, spacing: single-leading, ..range(n).map(_ => [)]))
    },
    align(horizon, right),
  )
}

#let cover(meta) = {
  court-title()
  v(double-leading)
  caption(meta)
  v(double-leading)
  align(center, text(weight: "bold", upper(meta.title)))
  v(double-leading)
}

// ---------------------------------------------------------------------------
// Signature block (D. Kan. R. 5.1(b): names, addresses, telephone, email of the signer)
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(breakable: false, width: 100%, above: double-leading, {
  grid(
    columns: (caption-left, 1fr),
    if "date" in meta and meta.date != none [DATED: #meta.date] else [],
    {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      line-stack(meta.signature.intro)
      v(single-pitch)
      line-stack((meta.signature.signer,) + meta.signature.lines)
    },
  )
})

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (FRCP 10(b)); lists become (a), (b), ...
// ---------------------------------------------------------------------------

/// Footnote definitions (`[^key]: text`) are read out of the body. cmarker resolves a footnote reference only in the
/// same source as its definition, and the body is rendered chunk by chunk, so each chunk gets the definitions it cites.
#let footnote-defs(body) = {
  let defs = (:)
  for line in body.split("\n") {
    let m = line.match(regex("^\\[\\^([^\\]]+)\\]:\\s*(.*)$"))
    if m != none { defs.insert(m.captures.at(0), m.captures.at(1)) }
  }
  defs
}

#let with-notes(t, defs) = {
  let s = t
  for (key, text) in defs {
    if t.contains("[^" + key + "]") { s += "\n\n[^" + key + "]: " + text }
  }
  s
}

/// Headings: level 1 is a centered section, unnumbered; level 2 is a Roman-numeral heading (I., II., ...) with a
/// hanging number; level 3 is a centered bold sub-heading. A level 1 heading named PRAYER or JURY turns paragraph
/// numbering off for what follows (a prayer and a jury demand are not allegations).
#let allegations(body) = {
  let defs = footnote-defs(body)
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "" and c.match(regex("^\\[\\^[^\\]]+\\]:")) == none)
  let num = 0
  let numbered = true
  for t in chunks {
    let src = with-notes(t, defs)
    if t.starts-with("#") {
      if t.starts-with("# ") {
        numbered = t.match(regex("(?i)^#\\s+(PRAYER|JURY)")) == none
      }
      cmarker.render(src, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Items are double-spaced like the paragraphs (the gap between items is the leading typst leaves out);
      // a list may break across pages.
      block(width: 100%, above: 0pt, below: double-leading, {
        set par(leading: double-leading, spacing: 0pt, first-line-indent: 0pt)
        set enum(numbering: "a.", indent: 0.5in, body-indent: 0.35in, spacing: double-leading)
        cmarker.render(src, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
    } else {
      // One paragraph per chunk: the number is the first words of its text (escaped, so it is not a list), and the
      // first-line indent puts the number at the paragraph indent; wrapped lines return to the margin.
      let lead = ""
      if numbered {
        num += 1
        lead = str(num) + "\\.\u{2003}\u{2003}"
      }
      // below: the leading that typst does not add between blocks, so the next paragraph keeps the double pitch
      block(width: 100%, above: 0pt, below: double-leading, {
        set par(leading: double-leading, spacing: 0pt, first-line-indent: (amount: para-indent, all: true))
        cmarker.render(lead + src, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
    }
  }
}

#let ksd-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: double-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  set footnote.entry(separator: line(length: 1.5in, stroke: 0.5pt))
  show footnote.entry: set text(size: footnote-size)
  show footnote.entry: set par(leading: single-leading)

  // Headings: level 1 centered bold caps; level 2 Roman numeral with a hanging number; level 3 centered bold.
  // Every heading is set at the body size (typst's default heading sizes are larger).
  let roman = counter("roman")
  show heading.where(level: 1): it => block(above: double-leading, below: double-leading, sticky: true, width: 100%,
    align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => {
    roman.step()
    context block(above: double-leading, below: double-leading, sticky: true, width: 100%,
      text(size: type-size, grid(columns: (0.5in, 1fr), roman.display("I."), text(weight: "bold", it.body))))
  }
  show heading.where(level: 3): it => block(above: double-leading, below: double-leading, sticky: true, width: 100%,
    align(center, text(size: type-size, weight: "bold", it.body)))

  cover(meta)

  if "lead_in" in meta {
    set par(leading: double-leading, spacing: 0pt, first-line-indent: 0pt)
    [#h(para-indent)#inl(meta.lead_in)]
  }

  allegations(body)

  signature-block(meta)
}
