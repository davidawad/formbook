// Adversary complaint for the United States Bankruptcy Court, Southern District of Iowa (iasb).
// Rules (primary sources, verified 2026-10-14; see ../README.md):
//   Fed. R. Bankr. P. 7010: Fed. R. Civ. P. 10 applies, and the caption must substantially conform to Official Form 416D.
//   Fed. R. Bankr. P. 7008: the jurisdiction allegation names the bankruptcy case (name, number, Code chapter), the district
//     and the division, and the complaint must state whether the pleader consents to final orders by the bankruptcy court.
//   Fed. R. Bankr. P. 9004(a), (b): legible; caption with the court's name, the title of the case, the case number and the
//     adversary-proceeding number, and a brief designation of the document.
//   Fed. R. Bankr. P. 9011(a): signed by an attorney of record, with the signer's address and telephone number.
//   Fed. R. Civ. P. 10(b): numbered paragraphs, each limited as far as practicable to a single set of circumstances.
// The court's local rules were abolished effective 2003-08-04 (court website), so no local typography rule applies.
// Font, size, spacing and margins are conventions (tier 2), chosen to match the filed exemplar; see ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each is a convention or a rule; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")     // no typeface is mandated; EB Garamond is the vendored serif (fonts/)
#let type-size = 12pt                // convention: 12 point, the size the exemplar uses
#let body-leading = 1.35em           // convention: double-spaced body text (exemplar), 1.35em of leading at 12 pt
#let single-leading = 0.5em          // single-spaced caption, block quotations, tables and signature block
#let para-indent = 0.5in             // first-line indent of numbered paragraphs
#let page-w = 8.5in                  // FRBP 9004(a) no longer states a paper size (restyled text); 8 1/2 x 11 is the court's paper
#let page-h = 11in
#let margin = 1in                    // convention: one inch on all sides
#let text-width = page-w - 2 * margin
#let caption-left = 3.4in            // width of the party column of the caption (Form 416D)
#let court-name = ("UNITED STATES BANKRUPTCY COURT", "SOUTHERN DISTRICT OF IOWA")  // FRBP 9004(b)(1), 7010

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("iasb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, case names in italics).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Single-spaced lines, one per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Caption (Form 416D): court, debtor, plaintiff and defendant on the left; case number, chapter and adversary
// number on the right; the document's title below the caption.
// ---------------------------------------------------------------------------

#let party-groups(meta) = {
  let g = ()
  let debtor-label = if meta.debtors.len() > 1 { "Debtors." } else { "Debtor." }
  g.push(("In re:",) + meta.debtors + (debtor-label,))
  for p in meta.caption.plaintiffs { g.push(p.names + (p.designation,)) }
  g.push(("v.",))
  for d in meta.caption.defendants { g.push(d.names + (d.designation,)) }
  g
}

#let caption(meta) = {
  let groups = party-groups(meta)
  let adv = if meta.adv_number == "" { "______________" } else { meta.adv_number }
  grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.25in,
    block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 10pt), {
      stack(dir: ttb, spacing: 12pt, ..groups.map(g => line-stack(g)))
    }),
    block(inset: (left: 0.1in, top: 0pt), line-stack((
      "Case No. " + meta.case_number,
      "Chapter " + meta.chapter,
      "Adv. Proc. No. " + adv,
    ))),
  )
}

#let cover(meta) = {
  stack(dir: ttb, spacing: single-leading, ..court-name.map(line => align(center, text(weight: "bold", line))))
  v(18pt)
  caption(meta)
  v(18pt)
  align(center, text(weight: "bold", inl(meta.brief_title)))
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Body: headings, numbered paragraphs, lettered prayer items, tables, block quotations
// ---------------------------------------------------------------------------

/// A heading is kept with the block after it, so it never ends a page. Level 1 is a centered section in capitals;
/// level 2 a bold sub-heading; level 3 bold italic.
#let heading-block(level, s) = block(width: text-width, sticky: true, above: 12pt, below: 12pt, {
  if level == 1 {
    align(center, text(weight: "bold", upper(s)))
  } else if level == 2 {
    text(weight: "bold", inl(s))
  } else {
    text(weight: "bold", style: "italic", inl(s))
  }
})

/// The body in document order. Numbered paragraphs continue from the consent paragraph (Fed. R. Civ. P. 10(b)).
#let body-content(body, meta) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let n = 0
  let out = []

  // The first two numbered paragraphs are required by Fed. R. Bankr. P. 7008 and come from the frontmatter, so a sample
  // cannot omit them: (1) the allegation of jurisdiction names the case (name, number, Code chapter), the district and the
  // division; (2) the statement whether the pleader consents to final orders by the bankruptcy court.
  assert("division" in meta, message: "iasb-adversary-complaint: frontmatter needs division (FRBP 7008)")
  assert("final_orders_consent" in meta, message: "iasb-adversary-complaint: frontmatter needs final_orders_consent (FRBP 7008)")
  let case-reference = "This adversary proceeding arises in and relates to the Chapter " + meta.chapter + " case of " + meta.debtors.join(", ") + ", Case No. " + meta.case_number + ", pending in the United States Bankruptcy Court for the Southern District of Iowa, " + meta.division + " Division."
  for sentence in (case-reference, meta.final_orders_consent) {
    n += 1
    out += block(width: text-width, {
      set par(leading: body-leading, first-line-indent: 0pt, justify: false)
      h(para-indent)
      [#(n).#h(0.25in)]
      inl(sentence)
    })
  }

  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      let level = t.match(regex("^(#+)")).captures.at(0).len()
      out += heading-block(level, t.replace(regex("^#+[ \t]*"), ""))
    } else if t.starts-with("|") {
      // A table is single-spaced, indented to the paragraph text, and not numbered.
      out += block(width: text-width, breakable: false, {
        set par(leading: single-leading, spacing: 0pt, justify: false)
        pad(left: para-indent, cmarker.render(t, raw-typst: false, smart-punctuation: true))
      })
    } else if t.starts-with("- ") {
      // A list is lettered A., B., C. (the prayer for relief). Each item starts with "- "; the list may break across pages.
      let items = t.split("\n").map(l => l.trim()).filter(l => l.starts-with("- ")).map(l => l.slice(2))
      for (i, item) in items.enumerate() {
        out += block(width: text-width, {
          set par(leading: body-leading, first-line-indent: 0pt, justify: false)
          pad(left: para-indent, grid(
            columns: (0.4in, text-width - para-indent - 0.4in),
            [#numbering("A.", i + 1)],
            inl(item),
          ))
        })
      }
    } else if t.starts-with(">") {
      // A block quotation is single-spaced and indented on both sides.
      out += block(width: text-width, {
        set par(leading: single-leading, spacing: 0pt, justify: true)
        pad(left: 0.75in, right: 0.75in, top: 6pt, bottom: 12pt, inl(t.replace(regex("(?m)^>[ \t]?"), "")))
      })
    } else if t.starts-with("WHEREFORE") {
      // The prayer's lead-in is an unnumbered paragraph (Fed. R. Civ. P. 10(b) numbers the allegations only).
      out += block(width: text-width, {
        set par(leading: body-leading, first-line-indent: 0pt, justify: false)
        h(para-indent)
        inl(t)
      })
    } else {
      // A numbered paragraph.
      n += 1
      out += block(width: text-width, {
        set par(leading: body-leading, first-line-indent: 0pt, justify: false)
        h(para-indent)
        [#(n).#h(0.25in)]
        inl(t)
      })
    }
  }
  out
}

/// Signature block: the date, the firm, the signer's electronic signature (FRBP 9011(a)), and the counsel lines.
#let signature-block(meta) = block(width: text-width, breakable: false, {
  v(body-leading)
  grid(
    columns: (2.8in, 1fr),
    column-gutter: 0.2in,
    [Dated: #meta.date],
    line-stack((
      "Respectfully submitted,",
      "",
      ..meta.signature.firm,
      "",
      "By: /s/ " + meta.signature.signer,
      meta.signature.signer,
      ..meta.signature.lines,
    )),
  )
})

/// Counsel's signature block at the end of the pleading; the caption carries no counsel block (Form 416D).
#let iasb-adversary-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, first-line-indent: 0pt, justify: false)

  cover(meta)

  if "lead_in" in meta {
    block(width: text-width, {
      set par(leading: body-leading, first-line-indent: 0pt, justify: false)
      h(para-indent)
      inl(meta.lead_in)
    })
  }

  body-content(body, meta)
  signature-block(meta)
}
