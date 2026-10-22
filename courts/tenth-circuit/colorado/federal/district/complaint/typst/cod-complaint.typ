// Complaint for the U.S. District Court for the District of Colorado (cod).
// Rules: D.C.COLO.LCivR 10.1 (paper, margins, font, double spacing, one side); 5.1(a) (CM/ECF format);
// Fed. R. Civ. P. 8(a), 10(a) (caption), 10(b) (numbered paragraphs), 11(a) (signature), 38(b) (jury demand).
// See ../README.md. Content-agnostic: every case-specific word comes from the sample's frontmatter and body.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // LCivR 10.1(d) names no face: Times New Roman, the house standard and the exemplar's face (docs/FONTS.md); vendored in fonts/
#let type-size = 12pt                   // LCivR 10.1(d): not less than 12-point font
#let margin-top = 1.5in                 // LCivR 10.1(c): 1 1/2 inches at the top
#let margin-side = 1in                  // LCivR 10.1(c): 1 inch at the left and right
#let margin-bottom = 1in                // LCivR 10.1(c): 1 inch at the bottom
#let para-indent = 0.5in                // first-line indent; the paragraph number in a box of it
#let designation-indent = 0.5in         // a party's designation ("Plaintiff,") in the caption
#let list-indent = 0.5in                // prayer items: the label half an inch in
#let list-label = 0.5in                 // prayer items: the label's box, the text hanging after it
#let quote-indent = 1in                 // block quotations: indented 1 inch on each side
#let signature-indent = 3in             // the firm and signer lines stand this far from the left margin

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt                // LCivR 10.1(e): double spaced, 2 x the type size
#let pitch-single = 13.8pt              // single spacing (court title, caption, headings, quotations, signature): 1.15 x

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("cod-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with quotation marks, *et seq.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line block (a paragraph of its own), with explicit space above it. An empty line keeps its
/// height.
#let line-block(above: 0pt, indent: 0pt, body) = block(width: 100%, above: above, below: 0pt,
  height: if body == "" or body == [] { pitch-single } else { auto }, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: indent, if type(body) == str { inl(body) } else { body })
})

// ---------------------------------------------------------------------------
// Caption (Fed. R. Civ. P. 10(a)): court, civil action number, parties, title of the paper. No separate cover
// page; pages are numbered in the footer, set in #cod-complaint below.
// ---------------------------------------------------------------------------

/// The court in two centered bold lines; a double line below them "Civil Action No." (a blank to fill in when the
/// sample has no number); a double line below that the parties: each party's names, a blank line and its designation
/// half an inch in, "v." between the parties with a blank line on each side; a double line below them the title,
/// centered and bold. Single lines; never split.
#let caption(meta) = block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
  line-block(align(center, strong[IN THE UNITED STATES DISTRICT COURT]))
  line-block(align(center, strong[FOR THE DISTRICT OF COLORADO]))
  let cn = meta.at("case_number", default: none)
  if cn == none or cn == "" { cn = "_" * 18 }
  line-block(above: pitch-double, [#("Civil Action No. " + cn)])   // text, not markdown (a run of underscores)
  for (k, p) in meta.caption.enumerate() {
    if k > 0 {
      line-block("")
      line-block[v.]
      line-block("")
    }
    for (j, n) in p.names.enumerate() { line-block(above: if k == 0 and j == 0 { pitch-double } else { 0pt }, n) }
    line-block("")
    line-block(indent: designation-indent, p.designation)
  }
  line-block(above: pitch-double, align(center, strong(inl(meta.title))))
})

// ---------------------------------------------------------------------------
// Body: headings, numbered paragraphs, quotations, lists, signature
// ---------------------------------------------------------------------------

/// A heading, single-spaced, a single line above and below it, sticky so it never ends a page: level 1 centered bold
/// capitals, level 2 centered bold, level 3 bold italic at the margin.
#let heading-block(level, c, above: pitch-single) = block(width: 100%, above: above, below: pitch-single,
  sticky: true, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if level == 1 { align(center, strong(upper(inl(c)))) }
  else if level == 2 { align(center, strong(inl(c))) }
  else { strong(emph(inl(c))) }
})

/// A body paragraph at the double pitch: the first-line indent, then (when numbered, Fed. R. Civ. P. 10(b)) the
/// number in a box of the paragraph indent and the text after it. `keep`: kept whole on the page of the block after it
/// (the last block stays with the signature).
#let body-par(num, content, keep: false, above: 0pt) = block(width: 100%, above: above, below: 0pt, sticky: keep,
  breakable: not keep,
  par(first-line-indent: (amount: para-indent, all: true),
    if num == none { content } else { [#box(width: para-indent, [#num.])#content] }))

/// A block quotation: its paragraphs single-spaced, indented on both sides, a single line above, below and between
/// them (LCivR 10.1(e) double spaces the pleading; quoted matter is set off single-spaced, as filers do).
#let quotation(t, keep: false) = {
  let src = t.split("\n").map(l => l.replace(regex("^[ \\t]*>[ \\t]?"), "")).join("\n")
  let paras = src.split(regex("\\n[ \\t]*\\n")).map(c => c.trim()).filter(c => c != "")
  for (k, q) in paras.enumerate() {
    let last = k == paras.len() - 1
    block(width: 100%, above: pitch-single, below: if last { pitch-single } else { 0pt },
      sticky: keep and last, breakable: not (keep and last), {
      set text(..edges(pitch-single))
      set par(first-line-indent: 0pt)
      pad(left: quote-indent, right: quote-indent, inl(q))
    })
  }
}

/// The body in order (README.md, markdown contract). The frontmatter's `lead_in` is an unnumbered paragraph before
/// it. A `#` heading is unnumbered. A `>` chunk is a block quotation. A list chunk (`1.` items) is lettered A., B., ...
/// by number (the prayer), a `-` list takes bullets. A paragraph starting with `~ ` is unnumbered (the preliminary
/// statement, the WHEREFORE clause, the jury demand). Any other paragraph is numbered. The last block is kept whole
/// with the signature block.
#let allegations(meta, body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  if "lead_in" in meta { chunks.insert(0, "~ " + meta.lead_in) }
  let n = 0
  for (k, t) in chunks.enumerate() {
    let keep = k == chunks.len() - 1
    // the body a double line below the caption
    let above = if k == 0 { pitch-double } else { 0pt }
    let h = t.match(regex("^(#+)\\s+(.*)$"))
    if h != none {
      heading-block(h.captures.at(0).len(), h.captures.at(1), above: calc.max(above, pitch-single))
    } else if t.starts-with(">") {
      quotation(t, keep: keep)
    } else if t.match(regex("^(\\d+\\.|[-*+])[ \\t]")) != none {
      // one item per marker line; a line without a marker continues the item before it
      let items = ()
      for l in t.split(regex("\\r?\\n")) {
        if l.match(regex("^(\\d+\\.|[-*+])[ \\t]")) != none or items.len() == 0 { items.push(l) }
        else { items.push(items.pop() + "\n" + l) }
      }
      for (j, it) in items.enumerate() {
        let m = it.match(regex("^(\\d+\\.|[-*+])[ \\t]+([\\s\\S]*)$"))
        let lab = if m.captures.at(0).ends-with(".") { numbering("A.", int(m.captures.at(0).slice(0, -1))) } else { [•] }
        let last = keep and j == items.len() - 1
        block(width: 100%, above: if j == 0 { above } else { 0pt }, below: 0pt, sticky: last, breakable: not last,
          pad(left: list-indent, par(first-line-indent: 0pt, hanging-indent: list-label,
            [#box(width: list-label, lab)#inl(m.captures.at(1))])))
      }
    } else if t.starts-with("~ ") {
      body-par(none, inl(t.slice(2).trim()), keep: keep, above: above)
    } else {
      n += 1
      body-par(n, inl(t), keep: keep, above: above)
    }
  }
}

/// Signature block (LCivR 5.1; Fed. R. Civ. P. 11(a)), a double line below the body: the intro lines (the date,
/// "Respectfully submitted,") at the margin; a blank line, then the firm; each signer a blank line below, "s/ Name"
/// (or the sample's `sig_line`), the name and the contact lines; a blank line and the role. The firm, signer and role
/// lines stand 3 in from the left margin. Single-spaced, never split.
#let signature(sig) = block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
  for l in sig.at("intro", default: ()) { line-block(l) }
  if "firm" in sig {
    line-block("")
    line-block(indent: signature-indent, sig.firm)
  }
  for s in sig.signers {
    line-block("")
    line-block(indent: signature-indent, s.at("sig_line", default: "s/ " + s.name))
    line-block(indent: signature-indent, s.name)
    for l in s.at("lines", default: ()) { line-block(indent: signature-indent, l) }
  }
  if "role" in sig {
    line-block("")
    line-block(indent: signature-indent, sig.role)
  }
})

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

/// `meta`: the frontmatter (see README.md, markdown contract). `body`: the markdown after it.
#let cod-complaint(meta, body) = {
  // Pages numbered at the bottom, centered; the number in a single-spaced line box, so it sits where Word's footer
  // sets it.
  set page(paper: "us-letter",
    margin: (top: margin-top, bottom: margin-bottom, left: margin-side, right: margin-side),
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("1"))))
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (LCivR 10.1(e): double spaced).
  show: xengine.with(pitch: pitch-double, list-indent: list-label)
  // A doubled section sign stays with its number (xengine binds a single sign), as the docx filter binds it.
  show regex("[§¶]{2,} \\S+"): it => box(it)

  caption(meta)
  allegations(meta, body)
  signature(meta.signature)
}
