// Motion to dismiss with incorporated memorandum for the U.S. District Court for the Southern District of
// Florida (flsd). Rules: S.D. Fla. L.R. 5.1(a) (paper, margins, spacing, type size, pagination, caption,
// signature block); L.R. 5.2 (certificate of service); L.R. 7.1(a)(1) (the motion incorporates its memorandum),
// 7.1(a)(3) (conferral certificate not required for a motion to dismiss for failure to state a claim),
// 7.1(c)(2) (20-page limit for a motion and its incorporated memorandum; the title page, signature page and
// certificate of service do not count). Fed. R. Civ. P. 7(b), 12(b)(6). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // no font rule in L.R. 5.1; Times New Roman, the house default (docs/FONTS.md), as in the exemplar
#let type-size = 12pt                   // L.R. 5.1(a)(4): fonts no smaller than 12 point, footnotes included
#let page-w = 8.5in                     // L.R. 5.1(a)(3): standard 8 1/2 x 11 inch paper
#let page-h = 11in
#let margin = 1in                       // L.R. 5.1(a)(4): 1 inch on top, bottom and each side
#let para-indent = 0.5in                // first-line indent of body paragraphs; level-3 headings stand in by it
#let style-width = 3.25in               // L.R. 5.1(a)(5)(C): the style fills no more than the left side of the page
#let sig-indent = style-width + 0.25in  // the signature column starts right of the style column

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // a single line: 1.15 x the type size (headings, caption, signature, footnotes)
#let pitch-double = 2 * pitch-single    // L.R. 5.1(a)(4): at least 1 1/2 spaces; double, as in the exemplar
#let caption-gap = pitch-double         // between the parts of the caption, and before the body
#let note-gap = 7pt                     // between two footnotes (Word: Footnote Text 140 twips after)
#let note-clearance = 12.6pt            // between the body and the footnote separator (LibreOffice's footnote area)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("flsd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in italics, links, footnote references).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: below,
  sticky: below > 0pt, pad(left: left, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    body
  }))

/// A body paragraph at the double pitch, first line indented.
#let body-par(content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), content))

// ---------------------------------------------------------------------------
// Caption: court (L.R. 5.1(a)(5)(A)), docket line (B), style on the left (C), title (D)
// ---------------------------------------------------------------------------

#let caption(meta) = {
  line-block(align(center, text(weight: "bold", "UNITED STATES DISTRICT COURT")))
  line-block(align(center, text(weight: "bold", "SOUTHERN DISTRICT OF FLORIDA")))
  if "division" in meta { line-block(align(center, text(weight: "bold", upper(meta.division)))) }
  // Docket line centered across the page (L.R. 5.1(a)(5)(B)): category, number, assigned judges.
  line-block(above: caption-gap, align(center, "CIVIL CASE NO. " + meta.case_number))
  // The style (L.R. 5.1(a)(5)(C)): each party's names, then its designation; "v." between the parties; "/" closes it.
  block(width: style-width, above: caption-gap, below: 0pt, {
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { line-block("v.") }
      for n in p.names { line-block(inl(n)) }
      line-block(inl(p.designation))
    }
    line-block("/")
  })
  line-block(above: caption-gap, below: caption-gap, align(center, text(weight: "bold", upper(meta.title))))
}

// ---------------------------------------------------------------------------
// Body: unnumbered paragraphs (a motion is not a pleading; Fed. R. Civ. P. 10(b) does not apply)
// ---------------------------------------------------------------------------

/// Each blank-line-separated chunk of markdown is a heading, a list, or a paragraph. Numbering is not used.
#let body-chunks(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // cmarker does not convert markdown footnotes: `[^key]: text` is a definition (collected here, not printed),
  // `[^key]` in a paragraph is a reference, rendered as a typst footnote.
  let notes = (:)
  for c in chunks {
    let m = c.trim().match(regex("^\\[\\^([^\\]]+)\\]:[ \\t]*"))
    if m != none { notes.insert(m.captures.at(0), c.trim().slice(m.end)) }
  }
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(regex("^\\[\\^[^\\]]+\\]:")) {
      // a footnote definition: printed at its reference
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      md(t)
    } else {
      // cmarker trims a piece's outer spaces: a space next to a footnote reference is put back.
      let piece(s) = [#if s.starts-with(" ") [ ]#inl(s)#if s.ends-with(" ") [ ]]
      let out = []
      let last = 0
      for r in t.matches(regex("\\[\\^([^\\]]+)\\]")) {
        if r.start > last { out += piece(t.slice(last, r.start)) }
        out += footnote(inl(notes.at(r.captures.at(0))))
        last = r.end
      }
      if last < t.len() { out += piece(t.slice(last)) }
      body-par(out)
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (L.R. 5.1(a)(6)), certificate of service (L.R. 5.2): neither breaks across a page
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
  line-block[Dated: #meta.date]
  line-block(above: pitch-double, left: sig-indent)[Respectfully submitted,]
  // L.R. 5.1(a)(6): name, street address, telephone, e-mail and bar number of each counsel.
  line-block(above: pitch-double, left: sig-indent, inl("By: s/ " + meta.signature.signer))
  for l in meta.signature.lines { line-block(left: sig-indent, inl(l)) }
})

#let certificate-of-service(meta) = if "service" in meta {
  let s = meta.service
  block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
    line-block(below: pitch-single, align(center, text(weight: "bold", "CERTIFICATE OF SERVICE")))
    body-par("I HEREBY CERTIFY that on this " + s.date + ", I electronically filed the foregoing document with the Clerk of the Court using CM/ECF. I also certify that the foregoing document is being served this day on all counsel of record in the manner specified, either via transmission of Notices of Electronic Filing generated by CM/ECF or in some other authorized manner for those counsel or parties who are not authorized to receive electronically Notices of Electronic Filing.")
    line-block(above: pitch-double, left: sig-indent, inl("s/" + s.signer))
    line-block(left: sig-indent, inl(s.signer))
    line-block(above: pitch-double, below: pitch-single, text(weight: "bold", "SERVICE LIST"))
    for l in s.list { line-block(inl(l)) }
  })
}

// ---------------------------------------------------------------------------
// Entry
// ---------------------------------------------------------------------------

#let flsd-motion-brief(meta, body) = {
  // Paginated consecutively at the bottom center of each page (L.R. 5.1(a)(4)); the number in a single-spaced
  // line box, so it sits where Word's footer does.
  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    numbering: "1",
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (double-spaced); list items as a label box with the text hanging.
  show: xengine.with(pitch: pitch-double, list-indent: para-indent)

  // Footnotes are 12 point and single-spaced (L.R. 5.1(a)(4)): the mark, a space, the note.
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt,
    separator: line(length: 1.5in, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)   // the entry does not inherit the body's leading
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  // Headings at the body size, bold and single-spaced, a single line above and below: level 1 centered capitals;
  // level 2 at the margin (argument point, I., II.); level 3 half an inch in (a., b.). The numbers are typed in
  // the sample. Sticky: a heading never ends a page.
  show heading: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt)
    let b = if it.level == 1 { align(center, text(weight: "bold", upper(it.body))) } else if it.level == 2 {
      text(weight: "bold", it.body)
    } else { pad(left: para-indent, text(weight: "bold", it.body)) }
    block(sticky: true, width: 100%, above: pitch-single, below: pitch-single, b)
  }

  caption(meta)
  body-chunks(body)
  signature-block(meta)
  certificate-of-service(meta)
}
