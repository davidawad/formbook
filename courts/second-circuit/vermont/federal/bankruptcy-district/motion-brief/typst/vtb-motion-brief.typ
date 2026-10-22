// U.S. Bankruptcy Court, District of Vermont: motion with memorandum (FRBP 9013; Vt. LBR 9013-1, 9013-5, 9013-6), in an
// adversary proceeding (the caption of FRBP 7010 and Official Form 416A).
//
// Rule-driven and content-agnostic. Requirement IDs VT-MB-... refer to ../README.md, VT-AC-... to
// ../../adversary-complaint/README.md.
// No case-specific text, no coordinates measured off any filed paper, no forced line
// breaks. The body is markdown rendered by cmarker; the metadata comes from the YAML
// frontmatter of the same sample file (contract: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // No rule names a face for filings; Times New Roman, the house standard and the exemplar's face (vendored metric twin).
#let type-size = 12pt                    // D. Vt. LBR 10(a)(4): no less than 12 point.
#let page-margin = 1in                   // VT-AC-002: no less than 3/4 inch, exclusive of page numbers.
#let indent = 0.5in                      // first-line indent of numbered paragraphs; lettered items and quotations this far in.
#let caption-left = 3.35in               // the debtor and parties boxes of the caption
#let caption-pad = 0.125in               // a box's text this far off its right rule
#let caption-foot = 6pt                  // and its last line this far above its bottom rule
#let caption-gap = 0.25in                // the case column this far off the boxes
#let designation-indent = 1.5in          // "Debtor.", "Plaintiff,", "Defendants." under the names
#let versus-indent = 0.5in               // "v." between the parties
#let signature-indent = 3in              // the signature lines stand 3 in. from the left margin
#let rule = 0.75pt

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 27.6pt               // VT-AC-003: Vt. LBR 5005-1(a)(5) 2.0 line spacing, Word's double (2 x 1.15 x 12 pt)
#let pitch-single = 13.8pt               // single spacing (1.15 x 12 pt): court, caption, title, quotations, signature

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics, bold) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("vtb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("vtb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it. An empty line keeps its
/// height.
#let line-block(above: 0pt, below: 0pt, height: auto, body) = block(width: 100%, above: above, below: below,
  height: if height != auto { height } else if body == "" or body == [] { pitch-single } else { auto }, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if type(body) == str { inl(body) } else { body }
})

// ---------------------------------------------------------------------------
// Caption (VT-AC-004: FRBP 7010 and Official Form 416A; FRBP 9004(b))
// ---------------------------------------------------------------------------

/// A caption box: one row per single line, the left cell ruled at its right, the case column beside it. Rows are
/// never split; the box may run over a page. Its foot, a short row ruled at its right and bottom, a tenth of a point
/// below (Word: a table of its own, as LibreOffice draws a table's last bottom rule again above its last page).
#let caption-box(left, right) = {
  let n = calc.max(left.len(), right.len())
  let cells = ()
  for i in range(n) {
    cells.push(table.cell(stroke: (right: rule), inset: (right: caption-pad), left.at(i, default: line-block(""))))
    cells.push(table.cell(inset: (left: caption-gap), right.at(i, default: line-block(""))))
  }
  table(columns: (caption-left, 1fr), stroke: none, inset: 0pt, ..cells)
  block(width: 100%, above: 0.1pt, below: 0pt, table(columns: (caption-left, 1fr), stroke: none, inset: 0pt,
    table.cell(stroke: (right: rule, bottom: rule), line-block(height: caption-foot, [])), []))
}

#let caption(meta) = {
  for l in need(meta, "court") { line-block(align(center, strong(inl(l)))) }
  let d = need(meta, "debtor")
  let c = need(meta, "caption")
  // the debtor box, a single line below the court
  block(width: 100%, above: pitch-single, below: 0pt, caption-box(
    (line-block[In re: #inl(d.name),], line-block(pad(left: designation-indent)[Debtor.])),
    (line-block[Chapter #d.chapter], line-block[Case No. #d.case_no]),
  ))
  // the parties box, its first line a blank one; a tenth of a point below the debtor box (Word: a table of its own)
  let left = (line-block(""),)
  for p in c.plaintiffs { left.push(line-block[#inl(p),]) }
  left.push(line-block(pad(left: designation-indent)[Plaintiff#if c.plaintiffs.len() > 0 [,]]))
  left.push(line-block(pad(left: versus-indent)[v.]))
  for dn in c.defendants { left.push(line-block(inl(dn))) }
  left.push(line-block(pad(left: designation-indent)[Defendants.]))
  block(width: 100%, above: 0.1pt, below: 0pt, caption-box(left,
    (line-block(""), line-block[Adv. Proc. No. #need(meta, "adv_no")])))
  // the title, a single line below the caption and above the body
  line-block(above: pitch-single, below: pitch-single, align(center, strong(inl(need(meta, "title")))))
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs after the unnumbered introduction, as filed
// ---------------------------------------------------------------------------

/// Blank-line-separated blocks of the markdown body.
#let body-blocks(body) = (
  body
    .replace("\r\n", "\n")
    .split("\n\n")
    .map(s => s.trim())
    .filter(s => s.len() > 0)
)

/// Headings at the body pitch, bold, sticky: levels 1 and 2 centered, level 3 bold italic at the margin.
#let heading(level, text) = block(width: 100%, sticky: true, above: 0pt, below: 0pt, {
  set par(first-line-indent: 0pt)
  let t = inl(text.trim())
  if level < 3 { align(center, strong(t)) } else { strong(emph(t)) }
})

/// A body block at the double pitch; `keep`: kept whole on the page of the block after it (the last block stays with
/// the signature).
#let body-par(content, left: 0pt, first: 0pt, keep: false) = block(width: 100%, above: 0pt, below: 0pt,
  sticky: keep, breakable: not keep,
  pad(left: left, par(first-line-indent: (amount: first, all: true), content)))

#let render-blocks(blocks, unnumbered: 0) = {
  // The first `unnumbered` paragraphs (an introduction, as filed) carry no number.
  let n = 0
  let seen = 0
  for (k, b) in blocks.enumerate() {
    let last = k == blocks.len() - 1
    if b.starts-with("### ") {
      heading(3, b.slice(4))
    } else if b.starts-with("## ") {
      heading(2, b.slice(3))
    } else if b.starts-with("# ") {
      heading(1, b.slice(2))
    } else if b.starts-with("> ") {
      // Quotation: single-spaced, indented both sides (LBR 5005-1(a)(5)), a single line above and below; one quoted
      // paragraph per block.
      block(width: 100%, above: pitch-single, below: pitch-single, sticky: last, breakable: not last,
        pad(left: indent, right: indent, {
          set text(..edges(pitch-single))
          par(first-line-indent: 0pt, inl(b.slice(2)))
        }))
    } else if b.starts-with("1. ") or b.starts-with("- ") {
      // Prayer and other lists: lettered (a), (b), ... half an inch in; one item per line.
      let items = b.split("\n")
      for (i, it) in items.enumerate() {
        let text = it.replace(regex("^\\s*(\\d+\\.|-)\\s+"), "")
        body-par(left: indent, keep: last and i == items.len() - 1,
          [(#"abcdefghijklmnopqrstuvwxyz".at(i)) #inl(text)])
      }
    } else {
      seen += 1
      if seen <= unnumbered {
        body-par(first: indent, keep: last, inl(b))
      } else {
        n += 1
        body-par(first: indent, keep: last, [#n. #inl(b)])
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Signature (VT-AC-006: LBR 5005-1(b), attorney identification below the signature line)
// ---------------------------------------------------------------------------

/// A single line below the body the dated line, a double line below it the signature lines 3 in. from the left
/// margin; single spaced, never broken across a page.
#let signature(meta) = {
  let s = need(meta, "signature")
  block(width: 100%, breakable: false, above: pitch-single, below: 0pt, {
    line-block(inl(s.at("dated")))
    block(width: 100%, above: pitch-double, below: 0pt, pad(left: signature-indent,
      for l in s.at("lines") { line-block(l) }))
  })
}

// ---------------------------------------------------------------------------
// Entry
// ---------------------------------------------------------------------------

#let vtb-motion-brief(meta, body) = {
  // VT-MB-001 (LBR 9013-1(f)(1)): a stipulated motion carries "stipulated" in its title.
  if meta.at("stipulated", default: false) and not lower(need(meta, "title")).contains("stipulated") {
    panic("vtb-motion-brief: a stipulated motion must include the word \"stipulated\" in its title (Vt. LBR 9013-1(f)(1))")
  }
  // VT-MB-002 (LBR 9013-5(a)): a motion and memorandum filed as one document name both in the caption.
  if meta.at("memorandum", default: false) and not lower(need(meta, "title")).contains("memorandum") {
    panic("vtb-motion-brief: a combined motion and memorandum must name the memorandum in the title (Vt. LBR 9013-5(a))")
  }
  // Pages numbered at the foot, centered, in a single line box, where Word's footer sets it.
  set page(paper: "us-letter", margin: page-margin, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("1"))))
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (2.0 line spacing).
  show: xengine.with(pitch: pitch-double, list-indent: none)
  // A doubled section sign stays with its number (xengine binds a single sign), as the docx filter binds it.
  show regex("[§¶]{2,} \\S+"): it => box(it)
  caption(meta)
  render-blocks(body-blocks(body), unnumbered: meta.at("unnumbered", default: 0))
  signature(meta)
}
