// uscgcoca opening brief: "Assignments of Error and Brief on Behalf of Appellant".
// Governing rules: CGCCA Rules of Appellate Procedure with JRAP (Rev. 03/25). That PDF was NOT readable
// from this box (uscg.mil returned 403). The only rule text read is 32 CFR 150.15 (Federal Register,
// 62 FR 2017, 15 Jan 1997; superseded in part), which settles: typed, double-spaced (150.15(a)); the
// Appendix B order (caption, case block, Statement of the Case, Statement of Facts, Errors and Argument,
// signature, certificate of filing and service). Everything marked UNVERIFIED is a placeholder.
#import "@preview/cmarker:0.1.10"

// ---- rule parameters ----
#let typeface = "EB Garamond"        // UNVERIFIED: the rule's typeface requirement was not read
#let body-size = 12pt                // UNVERIFIED: point size not in 32 CFR 150
#let margin = 1in                    // UNVERIFIED: margins not in 32 CFR 150
#let body-leading = 1.3em            // 150.15(a) double-spaced; exact spacing value UNVERIFIED
#let single-leading = 0.65em         // block quotes, caption, signature, certificate

#let court-name = "United States Coast Guard Court of Criminal Appeals"  // App. B, footnote 1
#let brief-title = "Assignments of Error and Brief on Behalf of Appellant" // App. B, item 2

// Caption: "United States v. <accused>, Appellant" (App. B, item 1).
#let caption-block(meta) = {
  align(center)[#text(weight: "bold")[In the #court-name]]
  v(0.6em)
  for (i, side) in meta.caption.enumerate() {
    if i > 0 { align(center)[v.] }
    align(center)[
      #for n in side.names [#n \ ]
      #side.designation
    ]
  }
}

#let uscgcoca-brief(meta, body) = {
  set document(title: meta.at("brief_title", default: brief-title), author: "")
  set page(
    paper: "us-letter",
    margin: margin,
    numbering: "1",
    footer: context align(center, text(size: body-size, counter(page).display())),
  )
  set text(font: typeface, size: body-size)
  set par(justify: false, first-line-indent: 0pt, leading: body-leading, spacing: body-leading)

  // sticky: a heading never ends a page, so it stays with the text that follows it.
  show heading.where(level: 1): it => block(sticky: true, width: 100%)[
    #set par(leading: single-leading)
    #align(center, text(weight: "bold", it.body))
    #v(body-leading)
  ]
  show heading.where(level: 2): it => block(sticky: true, width: 100%)[
    #set par(leading: single-leading)
    #text(weight: "bold", it.body)
    #v(body-leading)
  ]

  caption-block(meta)
  v(1.2em)
  align(center)[#text(weight: "bold")[#meta.brief_title]]
  v(0.6em)
  if "proceeding" in meta { align(center)[#set par(leading: single-leading); #meta.proceeding] }
  v(1.2em)

  // Counsel block (App. B, item 7: name, and rank, address and telephone of counsel).
  set par(leading: single-leading)
  for g in meta.at("counsel", default: ()) {
    for n in g.names { [#n \ ] }
    for l in g.at("lines", default: ()) { [_#l _ \ ] }
    v(0.8em)
  }

  set par(leading: body-leading)
  cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1)

  // Signature (App. B, item 7).
  if "signature" in meta {
    v(1.5em)
    block(width: 3.2in, breakable: false)[
      #set par(leading: single-leading)
      #line(length: 100%)
      #meta.signature.signer \
      #for l in meta.signature.at("lines", default: ()) { [#l \ ] }
      #if "date" in meta [#meta.date]
    ]
  }

  // Certificate of filing and service (App. B, item 8; wording from the 1997 rule).
  pagebreak(weak: true)
  align(center)[#text(weight: "bold")[CERTIFICATE OF FILING AND SERVICE]]
  v(1em)
  par(leading: body-leading)[
    I certify that a copy of the foregoing was mailed or delivered to the Court and opposing counsel
    on #meta.at("date", default: "__________").
  ]
  v(2em)
  block(width: 3.2in, breakable: false)[
    #set par(leading: single-leading)
    #line(length: 100%)
    #meta.at("signature", default: (signer: "", lines: ())).signer
  ]
}
