// Complaint for the U.S. District Court for the District of Rhode Island (rid).
// Rules: Fed. R. Civ. P. 8(a), 10(a), 10(b), 10(c); D.R.I. LR Cv 5(a)(1)-(5): 8 1/2 x 11 paper, full caption,
// title, double spacing, at least 12-point type, page numbers bottom center, signature block with bar number,
// firm address, fax and email; LR Cv 5(a)(4): jury demand to the right of the caption, below the case number.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
// See ../README.md.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout convention; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // Times New Roman substitute per docs/FONTS.md, vendored in fonts/; LR Cv 5(a)(3) sets no typeface, only the size
#let type-size = 12pt                   // LR Cv 5(a)(3): at least 12-point font
#let margin = 1in                       // convention (no D.R.I. margin rule); page number sits in the bottom margin
#let para-indent = 0.5in                // first-line indent of numbered paragraphs; the number stands here
#let number-box = 0.5in                 // the paragraph number's box: the text of the first line starts an inch in
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

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("rid-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, links, smart punctuation) for one run of text.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line block (a paragraph of its own), with explicit space above it; an empty one is a blank
/// line of the single pitch.
#let line-block(above: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if body == [] or body == "" { block(height: pitch-single) } else { body }
})

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

/// The caption: the party names on the left (closed by a rule on the right and below), the civil action
/// number on the right, and the jury demand below it (LR Cv 5(a)(4)).
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
// Body: numbered paragraphs (Fed. R. Civ. P. 10(b)), headings, prayer, signature
// ---------------------------------------------------------------------------

/// Heading level 1 is centered bold; level 2 is centered bold italic; level 3 is bold, left; at the body pitch, with
/// no space of their own (the double pitch sets them off). Sticky: a heading never ends a page.
#let heading-block(level, text-md) = {
  let c = inl(text-md)
  block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
    set par(first-line-indent: 0pt)
    if level == 1 {
      align(center, strong(c))
    } else if level == 2 {
      align(center, strong(emph(c)))
    } else {
      strong(c)
    }
  })
}

/// A body paragraph at the double pitch: numbered (the number in a box after the first-line indent) or not.
#let body-par(num, content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true),
    if num == none { content } else { [#box(width: number-box, [#num.])#content] }))

/// Splits the body into blank-line-separated chunks, and renders each: a heading, a list, an unnumbered
/// prayer ("WHEREFORE" paragraph), or a numbered allegation. The template numbers the allegations itself.
#let body-content(body) = {
  let n = 0
  for t in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "") {
    if t.starts-with("#") {
      let level = t.match(regex("^#+")).end
      heading-block(level, t.slice(level).trim())
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // prayer items: the label half an inch in, the text a box after it
      block(width: 100%, above: 0pt, below: 0pt, pad(left: para-indent, inl(t)))
    } else if t.starts-with("WHEREFORE") {
      body-par(none, inl(t))
    } else {
      n += 1
      body-par(n, inl(t))
    }
  }
}

/// The signature block (LR Cv 5(a)(5)): party line, "By ... attorneys", the signers with bar numbers,
/// then the firm's address, telephone, fax and email. Kept on one page.
#let signature(meta) = block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
  let sig = meta.signature
  grid(
    columns: (sig-left, sig-gutter, 1fr),
    line-block(if "date" in meta [Dated: #inl(meta.date)] else []),
    [],
    {
      if "lead" in sig { line-block(inl(sig.lead)); line-block([]) }
      for l in sig.party { line-block(inl(l)) }
      for (i, s) in sig.signers.enumerate() {
        line-block(above: pitch-single, inl("/s/ " + s.name))
        line-block(inl(if "bar" in s and s.bar != "" { s.name + " " + s.bar } else { s.name }))
      }
      for (i, l) in sig.firm.enumerate() { line-block(above: if i == 0 { pitch-single } else { 0pt }, inl(l)) }
    },
  )
})

#let rid-complaint(meta, body) = {
  // A complaint must name every party in the title (Rule 10(a)): the caption carries them all.
  assert("caption" in meta and "parties" in meta.caption, message: "rid-complaint: the sample needs caption.parties")
  assert("brief_title" in meta, message: "rid-complaint: the sample needs brief_title")
  assert("signature" in meta, message: "rid-complaint: the sample needs a signature block (LR Cv 5(a)(5))")

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
  // A sign repeated with a space ("§ § 1331", as filed) stays with its number too, as the Word filter binds each sign.
  show regex("[§¶]( [§¶])+ \\S+"): it => box(it)
  set enum(numbering: "(a)")

  cover(meta)
  body-content(body)
  signature(meta)
}
