// N.D. W. Va. Bankruptcy Court: adversary complaint (FRBP 7001 et seq.).
// Every number below traces to a rule; README.md has the rule, URL and date verified.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---- parameters ----
#let font-family = ("Times New Roman", "Liberation Serif")   // Times New Roman substitute per docs/FONTS.md, vendored in /fonts; no system font is ever used
#let type-size = 12pt              // LBR 9004-1 (search excerpt, see README): minimum 10 pt; 12 pt used
#let para-indent = 0.5in           // FRCP 10(b) numbered paragraphs: the number at the first-line indent
#let number-box = 0.5in            // the paragraph number's box; the text then wraps to the margin
#let margins = (top: 1in, bottom: 1in, left: 1in, right: 1in)  // LBR 9004-1 is silent on margins; 1 in is the convention
#let caption-left = 3.2in          // caption: the party column (rule on its right and bottom); the case column is the rest
#let caption-inset = 0.15in        // the party text stands off the caption's right rule
#let caption-rule = 0.75pt         // the caption's rules; Word adds the bottom rule's width to the caption's height
#let right-inset = 0.25in          // the case information stands off the rule
#let debtor-indent = 0.4in         // "Debtor." under the debtor's name
#let role-indent = 0.1in           // a side's designation ("Plaintiffs,") under its names
#let v-indent = 1.5in              // "v." in the party column
#let sig-column = 3.2in            // the signature's right-hand column starts this far in

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-body = 27.6pt           // double spacing: Word's double line in this face at 12 pt (2 x 13.8 pt), as in the filed complaint; LBR 9004-1 allows up to double
#let pitch-single = 13.8pt         // a single line: 1.15 x the type size (caption, headings, signature, schedule, footer)
#let gap = pitch-single            // between the caption's groups, around the title and the headings
#let cell-inset = 5.4pt            // a schedule table cell's text stands off its rules (Word's 108-twip cell margin)
#let rule = 0.5pt                  // a schedule table rule; Word sets each row a rule below the one above it

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

/// One single-spaced paragraph with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: left, body)
})

// FRCP 10(a): caption has the court name, a title, a file number, and a Rule 7(a) designation.
// FRBP 9004(b): caption names the court, the case title, the case and adversary-proceeding numbers,
// and a brief designation of the document. FRBP 7010: the caption substantially conforms to Form 416.
#let court-caption(meta) = {
  let court = need(meta, "court")
  for (i, l) in court.enumerate() {
    line-block(below: if i == court.len() - 1 { gap } else { 0pt }, align(center, strong(upper(l))))
  }
  let sides = need(meta, "caption")
  let left = {
    if "debtor" in meta {
      line-block[In re: #meta.debtor.name,]
      line-block(left: debtor-indent, below: gap)[Debtor.]
    }
    for (i, side) in sides.enumerate() {
      if i > 0 { line-block(left: v-indent, below: gap)[v.] }
      for n in side.names { line-block(n) }
      line-block(left: role-indent, below: gap, side.designation)
    }
  }
  let right = {
    line-block(below: gap)[Chapter #need(meta, "chapter")]
    line-block[Case No. #need(meta, "case_number")]
    if "judge" in meta { line-block[Judge #meta.judge] }
    line-block(above: gap)[Adv. Pro. No. #need(meta, "adversary_number")]
    if "adversary_title" in meta { line-block(meta.adversary_title) }
  }
  block(above: 0pt, below: 0pt, grid(
    columns: (caption-left, 1fr),
    block(width: 100%, stroke: (right: caption-rule, bottom: caption-rule), inset: (right: caption-inset, bottom: gap + caption-rule), left),
    pad(left: right-inset, top: gap, right),
  ))
  line-block(above: gap, below: gap, align(center, strong(upper(need(meta, "complaint_title")))))
}

// Counsel block, upper left, only when the filing has one. The filed WVNB complaint (Protea 2019, see
// usage/SOURCE.md) puts counsel at the signature only, so it is optional here.
#let counsel-block(meta) = {
  if "counsel" in meta {
    for (i, l) in meta.counsel.enumerate() {
      line-block(below: if i == meta.counsel.len() - 1 { gap } else { 0pt }, l)
    }
  }
}

// Paragraphs of the complaint are numbered continuously across the whole document (FRCP 10(b)).
#let para-no = counter("wvnb-para")

// "Dated" at the margin and the signer's block in the right-hand column, single-spaced, kept together.
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, breakable: false, above: pitch-body, below: 0pt, {
    line-block[#box(width: sig-column, if "date" in meta [Dated: #meta.date])Respectfully submitted,]
    line-block(above: gap, left: sig-column, strong[s/ #sig.signer])
    for l in sig.lines { line-block(left: sig-column, l) }
  })
}

// An item of a loose list (blank lines between the items) ends in a paragraph break; inside the numbered paragraph it
// means nothing, so it is dropped.
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

#let wvnb-adversary-complaint(meta, md) = {
  for k in ("court", "caption", "chapter", "case_number", "adversary_number", "complaint_title", "signature") {
    let _ = need(meta, k)
  }

  // A centered page number on every page, in a single-spaced line box (Word's footer).
  set page(paper: "us-letter", margin: margins, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set document(
    title: need(meta, "complaint_title") + ", Adv. Pro. No. " + need(meta, "adversary_number"),
    author: need(meta, "signature").signer,
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number ("§§ 547"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)

  // Numbered paragraphs: the number in a half-inch box at the first-line indent, the text after it, wrapping to the
  // margin (as in the filed Protea complaint). One counter runs through the whole document.
  show enum: it => for item in it.children {
    block(width: 100%, above: 0pt, below: 0pt, par[#box(width: number-box)[#para-no.step()#context para-no.display("1.")]#unloose(item.body)])
  }

  // Headings in a complaint are centered and bold (parts in capitals), single-spaced, a single line from the text on
  // either side, kept with the text after them.
  show heading: it => block(width: 100%, above: gap, below: gap, sticky: true, {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt)
    align(center, strong(if it.level == 1 { upper(it.body) } else { it.body }))
  })

  // A schedule table (cmarker sets its columns auto): equal columns across the text width, ruled, single-spaced
  // cells, the header row bold.
  show table: it => if not it.columns.all(c => c == auto) { it } else {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    show table.cell.where(y: 0): strong
    table(columns: (1fr,) * it.columns.len(), inset: (x: cell-inset, top: rule, bottom: 0pt), stroke: rule, align: left,
      ..it.children)
  }

  counsel-block(meta)
  court-caption(meta)

  // An attachment (a level-2 heading "Schedule ...") follows the signature block on a page of its own,
  // as the filed complaints do. The heading itself is the marker: no template-local text is needed in the sample.
  let cut = md.position("\n## Schedule")
  if cut == none {
    cmarker.render(md, raw-typst: false, smart-punctuation: true)
    signature-block(meta)
  } else {
    cmarker.render(md.slice(0, cut), raw-typst: false, smart-punctuation: true)
    signature-block(meta)
    pagebreak(weak: true)
    cmarker.render(md.slice(cut + 1), raw-typst: false, smart-punctuation: true)
  }
}
