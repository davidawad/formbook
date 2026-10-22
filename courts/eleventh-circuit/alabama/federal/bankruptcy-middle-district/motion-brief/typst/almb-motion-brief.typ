// U.S. Bankruptcy Court, M.D. Alabama: motion with its grounds in numbered paragraphs (contested matter).
//
// Rule-driven and content-agnostic. Requirement IDs (ALMB-MOT-...) refer to ../README.md, which quotes the
// rule text (FRBP 9013(b), 9004, 9011; LBR 9011-1). No case-specific text, no coordinates measured off an
// exemplar, no forced line breaks. The markdown body is rendered by cmarker; the metadata comes from the YAML
// frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")    // No M.D. Ala. typography rule exists; Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                    // Style choice, matched to the adversary complaint in this court.
#let page-margin = 1in                   // Style choice (FRBP 9004(a) requires legibility only).
#let para-indent = 0.5in
#let bullet-box = 0.25in                 // A bulleted item: the bullet in a box half an inch in, the text hanging after it.
#let footer-size = 11pt
#let caption-col = 3.3in                 // Width of the boxed debtor column of the caption.
#let caption-inset = 0.12in              // The debtor text stands off the box's rules.
#let right-inset = 0.2in                 // The case-number column stands off the box.
#let sig-col = 3.2in                     // The signature blocks: a column at the right margin.
#let rule = 0.75pt

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt                 // Double spacing (convention; no local rule).
#let pitch-single = 13.8pt               // A single line: 1.15 x the type size (Word's single line in this face).
#let pitch-footer = 1.15 * footer-size
#let gap = pitch-single                  // The space between the groups of the caption, signature and service list.

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("almb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("almb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-spaced paragraph of its own, with explicit space above it.
#let line-block(above: 0pt, indent: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: indent, body)
})

/// A double-spaced paragraph with the first-line indent.
#let body-block(c) = block(width: 100%, above: 0pt, below: 0pt, par(c))

/// Single lines in the signature column at the right margin.
#let right-column(above: 0pt, c) = block(width: 100%, above: above, below: 0pt, grid(columns: (1fr, sig-col), [], c))

// ---------------------------------------------------------------------------
// Caption (FRBP 9004(b): court, title, case number, designation; FRBP 9013 motions in a main case: no
// adversary-proceeding number)
// ---------------------------------------------------------------------------

#let court-title(meta) = for l in need(meta, "court") { line-block(align(center, strong(inl(l)))) }

/// The boxed left column ("IN RE:" and the debtor), the case number and the chapter beside it.
#let caption-table(meta) = {
  let debtor = need(meta, "debtor")
  let left = {
    line-block[IN RE:]
    for (i, n) in debtor.name.enumerate() { line-block(above: if i == 0 { gap } else { 0pt }, indent: para-indent, inl(n)) }
  }
  let right = {
    line-block[CASE NO. #debtor.case_number]
    line-block(above: gap, inl(debtor.chapter))
  }
  block(above: pitch-double, below: 0pt, table(
    columns: (caption-col, 1fr),
    inset: 0pt,
    stroke: (x, y) => if x == 0 { rule } else { none },
    pad(x: caption-inset, y: pitch-single / 2, left),
    align(horizon, pad(left: right-inset, right)),
  ))
}

// ---------------------------------------------------------------------------
// Signature block (LBR 9011-1(a): full name, a mailing address, a telephone number and an email address for
// each signer; LBR 9011-1(b): /s/ is an acceptable signature)
// ---------------------------------------------------------------------------

/// The date (when given) at the margin, then the signature column at the right margin; one block that never
/// breaks across a page.
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, width: 100%, above: pitch-single, below: 0pt, {
    if "date" in meta { line-block[Dated: #inl(meta.date)] }
    right-column({
      // Closing line and firm are optional: LBR 5005-4(f) requires only the signer's name, a mailing address
      // and a telephone number or email address. An empty `closing` omits the line.
      let closing = sig.at("closing", default: "Respectfully submitted,")
      let above = 0pt
      if closing != "" { line-block(inl(closing)); above = gap }
      if sig.at("firm", default: "") != "" { line-block(above: above, inl(sig.firm)); above = gap }
      line-block(above: above)[/s/ #inl(sig.signer)]
      for l in sig.at("lines", default: ()) { line-block(inl(l)) }
    })
  })
}

// ---------------------------------------------------------------------------
// The body, block by block
// ---------------------------------------------------------------------------

/// One markdown block of the body: "#" a heading (centered, bold), "##" a subheading (bold, at the margin), "N. "
/// a numbered paragraph (the number is the one written in the markdown, so the filer's own numbering stays), ">"
/// a quotation, "- " a bulleted list; anything else a paragraph.
#let body-block-of(t) = {
  if t.starts-with("##") {
    block(sticky: true, width: 100%, above: 0pt, below: 0pt, par(first-line-indent: 0pt, strong(inl(t.trim("#").trim()))))
  } else if t.starts-with("#") {
    block(sticky: true, width: 100%, above: 0pt, below: 0pt, align(center, strong(inl(t.trim("#").trim()))))
  } else if t.starts-with(">") or t.starts-with("- ") or t.starts-with("* ") {
    cmarker.render(t, raw-typst: false, smart-punctuation: true)
  } else {
    let m = t.match(regex("^(\\d+)\\.\\s+([\\s\\S]*)$"))
    body-block(if m != none [#m.captures.at(0). #inl(m.captures.at(1))] else { inl(t) })
  }
}

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

#let almb-motion-brief(meta, md) = {
  for k in ("court", "debtor", "title", "signature") {
    let _ = need(meta, k)
  }

  set page(paper: "us-letter", margin: page-margin, numbering: "-1-", footer-descent: 30%, footer: context {
    set text(size: footer-size, ..edges(pitch-footer))
    align(center, numbering("-1-", ..counter(page).get()))
  })
  set document(title: need(meta, "title"), author: need(meta, "signature").signer)
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (double-spaced); a bulleted item as a bullet box with the text hanging.
  show: xengine.with(pitch: pitch-double, list-indent: bullet-box)
  // A doubled section sign stays with its number ("§§ 1408"), as the docx engine binds it.
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // A bulleted list stands half an inch in, at the body pitch.
  show list: it => pad(left: para-indent, it)
  // Quotations single-spaced (convention), indented half an inch both sides, half a double line off the text.
  show quote.where(block: true): it => block(width: 100%, above: pitch-double / 2, below: pitch-double / 2, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    pad(x: para-indent, it.body)
  })

  court-title(meta)
  caption-table(meta)
  // Notice legend (LBR 1017-2(b), 9007-1(c), 4001-1, M.D. Ala. Local Rules eff. 2024-04-01): the rule's text "in all
  // capital letters, bolded, and centered on the page under the style of the case". The author supplies the text of
  // the rule the motion is filed under; the template sets it.
  if "notice" in meta {
    block(above: pitch-double, below: 0pt, line-block(align(center, strong(upper(inl(meta.notice))))))
  }
  block(above: pitch-double, below: pitch-single, line-block(align(center, strong(upper(inl(need(meta, "title")))))))

  let blocks = md.trim().split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(b => b.trim() != "")
  for b in blocks.slice(0, -1) { body-block-of(b.trim()) }
  // The last block (the prayer) is kept whole with the signature block, so the signature never stands alone.
  block(sticky: true, breakable: false, width: 100%, above: 0pt, below: 0pt, body-block-of(blocks.last().trim()))
  signature-block(meta)

  // Certificate of service: text from frontmatter, filed with the motion (service under FRBP 9014(b); see README).
  if "certificate" in meta {
    pagebreak(weak: true)
    block(sticky: true, width: 100%, above: 0pt, below: 0pt, align(center, strong[CERTIFICATE OF SERVICE]))
    body-block(inl(meta.certificate))
    // Signature under the certificate (LBR 5005-4(e): the filer's name on a signature block).
    if "certificate_signature" in meta {
      block(breakable: false, width: 100%, above: pitch-single, below: 0pt,
        right-column(for l in meta.certificate_signature { line-block(inl(l)) }))
    }
    // Service list (LBR 9013-3: the names and addresses of all parties served, and the method used for each,
    // with the addresses for each method clearly designated). `service` is a list of { method, parties }, each
    // party a list of lines; a party's lines never break across a page.
    if "service" in meta {
      for group in meta.service {
        block(sticky: true, width: 100%, above: pitch-double, below: 0pt, line-block(underline(inl(group.method))))
        for p in group.parties {
          block(breakable: false, width: 100%, above: gap, below: 0pt, for l in p { line-block(inl(l)) })
        }
      }
    }
  }
}
