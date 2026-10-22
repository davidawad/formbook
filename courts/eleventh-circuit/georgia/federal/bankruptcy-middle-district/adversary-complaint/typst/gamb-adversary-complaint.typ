// U.S. Bankruptcy Court, Middle District of Georgia: adversary complaint (FRBP 7001, 7003, 7008, 7010;
// caption per Official Form 416D as the Clerk's Instructions require, LBR 9004-2).
//
// Rule-driven and content-agnostic. Requirement IDs (GAMB-...) refer to ../README.md, which quotes
// the rule text. No case-specific text, no coordinates measured off the exemplar, no forced line
// breaks. The body is markdown rendered by cmarker; the metadata is the YAML frontmatter of the
// same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or is a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")    // No font rule for pleadings in this court (GAMB-FORM-002); Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                    // Style choice: 12 pt, the size of the filed exemplars (no rule sets a size). See ../README.md.
#let margins = (top: 1in, bottom: 1in, x: 1in)  // GAMB-FORM-001 (paper and margins: style choice, no local rule).
#let para-indent = 0.5in
#let number-box = 0.5in                  // the paragraph number's box after the first-line indent
#let sub-label-width = 0.5in             // Lettered sub-items "(a)": the label's box, half an inch in.
#let sig-column = 3.2in                  // Signature block sits in the right-hand column.
#let caption-left = 3.6in                // Caption: party column; the right column carries case information.
#let caption-inset = 0.2in               // the party text stands off the caption's right rule
#let right-inset = 0.35in                // the case information stands off the rule
#let v-indent = 1.2in                    // "v." in the party column
#let role-indent = 2.2in                 // a party's role ("Plaintiffs,") in the party column
#let title-inset = 0.325in               // the title is set in the middle 90 % of the line
#let quote-inset = 0.75in                // block quotations, both sides

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-body = 24pt                   // Double spacing for the body (GAMB-FORM-003, style choice; see ../README.md).
#let pitch-single = 13.8pt               // a single line: 1.15 x the type size (Word's single line in this face, the exemplar's caption)
#let gap = pitch-body / 2                // between the caption's groups, around headings and quotations

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics, quotes, section signs) as content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("gamb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("gamb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-spaced paragraph with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: left, body)
})

// ---------------------------------------------------------------------------
// Caption (GAMB-CAP-001 to GAMB-CAP-004)
// ---------------------------------------------------------------------------

/// Form 416D caption: parties on the left, case information on the right, closed by a rule on the
/// right and bottom of the party column.
#let caption(meta) = {
  let parties = need(meta, "parties")
  let left = {
    for (i, p) in parties.enumerate() {
      // "v." between the plaintiff side and the defendant side; none between the debtor and the rest.
      if i > 0 and parties.at(i - 1).kind != "debtor" { line-block(above: gap, below: gap, left: v-indent)[v.] }
      if p.kind == "debtor" { line-block(below: gap)[In re:] }
      for n in p.names { line-block(inl(n)) }
      line-block(left: role-indent, inl(p.role))
    }
  }
  let adversary = need(meta, "adversary_number")
  let right = {
    line-block(below: gap)[Bankruptcy Case No. #need(meta, "case_number")]
    line-block(below: gap)[Chapter #need(meta, "chapter")]
    line-block[Adversary Proceeding No. #if adversary == "" { "________" } else { adversary }]
  }
  block(above: pitch-body, below: pitch-body, grid(
    columns: (caption-left, 1fr),
    block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-inset, bottom: gap), left),
    pad(left: right-inset, right),
  ))
}

// ---------------------------------------------------------------------------
// Body blocks (GAMB-CONT-001 to GAMB-CONT-004)
// ---------------------------------------------------------------------------

/// Split the markdown body into blank-line-separated chunks.
#let chunks(md) = md.split("\n\n").map(s => s.trim()).filter(s => s != "")

/// Heading level = number of leading "#"; the text is the rest of the chunk.
#let heading-level(s) = {
  let lv = 0
  let t = s
  while t.starts-with("#") {
    lv += 1
    t = t.slice(1)
  }
  lv
}

/// Heading styles: level 1 centered capitals; level 2 bold; level 3 bold italic. Unnumbered (GAMB-CONT-002).
/// Single-spaced, half a body line above and below, kept with the text after it.
#let heading-block(lv, t) = block(width: 100%, above: gap, below: gap, sticky: true, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if lv == 1 { align(center, strong(upper(inl(t)))) }
  else if lv == 2 { strong(inl(t)) }
  else { strong(emph(inl(t))) }
})

/// A paragraph at the body pitch.
#let body-par(content) = block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: 0pt, content))

/// The body. Paragraphs after the first heading are numbered 1, 2, ... (FRCP 10(b), via FRBP 7010);
/// a paragraph before the first heading is the unnumbered lead-in; a chunk beginning "(a)", "(1)"
/// and so on is a lettered sub-item, not a numbered paragraph.
#let body(md) = {
  let k = 0
  let seen-heading = false
  for s in chunks(md) {
    if s.starts-with("#") {
      seen-heading = true
      let lv = heading-level(s)
      heading-block(lv, s.slice(lv).trim())
    } else if s.starts-with(">") {
      line-block(above: gap, below: gap, pad(x: quote-inset, inl(s.replace(regex("(?m)^>[ \t]?"), ""))))
    } else if s.match(regex("^\\([a-zA-Z0-9]+\\)")) != none {
      // the label in a box half an inch in, the text from one inch, every line
      let label = s.match(regex("^\\([a-zA-Z0-9]+\\)")).text
      block(width: 100%, above: 0pt, below: 0pt, par(hanging-indent: para-indent + sub-label-width,
        first-line-indent: 0pt, [#h(para-indent)#box(width: sub-label-width, inl(label))#inl(s.slice(label.len()).trim())]))
    } else if not seen-heading {
      body-par[#h(para-indent)#inl(s)]
    } else {
      k += 1
      body-par[#h(para-indent)#box(width: number-box)[#k.]#inl(s)]
    }
  }
}

// ---------------------------------------------------------------------------
// Prayer and signature (GAMB-SIG-001 to GAMB-SIG-003)
// ---------------------------------------------------------------------------

/// One signature block per attorney (LBR 9011-1(b): name, bar number, address, telephone and email
/// in immediate proximity to the signature). The "/s/" line is the electronic signature.
#let signature-block(meta) = {
  let sigs = need(meta, "signature")
  let at = 6.5in - sig-column
  block(breakable: false, above: pitch-body, below: 0pt, {
    line-block(need(meta, "date"))
    line-block(above: pitch-body, left: at)[Respectfully submitted,]
    for (j, s) in sigs.enumerate() {
      line-block(above: pitch-body, left: at)[/s/ #s.signer]
      for l in (s.signer, s.bar, ..s.firm, s.phone, s.email) { line-block(left: at, inl(l)) }
      line-block(left: at, emph(inl(s.role)))
    }
  })
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let gamb-adversary-complaint(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "title", "case_number", "chapter", "adversary_number", "parties", "wherefore", "date", "signature") {
    let _ = need(meta, k)
  }

  // ---- document-wide settings ----
  // A centered page number on every page, in a single-spaced line box (Word's footer).
  set page(paper: "us-letter", margin: margins, numbering: "1", footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set document(title: need(meta, "title"), author: need(meta, "signature").at(0).signer)
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number ("§§ 1334"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)

  // ---- court title, caption, complaint title ----
  for l in need(meta, "court") { line-block(align(center, strong(inl(l)))) }
  caption(meta)
  line-block(below: gap, pad(x: title-inset, align(center, strong(upper(inl(need(meta, "title")))))))

  // ---- body, prayer, signature ----
  body(md)
  block(width: 100%, sticky: true, above: 0pt, below: 0pt, par(first-line-indent: 0pt)[#h(para-indent)#inl(need(meta, "wherefore"))])
  signature-block(meta)
}
