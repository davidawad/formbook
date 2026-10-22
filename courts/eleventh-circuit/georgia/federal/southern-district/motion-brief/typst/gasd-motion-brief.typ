// Memorandum of law (brief) in support of a motion for the U.S. District Court for the Southern
// District of Georgia (gasd). Rules: S.D. Ga. LR 7.1(a) (length), LR 7.1(b) (motion cites authority;
// factual assertions cite the record), LR 10.1 (double-spaced, numbered pages), LR 5.1 (certificate of
// service), LR 5.4 (letter paper), LR 11.1 (counsel name, address, telephone, State Bar number);
// Fed. R. Civ. P. 7(b)(1) (grounds stated with particularity). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see ../README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // no S.D. Ga. typeface rule found (README.md); Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                   // the exemplar and the usual practice; not set by an S.D. Ga. rule
#let margin = 1in                       // not set by a rule (README.md); the usual 1-inch margin
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let item-label = 0.4in                 // a list item's label box, after the paragraph indent
#let quote-indent = 0.75in              // block quotations, both sides
#let address-indent = 1in               // the certificate's mailing addresses
#let caption-party-width = 3.1in        // width of the party column in the caption
#let caption-paren-width = 0.3in        // the ")" column of the caption
#let signature-indent = 3.2in           // signature blocks start this far in from the left margin

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-body = 24pt                  // LR 10.1 double-spacing: a 24 pt pitch at 12 pt (headings too)
#let pitch-single = 13.8pt              // single spacing (caption, quotations, footnotes, signature): Word's single line, 1.15 x 12 pt
#let gap = 16.2pt                       // between paragraphs, around headings and quotations
#let sig-gap = gap / 2                  // inside the signature block
#let note-gap = 7pt                     // between footnotes
#let note-clearance = 12.6pt            // between the text and the footnote rule

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("gasd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names with *...*, footnote marks, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced paragraph with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: left, body)
})

/// A paragraph at the body pitch with a first-line indent, a gap below it.
#let body-par(content) = block(width: 100%, above: 0pt, below: gap,
  par(first-line-indent: (amount: para-indent, all: true), content))

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  let lines = ("IN THE UNITED STATES DISTRICT COURT", "FOR THE SOUTHERN DISTRICT OF GEORGIA")
  if "division" in meta { lines.push(upper(meta.division)) }
  for (i, l) in lines.enumerate() {
    line-block(below: if i == lines.len() - 1 { gap } else { 0pt }, align(center, text(weight: "bold", l)))
  }
}

/// Caption: one row per line of the party column, a ")" in the middle, and the case number beside it.
/// Each row of frontmatter `caption.rows` is `{left: ..., right: ...}`; "right" may be empty.
#let caption(meta) = block(above: 0pt, below: 0pt, grid(
  columns: (caption-party-width, caption-paren-width, 1fr),
  ..meta.caption.rows.map(r => (line-block(r.left), line-block[)], line-block(r.right))).flatten(),
))

#let title-block(meta) = line-block(above: gap, below: gap, align(center, text(weight: "bold", upper(inl(meta.title)))))

// ---------------------------------------------------------------------------
// Body: headings (numbered I., A., 1.), paragraphs, lists, quotations
// ---------------------------------------------------------------------------

/// The body. Headings are numbered here, not typed in the sample: level 1 is a centered Roman
/// numeral section, level 2 a capital letter, level 3 an Arabic numeral. Each blank-line-separated
/// chunk that is not a heading is one double-spaced paragraph with a first-line indent.
/// A heading is kept with the paragraph after it (`sticky`), so it never ends a page.
#let body-text(body) = {
  let all = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // Footnote definitions ("[^key]: text") are not paragraphs. Each chunk is rendered with all of them, so a
  // reference resolves to its definition wherever the definition sits in the file.
  let notes = all.filter(c => c.trim().starts-with("[^")).join("\n\n")
  let md(s) = cmarker.render(s + "\n\n" + notes, raw-typst: false, smart-punctuation: true)
  let chunks = all.filter(c => not c.trim().starts-with("[^"))
  let (sec, sub, subsub) = (0, 0, 0)
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      let lvl = t.match(regex("^#+")).text.len()
      let txt = t.slice(lvl).trim()
      let h = if lvl == 1 {
        sec += 1
        (sub, subsub) = (0, 0)
        align(center, text(weight: "bold", [#numbering("I.", sec) #md(upper(txt))]))
      } else if lvl == 2 {
        sub += 1
        subsub = 0
        text(weight: "bold", [#numbering("A.", sub) #md(txt)])
      } else {
        subsub += 1
        text(weight: "bold", style: "italic", [#numbering("1.", subsub) #md(txt)])
      }
      block(width: 100%, above: gap, below: gap, sticky: true, { set par(first-line-indent: 0pt); h })
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list: each item a double-spaced paragraph, its label after the paragraph indent, the text hanging.
      let marker = regex("^(\\d+\\.|[-*+])[ \\t]+")
      let its = ()
      for l in t.split("\n").map(l => l.trim()).filter(l => l != "") {
        if l.starts-with(marker) or its.len() == 0 { its.push(l) } else { its.last() += " " + l }
      }
      for (i, s) in its.enumerate() {
        let lab = if s.starts-with(regex("^\\d")) { str(i + 1) + "." } else { "•" }
        block(width: 100%, above: 0pt, below: gap, par(hanging-indent: para-indent + item-label,
          first-line-indent: 0pt, [#h(para-indent)#box(width: item-label, lab)#md(s.replace(marker, ""))]))
      }
    } else if t.starts-with(">") {
      // A block quotation: indented and single-spaced, run in as one paragraph (its lines are joined).
      let quoted = t.split("\n").map(l => l.trim().trim(">", at: start).trim()).filter(s => s != "").join(" ")
      line-block(above: 0pt, below: gap, pad(x: quote-indent, md(quoted)))
    } else {
      body-par(md(t))
    }
  }
}

/// The signature: the date line, then "Respectfully submitted," and each signer in the right-hand column (LR 11.1).
#let signature-block(meta) = block(breakable: false, width: 100%, above: 0pt, below: 0pt, {
  let sig = meta.signature
  if "date" in sig { line-block(above: gap, below: gap)[This the #sig.date.] }
  line-block(above: gap, left: signature-indent)[Respectfully submitted,]
  for s in sig.signers {
    line-block(above: sig-gap, left: signature-indent)[By: /s/ #s.name]
    for l in (s.name, ..s.lines) { line-block(left: signature-indent, inl(l)) }
  }
})

/// Certificate of service (LR 5.1), on a page of its own: the caption again, then the statement of service and
/// the signature.
#let certificate(meta) = {
  pagebreak()
  court-title(meta)
  caption(meta)
  title-block(meta)
  let svc = meta.service
  body-par[I hereby certify that on #svc.date, I electronically filed the foregoing #upper(inl(meta.title)) with the Clerk of Court using the CM/ECF system, which will send notification of such filing to counsel of record.#if "unregistered" in svc [ I further certify that I served a true and correct copy of the same on the following by First-Class Mail, postage prepaid, addressed to:]]
  for p in svc.at("unregistered", default: ()) {
    block(width: 100%, above: sig-gap, below: 0pt, for l in p { line-block(left: address-indent, inl(l)) })
  }
  block(breakable: false, width: 100%, above: gap, below: 0pt, {
    line-block(left: signature-indent)[/s/ #svc.signer.name]
    for l in svc.signer.lines { line-block(left: signature-indent, inl(l)) }
  })
}

#let gasd-motion-brief(meta, body) = {
  // Page number "- N -" centered in the bottom margin, on every page including the first (LR 10.1), in a single-
  // spaced line box (Word's footer).
  set page(paper: "us-letter", margin: margin, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("- 1 -"))))
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number ("§§ 1334"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)

  // Footnotes: 12 pt, single-spaced (Harper exemplar practice; no S.D. Ga. rule found): the mark, a space, the note
  // (Word's footnote layout), 7 pt between notes.
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt, spacing: 0pt)
    [#super(num) #note.body]
  }

  court-title(meta)
  caption(meta)
  title-block(meta)
  body-text(body)
  signature-block(meta)
  certificate(meta)
}
