// Adversary complaint for the United States Bankruptcy Court, District of Guam (gub).
// Rules: GNLR 5.1 (paper, page numbers at the bottom, double spacing, counsel block upper left, court title
// at least 3 inches from the top, right-hand case information); Fed. R. Bankr. P. 7010 (caption per
// Official Form 416), 7008(a) (statement of consent to final orders), 9004(b) (caption contents), 9011(a)
// (signer's address and telephone). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // no point size or face is set by GNLR 5.1; a proportional serif, vendored in fonts/
#let type-size = 12pt                   // the exemplar is 12 pt Times; EB Garamond at 12 pt is the same size on the grid
#let pitch = 24pt                       // GNLR 5.1(a): double-spaced; the numbered lines are this pitch
#let lines-per-page = 28                // the exemplar's pleading form: 28 numbered lines (a convention, not a GNLR rule)
#let page-w = 8.5in                     // GNLR 5.1(a): 8 1/2 by 11 inch paper
#let page-h = 11in
#let top-margin = 72pt                  // the numbered lines start at the top margin
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 48 pt: holds the page number
#let left-margin = 1.5in                // room for the line numbers and the rules
#let right-margin = 0.75in
#let text-width = page-w - left-margin - right-margin
#let body-leading = 1.35em              // double spacing: 1.35em leading on a 0.65em line box gives a 24 pt pitch at 12 pt
#let single-leading = 0.5em             // single spacing for counsel, caption and signature
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let caption-left = 3.2in               // width of the party column of the caption; left of the page's centre (GNLR 5.1(c)(1))
#let counsel-lines = 8                  // GNLR 5.1(b): the court title starts at least 3 in from the top (line 9 here)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("gub-adversary-complaint: the sample must start with a YAML frontmatter block") }
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

/// A heading: one numbered line, kept with the paragraph after it (a heading never ends a page).
#let heading-line(c) = block(width: text-width, height: pitch, above: 0pt, below: 0pt, sticky: true, context {
  assert(measure(width: text-width, c).height <= pitch, message: "gub-adversary-complaint: a heading must fit on one numbered line")
  c
})

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Numbers 1 to 28 down the left margin, one per numbered line.
#let line-numbers() = {
  for i in range(1, lines-per-page + 1) {
    place(top + left, dx: 0pt, dy: top-margin + (i - 1) * pitch,
      block(width: left-margin - 0.42in, height: pitch,
        align(right, text(size: type-size, str(i)))))
  }
}

/// The pleading rules: a double rule at the text's left edge, a single rule at its right.
#let pleading-rules() = {
  place(top + left, dx: left-margin - 0.2in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: left-margin - 0.16in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: page-w - right-margin + 0.1in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
}

/// GNLR 5.1(a): all pages numbered consecutively at the bottom; the paper's title under the number.
#let footer-block(title) = place(
  top + left,
  dx: left-margin,
  dy: top-margin + lines-per-page * pitch + 6pt,
  block(width: text-width, {
    set text(size: 10pt)
    align(center, context counter(page).display("1"))
    v(4pt)
    align(left, upper(title))
  }),
)

// ---------------------------------------------------------------------------
// Cover: counsel (upper left), court title, caption, title of the paper
// ---------------------------------------------------------------------------

/// One single-spaced line per item: each item is a block, and the stack keeps the single pitch.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

/// Counsel identification, upper left (GNLR 5.1(c)(1)). The block occupies at least `counsel-lines` lines,
/// so the court title starts at or below the 3-inch line of GNLR 5.1(b).
#let counsel-block(meta) = context {
  let h = measure(width: text-width, line-stack(meta.counsel)).height
  assert(h <= counsel-lines * pitch, message: "gub-adversary-complaint: the counsel block must end above the court title (GNLR 5.1(b))")
  block(width: text-width, height: counsel-lines * pitch, line-stack(meta.counsel))
}

/// GNLR 5.1(b): the court title, centred. Lines are fixed; a court title is not case-specific.
#let court-title() = {
  on-grid(align(center, text(weight: "bold", "IN THE DISTRICT COURT OF GUAM")))
  on-grid(align(center, text(weight: "bold", "TERRITORY OF GUAM")))
  on-grid(align(center, text(weight: "bold", "BANKRUPTCY DIVISION")))
}

/// The caption's party column: the debtor ("In re:"), then each party with "v." between the parties.
#let party-rows(caption) = {
  let rows = ()
  if "debtor" in caption {
    rows.push("In re:")
    rows += caption.debtor.names + (caption.debtor.designation,)
    rows.push(" ")
  }
  for (k, p) in caption.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names + (p.designation,)
  }
  rows
}

/// The right-hand case information (GNLR 5.1(c)(3)): case number, the designation "Adversary Proceeding",
/// the adversary number, and the title of the paper.
#let case-info(meta) = {
  let rows = ()
  if "chapter" in meta { rows.push(meta.chapter) }
  rows.push("Case No. " + meta.case_number)
  rows.push(" ")
  rows.push("Adversary Proceeding")
  rows.push("Adv. Proc. No. " + meta.adversary_number)
  line-stack(rows)
  v(pitch * 0.5)
  text(weight: "bold", inl(meta.brief_title))
  if "jury_demand" in meta and meta.jury_demand {
    v(pitch * 0.5)
    text(weight: "bold", "DEMAND FOR JURY TRIAL")
  }
}

#let caption(meta) = on-grid(grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.2in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), {
    line-stack(party-rows(meta.caption))
  }),
  block(inset: (left: 0.1in), {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    case-info(meta)
  }),
))

#let cover(meta) = {
  counsel-block(meta)
  court-title()
  v(pitch)
  caption(meta)
  pagebreak()
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

#let signature-block(meta) = on-grid(grid(
  columns: (2.6in, 1fr),
  column-gutter: 0.2in,
  [],
  {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    line-stack(meta.signature.firm)
    v(pitch * 0.5)
    line-stack(("/s/ " + meta.signature.signer, meta.signature.signer) + meta.signature.lines)
  },
))

/// Numbered paragraphs. Each blank-line-separated chunk of markdown that is neither a heading nor a
/// list is one numbered paragraph (Fed. R. Civ. P. 10(b), as applied by Fed. R. Bankr. P. 7010).
/// A chunk that starts with "§ " is unnumbered text (the lead-in of a prayer, the signing line).
/// Headings and lists are rendered unnumbered.
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph
/// content recurses without end in typst 0.15.
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // A heading is kept in one unbreakable block with the chunk after it, so it never ends a page.
  let pending = []
  let has-pending = false
  for c in chunks {
    let raw-t = c.trim()
    let marker = raw-t.match(regex("^§ "))
    let unnumbered = marker != none
    let t = if unnumbered { raw-t.slice(marker.end) } else { raw-t }
    if t.starts-with("#") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list may break across pages; only a heading in front of it is kept with its first line.
      // Items are spaced by body-leading, so each item fills whole lines; the trailing v() closes the last one.
      // Not wrapped in on-grid: a fixed-height block cannot break between pages, and a list must.
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
      // An unnumbered paragraph (such as a prayer's WHEREFORE) is kept with the chunk after it.
      let piece = if unnumbered {
        on-grid({ set par(leading: body-leading); context [#h(para-indent)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)] })
      } else {
        para-counter.step()
        on-grid({ set par(leading: body-leading); context [#h(para-indent)#(para-counter.display()).#h(0.3in)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)] })
      }
      if unnumbered {
        pending += piece
        has-pending = true
      } else {
        if has-pending {
          block(breakable: false, width: text-width, { pending; piece })
        } else {
          piece
        }
        pending = []
        has-pending = false
      }
    }
  }
  if pending != [] { block(breakable: false, width: text-width, pending) }
}

#let gub-adversary-complaint(meta, body) = {
  // Fed. R. Bankr. P. 7008(a): an adversary complaint must state whether the pleader consents to the entry
  // of final orders or judgment by the bankruptcy court. The check is on the text, so a sample without it fails.
  assert(body.contains("consent to the entry of final orders"),
    message: "gub-adversary-complaint: the complaint must state consent to the entry of final orders (Fed. R. Bankr. P. 7008(a))")

  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    foreground: footer-block(meta.footer_title),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 is a centred bold section; level 2 a centred bold sub-heading.
  show heading.where(level: 1): it => heading-line(align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => heading-line(align(center, text(size: type-size, weight: "bold", it.body)))

  cover(meta)

  if "lead_in" in meta {
    on-grid({
      set par(leading: body-leading)
      h(para-indent)
      inl(meta.lead_in)
    })
  }

  // Body: numbered paragraphs; markdown lists become (a), (b), ...
  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  allegations(body, para-counter)

  signature-block(meta)
}
