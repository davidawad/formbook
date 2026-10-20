// Memorandum of law in support of a motion, for the U.S. Bankruptcy Court, S.D.N.Y. (nysb).
// Rules: Fed. R. Bankr. P. 9013 and Local Bankruptcy Rule 9013-1(a) (a motion states its rule and statutory basis and
// its authorities, in the motion or in a separate memorandum of law); Fed. R. Bankr. P. 9004(a) (legible) and (b) (caption,
// which follows Official Form 416D as the adversary caption); Local Bankruptcy Rule 9004-1(a) (typed, not bound or stapled;
// attorney name, office address and telephone on the face). Paragraph numbers follow the exemplar (a convention, not a rule).
// See ../README.md for the rule text, the verification date and the measured exemplar values.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule, the exemplar, or a stated convention; see README.md)
// ---------------------------------------------------------------------------
#let court-name = ("UNITED STATES BANKRUPTCY COURT", "SOUTHERN DISTRICT OF NEW YORK")  // Form 416D; Fed. R. Bankr. P. 9004(b)
#let font-family = ("Times New Roman", "Liberation Serif")        // Times New Roman substitute per docs/FONTS.md, vendored in fonts/; the exemplar is Times New Roman. No font rule in LBR 9004-1 (README.md)
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
  if m == none { panic("nysb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, smart quotes, and the like).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
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
      if k > 0 { items.push(align(center, [#meta.caption.at("separator", default: "against")])) }
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
  let notes = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim().starts-with("[^"))
  // A paragraph's footnote references ([^key]) are set by giving cmarker the definitions it uses, in the same chunk.
  let with-notes(t) = {
    let used = notes.filter(d => t.contains("[^" + d.trim().match(regex("^\\[\\^([^\\]]+)\\]")).captures.at(0) + "]"))
    if used.len() == 0 { t } else { t + "\n\n" + used.join("\n\n") }
  }
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
        [#h(para-indent)#n.#h(number-gap)#cmarker.render(with-notes(t), raw-typst: false, smart-punctuation: true, h1-level: 1)]
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

/// Whether a heading sits under the section "ARGUMENT": there its point headings are roman numerals (I., II.) and its
/// sub-headings letters (A., B.); elsewhere the sub-headings are letters (A., B.) and their sub-headings numbers (1., 2.).
#let in-argument(loc) = {
  let sections = query(heading.where(level: 1).before(loc))
  sections.len() > 0 and repr(sections.last().body).contains("ARGUMENT")
}

#let nysb-motion-brief(meta, body) = {
  // The cover carries no footer. The contents page is numbered in roman numerals; the body from 1 (Fed. R. Bankr. P. 9004(a)).
  set page(paper: "us-letter", margin: margin, footer: none)
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: gap, spacing: 0pt, first-line-indent: 0pt, justify: false)
  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in)
  set list(indent: 0.5in, body-indent: 0.4in)
  show footnote.entry: set text(size: 11pt)
  // The heading counters advance only for numbered headings; the labels are drawn by the show rules below, so the
  // numbering pattern itself is empty.
  set heading(numbering: (..nums) => "")

  // Headings: level 1 is a centered bold section; levels 2 and 3 are bold point headings, numbered by the template
  // (see in-argument above). Each heading is a sticky block, so it never ends a page.
  show heading.where(level: 1): it => block(width: text-width, sticky: true, above: 0pt, below: gap,
    align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: text-width, sticky: true, above: 0pt, below: gap, context {
    let idx = counter(heading).at(it.location())
    let label = if in-argument(it.location()) { numbering("I.", idx.at(1)) } else { numbering("A.", idx.at(1)) }
    set par(leading: single-leading, hanging-indent: 0.5in)
    text(weight: "bold", [#label#h(number-gap)#it.body])
  })
  show heading.where(level: 3): it => block(width: text-width, sticky: true, above: 0pt, below: gap, context {
    let idx = counter(heading).at(it.location())
    let label = if in-argument(it.location()) { numbering("A.", idx.at(2)) } else { numbering("1.", idx.at(2)) }
    set par(leading: single-leading, hanging-indent: 0.5in)
    text(weight: "bold", [#label#h(number-gap)#it.body])
  })

  cover(meta)

  // Contents page: roman numerals, counted from the first page after the cover.
  set page(
    numbering: "i",
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  counter(page).update(1)
  outline(title: align(center, text(weight: "bold", "TABLE OF CONTENTS")), depth: 3, indent: 0pt)
  pagebreak()

  // The memorandum: arabic numerals from 1.
  set page(numbering: "1")
  counter(page).update(1)
  allegations(body, signature-block(meta))
}
