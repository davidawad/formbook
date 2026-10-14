// N.D. W. Va. Bankruptcy Court: motion with memorandum (FRBP 9013; LBR 9013-1).
// Every number below traces to a rule; README.md has the rule, URL and date verified.
#import "@preview/cmarker:0.1.10"

// ---- parameters ----
#let font-family = "EB Garamond"   // vendored in /fonts; no system font is ever used
#let type-size = 12pt              // LBR 9004-1 (search excerpt, see README): minimum 10 pt; 12 pt used
#let body-leading = 0.85em         // ~1.5 spacing: inside LBR 9004-1's single-to-double range (see README)
#let single-leading = 0.3em        // caption, counsel block, notice, signature, certificate, footer
#let para-indent = 0.5in
#let margins = (top: 1in, bottom: 1in, left: 1in, right: 1in)  // LBR 9004-1 is silent on margins; 1 in is the convention
#let page-limit = 25               // LBR 9004-1 (search excerpt, see README): motions, briefs and memoranda

// ---- helpers ----
#let need(meta, key) = {
  if key not in meta { panic("wvnb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wvnb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// FRCP 10(a) and FRBP 9004(b): court name, title of the case, case and adversary numbers, designation.
// FRBP 7010: the caption substantially conforms to Form 416 (see README on the form number).
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
      #if "motion_docket" in meta [Motion Docket No. #meta.motion_docket\ ]
    ],
  )
  v(1.2em)
  align(center, strong(upper(need(meta, "motion_title"))))
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

// LBR 9013-1(c)(2)(B): negative notice, "...an order may be entered granting the relief sought unless
// a specific written objection is filed within ___ days of the date of the mailing of this notice."
// The number of days and the mailing date come from the sample; the template prints them as given.
#let negative-notice(meta) = {
  if "notice" in meta {
    let n = meta.notice
    block(width: 100%, breakable: false, stroke: 0.75pt, inset: 10pt)[
      #set par(first-line-indent: 0pt, leading: single-leading)
      #strong[NOTICE OF OPPORTUNITY TO OBJECT]\
      #v(0.5em)
      #n.text
    ]
    v(1.2em)
  }
}

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

// LBR 9013-1(c)(3): a certificate of service is used when required. The method and recipients come
// from the sample; "all creditors on the mailing matrix" wording is used only when the sample asks for it.
#let certificate-of-service(meta) = {
  let svc = need(meta, "service")
  set par(first-line-indent: 0pt, leading: single-leading)
  align(center, strong(upper("Certificate of Service")))
  v(0.8em)
  block(width: 100%)[
    I certify that on #svc.date, I #svc.method the foregoing #need(meta, "motion_title") and this
    certificate of service, which were served on the following parties:
  ]
  v(0.8em)
  for p in svc.parties [
    #block(width: 100%, breakable: false)[#p.name\ #for line in p.lines [#line\ ]]
    #v(0.6em)
  ]
  v(0.8em)
  block(width: 100%, breakable: false)[
    #h(3.2in)#strong[s/ #need(meta, "signature").signer]\
    #for line in need(meta, "signature").lines [#h(3.2in)#line\ ]
  ]
}

#let wvnb-motion-brief(meta, md) = {
  for k in ("court", "caption", "chapter", "case_number", "adversary_number", "motion_title", "counsel", "signature", "service") {
    let _ = need(meta, k)
  }

  set page(paper: "us-letter", margin: margins)
  set document(
    title: need(meta, "motion_title") + ", Adv. Pro. No. " + need(meta, "adversary_number"),
    author: need(meta, "signature").signer,
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", hyphenate: false, fallback: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set footnote.entry(separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: 10pt)
  show footnote.entry: set par(first-line-indent: 0pt)

  // Body headings: centered capitals (sections). The author types the heading text; no numbers are generated.
  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 0.8em, sticky: true,
    align(center, strong(upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, above: 1em, below: 0.6em, sticky: true,
    align(center, strong(it.body)))

  set page(footer: context {
    set text(size: 10pt)
    align(center, counter(page).display())
  })

  counsel-block(meta)
  court-caption(meta)
  negative-notice(meta)

  cmarker.render(md, raw-typst: false, smart-punctuation: true)
  signature-block(meta)

  pagebreak()
  certificate-of-service(meta)
}
