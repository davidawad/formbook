// Adversary complaint for the United States Bankruptcy Court, District of Oregon (orb).
// Rules: LBR 9004-1(a) (form of documents: size, margins, type, double spacing, counsel block, footer with the
// title and the page number), LBR 9004-2(c) (adversary proceeding caption), LBR 7001-1 (complaint filed with fee,
// cover sheet, summons: not on the page, see README.md). FRBP 7008(a) and FRBP 7001 are stated in the sample text.
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
#let leading-double = 1.35em              // LBR 9004-1(a)(4)(A): double spacing; the line box is 0.65em, so 2.0em = 24 pt at 12 pt
#let leading-single = 0.5em               // counsel block, caption, signature, quotations: single spacing (about 13.8 pt)
#let single-pitch = 13.8pt                // one single-spaced line at 12 pt; the caption's ")" column is built from it
#let para-indent = 0.5in                  // first-line indent of numbered allegations
#let caption-left = 3.4in                 // party column of the LBR 9004-2(c) caption
#let caption-paren = 0.3in                // the ")" column between the parties and the title

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("orb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline and block markdown from a string (names with *et al.*, the lead-in, and the like).
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
    if "subtitle" in meta and meta.subtitle != none {
      parbreak()
      md(meta.subtitle)
    }
    if "jury_demand" in meta and meta.jury_demand {
      v(single-pitch)
      [DEMAND FOR JURY TRIAL]
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

/// A markdown list chunk, one paragraph per item, lettered with `pattern` (the prayer: A., B., ...). Each item
/// is a paragraph starting at the item indent. Rendering the items as
/// paragraphs (not cmarker's list element) keeps each item's full height, so items never overlap.
#let list-items(t, letter-counter) = {
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
    // The letter counter runs across chunks: each prayer item is its own blank-line-separated chunk.
    letter-counter.step()
    context {
      let label = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".at(letter-counter.get().first() - 1) + "."
      v(leading-double)
      [#h(0.5in)#label#h(0.25in)#md(item)]
    }
  }
}

/// Numbered allegations (FRCP 10(b), applied through FRBP 7010). Each blank-line-separated chunk that is
/// neither a heading nor a list is one numbered paragraph; headings and lists are unnumbered.
/// Numbering is applied per chunk, not with a `show par` rule, which recurses without end in typst 0.15.
#let allegations(body, para-counter, letter-counter) = {
  for c in chunks(body) {
    let t = c.trim()
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      list-items(t, letter-counter)
    } else if t.starts-with("~ ") {
      // "~ " marks a paragraph that is not numbered (the prayer lead-in).
      [#h(para-indent)#md(t.slice(2))]
    } else {
      para-counter.step()
      context [#h(para-indent)#para-counter.display().#h(0.25in)#md(t)]
    }
  }
}

#let signature(meta) = block(width: text-width, breakable: false, above: leading-double, {
  if "date" in meta { par(leading: leading-double, meta.date) }
  block(width: 100%, pad(left: 3.0in, lines(meta.signature)))
})

// ---------------------------------------------------------------------------
// Entry
// ---------------------------------------------------------------------------

#let orb-adversary-complaint(meta, body) = {
  let para-counter = counter("allegation")
  let letter-counter = counter("prayer-item")

  set page(
    paper: "us-letter",
    margin: (top: margin-top, bottom: margin-bottom, left: margin-side, right: margin-side),
    footer: page-footer(meta.footer_title),
    footer-descent: 0.35in,
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: leading-double, spacing: 0pt, first-line-indent: 0pt, justify: false)
  // Lists are lettered (the prayer for relief): A., B., ...
  set enum(numbering: "A.", indent: 0.5in, body-indent: 0.25in, spacing: leading-double)

  // Headings: level 1 centered bold caps; level 2 centered bold; level 3 bold italic. Each is kept with the
  // text after it, so a heading never ends a page.
  show heading.where(level: 1): it => block(width: 100%, above: leading-double, below: leading-double, sticky: true,
    align(center, strong(upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, above: leading-double, below: leading-double, sticky: true,
    align(center, strong(it.body)))
  show heading.where(level: 3): it => block(width: 100%, above: leading-double, below: leading-double, sticky: true,
    strong(emph(it.body)))

  cover(meta)

  if "lead_in" in meta and meta.lead_in != none {
    block(width: text-width, { set par(leading: leading-double); h(para-indent); md(meta.lead_in) })
  }

  allegations(body, para-counter, letter-counter)

  signature(meta)
}
