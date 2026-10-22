// Motion with argument and authorities in an adversary proceeding, U.S. Bankruptcy Court, E.D. Texas (txeb).
// Content-agnostic: every case word comes from the sample's frontmatter, never from this file. Rules: Fed. R.
// Bankr. P. 9013 (motions by motion), 7010 (Civil Rule 10 form; caption to conform to Official Form 416, the version for other papers),
// 9004(b) (caption); E.D. Tex. LBR 7007-1 (14-day negative notice, in the motion text, preferably on the first
// page), LBR 7010-1 (caption), LBR 9004-1 (caption, title), LBR 9013-1 (certificate of service, proposed order,
// redaction). See ../README.md.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or to a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif") // no font is set by FRBP 9013 or the E.D. Tex. bankruptcy local rules; Times New Roman, the house face (docs/FONTS.md) and the exemplar's (data/exemplar-fonts.json)
#let type-size = 12pt
#let page-w = 8.5in                // letter; the rules set no paper size for this filing
#let page-h = 11in
#let margin = 1in
#let indent = 0.5in                // first-line indent of the paragraphs; the paragraph number stands in a box of this width after it
#let caption-case-col = 3.4in      // party column of the caption
#let caption-sign-col = 0.4in      // the column of section signs
#let caption-cont = 0.5in          // indent of an address line after the first
#let block-indent = 0.75in         // block quotations (both sides) and list items
#let sig-indent = 3.25in           // left edge of the signature block and certificate lines
#let block-gap = 12pt              // space around the negative notice, a block quotation and a list item, above a line group
#let title-gap = 24pt              // space above the caption, above and below the signature block
#let caption-gap = 18pt            // space between the caption and the title
#let footer-size = 11pt

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 27.6pt         // double spacing: Word's double in Times at 12 pt (2 x 1.15 x size), as the exemplar measures
#let pitch-single = 13.8pt         // single spacing (court title, caption, title, notice, block quotations, signature)
#let pitch-footer = 12.65pt        // the page number's line: 1.15 x the footer size

// ---------------------------------------------------------------------------
// Rule text (LBR 7007-1: the 14-day negative notice "must appear as presented"). Not case-specific.
// ---------------------------------------------------------------------------
#let negative-notice-text = "No hearing will be conducted on this Motion unless a written objection is filed with the Clerk of the United States Bankruptcy Court and served upon the party filing this pleading WITHIN FOURTEEN (14) DAYS FROM THE DATE OF SERVICE shown in the certificate of service unless the Court shortens or extends the time for filing such objection. If no objection is timely served and filed, this pleading shall be deemed to be unopposed, and the Court may enter an order granting the relief sought. If an objection is filed and served in a timely manner, the Court will thereafter set a hearing with appropriate notice. If you fail to appear at the hearing, your objection may be stricken. The Court reserves the right to set a hearing on any matter."

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("txeb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics for case names, and so on).
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
// Cover: court title, caption, title of the motion, negative notice
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
  lines-block(pitch-single, above: title-gap, below: caption-gap, breakable: false, grid(
    columns: (caption-case-col, caption-sign-col, 1fr),
    rows: (pitch-single,) * rows.len(),
    ..rows.map(((l, r, i)) => (pad(left: i, l), align(center, [§]), r)).flatten(),
  ))
}

/// The 14-day negative notice (LBR 7007-1), in the motion text, set as the rule presents it.
#let negative-notice() = lines-block(pitch-single, above: block-gap, below: block-gap, breakable: false, {
  par(text(weight: "bold", "14-DAY NEGATIVE NOTICE – LBR 7007:"))
  par(negative-notice-text)
})

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// The signature block: "Dated" in the left column, the signer's lines (the sample's, in the order given) after it.
#let signature-block(sig) = lines-block(pitch-single, above: title-gap, below: title-gap, breakable: false, grid(
  columns: (sig-indent, 1fr),
  [Dated: #sig.dated],
  for l in sig.lines { if l == "" { block(height: pitch-single) } else { par(l) } },
))

/// Section headings ("# "): centered bold lines of the body pitch. Sub-headings ("## "): bold, flush left. Both stay
/// with the text after them.
#let section-heading(t) = lines-block(pitch-double, sticky: true, align(center, text(weight: "bold", inl(t))))
#let sub-heading(t) = lines-block(pitch-double, sticky: true, text(weight: "bold", inl(t)))

/// A double-spaced paragraph whose first line is indented by `indent`. `keep`: not split, and kept on the page of
/// the signature block after it.
#let body-par(keep: false, body) = lines-block(pitch-double, sticky: keep, breakable: not keep,
  par(first-line-indent: (amount: indent, all: true), body))

/// Single-spaced lines at `left`, one paragraph per source line, kept together (addresses, the certificate's
/// signature). `keep`: kept on the page of the line group after it.
#let line-group(left, lines, marker, keep: false) = lines-block(pitch-single, above: block-gap, sticky: keep, breakable: false, pad(left: left,
  for l in lines { par(inl(if l.starts-with(marker) { l.slice(marker.len()).trim() } else { l })) }))

#let motion-body(body, meta) = {
  let num = 0
  let blocks = body.split(regex("\n[ \t]*\n")).map(b => b.trim()).filter(b => b != "")
  for (bi, b) in blocks.enumerate() {
    // the last block before the signature stays with it, and a block before a line group (a certificate's address
    // and signature) stays with that, so neither stands alone
    let next = blocks.at(bi + 1, default: "")
    let grouped = next.starts-with("<!-- flush -->") or next.starts-with("<!-- right -->")
    let keep = next == "<!-- signature -->" or grouped
    let lines = b.split("\n").map(l => l.trim())
    let first = lines.at(0)
    if first == "<!-- signature -->" {
      signature-block(meta.signature)
    } else if first.starts-with("## ") {
      sub-heading(first.slice(3))
    } else if first.starts-with("# ") {
      section-heading(first.slice(2))
    } else if first.starts-with("> ") {
      // Block quotation: single spaced, indented both sides, unnumbered.
      lines-block(pitch-single, above: block-gap, below: block-gap,
        pad(left: block-indent, right: block-indent,
          inl(lines.map(l => if l.starts-with("> ") { l.slice(2) } else { l }).join(" "))))
    } else if first.starts-with("- ") {
      // List items (the relief sought in a quotation): single spaced, indented, unnumbered.
      for l in lines {
        lines-block(pitch-single, above: block-gap, below: block-gap, pad(left: block-indent, inl(l.slice(2))))
      }
    } else if first.starts-with("<!-- right -->") {
      // Right half of the page, single spaced, unnumbered (certificate of service signature).
      line-group(sig-indent, lines, "<!-- right -->", keep: grouped)
    } else if first.starts-with("<!-- flush -->") {
      // Flush left, single spaced, unnumbered (addresses in a certificate).
      line-group(0pt, lines, "<!-- flush -->", keep: grouped)
    } else if first.starts-with("<!-- unnumbered -->") {
      // Unnumbered, indented first line, double spaced (the lead-in and the closing request).
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

#let txeb-motion-brief(meta, body) = {
  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    // The page number, centered in one line of the footer pitch.
    footer: context align(center, text(size: footer-size, ..edges(pitch-footer), counter(page).display())),
    footer-descent: 0.4in,
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (double spaced); the template's own lists are not used.
  show: xengine.with(pitch: pitch-double, list-indent: none)

  court-title(meta)
  caption(meta)
  lines-block(pitch-single, sticky: true, align(center, text(weight: "bold", upper(meta.title))))
  if meta.at("negative_notice", default: true) { negative-notice() }
  motion-body(body, meta)
}
