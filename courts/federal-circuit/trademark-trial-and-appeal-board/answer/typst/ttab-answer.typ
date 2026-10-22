// Trademark Trial and Appeal Board: inter partes paper (answer, answer and counterclaim, and other
// pleadings and motions that carry the standard Board caption).
//
// Rule-driven and content-agnostic. Requirement IDs (TTAB-...) refer to ../rules.md.
// No case-specific text. The body is markdown rendered by cmarker; the caption, signature block and
// certificate of service come from the YAML frontmatter of the same file (schema: ../README.md).
//
// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing). docx/ttab-answer.lua and docx/make-reference.sh
// set the same pitches and spaces (twips = 20 x pt), so the docx breaks every line and page where this does.

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

// The rule names no face (TTAB-FORM-006). Times New Roman, or the vendored Liberation Serif with the same metrics.
#let font-family = ("Times New Roman", "Liberation Serif")
#let type-size = 12pt                     // TTAB-FORM-001: at least 11-point (the template uses 12)
#let pitch-double = 27.6pt                // TTAB-FORM-002: double-spaced; Word's "double" for Times New Roman at 12 pt
#let pitch-single = 13.8pt                // caption, block quotations, signature block, certificate: single-spaced
#let page-margin = 1in                    // TTAB-FORM-005 (convention; the Board states no margin)
#let para-indent = 0.5in
#let sig-indent = 3.25in                  // the signature block starts at the middle of the text width
#let caption-col = 64%                    // caption: matter and parties left, the proceeding number right
#let caption-gutter = 8.4pt               // between the parties' text and the rule down the right of their cell
#let caption-num-pad = 13.2pt             // between that rule and the proceeding number
#let role-indent = 0.5in                  // a party's role under its name
#let versus-indent = 0.25in               // "v." between the parties
#let letter-width = 8.5in
#let letter-height = 11in

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Plain text of a piece of content, for comparisons only.
#let plain(c) = {
  if type(c) == str { c }
  else if c == [] { "" }
  else if c.has("text") { c.text }
  else if c.has("children") { c.children.map(plain).join() }
  else if c.has("body") { plain(c.body) }
  else if c.func() == [ ].func() { " " }
  else { "" }
}

#let need(meta, key) = {
  if key not in meta { panic("ttab-answer: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ttab-answer: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-spaced line (or paragraph) of a block, with explicit spaces above and below.
#let line-par(body, above: 0pt, below: 0pt, indent: 0pt) = block(above: above, below: below,
  pad(left: indent, par(first-line-indent: 0pt, body)))

/// A rule under a signature line.
#let sig-rule(indent) = block(above: 3pt, below: 4pt, pad(left: indent, line(length: 100%, stroke: 0.5pt)))

// ---------------------------------------------------------------------------
// Caption (TTAB-COVER-001, -002, -010, TTAB-CONT-002; TBMP 311.01(a), 309.02(a))
// ---------------------------------------------------------------------------

#let caption(meta) = {
  let plaintiff = need(meta, "plaintiff")
  let defendant = need(meta, "defendant")
  let matter = need(meta, "matter")
  let kind = meta.at("kind", default: "opposition")
  let number-label = if kind == "cancellation" { "Cancellation No." } else { "Opposition No." }
  set text(..edges(pitch-single))
  block(width: 100%, above: 0pt, below: 0pt, align(center, par(first-line-indent: 0pt,
    strong[IN THE UNITED STATES PATENT AND TRADEMARK OFFICE])))
  block(width: 100%, above: 0pt, below: 0pt, align(center, par(first-line-indent: 0pt,
    strong[BEFORE THE TRADEMARK TRIAL AND APPEAL BOARD])))
  block(above: 13.8pt, below: 0pt, grid(
    columns: (caption-col, 100% - caption-col),
    column-gutter: 0pt,
    // left cell: matter lines and the parties; a rule down its right edge and along its foot
    block(
      stroke: (right: 0.75pt, bottom: 0.75pt),
      inset: (right: caption-gutter, bottom: 10.8pt),
      width: 100%,
      {
        for l in matter { line-par(inl(l)) }
        line-par(inl(plaintiff.name), above: 7.2pt)
        line-par(inl(plaintiff.role), indent: role-indent)
        line-par(emph[v.], indent: versus-indent)
        line-par(inl(defendant.name))
        line-par(inl(defendant.role), indent: role-indent)
      },
    ),
    // right cell: the proceeding number, on the line of the "v." between the parties
    block(above: 0pt, below: 0pt, inset: (top: (matter.len() + 2) * pitch-single + 7.2pt),
      line-par([#number-label #need(meta, "proceeding_number")], indent: caption-num-pad)),
  ))
  block(width: 100%, above: 16.8pt, below: 10.8pt, align(center, par(first-line-indent: 0pt,
    text(weight: "bold", underline(inl(need(meta, "title")))))))
}

// ---------------------------------------------------------------------------
// Signature block (TTAB-CERT-001 to -003, -030; 37 CFR 2.119(e), 2.193(c), (d))
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  set text(..edges(pitch-single))
  block(breakable: false, width: 100%, above: 19.2pt, below: 0pt, {
    line-par(inl("Dated: " + sig.date))
    line-par(inl("Respectfully submitted,"), above: 6pt, indent: sig-indent)
    line-par(strong(inl(sig.firm)), above: 3.6pt, indent: sig-indent)
    line-par(inl(sig.esign), above: 13.2pt, indent: sig-indent)
    sig-rule(sig-indent)
    line-par(inl(sig.name), indent: sig-indent)
    line-par(inl(sig.title), indent: sig-indent)
    for l in sig.at("lines", default: ()) { line-par(inl(l), indent: sig-indent) }
  })
}

// ---------------------------------------------------------------------------
// Certificate of service (TTAB-CERT-004, -005, -031; 37 CFR 2.119(a), (b); TBMP 113.03)
// ---------------------------------------------------------------------------

#let certificate-of-service(meta) = {
  let sv = need(meta, "service")
  set text(..edges(pitch-single))
  block(width: 100%, above: 0pt, below: 0pt, align(center, par(first-line-indent: 0pt,
    text(weight: "bold", underline[CERTIFICATE OF SERVICE]))))
  let by = if sv.at("method", default: "email") == "email" { "by email" } else { sv.method }
  block(above: 14.4pt, below: 10pt, par(first-line-indent: para-indent, {
    [I hereby certify that on ]
    inl(sv.date)
    [, a true and complete copy of the foregoing ]
    inl(sv.paper)
    [ was served #by on:]
  }))
  for r in sv.recipients {
    block(breakable: false, above: 0pt, below: 12pt, {
      line-par(inl(r.name + ", " + r.role), indent: para-indent)
      for l in r.at("lines", default: ()) { line-par(inl(l), indent: para-indent) }
      line-par(inl(r.email), indent: para-indent)
    })
  }
  block(breakable: false, width: 100%, above: 18pt, below: 0pt, {
    line-par(inl(sv.esign), indent: sig-indent)
    sig-rule(sig-indent)
    line-par(inl(sv.name), indent: sig-indent)
    line-par(inl(sv.title), indent: sig-indent)
  })
}

// ---------------------------------------------------------------------------
// The paper
// ---------------------------------------------------------------------------

#let ttab-answer(meta, body) = {
  set document(title: need(meta, "title"))
  set page(
    width: letter-width,
    height: letter-height,
    margin: page-margin,
    footer: context align(center, text(size: type-size, ..edges(pitch-single), counter(page).display())),
  )
  set text(font: sys.inputs.at("font", default: font-family), size: type-size, lang: "en", region: "US",
           fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, no kerning, ligatures or hyphenation, line boxes of the body pitch,
  // bullets in a half-inch box at the margin (numbered paragraphs are set by hand below).
  show: xengine.with(pitch: pitch-double, list-indent: para-indent)

  // Headings: level 1 centred bold capitals-as-typed; level 2 bold; level 3 bold italic. No numbering.
  show heading: it => {
    set text(size: type-size, weight: "bold", ..edges(pitch-single))
    set par(first-line-indent: 0pt)
    if it.level == 1 {
      block(width: 100%, above: 19.2pt, below: 12pt, sticky: true, align(center, par(it.body)))
    } else if it.level == 2 {
      block(width: 100%, above: 15.6pt, below: 10.8pt, sticky: true, par(it.body))
    } else {
      block(width: 100%, above: 13.2pt, below: 9.6pt, sticky: true, par(text(style: "italic", it.body)))
    }
  }

  // Drafting markers: a paragraph that is entirely bold text beginning with "[" is a drafting note
  // (for example "[CONFORM: ...]"). It is set flush left, single-spaced, in italics. TTAB-TOOL-002.
  show strong: it => if plain(it.body).starts-with("[") {
    block(width: 100%, above: 10.8pt, below: 10.8pt, breakable: false, sticky: true, {
      set text(..edges(pitch-single))
      par(first-line-indent: 0pt, text(style: "italic", weight: "regular", it.body))
    })
  } else { it }

  // Block quotations: indented one inch both sides, single-spaced.
  show quote.where(block: true): it => {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    set par(spacing: 8.4pt)
    block(above: 10.8pt, below: 12pt, pad(left: 1in, right: 1in, it.body))
  }

  // Numbered paragraphs: the number sits at the first-line indent, two no-break spaces after it; wrapped lines
  // return to the margin. (Rendered by hand from the enum's children: an enum hangs its body.)
  show enum: it => {
    let n = if it.start == auto { 1 } else { it.start }
    for item in it.children {
      let k = if item.has("number") and item.number != auto and item.number != none { item.number } else { n }
      [#k.#"\u{a0}\u{a0}"#item.body]
      parbreak()
      n = k + 1
    }
  }

  caption(meta)
  // The signature block never stands alone on a page: the paper's last paragraph is kept together with it
  // (unless that last block is a heading or a list).
  let text-md = body.trim(at: end)
  let breaks = text-md.matches(regex("\n[ \t]*\n"))
  let cut = if breaks.len() > 0 { breaks.last().end } else { 0 }
  let tail = text-md.slice(cut)
  let keep = tail.len() > 0 and not tail.starts-with("#") and tail.match(regex("^\\s*([-*+]|\\d+[.)])\\s")) == none
  let render(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)
  if keep {
    render(text-md.slice(0, cut))
    block(breakable: false, above: 0pt, below: 0pt, { render(tail); signature-block(meta) })
  } else {
    render(text-md)
    signature-block(meta)
  }
  if "service" in meta {
    pagebreak(weak: true)
    certificate-of-service(meta)
  }
}
