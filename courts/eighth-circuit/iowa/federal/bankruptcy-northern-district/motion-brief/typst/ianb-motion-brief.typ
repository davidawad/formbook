// Motion with memorandum (brief), United States Bankruptcy Court, N.D. Iowa.
// Governing rules and the reading of each: ../README.md. Entry point: main.typ.
// The markdown body (usage/<id>.md) is rendered by cmarker; the metadata comes from the
// YAML frontmatter of the same file (fields listed in ../README.md).
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // vendored in fonts/. No N.D. Iowa rule names a font.
#let type-size = 12pt              // no rule sets a size; 12 pt is the convention of the filed exemplars
#let note-size = 11pt              // footnotes
#let para-indent = 0.5in           // first-line indent of every body paragraph
#let num-box = 24pt                // a ground's number, then the text at 0.5 in + 24 pt (Word: a tab stop at 1200 twips)
#let page-margin = 1in
#let text-width = 8.5in - 2 * page-margin

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/ianb-motion-brief.lua sets the same twips).
#let pitch-body = 24pt             // body double spaced
#let pitch-single = 13.8pt         // caption, signature block, certificate signature
#let pitch-note = 12.7pt           // footnotes, single spaced
#let pitch-footer = 12pt           // the 10 pt page footer
#let para-below = 7.2pt            // a paragraph's or numbered ground's space below it
#let heading-above = 12pt          // "#" and "##" headings
#let heading-below = 8.4pt         // "#" headings
#let argument-below = 7.2pt        // "##" argument headings
#let note-gap = 6pt                // between two footnotes
#let note-clearance = 12pt         // the body text to the footnote rule
#let court-below = 18pt            // caption: court name to the party block
#let caption-below = 14.4pt        // caption: party block to the text
#let party-col = 3.3in             // caption: the party block, ruled right and below
#let party-inset = 12pt            // caption: the party block's text stands off the vertical rule
#let party-pad = 10pt              // caption: the bottom rule stands off the last line
#let name-indent = 0.5in           // caption: the names, indented under "In re:"
#let case-inset = 16pt             // caption: the case numbers stand off the vertical rule
#let case-top = 2 * pitch-single   // caption: the case numbers start two lines down (on the party block's lines)
#let sig-above = 21.6pt            // signature block: space above
#let sig-left = 2.6in              // signature block: the column, 3.9 in at the right margin
#let sig-gap = 28.8pt              // signature block: room for the signature under "Respectfully submitted,"
#let role-gap = 12pt               // signature block: space above the role line
#let cert-above = 24pt             // certificate of service: space above its title
#let cert-gap = 7.2pt              // certificate: title to text
#let cert-sig = 14.4pt             // certificate: text to the signature

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("(?s)^---\n(.*?)\n---\n"))
  assert(m != none, message: "sample needs YAML frontmatter")
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  assert(key in meta, message: "frontmatter field missing: " + key)
  meta.at(key)
}

/// One block (a paragraph of its own), with an explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, body)

/// A line block indented by `left` (the block carries the space; pad would swallow it).
#let indented(left, above: 0pt, below: 0pt, body) = line-block(above: above, below: below, pad(left: left, body))

// ---------------------------------------------------------------------------
// Caption (FRBP 9004(b) and 7010; the layout follows the exemplars). A contested matter
// (no adversary_no) has the debtor block and case number only. Both columns on one line grid.
// ---------------------------------------------------------------------------

#let caption(meta) = {
  let adv = "adversary_no" in meta
  set text(..edges(pitch-single))
  line-block(align(center, text(weight: "bold")[UNITED STATES BANKRUPTCY COURT]))
  line-block(below: court-below, align(center, text(weight: "bold")[FOR THE NORTHERN DISTRICT OF IOWA]))
  let left = {
    line-block[In re:]
    indented(name-indent, above: pitch-single, inl(need(meta, "debtor")))
    line-block(above: pitch-single, align(right)[Debtor.])
    if adv {
      indented(name-indent, above: pitch-single, inl(need(meta, "plaintiff")))
      line-block(above: pitch-single, align(right)[Plaintiff,])
      indented(name-indent, above: pitch-single)[v.]
      indented(name-indent, above: pitch-single, inl(need(meta, "defendant")))
      line-block(above: pitch-single, align(right)[Defendant.])
    }
  }
  let right = {
    line-block(inl(need(meta, "chapter")))
    line-block(inl(need(meta, "case_no")))
    if adv { line-block(above: pitch-single, inl(meta.adversary_no)) }
    line-block(above: pitch-single, text(weight: "bold", inl(need(meta, "title"))))
  }
  block(above: 0pt, below: 0pt, grid(
    columns: (party-col, 1fr),
    block(width: 100%, inset: (right: party-inset, bottom: party-pad), stroke: (right: 0.75pt, bottom: 0.75pt), left),
    block(width: 100%, inset: (left: case-inset, top: case-top), right),
  ))
  // the space under the caption as a block of its own (Word: an empty paragraph of that height)
  block(above: 0pt, below: 0pt, height: caption-below, width: 100%)
}

/// "#" heading (the motion's own title and section names): centered bold, kept with what follows.
#let heading-block(t) = block(sticky: true, width: 100%, above: heading-above, below: heading-below,
  align(center, text(weight: "bold", inl(t))))

/// "##" argument heading (for example "I. PLAINTIFF HAS FAILED ..."): bold, at the margin.
#let argument-heading(t) = block(sticky: true, width: 100%, above: heading-above, below: argument-below,
  text(weight: "bold", inl(t)))

/// Footnote definitions (`[^N]: text` chunks). cmarker drops them, so the template places each
/// reference as a typst footnote.
#let note-defs(md) = {
  let d = (:)
  for c in md.split("\n\n").map(x => x.trim()) {
    let m = c.match(regex("^\\[\\^(\\d+)\\]:\\s*([\\s\\S]*)$"))
    if m != none { d.insert(m.captures.at(0), m.captures.at(1)) }
  }
  d
}

/// Paragraph text with `[^N]` references replaced by typst footnotes.
#let with-notes(s, notes) = {
  let pos = 0
  let out = []
  for m in s.matches(regex("\\[\\^(\\d+)\\]")) {
    out += inl(s.slice(pos, m.start))
    out += footnote(inl(notes.at(m.captures.at(0))))
    pos = m.end
  }
  out + inl(s.slice(pos))
}

// Footnote carry-over, as Word and LibreOffice set it: a line whose footnote does not fit below it moves to the next
// page with its note; typst keeps the line and sets the whole note on the next page. A footnote entry that lands on
// a later page than its mark flags its paragraph (<ianb-carry>, by the position of the paragraph's start, <ianb-ps>),
// and on the next layout pass the paragraph places an empty float at the foot of its page that ends the text half a
// line below the top of the mark's line, so that line moves on with its note. Once placed, the float stands (the
// layout converges); a paragraph without such a note is laid out exactly as before. Only a mark on the page its
// paragraph starts on is carried this way.
#let carry-start() = context {
  let me = here().position()
  let prev = query(<ianb-float>).filter(f => f.value.ps == me)
  let flags = query(<ianb-carry>).filter(f => f.value.ps == me and f.value.ref.page == me.page)
  let h = if prev.len() > 0 { prev.first().value.h } else if flags.len() > 0 {
    page.height - page-margin - (flags.first().value.ref.y - 0.8 * pitch-body) - 0.5 * pitch-body
  } else { 0pt }
  if h > 0pt {
    place(bottom, float: true, clearance: 0pt, block(width: 0pt, height: h, [#metadata((ps: me, h: h))<ianb-float>]))
  }
  [#metadata(none)<ianb-ps>]
}

/// The flag of carry-start, from inside a footnote entry: the note is on a later page than its mark.
#let carry-check(note) = context {
  let ref = note.location()
  let starts = query(selector(<ianb-ps>).before(ref))
  if starts.len() > 0 and here().page() > ref.page() {
    [#metadata((ps: starts.last().location().position(), ref: ref.position()))<ianb-carry>]
  }
}

/// Body paragraph with the half-inch first-line indent.
#let body-para(body) = block(width: 100%, above: 0pt, below: para-below,
  [#carry-start()#par(first-line-indent: (amount: para-indent, all: true), body)])

/// Items of a markdown ordered list, one string per item (continuation lines are joined).
#let list-items(c) = {
  let out = ()
  for line in c.split("\n") {
    let m = line.match(regex("^\\s*\\d+\\.\\s+(.*)$"))
    if m != none {
      out.push(m.captures.at(0))
    } else if out.len() > 0 {
      let k = out.len() - 1
      out.at(k) = out.at(k) + " " + line.trim()
    }
  }
  out
}

/// Body chunks are blank-line separated. `#` is a centered bold heading (the motion's own
/// title and section names); `##` is a bold argument heading. A numbered-list item is a ground or
/// fact numbered by the template (FRBP 9013(b): the motion states its grounds with particularity),
/// restarting under each heading. Other paragraphs are unnumbered.
#let render-body(md) = {
  let notes = note-defs(md)
  let n = 0
  for c in md.split("\n\n").map(x => x.trim()).filter(x => x != "") {
    if c.match(regex("^\\[\\^\\d+\\]:")) != none {
      continue
    } else if c.starts-with("## ") {
      n = 0
      argument-heading(c.slice(3))
    } else if c.starts-with("# ") {
      n = 0
      heading-block(c.slice(2))
    } else if c.match(regex("^\\d+\\. ")) != none {
      for it in list-items(c) {
        n += 1
        body-para[#box(width: num-box)[#n.]#with-notes(it, notes)]
      }
    } else {
      body-para(with-notes(c, notes))
    }
  }
}

/// Signature block (FRBP 9011; N.D. Iowa L.R. 9010-1(b): business address, telephone,
/// e-mail and FAX below the signature). The date (when given) at the margin, the signature in a column at sig-left.
#let signature(meta) = {
  let s = need(meta, "signature")
  set text(..edges(pitch-single))
  block(breakable: false, above: sig-above, below: 0pt, {
    if "date" in s {
      line-block[#box(width: sig-left)[Dated: #s.date]Respectfully submitted,]
    } else {
      indented(sig-left)[Respectfully submitted,]
    }
    indented(sig-left, above: sig-gap, text(style: "italic")[/s/ #s.signer])
    indented(sig-left)[#s.signer, #s.bar]
    for l in s.address { indented(sig-left)[#l] }
    indented(sig-left)[#s.firm]
    indented(sig-left)[Telephone: #s.phone]
    indented(sig-left)[Fax: #s.fax]
    indented(sig-left)[E-mail: #s.email]
    indented(sig-left, above: role-gap)[#s.role]
  })
}

/// Certificate of service (FRBP 9013-3): the date and the manner of service must appear.
#let certificate-of-service(meta) = {
  let sv = need(meta, "service")
  block(breakable: false, above: cert-above, below: 0pt, {
    line-block(below: cert-gap, text(..edges(pitch-single), align(center, text(weight: "bold")[CERTIFICATE OF SERVICE])))
    body-para[The undersigned certifies that on #sv.date, #sv.manner.]
    set text(..edges(pitch-single))
    line-block(above: cert-sig, align(right, text(style: "italic")[/s/ #sv.by]))
    line-block(align(right)[#sv.by])
  })
}

#let motion-brief(meta, md) = {
  set page(
    paper: "us-letter",
    margin: page-margin,
    footer-descent: 30%,
    footer: context align(center, text(size: 10pt, ..edges(pitch-footer))[
      Page #counter(page).display() of #counter(page).final().first()
    ]),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, footnote marks at 58 %. The template writes its own numbered paragraphs (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)
  set footnote.entry(separator: line(length: 30%, stroke: 0.5pt), gap: note-gap, clearance: note-clearance, indent: 0pt)
  show footnote.entry: it => {
    set text(size: note-size, ..edges(pitch-note))
    set par(first-line-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#carry-check(note)#super(num)#h(0.25em)#note.body]
  }
  // FRBP 9013(b): a motion must set out the relief requested. The check is a keyword test only.
  assert(md.contains("relief") or md.contains("requests") or md.contains("request"), message: "FRBP 9013(b): the motion must set out the relief requested")
  caption(meta)
  render-body(md)
  signature(meta)
  certificate-of-service(meta)
}
