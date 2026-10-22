// San Diego County Superior Court (calsuperct-sandiego): civil complaint on pleading paper.
//
// Rule-driven and content-agnostic. The governing rules are Cal. Rules of Court 2.100-2.119 and
// the San Diego Superior Court Local Rules, Division II (see ../README.md for the rule numbers, URLs
// and the date each was verified). No case-specific text, no coordinates measured off the filed
// exemplar, no forced line breaks. The markdown body is rendered by cmarker; the metadata comes
// from the YAML frontmatter of the same file.

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/pleading-paper.typ": line-numbers as shared-line-numbers, pleading-rules as shared-pleading-rules
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters: the only numbers in this file. Each one traces to a rule or is a named style choice.
// ---------------------------------------------------------------------------

// CRC 2.105: "essentially equivalent to Courier, Times New Roman, or Arial". No face is named, so
// the house face applies: Times New Roman (Liberation Serif, its metric twin, as the fallback).
#let font-family = ("Times New Roman", "Liberation Serif")
#let type-size = 12pt              // CRC 2.104: a font size not smaller than 12 points.
#let lines-per-page = 28           // numbered lines per page (pleading convention, tier 2; CRC 2.108 sets no count).
#let page-w = 8.5in
#let page-h = 11in
#let top-margin = 1in              // line 1 starts 1 inch from the top (CRC 2.111(1)).
#let left-margin = 1.5in           // text starts here; CRC 2.107 requires at least 1 inch.
#let right-margin = 0.5in          // CRC 2.107 requires at least 1/2 inch.
#let clerk-lines = 7               // lines 1-7 keep the right of center clear (CRC 2.111(2)).
#let para-indent = 0.5in
#let fee-width = 2.3in             // the fee-exemption label's column, top right (SD Local Rule 2.1.2(H)).
#let caption-left = 3.6in          // the party column of the caption.
#let caption-inset = 9pt           // the party column's text stands off its right rule
#let caption-foot = 9pt            // and its last line off its bottom rule
#let caption-right = 0.2in         // the case column stands off the party column's rule
#let space-indent = 3pt            // a leading space in a caption line indents it by a quarter em (12 pt)
#let signature-left = 3.1in        // the signature column
#let signer-indent = 0.3in         // the signer's name and role, in from the signature column
#let signature-rule = 2.7in        // the signature line after "By:"
#let footer-size = 10pt            // CRC 2.110: the footer title in at least 10-point type.

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is set here (Word's exact
// line spacing; docx/calsuperct-sandiego-complaint.lua sets the same twips).
#let pitch = 24pt                  // double spacing (CRC 2.108(1)); the numbered lines are this pitch.
#let pitch-single = 12pt           // single spacing (attorney block, caption, signature): two lines to a numbered line.
#let gap = pitch-single            // a single line between the groups of the caption and the signature
// A group of single lines starts this far below a numbered line's top, so every second single line stands level
// with a line number and the others halfway between two: the PDF text reads the same lines in every engine.
#let single-drop = 0.8 * (pitch - pitch-single)
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 48 pt: holds the footer
#let footer-gap = 4pt              // the footer's rule this far below the last numbered line
#let footer-rule-gap = 2pt         // the page number's line box this far below the rule

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Block markdown (a chunk of the body).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

#let need(meta, key) = {
  if key not in meta { panic("calsuperct-sandiego-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("calsuperct-sandiego-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Single-spaced lines, one paragraph per item, with `above` before the first. An empty item is an empty line;
/// leading spaces in an item indent it by a quarter em each, so the caption's "Plaintiff," and "v." sit where the
/// filer put them.
#let line-stack(items, above: 0pt, weight: "regular", align-to: left) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single), weight: weight)
  set par(first-line-indent: 0pt)
  for it in items {
    let m = it.match(regex("^( *)(.*)$"))
    let n = m.captures.at(0).len()
    let t = m.captures.at(1)
    if t == "" { block(height: pitch-single) } else {
      block(width: 100%, inset: (left: n * space-indent), align(align-to, inl(t)))
    }
  }
})

// ---------------------------------------------------------------------------
// Pleading paper: 28 numbered lines, two vertical rules, footer below the page number
// ---------------------------------------------------------------------------

#let line-numbers() = shared-line-numbers(left-margin, top-margin, pitch, lines-per-page, type-size, ..edges(pitch))

#let pleading-rules() = shared-pleading-rules(page-w, page-h, left-margin, right-margin)

/// Footer (CRC 2.109, 2.110): a printed line, the page number, then the title of the paper in at least 10-point
/// type, in the bottom margin below the last numbered line.
#let footer-block(title) = place(
  top + left,
  dx: left-margin,
  dy: top-margin + lines-per-page * pitch + footer-gap,
  block(width: page-w - left-margin - right-margin, {
    line(length: 100%, stroke: 0.5pt)
    block(above: footer-rule-gap, below: 0pt, {
      set text(..edges(pitch-single))
      align(center, context counter(page).display())
    })
    block(above: 0pt, below: 0pt, {
      set text(size: footer-size, ..edges(pitch-single))
      align(center, title)
    })
  }),
)

// ---------------------------------------------------------------------------
// First page (CRC 2.111): attorney block on line 1, court title on line 8, caption
// ---------------------------------------------------------------------------

/// Top of the first page: the attorney block, single spaced from line 1, left of center, on lines 1-7 at least
/// (CRC 2.111(1), (2)); more lines push the court title down to the next numbered line. When the filer is exempt
/// from fees (Gov. Code, § 6103), the label goes in the upper right-hand corner above the caption, clear of the
/// clerk's file-stamp area (SD Local Rule 2.1.2(H)).
#let first-page-top(meta) = {
  let att = need(meta, "attorney")
  let fee = meta.at("fee_exempt", default: ())
  let rows = calc.max(att.len(), fee.len())
  let n = calc.max(clerk-lines, calc.ceil((single-drop + rows * pitch-single) / pitch))
  if fee.len() > 0 {
    grid(columns: (1fr, fee-width), column-gutter: 0pt,
      block(height: n * pitch, inset: (top: single-drop), line-stack(att)),
      block(height: n * pitch, inset: (top: single-drop), line-stack(fee, align-to: right)))
  } else {
    block(height: n * pitch, inset: (top: single-drop), line-stack(att))
  }
}

/// Court title: centered, bold, one numbered line each, from line 8 (CRC 2.111(3)).
#let court-title(meta) = {
  for l in need(meta, "court") { block(align(center, text(weight: "bold", inl(l)))) }
}

/// Caption, a numbered line below the court title: parties on the left (ruled at its right and foot), the case
/// number, the nature of the paper and the judge and department on the right (CRC 2.111(4)-(7), (9), (10)).
#let caption(meta) = {
  let cap = need(meta, "caption")
  block(above: pitch, grid(
    columns: (caption-left, 1fr),
    grid.cell(stroke: (right: 0.75pt, bottom: 0.75pt), inset: (top: single-drop, right: caption-inset, bottom: caption-foot),
      line-stack(need(cap, "left"))),
    grid.cell(inset: (top: single-drop, left: caption-right), {
      let above = 0pt
      if "case_number" in cap { line-stack((cap.case_number,)); above = gap }
      // Limited civil cases carry the words "Limited Civil Case" in the caption (CRC 2.111(10)).
      if "limited_civil" in cap and cap.limited_civil { line-stack(("LIMITED CIVIL CASE",), above: above); above = gap }
      line-stack(need(cap, "title"), above: above, weight: "bold")
      if "details" in cap { line-stack(cap.details, above: gap) }
      // CRC 2.111(7): judge and department below the nature of the paper, when assigned.
      let jd = ()
      if "dept" in cap { jd.push("Dept.: " + cap.dept) }
      if "judge" in cap { jd.push("Judge: " + cap.judge) }
      if jd.len() > 0 { line-stack(jd, above: gap) }
      // CRC 2.111(9): on a limited civil complaint, the amount-demanded statement (wording from the frontmatter).
      if "amount_demanded" in cap { line-stack((cap.amount_demanded,), above: gap) }
    }),
  ))
}

// ---------------------------------------------------------------------------
// Signature block (CRC 2.111(1); the signature under CCP 128.7 is the signer's own)
// ---------------------------------------------------------------------------

/// A numbered line below the text: the date at the left, the signature lines in the signature column, a numbered
/// line, "By:" and the signature line, the signer's name and role; never split across pages.
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: pitch, inset: (top: single-drop), {
    if "dated" in sig { line-stack(("Dated: " + sig.dated,)) }
    pad(left: signature-left, {
      line-stack(sig.at("lines", default: ()))
      block(above: pitch, below: 0pt, {
        set text(..edges(pitch-single))
        [By: #box(width: signature-rule, line(length: 100%, stroke: 0.5pt))]
      })
      pad(left: signer-indent, {
        line-stack((upper(sig.signer),), weight: "bold")
        if "role" in sig { block(above: 0pt, below: 0pt, { set text(..edges(pitch-single)); inl(sig.role) }) }
      })
    })
  })
}

// ---------------------------------------------------------------------------
// The body: markdown chunks (the text between blank lines). A heading is one numbered line, kept with the chunk
// after it; every other chunk is a paragraph, its first line indented half an inch.
// ---------------------------------------------------------------------------

#let body-pieces(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  chunks.map(t => {
    if t.starts-with("#") {
      block(sticky: true, md(t))
    } else {
      block(par(first-line-indent: (amount: para-indent, all: true), inl(t)))
    }
  })
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let calsuperct-sandiego-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    foreground: footer-block(need(meta, "footer_title")),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(first-line-indent: 0pt)
  show: xengine.with(pitch: pitch, list-indent: none)
  // A doubled sign stays with its number ("§§ 17200"): xengine binds one sign, so "§" "§ 17200" could part.
  show regex("[§¶]+ \\S+"): it => box(it)
  set block(above: 0pt, below: 0pt, width: 100%)

  // Headings, one numbered line each: levels 1 and 2 centered bold capitals; level 3 bold; level 4 bold italic.
  show heading: it => {
    let b = if it.level <= 2 { upper(it.body) } else { it.body }
    let t = text(size: type-size, weight: "bold", style: if it.level >= 4 { "italic" } else { "normal" }, b)
    block(width: 100%, if it.level <= 2 { align(center, t) } else { t })
  }

  first-page-top(meta)
  court-title(meta)
  caption(meta)

  // The body a numbered line below the caption; the last chunk stays whole with the jury demand and the signature.
  let pieces = body-pieces(body)
  let closing = {
    if "jury_demand" in meta {
      block(above: pitch, sticky: true, align(center, text(weight: "bold", upper(meta.jury_demand))))
    }
    signature-block(meta)
  }
  v(pitch)
  for p in pieces.slice(0, -1) { p }
  block(breakable: false, { pieces.last(); closing })
}
