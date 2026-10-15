// Adversary complaint for the U.S. Bankruptcy Court, Eastern District of California (caeb).
// Rules: FRBP 7010 (FRCP 10 applies; the caption must substantially conform to Official Form 416A), FRCP 10(a)-(b),
// FRBP 9004(a)-(b) (caption), LBR 9004-1 (counsel block, signatures), LBR 9004-2 (paper, numbered and double-spaced
// lines, 12-14 point type, margins, clerk's stamp space, page numbers, page total), LBR 7038-1(b) (jury demand
// immediately after the title). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif"   // LBR 9004-2(a)(4) names Times New Roman; Liberation Serif is its metric-compatible substitute (docs/FONTS.md)
#let type-size = 13pt                   // LBR 9004-2(a)(4): not less than 12 and not more than 14 point
#let pitch = 24pt                       // LBR 9004-2(a)(2), (b)(1): numbered lines, double spaced
#let lines-per-page = 28                // the pleading form used by the exemplar and by CAND; the LBR sets no count
#let page-w = 8.5in                     // LBR 9004-2(a)(1): white letter-size paper
#let page-h = 11in
#let top-margin = 72pt                  // LBR 9004-2(b)(2): every margin not less than one-half inch
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 48 pt: holds the page number
#let left-margin = 1.5in                // room for the line numbers and the pleading rules
#let right-margin = 0.75in
#let text-width = page-w - left-margin - right-margin
#let body-leading = pitch - 0.65 * type-size   // baseline pitch of 24 pt (measured in README.md)
#let single-leading = 0.45em            // counsel, caption, quotations and signature are single spaced (LBR 9004-2(b)(1))
#let para-indent = 0.5in
#let caption-left = 3.1in               // width of the party column of the caption
#let counsel-width = 4.0in              // keeps the counsel block clear of the clerk's stamp space (LBR 9004-2(b)(3))
#let counsel-lines = 7                  // the court title starts on line 8 unless counsel needs more room

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("caeb-adversary-complaint: the sample must start with a YAML frontmatter block") }
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

/// A heading: kept with the paragraph after it, so a heading never ends a page.
#let heading-block(c) = block(width: text-width, sticky: true, above: 0pt, below: 0pt, on-grid(c))

/// A section sign never ends a line: "§ 9-406" is one unbreakable unit.
#let nbsp-sections(s) = s.replace(regex("§ "), "§\u{00A0}")

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

/// Bottom center page number (LBR 9004-2(c)(3)); page 1 is the page bearing the caption.
#let page-number() = place(
  top + left,
  dx: left-margin,
  dy: top-margin + lines-per-page * pitch + 8pt,
  block(width: text-width, align(center, context counter(page).display())),
)

/// Upper left corner of the first page: the total number of pages (LBR 9004-2(c)(4)).
#let page-total() = context if counter(page).get().first() == 1 {
  place(top + left, dx: left-margin, dy: 0.5in,
    text(size: type-size, [Page total: #counter(page).final().first()]))
}

// ---------------------------------------------------------------------------
// Cover: counsel, court title, caption, title of the paper
// ---------------------------------------------------------------------------

/// One single-spaced line per item: each item is a block, and the stack keeps the single pitch.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

#let counsel-block(meta) = context {
  // Lines 1-7 at least; more counsel lines push the court title down (LBR 9004-1(b) puts counsel in the upper left).
  let h = measure(width: counsel-width, line-stack(meta.counsel)).height
  // The 12 pt of slack keeps the court title off the last counsel line.
  block(width: counsel-width, height: calc.max(counsel-lines, calc.ceil((h + 12pt) / pitch)) * pitch,
    line-stack(meta.counsel))
}

#let court-title(meta) = {
  for line in meta.court {
    on-grid(align(center, text(weight: "bold", upper(line))))
  }
}

#let caption(meta) = on-grid(grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.2in,
  {
    // The debtor(s) above the party box (FRBP 9004(b)(2)): "In re:", the debtor names and the role.
    block(width: caption-left, inset: (right: 10pt, bottom: 10pt), line-stack(meta.caption.debtors))
    // The parties (FRCP 10(a): the title of the complaint names all the parties); "v." between them.
    block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), {
      let rows = ()
      for (k, p) in meta.caption.parties.enumerate() {
        if k > 0 { rows.push("v.") }
        rows += p.names + (p.designation,)
      }
      line-stack(rows)
    })
  },
  block(inset: (left: 0.1in), {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    // Case number, chapter, adversary number (FRBP 9004(b)(3)).
    line-stack(meta.caption.case-lines)
    v(pitch * 0.5)
    line-stack(meta.caption.chapter-lines)
    v(pitch * 0.5)
    line-stack(("Adv. Proc. No.: " + meta.caption.adversary,))
    if "dcn" in meta.caption and meta.caption.dcn != none {
      v(pitch * 0.5)
      line-stack(("DCN: " + meta.caption.dcn,))
    }
    v(pitch * 0.5)
    text(weight: "bold", upper(inl(meta.brief_title)))
    // The jury demand follows the title of the complaint (LBR 7038-1(b)).
    if "jury_demand" in meta and meta.jury_demand {
      v(pitch * 0.5)
      text(weight: "bold", "DEMAND FOR JURY TRIAL")
    }
  }),
))

#let cover(meta) = {
  counsel-block(meta)
  court-title(meta)
  v(pitch)
  caption(meta)
  pagebreak()
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

#let signature-block(date, sig) = on-grid(grid(
  columns: (2.6in, 1fr),
  column-gutter: 0.2in,
  [Dated: #date],
  {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    [Respectfully submitted,]
    v(pitch * 0.5)
    line-stack(sig.firm)
    v(pitch * 0.5)
    line-stack(("By: /s/ " + sig.signer, sig.signer) + sig.lines)
  },
))

/// Numbered paragraphs. Each blank-line-separated chunk of markdown that is neither a heading nor a
/// list is one numbered paragraph (FRCP 10(b)). Headings and lists are rendered unnumbered.
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph
/// content recurses without end in typst 0.15.
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // A heading is kept in one unbreakable block with the chunk after it, so it never ends a page.
  let pending = []
  let has-pending = false
  for c in chunks {
    let t = nbsp-sections(c.trim())
    if t.starts-with("#") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list may break across pages; only a heading in front of it is kept with its first line.
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
    } else if t.starts-with("^") {
      // An unnumbered paragraph (a lead-in such as "WHEREFORE"): the sample marks it with a leading "^".
      let piece = on-grid({
        set par(leading: body-leading)
        h(para-indent)
        cmarker.render(t.replace(regex("^\\^[ \\t]?"), ""), raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
      if has-pending {
        block(breakable: false, width: text-width, { pending; piece })
      } else {
        piece
      }
      pending = []
      has-pending = false
    } else if t.starts-with(">") {
      // A quotation is single spaced (LBR 9004-2(b)(1)); it stays on the numbered-line grid.
      let quote-piece = on-grid({
        set par(leading: single-leading)
        pad(left: 0.5in, right: 0.5in, cmarker.render(t.replace(regex("^>[ \\t]?"), ""), raw-typst: false, smart-punctuation: true))
      })
      if has-pending {
        block(breakable: false, width: text-width, { pending; quote-piece })
      } else {
        quote-piece
      }
      pending = []
      has-pending = false
    } else {
      // A paragraph breaks across pages like any text; only a heading in front of it is kept with its first line.
      let piece = {
        para-counter.step()
        on-grid({
          set par(leading: body-leading)
          context [#h(para-indent)#(para-counter.display()).#h(0.3in)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)]
        })
      }
      if has-pending {
        block(breakable: false, width: text-width, { pending; piece })
      } else {
        piece
      }
      pending = []
      has-pending = false
    }
  }
  if pending != [] { block(breakable: false, width: text-width, pending) }
}

#let caeb-adversary-complaint(meta, body) = {
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    foreground: {
      page-number()
      page-total()
    },
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 is a centered section; level 2 a bold centered sub-heading; level 3 bold italic.
  show heading.where(level: 1): it => heading-block(align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => heading-block(align(center, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => heading-block(text(weight: "bold", style: "italic", it.body))

  cover(meta)

  if "lead_in" in meta {
    on-grid({
      set par(leading: body-leading)
      h(para-indent)
      inl(meta.lead_in)
    })
  }

  // Body: numbered paragraphs (FRCP 10(b)); markdown lists become (a), (b), ...
  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  allegations(body, para-counter)

  // The signature blocks stay together, so the signature never stands alone on a page.
  if "signature" in meta {
    block(breakable: false, width: text-width, {
      v(pitch)
      for sig in meta.signature {
        signature-block(meta.date, sig)
        v(pitch)
      }
    })
  }
}
