// U.S. Bankruptcy Court, Southern District of California (casb): adversary complaint.
//
// Rule-driven and content-agnostic. Requirement IDs (CASB-...) refer to ../README.md, which quotes
// the rule text. No case-specific text, no coordinates measured off the exemplar, no forced line
// breaks. Every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // CASB-FORM-002: vendored in fonts/; see README.md (font is a choice, not a rule text)
#let type-size = 12pt                   // CASB-FORM-002: 12 point; the rule text is not verified, see README.md
#let pitch = 24pt                       // CASB-FORM-003: double spacing; the numbered lines are this pitch
#let lines-per-page = 27                // CASB-FORM-003: pleading paper, 28 numbered lines (exemplars)
#let page-w = 8.5in                     // CASB-FORM-001 (FRBP 9004(a), legibility; 8 1/2 x 11 paper)
#let page-h = 11in
#let top-margin = 72pt                  // the numbered lines start at the top margin
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 72 pt: holds the footer
#let left-margin = 1.5in                // room for the line numbers and the rules
#let right-margin = 1in
#let text-width = page-w - left-margin - right-margin
#let body-leading = 1.35em              // double spacing: 1.35em leading gives a 24 pt baseline pitch at 12 pt (measured, README.md)
#let single-leading = 0.5em             // single spacing for counsel, caption and signature
#let para-indent = 0.5in                // first-line indent of numbered allegations
#let caption-left = 3.2in               // width of the party column of the caption
#let counsel-lines = 7                  // the court title starts after at least this many numbered lines

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("casb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Fill whole numbered lines: the block is rounded up to a multiple of `pitch`, so whatever follows
/// it stays on the grid of numbered lines.
#let on-grid(c) = context {
  let h = measure(width: text-width, c).height
  block(width: text-width, height: calc.ceil(h / pitch) * pitch, above: 0pt, below: 0pt, c)
}

/// A heading: whole numbered lines (one or more), kept with the paragraph after it.
#let heading-block(c) = block(width: text-width, sticky: true, above: 0pt, below: 0pt, on-grid(c))

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Numbers 1 to 28 down the left margin, one per numbered line.
#let line-numbers() = {
  for i in range(1, lines-per-page + 1) {
    place(top + left, dx: 0pt, dy: top-margin + (i - 1) * pitch,
      block(width: left-margin - 0.5in, height: pitch,
        align(right, text(size: type-size, str(i)))))
  }
}

/// The pleading rules: a double rule at the text's left edge, a single rule at its right.
#let pleading-rules() = {
  place(top + left, dx: left-margin - 0.2in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: left-margin - 0.16in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: page-w - right-margin + 0.1in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
}

/// Footer: page number, then the paper's title and the case number, each centered on its own line
/// (the title is too long for a row shared with the case number at this size).
#let footer-block(title, case-number) = place(
  top + left,
  dx: left-margin,
  dy: top-margin + lines-per-page * pitch + 4pt,
  block(width: text-width, stack(
    dir: ttb,
    spacing: 2pt,
    align(center, text(size: 10pt, context counter(page).display())),
    align(center, text(size: 9pt, upper(title))),
    align(center, text(size: 9pt, [CASE NO. #case-number])),
  )),
)

// ---------------------------------------------------------------------------
// Cover: counsel, court title, caption (FRBP 7010 and Form 416; Fed. R. Civ. P. 10(a))
// ---------------------------------------------------------------------------

/// One single-spaced line per item: each item is a block, and the stack keeps the single pitch.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

/// Counsel identification, upper left, from line 1. More counsel lines push the court title down.
#let counsel-block(meta) = context {
  let h = measure(width: text-width, line-stack(meta.counsel)).height
  block(width: text-width, height: calc.max(counsel-lines, calc.ceil(h / pitch)) * pitch,
    line-stack(meta.counsel))
}

#let court-title(meta) = {
  on-grid(align(center, text(weight: "bold", "UNITED STATES BANKRUPTCY COURT")))
  on-grid(align(center, text(weight: "bold", "SOUTHERN DISTRICT OF CALIFORNIA")))
  if "division" in meta {
    on-grid(align(center, text(weight: "bold", upper(meta.division))))
  }
}

/// A list of parties: each side's names, then its designation; "vs." between the sides.
#let party-rows(sides) = {
  let rows = ()
  for (k, p) in sides.enumerate() {
    if k > 0 { rows.push("vs.") }
    rows += p.names + (p.designation,)
  }
  rows
}

#let caption(meta) = on-grid(grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.2in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), {
    // The debtor ("In re"), then the adversary parties: each side is its names, then its designation.
    set par(leading: single-leading, spacing: 0pt, justify: false)
    line-stack(("In re",) + party-rows(meta.in_re))
    v(pitch * 0.5)
    line-stack(party-rows(meta.caption))
  }),
  block(inset: (left: 0.1in), {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    line-stack(("Case No. " + meta.case_number, "Chapter " + meta.chapter))
    if "adv_number" in meta {
      v(pitch * 0.5)
      line-stack(("Adv. Proc. No. " + meta.adv_number,))
    }
    v(pitch * 0.5)
    [#text(weight: "bold", inl(meta.brief_title))]
    if "judge" in meta {
      v(pitch * 0.5)
      inl(meta.judge)
    }
  }),
))

#let cover(meta) = {
  counsel-block(meta)
  court-title(meta)
  v(pitch)
  caption(meta)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

#let signature-block(meta) = on-grid(grid(
  columns: (2.6in, 1fr),
  column-gutter: 0.2in,
  [Dated: #meta.date],
  {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    [Respectfully submitted,]
    v(pitch * 0.5)
    line-stack(meta.signature.firm)
    v(pitch * 0.5)
    line-stack(("By: /s/ " + meta.signature.signer, meta.signature.signer) + meta.signature.lines)
  },
))

/// Numbered allegations. Each blank-line-separated chunk of markdown that is neither a heading nor a
/// list is one numbered paragraph (Fed. R. Civ. P. 10(b), applied by FRBP 7010). Headings and lists
/// are rendered unnumbered. Numbering is applied per chunk, not with a `show par` rule: a show rule
/// that re-wraps paragraph content recurses without end in typst 0.15.
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // A heading is kept in one unbreakable block with the chunk after it, so it never ends a page.
  let pending = []
  let has-pending = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Items are lettered (a), (b), ... by the enum setting; items are spaced by body-leading, so each
      // item fills whole lines. A list may break across pages: only a heading in front of it is kept
      // with its first line.
      let items = {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      }
      if has-pending {
        block(breakable: false, width: text-width, { pending; items })
      } else {
        items
      }
      pending = []
      has-pending = false
    } else {
      // A paragraph breaks across pages like any text; only a heading in front of it is kept with its first line.
      let piece = {
        para-counter.step()
        on-grid({ set par(leading: body-leading); context [#h(para-indent)#(para-counter.display()).#h(0.3in)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)] })
      }
      if has-pending {
        { pending; piece }   // headings are sticky; a paragraph longer than a page must be able to break
      } else {
        piece
      }
      pending = []
      has-pending = false
    }
  }
  if pending != [] { block(breakable: false, width: text-width, pending) }
}

#let casb-adversary-complaint(meta, body) = {
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    foreground: footer-block(meta.footer_title, meta.case_number),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 is a centered section; level 2 a centered bold sub-heading; level 3 bold, at the margin.
  show heading.where(level: 1): it => heading-block(align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => heading-block(align(center, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => heading-block(text(weight: "bold", it.body))

  cover(meta)

  // The unnumbered lead-in ("Plaintiffs ... allege as follows:") follows the caption on the same page.
  if "lead_in" in meta {
    on-grid({
      set par(leading: body-leading)
      h(para-indent)
      inl(meta.lead_in)
    })
  }

  // Body: numbered allegations; markdown lists become (a), (b), ...
  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  allegations(body, para-counter)

  // Unnumbered closing paragraph (the prayer), then the date and signature.
  if "closing" in meta {
    on-grid({
      set par(leading: body-leading)
      h(para-indent)
      inl(meta.closing)
    })
  }
  signature-block(meta)
}
