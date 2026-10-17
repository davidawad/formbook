// N.D. W. Va. Bankruptcy Court: adversary complaint (FRBP 7001 et seq.).
// Every number below traces to a rule; README.md has the rule, URL and date verified.
#import "@preview/cmarker:0.1.10"

// ---- parameters ----
#let font-family = ("Times New Roman", "Liberation Serif")   // Times New Roman substitute per docs/FONTS.md, vendored in /fonts; no system font is ever used
#let type-size = 12pt              // LBR 9004-1 (search excerpt, see README): minimum 10 pt; 12 pt used
#let body-leading = 1.645em        // double spacing (27.6 pt line pitch at 12 pt), as in the filed complaints; LBR 9004-1 allows up to double
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

// Counsel block, upper left, only when the filing has one. The two WVNB complaints read
// (Protea 2019, see exemplars/SOURCE.md) put counsel at the signature only, so it is optional here.
#let counsel-block(meta) = {
  if "counsel" in meta {
    set par(first-line-indent: 0pt, leading: single-leading)
    for line in meta.counsel {
      [#line\ ]
    }
    v(1.2em)
  }
}

// Paragraphs of the complaint are numbered continuously across the whole document (FRCP 10(b)).
#let para-no = counter("wvnb-para")

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  set par(first-line-indent: 0pt, leading: single-leading)
  v(1.2em)
  // "Dated" at left, signer block in a right column so long lines wrap inside it.
  block(width: 100%, breakable: false)[
    #grid(
      columns: (3.2in, 3.3in),
      [#if "date" in meta [Dated: #meta.date]],
      [
        Respectfully submitted,\
        #v(0.8em)
        #strong[s/ #sig.signer]\
        #for line in sig.lines [#line\ ]
      ],
    )
  ]
}

#let wvnb-adversary-complaint(meta, md) = {
  for k in ("court", "caption", "chapter", "case_number", "adversary_number", "complaint_title", "signature") {
    let _ = need(meta, k)
  }

  set page(paper: "us-letter", margin: margins)
  set document(
    title: need(meta, "complaint_title") + ", Adv. Pro. No. " + need(meta, "adversary_number"),
    author: need(meta, "signature").signer,
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", hyphenate: false, fallback: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  // Numbered paragraphs: the number sits on the first-line indent and the text wraps to the
  // margin (as in the filed Protea complaint). One counter runs through the whole document.
  show enum.item: it => block(width: 100%, {
    set par(first-line-indent: 0pt)
    h(para-indent)
    para-no.step()
    context para-no.display() + "."
    h(0.25in)
    it.body
  })
  set footnote.entry(separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: 10pt)
  show footnote.entry: set par(first-line-indent: 0pt)

  // Headings in a complaint are centered capitals (parts) or bold centered (counts and subparts),
  // set at body size as in the filed complaint.
  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 0.8em, sticky: true,
    align(center, strong(text(size: type-size, upper(it.body)))))
  show heading.where(level: 2): it => block(width: 100%, above: 1em, below: 0.6em, sticky: true,
    align(center, strong(text(size: type-size, it.body))))

  // Running footer: page number on every page.
  set page(footer: context {
    set text(size: 10pt)
    align(center, counter(page).display())
  })

  counsel-block(meta)
  court-caption(meta)

  // A line `@@after-signature@@` in the sample starts the part that follows the signature
  // (the filed Protea complaint puts Schedule 1 on its own page after the signature).
  let parts = md.split("@@after-signature@@")
  cmarker.render(parts.at(0), raw-typst: false, smart-punctuation: true)
  signature-block(meta)
  for tail in parts.slice(1) {
    pagebreak(weak: true)
    cmarker.render(tail, raw-typst: false, smart-punctuation: true)
  }
}
