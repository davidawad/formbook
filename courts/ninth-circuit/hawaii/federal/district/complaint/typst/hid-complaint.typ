// U.S. District Court for the District of Hawaii: complaint.
//
// Rule-driven and content-agnostic. Requirement references are to ../README.md (the rules,
// with URLs and the date they were verified). No case-specific text, no coordinates measured
// off any filed document, no forced line breaks. The body is rendered by cmarker, except that
// allegations are numbered here (FRCP 10(b)); the metadata is the YAML frontmatter of the sample.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

// STAND-IN FONT. LR 10.2(a)(2) names 14-point Times New Roman for memoranda, and the filed
// complaint exemplar is set in Times New Roman. No Times-metric font is vendored in fonts/,
// so this is EB Garamond until one is. See README "Known gaps", item 1.
#let font-family = "EB Garamond"
#let type-size = 14pt                      // LR 10.2(a)(2) fixes 14 pt for memoranda only, so a complaint's size is
                                           // open; the exemplar's body is 14-pt Times (measured, see README).
#let body-leading = 1.0em                  // LR 10.2(a)(4) double spacing: baseline pitch 2.3 em (32.2 pt at 14 pt),
                                           // the exemplar's pitch (32.3 pt). Calibrated, see README.
#let single-leading = 0.12em               // counsel block, caption, title, quotations, footnotes.
#let page-margin = 1in                     // LR 10.2(a)(1): one-inch margins.
#let para-indent = 0.5in
#let court-title = ("IN THE UNITED STATES DISTRICT COURT", "FOR THE DISTRICT OF HAWAII")  // FRCP 10(a); LR 10.2(c)(1)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("hid-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("hid-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Blank-line separated chunks of the body.
#let chunks(body) = body.split(regex("\n[ \t]*\n")).map(s => s.trim()).filter(s => s != "")

// ---------------------------------------------------------------------------
// Caption (LR 10.2(b): counsel upper left; LR 10.2(c): court, action, case number, title)
// ---------------------------------------------------------------------------

// Counsel identification is single-spaced and set smaller than the body (the exemplar's counsel
// block is 12-pt; LR 10.2(b) requires the block, not its size). It has to fit above the caption on page 1.
#let counsel-size = 11pt
#let counsel-column(lines) = {
  set text(size: counsel-size)
  set par(leading: 0em, spacing: 0pt, first-line-indent: 0pt)
  for l in lines {
    if l == "" { v(0.6em) } else { [#inl(l)] }
    linebreak()
  }
}

// Counsel columns, by how many the frontmatter gives (`counsel.columns`). Widths sum to the 6.5-inch
// text block; three columns keep the counsel block short enough for the caption to start on page 1.
#let counsel-widths = (
  "1": (6.5in,),
  "2": (3.25in, 3.25in),
  "3": (2.3in, 2.2in, 2.0in),
)

#let caption(meta) = {
  let columns = meta.at("counsel", default: (:)).at("columns", default: ())
  grid(
    columns: counsel-widths.at(str(columns.len())),
    ..columns.map(counsel-column),
  )
  v(0.2in)
  if "counsel_for" in meta {
    set par(first-line-indent: 0pt)
    text(style: "italic")[#inl(meta.counsel_for)]
  }
  v(0.3in)
  align(center, strong(court-title.at(0)) + linebreak() + strong(court-title.at(1)))
  v(0.2in)
  block(breakable: false, grid(
    columns: (3.1in, 1fr), column-gutter: 0.2in,
    block(width: 100%, inset: (right: 0.12in, bottom: 0.12in), stroke: (right: 0.7pt, bottom: 0.7pt), {
      set par(leading: single-leading, first-line-indent: 0pt, spacing: 0.9em)
      for p in need(meta, "parties") {
        for n in p.names { [#inl(n)] ; linebreak() }
        v(0.4em)
        align(right, emph(inl(p.designation)))
        v(0.8em)
        if p != meta.parties.last() { [v.] ; linebreak() ; v(0.4em) }
      }
    }),
    {
      set par(leading: single-leading, first-line-indent: 0pt)
      v(0.5em)
      [Civil No. #need(meta, "case_number")]
      if "judge_initials" in meta and meta.judge_initials != "" { [-#meta.judge_initials] }
      v(1.2em)
      strong(need(meta, "title"))
    },
  ))
  v(0.3in)
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

#let allegation = counter("allegation")
#let level2 = counter("heading-level-2")

/// A numbered allegation (FRCP 10(b): numbered paragraphs).
#let numbered(text-md) = {
  allegation.step()
  par(first-line-indent: (amount: para-indent, all: true), {
    context allegation.display()
    [. ]
    inl(text-md)
  })
}

/// A level-1 heading: centered, bold, capitals. Not numbered.
#let heading1(text-md) = block(breakable: false, sticky: true, above: 1em, below: 1em,
  align(center, strong(upper(inl(text-md))))
)

/// A level-2 heading: bold, roman numeral, single-spaced, kept with the next paragraph.
#let heading2(text-md) = {
  level2.step()
  block(breakable: false, sticky: true, above: 1em, below: 1em, {
    set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    strong[#context numbering("I.", ..level2.get()) #h(0.5em) #inl(text-md)]
  })
}

/// An unnumbered paragraph (for example the WHEREFORE clause).
#let unnumbered(text-md) = par(first-line-indent: (amount: para-indent, all: true), inl(text-md))

/// A lettered list (prayer for relief): letters start half an inch in, text hangs at one inch.
#let lettered(items) = {
  let letters = ("a.", "b.", "c.", "d.", "e.", "f.", "g.", "h.", "i.", "j.", "k.", "l.", "m.", "n.", "o.", "p.", "q.", "r.", "s.", "t.")
  for (i, item) in items.enumerate() {
    block(breakable: true, grid(
      columns: (1in, 1fr),
      pad(left: para-indent, [#letters.at(i)]),
      par(first-line-indent: 0pt, inl(item)),
    ))
  }
}

#let render-body(body) = {
  let items = ()
  for c in chunks(body) {
    if c.starts-with("- ") {
      for line in c.split("\n") {
        if line.starts-with("- ") { items.push(line.slice(2).trim()) }
        else {
          let last = items.pop()
          items.push(last + " " + line.trim())
        }
      }
    } else {
      if items.len() > 0 {
        lettered(items)
        items = ()
      }
      if c.starts-with("## ") { heading2(c.slice(3)) }
      else if c.starts-with("# ") { heading1(c.slice(2)) }
      else if c.starts-with("> ") { unnumbered(c.slice(2).replace("\n", " ")) }
      else { numbered(c.replace("\n", " ")) }
    }
  }
  if items.len() > 0 { lettered(items) }
}

// ---------------------------------------------------------------------------
// Signature block (dated line at left, signature block at right)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = meta.at("signature", default: (:))
  block(breakable: false, {
    v(1.5em)
    set par(leading: single-leading, first-line-indent: 0pt)
    if "date" in meta { [#inl(meta.date)] }
    pad(left: 3in, {
      for b in sig.at("blocks", default: ()) {
        for l in b.lines {
          if l == "" { v(single-leading * 1.5) } else { [#inl(l)] }
          linebreak()
        }
        v(0.8em)
      }
    })
  })
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let hid-complaint(meta, body-md) = {
  set document(title: need(meta, "title") + " (Civil No. " + need(meta, "case_number") + ")")
  set page(
    paper: "us-letter", margin: page-margin,
    numbering: none,
    footer: context {
      set text(size: type-size)
      align(center, [#"-" #counter(page).display() #"-"])
    },
  )
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: "ascender", bottom-edge: "descender",
  )
  set par(
    leading: body-leading, spacing: body-leading,
    first-line-indent: 0pt, justify: false,
  )
  set heading(numbering: none)
  show link: it => it.body
  caption(meta)
  render-body(body-md)
  signature-block(meta)
}
