// Motion with memorandum for the U.S. Bankruptcy Court, District of Minnesota (mnb).
// Rules: Fed. R. Bankr. P. 9013 (form of motions), 9014 (contested matters), 9004(a) (legibility), 9004(b) (caption),
// 9011 (signature block); D. Minn. LBR 9013-1(a) (notice and motion substantially complying with Local Form 9013-1,
// concise memorandum of facts and law, verification if facts are at issue, proposed order, proof of service if
// required), 9004-1(a) (letter-size paper), 9004-1(b)(2) (print to PDF). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // no font rule in the local rules; Times New Roman as in the exemplars
#let type-size = 12pt                   // no size rule in the local rules; 12 pt is the convention in the exemplars
#let page-w = 8.5in                     // LBR 9004-1(a): letter-size paper
#let page-h = 11in
#let margin = 1in                       // convention in the exemplars; no local rule sets margins
#let para-indent = 0.5in                // first-line indent; the paragraph number's box after it
#let item-indent = 0.5in                // lettered items: the letter half an inch in, the text a box after it
#let list-left = 0.9in                  // a list that carries its own letters ("- (A) ...") stands this far in
#let quote-indent = 0.5in               // a block quotation (the text of a statute) is indented on both sides
#let caption-left = 3.5in               // width of the party column of the caption
#let caption-gutter = 0.2in             // between the caption's columns
#let caption-inset = 0.1in              // each caption column stands off the gutter
#let caption-pad = 8pt                  // the caption's rules stand off the text
#let designation-indent = 1.8in         // a caption line written "> Debtor." (the party designation)
#let sig-left = 2.6in                   // signature grid: the "Dated" column, a gutter, the signature column
#let sig-gutter = 0.2in
// The sample's body has two parts, split by this line: the notice and motion, then the memorandum of law.
#let part-split = "<!-- memorandum -->"

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // a single line: 1.15 x the type size (Word's single line in this face)
#let pitch-double = 2 * pitch-single    // double spacing: 27.6 pt, the pitch of the exemplars
#let quote-gap = pitch-single / 2       // between the paragraphs of a block quotation

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mnb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, below: 0pt, indent: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: indent, body)
})

/// Caption and signature lines, one single-spaced line each. An empty string is a blank line; a line starting
/// with ">" is indented (the party designation "Debtor.").
#let line-stack(items) = for i in items {
  if i == "" { line-block("\u{00A0}") } else if i.starts-with(">") {
    line-block(indent: designation-indent, inl(i.slice(1).trim()))
  } else { line-block(inl(i)) }
}

// ---------------------------------------------------------------------------
// Caption: court, debtor box, and the title of the part (Fed. R. Bankr. P. 9004(b); 9013)
// ---------------------------------------------------------------------------

#let court-title() = {
  line-block(align(center, text(weight: "bold", "UNITED STATES BANKRUPTCY COURT")))
  line-block(align(center, text(weight: "bold", "DISTRICT OF MINNESOTA")))
}

#let caption(meta, title) = {
  court-title()
  // Debtor box: "In re:" and the debtor names on the left; the case number and chapter on the right.
  block(width: 100%, above: pitch-double, below: 0pt, stroke: (top: 0.75pt, bottom: 0.75pt),
    inset: (top: caption-pad, bottom: caption-pad), grid(
      columns: (caption-left, 1fr),
      column-gutter: caption-gutter,
      pad(right: caption-inset, line-stack(meta.caption.debtor)),
      pad(left: caption-inset, line-stack(meta.caption.debtor_case)),
    ))
  block(width: 100%, above: pitch-double, below: pitch-double, {
    set par(first-line-indent: 0pt)
    align(center, text(weight: "bold", inl(title)))
  })
}

// ---------------------------------------------------------------------------
// Body, signature and verification
// ---------------------------------------------------------------------------

/// The signature block: "Dated" at the left; the firm, then the signer's lines at the right; never split.
#let signature-block(meta) = block(width: 100%, breakable: false, above: pitch-double, below: 0pt, grid(
  columns: (sig-left, 1fr),
  column-gutter: sig-gutter,
  line-block[Dated: #meta.date],
  {
    if "firm" in meta.signature { line-stack(meta.signature.firm) }
    block(width: 100%, above: if "firm" in meta.signature { pitch-double } else { 0pt }, below: 0pt,
      line-stack(("By: /s/ " + meta.signature.signer,) + meta.signature.lines))
  },
))

/// The verification (LBR 9013-1(a)(3)): its title, the declaration, the date and the signer; never split.
#let verification-block(meta) = if "verification" in meta {
  let v = meta.verification
  block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
    block(width: 100%, above: 0pt, below: pitch-double, {
      set par(first-line-indent: 0pt)
      align(center, text(weight: "bold", "VERIFICATION"))
    })
    par(first-line-indent: (amount: para-indent, all: true), inl(v.text))
    block(width: 100%, above: pitch-double, below: 0pt, grid(
      columns: (sig-left, 1fr),
      column-gutter: sig-gutter,
      line-block(inl(v.date)),
      line-stack(("/s/ " + v.signer,) + v.lines),
    ))
  })
}

/// A body paragraph at the double pitch: unnumbered (first-line indent) or numbered (Fed. R. Bankr. P. 9013; LBR
/// 9013-1(a)(1): the number in a box of the paragraph indent after the first-line indent, the text after it).
#let body-par(num, content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), if num == none { content } else {
    [#box(width: para-indent, [#num.])#content]
  }))
/// A lettered item ("1." in the markdown): the letter half an inch in, the text hanging a box after it.
#let lettered-item(letter, content) = block(width: 100%, above: 0pt, below: 0pt, pad(left: item-indent,
  par(hanging-indent: item-indent, first-line-indent: 0pt, [#box(width: item-indent, letter)#content])))
/// An item of a list that carries its own letters ("- (A) ..."): the whole item `list-left` in.
#let list-item(content) = block(width: 100%, above: 0pt, below: 0pt, pad(left: list-left,
  par(first-line-indent: 0pt, content)))
/// A block quotation (the text of a statute): single-spaced, indented on both sides, its paragraphs half a line
/// apart, a single line above and below it.
#let block-quote(t) = {
  let text-of = t.split(regex("\\r?\\n")).map(l => l.trim().slice(1).trim()).join("\n")
  let paras = text-of.split(regex("\\n[ \\t]*\\n")).filter(q => q.trim() != "")
  block(width: 100%, above: pitch-single, below: pitch-single, pad(left: quote-indent, right: quote-indent, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    for (k, q) in paras.enumerate() {
      block(width: 100%, above: if k == 0 { 0pt } else { quote-gap }, below: 0pt, md(q.trim()))
    }
  }))
}

/// Paragraphs of a part. Each blank-line-separated chunk of markdown is one paragraph: numbered in the notice,
/// unnumbered in the memorandum; a WHEREFORE paragraph, a list and a block quotation are never numbered. The last
/// chunk is kept with `tail` (the signature block), so the block never stands alone on a page.
#let paragraphs(body, numbered-paragraphs: true, tail: none) = {
  let n = 0
  let chunks = ()
  // a block quotation's paragraphs are separated by ">" lines, so a quotation is one chunk
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "") {
    if c.trim().starts-with(">") and chunks.len() > 0 and chunks.last().starts-with(">") {
      chunks.last() += "\n>\n" + c.trim()
    } else { chunks.push(c.trim()) }
  }
  for (i, t) in chunks.enumerate() {
    let piece = if t.starts-with("#") {
      md(t)
    } else if t.starts-with(">") {
      block-quote(t)
    } else if t.starts-with(regex("^[-*+][ \\t]")) {
      for l in t.split(regex("\\r?\\n")) { list-item(md(l.trim().slice(1).trim())) }
    } else if t.starts-with(regex("^\\d+\\.[ \\t]")) {
      let m = t.match(regex("^(\\d+)\\.[ \\t]+([\\s\\S]*)$"))
      lettered-item(str.from-unicode(64 + int(m.captures.at(0))) + ".", md(m.captures.at(1)))
    } else if numbered-paragraphs and not t.starts-with("WHEREFORE") {
      n += 1
      body-par(n, md(t))
    } else {
      body-par(none, md(t))
    }
    if i == chunks.len() - 1 and tail != none {
      block(width: 100%, breakable: false, above: 0pt, below: 0pt, { piece; tail })
    } else { piece }
  }
}

#let mnb-motion-brief(meta, body) = {
  // Page numbers centred in the bottom margin, arabic, on every page; the number in a single-spaced line box just
  // below the text (Word's footer).
  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    footer-descent: 0pt,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (double-spaced).
  show: xengine.with(pitch: pitch-double, list-indent: item-indent)

  // Headings at the body size and pitch, no space of their own (the double pitch sets them off): level 1 a centred
  // caps section, level 2 a centred bold sub-heading, level 3 bold italic. Sticky: a heading never ends a page.
  show heading: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    let b = if it.level == 1 { align(center, text(weight: "bold", upper(it.body))) } else if it.level == 2 {
      align(center, text(weight: "bold", it.body))
    } else { text(weight: "bold", style: "italic", it.body) }
    block(sticky: true, width: 100%, above: 0pt, below: 0pt, b)
  }

  let parts = body.split(part-split)
  let notice = parts.at(0)
  let memo = if parts.len() > 1 { parts.at(1) } else { none }

  // Part 1: the notice of hearing and motion, numbered paragraphs (LBR 9013-1(a)(1)), then the signature and,
  // if the facts are at issue, the verification (LBR 9013-1(a)(3)).
  caption(meta, meta.notice_title)
  if "lead_in" in meta { body-par(none, inl(meta.lead_in)) }
  paragraphs(notice, tail: signature-block(meta))
  verification-block(meta)

  // Part 2: the memorandum of facts and law (LBR 9013-1(a)(2)) on a new page; its paragraphs are unnumbered.
  if memo != none {
    pagebreak()
    caption(meta, meta.memo_title)
    paragraphs(memo, numbered-paragraphs: false, tail: signature-block(meta))
  }
}
