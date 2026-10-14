// Adversary complaint, United States Bankruptcy Court, Western District of North Carolina.
// Rules (text read 2026-10-14; see ../README.md): Fed. R. Bankr. P. 7001 (what is an adversary
// proceeding), 7008(a) (jurisdiction allegation, core statement, consent to final orders), 7010 (caption
// substantially conforms to Official Form 416), 9004(a)-(b) (legible; caption: court, title, case and
// adversary numbers, designation). W.D.N.C. LR 7003-1: the Adversary Proceeding Cover Sheet (Form B 1040)
// accompanies the complaint as a separate filing; it is not generated here.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"   // vendored in fonts/ (SIL OFL); render.sh compiles with vendored fonts only
#let type-size = 12pt              // no bankruptcy-court type rule for complaints; 12 pt is the LR 9013-2(a) floor for briefs
#let page-w = 8.5in                // letter paper (convention; the local rules are silent on paper size)
#let page-h = 11in
#let margin = 1in                  // LR 9013-2(a): one inch on all sides (stated for briefs; applied to the complaint too)
#let text-width = page-w - 2 * margin
#let double = 1.35em               // double spacing: EB Garamond line box is 0.65 em, so this leading gives a 24 pt baseline pitch at 12 pt
#let single = 0.5em                // single spacing for caption, counsel block and quotations (about 14 pt pitch)
#let para-indent = 0.5in           // first-line indent of each allegation
#let caption-left = 3.6in          // width of the party column of the caption boxes

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ncwb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown for a single line (names with *et al.*, bar numbers with \*, and so on).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line per item. An empty string is a blank line.
#let line-stack(items) = {
  set par(leading: single, spacing: 0pt, first-line-indent: 0pt, justify: false)
  stack(dir: ttb, spacing: single, ..items.map(i => if i == "" { block(height: single) } else { block(inl(i)) }))
}

// ---------------------------------------------------------------------------
// Cover: court title, caption (Form 416 style: debtor box, then adversary box), title of the paper
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(leading: single, spacing: 0pt, first-line-indent: 0pt)
  align(center, stack(dir: ttb, spacing: single,
    text(weight: "bold", upper(meta.court)),
    text(weight: "bold", upper(meta.district)),
    text(weight: "bold", upper(meta.division)),
  ))
}

/// The party column of a caption: each party's names, its designation, and "v." between parties.
#let parties-rows(parties) = {
  let rows = ()
  for (k, p) in parties.enumerate() {
    if k > 0 { rows += ("v.", "") }
    rows += p.names
    rows.push(p.designation)
  }
  rows
}

#let caption(meta) = {
  let d = meta.debtor
  // Box 1: the debtor, with the bankruptcy case number and chapter.
  grid(
    columns: (caption-left, 1fr),
    block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 0.12in, bottom: 0.12in, top: 0pt), {
      line-stack(("In re:", "") + d.names + ("", d.designation))
    }),
    block(inset: (left: 0.2in, bottom: 0.12in, top: 0pt), {
      line-stack(("Case No. " + d.case_number, "", "Chapter " + d.chapter))
    }),
  )
  v(double)
  // Box 2: the parties to the adversary proceeding, with the adversary number.
  grid(
    columns: (caption-left, 1fr),
    block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 0.12in, bottom: 0.12in, top: 0pt), {
      line-stack(parties-rows(meta.caption.parties))
    }),
    block(inset: (left: 0.2in, bottom: 0.12in, top: 0pt), {
      line-stack(("Adv. Proc. No. " + meta.adversary.number,))
    }),
  )
}

#let title-block(meta) = block(width: 100%, above: double, below: double, breakable: false,
  align(center, text(weight: "bold", upper(meta.title))))

// ---------------------------------------------------------------------------
// Signature and certificate
// ---------------------------------------------------------------------------

#let signature(meta) = block(width: 100%, above: double, {
  set par(first-line-indent: 0pt, leading: single)
  grid(
    columns: (2.6in, 1fr),
    column-gutter: 0.2in,
    [Dated: #meta.signature.date],
    line-stack(meta.signature.lines),
  )
})

// ---------------------------------------------------------------------------
// Entry: the page, the caption, the body (markdown) and the signature block
// ---------------------------------------------------------------------------

#let doc(meta, body) = {
  set page(paper: "us-letter", margin: margin, numbering: "1", number-align: center)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: double, spacing: double, justify: false, first-line-indent: (amount: para-indent, all: true))

  // Headings in the complaint: section headings centered and bold; count headings the same; sub-headings flush left.
  show heading.where(level: 1): it => block(width: 100%, above: double, below: double, inset: (y: 0.25em), sticky: true,
    align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, above: 0pt, below: double, inset: (y: 0.25em), sticky: true,
    align(center, text(size: type-size, weight: "bold", it.body)))
  show heading.where(level: 3): it => block(width: 100%, above: double, below: double, inset: (y: 0.25em), sticky: true,
    text(size: type-size, weight: "bold", it.body))

  // Block quotations: indented both sides, single-spaced (FRAP-style convention; none in the complaint's exemplar).
  show quote.where(block: true): it => pad(left: 0.5in, right: 0.5in, block(width: 100%, above: 0.5em, below: 0.5em, {
    set par(leading: single, spacing: single, first-line-indent: 0pt)
    it.body
  }))

  court-title(meta)
  v(double)
  caption(meta)
  title-block(meta)

  cmarker.render(body, raw-typst: false, smart-punctuation: true)

  signature(meta)
}
