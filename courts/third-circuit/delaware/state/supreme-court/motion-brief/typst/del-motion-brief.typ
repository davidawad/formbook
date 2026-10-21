// Delaware Supreme Court motion template (a motion, an answer to a motion, or a reply; the State's
// answer and motion to dismiss in the exemplar uses the same form). Entry point: typst/main.typ,
// which calls del-motion(meta, body).
// Rules: ../rules.md (DEL-FORM-201..204, DEL-LEN-201, DEL-CERT-201..202), from Supreme Court Rules
// 10, 13(a)-(b), 30(a)-(d). Nothing here is case-specific: case text comes from the sample's
// frontmatter and markdown only.
#import "@preview/cmarker:0.1.10"

// ---- Rule 13(a)(i): typeface -----------------------------------------------------------------
// Times New Roman, 14 point, with Liberation Serif as the metric-compatible fallback (docs/FONTS.md).
#let font-family = ("Times New Roman", "Liberation Serif")
#let text-size = 14pt
#let note-size = 14pt // Rule 13(a)(i): footnotes are in the same 14-point face

// ---- Rule 13(a)(ii): double spacing, single for quotations and footnotes ---------------------
// On this face the natural line height is 0.655 em, so 1.645 em gives a 32.2 pt baseline pitch
// (Word "double" at 14 pt) and 0.5 em a 16.2 pt single pitch.
#let double = 1.645em
#let single = 0.5em
#let indent = 0.5in
#let margin = 1in // Rule 13(a)(ii): top, bottom and side margins not less than 1 inch

// ---- Rule 30(d): length of a motion, answer or reply ------------------------------------------
#let word-limit = 1200

// ---- Input helpers ---------------------------------------------------------------------------------
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("del-motion: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// ---- Word count (Rule 30(d)): every word of the text except the caption, the signature block and
// the eFile footer. Footnote labels and authority links are not words; footnotes are counted.
#let count-words(s) = s.split(regex("\\s+")).filter(w => w.find(regex("[A-Za-z0-9]")) != none).len()
#let body-words(md) = count-words(
  md.replace(regex("\\[\\^[^\\]]*\\]"), " ").replace(regex("\\(toa:[^)]*\\)"), " "),
)

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

#let folio = context {
  let n = here().page-numbering()
  if n != none { align(center, counter(page).display(n)) }
}

#let lines-of(list, italic: false) = for l in list {
  block(width: 100%, spacing: 0pt, if italic { emph[#l] } else { [#l] })
}

#let front-title(t) = align(center, block(above: 0pt, below: 1.2em, strong(t)))

// ---- Caption (Rule 13(b)): this Court, the caption of the case, the file number ----------------
// The caption lines are the frontmatter's `caption` list, set with a ")" column. The file number
// sits on the middle line of the caption.
#let caption-block(meta, title: true) = {
  set par(leading: single, spacing: single, first-line-indent: 0pt, justify: false)
  align(center, [IN THE SUPREME COURT OF THE STATE OF DELAWARE])
  v(0.3in)
  let mid = calc.floor(meta.caption.len() / 2)
  grid(
    columns: (3.6in, 0.35in, 1fr),
    row-gutter: single,
    ..meta.caption
      .enumerate()
      .map(((i, line)) => (
        [#line],
        [)],
        if i == mid [No. #meta.case_number] else [],
      ))
      .flatten(),
  )
  v(0.3in)
  if title {
    align(center, block(width: 100%, strong(underline(meta.brief_title))))
    v(0.3in)
  }
}

// ---- Closing: signature block with the date (Rule 13(b), 10(b)) ---------------------------------
#let closing(meta) = block(breakable: false)[
  #set par(leading: single, spacing: single, first-line-indent: 0pt)
  #v(double)
  #grid(
    columns: (1fr, 3.2in),
    gutter: 0.3in,
    [Dated: #meta.date],
    lines-of(meta.signature.lines),
  )
]

// ---- Certificate of compliance (Rule 13(a)(i), 30(d)): typeface and word count -------------------
#let certificate-of-compliance(meta, words) = [
  #caption-block(meta, title: false)
  #front-title[CERTIFICATE OF COMPLIANCE WITH TYPEFACE REQUIREMENT AND TYPE-VOLUME LIMITATION]
  #set par(leading: double, spacing: double, first-line-indent: indent)
  This motion complies with the typeface requirement of Supreme Court Rule 13(a)(i) because it has been prepared in Times New Roman 14-point typeface. It contains #group-digits(words) words, counted from the first line of the text through the conclusion, excluding the caption, the signature block and the eFile footer.
  #if words <= word-limit [
    This motion complies with the type-volume limitation of Supreme Court Rule 30(d).
  ]
  #v(1.2em)
  #set par(leading: single, spacing: single, first-line-indent: 0pt)
  #align(right, block(width: 3.2in, lines-of(meta.signature.lines.slice(0, 1))))
]

// ---- Certificate of service (Rule 10(c)); printed when the frontmatter has a `service` entry -------
#let certificate-of-service(meta) = [
  #caption-block(meta, title: false)
  #front-title[CERTIFICATE OF SERVICE]
  #set par(leading: double, spacing: double, first-line-indent: indent)
  I certify that on #meta.service.date I caused a true and correct copy of the foregoing to be served on the following counsel of record by #meta.service.method:
  #v(1.2em)
  #set par(leading: single, spacing: single, first-line-indent: 0pt)
  #grid(
    columns: range(meta.service.recipients.len()).map(_ => 1fr),
    gutter: 0.3in,
    ..meta.service.recipients.map(g => lines-of(g.lines)),
  )
  #v(1.4em)
  #align(right, block(width: 3.2in, lines-of(meta.signature.lines.slice(0, 1))))
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
  show footnote.entry: set text(size: note-size)
  show footnote.entry: set par(leading: single, spacing: single, justify: false, first-line-indent: 0pt)
  set footnote.entry(separator: line(length: 1.5in, stroke: 0.5pt))
  // The single-spaced last line of the notes keeps its descent inside the bottom margin (Rule 13(a)(ii)).
  show footnote.entry: it => pad(bottom: 0.3em, it)
  show quote.where(block: true): q => block(above: 1em, below: 1em, pad(
    left: 1in,
    right: 1in,
    {
      set par(leading: single, spacing: single, first-line-indent: 0pt)
      q.body
    },
  ))
  it
}

// ---- Entry -----------------------------------------------------------------------------------------
#let del-motion(meta, body) = {
  let words = body-words(body)
  set document(title: meta.case_number + " " + meta.brief_title)
  set page(paper: "us-letter", margin: margin, footer-descent: 0.4in, numbering: "1", footer: folio)
  set text(font: font-family, size: text-size, lang: "en")
  show: style-body
  caption-block(meta)
  cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1)
  closing(meta)
  pagebreak(weak: true)
  certificate-of-compliance(meta, words)
  if "service" in meta {
    pagebreak(weak: true)
    certificate-of-service(meta)
  }
}
