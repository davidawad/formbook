// Memorandum in support of a motion to dismiss for the U.S. District Court for the District of Rhode Island (rid).
// Rules: Fed. R. Civ. P. 7(b)(1) (grounds stated with particularity), 12(b)(6); D.R.I. LR Cv 5(a)(1)-(5) (form of
// papers: 8 1/2 x 11, caption with judge's initials after docketing, title, double spacing, at least 12-point type,
// footnotes at least 10-point, page numbers bottom center, signature block); LR Cv 7(a)(2)(A)-(B) (motion states
// grounds and argument; a memorandum is an attachment to the motion, not a separate docket entry); LR Cv 7(c)
// (statement on oral argument and evidentiary hearing).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
// See ../README.md.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout convention; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // Times New Roman substitute per docs/FONTS.md, vendored in fonts/; LR Cv 5(a)(3) sets no typeface, only the size
#let type-size = 12pt                   // LR Cv 5(a)(3): at least 12-point font
#let footnote-size = 10pt               // LR Cv 5(a)(3): footnotes at least 10-point, may be single-spaced
#let margin = 1in                       // convention (no D.R.I. margin rule); page number sits in the bottom margin
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let quote-indent = 0.5in               // block quotations are indented on both sides
#let caption-left = 3.4in               // width of the party column of the caption
#let caption-gutter = 0.25in            // between the party column's rule and the case-number column
#let caption-inset = 8.6pt              // the party text stands off the caption's right rule, and its last line off the bottom rule
#let number-inset = 0.1in               // the case number stands off the start of its column
#let sig-left = 2.9in                   // width of the left column of the signature block
#let sig-gutter = 0.2in                 // between the signature block's columns

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 27.6pt              // LR Cv 5(a)(3) double spacing: Word's "double" for 12 pt Times, the pitch of both filed exemplars (RID-FORM-009)
#let pitch-single = 13.8pt              // a single line: 1.15 x the type size (Word's single line in this face)
#let pitch-note = 11.5pt                // a footnote line, single-spaced (LR Cv 5(a)(3)): 1.15 x the footnote size
#let note-gap = 7pt                     // between two footnotes (Word: Footnote Text's space after)
#let note-clearance = 6pt               // from the text to the footnote rule: with note-gap, the room LibreOffice keeps above a footnote (its separator line); 2 to 9 pt break every page of the sample alike

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("rid-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, links, footnote references, smart punctuation) for one run of text.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line block (a paragraph of its own), with explicit space above it; an empty one is a blank
/// line of the single pitch.
#let line-block(above: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if body == [] or body == "" { block(height: pitch-single) } else { body }
})

/// Roman numerals for heading level 1 (I to XX is enough for a memorandum).
#let roman(n) = (
  "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X",
  "XI", "XII", "XIII", "XIV", "XV", "XVI", "XVII", "XVIII", "XIX", "XX",
).at(n - 1)

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

/// The caption: the party names on the left (closed by a rule on the right and below) and the civil action
/// number on the right, with the judge's initials (LR Cv 5(a)(1)).
#let caption(meta) = {
  let number = if "case_number" in meta and meta.case_number != "" {
    "C.A. No. " + meta.case_number
  } else {
    "C.A. No. ______________"
  }
  block(above: pitch-double, below: 0pt, grid(
    columns: (caption-left, caption-gutter, 1fr),
    block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-inset, bottom: caption-inset), {
      for (k, p) in meta.caption.parties.enumerate() {
        if k > 0 { line-block[v.] }
        for n in p.names { line-block(inl(n)) }
        line-block(inl(p.designation))
      }
    }),
    [],
    pad(left: number-inset, {
      line-block(inl(number))
      if "jury_demand" in meta and meta.jury_demand {
        line-block(above: pitch-double, strong("JURY TRIAL DEMANDED"))
      }
    }),
  ))
}

#let cover(meta) = {
  line-block(align(center, strong("UNITED STATES DISTRICT COURT")))
  line-block(align(center, strong("FOR THE DISTRICT OF RHODE ISLAND")))
  caption(meta)
  block(width: 100%, sticky: true, above: pitch-double, below: pitch-single, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    align(center, strong(inl(meta.brief_title)))
  })
}

// ---------------------------------------------------------------------------
// Body: headings (auto-numbered at levels 1 and 2), paragraphs, block quotations, footnotes
// ---------------------------------------------------------------------------

/// Level 1: centered bold capitals with a roman numeral (I., II., ...). Level 2: bold, "A.", "B.", ... at the
/// left. Level 3: bold, at the left, exactly as written (a level-3 heading that numbers itself keeps its number).
/// At the body pitch with no space of their own (the double pitch sets them off). Sticky: a heading never ends a
/// page.
#let heading-block(level, n1, n2, text-md) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
  set par(first-line-indent: 0pt)
  if level == 1 {
    align(center, strong[#roman(n1). #upper(inl(text-md))])
  } else if level == 2 {
    strong[#("ABCDEFGHIJKLMNOPQRSTUVWXYZ".at(n2 - 1)). #inl(text-md)]
  } else {
    strong(inl(text-md))
  }
})

/// Footnote definitions in the body (`[^key]: text`) are collected first. Each paragraph is rendered with the
/// definitions of the keys it refers to, so cmarker resolves every reference to a typst footnote.
#let collect-footnotes(chunks) = {
  let defs = (:)
  for t in chunks {
    if t.starts-with("[^") {
      let m = t.match(regex("^\\[\\^([^\\]]+)\\]:[ \\t]*"))
      if m != none { defs.insert(m.captures.at(0), t.slice(m.end)) }
    }
  }
  defs
}

#let footnote-source(t, defs) = {
  let keys = t.matches(regex("\\[\\^([^\\]]+)\\]")).map(m => m.captures.at(0)).dedup()
  let out = t
  for k in keys {
    if k in defs { out += "\n\n[^" + k + "]: " + defs.at(k) }
  }
  out
}

/// A body paragraph at the double pitch with a first-line indent.
#let body-par(content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), content))

/// The body: chunks separated by blank lines. A heading (#...), a block quotation (>...), a list, or a paragraph.
/// Paragraphs are not numbered (a memorandum is not a pleading); each has a first-line indent.
#let body-content(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let defs = collect-footnotes(chunks)
  let n1 = 0
  let n2 = 0
  for t in chunks {
    if t.starts-with("[^") {
      // a footnote definition: rendered as a footnote where it is referenced
    } else if t.starts-with("#") {
      let level = t.match(regex("^#+")).end
      if level == 1 {
        n1 += 1
        n2 = 0
      } else if level == 2 {
        n2 += 1
      }
      heading-block(level, n1, n2, t.slice(level).trim())
    } else if t.starts-with(">") {
      // LR Cv 5(a)(3): "all documents shall be double-spaced": the quotation too, indented on both sides
      let quoted = t.split(regex("\\r?\\n")).map(l => l.trim().trim(">", at: start).trim()).join(" ")
      block(width: 100%, above: 0pt, below: 0pt, inset: (left: quote-indent, right: quote-indent),
        par(first-line-indent: 0pt, inl(footnote-source(quoted, defs))))
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // list items: the label at the margin in a half-inch box, the text hanging after it
      block(width: 100%, above: 0pt, below: 0pt, inl(footnote-source(t, defs)))
    } else {
      body-par(inl(footnote-source(t, defs)))
    }
  }
}

/// The oral argument statement (LR Cv 7(c)): "requested" with the estimated time, or "not requested".
#let oral-argument(meta) = {
  let oa = meta.oral_argument
  let statement = if oa.requested {
    "Oral argument and evidentiary hearing are requested" + if "minutes" in oa and oa.minutes != none { "; the estimated time is " + str(oa.minutes) + " minutes." } else { "." }
  } else {
    "Oral argument and evidentiary hearing are not requested."
  }
  block(width: 100%, above: 0pt, below: 0pt, breakable: false,
    par(first-line-indent: (amount: para-indent, all: true), [#strong[Statement on oral argument.] #statement]))
}

/// The signature block (LR Cv 5(a)(5)): optional lead line ("Respectfully submitted,"), the party line, the
/// signers with bar numbers, then the firm's address, telephone, and email. Kept on one page.
#let signature(meta) = block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
  let sig = meta.signature
  grid(
    columns: (sig-left, sig-gutter, 1fr),
    line-block(if "date" in meta [Dated: #inl(meta.date)] else []),
    [],
    {
      if "lead" in sig { line-block(inl(sig.lead)); line-block([]) }
      for l in sig.party { line-block(inl(l)) }
      for s in sig.signers {
        line-block(above: pitch-single, inl("/s/ " + s.name))
        line-block(inl(if "bar" in s and s.bar != "" { s.name + " " + s.bar } else { s.name }))
      }
      for (i, l) in sig.firm.enumerate() { line-block(above: if i == 0 { pitch-single } else { 0pt }, inl(l)) }
    },
  )
})

/// The certificate of service (LR Cv 5(a)(5) signature; the text comes from the sample's frontmatter): its
/// heading, the text, and the first signer's "/s/" lines in the signature column. Kept on one page.
#let certificate(meta) = if "certificate_of_service" in meta {
  let cos = meta.certificate_of_service
  let signer = meta.signature.signers.at(0)
  block(width: 100%, above: pitch-double, below: 0pt, breakable: false, {
    block(width: 100%, above: 0pt, below: 0pt, align(center, strong("CERTIFICATE OF SERVICE")))
    body-par(inl(cos.text))
    block(width: 100%, above: pitch-single, below: 0pt, pad(left: sig-left + sig-gutter, {
      line-block(inl("/s/ " + signer.name))
      line-block(inl(if "bar" in signer and signer.bar != "" { signer.name + " " + signer.bar } else { signer.name }))
    }))
  })
}

#let rid-motion-brief(meta, body) = {
  // The caption, the title, and the signature are required (LR Cv 5(a)(1), (2), (5); Fed. R. Civ. P. 10(a) as
  // applied to motions by Rule 7(b)(2)). Missing fields fail the build.
  assert("caption" in meta and "parties" in meta.caption, message: "rid-motion-brief: the sample needs caption.parties")
  assert("brief_title" in meta, message: "rid-motion-brief: the sample needs brief_title")
  assert("signature" in meta, message: "rid-motion-brief: the sample needs a signature block (LR Cv 5(a)(5))")
  assert("oral_argument" in meta, message: "rid-motion-brief: the sample needs oral_argument (LR Cv 7(c))")

  set document(title: meta.brief_title)
  // LR Cv 5(a)(3): page numbers bottom center, arabic, on every page; the number in a single-spaced line box
  // (Word's footer).
  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch; list items as a label box (para-indent) with the text hanging.
  show: xengine.with(pitch: pitch-double, list-indent: para-indent)
  // A doubled sign stays with its number ("§§ 157"), as the Word filter binds it (xengine binds one sign).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // A sign repeated with a space ("§ § 1331") stays with its number too, as the Word filter binds each sign.
  show regex("[§¶]( [§¶])+ \\S+"): it => box(it)
  // Footnotes at 10 pt, single-spaced (LR Cv 5(a)(3)), the mark and a space before the note (Word's Footnote Text).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: footnote-size, ..edges(pitch-note))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }
  set enum(numbering: "1.")

  cover(meta)
  body-content(body)
  oral-argument(meta)
  signature(meta)
  certificate(meta)
}
