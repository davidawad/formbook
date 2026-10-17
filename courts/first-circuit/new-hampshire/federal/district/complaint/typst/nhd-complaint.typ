// Complaint for the U.S. District Court for the District of New Hampshire (nhd).
// Rules: LR 5.1(a) (8 1/2 x 11 paper, 12-point proportionally spaced type, one-inch margins, double spaced
// except quotations, page numbers at the bottom center); LR 5.1(b) (attorney identification in the
// signature section); LR 5.1(c) (caption, description of the filing, docket number); Fed. R. Civ. P. 8
// (short and plain statement), 10(a) (caption and title), 10(b) (numbered paragraphs, one set of
// circumstances each). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif"        // Times New Roman substitute per docs/FONTS.md, vendored in fonts/ (Times itself cannot be vendored)
#let type-size = 12pt                   // LR 5.1(a): proportionally spaced font, no less than 12 point
#let margin = 1in                       // LR 5.1(a): no less than one-inch margins
#let body-leading = 1.645em             // LR 5.1(a): double spaced = 2 x single (1.15em = 13.8 pt); Liberation Serif line box 0.655em, so 27.6 pt pitch
#let single-leading = 0.5em             // counsel, caption, signature: single spaced
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let text-width = 8.5in - 2 * margin
#let sig-indent = 3.25in                // signature block starts at the right half of the page

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nhd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Single-spaced lines (caption, counsel, signature). Plain text: no markdown in these fields.
#let lines(items) = {
  set par(leading: single-leading)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => [#i]))
}

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title() = align(center, stack(dir: ttb, spacing: single-leading,
  text(weight: "bold", [IN THE UNITED STATES DISTRICT COURT]),
  text(weight: "bold", [FOR THE DISTRICT OF NEW HAMPSHIRE]),
))

#let caption(meta) = {
  // Party names and designations, one per line; "v." between the parties.
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names + (p.designation,)
  }
  grid(
    columns: (3.4in, 1fr),
    column-gutter: 0.3in,
    lines(rows),
    block(width: 100%, {
      // The case number sits beside the party block, as the filed caption does.
      v(body-leading * 1.5)
      lines(
        if "jury_demand" in meta and meta.jury_demand {
          (meta.case_number, text(weight: "bold", [JURY TRIAL DEMANDED]))
        } else {
          (meta.case_number,)
        },
      )
    }),
  )
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (Fed. R. Civ. P. 10(b)), headings, lettered lists
// ---------------------------------------------------------------------------

/// Numbered paragraphs. Each blank-line-separated chunk of markdown is one of:
///   `#`, `##`, `###` heading (kept with the chunk after it, so it never ends a page);
///   `1.` list (rendered as (a), (b), ... and not numbered as a paragraph);
///   `~ ` unnumbered paragraph (the jury demand and similar closing text);
///   anything else: one numbered paragraph.
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph
/// content recurses without end in typst 0.15.
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let pending = []
  let has-pending = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      // A heading is a typst heading with plain text (headings carry no markup in this contract).
      let m = t.match(regex("^(#+)[ \\t]+([\\s\\S]*)$"))
      pending += v(body-leading)
      pending += heading(level: m.captures.at(0).len(), [#m.captures.at(1)])
      has-pending = true
      continue
    }
    let piece = if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list may break across pages; the items are spaced by body-leading, like the text.
      block(width: 100%, spacing: 0pt, {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      })
    } else if t.starts-with("~ ") {
      block(width: 100%, spacing: 0pt, {
        set par(leading: body-leading)
        h(para-indent)
        cmarker.render(t.slice(2), raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      })
    } else {
      para-counter.step()
      block(width: 100%, spacing: 0pt, {
        set par(leading: body-leading)
        context [#h(para-indent)#(para-counter.display()).#h(0.3in)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)]
        v(body-leading)
      })
    }
    if has-pending {
      block(breakable: false, width: 100%, { pending; piece })
    } else {
      piece
    }
    pending = []
    has-pending = false
  }
  if pending != [] { block(breakable: false, width: 100%, pending) }
}

// ---------------------------------------------------------------------------
// Signature section (LR 5.1(b): name, address, telephone, e-mail and NH bar number)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = meta.signature
  let groups = (
    lines((sig.intro,)),
    if "party" in sig { lines(sig.party) } else { none },
    if "date" in sig { lines((sig.date,)) } else { none },
    lines(("/s/ " + sig.signer,)),
    ..sig.blocks.map(b => lines(b)),
  ).filter(g => g != none)
  block(width: 100%, breakable: false, {
    v(body-leading)
    pad(left: sig-indent, stack(dir: ttb, spacing: body-leading, ..groups))
  })
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let nhd-complaint(meta, body) = {
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: margin,
    footer: context align(center, text(size: type-size, counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in)

  // Headings: level 1 centered bold caps; level 2 centered bold; level 3 bold, flush left.
  show heading.where(level: 1): it => {
    align(center, text(size: type-size, weight: "bold", upper(it.body)))
    v(body-leading)
  }
  show heading.where(level: 2): it => {
    align(center, text(size: type-size, weight: "bold", it.body))
    v(body-leading)
  }
  show heading.where(level: 3): it => {
    text(size: type-size, weight: "bold", it.body)
    v(body-leading)
  }

  court-title()
  v(body-leading)
  caption(meta)
  v(body-leading)
  align(center, text(weight: "bold", upper(meta.title)))
  v(body-leading)

  if "lead_in" in meta {
    block(width: 100%, {
      set par(leading: body-leading)
      h(para-indent)
      cmarker.render(meta.lead_in, raw-typst: false, smart-punctuation: true, h1-level: 1)
    })
  }

  allegations(body, para-counter)

  signature-block(meta)
}
