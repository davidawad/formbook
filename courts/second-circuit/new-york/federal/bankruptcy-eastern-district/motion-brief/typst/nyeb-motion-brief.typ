// Motion with memorandum of law for the United States Bankruptcy Court, Eastern District of New York (nyeb).
// Rules (sources and dates in ../README.md):
//   Fed. R. Bankr. P. 9013 (a motion is in writing and states its grounds with particularity), 7012 (Fed. R.
//   Civ. P. 12 applies in an adversary proceeding), 9004(b) (caption: court's name, case title, case number and
//   adversary-proceeding number, designation of the paper);
//   E.D.N.Y. LBR 9004-1(a) (plainly typed, no erasures, 8 1/2 x 11 paper, signed under Rule 9011, not bound
//   on the side); E.D.N.Y. LBR 9004-2(a) (caption states the court, the title and chapter, the case number and
//   judge code, and for an adversary proceeding the full title and the adversary number);
//   E.D.N.Y. LBR 9013-1(a) (the rules and authorities relied on, in the motion or a separate memorandum of law).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see ../README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")       // no font is named by FRBP 9004 or E.D.N.Y. LBR 9004-1; Times New Roman (vendored) per docs/FONTS.md, the face of both filed exemplars
#let type-size = 12pt                  // no size is named either; 12 pt is the working convention (README.md)
#let footer-size = 10pt                // the matter number in the footer (layout choice, as in the exemplar)
#let page-w = 8.5in                    // E.D.N.Y. LBR 9004-1(a)(ii): 8 1/2 x 11 inch paper
#let margin = 1in                      // layout choice: 1 inch margins on all sides
#let footer-distance = 0.5in           // the footer's line box ends half an inch above the page edge (docx: footer 720)
#let para-indent = 0.5in               // first-line indent of body paragraphs; a bullet stands here
#let bullet-box = 0.25in               // a bullet's box: the item's text hangs 0.75 in from the margin
#let quote-indent = 1in                // quotations are indented on both sides
#let caption-left = 3.8in              // the caption's party column
#let caption-gutter = 0.2in            // between it and the numbers column
#let designation-indent = 1.2in        // "Debtor.", "Plaintiff,", "Defendants." set in under the names
#let caption-rule = 0.75pt             // the caption's rules above, between and below its two blocks
#let caption-inset = 8pt               // the space inside each block, above and below its lines
#let signature-indent = 3.25in         // the signer's column; the place and date stand left of it

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/nyeb-motion-brief.lua and docx/reference.xml set
// the same twips: 20 x pt).
#let pitch-body = 24pt                 // double spacing: the body, headings, bullets
#let pitch-single = 13.8pt             // single spacing: counsel, court title, caption, title, quotations, signature
#let title-gap = 6pt                   // between the two lines of the court title
#let block-gap = 24pt                  // counsel to court title, court title to caption, caption to title, title to text
#let versus-gap = 12pt                 // above and below "v." between the parties
#let heading-above = 12pt              // above a heading (none at the top of a page)
#let quote-space = 12pt                // above and below a quotation paragraph
#let signature-above = 24pt            // the last paragraph to the signature block

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nyeb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline content without the paragraph breaks cmarker may put around it.
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// Inline markdown (italics for case names, emphasis) for one piece of text. A label "1." opening the text stays
/// text (the docx reads markdown without fancy lists, so it is text there too). A straight double quote that ends
/// the text closes a quotation: cmarker's smart punctuation would open one there (pandoc closes it).
#let inl(s) = if type(s) != str { s } else {
  let s = s.replace(regex("^(\\d+)([.)])"), m => m.captures.at(0) + "\\" + m.captures.at(1))
    .replace(regex("\"$"), "\u{201D}")
  unloose(cmarker.render(s, raw-typst: false, smart-punctuation: true))
}

/// The body's blank-line-separated chunks, in order.
#let chunks(body) = body.replace("\r\n", "\n").split(regex("\n[ \t]*\n")).map(s => s.trim()).filter(s => s != "")

/// One single-pitch line (a paragraph of its own), with an explicit space above it.
#let sline(above: 0pt, left: 0pt, centered: false, c) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set align(center) if centered
  pad(left: left, par(first-line-indent: 0pt, inl(c)))
})

// ---------------------------------------------------------------------------
// Cover: counsel block (top left), court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title() = {
  sline(above: block-gap, centered: true, text(weight: "bold", "UNITED STATES BANKRUPTCY COURT"))
  sline(above: title-gap, centered: true, text(weight: "bold", "EASTERN DISTRICT OF NEW YORK"))
}

/// One side of the caption: its names, then its designation set in from the left.
#let party-lines(p) = (..p.names.map(n => sline(n)), sline(left: designation-indent, p.designation)).join()

#let caption(meta) = {
  let debtor = meta.caption.debtor
  let left1 = [#sline("In re:")#party-lines(debtor)]
  let right1 = [#sline("Case No. " + meta.case_number)#sline("Chapter " + meta.chapter)]
  let left2 = {
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { sline(above: versus-gap, centered: true, "v."); v(versus-gap) }
      party-lines(p)
    }
  }
  let right2 = sline("Adv. Pro. No. " + meta.adversary_number)
  // Two blocks, each between rules, the numbers column centred on the parties beside it (docx: a two-row table,
  // cell rules and vertical centring).
  block(width: 100%, above: block-gap, below: 0pt, grid(
    columns: (caption-left, caption-gutter, 1fr),
    inset: (x: 0pt, y: caption-inset),
    stroke: (x, y) => (top: if y == 0 { caption-rule }, bottom: caption-rule),
    align: (x, y) => if x == 2 { left + horizon } else { left + top },
    left1, [], right1,
    left2, [], right2,
  ))
}

#let cover(meta) = {
  if "counsel" in meta { for l in meta.counsel { sline(l) } }
  court-title()
  caption(meta)
  block(width: 100%, above: block-gap, below: block-gap,
    sline(centered: true, text(weight: "bold", inl(meta.title))))
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// A paragraph on the body pitch. `keep`: unbreakable and kept with what follows (headings; the conclusion, kept
/// with the signature block; docx: keep with next, keep lines together).
#let body-par(c, above: 0pt, keep: false) = block(width: 100%, above: above, below: 0pt, sticky: keep,
  breakable: not keep, c)

/// A heading on the body pitch, kept with what follows: level 1 centred bold, 2 bold, 3 bold italic.
#let heading-block(level, t) = body-par(above: heading-above, keep: true, {
  set align(center) if level == 1
  par(first-line-indent: 0pt, if level <= 2 { text(weight: "bold", inl(t)) }
    else { text(weight: "bold", style: "italic", inl(t)) })
})

/// A quotation paragraph: single-spaced, indented on both sides.
#let quote-par(t) = block(width: 100%, above: quote-space, below: quote-space, pad(x: quote-indent, {
  set text(..edges(pitch-single))
  par(first-line-indent: 0pt, inl(t))
}))

/// A bullet item: the bullet at the paragraph indent, the text hanging after its box (docx: a tab).
#let bullet-item(t, keep: false) = body-par(keep: keep, par(first-line-indent: 0pt,
  hanging-indent: para-indent + bullet-box, [#h(para-indent)#box(width: bullet-box, [•])#inl(t)]))

/// The body: headings, bullets, quotations (a quoted blank line separates its paragraphs) and paragraphs.
/// `keep-last`: the last paragraph or bullet stays with the signature block after it.
#let render-body(cs, keep-last: false) = {
  let n = cs.len()
  for (i, c) in cs.enumerate() {
    let last = keep-last and i == n - 1
    let h = c.match(regex("^(#{1,3})[ \t]+([\\s\\S]*)$"))
    if h != none {
      heading-block(h.captures.at(0).len(), h.captures.at(1).replace("\n", " "))
    } else if c.match(regex("^[-*+] ")) != none {
      let items = c.split(regex("\n[-*+] ")).map(s => s.trim()).filter(s => s != "")
      for (k, it) in items.enumerate() {
        bullet-item(it.replace(regex("^[-*+] "), "").replace("\n", " "), keep: last and k == items.len() - 1)
      }
    } else if c.starts-with(">") {
      let lines = c.split("\n").map(s => s.replace(regex("^> ?"), "").trim())
      let paras = lines.join("\n").split(regex("\n[ \t]*\n")).map(s => s.trim()).filter(s => s != "")
      for p in paras { quote-par(p.replace("\n", " ")) }
    } else {
      body-par(keep: last, par(inl(c.replace("\n", " "))))
    }
  }
}

/// The signature block, single-spaced and on one page: the place and date at the left, the firm's lines in a column
/// from `signature-indent`, line for line (docx: a tab and a hanging indent there).
#let signature(sig) = block(width: 100%, above: signature-above, below: 0pt, breakable: false, {
  set text(..edges(pitch-single))
  let dated = sig.at("dated", default: ())
  let lines = sig.lines
  for i in range(calc.max(dated.len(), lines.len())) {
    block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: 0pt, hanging-indent: signature-indent,
      [#box(width: signature-indent, inl(dated.at(i, default: "")))#inl(lines.at(i, default: ""))]))
  }
})

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let nyeb-motion-brief(meta, body) = {
  set document(title: meta.title)
  set page(
    paper: "us-letter",
    margin: margin,
    // the matter number at the left and the page number centred, in a single-pitch line box that ends
    // footer-distance above the page edge
    footer-descent: margin - footer-distance - pitch-single,
    footer: context {
      set text(..edges(pitch-single))
      grid(
        columns: (1fr, 1fr, 1fr),
        align(left, text(size: footer-size, if "matter_number" in meta { meta.matter_number } else { "" })),
        align(center, counter(page).display()),
        [],
      )
    },
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number. Lists are laid out here (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number too ("¶¶ 51–55"): typst would break between the two signs (docx: a no-break
  // space after the doubled sign).
  show regex("[§¶]{2,} \\S+"): it => box(it)

  cover(meta)
  // The last paragraph stays with the signature block: a signature never stands alone on a page.
  render-body(chunks(body), keep-last: "signature" in meta)
  if "signature" in meta { signature(meta.signature) }
}
