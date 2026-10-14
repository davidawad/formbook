// Complaint for the U.S. District Court for the Northern District of Florida (flnd).
// Rules: N.D. Fla. Loc. R. 5.1(B) (case style and heading), 5.1(C) (double spaced, 14-point font, one-inch
// margins, numbered pages), 5.1(D) (attorney signature block); Fed. R. Civ. P. 8(a), 10(a), 10(b). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"       // vendored in fonts/; see README.md, known gap 2
#let type-size = 14pt                  // Loc. R. 5.1(C): at least 14-point font, everywhere (footer included)
#let pitch = 32.2pt                    // double spacing: the baseline pitch measured on the filed exemplars
#let body-leading = 1.65em             // extra space between lines; calibrated so body lines land on `pitch`
#let single-leading = 0.5em            // caption, court title and signature: single spaced, 16 pt pitch (see README.md)
#let blank-line = 16pt                 // one single-spaced blank line
#let para-indent = 0.5in               // first-line indent of numbered paragraphs
#let caption-left = 3.3in              // width of the party column of the caption

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("flnd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, quotations, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Markdown chunk to content, with a level-1 heading for `#`.
#let md(t) = cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line per item; strings are markdown, content is used as given.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => if type(i) == str { inl(i) } else { i }))
}

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

/// Court name, centered, single spaced (Loc. R. 5.1(B): the case style begins the first page).
#let court-title(meta) = align(center, line-stack((
  text(weight: "bold", "UNITED STATES DISTRICT COURT"),
  text(weight: "bold", "NORTHERN DISTRICT OF FLORIDA"),
  text(weight: "bold", upper(meta.division)),
)))

/// Case style (Loc. R. 5.1(B)): the parties on the left, the case number with the judges' initials on the
/// right. The party column is closed by a rule at its foot. Each party: its names, then its designation;
/// "v." between the parties; a blank line after each group.
#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.3in,
  block(width: 100%, inset: (right: 0.2in, bottom: 0.1in), stroke: (bottom: 0.75pt), {
    let rows = ()
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { rows += (block(height: 0.65em), "v.", block(height: 0.65em)) }
      rows += p.names + (p.designation,)
    }
    line-stack(rows)
  }),
  block(inset: (left: 0.1in), line-stack(("CASE NO.", meta.case_number))),
)

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// The signature block (Loc. R. 5.1(D)): the date, then "Respectfully submitted," and the signing attorney's
/// electronic signature, typed name, bar number, street and email addresses, telephone, and the party served.
#let signature-block(meta) = block(breakable: false, width: 100%, {
  v(pitch)
  grid(
    columns: (3.0in, 1fr),
    column-gutter: 0.2in,
    [Dated: #meta.date],
    {
      line-stack(("Respectfully submitted,",))
      v(blank-line)
      line-stack(meta.signature.firm)
      v(blank-line)
      line-stack((meta.signature.by,) + meta.signature.lines)
    },
  )
})

/// Numbered paragraphs (Fed. R. Civ. P. 10(b)). Each blank-line-separated chunk of markdown that is neither a
/// heading nor a list is one numbered paragraph, except a prayer paragraph (the WHEREFORE clause), which is
/// unnumbered as in the filed complaint. Lists are lettered in roman numerals. Numbering is applied per chunk,
/// not with a `show par` rule: a show rule that re-wraps paragraph content recurses without end in typst 0.15.
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(regex("^\\d+\\.[ \\t]")) {
      // Items are spaced by body-leading, so each item fills whole lines; they may break across pages.
      set enum(numbering: "i.", indent: 1in, body-indent: 0.4in, spacing: body-leading)
      block(width: 100%, md(t))
    } else if t.starts-with("WHEREFORE") {
      block(width: 100%, h(para-indent) + md(t))
    } else {
      para-counter.step()
      // A block per paragraph: inline content would run into the next paragraph on the same line.
      block(width: 100%, context [#h(para-indent)#para-counter.display().#h(0.4in)#md(t)])
    }
  }
}

#let flnd-complaint(meta, body) = {
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: 1in,
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)

  // Headings: level 1 is a centered section; level 2 and 3 are centered bold sub-headings (counts).
  // Each heading is kept with the text after it, so it never ends a page.
  show heading.where(level: 1): it => block(width: 100%, above: body-leading, below: body-leading, sticky: true,
    align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, above: body-leading, below: body-leading, sticky: true,
    align(center, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => block(width: 100%, above: 0pt, below: body-leading, sticky: true,
    align(center, text(weight: "bold", it.body)))

  court-title(meta)
  v(pitch)
  caption(meta)
  v(pitch)
  align(center, text(weight: "bold", inl(meta.brief_title)))
  v(pitch)

  // The lead-in paragraph is unnumbered (the filed complaint begins with it).
  if "lead_in" in meta {
    block(width: 100%, h(para-indent) + inl(meta.lead_in))
  }

  allegations(body, para-counter)

  signature-block(meta)
}
