// Delaware Supreme Court brief template (answering brief; the same layout serves the opening brief
// on the merits). Entry point: typst/main.typ, which calls del-brief(meta, body).
// Rules: ../rules.md (DEL-FORM-*, DEL-LEN-001, DEL-CERT-001), from Supreme Court Rules 10, 13, 14.
// Nothing here is case-specific: case text comes from the sample's frontmatter and markdown only.
#import "@preview/cmarker:0.1.10"

// ---- Rule 13(a)(i): typeface -----------------------------------------------------------------
// Times New Roman, 14 point, with Liberation Serif as the metric-compatible fallback (docs/FONTS.md).
#let font-family = ("Times New Roman", "Liberation Serif")
#let text-size = 14pt
#let note-size = 14pt // Rule 13(a)(i): footnotes are in the same 14-point face

// ---- Rule 13(a)(ii): double spacing, single for quotations and footnotes ---------------------
// Typst leading is the gap between lines. On this face the natural line height is 0.655 em, so
// 1.645 em gives a 32.2 pt baseline pitch (Word "double" at 14 pt) and 0.5 em a 16.2 pt single pitch.
#let double = 1.645em
#let single = 0.5em
#let indent = 0.5in
#let margin = 1in // Rule 13(a)(ii): top, bottom and side margins not less than 1 inch

// ---- Rule 14(d)(i): type-volume limits -------------------------------------------------------
#let word-limit = 5500 // Rule 14(d)(i): reply brief
#let word-limit-cross = 10000 // Rule 14(d)(i): appellant reply on cross-appeal

// ---- Rule 14(b): required sections, in the rule's order (matched against H1 titles) ----------
#let required-sections = (
  "conclusion",
)

#let kinds = (
  (key: "case", title: "CASES"),
  (key: "statute", title: "STATUTES"),
  (key: "constitution", title: "CONSTITUTIONAL PROVISIONS"),
  (key: "rule", title: "RULES"),
  (key: "other", title: "OTHER AUTHORITIES"),
)

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("del-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// ---- Word count (Rule 14(d)(i)): every word of the brief text except the cover, the tables,
// the signature block and the certificates. Footnote labels and authority links are not words.
#let count-words(s) = s.split(regex("\\s+")).filter(w => w.find(regex("[A-Za-z0-9]")) != none).len()
#let body-words(md) = count-words(
  md.replace(regex("\\[\\^[^\\]]*\\]"), " ").replace(regex("\\(toa:[^)]*\\)"), " "),
)

// One entry per H1 section of a markdown string: (title, text including the heading).
#let sections(md) = {
  let starts = md.matches(regex("(?m)^# ")).map(m => m.start)
  starts
    .enumerate()
    .map(((i, s)) => {
      let e = if i + 1 < starts.len() { starts.at(i + 1) } else { md.len() }
      let chunk = md.slice(s, e)
      (title: chunk.slice(2).split("\n").first().trim(), text: chunk)
    })
}

#let check-order(md) = {
  let titles = sections(md).map(s => lower(s.title))
  let pos = 0
  for pat in required-sections {
    let rest = titles.slice(pos)
    let k = rest.position(t => t.find(regex(pat)) != none)
    assert(
      k != none,
      message: "Rule 14(b): the brief needs a section matching `" + pat + "`, after the sections before it in the rule's order",
    )
    pos += k + 1
  }
}

// "4358" -> "4,358"
#let group-digits(n) = {
  let s = str(n)
  let out = ""
  for (i, c) in s.clusters().enumerate() {
    if i > 0 and calc.rem(s.len() - i, 3) == 0 { out += "," }
    out += c
  }
  out
}

// Page number in the footer; cover and front matter in roman numerals, body in Arabic (Rule 14(b)).
#let folio = context {
  let n = here().page-numbering()
  if n != none { align(center, counter(page).display(n)) }
}

#let lines-of(list, italic: false) = for l in list {
  block(width: 100%, spacing: 0pt, if italic { emph[#l] } else { [#l] })
}

#let front-title(t) = align(center, block(above: 0pt, below: 1.2em, strong(t)))

// ---- Cover (Rule 14(a)): court, caption and number, trial court, title, counsel, date ---------
#let caption-side(side) = {
  lines-of(side.names)
  block(width: 100%, align(right, [#side.designation]))
}

#let cover(meta) = {
  set par(leading: single, spacing: single, first-line-indent: 0pt, justify: false)
  align(center, strong("IN THE SUPREME COURT OF THE STATE OF DELAWARE"))
  v(0.3in)
  grid(
    columns: (3.4in, 1fr),
    gutter: 0.25in,
    [
      #for (i, side) in meta.caption.enumerate() {
        if i > 0 { block(width: 100%, [v.]) }
        caption-side(side)
      }
    ],
    [
      #v(0.8in)
      No. #meta.case_number
      #v(1.2em)
      #if "trial_court" in meta [On Appeal from #meta.trial_court]
      #if "lower_court_case" in meta [
        #v(0.6em)
        #meta.lower_court_case
      ]
    ],
  )
  v(0.3in)
  align(center, block(width: 90%, strong(meta.brief_title)))
  v(0.3in)
  align(left, [Dated: #meta.date])
  v(0.6em)
  grid(
    columns: (1fr, 1fr),
    gutter: 0.3in,
    ..meta.counsel.map(g => {
      lines-of(g.names)
      lines-of(g.lines, italic: false)
    }),
  )
}

// ---- Table of citations (Rule 14(b)(ii)) ---------------------------------------------------------
// A link whose target is `toa:KEY` in the body is recorded with its page; the table is built from
// those records. Every other link prints its text only.
#let authority-line(a) = if a.kind == "case" {
  [#emph(a.name), #a.cite]
} else if "cite" in a {
  [#a.name, #a.cite]
} else {
  [#a.name]
}

#let table-of-authorities(auths) = context {
  let hits = query(<toa-hit>)
  for k in kinds {
    let rows = auths.pairs().filter(((key, a)) => a.kind == k.key)
    if rows.len() == 0 { continue }
    rows = rows.sorted(key: ((key, a)) => lower(a.at("sort", default: if "name" in a { a.name } else { a.cite })))
    block(above: 1.1em, below: 0.5em, strong(k.title))
    for (key, a) in rows {
      let pages = hits.filter(h => h.value.key == key).map(h => counter(page).at(h.location()).first())
      let pages = pages.dedup().sorted()
      let shown = if pages.len() >= 7 { "passim" } else { pages.map(str).join(", ") }
      block(
        above: 0pt,
        below: 0.5em,
        grid(
          columns: (1fr, auto),
          gutter: 1em,
          par(leading: single, first-line-indent: 0pt, hanging-indent: 0.4in)[#authority-line(a)],
          shown,
        ),
      )
    }
  }
}

// ---- Closing: prayer, signature blocks, certificates -----------------------------------------------
#let signature-blocks(meta) = {
  set par(leading: single, spacing: single, first-line-indent: 0pt)
  grid(
    columns: range(meta.signature.len()).map(_ => 1fr),
    gutter: 0.3in,
    ..meta.signature.map(g => lines-of(g.lines)),
  )
}

#let closing(meta) = block(breakable: false)[
  #set par(leading: double, spacing: double, first-line-indent: 0pt)
  Respectfully submitted,
  #v(0.4em)
  #signature-blocks(meta)
]

#let certificate-of-compliance(meta, words) = [
  #front-title[CERTIFICATE OF COMPLIANCE]
  #set par(leading: double, spacing: double, first-line-indent: indent)
  I certify that this brief complies with the typeface requirement of Supreme Court Rule 13(a)(i) and the type-volume limitation of Supreme Court Rule 14(d)(i). The brief is set in Times New Roman 14-point type. It contains #group-digits(words) words, counted from the first page of the argument through the conclusion, excluding the cover, the table of contents, the table of citations and the signature block.
  #v(1.2em)
  #set par(leading: single, spacing: single, first-line-indent: 0pt)
  #align(right, block(width: 3in, lines-of(meta.signature.at(0).lines.slice(0, 1))))
]

#let certificate-of-service(meta) = [
  #front-title[CERTIFICATE OF SERVICE]
  #set par(leading: double, spacing: double, first-line-indent: indent)
  I certify that on #meta.service.date I caused a true and correct copy of the foregoing to be served on the following counsel of record by #meta.service.method:
  #v(1.2em)
  #set par(leading: single, spacing: single, first-line-indent: 0pt)
  #grid(
    columns: range(meta.service.recipients.len()).map(_ => 1fr),
    gutter: 0.3in,
    ..meta.service.recipients.map(g => {
      lines-of(g.names)
      lines-of(g.lines)
    }),
  )
  #v(1.4em)
  #align(right, block(width: 3in, lines-of(meta.signature.at(0).lines.slice(0, 1))))
]

// ---- Body styling (applied with `#show: style-body`) ------------------------------------------------
#let style-body(it) = {
  set text(font: font-family, size: text-size, lang: "en")
  set par(justify: false, leading: double, spacing: double, first-line-indent: indent)
  show heading.where(level: 1): h => block(
    above: 1.2em,
    below: 1em,
    width: 100%,
    sticky: true,
    align(center, strong(h.body)),
  )
  show heading.where(level: 2): h => block(above: 1.2em, below: 0.8em, sticky: true, {
    set par(leading: single, first-line-indent: 0pt, hanging-indent: 0.5in)
    strong(h.body)
  })
  show heading.where(level: 3): h => block(above: 1.1em, below: 0.6em, sticky: true, {
    set par(leading: single, first-line-indent: 0pt, hanging-indent: 0.5in)
    pad(left: 0.5in, strong(h.body))
  })
  show heading.where(level: 4): h => block(above: 1em, below: 0.6em, sticky: true, {
    set par(leading: single, first-line-indent: 0pt, hanging-indent: 0.5in)
    pad(left: 1in, strong(emph(h.body)))
  })
  show footnote.entry: set text(size: note-size)
  show footnote.entry: set par(leading: single, spacing: single, justify: false, first-line-indent: 0pt)
  set footnote.entry(separator: line(length: 1.5in, stroke: 0.5pt))
  show quote.where(block: true): q => block(above: 1em, below: 1em, pad(
    left: 1in,
    right: 1in,
    {
      set par(leading: single, spacing: single, first-line-indent: 0pt)
      q.body
    },
  ))
  show link: l => {
    if type(l.dest) == str and l.dest.starts-with("toa:") {
      [#l.body#metadata((key: l.dest.slice(4)))<toa-hit>]
    } else if type(l.dest) == str {
      l.body
    } else {
      l
    }
  }
  it
}

// ---- Entry -----------------------------------------------------------------------------------------
#let del-brief(meta, body) = {
  let cross = meta.at("cross_appeal", default: false)
  let limit = if cross { word-limit-cross } else { word-limit }
  let words = body-words(body)
  assert(words <= limit, message: "word count " + str(words) + " exceeds the " + str(limit) + "-word limit of Rule 14(d)(i)")
  check-order(body)
  set document(title: meta.case_number + " " + meta.brief_title)
  set page(paper: "us-letter", margin: margin, footer-descent: 0.4in)
  set text(font: font-family, size: text-size, lang: "en")

  // Cover, then table of contents and table of citations in roman numerals; the body restarts at 1.
  page(numbering: "i", footer: folio)[
    #show: style-body
    #cover(meta)
  ]
  page(numbering: "i", footer: folio)[
    #show: style-body
    #front-title[TABLE OF CONTENTS]
    #set par(leading: single, spacing: 0.9em, first-line-indent: 0pt)
    #outline(title: none, depth: 4, indent: 0.5in)
  ]
  page(numbering: "i", footer: folio)[
    #show: style-body
    #front-title[TABLE OF CITATIONS]
    #set par(leading: single, spacing: 0.9em, first-line-indent: 0pt)
    #table-of-authorities(meta.at("authorities", default: (:)))
  ]
  page(numbering: "1", footer: folio)[
    #show: style-body
    #counter(page).update(1)
    #cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1)
    #closing(meta)
  ]
  page(numbering: "1", footer: folio)[
    #show: style-body
    #certificate-of-compliance(meta, words)
  ]
  if "service" in meta {
    page(numbering: "1", footer: folio)[
      #show: style-body
      #certificate-of-service(meta)
    ]
  }
}
