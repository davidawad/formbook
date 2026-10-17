// Memorandum in support of a motion for the U.S. District Court for the District of Kansas (ksd).
// Rules: D. Kan. Rule 5.1(a) (letter-size paper, double-spaced, no less than 12-point, Times New Roman or similar),
// 5.1(b) (signature block), 5.1(f) (certificate of service: name and address, capacity, manner and date of service);
// D. Kan. Rule 7.1(a) (the brief states the specific relief sought, the nature of the matter, a concise statement of
// the facts, and the argument) and 7.1(d)(3) (a principal brief for a motion to dismiss is 15 pages at most).
// See ../README.md. Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")  // D. Kan. R. 5.1(a): "Times New Roman or similar"; docs/FONTS.md substitute (metric-compatible)
#let type-size = 12pt                // D. Kan. R. 5.1(a): no less than 12-point
#let footnote-size = 12pt            // D. Kan. R. 5.1(a): 10-point is the floor for footnotes; 12-point is used
#let margin = 1in                    // not set by the D. Kan. rules: one inch on every side (README)
#let single-leading = 0.5em          // single spacing: the 0.65em line box + 0.5em = 13.8 pt at 12 pt
#let single-pitch = 13.8pt           // the baseline pitch that single-leading gives at 12 pt
#let double-leading = 1.65em         // double spacing: 0.65em line box + 1.65em = 27.6 pt, twice the single pitch
#let para-indent = 0.5in             // first-line indent of body paragraphs
#let caption-left = 3.2in            // width of the party column of the caption
#let page-limit = 15                 // D. Kan. R. 7.1(d)(3): principal brief supporting a motion other than the listed ones

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ksd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, case names, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// A stack of single-spaced lines; an empty string is a blank line.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false, first-line-indent: 0pt)
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
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
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
  set par(leading: single-leading, spacing: 0pt, justify: false, first-line-indent: 0pt)
  stack(dir: ttb, spacing: single-leading, ..rows)
}

/// The caption: parties, a column of ")" marks as tall as the party column, and the case number on the right.
#let caption(meta) = {
  let left = party-stack(meta.caption.parties)
  let right = {
    set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
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
// Signature block (D. Kan. R. 5.1(b)) and certificate of service (D. Kan. R. 5.1(f))
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(breakable: false, width: 100%, above: double-leading, {
  grid(
    columns: (caption-left, 1fr),
    if "date" in meta and meta.date != none [DATED: #meta.date] else [],
    {
      set par(leading: single-leading, spacing: 0pt, justify: false, first-line-indent: 0pt)
      line-stack(meta.signature.intro)
      v(single-pitch)
      line-stack((meta.signature.signer,) + meta.signature.lines)
    },
  )
})

/// Certificate of service: each recipient needs a name and address, a capacity, a manner of service (D. Kan. R. 5.1(f)).
#let certificate(service) = {
  for r in service.recipients {
    assert("name" in r and "address" in r and "capacity" in r and "manner" in r, message:
      "ksd-motion-brief: D. Kan. R. 5.1(f) needs each recipient's name, address, capacity and manner of service")
  }
  assert("date" in service, message: "ksd-motion-brief: D. Kan. R. 5.1(f)(4) needs the date of service")
  block(breakable: false, width: 100%, above: double-leading, below: 0pt, {
    align(center, text(weight: "bold", "CERTIFICATE OF SERVICE"))
    v(double-leading)
    set par(leading: double-leading, spacing: 0pt, first-line-indent: (amount: para-indent, all: true))
    inl(service.text)
    v(double-leading)
    for r in service.recipients {
      set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
      pad(left: 0.5in, line-stack((r.name,) + r.address + ("Capacity: " + r.capacity, "Manner of service: " + r.manner)))
      v(double-leading)
    }
    v(double-leading)
    pad(left: caption-left, line-stack((service.signer, service.signer_name)))
  })
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// Headings: level 1 is a centered section, unnumbered; level 2 is a letter (A., B., ...) with a hanging number,
/// bold; level 3 is a number (1., 2., ...) under it, bold; level 4 is a letter (a., b., ...) under that, italic.
#let ksd-motion-brief(meta, body) = {
  // Rule 7.1(a): the brief must contain a statement of the facts and a statement of the specific relief sought
  assert(body.match(regex("(?im)^#\\s+.*(FACTS|BACKGROUND)")) != none, message:
    "ksd-motion-brief: D. Kan. R. 7.1(a)(3) needs a concise statement of the facts (a level 1 heading naming the facts or background)")
  assert(body.match(regex("(?im)^#\\s+CONCLUSION")) != none, message:
    "ksd-motion-brief: D. Kan. R. 7.1(a)(1) needs the specific relief sought (a level 1 CONCLUSION heading)")

  set page(
    paper: "us-letter",
    margin: margin,
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: double-leading, spacing: double-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set footnote.entry(separator: line(length: 1.5in, stroke: 0.5pt))
  show footnote.entry: set text(size: footnote-size)
  show footnote.entry: set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)

  let sub2 = counter("sub2")
  let sub3 = counter("sub3")
  let sub4 = counter("sub4")
  show heading.where(level: 1): it => block(above: double-leading, below: double-leading, sticky: true, width: 100%,
    align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => {
    sub2.step()
    sub3.update(0)
    sub4.update(0)
    context block(above: double-leading, below: double-leading, sticky: true, width: 100%,
      text(size: type-size, grid(columns: (0.5in, 1fr), sub2.display("A."), text(weight: "bold", it.body))))
  }
  show heading.where(level: 3): it => {
    sub3.step()
    sub4.update(0)
    context block(above: double-leading, below: double-leading, sticky: true, width: 100%,
      text(size: type-size, grid(columns: (0.5in, 1fr), sub3.display("1."), text(weight: "bold", it.body))))
  }
  show heading.where(level: 4): it => {
    sub4.step()
    context block(above: double-leading, below: double-leading, sticky: true, width: 100%,
      text(size: type-size, grid(columns: (0.5in, 1fr), sub4.display("a."), text(style: "italic", it.body))))
  }

  // Block quotations are single-spaced and indented on both sides.
  show quote.where(block: true): it => pad(x: 0.5in, block(below: double-leading, {
    set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
    it.body
  }))

  set enum(numbering: "a.", indent: 0.5in, body-indent: 0.35in, spacing: double-leading)
  set list(indent: 0.5in, body-indent: 0.35in, spacing: double-leading)

  cover(meta)

  cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1)

  signature-block(meta)
  [#metadata(none) <brief-end>]

  if "service" in meta and meta.service != none {
    certificate(meta.service)
  }

  // D. Kan. R. 7.1(d)(3): the principal brief (caption through the signature) is 15 pages at most
  context {
    let end = query(<brief-end>).first().location().page()
    assert(end <= page-limit, message: "ksd-motion-brief: the brief runs to page " + str(end) + "; D. Kan. R. 7.1(d)(3) allows " + str(page-limit) + " pages")
  }
}
