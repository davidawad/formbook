// Adversary complaint for the United States Bankruptcy Court, Middle District of Florida (flmb).
// Rules: Fed. R. Bankr. P. 7010 (form of adversary pleadings), 9004(b) (caption), 7008(a) (jurisdiction
// allegation, core or non-core, consent to final orders); Fed. R. Civ. P. 10(a)-(b) as applied by 7010
// (caption, numbered paragraphs); Local Rules 9004-1(a)-(c) (party designation, jury demand, injunctive
// relief in the title) and 7001-1(b) (injunctive relief); the Court's Style Guide II.A and Local Rule
// 5005-1(d) (paper, margins, font, page numbers). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter or body.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"   // Style Guide II.A asks for Times New Roman 12 point; no Times-metric face is vendored (README, Known gaps)
#let type-size = 12pt              // Style Guide II.A: 12-point font
#let body-leading = 1.35em         // double spacing: 24 pt baseline pitch at 12 pt in EB Garamond (README)
#let single-leading = 0.5em        // counsel, caption, signature block, tables
#let para-indent = 0.5in           // first-line indent of numbered and unnumbered paragraphs
#let margin = 1in                  // Style Guide II.A; Local Rule 5005-1(d): one-inch margins on 8 1/2 x 11 paper
#let caption-left = 3.4in          // width of the party column of the caption
#let text-width = 8.5in - 2 * margin

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("flmb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in *italics*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// The title as printed: capitals, with the words the Local Rules require when they apply.
#let full-title(meta) = {
  let parts = (upper(meta.title),)
  if "injunctive_relief" in meta and meta.injunctive_relief { parts.push("INJUNCTIVE RELIEF SOUGHT") } // LR 7001-1(b), 9004-1(c)
  if "jury_demand" in meta and meta.jury_demand { parts.push("DEMAND FOR JURY TRIAL") } // LR 9004-1(b)
  parts.join("; ")
}

/// Footnote definitions (`[^key]: text`), keyed by name. Each is rendered with the paragraph that cites it.
#let footnote-defs(body) = {
  let defs = (:)
  for m in body.matches(regex("(?m)^\\[\\^([^\\]]+)\\]:[ \\t]*(.+)$")) {
    defs.insert(m.captures.at(0), m.captures.at(1))
  }
  defs
}

/// A paragraph's markdown, with the definitions of the footnotes it cites appended.
#let with-notes(t, defs) = {
  let keys = t.matches(regex("\\[\\^([^\\]]+)\\]")).map(m => m.captures.at(0)).dedup()
  if keys.len() == 0 { t } else {
    t + "\n\n" + keys.map(k => "[^" + k + "]: " + defs.at(k)).join("\n\n")
  }
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Page number centered in the footer on every page except the first (Style Guide II.A).
#let footer-page() = context {
  if counter(page).get().first() > 1 {
    align(center, text(size: type-size, counter(page).display()))
  }
}

// ---------------------------------------------------------------------------
// Caption (Fed. R. Bankr. P. 9004(b), 7010; Local Rule 9004-1(a))
// ---------------------------------------------------------------------------

#let caption(meta) = {
  set par(leading: single-leading, justify: false)
  let slash = grid(columns: (1fr, 0.2in), line(length: 100%, stroke: 0.75pt), align(bottom, [/]))
  grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.2in,
    row-gutter: body-leading,
    stack(dir: ttb, spacing: single-leading,
      [In re:],
      ..meta.in_re.map(n => inl(n)),
      pad(left: 0.5in, [Debtor.]),
      slash,
    ),
    stack(dir: ttb, spacing: single-leading, [Case No. #meta.case_number], [#meta.chapter]),
    stack(dir: ttb, spacing: single-leading, ..meta.caption.at(0).names.map(n => inl(n)), pad(left: 0.5in, inl(meta.caption.at(0).designation))),
    [],
    [v.],
    [Adv. Case No. #meta.adversary_number],
    stack(dir: ttb, spacing: single-leading,
      ..meta.caption.at(1).names.map(n => inl(n)),
      pad(left: 0.5in, inl(meta.caption.at(1).designation)),
      slash,
    ),
    [],
  )
}

#let court-title(meta) = {
  set par(leading: single-leading, justify: false)
  align(center, stack(dir: ttb, spacing: single-leading,
    text(weight: "bold", "UNITED STATES BANKRUPTCY COURT"),
    text(weight: "bold", "MIDDLE DISTRICT OF FLORIDA"),
    text(weight: "bold", upper(meta.division) + " DIVISION"),
  ))
}

// ---------------------------------------------------------------------------
// Signature block (Fed. R. Civ. P. 11(a) as applied; Local Rule 9004-1)
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(breakable: false, width: 100%, {
  set par(leading: single-leading, justify: false)
  grid(
    columns: (1fr, 3.1in),
    column-gutter: 0.2in,
    if "date" in meta { [Dated: #meta.date] } else { [] },
    stack(dir: ttb, spacing: single-leading,
      [Respectfully submitted,],
      v(body-leading * 0.5),
      ..meta.signature.firm.map(n => inl(n)),
      v(body-leading * 0.5),
      inl("By: /s/ " + meta.signature.signer),
      inl(meta.signature.signer),
      ..meta.signature.lines.map(n => inl(n)),
    ),
  )
})

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (Fed. R. Civ. P. 10(b)); unnumbered paragraphs are marked with a leading ^
// in the sample (the reservation of rights, the prayer for relief); lists are lettered a., b., ...
// ---------------------------------------------------------------------------

#let body-chunks(body, para-counter, defs) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if not t.starts-with("[^") {
      if t.starts-with("#") {
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      } else if t.starts-with("|") {
        // A table (the transfer chart): unruled, centered, single-spaced.
        block(width: 100%, breakable: false, align(center, {
          set par(leading: single-leading, justify: false)
          set table(stroke: none, inset: (x: 10pt, y: 3pt))
          cmarker.render(t, raw-typst: false, smart-punctuation: true)
        }))
      } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
        // A list may break across pages.
        block(width: 100%, {
          set par(leading: body-leading, justify: true)
          set enum(numbering: "a.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
          set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
          cmarker.render(with-notes(t, defs), raw-typst: false, smart-punctuation: true, h1-level: 1)
          v(body-leading)
        })
      } else if t.starts-with("^") {
        h(para-indent)
        inl(with-notes(t.slice(1).trim(), defs))
        parbreak()
      } else {
        para-counter.step()
        h(para-indent)
        context para-counter.display()
        h(0.3in)
        inl(with-notes(t, defs))
        parbreak()
      }
    }
  }
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let flmb-adversary-complaint(meta, body) = {
  let para-counter = counter("allegation")
  let defs = footnote-defs(body)

  set page(
    paper: "us-letter",
    margin: margin,
    footer: footer-page(),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, first-line-indent: 0pt, justify: true)
  show footnote.entry: set text(size: type-size)

  // Headings: level 1 centered bold capitals; level 2 centered bold; level 3 centered bold italic.
  show heading.where(level: 1): it => block(width: 100%, above: body-leading, sticky: true,
    align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, above: body-leading, sticky: true,
    align(center, text(size: type-size, weight: "bold", it.body)))
  show heading.where(level: 3): it => block(width: 100%, above: body-leading, sticky: true,
    align(center, text(size: type-size, weight: "bold", style: "italic", it.body)))

  court-title(meta)
  v(body-leading)
  caption(meta)
  v(body-leading)
  align(center, block(width: 100%, text(weight: "bold", full-title(meta))))
  v(body-leading)

  body-chunks(body, para-counter, defs)

  v(body-leading)
  signature-block(meta)
}
