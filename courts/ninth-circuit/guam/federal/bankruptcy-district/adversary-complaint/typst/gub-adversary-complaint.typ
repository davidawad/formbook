// Adversary complaint for the United States Bankruptcy Court, District of Guam (gub).
// Rules: GNLR 5.1 (paper, page numbers at the bottom, double spacing, counsel block upper left, court title
// at least 3 inches from the top, right-hand case information); Fed. R. Bankr. P. 7010 (caption per
// Official Form 416), 7008(a) (statement of consent to final orders), 9004(b) (caption contents), 9011(a)
// (signer's address and telephone). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // GNLR 5.1 names no face or size; the house standard (data/exemplar-fonts.json template_face), the exemplar a Times
#let type-size = 12pt                   // the exemplar is 12 pt Times
#let pitch = 24pt                       // GNLR 5.1(a): double-spaced; the numbered lines are this pitch
#let pitch-single = pitch / 2         // single spacing (counsel, caption, signature): half a numbered line
#let grid-drop = 0.4 * pitch           // a single-spaced group starts this far into a numbered line, so its lines sit on the
                                        // line numbers' baselines and halfway between them (0.8 of the numbered line less 0.8 of a single one)
#let lines-per-page = 27                // 27 numbered lines fit between 1 in margins (the exemplar has 28, a convention, not a GNLR rule)
#let page-w = 8.5in                     // GNLR 5.1(a): 8 1/2 by 11 inch paper
#let page-h = 11in
#let top-margin = 72pt                  // the numbered lines start at the top margin
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 72 pt: holds the page number
#let left-margin = 1.5in                // room for the line numbers and the rules
#let right-margin = 1in                 // GNLR 5.1 sets no margin; 1 in, as the default tier-1 checks require (the exemplar is narrower)
#let text-width = page-w - left-margin - right-margin
#let para-indent = 0.5in                // first-line indent of every paragraph
#let num-box = 0.5in                    // the paragraph number in a box after the indent; the text starts an inch in
#let item-indent = 0.5in                // lettered items: the letter half an inch in ...
#let item-box = 0.5in                   // ... in a box of half an inch, the lines after the first hanging after it
#let caption-left = 3.2in               // width of the party column of the caption; left of the page's centre (GNLR 5.1(c)(1))
#let caption-gutter = 0.2in             // between the party column and the case information
#let caption-inset = 10pt               // the party text stands off the caption's right rule
#let caption-pad = 8pt                  // the caption's bottom rule below the last party line
#let right-inset = 0.1in                // the case information stands off the gutter
#let counsel-lines = 8                  // GNLR 5.1(b): the court title starts at least 3 in from the top (line 9 here)
#let sig-left = 2.8in                   // the signature column (GNLR 5.1(d))
#let foot-size = 10pt                   // the page number and the paper's title below the numbered lines
#let foot-pitch = 11.5pt                // their lines: 1.15 x the size
#let foot-gap = 4pt                     // between the page number and the title
#let foot-top = top-margin + lines-per-page * pitch + 6pt   // the page number's line, 6 pt below the last numbered line

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("gub-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it. An empty line
/// keeps its height.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below,
  height: if body == "" or body == [] { pitch-single } else { auto }, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    if type(body) == str { inl(body) } else { body }
  })

/// A paragraph at the numbered-line pitch. `keep`: kept whole on the page of the block after it.
#let body-par(content, keep: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: keep, breakable: not keep,
  par(first-line-indent: 0pt, content))

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Numbers 1 to 27 down the left margin, one per numbered line, each in a line box of the pitch.
#let line-numbers() = {
  for i in range(1, lines-per-page + 1) {
    place(top + left, dx: 0pt, dy: top-margin + (i - 1) * pitch,
      block(width: left-margin - 0.5in, height: pitch,   // numbers end at the 1 in line, inside the margin
        align(right, text(font: font-family, size: type-size, ..edges(pitch), str(i)))))
  }
}

/// The pleading rules: a double rule at the text's left edge, a single rule at its right.
#let pleading-rules() = {
  place(top + left, dx: left-margin - 0.2in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: left-margin - 0.16in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: page-w - right-margin + 0.1in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
}

/// GNLR 5.1(a): all pages numbered consecutively at the bottom; the paper's title under the number.
#let footer-block(title) = place(top + left, dx: left-margin, dy: foot-top, block(width: text-width, {
  set text(font: font-family, size: foot-size, ..edges(foot-pitch))
  set par(leading: 0pt, spacing: 0pt, first-line-indent: 0pt)
  block(width: 100%, above: 0pt, below: 0pt, align(center, context counter(page).display("1")))
  block(width: 100%, above: foot-gap, below: 0pt, align(left, upper(title)))
}))

// ---------------------------------------------------------------------------
// Cover: counsel (upper left), court title, caption, title of the paper
// ---------------------------------------------------------------------------

/// Counsel identification, upper left (GNLR 5.1(c)(1)), single-spaced. The block occupies `counsel-lines` numbered
/// lines, so the court title starts at or below the 3-inch line of GNLR 5.1(b).
#let counsel-block(meta) = block(width: 100%, height: counsel-lines * pitch, above: 0pt, below: 0pt, clip: true,
  pad(top: grid-drop, for l in meta.counsel { line-block(l) }))

/// GNLR 5.1(b): the court title, centred, one numbered line each. Not case-specific.
#let court-title() = {
  for l in ("IN THE DISTRICT COURT OF GUAM", "TERRITORY OF GUAM", "BANKRUPTCY DIVISION") {
    block(width: 100%, above: 0pt, below: 0pt, align(center, text(weight: "bold", l)))
  }
}

/// The caption's party column: the debtor ("In re:"), then each party with "v." between the parties.
#let party-rows(caption) = {
  let rows = ()
  if "debtor" in caption {
    rows.push("In re:")
    rows += caption.debtor.names + (caption.debtor.designation,)
    rows.push("")
  }
  for (k, p) in caption.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names + (p.designation,)
  }
  rows
}

/// The right-hand case information (GNLR 5.1(c)(3)): the chapter, the case number, the designation "Adversary
/// Proceeding", the adversary number, and the title of the paper; a single line between the groups.
#let case-info(meta) = {
  if "chapter" in meta { line-block(meta.chapter) }
  line-block("Case No. " + meta.case_number)
  line-block(above: pitch-single, "Adversary Proceeding")
  line-block("Adv. Proc. No. " + meta.adversary_number)
  line-block(above: pitch-single, text(weight: "bold", inl(meta.brief_title)))
  if "jury_demand" in meta and meta.jury_demand {
    line-block(above: pitch-single, text(weight: "bold", "DEMAND FOR JURY TRIAL"))
  }
}

/// The caption a numbered line below the court title: the party column ruled at its right and foot (the rule as
/// tall as the row, as Word draws a cell's border), the case information beside it.
#let caption(meta) = block(width: 100%, above: pitch, below: 0pt, grid(
  columns: (caption-left, 1fr),
  column-gutter: caption-gutter,
  stroke: (x, y) => if x == 0 { (right: 0.75pt, bottom: 0.75pt) },
  // the rule's width sits below every cell of the row, as LibreOffice adds a cell's bottom border to the row height
  inset: (x, y) => if x == 0 { (top: grid-drop, right: caption-inset, bottom: caption-pad) } else {
    (top: grid-drop, left: right-inset, bottom: 0.75pt) },
  { for r in party-rows(meta.caption) { line-block(r) } },
  case-info(meta),
))

#let cover(meta) = {
  counsel-block(meta)
  court-title()
  caption(meta)
  pagebreak()
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// A heading: one numbered line, centred and bold (level 1 in capitals), kept with the block after it.
#let heading-line(lvl, c) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
  set par(first-line-indent: 0pt)
  align(center, text(weight: "bold", if lvl == 1 { upper(c) } else { c }))
})

/// Lettered items (a), (b), ...: the letter half an inch in, in a box of half an inch, the lines after the first
/// hanging after it; a continuation line joins the item before it.
#let lettered(t, keep) = {
  let items = ()
  for l in t.split("\n") {
    let m = l.match(regex("^\\s*(\\d+\\.|[-*+])\\s+(.*)$"))
    if m != none { items.push(m.captures.at(1)) } else if items.len() > 0 { items.last() += " " + l.trim() }
  }
  for (i, it) in items.enumerate() {
    let lab = "(" + numbering("a", i + 1) + ")"
    block(width: 100%, above: 0pt, below: 0pt, sticky: keep and i == items.len() - 1,
      breakable: not (keep and i == items.len() - 1), pad(left: item-indent,
        par(first-line-indent: 0pt, hanging-indent: item-box, [#box(width: item-box, lab)#inl(it)])))
  }
}

/// Numbered paragraphs. Each blank-line-separated chunk of markdown that is neither a heading nor a list is one
/// numbered paragraph (Fed. R. Civ. P. 10(b), as applied by Fed. R. Bankr. P. 7010), the number in a box after
/// the indent. A chunk that starts with "§ " is unnumbered text (the lead-in of a prayer, the signing line), kept
/// with the block after it. Headings are kept with the block after them; the last block stays with the signature.
#let allegations(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let n = 0
  for (i, raw-t) in chunks.enumerate() {
    let last = i == chunks.len() - 1
    let marker = raw-t.match(regex("^§ "))
    let t = if marker != none { raw-t.slice(marker.end) } else { raw-t }
    if t.starts-with("#") {
      let lvl = t.match(regex("^#+")).text.len()
      heading-line(lvl, inl(t.replace(regex("^#+[ \\t]*"), "")))
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      lettered(t, last)
    } else if marker != none {
      body-par(keep: true, [#h(para-indent)#inl(t)])
    } else {
      n += 1
      body-par(keep: last, [#h(para-indent)#box(width: num-box, [#n.])#inl(t)])
    }
  }
}

/// The signature in the right column, a single line below the text (on the grid of the line numbers): the firm lines, a single line, "/s/" and the
/// signer, the signer's name and lines; never broken across a page.
#let signature-block(meta) = block(width: 100%, breakable: false, above: pitch-single + grid-drop, below: 0pt, pad(left: sig-left, {
  for l in meta.signature.firm { line-block(l) }
  line-block(above: pitch-single, "/s/ " + meta.signature.signer)
  line-block(meta.signature.signer)
  for l in meta.signature.lines { line-block(l) }
}))

#let gub-adversary-complaint(meta, body) = {
  // Fed. R. Bankr. P. 7008(a): an adversary complaint must state whether the pleader consents to the entry
  // of final orders or judgment by the bankruptcy court. The check is on the text, so a sample without it fails.
  assert(body.contains("consent to the entry of final orders"),
    message: "gub-adversary-complaint: the complaint must state consent to the entry of final orders (Fed. R. Bankr. P. 7008(a))")

  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    foreground: footer-block(meta.footer_title),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // numbered-line pitch (GNLR 5.1(a): double-spaced).
  show: xengine.with(pitch: pitch)
  // A doubled section sign stays with its number (xengine binds a single sign), as the docx filter binds it.
  show regex("[§¶]{2,} \\S+"): it => box(it)

  cover(meta)
  if "lead_in" in meta { body-par[#h(para-indent)#inl(meta.lead_in)] }
  allegations(body)
  signature-block(meta)
}
