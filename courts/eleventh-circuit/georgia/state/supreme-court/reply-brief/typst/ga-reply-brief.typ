// Georgia Supreme Court brief template (reply brief, Ga. Sup. Ct. R. 16-22). Entry point:
// typst/main.typ, which calls ga-brief(meta, body) with the sample's frontmatter and markdown.
// Every number is a named constant below and traces to a rule in ../README.md. Nothing here is
// case-specific: case text comes from the sample's frontmatter only. The answering, opening and reply briefs
// share this code (one copy per folder); docx/ga-brief.lua writes the same layout in Word.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---- Rule 16: typography -------------------------------------------------------------------
// Rule 16(1) names the Century family; the rule sizes the body by Century Schoolbook (Rule 16(2)).
// TeX Gyre Schola is the vendored Century Schoolbook substitute (docs/FONTS.md): proportional serif.
#let face = "TeX Gyre Schola"
#let body-size = 13pt // Rule 16(2): body text and headings no smaller than 13-pt Century Schoolbook
#let note-size = 11pt // Rule 16(2): footnotes no smaller than 11-pt Century Schoolbook
#let margin = 1in // Rule 16(5), Rule 17(2): no margin smaller than one inch
#let indent = 0.5in // first-line indent of a paragraph; a list's label box; a quotation's margins

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a
// box of its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger
// of the space below the one and above the other (Word's exact line spacing). Rule 16(4): line spacing from 1.2
// times to double; block quotations, headings, captions and footnotes may be single-spaced.
#let pitch-body = 31.2pt // double spacing (2 x 1.2 x 13 pt): the text, the closing
#let pitch-single = 15.6pt // 1.2 x 13 pt, the rule's floor: cover, headings, quotations, tables, signature
#let pitch-note = 13.2pt // 1.2 x 11 pt: footnotes
#let half = 7.8pt // half a single line: around headings and quotations, between table rows
#let note-gap = 6.6pt // between two footnotes (half a footnote line)
#let note-clearance = 8.53pt // with note-gap, the last text line to the first footnote: LibreOffice's separator
#let toc-col = 36pt // the contents' page numbers keep this column to themselves
#let toa-col = 72pt // the authorities' page lists; a longer list widens its own row's column
#let toa-hang = 0.4in // a wrapped authority hangs this far
#let passim-at = 7 // an authority cited on this many pages or more reads "passim"
#let footer-descent = 0.4in // the page number's line starts this far into the bottom margin

// ---- Court constants (not case text) ----------------------------------------------------------
#let court-lines = ("IN THE SUPREME COURT", "STATE OF GEORGIA")
#let closing-sentence = "This submission does not exceed the word-count limit imposed by Rule 20." // Rule 20(7)
#let kinds = (
  (key: "case", title: "CASES"),
  (key: "statute", title: "STATUTES"),
  (key: "constitution", title: "CONSTITUTIONAL PROVISIONS"),
  (key: "rule", title: "RULES"),
  (key: "other", title: "OTHER AUTHORITIES"),
)

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ga-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Put an invisible tag right after the first word of `c`, keeping emphasis around it: a citation's page is
/// the page it starts on (the docx engine finds a citation by its first words).
#let tag-after-first-word(c, tag) = {
  if type(c) == str or c.func() == text {
    let t = if type(c) == str { c } else { c.text }
    let m = t.match(regex("^\\s*\\S+"))
    if m == none { return (c, false) }
    return ([#m.text#tag#t.slice(m.end)], true)
  }
  if c.func() == emph { let r = tag-after-first-word(c.body, tag); return (emph(r.first()), r.last()) }
  if c.func() == strong { let r = tag-after-first-word(c.body, tag); return (strong(r.first()), r.last()) }
  if c.func() == [].func() {
    let out = ()
    let placed = false
    for ch in c.children {
      if placed { out.push(ch) } else {
        let r = tag-after-first-word(ch, tag)
        out.push(r.first())
        placed = r.last()
      }
    }
    return (out.join(), placed)
  }
  (c, false)
}

// Page number in the footer, centered in a single line; none on the cover. Rule 21: Arabic numerals for
// counted pages.
#let folio = context {
  let n = here().page-numbering()
  if n != none { align(center, text(..edges(pitch-single), counter(page).display(n))) }
}

// One single-spaced line (it may wrap) per entry: the lines of an address block, a caption or a signature.
#let line-of(above, body) = block(above: above, below: 0pt, width: 100%, body)
#let lines-of(list, italic: false) = for l in list { line-of(0pt, if italic { emph(l) } else { l }) }

// N columns of equal width, 0.3 in apart, top-aligned: counsel, signatures, the parties served.
#let columns-of(cells, above) = block(above: above, below: 0pt, width: 100%, grid(
  columns: range(cells.len()).map(_ => 1fr),
  column-gutter: 0.3in,
  ..cells,
))

#let front-title(t) = block(above: 0pt, below: pitch-single, width: 100%, sticky: true,
  align(center, text(..edges(pitch-single), strong(t))))

// ---- Cover ------------------------------------------------------------------------------------
#let caption-side(side) = {
  lines-of(side.names)
  line-of(0pt, pad(left: indent, side.designation))
}

#let cover(meta) = {
  set par(first-line-indent: 0pt)
  set text(..edges(pitch-single))
  line-of(0pt, align(center, strong(court-lines.at(0))))
  line-of(0pt, align(center, strong(court-lines.at(1))))
  block(above: 2 * pitch-single, below: 0pt, width: 100%, grid(
    columns: (1fr, 1fr),
    column-gutter: 0.4in,
    {
      caption-side(meta.caption.at(0))
      for side in meta.caption.slice(1) {
        line-of(pitch-single, pad(left: indent)[v.])
        block(above: pitch-single, below: 0pt, caption-side(side))
      }
    },
    {
      line-of(0pt, [Case No. #meta.case_number])
      if "lower_court_case" in meta { line-of(pitch-single, [Lower Court Case No. #meta.lower_court_case]) }
    },
  ))
  line-of(2 * pitch-single, align(center, strong(meta.brief_title)))
  columns-of(meta.counsel.map(g => {
    lines-of(g.names)
    lines-of(g.lines, italic: true)
  }), 3 * pitch-single)
}

// ---- Table of contents (Rule 19(1)(a)) ------------------------------------------------------------
// Levels 1 and 2, a blank single line between rows; level 2 a half inch in, its wrapped lines with it.
#let table-of-contents() = context {
  set text(..edges(pitch-single))
  front-title[TABLE OF CONTENTS]
  for hd in query(heading.where(outlined: true)) {
    if hd.level <= 2 {
      let ind = (hd.level - 1) * indent
      let loc = hd.location()
      let pg = numbering(loc.page-numbering(), ..counter(page).at(loc))
      listing-row(loc, [#h(ind)#hd.body], pg, toc-col, ind, pitch-single)
    }
  }
}

// ---- Table of authorities (Rule 19(1)(a)) ----------------------------------------------------
// A link whose target is `toa:KEY` in the body is recorded with the page it starts on; the TOA is built from
// those records. Every other link prints its text only (Rule 17(3): no links to other documents).
#let authority-line(a) = if a.kind == "case" {
  [#emph(a.name), #a.cite]
} else if "cite" in a {
  [#a.name, #a.cite]
} else {
  [#a.name]
}

#let table-of-authorities(auths) = context {
  set text(..edges(pitch-single))
  front-title[TABLE OF AUTHORITIES]
  let hits = query(<toa-hit>)
  for k in kinds {
    let rows = auths.pairs().filter(((key, a)) => a.kind == k.key)
    rows = rows.filter(((key, a)) => hits.any(h => h.value == key))
    if rows.len() == 0 { continue }
    rows = rows.sorted(key: ((key, a)) => lower(a.at("sort", default: if "name" in a { a.name } else { a.cite })))
    block(above: pitch-single, below: half, sticky: true, strong(k.title))
    for (key, a) in rows {
      let pages = hits.filter(h => h.value == key).map(h => counter(page).at(h.location()).first())
      let pages = pages.dedup().sorted()
      let shown = if pages.len() >= passim-at { "passim" } else { pages.map(str).join(", ") }
      listing-row(none, authority-line(a), shown, calc.max(toa-col, measure(shown).width), toa-hang, half)
    }
  }
}

// ---- Closing: word-count statement, signature blocks, certificate of service ----------------
#let signature-blocks(meta, above) = {
  set text(..edges(pitch-single))
  columns-of(meta.signature.map(g => lines-of(g.lines)), above)
}

// Rule 20(7): the statement immediately above the signature block; the closing is never split.
#let closing(meta) = block(breakable: false, above: 0pt, below: 0pt, {
  set par(first-line-indent: 0pt)
  par(closing-sentence)
  par[Respectfully submitted, this #meta.date.]
  signature-blocks(meta, pitch-single)
})

#let certificate-of-service(meta) = {
  set par(first-line-indent: 0pt)
  front-title[CERTIFICATE OF SERVICE]
  // Rule 14: name the manner of service in the certificate; e-mail needs the prior-agreement certification.
  if meta.service.at("email", default: false) {
    par[I certify that there is a prior agreement with counsel to allow documents in a PDF format sent via e-mail to suffice for service under Supreme Court Rule 14. I further certify that I have on this day served true and correct copies of the foregoing upon the following counsel of record via e-mail:]
  } else {
    par[I certify that I have on this day served true and correct copies of the foregoing upon the following counsel of record by #meta.service.method:]
  }
  {
    set text(..edges(pitch-single))
    columns-of(meta.service.recipients.map(g => {
      lines-of(g.names)
      lines-of(g.lines)
    }), pitch-single)
  }
  block(above: pitch-single, below: 0pt, breakable: false, {
    par[Respectfully submitted, this #meta.date.]
    signature-blocks(meta, pitch-single)
  })
}

// ---- Entry -------------------------------------------------------------------------------------
#let ga-brief(meta, body) = {
  let auths = meta.at("authorities", default: (:))
  set document(title: meta.case_number + " " + meta.brief_title)
  set page(paper: "us-letter", margin: margin, footer-descent: footer-descent, footer: folio)
  set text(font: face, size: body-size, lang: "en", fallback: false)
  set par(first-line-indent: indent)
  // The cross-engine layout model: first fit, ragged right (Rule 16(3): left-aligned), no kerning, ligatures or
  // hyphenation, line boxes of the body pitch, footnote marks at 58 %, list labels in a half-inch box.
  show: xengine.with(pitch: pitch-body, list-indent: indent)

  // Headings: body size (Rule 16(2)), bold, single-spaced (Rule 16(4)); level 1 centered, level 3 italic too.
  show heading: set text(size: body-size, ..edges(pitch-single))
  show heading: set par(first-line-indent: 0pt)
  show heading.where(level: 1): h => block(above: pitch-single, below: half, width: 100%, sticky: true,
    align(center, strong(h.body)))
  show heading.where(level: 2): h => block(above: half, below: 0pt, width: 100%, sticky: true, strong(h.body))
  show heading.where(level: 3): h => block(above: half, below: 0pt, width: 100%, sticky: true,
    strong(emph(h.body)))
  // Block quotations: single-spaced (Rule 16(4)), a half inch in on both sides, half a single line around.
  show quote.where(block: true): q => block(above: half, below: half, pad(left: indent, right: indent, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, spacing: half)
    q.body
  }))
  // Footnotes: 11 pt (Rule 16(2)) single-spaced; the mark, a space, the note; a note kept whole on its page (Word).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt,
    separator: line(length: 2in, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: note-size, ..edges(pitch-note))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt, spacing: note-gap)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    block(breakable: false, [#super(num)#h(0.25em)#note.body])
  }
  show link: l => {
    if type(l.dest) == str and l.dest.starts-with("toa:") {
      let key = l.dest.slice(4)
      if key not in auths { panic("ga-brief: link `toa:" + key + "` has no entry under `authorities:`") }
      tag-after-first-word(l.body, [#metadata(key)<toa-hit>]).first()
    } else if type(l.dest) == str {
      l.body
    } else {
      l
    }
  }

  // The cover has no folio; it counts as page i, so the front matter starts at ii; the body restarts at 1 in
  // Arabic numerals (Rule 21); the certificate of service starts a page of its own.
  set page(numbering: none)
  cover(meta)
  pagebreak()
  set page(numbering: "i")
  table-of-contents()
  if auths.len() > 0 {
    pagebreak()
    table-of-authorities(auths)
  }
  pagebreak()
  set page(numbering: "1")
  counter(page).update(1)
  cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1)
  closing(meta)
  if "service" in meta {
    pagebreak()
    certificate-of-service(meta)
  }
}
