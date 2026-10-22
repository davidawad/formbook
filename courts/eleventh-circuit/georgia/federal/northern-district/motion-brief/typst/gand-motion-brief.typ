// Motion with supporting memorandum of law for the U.S. District Court for the Northern District of Georgia (gand).
// Rules (N.D. Ga. Local Rules): LR 5.1(C) type and spacing, 5.1(D) margins, 5.1(E) page numbers bottom center,
// 5.1(G) counsel identification, 5.1(J) captions, 5.1(K) case number with judge suffix; LR 7.1(A)(1) a motion
// comes with a memorandum; LR 7.1(D) 25-page limit and certificate of font compliance at the end of the brief.
// Fed. R. Civ. P. 7(b) (motions), 10(a) (caption), 12(b) (defenses). See ../README.md for the rule text and gaps.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-name = ("Times New Roman", "Liberation Serif")     // LR 5.1(C) names Times New Roman (14 pt); substitute per docs/FONTS.md, metric-compatible.
#let font-family = font-name
#let rule-font-name = "Times New Roman" // the face the filer certifies (LR 7.1(D)); not the rendered face
#let type-size = 14pt                   // LR 5.1(C): Times New Roman at least 14 point; footnotes and quotations too
#let page-w = 8.5in
#let page-h = 11in
#let margin = 1in                       // LR 5.1(D): top, bottom, left and right margins at least one inch
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-party-w = 3.2in            // width of the party column of the caption
#let caption-paren-w = 0.35in           // the column of ")" marks between the parties and the case number
#let designation-indent = 1.5in         // "Plaintiff," and "Defendant." in the party column
#let quote-indent = 0.5in               // block quotations, both sides
#let list-indent = 0.5in                // lettered items: the label's box
#let sig-left = 2.7in                   // the signature lines stand 2.7 in from the margin
#let sig-gap = 4pt                      // between the groups of the signature block

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 16.1pt              // a single line: 1.15 x the type size (Word's single line in this face)
#let pitch-body = 2 * pitch-single      // LR 5.1(C): double-spaced; 32.2 pt, the filed exemplar's body pitch (Durand p.2)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("gand-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A required frontmatter field. A missing one stops the render: the form cannot be left incomplete.
#let need(meta, key) = {
  assert(key in meta, message: "gand-motion-brief: frontmatter field `" + key + "` is required")
  meta.at(key)
}

/// Inline markdown (for case names with *Id.*, *See*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: left, body)
})

/// A body paragraph at the double pitch, its first line indented.
#let body-par(content) = block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: 0pt)[#h(para-indent)#content])

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (Fed. R. Civ. P. 10(a))
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  line-block(align(center, text(weight: "bold", "IN THE UNITED STATES DISTRICT COURT")))
  line-block(align(center, text(weight: "bold", "FOR THE NORTHERN DISTRICT OF GEORGIA")))
  line-block(align(center, text(weight: "bold", upper(need(meta, "division")) + " DIVISION")))
}

/// The caption: party names on the left, a column of ")" marks, and the case number on the right (LR 5.1(K)) on
/// the middle row; every row one single line. A name that is wider than its column is a render error (split the
/// name over two lines in the frontmatter, as the filed caption does).
#let caption(meta) = {
  let lines = ()
  for (k, p) in need(meta, "caption").at("parties").enumerate() {
    if k > 0 { lines.push(("v.", 0pt)) }
    for n in need(p, "names") { lines.push((n, 0pt)) }
    lines.push((need(p, "designation"), designation-indent))
  }
  let case-no = if "case_number" in meta and meta.case_number != "" { meta.case_number } else { "______________" }
  let mid = calc.quo(lines.len() - 1, 2)
  let cell(body) = block(width: 100%, height: pitch-single, { set text(..edges(pitch-single)); body })
  let cells = ()
  for (i, (s, indent)) in lines.enumerate() {
    cells.push(cell(context {
      assert(measure(inl(s)).width + indent <= caption-party-w,
        message: "gand caption: a party line is wider than its column; split it in the frontmatter: " + s)
      pad(left: indent, inl(s))
    }))
    cells.push(cell[)])
    cells.push(cell(if i == mid [Civil Action No. #case-no]))
  }
  block(above: pitch-single, below: pitch-single, grid(columns: (caption-party-w, caption-paren-w, 1fr), ..cells))
}

#let cover(meta) = {
  court-title(meta)
  caption(meta)
  line-block(below: pitch-single, align(center, text(weight: "bold", upper(need(meta, "title")))))
}

// ---------------------------------------------------------------------------
// Body, signature, certificates
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let s = need(meta, "signature")
  let attorneys = need(s, "attorneys")
  assert(attorneys.len() > 0, message: "gand-motion-brief: LR 5.1(G) needs at least one attorney block")
  for a in attorneys {
    // LR 5.1(G): name, complete address, telephone, email and bar number on every document.
    for k in ("name", "bar", "email") {
      assert(k in a, message: "gand-motion-brief: LR 5.1(G) needs `" + k + "` for every attorney")
    }
  }
  block(breakable: false, above: pitch-body, below: 0pt, {
    line-block[Respectfully submitted,]
    line-block(above: pitch-body, left: sig-left)[s/ #need(s, "signer")]
    for a in attorneys { line-block(left: sig-left)[#a.name, Georgia Bar No. #a.bar] }
    for (i, l) in need(s, "firm").enumerate() { line-block(above: if i == 0 { sig-gap } else { 0pt }, left: sig-left, inl(l)) }
    for l in need(s, "address") { line-block(left: sig-left, inl(l)) }
    line-block(left: sig-left)[Telephone: #need(s, "phone")]
    for a in attorneys { line-block(left: sig-left, a.email) }
    line-block(above: sig-gap, left: sig-left, inl(need(s, "role")))
  })
}

/// A certificate: its heading centered and bold a body line above and a single line above the text, the text in
/// double-spaced paragraphs, the signer's "s/" line at the right a body line below; it never breaks across a page.
#let certificate(meta, title, paras) = block(breakable: false, above: pitch-body, below: 0pt, {
  line-block(below: pitch-single, align(center, text(weight: "bold", title)))
  for t in paras { body-par(t) }
  line-block(above: pitch-body, align(right, [s/ #need(need(meta, "signature"), "signer")]))
})

/// LR 7.1(D): at the end of the brief, counsel certifies the font and point size. The certificate names the rule's
/// face (`rule-font-name`), because the filer prepares the brief in that face; `font-name` is the vendored
/// metric-compatible substitute the render uses, and the two have the same metrics. See README.md.
#let font-certificate(meta) = certificate(meta, "CERTIFICATE PURSUANT TO LOCAL RULE 7.1(D)",
  ([I certify that the foregoing brief conforms to the requirements of LR 5.1(C). The brief is prepared in #int(type-size / 1pt)-point #rule-font-name font.],))

/// Certificate of service through CM/ECF.
#let service-certificate(meta) = certificate(meta, "CERTIFICATE OF SERVICE", (
  [I certify that I have this day served the foregoing pleading with the Clerk of Court using the CM/ECF system which will automatically send email notification of such filing to all counsel of record.],
  [This #need(meta, "service_text").],
))

/// The body as one flow of paragraphs (unnumbered: a brief is not pleaded in numbered paragraphs). A chunk
/// that is a heading is a sticky block; a block quotation (">") is single-spaced and indented; a footnote
/// definition is merged into the chunk before it, so its reference and text are rendered together.
#let brief-body(body) = {
  let raw = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "").map(c => c.trim())
  let chunks = ()
  for t in raw {
    if t.starts-with("[^") and chunks.len() > 0 {
      chunks = chunks.slice(0, -1) + (chunks.last() + "\n\n" + t,)
    } else {
      chunks.push(t)
    }
  }
  for t in chunks {
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(">") {
      // LR 5.1(C): indented quotations may be single-spaced; a single line above and below
      line-block(above: pitch-single, below: pitch-single, pad(x: quote-indent, md(t.replace(regex("(?m)^>[ \\t]?"), ""))))
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      pad(left: list-indent, md(t))
    } else {
      body-par(md(t))
    }
  }
}

#let gand-motion-brief(meta, body) = {
  // LR 5.1(E): page numbers at the bottom center of every page, in a single-spaced line box (Word's footer).
  set page(width: page-w, height: page-h, margin: margin, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (LR 5.1(C): double-spaced).
  show: xengine.with(pitch: pitch-body, list-indent: list-indent)
  // A doubled sign stays with its number ("§§ 50-14-1"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)
  // Footnotes (LR 5.1(C): single-spaced, 14 pt): the mark, a space, the note (Word's footnote layout).
  set footnote.entry(gap: 7pt, clearance: 12.6pt, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt, spacing: 0pt)
    [#super(num)#h(0.25em)#note.body]
  }

  // Headings (LR 5.1(C): may be single-spaced): level 1 a centered section in capitals; level 2 bold at the margin
  // (the letters and numbers are typed by the author); a single line above and below, kept with the text after.
  show heading: it => block(width: 100%, sticky: true, above: pitch-single, below: pitch-single, {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt)
    if it.level == 1 { align(center, text(weight: "bold", upper(it.body))) } else { text(weight: "bold", it.body) }
  })

  cover(meta)
  brief-body(body)
  signature-block(meta)
  font-certificate(meta)
  service-certificate(meta)
}
