// Memorandum in support of a motion for the U.S. District Court for the Northern District of Ohio (ohnd).
// Rules: Fed. R. Civ. P. 10(a) (caption), 12(b) (the motion this memorandum supports); N.D. Ohio L.R. 7.1(c)
// (memorandum with the motion), 7.1(f) (length: 20 pages for dispositive motions, 15 for others; a memorandum
// over 15 pages needs a table of contents, a table of authorities, a statement of the issues and a summary of
// the argument; every dispositive memorandum carries a certification of track and page limit), 10.1 (8 1/2 x 11
// paper, double spacing except quotations, a 1 1/2 inch top margin on the first page, consecutive page numbers).
// See ../README.md. Content-agnostic: every case-specific word comes from the sample's frontmatter.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or to a stated convention; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")  // L.R. 10.1 names no face; Times New Roman (vendored, docs/FONTS.md), as both filed exemplars
#let type-size = 12pt                  // convention for federal filings; no N.D. Ohio font rule in L.R. 10.1
#let para-indent = 0.5in               // first-line indent of every body paragraph
#let page-w = 8.5in
#let margin = 1in
#let first-page-top = 1.5in            // L.R. 10.1: top margin of the first page, for the clerk's file stamp
#let text-width = page-w - 2 * margin
#let caption-left = 3.3in              // width of the party column of the caption
#let caption-paren = 0.3in             // the column of ")" marks
#let caption-right-inset = 0.3in       // the case number and judge stand this far right of the ")" column
#let title-width = 5.6in               // the title of the paper is centered in a measure narrower than the text
#let heading-step = 0.5in              // each heading level starts half an inch further in, its lines hanging 0.5 in
#let quote-inset = 0.5in               // a block quotation is indented half an inch on both sides
#let sig-col = 2.8in                   // the signature column starts here; the date sits left of it
#let passim-threshold = 7              // convention: an authority cited on 7 or more pages is listed "passim"
#let memo-limit-plain = 15             // L.R. 7.1(f): memoranda relating to all other motions
// L.R. 7.1(f): dispositive-motion memoranda, by track (expedited; administrative, standard and unassigned;
// complex; mass tort). Changed only by an order of the Judicial Officer, which the frontmatter records.
#let track-limits = (
  "expedited": 10,
  "administrative": 20,
  "standard": 20,
  "unassigned": 20,
  "complex": 30,
  "mass tort": 40,
)

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/ohnd-motion-brief.lua and docx/reference.xml set
// the same twips: 20 x pt).
#let pitch-single = 13.8pt             // single spacing (1.15 x the type size): caption, title, headings, quotations, notes, signature
#let pitch-body = 2 * pitch-single     // L.R. 10.1: double-spaced, 27.6 pt (the Hammill exemplar's measured pitch)
#let heading-above = pitch-single      // the space above a heading
#let quote-gap = pitch-single          // above and below a block quotation
#let note-after = 7pt                  // below every footnote, the last too (docx: Footnote Text's space after, 140 twips, which LibreOffice counts on the last note of a page as well)
#let note-clearance = 3.5pt            // from the last text line to the separator; with the separator's 7 pt box, the 10.5 pt LibreOffice keeps between the text and the first note
#let note-rule = 7pt                   // the separator rule at the top of a box this tall, above the first note
// The footer's single-pitch line box ends half an inch above the bottom edge (docx: footer 720 twips).
#let footer-descent = margin - 0.5in - pitch-single

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ohnd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (party names, the signature lines, and so on).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Inline content without the paragraph breaks cmarker may put around it (they may not occur inside a paragraph).
#let unloose(body) = {
  if type(body) != content or body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// One single-spaced paragraph of its own, `above` and `below` the space around it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, right: 0pt, hanging: 0pt, center: false, sticky: false, body) = block(
  width: 100%, above: above, below: below, sticky: sticky, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    set align(if center { std.center } else { std.left })
    pad(left: left, right: right, par(hanging-indent: hanging, unloose(body)))
  })

/// Plain text of content, for the checks on headings (the words of the heading, without markup).
#let text-of(c) = lower(repr(c))

// ---------------------------------------------------------------------------
// Caption (as the complaint: the court title, the party column with ")" marks, and the case number)
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  let lines = ("UNITED STATES DISTRICT COURT", "NORTHERN DISTRICT OF OHIO")
  if "division" in meta { lines.push(upper(meta.division)) }
  for l in lines { line-block(center: true, l) }
}

/// The caption: one row per line of the party column (a name, a designation, "v." between parties with a blank
/// line on each side), a ")" on every line of it (a name that wraps takes one per line), and right of the marks the
/// case number on the first row and the judge on the third. A row is as tall as its name.
#let caption(meta) = {
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows += ("", "v.", "") }
    rows += p.names + (p.designation,)
  }
  let judge = if "judge" in meta and meta.judge != none { meta.judge } else { "" }
  let cells = ()
  for (i, r) in rows.enumerate() {
    let name = line-block(if r == "" { box() } else { inl(r) })  // a blank row is one empty line
    let parens = context {
      let k = calc.max(1, int(calc.round(measure(width: caption-left, name).height / pitch-single)))
      for _ in range(k) { line-block[)] }
    }
    let right = if i == 0 { "Case No. " + meta.case_number } else if i == 2 { "Judge: " + judge } else { "" }
    cells += (name, parens, line-block(left: caption-right-inset, right))
  }
  block(width: 100%, above: pitch-body, below: 0pt, breakable: false,
    grid(columns: (caption-left, caption-paren, 1fr), ..cells))
}

/// The title of the paper: bold, centered, single-spaced in a measure narrower than the page (the words wrap; no
/// breaks), a double line below the caption and a single line above the text.
#let title-block(meta) = {
  let side = (text-width - title-width) / 2
  line-block(above: pitch-body, below: pitch-single, left: side, right: side, center: true,
    text(weight: "bold", inl(meta.title)))
}

// ---------------------------------------------------------------------------
// Table of contents and table of authorities (L.R. 7.1(f); built from the headings and the `toa:` links)
// ---------------------------------------------------------------------------

#let toc-section() = {
  line-block(center: true, below: pitch-body, strong("TABLE OF CONTENTS"))
  set text(..edges(pitch-single))
  set par(leading: 0pt, spacing: 0pt)
  show outline.entry: it => block(above: 0.6em, below: 0pt, it)
  outline(title: none, depth: 3, indent: 0.5in)
}

#let toa-groups = (
  ("case", "Cases"),
  ("constitution", "Constitutional Provisions"),
  ("statute", "Statutes"),
  ("regulation", "Regulations"),
  ("rule", "Rules"),
  ("other", "Other Authorities"),
)

/// Plain text of an inline-markdown string (case names in italics lose their markup).
#let plain-text(c) = {
  if type(c) == str { c.replace(regex("[*_]"), "") } else { repr(c) }
}

#let sort-key(a) = lower(plain-text(a.at("sort", default: a.at("name", default: "") + " " + a.cite)))
  .replace(regex("[^a-z0-9 ]"), "")

#let toa-section(authorities) = {
  line-block(center: true, below: pitch-body, strong("TABLE OF AUTHORITIES"))
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("ohnd-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    set text(..edges(pitch-single))
    set par(leading: 0pt, spacing: 0pt)
    let first = true
    for (kind, title) in toa-groups {
      let members = authorities.pairs()
        .filter(p => p.last().kind == kind and hits.any(h => h.value == p.first()))
        .sorted(key: p => sort-key(p.last()))
      if members.len() == 0 { continue }
      block(above: if first { 0pt } else { 1.2em }, below: 0.4em, sticky: true, {
        strong(title)
        if first { h(1fr); strong("Page(s)") }
      })
      first = false
      for (key, a) in members {
        // Distinct page numbers, in document order.
        let pages = ()
        for h in hits.filter(h => h.value == key) {
          let p = counter(page).at(h.location()).first()
          if p not in pages { pages.push(p) }
        }
        let page-text = if pages.len() >= passim-threshold { emph[passim] } else { pages.map(str).join(", ") }
        block(breakable: false, above: 0.6em, below: 0pt, width: 100%, {
          set par(hanging-indent: 0.35in, first-line-indent: 0pt, leading: 0pt, spacing: 0pt)
          if "name" in a {
            if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }
            [, ]
          }
          inl(a.cite)
          h(0.8em)
          box(width: 1fr, repeat[.])
          h(0.3em)
          page-text
        })
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Checks the template makes on the layout itself (a failed check stops the build)
// ---------------------------------------------------------------------------

/// The memorandum (caption page through the signature block) is within the page limit for its track, and a
/// memorandum over 15 pages has the contents and summary the rule requires.
#let length-checks(meta, limit, has-contents) = context {
  let end = query(<memo-end>).first().location()
  let pages = counter(page).at(end).first()
  assert(pages <= limit, message: "ohnd-motion-brief: the memorandum runs " + str(pages) + " pages; L.R. 7.1(f) allows " + str(limit) + " for this track (a Judicial Officer's order is needed to exceed it)")
  if pages > memo-limit-plain {
    assert(has-contents, message: "ohnd-motion-brief: the memorandum runs " + str(pages) + " pages; L.R. 7.1(f) requires a table of contents and a table of authorities above 15 pages (set `contents: true`)")
    let heads = query(heading).map(h => text-of(h.body))
    assert(heads.any(h => h.contains("issue")), message: "ohnd-motion-brief: L.R. 7.1(f) requires a statement of the issue(s) to be decided above 15 pages (a heading with \"Issue\")")
    assert(heads.any(h => h.contains("summary")), message: "ohnd-motion-brief: L.R. 7.1(f) requires a summary of the argument above 15 pages (a heading with \"Summary\")")
  }
}

// ---------------------------------------------------------------------------
// Certification of track and page limit (L.R. 7.1(f)); printed after the signature block
// ---------------------------------------------------------------------------

#let certification(meta, limit) = {
  let dispositive = if "dispositive" in meta { meta.dispositive } else { true }
  let track = meta.track
  block(width: 100%, breakable: false, above: pitch-body, below: 0pt, {
    block(width: 100%, above: 0pt, below: 0pt, align(center, par(first-line-indent: 0pt,
      text(weight: "bold", "CERTIFICATION OF TRACK AND PAGE LIMIT"))))
    block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: (amount: para-indent, all: true), {
      if dispositive {
        "Pursuant to Local Rule 7.1(f), the undersigned certifies that this memorandum relates to a dispositive motion, that this case is assigned to the " + track + " track, and that this memorandum adheres to the " + str(limit) + "-page limitation set by Local Rule 7.1(f) for that track."
      } else {
        "Pursuant to Local Rule 7.1(f), the undersigned certifies that this memorandum relates to a motion other than a dispositive motion, that this case is assigned to the " + track + " track, and that this memorandum adheres to the " + str(limit) + "-page limitation set by Local Rule 7.1(f) for such motions."
      }
      if "page_limit_order" in meta {
        " The page limitation was modified by order (" + meta.page_limit_order + "), and this memorandum complies with that modification."
      }
    }))
  })
}

// ---------------------------------------------------------------------------
// Signature block (single-spaced; L.R. 10.1: name, address, telephone, fax, e-mail, Ohio Bar No.)
// ---------------------------------------------------------------------------

/// A double line below the text: "Dated:" and the date (when given) at the left of the first line,
/// "Respectfully submitted,", and after a blank line each the firm lines (when given) and the signature lines, in a
/// column from `sig-col` (docx: a tab and a hanging indent there).
#let signature-block(meta) = {
  let date = if "date" in meta and meta.date != none [Dated: #meta.date] else []
  line-block(above: pitch-body, hanging: sig-col, [#box(width: sig-col, date)Respectfully submitted,])
  let groups = if "firm" in meta.signature { (meta.signature.firm, meta.signature.lines) } else { (meta.signature.lines,) }
  for g in groups {
    for (i, l) in g.enumerate() {
      line-block(above: if i == 0 { pitch-single } else { 0pt }, left: sig-col, inl(l))
    }
  }
  [#metadata(none)<memo-end>]
}

// ---------------------------------------------------------------------------
// The memorandum
// ---------------------------------------------------------------------------

#let ohnd-motion-brief(meta, body) = {
  let has-contents = if "contents" in meta { meta.contents } else { false }
  let authorities = if "authorities" in meta { meta.authorities } else { (:) }
  let dispositive = if "dispositive" in meta { meta.dispositive } else { true }
  assert(meta.track in track-limits, message: "ohnd-motion-brief: frontmatter `track` must be one of " + track-limits.keys().join(", "))
  let limit = if dispositive { track-limits.at(meta.track) } else { memo-limit-plain }

  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: footer-descent,
    footer: context align(center, par(first-line-indent: 0pt, text(..edges(pitch-single), counter(page).display()))),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  // Only the body's paragraphs are indented (set again where the body is rendered below); the caption, headings,
  // quotations and signature are not.
  set par(first-line-indent: 0pt)
  set heading(numbering: none)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number; a footnote's line moves on with the line before it, as Word
  // and LaTeX do (footnote-widows: false).
  show: xengine.with(pitch: pitch-body, footnote-widows: false)
  // A doubled sign stays with its number ("¶¶ 28-29"), as the Word filter binds it (xengine binds one sign).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // Footnotes: the type size, single-spaced; the mark, a space, the note (Word's footnote).
  set footnote.entry(gap: 0pt, clearance: note-clearance, indent: 0pt, separator: box(height: note-rule, line(length: 30%, stroke: 0.5pt)))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    block(width: 100%, above: 0pt, below: 0pt, par[#super(num)#h(0.25em)#unloose(note.body)])
    v(note-after)
  }
  // Headings: single-spaced, bold, at the type size, kept with the paragraph after them, a single line above them.
  // Level 1 is a section of the memorandum at the margin, level 2 a point half an inch in, level 3 a sub-point an
  // inch in; the lines of each hang half an inch. The numerals are typed in the sample, as filed.
  show heading: it => line-block(above: heading-above, sticky: true, left: heading-step * (calc.min(it.level, 3) - 1),
    hanging: heading-step, text(size: type-size, weight: "bold", it.body))
  // Block quotations: single-spaced, indented on both sides, a single line above and below.
  show quote.where(block: true): it => block(width: 100%, above: quote-gap, below: quote-gap,
    pad(left: quote-inset, right: quote-inset, {
      set text(..edges(pitch-single))
      set par(first-line-indent: 0pt)
      it.body
    }))
  // Each `toa:` link marks the page where its authority is cited (the table of authorities reads the marks).
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      [#metadata(it.dest.slice(4))<toa-hit>#it.body]
    } else {
      it.body
    }
  }

  // ---- the caption page ----
  // First page: the top margin is 1 1/2 inches (L.R. 10.1), so the first page starts with the extra 1/2 inch.
  v(first-page-top - margin)
  court-title(meta)
  caption(meta)
  title-block(meta)

  // ---- contents (L.R. 7.1(f): above 15 pages; the template always prints them when asked for) ----
  if has-contents {
    pagebreak()
    toc-section()
    pagebreak()
    toa-section(authorities)
    pagebreak()
  }

  // ---- the body: everything but the last paragraph, then the last paragraph with the signature ----
  let chunks = body.trim().split(regex("\\r?\\n[ \\t]*\\r?\\n"))
  let tail = chunks.last()
  // The tail is rendered apart from the rest, so it can carry neither a footnote definition nor a footnote mark.
  assert(not tail.trim().starts-with("[^") and not tail.contains("[^"), message: "ohnd-motion-brief: the last paragraph of the body must not hold a footnote (move the note to an earlier paragraph)")
  set par(first-line-indent: (amount: para-indent, all: true))
  cmarker.render(chunks.slice(0, chunks.len() - 1).join("\n\n"), raw-typst: false, smart-punctuation: true, h1-level: 1)
  // The last paragraph is kept with the signature block, so the signature never stands alone.
  block(breakable: false, width: 100%, above: 0pt, below: 0pt, {
    cmarker.render(tail, raw-typst: false, smart-punctuation: true, h1-level: 1)
    signature-block(meta)
  })
  certification(meta, limit)
  length-checks(meta, limit, has-contents)
}
