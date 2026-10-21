// Michigan Supreme Court (mich): a motion and its supporting memorandum filed in the Supreme Court
// (MCR 7.311). The same template serves the other Supreme Court papers in the sibling doc folders;
// each folder carries its own copy so it can be read on its own.
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next to it
// (Michigan Court Rules of 1985, chapters 1 and 7, official courts.michigan.gov HTML; see ../../rules.md).
// No case-specific text, no coordinates measured off any filed paper, no forced line breaks. The
// markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the input.
//
// Layout switches read from the frontmatter (all optional):
//   toc: false          no contents page (a motion has none, MCR 7.311 does not require one)
//   cover_page: false   the cover runs on into the body on the same page (the exemplar's form)
//   caption_right       lines in the right column of the caption (for example, a response date)
//   lead                lines printed at the left above the signatures (for example, the Attorney General)
//   signatures          two or more signature blocks, set side by side (a joint motion)
//   closing             "Respectfully submitted," and similar

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

// No Michigan rule names a face. Times New Roman is declared first (repo standard); Liberation Serif
// is its metric-compatible fallback, the face embedded where Times New Roman is not installed (docs/FONTS.md).
#let font-family = ("Times New Roman", "Liberation Serif")
#let type-size = 12pt                    // MCR 7.212(B)(5): 12-point font (MCR 1.109(D)(1)(a): 12 or 13 point body text).
#let page-margin = 1in                   // MCR 7.212(B)(5): at least one-inch page margins.
// Leading measured on this font at 12 pt: a single line is 13.86 pt (leading 0.5 em adds 6 pt to the
// 7.86 pt baseline pitch of the Chapter 7 template). MCR 7.212(B)(5): text is 1.5-line spaced.
#let onehalf-leading = 1.08em            // 1.5 lines = 20.8 pt pitch.
#let single-leading = 0.5em              // single line = 13.86 pt: quotations, captions and footnotes (MCR 7.212(B)(5)).
#let para-indent = 0.5in
#let sig-indent = 3.2in                  // signature block sits right of centre (style; the exemplar does the same).
#let toc-depth = 2                       // MCR 7.212(C)(2): the contents list the headings and principal points of argument.
#let caption-left = 3.7in                // the party column of the caption; the case-number column takes the rest.
#let caption-gutter = 0.25in

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mich-petition-for-rehearing: the input must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("mich-petition-for-rehearing: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Caption, party column. Each side: names (lines), designation (optional), and the word that joins
/// it to the side above (join: "v" by default; "and," for a joined defendant).
#let caption-parties(meta) = [
  #set par(leading: single-leading, first-line-indent: 0pt)
  #for (i, side) in need(meta, "caption").enumerate() [
    #if i > 0 [ #side.at("join", default: "v") \ ]
    #for n in side.names [ #inl(n) \ ]
    #if "designation" in side [ #inl(side.designation) \ ]
    #v(0.1in)
  ]
]

/// Caption, case-number column: the MSC blank (MCR 7.312(C); the number is not printed here),
/// the lower-court numbers, and any caption_right lines.
#let caption-numbers(meta) = [
  #set par(leading: single-leading, first-line-indent: 0pt)
  MSC No. #box(width: 1.6in, repeat[\_]) \
  #if "coa_no" in meta [ #meta.at("coa_label", default: "COA No.") #inl(meta.coa_no) \ ]
  #if "trial_court_no" in meta [ #meta.at("trial_court_label", default: "Trial Ct No.") #inl(meta.trial_court_no) \ ]
  #v(0.2in)
  #for t in meta.at("caption_right", default: ()) [ #inl(t) #v(0.1in) ]
]

/// Counsel block: names, then the firm, address and contact lines.
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for n in g.names [ #inl(n) \ ]
  for l in g.at("lines", default: ()) [ #inl(l) \ ]
}

/// One signature block: firm lines, then "/s/" and the typed name, then the lines (bar number, address).
#let sig-column(sig) = [
  #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
  #for l in sig.at("firm", default: ()) [ #inl(l) \ ]
  #if "signer" in sig [ #v(0.6em) #underline[/s/ #inl(sig.signer)] \ ]
  #for l in sig.at("lines", default: ()) [ #inl(l) \ ]
]

/// Closing, signatures and date, after the request for relief.
#let signature-section(meta) = block(width: 100%, breakable: false)[
  #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
  #v(0.3in)
  #if "closing" in meta [ #inl(meta.closing) \ #v(0.3in) ]
  #if "lead" in meta [ #for l in meta.lead [ #inl(l) \ ] #v(0.3in) ]
  #if "date" in meta [ #inl(meta.date) \ #v(0.4em) ]
  #if "signatures" in meta [
    #grid(columns: (1fr, 1fr), gutter: 0.3in, ..meta.signatures.map(s => sig-column(s)))
  ] else [
    #pad(left: sig-indent)[#sig-column(need(meta, "signature"))]
  ]
]

// Table of authorities, for a paper that carries one (meta.authorities). Each entry carries `find`:
// a string that appears in every citation of the authority in the body. A show rule on that string
// drops a marker after each occurrence; the table lists the pages of the markers.
#let toa-marker(key) = [#metadata(key)<mich-toa>]

#let mark-authorities(meta, content) = {
  let out = content
  for group in meta.at("authorities", default: ()) {
    for e in group.entries {
      if "find" in e {
        let key = e.find
        out = {
          show key: it => it + toa-marker(key)
          out
        }
      }
    }
  }
  out
}

#let toa-pages(key) = context {
  let pages = query(<mich-toa>)
    .filter(m => m.value == key)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
  if pages.len() == 0 { [--] } else { pages.map(str).join(", ") }
}

#let authorities-table(meta) = {
  align(center, strong[INDEX OF AUTHORITIES])
  v(0.4em)
  set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in, justify: false)
  for group in meta.authorities {
    block(above: 1.1em, below: 0.7em, sticky: true, strong(group.heading))
    for e in group.entries {
      block(above: 0.7em, below: 0.7em, breakable: false)[
        #inl(e.cite) #box(width: 1fr, repeat[.#h(2pt)]) #h(4pt) #if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") }
      ]
    }
  }
}

// ---------------------------------------------------------------------------
// Sections
// ---------------------------------------------------------------------------

/// The cover (MCR 7.312(C) general form, as the exemplar sets it out).
#let make-cover(meta) = [
  #set par(leading: single-leading, first-line-indent: 0pt)
  #align(center)[
    #strong[#upper(need(meta, "court_line"))]
    #v(0.1in)
    #strong[IN THE SUPREME COURT]
    #v(0.1in)
    #if "proceeding" in meta [ #inl(meta.proceeding) \ ]
    #if "trial_court" in meta [ #inl(meta.trial_court) \ ]
    #if "judge" in meta [ #inl(meta.judge) ]
  ]
  #v(0.2in)
  #grid(columns: (caption-left, 1fr), gutter: caption-gutter, caption-parties(meta), caption-numbers(meta))
  #v(0.2in)
  #align(center)[#strong(upper(inl(need(meta, "brief_title"))))]
  #v(0.1in)
  #if "oral_argument" in meta [ #align(center)[#strong[ORAL ARGUMENT #upper(meta.oral_argument)]] ]
  #if "counsel" in meta [
    #v(0.3in)
    #grid(columns: (1fr, 1fr), gutter: 0.3in, ..meta.counsel.map(g => counsel-group(g)))
  ]
]

/// Contents (only when toc is set) and index of authorities (only when the paper has one).
#let front-section(meta) = [
  #set par(leading: single-leading, first-line-indent: 0pt)
  #if meta.at("toc", default: true) [
    #align(center, strong[TABLE OF CONTENTS])
    #v(0.3em)
    #show outline.entry: it => block(above: 0.6em, below: 0.6em, it)
    #outline(title: none, depth: toc-depth, indent: 1.5em)
  ]
  #if "authorities" in meta [
    #if meta.at("toc", default: true) [ #pagebreak() ]
    #authorities-table(meta)
  ]
]

/// The argument or the relief, then the signature, then the certificates, each on its own page.
#let body-section(meta, body) = [
  #set par(leading: onehalf-leading, spacing: 0pt, first-line-indent: (amount: para-indent, all: true), justify: false)
  #mark-authorities(meta, cmarker.render(body, raw-typst: false, smart-punctuation: true))
  #signature-section(meta)
  #for c in meta.at("certificates", default: ()) [
    #pagebreak()
    #align(center, strong(upper(c.heading)))
    #v(0.4em)
    #set par(leading: onehalf-leading, first-line-indent: 0.5in)
    #inl(c.text)
    #if "signer" in c [
      #v(0.4em)
      #par(first-line-indent: 0pt, [#h(sig-indent)#underline[/s/ #inl(c.signer)]])
    ]
  ]
]

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let mich-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  set page(paper: "us-letter", margin: page-margin, numbering: none)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: onehalf-leading, spacing: 0pt, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Level 1: a section, centred, capitals, bold, single-spaced. Level 2: point heading, bold, hanging.
  // Level 3: sub-heading, bold italic. Headings are typed with their own numbering, as filed.
  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 1em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, strong(upper(it.body)))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #strong(it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #strong(emph(it.body))
  ]
  show heading.where(level: 4): it => block(width: 100%, above: 0.8em, below: 0.6em, sticky: true)[
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #emph(it.body)
  ]

  // Block quotations: indented, single-spaced (MCR 7.212(B)(5)).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.6em, below: 1em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: the same size as the text, single-spaced (MCR 7.212(B)(5)).
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)
  }

  let inline-cover = not meta.at("cover_page", default: true)
  let has-front = meta.at("toc", default: true) or ("authorities" in meta)

  // Page numbers. A cover that carries the body is page 1; otherwise the cover is not numbered,
  // the front matter is roman from i, and the body is arabic from 1 (as in the Chapter 7 papers).
  set page(numbering: if inline-cover and not has-front { "1" } else { none })
  make-cover(meta)

  if inline-cover and not has-front {
    body-section(meta, body)
  } else if has-front {
    pagebreak()
    set page(numbering: "i")
    counter(page).update(1)
    front-section(meta)
    pagebreak()
    set page(numbering: "1")
    counter(page).update(1)
    body-section(meta, body)
  } else {
    pagebreak()
    set page(numbering: "1")
    counter(page).update(1)
    body-section(meta, body)
  }
}
