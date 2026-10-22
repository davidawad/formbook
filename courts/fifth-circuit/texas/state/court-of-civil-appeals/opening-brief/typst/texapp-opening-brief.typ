// Texas Court of Appeals: appellant's opening brief (TRAP 38.1).
//
// Rule-driven and content-agnostic. Governing rules: ../../rules.md (TRAP 9.4, 38) and ../README.md.
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The body is the sample markdown rendered by cmarker; the metadata is the YAML frontmatter of
// the same file (contract: ../README.md, "Markdown contract").
//
// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing). The docx engine (../docx/texapp.lua,
// ../docx/reference.xml) writes the same layout in twips (20 x the pt values here).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif") // TRAP 9.4(e) names no typeface; Times New Roman, the default per docs/FONTS.md
#let type-size = 14pt              // TRAP 9.4(e): conventional typeface no smaller than 14-point
#let footnote-size = 12pt          // TRAP 9.4(e): footnotes no smaller than 12-point
#let pitch-body = 31.5pt           // TRAP 9.4(d): double-spaced text (2.25 x the type size)
#let pitch-single = 16.1pt         // TRAP 9.4(d) exceptions: block quotations, issues, headings, tables, lists of
                                   // parties, signature, contents, index; Word's single line at 14 pt (1.15 x)
#let pitch-note = 13.8pt           // footnotes, single-spaced (Word's single line at 12 pt)
#let note-gap = 4pt                // between footnotes
#let note-clearance = 12.1pt       // the text to the footnote rule: with note-gap, Word's 16.1 pt separator line
#let page-margin = 1in             // TRAP 9.4(c): margins at least 1 inch on all four sides
#let para-indent = 0.5in
#let short-line = 50               // paragraphs shorter than this (bytes of text) are set flush left
#let quote-gap = 14pt              // around a block quotation and between its paragraphs
#let h1-above = 24pt               // level-1 heading: space above and below
#let h1-below = 12pt
#let h-above = 16pt                // level-2 to level-4 headings
#let h-below = 8pt
#let label-column = 2.25in         // first column of a two-column (label, text) table and of the identity list
#let label-gutter = 0.25in
#let row-gap = 14pt                // between the rows of such a table
#let sig-indent = 3in              // signature and cover counsel: the right half of the page
#let sig-above = 22pt
#let toc-col = 36pt                // contents: the page column
#let toa-col = 56pt                // index of authorities: the page column (page lists such as "1, 4, 6")
#let row-hang = 0.25in             // a wrapped contents or index row hangs this far
#let lead-room = 4pt               // a row's last word keeps this much more room before the leader (LibreOffice
                                   // wraps a word that leaves less than about 4 pt for its leader tab)
#let toc-step = 0.4in             // contents: each heading level steps in by this
#let toc-above = 8pt               // between contents and index rows
#let toc-above-1 = 14pt            // above a level-1 contents row
#let group-above = 22pt            // index: above a group title
#let word-limit = 15000            // TRAP 9.4(i)(2)(B): brief in a court of appeals, computer-generated
#let default-district = "Fifth"    // court-lines default; frontmatter `district` and `seat` override
#let default-seat = "Dallas"

// TRAP 9.4(i)(1): parts of a brief not counted toward the word limit. Matched against the
// level-1 heading that opens each section of the markdown.
#let excluded-section = regex(
  "(?i)^(identit|table of contents|index of authorities|table of authorities|statement (regarding|concerning) oral argument|statement of the case|issues? presented|statement of jurisdiction|procedural history|certificate|appendix)",
)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Plain text of a piece of content, for measuring only.
#let plain-text(c) = {
  if type(c) == str { c }
  else if c.has("text") { c.text }
  else if c.has("children") { c.children.map(plain-text).join() }
  else if c.has("body") { plain-text(c.body) }
  else if c.has("child") { plain-text(c.child) }
  else if c.func() == [ ].func() { " " }
  else { "" }
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("texapp brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Escape a literal string for use in a regex.
#let regex-literal(s) = {
  let out = ""
  for ch in s.clusters() {
    if "\\.^$|?*+()[]{}".contains(ch) { out += "\\" + ch } else { out += ch }
  }
  out
}

#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let count-words(s) = s.split(regex("\\s+")).filter(w => w.find(regex("[A-Za-z0-9]")) != none).len()

/// TRAP 9.4(i)(1): words in every level-1 section not excluded by the rule. Text before the first
/// heading of the body (the address to the court) counts; placeholders are not counted.
/// (docx/texapp.lua counts the same way.)
#let word-count(src) = {
  let total = 0
  let chunks = src.split(regex("(?m)^# "))
  total += count-words(chunks.first().replace(regex("\\{\\{[a-z-]+\\}\\}"), ""))
  for chunk in chunks.slice(1) {
    let title = chunk.split("\n").first().trim()
    if title.find(excluded-section) != none { continue }
    total += count-words(chunk.replace(regex("\\{\\{[a-z-]+\\}\\}"), ""))
  }
  total
}

/// A block of single-spaced lines (each a line box of the single pitch).
#let single(above: 0pt, below: 0pt, left: 0pt, sticky: false, breakable: true, body) = block(width: 100%,
  above: above, below: below, sticky: sticky, breakable: breakable, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt)
    pad(left: left, body)
  })

/// Lines from the frontmatter, one paragraph each; an empty string is an empty line.
#let lines-of(ls) = for l in ls {
  if l == "" { block(width: 100%, height: pitch-single, above: 0pt, below: 0pt) }
  else { block(width: 100%, above: 0pt, below: 0pt, par(md(l))) }
}

/// The cover, TRAP 9.4(g): case style, case number, title, filing party, lead counsel's name,
/// address, telephone, email and bar number (the `counsel` lines); the oral-argument request
/// (TRAP 9.4(g), 39.7) when `oral_argument_requested` is true. Single-spaced centered lines with rules between the
/// parts; counsel in the right half below the title.
#let cover(meta) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  let district = meta.at("district", default: default-district)
  let seat = meta.at("seat", default: default-seat)
  let c(above, body) = block(width: 100%, above: above, below: 0pt, align(center, par(body)))
  let rule(above) = block(width: 100%, above: above, below: 0pt, line(length: 100%, stroke: 0.75pt))
  c(0pt)[No. #meta.case_number]
  rule(11pt)
  c(7pt, strong[IN THE COURT OF APPEALS])
  c(0pt, strong[FOR THE #upper(district) DISTRICT OF TEXAS])
  c(0pt, strong[AT #upper(seat)])
  rule(7pt)
  if "caption" in meta { c(11pt, strong(meta.caption)) }
  c(11pt, strong(upper(meta.appellant)))
  c(0pt)[Appellant,]
  c(7pt)[v.]
  c(7pt, strong(upper(meta.appellee)))
  c(0pt)[Appellee.]
  rule(11pt)
  c(7pt)[On Appeal from the #meta.trial_court, #meta.county County, Texas]
  c(0pt)[Trial Court Cause No. #meta.trial_cause]
  if "trial_judge" in meta { c(0pt)[#meta.trial_judge, Presiding] }
  rule(7pt)
  c(11pt, strong(upper(meta.brief_title)))
  rule(11pt)
  block(width: 100%, above: 36pt, below: 0pt, pad(left: sig-indent, lines-of(meta.counsel)))
  let notes = if meta.at("oral_argument_requested", default: false) { ("ORAL ARGUMENT REQUESTED",) } else { () }
  notes += meta.at("cover_notes", default: ())
  for (i, n) in notes.enumerate() { c(if i == 0 { 22pt } else { 0pt }, strong(n)) }
}

/// Label/text rows (the identity of parties and counsel, TRAP 38.1(a); a two-column table): the label in a
/// 2.25 in column, the text beside it, single-spaced; a row is never split across pages.
#let label-rows(rows) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt, hanging-indent: 0pt)
  for (i, (lab, txt)) in rows.enumerate() {
    // between two rows an empty line of row-gap, kept at the top of a page as Word keeps a table's empty row there
    if i > 0 { block(width: 100%, height: row-gap, above: 0pt, below: 0pt) }
    block(width: 100%, breakable: false, above: if i == 0 { row-gap } else { 0pt },
      below: if i == rows.len() - 1 { row-gap } else { 0pt }, grid(
      columns: (label-column, 1fr), column-gutter: label-gutter,
      lab, txt,
    ))
  }
}

#let identity-block(entries) = label-rows(entries.map(e => (strong(md(e.role)), lines-of(e.lines))))

/// A signature block: single-spaced, in the right half of the page, never split.
#let signature-block(lines) = single(above: sig-above, left: sig-indent, breakable: false, lines-of(lines))

/// A level-1 title (a section heading, the contents' and index's titles): bold capitals, centered.
#let h1(body) = single(above: h1-above, below: h1-below, sticky: true, align(center, strong(upper(body))))

/// Contents, TRAP 38.1(b): every heading of levels 1 to 3 with the page it starts on (front matter in lower roman,
/// the body in arabic), each row a listing-row: the text wraps before the page column, a leader runs to the number.
#let toc-page() = context {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  for hd in query(heading.where(level: 1).or(heading.where(level: 2)).or(heading.where(level: 3))) {
    let loc = hd.location()
    let pg = numbering(loc.page-numbering(), ..counter(page).at(loc))
    let ind = (hd.level - 1) * toc-step
    listing-row(loc, [#h(ind)#hd.body#h(lead-room)], pg, toc-col, ind + row-hang, if hd.level == 1 { toc-above-1 } else { toc-above })
  }
}

/// Index of authorities, TRAP 38.1(c): authorities from the frontmatter, grouped, each listed
/// with every body page on which its `find` string appears (located by the layout, not typed).
#let authorities-index(groups) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  let n = 0
  for g in groups {
    block(width: 100%, above: group-above, below: toc-above, sticky: true, par(strong(upper(g.group))))
    for a in g.items {
      let i = n
      n += 1
      let name = if a.at("italic", default: true) { emph(a.name) } else { [#a.name] }
      let cite = a.at("cite", default: none)
      // the page column: toa-col, or the page list's own width when longer (it is never wrapped)
      context {
        let ps = query(<texapp-authority>)
          .filter(m => m.value == i)
          .map(m => counter(page).at(m.location()).first())
          .dedup()
          .sorted()
        let pages = if ps.len() == 0 { strong[not cited] } else { ps.map(str).join(", ") }
        listing-row(none, [#name#if cite != none [, #cite]#h(lead-room)], pages, calc.max(toa-col, measure(pages).width), row-hang,
          toc-above)
      }
    }
  }
}

/// Mark every occurrence of each authority's `find` string in `body` with invisible metadata,
/// so the index can list the pages.
#let mark-authorities(groups, body) = {
  let items = groups.map(g => g.items).flatten()
  for (i, a) in items.enumerate() {
    let key = a.at("find", default: a.name).replace("\u{a7} ", "\u{a7}\u{a0}")
    body = {
      show regex(regex-literal(key)): it => [#it#metadata(i)<texapp-authority>]
      body
    }
  }
  body
}

// ---------------------------------------------------------------------------
// Render
// ---------------------------------------------------------------------------

#let render(src) = {
  let (meta, body) = split-frontmatter(src)

  // TRAP 9.4(i): count, check the limit, and fill the certificate of compliance.
  let words = word-count(body)
  assert(
    words <= word-limit,
    message: "word count " + str(words) + " exceeds the " + str(word-limit) + "-word limit of TRAP 9.4(i)(2)",
  )
  let body = body.replace("{{word-count}}", str(words))
  // A section sign is never left at the end of a line apart from its number.
  let body = body.replace("\u{a7} ", "\u{a7}\u{a0}")

  // The markdown is split at `{{contents}}`: before it, front matter on lower-roman pages;
  // after it, the table of contents, the index of authorities, then the body from page 1.
  let parts = body.split(regex("(?m)^\\{\\{contents\\}\\}[ \t]*$"))
  assert(parts.len() == 2, message: "texapp brief: the markdown needs exactly one {{contents}} line")
  let (front, main) = parts

  set document(title: meta.brief_title)
  // The page number: centered in a single-spaced line box (Word's footer); none on the cover, which counts as i.
  set page(paper: "us-letter", margin: page-margin, numbering: "i",
    footer: context if here().page() > 1 {
      align(center, text(..edges(pitch-single), counter(page).display(page.numbering)))
    })
  set text(font: font-family, size: type-size, lang: "en")
  set par(first-line-indent: (amount: para-indent, all: true))
  show: xengine.with(pitch: pitch-body, list-indent: para-indent)

  // Headings: 14 pt, single-spaced, kept with the text that follows. Level 1 bold capitals centered; level 2 bold;
  // level 3 bold italic; level 4 italic.
  show heading: set text(size: type-size)
  show heading.where(level: 1): it => h1(it.body)
  show heading.where(level: 2): it => single(above: h-above, below: h-below, sticky: true, strong(it.body))
  show heading.where(level: 3): it => single(above: h-above, below: h-below, sticky: true, strong(emph(it.body)))
  show heading.where(level: 4): it => single(above: h-above, below: h-below, sticky: true, emph(it.body))

  // Block quotations and footnotes: single-spaced (TRAP 9.4(d)); footnotes in 12-point (9.4(e)), each kept whole.
  show quote.where(block: true): it => block(above: quote-gap, below: quote-gap, pad(x: para-indent, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, spacing: quote-gap)
    it.body
  }))
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 2in, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: footnote-size, ..edges(pitch-note))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    block(breakable: false, [#super(num) #note.body])
  }
  // A two-column markdown table is read as label and text (a statement of the case set out in rows), as the
  // identity list is set; its first row (a markdown table always has one) is an ordinary row.
  show table: it => if it.columns.len() == 2 {
    let cells = it.children.map(c => if c.func() == table.header { c.children } else { (c,) }).flatten()
    label-rows(range(0, cells.len(), step: 2).map(k => (cells.at(k).body, cells.at(k + 1).body)))
  } else {
    set table(stroke: none, inset: (x: 0pt, y: 4pt), column-gutter: label-gutter)
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    it
  }
  // Short standalone lines (a record or case citation after a quotation, a label) are not
  // indented; body paragraphs keep the first-line indent.
  // A paragraph that ends in a colon introduces what follows (a list, a quotation) and is
  // kept on the same page with it.
  show par: it => {
    let s = plain-text(it.body).trim()
    let p = if it.first-line-indent.amount != 0pt and s.len() < short-line {
      par(first-line-indent: 0pt, it.body)
    } else { it }
    if s.ends-with(":") { block(sticky: true, above: 0pt, below: 0pt, p) } else { p }
  }

  // The markdown with its placeholders: {{identity}}, {{signature}} and {{signer}} on lines of their own. The
  // brief's last block before {{signature}} is kept with the signature; a certificate (the last level-1 section
  // before {{signer}}) is kept on one page with its signer.
  let render-md(m) = {
    let pieces = m.split(regex("(?m)^(\\{\\{(?:identity|signature|signer)\\}\\})[ \t]*$"))
    let tags = m.matches(regex("(?m)^\\{\\{(identity|signature|signer)\\}\\}[ \t]*$")).map(x => x.captures.at(0))
    for (k, piece) in pieces.enumerate() {
      let t = tags.at(k, default: none)
      let heads = piece.matches(regex("(?m)^# "))
      if t == "signer" and heads.len() > 0 {
        let at = heads.last().start
        md(piece.slice(0, at))
        block(breakable: false, width: 100%, above: h1-above, below: 0pt, { md(piece.slice(at)); signature-block(meta.signer) })
      } else if t == "signature" or t == "signer" {
        let blocks = piece.trim(at: end).split(regex("\n[ \t]*\n"))
        let last = blocks.last()
        if blocks.len() > 1 and not last.starts-with("#") {
          // of a list, its last item alone is kept with the signature
          let marker = regex("^([-*+]|[0-9]+[.)])[ \t]")
          let lines = last.split("\n")
          let k = lines.len() - 1
          while k > 0 and lines.at(k).find(marker) == none { k -= 1 }
          let head = blocks.slice(0, -1)
          if lines.first().find(marker) != none and k > 0 {
            head.push(lines.slice(0, k).join("\n"))
            last = lines.slice(k).join("\n")
          }
          md(head.join("\n\n"))
          block(breakable: false, width: 100%, above: if last.starts-with(">") { quote-gap } else { 0pt }, below: 0pt, { md(last); signature-block(meta.at(t)) })
        } else {
          md(piece)
          signature-block(meta.at(t))
        }
      } else {
        md(piece)
        if t == "identity" { identity-block(meta.identity) }
      }
    }
  }

  // Cover (page i, unnumbered).
  cover(meta)
  pagebreak()

  // Front matter (identity of parties, record citations): lower-roman pages from ii.
  if front.trim() != "" {
    render-md(front)
    pagebreak()
  }

  // Table of contents, generated from the headings (TRAP 38.1(b)).
  heading(level: 1)[Table of Contents]
  toc-page()
  pagebreak()

  // Index of authorities (TRAP 38.1(c)).
  if "authorities" in meta {
    heading(level: 1)[Index of Authorities]
    authorities-index(meta.authorities)
    pagebreak()
  }

  // Body: arabic page numbers from 1.
  set page(numbering: "1")
  counter(page).update(1)
  let content = render-md(main)
  if "authorities" in meta { mark-authorities(meta.authorities, content) } else { content }
}
