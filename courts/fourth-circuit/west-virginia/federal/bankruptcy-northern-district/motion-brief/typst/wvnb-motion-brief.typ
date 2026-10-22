// N.D. W. Va. Bankruptcy Court: motion with memorandum (FRBP 9013; LBR 9013-1).
// Every number below traces to a rule; README.md has the rule, URL and date verified.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---- parameters ----
#let font-family = ("Times New Roman", "Liberation Serif")   // Times New Roman substitute per docs/FONTS.md, vendored in /fonts; no system font is ever used
#let type-size = 12pt              // LBR 9004-1 (search excerpt, see README): minimum 10 pt; 12 pt used
#let footnote-size = 10pt          // footnotes (LBR 9004-1's 10 pt minimum)
#let para-indent = 0.5in
#let margins = (top: 1in, bottom: 1in, left: 1in, right: 1in)  // LBR 9004-1 is silent on margins; 1 in is the convention
#let page-limit = 25               // LBR 9004-1 (search excerpt, see README): motions, briefs and memoranda
#let caption-left = 3.2in          // caption: the party column (rule on its right and bottom); the case column is the rest
#let caption-inset = 0.15in        // the party text stands off the caption's right rule
#let caption-rule = 0.75pt         // the caption's rules; Word adds the bottom rule's width to the caption's height
#let right-inset = 0.25in          // the case information stands off the rule
#let debtor-indent = 0.4in         // "Debtor." under the debtor's name
#let role-indent = 0.1in           // a side's designation ("Plaintiff,") under its names
#let v-indent = 1.5in              // "v." in the party column
#let notice-inset = 10pt           // the negative notice's text stands off its box
#let notice-rule = 0.75pt          // the negative notice's box; Word adds its top and bottom rules to the box's height
#let quote-inset = 0.5in           // block quotations, both sides
#let sig-column = 3.2in            // signature blocks start this far in from the left margin

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-body = 18pt             // about 1.5 spacing: inside LBR 9004-1's single-to-double range (see README)
#let pitch-single = 13.8pt         // a single line: 1.15 x the type size (caption, notice, headings, quotations, signature, certificate, footer)
#let pitch-note = 11.5pt           // a footnote line: 1.15 x the footnote size
#let gap = pitch-single            // between the caption's groups, around the title, the notice, headings and quotations
#let small-gap = gap / 2           // below a heading, inside the notice, between quoted paragraphs and served parties
#let note-gap = 6pt                // after each footnote (Word: Footnote Text's space after)
#let note-clearance = 7.8pt        // between the text and the footnote rule: with note-gap, the 13.8 pt single line of Word's separator

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

/// Inline markdown (a frontmatter value): smart quotes and emphasis, as pandoc reads it in the docx engine.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced paragraph with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: left, body)
})

// FRCP 10(a) and FRBP 9004(b): court name, title of the case, case and adversary numbers, designation.
// FRBP 7010: the caption substantially conforms to Form 416 (see README on the form number).
#let court-caption(meta) = {
  let court = need(meta, "court")
  for (i, l) in court.enumerate() {
    line-block(below: if i == court.len() - 1 { gap } else { 0pt }, align(center, upper(inl(l))))
  }
  let sides = need(meta, "caption")
  let left = {
    if "debtor" in meta {
      line-block[In re: #inl(meta.debtor.name),]
      line-block(left: debtor-indent, below: gap)[Debtor.]
    }
    for (i, side) in sides.enumerate() {
      if i > 0 { line-block(left: v-indent, below: gap)[v.] }
      for n in side.names { line-block(inl(n)) }
      line-block(left: role-indent, below: gap, inl(side.designation))
    }
  }
  let right = {
    if "chapter" in meta { line-block(below: gap)[Chapter #inl(meta.chapter)] }
    line-block[Case No. #need(meta, "case_number")]
    if "judge" in meta { line-block[Judge #inl(meta.judge)] }
    line-block(above: gap)[Adv. Pro. No. #need(meta, "adversary_number")]
    if "motion_docket" in meta { line-block[Motion Docket No. #inl(meta.motion_docket)] }
  }
  block(above: 0pt, below: 0pt, grid(
    columns: (caption-left, 1fr),
    block(width: 100%, stroke: (right: caption-rule, bottom: caption-rule),
      inset: (right: caption-inset, bottom: gap + caption-rule), left),
    pad(left: right-inset, top: gap, right),
  ))
  line-block(above: gap, below: gap, align(center, strong(upper(inl(need(meta, "motion_title"))))))
}

// Counsel block, upper left (convention; the rules text read does not set a position).
// Optional: a filing that gives counsel only in its signature block omits `counsel`.
#let counsel-block(meta) = {
  if "counsel" in meta {
    for (i, l) in meta.counsel.enumerate() {
      line-block(below: if i == meta.counsel.len() - 1 { gap } else { 0pt }, inl(l))
    }
  }
}

// LBR 9013-1(c)(2)(B): negative notice, "...an order may be entered granting the relief sought unless
// a specific written objection is filed within ___ days of the date of the mailing of this notice."
// The number of days and the mailing date come from the sample; the template prints them as given.
#let negative-notice(meta) = {
  if "notice" in meta {
    block(width: 100%, breakable: false, above: gap, below: gap, stroke: notice-rule,
      inset: (x: notice-inset, top: notice-inset + notice-rule, bottom: notice-inset + notice-rule), {
        line-block(below: small-gap, strong[NOTICE OF OPPORTUNITY TO OBJECT])
        line-block(inl(meta.notice.text))
      })
  }
}

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, breakable: false, above: gap, below: 0pt, {
    if "date" in meta { line-block(below: gap)[Dated: #inl(meta.date)] }
    line-block(left: sig-column, below: gap)[Respectfully submitted,]
    // Optional party lines above the signature (e.g. "DAVID A. LEVINE" / "By Counsel").
    for l in sig.at("parties", default: ()) { line-block(left: sig-column, inl(l)) }
    line-block(left: sig-column, strong[s/ #inl(sig.signer)])
    for l in sig.lines { line-block(left: sig-column, inl(l)) }
  })
}

// LBR 9013-1(c)(3): a certificate of service is used when required. The method and recipients come
// from the sample; "all creditors on the mailing matrix" wording is used only when the sample asks for it.
#let certificate-of-service(meta) = {
  let svc = need(meta, "service")
  let sig = need(meta, "signature")
  line-block(below: gap, align(center, strong(upper("Certificate of Service"))))
  // `text` gives the certificate sentence as filed; otherwise the template builds it from date and method.
  line-block(below: gap, if "text" in svc [#inl(svc.text)] else [I certify that on #inl(svc.date), I #inl(svc.method) the foregoing #inl(need(meta, "motion_title")) and this certificate of service, which were served on the following parties:])
  // Parties are listed only when the filing lists them; the CM/ECF certificate lists none.
  for p in svc.at("parties", default: ()) {
    block(width: 100%, breakable: false, above: small-gap, below: small-gap, {
      line-block(inl(p.name))
      for l in p.at("lines", default: ()) { line-block(inl(l)) }
    })
  }
  block(width: 100%, breakable: false, above: gap, below: 0pt, {
    line-block(left: sig-column, strong[s/ #inl(sig.signer)])
    for l in sig.lines { line-block(left: sig-column, inl(l)) }
  })
}

#let wvnb-motion-brief(meta, md) = {
  for k in ("court", "caption", "case_number", "adversary_number", "motion_title", "signature", "service") {
    let _ = need(meta, k)
  }

  // A centered page number on every page, in a single-spaced line box (Word's footer).
  set page(paper: "us-letter", margin: margins, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set document(
    title: need(meta, "motion_title") + ", Adv. Pro. No. " + need(meta, "adversary_number"),
    author: need(meta, "signature").signer,
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number ("§§ 544(b)"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)

  // Footnotes: 10 pt, single-spaced; the mark, a space, the note (Word's footnote layout); a note is not split
  // over pages (Word keeps Footnote Text's lines together: the line that anchors it moves on instead).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: footnote-size, ..edges(pitch-note))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt, spacing: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    block(breakable: false)[#super(num) #note.body]
  }

  // Body headings, as the author types them (no numbers are generated): single-spaced and bold, a single line above
  // and half a line below, kept with the text; level 1 centered capitals, level 2 centered, level 3 at the margin.
  show heading: it => block(width: 100%, above: gap, below: small-gap, sticky: true, {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt)
    let t = strong(if it.level == 1 { upper(it.body) } else { it.body })
    if it.level <= 2 { align(center, t) } else { t }
  })

  // Block quotations: indented on both sides, single-spaced, half a line between their paragraphs.
  show quote.where(block: true): it => block(width: 100%, above: gap, below: gap, pad(x: quote-inset, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, spacing: small-gap)
    it.body
  }))

  counsel-block(meta)
  court-caption(meta)
  negative-notice(meta)

  cmarker.render(md, raw-typst: false, smart-punctuation: true)
  signature-block(meta)

  pagebreak()
  certificate-of-service(meta)
}
