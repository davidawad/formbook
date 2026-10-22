// U.S. Bankruptcy Court, Western District of Michigan: adversary complaint (Fed. R. Bankr. P. 7001, 7008,
// 7010; LBR 7008, 9004). Rule IDs (MIWB-...) refer to ../README.md, which quotes the rules and their
// source, fetched 2026-10-14. Content-agnostic: every case-specific word comes from the sample's
// frontmatter, never from this file. The body is markdown rendered by cmarker.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // MIWB-FORM-001: the rules name no face (LBR 9004(f): "typewritten in at least 12-point type"); Times New Roman (vendored), the default per docs/FONTS.md
#let type-size = 12pt                   // MIWB-FORM-001: at least 12-point type (LBR 9004(f))
#let footer-size = 11pt                 // the "Page n of N" footer
#let page-margin = 1in                  // MIWB-FORM-011: letter paper; margins are a layout choice (the exemplars use 1 in)
#let para-indent = 0.5in                // first-line indent; an allegation's number sits here, its text at the next 0.5 in (exemplars)
#let label-box = 0.5in                  // the box of an allegation number or a list letter (docx: the tab stop 0.5 in on)
#let caption-left = 3.5in               // width of the left (party) column of the caption
#let caption-gutter = 0.25in            // caption: between the two columns
#let rule-width = caption-left - 0.1in  // the "_____/" rule that ends a party block
#let rule-drop = 1.3pt                  // the rule below the baseline (Times New Roman's underline position, Word's underlined tab)
#let rule-stroke = 0.6pt                // its thickness (Times New Roman's underline thickness)
#let name-indent = 0.5in                // caption: the debtor's names
#let designation-indent = 1.2in         // caption: "Debtor.", "Plaintiff,", "Defendant."
#let sig-left = 2.9in                   // signature: the "Dated" column
#let sig-gutter = 0.2in                 // signature: between the two columns

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/miwb-adversary-complaint.lua sets the same
// twips, 20 x pt).
#let pitch-body = 27.6pt                // MIWB-FORM-001: double-spaced; the filed exemplars measure 27.6 pt baseline to baseline
#let pitch-single = 13.8pt              // caption, title, signature, footnotes, footer: single-spaced (half the body pitch)
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
  if m == none { panic("miwb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A required frontmatter field: a missing one stops the build (no silent blank in a filing).
#let need(meta, key) = {
  if key not in meta { panic("miwb-adversary-complaint: missing required frontmatter field `" + key + "`") }
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

// ---------------------------------------------------------------------------
// Caption (Fed. R. Bankr. P. 7010 and Form 416A; Fed. R. Civ. P. 10(a); LBR 9004(a), (b))
// ---------------------------------------------------------------------------

/// Two columns, the gutter between them; one row, not split across pages (docx: a table row).
#let two-cols(above, left, right) = block(width: 100%, above: above, below: 0pt, breakable: false, grid(
  columns: (caption-left, caption-gutter, 1fr), left, [], right))

#let caption(meta) = {
  let debtor = need(meta, "debtor")
  let plaintiff = need(meta, "plaintiff")
  let defendants = need(meta, "defendants")
  let case = need(meta, "case")
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  // The court's title, as the court prints it on its own papers (MIWB-FORM-002).
  line-block(align(center, strong[UNITED STATES BANKRUPTCY COURT]))
  line-block(align(center, strong[FOR THE WESTERN DISTRICT OF MICHIGAN]))
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
  two-cols(pitch-body, left, right)
  // Row 2: the adversary parties; the adversary proceeding number on the right.
  let left = {
    for n in plaintiff.names { line-block(inl(n)) }
    line-block(left: designation-indent, inl(plaintiff.designation))
    line-block(above: v-gap)[v.]
    for (i, n) in defendants.names.enumerate() { line-block(above: if i == 0 { v-gap } else { 0pt }, inl(n)) }
    line-block(left: designation-indent, inl(defendants.designation))
    slash-rule()
  }
  two-cols(row-gap, left, line-block[Adv. Proc. No. #inl(need(meta, "adversary_number"))])
  // LBR 9004(b): the description of the document, centered, immediately before the body.
  block(width: 100%, above: pitch-body, below: pitch-single, align(center, strong(upper(need(meta, "title")))))
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (Fed. R. Civ. P. 10(b), applied by Fed. R. Bankr. P. 7010)
// ---------------------------------------------------------------------------

/// A body paragraph at the body pitch, its first line indented half an inch; `label` (an allegation's number) in a
/// half-inch box at that indent, the text following at the next half inch, as on the filed exemplars.
#let body-par(content, label: none) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true),
    if label == none { unloose(content) } else { box(width: label-box, label) + unloose(content) }))

/// Headings, on the body pitch and kept with the block after them: level 1 and 2 centered bold capitals; level 3
/// bold, at the margin.
#let heading-block(level, s) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
  set par(first-line-indent: 0pt)
  if level <= 2 { align(center, strong(upper(inl(s)))) } else { strong(inl(s)) }
})

/// A list, lettered a., b., ... (after a WHEREFORE: A., B., ..., as the exemplars do): the letter in a half-inch box
/// half an inch in, the text hanging after it.
#let lettered(c, capital) = {
  let items = ()
  for l in c.split("\n") {
    let m = l.match(regex("^\\s*(?:-|\\*|\\+|\\d+\\.)\\s+(.*)$"))
    if m != none { items.push(m.captures.at(0)) } else if items.len() > 0 { items.at(-1) += " " + l.trim() }
  }
  for (i, it) in items.enumerate() {
    block(width: 100%, above: 0pt, below: 0pt, pad(left: para-indent,
      par(first-line-indent: 0pt, hanging-indent: label-box,
        [#box(width: label-box, numbering(if capital { "A." } else { "a." }, i + 1))#unloose(inl(it))])))
  }
}

/// Generated statements (MIWB-FORM-005 and MIWB-FORM-007): numbered in place, right after the first
/// paragraph under the Jurisdiction heading. Their wording comes from the frontmatter.
#let generated-statements(meta) = {
  let case = need(meta, "case")
  let debtor = need(meta, "debtor")
  let dates = need(meta, "dates")
  let scope = "the United States Bankruptcy Court for the Western District of Michigan"
  if "division" in meta and meta.division != none {
    scope = "the " + meta.division + " of " + scope
  }
  // MIWB-FORM-005: the petition date and any conversion, dismissal or reinstatement (LBR 9004(c)).
  let petition = "The petition commencing the underlying Chapter " + case.chapter + " case was filed on " + dates.petition + ". " + dates.later
  // MIWB-FORM-007: the case this proceeding relates to, its name, number, chapter, district and division
  // (Fed. R. Bankr. P. 7008(a)).
  let relation = "This Adversary Proceeding arises in and relates to *In re " + debtor.name + "*, Case No. " + case.number + " (Chapter " + case.chapter + "), pending in " + scope + "."
  // MIWB-FORM-007: core or non-core, and consent to final judgment (LBR 7008).
  let core = if need(meta, "core") {
    "This Adversary Proceeding is a core proceeding under 28 U.S.C. § 157(b)(2). "
  } else {
    "This Adversary Proceeding is a non-core proceeding under 28 U.S.C. § 157(c). "
  }
  let consent = if need(meta, "consent") {
    "The Plaintiff consents to the entry of a final order or judgment by the Bankruptcy Court."
  } else {
    "The Plaintiff does not consent to the entry of a final order or judgment by the Bankruptcy Court."
  }
  (petition, relation, core + consent)
}

/// The body, chunk by chunk (blank-line separated): a heading; a list (lettered); a block quotation (not numbered,
/// half an inch in, on the body pitch); a WHEREFORE clause (the prayer's lead-in, not numbered); every other chunk a
/// numbered allegation. The statements the rules require come after the first paragraph under JURISDICTION.
#let allegations(meta, body) = {
  // Footnote definitions ("[^key]: text") are appended to each chunk that refers to them: cmarker renders one chunk
  // at a time, so a reference and its definition must be in the same string.
  let notes = (:)
  for line in body.split("\n") {
    if line.starts-with("[^") and line.contains("]:") {
      let key = line.slice(2, line.position("]:"))
      notes.insert(key, line.slice(line.position("]:") + 2).trim())
    }
  }
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "" and not c.starts-with("[^"))
  let n = 0
  let after-jurisdiction = false
  let generated-done = false
  let prayer = false
  for c in chunks {
    let t = c
    for (key, note) in notes.pairs() {
      if t.contains("[^" + key + "]") { t += "\n\n[^" + key + "]: " + note }
    }
    if t.starts-with("#") {
      prayer = false
      let level = t.match(regex("^(#+)")).captures.at(0).len()
      let s = t.replace(regex("^#+[ \t]*"), "")
      heading-block(level, s)
      // The Jurisdiction heading opens the section where the generated statements go.
      after-jurisdiction = lower(s).starts-with("jurisdiction") and not generated-done
    } else if t.match(regex("^(\\d+\\.|[-*+])[ \\t]")) != none {
      lettered(t, prayer)
    } else if t.starts-with(">") {
      block(width: 100%, above: 0pt, below: 0pt, pad(left: para-indent, {
        set par(first-line-indent: 0pt)
        unloose(inl(t.replace(regex("(?m)^>[ \t]?"), "")))
      }))
    } else if t.starts-with("WHEREFORE") {
      prayer = true
      body-par(inl(t))
    } else {
      n += 1
      body-par(inl(t), label: [#n.])
      if after-jurisdiction {
        for g in generated-statements(meta) {
          n += 1
          body-par(inl(g), label: [#n.])
        }
        after-jurisdiction = false
        generated-done = true
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
      lines((sig.signer + " (" + sig.bar_id + ")", sig.role))
      line-block(above: pitch-single)[BUSINESS ADDRESS:]
      lines(sig.address + ("Telephone " + sig.phone, "Email " + sig.email))
    },
  ))
}

// ---------------------------------------------------------------------------
// The pleading
// ---------------------------------------------------------------------------

#let miwb-adversary-complaint(meta, body) = {
  set document(title: need(meta, "title"), author: need(meta, "signature").signer)
  // Every page "Page n of N", bottom centre, in a single-spaced line box (Word's footer: PAGE and NUMPAGES).
  set page(
    paper: "us-letter",
    margin: page-margin,
    footer-descent: 30%,
    footer: context align(center, text(size: footer-size, ..edges(pitch-single),
      [Page #counter(page).display() of #counter(page).final().first()])),
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

  caption(meta)
  allegations(meta, body)
  signature-block(meta)
}
