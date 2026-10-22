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
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // MIWB-FORM-001: the rules name no face (LBR 9004(f): "typewritten in at least 12-point type"); Times New Roman (vendored), the default per docs/FONTS.md
#let type-size = 12pt                   // MIWB-FORM-001: at least 12-point type (LBR 9004(f))
#let footer-size = 11pt                 // the page number
#let page-margin = 1in                  // MIWB-FORM-011: letter paper; margins are a layout choice (the exemplars use 1 in)
#let para-indent = 0.5in                // first-line indent of body paragraphs (exemplars: 0.5 in)
#let label-box = 0.5in                  // a list letter's box (docx: the tab stop 0.5 in on)
#let caption-left = 3.5in               // width of the left (party) column of the caption
#let caption-gutter = 0.25in            // caption: between the two columns
#let rule-width = caption-left - 0.1in  // the "_____/" rule that ends a party block
#let rule-drop = 1.3pt                  // the rule below the baseline (Times New Roman's underline position, Word's underlined tab)
#let rule-stroke = 0.6pt                // its thickness (Times New Roman's underline thickness)
#let name-indent = 0.5in                // caption: the debtor's names
#let designation-indent = 1.2in         // caption: "Debtor.", "Plaintiff", "Defendants."
#let sig-left = 2.9in                   // signature: the "Dated" column
#let sig-gutter = 0.2in                 // signature: between the two columns

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/miwb-motion-brief.lua sets the same twips,
// 20 x pt).
#let pitch-body = 27.6pt                // MIWB-FORM-001: double-spaced; the filed exemplars measure 27.6 pt baseline to baseline
#let pitch-single = 13.8pt              // caption, signature, footer: single-spaced (half the body pitch)
#let row-gap = 7.2pt                    // caption: the debtor row to the adversary row
#let v-gap = 4.8pt                      // caption: above and below "v."
#let note-gap = 4pt                     // between two footnotes
#let note-clearance = 12pt              // the body text to the footnote rule

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

/// Inline content without the paragraph breaks cmarker may put around it (they may not occur inside a paragraph).
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// One single-spaced line (a paragraph of its own), with an explicit space above it.
#let line-block(above: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: 0pt, pad(left: left, body))

/// The rule ending a party block, as on the filed exemplars ("_______/"): a ruled fill and a slash (docx: an
/// underlined tab to a right tab stop, then the slash).
#let slash-rule() = line-block(block(width: rule-width,
  [#box(width: 1fr, height: 0pt, baseline: rule-drop, stroke: (bottom: rule-stroke))/]))

/// Two columns, the gutter between them; one row, not split across pages (docx: a table row).
#let two-cols(above, cols, left, right) = block(width: 100%, above: above, below: 0pt, breakable: false, grid(
  columns: cols, left, [], right))

// ---------------------------------------------------------------------------
// Caption (Fed. R. Bankr. P. 7010 and Form 416A; LBR 9004(a), (b)) and the description of the document
// ---------------------------------------------------------------------------

#let document-head(meta, title) = {
  let debtor = need(meta, "debtor")
  let plaintiff = need(meta, "plaintiff")
  let defendants = need(meta, "defendants")
  let case = need(meta, "case")
  {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    // The court's title, as the court prints it on its own papers (MIWB-FORM-002).
    line-block(align(center, strong[UNITED STATES BANKRUPTCY COURT]))
    line-block(align(center, strong[FOR THE WESTERN DISTRICT OF MICHIGAN]))
    let cols = (caption-left, caption-gutter, 1fr)
    // Row 1: the debtor, in re; the case number, and the chapter directly below it (LBR 9004(a)).
    let left = {
      line-block[In re:]
      for (i, n) in debtor.names.enumerate() {
        line-block(above: if i == 0 { pitch-single } else { 0pt }, left: name-indent, inl(n))
      }
      line-block(left: designation-indent, inl(debtor.designation))
      slash-rule()
    }
    let right = {
      line-block[Case No. #inl(case.number)]
      line-block[Chapter #inl(case.chapter)]
      if "judge" in case and case.judge != none { line-block(inl(case.judge)) }
    }
    two-cols(pitch-body, cols, left, right)
    // Row 2: the adversary parties; the adversary proceeding number on the right.
    let left = {
      for n in plaintiff.names { line-block(inl(n)) }
      line-block(left: designation-indent, inl(plaintiff.designation))
      line-block(above: v-gap)[v.]
      for (i, n) in defendants.names.enumerate() { line-block(above: if i == 0 { v-gap } else { 0pt }, inl(n)) }
      line-block(left: designation-indent, inl(defendants.designation))
      slash-rule()
    }
    two-cols(row-gap, cols, left, line-block[Adv. Proc. No. #inl(need(meta, "adversary_number"))])
  }
  // LBR 9004(b): the description of the document, centered, on the body pitch, immediately before the body.
  block(width: 100%, above: pitch-body, below: pitch-single, align(center, strong(upper(inl(title)))))
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

/// A body paragraph at the body pitch, its first line indented half an inch.
#let body-par(content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), unloose(content)))

/// Headings, on the body pitch and kept with the block after them: "#" centred bold capitals, "##" bold, "###" bold
/// italic, at the margin. Their numbers are typed by the author.
#let heading-block(level, s) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
  set par(first-line-indent: 0pt)
  if level == 1 { align(center, strong(upper(inl(s)))) }
  else if level == 2 { strong(inl(s)) }
  else { strong(emph(inl(s))) }
})

/// A list, lettered a., b., ... (the court's sub-list style): the letter in a half-inch box half an inch in, the text
/// hanging after it.
#let lettered(c) = {
  let items = ()
  for l in c.split("\n") {
    let m = l.match(regex("^\\s*(?:-|\\*|\\+|\\d+\\.)\\s+(.*)$"))
    if m != none { items.push(m.captures.at(0)) } else if items.len() > 0 { items.at(-1) += " " + l.trim() }
  }
  for (i, it) in items.enumerate() {
    block(width: 100%, above: 0pt, below: 0pt, pad(left: para-indent,
      par(first-line-indent: 0pt, hanging-indent: label-box,
        [#box(width: label-box, numbering("a.", i + 1))#unloose(inl(it))])))
  }
}

/// Markdown body as blocks: headings, block quotations (half an inch in, on the body pitch), lists (lettered),
/// paragraphs. Footnote definitions ("[^key]: text") are appended to each chunk that refers to them: cmarker renders
/// one chunk at a time, so a reference and its definition must be together. `insert` is an optional statement placed
/// right after the first paragraph (the LBR 9004(c) statement).
#let body-blocks(body, insert: none) = {
  let notes = (:)
  for line in body.split("\n") {
    if line.starts-with("[^") and line.contains("]:") {
      let key = line.slice(2, line.position("]:"))
      notes.insert(key, line.slice(line.position("]:") + 2).trim())
    }
  }
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "" and not c.starts-with("[^"))
  let inserted = insert == none
  for c in chunks {
    let t = c
    for (key, note) in notes.pairs() {
      if t.contains("[^" + key + "]") { t += "\n\n[^" + key + "]: " + note }
    }
    if t.starts-with("#") {
      let level = t.match(regex("^(#+)")).captures.at(0).len()
      heading-block(level, t.replace(regex("^#+[ \t]*"), ""))
    } else if t.starts-with(">") {
      block(width: 100%, above: 0pt, below: 0pt, pad(left: para-indent, {
        set par(first-line-indent: 0pt)
        unloose(inl(t.replace(regex("(?m)^>[ \t]?"), "")))
      }))
    } else if t.match(regex("^(\\d+\\.|[-*+])[ \\t]")) != none {
      lettered(t)
    } else {
      body-par(inl(t))
      if not inserted {
        body-par(inl(insert))
        inserted = true
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (LBR 9004(d): telephone, office address, email and bar number directly below the signature)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  let lines(items) = for l in items { line-block(inl(l)) }
  block(width: 100%, above: pitch-body, below: 0pt, breakable: false, grid(
    columns: (sig-left, sig-gutter, 1fr),
    line-block[Dated: #need(meta, "date")],
    [],
    {
      line-block[Respectfully submitted,]
      line-block(above: pitch-single, inl(sig.firm.first()))
      lines(sig.firm.slice(1))
      line-block(above: pitch-single, inl("By: /s/ " + sig.signer))
      // Further signing attorneys (optional `also`) are listed under the signer, before the role.
      lines((sig.signer + " (" + sig.bar_id + ")",) + sig.at("also", default: ()) + (sig.role,))
      line-block(above: pitch-single)[BUSINESS ADDRESS:]
      lines(sig.address + ("Telephone " + sig.phone, "Email " + sig.email))
    },
  ))
}

// ---------------------------------------------------------------------------
// The two documents
// ---------------------------------------------------------------------------

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
  set document(title: need(meta, "motion").title, author: need(meta, "signature").signer)
  // Every page numbered, bottom centre, in a single-spaced line box (Word's footer: a PAGE field).
  set page(
    paper: "us-letter",
    margin: page-margin,
    footer-descent: 30%,
    footer: context align(center, text(size: footer-size, ..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, footnote marks at 58 %, a section sign kept with its number. No markdown list reaches typst's lists.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  set footnote.entry(separator: line(length: 30%, stroke: 0.5pt), gap: note-gap, clearance: note-clearance, indent: 0pt)
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }
  motion-document(meta)
  // The brief is a separate document: it starts on a new page and its page numbers restart (docx: a new section).
  pagebreak()
  counter(page).update(1)
  brief-document(meta, body)
}
