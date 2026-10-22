// Adversary complaint for the United States Bankruptcy Court for the Northern District of Mississippi (msnb).
// Governing rules: Fed. R. Bankr. P. 7010 (Fed. R. Civ. P. 10 applies; caption substantially conforms to
// Official Form 416A), 9004(a) (legible papers), 9004(b) (caption contents), Fed. R. Civ. P. 10(b)
// (numbered paragraphs, one set of circumstances each). The local rules of msnb were not reachable when this
// template was written, so the format choices below are standard-letter defaults flagged in ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------
#let font-family = "TeX Gyre Termes"   // Termes matches the audited exemplar (Type 1 Times; data/exemplar-fonts.json)
#let type-size = 12pt
#let page-w = 8.5in
#let page-h = 11in
#let margin = 1in
#let para-indent = 0.5in                // first-line indent of every body paragraph
#let label-box = 0.5in                  // a paragraph number or sub-item letter stands in a box of this width
#let item-indent = 1in                  // a lettered sub-item's letter stands here, as in the filed exemplar
#let caption-left = 3.25in              // the party column of the caption; the designations flush right after it
#let signature-indent = 3.25in          // the firm, the signature line and the title sit in the right half

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // single spacing: 1.15 x the type size (Word's single line)
#let pitch-double = 2 * pitch-single    // double-spaced body (Word's double, as the exemplar is spaced)
#let gap = pitch-single                 // one blank single line

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("msnb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, emphasis).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Blank-line-separated chunks of the body, trimmed, with empty chunks dropped.
#let chunks(body) = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(s => s.trim()).filter(s => s != "")

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt, hanging-indent: 0pt)
  body
})

/// A body block at the double pitch. `keep`: not split, and on the page of the block after it (the last paragraph
/// before the signature: a signature never starts a page alone).
#let body-block(keep: false, body) = block(width: 100%, above: 0pt, below: 0pt, sticky: keep, breakable: not keep,
  body)

/// A labeled paragraph: the label at `at` in a box of label-box, the text after it, the lines after the first at
/// the margin (an allegation "1.", a lettered sub-item "(a)", a prayer item).
#let labeled(keep: false, at: para-indent, label, body) = body-block(keep: keep,
  par(first-line-indent: 0pt, { h(at); box(width: label-box, label); body }))

/// An unnumbered paragraph (a markdown blockquote in the sample): e.g. the WHEREFORE lead-in.
#let unnumbered(keep: false, body) = body-block(keep: keep,
  par(first-line-indent: (amount: para-indent, all: true), body))

/// A heading, one line at the double pitch, kept with the block after it: centered bold capitals (level 1) or
/// centered bold (level 2 and below).
#let heading-block(t) = {
  let lvl = t.match(regex("^#+")).text.len()
  let s = t.replace(regex("^#+[ \\t]*"), "")
  block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
    set par(first-line-indent: 0pt)
    align(center, text(weight: "bold", if lvl == 1 { upper(inl(s)) } else { inl(s) }))
  })
}

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let counsel-block(meta) = {
  for l in meta.counsel { line-block(inl(l)) }
}

#let court-title() = {
  for l in ("IN THE UNITED STATES BANKRUPTCY COURT", "FOR THE NORTHERN DISTRICT OF MISSISSIPPI") {
    line-block(align(center, text(weight: "bold", l)))
  }
}

/// The caption, as the filed exemplar sets it: party names left, the designations and numbers flush right, one rule
/// under the debtor row, a blank single line between the rows. One grid, every line a single-pitch line, bold.
#let caption(meta) = {
  let stack(items, flush: false) = for i in items { line-block(if flush { align(right, inl(i)) } else { inl(i) }) }
  let row(left, right) = (stack(left), stack(right, flush: true))
  let spacer(rule: false) = (grid.cell(colspan: 2, stroke: if rule { (top: 0.5pt) } else { none },
    block(height: gap)),)
  let pl = meta.plaintiffs
  let cells = ()
  cells += row(meta.debtor.names.enumerate().map(((i, n)) => if i == 0 { "IN RE: " + n } else { n }),
    ("NO. " + meta.case_number,))
  cells += spacer(rule: true)
  cells += row(pl, (if pl.len() > 1 { "PLAINTIFFS" } else { "PLAINTIFF" },))
  cells += spacer()
  cells += spacer()
  cells += row(("VS.",), ("ADVERSARY NO. " + meta.adv_number,))
  cells += spacer()
  cells += spacer()
  cells += row(meta.defendants, (meta.at("defendants_label", default: "DEFENDANT"),))
  block(width: 100%, above: 2 * gap, below: 0pt, {
    set text(weight: "bold")
    grid(columns: (caption-left, 1fr), inset: 0pt, ..cells)
  })
}

// ---------------------------------------------------------------------------
// Signature block
// ---------------------------------------------------------------------------

/// The date line at the paragraph indent; the firm (bold), the signature line and the title in the right half; the
/// signer's counsel block flush left. One unbreakable block.
#let signature(meta) = block(width: 100%, breakable: false, above: gap, below: 0pt, {
  let s = meta.signature
  if "dated" in meta { line-block(pad(left: para-indent, [DATED: #inl(meta.dated)])) }
  block(width: 100%, above: gap, below: 0pt, pad(left: signature-indent, {
    line-block(text(weight: "bold", inl(s.firm)))
    line-block(above: 2 * gap, [By: #underline[/s/ #inl(s.signer)]])
    line-block(pad(left: para-indent, inl(s.title)))
  }))
  block(width: 100%, above: 2 * gap, below: 0pt, for l in s.lines { line-block(inl(l)) })
})

// ---------------------------------------------------------------------------
// Entry: the full complaint
// ---------------------------------------------------------------------------

#let msnb-adversary-complaint(meta, body) = {
  // The page number: centered in a single-spaced line box, at the same place on every page (Word's footer).
  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(size: type-size, ..edges(pitch-single), counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (double-spaced).
  show: xengine.with(pitch: pitch-double, list-indent: none)

  if meta.counsel.len() > 0 {
    counsel-block(meta)
    block(height: gap, above: 0pt, below: 0pt)
  }
  court-title()
  caption(meta)
  line-block(above: 2 * gap, below: gap, align(center, text(weight: "bold", upper(meta.title))))

  // Body chunks (blank-line separated markdown):
  //  - `#`: headings, kept with the next chunk;
  //  - `>`: an unnumbered paragraph (the WHEREFORE lead-in);
  //  - `- item` lines: lettered sub-items (a), (b), ...;
  //  - `1. item` lines: after an unnumbered paragraph, the prayer with the markdown's own numbers; anywhere else,
  //    allegations numbered on (Fed. R. Civ. P. 10(b));
  //  - a `[^n]:` line is text (the template sets no footnotes), numbered like any other paragraph;
  //  - anything else: a numbered allegation.
  // The last block stays with the signature.
  let cs = chunks(body)
  let n = 0
  let prev = none
  for (ci, c) in cs.enumerate() {
    let last = ci == cs.len() - 1
    let lines = c.split(regex("\\r?\\n")).map(l => l.trim()).filter(l => l != "")
    if c.starts-with("#") {
      heading-block(c)
    } else if c.starts-with(">") {
      unnumbered(keep: last, inl(lines.map(l => l.replace(regex("^>\\s?"), "")).join("\n")))
    } else if c.starts-with("- ") {
      for (i, l) in lines.enumerate() {
        labeled(keep: last and i == lines.len() - 1, at: item-indent, numbering("(a)", i + 1),
          inl(l.replace(regex("^-\\s*"), "")))
      }
    } else if c.match(regex("^\\d+\\.\\s")) != none {
      for (i, l) in lines.enumerate() {
        let m = l.match(regex("^(\\d+)\\.\\s*"))
        let k = last and i == lines.len() - 1
        if prev == ">" {
          labeled(keep: k, m.captures.at(0) + ".", inl(l.slice(m.end)))
        } else {
          n += 1
          labeled(keep: k, [#n.], inl(l.slice(m.end)))
        }
      }
    } else if c.match(regex("^\\[\\^\\w+\\]:")) != none {
      n += 1
      labeled(keep: last, [#n.], inl("\\" + c))
    } else {
      n += 1
      labeled(keep: last, [#n.], inl(c))
    }
    prev = if c.starts-with(">") { ">" } else { c.slice(0, 1) }
  }

  signature(meta)
}
