// U.S. District Court, Eastern District of New York: complaint.
//
// Rule-driven and content-agnostic. Requirement IDs (NYED-...) refer to ../README.md, which quotes
// the rule text: Fed. R. Civ. P. 5.2(a), 8(a), 10(a)-(b); Local Civil Rule 7.1(b) (typeface,
// margins, spacing; it applies to all documents presented for filing). No case-specific text, no
// coordinates measured off the exemplar, no forced line breaks. The markdown body is rendered by
// cmarker; the metadata comes from the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")         // No EDNY rule names a face (NYED-FORM-002); Times New Roman, the house standard. Vendored in /fonts.
#let type-size = 12pt                    // NYED-FORM-002: LCR 7.1(b)(1), 12-point type or larger.
#let margins = (top: 1in, bottom: 1in, x: 1in)  // NYED-FORM-004: LCR 7.1(b)(2), at least one inch on all sides.
#let para-indent = 0.5in                 // First-line indent of numbered paragraphs.
#let number-tab = 0.5in                  // The paragraph number in a box of this width; the text after it.
#let prayer-tab = 0.5in                  // Lettered prayer items: the label box, the text hanging after it.
#let caption-left = 3.4in                // The party column of the caption.
#let caption-pad = 9pt                   // The party column's text this far inside its rules (top and bottom).
#let caption-gap = 0.2in                 // The case column this far right of the party column.
#let against-indent = 1.2in              // "-against-" between the parties.
#let designation-indent = 1.9in          // "Plaintiff," / "Defendants." under the names.
#let signature-w = 3.2in                 // The signature column at the right.
#let rule = 0.75pt                       // The caption's rules.

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt                 // NYED-FORM-003: LCR 7.1(b)(3), double-spaced body text.
#let pitch-single = 13.8pt               // Single spacing, 1.15 x the size: counsel, court, caption, headings (LCR
                                         // 7.1(b)(3) excepts headings), signature.

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Inline markdown (italics, bold, links) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("nyed-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nyed-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it. An empty line
/// keeps its height.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below,
  height: if body == "" or body == [] { pitch-single } else { auto }, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if type(body) == str { inl(body) } else { body }
})

// ---------------------------------------------------------------------------
// Counsel block, court name, caption (Fed. R. Civ. P. 10(a): court name, title, file number)
// ---------------------------------------------------------------------------

#let counsel-block(meta) = for l in meta.at("counsel", default: ()) { line-block(l) }

/// The court's name, bold capitals, a double line below the counsel block.
#let court-name(meta) = for (i, l) in need(meta, "court").enumerate() {
  line-block(above: if i == 0 and "counsel" in meta { pitch-double } else { 0pt }, align(center, strong(upper(inl(l)))))
}

/// The caption, a double line below the court's name: the party column between a rule above and below, the case
/// column (docket number, jury demand) at its right, its first line level with the party column's (Word sets a
/// row's cells the same top margin). Never split.
#let caption-table(meta) = {
  let sides = need(meta, "caption")
  let left = {
    for (i, side) in sides.enumerate() {
      if i > 0 {
        line-block("")
        line-block(pad(left: against-indent, [-against-]))
        line-block("")
      }
      for n in side.names { line-block(n) }
      line-block(pad(left: designation-indent, inl(side.designation)))
    }
  }
  let right = {
    line-block[Docket No. #need(meta, "case_number")]
    if meta.at("jury_demand", default: false) {
      line-block(above: pitch-single, strong[JURY TRIAL DEMANDED])
    }
  }
  block(width: 100%, above: pitch-double, below: 0pt, breakable: false, grid(
    columns: (caption-left, 1fr),
    block(width: 100%, inset: (top: caption-pad, bottom: caption-pad), stroke: (top: rule, bottom: rule), left),
    pad(left: caption-gap, top: caption-pad, right),
  ))
}

/// The paper's title, bold capitals, a double line below the caption.
#let title-block(meta) = line-block(above: pitch-double, align(center, strong(upper(inl(need(meta, "title"))))))

// ---------------------------------------------------------------------------
// Headings and body
// ---------------------------------------------------------------------------

/// A heading block, single-spaced (LCR 7.1(b)(3)), a single line above and below it, sticky. `#` is a centered bold
/// capital heading, `##` a centered bold heading, `###` a left-aligned bold heading.
#let heading-block(level, text) = block(width: 100%, above: pitch-single, below: pitch-single, sticky: true, {
  set std.text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if level == 1 { align(center, strong(upper(inl(text)))) }
  else if level == 2 { align(center, strong(inl(text))) }
  else { strong(inl(text)) }
})

/// A body paragraph at the double pitch: the first-line indent, then (when numbered, Fed. R. Civ. P. 10(b)) the
/// number in a box of number-tab and the text after it. `keep`: kept whole on the page of the block after it (the
/// last block stays with the signature).
#let body-par(num, content, keep: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: keep,
  breakable: not keep,
  par(first-line-indent: (amount: para-indent, all: true),
    if num == none { content } else { [#box(width: number-tab, [#num.])#content] }))

/// Numbered allegations (Fed. R. Civ. P. 10(b)). Each blank-line-separated chunk of markdown that is neither a
/// heading nor a list is one numbered paragraph; a chunk that starts with "WHEREFORE" (the prayer's lead-in) is
/// unnumbered. Prayer items ("- ") are lettered A., B., ... half an inch in, the text hanging after the label.
#let allegations(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let n = 0
  for (k, t) in chunks.enumerate() {
    let last = k == chunks.len() - 1
    if t.starts-with("#") {
      let m = t.match(regex("^(#+)\\s+(.*)$"))
      if m == none { panic("nyed-complaint: malformed heading: " + t) }
      heading-block(m.captures.at(0).len(), m.captures.at(1))
    } else if t.starts-with("- ") {
      let items = t.split(regex("\\r?\\n")).filter(l => l.trim() != "")
      for (i, it) in items.enumerate() {
        let keep = last and i == items.len() - 1
        block(width: 100%, above: 0pt, below: 0pt, sticky: keep, breakable: not keep, pad(left: para-indent,
          par(first-line-indent: 0pt, hanging-indent: prayer-tab,
            [#box(width: prayer-tab, numbering("A.", i + 1))#inl(it.trim().slice(2))])))
      }
    } else if t.starts-with("WHEREFORE") {
      body-par(none, inl(t), keep: last)
    } else {
      n += 1
      body-par(n, inl(t), keep: last)
    }
  }
}

// ---------------------------------------------------------------------------
// Signature (Fed. R. Civ. P. 11(a): signed by at least one attorney of record)
// ---------------------------------------------------------------------------

/// A double line below the body: "Dated:" at the left, the signature column at the right; single-spaced, never
/// broken across a page.
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, breakable: false, above: pitch-double, below: 0pt, grid(
    columns: (1fr, signature-w),
    line-block[Dated: #inl(need(meta, "date"))],
    {
      line-block[Respectfully submitted,]
      line-block(above: pitch-double)[By: /s/ #inl(sig.signer)]
      line-block(sig.signer)
      for l in sig.at("lines", default: ()) { line-block(l) }
    },
  ))
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let nyed-complaint(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "court", "caption", "title", "date", "signature") {
    let _ = need(meta, k)
  }

  // ---- document-wide settings ----
  // The page number centered at the foot, in a single line box, where Word's footer sets it.
  set page(paper: "us-letter", margin: margins, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set document(
    title: need(meta, "title") + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (LCR 7.1(b)(3): double spaced).
  show: xengine.with(pitch: pitch-double, list-indent: prayer-tab)
  // A doubled section sign stays with its number (xengine binds a single sign), as the docx filter binds it.
  show regex("[§¶]{2,} \\S+"): it => box(it)

  counsel-block(meta)
  court-name(meta)
  caption-table(meta)
  title-block(meta)
  // Unnumbered lead-in paragraph (the "Plaintiff ... states as follows:" opening), if given, a single line below the
  // title.
  if "lead_in" in meta {
    block(above: pitch-single, below: 0pt, body-par(none, inl(meta.lead_in)))
  }
  allegations(md)
  signature-block(meta)
}
