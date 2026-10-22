// Motion to dismiss (Rules 12(b)(1), 12(b)(6)) for the U.S. District Court for the Southern District of Texas (txsd).
// Rules: Fed. R. Civ. P. 10(a) (caption: court name, title, file number), 10(b) (numbered paragraphs, each
// limited to a single set of circumstances); the district's form rules as far as they could be retrieved (see
// ../README.md: 13-point or larger, double-spaced, 1-inch margins, 8 1/2 by 11). Content-agnostic: every
// case-specific word comes from the sample's frontmatter or body, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // no face named by S.D. Tex. LR10.2 or the judges' procedures retrieved; Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 13pt                   // Galveston Div. R. of Practice f and Judge Hanks Procs. 7.A: "13-point" (not in LR10.2; see README.md)
#let para-indent = 0.5in                // first-line indent of paragraphs; the paragraph number's box after it
#let page-margin = 1in                  // 1-inch margins on all sides
#let caption-left = 3.3in               // width of the party column of the caption
#let caption-gutter = 0.2in             // between the party column and the case-number column
#let caption-inset = 0.12in             // the party column's text stands off its right and bottom rules
#let caption-right-inset = 0.1in        // the case-number column stands off the gutter
#let item-label = 0.75in                // prayer items and numbered lists: half an inch in, the label in a box of this
#let letter-label = 1in                 // lettered items (a), (b): the label in a box of this at the margin
#let sig-left = 3.25in                  // the signature block stands 3.25 inches in
#let toc-page-col = 36pt                // contents: the page numbers keep the last 36 pt of the line to themselves

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips, 20 x pt).
#let pitch-double = 26pt                // LR10.2: double spaced, 2 x the type size (520 twips)
#let pitch-single = 14.95pt             // single spacing (court title, caption, signature): 1.15 x the size (299 twips)
#let cover-gap = 17.5pt                 // between the court title and the caption, after the title, after the date (350 twips)
#let caption-gap = 7.7pt                // between the party rows of the box caption (154 twips)
#let sig-above = 8.75pt                 // above the signature block, and after its lead and party lines (175 twips)
#let sig-by-gap = 6.5pt                 // after the "By" line (130 twips)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("txsd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in italics, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Blank-line-separated chunks of the body: a heading, a list, or a paragraph.
#let chunks(body) = body.replace("\r\n", "\n").split("\n\n").map(s => s.trim()).filter(s => s != "")

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  body
})

// ---------------------------------------------------------------------------
// Court title and caption
// ---------------------------------------------------------------------------

/// Court title (Fed. R. Civ. P. 10(a)): single-spaced, bold, centered.
#let court-title(meta) = {
  let lines = ("UNITED STATES DISTRICT COURT", "FOR THE SOUTHERN DISTRICT OF TEXAS")
  if "division" in meta and meta.division != none { lines.push(upper(meta.division)) }
  for l in lines { line-block(align(center, text(weight: "bold", l))) }
}

/// Party lines with their indent: names flush left, designation indented, "v." between parties.
#let party-rows(parties) = {
  let rows = ()
  for (k, p) in parties.enumerate() {
    if k > 0 { rows.push(("v.", 0pt)) }
    for nm in p.names { rows.push((nm, 0pt)) }
    rows.push((p.designation, para-indent))
  }
  rows
}

/// Box caption (the form used in Schott, S.D. Tex. 2026): party column closed on the right and bottom,
/// "C.A. No." and "JURY DEMANDED" at the right.
#let caption-box(meta) = {
  let rows = party-rows(meta.caption.parties)
  grid(columns: (caption-left, caption-gutter, 1fr),
    block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt),
      inset: (right: caption-inset, bottom: caption-inset), {
      for (i, r) in rows.enumerate() {
        line-block(above: if i > 0 { caption-gap } else { 0pt }, pad(left: r.at(1), inl(r.at(0))))
      }
    }),
    [],
    pad(left: caption-right-inset, {
      let cn = meta.at("case_number", default: none)
      line-block[C.A. No. #if cn != none { inl(cn) } else { h(1.6in) }]
      if meta.at("jury_demand", default: false) { line-block(above: cover-gap, [JURY DEMANDED]) }
    }),
  )
}

/// Section-symbol caption (the form used in Dangelas, S.D. Tex. Houston Div. 2026): one row per line, "§" at
/// the middle column, the civil action number and judge at the right.
#let caption-section(meta) = {
  let left = party-rows(meta.caption.parties)
  let right = ()
  let cn = meta.at("case_number", default: none)
  if cn != none { right.push("Civil Action No. " + cn) }
  if "judge" in meta and meta.judge != none { right.push(meta.judge) }
  let n = calc.max(left.len(), right.len() + 2)
  let cells = ()
  for i in range(n) {
    let lc = if i < left.len() { pad(left: left.at(i).at(1), inl(left.at(i).at(0))) } else { [] }
    let rc = if i >= 2 and i - 2 < right.len() { inl(right.at(i - 2)) } else { [] }
    cells += (line-block(lc), line-block(align(center, [§])), line-block(rc))
  }
  grid(columns: (caption-left, 0.4in, 1fr), row-gutter: 9.65pt, ..cells)
}

#let caption(meta) = block(width: 100%, above: cover-gap, below: 0pt,
  if meta.caption.style == "box" { caption-box(meta) } else { caption-section(meta) })

// ---------------------------------------------------------------------------
// Body: paragraphs (numbered or not), headings, lists
// ---------------------------------------------------------------------------

#let letters = ("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t")
#let unnumbered-headings = ("PRAYER FOR RELIEF", "JURY TRIAL DEMAND")

/// A body paragraph at the double pitch: a first-line indent, then (numbered, Fed. R. Civ. P. 10(b)) the number in
/// a box of the paragraph indent and the text after it. `keep`: kept on the page of the block after it.
#let body-par(num, content, keep: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: keep,
  par(first-line-indent: (amount: para-indent, all: true),
    if num == none { content } else { [#box(width: para-indent, [#num.])#content] }))

/// A labelled item at the double pitch: the label in a box of `label-w` at `left`, the text hanging after it.
#let label-item(left, label-w, label, content) = block(width: 100%, above: 0pt, below: 0pt, pad(left: left,
  par(first-line-indent: 0pt, hanging-indent: label-w, [#box(width: label-w, label)#content])))

/// The body. Paragraphs are numbered 1, 2, ... (Rule 10(b)) when `numbered` is true; a list is lettered (a), (b).
/// Prayer items ("A. ...") and numbered list items keep their label and are not numbered.
#let body-content(body, numbered) = {
  let n = 0
  let unnum = false
  for c in chunks(body) {
    let hm = c.match(regex("^(#{1,3})\\s+([\\s\\S]*)$"))
    let lines = c.split("\n").filter(l => l.trim() != "")
    if hm != none {
      let lvl = hm.captures.at(0).len()
      // Paragraphs under these headings are not numbered in the filed form (Schott, S.D. Tex. 2026).
      unnum = unnumbered-headings.any(t => upper(hm.captures.at(1)) == t)
      if lvl == 1 { heading(level: 1, inl(upper(hm.captures.at(1)))) } else { heading(level: 2, inl(hm.captures.at(1))) }
    } else if lines.len() > 0 and lines.at(0).match(regex("^-\\s")) != none {
      for (i, l) in lines.enumerate() {
        let t = l.match(regex("^-\\s+([\\s\\S]*)$")).captures.at(0)
        label-item(0pt, letter-label, "(" + letters.at(i) + ")", inl(t))
      }
    } else if c.match(regex("^([A-Z]|\\d+)\\.\\s")) != none {
      // A prayer item ("A. ...") or a numbered list item keeps its own label, with a hanging indent.
      let m = c.match(regex("^([A-Z]|\\d+)\\.\\s+([\\s\\S]*)$"))
      label-item(para-indent, item-label, m.captures.at(0) + ".", inl(m.captures.at(1)))
    } else if numbered and not unnum {
      n += 1
      body-par(n, inl(c))
    } else {
      // An unnumbered lead-in (WHEREFORE, the jury demand) stays with the block that follows it.
      body-par(none, inl(c), keep: unnum)
    }
  }
}

// ---------------------------------------------------------------------------
// Table of contents and certificates
// ---------------------------------------------------------------------------

#let certificates = (
  ("word_count_certificate", "CERTIFICATE OF WORD COUNT"),
  ("certificate_of_conference", "CERTIFICATE OF CONFERENCE"),
  ("certificate_of_service", "CERTIFICATE OF SERVICE"),
)

/// One contents row at the body pitch: the heading, a dot leader, the page number in its own column.
#let toc-entry(it) = listing-row(it.element.location(), it.element.body, it.page(), toc-page-col, 0pt, 0pt)

/// The table of contents: the headings of levels 1 and 2 (the certificates too) with their pages. Its title is
/// not a heading, so it is not listed in its own entries.
#let contents() = {
  block(width: 100%, above: 0pt, below: 0pt, sticky: true, align(center, text(weight: "bold", [TABLE OF CONTENTS])))
  show outline.entry: toc-entry
  outline(title: none, depth: 2, indent: 0pt)
}

// ---------------------------------------------------------------------------
// Signature block (Fed. R. Civ. P. 11(a))
// ---------------------------------------------------------------------------

/// The date at the margin, then 3.25 inches in the lead, the party, the "By" line and the signer's lines, single
/// spaced; never split across pages.
#let signature-block(sig, date) = block(width: 100%, breakable: false, above: sig-above, below: 0pt, {
  if date != none { line-block(below: cover-gap, inl(date)) }
  pad(left: sig-left, {
    if "lead" in sig and sig.lead != none { line-block(below: sig-above, inl(sig.lead)) }
    if "party" in sig and sig.party != none { line-block(below: sig-above, text(weight: "bold", inl(sig.party))) }
    if "by" in sig and sig.by != none { line-block(below: sig-by-gap, inl(sig.by)) }
    for l in sig.signer_lines { line-block(inl(l)) }
  })
})

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let txsd-motion-brief(meta, body) = {
  // Page numbers centered at the foot, arabic from the first page; the number in a single-spaced line box, so it
  // sits at the same place on every page (Word's footer).
  set page(paper: "us-letter", margin: page-margin, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("1"))))
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (double spaced).
  show: xengine.with(pitch: pitch-double, list-indent: none)
  // A doubled section sign or pilcrow ("¶¶ 27") stays with its number too, as one unbreakable box (xengine binds
  // one sign; the docx filter binds the signs with a no-break space).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // Headings at the body size and pitch, bold: level 1 centered, level 2 flush left. No space of their own (the
  // double pitch sets them off); sticky, so a heading never ends a page.
  show heading: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    let b = text(weight: "bold", it.body)
    block(sticky: true, width: 100%, above: 0pt, below: 0pt, if it.level == 1 { align(center, b) } else { b })
  }

  court-title(meta)
  caption(meta)
  // The title of the paper, bold and centered at the body pitch, a double line below the caption.
  block(width: 100%, above: pitch-double, below: cover-gap, align(center, text(weight: "bold", inl(meta.brief_title))))

  // A brief with a table of contents: the cover (caption and title) is its own page; the contents follow, the body
  // starts a new page.
  if "toc" in meta and meta.toc {
    pagebreak()
    contents()
    pagebreak()
  } else if "lead_in" in meta and meta.lead_in != none {
    body-par(none, inl(meta.lead_in))
  }

  body-content(body, false)

  if "signature" in meta and meta.signature != none {
    signature-block(meta.signature, meta.at("date", default: none))
  }

  // Certificates (Fed. R. Civ. P. 5(b)(2)(E) service through CM/ECF; word count and conference are the
  // judge's procedures where the filing cites them, so each is printed only when the sample carries the text).
  for (key, title) in certificates {
    // Each certificate (its heading, text and signature) stays on one page.
    if key in meta and meta.at(key) != none { block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
      heading(level: 1, title)
      body-par(none, inl(meta.at(key)))
      if "certificate_signature" in meta and meta.certificate_signature != none {
        line-block(above: sig-above, pad(left: sig-left, inl(meta.certificate_signature)))
      }
    }) }
  }
}
