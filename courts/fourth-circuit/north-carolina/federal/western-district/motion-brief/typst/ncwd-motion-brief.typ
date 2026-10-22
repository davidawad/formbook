// Memorandum of law supporting a motion for the U.S. District Court for the Western District of North Carolina (ncwd).
// Rules: LCvR 7.1(c) (a brief is filed with the motion), 7.1(d) (25-page limit, 12 pt minimum, double-spaced,
// one-inch margins, numbered pages; a judge's standing order overrides these); Fed. R. Civ. P. 7(b), 11(a) (signer's
// address, e-mail and telephone); the June 18, 2024 Standing Order on artificial intelligence (3:24-mc-104), whose
// certification the template prints when the sample asks for it. See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // LCvR 7.1(d): font size is the rule; Times New Roman (vendored, docs/FONTS.md)
#let type-size = 12pt                   // LCvR 7.1(d): a minimum of 12 point
#let margin = 1in                       // LCvR 7.1(d): one-inch margins
#let text-width = 8.5in - 2 * margin
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let list-indent = 0.5in                // a list item's label starts half an inch in ...
#let label-box = 0.5in                  // ... in a box of its own; the text hangs 1 in from the margin
#let caption-left = 2.9in               // party column of the caption
#let caption-mark = 0.3in               // ")" column between the parties and the title
#let caption-gutter = 0.1in             // between the caption's columns ...
#let caption-pad = 0.1in                // ... and the right column stands off its gutter by this much
#let sig-left = 3.0in                   // the firm blocks' left edge (the right half of the page)

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/motion-brief.lua and docx/reference.xml set the
// same twips).
#let pitch-body = 27.6pt                // LCvR 7.1(d): double-spaced, twice the 13.8 pt single line of 12 pt Times
#let pitch-single = 13.8pt              // single spacing: court title, caption, headings, signature, counsel, page number
#let gap = 24pt                         // the block-spacing unit: caption to text, around the signature and counsel
                                        // blocks, above a heading
#let court-below = 13.8pt               // the court title to the caption (a blank single line)
#let caption-gap = 13.8pt               // inside the caption's right column: a blank single line, so every line
                                        // stands on a row of the party column
#let heading-below = 13.8pt             // a heading to the text after it (a blank single line)
// LCvR 7.1(d): every page numbered. The number sits in a single-spaced line box whose foot is 0.5 in above the bottom
// edge (docx: footer distance 720 twips): 72 - 36 - 13.8 = 22.2 pt below the text.
#let footer-descent = 22.2pt

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ncwd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in italics, quotations, and so on).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Inline content without the paragraph breaks cmarker may put around it (they may not occur inside a paragraph).
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// Single-spaced lines, one paragraph each; an empty item is a blank single line. `above`: the space before the
/// first line. An item is a string (markdown) or content.
#let line-stack(items, above: 0pt) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  let g = above
  for i in items {
    if i == "" { g += pitch-single } else {
      block(width: 100%, above: g, below: 0pt, if type(i) == str { inl(i) } else { i })
      g = 0pt
    }
  }
}

/// A body paragraph at the body pitch, its first line indented half an inch (`indent: false`: flush).
#let body-par(content, above: 0pt, indent: true) = block(width: 100%, above: above, below: 0pt,
  par(first-line-indent: if indent { (amount: para-indent, all: true) } else { 0pt }, unloose(content)))

// ---------------------------------------------------------------------------
// First page: court title, caption, title of the paper
// ---------------------------------------------------------------------------

/// Fed. R. Civ. P. 10(a): the court's name; the division line when the filing uses one.
#let court-title(meta) = {
  let lines = ("UNITED STATES DISTRICT COURT", "FOR THE WESTERN DISTRICT OF NORTH CAROLINA")
  if "division" in meta and meta.division != none { lines.push(upper(meta.division)) }
  line-stack(lines.map(l => align(center, text(weight: "bold", l))))
}

/// The parties at left (each party's lines, then its designation; "v." between the parties; one line per row), a ")"
/// beside each row, and at right the civil action number and the title of the paper (bold).
#let caption(meta) = {
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.lines + (p.designation,)
  }
  block(width: 100%, breakable: false, above: court-below, below: 0pt, grid(
    columns: (caption-left, caption-mark, 1fr),
    column-gutter: caption-gutter,
    line-stack(rows),
    line-stack(rows.map(_ => ")")),
    pad(left: caption-pad, {
      line-stack(("Civil Action No. " + meta.case_number,))
      line-stack(above: caption-gap, meta.title.map(l => text(weight: "bold", inl(l))))
    }),
  ))
}

// ---------------------------------------------------------------------------
// Headings, signature, certification, certificate of service
// ---------------------------------------------------------------------------

/// Headings, single-spaced and kept with the block after them: level 1 a centered bold section in capitals; level 2
/// a bold argument heading at the left; level 3 a bold italic sub-heading at the left.
#let heading-block(level, body) = {
  set text(..edges(pitch-single))
  let b = if level == 1 { text(weight: "bold", upper(body)) } else if level == 2 {
    text(weight: "bold", body) } else { text(weight: "bold", style: "italic", body) }
  block(width: 100%, sticky: true, above: gap, below: heading-below,
    align(if level == 1 { center } else { left }, par(first-line-indent: 0pt, unloose(b))))
}

/// Signature block (Fed. R. Civ. P. 11(a)): the date line at the left, then each firm's block at the right half.
/// A signing firm has a "By: /s/" line for the signer; the signer's address, e-mail and telephone follow.
#let signature-block(sig) = {
  line-stack(above: gap, (sig.date_line,))
  // The gap above is the outer block's own: a gap at the start of the pad would be dropped.
  block(width: 100%, above: gap, below: 0pt, pad(left: sig-left, {
    for (k, b) in sig.blocks.enumerate() {
      let lines = if "by" in b and b.by != none { (b.firm, "By: /s/ " + b.by) + b.lines } else { (b.firm,) + b.lines }
      line-stack(above: if k > 0 { gap } else { 0pt }, lines)
    }
  }))
}

/// A closing block and the signature after it, kept on one page: a signature never starts a page alone.
#let with-signature(meta, last) = block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
  last
  signature-block(meta.signature)
})

/// The AI certification the June 18, 2024 Standing Order requires (wording as filed in the exemplar).
#let ai-certification(meta) = {
  heading-block(1)[Certification Regarding Use of Artificial Intelligence]
  body-par[Pursuant to the June 18, 2024 Standing Order of this Court _In Re: Use of Artificial Intelligence_, 3:24-mc-104, counsel, by signing above, submits the following certification regarding #meta.ai_title.]
  body-par[1\. No artificial intelligence was employed in doing the research for the preparation of this Memorandum, with the exception of such artificial intelligence embedded in the standard on-line legal research sources Westlaw, Lexis, FastCase, and Bloomberg, as well as Google and Google Scholar;]
  with-signature(meta, body-par[2\. Every statement and every citation to an authority contained in this Memorandum has been checked by the undersigned as to the accuracy of the proposition for which it is offered, and the citation to authority provided.])
}

/// The certificate of service: the filing, the counsel served (each block whole; the list may break between them),
/// the date and the signature.
#let certificate-of-service(meta) = {
  heading-block(1)[Certificate of Service]
  body-par[This is to certify that the undersigned has this day electronically filed the foregoing #meta.service_title with the Clerk of the Court using the CM/ECF system which will send notification of such filing to the following counsel of record:]
  let counsel = meta.service.counsel
  for c in counsel.slice(0, -1) { block(width: 100%, breakable: false, above: gap, below: 0pt, line-stack(c)) }
  with-signature(meta, block(width: 100%, above: gap, below: 0pt, line-stack(counsel.last())))
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// The body. Each blank-line-separated chunk of markdown is one of:
///   `#` heading (levels 1 to 3), kept with the text after it;
///   `>` paragraph: flush left;
///   `1.` or `-` list: one item per labelled line, the label half an inch in, the text hanging after it;
///   anything else: a paragraph, its first line indented (a brief is not a pleading: no numbers).
#let item-re = regex("^(\\d+\\.|[-*+])[ \\t]+")
#let chunk(t) = {
  if t.starts-with("#") {
    let level = t.match(regex("^#+")).end
    heading-block(calc.min(level, 3), inl(t.slice(level).trim()))
  } else if t.starts-with(">") {
    body-par(indent: false, inl(t.replace(regex("(?m)^>[ \t]?"), "")))
  } else if t.starts-with(item-re) {
    let items = ()
    for l in t.split("\n").map(l => l.trim()).filter(l => l != "") {
      if l.starts-with(item-re) or items.len() == 0 { items.push(l) } else { items.last() += " " + l }
    }
    for item in items {
      let m = item.match(item-re)
      let label = if m.captures.at(0).ends-with(".") { m.captures.at(0) } else { [•] }
      block(width: 100%, above: 0pt, below: 0pt, pad(left: list-indent,
        par(first-line-indent: 0pt, hanging-indent: label-box,
          [#box(width: label-box, label)#unloose(inl(item.slice(m.end)))])))
    }
  } else {
    body-par(inl(t))
  }
}

#let ncwd-motion-brief(meta, body) = {
  // Every page numbered, bottom centre (LCvR 7.1(d)).
  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: footer-descent,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch. Lists are written by chunk() (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays whole and with its number ("¶¶ 8–9", "§§ 206(a)"): typst would break between the signs.
  show regex("[§¶]{2,} \\S+"): it => box(it)

  court-title(meta)
  caption(meta)
  v(gap, weak: true)

  // The last chunk stays on the page with the signature block.
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  for t in chunks.slice(0, -1) { chunk(t) }
  with-signature(meta, chunk(chunks.last()))
  if "ai_certification" in meta and meta.ai_certification { ai-certification(meta) }
  if "service" in meta and meta.service != none { certificate-of-service(meta) }
}
