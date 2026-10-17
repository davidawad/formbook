// Adversary complaint for the United States Bankruptcy Court for the District of Utah (utb).
// Rules: Fed. R. Bankr. P. 7001, 7008(a) (jurisdiction allegation; statement of consent to final orders),
// 7010 (Fed. R. Civ. P. 10 applies; caption substantially conforms to Form 416); Local Rules 7003-1 (cover
// sheet, filed separately), 9004-1(a)(2) (caption per Official Form 416D), 5005-3 (format); DUCivR 10-1
// (format; applies in bankruptcy through LBR 1001-1(a)); Fed. R. Civ. P. 10(b) (numbered paragraphs).
// See ../README.md. Content-agnostic: every case-specific word comes from the sample.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif"     // DUCivR 10-1(3): clearly legible; Times New Roman substitute per docs/FONTS.md
#let type-size = 12pt                     // DUCivR 10-1(3) and LBR 5005-3(a)(4): minimum 12 point
#let pitch = 24pt                         // DUCivR 10-1(4): double-spaced; a 24 pt baseline pitch at 12 pt
#let body-leading = 1.345em               // Liberation Serif's line box is 0.655em (measured), so 1.345em leading = 24 pt pitch
#let single-leading = 0.65em              // typst's default leading: single-spaced (caption, counsel, signature)
#let top-margin = 1.5in                   // DUCivR 10-1(1): top margin of at least 1 1/2 inches (stricter than LBR 5005-3(a)(2))
#let side-margin = 1in                    // DUCivR 10-1(1), LBR 5005-3(a)(3): left and right at least 1 inch
#let bottom-margin = 1in                  // holds the page number (LBR 5005-3(a)(7))
#let text-width = 8.5in - 2 * side-margin
#let para-indent = 0.5in                  // first-line indent of numbered allegations
#let caption-left = 3.3in                 // width of the party column of the caption (Form 416D)
#let footnote-size = 12pt                 // DUCivR 10-1(3): the 12 point minimum includes footnotes

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("utb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, and so on).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Block markdown.
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

/// Headings are blocks kept with the text after them.
// Typst adds leading only between lines, so `below` restores the trailing leading and keeps the next line on the
// 24 pt pitch (without it, each paragraph's first line lands on the previous paragraph's last line).
#let heading-block(c) = block(width: text-width, above: pitch, below: body-leading, sticky: true, c)

/// A lettered prayer item: the letter sits at the paragraph indent, the text hangs to its right.
#let lettered-item(label, rest) = {
  set par(leading: body-leading, first-line-indent: 0pt)
  grid(columns: (para-indent + 0.4in, 1fr), [#h(para-indent)#label], md(rest))
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Arabic page number at the bottom center (LBR 5005-3(a)(7)).
#let folio() = context align(center, text(size: type-size, counter(page).display()))

// ---------------------------------------------------------------------------
// Cover: contact block (DUCivR 10-1(6)(A)), court title, caption (Form 416D), title (LBR 9004-1(b))
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  let lines = (
    text(weight: "bold", "UNITED STATES BANKRUPTCY COURT"),
    text(weight: "bold", "DISTRICT OF UTAH"),
  )
  if "division" in meta and meta.division != none {
    lines.push(text(weight: "bold", upper(meta.division) + " DIVISION"))
  }
  align(center, stack(dir: ttb, spacing: single-leading, ..lines))
}

/// Form 416D: the debtor, then the adversary parties; on the right the case numbers and the judge.
#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.25in,
  block(stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), {
    let parts = ([In re:], [ ])
    for d in meta.caption.debtors {
      parts.push(inl(d))
    }
    parts += ([ ], [#inl(meta.caption.debtor_designation)], [ ])
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { parts += ([ v. ], [ ]) }
      for n in p.names { parts.push(inl(n)) }
      parts += ([ ], [#inl(p.designation)], [ ])
    }
    set par(leading: single-leading, spacing: 0pt, justify: false)
    stack(dir: ttb, spacing: single-leading, ..parts)
  }),
  block(inset: (left: 0.15in), {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    let bk = if meta.case.bankruptcy_number == "" { "________" } else { meta.case.bankruptcy_number }
    let adv = if meta.case.adversary_number == "" { "________" } else { meta.case.adversary_number }
    stack(dir: ttb, spacing: single-leading,
      [Bankruptcy No. #bk],
      [Chapter #meta.case.chapter],
      [ ],
      [Adversary Proceeding No. #adv],
      [ ],
      [Hon. #(meta.case.judge)],
    )
  }),
)

#let cover(meta) = {
  line-stack(meta.counsel)
  v(pitch)
  court-title(meta)
  v(pitch)
  caption(meta)
  v(pitch)
  block(width: text-width, {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    align(center, text(weight: "bold", upper(meta.title)))
  })
  v(pitch)
}

// ---------------------------------------------------------------------------
// Body: numbered allegations (Fed. R. Civ. P. 10(b))
// ---------------------------------------------------------------------------

/// Each blank-line-separated chunk of markdown is one of: a heading (kept with the chunk after it),
/// a lettered prayer item ("A. ..."), a markdown list (lettered (a), (b), ...), or a numbered
/// paragraph. Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps
/// paragraph content recurses without end in typst 0.15.
#let allegations(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let pending = []
  let has-pending = false
  // Text before the first heading is the complaint's lead-in: it is not an allegation and is unnumbered.
  let seen-heading = false
  let n = 0
  for c in chunks {
    let t = c.trim()
    let piece = none
    if t.starts-with("#") {
      pending += md(t)
      has-pending = true
      seen-heading = true
      continue
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Lists may break across pages; only a heading in front of a list is kept with its first item.
      piece = block(width: text-width, above: 0pt, below: 0pt, {
        set par(leading: body-leading, first-line-indent: 0pt)
        md(t)
        v(body-leading)
      })
    } else if t.match(regex("^[A-Z]\\.[ \\t]")) != none {
      piece = block(width: text-width, above: 0pt, below: body-leading, lettered-item(t.at(0) + ".", t.slice(3)))
    } else if t.starts-with("WHEREFORE") or not seen-heading {
      // The prayer's lead-in and the complaint's lead-in are not allegations: they are unnumbered.
      piece = block(width: text-width, above: 0pt, below: body-leading, {
        set par(leading: body-leading, first-line-indent: 0pt)
        h(para-indent)
        md(t)
      })
    } else {
      // The number is placed at the first line, not typed inline: a paragraph nested in the same line
      // would measure as one line high and overlap the paragraph after it. The first-line indent is a
      // leading space: cmarker's paragraphs do not take the par setting.
      n += 1
      piece = block(width: text-width, above: 0pt, below: body-leading, {
        place(top + left, dx: para-indent, [#n])
        set par(leading: body-leading, first-line-indent: 0pt)
        h(para-indent + 0.4in)
        md(t)
      })
    }
    if has-pending {
      // The group's bottom gap is on the group: a container drops the spacing of its last child.
      block(breakable: false, width: text-width, below: body-leading, { pending; piece })
    } else {
      piece
    }
    pending = []
    has-pending = false
  }
  if pending != [] { block(breakable: false, width: text-width, below: body-leading, pending) }
}

// ---------------------------------------------------------------------------
// Signature and verification
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(width: text-width, breakable: false, {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  v(pitch)
  grid(
    columns: (3.2in, 1fr),
    column-gutter: 0.2in,
    [DATED #(meta.signature.date).],
    stack(dir: ttb, spacing: single-leading,
      [#meta.signature.firm],
      [ ],
      [/s/ #meta.signature.signer],
      ..meta.signature.lines.map(i => inl(i)),
    ),
  )
})

/// Verification (28 U.S.C. § 1746 declaration), when the complaint is verified.
#let verification-block(meta) = if "verification" in meta and meta.verification != none {
  let vm = meta.verification
  block(width: text-width, breakable: false, above: pitch, {
    block(below: body-leading, align(center, text(weight: "bold", "VERIFICATION")))
    set par(leading: body-leading, first-line-indent: para-indent)
    [I, #(vm.declarant), declare under penalty of perjury under the laws of the United States of America that I am #(vm.title) of #(vm.entity), that I have read the foregoing #(meta.title), and that the factual allegations in it are true and correct to the best of my knowledge, information, and belief.]
    v(pitch)
    set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
    grid(columns: (3.2in, 1fr), column-gutter: 0.2in,
      [Executed on #(vm.date), at #(vm.place).],
      stack(dir: ttb, spacing: single-leading,
        [ ],
        [#(vm.declarant)],
        [#(vm.title), #(vm.entity)],
      ),
    )
  })
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let utb-adversary-complaint(meta, body) = {
  // FRBP 7008(a): the complaint must state whether the pleader does or does not consent to the entry of
  // final orders or judgment by the bankruptcy court. The template refuses to build without that statement.
  assert(
    body.contains("consent to the entry of final orders"),
    message: "utb-adversary-complaint: FRBP 7008(a) requires a statement whether the pleader does or does not consent to the entry of final orders or judgment by the bankruptcy court",
  )
  // FRBP 7008(a): the jurisdiction allegation names the bankruptcy case, its number and its Code chapter.
  assert(
    body.contains(meta.case.bankruptcy_number) and lower(body).contains("chapter " + lower(meta.case.chapter)),
    message: "utb-adversary-complaint: FRBP 7008(a) requires the jurisdiction allegation to name the case, its number and its Code chapter",
  )
  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: side-margin, right: side-margin),
    footer: folio(),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  show footnote.entry: set text(size: footnote-size)
  show footnote.entry: set par(leading: single-leading)

  show heading.where(level: 1): it => heading-block(align(center, text(weight: "bold", it.body)))
  show heading.where(level: 2): it => heading-block(align(center, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => heading-block(text(weight: "bold", it.body))

  cover(meta)
  allegations(body)
  signature-block(meta)
  verification-block(meta)
}
