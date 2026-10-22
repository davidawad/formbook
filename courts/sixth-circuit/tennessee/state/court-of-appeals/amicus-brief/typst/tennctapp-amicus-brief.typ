// Court of Appeals of Tennessee (tennctapp): amicus curiae brief, e-filed PDF.
// Tenn. R. App. P. 31 (second paragraph): an amicus brief follows the form prescribed for the brief of an
// appellee, so the layout is the answering-brief template's; the word limit is Rule 30 (e) (3).
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next to it:
// Tenn. Sup. Ct. R. 46, section 3.02 (e-filed formats; governs over the paper rules where they conflict),
// Tenn. R. App. P. 27 (content and order), 30 (cover, word limits), 20 (proof of service).
// Sources and capture dates: ../rules.md (court folder). No case-specific text, no coordinates
// measured off any filed brief, no forced line breaks. The body is the markdown below the YAML
// frontmatter of the sample (contract: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/word-compat.typ": word-compat

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

// Rule 46 section 3.02 (3) (a): any font within the Century family. TeX Gyre Schola is the vendored
// Century Schoolbook substitute (docs/FONTS.md). Times New Roman is not declared for this court.
#let font-family = "TeX Gyre Schola"
// Rule 46 section 3.02 (3) (b): 14-point. Footnotes take the same size (3) (c).
#let type-size = 14pt
// Rule 46 section 3.02 (2) (a): 1.5 line spacing. Typst's natural line box for this face is 10.1 pt at
// 14 pt (measured); 1.5 lines = 25.2 pt (Word single 16.8 pt x 1.5), so leading = 15.1 pt = 1.08 em.
#let body-leading = 1.08em
// Single spacing for block quotations, headings and footnotes (a convention shared by the exemplars:
// Word single at 14 pt is 16.8 pt; 10.1 pt + 0.48 em (6.7 pt) = 16.8 pt).
#let single-leading = 0.48em
// Rule 46 section 3.02 (2) (b): 1 inch margins.
#let page-margin = 1in
#let para-indent = 0.5in
// The table of contents lists argument points down to level 4 (the numbered subpoints).
#let toc-depth = 4
#let sig-indent = 3.2in
// Rule 30 (e) (3) and Rule 46 section 3.02 (1) (c): amicus briefs 7,500 words.
#let word-limit = "7,500"
// Rule 30 (e) and the Rule 46 certificate (section 3.02 (c)): the statement of the number of words.
#let compliance-text = "The undersigned certifies that this brief complies with the word limit of Tenn. R. App. P. 30 (e) (3) and Tenn. Sup. Ct. R. 46, section 3.02 (1) (c), as applied to amicus curiae briefs."

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("tennctapp-amicus-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("tennctapp-amicus-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One caption side: centred names, then the designation.
#let caption-side(side) = {
  align(center)[
    #set par(leading: single-leading, spacing: 0.4em, first-line-indent: 0pt)
    #for n in side.names [ #inl(n) \ ]
    #emph(side.designation)
  ]
}

/// Counsel group: names (bold) then the lines beneath.
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for n in g.names [ #strong(inl(n)) \ ]
  for l in g.lines [ #inl(l) \ ]
  v(0.6em)
}

/// Signature block: Rule 46 section 3.04 (a) and 1.01 (i): "s/" and the typed name, followed by the
/// signer's name, business address, telephone, e-mail and Board of Professional Responsibility number.
#let signature-block(sig) = {
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #underline[s/ #inl(sig.signer)] \
    #for l in sig.at("lines", default: ()) [ #inl(l) \ ]
  ])
}

// Table of authorities. Each entry carries `find`: a string, or a list of strings, that occurs in
// every citation of the authority in the body (the full cite and short forms). A show rule on each
// string drops a marker after it; the table lists the pages of the markers. Entry keys are assigned
// in order ("toa0", "toa1", ...) by `flat-authorities`, which the table also uses.
#let toa-marker(key) = [#metadata(key)<tennctapp-toa>]

#let flat-authorities(meta) = {
  let out = ()
  let i = 0
  for group in meta.at("authorities", default: ()) {
    for e in group.entries {
      let finds = if "find" in e { if type(e.find) == str { (e.find,) } else { e.find } } else { () }
      out.push((key: "toa" + str(i), finds: finds, cite: e.cite, pages: e.at("pages", default: none)))
      i += 1
    }
  }
  out
}

#let mark-authorities(flat, content) = {
  let out = content
  for e in flat {
    for f in e.finds {
      let key = e.key
      out = {
        show f: it => it + toa-marker(key)
        out
      }
    }
  }
  out
}

#let toa-pages(key) = context {
  let pages = query(<tennctapp-toa>)
    .filter(m => m.value == key)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
  if pages.len() == 0 { [--] } else { pages.map(str).join(", ") }
}

#let authorities-table(meta, flat) = {
  heading(level: 1, outlined: true)[Table of Authorities]
  set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 1.5em, justify: false)
  let idx = 0
  for group in meta.authorities {
    block(above: 1.2em, below: 0.8em, sticky: true, strong(group.heading))
    for e in group.entries {
      let key = flat.at(idx).key
      idx += 1
      block(above: 0.9em, below: 0.9em, breakable: false)[
        #inl(e.cite) #box(width: 1fr, repeat[.#h(2pt)]) #h(4pt) #if "passim" in e and e.passim { [passim] } else if "pages" in e and e.pages != none { e.pages } else { toa-pages(key) }
      ]
    }
  }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let tennctapp-brief(meta, body) = {
  // Word composition (kerning and hyphenation off, greedy lines, no hanging punctuation); justify and
  // any space compression come from the INPUT's `word:` map (lib/typst/word-compat.typ).
  show: word-compat.with(meta.at("word", default: (:)))
  set document(title: need(meta, "brief_title"))
  // Rule 46 section 3.02 (5): pagination begins with page 1, which is the cover; Arabic numerals
  // at the bottom (Rule 30 (a): papers numbered on the bottom).
  set page(paper: "us-letter", margin: page-margin, numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", region: "us", hyphenate: false)
  // Rule 46 section 3.02 (4): full justification. Rule 46 section 3.02 (2) (a): 1.5 spacing.
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: true)
  set heading(numbering: none)

  let flat = flat-authorities(meta)

  // Headings in the body: level 1 is a section (centred, capitals, bold); level 2 and 3 are argument
  // points (bold, left, hanging). Argument numbering is typed by the author, as in the filing.
  show heading.where(level: 1): it => block(width: 100%, above: 1.6em, below: 1.2em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, justify: false)
    #align(center, text(weight: "bold", upper(it.body)))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1.2em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in, justify: false)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in, justify: false)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 4): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in, justify: false)
    #text(weight: "bold", it.body)
  ]

  // Block quotations: indented, single-spaced (Rule 46 section 3.02 (2) (a) body rule; exemplar convention).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt, justify: true)
    #it.body
  ]
  // Footnotes: same font and size as the text (Rule 46 section 3.02 (3) (c)), single-spaced.
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt, justify: false)
    mark-authorities(flat, it)
  }

  // ---- Cover (Tenn. R. App. P. 30 (b)) ----
  page[
    #set par(leading: single-leading, first-line-indent: 0pt, justify: false)
    #align(center)[
      No. #need(meta, "case_number") \
      #v(0.35in)
      #text(weight: "bold")[IN THE COURT OF APPEALS OF TENNESSEE] \
      #if "court_seat" in meta [ #text(weight: "bold")[#meta.court_seat] ]
    ]
    #v(0.3in)
    #caption-side(meta.caption.at(0))
    #v(0.2in)
    #align(center)[v.]
    #v(0.2in)
    #caption-side(meta.caption.at(1))
    #v(0.3in)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt, justify: false)
      #if "proceeding" in meta { inl(meta.proceeding) }
    ]
    #v(1fr)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt, justify: false)
      #text(weight: "bold", upper(inl(need(meta, "brief_title"))))
    ]
    #v(1fr)
    #{
      set par(leading: single-leading, first-line-indent: 0pt, justify: false)
      pad(left: 2.4in, {
        for g in need(meta, "counsel") { counsel-group(g) }
      })
    }
  ]

  // ---- Table of contents (Tenn. R. App. P. 27 (a) (1)) ----
  if meta.at("toc", default: true) {
    page[
      #set par(leading: single-leading, first-line-indent: 0pt, justify: false)
      #align(center, text(weight: "bold")[TABLE OF CONTENTS])
      #v(0.5em)
      #show outline.entry: it => block(above: 0.9em, below: 0.9em, it)
      #outline(title: none, depth: toc-depth, indent: 1.5em)
    ]
  }

  // ---- Table of authorities (Tenn. R. App. P. 27 (a) (2)) ----
  if "authorities" in meta {
    page(authorities-table(meta, flat))
  }

  // ---- Body. A line "# Addendum" (Rule 27 (e)) splits off the addendum, which follows the certificates. ----
  let parts = body.split("\n# Addendum\n")
  let main-body = parts.at(0)
  mark-authorities(flat, cmarker.render(main-body, raw-typst: false, smart-punctuation: true))

  // ---- Signature block (Tenn. R. App. P. 27 (a) (8); Rule 46 section 3.04) ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #set par(first-line-indent: 0pt, justify: false)
    #if "date" in meta [ Dated: #inl(meta.date) ]
    #v(0.4em)
    #pad(left: sig-indent)[ Respectfully submitted, ]
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]

  // ---- Certificate of compliance (Rule 46 section 3.02 (1) and (c); Rule 46 section 1.01 (b)) ----
  // Order follows the filed exemplar: compliance, then service.
  if "word_count" in meta {
    pagebreak(weak: true)
    heading(level: 1)[Certificate of Compliance]
    par(first-line-indent: (amount: para-indent, all: true))[#compliance-text]
    par(first-line-indent: (amount: para-indent, all: true))[
      Based on the word-count function of the word-processing system used to prepare the brief, the brief contains #inl(str(meta.word_count)) words, exclusive of the material excluded by Tenn. R. App. P. 30 (e), and the Rule 27 (e) addendum is not included in that count.
    ]
    if "date" in meta { par(first-line-indent: (amount: para-indent, all: true), inl(meta.date)) }
    v(0.4em)
    signature-block(need(meta, "signature"))
  }

  // ---- Certificate of service (Tenn. R. App. P. 20 (e)) ----
  if "service" in meta {
    let svc = meta.service
    pagebreak(weak: true)
    heading(level: 1)[Certificate of Service]
    par(first-line-indent: (amount: para-indent, all: true))[
      The undersigned certifies that on #inl(svc.date), a true and correct copy of the foregoing was served #inl(svc.at("method", default: "through the court's e-filing system")) on:
    ]
    for r in svc.at("recipients", default: ()) {
      block(above: 1em, below: 1em, breakable: false, pad(left: 1in)[
        #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt, justify: false)
        #for l in r [ #inl(l) \ ]
      ])
    }
    v(0.4em)
    signature-block(need(meta, "signature"))
  }

  // ---- Addendum (Tenn. R. App. P. 27 (e)) ----
  if parts.len() > 1 {
    pagebreak(weak: true)
    heading(level: 1)[#meta.at("addendum_title", default: "Addendum")]
    cmarker.render(parts.at(1), raw-typst: false, smart-punctuation: true)
  }
}
