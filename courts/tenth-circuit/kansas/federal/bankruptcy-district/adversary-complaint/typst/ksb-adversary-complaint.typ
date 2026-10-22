// U.S. Bankruptcy Court, District of Kansas: adversary complaint (FRBP 7001 et seq.).
//
// Rule-driven and content-agnostic. Requirement IDs (KSB-...) refer to ../README.md, which quotes
// the rule text (Fed. R. Bankr. P. 7001, 7003, 7008, 7010, 9004, 9011; Fed. R. Civ. P. 8, 10;
// D. Kan. LBR 7003.1, 9004.1). No case-specific text, no coordinates measured off the exemplar,
// no forced line breaks. The metadata comes from the YAML frontmatter of the sample; the body is its
// markdown, read block by block here (inline markdown by cmarker), as docx/ksb-adversary-complaint.lua
// reads it (schema: ../README.md).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")    // no D. Kan. rule names a face; Times New Roman, the house standard and the exemplar's face (vendored metric twin)
#let type-size = 16pt                    // KSB-FORM-002: 12 pt or larger, and an average of no more than 12 characters per inch (LBR 9004.1(a)(1)). Measured in Liberation Serif on the sample text (typst 0.15.0, 2026-10-17): 12.8 cpi at 14 pt, 11.9 at 15 pt, 11.2 at 16 pt; 16 pt keeps a margin under 12.
#let page-margin = 1in                   // style choice: 1 inch on all sides (no margin figure in the rules).
#let para-indent = 0.5in                 // first-line indent of paragraphs; numbered paragraphs: the number sits here.
#let number-box = 0.5in                  // numbered paragraphs: the number in a box this wide, the text after it.
#let designation-indent = 2in            // caption: "Debtor.", "Plaintiff,", "Defendant." under the names.
#let caption-left = 3.6in                // caption: width of the party column.
#let caption-pad = 0.2in                 // caption: the party column's text this far off its right rule,
#let caption-gap = 0.2in                 // and the case column's this far off it.
#let sig-left = 3.3in                    // signature block: its column this far from the left margin (the right half).
#let cell-inset = (x: 6pt, y: 3pt)       // exhibit tables: cell padding.
#let rule = 0.75pt

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 32pt                 // KSB-FORM-003: double-spaced where practicable (LBR 9004.1(a)(1)): two type sizes per line.
#let pitch-single = 18.4pt               // single spacing (1.15 x the size): court, caption, title, signature, tables.

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("ksb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ksb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it. An empty line keeps
/// its height.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below,
  height: if body == "" or body == [] { pitch-single } else { auto }, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if type(body) == str { inl(body) } else { body }
})

// ---------------------------------------------------------------------------
// Caption (Form 416D, adversary caption; FRBP 7010, 9004(b))
// ---------------------------------------------------------------------------

/// The caption: a table of one row per single line, the party column ruled at its right, the case column beside it.
/// The party column: "In re:", a blank line, the debtor's names and designation, then each side's names and
/// designation, a blank line, "v." and a blank line between the sides. The case column: the case number and the
/// chapter beside the debtor's names, the adversary number beside "v.". Never split.
#let caption-block(meta) = {
  let debtor = need(meta, "debtor")
  let sides = need(meta, "caption")
  let adv = meta.at("adversary_number", default: "Adv. Proc. No. " + "_" * 10)  // a blank that fits beside "v." in the case column
  let left = (line-block("In re:"), line-block(""))
  let at-debtor = left.len()
  for n in debtor.names { left.push(line-block(n)) }
  left.push(line-block(pad(left: designation-indent, inl(debtor.designation))))
  let at-v = none
  for (i, side) in sides.enumerate() {
    left.push(line-block(""))
    if i > 0 {
      if at-v == none { at-v = left.len() }
      left.push(line-block(align(center)[v.]))
      left.push(line-block(""))
    }
    for n in side.names { left.push(line-block(n)) }
    left.push(line-block(pad(left: designation-indent, inl(side.designation))))
  }
  if at-v == none { at-v = left.len() - 1 }
  let right = range(left.len()).map(_ => line-block(""))
  right.at(at-debtor) = line-block(need(meta, "bankruptcy_case"))
  right.at(at-debtor + 1) = line-block(need(meta, "chapter"))
  right.at(at-v) = line-block(adv)
  let cells = ()
  for i in range(left.len()) {
    cells.push(table.cell(stroke: (right: rule), inset: (right: caption-pad), left.at(i)))
    cells.push(table.cell(inset: (left: caption-gap), right.at(i)))
  }
  block(width: 100%, breakable: false, above: 0pt, below: 0pt,
    table(columns: (caption-left, 1fr), stroke: none, inset: 0pt, ..cells))
}

// ---------------------------------------------------------------------------
// Body: blank-line-separated blocks. "# " and "## " headings, "N. " numbered allegations (numbered here, one count
// through the complaint: FRCP 10(b)), "| " tables (exhibits), "> " quotations; any other block an unnumbered
// paragraph (the introduction, the prayers).
// ---------------------------------------------------------------------------

#let body-blocks(body) = body.replace("\r\n", "\n").split(regex("\n[ \t]*\n")).map(s => s.trim()).filter(s => s != "")

/// Headings at the body pitch, sticky: level 1 centered bold capitals, level 2 centered bold.
#let heading-block(level, t, above: 0pt) = block(width: 100%, sticky: true, breakable: false, above: above,
  below: 0pt, {
  set par(first-line-indent: 0pt)
  align(center, if level == 1 { strong(upper(inl(t))) } else { strong(inl(t)) })
})

/// A body block at the double pitch; `keep`: kept whole on the page of the block after it (the last block stays with
/// the signature).
#let body-par(content, keep: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: keep, breakable: not keep,
  par(first-line-indent: (amount: para-indent, all: true), content))

/// A pipe table (an exhibit): single-spaced cells, the header row bold, the first column twice as wide as each other
/// one; rows never split.
#let pipe-table(src) = {
  let rows = src.split("\n").map(l => l.trim()).filter(l => l.starts-with("|"))
    .map(l => l.trim("|").split("|").map(c => c.trim()))
  let head = rows.first()
  let body = rows.slice(2)
  let n = head.len()
  let cell(t, bold: false) = table.cell(breakable: false, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    if bold { strong(inl(t)) } else { inl(t) }
  })
  block(width: 100%, above: pitch-single, below: 0pt, table(
    columns: (2fr,) + (1fr,) * (n - 1), stroke: none, inset: cell-inset,
    ..head.map(t => cell(t, bold: true)),
    ..body.map(r => r.map(t => cell(t))).flatten(),
  ))
}

#let render-blocks(blocks, number: 0) = {
  let n = number
  for (k, b) in blocks.enumerate() {
    let last = k == blocks.len() - 1
    if b.starts-with("## ") {
      heading-block(2, b.slice(3))
    } else if b.starts-with("# ") {
      heading-block(1, b.slice(2))
    } else if b.starts-with("|") {
      pipe-table(b)
    } else if b.starts-with("> ") {
      block(width: 100%, above: pitch-single, below: pitch-single, sticky: last, breakable: not last,
        pad(left: para-indent, right: para-indent, {
          set text(..edges(pitch-single))
          par(first-line-indent: 0pt, inl(b.split("\n").map(l => l.trim(">", at: start).trim()).join(" ")))
        }))
    } else if b.match(regex("^\\d+\\.\\s")) != none {
      n += 1
      body-par(keep: last, [#box(width: number-box, [#n.])#inl(b.replace(regex("^\\d+\\.\\s+"), "").replace("\n", " "))])
    } else {
      body-par(keep: last, inl(b.replace("\n", " ")))
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (FRBP 9011(a): signed in the attorney's name, with address and telephone)
// ---------------------------------------------------------------------------

/// A double line below the body: the date at the left margin; "Respectfully submitted,", a single line below it the
/// firm, a single line below that "By: /s/" and the signer, the signer's name and bar number and lines, and a single
/// line below them the role, in bold, all in a column at sig-left. Single-spaced, never split.
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  let col(above: 0pt, body) = line-block(above: above, pad(left: sig-left, body))
  block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
    place(top + left, line-block(meta.at("date", default: "")))
    col[Respectfully submitted,]
    for (i, l) in sig.at("preamble", default: ()).enumerate() {
      col(above: if i == 0 { pitch-single } else { 0pt }, inl(l))
    }
    col(above: pitch-single)[By: /s/ #inl(sig.signer)]
    col[#inl(sig.signer)#if "bar" in sig [, #inl(sig.bar)]]
    for l in sig.at("lines", default: ()) { col(inl(l)) }
    if "role" in sig { col(above: pitch-single, strong(inl(sig.role))) }
  })
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let ksb-adversary-complaint(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "debtor", "bankruptcy_case", "chapter", "caption", "title", "signature") {
    let _ = need(meta, k)
  }

  // ---- document-wide settings ----
  // LBR 9004.1(a)(1): 8-1/2 x 11 inch paper; (a)(2): numbered from the first page. The number centered at the foot in
  // a single line box, where Word's footer sets it.
  set page(paper: "us-letter", margin: page-margin, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("1"))))
  set document(title: need(meta, "title"), author: need(meta, "signature").signer)
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (double spacing).
  show: xengine.with(pitch: pitch-double, list-indent: none)
  // A doubled section sign stays with its number (xengine binds a single sign), as the docx filter binds it.
  show regex("[§¶]{2,} \\S+"): it => box(it)

  // ---- the first page: court title, a double line below it the caption, a double line below that the title ----
  for l in need(meta, "court") { line-block(align(center, strong(upper(inl(l))))) }
  block(width: 100%, above: pitch-double, below: 0pt, caption-block(meta))
  line-block(above: pitch-double, below: pitch-single, align(center, strong(upper(inl(need(meta, "title"))))))

  // ---- the body, with the signature block where the author puts <!--signature--> ----
  let parts = md.split("<!--signature-->")
  if parts.len() != 2 { panic("ksb-adversary-complaint: the body must contain exactly one <!--signature--> marker") }
  let blocks = body-blocks(parts.at(0))
  render-blocks(blocks)
  let n = blocks.filter(b => b.match(regex("^\\d+\\.\\s")) != none).len()
  signature-block(meta)
  // Anything after the signature (exhibits) starts on its own page.
  let rest = body-blocks(parts.at(1))
  if rest.len() > 0 {
    pagebreak()
    render-blocks(rest, number: n)
  }
}
