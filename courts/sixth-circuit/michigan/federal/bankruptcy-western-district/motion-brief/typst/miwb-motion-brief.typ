// U.S. Bankruptcy Court, Western District of Michigan: motion with brief in support, in an adversary
// proceeding (Fed. R. Bankr. P. 7012(b), 9013; LBR 7007, 9004, 9013). Rule IDs (MIWB-...) refer to
// ../README.md, which quotes the rules and their source, fetched 2026-10-14. Content-agnostic: every
// case-specific word comes from the sample's frontmatter, never from this file. The body is markdown
// rendered by cmarker.
//
// Two documents, as the court's ECF Administrative Procedures file them (the brief is an attachment
// to the motion, section II.A.2): the motion, then the brief in support, each with its own caption and
// its own page numbers.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif"   // MIWB-FORM-001: the rules name no face (LBR 9004(f): "typewritten in at least 12-point type"); Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                   // MIWB-FORM-001: at least 12-point type (LBR 9004(f))
#let pitch = 27.6pt                     // MIWB-FORM-001: double-spaced; the filed exemplars measure 27.6 pt baseline to baseline
#let body-leading = 1.645em             // gap between lines of body text; with Liberation Serif's 0.655em line box this gives the 27.6 pt baseline pitch at 12 pt
#let single-leading = 0.495em         // caption, counsel, signature, footers: single-spaced (1.15em, 13.8 pt pitch)
#let page-margin = 1in                  // MIWB-FORM-011: letter paper; margins are a layout choice (the exemplars use 1 in)
#let para-indent = 0.5in                // first-line indent of body paragraphs (exemplars: 0.5 in)
#let caption-left = 3.5in               // width of the left (party) column of the caption
#let footer-size = 11pt

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("miwb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A required frontmatter field: a missing one stops the build (no silent blank in a filing).
#let need(meta, key) = {
  if key not in meta { panic("miwb-motion-brief: missing required frontmatter field `" + key + "`") }
  meta.at(key)
}

/// Inline markdown (names with *et al.*, italic case names) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

/// Underscored rule ending a party block, as on the filed exemplars: "_______/".
#let slash-rule(width) = block(width: width, stack(dir: ltr, box(width: 1fr, repeat("_")), "/"))

// ---------------------------------------------------------------------------
// Caption (Fed. R. Bankr. P. 7010 and Form 416A; LBR 9004(a), (b))
// ---------------------------------------------------------------------------

/// The court's title, as the court prints it on its own papers (MIWB-FORM-002).
#let court-title() = {
  set par(leading: single-leading, first-line-indent: 0pt, justify: false)
  align(center, text(weight: "bold", [UNITED STATES BANKRUPTCY COURT #linebreak() FOR THE WESTERN DISTRICT OF MICHIGAN]))
}

#let caption(meta) = {
  let debtor = need(meta, "debtor")
  let plaintiff = need(meta, "plaintiff")
  let defendants = need(meta, "defendants")
  let case = need(meta, "case")
  set par(leading: single-leading, first-line-indent: 0pt, justify: false)
  // Each column is a stack of single lines, so every line gets the same single spacing.
  let names(list) = stack(dir: ttb, spacing: single-leading, ..list.map(n => inl(n)))
  let gap = block(height: pitch * 0.5)
  let rule = slash-rule(caption-left - 0.1in)
  let case-lines = ([Case No. #inl(case.number)], [Chapter #inl(case.chapter)])
  if "judge" in case and case.judge != none { case-lines.push(inl(case.judge)) }
  grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.25in,
    row-gutter: 0.6em,
    // Row 1: the debtor, in re; the case number, and the chapter directly below it (LBR 9004(a)).
    stack(dir: ttb, spacing: single-leading,
      [In re:], gap, pad(left: 0.5in, names(debtor.names)), pad(left: 1.2in, inl(debtor.designation)), rule),
    stack(dir: ttb, spacing: single-leading, ..case-lines),
    // Row 2: the adversary parties; the adversary proceeding number on the right.
    stack(dir: ttb, spacing: single-leading,
      names(plaintiff.names), pad(left: 1.2in, inl(plaintiff.designation)), block(height: 0.4em), [v.],
      block(height: 0.4em), names(defendants.names), pad(left: 1.2in, inl(defendants.designation)), rule),
    [Adv. Proc. No. #inl(need(meta, "adversary_number"))],
  )
}

// ---------------------------------------------------------------------------
// Body paragraphs (unnumbered; motions and briefs are not numbered pleadings)
// ---------------------------------------------------------------------------

/// The statement the rules require in every motion (LBR 9004(c)): the petition date and any
/// conversion, dismissal or reinstatement. Its wording comes from the frontmatter.
#let petition-statement(meta) = {
  let case = need(meta, "case")
  let dates = need(meta, "dates")
  "The petition commencing the underlying Chapter " + case.chapter + " case was filed on " + dates.petition + ". " + dates.later
}

/// One body paragraph with a first-line indent.
#let para(t) = block(width: 100%, above: 0pt, below: body-leading, breakable: true, {
  set par(leading: body-leading, first-line-indent: 0pt, justify: false)
  h(para-indent)
  cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
})

/// Markdown body as blocks. Footnote definitions ("[^key]: text") are inlined into each chunk that refers
/// to them: cmarker renders one chunk at a time, so a reference and its definition must be together.
/// `insert` is an optional statement placed right after the first paragraph (the LBR 9004(c) statement).
#let body-blocks(body, insert: none) = {
  let notes = (:)
  for line in body.split("\n") {
    if line.starts-with("[^") and line.contains("]:") {
      let key = line.slice(2, line.position("]:"))
      notes.insert(key, line.slice(line.position("]:") + 2).trim())
    }
  }
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "" and not c.trim().starts-with("[^"))
  let pending = []
  let has-pending = false
  let inserted = insert == none
  for c in chunks {
    let t = c.trim()
    for (key, note) in notes.pairs() {
      if t.contains("[^" + key + "]") { t += "\n\n[^" + key + "]: " + note }
    }
    if t.starts-with("#") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
    } else {
      let piece = if t.starts-with(">") {
        block(width: 100%, below: body-leading, pad(left: 0.5in, {
          set par(leading: body-leading, first-line-indent: 0pt, justify: false)
          cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        }))
      } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
        // A list may break across pages; items are lettered a., b., ... (the court's sub-list style).
        block(width: 100%, below: body-leading, {
          set enum(numbering: "a.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
          set par(leading: body-leading)
          cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        })
      } else {
        para(t)
      }
      if has-pending {
        block(breakable: false, width: 100%, below: body-leading, { pending; piece })
      } else {
        piece
      }
      pending = []
      has-pending = false
      if not inserted and not t.starts-with("#") and not t.starts-with(">") {
        para(insert)
        inserted = true
      }
    }
  }
  if pending != [] { block(breakable: false, width: 100%, pending) }
}

// ---------------------------------------------------------------------------
// Signature block (LBR 9004(d): telephone, office address, email and bar number directly below the signature)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: pitch, {
    set par(leading: single-leading, first-line-indent: 0pt, justify: false)
    grid(
      columns: (2.9in, 1fr),
      column-gutter: 0.2in,
      [Dated: #need(meta, "date")],
      {
        [Respectfully submitted,]
        v(pitch * 0.5)
        line-stack(sig.firm)
        v(pitch * 0.5)
        // Further signing attorneys (optional `also`) are listed under the signer, before the role.
        line-stack(("By: /s/ " + sig.signer, sig.signer + " (" + sig.bar_id + ")") + sig.at("also", default: ()) + (sig.role,))
        v(pitch * 0.5)
        line-stack(("BUSINESS ADDRESS:",) + sig.address + ("Telephone " + sig.phone, "Email " + sig.email))
      },
    )
  })
}

// ---------------------------------------------------------------------------
// The two documents
// ---------------------------------------------------------------------------

/// A document's heading block: the court, the caption, and the description of the document (LBR 9004(b)).
#let document-head(meta, title) = {
  court-title()
  v(pitch)
  caption(meta)
  v(pitch)
  // LBR 9004(b): the description of the document, centered, immediately before the body.
  align(center, text(weight: "bold", upper(title)))
  v(pitch * 0.5)
}

#let motion-document(meta) = {
  let motion = need(meta, "motion")
  document-head(meta, motion.title)
  // LBR 9004(c): the statement follows the first paragraph of the motion.
  body-blocks(motion.body, insert: petition-statement(meta))
  signature-block(meta)
}

#let brief-document(meta, body) = {
  document-head(meta, need(meta, "brief_title"))
  body-blocks(body)
  signature-block(meta)
}

#let miwb-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: page-margin,
    numbering: "1",
    footer: context align(center, text(size: footer-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  // Headings in the brief: level 1 centered bold capitals; level 2 bold; level 3 bold italic. Numbers are typed.
  show heading.where(level: 1): it => block(width: 100%, above: 0pt, below: body-leading, sticky: true,
    align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, above: 0pt, below: body-leading, sticky: true,
    text(size: type-size, weight: "bold", it.body))
  show heading.where(level: 3): it => block(width: 100%, above: 0pt, below: body-leading, sticky: true,
    text(size: type-size, weight: "bold", style: "italic", it.body))
  motion-document(meta)
  // The brief is a separate document: it starts on a new page and its page numbers restart.
  pagebreak()
  counter(page).update(1)
  brief-document(meta, body)
}
