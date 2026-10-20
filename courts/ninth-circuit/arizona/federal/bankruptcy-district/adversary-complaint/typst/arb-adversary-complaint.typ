// Adversary complaint, United States Bankruptcy Court, District of Arizona (arb).
// Rules: FRBP 7001 (an adversary proceeding is commenced by complaint), 7008(a) (jurisdiction reference
// and a statement of consent to final orders), 7010 (caption substantially conforms to Official Form 416A;
// Fed. R. Civ. P. 10 applies, so allegations are numbered); LRBP 1005-1(a) (court title), LRBP 9004-1
// (a) first-page filer block, (c) dual caption, (e) hearing if known, (g) form of papers, (h) length.
// See ../README.md for the quoted rule text, the date verified and the known gaps.
// Content-agnostic: every case word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a named layout choice; see README.md)
// ---------------------------------------------------------------------------
#let court-title = ("UNITED STATES BANKRUPTCY COURT", "DISTRICT OF ARIZONA")  // LRBP 1005-1(a)
#let font-family = ("Times New Roman", "Liberation Serif")        // proportional, standard; vendored in fonts/ (LRBP 9004-1(g))
#let type-size = 13pt                   // LRBP 9004-1(g): "a proportional font size no smaller than 13 point"
#let footnote-size = 12pt               // LRBP 9004-1(g): footnotes may be 12 point
#let pitch = 24pt                       // LRBP 9004-1(g): double spacing; the numbered lines are this pitch
#let lines-per-page = 27                // LRBP 9004-1(g): no more than 28 lines per page
#let page-w = 8.5in                     // LRBP 9004-1(g): paper 8 1/2 by 11 inches
#let page-h = 11in
#let top-margin = 72pt                  // numbered line 1 sits on the top margin
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 72 pt: holds the footer
#let left-margin = 1.5in                // LRBP 9004-1(g): left margin at least 1 1/2 inches
#let right-margin = 1in              // LRBP 9004-1(g): right margin at least 1/2 inch
#let text-width = page-w - left-margin - right-margin
// 8.45 pt is EB Garamond's natural line pitch at 13 pt (0.65 em, measured); 15.55 pt of leading makes
// the baseline pitch exactly 24 pt. Measured with pdftotext -bbox on the render (README.md).
#let body-leading = 15.55pt
#let single-leading = 0.5em             // counsel, caption, signature, footnotes: single-spaced
#let para-indent = 0.5in
#let caption-left = 3.1in               // width of the party column of the caption
#let filer-lines = 7                    // the court title starts on line 8 (convention; LRBP 9004-1(a) only fixes line 1)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("arb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics for case names, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("arb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Fill whole numbered lines: the block is rounded up to a multiple of `pitch`, so whatever follows
/// it stays on the grid of numbered lines.
#let on-grid(c) = context {
  let h = measure(width: text-width, c).height
  block(width: text-width, height: calc.ceil(h / pitch) * pitch, above: 0pt, below: 0pt, c)
}

/// A heading: whole numbered lines (one line unless the title wraps), kept with the paragraph after it
/// (a heading never ends a page).
#let heading-line(c) = context {
  let h = measure(width: text-width, c).height
  block(width: text-width, height: calc.ceil(h / pitch) * pitch, above: 0pt, below: 0pt, sticky: true, c)
}

// ---------------------------------------------------------------------------
// Page furniture: pleading paper (LRBP 9004-1(g))
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

/// Footer in the bottom margin: page number, the paper's title, and the adversary number.
#let footer-block(meta) = place(
  top + left,
  dx: left-margin,
  dy: top-margin + lines-per-page * pitch + 6pt,
  block(width: text-width, {
    set text(size: 11pt)
    align(center, context counter(page).display("1"))
    v(4pt)
    grid(
      columns: (1fr, auto),
      upper(need(meta, "footer_title")),
      if str(need(meta, "adversary_number")) != "" { [ADV. NO. #need(meta, "adversary_number")] } else { [] },
    )
  }),
)

// ---------------------------------------------------------------------------
// First page: filer block (line 1), court title, dual caption (LRBP 9004-1(a), (c), (e); FRBP 7010)
// ---------------------------------------------------------------------------

/// One single-spaced line per item, kept on the single-spacing grid. Items are strings (cmarker) or content.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => if type(i) == str { inl(i) } else { i }))
}

/// Filer block from line 1: counsel, firm, address, email, State Bar number, telephone and the party
/// represented (LRBP 9004-1(a)). Occupies at least `filer-lines` numbered lines; longer blocks push the
/// court title down (convention: the rule gives no line for the title).
#let filer-block(meta) = context {
  let items = need(meta, "filer")
  let h = measure(width: text-width, line-stack(items)).height
  block(width: text-width, height: calc.max(filer-lines, calc.ceil(h / pitch)) * pitch, line-stack(items))
}

#let court-title-block() = {
  for l in court-title {
    on-grid(align(center, text(weight: "bold", l)))
  }
}

/// Dual caption (LRBP 9004-1(c)): the first caption names the debtor and the case; the second names the
/// adversary parties and the adversary number. The right column carries the title and the relief sought
/// (LRBP 9004-1(a)) and the hearing, when one is known (LRBP 9004-1(e)).
#let dual-caption(meta) = {
  let debtor = need(meta, "debtor")
  let parties = need(meta, "parties")
  let left-cell(rows, top: 0pt) = block(
    width: caption-left,
    stroke: (right: 0.75pt, bottom: 0.75pt),
    inset: (right: 10pt, bottom: 8pt, top: top),
    line-stack(rows),
  )
  let right-cell(rows, top: 0pt) = block(inset: (left: 0.1in, bottom: 8pt, top: top), line-stack(rows))

  // Row 1: the debtor (the case, chapter and complete case number; LRBP 9004-1(b)).
  let debtor-rows = ("In re:", "") + debtor.names + ("", "*Debtor.*")
  let case-rows = ("Chapter " + str(debtor.chapter), "", "Case No. " + debtor.case_number)

  // Row 2: the adversary parties and the adversary number.
  let party-rows = ()
  for (k, p) in parties.enumerate() {
    if k > 0 { party-rows += ("", "v.", "") }
    party-rows += p.names
    party-rows += ("", "*" + p.designation + "*")
  }
  let adv-rows = ("Adv. No. " + need(meta, "adversary_number"), "")
  adv-rows += (text(weight: "bold", upper(inl(need(meta, "title")))),)
  adv-rows += ("", inl(need(meta, "relief")))
  if "hearing" in meta and meta.hearing != none {
    let hr = meta.hearing
    adv-rows += ("", "Hearing date: " + hr.at("date", default: ""), "Time: " + hr.at("time", default: ""), "Place: " + hr.at("place", default: ""))
  }

  on-grid(grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.2in,
    left-cell(debtor-rows),
    right-cell(case-rows),
    left-cell(party-rows, top: 8pt),
    right-cell(adv-rows, top: 8pt),
  ))
}

#let cover(meta) = {
  filer-block(meta)
  court-title-block()
  v(pitch)
  dual-caption(meta)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

#let signature-block(meta) = on-grid(grid(
  columns: (2.6in, 1fr),
  column-gutter: 0.2in,
  [Dated: #need(meta, "date")],
  {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    [Respectfully submitted,]
    v(pitch * 0.5)
    let sig = need(meta, "signature")
    line-stack(("/s/ " + sig.signer,) + sig.lines)
  },
))

/// Numbered allegations (Fed. R. Civ. P. 10(b), applied by FRBP 7010). Each blank-line-separated chunk of
/// markdown that is neither a heading nor a list is one numbered paragraph. Headings and lists are
/// unnumbered. The last chunk is set together with `tail` (the jury demand and the signature block), so a
/// signature never stands alone on a page. Numbering is applied per chunk, not with a `show par` rule: a
/// show rule that re-wraps paragraph content recurses without end in typst 0.15.
#let allegations(body, para-counter, tail) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // A heading is kept in one unbreakable block with the chunk after it, so it never ends a page.
  let pending = []
  let has-pending = false
  for (idx, c) in chunks.enumerate() {
    let t = c.trim()
    let last = idx == chunks.len() - 1
    if t.starts-with("#") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
    } else {
      let piece = if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
        // A list may break across pages. Items are spaced by body-leading, so each item fills whole lines;
        // the trailing v() closes the last one.
        {
          set par(leading: body-leading)
          cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
          v(body-leading)
        }
      } else {
        // A paragraph breaks across pages like any text.
        para-counter.step()
        on-grid({
          set par(leading: body-leading)
          context [#h(para-indent)#(para-counter.display()).#h(0.3in)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)]
        })
      }
      if last {
        block(breakable: false, width: text-width, { pending; piece; tail })
      } else if has-pending {
        block(breakable: false, width: text-width, { pending; piece })
      } else {
        piece
      }
      pending = []
      has-pending = false
    }
  }
  if chunks.len() == 0 or has-pending {
    block(breakable: false, width: text-width, { pending; tail })
  }
}

#let arb-adversary-complaint(meta, body) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("filer", "debtor", "adversary_number", "parties", "title", "relief", "footer_title", "date", "signature", "consent_to_final_orders") {
    let _ = need(meta, k)
  }
  // FRBP 7008(a): the pleader must state whether it consents to entry of final orders or judgment by the
  // bankruptcy court. The template requires the answer in frontmatter; the wording is written in the body.
  assert(meta.consent_to_final_orders in ("yes", "no"), message: "arb-adversary-complaint: consent_to_final_orders must be \"yes\" or \"no\" (FRBP 7008(a))")
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    foreground: footer-block(meta),
  )
  let document-title = upper(need(meta, "title"))
  let document-title = if str(need(meta, "adversary_number")) != "" {
    document-title + ", Adv. No. " + need(meta, "adversary_number")
  } else { document-title }
  set document(title: document-title, author: need(meta, "signature").signer)
  set text(font: font-family, size: type-size, lang: "en", region: "us", hyphenate: false, fallback: false)
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 is a centered section; level 2 a bold centered sub-heading; level 3 bold italic.
  show heading.where(level: 1): it => heading-line(align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => heading-line(align(center, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => heading-line(text(weight: "bold", style: "italic", it.body))

  // Footnotes: 12 point, single-spaced (LRBP 9004-1(g)).
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: footnote-size)
  show footnote.entry: set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em)

  cover(meta)

  // Unnumbered lead-in paragraph (for example, "Plaintiff alleges as follows."), if the sample has one.
  if "lead_in" in meta {
    on-grid({
      set par(leading: body-leading)
      h(para-indent)
      inl(meta.lead_in)
    })
  }

  // Body: numbered allegations; markdown lists become (a), (b), ...
  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  let jury = if "jury_demand" in meta and meta.jury_demand {
    on-grid({
      set par(leading: body-leading)
      h(para-indent)
      [Plaintiff demands a trial by jury on all claims so triable. Fed. R. Civ. P. 38, as applied by FRBP 9015.]
    })
  } else { [] }
  allegations(body, para-counter, {
    jury
    signature-block(meta)
  })
}
