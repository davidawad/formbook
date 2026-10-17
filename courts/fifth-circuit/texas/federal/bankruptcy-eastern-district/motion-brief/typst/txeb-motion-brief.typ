// Motion with argument and authorities in an adversary proceeding, U.S. Bankruptcy Court, E.D. Texas (txeb).
// Content-agnostic: every case word comes from the sample's frontmatter, never from this file. Rules: Fed. R.
// Bankr. P. 9013 (motions by motion), 7010 (Civil Rule 10 form; caption to conform to Official Form 416, the version for other papers),
// 9004(b) (caption); E.D. Tex. LBR 7007-1 (14-day negative notice, in the motion text, preferably on the first
// page), LBR 7010-1 (caption), LBR 9004-1 (caption, title), LBR 9013-1 (certificate of service, proposed order,
// redaction). See ../README.md.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or to a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif") // no font is set by FRBP 9013 or the E.D. Tex. bankruptcy local rules; Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt
#let page-w = 8.5in                // letter; the rules set no paper size for this filing
#let page-h = 11in
#let margin = 1in
#let text-width = page-w - 2 * margin
#let double = 1.345em              // double spacing: 0.655em natural line box + 1.345em leading = 24 pt pitch at 12 pt
#let single = 0.65em               // single spacing (caption, block quotes, signature, notice)
#let indent = 0.5in                // first-line indent of numbered paragraphs
#let block-indent = 0.75in         // block quotations
#let sig-indent = 3.25in           // left edge of the signature block and certificate lines

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
// Cover: court title, caption, title of the motion, negative notice
// ---------------------------------------------------------------------------

/// Single-spaced caption: every row is one fixed line, so no two rows can overlap.
#let caption(meta) = {
  let rows = caption-rows(meta)
  grid(
    columns: (3.4in, 0.4in, 1fr),
    rows: (14.5pt,) * rows.len(),
    ..rows.map(((l, r)) => (l, align(center, [§]), r)).flatten(),
  )
}

/// Court title (FRBP 9004(b)(1); LBR 7010-1(1)). One centered line per item, no forced breaks.
#let court-title(meta) = align(center, stack(dir: ttb, spacing: single,
  text(weight: "bold", "IN THE UNITED STATES BANKRUPTCY COURT"),
  text(weight: "bold", "FOR THE EASTERN DISTRICT OF TEXAS"),
  text(weight: "bold", upper(meta.division) + " DIVISION"),
))

/// The 14-day negative notice (LBR 7007-1), in the motion text, set as the rule presents it.
#let negative-notice() = block(width: text-width, above: 12pt, below: 12pt, breakable: false,
  stack(dir: ttb, spacing: single,
    text(weight: "bold", "14-DAY NEGATIVE NOTICE – LBR 7007:"),
    negative-notice-text,
  ))

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// Signature block at the right half of the page; the lines are the sample's, in the order given.
#let signature-block(sig) = block(width: text-width, breakable: false, above: 24pt, below: double, {
  set par(leading: single, spacing: 0pt)
  grid(
    columns: (sig-indent, 1fr),
    [Dated: #sig.dated],
    stack(dir: ttb, spacing: single, ..sig.lines.map(l => if l == "" { v(single) } else { [#l] })),
  )
})

/// Roman/section headings ("# "): centered bold. Sub-headings ("## "): bold, flush left.
#let section-heading(t) = block(width: text-width, above: 0pt, below: double, sticky: true,
  align(center, text(weight: "bold", inl(t))))
#let sub-heading(t) = block(width: text-width, above: 0pt, below: double, sticky: true,
  text(weight: "bold", inl(t)))

#let motion-body(body, meta) = {
  let num = 0
  let blocks = body.split(regex("\n[ \t]*\n"))
  for raw in blocks {
    let b = raw.trim()
    if b == "" { continue }
    let lines = b.split("\n").map(l => l.trim())
    let first = lines.at(0)
    if first == "<<signature>>" {
      signature-block(meta.signature)
    } else if first.starts-with("## ") {
      sub-heading(first.slice(3))
    } else if first.starts-with("# ") {
      section-heading(first.slice(2))
    } else if first.starts-with("> ") {
      // Block quotation: single spaced, indented both sides, unnumbered.
      block(width: text-width, inset: (left: block-indent, right: block-indent), above: 12pt, below: 12pt,
        par(leading: single, spacing: 0pt, inl(lines.map(l => if l.starts-with("> ") { l.slice(2) } else { l }).join(" "))))
    } else if first.starts-with("- ") {
      // List items (the relief sought in a quotation): single spaced, indented, unnumbered.
      for l in lines {
        block(width: text-width, inset: (left: block-indent), above: 0pt, below: 12pt,
          par(leading: single, spacing: 0pt, inl(l.slice(2))))
      }
    } else if first.starts-with("~> ") {
      // Right half of the page, single spaced, unnumbered (certificate of service signature).
      block(width: text-width, inset: (left: sig-indent), above: 0pt, below: 0pt, breakable: false,
        stack(dir: ttb, spacing: single, ..lines.map(l => inl(if l.starts-with("~> ") { l.slice(3) } else { l }))))
    } else if first.starts-with("~| ") {
      // Flush left, single spaced, unnumbered (addresses in a certificate).
      block(width: text-width, above: 0pt, below: 0pt, breakable: false,
        stack(dir: ttb, spacing: single, ..lines.map(l => inl(if l.starts-with("~| ") { l.slice(3) } else { l }))))
    } else if first.starts-with("~ ") {
      // Unnumbered, indented first line, double spaced (the lead-in and the closing request).
      block(width: text-width, above: 0pt, below: double, sticky: true,
        par(leading: double, spacing: 0pt, h(indent) + inl(lines.join(" ").slice(2))))
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

#let txeb-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: (top: margin, bottom: margin, left: margin, right: margin),
    footer: context align(center, text(size: 11pt, counter(page).display())),
    footer-descent: 0.4in,
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(justify: false, leading: single, spacing: 0pt, first-line-indent: 0pt)

  court-title(meta)
  v(24pt)
  caption(meta)
  v(18pt)
  align(center, text(weight: "bold", upper(meta.title)))
  if meta.at("negative_notice", default: true) { negative-notice() }
  motion-body(body, meta)
}
