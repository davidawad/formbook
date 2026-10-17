// U.S. Bankruptcy Court, Northern District of Illinois: memorandum of law in support of a motion
// (Fed. R. Bankr. P. 9013, 9014; N.D. Ill. Bankr. L.R. 5005-2, 9013-1, 9014-1).
//
// Rule-driven and content-agnostic. Requirement IDs (ILNB-...) refer to ../README.md, which quotes the rule
// text (effective Sept. 1, 2024). No case-specific text, no coordinates measured off the exemplar, no forced
// line breaks. The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of the
// same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = "Liberation Serif"         // ILNB-FORM-002: a proportionally spaced font; Times New Roman substitute per docs/FONTS.md. Vendored in /fonts.
#let type-size = 12pt                    // ILNB-FORM-002: at least 12 point, footnotes included (the rule floor).
#let line-pitch = 24pt                   // ILNB-FORM-003: double spacing, a 24 pt baseline pitch.
#let body-leading = 1.091em              // extra space between body lines: the ascender-to-descender box set below is 0.909em, so the pitch is 2.0em = line-pitch at 12 pt.
#let single-leading = 0.596em            // caption, counsel, signature block, footnotes, quotations, headings (ILNB-FORM-003 exception, README.md) (1.505em pitch).
#let page-margin = 1in                   // ILNB-FORM-004: no margin less than one inch.
#let para-indent = 0.5in                 // first-line indent of body paragraphs.
#let heading-tab = 0.5in                 // hanging indent of a heading's label.
#let max-pages = 15                      // ILNB-LIMIT-001: no memorandum may exceed 15 pages without leave of court (LBR 5005-2(D)).
#let footer-size = 12pt                  // page numbers (ILNB-FORM-005)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Stop with a message when a required metadata field is missing.
#let need(meta, key) = {
  if key not in meta { panic("ilnb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ilnb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *pro hac vice*, case names, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Several single-spaced lines, one block per item. Items are markdown strings or content.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: single-leading, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => if type(i) == str { inl(i) } else { i }))
}

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

// ---------------------------------------------------------------------------
// Headings: numbering and styles (ILNB-HEAD-001). Level 1 "I.", level 2 "A.", level 3 "1.", level 4 "a.".
// ---------------------------------------------------------------------------

/// Printed label of a heading. The numbering function is what steps the heading counter.
#let heading-num(..n) = {
  let lv = n.pos().len()
  let k = n.pos().last()
  if lv == 1 { numbering("I.", k) }
  else if lv == 2 { numbering("A.", k) }
  else if lv == 3 { numbering("1.", k) }
  else if lv == 4 { numbering("a.", k) }
  else { "" }
}

/// Left edge of a heading's label: level 1 at the margin, each deeper level half an inch in.
#let label-indent(level) = (level - 1) * heading-tab

// ---------------------------------------------------------------------------
// Court heading and caption (ILNB-CAP-001..003)
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(leading: single-leading, spacing: single-leading, justify: false)
  align(center, text(weight: "bold", line-stack((
    "IN THE UNITED STATES BANKRUPTCY COURT",
    "FOR THE NORTHERN DISTRICT OF ILLINOIS",
  ))))
  v(line-pitch * 0.5)
  align(center, text(weight: "bold", upper(need(meta, "division"))))
}

/// The caption: the party column (the debtor, and the adversary parties when there are any) and the case
/// column (chapter, case number, adversary number, judge). The rule requires the case number, chapter,
/// judge and the division (ILNB-CAP-001..003).
#let caption(meta) = {
  let cap = need(meta, "caption")
  let party(p) = {
    let rows = p.names
    rows.push(pad(left: 1.4in, inl(p.designation)))
    line-stack(rows)
  }
  let left = {
    line-stack(("In re:",))
    v(single-leading)
    party(cap.in_re)
    if "adversary" in cap and cap.adversary != none {
      v(line-pitch * 0.5)
      for (k, p) in cap.adversary.parties.enumerate() {
        if k > 0 {
          v(line-pitch * 0.5)
          line-stack(("v.",))
          v(line-pitch * 0.5)
        }
        party(p)
      }
    }
  }
  grid(
    columns: (3.4in, 1fr),
    column-gutter: 0.3in,
    block(width: 3.4in, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 0.15in, bottom: 0.12in), left),
    block(inset: (top: 0pt), {
      set par(leading: single-leading, spacing: single-leading, justify: false)
      let rows = ()
      if "chapter" in cap { rows.push(cap.chapter) }
      rows.push("Case No. " + cap.case_number)
      if "adversary" in cap and cap.adversary != none {
        rows.push("Adv. Pro. No. " + cap.adversary.number)
      }
      if "judge" in cap { rows.push(cap.judge) }
      stack(dir: ttb, spacing: line-pitch * 0.5, ..rows.map(r => inl(r)))
    }),
  )
}

#let cover(meta) = {
  court-title(meta)
  v(line-pitch)
  caption(meta)
  v(line-pitch)
  align(center, block(width: 100%, sticky: true, {
    set par(leading: single-leading, spacing: single-leading, justify: false)
    text(weight: "bold", upper(need(meta, "title")))
  }))
  v(line-pitch)
}

// ---------------------------------------------------------------------------
// Signature block (ILNB-SIG-001..002): signed by counsel, with the signing attorney's name, mailing
// address, email and telephone on the last page (LBR 5005-2(C)(6)). Single spaced, as in the exemplar.
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, sticky: true, {
    grid(
      columns: (2.5in, 1fr),
      column-gutter: 0.2in,
      line-stack(("Dated: " + sig.date,)),
      {
        line-stack(("Respectfully submitted,",))
        v(line-pitch * 0.5)
        line-stack((sig.party,))
        v(line-pitch * 0.5)
        line-stack(("/s/ " + sig.signer,))
        line-stack((sig.role,))
      },
    )
    for (k, g) in sig.counsel.enumerate() {
      if k > 0 {
        v(line-pitch * 0.5)
        line-stack(([#"- and -"],))
      }
      v(line-pitch * 0.5)
      line-stack(g.names + g.lines)
    }
  })
}

// ---------------------------------------------------------------------------
// The memorandum
// ---------------------------------------------------------------------------

#let ilnb-motion-brief(meta, md) = {
  set document(title: need(meta, "title"), author: need(meta, "signature").signer)
  set page(
    paper: "us-letter",
    margin: page-margin,
    footer: context align(center, text(size: footer-size, counter(page).display("1"))),
  )
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: "ascender", bottom-edge: "descender",
  )
  set par(
    leading: body-leading, spacing: body-leading,
    first-line-indent: (amount: para-indent, all: true), justify: false,
  )
  // The numbering function is what steps the heading counter; the labels are drawn by the show rule below.
  set heading(numbering: heading-num)
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em)

  // Block quotations: indented on both sides, single spaced (ILNB-FORM-003 exception, README.md).
  show quote.where(block: true): it => pad(x: para-indent, block(width: 100%, {
    set par(leading: single-leading, first-line-indent: 0pt, spacing: line-pitch * 0.5)
    it.body
  }))

  show heading: it => context {
    let nums = counter(heading).at(it.location()).slice(0, it.level)
    let lab = if it.numbering == none { "" } else { numbering(it.numbering, ..nums) }
    let ind = label-indent(it.level)
    block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
      hang(ind + heading-tab, {
        h(ind)
        box(width: heading-tab, text(size: type-size, lab))
        text(size: type-size, strong(it.body))
      }))
  }

  cover(meta)

  cmarker.render(md, raw-typst: false, smart-punctuation: true)

  v(line-pitch)
  signature-block(meta)

  // The page limit (ILNB-LIMIT-001): every page of the memorandum counts. Stops the build when exceeded.
  context {
    let n = counter(page).final().first()
    assert(n <= max-pages, message: "ilnb-motion-brief: the memorandum is " + str(n) + " pages; N.D. Ill. Bankr. L.R. 5005-2(D) allows " + str(max-pages) + " without leave of court")
  }
}
