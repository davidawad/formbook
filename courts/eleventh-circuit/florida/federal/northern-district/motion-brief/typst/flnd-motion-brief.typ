// Motion with incorporated memorandum for the U.S. District Court for the Northern District of Florida (flnd).
// Rules: N.D. Fla. Loc. R. 5.1(B) (case style and heading), 5.1(C) (double spaced, 14-point font, one-inch
// margins, numbered pages), 5.1(D) (attorney signature block), 5.1(F) (certificate of service), 7.1(A)-(F)
// (motion in writing, conference statement or exception under 7.1(D), memorandum in the same document,
// 8,000-word limit with a certificate of word count); Fed. R. Civ. P. 10(a)-(b), 12(b), 12(f). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif"  // Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 14pt                  // Loc. R. 5.1(C): at least 14-point font, everywhere (footer included)
#let pitch = 32.2pt                    // double spacing: the baseline pitch measured on the filed exemplars
#let body-leading = 1.65em             // extra space between lines; calibrated so body lines land on `pitch`
#let single-leading = 0.495em           // caption, court title and signature: single spaced, 16 pt pitch
#let blank-line = 16pt                 // one single-spaced blank line
#let para-indent = 0.5in               // first-line indent of body paragraphs
#let caption-left = 3.3in              // width of the party column of the caption

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("flnd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in italics, quotations, etc.).
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
/// "v." between the parties (none here: the defendants are one side); a blank line after each group.
#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.3in,
  block(width: 100%, inset: (right: 0.2in, bottom: 0.1in), stroke: (bottom: 0.75pt), {
    let rows = ()
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { rows += (block(height: 0.65em), block(height: 0.65em)) }
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

/// Body paragraphs are unnumbered (a memorandum, Loc. R. 7.1(E)): each blank-line-separated chunk of markdown
/// is one paragraph with a first-line indent; a list is set as its own block. Headings come from the chunks
/// that start with `#`. The signature block closes the memorandum: it is set before a certificate of service
/// (Loc. R. 5.1(F)) when the sample has one, and at the end otherwise.
#let body(text-body, meta) = {
  let chunks = text-body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let signed = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      if t.contains("CERTIFICATE OF SERVICE") and not signed {
        signature-block(meta)
        signed = true
      }
      md(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      block(width: 100%, md(t))
    } else {
      block(width: 100%, h(para-indent) + md(t))
    }
  }
  if not signed { signature-block(meta) }
}

#let flnd-motion-brief(meta, text-body) = {
  set page(
    paper: "us-letter",
    margin: 1in,
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)

  // Headings: level 1 is a centered section (I. INTRODUCTION; certificates); level 2 is a bold, left-aligned
  // heading with a hanging indent (A. ...). Each heading is kept with the text after it.
  show heading.where(level: 1): it => block(width: 100%, above: body-leading, below: body-leading, sticky: true,
    align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, above: body-leading, below: body-leading, sticky: true,
    {
      set par(hanging-indent: 0.5in)
      text(weight: "bold", it.body)
    })

  court-title(meta)
  v(pitch)
  caption(meta)
  v(pitch)
  align(center, text(weight: "bold", inl(meta.brief_title)))
  v(pitch)

  // The lead-in paragraph is unnumbered and states the relief sought.
  if "lead_in" in meta {
    block(width: 100%, h(para-indent) + inl(meta.lead_in))
  }

  body(text-body, meta)
}
