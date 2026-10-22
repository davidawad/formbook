// E.D. La. memorandum supporting a motion (FRCP 12(b)(6) and the like). Every number is a rule or a named default;
// nothing here is case-specific. Rules (verified 2026-10-14; see ../README.md):
//   E.D. La. LR 7.4 (a contested motion is accompanied by a separate memorandum with citations of authority),
//   LR 7.7 (a memorandum supporting a motion must not exceed 25 pages, excluding exhibits; checked below),
//   LR 10.1 (8-1/2 x 11 inch, double spaced, standard font, margins of at least one inch, page numbers from "2" on,
//     and a caption that shows the Section and the judge and magistrate judge),
//   FRCP 5(b)(2)(E) (electronic service, for the certificate), FRCP 10(a) (caption).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Rule-driven parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif") // LR 10.1 "standard font"; Times New Roman (vendored) per docs/FONTS.md
#let type-size = 12pt              // LR 10.1 sets no point size; 12 pt, as in the filed exemplar
#let margin = 1in                  // LR 10.1: every margin no less than one inch
#let text-width = 8.5in - 2 * margin
#let footer-distance = 0.6in       // LR 10.1: a page number is not less than 1/2 inch from the bottom edge (its line box ends here)
#let para-indent = 0.5in           // first-line indent of body paragraphs
#let letter-box = 0.5in            // a lettered item's label box after the indent, the text hanging after it
#let quote-indent = 0.5in          // a block quotation's indent on both sides
#let caption-left = 3.25in         // width of the party column of the caption
#let caption-gutter = 0.35in       // between the party column and the case fields
#let caption-pad = 0.2in           // the caption rules stand off the party block by this much
#let versus-indent = 0.5in         // "VERSUS" between the sides
#let designation-indent = 1.5in    // "Plaintiff" / "Defendant"
#let sig-indent = 3.0in            // signature block starts at the right half of the page
#let memo-page-limit = 25          // LR 7.7: a memorandum supporting a motion, excluding exhibits

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/laed-motion-brief.lua sets the same twips).
#let pitch-body = 24pt             // LR 10.1: double spaced; body text, headings, lettered items
#let pitch-single = 13.8pt         // single spacing: court title, caption, title, quotations, signature
#let court-below = 13.8pt          // the court title to the caption
#let title-above = 24pt            // the caption to the document's title
#let title-below = 12pt            // the title to the text
#let quote-space = 12pt            // above and below a block quotation
#let sig-above = 8.2pt             // the last paragraph to the signature block (a 24 pt baseline step)
#let sig-gap = 10.2pt              // between the groups of the signature block (a blank single line's step)
#let cert-above = 24pt             // the signature block to the certificate of service

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("laed-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italic case names, and so on).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// Inline content without the paragraph breaks cmarker may put around it.
#let unloose(body) = {
  if type(body) != content or body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// One line paragraph (single pitch where the caller sets it), with an explicit space above it.
#let sline(above: 0pt, left: 0pt, centered: false, c) = block(width: 100%, above: above, below: 0pt, {
  set align(center) if centered
  pad(left: left, par(first-line-indent: 0pt, unloose(c)))
})

/// A caption field the sample leaves empty (not yet assigned): a blank line to fill in.
#let or-blank(v) = if v == none or v == "" { "______________" } else { v }

/// Paragraphs of the body, split on blank lines.
#let body-chunks(body) = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")

// ---------------------------------------------------------------------------
// Caption: FRCP 10(a) and LR 10.1
// ---------------------------------------------------------------------------

#let court-title() = {
  sline(centered: true, text(weight: "bold", [UNITED STATES DISTRICT COURT]))
  sline(centered: true, text(weight: "bold", [EASTERN DISTRICT OF LOUISIANA]))
}

/// The parties on the left, joined by VERSUS (the usage in the filed memorandum; no rule sets it) and closed by a
/// right and a bottom rule (docx: the cell's borders); on the right each case field is a label over its value, so a
/// long case number or a magistrate's name never wraps mid-token. Every line single-pitch.
#let caption(meta) = block(above: court-below, below: 0pt, grid(
  columns: (caption-left, caption-gutter, text-width - caption-left - caption-gutter),
  grid.cell(stroke: (right: 0.75pt + black, bottom: 0.75pt + black), inset: (right: caption-pad, bottom: caption-pad), {
    for (i, side) in meta.caption.enumerate() {
      if i > 0 { sline(left: versus-indent)[VERSUS] }
      for n in side.names { sline(inl(n)) }
      sline(left: designation-indent, inl(side.designation))
    }
  }),
  [],
  {
    for (label, key) in (("CIVIL ACTION NO.", "civil_action_no"), ("SECTION:", "section"), ("JUDGE", "judge"),
      ("MAGISTRATE JUDGE", "magistrate")) {
      sline(label)
      sline(or-blank(meta.at(key, default: none)))
    }
  },
))

#let title-block(meta) = block(width: 100%, above: title-above, below: title-below,
  sline(centered: true, text(weight: "bold", inl(meta.title))))

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// Heading levels, on the body pitch with no space of their own: 1 centered bold; 2 bold; 3 bold italic.
/// Sticky, so a heading never ends a page.
#let heading-block(level, t) = block(above: 0pt, below: 0pt, width: 100%, sticky: true, {
  set align(center) if level == 1
  par(first-line-indent: 0pt, if level <= 2 {
    text(weight: "bold", unloose(inl(t)))
  } else {
    text(weight: "bold", style: "italic", unloose(inl(t)))
  })
})

/// A body paragraph at the body pitch, its first line indented half an inch (memoranda are not paragraph-numbered).
#let body-par(c) = block(width: 100%, above: 0pt, below: 0pt, par(unloose(c)))

/// A lettered item: the author types the label ("A." or "(a)"); the text hangs after its box.
#let lettered-item(t) = {
  let m = t.match(regex("^(\\(?[A-Za-z]\\)?\\.?)[ \\t]+([\\s\\S]*)$"))
  block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: 0pt, hanging-indent: para-indent + letter-box,
    [#h(para-indent)#box(width: letter-box, m.captures.at(0))#unloose(inl(m.captures.at(1)))]))
}

#let body-flow(body) = {
  for chunk in body-chunks(body) {
    let t = chunk.trim()
    if t.starts-with("#") {
      let m = t.match(regex("^(#+)[ \\t]+([\\s\\S]*)$"))
      heading-block(m.captures.at(0).len(), m.captures.at(1))
    } else if t.match(regex("^([A-Za-z]\\.|\\([A-Za-z]\\))[ \\t]")) != none {
      lettered-item(t)
    } else if t.starts-with(">") {
      // An indented, single-spaced block quotation.
      block(width: 100%, above: quote-space, below: quote-space, pad(x: quote-indent, {
        set text(..edges(pitch-single))
        par(first-line-indent: 0pt, unloose(inl(t.replace(regex("(?m)^>[ \t]?"), ""))))
      }))
    } else {
      body-par(inl(t))
    }
  }
}

/// Signature block (single spaced, right half of the page), kept on one page. "Dated" sits on the left of
/// "Respectfully submitted," if the sample gives a date (docx: a tab at the signature indent).
#let signature-block(meta) = block(width: 100%, above: sig-above, below: 0pt, breakable: false, {
  set text(..edges(pitch-single))
  let date = meta.at("date", default: none)
  sline[#box(width: sig-indent, if date != none [Dated: #date])Respectfully submitted,]
  for group in meta.signature {
    let ls = group.names + group.at("lines", default: ())
    for (i, l) in ls.enumerate() {
      sline(above: if i == 0 { sig-gap } else { 0pt }, left: sig-indent, inl(l))
    }
  }
})

/// Certificate of service (FRCP 5(b)(2)(E)). Shown only when the sample gives a `service` map: a centred bold title
/// on the body pitch kept with the text, two body paragraphs, the electronic signature at the signature indent.
#let certificate(meta) = {
  let s = meta.service
  block(width: 100%, above: cert-above, below: 0pt, sticky: true,
    sline(centered: true, text(weight: "bold", [CERTIFICATE OF SERVICE])))
  body-par[I hereby certify that a copy of the foregoing has been served on all counsel of record via the Court’s Electronic Filing System.]
  body-par[This #s.date.]
  block(width: 100%, above: sig-above, below: 0pt, {
    set text(..edges(pitch-single))
    sline(left: sig-indent)[/s/ #s.signer]
  })
}

// ---------------------------------------------------------------------------
// Document
// ---------------------------------------------------------------------------

#let laed-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    // the page number in a single-pitch line box that ends footer-distance above the page edge (Word: the footer
    // distance); none on page 1 (Word: a different first page)
    footer-descent: margin - footer-distance - pitch-single,
    footer: context {
      let n = counter(page).get().first()
      if n > 1 { align(center, text(size: type-size, ..edges(pitch-single), str(n))) }
    },
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  // Every body paragraph opens with the half-inch indent (after a heading too).
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch. Lettered items are laid out here (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)

  {
    set text(..edges(pitch-single))
    court-title()
    caption(meta)
    title-block(meta)
  }
  body-flow(body)
  signature-block(meta)
  if "service" in meta { certificate(meta) }

  // LR 7.7: the memorandum must not exceed 25 pages. A longer memorandum fails the build (it does not warn).
  context {
    let pages = counter(page).final().first()
    if pages > memo-page-limit {
      panic("LR 7.7: the memorandum is " + str(pages) + " pages; the limit is " + str(memo-page-limit) + " pages, excluding exhibits")
    }
  }
}
