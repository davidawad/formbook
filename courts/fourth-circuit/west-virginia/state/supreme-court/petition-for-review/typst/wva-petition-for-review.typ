// West Virginia Supreme Court of Appeals petition-for-review filing: a brief of the petitioner in an appeal from a
// Public Service Commission order, formatted as a Rule 10 brief (Rule 14(d) for PSC appeals; rules.md WVA-FORM,
// WVA-COVER, WVA-CONT, WVA-LEN, WVA-CERT and WVA-ELEC rows). Entry point: typst/main.typ calls
// wva-petition-for-review(meta, body) with the sample's frontmatter and markdown. Every number is a named constant
// below and traces to rules.md. Nothing here is case-specific: case text comes from frontmatter only.
#import "@preview/cmarker:0.1.10"

// ---- Typography (RAP 38(a)) ----------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif") // rules.md WVA-TPL-002: tier-2 face choice
#let body-size = 12pt // RAP 38(a) (WVA-FORM-003): no smaller than 12-point proportional type
#let note-size = 11pt // RAP 38(a) (WVA-FORM-004): footnotes no smaller than 11-point proportional type
#let margin = 1in // RAP 38(a) (WVA-FORM-005): no less than one inch on all sides
#let indent = 0.5in // first-line indent of body paragraphs
// RAP 38(a) (WVA-FORM-002): double-spaced text. The pitch is the font's natural line plus `leading`.
#let leading-double = 1.3em
#let leading-single = 0.2em // single spacing: headings, quotations, footnotes, caption and signature lines
#let leading-tight = 0.2em // TOC and TOA entries

// ---- Court constants (not case text) ------------------------------------------------------------
#let court-line = "IN THE SUPREME COURT OF APPEALS OF WEST VIRGINIA" // RAP 38(b)(1) (WVA-COVER-001)
#let doc-noun = "brief" // the noun used in the certificate of service
#let kinds = (
  (key: "case", title: "CASES"),
  (key: "statute", title: "STATUTES"),
  (key: "regulation", title: "REGULATIONS"),
  (key: "rule", title: "RULES"),
  (key: "agency", title: "REGULATORY AUTHORITY"),
  (key: "other", title: "OTHER AUTHORITIES"),
)

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wva filing: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// Page number in the bottom margin (RAP 38(a)); none on the cover.
#let folio = context {
  let n = here().page-numbering()
  if n != none { align(center, text(font: font-family, size: body-size, counter(page).display(n))) }
}

#let lines-of(list, italic: false) = for l in list {
  block(width: 100%, if italic { emph[#l] } else { [#l] })
}

// A date the filer has not printed in the source is a blank line for the filer to complete, never a guessed date.
#let when(d, key) = if key in d { d.at(key) } else { "____________" }

#let front-title(t) = align(center, block(below: 1.2em, text(weight: "bold", t)))

// ---- Cover (RAP 38(b); RAP 10(a)) ----------------------------------------------------------------
#let caption-side(side) = {
  set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  align(center, lines-of(side.names))
  align(center, block(width: 100%, side.designation))
}

#let cover(meta) = {
  set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  if "docket" in meta [
    #meta.docket
    #v(1.6em)
  ]
  align(center, text(weight: "bold", court-line))
  v(1.6em)
  caption-side(meta.caption.at(0))
  v(0.8em)
  align(center, [v.])
  v(0.8em)
  caption-side(meta.caption.at(1))
  if "proceeding" in meta [
    #v(1.2em)
    #align(center, meta.proceeding)
  ]
  v(2.4em)
  align(center, text(weight: "bold", meta.brief_title))
  v(3em)
  // Counsel name, West Virginia State Bar number, mailing address, telephone, e-mail (RAP 38(b)(5)). Counsel
  // blocks stack one under another: two columns overflow the right margin with long e-mail addresses.
  pad(left: 3in, {
    for g in meta.counsel [
      #lines-of(g.names)
      #lines-of(g.lines)
      #v(1.2em)
    ]
  })
}

// ---- Table of authorities (RAP 10(c)(2); year of each citation in the cite text) ------------------
// A link whose target is `toa:KEY` in the body is recorded with its page; the TOA is built from those records.
// Every other link prints its text only.
#let authority-line(a) = if a.kind == "case" {
  [#emph(a.name), #a.cite]
} else if "cite" in a and a.cite != "" {
  [#a.name #a.cite]
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
        below: 0.7em,
        grid(
          columns: (1fr, auto),
          gutter: 1em,
          par(leading: leading-tight, first-line-indent: 0pt, hanging-indent: 0.4in)[#authority-line(a)],
          shown,
        ),
      )
    }
  }
}

// ---- Closing: signature block, certificate of service -------------------------------------------
// RAP 38A and 38(b)(5): the typographical signature "s/ name" with the bar identification and contact lines.
#let signature-block(sig) = {
  set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  pad(left: 3in, block(width: 100%, {
    if "signer" in sig { lines-of(("s/" + sig.signer,) + sig.lines) } else { lines-of(sig.lines) }
  }))
}

#let closing(meta) = block(breakable: false)[
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: 0pt)
  Respectfully submitted#if "date" in meta [ on #meta.date].

  #signature-block(meta.signature)
]

// RAP 10(c)(9), RAP 37(b): the certificate of service is attached at the end of the brief; it carries no page
// number of its own and sits outside the page limit. The method and the title are filer-supplied text.
#let certificate-of-service(meta) = {
  let s = meta.at("service", default: (:))
  [
  #front-title[CERTIFICATE OF SERVICE]
  #set par(leading: leading-double, spacing: leading-double, first-line-indent: indent)
  I hereby certify that on #when(s, "date"), I served the foregoing “#s.at("title", default: meta.brief_title)” by #s.at("method", default: "____________"), on the following counsel of record:

  #v(1.2em)
  #set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  #if "recipients" in s [
    // Recipients stack one under another: side-by-side columns overflow the right margin with long e-mail addresses.
    #for g in s.recipients [
      #lines-of(g.names)
      #lines-of(g.lines)
      #v(1.2em)
    ]
  ]
  #if "additional" in s [
    #set par(leading: leading-double, spacing: leading-double, first-line-indent: indent)
    Additionally, on #when(s.additional, "date"), I served the foregoing “#s.at("title", default: meta.brief_title)” by #s.additional.at("method", default: "____________"), to the following:
    #v(1.2em)
    #set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
    #for g in s.additional.recipients [
      #lines-of(g.names)
      #lines-of(g.lines)
      #v(1.2em)
    ]
  ]
  ]
}

// A link whose target is `toa:KEY` records a hit for the table of authorities (in the body and in footnotes);
// any other link prints its text only.
#let toa-link(l) = {
  if type(l.dest) == str and l.dest.starts-with("toa:") {
    [#l.body#metadata((key: l.dest.slice(4)))<toa-hit>]
  } else if type(l.dest) == str {
    l.body
  } else {
    l
  }
}

// ---- Body styling (applied with `#show: style-body`) ---------------------------------------------
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
  show heading.where(level: 3): h => block(above: 1.1em, below: 0.6em, text(weight: "bold", h.body))
  show heading: set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
  show footnote: f => text(font: font-family, size: note-size, f)
  show footnote.entry: n => {
    set text(font: font-family, size: note-size)
    set par(leading: leading-single, spacing: leading-single, first-line-indent: 0pt)
    show link: toa-link
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
  show link: toa-link
  it
}

// ---- Entry -------------------------------------------------------------------------------------
#let wva-petition-for-review(meta, body) = {
  set document(title: meta.brief_title)
  set page(paper: "us-letter", margin: margin, footer-descent: 0.4in)
  set text(font: font-family, size: body-size, lang: "en")
  // Cover: no folio. Front matter: roman numerals. Body: restarts at 1 in arabic numerals.
  page(numbering: none, footer: none)[
    #show: style-body
    #cover(meta)
  ]
  page(numbering: "i", footer: folio)[
    #show: style-body
    #front-title[TABLE OF CONTENTS]
    #outline(title: none, depth: 3, indent: n => n * 0.5in)
  ]
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
  page(numbering: "1", footer: folio)[
    #show: style-body
    #certificate-of-service(meta)
  ]
}
