// Complaint for the United States District Court for the District of Delaware (ded).
// Rules: D. Del. LR 5.1.1(a) (8 1/2 x 11 white paper, double-spaced "typical word processing"
// spacing, at least 12 point type for all printed matter, margins at least 1 inch, consecutive page
// numbers, date and descriptive title, Delaware counsel block under the signature line); Fed. R.
// Civ. P. 10(a) (caption, title, file number, Rule 7(a) designation) and 10(b) (numbered paragraphs).
// See ../README.md for the rule text, the verification date and the open choices.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a named layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // Vendored in fonts/ (the only serif vendored). Not a rule requirement: the rule is about size.
#let type-size = 13pt                   // LR 5.1.1(a): at least 12 point for all printed matter. 13 pt is a style choice (Garamond sets smaller than Times at the same size; see README.md).
#let footer-size = 13pt                 // LR 5.1.1(a) "all printed matter": the page number is printed matter too.
#let line-pitch = 27pt                  // Double spacing, measured against the exemplar's 27.6 pt pitch at 12 pt Times (README.md).
#let body-leading = 1.43em              // Gap between body lines. EB Garamond's line box is about 0.65em, so 1.43em gives about 2.08em (27 pt at 13 pt): double spacing.
#let single-leading = 0.45em            // Caption, counsel block, signature and footnotes: single spacing (about 1.1em, EB Garamond line box 0.65em).
#let page-margin = 1in                  // LR 5.1.1(a): margins not less than 1 inch.
#let para-indent = 0.5in                // First-line indent of numbered paragraphs.
#let number-tab = 0.5in                 // Distance from the paragraph number to the text.
#let caption-left = 3.3in               // Width of the party column of the caption.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ded-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// A block of single-spaced lines (caption, counsel, signature). One item per line.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Cover: court title, caption (Fed. R. Civ. P. 10(a)), title of the pleading
// ---------------------------------------------------------------------------

/// The caption: parties on the left, the file number and the jury demand on the right.
/// Each party's names are followed by its designation ("Plaintiffs," indented); "v." sits between.
#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.3in,
  {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    let items = ()
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { items.push([v.]) }
      for n in p.names { items.push(inl(n)) }
      items.push(pad(left: 2in, inl(p.designation)))
    }
    stack(dir: ttb, spacing: single-leading, ..items)
  },
  {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    v(line-pitch * 0.5)
    [C.A. No. #meta.case_number]
    if "jury_demand" in meta and meta.jury_demand {
      v(line-pitch)
      [JURY TRIAL DEMANDED]
    }
  },
)

#let cover(meta) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  align(center, strong(stack(dir: ttb, spacing: single-leading,
    [IN THE UNITED STATES DISTRICT COURT],
    [FOR THE DISTRICT OF DELAWARE],
  )))
  v(line-pitch)
  caption(meta)
  v(line-pitch)
  align(center, strong(upper(inl(meta.title))))
  v(line-pitch * 0.5)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// Signature block: the date of filing (LR 5.1.1(a)) and the signing counsel, Delaware counsel first.
#let signature-block(meta) = {
  let sig = meta.signature
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(
      columns: (2.9in, 1fr),
      column-gutter: 0.2in,
      [Dated: #meta.date],
      {
        line-stack(sig.firm)
        v(line-pitch * 0.5)
        line-stack(sig.lines)
      },
    )
    if "attorneys_for" in meta {
      v(line-pitch * 0.5)
      set par(first-line-indent: 0pt, leading: single-leading, justify: false)
      pad(left: 2.9in + 0.2in, line-stack(meta.attorneys_for))
    }
  })
}

/// Numbered paragraphs (Fed. R. Civ. P. 10(b)). Each blank-line-separated markdown chunk that is
/// neither a heading nor a list is one numbered paragraph. A chunk starting with "!" is an unnumbered
/// paragraph (the filing's own convention for WHEREFORE and the jury demand). Headings are kept with the
/// paragraph after them. Lists are lettered (A., B., ...), as in a prayer for relief.
/// Footnote definitions ("[^name]: ...") are attached to the paragraph that cites them: cmarker only
/// resolves a footnote reference when its definition is in the same markdown source.
#let allegations(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let is-def = c => c.starts-with(regex("^\\[\\^[^\\]]+\\]:"))
  let defs = chunks.filter(is-def)
  let n = 0
  for t in chunks.filter(c => not is-def(c)) {
    if t.starts-with("#") {
      // Headings are drawn here, not by a show rule: a show rule set in this function does not reach
      // headings produced by cmarker (checked by reproduction). Level 1 centred bold caps; level 2 centred
      // bold; level 3 bold italic at the margin. Kept with the paragraph after them (sticky).
      let m = t.match(regex("^(#+)[ \t]*([\\s\\S]*)$"))
      let lvl = m.captures.at(0).len()
      let txt = m.captures.at(1)
      block(width: 100%, sticky: true, above: line-pitch * 0.5, below: line-pitch * 0.5, {
        if lvl == 1 { align(center, strong(upper(txt))) }
        else if lvl == 2 { align(center, strong(txt)) }
        else { strong(emph(txt)) }
      })
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      set enum(numbering: "A.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
      set par(leading: body-leading)
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      v(body-leading)
    } else {
      let unnumbered = t.starts-with("!")
      let text = if unnumbered { t.slice(1).trim() } else { t }
      // Footnote definitions this paragraph cites, in the order they are defined.
      for d in defs {
        let key = d.match(regex("^\\[\\^([^\\]]+)\\]:")).captures.at(0)
        if text.contains("[^" + key + "]") { text += "\n\n" + d }
      }
      if not unnumbered { n += 1 }
      block(width: 100%, {
        if unnumbered {
          h(para-indent)
        } else {
          h(para-indent)
          [#n.]
          h(number-tab - 0.3in)
        }
        cmarker.render(text, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
    }
  }
}

#let ded-complaint(meta, body) = {
  for k in ("case_number", "caption", "title", "date", "signature") {
    if k not in meta { panic("ded-complaint: missing required metadata field `" + k + "`") }
  }

  set document(title: meta.title + ", C.A. No. " + meta.case_number, author: meta.signature.lines.at(0, default: ""))
  set page(
    paper: "us-letter",
    margin: page-margin,
    numbering: "1",
    footer: context align(center, text(size: footer-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", hyphenate: false)
  // Paragraph spacing equals the body leading: typst adds leading only between the lines of one paragraph,
  // so without it the next paragraph starts a natural line height below the last one (overlap, measured).
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)

  cover(meta)

  // An unnumbered lead-in paragraph (the complaint's opening sentence, before the first heading).
  if "lead_in" in meta {
    block(width: 100%, [#h(para-indent)#inl(meta.lead_in)])
  }

  allegations(body)

  signature-block(meta)
}
