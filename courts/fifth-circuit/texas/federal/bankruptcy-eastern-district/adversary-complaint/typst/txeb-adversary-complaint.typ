// Adversary complaint for the U.S. Bankruptcy Court, E.D. Texas (txeb). Content-agnostic: every case word comes
// from the sample's frontmatter, never from this file. Rules: Fed. R. Bankr. P. 7010 (Civil Rule 10 applies;
// caption to conform to Official Form 416, the version for a complaint), 9004(b) (caption: court, title, case number, document designation);
// E.D. Tex. LBR 7010-1 (caption: district and division; style of the bankruptcy case with name, address, last
// four digits of the debtor's TIN, case number and chapter; plaintiffs and defendants; adversary number space;
// descriptive title). Fed. R. Civ. P. 10(b) (numbered paragraphs). See ../README.md.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or to a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif") // no font is set by FRBP 7010 or the E.D. Tex. bankruptcy local rules; Times New Roman, the house face (docs/FONTS.md) and the exemplar's (data/exemplar-fonts.json)
#let type-size = 12pt
#let page-w = 8.5in                // paper: letter; the rules set no paper size for this pleading
#let page-h = 11in
#let margin = 1in
#let indent = 0.5in                // first-line indent of the paragraphs; the allegation number stands in a box of this width after it
#let caption-case-col = 3.4in      // party column of the caption
#let caption-sign-col = 0.4in      // the column of section signs
#let caption-cont = 0.5in          // indent of an address line after the first
#let block-indent = 0.75in         // block quotes (both sides) and prayer items
#let sig-col = 3in                 // "Dated" column of the signature block; the signer's lines start after it
#let quote-gap = 12pt              // space above and below a block quotation
#let title-gap = 24pt              // space around the caption and above the signature block
#let footer-size = 10pt

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 27.6pt         // double spacing: Word's double in Times at 12 pt (2 x 1.15 x size), as the exemplar measures
#let pitch-single = 13.8pt         // single spacing (court title, caption, count headings, block quotations, signature)
#let pitch-footer = 11.5pt         // a footer line: 1.15 x the footer size

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("txeb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics for case names, the section sign, and so on).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// A block of lines of one pitch, with explicit space above and below (two adjacent spaces collapse to the larger).
#let lines-block(pitch, above: 0pt, below: 0pt, sticky: false, breakable: true, body) = block(width: 100%,
  above: above, below: below, sticky: sticky, breakable: breakable, { set text(..edges(pitch)); body })

/// Caption rows: (left text, right text, left indent) per line. The § column is drawn on every row.
#let caption-rows(meta) = {
  let rows = ()
  rows.push(("IN RE:", "Chapter " + str(meta.chapter), 0pt))
  rows.push(("", "", 0pt))
  for (i, n) in meta.debtor.names.enumerate() {
    rows.push((n + ",", (if i == 0 { "Case No. " + meta.case_number } else { "" }), 0pt))
  }
  // LBR 7010-1(2): the debtor's address and the last four digits of the TIN are part of the caption.
  // A missing value stays a blank for the filer to complete; the template never guesses one.
  let addr = meta.debtor.at("address", default: "")
  let addr-lines = if type(addr) == array { addr } else { (addr,) }
  let tin = meta.debtor.at("tin_last4", default: "")
  rows.push(("Address: " + (if addr-lines.at(0, default: "") == "" { "________________" } else { addr-lines.at(0) }), "", 0pt))
  for l in addr-lines.slice(1) { rows.push((l, "", caption-cont)) }
  rows.push(("Last four digits of TIN: " + (if tin == "" { "____" } else { tin }), "", 0pt))
  rows.push((meta.debtor.designation, "", 0pt))
  rows.push(("", "", 0pt))
  for (pi, p) in meta.parties.enumerate() {
    if pi > 0 {
      // LBR 7010-1(4): a space for the adversary number, placed beside the "v." line.
      rows.push(("v.", "Adv. Proc. No. " + meta.adversary_number, 0pt))
      rows.push(("", "", 0pt))
    }
    for n in p.names { rows.push((n, "", 0pt)) }
    rows.push((p.designation, "", 0pt))
  }
  rows
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Court title (FRBP 9004(b)(1); LBR 7010-1(1)). One centered bold line per item, no forced breaks.
#let court-title(meta) = for l in (
  "IN THE UNITED STATES BANKRUPTCY COURT",
  "FOR THE EASTERN DISTRICT OF TEXAS",
  upper(meta.division) + " DIVISION",
) { lines-block(pitch-single, align(center, text(weight: "bold", l))) }

/// Single-spaced caption: every row is one line of the single pitch, so the § column aligns on every row.
#let caption(meta) = {
  let rows = caption-rows(meta)
  lines-block(pitch-single, above: title-gap, below: title-gap, breakable: false, grid(
    columns: (caption-case-col, caption-sign-col, 1fr),
    rows: (pitch-single,) * rows.len(),
    ..rows.map(((l, r, i)) => (pad(left: i, l), align(center, [§]), r)).flatten(),
  ))
}

/// The signature block: "Dated" in the left column, the signer's lines (the sample's, in the order given) after it.
#let signature-block(sig) = lines-block(pitch-single, above: title-gap, breakable: false, grid(
  columns: (sig-col, 1fr),
  [Dated: #sig.dated],
  for l in sig.lines { if l == "" { block(height: pitch-single) } else { par(l) } },
))

// ---------------------------------------------------------------------------
// Body: headings, numbered allegations, block quotes, prayer items
// ---------------------------------------------------------------------------

/// Roman-numeral section headings ("# ") are centered bold lines of the body pitch; count headings ("## ") are
/// bold, single spaced, half an inch in, a single line above and below. Both stay with the text after them.
#let section-heading(t) = lines-block(pitch-double, sticky: true, align(center, text(weight: "bold", inl(t))))
#let count-heading(t) = lines-block(pitch-single, above: pitch-single, below: pitch-single, sticky: true,
  pad(left: indent, text(weight: "bold", inl(t))))

/// A double-spaced paragraph whose first line is indented by `indent`. `keep`: not split, and kept on the page of
/// the signature block after it.
#let body-par(keep: false, left: 0pt, first: indent, body) = lines-block(pitch-double, sticky: keep,
  breakable: not keep, pad(left: left, par(first-line-indent: (amount: first, all: true), body)))

#let complaint-body(body, meta) = {
  let num = 0
  let blocks = body.split(regex("\n[ \t]*\n")).map(b => b.trim()).filter(b => b != "")
  for (bi, b) in blocks.enumerate() {
    // the last block before the signature stays with it, so the signature never stands alone
    let keep = blocks.at(bi + 1, default: "") == "<!-- signature -->"
    let lines = b.split("\n").map(l => l.trim())
    let first = lines.at(0)
    if first == "<!-- signature -->" {
      signature-block(meta.signature)
    } else if first.starts-with("## ") {
      count-heading(first.slice(3))
    } else if first.starts-with("# ") {
      section-heading(first.slice(2))
    } else if first.starts-with("> ") {
      // Block quotation: single spaced, indented both sides, unnumbered.
      lines-block(pitch-single, above: quote-gap, below: quote-gap,
        pad(left: block-indent, right: block-indent,
          inl(lines.map(l => if l.starts-with("> ") { l.slice(2) } else { l }).join(" "))))
    } else if first.starts-with("- ") {
      // Prayer items: double spaced, indented.
      for (li, l) in lines.enumerate() {
        body-par(keep: keep and li == lines.len() - 1, left: block-indent, first: 0pt, inl(l.slice(2)))
      }
    } else if first.starts-with("<!-- unnumbered -->") {
      body-par(keep: keep, inl(lines.join(" ").slice("<!-- unnumbered -->".len()).trim()))
    } else {
      num += 1
      body-par(keep: keep, box(width: indent, [#num.]) + inl(lines.join(" ")))
    }
  }
}

// ---------------------------------------------------------------------------
// Document
// ---------------------------------------------------------------------------

#let txeb-adversary-complaint(meta, body) = {
  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    // The footer: the title in capitals at the left, "PAGE n OF N" at the right, in one line of the footer pitch.
    footer: context {
      set text(size: footer-size, ..edges(pitch-footer))
      grid(
        columns: (1fr, auto),
        upper(meta.footer_title),
        [PAGE #counter(page).display() OF #counter(page).final().first()],
      )
    },
    footer-descent: 0.4in,
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (double spaced); the template's own lists are not used.
  show: xengine.with(pitch: pitch-double, list-indent: none)

  court-title(meta)
  caption(meta)
  lines-block(pitch-single, below: quote-gap, sticky: true, align(center, text(weight: "bold", upper(meta.title))))
  complaint-body(body, meta)
}
