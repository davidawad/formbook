// Memorandum of law (brief) in support of a motion for the U.S. District Court for the Southern
// District of Georgia (gasd). Rules: S.D. Ga. LR 7.1(a) (length), LR 7.1(b) (motion cites authority;
// factual assertions cite the record), LR 10.1 (double-spaced, numbered pages), LR 5.1 (certificate of
// service), LR 5.4 (letter paper), LR 11.1 (counsel name, address, telephone, State Bar number);
// Fed. R. Civ. P. 7(b)(1) (grounds stated with particularity). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see ../README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // no S.D. Ga. typeface rule found (README.md); Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                   // the exemplar and the usual practice; not set by an S.D. Ga. rule
#let body-leading = 1.345em             // LR 10.1 double-spacing: Liberation Serif's line box is 0.655em, so this is a 24 pt pitch at 12 pt
#let single-leading = 0.495em            // single spacing for the caption, quotations, footnotes and signature
#let single-row = 13.8pt                // one single-spaced line: 0.655em line box + single-leading at 12 pt
#let page-w = 8.5in                     // LR 5.4: paper 8 1/2 by 11 inches
#let page-h = 11in
#let margin = 1in                       // not set by a rule (README.md); the usual 1-inch margin
#let text-width = page-w - 2 * margin
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-party-width = 3.1in        // width of the party column in the caption
#let caption-paren-width = 0.3in        // the ")" column of the caption
#let signature-indent = 3.2in           // signature blocks start this far in from the left margin

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

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(leading: single-leading, spacing: 0pt)
  align(center, {
    text(weight: "bold", "IN THE UNITED STATES DISTRICT COURT")
    linebreak()
    text(weight: "bold", "FOR THE SOUTHERN DISTRICT OF GEORGIA")
    if "division" in meta {
      linebreak()
      text(weight: "bold", upper(meta.division))
    }
  })
}

/// Caption: one row per line of the party column, a ")" in the middle, and the case number beside it.
/// Each row of frontmatter `caption.rows` is `{left: ..., right: ...}`; "right" may be empty.
#let caption(meta) = {
  set par(leading: single-leading, spacing: 0pt)
  let rows = meta.caption.rows
  grid(
    columns: (caption-party-width, caption-paren-width, 1fr),
    rows: (single-row,) * rows.len(),
    row-gutter: 0pt,
    ..rows.map(r => (text(r.left), [)], text(r.right))).flatten(),
  )
}

#let title-block(meta) = {
  set par(leading: single-leading, spacing: 0pt)
  v(body-leading)
  align(center, text(weight: "bold", upper(inl(meta.title))))
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Page number centered in the bottom margin, on every page including the first (LR 10.1).
#let footer-number() = context {
  set text(size: type-size)
  align(center, counter(page).display("- 1 -"))
}

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
  let chunks = all.filter(c => not c.trim().starts-with("[^"))
  let sec = 0
  let sub = 0
  let subsub = 0
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      let lvl = t.match(regex("^#+")).text.len()
      let txt = t.slice(lvl).trim()
      if lvl == 1 {
        sec += 1
        sub = 0
        subsub = 0
        block(width: text-width, above: body-leading, below: body-leading, sticky: true,
          align(center, text(weight: "bold", [#numbering("I.", sec)#h(0.5em)#inl(upper(txt) + "\n\n" + notes)])))
      } else if lvl == 2 {
        sub += 1
        subsub = 0
        block(width: text-width, above: body-leading, below: body-leading, sticky: true,
          text(weight: "bold", [#numbering("A.", sub)#h(0.5em)#inl(txt + "\n\n" + notes)]))
      } else {
        subsub += 1
        block(width: text-width, above: body-leading, below: body-leading, sticky: true,
          text(weight: "bold", style: "italic", [#numbering("1.", subsub)#h(0.5em)#inl(txt + "\n\n" + notes)]))
      }
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list may break across pages. Items are double-spaced like the text.
      set par(leading: body-leading)
      cmarker.render(t + "\n\n" + notes, raw-typst: false, smart-punctuation: true, h1-level: 1)
      v(body-leading)
    } else if t.starts-with(">") {
      // A block quotation: indented and single-spaced, run in as one paragraph (its lines are joined).
      let quoted = t.split("\n").map(l => { let s = l.trim(); if s.starts-with(">") { s.slice(1).trim() } else { s } }).filter(s => s != "").join(" ")
      pad(left: 0.75in, right: 0.75in, block(width: 100%, {
        set par(leading: single-leading)
        text(quoted)
      }))
      v(body-leading)
    } else {
      set par(leading: body-leading)
      h(para-indent)
      cmarker.render(t + "\n\n" + notes, raw-typst: false, smart-punctuation: true, h1-level: 1)
      v(body-leading)
    }
  }
}

#let signature-block(meta) = {
  set par(leading: single-leading, spacing: 0pt)
  block(breakable: false, width: text-width, {
    v(body-leading)
    if "date" in meta.signature { [This the #meta.signature.date.] ; v(body-leading) }
    // The signature sits in the right-hand column; its lines wrap inside that column.
    pad(left: signature-indent, block(width: text-width - signature-indent, {
      [Respectfully submitted,]
      v(body-leading * 0.5)
      for s in meta.signature.signers {
        [By: /s/ #s.name]
        linebreak()
        s.name
        for l in s.lines { linebreak(); inl(l) }
        v(body-leading * 0.5)
      }
    }))
  })
}

/// Certificate of service (LR 5.1): the caption again, then the statement of service and the signature.
#let certificate(meta) = {
  pagebreak()
  court-title(meta)
  v(body-leading)
  caption(meta)
  title-block(meta)
  set par(leading: body-leading)
  h(para-indent)
  [I hereby certify that on #meta.service.date, I electronically filed the foregoing #upper(inl(meta.title)) with the Clerk of Court using the CM/ECF system, which will send notification of such filing to counsel of record.]
  if "unregistered" in meta.service {
    [ I further certify that I served a true and correct copy of the same on the following by First-Class Mail, postage prepaid, addressed to:]
    v(single-leading)
    set par(leading: single-leading, spacing: 0pt)
    for p in meta.service.unregistered {
      pad(left: 1in, {
        for l in p { linebreak(); inl(l) }
      })
      v(body-leading * 0.5)
    }
  }
  set par(leading: single-leading, spacing: 0pt)
  block(breakable: false, width: text-width, {
    v(body-leading)
    pad(left: signature-indent, block(width: text-width - signature-indent, {
      [/s/ #meta.service.signer.name]
      for l in meta.service.signer.lines { linebreak(); inl(l) }
    }))
  })
}

#let gasd-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    footer: footer-number(),
    footer-descent: 0.4in,
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Footnotes: 12 pt, single-spaced (Harper exemplar practice; no S.D. Ga. rule found).
  show footnote.entry: set text(size: type-size)
  set footnote.entry(indent: 0pt)

  // Block quotations: indented on both sides, single-spaced.
  show quote.where(block: true): it => pad(left: 0.75in, right: 0.75in, block(width: 100%, {
    set par(leading: single-leading)
    it.body
  }))

  set enum(numbering: "1.", indent: para-indent, body-indent: 0.4in, spacing: body-leading)
  set list(indent: para-indent, body-indent: 0.4in, spacing: body-leading)

  court-title(meta)
  v(body-leading)
  caption(meta)
  title-block(meta)

  body-text(body)

  signature-block(meta)
  certificate(meta)
}
