// Motion with incorporated memorandum (or memorandum in support of motion) for the United States Bankruptcy
// Court, Southern District of Florida, filed in an adversary proceeding.
// Rules (verified 2026-10-14; see ../README.md): Fed. R. Bankr. P. 9004(b) (caption), 9013 (a motion must state
// its grounds with particularity and the relief requested), 7010 (adversary caption); S.D. Fla. Bankr. L.R.
// 9004-1(a)(2)-(4) (1-inch margins, 12-point type, double spacing except captions, headings, quotations over
// 50 words, footnotes, signature blocks and certificates), 9004-1(d) (no incorporation by reference of other
// filed documents), 9004-1(e)(2) (adversary caption form), 9013-1(a) (conferral certification).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // L.R. 9004-1(a)(3): 12-point font, no face named; Times New Roman, the house standard (docs/FONTS.md)
#let type-size = 12pt                   // L.R. 9004-1(a)(3)
#let footnote-size = 10pt               // L.R. 9004-1(a)(3): footnotes may be 10-point
#let margin = 1in                       // L.R. 9004-1(a)(2): at least one inch on every side
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let item-indent = 0.5in                // lettered or roman parentheticals ("(i) ...") stand this far in
#let caption-left = 3.4in               // width of the party column of the caption
#let caption-gutter = 0.2in
#let quote-inset = 0.5in                // block quotations are indented on both sides
#let sig-indent = 3in                   // the signature block and the certificate's signature stand this far in

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt                // L.R. 9004-1(a)(4): double spacing, two 12 pt lines
#let pitch-single = 13.8pt              // single-spaced caption, title, headings, quotations, signature, certificates: 1.15 x 12 pt
#let pitch-note = 11.5pt                // single-spaced 10 pt footnotes: 1.15 x 10 pt
#let gap-half = 12pt                    // half a double line: inside the caption and the signature, around quotations and headings
#let note-gap = 7pt                     // between two footnotes
#let note-clearance = 3.5pt             // from the last text line to the separator: with note-gap, the 10.5 pt LibreOffice keeps between the text and the first note (its separator 0.5 pt, about 5 pt above the note; measured on our docx render)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("flsb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline and block markdown (names with *et al.*, the sample's emphasis).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  body
})

/// Single lines, the first with space above it.
#let line-group(above, items) = for (i, l) in items.enumerate() { line-block(above: if i == 0 { above } else { 0pt }, md(l)) }

// ---------------------------------------------------------------------------
// Caption (L.R. 9004-1(e)(2)): court, division, debtor and case, parties and adversary number
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  line-block(align(center, text(weight: "bold", "UNITED STATES BANKRUPTCY COURT")))
  line-block(align(center, text(weight: "bold", meta.district)))
  // The division is printed as a blank line when the sample does not name one (L.R. 9004-1(e)(2)).
  let division = if "division" in meta { upper(meta.division) } else { "___________" }
  line-block(above: pitch-double, align(center, text(weight: "bold", division + " DIVISION")))
}

/// The caption: two rows. The debtor ("In re:") with the case number and chapter; then the parties with the
/// adversary number at the first party's line. Each row closes with the rule "____/".
#let caption(meta) = {
  let rule = "_" * 36 + "/"
  let parties = ()
  for (k, p) in meta.parties.enumerate() {
    if k > 0 { parties.push("v.") }
    parties += p.names + (p.designation,)
  }
  block(width: 100%, above: pitch-double, below: 0pt, grid(
    columns: (caption-left, caption-gutter, 1fr),
    row-gutter: gap-half,
    {
      line-group(0pt, ("In re:", ..meta.debtor.names, meta.debtor.designation))
      line-block(above: gap-half, rule)
    },
    [],
    line-group(0pt, ("Case No. " + meta.case_number, "Chapter " + meta.chapter)),
    {
      line-group(0pt, parties)
      line-block(above: gap-half, rule)
    },
    [],
    line-block("Adv. Case No. " + meta.adv_number),
  ))
}

#let cover(meta) = {
  court-title(meta)
  caption(meta)
  line-block(above: pitch-double, below: pitch-double, align(center, text(weight: "bold", md(meta.title))))
}

// ---------------------------------------------------------------------------
// Body. Paragraphs are double-spaced with a first-line indent and not numbered. Headings are typed by the author
// (I., A., (i)); block quotations are single-spaced; lettered or roman parentheticals are indented.
// ---------------------------------------------------------------------------

/// Footnote definitions ("[^key]: text") of the body, by key.
#let footnote-defs(body) = {
  let defs = ()
  for line in body.split("\n") {
    let m = line.match(regex("^\\[\\^([^\\]]+)\\]:[ \\t]*(.*)$"))
    if m != none { defs.push((key: m.captures.at(0), text: m.captures.at(1))) }
  }
  defs
}

/// cmarker resolves footnotes per render call, so a paragraph is rendered together with the definitions it cites.
#let with-defs(t, defs) = {
  let extra = defs.filter(d => t.contains("[^" + d.key + "]")).map(d => "[^" + d.key + "]: " + d.text)
  t + if extra.len() > 0 { "\n\n" + extra.join("\n\n") } else { "" }
}

/// A body paragraph at the double pitch, first-line indented.
#let body-par(content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), content))

/// Body chunks: a heading, a block quotation (single-spaced, indented on both sides, half a double line above and
/// below), a lettered or roman parenthetical (indented), or a paragraph. The last chunk stays on one page with
/// `tail` (the signature block), so a signature never stands alone.
#let memorandum-body(body, tail) = {
  let defs = footnote-defs(body)
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "" and not c.starts-with("[^"))
  for (i, t) in chunks.enumerate() {
    let piece = if t.starts-with("#") {
      md(t)
    } else if t.starts-with(">") {
      line-block(above: gap-half, below: gap-half,
        pad(x: quote-inset, md(with-defs(t.replace(regex("(?m)^>[ \t]?"), ""), defs))))
    } else if t.starts-with(regex("^\\([a-z]+\\)[ \\t]")) {
      block(width: 100%, above: 0pt, below: 0pt, pad(left: item-indent, par(first-line-indent: 0pt, md(with-defs(t, defs)))))
    } else {
      body-par(md(with-defs(t, defs)))
    }
    if i == chunks.len() - 1 { block(width: 100%, breakable: false, above: 0pt, below: 0pt, { piece; tail }) } else { piece }
  }
}

// ---------------------------------------------------------------------------
// Signature, certificate of conferral (L.R. 9013-1(a)) and certificate of service
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(width: 100%, breakable: false, above: pitch-double, below: 0pt, pad(left: sig-indent, {
  line-block[Respectfully submitted,]
  line-group(gap-half, meta.signature.firm)
  line-group(gap-half, ("By: /s/ " + meta.signature.signer,) + meta.signature.lines)
}))

#let conferral-block(meta) = if "conferral" in meta and meta.conferral != none {
  block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
    line-block(below: gap-half, align(center, text(weight: "bold", "CERTIFICATE OF CONFERRAL")))
    body-par(md(meta.conferral))
  })
}

#let certificate-block(meta) = if "certificate" in meta and meta.certificate != none {
  let c = meta.certificate
  block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
    line-block(below: gap-half, align(center, text(weight: "bold", "CERTIFICATE OF SERVICE")))
    line-block(par(first-line-indent: (amount: para-indent, all: true))[I HEREBY CERTIFY that a true and correct copy of the foregoing was served electronically via CM/ECF, Email, and/or via U.S. Mail, as indicated on the attached service list on this #c.date.])
    block(width: 100%, above: gap-half, below: 0pt, pad(left: sig-indent, line-group(0pt, ("By: /s/ " + c.signer, c.signer))))
    line-block(above: pitch-double, below: gap-half, align(center, text(weight: "bold", "SERVICE LIST")))
    line-group(0pt, c.service_list)
  })
}

#let flsb-motion-brief(meta, body) = {
  // The page number: centered in a single-spaced line box, at the same place on every page (Word's footer).
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
  // A doubled sign stays with its number too ("¶¶ 20", "§§ 157"; xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)
  // A quotation mark right after sentence punctuation closes a quotation (cmarker reads an unmatched one as
  // opening; pandoc, the docx reader, as closing).
  show regex("[.,;:!?][\u{201C}]"): it => it.text.replace("\u{201C}", "\u{201D}")
  // Footnotes (L.R. 9004-1(a)(3), (4)): 10 pt, single-spaced; the mark, a space, the note (Word's footnote).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 2in, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: footnote-size, ..edges(pitch-note))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    [#super(num)#h(0.25em)#note.body]
  }
  // Headings (single-spaced, L.R. 9004-1(a)(4)): 12 pt, half a double line above and below, kept with the text
  // after them; level 1 centered bold capitals, level 2 bold, level 3 bold italic.
  show heading: it => block(sticky: true, width: 100%, above: gap-half, below: gap-half, {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt)
    if it.level == 1 { align(center, text(weight: "bold", upper(it.body))) } else if it.level == 2 {
      text(weight: "bold", it.body)
    } else { text(weight: "bold", style: "italic", it.body) }
  })

  cover(meta)
  memorandum-body(body, signature-block(meta))
  conferral-block(meta)
  certificate-block(meta)
}
