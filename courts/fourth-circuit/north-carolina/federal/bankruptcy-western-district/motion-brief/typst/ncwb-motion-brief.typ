// Motion with memorandum, United States Bankruptcy Court, Western District of North Carolina.
// Rules (text read 2026-10-14; see ../README.md): Fed. R. Bankr. P. 9013 (a motion states its grounds with
// particularity and the relief requested; served on the trustee); W.D.N.C. LR 7007-1(a) (motions in an
// adversary proceeding state the facts and the relief; the memorandum follows LR 9013-2), LR 7007-1(d) and
// LR 9013-1 (a separate notice of hearing accompanies each motion), LR 9013-1(c) (a certificate of service
// with each pleading), LR 9013-2(a) (12 point minimum, double-spaced, one-inch margins, numbered pages,
// 25-page limit: not counted by the template). Caption: Fed. R. Bankr. P. 9004(b), 7010 (Official Form 416).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // Times New Roman substitute per docs/FONTS.md, vendored in fonts/ (SIL OFL); render.sh compiles with vendored fonts only
#let type-size = 12pt              // LR 9013-2(a): font size a minimum of 12 point
#let page-w = 8.5in                // letter paper (convention; the local rules are silent on paper size)
#let page-h = 11in
#let margin = 1in                  // LR 9013-2(a): margins one inch on all sides
#let text-width = page-w - 2 * margin
#let double = 1.345em              // LR 9013-2(a): double-spaced; Liberation Serif line box is 0.655 em, so this gives a 24 pt baseline pitch at 12 pt
#let single = 0.5em                // single spacing for the caption, the signature block, block quotations and the notice caption
#let para-indent = 0.5in           // first-line indent of each paragraph (exemplar convention)
#let caption-left = 3.6in          // width of the party column of the caption boxes

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ncwb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown for a single line (names with *et al.*, bar numbers with \*, and so on).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line per item. An empty string is a blank line.
#let line-stack(items) = {
  set par(leading: single, spacing: single, first-line-indent: 0pt, justify: false)
  stack(dir: ttb, spacing: single, ..items.map(i => if i == "" { block(height: single) } else { block(inl(i)) }))
}

// ---------------------------------------------------------------------------
// Cover: court title, caption (Form 416 style: debtor box, then adversary box), title of the paper
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(leading: single, spacing: single, first-line-indent: 0pt)
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
      line-stack((meta.adversary.label + " " + meta.adversary.number,))
    }),
  )
}

#let title-block(meta) = block(width: 100%, above: double, below: double, breakable: false,
  align(center, text(weight: "bold", upper(meta.title))))

// ---------------------------------------------------------------------------
// Signature, notice of hearing, certificate of service
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

/// The notice of hearing is a separate paper with its own caption (LR 7007-1(d)); the exemplar prints it
/// after the memorandum, on new pages, with the caption repeated.
#let notice-page(meta, body) = {
  pagebreak()
  court-title(meta)
  v(double)
  caption(meta)
  block(width: 100%, above: double, below: double, breakable: false,
    align(center, text(weight: "bold", "NOTICE OF HEARING")))
  cmarker.render(body, raw-typst: false, smart-punctuation: true)
  signature(meta)
}

/// Certificate of service (LR 9013-1(c)): the names and addresses of the parties served, the method, the date.
#let certificate(meta) = if "service" in meta and meta.service != none {
  pagebreak()
  block(width: 100%, above: 0pt, below: double, breakable: false,
    align(center, text(weight: "bold", "CERTIFICATE OF SERVICE")))
  block(width: 100%, above: 0pt, below: double, {
    set par(first-line-indent: (amount: para-indent, all: true))
    [I certify that on #meta.service.date, a copy of the #meta.service.document was served by #meta.service.method, on the following:]
  })
  block(width: 100%, inset: (left: 0.5in), line-stack(meta.service.parties))
  block(width: 100%, above: double, breakable: false, {
    set par(first-line-indent: 0pt, leading: single)
    grid(
      columns: (2.6in, 1fr),
      column-gutter: 0.2in,
      [Dated: #meta.service.date],
      line-stack(meta.service.signature),
    )
  })
}

// ---------------------------------------------------------------------------
// Entry: the page, the caption, the memorandum (markdown), the signature block, the notice, the certificate
// ---------------------------------------------------------------------------

#let doc(meta, body) = {
  set page(paper: "us-letter", margin: margin, numbering: "1", number-align: center)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: double, spacing: double, justify: false, first-line-indent: (amount: para-indent, all: true))

  // Section headings (I., II., ...): centered, bold, capitals. Sub-headings (A., B., ...): bold, flush left.
  show heading.where(level: 1): it => block(width: 100%, above: double, below: double, inset: (y: 0.25em), sticky: true,
    align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, above: double, below: double, inset: (y: 0.25em), sticky: true,
    text(size: type-size, weight: "bold", it.body))
  show heading.where(level: 3): it => block(width: 100%, above: double, below: double, inset: (y: 0.25em), sticky: true,
    text(size: type-size, weight: "bold", style: "italic", it.body))

  // Block quotations: indented both sides, single-spaced (the statute quotations in the exemplar).
  show quote.where(block: true): it => pad(left: 0.5in, right: 0.5in, block(width: 100%, above: 0.5em, below: 0.5em, {
    set par(leading: single, spacing: single, first-line-indent: 0pt)
    it.body
  }))

  court-title(meta)
  v(double)
  caption(meta)
  title-block(meta)

  // The memorandum runs up to the notice of hearing, which is a separate paper.
  let parts = body.split(regex("(?m)^# NOTICE OF HEARING[ \\t]*\\r?\\n?"))
  cmarker.render(parts.at(0), raw-typst: false, smart-punctuation: true)
  signature(meta)
  if parts.len() > 1 {
    notice-page(meta, parts.at(1))
  }
  certificate(meta)
}
