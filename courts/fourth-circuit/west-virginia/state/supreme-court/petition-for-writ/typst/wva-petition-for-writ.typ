// West Virginia Supreme Court of Appeals verified petition for writ (Rules of Appellate Procedure, see ../../rules.md;
// WVA-WRIT rows for original-jurisdiction petitions under Rule 16, Rule 10 form). Entry point: typst/main.typ calls
// wva-petition-for-writ(meta, body) with the sample's frontmatter and markdown.
// wva-petition-for-writ(meta, body) with the sample's frontmatter and markdown.
// Every number below is a named constant that traces to rules.md. Nothing here is case-specific: case text comes
// from the sample's frontmatter only.
#import "@preview/cmarker:0.1.10"

// ---- Typography (RAP 38(a)) -----------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")
#let body-size = 12pt          // RAP 38(a): text no smaller than 12-pt proportional type
#let note-size = 11pt          // RAP 38(a): footnote text no smaller than 11-pt proportional type
#let margin = 1in              // RAP 38(a): margins no less than one inch on all sides
#let indent = 0.5in            // first-line indent of body paragraphs
// RAP 38(a): double-spaced text. Times and Liberation Serif have a natural line height of about
// 1.15 em, so `leading` 1.15 em gives a double-spaced pitch (about 2.3 em).
#let leading-double = 1.15em
#let leading-single = 0.3em    // single spacing: quotations, footnotes, headings, caption, blocks

#let court-lines = ("IN THE SUPREME COURT OF APPEALS", "OF WEST VIRGINIA") // RAP 38(b)(1)
#let kinds = (
  (key: "case", title: "CASES"),
  (key: "statute", title: "STATUTES"),
  (key: "constitution", title: "CONSTITUTIONAL PROVISIONS"),
  (key: "rule", title: "RULES"),
  (key: "other", title: "OTHER AUTHORITIES"),
)

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wva petition: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// Page number in the bottom margin; none on the cover.
#let folio = context {
  let n = here().page-numbering()
  if n != none { align(center, text(size: body-size, counter(page).display(n))) }
}

#let lines-of(list) = block(width: 100%, list.map(l => cmarker.render(l)).join(linebreak()))

#let front-title(t) = align(center, block(below: 1.2em, text(weight: "bold", t)))

// ---- Cover (RAP 38(b)) ----------------------------------------------------------------------
#let cover(meta) = {
  set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  if "docket" in meta { text(weight: "bold", meta.docket) }
  v(1.2em)
  align(center, text(weight: "bold", court-lines.at(0)))
  align(center, text(weight: "bold", court-lines.at(1)))
  v(1.6em)
  for (i, side) in meta.caption.enumerate() {
    if i > 0 {
      v(0.5em)
      align(center, [v.])
      v(0.5em)
    }
    lines-of(side.names)
    block(width: 100%, align(right, side.designation))
  }
  if "proceeding" in meta {
    v(1.2em)
    align(center, text(weight: "bold", meta.proceeding))
  }
  v(1.6em)
  align(center, text(weight: "bold", meta.brief_title))
  v(3em)
  // Counsel blocks stack one under another: side-by-side columns overflow the right margin with long e-mail addresses.
  pad(left: 45%, {
    for g in meta.counsel [
      #lines-of(g.names)
      #lines-of(g.lines)
      #v(1.2em)
    ]
  })
}

// ---- Table of contents and table of authorities (RAP 10(c)(1)-(2)) -------------------------
// A link whose target is `toa:KEY` in the body is recorded with its page; the TOA is built from
// those records. Other links print their text only.
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
    block(above: 1.1em, below: 0.5em, text(weight: "bold", k.title))
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
          par(leading: leading-single, first-line-indent: 0pt, hanging-indent: 0.4in)[#authority-line(a)],
          shown,
        ),
      )
    }
  }
}

// ---- Closing: signature, certificate of service (RAP 37(b), 38A) ------------------------------
#let signature-blocks(meta) = {
  set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  if "signature" in meta {
    pad(left: 45%, {
      for g in meta.signature [
        #lines-of(g.lines)
        #v(1.2em)
      ]
    })
  }
}
#let closing(meta) = if "signature" in meta { block(breakable: false)[
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: 0pt)
  Respectfully submitted,

  #signature-blocks(meta)
] }

// Verification under W. Va. Code 53-1-3 (the verified petition; the verification page is printed after the closing).
#let verification(meta) = if "verification" in meta {
  let vf = meta.verification
  [
  #front-title[VERIFICATION]
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: 0pt)
  #align(left, [#vf.venue])
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: indent)
  #vf.text
  #set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  #v(2.4em)
  #align(right, block(width: 45%, [#vf.affiant \ Counsel for Petitioner]))
  #v(1.6em)
  Taken, sworn to and subscribed before me this #vf.sworn.
  #v(2.4em)
  #align(right, block(width: 45%, [Notary Public \ My Commission Expires: \_\_\_\_\_\_\_\_\_\_\_\_]))
  ]
}

// RAP 37(b), 38A: the certificate of service is attached at the end of every filing. A date, method or recipient the
// filer has not supplied prints as a blank for the filer to complete, never a guessed value.
#let when(d, key) = if key in d { d.at(key) } else { "____________" }
#let certificate-of-service(meta) = {
  let s = meta.at("service", default: (:))
  [
  #front-title[CERTIFICATE OF SERVICE]
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: indent)
  I certify that I served the foregoing #when(s, "document") upon counsel of record by #when(s, "method") on the #when(s, "date").
  #set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  #v(1em)
  #if "recipients" in s [
    #grid(
      columns: range(s.recipients.len()).map(_ => 1fr),
      gutter: 0.3in,
      ..s.recipients.map(g => lines-of(g.lines)),
    )
  ] else [
    #v(3em)
  ]
  #v(2em)
  #signature-blocks(meta)
  ]
}

// ---- Body styling ------------------------------------------------------------------------------
#let style-body(it) = {
  set text(font: font-family, size: body-size, lang: "en")
  set par(justify: false, leading: leading-double, spacing: leading-double, first-line-indent: indent)
  show heading.where(level: 1): h => block(
    above: 1.2em,
    below: 1em,
    width: 100%,
    align(center, text(weight: "bold", h.body)),
  )
  show heading.where(level: 2): h => block(above: 1.2em, below: 0.8em, text(weight: "bold", h.body))
  show heading.where(level: 3): h => block(
    above: 1.1em,
    below: 0.6em,
    text(weight: "bold", style: "italic", h.body),
  )
  show heading: set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  show footnote: f => text(font: font-family, size: note-size, f)
  show footnote.entry: n => {
    set text(font: font-family, size: note-size)
    set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
    n
  }
  show quote.where(block: true): q => block(above: 1em, below: 1em, pad(
    left: indent,
    right: indent,
    {
      set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
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

// ---- Entry -------------------------------------------------------------------------------------
#let wva-petition-for-writ(meta, body) = {
  set document(title: meta.brief_title)
  set page(paper: "us-letter", margin: margin, footer-descent: 0.4in)
  set text(font: font-family, size: body-size, lang: "en")
  page(numbering: none, footer: none)[
    #show: style-body
    #cover(meta)
  ]
  if "toc" in meta {
    page(numbering: "i", footer: folio)[
      #show: style-body
      #front-title[TABLE OF CONTENTS]
      #outline(title: none, depth: 3, indent: 0pt)
    ]
  }
  if "authorities" in meta {
    page(numbering: "i", footer: folio)[
      #show: style-body
      #front-title[TABLE OF AUTHORITIES]
      #table-of-authorities(meta.authorities)
    ]
  }
  page(numbering: "1", footer: folio)[
    #show: style-body
    #counter(page).update(1)
    #cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1)
    #closing(meta)
  ]
  if "verification" in meta {
    page(numbering: "1", footer: folio)[
      #show: style-body
      #verification(meta)
    ]
  }
  page(numbering: "1", footer: folio)[
    #show: style-body
    #certificate-of-service(meta)
  ]
}
