// Adversary complaint for the United States Bankruptcy Court for the District of Idaho (idb).
// Rules: Fed. R. Bankr. P. 7001, 7003, 7010 (Fed. R. Civ. P. 10 applies; the caption must substantially
// conform to Official Form 416), 9004(a)-(b) (legible; caption content); D. Idaho LBR 5005-1(c) (counsel
// block, 12-14 point type, caption form), LBR 7003-1 (cover sheet; judge suffix on the case and adversary
// numbers). See ../README.md for the meaning of every parameter.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // LBR 5005-1(c)(2) names no face; the house face, as filed
#let type-size = 12pt              // LBR 5005-1(c)(2): 12 to 14 point; the exemplar's 12 pt
#let margin = 1in                  // LBR 5005-1(c)(1): counsel information starts 1 inch from the top; 1 in elsewhere
#let para-indent = 0.5in           // first-line indent; the paragraph number starts here (the exemplar)
#let num-box = 0.5in               // the paragraph number's box: the text starts 1 in from the margin
#let item-indent = 1in             // lettered items: the letter 1 in from the margin
#let item-box = 0.25in             // the letter's box: the item text hangs 1.25 in from the margin
#let caption-left = 3.2in          // width of the party column of the caption, closed by a vertical rule
#let caption-inset = 0.15in        // the case identifiers stand off the rule
#let designation-indent = 1.5in    // "Debtors.", "Plaintiff," ... under the names
#let sig-left = 3.5in              // the signature block's column; "Date:" at the margin beside it

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is explicit (Word's exact
// line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt         // a single line, 1.15 x the type size: counsel, caption, headings, signature
#let pitch-double = 27.6pt         // the body, double spaced (the exemplar's pitch)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\\r?\\n([\\s\\S]*?)\\r?\\n---[ \\t]*\\r?\\n"))
  if m == none { panic("idb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, case names, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Blank-line-separated chunks of the body (the markdown contract in ../README.md).
#let chunks(body) = body.split(regex("\\n\\s*\\n")).map(c => c.trim()).filter(c => c != "")

/// One line block (a paragraph of its own) at a pitch, with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, pitch: pitch-single, indent: 0pt, body) = block(width: 100%, above: above,
  below: below, pad(left: indent, {
    set text(..edges(pitch))
    set par(first-line-indent: 0pt)
    body
  }))

// ---------------------------------------------------------------------------
// Counsel, court, caption, title
// ---------------------------------------------------------------------------

/// Counsel block: upper left, single spaced, from the top margin (LBR 5005-1(c)(1)).
#let counsel-block(lines) = for l in lines { line-block(inl(l)) }

/// The court's name, centered and bold, a single line above and below it.
#let court-title() = {
  line-block(above: pitch-single, align(center, text(weight: "bold", "UNITED STATES BANKRUPTCY COURT")))
  line-block(below: pitch-single, align(center, text(weight: "bold", "DISTRICT OF IDAHO")))
}

/// A party block: its names one per line (a single line above them unless `gap` is false), the designation under
/// them, a single line apart.
#let party-lines(p, gap: true) = {
  for (i, n) in p.names.enumerate() { line-block(above: if i == 0 and gap { pitch-single } else { 0pt }, inl(n)) }
  line-block(above: pitch-single, indent: designation-indent, inl(p.designation))
}

/// The caption (Official Form 416): two rows, each a party cell closed by a vertical rule and a cell of case
/// identifiers. The debtors and the case and chapter numbers above a rule; the adversary parties ("v." between
/// them) and the adversary number below it, a single line down. That space opens the second row's cells as `v`:
/// typst drops a block's space above at the start of its container, and Word keeps a paragraph's in a cell.
#let caption(meta) = {
  let rule = 0.75pt
  let cell(top, body) = block(width: 100%, stroke: (right: rule, bottom: if top { rule } else { none }),
    inset: (bottom: pitch-single), body)
  let ids(body) = pad(left: caption-inset, body)
  grid(
    columns: (caption-left, 1fr),
    cell(true, {
      line-block("In re:")
      party-lines(meta.debtors)
    }),
    ids({
      line-block([Case No. #meta.case_number])
      line-block(above: pitch-single, [Chapter #meta.chapter])
    }),
    cell(false, {
      v(pitch-single)
      for (k, p) in meta.parties.enumerate() {
        if k > 0 { line-block(above: pitch-single, "v.") }
        party-lines(p, gap: k > 0)
      }
    }),
    ids({
      v(pitch-single)
      line-block[Adv. No. #meta.at("adv_number", default: "")]
    }),
  )
}

/// The title of the paper: bold capitals, underlined, centered, a single line below the caption.
#let title(meta) = line-block(above: pitch-single, pitch: pitch-double,
  align(center, text(weight: "bold", underline(upper(meta.title)))))

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// A body paragraph at the double pitch: unnumbered (first-line indent) or numbered (Fed. R. Civ. P. 10(b): the
/// number in a box after the first-line indent, the text after it). `keep`: kept whole with the block after it.
#let body-par(num, content, keep: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: keep,
  breakable: not keep, if num == none {
  par(first-line-indent: (amount: para-indent, all: true), content)
} else {
  par(first-line-indent: (amount: para-indent, all: true), [#box(width: num-box, [#num.])#content])
})

/// Lettered items a., b., ...: the letter 1 in from the margin, the text hanging after it.
#let lettered(items, keep-last: false) = for (i, it) in items.enumerate() {
  let last = i == items.len() - 1
  block(width: 100%, above: 0pt, below: 0pt, sticky: keep-last and last, breakable: not (keep-last and last),
    pad(left: item-indent, par(first-line-indent: 0pt, hanging-indent: item-box,
      [#box(width: item-box, numbering("a.", i + 1))#inl(it)])))
}

/// Headings at the body size, sticky: `# ` (COUNT, PRAYER) bold, underlined and centered on a single line, a
/// single line above it; `## ` right after it (the count's description) bold and centered, single spaced; any
/// other `## ` bold and underlined at the margin on a body line; `### ` bold at the margin on a body line. A
/// heading followed by text has a single line below it when it is single spaced.
#let heading-block(level, s, after-h1: false, then-text: true) = {
  // the spaces on the sticky block itself: a block's own space at the start or end of its container is dropped
  let below = if then-text { pitch-single } else { 0pt }
  let wrap(above, below, b) = block(sticky: true, width: 100%, above: above, below: below, b)
  if level == 1 {
    wrap(pitch-single, below, line-block(align(center, text(weight: "bold", underline(inl(s))))))
  } else if level == 2 and after-h1 {
    wrap(0pt, below, line-block(align(center, text(weight: "bold", inl(s)))))
  } else if level == 2 {
    wrap(0pt, 0pt, line-block(pitch: pitch-double, text(weight: "bold", underline(inl(s)))))
  } else {
    wrap(0pt, 0pt, line-block(pitch: pitch-double, text(weight: "bold", inl(s))))
  }
}

#let render-body(body) = {
  let cs = chunks(body)
  let n = 0
  let num-on = true   // off after the prayer heading: the prayer is not numbered
  let prev = 0        // the level of the heading just before, 0 after any other chunk
  for (i, c) in cs.enumerate() {
    let last = i == cs.len() - 1
    let next = if last { "" } else { cs.at(i + 1) }
    let m = c.match(regex("^(#{1,3}) "))
    if m != none {
      let level = m.captures.at(0).len()
      let s = c.slice(level + 1)
      if level == 1 and s.starts-with("PRAYER") { num-on = false }
      heading-block(level, s, after-h1: level == 2 and prev == 1, then-text: not next.starts-with("#"))
      prev = level
    } else if c.starts-with("- ") {
      lettered(c.split("\n").map(l => l.trim()).filter(l => l != "").map(l => l.slice(2)), keep-last: last)
      prev = 0
    } else {
      if num-on { n += 1 }
      body-par(if num-on { n } else { none }, inl(c), keep: last)
      prev = 0
    }
  }
}

/// "Date:" at the margin; at 3.5 in the lines above the signature, two single lines, "/s/ Name", the name in
/// capitals and the lines under it. It never breaks across a page.
#let signature-block(meta) = {
  let s = meta.signature
  block(width: 100%, breakable: false, above: pitch-double, below: 0pt, grid(
    columns: (sig-left, 1fr),
    line-block([Date: #meta.date]),
    {
      for l in s.at("lines_above", default: ()) { line-block(inl(l)) }
      line-block(above: 2 * pitch-single, [/s/ #s.signer])
      line-block(upper(s.signer))
      for l in s.at("lines", default: ()) { line-block(inl(l)) }
    },
  ))
}

// ---------------------------------------------------------------------------
// Entry point: idb-adversary-complaint(meta, body)
// ---------------------------------------------------------------------------
#let idb-adversary-complaint(meta, body) = {
  // judge suffix on the case and adversary numbers (LBR 7003-1(b)(1), (c)(1))
  assert(meta.case_number.match(regex("^\\d{2}-\\d{5}-[A-Z]{3}$")) != none,
    message: "idb-adversary-complaint: case_number must end in a three-letter judge suffix (LBR 7003-1(b)(1))")
  if meta.at("adv_number", default: "") != "" {
    assert(meta.adv_number.match(regex("^\\d{2}-\\d{4,5}-[A-Z]{3}$")) != none,
      message: "idb-adversary-complaint: adv_number must end in a three-letter judge suffix (LBR 7003-1(c)(1))")
  }

  // Page numbers centered, arabic, on every page, in a single line box (Word's footer).
  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch.
  show: xengine.with(pitch: pitch-double)
  // A doubled sign stays with its number ("§§ 157(a)"): xengine binds one sign (the docx filter binds the same).
  show regex("[§¶]{2,} \\S+"): it => box(it)

  counsel-block(meta.counsel)
  court-title()
  caption(meta)
  title(meta)
  body-par(none, inl(meta.lead_in))
  render-body(body)
  signature-block(meta)
}
