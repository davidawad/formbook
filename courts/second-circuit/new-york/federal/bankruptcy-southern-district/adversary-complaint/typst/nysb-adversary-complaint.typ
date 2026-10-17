// Adversary complaint for the U.S. Bankruptcy Court, S.D.N.Y. (nysb).
// Rules: Fed. R. Bankr. P. 7010 (Fed. R. Civ. P. 10 applies; the caption substantially conforms to Official Form 416D);
// Fed. R. Civ. P. 10(a) (caption) and 10(b) (numbered paragraphs); Fed. R. Bankr. P. 9004(a) (legible) and (b) (caption);
// Local Bankruptcy Rule 9004-1(a) (typed, not bound or stapled; attorney name, office address and telephone on the face).
// See ../README.md for the rule text, the verification date and the measured exemplar values.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule, the exemplar, or a stated convention; see README.md)
// ---------------------------------------------------------------------------
#let court-name = ("UNITED STATES BANKRUPTCY COURT", "SOUTHERN DISTRICT OF NEW YORK")  // Form 416D; Fed. R. Bankr. P. 9004(b)
#let font-family = "Liberation Serif"        // Times New Roman substitute per docs/FONTS.md, vendored in fonts/; the exemplar is Times New Roman. No font rule in LBR 9004-1 (README.md)
#let type-size = 12pt                   // exemplar: 12 pt (measured); LBR 9004-1 is adapted from Civil Rule 11.1 (README.md)
#let body-leading = 1.645em             // double spacing: Liberation Serif line box 0.655em + 1.645em = 2.3em = 27.6 pt, the exemplar's pitch
#let single-leading = 0.5em             // single spacing for counsel, caption, footnotes and signature (about 13.8 pt)
#let margin = 1in                       // exemplar margins: 72 pt on all sides (measured)
#let page-w = 8.5in
#let text-width = page-w - 2 * margin
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let number-gap = 0.3in                 // gap between a paragraph number (or heading letter) and its text
#let caption-left = 3.35in              // width of the party column of the caption (Form 416D: parties left, case data right)

// A block's `below` must be one full leading: typst puts no leading after a block's last line, so without it the next
// block starts one line too high and overlaps. Every block that stands in the flow of the body uses this spacing.
#let gap = body-leading

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nysb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, smart quotes, and the like).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

/// Heading letters: level 2 is a lettered sub-heading (A., B., ...); other levels are unnumbered.
#let heading-numbering(..nums) = {
  let pos = nums.pos()
  if pos.len() == 2 { numbering("A.", pos.last()) } else { none }
}

// ---------------------------------------------------------------------------
// Cover: counsel (LBR 9004-1(a)(4)), court name, caption (Form 416D), title
// ---------------------------------------------------------------------------

#let counsel-block(meta) = {
  stack(dir: ttb, spacing: gap * 0.5, ..meta.counsel.map(g => line-stack(g)))
  if "counsel_for" in meta {
    v(single-leading)
    set par(leading: single-leading, spacing: 0pt)
    text(style: "italic", inl(meta.counsel_for))
  }
}

#let court-title() = {
  set par(leading: single-leading, spacing: 0pt)
  align(center, stack(dir: ttb, spacing: single-leading,
    text(weight: "bold", court-name.at(0)),
    text(weight: "bold", court-name.at(1))))
}

/// One party: its names, then its designation, set against the right edge of the column. An optional `note`
/// (the debtors' tax-identification footnote, as in the exemplar) is a footnote on the last name.
#let party(p) = {
  let names = p.names.map(n => inl(n))
  if "note" in p and p.note != none {
    let k = names.len() - 1
    names = names.slice(0, k) + ((names.at(k) + footnote(inl(p.note))),)
  }
  stack(dir: ttb, spacing: single-leading, ..(names + (align(right, inl(p.designation)),)))
}

#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.2in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 0.15in, bottom: 0.15in), {
    // The debtors, then the plaintiffs, then "against", then the defendants (Form 416D).
    let items = (party(meta.caption.debtors),)
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { items.push(align(center, [against])) }
      items.push(party(p))
    }
    stack(dir: ttb, spacing: gap * 0.5, ..items)
  }),
  block(inset: (left: 0.15in), {
    set par(leading: single-leading, spacing: 0pt)
    stack(dir: ttb, spacing: gap,
      [Chapter #meta.chapter],
      stack(dir: ttb, spacing: single-leading,
        [Case No. #meta.case_number],
        if "jointly_administered" in meta and meta.jointly_administered { [(Jointly Administered)] }),
      [Adv. Pro. No. #meta.adv_proc_no])
  }),
)

#let cover(meta) = {
  counsel-block(meta)
  v(gap)
  court-title()
  v(gap)
  caption(meta)
  v(gap)
  align(center, text(weight: "bold", inl(meta.title)))
  pagebreak()
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(width: text-width, breakable: false, {
  v(gap)
  grid(
    columns: (2.8in, 1fr),
    column-gutter: 0.2in,
    [Dated: #meta.date],
    {
      set par(leading: single-leading, spacing: 0pt)
      line-stack(meta.signature.firm)
      v(gap * 0.5)
      line-stack(("By: /s/ " + meta.signature.signer, meta.signature.signer) + meta.signature.lines)
    },
  )
})

/// The items of a markdown list chunk, one string per item (a continuation line belongs to the item above it).
#let list-items(t) = {
  let items = ()
  for line in t.split("\n") {
    if items.len() == 0 or line.match(regex("^\\s*(\\d+\\.|[-*+])\\s")) != none {
      items.push(line)
    } else {
      let k = items.len() - 1
      items.at(k) = items.at(k) + "\n" + line
    }
  }
  items
}

/// Body: numbered paragraphs (Fed. R. Civ. P. 10(b)). Each blank-line-separated chunk of markdown that is neither a
/// heading nor a list is one numbered paragraph; a chunk marked "^" is not numbered; headings and lists are not numbered;
/// footnote definitions are not paragraphs. Numbers are a plain count in the loop, so no `context` is needed for them.
/// The last item of the last list (or the last paragraph) sticks to the
/// signature block, so a signature never stands alone on a page.
#let allegations(body, tail) = {
  let n = 0
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "" and not c.trim().starts-with("[^"))
  let doc = []
  // A heading is kept in one unbreakable block with the chunk after it, so it never ends a page.
  let pending = []
  let last = chunks.len() - 1
  for (i, c) in chunks.enumerate() {
    let t = c.trim()
    let out = none
    if t.starts-with("#") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      continue
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list may break across pages. Its items keep their markdown numbers (cmarker honours a start number), so the
      // last item can be set on its own, sticking to the signature, without renumbering.
      let items = list-items(t)
      let k = items.len() - 1
      if k > 0 {
        doc += block(width: text-width, below: gap, {
          set par(leading: gap, spacing: 0pt)
          if pending != [] { pending }
          cmarker.render(items.slice(0, k).join("\n"), raw-typst: false, smart-punctuation: true, h1-level: 1)
        })
        pending = []
      }
      out = block(width: text-width, below: gap, {
        set par(leading: gap, spacing: 0pt)
        cmarker.render(items.at(k), raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
    } else if t.starts-with("^") {
      out = block(width: text-width, below: gap, {
        set par(leading: gap, spacing: 0pt, first-line-indent: 0pt, justify: false)
        [#h(para-indent)#cmarker.render(t.slice(1).trim(), raw-typst: false, smart-punctuation: true, h1-level: 1)]
      })
    } else {
      n += 1
      out = block(width: text-width, below: gap, {
        set par(leading: gap, spacing: 0pt, first-line-indent: 0pt, justify: false)
        [#h(para-indent)#n.#h(number-gap)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)]
      })
    }
    if pending != [] {
      out = block(width: text-width, below: gap, { pending; out })
      pending = []
    }
    // The last chunk sticks to the signature: it may break across pages, but it never ends a page before the signature.
    if i == last and tail != none {
      out = block(width: text-width, sticky: true, below: 0pt, out)
    }
    doc += out
  }
  if pending != [] { doc += block(breakable: false, width: text-width, below: gap, pending) }
  if tail != none { doc += tail }
  doc
}

#let nysb-adversary-complaint(meta, body) = {
  // The cover carries no footer; the body is numbered from 1 after it.
  set page(paper: "us-letter", margin: margin)
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: gap, spacing: 0pt, first-line-indent: 0pt, justify: false)
  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in)
  set list(indent: 0.5in, body-indent: 0.4in)
  set heading(numbering: heading-numbering)

  // Headings: level 1 is a centered bold section; level 2 a bold lettered sub-heading, numbered by the template.
  show heading.where(level: 1): it => block(width: text-width, sticky: true, above: 0pt, below: gap,
    align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: text-width, sticky: true, above: 0pt, below: gap, {
    context text(weight: "bold", numbering(it.numbering, ..counter(heading).at(it.location())))
    h(number-gap)
    text(weight: "bold", it.body)
  })

  cover(meta)

  set page(
    numbering: "1",
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  counter(page).update(1)
  allegations(body, signature-block(meta))
}
