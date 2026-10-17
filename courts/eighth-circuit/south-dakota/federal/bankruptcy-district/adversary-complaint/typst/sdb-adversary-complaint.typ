// Adversary complaint for the United States Bankruptcy Court, District of South Dakota (sdb).
// Rules (see ../README.md for the full table): FRBP 7001 (adversary proceeding), 7008(a) (jurisdiction
// and consent), 7010 (caption conforms to Form 416); Bankr. D.S.D. R. 9004-1(a) (8 1/2 x 11 paper,
// margins of at least one inch, one simple font, signature and date), 9004-2 (caption: debtor's full
// name, SSN or TIN last four digits, names used), 7010-2 (complete legal names of all parties); FRCP 10(b)
// (numbered paragraphs, applied by FRBP 7010).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a stated choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // R. 9004-1(a)(1): one simple font; vendored in fonts/ (the only font available here)
#let type-size = 12pt                   // no size is set by the local rules (tier 2: the exemplars are set at about 12 pt)
#let margin = 1in                       // R. 9004-1(a)(1): margins not less than one inch
#let page-w = 8.5in                     // R. 9004-1(a)(1): white 8 1/2 x 11 inch paper
#let page-h = 11in
#let single-leading = 0.5em             // single spacing (about 13.8 pt baseline at 12 pt); no spacing rule in the local rules
#let para-gap = 1em                     // space between paragraphs, as in the exemplar
#let para-indent = 0.5in                // first-line indent of numbered allegations
#let caption-left = 3.3in               // width of the party column of the caption
#let caption-paren = 0.3in              // width of the column of ")" marks
#let sig-indent = 3.25in                // signature block starts at the middle of the page (exemplar)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("sdb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, case names, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// The caption: court name, then a three-column grid (left: parties; ")" marks; right: case numbers).
/// Every row of the grid is one line, so the ")" marks align on every row.
#let caption(meta) = {
  let rows = ()                       // each row: (left content, right content)
  let debtors = meta.debtors
  // Rule 9004-2(a)(1)-(5): full debtor name, EIN, last four of SSN/TIN, names used (aka / fka)
  rows.push(([In re:], [Bankr. No. #meta.bankr_no]))
  rows.push(([], [Chapter #meta.chapter]))
  rows.push(([], []))
  for d in debtors {
    rows.push((inl(d.name), []))
    if "ssn_last4" in d { rows.push(([SSN xxx-xx-#d.ssn_last4], [])) }
    if "ein" in d { rows.push(([EIN #d.ein], [])) }
    if "tin_last4" in d { rows.push(([TIN xx-xxx#d.tin_last4], [])) }
    if "aka" in d { for a in d.aka { rows.push(([aka #a], [])) } }
    if "fka" in d { for a in d.fka { rows.push(([fka #a], [])) } }
    rows.push(([], []))
  }
  rows.push((align(right, [#if debtors.len() > 1 [Debtors.] else [Debtor.]]), []))
  rows.push(([], []))
  // Plaintiffs, then the adversary number on the first plaintiff row (Form 416D)
  let adv-done = false
  for p in meta.plaintiffs {
    for n in p.names {
      if not adv-done {
        rows.push((inl(n), [Adv. No. #meta.adversary_no]))
        adv-done = true
      } else {
        rows.push((inl(n), []))
      }
    }
    rows.push((align(right, [#p.designation]), []))
    rows.push(([], []))
  }
  rows.push(([v.], []))
  rows.push(([], []))
  for d in meta.defendants {
    for n in d.names { rows.push((inl(n), [])) }
    rows.push((align(right, [#d.designation]), []))
  }
  let cells = ()
  for r in rows {
    cells.push(pad(right: 0.2in, r.at(0)))
    cells.push([)])
    cells.push(r.at(1))
  }
  block(width: 100%, [
    #align(center)[
      #text(weight: "bold")[UNITED STATES BANKRUPTCY COURT] \
      #text(weight: "bold")[DISTRICT OF SOUTH DAKOTA]
    ]
    #v(1.5em)
    #grid(
      columns: (caption-left, caption-paren, 1fr),
      align: top,
      inset: (x: 0pt, y: 0pt),
      row-gutter: 0.5em,
      ..cells,
    )
  ])
}

/// Signature block after the body: date line, then the signer block at the middle of the page.
#let signature(sig) = {
  block(width: 100%, above: 1.5em, below: 0pt, breakable: false, [
    DATED #sig.date.
    #v(1.5em)
    #pad(left: sig-indent, block(breakable: false, [
      /s/ #sig.signer \
      #sig.signer \
      #for l in sig.firm [#l \ ]
      #sig.role
    ]))
  ])
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

/// Renders one adversary complaint. `meta` is the frontmatter, `md` the markdown body.
#let sdb-adversary-complaint(meta, md) = {
  set page(
    paper: "us-letter",
    width: page-w,
    height: page-h,
    margin: margin,
    footer: context align(center, text(size: 10pt, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(justify: false, leading: single-leading, spacing: para-gap, first-line-indent: 0pt)
  set enum(indent: 0.5in, body-indent: 0.5em, spacing: para-gap)

  // Frontmatter checks that are rule requirements (a missing one stops the build)
  assert(meta.debtors.len() > 0, message: "R. 9004-2(a): the caption needs at least one debtor")
  for d in meta.debtors {
    assert("ssn_last4" in d or "ein" in d or "tin_last4" in d,
      message: "R. 9004-2(a)(2)-(4): each debtor needs an EIN, the last four of an SSN, or the last four of a TIN: " + d.name)
  }

  caption(meta)
  v(1.5em)
  align(center, block(width: 100%, text(weight: "bold", inl(meta.title))))
  v(1.5em)
  if "lead_in" in meta [#meta.lead_in]

  let chunks = md.replace("\r", "").split("\n\n").map(s => s.trim()).filter(s => s != "")
  let n = 0                           // paragraph number (FRCP 10(b))
  let numbered = true                 // the prayer for relief is not a numbered claim
  for c in chunks {
    if c.starts-with("# ") {
      let t = c.slice(2)
      numbered = not t.contains("PRAYER")
      block(width: 100%, above: 1.5em, below: para-gap, sticky: true, align(center, text(weight: "bold", inl(t))))
    } else if c.starts-with("1. ") or c.starts-with("- ") {
      inl(c)
    } else if numbered {
      n = n + 1
      block(width: 100%, [#h(para-indent) #str(n). #h(0.5em) #inl(c)])
    } else {
      block(width: 100%, [#h(para-indent) #inl(c)])
    }
  }
  signature(meta.signature)
}
