// U.S. Bankruptcy Court, S.D. Alabama: adversary complaint.
//
// Rule-driven and content-agnostic. Requirement IDs (ALSB-...) refer to ../README.md, which records the
// rule text and the date verified. Governing rules: Fed. R. Bankr. P. 7001 (adversary proceeding), 7008(a)
// (statement of consent to final orders), 7010 (Fed. R. Civ. P. 10 applies; caption must substantially conform
// to Official Form 416), 9004(a)-(b) (legibility, caption). S.D. Ala. LBR 7026-1 (Rule 26(a)(1) statement in
// every complaint). The S.D. Ala. Local Bankruptcy Rules (effective December 1, 2009) set no font or layout
// format for complaints. Font, size, margins and spacing are convention choices (see ../README.md). No case-specific text, no
// coordinates measured off an exemplar, no forced line breaks. The markdown body is rendered by cmarker;
// the metadata comes from the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")    // no S.D. Ala. type rule; Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                    // Convention: 12 pt, the size of the filed exemplars (no rule sets a size).
#let page-margin = 1in                   // Convention: 1 inch on all sides.
#let para-indent = 0.5in                 // First-line indent of body paragraphs; the bullet's box in a list.
#let cap-left = 3.4in                    // Caption: the party column, ruled on its right.
#let cap-inset = 0.2in                   // The party text stands off the rule.
#let cap-right-inset = 0.3in             // The case-number column stands off the rule.
#let designation-indent = 0.3in          // A party's designation ("Plaintiff,") stands in from its names.
#let sig-right = 3.0in                   // Signature grid: "Dated" at the left, counsel in a 3 in column at the right.

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt               // a single line: 1.15 x the type size (Word's single line in this face)
#let pitch-double = 2 * pitch-single     // body text double-spaced (27.6 pt, Word's double)
#let cap-pad = pitch-single / 2          // the caption rule runs half a line past the text

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("alsb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("alsb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, indent: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: indent, body)
})

// ---------------------------------------------------------------------------
// Caption (Fed. R. Bankr. P. 7010, Fed. R. Civ. P. 10(a), Official Form 416A; Fed. R. Bankr. P. 9004(b))
// ---------------------------------------------------------------------------

/// One party group: the names, one per line, then the designation ("Plaintiff," and so on).
#let party(p, above) = {
  for (i, n) in p.names.enumerate() { line-block(above: if i == 0 { above } else { 0pt }, inl(n)) }
  line-block(indent: designation-indent, inl(p.designation))
}

#let caption(meta) = {
  let cap = need(meta, "caption")
  for l in need(meta, "court") { line-block(align(center, strong(upper(inl(l))))) }
  block(above: pitch-double, below: 0pt, grid(
    columns: (cap-left, 1fr),
    block(width: 100%, stroke: (right: 0.6pt), inset: (right: cap-inset, bottom: cap-pad), {
      party(cap.debtor, 0pt)
      party(cap.plaintiff, pitch-single)
      line-block(above: pitch-single, "v.")
      party(cap.defendant, pitch-single)
    }),
    pad(left: cap-right-inset, {
      line-block("Case No. " + need(meta, "case_number"))
      line-block(above: pitch-single, "Chapter " + need(meta, "chapter"))
      line-block(above: pitch-single, "Adv. Pro. No. " + need(meta, "adversary_number"))
    }),
  ))
  block(sticky: true, above: pitch-double, below: pitch-single,
    line-block(align(center, strong(upper(inl(need(meta, "title")))))))
}

// ---------------------------------------------------------------------------
// Signature block (Fed. R. Bankr. P. 9011 signature; counsel block): it never breaks across a page
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, width: 100%, above: pitch-double, below: 0pt, grid(
    columns: (1fr, sig-right),
    line-block[Dated: #inl(meta.at("date", default: "__________, 20__"))],
    {
      line-block[Respectfully submitted,]
      line-block(above: pitch-single)[/s/ #inl(sig.signer)]
      for l in sig.lines { line-block(inl(l)) }
    },
  ))
}

// ---------------------------------------------------------------------------
// Template entry point
// ---------------------------------------------------------------------------

/// Numbered paragraphs run continuously through the complaint (Fed. R. Civ. P. 10(b)).
#let para-no = counter("alsb-complaint-para")

/// An item's body without the paragraph breaks of a loose list (the paragraph has no space of its own).
#let unloose(body) = {
  if body.func() != [].func() { return body }
  body.children.filter(c => c.func() != parbreak).join()
}

#let alsb-adversary-complaint(meta, body) = {
  set document(title: need(meta, "title"), author: need(meta, "signature").signer)
  // Page numbers centered, arabic, in a single-spaced line box, so they sit at the same place on every page (Word's
  // footer).
  set page(
    paper: "us-letter",
    margin: page-margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (double-spaced); bullets in a box of the paragraph indent, the text hanging after it.
  show: xengine.with(pitch: pitch-double, list-indent: para-indent)

  // Level 1 = centered caps section heading; level 2 = bold heading at the margin. Both in a line of the body
  // pitch, with no space of their own; sticky: a heading never ends a page. Not numbered by the template.
  show heading: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    let b = if it.level == 1 { align(center, strong(upper(it.body))) } else { strong(it.body) }
    block(sticky: true, width: 100%, above: 0pt, below: 0pt, b)
  }

  // Numbered paragraphs: each markdown list item becomes one paragraph numbered from the running counter, the
  // number after the first-line indent.
  show enum: it => for item in it.children {
    para-no.step()
    block(width: 100%, above: 0pt, below: 0pt, par(context [#para-no.display("1.") #unloose(item.body)]))
  }

  caption(meta)
  cmarker.render(body, raw-typst: false, smart-punctuation: true)
  // LBR 7026-1: the complaint must state whether the pleader stipulates that Fed. R. Civ. P. 26(a)(1) will not apply.
  par(inl(need(meta, "stipulation-26-1")))
  signature-block(meta)
  // Optional certificate of service (markdown), after the signature block as filed.
  if "certificate-of-service" in meta {
    block(above: pitch-double, below: 0pt,
      cmarker.render(meta.at("certificate-of-service"), raw-typst: false, smart-punctuation: true))
  }
}
