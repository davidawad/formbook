// Adversary complaint for the United States Bankruptcy Court, District of Oregon (orb).
// Rules: LBR 9004-1(a) (form of documents: size, margins, type, double spacing, counsel block, footer with the
// title and the page number), LBR 9004-2(c) (adversary proceeding caption), LBR 7001-1 (complaint filed with fee,
// cover sheet, summons: not on the page, see README.md). FRBP 7008(a) and FRBP 7001 are stated in the sample text.
// See ../README.md for the rule text, the date verified, and the known gaps.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")          // vendored in fonts/; the render never falls back to a system font
#let type-size = 12pt                     // LBR 9004-1(a)(1)(B): no smaller than 12 point (footer included)
#let page-w = 8.5in                       // LBR 9004-1(a)(1)(A)
#let page-h = 11in
#let margin-top = 1in                     // LBR 9004-1(a)(2): top and bottom at least 1 inch
#let margin-bottom = 1in
#let margin-side = 0.75in                 // LBR 9004-1(a)(2): sides at least 3/4 inch
#let text-width = page-w - 2 * margin-side

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/orb-complaint.lua sets the same twips).
#let pitch-body = 24pt                    // LBR 9004-1(a)(4)(A): body text double-spaced (docx 480)
#let pitch-single = 13.8pt                // counsel block, caption, signature, footer: single spacing (docx 276)
#let blank = 24pt                         // one blank double line: counsel to court title, court title to caption,
                                          // caption to the body
#let para-indent = 0.5in                  // first-line indent of numbered allegations and of the lead-in
#let num-box = 0.5in                      // an allegation's number (or a prayer item's letter) in a box this wide
#let caption-left = 3.4in                 // party column of the LBR 9004-2(c) caption
#let caption-pad = 6pt                    // the caption's text to its rules
#let sig-indent = 3in                     // the signature block, 3 in from the left margin
#let footer-foot = 0.35in                 // the footer's last line ends this far above the bottom edge (docx footer 504)
#let footer-gap = 2pt                     // the title to "Page N of M"

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("orb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline and block markdown from a string (names with *et al.*, the lead-in, and the like).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// Single-spaced lines, one paragraph each; an empty item is a blank single line. `above`: space above the first.
#let lines(items, above: 0pt) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt, hanging-indent: 0pt)
  let gap = above
  for i in items {
    if i == "" { gap += pitch-single } else {
      block(width: 100%, above: gap, below: 0pt, if type(i) == str { md(i) } else { i })
      gap = 0pt
    }
  }
}

/// Body chunks: blank-line-separated markdown blocks.
#let chunks(body) = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// LBR 9004-1(a)(9)(D): the title (or an abbreviation) and the page number, in the lower-left margin; single lines,
/// the last one ending `footer-foot` above the bottom edge (docx: the footer, 504 twips from the edge).
#let page-footer(title) = place(bottom + left, dx: margin-side, dy: -footer-foot, block(width: text-width, context {
  let p = counter(page).get().first()
  let n = counter(page).final().first()
  set text(font: font-family, size: type-size, ..edges(pitch-single))
  set par(first-line-indent: 0pt, leading: 0pt)
  block(width: 100%, above: 0pt, below: 0pt, upper(title))
  block(width: 100%, above: footer-gap, below: 0pt, [Page #p of #n])
}))

// ---------------------------------------------------------------------------
// Cover: counsel (upper left), court title, LBR 9004-2(c) caption
// ---------------------------------------------------------------------------

#let court-title() = lines((strong[UNITED STATES BANKRUPTCY COURT], strong[FOR THE DISTRICT OF OREGON]).map(
  l => align(center, l)), above: blank)

/// The LBR 9004-2(c) caption, ruled as in the filed complaint: the "In re" debtor block above the parties at the
/// left, a rule under it and a rule down the right of the party column; the case number beside the debtor, the
/// adversary number, the title, the subtitle and the jury demand beside the parties.
#let caption(meta) = {
  let c = meta.caption
  let debtor = ("In re:",) + c.debtor + (c.debtor_role,)
  let parties = ()
  for (k, p) in c.parties.enumerate() {
    if k > 0 { parties += ("", "v.", "") }
    parties += p.names + (p.designation,)
  }
  let right = ([Adv. Proc. No. #meta.adv_number], "", strong(md(meta.brief_title)))
  if "subtitle" in meta and meta.subtitle != none { right += ("", md(meta.subtitle)) }
  if "jury_demand" in meta and meta.jury_demand { right += ("", [DEMAND FOR JURY TRIAL]) }
  block(width: 100%, above: blank, below: 0pt, breakable: false, grid(
    columns: (caption-left, 1fr),
    stroke: (x, y) => if x == 0 { (right: 0.75pt, bottom: if y == 0 { 0.75pt } else { none }) } else { none },
    pad(right: caption-pad, bottom: caption-pad, lines(debtor)),
    pad(left: caption-pad, bottom: caption-pad, lines(([Case No. #meta.case_number],))),
    pad(right: caption-pad, top: caption-pad, lines(parties)),
    pad(left: caption-pad, top: caption-pad, lines(right)),
  ))
}

#let cover(meta) = {
  lines(meta.counsel)
  court-title()
  caption(meta)
  pagebreak()
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// A body paragraph on the double pitch: the first line indented, then `label` in a box `num-box` wide, if any.
#let body-par(label, content) = block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: 0pt, {
  h(para-indent)
  if label != none { box(width: num-box, label) }
  content
}))

/// A markdown list chunk, one paragraph per item, lettered A., B., ... across chunks (the prayer for relief).
#let list-items(t, letter-counter) = {
  let items = ()
  for line in t.split(regex("\\r?\\n")) {
    let m = line.match(regex("^(?:\\d+\\.|[-*+])[ \\t]+([\\s\\S]*)$"))
    if m != none {
      items.push(m.captures.at(0))
    } else if items.len() > 0 {
      let k = items.len() - 1
      items.at(k) = items.at(k) + " " + line.trim()
    }
  }
  for item in items {
    letter-counter.step()
    context body-par("ABCDEFGHIJKLMNOPQRSTUVWXYZ".at(letter-counter.get().first() - 1) + ".", md(item))
  }
}

/// Numbered allegations (FRCP 10(b), applied through FRBP 7010). Each blank-line-separated chunk that is
/// neither a heading nor a list is one numbered paragraph; headings and lists are unnumbered.
#let allegations(cs, para-counter, letter-counter) = {
  for c in cs {
    let t = c.trim()
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      list-items(t, letter-counter)
    } else if t.starts-with("~ ") {
      // "~ " marks a paragraph that is not numbered (the prayer lead-in).
      body-par(none, md(t.slice(2)))
    } else {
      para-counter.step()
      context body-par(para-counter.display() + ".", md(t))
    }
  }
}

/// The date on a double line, then the signature lines single-spaced 3 in from the margin; kept on one page.
#let signature(meta) = block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
  if "date" in meta { block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: 0pt, md(meta.date))) }
  pad(left: sig-indent, lines(meta.signature))
})

// ---------------------------------------------------------------------------
// Entry
// ---------------------------------------------------------------------------

#let orb-adversary-complaint(meta, body) = {
  let para-counter = counter("allegation")
  let letter-counter = counter("prayer-item")

  set page(
    paper: "us-letter",
    margin: (top: margin-top, bottom: margin-bottom, left: margin-side, right: margin-side),
    footer: none,
    foreground: page-footer(meta.footer_title),
  )
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number.
  show: xengine.with(pitch: pitch-body)
  // A doubled sign stays with its number ("§§ 544"; xengine binds a single sign; docx: a no-break space).
  show regex("[§¶]{2,} \\S+"): it => box(it)

  // Headings on the body pitch at the type size, kept with the text after them: level 1 centred bold capitals;
  // level 2 centred bold; level 3 bold italic.
  show heading: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    let body = if it.level == 1 { align(center, par(strong(upper(it.body)))) }
      else if it.level == 2 { align(center, par(strong(it.body))) }
      else { par(strong(emph(it.body))) }
    block(width: 100%, above: 0pt, below: 0pt, sticky: true, body)
  }

  cover(meta)

  if "lead_in" in meta and meta.lead_in != none { body-par(none, md(meta.lead_in)) }

  // The last chunk is kept with the signature block, so a sign-off never stands alone on a page.
  let cs = chunks(body)
  allegations(cs.slice(0, -1), para-counter, letter-counter)
  block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
    allegations(cs.slice(-1), para-counter, letter-counter)
    signature(meta)
  })
}
