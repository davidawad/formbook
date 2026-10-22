// Adversary complaint, United States Bankruptcy Court for the District of North Dakota (ndb).
//
// Rules (text checked 2026-10-14; see ../README.md for the table):
//   FRBP 7003   commencing an adversary proceeding by complaint
//   FRBP 7010   Fed. R. Civ. P. 10 applies; the caption substantially conforms to Form 416
//   FRCP 10(a)  caption: court name, title, file number, Rule 7(a) designation
//   FRCP 10(b)  claims in numbered paragraphs
//   FRBP 9004   legibility (a); caption contents (b)
//   FRBP 7008(a) the reference to the case (name, number, chapter, district) and the statement whether
//               the pleader consents to entry of final orders by the bankruptcy court
//   FRBP 9011(a) signed by an attorney, with address and telephone number
// No type-size or spacing rule appears in the D.N.D. Bankr. L.R. (2023); the form choices below
// follow the rules above and the filed exemplar (README.md, "Layout choices").
//
// Content-agnostic: every case-specific word comes from the sample's YAML frontmatter, never from this
// file. No coordinates, no forced line breaks, no lists (not needed by this form).
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the numbers in this file; each traces to a rule or a layout choice)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // vendored in fonts/; the filed exemplar is Times New Roman (README: Known gaps)
#let type-size = 12pt              // FRBP 9004(a) legibility; the exemplar is 12 pt
#let para-indent = 0.5in           // first-line indent of body paragraphs; the paragraph number's box after it
#let caption-left = 3.4in          // width of the party column of the caption
#let caption-mid = 0.3in           // the column of ")" marks
#let caption-step = 0.5in          // indent of a party's designation ("Plaintiff,") in the caption
#let quote-indent = 0.5in          // quotations: indented both sides, single spaced
#let sig-left = 3.0in              // signature: the "Dated" column; the signer's lines to the right of it
#let note-gap = 7pt                // space between two footnotes (Word: Footnote Text 140 twips after)

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt         // a single line: 1.15 x the type size (Word's single line in this face)
#let pitch-double = 2 * pitch-single // double spacing as Word sets it for 12 pt type (the exemplar's body)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ndb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A required metadata field; a missing one fails the build with its name.
#let need(meta, key) = {
  if key not in meta { panic("ndb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Inline markdown (italics, bold, smart quotes) as content. A straight double quote between a non-space character and
/// a space (or the end) closes a quotation, as pandoc reads it for the docx engine (cmarker opens it after a
/// closing single quote: ’" would print ’“).
#let inl(s) = cmarker.render(s.replace(regex("(\\S)\"(\\s|$)"), m => m.captures.at(0) + "”" + m.captures.at(1)),
  raw-typst: false, smart-punctuation: true)

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  body
})

/// Single-spaced lines; an empty string is a blank single line before the next one.
#let line-stack(items) = {
  let gap = 0pt
  for t in items {
    if t == "" { gap += pitch-single } else { line-block(above: gap, inl(t)); gap = 0pt }
  }
}

/// The court's name (FRBP 9004(b)(1)); the same for every filing in this court.
#let court-name = ("IN THE UNITED STATES BANKRUPTCY COURT", "FOR THE DISTRICT OF NORTH DAKOTA")

// ---------------------------------------------------------------------------
// Caption (FRBP 7010 / Form 416: court, debtor, parties, case and adversary numbers, title)
// ---------------------------------------------------------------------------

/// Rows of the left column as (text, indent level, right-column text). One row is one single-spaced line (one
/// grid row), so the ")" column (one mark per row) and the case block stand at the party column's lines. The case
/// number and chapter stand at the debtor's first lines, the adversary number at the first party's first line.
#let caption-rows(meta) = {
  let c = need(meta, "caption")
  let rows = ()
  if "debtors" in c {
    rows.push(("In re:", 0, ""))
    for d in c.debtors { rows.push((d, 0, "")) }
    if "debtor_designation" in c { rows.push((c.debtor_designation, 1, "")) }
    rows.push(("", 0, ""))
  }
  let first-party = rows.len()
  for (k, p) in c.parties.enumerate() {
    if k > 0 {
      rows.push(("v.", 0, ""))
      rows.push(("", 0, ""))
    }
    for n in p.names { rows.push((n, 0, "")) }
    rows.push((p.designation, 1, ""))
  }
  let case-at = if "debtors" in c { 1 } else { 0 }
  rows.at(case-at).at(2) = "Case No. " + need(meta, "case_number")
  rows.at(case-at + 1).at(2) = need(meta, "chapter")
  let adv-at = calc.max(first-party, case-at + 3)
  rows.at(adv-at).at(2) = "Adversary No. " + need(meta, "adversary_number")
  rows
}

#let caption(meta) = block(width: 100%, above: pitch-double, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  grid(
    columns: (caption-left, caption-mid, 1fr),
    ..caption-rows(meta).map(r => (
      pad(left: r.at(1) * caption-step, if r.at(0) == "" { [~] } else { inl(r.at(0)) }),
      align(center, ")"),
      inl(r.at(2)),
    )).flatten(),
  )
})

#let cover(meta) = {
  for t in court-name { line-block(align(center, strong(t))) }
  caption(meta)
  line-block(above: pitch-double, below: pitch-single, align(center, strong(inl(need(meta, "title")))))
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// Footnote definitions: chunks "[^id]: text". Returns array of (id, text).
#let footnote-defs(body) = {
  let pairs = ()
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")) {
    let t = c.trim()
    if t.starts-with("[^") {
      let m = t.match(regex("^\\[\\^([^\\]]+)\\]:[ \\t]*([\\s\\S]*)$"))
      if m == none { panic("ndb-adversary-complaint: malformed footnote definition") }
      pairs.push((m.captures.at(0), m.captures.at(1).trim()))
    }
  }
  pairs
}

/// Inline markdown with footnote references "[^id]" replaced by real footnotes.
#let with-footnotes(t, pairs) = {
  let parts = (t,)
  for (id, note) in pairs {
    let next = ()
    for p in parts {
      if type(p) == str {
        for (k, s) in p.split("[^" + id + "]").enumerate() {
          if k > 0 { next.push(footnote(inl(note))) }
          next.push(s)
        }
      } else {
        next.push(p)
      }
    }
    parts = next
  }
  parts.map(p => if type(p) == str { inl(p) } else { p }).join()
}

/// A body paragraph at the double pitch: first-line indented (`indent: false`: flush left, a continuation); a
/// numbered one (FRCP 10(b)) has its number in a box of the paragraph indent after the indent.
#let body-par(num, content, indent: true) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: if indent { para-indent } else { 0pt }, all: true),
    if num == none { content } else { [#box(width: para-indent, [#num.])#content] }))

/// A heading: one centered bold line at the body pitch, kept with the text after it (a heading never ends a page).
#let heading-block(t) = {
  let level = t.match(regex("^#+")).text.len()
  let txt = t.slice(level).trim()
  block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
    set par(first-line-indent: 0pt)
    align(center, strong(inl(txt)))
  })
}

/// A quotation: single spaced, indented both sides, a single line of space above and below it.
#let quotation(content) = block(width: 100%, above: pitch-single, below: pitch-single,
  pad(left: quote-indent, right: quote-indent, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    content
  }))

/// Body chunks (blank-line separated markdown). Rules for the chunk kinds:
///   "# ..."      heading (centered, bold)
///   "> ..."      quotation (indented, single spaced, not numbered)
///   "~ ..."      continuation of the previous paragraph (not numbered, flush left)
///   "WHEREFORE"  prayer paragraph (not numbered; the complaint's prayer is not a claim)
///   anything else  a numbered paragraph (FRCP 10(b))
#let body-blocks(body, pairs) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "" and not c.trim().starts-with("[^"))
  let n = 0
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      heading-block(t)
    } else if t.starts-with(regex("^[-*+][ \t]|^\\d+\\.[ \t]")) {
      panic("ndb-adversary-complaint: lists are not supported by this template (README: Known gaps)")
    } else if t.starts-with(">") {
      quotation(with-footnotes(t.slice(1).trim(), pairs))
    } else if t.starts-with("~") {
      body-par(none, with-footnotes(t.slice(1).trim(), pairs), indent: false)
    } else if t.starts-with("WHEREFORE") {
      body-par(none, with-footnotes(t, pairs))
    } else {
      n += 1
      body-par(n, with-footnotes(t, pairs))
    }
  }
}

/// Signature block (FRBP 9011(a)): date at left; closing, "By: /s/ signer" and the signer's address,
/// telephone and e-mail at right. Lines come from the sample's frontmatter.
#let signature(meta) = {
  let s = need(meta, "signature")
  let items = ()
  if "closing" in s { items.push(s.closing); items.push("") }
  items.push("By: /s/ " + need(s, "signer"))
  items.push("")
  items += need(s, "lines")
  block(width: 100%, breakable: false, above: pitch-single, below: 0pt, grid(
    columns: (sig-left, 1fr),
    line-block[Dated: #need(meta, "date")],
    line-stack(items),
  ))
}

/// The whole complaint: cover, lead-in (unnumbered), numbered body, the consent statement (unnumbered,
/// FRBP 7008(a), placed after the prayer so the paragraph numbers the body cross-refers to do not move),
/// signature.
#let ndb-adversary-complaint(meta, body) = {
  // The page number: centered in a single-spaced line box, at the same place on every page (Word's footer).
  set page(
    paper: "us-letter",
    margin: 1in,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (double spaced).
  show: xengine.with(pitch: pitch-double, list-indent: none)
  // Footnotes: single spaced at the type size, flush left (Word's Footnote Text), a 7 pt gap between two.
  set footnote.entry(gap: note-gap, indent: 0pt)
  show footnote.entry: set text(size: type-size, ..edges(pitch-single))
  show footnote.entry: set par(first-line-indent: 0pt)
  cover(meta)
  if "lead_in" in meta { body-par(none, inl(meta.lead_in)) }
  body-blocks(body, footnote-defs(body))
  // the consent statement stays with the signature (no signature alone on a page)
  block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
    body-par(none, inl(need(meta, "consent_statement")))
    signature(meta)
  })
}
