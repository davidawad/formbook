// U.S. District Court, District of Massachusetts: memorandum of law supporting a motion (Fed. R. Civ. P. 7(b),
// 12(b)(6); D. Mass. L.R. 5.1, 7.1(a)(2), 7.1(b)(1), 7.1(b)(4)). Requirement IDs (MAD-...) and the rule text are
// in ../README.md and ../../rules.md. Content-agnostic: every case-specific word comes from the sample's frontmatter
// or markdown body, never from this file. The markdown body is rendered by cmarker. No forced line breaks, no
// coordinates measured off the exemplar.

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a named style choice; see ../README.md)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")     // MAD-FORM-002: L.R. 5.1 sets no typeface; Times New Roman substitute per docs/FONTS.md, vendored in fonts/
#let type-size = 12pt                // MAD-FORM-004: L.R. 5.1 sets no size; 12 pt, the size of the filed exemplars
#let note-size = 12pt                // footnotes at the type size (single-spaced, L.R. 5.1(a)(2)); size is a style choice
#let page-margin = 1in               // MAD-FORM-004: no rule (L.R. 5.1(a)(2) sets paper size only); 1 inch as filed
#let para-indent = 0.5in             // first-line indent of body paragraphs; the hanging indent of level 2 and 3 headings
#let quote-indent = 0.5in            // quotations, indented on both sides
#let caption-left = 3.5in            // width of the party column of the caption (its rule included; wide enough that a party name does not wrap a word)
#let caption-gutter = 0.25in         // between the party column and the case number
#let caption-inset = 10pt            // the party column's text stops this far from its rules
#let caption-right-inset = 0.1in     // the case number column starts this far after the gutter
#let caption-rule = 0.75pt           // the rule on the right and below the party column
#let designation-indent = 1.25in     // "Plaintiff," / "Defendant." in the party column
#let vs-indent = 0.5in               // "v." in the party column
#let sig-indent = 3.0in              // left edge of the signature block

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt             // MAD-FORM-001: double-spaced text (L.R. 5.1(a)(2)), twice the type size
#let pitch-single = 13.8pt           // caption, title, quotations, footnotes, counsel: single-spaced (exempt under L.R. 5.1(a)(2)), 1.15 x the type size
#let note-gap = 7pt                  // between two footnotes (Word: Footnote Text's space after)
#let note-clearance = 12pt          // from the text to the first footnote, the separator in it: LibreOffice sets a line 19.2 pt above the footnote area, which typst at 12.6 pt (the ca3 value) refused

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mad-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, smart quotes) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, indent: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: indent, body)
})

/// Lines at an indent, the first with `above` before it.
#let group(lines, above, indent: 0pt) = for (i, l) in lines.enumerate() {
  line-block(above: if i == 0 { above } else { 0pt }, indent: indent, l)
}

// ---------------------------------------------------------------------------
// Caption (MAD-CAP-001..003: court name, title, civil action number)
// ---------------------------------------------------------------------------

#let court-title() = {
  for l in ("IN THE UNITED STATES DISTRICT COURT", "FOR THE DISTRICT OF MASSACHUSETTS") {
    line-block(align(center, text(weight: "bold", l)))
  }
}

/// The party column, closed by a rule on its right and below (each party's names, its designation a single line
/// lower and indented, "v." between the parties, a single line off each side); the civil action number to its
/// right.
#let caption(meta) = {
  let left = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { left.push(line-block(above: pitch-single, indent: vs-indent, inl("v."))) }
    for (j, n) in p.names.enumerate() {
      left.push(line-block(above: if j == 0 and k > 0 { pitch-single } else { 0pt }, inl(n)))
    }
    left.push(line-block(above: pitch-single, indent: designation-indent, inl(p.designation)))
  }
  block(above: pitch-double, below: 0pt, grid(
    columns: (caption-left, 1fr),
    column-gutter: caption-gutter,
    block(width: caption-left, stroke: (right: caption-rule, bottom: caption-rule),
      inset: (right: caption-inset, bottom: caption-inset), left.join()),
    pad(left: caption-right-inset, line-block[Civil Action No. #meta.case_number]),
  ))
}

// ---------------------------------------------------------------------------
// Body: headings, paragraphs, quotations
// ---------------------------------------------------------------------------

/// Body paragraphs are not numbered (a memorandum, unlike a complaint, has no numbered paragraphs). Each
/// blank-line-separated chunk is one paragraph with a first-line indent at the double pitch; a `#` chunk is a
/// heading, a `>` chunk a quotation, a list chunk a list.
#let paragraphs(body) = {
  // Footnote definitions (`[^key]: text`, one line each) are collected here and attached to the chunk that
  // cites them: cmarker resolves a reference only against a definition in the same render call, and the body
  // is rendered one chunk at a time.
  let defs = (:)
  for m in body.matches(regex("(?m)^\\[\\^([^\\]]+)\\]:[ \\t]*(.*)$")) {
    defs.insert(m.captures.at(0), m.captures.at(1))
  }
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "" and not c.trim().starts-with("[^"))
  for c in chunks {
    let t = c.trim()
    for (k, v) in defs {
      if t.contains("[^" + k + "]") { t = t + "\n\n[^" + k + "]: " + v }
    }
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(">") {
      // A quotation: single-spaced (L.R. 5.1(a)(2) exempts quotations), indented on both sides, a single line off
      // the text above and below.
      let q = t.split("\n").map(l => l.trim().trim(">", at: start).trim()).join("\n")
      block(width: 100%, above: pitch-single, below: pitch-single, {
        set text(..edges(pitch-single))
        set par(first-line-indent: 0pt)
        pad(left: quote-indent, right: quote-indent, md(q))
      })
    } else {
      block(width: 100%, above: 0pt, below: 0pt, par(md(t)))
    }
  }
}

// ---------------------------------------------------------------------------
// Signature, certificates
// ---------------------------------------------------------------------------

/// The signature block (MAD-SIG-001: the board of bar overseers number under each attorney's name, L.R. 5.1(a)(1)):
/// the date at the margin, then at the signature indent the lead lines, the /s/ line, each attorney and the firm, a
/// single line apart. It never breaks across a page.
#let signature(meta) = {
  let sig = meta.signature
  block(breakable: false, width: 100%, above: pitch-double, below: 0pt, {
    line-block[DATED: #meta.date]
    group(sig.lead.map(inl), pitch-double, indent: sig-indent)
    group((inl("By: /s/ " + sig.signer),), pitch-single, indent: sig-indent)
    for a in sig.attorneys {
      group((inl(a.name + " (BBO# " + a.bbo + ")"), inl(a.email)), pitch-single, indent: sig-indent)
    }
    group(sig.firm.map(inl), pitch-single, indent: sig-indent)
  })
}

/// Certificate of service (MAD-CERT-001). Fed. R. Civ. P. 5(d)(1)(B): no certificate is required when the paper
/// is served by filing it with the court's electronic-filing system; the certificate is rendered when the sample has
/// one. It never breaks across a page.
#let service-block(meta) = {
  if "service" in meta {
    let svc = meta.service
    block(breakable: false, width: 100%, above: pitch-double, below: 0pt, {
      line-block(align(center, text(weight: "bold", "CERTIFICATE OF SERVICE")))
      block(width: 100%, above: pitch-single, below: 0pt, par(first-line-indent: (amount: para-indent, all: true),
        [I hereby certify that on #svc.date, a true copy of the foregoing document was electronically filed through the Court’s ECF system on all counsel of record:]))
      for c in svc.counsel { group(c.map(inl), pitch-single) }
      group((inl("/s/ " + meta.signature.signer), inl(meta.signature.signer)), pitch-double)
    })
  }
}

/// Certificate of consultation (MAD-CERT-002: L.R. 7.1(a)(2)). Rendered when the sample carries `consultation`.
#let consultation-block(meta) = {
  if "consultation" in meta {
    block(breakable: false, width: 100%, above: pitch-double, below: 0pt, {
      line-block(align(center, text(weight: "bold", "CERTIFICATE OF CONSULTATION")))
      block(width: 100%, above: pitch-single, below: 0pt,
        par(first-line-indent: (amount: para-indent, all: true), inl(meta.consultation)))
    })
  }
}

// ---------------------------------------------------------------------------
// Entry
// ---------------------------------------------------------------------------

#let mad-motion-brief(meta, body) = {
  // Page numbers centered (MAD-FORM-005), at the type size, in a single-spaced line box.
  set page(
    paper: "us-letter",
    margin: page-margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (MAD-FORM-001: double-spaced).
  show: xengine.with(pitch: pitch-double, list-indent: para-indent)
  // A doubled sign stays with its number ("§§ 1331"), as the Word filter binds it (xengine binds one sign).
  show regex("[§¶]{2,} \\S+"): it => box(it)

  // Headings at the type size and the body pitch, no space of their own: level 1 centered bold capitals; levels 2
  // and 3 bold at the left, hanging half an inch (the argument's I., II., ...). Sticky: a heading never ends a page.
  show heading: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    let b = if it.level == 1 { align(center, text(weight: "bold", upper(it.body))) } else {
      par(hanging-indent: para-indent, text(weight: "bold", it.body))
    }
    block(sticky: true, width: 100%, above: 0pt, below: 0pt, b)
  }

  // Footnotes: at the type size, single-spaced (L.R. 5.1(a)(2)), the mark and a space before the note (Word's
  // Footnote Text); a footnote is kept whole on one page.
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: note-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    block(breakable: false, [#super(num)#h(0.25em)#note.body])
  }

  court-title()
  caption(meta)
  // The title of the memorandum, centered bold capitals, single-spaced (title of the case, L.R. 5.1(a)(2)).
  block(width: 100%, above: pitch-double, below: pitch-single, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    align(center, text(weight: "bold", upper(inl(meta.title))))
  })

  paragraphs(body)

  signature(meta)
  service-block(meta)
  consultation-block(meta)
}
