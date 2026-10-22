// Complaint for the U.S. District Court for the Western District of Washington (wawd).
// Rules: W.D. Wash. LCR 10(d)-(e) (page size, first-page space, margins, font, title, bottom notation,
// numbered paper); Fed. R. Civ. P. 10(a) (caption) and 10(b) (numbered paragraphs). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // LCR 10(e)(1): proportionally spaced font; Times New Roman as both exemplars (docs/FONTS.md)
#let type-size = 12pt                   // LCR 10(e)(1): 12 point or larger
#let lines-per-page = 27                // LCR 10(e)(5): numbered paper; 27 numbered lines fill the text block
#let page-w = 8.5in                     // LCR 10(d): 8 1/2 by 11 inch paper
#let page-h = 11in
#let top-margin = 72pt                  // LCR 10(e)(1): one-inch margins; line 1 sits on the top margin
#let left-margin = 1.5in                // room for the line numbers (LCR 10(e)(5): at least 1/2 inch to their left)
#let right-margin = 1in                 // LCR 10(e)(1): at least one inch
#let text-width = page-w - left-margin - right-margin
#let para-indent = 0.5in                // first-line indent of every body paragraph
#let number-box = 0.5in                 // a paragraph number's box after the indent: the text starts 1 in from the margin (docx: a tab)
#let prayer-indent = 0.5in              // a prayer item's number half an inch in ...
#let prayer-box = 0.4in                 // ... in a box of its own; the text hangs 0.9 in from the margin
#let caption-left = 3.1in               // the party column of the caption, closed by a rule at its right and foot
#let caption-pad = 10pt                 // the party text stands off that rule by this much ...
#let caption-foot = 8pt                 // ... and off the rule below it by this much
#let caption-gutter = 0.25in            // between the party column and the right column ...
#let caption-inset = 0.1in              // ... whose text stands off the gutter by this much
#let first-page-blank = 6               // LCR 10(e)(1): no less than three inches above the court title (lines 1-6 blank)
#let sig-left = 3.0in                   // the signature's date column ...
#let sig-gutter = 0.2in                 // ... and the signers' column 3.2 in from the margin

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/complaint.lua and docx/reference.xml set the
// same twips).
#let pitch-body = 24pt                  // LCR 10(e)(1): double spaced or exactly 24 points; the numbered lines are this pitch
#let pitch-single = 12pt                // single spacing (the caption, the signature): exactly 12 points, half a numbered
                                        // line, so every single line stands on the numbered line or halfway between two
#let half-line = 12pt                   // half a numbered line: between the caption's and the signature's items
#let single-drop = 9.6pt                // a single-spaced block starts this far below the top of a numbered line: its
                                        // first baseline (0.8 of 12 pt down) is then the number's (0.8 of 24 pt down)
// LCR 10(e)(3): the bottom notation, below the 27th line. The title and case number in 10 pt on a 12 pt pitch, the
// firm block in 9 pt on a 10.5 pt pitch; its foot 15.4 pt above the page's bottom edge (docx: footer distance 0.2 in,
// 288 twips, under the 1 pt closing paragraph a footer table needs).
#let notation-pitch = 12pt
#let firm-pitch = 10.5pt
#let notation-foot = 15.4pt
#let bottom-margin = page-h - top-margin - lines-per-page * pitch-body   // 72 pt: holds the bottom notation

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wawd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names with *italics*, section symbols, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Inline content without the paragraph breaks cmarker may put around it (they may not occur inside a paragraph).
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// Single-spaced lines, one paragraph each. `above`: the space before the first line. An item is a string
/// (markdown) or content.
#let line-stack(items, above: 0pt) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  let g = above
  for i in items {
    block(width: 100%, above: g, below: 0pt, par(unloose(if type(i) == str { inl(i) } else { i })))
    g = 0pt
  }
}

/// One line of the body pitch, its paragraph not indented.
#let line-par(c, above: 0pt, align-to: left) = block(width: 100%, above: above, below: 0pt,
  align(align-to, par(first-line-indent: 0pt, unloose(c))))

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Numbers 1 to 27 down the left margin, one per numbered line, each on the baseline of its line.
#let line-numbers() = {
  for i in range(1, lines-per-page + 1) {
    place(top + left, dx: 0pt, dy: top-margin + (i - 1) * pitch-body,
      block(width: left-margin - 0.5in, height: pitch-body,
        align(right, text(size: type-size, ..edges(pitch-body), str(i)))))
  }
}

/// The pleading rules: a double rule at the text's left edge, a single rule at its right.
#let pleading-rules() = {
  place(top + left, dx: left-margin - 0.2in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: left-margin - 0.16in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: page-w - right-margin + 0.1in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
}

/// LCR 10(e)(3): bottom notation. Left: abbreviated title, case number and page number.
/// Right: the firm, mailing address and telephone of the preparing attorney. Its foot is fixed (Word grows a footer
/// upward from its foot), both columns from the top of the row.
#let footer-block(title, case-number, firm) = place(
  bottom + left,
  dx: left-margin,
  dy: -notation-foot,
  block(width: text-width, grid(
    columns: (1fr, auto),
    column-gutter: 0.3in,
    align: (left + top, right + top),
    {
      set text(size: 10pt, ..edges(notation-pitch))
      set par(first-line-indent: 0pt)
      block(above: 0pt, below: 0pt, par(upper(title)))
      block(above: 0pt, below: 0pt, par[(Case No. #case-number) -- #context counter(page).display()])
    },
    {
      set text(size: 9pt, ..edges(firm-pitch))
      set par(first-line-indent: 0pt)
      for l in firm { block(above: 0pt, below: 0pt, par(l)) }
    },
  )),
)

// ---------------------------------------------------------------------------
// Cover: judge (line 1), court title (line 7), caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  for l in ("UNITED STATES DISTRICT COURT", "WESTERN DISTRICT OF WASHINGTON", upper(meta.location)) {
    line-par(align-to: center, text(weight: "bold", l))
  }
}

/// A block of single-spaced lines on the numbered paper, built by `cells(h)` at row height `h` (auto: its natural
/// height): its cells start their text `single-drop` below the top of a numbered line, so every single line's
/// baseline is a number's baseline or halfway between two, and the row is rounded up to whole numbered lines, so the
/// text after it stays on them. docx/complaint.lua computes the same heights from the same lines.
#let on-grid(cells, above: pitch-body, below: 0pt) = block(width: 100%, breakable: false, above: above, below: below,
  context {
    let h = measure(width: text-width, cells(auto)).height
    cells(calc.ceil(h / pitch-body - 0.001) * pitch-body)
  })

/// The caption: the parties at left in a column closed by a rule at its right and foot, the case number, the title
/// (bold) and the notes (jury demand) at right, on whole numbered lines.
#let caption(meta) = {
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names + (p.designation,)
  }
  let parties = pad(top: single-drop, right: caption-pad, bottom: caption-foot, line-stack(rows))
  let right = pad(top: single-drop, left: caption-inset, {
    line-stack(("Case No. " + meta.case_number,))
    line-stack(above: half-line, (text(weight: "bold", inl(meta.brief_title)),))
    for note in meta.at("caption_notes", default: ()) {
      line-stack(above: half-line, (text(weight: "bold", inl(note)),))
    }
  })
  on-grid(below: pitch-body, h => grid(
    columns: (caption-left, caption-gutter, 1fr),
    rows: h,
    grid.cell(stroke: (right: 0.75pt, bottom: 0.75pt), parties),
    [],
    right,
  ))
}

#let cover(meta) = {
  // Lines 1-6: the judge's name on line 1 (LCR 10(e)(1) lets the judge's name sit in the margin), then blank.
  line-par(align-to: right, text(weight: "bold", if "judge" in meta { meta.judge } else { "" }))
  v((first-page-blank - 1) * pitch-body)
  court-title(meta)
  caption(meta)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// The signature block (LCR 10(e)(4): dated and signed): the date at left; "Respectfully submitted," the firm and the
/// signers at 3.2 in, on whole numbered lines; a numbered line below, the rest of the counsel list and the role.
#let signature-block(meta) = {
  let sig = meta.signature
  // One unbreakable block: the counsel list stays with the signers.
  block(width: 100%, breakable: false, above: pitch-body, below: 0pt, {
    on-grid(above: 0pt, h => grid(
      columns: (sig-left, 1fr),
      rows: h,
      column-gutter: sig-gutter,
      pad(top: single-drop, line-stack((sig.date,))),
      pad(top: single-drop, {
        line-stack(("Respectfully submitted,",))
        if "firm" in sig and sig.firm != "" { line-stack(above: half-line, (sig.firm,)) }
        line-stack(above: half-line, sig.signers.enumerate().map(((k, s)) => if k == 0 { "By: " + s } else { s }))
      }),
    ))
    if "additional" in sig {
      let rows = sig.additional
      if "role" in sig { rows.push(sig.role) }
      pad(top: pitch-body + single-drop, line-stack(rows))
    }
  })
}

/// A heading on the body pitch, kept with the block after it: level 1 centered bold capitals; level 2 centered roman
/// (a cause of action's sub-caption); level 3 bold, left.
#let heading-block(level, s) = {
  let body = if level == 1 { text(weight: "bold", upper(inl(s))) }
    else if level == 2 { inl(s) }
    else { text(weight: "bold", inl(s)) }
  block(width: 100%, sticky: true, above: 0pt, below: 0pt,
    align(if level <= 2 { center } else { left }, par(first-line-indent: 0pt, unloose(body))))
}

/// Numbered allegations. Each blank-line-separated chunk of markdown that is neither a heading nor a list is one
/// numbered paragraph (Fed. R. Civ. P. 10(b)): the number in its box after the first-line indent, then the text.
/// The paragraphs under the prayer and the jury demand are not allegations: they are not numbered. A list (the
/// prayer) is numbered 1., 2., ..., each item half an inch in, its text hanging after the number's box.
/// `st`: (unnumbered, paragraph number, item number) carried from the chunks before; returns (content, st).
#let item-re = regex("^(\\d+\\.|[-*+])[ \\t]+")
#let allegations(chunks, st) = {
  let (unnumbered, n, k) = st
  let out = []
  for t in chunks {
    if t.starts-with("#") {
      let level = t.match(regex("^#+")).end
      let s = t.slice(level).trim()
      unnumbered = s.contains("PRAYER FOR RELIEF") or s.contains("DEMAND FOR JURY TRIAL")
      k = 0
      out += heading-block(calc.min(level, 3), s)
    } else if t.starts-with(item-re) {
      // One item per line that starts with a label; a line without one continues the item before it.
      let items = ()
      for l in t.split("\n").map(l => l.trim()).filter(l => l != "") {
        if l.starts-with(item-re) or items.len() == 0 { items.push(l.replace(item-re, "")) } else { items.last() += " " + l }
      }
      let ordered = t.starts-with(regex("^\\d"))
      for item in items {
        k += 1
        out += block(width: 100%, above: 0pt, below: 0pt, pad(left: prayer-indent,
          par(first-line-indent: 0pt, hanging-indent: prayer-box,
            [#box(width: prayer-box)[#if ordered [#k.] else [•]]#unloose(inl(item))])))
      }
    } else if unnumbered {
      out += block(width: 100%, above: 0pt, below: 0pt, par(unloose(inl(t))))
    } else {
      n += 1
      out += block(width: 100%, above: 0pt, below: 0pt, par[#box(width: number-box)[#n.]#unloose(inl(t))])
    }
  }
  (out, (unnumbered, n, k))
}

#let wawd-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      set text(font: font-family, fallback: false)
      line-numbers()
      pleading-rules()
    },
    foreground: {
      set text(font: font-family, fallback: false, hyphenate: false, kerning: false, ligatures: false)
      footer-block(meta.footer_title, meta.case_number, meta.footer_firm)
    },
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch. Lists are written by allegations() (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // No break inside a dotted token ("www.ironleafcapital.com", "L.P."): typst may break before an inner period,
  // which Word and LibreOffice never do.
  show regex("\\w+(\\.\\w+)+"): it => box(it)
  // A doubled sign stays whole and with its number ("§§ 1331", "¶¶ 8–9"): typst would break between the signs.
  show regex("[§¶]{2,} \\S+"): it => box(it)

  cover(meta)
  // The last paragraph (or, when the body ends in a list, its last item) stays on the page with the signature block:
  // a signature never starts a page alone.
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let tail = chunks.last()
  if tail.starts-with(item-re) {
    let at = tail.matches(regex("(?m)^(\\d+\\.|[-*+])[ \\t]")).last().start
    if at > 0 { chunks = chunks.slice(0, -1) + (tail.slice(0, at).trim(), tail.slice(at)) }
  }
  let (main, st) = allegations(chunks.slice(0, -1), (false, 0, 0))
  main
  block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
    allegations(chunks.slice(-1), st).at(0)
    signature-block(meta)
  })
}
