// Memorandum in support of a motion, United States Bankruptcy Court for the District of North Dakota (ndb),
// filed in an adversary proceeding.
//
// Rules (text checked 2026-10-14; see ../README.md for the table):
//   FRBP 9013(b) a motion states its grounds with particularity and the relief requested
//   D.N.D. Bankr. L.R. 7007-1(B) a non-dispositive motion in an adversary case is filed with a memorandum
//                 in support, not to exceed 20 pages (dispositive motions: 40 pages, 25 of argument)
//   D.N.D. Bankr. L.R. 9013-1(A) interested parties have 14 days to respond to a motion under FRBP 9013
//   FRBP 7010   Fed. R. Civ. P. 10 applies; the caption substantially conforms to Form 416
//   FRCP 10(a)  caption: court name, title, file number, Rule 7(a) designation
//   FRCP 10(b)  claims and grounds in numbered paragraphs (the memorandum numbers every paragraph)
//   FRBP 9004   legibility (a); caption contents (b)
//   FRBP 9011(a) signed by an attorney, with address and telephone number
// No type-size or spacing rule appears in the D.N.D. Bankr. L.R. (2023); the form choices below
// follow the rules above and the filed exemplar (README.md, "Layout choices").
//
// Content-agnostic: every case-specific word comes from the sample's YAML frontmatter, never from this
// file. No coordinates, no forced line breaks, no lists (not needed by this form).
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the numbers in this file; each traces to a rule or a layout choice)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // vendored in fonts/; the filed exemplar is Times New Roman (README: Known gaps)
#let type-size = 12pt              // FRBP 9004(a) legibility; the exemplar is 12 pt
#let pitch = 27.6pt               // double spacing as Word sets it for 12 pt type: 2 x 13.8 pt (single-spaced line, 1.15 em)
#let body-leading = pitch - 0.65em // leading that makes the baseline pitch 27.6 pt: EB Garamond line box is 0.65 em
#let single-leading = 0.5em        // caption, counsel, quotations, signature: single spaced
#let para-indent = 0.5in           // first-line indent of numbered paragraphs
#let number-gap = 0.25in           // gap between a paragraph number and its text
#let caption-left = 3.4in          // width of the party column of the caption
#let caption-mid = 0.3in           // the column of ")" marks
#let quote-indent = 0.5in          // quotations: indented both sides, single spaced

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ndb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A required metadata field; a missing one fails the build with its name.
#let need(meta, key) = {
  if key not in meta { panic("ndb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Inline markdown (italics, bold, smart quotes) as content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// A single-spaced stack of lines. An empty string keeps the height of a line.
#let single(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => if i == "" { [~] } else { inl(i) }))
}

/// The court's name (FRBP 9004(b)(1)); the same for every filing in this court.
#let court-name = ("IN THE UNITED STATES BANKRUPTCY COURT", "FOR THE DISTRICT OF NORTH DAKOTA")

// ---------------------------------------------------------------------------
// Caption (FRBP 7010 / Form 416: court, debtor, parties, case and adversary numbers, title)
// ---------------------------------------------------------------------------

/// Rows of the left column as (text, indent level). One row is one single-spaced line, so the
/// ")" column (one mark per row) lines up with the text.
#let caption-rows(c) = {
  let rows = ()
  if "debtors" in c {
    rows.push(("In re:", 0))
    for d in c.debtors { rows.push((d, 0)) }
    if "debtor_designation" in c { rows.push((c.debtor_designation, 1)) }
    rows.push(("", 0))
  }
  for (k, p) in c.parties.enumerate() {
    if k > 0 {
      rows.push(("v.", 0))
      rows.push(("", 0))
    }
    for n in p.names { rows.push((n, 0)) }
    rows.push((p.designation, 1))
  }
  rows
}

#let caption-left-column(rows) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..rows.map(r => block(width: caption-left, pad(
    left: r.at(1) * 0.5in,
    if r.at(0) == "" { [~] } else { inl(r.at(0)) },
  ))))
}

#let caption(meta) = {
  let rows = caption-rows(need(meta, "caption"))
  grid(
    columns: (caption-left, caption-mid, 1fr),
    caption-left-column(rows),
    single(rows.map(_ => ")")),
    align(horizon, single((
      "Case No. " + need(meta, "case_number"),
      need(meta, "chapter"),
      "",
      "Adversary No. " + need(meta, "adversary_number"),
    ))),
  )
}

#let cover(meta) = {
  align(center, single(court-name.map(t => "**" + t + "**")))
  v(pitch)
  caption(meta)
  v(pitch)
  align(center, strong(inl(need(meta, "title"))))
  v(pitch)
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
      if m == none { panic("ndb-motion-brief: malformed footnote definition") }
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

/// A heading: one centered bold line, kept with the text after it (a heading never ends a page).
#let heading-block(t) = {
  let level = t.match(regex("^#+")).text.len()
  let txt = t.slice(level).trim()
  block(width: 100%, above: 0pt, below: body-leading, sticky: true, align(center, strong(inl(txt))))
}

/// Body chunks (blank-line separated markdown). Rules for the chunk kinds:
///   "# ..."      heading (centered, bold)
///   "> ..."      quotation (indented, single spaced, not numbered)
///   "~ ..."      continuation of the previous paragraph (not numbered, flush left)
///   anything else  a numbered paragraph (FRCP 10(b)); the memorandum's conclusion is numbered too
#let body-blocks(body, pairs, tail: []) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "" and not c.trim().starts-with("[^"))
  let out = []
  let n = 0
  let tail-done = false
  let last = chunks.len() - 1
  for (i, c) in chunks.enumerate() {
    let t = c.trim()
    if t.starts-with("#") {
      out += heading-block(t)
    } else if t.starts-with(regex("^[-*+][ \t]|^\\d+\\.[ \t]")) {
      panic("ndb-motion-brief: lists are not supported by this template (README: Known gaps)")
    } else if t.starts-with(">") {
      let q = t.slice(1).trim()
      out += block(width: 100%, above: 0pt, below: body-leading, pad(left: quote-indent, right: quote-indent, {
        set par(leading: single-leading, spacing: 0pt, justify: false)
        with-footnotes(q, pairs)
      }))
    } else if t.starts-with("~") {
      out += block(width: 100%, above: 0pt, below: body-leading, with-footnotes(t.slice(1).trim(), pairs))
    } else {
      n += 1
      let para = [#h(para-indent)#(str(n) + ".")#h(number-gap)#with-footnotes(t, pairs)]
      if i == last {
        // the signature stays with the last paragraph it signs (no signature alone on a page)
        out += block(width: 100%, breakable: false, above: 0pt, below: 0pt, { para; tail })
        tail-done = true
      } else {
        out += block(width: 100%, above: 0pt, below: body-leading, para)
      }
    }
  }
  if not tail-done { out += tail }
  out
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
  block(width: 100%, breakable: false, above: pitch, below: 0pt, grid(
    columns: (3.0in, 1fr),
    [Dated: #need(meta, "date")],
    single(items),
  ))
}

/// Optional certificate of service after the signature: a centered heading, then the sample's paragraphs
/// (unnumbered). The exemplar has none, so it is only rendered when the sample supplies one.
#let certificate(meta) = {
  if "certificate_of_service" in meta {
    block(width: 100%, above: pitch, below: body-leading, sticky: true, align(center, strong[CERTIFICATE OF SERVICE]))
    for p in meta.certificate_of_service {
      block(width: 100%, above: 0pt, below: body-leading, [#h(para-indent)#inl(p)])
    }
  }
}

/// The whole memorandum: cover (caption, title), lead-in (unnumbered, if any), numbered body, signature,
/// optional certificate of service.
#let ndb-motion-brief(meta, body) = {
  cover(meta)
  if "lead_in" in meta {
    block(width: 100%, above: 0pt, below: body-leading, [#h(para-indent)#inl(meta.lead_in)])
  }
  body-blocks(body, footnote-defs(body), tail: signature(meta))
  certificate(meta)
}
