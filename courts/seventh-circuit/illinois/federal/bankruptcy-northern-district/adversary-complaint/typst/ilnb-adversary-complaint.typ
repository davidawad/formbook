// U.S. Bankruptcy Court, Northern District of Illinois: adversary complaint (Fed. R. Bankr. P. 7001, 7010).
//
// Rule-driven and content-agnostic. Requirement IDs (ILNB-...) refer to ../README.md, which quotes the rule
// text: Fed. R. Bankr. P. 7010 (caption and form of pleadings), 9004(b); Fed. R. Civ. P. 10 (as applied by 7010);
// N.D. Ill. Bankr. L.R. 5005-1(C), 5005-2, 7003-1 (effective Sept. 1, 2024). No case-specific text, no
// coordinates measured off the exemplar, no forced line breaks. The markdown body is rendered by cmarker; the
// metadata comes from the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")         // ILNB-FORM-002: a proportionally spaced font; Times New Roman substitute per docs/FONTS.md. Vendored in /fonts.
#let type-size = 12pt                    // ILNB-FORM-002: at least 12 point, footnotes included (the rule floor).
#let page-margin = 1in                   // ILNB-FORM-004: no margin less than one inch.
#let para-indent = 0.5in                 // first-line indent of text, numbered paragraphs and prayer items.
#let number-box = 0.4in                  // a paragraph number's (or prayer letter's) box; the text follows it and wraps to the margin.
#let caption-left = 3.4in                // width of the party column of the caption (its rules on the right and bottom).
#let caption-inset = 0.15in              // the party text stands off the column's right rule.
#let caption-rule = 0.75pt               // the caption's rules; Word adds the bottom rule's width to the caption's height.
#let caption-gutter = 0.3in              // the case column stands off the rule.
#let designation-indent = 1.4in          // "Debtor.", "Plaintiff," under the party's names.
#let sig-column = 2.7in                  // the signature column starts this far in ("Dated" and the city to its left).

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-body = 27.6pt                 // ILNB-FORM-003: double spacing, Word's double line in this face at 12 pt (2 x 13.8 pt), as in the filed complaint.
#let pitch-single = 13.8pt               // a single line, 1.15 x the type size: court lines, caption, title, headings, footnotes, signature (ILNB-FORM-003 exception, README.md).
#let gap = pitch-single                  // between the court lines and the division, around headings, between the caption's groups.
#let small-gap = gap / 2                 // between the rows of the case column, and between counsel groups.
#let big-gap = pitch-body                // around the caption and the title, before the signature.
#let note-gap = 7pt                      // after each footnote (Word: Footnote Text's space after).
#let note-clearance = 12.6pt             // between the text and the footnote rule (Word's separator line).

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Stop with a message when a required metadata field is missing.
#let need(meta, key) = {
  if key not in meta { panic("ilnb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ilnb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (a frontmatter value): smart quotes and emphasis, as pandoc reads it in the docx engine.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced paragraph with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: left, body)
})

/// Rendered markdown without the paragraph breaks around it (it goes inside one paragraph).
#let trim-breaks(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// A double-spaced paragraph: the first line indented, a label (number or letter) in its box, the text wrapping to
/// the margin.
#let body-par(label: none, body) = par(if label == none { trim-breaks(body) } else [#box(width: number-box, label)#trim-breaks(body)])

// ---------------------------------------------------------------------------
// Court heading and caption (ILNB-CAP-001..003)
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  line-block(align(center, strong[IN THE UNITED STATES BANKRUPTCY COURT]))
  line-block(below: gap, align(center, strong[FOR THE NORTHERN DISTRICT OF ILLINOIS]))
  line-block(below: big-gap, align(center, strong(upper(inl(need(meta, "division"))))))
}

/// The caption: the party column (debtor, then the adversary parties) and the case column (chapter,
/// case number, adversary number, judge). Form 416 wording; the rule requires the case number, chapter,
/// judge and the division (ILNB-CAP-001..003).
#let caption(meta) = {
  let cap = need(meta, "caption")
  let party(p) = {
    for n in p.names { line-block(inl(n)) }
    line-block(left: designation-indent, inl(p.designation))
  }
  let left = {
    line-block(below: gap)[In re:]
    party(cap.in_re)
    if "adversary" in cap and cap.adversary != none {
      for (k, p) in cap.adversary.parties.enumerate() {
        if k > 0 { line-block(above: gap)[v.] }
        block(above: gap, below: 0pt, party(p))
      }
    }
  }
  let rows = ()
  if "chapter" in cap { rows.push(inl(cap.chapter)) }
  rows.push[Case No. #inl(cap.case_number)]
  if "adversary" in cap and cap.adversary != none { rows.push[Adv. Pro. No. #inl(cap.adversary.number)] }
  if "judge" in cap { rows.push(inl(cap.judge)) }
  block(above: 0pt, below: 0pt, grid(
    columns: (caption-left, 1fr),
    block(width: 100%, stroke: (right: caption-rule, bottom: caption-rule),
      inset: (right: caption-inset, bottom: gap + caption-rule), left),
    pad(left: caption-gutter, for (i, r) in rows.enumerate() {
      line-block(below: if i < rows.len() - 1 { small-gap } else { 0pt }, r)
    }),
  ))
}

#let cover(meta) = {
  court-title(meta)
  caption(meta)
  line-block(above: big-gap, below: big-gap, align(center, strong(upper(inl(need(meta, "title"))))))
}

// ---------------------------------------------------------------------------
// Signature block (ILNB-SIG-001..002): the signing attorney's name, mailing address, email and telephone
// (LBR 5005-2(C)(6)). Single spaced, like the filed exemplar; "Dated" and the city at the margin, the signature
// column to their right; kept together.
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, breakable: false, above: big-gap, below: 0pt, {
    line-block[#box(width: sig-column)[Dated: #inl(sig.date)]s/ #inl(sig.signer)]
    line-block(inl(sig.city))
    for (k, g) in sig.counsel.enumerate() {
      if k > 0 { line-block(above: small-gap, left: sig-column)[#"- and -"] }
      block(above: small-gap, below: 0pt, for l in g.names + g.lines { line-block(left: sig-column, inl(l)) })
    }
  })
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (ILNB-BODY-001, Fed. R. Civ. P. 10(b) via Rule 7010)
// ---------------------------------------------------------------------------

/// A footnote definition is rendered with the paragraph that refers to it, so the reference resolves inside
/// one cmarker call.
#let footnote-key-re = regex("\\[\\^([^\\]]+)\\]")

/// Numbered paragraphs. Each blank-line-separated chunk of markdown that is neither a heading nor a
/// list is one numbered paragraph. Headings and lists are not numbered. Numbering is applied per chunk,
/// not with a `show par` rule: a show rule that re-wraps paragraph content recurses without end in typst 0.15.
#let allegations(body) = {
  let para-n = 0
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let defs = chunks.filter(c => c.trim().starts-with("[^"))
  for c in chunks {
    let t = c.trim()
    if t.starts-with("[^") {
      // Footnote definitions are rendered with the paragraph that refers to them.
    } else if t.starts-with("#") or t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A heading or a list is not numbered.
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else {
      let keys = t.matches(footnote-key-re).map(m => m.captures.at(0))
      let own = defs.filter(d => keys.any(k => d.trim().starts-with("[^" + k + "]:")))
      para-n += 1
      let md = t + "\n\n" + own.join("\n\n", default: "")
      // cmarker renders the chunk as a paragraph; its content goes into the numbered paragraph.
      let content = cmarker.render(md, raw-typst: false, smart-punctuation: true, h1-level: 1)
      body-par(label: [#para-n.], content)
    }
  }
}

#let ilnb-adversary-complaint(meta, body) = {
  set document(title: need(meta, "title"), author: need(meta, "signature").signer)
  // ILNB-FORM-005: a centered page number on every page, in a single-spaced line box (Word's footer).
  set page(paper: "us-letter", margin: page-margin, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("1"))))
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch.
  show: xengine.with(pitch: pitch-body)
  // A doubled sign stays with its number ("§§ 157"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)

  // Footnotes: 12 pt (ILNB-FORM-002), single-spaced (the entry sets its own leading: it does not inherit the
  // body's); the mark, a space, the note (Word's footnote layout). LibreOffice splits a note anywhere (it keeps no
  // widow or orphan line in a footnote): so does typst here.
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: type-size, ..edges(pitch-single), costs: (widow: 0%, orphan: 0%))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    [#super(num) #note.body]
  }

  // Headings (ILNB-HEAD-001): single-spaced, a single line from the text on either side, kept with the text after
  // them; level 1 centered bold capitals, level 2 bold, level 3 bold italic.
  show heading: it => block(width: 100%, above: gap, below: gap, sticky: true, {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt)
    if it.level == 1 { align(center, strong(upper(it.body))) }
    else if it.level == 2 { strong(it.body) }
    else { strong(emph(it.body)) }
  })

  cover(meta)

  if "intro" in meta { body-par(inl(meta.intro)) }

  allegations(body)

  if "prayer" in meta {
    body-par(inl(meta.prayer))
    // Lettered items (a., b., ...), each a paragraph like a numbered one. The last is kept with the signature block,
    // so the signature never stands alone on a page.
    let items = meta.at("prayer_items", default: ())
    for (k, item) in items.enumerate() {
      let row = body-par(label: numbering("a.", k + 1), inl(item))
      if k == items.len() - 1 { block(width: 100%, sticky: true, breakable: false, row) } else { row }
    }
  }

  signature-block(meta)
}
