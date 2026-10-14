// U.S. Bankruptcy Court, Southern District of Illinois: brief in support of a motion (S.D. Ill. L.R. 9013-5).
//
// The brief is a separate document from the motion (L.R. 9013-1(A), 9013-5(D)). Rule-driven and
// content-agnostic. Requirement IDs (ILSB-...) refer to ../README.md, which quotes the rule text. No
// case-specific text, no coordinates measured off an exemplar, no forced line breaks. The body is markdown
// rendered by cmarker; the caption, counsel and certificate data come from the YAML frontmatter of the
// same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or to a named style choice; see ../README.md)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"        // Vendored in /fonts. No S.D. Ill. rule names a typeface (ILSB-FORM-002 gap).
#let type-size = 12pt                   // Style choice. No S.D. Ill. type-size rule.
#let pitch = 24pt                       // Double spacing for the body (convention, not a rule).
#let body-leading = 1.35em              // Gives a 24 pt baseline pitch at 12 pt in EB Garamond (line box 0.65 em).
#let single-leading = 0.5em             // Caption, counsel, signature, block quotations, footnotes, certificate.
#let page-w = 8.5in                     // ILSB-FORM-001 (L.R. 5005-2): 8 1/2 by 11 inch paper.
#let page-h = 11in
#let page-margin = 1in
#let para-indent = 0.5in
#let caption-left = 3.6in               // Width of the party column of the caption.
#let footer-size = 10pt                 // Page number only; not body text.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ilsb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names, *Id.*), as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line per item, with the single-spaced gap between items.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Caption (the same form as the adversary complaint: court, debtor and chapter, parties, adversary number)
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(leading: single-leading, spacing: 0pt)
  let lines = ("IN THE UNITED STATES BANKRUPTCY COURT", "FOR THE SOUTHERN DISTRICT OF ILLINOIS")
  if "division" in meta and meta.division != none { lines.push(upper(meta.division)) }
  align(center, stack(dir: ttb, spacing: single-leading, ..lines.map(l => text(weight: "bold", l))))
}

#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.25in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 10pt), {
    let rows = ("In re:",) + meta.debtors + (meta.debtor_designation,)
    rows.push("")
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { rows.push("v.") }
      rows += p.names + (p.designation,)
    }
    line-stack(rows)
  }),
  block(inset: (left: 0.1in), {
    set par(leading: single-leading, spacing: 0pt)
    stack(
      dir: ttb,
      spacing: single-leading,
      [Case No. #meta.bankruptcy_case_no],
      [Chapter #meta.chapter],
      v(pitch * 0.5),
      if meta.adversary_no != none and meta.adversary_no != "" {
        [Adversary No. #meta.adversary_no]
      } else {
        [Adversary No. #("_" * 10)]
      },
    )
  }),
)

// ---------------------------------------------------------------------------
// Signature, attorney block and certificate of service
// (L.R. 9011(A) attorney block; L.R. 9013-2 certificate of service; Electronic Filing Rules, Rule 5)
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(width: 100%, breakable: false, above: pitch, {
  grid(
    columns: (2.8in, 1fr),
    column-gutter: 0.2in,
    [Dated: #meta.date],
    {
      set par(leading: single-leading, spacing: 0pt)
      [Respectfully submitted,]
      v(pitch * 0.5)
      line-stack(meta.signature.party)
      v(pitch * 0.5)
      line-stack(("/s/ " + meta.signature.signer, meta.signature.signer + ",", meta.signature.signer_title))
    },
  )
  v(pitch)
  line-stack(meta.signature.attorney)
})

#let certificate-of-service(meta) = {
  // L.R. 9013-2(A): a paper filed under Rule 9013 or 9014 must comply with Rule 7005(d), and L.R. 9013-2(B)
  // lets the court strike a paper without it. The statement and the list of recipients are the author's.
  pagebreak()
  align(center, text(weight: "bold", "CERTIFICATE OF SERVICE"))
  v(pitch)
  block(width: 100%, {
    set par(leading: body-leading)
    h(para-indent)
    inl(meta.service.statement)
  })
  v(pitch)
  line-stack(meta.service.parties)
  v(pitch * 0.5)
  line-stack(meta.service.signature)
}

// ---------------------------------------------------------------------------
// Body: headings and paragraphs
// ---------------------------------------------------------------------------

/// The body, one blank-line-separated chunk at a time.
///  - `#` / `##` / `###` headings: centered bold capitals / centered bold / bold. Not numbered: the
///    author types any numbering (a brief's point headings are I., A., 1.; the template does not number).
///  - a chunk beginning `>` is a block quotation: single-spaced and indented.
///  - a chunk beginning `- ` is a bulleted list.
///  - every other chunk is a paragraph with a first-line indent, double-spaced. Not numbered (briefs are not).
/// Headings are `sticky`, so one never ends a page.
/// Footnote definitions (`[^key]: text`) are taken out of the flow and rendered with the paragraph that
/// cites them: cmarker resolves a footnote reference only within the text it renders in one call.
#let body-flow(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let defs = (:)
  for c in chunks {
    let key = c.trim().match(regex("^\\[\\^([^\\]]+)\\]:"))
    if key != none { defs.insert(key.captures.at(0), c.trim()) }
  }
  let md(t) = {
    let tail = ""
    for (key, d) in defs {
      if t.contains("[^" + key + "]") { tail += "\n\n" + d }
    }
    cmarker.render(t + tail, raw-typst: false, smart-punctuation: true, h1-level: 1)
  }
  for c in chunks.filter(c => not c.trim().starts-with("[^")) {
    let t = c.trim()
    if t.starts-with("#") {
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^[-*+][ \\t]")) {
      {
        set par(leading: body-leading)
        set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      }
    } else if t.starts-with(">") {
      pad(left: 0.5in, right: 0.5in, {
        set par(leading: single-leading)
        v(pitch * 0.5)
        md(t)
        v(pitch * 0.5)
      })
    } else {
      block(width: 100%, below: body-leading, {
        set par(leading: body-leading)
        h(para-indent)
        md(t)
      })
    }
  }
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let ilsb-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: page-margin,
    footer: context {
      let p = counter(page).get().first()
      let n = counter(page).final().first()
      set text(size: footer-size)
      align(center, [Page #p of #n])
    },
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  show heading.where(level: 1): it => block(width: 100%, above: pitch * 0.5, below: pitch * 0.5, sticky: true,
    align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, above: pitch * 0.5, below: pitch * 0.5, sticky: true,
    align(center, text(size: type-size, weight: "bold", it.body)))
  show heading.where(level: 3): it => block(width: 100%, above: pitch * 0.5, below: pitch * 0.5, sticky: true,
    text(size: type-size, weight: "bold", it.body))

  court-title(meta)
  v(pitch)
  caption(meta)
  v(pitch)
  align(center, text(weight: "bold", upper(meta.title)))
  v(pitch)

  body-flow(body)

  signature-block(meta)

  if "service" in meta and meta.service != none {
    certificate-of-service(meta)
  }
}
