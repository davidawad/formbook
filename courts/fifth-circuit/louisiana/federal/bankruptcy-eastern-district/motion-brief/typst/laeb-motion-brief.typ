// Memorandum in support of a motion, United States Bankruptcy Court, Eastern District of Louisiana.
// Rules: Fed. R. Bankr. P. 9013 (a motion states its grounds with particularity and the relief requested),
// 9004(a) (legible), 9004(b) (caption contents); Fed. R. Bankr. P. 7056 applies Fed. R. Civ. P. 56 to summary
// judgment motions in adversary proceedings. E.D. La. Local Rule 9013-2: a motion's authorities may be
// incorporated in the motion or set out in a separate memorandum served and filed with it. The 2013 Local
// Rules set no paper, type or margin rule (see ../README.md). Typography is a convention, not a rule.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let court-lines = ("UNITED STATES BANKRUPTCY COURT", "EASTERN DISTRICT OF LOUISIANA")  // Fed. R. Bankr. P. 9004(b)
#let font-family = ("Times New Roman", "Liberation Serif")   // no E.D. La. font rule; the exemplar is Times New Roman (vendored)
#let type-size = 12pt                   // convention: the exemplar's body is 12 pt
#let note-size = 10pt                   // footnotes, as the exemplar's are smaller than the body
#let footer-size = 11pt                 // the "Page X of Y" footer
#let margin = 1in                       // convention: the exemplar's margins are 1 inch; letter paper
#let text-width = 8.5in - 2 * margin
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let heading-box = 0.5in                // a heading's number ("I.", "A.", "1."), the text hanging after it (docx: a tab)
#let label-box = 0.6in                  // a list item's number "(1)", hanging, half an inch in (docx: Pleading List)
#let caption-left = 3.4in               // width of the party column of the caption
#let caption-gutter = 0.25in            // between the party column and the case information
#let caption-pad = 10pt                 // the party column's text stands off its rule
#let caption-foot = 6pt                 // the rule runs this far below the last party line
#let case-pad = 0.1in                   // the case information stands off the gutter
#let designation-indent = 1.6in         // a party's designation ("Debtors.", "PLAINTIFFS") under its names
#let sig-left = 3in                     // the signature block's column

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/laeb-motion-brief.lua sets the same twips).
#let pitch-body = 24pt                  // convention: double-spaced body text (exemplar)
#let pitch-single = 13.8pt              // caption, block quotations, signature block
#let pitch-note = 11.5pt                // footnotes, single-spaced at 10 pt
#let pitch-footer = 13.8pt              // the footer line
#let court-below = 12pt                 // court name to the caption
#let caption-below = 12pt               // the caption to the title
#let title-below = 12pt                 // the title to the text
#let heading-above = 12pt               // every heading
#let quote-space = 12pt                 // a block quotation's space above and below it
#let note-gap = 6pt                     // between two footnotes
#let note-clearance = 12pt              // the body text to the footnote rule
#let signature-above = 24pt             // the last paragraph to the signature block
#let sig-gap = 24pt                     // signature block: the date to "Respectfully submitted," and that to the firm
#let line-gap = 12pt                    // signature block: the firm to the By line, and that to the counsel lines
#let cert-above = 24pt                  // the signature block to the certificate of service
#let cert-sig = 12pt                    // the certificate's text to its signature

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("laeb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for case names in italics, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Blank-line-separated chunks of the body, without empty ones.
#let chunks-of(body) = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")

/// Footnote definitions (`[^key]: text`) are collected from the whole body. A chunk that uses a key gets
/// its definition appended, so cmarker renders the footnote where it is referenced.
#let note-defs(chunks) = {
  let defs = (:)
  for c in chunks {
    let m = c.match(regex("^\\[\\^([^\\]]+)\\]:[ \\t]*([\\s\\S]*)$"))
    if m != none { defs.insert(m.captures.at(0), m.captures.at(1)) }
  }
  defs
}

#let with-notes(t, defs) = {
  let keys = ()
  for m in t.matches(regex("\\[\\^([^\\]]+)\\]")) {
    let k = m.captures.at(0)
    if k not in keys { keys.push(k) }
  }
  t + keys.map(k => "\n\n[^" + k + "]: " + defs.at(k)).join("")
}

/// "# Text" is level 1, "## Text" level 2, "### Text" level 3.
#let heading-level(t) = t.split(" ").first().len()
#let heading-text(t) = t.slice(heading-level(t)).trim()

/// Inline content without the paragraph breaks cmarker may put around it (they may not occur inside a paragraph).
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// One line (a paragraph of its own), with an explicit space above it and a left indent.
#let line-block(above: 0pt, left: 0pt, center: false, body) = block(width: 100%, above: above, below: 0pt,
  align(if center { std.center } else { std.left }, pad(left: left,
    par(first-line-indent: 0pt, if type(body) == str { unloose(inl(body)) } else { body }))))

// ---------------------------------------------------------------------------
// Caption: court title, parties (left, with a rule at its right edge), case information (right)
// ---------------------------------------------------------------------------

/// Parties in order. Each party is {names, designation, sep}; "v." (or the sample's own word in `sep`)
/// is printed before every party but the first, unless `sep` is "" (a debtor's line, for example). A blank
/// line separates two parties.
#let party-stack(c) = {
  set text(..edges(pitch-single))
  if "lead" in c { line-block(c.lead) }
  for (k, p) in c.parties.enumerate() {
    let sep = p.at("sep", default: "v.")
    let gap = if k > 0 { pitch-single } else { 0pt }
    if k > 0 and sep != "" {
      line-block(above: gap, sep)
      gap = 0pt
    }
    for n in p.names {
      line-block(above: gap, n)
      gap = 0pt
    }
    line-block(left: designation-indent, p.designation)
  }
}

#let caption(meta) = {
  set text(..edges(pitch-single))
  for l in court-lines { line-block(center: true, text(weight: "bold", l)) }
  block(above: court-below, below: 0pt, grid(
    columns: (caption-left, caption-gutter, text-width - caption-left - caption-gutter),
    grid.cell(stroke: (right: 0.75pt), inset: (right: caption-pad, bottom: caption-foot), party-stack(meta.caption)),
    [],
    pad(left: case-pad, for c in meta.case_info { line-block(c) }),
  ))
  block(width: 100%, sticky: true, above: caption-below, below: title-below,
    align(center, text(weight: "bold", inl(meta.title))))
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// A body paragraph at the body pitch, its first line indented half an inch.
#let body-par(content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), unloose(content)))

/// Headings are numbered by the template: level 1 "I." at the margin (the text in capitals: the text, not a style, so
/// every engine prints the same characters), level 2 "A." half an inch in, level 3 "1." an inch in, bold italic; the
/// number in its box, the text hanging after it. Kept with the block after it (sticky), so it never ends a page.
#let heading-block(t, n) = {
  let lvl = calc.min(heading-level(t), 3)
  let txt = heading-text(t)
  let (label, indent, body) = if lvl == 1 {
    (numbering("I.", n.at(0)), 0pt, text(weight: "bold", inl(upper(txt))))
  } else if lvl == 2 {
    (numbering("A.", n.at(1)), para-indent, text(weight: "bold", inl(txt)))
  } else {
    (numbering("1.", n.at(2)), 2 * para-indent, text(weight: "bold", style: "italic", inl(txt)))
  }
  block(width: 100%, sticky: true, above: heading-above, below: 0pt, pad(left: indent,
    par(first-line-indent: 0pt, hanging-indent: heading-box,
      [#box(width: heading-box, text(weight: "bold", style: if lvl == 3 { "italic" } else { "normal" }, label))#unloose(body)])))
}

/// Items of a markdown list, one string per item (continuation lines are joined).
#let list-items(c) = {
  let out = ()
  for line in c.split("\n") {
    let m = line.match(regex("^\\s*(?:\\d+\\.|[-*+])\\s+(.*)$"))
    if m != none { out.push(m.captures.at(0)) } else if out.len() > 0 {
      out.at(-1) = out.at(-1) + " " + line.trim()
    }
  }
  out
}

/// The body: paragraphs (not numbered), headings (numbered by the template), block quotations (single-spaced,
/// indented half an inch on both sides) and lists ((1), (2), ... half an inch in, the text hanging).
#let argument-body(body, defs) = {
  let n = (0, 0, 0)
  for t in chunks-of(body) {
    if t.starts-with("[^") { continue }
    if t.starts-with("#") {
      let lvl = heading-level(t)
      if lvl == 1 { n = (n.at(0) + 1, 0, 0) } else if lvl == 2 { n = (n.at(0), n.at(1) + 1, 0) } else {
        n = (n.at(0), n.at(1), n.at(2) + 1)
      }
      heading-block(t, n)
    } else if t.starts-with(">") {
      block(width: 100%, above: quote-space, below: quote-space, pad(x: para-indent, {
        set text(..edges(pitch-single))
        set par(first-line-indent: 0pt)
        inl(with-notes(t.replace(regex("(?m)^>[ \t]?"), ""), defs))
      }))
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      for (i, item) in list-items(t).enumerate() {
        block(width: 100%, above: 0pt, below: 0pt, pad(left: para-indent,
          par(first-line-indent: 0pt, hanging-indent: label-box,
            [#box(width: label-box)[(#(i + 1))]#unloose(inl(with-notes(item, defs)))])))
      }
    } else {
      body-par(inl(with-notes(t, defs)))
    }
  }
}

/// Dated line (at the margin) and the counsel signature block (single-spaced, in the column at sig-left), kept on one
/// page. The space above it is spacing of its own (docx: an empty paragraph of that height), so it stays behind when
/// the block moves to the next page.
#let signature-block(meta) = v(signature-above) + block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
  set text(..edges(pitch-single))
  let above = 0pt
  if "date" in meta {
    line-block([Dated: #unloose(inl(meta.date))])
    above = sig-gap
  }
  line-block(above: above, left: sig-left, [Respectfully submitted,])
  let gap = sig-gap
  if "firm" in meta.signature {
    line-block(above: gap, left: sig-left, meta.signature.firm)
    gap = line-gap
  }
  line-block(above: gap, left: sig-left, [By: #unloose(inl(meta.signature.by))])
  for (j, l) in meta.signature.lines.enumerate() {
    line-block(above: if j == 0 { line-gap } else { 0pt }, left: sig-left, l)
  }
})

/// Certificate of service: its title, its text and the signer's /s/ line, kept on one page.
#let certificate-block(c) = v(cert-above) + block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
  line-block(center: true, text(weight: "bold", "CERTIFICATE OF SERVICE"))
  body-par(inl(c.text))
  set text(..edges(pitch-single))
  line-block(above: cert-sig, left: sig-left, "/s/ " + c.signer)
})

#let laeb-motion-brief(meta, body) = {
  let defs = note-defs(chunks-of(body))

  // Every page numbered "Page X of Y", bottom centre, in a single-spaced line box (Word's footer).
  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(size: footer-size, ..edges(pitch-footer))[
      Page #counter(page).display() of #counter(page).final().first()
    ]),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, footnote marks at 58 %. The template writes its own headings and lists (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // Times New Roman has no glyph for U+2010 HYPHEN: it is set as the hyphen-minus, the same mark in the face, so no
  // fallback face sets it (LibreOffice splits a word at such a fallback; docx/laeb-motion-brief.lua does the same).
  show "\u{2010}": "-"
  set footnote.entry(separator: line(length: 30%, stroke: 0.5pt), gap: note-gap, clearance: note-clearance, indent: 0pt)
  show footnote.entry: it => {
    set text(size: note-size, ..edges(pitch-note))
    set par(first-line-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  caption(meta)
  argument-body(body, defs)
  signature-block(meta)
  if "certificate" in meta { certificate-block(meta.certificate) }
}
