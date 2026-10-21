// Michigan Supreme Court (mich): brief in a calendar case or a case argued on the application, the
// answering (appellee's) brief. The same template serves the other Supreme Court briefs in the
// sibling doc folders; each folder carries its own copy so it can be read on its own.
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next to it
// (Michigan Court Rules of 1985, chapters 1 and 7, official courts.michigan.gov HTML; see ../../rules.md).
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks. The
// markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the sample.

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
#let single-leading = 0.5em              // single line = 13.86 pt: quotations and footnotes (MCR 7.212(B)(5)).
#let para-indent = 0.5in
#let sig-indent = 3.2in                  // signature block sits right of centre (style; the exemplar does the same).
#let toc-depth = 2                       // MCR 7.212(C)(2): the contents list the headings and principal points of argument.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mich-answering-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("mich-answering-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Caption side: the party names centred, the designation (for example, Plaintiff-Appellant) below.
#let caption-side(side) = {
  set par(leading: single-leading, first-line-indent: 0pt)
  align(center)[
    #for n in side.names [ #inl(n) \ ]
    #inl(side.designation)
  ]
}

/// Counsel block: names, then the firm, address and contact lines.
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for n in g.names [ #inl(n) \ ]
  for l in g.lines [ #inl(l) \ ]
}

/// Signature block: the firm lines, then "/s/" and the typed name, then the bar number and the party.
#let signature-block(sig) = {
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #for l in sig.at("firm", default: ()) [ #inl(l) \ ]
    #v(0.6em)
    #underline[/s/ #inl(sig.signer)] \
    #for l in sig.at("lines", default: ()) [ #inl(l) \ ]
  ])
}

// Table of authorities. Each entry carries `find`: a string that appears in every citation of the
// authority in the body. A show rule on that string drops a marker after each occurrence; the
// table lists the pages of the markers.
#let toa-marker(key) = [#metadata(key)<mich-toa>]

#let mark-authorities(meta, content) = {
  let out = content
  let finds = ()
  for group in meta.at("authorities", default: ()) {
    for e in group.entries {
      if "find" in e { finds.push(e.find) }
    }
  }
  // Longest find first: a shorter find applied earlier would split a longer one ("MCL 600.6431" inside "MCL 600.6431(1)").
  for key in finds.sorted(key: f => -f.len()) {
    out = {
      show key: it => it + toa-marker(key)
      out
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
// Template
// ---------------------------------------------------------------------------

#let mich-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  set page(paper: "us-letter", margin: page-margin, numbering: none)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: onehalf-leading, spacing: onehalf-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
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

  // ---- Cover (MCR 7.312(C) general form). Page one, not numbered. ----
  [
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center)[
      #strong[#upper(need(meta, "court_line"))]
      #v(0.1in)
      #strong[IN THE SUPREME COURT]
      #v(0.1in)
      #if "proceeding" in meta [ APPEAL FROM #inl(meta.proceeding) \ ]
      #if "trial_court" in meta [ #inl(meta.trial_court) \ ]
      #if "judge" in meta [ #inl(meta.judge) ]
    ]
    #v(0.2in)
    #for (i, side) in need(meta, "caption").enumerate() [
      #if i > 0 [ #align(center)[v.] #v(0.1in) ]
      #caption-side(side)
      #v(0.1in)
    ]
    #v(0.1in)
    #align(center)[
      MSC No. #box(width: 1.6in, repeat[\_])
      \
      #if "coa_no" in meta [ COA No. #inl(meta.coa_no) \ ]
      #if "trial_court_no" in meta [ Trial Ct No. #inl(meta.trial_court_no) ]
    ]
    #v(0.2in)
    #align(center)[#strong(upper(inl(need(meta, "brief_title"))))]
    #v(0.1in)
    #if "oral_argument" in meta [
      #align(center)[
        #strong[ORAL ARGUMENT #upper(meta.oral_argument)]
      ]
    ]
    #v(0.3in)
    #grid(
      columns: (1fr, 1fr),
      gutter: 0.3in,
      ..need(meta, "counsel").map(g => counsel-group(g)),
    )
  ]

  // ---- Front matter: contents, then index of authorities, roman numbering from i. ----
  pagebreak()
  set page(numbering: "i")
  counter(page).update(1)
  align(center, strong[TABLE OF CONTENTS])
  v(0.3em)
  set par(leading: single-leading, first-line-indent: 0pt)
  show outline.entry: it => block(above: 0.6em, below: 0.6em, it)
  outline(title: none, depth: toc-depth, indent: 1.5em)

  if "authorities" in meta {
    pagebreak()
    authorities-table(meta)
  }

  // ---- Body, arabic numbering from 1 ----
  set par(leading: onehalf-leading, spacing: onehalf-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  pagebreak()
  set page(numbering: "1")
  counter(page).update(1)

  // Footnote definitions sit at the end of the body; they go with the main text, where their references are.
  let rendered = cmarker.render(body, raw-typst: false, smart-punctuation: true)
  mark-authorities(meta, rendered)

  // ---- Signature block (after the request for relief) ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #if "date" in meta { par(first-line-indent: 0pt, inl(meta.date)) }
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]

  // ---- Certificates (MCR 7.212(B)(3) word count; service), each on a new page ----
  for c in meta.at("certificates", default: ()) {
    pagebreak()
    align(center, strong(upper(c.heading)))
    v(0.4em)
    set par(leading: onehalf-leading, first-line-indent: 0.5in)
    inl(c.text)
    if "signer" in c [
      #v(0.4em)
      #par(first-line-indent: 0pt, [#h(sig-indent)#underline[/s/ #inl(c.signer)]])
    ]
  }
}
