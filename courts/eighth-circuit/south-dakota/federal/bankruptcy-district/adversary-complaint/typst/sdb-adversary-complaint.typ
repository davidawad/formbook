// Adversary complaint for the United States Bankruptcy Court, District of South Dakota (sdb).
// Rules (see ../README.md for the full table): FRBP 7001 (adversary proceeding), 7008(a) (jurisdiction
// and consent), 7010 (caption conforms to Form 416); Bankr. D.S.D. R. 9004-1(a) (8 1/2 x 11 paper,
// margins of at least one inch, one simple font, signature and date), 9004-2 (caption: debtor's full
// name, SSN or TIN last four digits, names used), 7010-2 (complete legal names of all parties); FRCP 10(b)
// (numbered paragraphs, applied by FRBP 7010).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a stated choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")  // R. 9004-1(a)(1): one simple font (no face named; the house face); vendored in fonts/
#let type-size = 12pt                   // no size is set by the local rules (tier 2: the exemplars are set at about 12 pt)
#let margin = 1in                       // R. 9004-1(a)(1): margins not less than one inch
#let page-w = 8.5in                     // R. 9004-1(a)(1): white 8 1/2 x 11 inch paper
#let page-h = 11in
#let para-gap = 12pt                    // space between paragraphs (one blank line at 12 pt), as in the exemplar
#let section-gap = 18pt                 // space around the title, above a heading and before the signature
#let label-box = 0.5in                  // a paragraph or prayer item number in a box of this width, its text hanging after it
#let caption-left = 3.3in               // width of the party column of the caption
#let caption-pad = 0.2in                // space kept at the right of the party column (the right-aligned designations)
#let caption-paren = 0.3in              // width of the column of ")" marks
#let sig-indent = 3.25in                // signature block starts at the middle of the page (exemplar)

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // single spacing: 1.15 x the type size (Word's single line in this face); no spacing rule in the local rules

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

/// A paragraph block with explicit space above and below (two adjacent spaces collapse to the larger).
/// `keep`: the block is not split and stays on the page of the block after it (the last paragraph before the
/// signature; Word's keep with next and keep lines together).
#let para-block(above: para-gap, below: para-gap, sticky: false, keep: false, body) = block(width: 100%,
  above: above, below: below, sticky: sticky or keep, breakable: not keep, body)

/// A paragraph whose label (a number) stands in a box of `label-box` at `left`, its text hanging after the box.
#let labeled(left: 0pt, keep: false, label, body) = para-block(keep: keep, pad(left: left,
  par(hanging-indent: label-box, first-line-indent: 0pt, { box(width: label-box, label); body })))

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
    rows.push((align(right, inl(p.designation)), []))
    rows.push(([], []))
  }
  rows.push(([v.], []))
  rows.push(([], []))
  for d in meta.defendants {
    for n in d.names { rows.push((inl(n), [])) }
    rows.push((align(right, inl(d.designation)), []))
  }
  let cells = ()
  for r in rows {
    cells.push(pad(right: caption-pad, r.at(0)))
    cells.push([)])
    cells.push(r.at(1))
  }
  for l in ("UNITED STATES BANKRUPTCY COURT", "DISTRICT OF SOUTH DAKOTA") {
    para-block(above: 0pt, below: 0pt, align(center, text(weight: "bold", l)))
  }
  para-block(above: section-gap, below: section-gap, grid(
    columns: (caption-left, caption-paren, 1fr),
    align: top,
    inset: 0pt,
    ..cells,
  ))
}

/// Signature block after the body: date line, then the signer block at the middle of the page.
#let signature(sig) = block(width: 100%, above: section-gap, below: 0pt, breakable: false, {
  par[DATED #inl(sig.date).]
  let lines = ("/s/ " + sig.signer, sig.signer, ..sig.firm, sig.role)
  block(above: section-gap, below: 0pt, pad(left: sig-indent, for l in lines { if l == "" { block(height: pitch-single) } else { par(inl(l)) } }))
})

/// Prayer items: "1. " (or "- ") lines of one chunk; a line that does not start a new item continues the last one.
#let items(c) = {
  let out = ()
  for l in c.split("\n") {
    let m = l.match(regex("^\\s*(\\d+\\.|[-*])\\s+(.*)$"))
    if m != none {
      let lab = m.captures.at(0)
      out.push((if lab in ("-", "*") { "•" } else { lab }, m.captures.at(1)))
    } else if out.len() > 0 {
      out.last().at(1) += " " + l.trim()
    }
  }
  out
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

/// Renders one adversary complaint. `meta` is the frontmatter, `md` the markdown body.
#let sdb-adversary-complaint(meta, md) = {
  // The page number: centered in a single-spaced line box, at the same place on every page (Word's footer).
  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  // no punctuation hanging into the margin (Word sets none: the right-aligned caption designations end where it ends them)
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false, overhang: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, single-spaced
  // line boxes.
  show: xengine.with(pitch: pitch-single, list-indent: none)

  // Frontmatter checks that are rule requirements (a missing one stops the build)
  assert(meta.debtors.len() > 0, message: "R. 9004-2(a): the caption needs at least one debtor")
  for d in meta.debtors {
    assert("ssn_last4" in d or "ein" in d or "tin_last4" in d,
      message: "R. 9004-2(a)(2)-(4): each debtor needs an EIN, the last four of an SSN, or the last four of a TIN: " + d.name)
  }

  caption(meta)
  para-block(above: section-gap, below: section-gap, align(center, text(weight: "bold", inl(meta.title))))
  if "lead_in" in meta { para-block(par(first-line-indent: (amount: label-box, all: true), inl(meta.lead_in))) }

  let chunks = md.replace("\r", "").split("\n\n").map(s => s.trim()).filter(s => s != "")
  let n = 0                           // paragraph number (FRCP 10(b))
  let numbered = true                 // the prayer for relief is not a numbered claim
  for (ci, c) in chunks.enumerate() {
    // the last paragraph (or prayer item) stays with the signature block, so a signature never stands alone
    let last = ci == chunks.len() - 1
    if c.starts-with("# ") {
      let t = c.slice(2)
      numbered = not t.contains("PRAYER")
      para-block(above: section-gap, sticky: true, align(center, text(weight: "bold", inl(t))))
    } else if c.match(regex("^(\\d+\\.|[-*])\\s")) != none {
      let its = items(c)
      for (i, (lab, t)) in its.enumerate() { labeled(left: label-box, keep: last and i == its.len() - 1, lab, inl(t)) }
    } else if numbered {
      n = n + 1
      labeled(keep: last, [#n.], inl(c))
    } else {
      para-block(keep: last, par(first-line-indent: (amount: label-box, all: true), inl(c)))
    }
  }
  signature(meta.signature)
}
