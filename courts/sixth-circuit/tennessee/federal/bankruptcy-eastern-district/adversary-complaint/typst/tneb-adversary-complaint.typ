// Adversary complaint for the United States Bankruptcy Court, E.D. Tennessee (tneb).
// Rules (see ../README.md and ../../rules.md): FRBP 7001 (an adversary proceeding), 7003 and E.D. Tenn. LBR 7003-1
// (Form B 1040 cover sheet filed with the complaint; not produced here), 7008(a) (Rule 8 applies; the complaint
// states the jurisdiction and whether the pleader consents to final orders), 7010 (Rule 10 applies; the caption
// substantially conforms to Official Form 416), Fed. R. Civ. P. 10(b) (numbered paragraphs), E.D. Tenn. LBR
// 9004-1(a) (8 1/2 by 11 inches, double-spaced, paginated at the bottom from page 2), LBR 9004-2(a) (the caption
// identifies the division and the case or adversary number with the judge's initials).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // no rule names a face (LBR 9004-1 is silent); Times New Roman, vendored in fonts/
#let type-size = 12pt                   // the usual 12-point text; the rules set no minimum for this court
#let page-w = 8.5in                     // LBR 9004-1(a): 8 1/2 by 11 inches
#let page-h = 11in
#let margin = 1in                       // no rule sets margins (rules.md TNEB-FORM-002); the usual 1 inch
#let text-width = page-w - 2 * margin

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/tneb-adversary-complaint.lua sets the same twips).
#let pitch-body = 24pt                  // LBR 9004-1(a): double-spaced (docx 480)
#let pitch-single = 13.8pt              // court title, caption, signature, page number: single spacing (docx 276)
#let blank-title = 13.8pt               // one blank single line around the caption and under the paper's title
#let blank-body = 24pt                  // one blank double line between the dated line and the signature lines
#let para-indent = 0.5in                // first-line indent; the paragraph number sits at this indent
#let num-box = 0.5in                    // the paragraph number (or the prayer letter) in a box this wide (docx: a tab 1 in in)
#let caption-left = 3.25in              // width of the party column; the ")" column follows
#let caption-mid = 0.3in
#let sig-indent = 3.25in                // the signature block, from the left margin
#let footer-foot = 0.5in                // the page number's line ends this far above the bottom edge (docx footer 720)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline and block markdown from a string (CommonMark with smart punctuation, as the docx engine reads it).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line (or more, if it wraps); an empty string is a blank single line.
#let line-block(s, above: 0pt) = {
  set text(..edges(pitch-single))
  if s == "" or s == none { block(width: 100%, height: pitch-single, above: above, below: 0pt) }
  else { block(width: 100%, above: above, below: 0pt, md(s)) }
}

/// Blank-line-separated chunks of the markdown body.
#let chunks(body) = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")

// ---------------------------------------------------------------------------
// Page furniture: LBR 9004-1(a), paginated at the bottom from the second page
// ---------------------------------------------------------------------------

#let page-number() = place(bottom + left, dx: margin, dy: -footer-foot, block(width: text-width, context {
  let p = counter(page).get().first()
  if p > 1 {
    set text(font: font-family, size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, leading: 0pt)
    align(center, [#p])
  }
}))

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (FRBP 7010; Form 416; LBR 9004-2)
// ---------------------------------------------------------------------------

/// One caption row: party text, a ")" in the middle column, and the case information on the right; each a
/// single-spaced line (an empty entry still takes its line).
#let caption-row(r) = grid(
  columns: (caption-left, caption-mid, 1fr),
  line-block(r.at("left", default: "")),
  line-block(")") ,
  line-block(r.at("right", default: "")),
)

#let cover(meta) = {
  set par(first-line-indent: 0pt)
  let centered(s) = { set text(..edges(pitch-single)); block(width: 100%, above: 0pt, below: 0pt, align(center, strong(s))) }
  centered("IN THE " + meta.court)
  centered(meta.district)
  if "division" in meta and meta.division != none { centered(upper(meta.division)) }
  block(width: 100%, above: blank-title, below: 0pt, {
    show grid: set align(left)
    show grid.cell.where(x: 1): set align(center)
    for r in meta.caption { block(width: 100%, above: 0pt, below: 0pt, breakable: false, caption-row(r)) }
  })
  {
    set text(..edges(pitch-single))
    block(width: 100%, above: blank-title, below: blank-title, align(center, strong(md(meta.title))))
  }
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

/// The lettered prayer (a markdown list chunk) as its items' texts.
#let prayer-items(t) = {
  let items = ()
  for line in t.split(regex("\\r?\\n")) {
    let m = line.match(regex("^(?:\\d+\\.|[-*+])[ \\t]+([\\s\\S]*)$"))
    if m != none { items.push(m.captures.at(0)) }
    else if items.len() > 0 { items.at(-1) = items.at(-1) + " " + line.trim() }
  }
  items
}

/// The body as a list of blocks: headings, numbered allegations (Rule 10(b)), an unnumbered WHEREFORE lead-in, and
/// the lettered prayer items ((a), (b), ... after the indent, the text wrapping to the margin). Paragraphs are
/// counted in the template, never typed into the sample.
#let body-blocks(body) = {
  let out = ()
  let n = 0
  for c in chunks(body) {
    if c.starts-with("#") {
      out.push(md(c))
    } else if c.starts-with(regex("^\\d+\\.[ \\t]")) {
      for (k, it) in prayer-items(c).enumerate() { out.push(body-par("(" + str.from-unicode(97 + k) + ")", md(it))) }
    } else if c.starts-with("WHEREFORE") {
      out.push(body-par(none, md(c)))
    } else {
      n += 1
      out.push(body-par([#n.], md(c)))
    }
  }
  out
}

/// The dated line on the double pitch, a blank double line, then the signature lines single-spaced from
/// `sig-indent` (the lead line, a blank single line, the signer, the rest).
#let signature(sig) = {
  if "dated" in sig { body-par(none, md(sig.dated)) }
  block(width: 100%, above: blank-body, below: 0pt, inset: (left: sig-indent), {
    let above = 0pt
    if "lead" in sig {
      line-block(sig.lead, above: above)
      above = pitch-single
    }
    if "by" in sig { line-block(sig.by, above: above); above = 0pt }
    for l in sig.lines { line-block(l, above: above); above = 0pt }
  })
}

#let adversary-complaint(meta, body) = {
  set page(paper: "us-letter", margin: margin, footer: none, foreground: page-number())
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number.
  show: xengine.with(pitch: pitch-body)
  // A doubled sign stays with its number (xengine binds a single sign; docx: a no-break space).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // Headings: centred and bold at the type size on the body pitch, kept with the text after them.
  show heading: it => {
    set text(size: type-size)
    block(width: 100%, above: 0pt, below: 0pt, sticky: true, align(center, par(strong(it.body))))
  }

  cover(meta)

  if "lead_in" in meta and meta.lead_in != none { body-par(none, md(meta.lead_in)) }

  // The last block (the last prayer item) is kept with the signature block, so a signature never stands alone.
  let bs = body-blocks(body)
  for b in bs.slice(0, -1) { b }
  block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
    bs.last()
    if "signature" in meta { signature(meta.signature) }
  })
}
