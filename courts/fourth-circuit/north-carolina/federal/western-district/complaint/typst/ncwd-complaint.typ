// Complaint for the U.S. District Court for the Western District of North Carolina (ncwd).
// Rules: LCvR 7.1(d) (12 pt minimum, double-spaced, one-inch margins, numbered pages; a judge's standing
// order overrides these); Fed. R. Civ. P. 8(a), 10(a) (caption), 10(b) (numbered paragraphs), 11(a)
// (signer's address, e-mail and telephone). See ../README.md.
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
#let para-indent = 0.5in                // first-line indent of every body paragraph
#let number-box = 0.5in                 // a paragraph number's box: the text starts 1 in from the margin (docx: a tab)
#let list-indent = 0.5in                // a prayer item's letter starts half an inch in ...
#let letter-box = 0.5in                 // ... in a box of its own; the text hangs 1 in from the margin
#let caption-left = 3.0in               // party column of the caption
#let caption-mark = 0.3in               // ")" column between the parties and the title
#let caption-gutter = 0.1in             // between the caption's columns ...
#let caption-pad = 0.1in                // ... and the right column stands off its gutter by this much
#let sig-left = 2.75in                  // the signature blocks' left edge (the right half of the page)

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/complaint.lua and docx/reference.xml set the
// same twips).
#let pitch-body = 27.6pt                // LCvR 7.1(d): double-spaced, twice the 13.8 pt single line of 12 pt Times
#let pitch-single = 13.8pt              // single spacing: court title, caption, headings, signature, page number
#let gap = 24pt                         // the block-spacing unit: caption to text, around the signature blocks, above a heading
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
  if m == none { panic("ncwd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names with *et al.*, quotations, and so on).
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

/// A body paragraph at the body pitch, its first line indented half an inch.
#let body-par(content, above: 0pt) = block(width: 100%, above: above, below: 0pt, par(unloose(content)))

/// A numbered paragraph (Fed. R. Civ. P. 10(b)): the number in its box after the first-line indent, then the text.
#let numbered(n, content) = body-par[#box(width: number-box)[#n.]#unloose(content)]

// ---------------------------------------------------------------------------
// First page: court title, caption, title of the paper
// ---------------------------------------------------------------------------

/// Fed. R. Civ. P. 10(a): the court's name; the division line when the filing uses one.
#let court-title(meta) = {
  let lines = ("IN THE UNITED STATES DISTRICT COURT", "FOR THE WESTERN DISTRICT OF NORTH CAROLINA")
  if "division" in meta and meta.division != none { lines.push(upper(meta.division)) }
  line-stack(lines.map(l => align(center, text(weight: "bold", l))))
}

/// The caption rows: each party's lines, then its designation; "v." between the parties. Every row is one line.
#let caption-rows(meta) = {
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.lines + (p.designation,)
  }
  rows
}

/// The parties at left, a ")" beside each row, and at right the civil action number, the title of the paper (bold)
/// and the jury demand, a gap between them.
#let caption(meta) = {
  let rows = caption-rows(meta)
  let number = if "case_number" in meta and meta.case_number != none and meta.case_number != "" {
    "Civil Action No. " + meta.case_number
  } else { "Civil Action No.:" }
  block(width: 100%, breakable: false, above: court-below, below: 0pt, grid(
    columns: (caption-left, caption-mark, 1fr),
    column-gutter: caption-gutter,
    line-stack(rows),
    line-stack(rows.map(_ => ")")),
    pad(left: caption-pad, {
      line-stack((number,))
      line-stack(above: caption-gap, meta.title.map(l => text(weight: "bold", inl(l))))
      if "jury_demand" in meta and meta.jury_demand {
        line-stack(above: caption-gap, (text(weight: "bold")[JURY TRIAL DEMANDED],))
      }
    }),
  ))
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// Headings, single-spaced and kept with the block after them: level 1 a centered bold section in capitals; level 2
/// a centered bold heading (a claim's title); level 3 a centered line (a claim's "(On Behalf of ...)" line).
#let heading-block(level, s) = {
  set text(..edges(pitch-single))
  let body = if level == 1 { text(weight: "bold", upper(inl(s))) } else if level == 2 { text(weight: "bold", inl(s)) } else { inl(s) }
  block(width: 100%, sticky: true, above: gap, below: heading-below,
    align(center, par(first-line-indent: 0pt, unloose(body))))
}

/// Signature block (Fed. R. Civ. P. 11(a)): the date at the margin, then "Respectfully submitted," and each firm's
/// block at the right half. A signing firm has a "By: /s/" line for the signer, then its lines (the signer's own name
/// is one of them); co-counsel has the firm and its lines only.
#let signature-block(sig) = {
  line-stack(above: gap, ("Dated: " + sig.date,))
  // The gap above is the outer block's own: a gap at the start of the pad would be dropped.
  block(width: 100%, above: gap, below: 0pt, pad(left: sig-left, {
    line-stack(("Respectfully submitted,",))
    for b in sig.blocks {
      let lines = if "by" in b and b.by != none { (b.firm, "By: /s/ " + b.by) + b.lines } else { (b.firm,) + b.lines }
      line-stack(above: gap, lines)
    }
  }))
}

/// The body. Each blank-line-separated chunk of markdown is one of:
///   `#` heading (levels 1 to 3), kept with the text after it;
///   `>` paragraph: unnumbered text, its first line indented (the class definition, the prayer's lead-in);
///   `1.` or `-` list: lettered A., B., ... (the prayer for relief), the letter half an inch in (the letters run on
///   through the body: a complaint has one prayer);
///   anything else: one numbered paragraph (Fed. R. Civ. P. 10(b)).
#let item-re = regex("^(\\d+\\.|[-*+])[ \\t]+")
#let allegations(chunks, n, k) = {
  let out = []
  for t in chunks {
    if t.starts-with("#") {
      let level = t.match(regex("^#+")).end
      out += heading-block(calc.min(level, 3), t.slice(level).trim())
    } else if t.starts-with(">") {
      out += body-par(inl(t.replace(regex("(?m)^>[ \t]?"), "")))
    } else if t.starts-with(item-re) {
      // One item per line that starts with a label; a line without one continues the item before it.
      let items = ()
      for l in t.split("\n").map(l => l.trim()).filter(l => l != "") {
        if l.starts-with(item-re) or items.len() == 0 { items.push(l.replace(item-re, "")) } else { items.last() += " " + l }
      }
      for item in items {
        k += 1
        out += block(width: 100%, above: 0pt, below: 0pt, pad(left: list-indent,
          par(first-line-indent: 0pt, hanging-indent: letter-box,
            [#box(width: letter-box)[#numbering("A.", k)]#unloose(inl(item))])))
      }
    } else {
      n += 1
      out += numbered(n, inl(t))
    }
  }
  (out, n, k)
}

#let ncwd-complaint(meta, body) = {
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
  // body pitch. Lists are written by allegations() (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays whole and with its number ("¶¶ 8–9", "§§ 206(a)"): typst would break between the signs.
  show regex("[§¶]{2,} \\S+"): it => box(it)

  court-title(meta)
  caption(meta)
  if "lead_in" in meta { body-par(above: gap, inl(meta.lead_in)) }

  // The last paragraph (or, when the body ends in a list, its last item) stays on the page with the signature block:
  // a signature never starts a page alone.
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let tail = chunks.last()
  if tail.starts-with(item-re) {
    let at = tail.matches(regex("(?m)^(\\d+\\.|[-*+])[ \\t]")).last().start
    if at > 0 { chunks = chunks.slice(0, -1) + (tail.slice(0, at).trim(), tail.slice(at)) }
  }
  let (main, n, k) = allegations(chunks.slice(0, -1), 0, 0)
  // The lead-in is absent: the first paragraph takes the gap below the caption.
  if not "lead_in" in meta { v(gap, weak: true) }
  main
  block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
    allegations(chunks.slice(-1), n, k).at(0)
    signature-block(meta.signature)
  })
}
