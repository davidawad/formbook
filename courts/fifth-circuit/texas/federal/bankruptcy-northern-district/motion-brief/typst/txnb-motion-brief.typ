// Motion with brief in support, for the U.S. Bankruptcy Court, N.D. Texas (txnb).
// Rules: Fed. R. Bankr. P. 9013 (motions: written, grounds stated with particularity), 7005 and 9014(b) (service),
// 9004(a)-(b) (legible; caption contents); L.B.R. 9013-1(a) (applies L.B.R. 7007-1(a)-(c) and 7007-3),
// L.B.R. 7007-1(b) and (f) (certificate of conference), 7007-1(c) (proposed order as a separate exhibit),
// 7007-1(e) (certificate of service), L.B.R. 7007-2(a) (legible form), (c) (25-page limit, excluding the table
// of contents and authorities), (d) (tables of contents and authorities for a brief over 10 pages).
// See ../README.md. Content-agnostic: every case-specific word comes from the sample's frontmatter.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// The only part that differs between the two doc types (docx/txnb-<doc>.lua has the same switches).
#let CFG = (
  numbered: false,          // complaint: body paragraphs are numbered (Fed. R. Civ. P. 10(b)); motion: not
  enum: "number",           // complaint lists are (a), (b), ...; motion lists are 1., 2., ... as written
  certificates: true,       // motion: certificate_conference / certificate_service
  toc: true,                // motion: table of contents when the frontmatter says toc: true (L.B.R. 7007-2(d))
)

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a stated convention; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // no font rule in the N.D. Tex. bankruptcy rules for motions; the house standard, as the exemplar is set (data/exemplar-fonts.json)
#let type-size = 12pt                   // convention
#let page-w = 8.5in                     // FRBP 9004(a): legible paper; 8 1/2 by 11 inch is the practice
#let page-h = 11in
#let margin = 1in                       // convention
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let label-box = 0.5in                  // a paragraph or list number in a box of this width, the text after it
#let caption-left = 3.25in              // width of the party column of the caption
#let caption-gutter = 0.25in            // between the party column and the number column
#let caption-inset = 10pt               // the party text stands off the caption's right rule
#let right-inset = 0.1in                // the number column stands off the gutter
#let designation-indent = 1.5in         // a party's designation ("Plaintiffs.") stands in from the names
#let sig-indent = 3in                   // the signature block at the right of the page
#let toc-page-col = 36pt                // contents: the page numbers keep the last 36 pt of the line to themselves

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // a single line: 1.15 x the type size (Word's single line in this face)
#let pitch-double = 2 * pitch-single    // double-spaced body: Word's double, 27.6 pt, as the exemplar measures
#let caption-pad = pitch-single / 2     // caption: the bottom rule stands half a line off the text

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("txnb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, sticky: false, body) = block(width: 100%, above: above, below: below,
  sticky: sticky, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    body
  })

/// An empty single line.
#let blank-line() = block(width: 100%, above: 0pt, below: 0pt, height: pitch-single)

/// A body paragraph at the double pitch. `indent`: its first-line indent; `keep`: kept whole and on the page of the
/// block after it (the last paragraph before the signature: a signature never starts a page alone).
#let body-par(content, indent: para-indent, keep: false) = block(width: 100%, above: 0pt, below: 0pt,
  sticky: keep, breakable: not keep,
  par(first-line-indent: (amount: indent, all: true), content))

// ---------------------------------------------------------------------------
// Cover: counsel (top left), court title, caption (Form 416 style), title of the paper
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  let lines = ("UNITED STATES BANKRUPTCY COURT", "NORTHERN DISTRICT OF TEXAS")
  if "division" in meta and meta.division != none { lines.push(upper(meta.division)) }
  for (i, l) in lines.enumerate() {
    line-block(above: if i == 0 { pitch-double } else { 0pt }, align(center, text(weight: "bold", l)))
  }
}

/// Form 416 style caption: the debtor and the adversary parties on the left (each party's designation stands in from
/// its names, "v." between the parties), the chapter, case and adversary numbers on the right.
#let caption(meta) = block(above: pitch-double, below: 0pt, breakable: false, grid(
  columns: (caption-left, 1fr),
  column-gutter: caption-gutter,
  block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-inset, bottom: caption-pad), {
    let cap = meta.caption
    if "debtor" in cap and cap.debtor != none {
      line-block[In re:]
      line-block(inl(cap.debtor))
      line-block(pad(left: designation-indent, inl(cap.at("debtor_designation", default: "Debtor") + ".")))
      blank-line()
    }
    for (k, p) in cap.parties.enumerate() {
      if k > 0 { blank-line(); line-block[v.]; blank-line() }
      for n in p.names { line-block(inl(n)) }
      line-block(pad(left: designation-indent, inl(p.designation + ".")))
    }
  }),
  pad(left: right-inset, {
    line-block[Chapter #meta.chapter]
    blank-line()
    line-block[Case No. #meta.case_number]
    blank-line()
    line-block[Adversary Proceeding No. #meta.adversary_number]
  }),
))

#let cover(meta) = {
  for l in meta.counsel { line-block(inl(l)) }
  court-title(meta)
  caption(meta)
  line-block(above: pitch-double, below: pitch-double, align(center, text(weight: "bold", inl(meta.title))))
}

// ---------------------------------------------------------------------------
// Body, signature and certificates
// ---------------------------------------------------------------------------

/// A heading as its own sticky block in a line of the double pitch (a heading never ends a page), set as written (no
/// case change: upper() would turn subsection letters in citations, "§ 523(a)(4)", into "(A)"). Level 1: centered
/// bold; level 2 bold; level 3 bold italic. Each carries a metadata entry for the table of contents.
#let heading-block(t) = {
  let lvl = t.match(regex("^#+")).text.len()
  let txt = t.replace(regex("^#+[ \\t]*"), "")
  block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
    set par(first-line-indent: 0pt)
    [#metadata((level: lvl, text: txt)) <toc-entry>]
    if lvl == 1 { align(center, text(weight: "bold", inl(txt))) }
    else { text(weight: "bold", style: if lvl == 2 { "normal" } else { "italic" }, inl(txt)) }
  })
}

/// Table of contents (L.B.R. 7007-2(d)(1)) on its own page after the cover: levels 1 and 2, each row's text wrapping
/// before the page column, a dot leader to the page number. The table of authorities is not generated (README).
#let toc-page() = {
  pagebreak()
  line-block(below: pitch-single, align(center, text(weight: "bold", "TABLE OF CONTENTS")))
  context for e in query(<toc-entry>).filter(e => e.value.level <= 2) {
    let ind = (e.value.level - 1) * label-box
    set text(..edges(pitch-single))
    listing-row(e.location(), { h(ind); inl(e.value.text) }, str(e.location().page()), toc-page-col, ind, pitch-single)
  }
  pagebreak()
}

/// List items: the label in a box of label-box half an inch in, the text hanging after it, at the double pitch.
#let list-items(t, last) = {
  let its = ()
  for l in t.split(regex("\\r?\\n")) {
    let m = l.match(regex("^\\s*(\\d+\\.|[-*+])\\s+(.*)$"))
    if m != none { its.push((m.captures.at(0), m.captures.at(1))) }
    else if its.len() > 0 { its.last().at(1) += " " + l.trim() }
  }
  for (i, (lab, txt)) in its.enumerate() {
    let label = if lab in ("-", "*", "+") { "•" } else if CFG.enum == "letter" { numbering("(a)", i + 1) } else { lab }
    let keep = last and i == its.len() - 1
    block(width: 100%, above: 0pt, below: 0pt, sticky: keep, breakable: not keep, pad(left: label-box,
      par(hanging-indent: label-box, first-line-indent: 0pt, { box(width: label-box, label); inl(txt) })))
  }
}

/// The body: blank-line-separated chunks, each a heading, a list or a paragraph. A paragraph is first-line
/// indented (complaint: numbered after the indent, Fed. R. Civ. P. 10(b)); one starting with "<!-- unnumbered -->"
/// is indented but not numbered, one starting with "[noindent]" is neither. The last chunk stays with the signature.
#let body-chunks(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let n = 0
  for (i, t) in chunks.enumerate() {
    let last = i == chunks.len() - 1
    if t.starts-with("#") {
      heading-block(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      list-items(t, last)
    } else if t.starts-with("<!-- unnumbered -->") {
      body-par(inl(t.slice("<!-- unnumbered -->".len()).trim()), keep: last)
    } else if t.starts-with("[noindent]") {
      body-par(inl(t.slice("[noindent]".len()).trim()), indent: 0pt, keep: last)
    } else if CFG.numbered {
      n += 1
      body-par({ box(width: label-box, [#n.]); inl(t) }, keep: last)
    } else {
      body-par(inl(t), keep: last)
    }
  }
}

/// Signature block: the date, then at the right "Respectfully submitted,", the firm and the signer's lines, a blank
/// single line between the groups. Never split.
#let signature-block(meta) = block(width: 100%, above: 0pt, below: 0pt, breakable: false, {
  body-par([Dated: #meta.date], indent: 0pt)
  let sig = meta.signature
  pad(left: sig-indent, {
    blank-line()
    line-block[Respectfully submitted,]
    blank-line()
    for l in sig.firm { line-block(inl(l)) }
    blank-line()
    line-block[By: /s/ #inl(sig.signer)]
    for l in sig.lines { line-block(inl(l)) }
  })
})

/// A closing certificate: a centered bold heading a double line below what precedes it, its paragraphs at the double
/// pitch (not indented; a leading "[noindent]" is dropped), then "/s/" and the signer at the right a single line
/// below. Never split.
#let certificate(title, text-md, signer) = block(width: 100%, above: pitch-double, below: 0pt, breakable: false, {
  block(width: 100%, above: 0pt, below: 0pt, sticky: true, align(center, text(weight: "bold", upper(title))))
  let paras = text-md.replace("[noindent]", "").split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  for q in paras { body-par(inl(q), indent: 0pt) }
  line-block(above: pitch-single, align(right, [/s/ #inl(signer)]))
})

#let txnb-motion-brief(meta, body) = {
  // The page number: centered in a single-spaced line box, at the same place on every page (Word's footer).
  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false, overhang: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (double-spaced).
  show: xengine.with(pitch: pitch-double, list-indent: none)
  // a doubled section sign stays with its number ("§§ 157"), as the docx filter binds it (xengine binds one sign)
  show regex("[§¶]{2,} \\S+"): it => box(it)

  cover(meta)
  if CFG.toc and "toc" in meta and meta.toc == true { toc-page() }
  body-chunks(body)
  signature-block(meta)
  if CFG.certificates {
    if "certificate_conference" in meta and meta.certificate_conference != none {
      certificate("Certificate of Conference", meta.certificate_conference, meta.signature.signer)
    }
    if "certificate_service" in meta and meta.certificate_service != none {
      certificate("Certificate of Service", meta.certificate_service, meta.signature.signer)
    }
  }
}
