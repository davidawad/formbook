// Complaint for the U.S. District Court for the District of Nevada (nvd).
// Rules: LR IA 10-1 (numbered lines, 28 per page, double-spaced text, 12 pt or larger, one-inch margins,
// numbered pages; quotations over 50 words indented and single spaced), LR IA 10-2 (first-page format), LR 38-1
// (JURY DEMAND below the title); Fed. R. Civ. P. 10(a) (caption), 10(b) (numbered paragraphs). See ../README.md for
// the rule text and the choices made here.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
//
// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is explicit; the docx
// engine (docx/nvd-complaint.lua, docx/reference.xml) sets the same twips. Every vertical length below is a whole
// multiple of 4.6 pt (92 twips), so each text line sits level with a line number, or clear of it.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // LR IA 10-1(a)(3) names no face: the house face (docs/FONTS.md)
#let type-size = 12pt                   // LR IA 10-1(a)(3): 12 pt or larger (the filed exemplar's size)
#let lines-per-page = 28                // LR IA 10-1(a)(1): no more than 28 numbered lines per page
#let page-w = 8.5in                     // LR IA 10-1(c): 8 1/2 by 11 inch paper
#let page-h = 11in
#let top-margin = 1in                   // LR IA 10-1(a)(6): margins at least one inch on all four sides
#let bottom-margin = 1in
#let pitch = 23pt                       // one numbered line (460 twips): 28 of them fit between the 1 in margins
#let pitch-single = 13.8pt              // a single-spaced line (276 twips): counsel, caption, quotations, signature
#let gap-small = 4.6pt                  // between the claims of the caption's summary (92 twips)
#let single-shift = 0.5pt               // space before a run of single lines (10 twips), and after it
#let single-resync = 4.1pt              // (82 twips): every vertical length is otherwise a multiple of 4.6 pt, so each
                                        // single line's baseline is level with a line number or 4.6 pt clear of it
#let left-margin = 1.5in                // room for the line numbers and the pleading rules
#let right-margin = 1in
#let number-right = 1.05in              // the line numbers end this far from the page's left edge (a one-digit number starts left of 1 in)
#let para-indent = 0.5in                // first-line indent; the paragraph number's box after it (FRCP 10(b))
#let caption-left = 3.2in               // width of the party column of the caption
#let caption-gutter = 0.2in             // between the party column's rule and the right column
#let caption-pad = 10pt                 // the party text stops this far left of the rule
#let caption-bottom = 8.7pt             // the bottom rule stands this far below the last party line (single-resync + 4.6 pt)
#let caption-right-pad = 0.1in          // the right column's text starts this far right of the gutter
#let designation-indent = 1.2in         // a party's designation stands this far in
#let summary-hang = 0.35in              // a claim of the caption's summary hangs this far
#let sig-indent = 2.6in                 // the signature block's left edge
#let counsel-lines = 7                  // the counsel block occupies at least lines 1 to 7
#let footer-foot = 0.5in                // the footer's last line box ends this far above the page's bottom edge

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nvd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line block (a paragraph of its own), with explicit space above and below.
#let line-block(above: 0pt, below: 0pt, left: 0pt, hang: 0pt, body) = block(width: 100%, above: above, below: below,
  pad(left: left, {
    set text(..edges(pitch-single))
    par(first-line-indent: 0pt, hanging-indent: hang, body)
  }))

/// A body block at the numbered pitch: `first` is the first-line indent.
#let body-block(first: 0pt, left: 0pt, hang: 0pt, sticky: false, align-to: left, body) = block(width: 100%,
  above: 0pt, below: 0pt, sticky: sticky, pad(left: left,
    align(align-to, par(first-line-indent: (amount: first, all: true), hanging-indent: hang, body))))

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Numbers 1 to 28 down the left margin, one per numbered line (line boxes of the pitch from the top margin).
#let line-numbers() = {
  for i in range(1, lines-per-page + 1) {
    place(top + left, dx: 0pt, dy: top-margin + (i - 1) * pitch,
      block(width: number-right, height: pitch,
        align(right, text(..edges(pitch), str(i)))))
  }
}

/// The pleading rules: a double rule at the text's left edge, a single rule at its right.
#let pleading-rules() = {
  place(top + left, dx: left-margin - 0.2in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: left-margin - 0.16in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: page-w - right-margin + 0.1in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
}

/// Page number ("-1-") and, when the sample gives one, the paper's title, in single-spaced line boxes whose foot is
/// `footer-foot` above the page's bottom edge (LR IA 10-1(a)(5); 12 pt, LR IA 10-1(a)(3)).
#let footer-block(title) = {
  let n = if title == none { 1 } else { 2 }
  place(top + left, dx: left-margin, dy: page-h - footer-foot - n * pitch-single,
    block(width: page-w - left-margin - right-margin, {
      set text(..edges(pitch-single))
      set par(first-line-indent: 0pt)
      align(center, context counter(page).display("-1-"))
      if title != none { block(width: 100%, above: 0pt, below: 0pt, align(center, upper(title))) }
    }))
}

// ---------------------------------------------------------------------------
// Cover: counsel (single spaced, LR IA 10-2), court title, caption, title of the paper
// ---------------------------------------------------------------------------

/// Counsel on lines 1 to 7 at least: single lines, then the space left to the 8th numbered line (a longer block is
/// followed by single-resync), then a blank numbered line.
#let counsel-block(meta) = {
  let n = meta.counsel.len()
  let h = n * pitch-single
  let target = calc.max(counsel-lines * pitch, single-shift + h + single-resync)
  v(single-shift)
  for c in meta.counsel { line-block(inl(c)) }
  v(target - single-shift - h)
  v(pitch)
}

#let caption(meta) = block(width: 100%, above: 0pt, below: 0pt, breakable: false, grid(
  columns: (caption-left, caption-gutter, 1fr),
  stroke: (x, y) => if x == 0 { (right: 0.75pt, bottom: 0.75pt) } else { none },
  inset: (x, y) => if x == 0 { (top: single-shift, right: caption-pad, bottom: caption-bottom) } else if x == 2 {
    (top: single-shift, left: caption-right-pad, bottom: single-resync) } else { 0pt },
  {
    // Each party: its names, then its designation (indented); the separator ("v.") between the parties, a single
    // line clear above and below it.
    let sep = meta.caption.at("separator", default: "v.")
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { line-block(above: pitch-single, below: pitch-single, inl(sep)) }
      for n in p.names { line-block(inl(n)) }
      line-block(left: designation-indent, inl(p.designation))
    }
  },
  [],
  {
    line-block(inl("Case No.: " + meta.case_number))
    line-block(above: pitch-single, strong(inl(meta.brief_title)))
    // LR 38-1: "JURY DEMAND" in capitals on the first page, immediately below the title of the pleading.
    if meta.at("jury_demand", default: false) == true {
      line-block(above: pitch-single, strong("JURY DEMAND"))
    }
    // The complaint's first-page list of causes of action, one hanging item each.
    let summary = meta.at("summary", default: none)
    if summary != none {
      for (k, s) in summary.enumerate() {
        line-block(above: if k == 0 { pitch-single } else { gap-small }, hang: summary-hang,
          [(#(k + 1)) #strong(inl(s))])
      }
    }
  },
))

#let cover(meta) = {
  counsel-block(meta)
  body-block(align-to: center, strong("UNITED STATES DISTRICT COURT"))
  body-block(align-to: center, strong("DISTRICT OF NEVADA"))
  v(pitch)
  caption(meta)
  pagebreak()
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// The date, a blank numbered line, then the signature block at `sig-indent`: the firm, a single line clear, "By: /s/"
/// and the signer's lines. One block that does not break.
#let signature-block(meta) = block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
  body-block(inl(meta.date))
  v(pitch + single-shift)
  for l in meta.signature.firm { line-block(left: sig-indent, inl(l)) }
  line-block(above: pitch-single, left: sig-indent, inl("By: /s/ " + meta.signature.signer))
  for l in meta.signature.lines { line-block(left: sig-indent, inl(l)) }
})

/// Numbered allegations. Each blank-line-separated chunk of markdown that is neither a heading, a list, a
/// parenthetical nor a quotation is one numbered paragraph (Fed. R. Civ. P. 10(b)): the number in a box of the
/// paragraph indent after the first-line indent, then the text. Headings stay with the block after them.
#let allegations(body, unnumbered) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let n = 0
  // The section the chunk is in (its level 1 heading, upper case). Sections listed in the sample's
  // `unnumbered_sections` (the prayer and the jury demand) take unnumbered paragraphs.
  let section = ""
  for c in chunks {
    let t = c.trim()
    let h = t.match(regex("^(#+)\\s+(.*)$"))
    if h != none {
      let level = h.captures.at(0).len()
      let text = h.captures.at(1).trim()
      if level == 1 {
        section = upper(text)
        body-block(sticky: true, align-to: center, strong(upper(inl(text))))
      } else if level == 2 {
        body-block(sticky: true, align-to: center, strong(inl(text)))
      } else {
        body-block(sticky: true, strong(emph(inl(text))))
      }
    } else if t.starts-with("(") and t.ends-with(")") {
      // A parenthetical line under a claim heading ("(Plaintiff ... against Defendant ...)"): centered, unnumbered.
      body-block(sticky: true, align-to: center, inl(t))
    } else if t.starts-with(">") {
      // A quotation: single spaced, indented half an inch on both sides, unnumbered (LR IA 10-1(a)(4)).
      let paras = t.replace(regex("(?m)^>[ \\t]?"), "").split(regex("\\n[ \\t]*\\n"))
      let last = paras.len() - 1
      for (k, p) in paras.enumerate() {
        block(width: 100%, above: if k == 0 { single-shift } else { 0pt }, below: if k == last { single-resync } else { 0pt },
          pad(left: para-indent, right: para-indent, line-block(inl(p.trim()))))
      }
    } else if t.starts-with(regex("^\\d+\\.[ \\t]")) {
      // A numbered list (the prayer): the number in a half-inch box half an inch in, the text hanging after it.
      let items = t.matches(regex("(?m)^(\\d+)\\.[ \\t]+(.*)$"))
      for m in items {
        body-block(left: para-indent, hang: para-indent,
          [#box(width: para-indent, m.captures.at(0) + ".")#inl(m.captures.at(1).trim())])
      }
    } else if unnumbered.contains(section) {
      body-block(first: para-indent, inl(t))
    } else {
      n += 1
      body-block(first: para-indent, [#box(width: para-indent, str(n) + ".")#inl(t)])
    }
  }
}

#let nvd-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    foreground: footer-block(meta.at("footer_title", default: none)),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // numbered pitch.
  show: xengine.with(pitch: pitch, list-indent: none)

  cover(meta)

  if "lead_in" in meta and meta.lead_in != none {
    body-block(first: para-indent, inl(meta.lead_in))
  }
  allegations(body, meta.at("unnumbered_sections", default: ()).map(upper))
  signature-block(meta)
}
