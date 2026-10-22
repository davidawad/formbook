// Brief in support of a motion (FRBP 9013) for the U.S. Bankruptcy Court, Western District of Arkansas.
// Rules: Fed. R. Bankr. P. 9013 (a motion, and its grounds and relief, in writing), 9004(a) (legible),
// 9004(b) (caption: court, title, case number and designation). The local rule text on brief form was not
// retrievable (see ../README.md, gap 1); the layout follows the filed exemplar. Content-agnostic: every
// case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a named layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // vendored in fonts/ (no rule names a face)
#let type-size = 13pt                   // legible (Rule 9004(a)); the template's size, no rule sets one
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let label-box = 0.5in                  // a heading's or a list item's label in a box: the text after it at the next half inch
#let list-left = 0.5in                  // a list item's label stands at this indent; its text hangs at list-left + label-box
#let margin-all = 1in
#let caption-left = 3.6in               // width of the debtor column of the caption
#let caption-gutter = 0.2in             // the case number stands off the debtor column
#let designation-indent = 0.9in         // the debtor's designation in the caption
#let recipient-indent = 0.5in           // the recipients of the certificate of service
#let signature-left = 3.25in            // the signature column, from the left margin

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/arwb-motion-brief.lua sets the same twips).
#let pitch-body = 24pt                  // double spacing at 13 pt
#let pitch-single = 15.6pt              // single spacing (1.2 em): court title, caption, signature, recipients
#let line-gap = 15.6pt                  // one blank single line: court title to caption, recipients to the signer
#let half-gap = 7.8pt                   // half a single line: caption to title, around the signature and certificate

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// A required frontmatter key; a missing key is a loud failure, never a silent omission.
#let need(meta, key) = {
  if key not in meta { panic("arwb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("arwb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics such as *Id.* and case names, smart quotes) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line (a paragraph of its own), with an explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  body
})

/// A double-spaced paragraph with the half-inch first-line indent.
#let body-par(sticky: false, body) = block(width: 100%, above: 0pt, below: 0pt, sticky: sticky, [#h(para-indent)#body])

// ---------------------------------------------------------------------------
// Page furniture and cover (Rule 9004(b): court, title, case number, designation)
// ---------------------------------------------------------------------------

#let page-footer() = context align(center, text(size: type-size, ..edges(pitch-single), counter(page).display("1")))

#let court-title(meta) = for l in need(meta, "court") {
  line-block(align(center, text(weight: "bold", upper(inl(l)))))
}

/// Debtor on the left, case number and chapter on the right, a blank line below the court title.
#let caption(meta) = {
  let c = need(meta, "caption")
  let debtor = c.debtor
  let left = {
    for n in debtor.names { line-block(inl(n)) }
    line-block(pad(left: designation-indent, inl(debtor.designation)))
  }
  let right = {
    line-block[Case No: #need(meta, "case_number")]
    line-block[Chapter #need(meta, "chapter")]
  }
  block(above: line-gap, below: 0pt, grid(columns: (caption-left, 1fr), column-gutter: caption-gutter, left, right))
}

#let cover(meta) = {
  court-title(meta)
  caption(meta)
  block(width: 100%, above: half-gap, below: 0pt, align(center, text(weight: "bold", upper(need(meta, "brief_title")))))
}

// ---------------------------------------------------------------------------
// Body: headings, paragraphs, lists (factor lists), the signature and the certificate of service
// ---------------------------------------------------------------------------

/// Headings are numbered by level (level 2: I., 3: A., 4: 1., 5: a.), and the numbers are typed by the template,
/// not the author. Level 1 is not used in the sample. With `keep-last`, the last paragraph stays on the page with
/// the signature block after it.
#let body-of(md, keep-last: false) = {
  let chunks = md.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let c2 = 0
  let c3 = 0
  let c4 = 0
  let c5 = 0
  let out = []
  for (ci, c) in chunks.enumerate() {
    let t = c.trim()
    if t.starts-with("#") {
      let lv = t.find(regex("^#+")).len()
      let title = t.slice(lv).trim()
      let label = ""
      if lv == 2 {
        c2 += 1; c3 = 0; c4 = 0; c5 = 0
        label = numbering("I.", c2)
      } else if lv == 3 {
        c3 += 1; c4 = 0; c5 = 0
        label = numbering("A.", c3)
      } else if lv == 4 {
        c4 += 1; c5 = 0
        label = numbering("1.", c4)
      } else if lv == 5 {
        c5 += 1
        label = numbering("a.", c5)
      } else {
        panic("arwb-motion-brief: heading level " + str(lv) + " is not used by the template (use ## to #####)")
      }
      // Bold capitals on a body line, the title after its label at the half inch, hanging there; sticky: the
      // heading stays on the page with the text after it.
      out += block(width: 100%, above: 0pt, below: 0pt, sticky: true,
        par(hanging-indent: label-box, text(weight: "bold", [#box(width: label-box, label)#upper(title)])))
    } else if t.find(regex("^\\d+\\.\\s")) != none {
      // A markdown list of factors or items: each item is labelled (1), (2), ... and hangs from its label.
      let li = 0
      for item in t.split(regex("\\r?\\n")).filter(l => l.trim() != "") {
        li += 1
        let text-of = item.trim().replace(regex("^\\d+\\.\\s+"), "")
        out += block(width: 100%, above: 0pt, below: 0pt, pad(left: list-left,
          par(hanging-indent: label-box, [#box(width: label-box)[(#li)]#inl(text-of)])))
      }
    } else {
      out += body-par(sticky: keep-last and ci == chunks.len() - 1, inl(t))
    }
  }
  out
}

/// "Respectfully submitted," then the signer's lines, single spaced at 3.25 in; never split.
#let signature-block(meta) = block(breakable: false, above: half-gap, below: 0pt, pad(left: signature-left, {
  line-block(below: half-gap)[Respectfully submitted,]
  for l in need(meta, "signature") { line-block(inl(l)) }
}))

/// The certificate of service: a centred heading, the text, the recipients, the signer; never split.
#let certificate(meta) = {
  let cos = need(meta, "certificate_of_service")
  block(breakable: false, above: half-gap, below: 0pt, {
    block(width: 100%, above: 0pt, below: 0pt, align(center, text(weight: "bold", [CERTIFICATE OF SERVICE])))
    body-par(inl(cos.text))
    block(above: half-gap, below: 0pt, pad(left: recipient-indent, for r in cos.recipients { line-block(inl(r)) }))
    block(above: line-gap, below: 0pt, pad(left: signature-left, for l in cos.signer { line-block(inl(l)) }))
  })
}

#let arwb-motion-brief(meta, md) = {
  set page(paper: "us-letter", margin: margin-all, footer-descent: 30%, footer: page-footer())
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number. The lists are written above (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)

  cover(meta)

  if "lead_in" in meta { body-par(inl(meta.lead_in)) }

  body-of(md, keep-last: true)

  signature-block(meta)
  if "certificate_of_service" in meta { certificate(meta) }
}
