// Adversary complaint for the U.S. Bankruptcy Court, E.D. Texas (txeb). Content-agnostic: every case word comes
// from the sample's frontmatter, never from this file. Rules: Fed. R. Bankr. P. 7010 (Civil Rule 10 applies;
// caption to conform to Official Form 416, the version for a complaint), 9004(b) (caption: court, title, case number, document designation);
// E.D. Tex. LBR 7010-1 (caption: district and division; style of the bankruptcy case with name, address, last
// four digits of the debtor's TIN, case number and chapter; plaintiffs and defendants; adversary number space;
// descriptive title). Fed. R. Civ. P. 10(b) (numbered paragraphs). See ../README.md.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or to a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif") // no font is set by FRBP 7010 or the E.D. Tex. bankruptcy local rules; Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt
#let page-w = 8.5in                // paper: letter; the rules set no paper size for this pleading
#let page-h = 11in
#let margin = 1in
#let text-width = page-w - 2 * margin
#let double = 1.345em              // double spacing: 0.655em natural line box + 1.345em leading = 24 pt pitch at 12 pt
#let single = 0.65em               // single spacing (caption, block quotations, signature)
#let indent = 0.5in                // first-line indent of numbered paragraphs
#let caption-case-col = 3.4in      // party column of the caption
#let caption-line = 14.5pt         // one single-spaced caption line (about 1.2 em at 12 pt)
#let block-indent = 0.75in         // block quotes and prayer items

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

/// Caption rows: (left text, right text) per line. The § column is drawn on every row.
#let caption-rows(meta) = {
  let rows = ()
  rows.push(("IN RE:", "Chapter " + str(meta.chapter)))
  rows.push(("", ""))
  for (i, n) in meta.debtor.names.enumerate() {
    rows.push((n + ",", (if i == 0 { "Case No. " + meta.case_number } else { "" })))
  }
  // LBR 7010-1(2): the debtor's address and the last four digits of the TIN are part of the caption.
  // A missing value stays a blank for the filer to complete; the template never guesses one.
  let addr = meta.debtor.at("address", default: "")
  let addr-lines = if type(addr) == array { addr } else { (addr,) }
  let tin = meta.debtor.at("tin_last4", default: "")
  rows.push(("Address: " + (if addr-lines.at(0, default: "") == "" { "________________" } else { addr-lines.at(0) }), ""))
  for l in addr-lines.slice(1) { rows.push(("     " + l, "")) }
  rows.push(("Last four digits of TIN: " + (if tin == "" { "____" } else { tin }), ""))
  rows.push((meta.debtor.designation, ""))
  rows.push(("", ""))
  for (pi, p) in meta.parties.enumerate() {
    if pi > 0 {
      // LBR 7010-1(4): a space for the adversary number, placed beside the "v." line.
      rows.push(("v.", "Adv. Proc. No. " + meta.adversary_number))
      rows.push(("", ""))
    }
    for n in p.names { rows.push((n, "")) }
    rows.push((p.designation, ""))
  }
  rows
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Single-spaced caption: every row is one fixed line, so no two rows can overlap.
#let caption(meta) = {
  let rows = caption-rows(meta)
  grid(
    columns: (caption-case-col, 0.4in, 1fr),
    rows: (caption-line,) * rows.len(),
    ..rows.map(((l, r)) => (l, align(center, [§]), r)).flatten(),
  )
}

/// Court title (FRBP 9004(b)(1); LBR 7010-1(1)). One centered line per item, no forced breaks.
#let court-title(meta) = {
  set par(leading: 0.65em, spacing: 0pt)
  align(center, stack(dir: ttb, spacing: 0.65em,
    text(weight: "bold", "IN THE UNITED STATES BANKRUPTCY COURT"),
    text(weight: "bold", "FOR THE EASTERN DISTRICT OF TEXAS"),
    text(weight: "bold", upper(meta.division) + " DIVISION"),
  ))
}

/// A signature block at the right half of the page; the lines are the sample's, in the order given.
#let signature-block(sig) = block(width: text-width, breakable: false, above: 24pt, {
  set par(leading: 0.65em, spacing: 0pt)
  grid(
    columns: (3in, 1fr),
    [Dated: #sig.dated],
    stack(dir: ttb, spacing: 0.65em, ..sig.lines.map(l => if l == "" { v(0.65em) } else { [#l] })),
  )
})

// ---------------------------------------------------------------------------
// Body: headings, numbered allegations, block quotes, prayer items
// ---------------------------------------------------------------------------

/// Roman-numeral section headings ("# ") are centered bold; count headings ("## ") are bold, under the margin.
/// Body text is double spaced, as the filed exemplar is. In typst the leading sits between the lines of
/// one paragraph only, so each block also gets a gap below it equal to the leading (the block's last line
/// otherwise runs into the next block).
#let section-heading(t) = block(width: text-width, above: 12pt, below: double, sticky: true,
  align(center, text(weight: "bold", inl(t))))
#let count-heading(t) = block(width: text-width, above: 0pt, below: double, sticky: true,
  pad(left: indent, text(weight: "bold", inl(t))))

#let complaint-body(body, meta) = {
  let num = 0
  let blocks = body.split(regex("\n[ \t]*\n"))
  for raw in blocks {
    let b = raw.trim()
    if b == "" { continue }
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
      block(width: text-width, inset: (left: block-indent, right: block-indent), above: 12pt, below: 12pt,
        par(leading: single, spacing: 0pt, inl(lines.map(l => if l.starts-with("> ") { l.slice(2) } else { l }).join(" "))))
    } else if first.starts-with("- ") {
      // Prayer items are sticky: the request for relief stays with the signature block that follows it.
      for l in lines {
        block(width: text-width, inset: (left: block-indent), above: 0pt, below: double, sticky: true,
          par(leading: double, spacing: 0pt, inl(l.slice(2))))
      }
    } else if first.starts-with("<!-- unnumbered -->") {
      block(width: text-width, above: 0pt, below: double, sticky: true,
        par(leading: double, spacing: 0pt, h(indent) + inl(lines.join(" ").slice("<!-- unnumbered -->".len()).trim())))
    } else {
      num += 1
      block(width: text-width, above: 0pt, below: double,
        par(leading: double, spacing: 0pt, h(indent) + [#num.] + h(0.4in) + inl(lines.join(" "))))
    }
  }
}

// ---------------------------------------------------------------------------
// Document
// ---------------------------------------------------------------------------

#let txeb-adversary-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: (top: margin, bottom: 1in, left: margin, right: margin),
    footer: context {
      set text(size: 10pt)
      grid(
        columns: (1fr, auto),
        upper(meta.footer_title),
        [PAGE #counter(page).display() OF #counter(page).final().first()],
      )
    },
    footer-descent: 0.4in,
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(justify: false, leading: 0.65em, spacing: 0pt, first-line-indent: 0pt)

  court-title(meta)
  v(24pt)
  caption(meta)
  v(24pt)
  align(center, text(weight: "bold", upper(meta.title)))
  v(12pt)
  complaint-body(body, meta)
}
