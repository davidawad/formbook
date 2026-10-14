// Complaint for the U.S. District Court for the Northern District of West Virginia (wvnd).
// Rules: Fed. R. Civ. P. 8(a) (short and plain statement, jurisdiction, demand), 10(a) (caption: court,
// title, file number, Rule 7(a) designation), 10(b) (numbered paragraphs), 11(a) (signer's address,
// e-mail and telephone), 38(b) (jury demand, as body text); LR Gen P 5.03(c) (the "s/ name" signature).
// The local rules set no typography for complaints. The page is set to LR Civ P 7.02(a) (one-inch
// margins, 12 point, double spaced), the court's own filing standard for papers. See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"   // vendored in fonts/; LR Civ P 7.02(a) names Times New Roman, Courier New or Arial (README, known gaps)
#let type-size = 12pt              // LR Civ P 7.02(a): 12 point proportionally spaced type
#let page-w = 8.5in                // LR Civ P 7.02(a): 8 1/2 by 11 inch paper
#let page-h = 11in
#let margin = 1in                  // LR Civ P 7.02(a): one inch on all four sides
#let text-width = page-w - 2 * margin
#let body-leading = 1.35em         // double spacing: EB Garamond's line box is 0.65em, so 1.35em leading gives a 24 pt pitch at 12 pt (README)
#let single-leading = 0.5em        // single spacing for caption, signature and quotations: about 13.8 pt at 12 pt
#let para-indent = 0.5in           // first-line indent of numbered paragraphs
#let caption-left = 3.6in          // width of the party column of the caption
#let sig-left = 3.25in             // the signature block starts at the middle of the page

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wvnd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in italics, links). Smart punctuation keeps the author's characters.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Numbered paragraphs (Fed. R. Civ. P. 10(b)). The counter runs through the whole complaint.
#let allegation = counter("wvnd-allegation")

/// Split the body into blank-line-separated chunks: headings, lettered lists, numbered paragraphs.
#let chunks-of(body) = body.split("\n\n").map(c => c.trim()).filter(c => c != "")

/// Caption: court title, parties (left) and the civil action number (right), closed by a rule.
#let caption(meta) = {
  align(center)[
    UNITED STATES DISTRICT COURT \
    FOR THE NORTHERN DISTRICT OF WEST VIRGINIA
    #if "division" in meta [ \ #meta.division ]
  ]
  v(body-leading)
  grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.25in,
    {
      // the party column is single spaced; each entry is its own paragraph so it flows, never overlaps
      set par(leading: single-leading, spacing: single-leading)
      for side in meta.caption {
        for n in side.names {
          inl(n)
          parbreak()
        }
        pad(left: 1in, side.designation)
        parbreak()
        if side != meta.caption.last() {
          "v."
          parbreak()
        }
      }
    },
    align(bottom, {
      "Civil Action No. " + meta.case_number
      if "judge" in meta { linebreak() + "Judge: " + meta.judge }
    }),
  )
  v(0.5 * body-leading)
  line(length: 100%, stroke: 0.75pt)
  v(0.5 * body-leading)
}

/// The signature block, after the last paragraph (Fed. R. Civ. P. 11(a); LR Gen P 5.03(c)).
#let signature-block(sig) = {
  assert(sig.lines.any(l => l.contains("@")), message: "wvnd-complaint: the signature lines need an e-mail address (Fed. R. Civ. P. 11(a))")
  assert(sig.lines.any(l => l.match(regex("\\(?\\d{3}\\)?[ .-]?\\d{3}[ .-]?\\d{4}")) != none), message: "wvnd-complaint: the signature lines need a telephone number (Fed. R. Civ. P. 11(a))")
  block(sticky: true, above: body-leading, below: 0pt, [Dated: #sig.date])
  block(sticky: true, above: body-leading, below: 0pt, pad(left: sig-left, {
    sig.party
    linebreak()
    "By Counsel,"
    v(body-leading)
    "s/ " + sig.signer
    v(single-leading)
    for l in sig.lines { block(below: single-leading, inl(l)) }
  }))
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let wvnd-complaint(meta, body) = {
  assert("case_number" in meta, message: "wvnd-complaint: frontmatter needs case_number")
  assert("caption" in meta, message: "wvnd-complaint: frontmatter needs caption (a list of sides)")
  assert("title" in meta, message: "wvnd-complaint: frontmatter needs title (Fed. R. Civ. P. 10(a))")
  assert("signature" in meta, message: "wvnd-complaint: frontmatter needs signature")

  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(justify: false, leading: body-leading, spacing: body-leading, first-line-indent: 0pt)
  // quotations and block quotations are single spaced (LR Civ P 7.02(a))
  show quote: set par(leading: single-leading, spacing: single-leading)

  caption(meta)

  // Fed. R. Civ. P. 10(a): the title of the complaint names the paper.
  align(center, block(sticky: true, above: body-leading, below: body-leading, text(weight: "bold", meta.title)))

  if "lead_in" in meta {
    [#h(para-indent)#inl(meta.lead_in)]
    parbreak()
  }

  for c in chunks-of(body) {
    if c.starts-with("#") {
      let level = c.match(regex("^#+")).text.len()
      let t = c.replace(regex("^#+\\s*"), "")
      if level == 1 {
        block(width: 100%, sticky: true, above: body-leading, below: body-leading, align(center, text(weight: "bold", inl(t))))
      } else if level == 2 {
        block(width: 100%, sticky: true, above: body-leading, below: body-leading, align(center, text(weight: "bold", inl(t))))
      } else {
        block(width: 100%, sticky: true, above: body-leading, below: body-leading, text(weight: "bold", style: "italic", inl(t)))
      }
    } else if c.split("\n").all(l => l.match(regex("^[0-9]+\\. ")) != none) {
      // prayer and other lettered lists: (a), (b), ...
      let letters = "abcdefghijklmnopqrstuvwxyz"
      let items = c.split("\n")
      for (i, l) in items.enumerate() {
        let t = l.replace(regex("^[0-9]+\\. "), "")
        block(width: 100%, below: body-leading, pad(left: 0.5in, grid(
          columns: (0.5in, 1fr),
          "(" + letters.at(i) + ")",
          inl(t),
        )))
      }
    } else if c.starts-with("~ ") {
      // an unnumbered paragraph (the introduction, notes outside the allegations)
      [#h(para-indent)#inl(c.slice(2))]
      parbreak()
    } else {
      // a numbered paragraph (Fed. R. Civ. P. 10(b))
      allegation.step()
      context [#h(para-indent)#allegation.display().#h(0.25in)#inl(c)]
      parbreak()
    }
  }

  signature-block(meta.signature)
}
