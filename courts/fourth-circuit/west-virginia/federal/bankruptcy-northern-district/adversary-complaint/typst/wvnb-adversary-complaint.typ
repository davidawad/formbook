// N.D. W. Va. Bankruptcy Court: adversary complaint (FRBP 7001 et seq.).
// Every number below traces to a rule; README.md has the rule, URL and date verified.
#import "@preview/cmarker:0.1.10"

// ---- parameters ----
#let font-family = "EB Garamond"   // vendored in /fonts; no system font is ever used
#let type-size = 12pt              // LBR 9004-1 (search excerpt, see README): minimum 10 pt; 12 pt used
#let body-leading = 0.85em         // ~1.5 spacing: inside LBR 9004-1's single-to-double range (see README)
#let single-leading = 0.3em        // caption, counsel block, signature, footer
#let para-indent = 0.5in           // FRCP 10(b) numbered paragraphs; indent is presentation only
#let margins = (top: 1in, bottom: 1in, left: 1in, right: 1in)  // LBR 9004-1 is silent on margins; 1 in is the convention

// ---- helpers ----
#let need(meta, key) = {
  if key not in meta { panic("wvnb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wvnb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// FRCP 10(a): caption has the court name, a title, a file number, and a Rule 7(a) designation.
// FRBP 9004(b): caption names the court, the case title, the case and adversary-proceeding numbers,
// and a brief designation of the document. FRBP 7010: the caption substantially conforms to Form 416.
#let court-caption(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading)
  stack(dir: ttb, spacing: 0.3em, ..need(meta, "court").map(line => align(center, upper(line))))
  v(1.2em)
  let sides = need(meta, "caption")
  table(
    columns: (3.2in, 3.3in),
    stroke: none,
    inset: (x: 0.1in, y: 0.25em),
    table.cell(stroke: (right: 0.75pt + black, bottom: 0.75pt + black), inset: (bottom: 0.9em, right: 0.15in))[
      #if "debtor" in meta [
        In re: #meta.debtor.name,\
        #h(0.4in)Debtor.
        #v(0.8em)
      ]
      #for side in sides.slice(0, 1) {
        for n in side.names { [#n\ ] }
        h(0.6em)
        [#side.designation]
        v(0.8em)
      }
      #h(1.5in) v.
      #v(0.8em)
      #for side in sides.slice(1) {
        for n in side.names { [#n\ ] }
        h(0.6em)
        [#side.designation]
      }
      #v(0.6em)
    ],
    table.cell(inset: (left: 0.25in))[
      #v(0.6em)
      Chapter #need(meta, "chapter")\
      #v(0.6em)
      Case No. #need(meta, "case_number")\
      #if "judge" in meta [Judge #meta.judge\ ]
      #v(0.6em)
      Adv. Pro. No. #need(meta, "adversary_number")\
      #if "adversary_title" in meta [#meta.adversary_title\ ]
    ],
  )
  v(1.2em)
  align(center, strong(upper(need(meta, "complaint_title"))))
  v(0.6em)
}

// Counsel block, upper left (convention; the rules text read does not set a position).
#let counsel-block(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading)
  for line in need(meta, "counsel") {
    [#line\ ]
  }
  v(1.2em)
}

// Paragraphs of the complaint are numbered continuously across the whole document (FRCP 10(b)).
#let para-no = counter("wvnb-para")

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  set par(first-line-indent: 0pt, leading: single-leading)
  v(1.2em)
  block(width: 100%, breakable: false)[
    #if "date" in meta [Dated: #meta.date\ ]
    #v(0.8em)
    #h(3.2in)Respectfully submitted,\
    #v(0.8em)
    #h(3.2in)#strong[s/ #sig.signer]\
    #for line in sig.lines [#h(3.2in)#line\ ]
  ]
}

#let wvnb-adversary-complaint(meta, md) = {
  for k in ("court", "caption", "chapter", "case_number", "adversary_number", "complaint_title", "counsel", "signature") {
    let _ = need(meta, k)
  }

  set page(paper: "us-letter", margin: margins)
  set document(
    title: need(meta, "complaint_title") + ", Adv. Pro. No. " + need(meta, "adversary_number"),
    author: need(meta, "signature").signer,
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", hyphenate: false, fallback: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set enum(
    numbering: _ => {
      para-no.step()
      context para-no.display() + "."
    },
    indent: 0pt,
    body-indent: 0.5in,
  )
  set footnote.entry(separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: 10pt)
  show footnote.entry: set par(first-line-indent: 0pt)

  // Headings in a complaint are centered capitals (parts) or bold centered (counts and subparts).
  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 0.8em, sticky: true,
    align(center, strong(upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, above: 1em, below: 0.6em, sticky: true,
    align(center, strong(it.body)))

  // Running footer: page number on every page.
  set page(footer: context {
    set text(size: 10pt)
    align(center, counter(page).display())
  })

  counsel-block(meta)
  court-caption(meta)

  cmarker.render(md, raw-typst: false, smart-punctuation: true)
  signature-block(meta)
}
