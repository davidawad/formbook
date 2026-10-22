// Motion or brief in a contested matter for the United States Bankruptcy Court for the District of Idaho (idb).
// Rules: Fed. R. Bankr. P. 9013 and 9014 (motions, contested matters), 9004(a)-(b) (legible, paper and type),
// D. Idaho LBR 5005-1(c) (counsel block starting 1 inch from the top, 12-14 point type, caption with the
// case number and judge suffix), LBR 2002-2(d)(1) (negative-notice legend in a box immediately below the
// caption), LBR 9014-1 (witness testimony notice). See ./README.md for every parameter.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // LBR 5005-1(c)(2): 12 to 14 point type, no face named; Times New Roman, the house standard (docs/FONTS.md)
#let type-size = 12pt              // inside the 12-14 point range; both filers set Times New Roman at 12 pt (fb-w0vj)
#let note-size = 12pt              // footnotes: LBR 5005-1(c)(2) sets 12 pt as the floor for all type
#let para-indent = 0.5in           // first-line indent of paragraphs (both filers)
#let num-width = 0.5in             // paragraph number box: text after "1." and "10." starts at the same tab (both filers)
#let bullet-width = 0.3in          // bullet box of a `- ` item, the item indented by para-indent
#let margin = 1in                  // LBR 5005-1(c)(1): counsel information starts 1 inch from the top; 1 inch all round
#let caption-left = 3.4in          // width of the party column of the caption
#let caption-pad-left = 0.2in      // the party text stops this far left of the caption's rule
#let caption-pad-right = 0.3in     // the case-number column starts this far right of the rule
#let notice-inset = 0.1in          // the negative-notice box: text inset from its rule
#let quote-left = 0.75in           // block quotations: left and right indents
#let quote-right = 0.5in
#let sig-indent = 3.0in            // signature column (both filers sign in the right half)

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt         // single spacing, 1.15 x 12 pt: counsel, caption, quotations, notice, signature, footnotes
#let pitch-double = 2 * pitch-single   // double spacing (both filers; no rule sets it): 27.6 pt
#let gap = pitch-single            // between the parts of the cover, around quotations, above the signature
#let notice-gap = 6.9pt            // between the paragraphs of the negative-notice legend
#let note-gap = 7pt                // between two footnotes
#let note-clearance = 10pt         // from the last text line to the separator: with note-gap, 17 pt; LibreOffice keeps more than 13.2 pt and at most 26.8 pt between the text and the first note (measured on this template, fb-595.68.23; Word sets the separator as a single-spaced paragraph)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\\r?\\n([\\s\\S]*?)\\r?\\n---[ \\t]*\\r?\\n"))
  if m == none { panic("idb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, case names, footnote references, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Blank-line-separated chunks of the body (the markdown contract in ./README.md).
#let chunks(body) = body.split(regex("\\n\\s*\\n")).map(c => c.trim()).filter(c => c != "")

/// A footnote definition chunk: `[^id]: text`.
#let fn-def-re = regex("^\\[\\^([^\\]]+)\\]:\\s*")
#let is-fn-def(c) = c.match(fn-def-re) != none

/// Heading text that begins with "1." or "1)" is a heading, not a list item: escape the marker.
#let no-list(s) = s.replace(regex("^(\\d+)([.)])"), m => m.captures.at(0) + "\\" + m.captures.at(1))

#let para-n = counter("idb-para")
#let num-on = state("idb-num-on", true)   // off after the prayer and certificate headings

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, right: 0pt, body) = block(width: 100%, above: above, below: below,
  breakable: false, pad(left: left, right: right, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    body
  }))

/// Single lines, one per item; an empty (or blank) item is a blank line.
#let lines(items, left: 0pt, right: 0pt) = for i in items {
  if i.trim() == "" { block(width: 100%, height: pitch-single, above: 0pt, below: 0pt) }
  else { line-block(left: left, right: right, inl(i)) }
}

/// A double-spaced body paragraph: `num` a number in its box after the indent, or none.
#let body-par(num, content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: 0pt, {
    h(para-indent)
    if num != none { box(width: num-width, num) }
    content
  }))

// ---------------------------------------------------------------------------
// Caption and cover
// ---------------------------------------------------------------------------

/// The caption: the debtors under "In re:" with their designation centered under them, a rule, then the case
/// number, chapter and judge (LBR 5005-1(c)(3)).
#let caption(meta) = block(width: 100%, above: gap, below: 0pt, breakable: false, grid(
  columns: (caption-left, 1fr),
  stroke: (x, y) => if x == 0 { (right: 0.75pt) } else { none },
  {
    lines(("In re:", ""), right: caption-pad-left)
    lines(meta.debtors.names, right: caption-pad-left)
    line-block(right: caption-pad-left, align(center, inl(meta.debtors.designation)))
  },
  {
    let r = ("", "Case No. " + meta.case_number, "", "Chapter " + str(meta.chapter))
    if "judge" in meta { r += ("", meta.judge) }
    lines(r, left: caption-pad-right)
  },
))

/// LBR 2002-2(d)(1): the negative-notice legend, immediately below the caption, in a text box
/// (2008 advisory committee note). Its words come from the sample (`meta.notice`).
#let notice-box(n) = block(width: 100%, above: gap, below: 0pt, stroke: 0.75pt, inset: notice-inset,
  breakable: false, {
    line-block(align(center, text(weight: "bold", upper(n.heading))))
    for p in n.paragraphs {
      line-block(above: notice-gap, {
        if "label" in p { underline(inl(p.label)); [ ] }
        inl(p.text)
      })
    }
  })

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// A numbered paragraph: the template numbers them ("1."); the sample does not.
#let numbered(md) = {
  para-n.step()
  context body-par(if num-on.get() { para-n.display("1.") } else { none }, inl(md))
}

/// A bulleted list (`- `); the source's own letters or numbers, if any, stay in the item text.
#let bullets(items) = for it in items {
  block(width: 100%, above: 0pt, below: 0pt, pad(left: para-indent,
    par(first-line-indent: 0pt, hanging-indent: bullet-width, [#box(width: bullet-width)[•]#inl(it)])))
}

/// A block quotation: single spaced, indented on both sides, a single line above and below.
#let quotation(md) = line-block(above: gap, below: gap, left: quote-left, right: quote-right, inl(md))

/// A heading at the body pitch, kept with what follows.
#let head(above, body, centered: true) = block(width: 100%, sticky: true, above: above, below: 0pt, {
  set par(first-line-indent: 0pt)
  if centered { align(center, text(weight: "bold", body)) } else { text(weight: "bold", body) }
})

/// Body chunks: `# ` centered bold (a single line above); `## ` centered bold; `### ` bold at the left; `- `
/// bullets; `> ` block quote; `~ ` unnumbered flush continuation; `: ` unnumbered indented paragraph;
/// `WHEREFORE` unnumbered; `[^id]: ` footnote definitions (set at the foot of the page of their reference);
/// anything else is a numbered paragraph. `md` is the chunk plus the footnote definitions it references.
#let render-chunk(c, md) = {
  if c.starts-with("# ") {
    if c.slice(2).starts-with("PRAYER") or c.slice(2).starts-with("CERTIFICATE") { num-on.update(false) }
    head(gap, inl(no-list(c.slice(2))))
  } else if c.starts-with("## ") {
    head(0pt, inl(no-list(c.slice(3))))
  } else if c.starts-with("### ") {
    head(0pt, inl(no-list(c.slice(4))), centered: false)
  } else if c.starts-with("- ") {
    bullets(md.split("\n").map(l => l.trim()).filter(l => l.starts-with("- ")).map(l => l.slice(2)))
  } else if c.starts-with("WHEREFORE") {
    body-par(none, inl(md))
  } else if c.starts-with(": ") {
    body-par(none, inl(md.slice(2)))
  } else if c.starts-with("> ") {
    quotation(md.slice(2))
  } else if c.starts-with("~ ") {
    block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: 0pt, inl(md.slice(2))))
  } else {
    numbered(md)
  }
}

/// The date line and signature block (`meta.dated` verbatim). `signature`: `lines_above` (firm, party),
/// `signer`, `by` (prefix before "/s/", default "By "), `lines_below` (firm, party, under the name).
#let signature-block(meta) = {
  let s = meta.signature
  line-block(above: gap, left: para-indent, inl(meta.dated))
  let groups = ()
  let above = s.at("lines_above", default: ())
  if above.len() > 0 { groups.push(above) }
  groups.push((s.at("by", default: "By ") + "/s/ " + s.signer, s.signer))
  let below = s.at("lines_below", default: ())
  if below.len() > 0 { groups.push(below) }
  for g in groups {
    for (i, l) in g.enumerate() { line-block(above: if i == 0 { gap } else { 0pt }, left: sig-indent, inl(l)) }
  }
}

/// The certificate's own signature (`meta.service_signature`: `signer`, optional `name`).
#let service-signature(s) = block(width: 100%, above: gap, below: 0pt, breakable: false, {
  line-block(left: sig-indent, [By /s/ #s.signer])
  line-block(left: sig-indent, [#s.at("name", default: s.signer)])
})

// ---------------------------------------------------------------------------
// Entry point: idb-motion-brief(meta, body)
// ---------------------------------------------------------------------------
#let idb-motion-brief(meta, body) = {
  // LBR 5005-1(c): case number with the judge's initials (written "20-40042-JMM" or "24-bk-00388-ngh")
  assert(meta.case_number.match(regex("^\\d{2}-(?:bk-)?\\d{5}-[A-Za-z]{3}$")) != none,
    message: "idb-motion-brief: case_number must end in a three-letter judge suffix")

  // Page number centered in a single-spaced line box, where Word's footer sets it.
  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (double spaced).
  show: xengine.with(pitch: pitch-double, list-indent: none)
  // A doubled sign stays with its number too ("§§ 157"; xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)
  // A quotation mark right after sentence punctuation closes a quotation (cmarker reads an unmatched one as
  // opening; pandoc, the docx reader, as closing).
  show regex("[.,;:!?][\u{201C}]"): it => it.text.replace("\u{201C}", "\u{201D}")
  // Footnotes (LBR 5005-1(c)(2): 12 pt), single spaced: the indent, the mark, a space, the note (Word's footnote).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt,
    separator: line(length: 2in, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: note-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    [#h(para-indent)#super(num)#h(0.25em)#note.body]
  }

  // Cover: counsel (LBR 5005-1(c)(1)), court, caption, title, the negative-notice legend, the lead-in.
  lines(meta.counsel)
  line-block(above: gap, align(center, text(weight: "bold")[UNITED STATES BANKRUPTCY COURT]))
  line-block(align(center, text(weight: "bold")[FOR THE DISTRICT OF IDAHO]))
  caption(meta)
  line-block(above: gap, align(center, text(weight: "bold", upper(meta.title))))
  if "notice" in meta { notice-box(meta.notice) }
  block(width: 100%, above: gap, below: 0pt, body-par(none, inl(meta.lead_in)))

  // footnote definitions are pulled out and appended to the chunks that cite them
  let all = chunks(body)
  let defs = (:)
  for c in all.filter(is-fn-def) {
    let m = c.match(fn-def-re)
    defs.insert(m.captures.at(0), c)
  }
  let cs = all.filter(c => not is-fn-def(c))
  let with-defs(c) = {
    let md = c
    for r in c.matches(regex("\\[\\^([^\\]]+)\\]")) {
      let id = r.captures.at(0)
      assert(id in defs, message: "idb-motion-brief: footnote [^" + id + "] has no definition")
      md += "\n\n" + defs.at(id)
    }
    md
  }

  // The signature goes after the body and before the certificate of service. The body's last
  // paragraph is kept on the signature's page (unless it is a heading), so the signature never
  // stands alone.
  let cert = cs.position(c => c.starts-with("# CERTIFICATE"))
  let n-body = if cert == none { cs.len() } else { cert }
  let last = if n-body > 0 and not cs.at(n-body - 1).starts-with("#") { n-body - 1 } else { none }
  for (i, c) in cs.slice(0, n-body).enumerate() {
    if i != last { render-chunk(c, with-defs(c)) }
  }
  block(width: 100%, above: 0pt, below: 0pt, breakable: false, {
    if last != none { let c = cs.at(last); render-chunk(c, with-defs(c)) }
    signature-block(meta)
  })
  for c in cs.slice(n-body) { render-chunk(c, with-defs(c)) }
  if cert != none and "service_signature" in meta { service-signature(meta.service_signature) }
}
