// Adversary complaint, United States Bankruptcy Court, District of the Virgin Islands (vib).
//
// Rule-driven and content-agnostic. Requirement IDs (VIB-AC-...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed complaint, no forced line
// breaks. Every case word comes from the sample: the YAML frontmatter and the markdown body
// (markdown contract: ../README.md).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // VIB-AC-FONT: LBR 5005-1(B) names no face; Times New Roman (vendored, docs/FONTS.md), the exemplar's face
#let type-size = 12pt                    // VIB-AC-FONT: LBR 5005-1(B) "no smaller than 12 Courier or an equivalent"; 12 pt Times New Roman, footnotes and footer too
#let page-margin = 1in                   // VIB-AC-MARGIN: letter paper, one-inch margins on every side
#let text-width = 8.5in - 2 * page-margin
#let para-indent = 0.5in                 // first-line indent of every body paragraph; a paragraph's number starts here
#let number-box = 0.5in                  // the paragraph number's box: the text starts 1 in from the margin (docx: a tab)
#let cap-left = 3.45in                   // VIB-AC-CAPTION: the caption's party column (Form 416), ruled right and below
#let cap-pad = 0.2in                     // the text off the caption's vertical rule, on both sides
#let cap-top = 6pt                       // a caption row's text below its top
#let cap-bottom = 10pt                   // a caption row's text above its rule
#let cap-rule = 0.75pt                   // the caption's rules
#let designation-indent = 0.5in          // "Debtor.", "Plaintiff," and "Defendant." in from the party names
#let sig-col = 3.0in                     // VIB-AC-SIGNATURE: the signature column starts here
#let footer-page = 1.3in                 // the footer's "Page n of N" column, at the right; the short title wraps before it

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/vib-adversary-complaint.lua and
// docx/reference.xml set the same twips: 20 x pt).
#let pitch-body = 24pt                   // VIB-AC-SPACING: double spaced, as the exemplar
#let pitch-single = 13.8pt               // court header, caption, title, signature, footnotes, footer
#let caption-above = 24pt                // the court header to the caption
#let title-above = 24pt                  // the caption to the title
#let text-above = 13.8pt                 // the title to the text: a blank single line
#let sig-above = 24pt                    // the last paragraph to "Dated:"
#let sig-gap = 13.8pt                    // a blank single line between the parts of the signature block
#let note-gap = 7pt                      // between two footnotes (docx: Footnote Text 140 twips after)
#let note-clearance = 6pt                // the text to the footnote rule (LibreOffice reserves no more above a note)
// The footer: its last line box ends 0.3 in above the bottom edge and further lines stack upward, as Word
// sets a footer (docx: footer 432 twips); the footer area starts `footer-descent` below the text.
#let footer-descent = 6pt
#let footer-height = page-margin - footer-descent - 0.3in

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

#let need(meta, key) = {
  if key not in meta { panic("vib-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("vib-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline content without the paragraph breaks cmarker may put around it (they may not occur inside a paragraph).
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// Inline markdown (italics etc.).
#let inl(s) = unloose(cmarker.render(s, raw-typst: false, smart-punctuation: true))

/// Footnote definitions "[^n]: text" keyed by label; their chunks are taken out of the body.
#let footnote-defs(body) = {
  let d = (:)
  for m in body.matches(regex("(?m)^\\[\\^(\\w+)\\]:[ \\t]*(.+)$")) { d.insert(m.captures.at(0), m.captures.at(1)) }
  d
}

/// Inline markdown for one text segment; a space at either edge is kept (a footnote reference sits between two).
#let seg(s) = {
  let lead = if s.starts-with(" ") { [ ] } else { [] }
  let trail = if s.ends-with(" ") { [ ] } else { [] }
  lead + inl(s) + trail
}

/// Inline markdown with footnote references "[^n]" as typst footnotes.
#let rich(t, defs) = {
  let out = []
  let pos = 0
  for m in t.matches(regex("\\[\\^(\\w+)\\]")) {
    out += seg(t.slice(pos, m.start))
    out += footnote(inl(defs.at(m.captures.at(0))))
    pos = m.end
  }
  out + seg(t.slice(pos))
}

/// Single-pitch lines, one paragraph each; an empty item is a blank single line. `above`: the space before the
/// first; `left`: an indent of every line.
#let lines(items, above: 0pt, centered: false, left: 0pt) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  set align(center) if centered
  let gap = above
  for i in items {
    if i == "" { gap += pitch-single } else {
      block(width: 100%, above: gap, below: 0pt, pad(left: left, par(if type(i) == str { inl(i) } else { i })))
      gap = 0pt
    }
  }
}

// ---------------------------------------------------------------------------
// Court header, caption, title (VIB-AC-CAPTION: Form 416 layout, FRBP 7010, FRBP 9004(b), LBR 7008-1(A))
// ---------------------------------------------------------------------------

#let court-header(meta) = lines(centered: true, (
  "IN THE DISTRICT COURT OF THE VIRGIN ISLANDS",
  "DIVISION OF " + upper(need(meta, "division")) + ", BANKRUPTCY DIVISION",
).map(l => text(weight: "bold", l)))

/// A party: its names, then its designation in from them.
#let party(p) = {
  lines(p.names)
  lines((p.designation,), left: designation-indent)
}

/// The caption: two rows, the parties at the left in a column ruled on the right and below each row (Form 416), the
/// case information at the right: the chapter and case number beside the debtor, the adversary number (and a note)
/// beside the adversary parties.
#let caption-block(meta) = {
  let debtor = need(meta, "debtor")
  let adv = need(meta, "adversary")
  let sides = need(meta, "caption")
  let left-cell(body) = grid.cell(stroke: (right: cap-rule, bottom: cap-rule),
    inset: (top: cap-top, bottom: cap-bottom, right: cap-pad), body)
  let right-cell(body) = grid.cell(inset: (top: cap-top, bottom: cap-bottom, left: cap-pad), body)
  block(width: 100%, above: caption-above, below: 0pt, breakable: false, grid(
    columns: (cap-left, 1fr),
    left-cell({ lines(("In re:", "")); party(debtor) }),
    right-cell(lines((need(meta, "chapter"), "", "Case No. " + need(meta, "case_number")))),
    left-cell({ party(sides.at(0)); lines(("", "v.", "")); party(sides.at(1)) }),
    right-cell(lines(("Adv. Proc. No. " + adv.number,) + if "note" in adv { ("", adv.note) } else { () })),
  ))
}

#let title-block(meta) = lines(above: title-above, centered: true, (text(weight: "bold", upper(need(meta, "title"))),))

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (VIB-AC-NUMBER), headings, footnotes
// ---------------------------------------------------------------------------

/// A body paragraph on the double pitch, its first line indented; `label` (a number) in a box `number-box` wide.
#let body-par(label, content) = block(width: 100%, above: 0pt, below: 0pt, par({
  if label != none { box(width: number-box, label) }
  content
}))

/// Headings centred bold on the body pitch with no space of their own, kept with the block after them; the sample
/// writes them in the case it wants (the section headings in capitals).
#let heading-block(s) = block(width: 100%, above: 0pt, below: 0pt, sticky: true,
  align(center, par(first-line-indent: 0pt, text(weight: "bold", inl(s)))))

/// One chunk: a heading ("#", "##"), a numbered paragraph (a "1." item: every one is numbered from one counter
/// through the whole document, the typed number ignored; LBR 5005-1(A), FRCP 10(b)), or an unnumbered paragraph
/// (the opening and the prayer).
#let render-chunk(t, defs, n) = {
  let h = t.match(regex("^#+[ \\t]+"))
  if h != none { return (heading-block(t.slice(h.end)), n) }
  let m = t.match(regex("^\\d+\\.[ \\t]+"))
  if m != none {
    let n = n + 1
    return (body-par(str(n) + ".", rich(t.slice(m.end).replace(regex("\\s*\\r?\\n\\s*"), " "), defs)), n)
  }
  (body-par(none, rich(t.replace(regex("\\s*\\r?\\n\\s*"), " "), defs)), n)
}

// ---------------------------------------------------------------------------
// Signature block (VIB-AC-SIGNATURE, FRBP 9011 signing convention)
// ---------------------------------------------------------------------------

/// "Dated:" at the margin; each counsel group in the signature column ("By: /s/" the signer, when there is one, and
/// the lines), a "- and –" line between two groups; single-spaced, a blank single line between the parts.
#let signature-block(meta) = block(width: 100%, above: sig-above, below: 0pt, breakable: false, {
  lines(([Dated: #need(meta, "date")],))
  for (i, g) in need(meta, "signature").enumerate() {
    if i > 0 { lines(above: sig-gap, left: sig-col, ([\- and –],)) }
    let ls = if "signer" in g { ("By: /s/ " + g.signer,) } else { () }
    lines(above: sig-gap, left: sig-col, ls + g.lines)
  }
})

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let complaint(meta, md) = {
  let defs = footnote-defs(md)
  let chunks = md.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim())
    .filter(c => c != "" and c.match(regex("^\\[\\^\\w+\\]:")) == none)
  let short-title = upper(if "footer" in meta { meta.footer } else { need(meta, "title") })

  set document(title: need(meta, "title"))
  set page(
    paper: "us-letter",
    margin: page-margin,
    // VIB-AC-PAGE: "Page n of N" at the right, the short title at the left (the exemplar's footer).
    footer-descent: footer-descent,
    footer: context block(width: 100%, height: footer-height, align(bottom, {
      set text(..edges(pitch-single))
      set par(first-line-indent: 0pt)
      grid(columns: (1fr, footer-page),
        par(short-title),
        align(right + bottom, par[Page #counter(page).display() of #counter(page).final().first()]))
    })),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, footnote marks at 58 %, a section sign kept with its number. Lists are laid out here.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays whole and with its number ("§§ 157"): typst would break between the signs.
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // Footnotes at the type size, single-spaced (docx: Footnote Text in 13.8 pt boxes, 7 pt after), a short rule above.
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  court-header(meta)
  caption-block(meta)
  title-block(meta)
  v(text-above)

  // The last chunk is set with the signature block in one unbreakable block, so the signature never starts a page.
  assert(chunks.len() > 0 and not chunks.last().starts-with("#"),
    message: "vib-adversary-complaint: the body must end with a paragraph (the signature is set with it)")
  let n = 0
  for (i, t) in chunks.enumerate() {
    let (it, next) = render-chunk(t, defs, n)
    n = next
    if i == chunks.len() - 1 {
      block(width: 100%, breakable: false, above: 0pt, below: 0pt, { it; signature-block(meta) })
    } else { it }
  }
}
