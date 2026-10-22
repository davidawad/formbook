// Memorandum of law in support of a motion, U.S. Bankruptcy Court, N.D.N.Y. (nynb).
// Rules: FRBP 9013 (a request for an order must be made by written motion); LBR 9013-1(a)(1) (the relief, the party
// against whom it is sought and the rule or statute relied on are stated plainly), (c) (certificate of service),
// (g)(1) (hearing date, time and location above the case number), (h) (chambers copy marked "ECF CASE – CHAMBERS
// COPY"); LBR 9004-1(a) (form), (c) (caption), (d) (noncompliance); FRBP 7012(b) when the motion is in an adversary
// proceeding (Fed. R. Civ. P. 12(b) applies). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see ../README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")     // Times New Roman substitute per docs/FONTS.md, vendored in fonts/; --ignore-system-fonts means no other substitute
#let type-size = 12pt                // LBR 9004-1(a)(1)(A): minimum 12-point, text and footnotes
#let margin = 1in                    // LBR 9004-1(a)(2)(A): one-inch margin on all four sides
#let para-indent = 0.5in             // first line of each body paragraph (memorandum text is not numbered)
#let quote-inset = 0.5in             // block quotations: indented on both sides
#let caption-left = 3.4in            // width of the party column of the caption
#let caption-gutter = 0.25in         // between the party column and the case numbers
#let caption-inset = 0.1in           // the case numbers' own inset
#let rule-pad = 10pt                 // the party text stops this far from the caption rule (right and bottom)
#let sig-left = 3in                  // the "Dated" column of the signature block and the certificate

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/nynb-motion-brief.lua sets the same twips).
#let pitch-double = 24pt             // LBR 9004-1(a)(1)(B): double-spaced body
#let pitch-single = 13.8pt           // caption, counsel, block quotations, signature: 1.15 x 12 pt (LBR 9004-1(a)(1)(B)
                                     // lets block quotations be single-spaced)
#let gap = 24pt                      // one blank double-spaced line between the cover's parts and before headings
#let caption-sep = 6pt               // between the bankruptcy and the adversary caption; below the chambers legend
#let quote-gap = 12pt                // above and below a block quotation, and between its paragraphs

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nynb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, section symbols, case names).
#let inl(s) = cmarker.render(str(s), raw-typst: false, smart-punctuation: true)

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  body
})

/// Single-spaced stack of lines (caption, counsel, signature); an empty line keeps its full height.
#let line-stack(items) = for i in items {
  if i == "" { block(height: pitch-single, above: 0pt, below: 0pt) } else { line-block(inl(i)) }
}

// ---------------------------------------------------------------------------
// Caption and cover (LBR 9004-1(c); FRBP 9004(b); LBR 9013-1(g)(1); LBR 9013-1(h))
// ---------------------------------------------------------------------------

/// A caption: the left column ruled on its right and bottom, the right column beside it.
#let caption-grid(left, right) = grid(
  columns: (caption-left, 1fr),
  column-gutter: caption-gutter,
  block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: rule-pad, bottom: rule-pad),
    line-stack(left)),
  pad(left: caption-inset, line-stack(right)),
)

/// The bankruptcy caption: debtor on the left; hearing (when given) and case number and chapter on the right.
/// The hearing lines sit above the case number, as LBR 9013-1(g)(1) requires for answering papers.
#let bankruptcy-caption(meta) = caption-grid(
  ("In re:",) + meta.debtor.names + ("(" + meta.debtor.tin + ")", "Debtor."),
  (if "hearing" in meta and meta.hearing != none {
    ("Hearing: " + meta.hearing.date, "Time: " + meta.hearing.time, "Location: " + meta.hearing.location)
  } else { () }) + ("Case No. " + meta.case_number, "Chapter " + str(meta.chapter)),
)

/// The adversary caption, shown only when the motion is filed in an adversary proceeding.
#let adversary-caption(meta) = {
  let rows = ()
  for (k, p) in meta.adversary.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names + (p.designation,)
  }
  caption-grid(rows, ("Adv. Pro. No. " + meta.adversary.number,))
}

#let cover(meta) = {
  // The chambers-copy legend (LBR 9013-1(h)) is marked on the first page, above the counsel block.
  if "chambers_copy" in meta and meta.chambers_copy == true {
    line-block(below: caption-sep, align(right, text(weight: "bold", "ECF CASE – CHAMBERS COPY")))
  }
  if "counsel" in meta and meta.counsel != none {
    block(width: 100%, below: gap, line-stack(meta.counsel))
  }
  line-block(align(center, text(weight: "bold", "UNITED STATES BANKRUPTCY COURT")))
  line-block(below: gap, align(center, text(weight: "bold", "NORTHERN DISTRICT OF NEW YORK")))
  let adversary = "adversary" in meta and meta.adversary != none
  block(width: 100%, above: gap, below: if adversary { caption-sep } else { gap }, bankruptcy-caption(meta))
  if adversary { block(width: 100%, above: caption-sep, below: gap, adversary-caption(meta)) }
  line-block(above: gap, below: gap, align(center, text(weight: "bold", inl(meta.title))))
}

// ---------------------------------------------------------------------------
// Body: unnumbered memorandum paragraphs, headings, block quotations
// ---------------------------------------------------------------------------

/// A block quotation: single-spaced, indented on both sides, its paragraphs a quote-gap apart.
#let quotation(c) = {
  let ps = c.replace(regex("(?m)^>[ \\t]?"), "").split(regex("\\n[ \\t]*\\n")).map(s => s.trim()).filter(s => s != "")
  for q in ps {
    block(width: 100%, above: quote-gap, below: quote-gap, pad(left: quote-inset, right: quote-inset, {
      set text(..edges(pitch-single))
      inl(q)
    }))
  }
}

/// Each blank-line-separated chunk of markdown is one unit. "#" is a centred bold heading (PRELIMINARY STATEMENT,
/// ARGUMENT); "##" is a bold heading flush left (a POINT heading); "###" is bold italic flush left; each on the body
/// pitch, a blank double line above it, kept with the text after it. A chunk starting with ">" is a block quotation.
/// Every other chunk is one double-spaced paragraph with a first-line indent, with no space between paragraphs.
#let body-content(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let i = 0
  while i < chunks.len() {
    let t = chunks.at(i)
    if t.starts-with("#") {
      let level = t.match(regex("^#+")).text.len()
      let words = text(weight: "bold", style: if level >= 3 { "italic" } else { "normal" }, inl(t.slice(level).trim()))
      block(width: 100%, above: gap, sticky: true, if level == 1 { align(center, words) } else { words })
    } else if t.starts-with(">") {
      // consecutive ">" chunks are one quotation (pandoc reads them so)
      let q = t
      while i + 1 < chunks.len() and chunks.at(i + 1).starts-with(">") {
        i += 1
        q += "\n\n" + chunks.at(i)
      }
      quotation(q)
    } else {
      block(width: 100%, [#h(para-indent)#inl(t)])
    }
    i += 1
  }
}

// ---------------------------------------------------------------------------
// Signature block and certificate of service (LBR 9013-1(c))
// ---------------------------------------------------------------------------

#let signature(meta) = block(width: 100%, breakable: false, above: gap, grid(
  columns: (sig-left, 1fr),
  column-gutter: caption-gutter,
  line-stack(("Dated: " + meta.dated,)),
  line-stack(("Respectfully submitted,",) + meta.signature.firm + ("", "By: /s/ " + meta.signature.signer)
    + meta.signature.lines),
))

/// The certificate of service follows the signature block. Its manner of service is stated by the sample
/// (LBR 9013-1(c): "the manner in which service or notice was accomplished on each party").
#let certificate(meta) = if "certificate" in meta and meta.certificate != none {
  let c = meta.certificate
  block(width: 100%, above: gap, sticky: true, align(center, text(weight: "bold",
    inl(c.at("title", default: "CERTIFICATE OF SERVICE")))))
  for p in c.paragraphs { block(width: 100%, [#h(para-indent)#inl(p)]) }
  block(width: 100%, breakable: false, grid(
    columns: (sig-left, 1fr),
    column-gutter: caption-gutter,
    // A sworn affidavit of service may carry no date line of its own (the jurat carries the date).
    line-stack(if "dated" in c and c.dated != none { ("Dated: " + c.dated,) } else { ("",) }),
    line-stack(("", "/s/ " + c.signer)),
  ))
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let nynb-motion-brief(meta, body) = {
  set document(title: meta.title)
  // LBR 9004-1(a)(2)(B): consecutively numbered pages, the number centred at the foot of every page, in a
  // single-spaced line box where Word's footer sets it.
  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (double spaced). The template sets no lists.
  show: xengine.with(pitch: pitch-double, list-indent: none)
  // A doubled sign stays with its number too ("§§ 151"; xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)
  cover(meta)
  body-content(body)
  signature(meta)
  certificate(meta)
}
