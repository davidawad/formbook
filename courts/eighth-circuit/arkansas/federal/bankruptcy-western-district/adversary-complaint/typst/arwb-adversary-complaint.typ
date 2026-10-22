// Adversary complaint for the U.S. Bankruptcy Court, Western District of Arkansas.
// Rules: Fed. R. Bankr. P. 7010 (caption substantially conforms to Official Form 416, the adversary
// caption), 9004(a) (legible), 9004(b) (caption: court, title, case number and adversary number, designation);
// Fed. R. Civ. P. 10(b) as applied by Rule 7010 (numbered paragraphs). See ../README.md for the rule IDs,
// sources and the known gaps (the W.D. Ark. local rules text was not retrievable).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a named layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // vendored in fonts/ (no rule names a face)
#let type-size = 13pt                   // ADV-FORM-001 (legible); the template's size, no rule sets one
#let para-indent = 0.5in                // first-line indent of numbered paragraphs and of the opening paragraph
#let number-box = 0.5in                 // a paragraph number in a box from the indent: the text starts 1 in in (a tab stop)
#let caption-left = 3.7in               // width of the debtor and party column of the caption
#let caption-gutter = 0.2in             // the case numbers stand off the party column
#let designation-indent = 0.9in         // the designations ("Debtor.", "Plaintiff,") and "v." in the caption
#let signature-left = 3.25in            // the signature column, from the left margin
#let margin-all = 1in

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/arwb-adversary-complaint.lua sets the same twips).
#let pitch-body = 24pt                  // double spacing at 13 pt (README.md, Layout)
#let pitch-single = 15.6pt              // single spacing (1.2 em): court title, caption, signature
#let line-gap = 15.6pt                  // one blank single line: court title to caption, between the caption's groups
#let half-gap = 7.8pt                   // half a single line: caption to title, above the signature, between its parts

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// A required frontmatter key; a missing key is a loud failure, never a silent omission.
#let need(meta, key) = {
  if key not in meta { panic("arwb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("arwb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics such as *et al.*, smart quotes) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line (a paragraph of its own), with an explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  body
})

/// A double-spaced paragraph with the half-inch first-line indent.
#let body-par(body) = block(width: 100%, above: 0pt, below: 0pt, [#h(para-indent)#body])

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Page number centred in the footer, in the form used by the filed exemplar ("- 1 -"), in a single-spaced line.
#let page-footer() = context align(center, text(size: type-size, ..edges(pitch-single), counter(page).display("- 1 -")))

// ---------------------------------------------------------------------------
// Cover: court title, caption (Official Form 416 layout), title of the paper
// ---------------------------------------------------------------------------

/// The court's name, one centred line per item, as the caption requires (Rule 9004(b)(1)).
#let court-title(meta) = for l in need(meta, "court") { line-block(align(center, upper(inl(l)))) }

/// The caption: the debtor ("In re") and the parties on the left, the case, chapter and adversary numbers on
/// the right (Official Form 416; Rule 7010). The groups are a blank line apart; the right column's lines fall on the
/// left column's lines (the adversary number on the plaintiff's first line, two blank lines below the chapter).
#let caption(meta) = {
  let c = need(meta, "caption")
  let debtor = c.debtor
  let left = {
    line-block[In re:]
    for n in debtor.names { line-block(inl(n)) }
    line-block(pad(left: designation-indent, inl(debtor.designation)))
    for (k, p) in c.parties.enumerate() {
      for (j, n) in p.names.enumerate() { line-block(above: if j == 0 { line-gap } else { 0pt }, inl(n)) }
      line-block(pad(left: designation-indent, inl(p.designation)))
      if k < c.parties.len() - 1 {
        line-block(above: line-gap, below: line-gap, pad(left: designation-indent, [v.]))
      }
    }
  }
  let right = {
    line-block[Case No. #need(meta, "case_number")]
    line-block[Chapter #need(meta, "chapter")]
    line-block(above: 2 * line-gap)[Adv. Pro. No. #need(meta, "adversary_number")]
  }
  block(above: line-gap, below: 0pt, grid(
    columns: (caption-left, 1fr),
    column-gutter: caption-gutter,
    left,
    right,
  ))
}

#let cover(meta) = {
  court-title(meta)
  caption(meta)
  block(width: 100%, above: half-gap, below: 0pt, align(center, text(weight: "bold", upper(need(meta, "document_title")))))
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs, centred headings, the prayer, the signature
// ---------------------------------------------------------------------------

/// "Respectfully Submitted," and one single-spaced block per signer, half a line apart; never split.
#let signature-block(meta) = block(breakable: false, above: half-gap, below: 0pt, pad(left: signature-left, {
  line-block(below: half-gap)[Respectfully Submitted,]
  for (i, b) in need(meta, "signature").enumerate() {
    block(above: if i > 0 { half-gap } else { 0pt }, below: 0pt, for l in b { line-block(inl(l)) })
  }
}))

/// Numbered paragraphs (Fed. R. Civ. P. 10(b), as applied by Rule 7010). Each blank-line-separated chunk of
/// markdown that is neither a heading nor a list is one numbered paragraph. A chunk that begins with
/// `WHEREFORE` is the prayer and is not numbered. Headings and the prayer are kept with what follows them.
/// Numbering is a plain variable, not a counter, so each paragraph's number is fixed when the body is built.
#let allegations(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let n = 0
  let out = []
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      // A section heading: centred bold capitals on a body line; it stays on the page with the paragraph after it.
      let title = t.replace(regex("^#+\\s*"), "")
      out += block(width: 100%, above: 0pt, below: 0pt, sticky: true,
        align(center, text(weight: "bold", upper(title))))
    } else if t.starts-with("WHEREFORE") {
      // The prayer stays on the page with the signature block that follows it (sticky), as in the exemplar.
      out += block(width: 100%, above: 0pt, below: 0pt, sticky: true, [#h(para-indent)#inl(t)])
    } else {
      n += 1
      out += body-par[#box(width: number-box)[#n.]#inl(t)]
    }
  }
  out
}

#let arwb-adversary-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin-all,
    footer-descent: 30%,
    footer: page-footer(),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number. No lists in this document type (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)

  cover(meta)

  if "lead_in" in meta { body-par(inl(meta.lead_in)) }

  allegations(body)

  signature-block(meta)
}
