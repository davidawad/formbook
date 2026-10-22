// U.S. District Court for the District of Maryland (mdd): complaint.
//
// Rule-driven and content-agnostic. Requirement IDs (LR-..., FRCP-...) refer to ../README.md, which quotes
// the rule text (D. Md. Local Rules, effective Dec. 1, 2025; Fed. R. Civ. P.). No case-specific text, no
// coordinates measured off the exemplar, no forced line breaks. The markdown body is rendered by cmarker;
// the metadata comes from the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // LR-102.2.b: Times New Roman or larger typeface. Metric-compatible substitute, vendored in /fonts (docs/FONTS.md).
#let type-size = 12pt                   // LR-102.2.b: at least 12 pt text (Times New Roman 12 pt).
#let margin = 1in                       // LR-102.2.b: one-inch margin on all sides
#let para-indent = 0.5in                // first-line indent of paragraphs; the paragraph number's box after it
#let item-indent = 0.5in                // lettered prayer items: the label at this indent
#let item-label = 0.625in               // the label's box; the item's text hangs after it
#let caption-left = 3.6in               // width of the party column of the caption
#let caption-pad = 0.2in                // the party text stops this far left of the caption's rule
#let designation-indent = 1.8in         // a party's designation stands this far in
#let sig-left = 3.4in                   // the signature grid: "Dated" column, then the signature column
#let max-pages = 40                     // LR-103.1.d: a pleading shall not exceed forty pages

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // a single line: 1.15 x the type size (court lines, caption, signature)
#let pitch-double = 2 * pitch-single    // LR-102.2.b: double-spaced (Times New Roman 12 pt, double in Word)
#let gap-half = pitch-single            // half a double line: around "v.", before a designation, after the title
#let heading-above = 19.75pt            // space above a level-1 to level-3 heading
#let case-top = 3.6pt                   // the case number stands this far below the caption's top

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics, the section sign, etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

#let need(meta, key) = {
  if key not in meta { panic("mdd-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mdd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: below,
  pad(left: left, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    body
  }))

// ---------------------------------------------------------------------------
// Caption and title. LR-102.2.a: the original complaint carries the names and addresses of all parties and
// the county of residence of any Maryland party. FRCP 10(a): court name, title, file number, designation.
// ---------------------------------------------------------------------------

/// One party in the caption: names, then address and county (if any), then the designation, indented.
#let party-block(p) = {
  for l in p.names + need(p, "address") { line-block(inl(l)) }
  if "county" in p { line-block(inl(p.county)) }
  line-block(above: gap-half, left: designation-indent, inl(need(p, "designation")))
}

#let caption(meta) = {
  let parties = need(meta.caption, "parties")
  for p in parties {
    if "Maryland" in need(p, "address").join(" ") and "county" not in p {
      panic("mdd-complaint: LR-102.2.a: a Maryland party needs its county of residence (`county`)")
    }
  }
  block(width: 100%, above: pitch-double, below: 0pt, grid(
    columns: (caption-left, 1fr),
    stroke: (x, y) => if x == 0 { (right: 0.75pt, bottom: 0.75pt) } else { none },
    pad(right: caption-pad, bottom: gap-half, {
      for (k, p) in parties.enumerate() {
        if k > 0 { line-block(above: gap-half, below: gap-half, align(center, [v.])) }
        party-block(p)
      }
    }),
    pad(left: caption-pad, top: case-top, {
      let num = meta.at("case_number", default: "")
      // An empty case number leaves a blank for the clerk.
      line-block[Case No. #if num == "" { "_" * 14 } else { num }]
    }),
  ))
}

// ---------------------------------------------------------------------------
// Signature block. LR-102.1.b.i: at the bottom of every court document, counsel states name, address,
// telephone, email and fax number, and bar number. LR-102.1.a: counsel signs.
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  for k in ("name", "bar", "firm", "address", "phone", "fax", "email", "role") {
    if k not in sig { panic("mdd-complaint: LR-102.1.b.i: the signature block needs `" + k + "`") }
  }
  block(width: 100%, breakable: false, above: pitch-double, below: 0pt, grid(
    columns: (sig-left, 1fr),
    if "date" in meta { line-block[Dated: #meta.date] } else { [] },
    for l in (
      "Respectfully submitted,",
      "/s/ " + sig.name,
      sig.name,
      sig.bar,
      ..sig.firm,
      ..sig.address,
      "Telephone: " + sig.phone,
      "Facsimile: " + sig.fax,
      sig.email,
      sig.role,
    ) { line-block(inl(l)) },
  ))
}

// ---------------------------------------------------------------------------
// Body: numbered allegations (FRCP 10(b)). Each blank-line-separated chunk that is neither a heading nor a
// list is one numbered paragraph; headings and lists are not numbered. Numbering is applied per chunk, not
// with a `show par` rule (a show rule that re-wraps paragraph content recurses without end in typst 0.15).
// ---------------------------------------------------------------------------

/// A body paragraph at the double pitch, first line indented: unnumbered, or numbered (the number in a box of the
/// paragraph indent after the first-line indent, then the text).
#let body-par(num, content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true),
    if num == none { content } else { [#box(width: para-indent, [#num.])#content] }))

/// Prayer items (a markdown list), lettered (a), (b), ...: the label at the item indent in a box, the text
/// hanging after it.
#let lettered(t) = {
  let items = t.split(regex("(?m)^(\\d+\\.|[-*+])[ \\t]+")).filter(s => s.trim() != "")
  for (i, it) in items.enumerate() {
    block(width: 100%, above: 0pt, below: 0pt, pad(left: item-indent,
      par(hanging-indent: item-label, first-line-indent: 0pt,
        [#box(width: item-label, numbering("(a)", i + 1))#inl(it.trim().replace(regex("\\s*\\n\\s*"), " "))])))
  }
}

/// The body's chunks: (kind, content) with the paragraphs numbered.
#let chunks(body) = {
  let n = 0
  let out = ()
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "") {
    let t = c.trim()
    if t.starts-with("#") {
      out.push(md(t))
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      out.push(lettered(t))
    } else if t.starts-with("^ ") {
      // Unnumbered paragraph (the WHEREFORE paragraph and the jury demand): a leading "^ " in the sample.
      out.push(body-par(none, inl(t.slice(2))))
    } else {
      n += 1
      out.push(body-par(n, inl(t)))
    }
  }
  out
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let mdd-complaint(meta, body) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "caption", "brief_title", "signature") {
    let _ = need(meta, k)
  }

  // ---- document-wide settings ----
  // LR-102.2.b: page numbers at the bottom of every page after the first, centered in a single-spaced line box
  // where Word's footer sets it.
  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: 30%,
    footer: context if here().page() > 1 {
      align(center, text(..edges(pitch-single), counter(page).display()))
    },
  )
  set document(title: need(meta, "brief_title"), author: need(meta, "signature").name)
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (double-spaced).
  show: xengine.with(pitch: pitch-double, list-indent: none)
  // A doubled sign stays with its number too ("§§ 101"; xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)

  // Headings at the body pitch, kept with the text after them: level 1 centered bold capitals; level 2 bold,
  // hanging; level 3 bold italic; level 4 centered (cause sub-titles), close under its cause.
  show heading: it => block(sticky: true, width: 100%, above: if it.level < 4 { heading-above } else { 0pt },
    below: 0pt, {
      set text(size: type-size)
      set par(first-line-indent: 0pt)
      if it.level == 1 { align(center, strong(upper(it.body))) } else if it.level == 2 {
        par(hanging-indent: para-indent, strong(it.body))
      } else if it.level == 3 { strong(emph(it.body)) } else { align(center, it.body) }
    })

  // ---- cover: court, caption, title ----
  for c in need(meta, "court") { line-block(align(center, inl(c))) }
  caption(meta)
  block(width: 100%, above: pitch-double, below: gap-half, {
    set par(first-line-indent: 0pt)
    align(center, strong(upper(inl(meta.brief_title))))
  })

  // Unnumbered lead-in (the "for its complaint against ... alleges as follows" paragraph), if the sample has one.
  if "lead_in" in meta { body-par(none, inl(meta.lead_in)) }

  // The body, then the signature block. The last chunk (the jury demand) and the signature block stay on one
  // page, so a signature never stands alone at the top of a page.
  let cs = chunks(body)
  for c in cs.slice(0, -1) { c }
  block(width: 100%, breakable: false, above: 0pt, below: 0pt, { cs.last(); signature-block(meta) })

  // ---- end check: LR-103.1.d, the pleading's total length ----
  context {
    let n = counter(page).get().first()
    if n > max-pages {
      panic("mdd-complaint: LR-103.1.d: a pleading shall not exceed " + str(max-pages) + " pages (this one has " + str(n) + ")")
    }
  }
}
