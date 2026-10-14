// Adversary complaint for the U.S. Bankruptcy Court, Western District of Texas (txwb).
// Rules: Fed. R. Bankr. P. 7001 (adversary proceeding), 7010 (Fed. R. Civ. P. 10 applies; caption per Form 416A/B/D),
// Fed. R. Civ. P. 10(b) (numbered paragraphs). Local rules: no format rule for this doc type was located (see ../README.md).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a stated convention; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // vendored in fonts/; the only font the build can use
#let type-size = 12pt                   // convention (FRBP 9004(a): legible; no point size in the rule)
#let margin = 1in                       // convention; the exemplar's margins are about one inch
#let body-leading = 1.35em              // double spacing (about 24 pt pitch at 12 pt)
#let single-leading = 0.5em
#let para-indent = 0.5in                // first-line indent of numbered paragraphs (Fed. R. Civ. P. 10(b))
#let caption-left = 3.4in               // width of the parties column of the caption
#let text-width = 8.5in - 2 * margin

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("txwb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names with *italics*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

#let footer-page-number() = context align(center, text(size: type-size, counter(page).display()))

// ---------------------------------------------------------------------------
// Caption: court title, parties (left), case numbers (right), title of the paper
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(leading: body-leading, spacing: body-leading)
  align(center, text(weight: "bold", [IN THE UNITED STATES BANKRUPTCY COURT]))
  align(center, text(weight: "bold", [FOR THE WESTERN DISTRICT OF TEXAS]))
  if "division" in meta and meta.division != none {
    align(center, text(weight: "bold", upper(meta.division) + [ DIVISION]))
  }
  v(body-leading)
}

#let caption(meta) = {
  let parties = ()
  // The debtor block (In re), then the adversary parties: each side's names, then its designation.
  parties.push(line-stack(("IN RE:", meta.debtor.name)))
  parties.push(block(inset: (left: 0.5in), line-stack(("Debtor.",))))
  parties.push(v(single-leading * 2))
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names + (p.designation,)
  }
  parties.push(line-stack(rows))
  let right = (
    "Case No. " + meta.debtor.case_number,
    meta.debtor.chapter,
  )
  block(width: text-width, grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.3in,
    block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), stack(dir: ttb, spacing: single-leading, ..parties)),
    block(inset: (left: 0.1in), {
      line-stack(right)
      v(body-leading)
      line-stack(("Adv. Pro. No. " + if "adversary_number" in meta and meta.adversary_number != "" { meta.adversary_number } else { "____________________" },))
    }),
  ))
  v(body-leading)
  align(center, text(weight: "bold", upper(meta.brief_title)))
  v(body-leading)
}

#let cover(meta) = {
  court-title(meta)
  caption(meta)
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs, lettered prayer items, headings
// ---------------------------------------------------------------------------

/// A heading is kept in one block with the chunk after it, so it never ends a page.
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let pending = []
  let has-pending = false
  let h1n = 0
  let h2n = 0
  for c in chunks {
    let t = c.trim()
    if t.starts-with("# ") {
      // Level 1: a centered section, numbered with roman numerals by the template.
      h1n += 1
      h2n = 0
      let txt = t.slice(2)
      let md = "# " + numbering("I.", h1n) + " " + txt
      pending += cmarker.render(md, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
    } else if t.starts-with("## ") {
      // Level 2: a bold sub-heading with a capital letter (A., B., ...).
      h2n += 1
      let txt = t.slice(3)
      pending += cmarker.render("## " + numbering("A.", h2n) + " " + txt, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
    } else if t.starts-with("### ") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Lists (prayer items): lettered (a), (b), ...; a list may break across pages.
      let items = {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      }
      if has-pending {
        { pending; items }
      } else {
        items
      }
      pending = []
      has-pending = false
    } else {
      para-counter.step()
      let piece = {
        set par(leading: body-leading)
        h(para-indent)
        context [#(para-counter.display()).#h(0.3in)]
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      }
      if has-pending {
        { pending; piece }
      } else {
        piece
      }
      pending = []
      has-pending = false
    }
  }
  if pending != [] { pending }
}

// ---------------------------------------------------------------------------
// Signature block
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(breakable: false, width: text-width, {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  grid(
    columns: (2.6in, 1fr),
    column-gutter: 0.2in,
    [Dated: #meta.date],
    {
      [Respectfully submitted,]
      v(body-leading)
      line-stack(meta.signature.firm)
      v(body-leading)
      for (k, g) in meta.signature.groups.enumerate() {
        if k > 0 {
          v(body-leading)
          [-AND-]
          v(body-leading)
        }
        // A group with a `signer` is signed: "/s/ Name", then the name and the lines under it.
        if "signer" in g {
          line-stack(("/s/ " + g.signer, g.signer) + g.lines)
        } else {
          line-stack(g.lines)
        }
      }
      v(body-leading)
      line-stack(meta.signature.role)
    },
  )
})

#let txwb-adversary-complaint(meta, body) = {
  let para-counter = counter("paragraph")

  set page(
    paper: "us-letter",
    margin: margin,
    footer: footer-page-number(),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)
  // Prayer items (markdown lists) are lettered (a), (b), ... as in the filed form.
  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in)

  // Headings: level 1 is a centered section (roman); level 2 a bold lettered sub-heading; level 3 bold italic.
  show heading.where(level: 1): it => block(width: text-width, sticky: true,
    align(center, text(size: type-size, weight: "bold", it.body)))
  show heading.where(level: 2): it => block(width: text-width, sticky: true,
    text(size: type-size, weight: "bold", it.body))
  show heading.where(level: 3): it => block(width: text-width, sticky: true,
    text(size: type-size, weight: "bold", style: "italic", it.body))

  cover(meta)
  // The opening paragraph of the pleading is unnumbered in the filed form.
  if "lead_in" in meta {
    block(width: text-width, { h(para-indent); inl(meta.lead_in) })
  }
  allegations(body, para-counter)
  v(body-leading)
  signature-block(meta)
}
