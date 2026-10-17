// Motion with memorandum for the United States Bankruptcy Court, District of Oregon (orb), in an adversary proceeding.
// Rules: LBR 9004-1(a) (form of documents: size, margins, type, double spacing, counsel block, footer with the
// title and the page number), LBR 9004-2(c) (adversary proceeding caption), LBR 9013-1(b)(1) (title names the
// parties against whom relief is sought), LBR 9013-1(b)(2) (notice of motion precedes the substantive motion),
// LBR 7007-1(a)(1) (prefiling certification in the first paragraph), LBR 7007-1(b)(1)(D) (20-page limit).
// See ../README.md for the rule text, the date verified, and the known gaps.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")          // vendored in fonts/; the render never falls back to a system font
#let type-size = 12pt                     // LBR 9004-1(a)(1)(B): no smaller than 12 point (footer included)
#let page-w = 8.5in                       // LBR 9004-1(a)(1)(A)
#let page-h = 11in
#let margin-top = 1in                     // LBR 9004-1(a)(2): top and bottom at least 1 inch
#let margin-bottom = 1in
#let margin-side = 0.75in                 // LBR 9004-1(a)(2): sides at least 3/4 inch
#let text-width = page-w - 2 * margin-side
#let leading-double = 1.35em              // LBR 9004-1(a)(4)(A): double spacing; 2.0em line pitch = 24 pt at 12 pt
#let leading-single = 0.5em               // counsel block, caption, signature: single spacing (about 13.8 pt)
#let single-pitch = 13.8pt                // one single-spaced line at 12 pt; the caption's ")" column is built from it
#let para-indent = 0.5in                  // first-line indent of body paragraphs
#let caption-left = 3.4in                 // party column of the LBR 9004-2(c) caption
#let caption-paren = 0.3in                // the ")" column between the parties and the title

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("orb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline and block markdown from a string.
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// Single-spaced lines (counsel block, caption, signature). Each item is its own paragraph: the paragraph
/// spacing equals the single leading, so the items stack at one single-spaced line each.
#let lines(items) = {
  set par(leading: leading-single, spacing: leading-single, justify: false)
  items.map(i => [#i]).join(parbreak())
}

/// Body chunks: blank-line-separated markdown blocks.
#let chunks(body) = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// LBR 9004-1(a)(9)(D): the title (or an abbreviation) and the page number, in the lower-left margin.
#let page-footer(title) = context {
  let p = counter(page).get().first()
  let n = counter(page).final().first()
  set text(size: type-size)
  align(left, stack(dir: ttb, spacing: 2pt,
    upper(title),
    [Page #p of #n],
  ))
}

// ---------------------------------------------------------------------------
// Cover: counsel (upper left), court title, LBR 9004-2(c) caption
// ---------------------------------------------------------------------------

#let court-title() = {
  align(center, strong[UNITED STATES BANKRUPTCY COURT])
  v(leading-single)
  align(center, strong[FOR THE DISTRICT OF OREGON])
}

/// The LBR 9004-2(c) caption: parties on the left, a ")" column, then the case numbers and the title.
#let caption(meta) = context {
  let c = meta.caption
  // Each party: its names, then its designation; "v." between the parties.
  let rows = ("In re:",) + c.debtor + (c.debtor_role, "")
  for (k, p) in c.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names + (p.designation,)
  }
  let left = lines(rows)
  let n = calc.ceil(measure(width: caption-left, left).height / single-pitch)
  let parens = stack(dir: ttb, spacing: 0pt, ..range(n).map(_ => block(height: single-pitch, [)])))
  let right = {
    set par(leading: leading-single, spacing: leading-single, justify: false)
    [Case No. #meta.case_number]
    parbreak()
    [Adv. Proc. No. #meta.adv_number]
    parbreak()
    v(single-pitch)
    strong(md(meta.brief_title))
    if "hearing" in meta and meta.hearing != none {
      v(single-pitch)
      [DATE OF HEARING: #meta.hearing.date]
      parbreak()
      [TIME OF HEARING: #meta.hearing.time]
    }
  }
  grid(columns: (caption-left, caption-paren, 1fr), left, parens, right)
}

#let cover(meta) = {
  lines(meta.counsel)
  v(leading-double)
  court-title()
  v(leading-double)
  caption(meta)
  pagebreak()
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// A markdown list chunk, one paragraph per item, lettered in sequence with the list counter (1., 2., ...).
/// Each item is its own paragraph (not cmarker's list element), so each keeps its full height.
#let list-items(t, item-counter) = {
  let items = ()
  for line in t.split(regex("\\r?\\n")) {
    let m = line.match(regex("^(?:\\d+\\.|[-*+])[ \\t]+([\\s\\S]*)$"))
    if m != none {
      items.push(m.captures.at(0))
    } else if items.len() > 0 {
      let k = items.len() - 1
      items.at(k) = items.at(k) + " " + line.trim()
    }
  }
  for item in items {
    // The counter runs across chunks: each item may be its own blank-line-separated chunk.
    item-counter.step()
    context {
      let label = str(item-counter.get().first()) + "."
      v(leading-double)
      [#h(para-indent)#label#h(0.25in)#md(item)]
    }
  }
}

/// Body paragraphs are not numbered (a motion, unlike a complaint, does not number its allegations).
/// A chunk starting with "~ " is a paragraph without the first-line indent (the lead-in of a list).
#let body-text(body, item-counter) = {
  for c in chunks(body) {
    let t = c.trim()
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      list-items(t, item-counter)
    } else if t.starts-with("~ ") {
      // Each chunk gets a double line of space before it: paragraphs stacked without it collide.
      v(leading-double)
      md(t.slice(2))
    } else {
      v(leading-double)
      [#h(para-indent)#md(t)]
    }
  }
}

#let signature(meta) = block(width: text-width, breakable: false, above: leading-double, {
  if "date" in meta { par(leading: leading-double, meta.date) }
  block(width: 100%, pad(left: 3.0in, lines(meta.signature)))
})

/// LBR 9013-1(b)(2): the notice of motion, which precedes the substantive motion.
#let notice(meta) = if "notice" in meta and meta.notice != none {
  md(meta.notice)
  v(leading-double)
}

/// Certificate of service on its own page, after the signature. Its chunks are rendered like the body.
#let certificate(meta, item-counter) = if "certificate" in meta and meta.certificate != none {
  pagebreak()
  body-text(meta.certificate, item-counter)
}

// ---------------------------------------------------------------------------
// Entry
// ---------------------------------------------------------------------------

#let orb-motion-brief(meta, body) = {
  let item-counter = counter("list-item")

  set page(
    paper: "us-letter",
    margin: (top: margin-top, bottom: margin-bottom, left: margin-side, right: margin-side),
    footer: page-footer(meta.footer_title),
    footer-descent: 0.35in,
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: leading-double, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 centered bold caps; level 2 bold (argument headings); level 3 bold italic. Each is kept
  // with the text after it, so a heading never ends a page.
  show heading.where(level: 1): it => block(width: 100%, above: leading-double, below: leading-double, sticky: true,
    align(center, strong(upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, above: leading-double, below: leading-double, sticky: true,
    strong(it.body))
  show heading.where(level: 3): it => block(width: 100%, above: leading-double, below: leading-double, sticky: true,
    strong(emph(it.body)))

  cover(meta)

  notice(meta)

  body-text(body, item-counter)

  signature(meta)

  certificate(meta, item-counter)
}
