// U.S. Bankruptcy Court, Middle District of Georgia: motion with memorandum (FRBP 9013; LBR 9013-1,
// 9013-3; caption per Official Form 416D as the Clerk's Instructions require, LBR 9004-2).
//
// Rule-driven and content-agnostic. Requirement IDs (GAMB-...) refer to ../README.md, which quotes
// the rule text. No case-specific text, no coordinates measured off the exemplar, no forced line
// breaks. The body is markdown rendered by cmarker; the metadata is the YAML frontmatter of the
// same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or is a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")    // No font rule for motions in this court (GAMB-FORM-002); Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                    // Style choice: 12 pt, the size of the filed exemplars (no rule sets a size). See ../README.md.
#let footnote-size = 12pt
#let margins = (top: 1in, bottom: 1in, x: 1in)  // GAMB-FORM-001 (paper and margins: style choice, no local rule).
#let para-indent = 0.5in
#let sig-column = 3.2in                  // Signature and certificate blocks sit in the right-hand column.
#let caption-left = 3.6in                // Caption: party column; the right column carries case information.
#let caption-inset = 0.2in               // the party text stands off the caption's right rule
#let right-inset = 0.35in                // the case information stands off the rule
#let v-indent = 1.2in                    // "v." in the party column
#let role-indent = 2.2in                 // a party's role ("Plaintiff,") in the party column
#let title-inset = 0.325in               // the title is set in the middle 90 % of the line
#let quote-inset = 0.75in                // block quotations, both sides

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-body = 24pt                   // Double spacing for the body (GAMB-FORM-003, style choice; see ../README.md).
#let pitch-single = 13.8pt               // a single line: 1.15 x the type size (Word's single line in this face)
#let gap = pitch-body / 2                // between the caption's groups, around headings and quotations
#let quote-gap = pitch-single / 2        // between the paragraphs of a block quotation
#let note-gap = 7pt                      // after each footnote (Word: Footnote Text's space after)

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics, quotes, section signs) as content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("gamb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("gamb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-spaced paragraph with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: left, body)
})

// ---------------------------------------------------------------------------
// Caption (GAMB-CAP-001 to GAMB-CAP-004)
// ---------------------------------------------------------------------------

/// Form 416D caption: parties on the left, case information on the right, closed by a rule on the
/// right and bottom of the party column.
#let caption(meta) = {
  let parties = need(meta, "parties")
  let left = {
    for (i, p) in parties.enumerate() {
      // "v." between the plaintiff side and the defendant side; none between the debtor and the rest.
      if i > 0 and parties.at(i - 1).kind != "debtor" { line-block(above: gap, below: gap, left: v-indent)[v.] }
      if p.kind == "debtor" { line-block(below: gap)[In re:] }
      for n in p.names { line-block(inl(n)) }
      line-block(left: role-indent, inl(p.role))
    }
  }
  let adversary = need(meta, "adversary_number")
  let right = {
    line-block(below: gap)[Bankruptcy Case No. #need(meta, "case_number")]
    line-block(below: gap)[Chapter #need(meta, "chapter")]
    line-block[Adversary Proceeding No. #if adversary == "" { "________" } else { adversary }]
  }
  block(above: pitch-body, below: pitch-body, grid(
    columns: (caption-left, 1fr),
    block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-inset, bottom: gap), left),
    pad(left: right-inset, right),
  ))
}

// ---------------------------------------------------------------------------
// Signature and certificate of service (GAMB-SIG-001 to GAMB-SIG-004)
// ---------------------------------------------------------------------------

/// One signature block per attorney (LBR 9011-1(b): name, bar number, address, telephone and email
/// in immediate proximity to the signature). The "/s/" line is the electronic signature; a body line
/// stands above each block.
#let attorney-blocks(meta) = {
  let at = 6.5in - sig-column
  for s in need(meta, "signature") {
    line-block(above: pitch-body, left: at)[/s/ #s.signer]
    for l in (s.signer, s.bar, ..s.firm, s.phone, s.email) { line-block(left: at, inl(l)) }
    if s.role != "" { line-block(left: at, emph(inl(s.role))) }
  }
}

#let signature-block(meta) = block(breakable: false, above: pitch-body, below: 0pt, {
  line-block(need(meta, "dated"))
  attorney-blocks(meta)
})

/// Certificate of service: the parties served, the method, the date and the attorney's signature
/// (LBR 9013-3(a)). Parties served through CM/ECF need no address under that rule.
#let certificate-of-service(meta) = block(breakable: false, above: pitch-body, below: 0pt, {
  let svc = need(meta, "service")
  line-block(below: gap, align(center, strong[Certificate of Service]))
  block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: (amount: para-indent, all: true))[I certify that on #svc.date I filed the foregoing with the Clerk of Court using the CM/ECF system, which will send notification of the filing to the parties listed below who are registered CM/ECF users. I further certify that I served by first-class United States mail, postage prepaid, the parties listed below who are not registered CM/ECF users.])
  line-block(above: gap, strong[Served through CM/ECF:])
  for l in svc.ecf { line-block(inl(l)) }
  line-block(above: gap, strong[Served by first-class mail:])
  for l in svc.mail { line-block(inl(l)) }
  attorney-blocks(meta)
})

// ---------------------------------------------------------------------------
// The motion with memorandum
// ---------------------------------------------------------------------------

#let gamb-motion-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "title", "case_number", "chapter", "adversary_number", "parties", "dated", "signature", "service") {
    let _ = need(meta, k)
  }

  // ---- document-wide settings ----
  // A centered page number on every page, in a single-spaced line box (Word's footer).
  set page(paper: "us-letter", margin: margins, numbering: "1", footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set document(title: need(meta, "title"), author: need(meta, "signature").at(0).signer)
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number ("§§ 1334"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)
  // A double quotation mark after closing punctuation closes a quotation: cmarker opens one that has no opening
  // mark in the same paragraph (a quotation over several block-quoted paragraphs); pandoc closes it.
  show regex("[.,;:!?)]\u{201C}"): it => it.text.replace("\u{201C}", "\u{201D}")

  // Footnotes: 12 pt, single-spaced; the mark, a space, the note (Word's footnote layout).
  set footnote.entry(gap: note-gap, clearance: 12.6pt, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: footnote-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }
  // Headings as typed by the author (no automatic numbering: the memorandum's own I., A. labels stay); single-spaced,
  // half a body line above and below, kept with the text: level 1 centered bold capitals, level 2 bold, level 3 bold
  // italic.
  show heading: it => block(width: 100%, above: gap, below: gap, sticky: true, {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt)
    if it.level == 1 { align(center, strong(upper(it.body))) }
    else if it.level == 2 { strong(it.body) }
    else { strong(emph(it.body)) }
  })
  // Block quotations: indented 0.75 in on both sides, single-spaced, a half line between their paragraphs.
  show quote.where(block: true): it => block(width: 100%, above: gap, below: gap, pad(x: quote-inset, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, spacing: quote-gap)
    it.body
  }))

  // ---- court title, caption, title ----
  for l in need(meta, "court") { line-block(align(center, strong(inl(l)))) }
  caption(meta)
  line-block(below: gap, pad(x: title-inset, align(center, strong(upper(inl(need(meta, "title")))))))

  // ---- body, signature, certificate of service ----
  cmarker.render(md, raw-typst: false, smart-punctuation: true)
  signature-block(meta)
  certificate-of-service(meta)
}
