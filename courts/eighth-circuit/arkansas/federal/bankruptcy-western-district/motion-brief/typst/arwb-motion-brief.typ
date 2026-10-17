// Brief in support of a motion (FRBP 9013) for the U.S. Bankruptcy Court, Western District of Arkansas.
// Rules: Fed. R. Bankr. P. 9013 (a motion, and its grounds and relief, in writing), 9004(a) (legible),
// 9004(b) (caption: court, title, case number and designation). The local rule text on brief form was not
// retrievable (see ../README.md, gap 1); the layout follows the filed exemplar. Content-agnostic: every
// case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a named layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // vendored in fonts/; no Times New Roman is vendored (README.md, gap 3)
#let type-size = 13pt                   // EB Garamond sets narrower than Times, so 13 pt gives about the exemplar's line length (README.md, gap 3)
#let body-leading = 1.2em               // double spacing: 0.65em line box + 1.2em leading = 24 pt baseline pitch at 13 pt (measured)
#let single-leading = 0.55em            // single spacing for the caption, counsel and signature: 1.2em pitch
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let margin-all = 1in
#let caption-left = 3.6in               // width of the debtor column of the caption

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

/// A double-spaced block that occupies whole pitches. `below` adds the leading that follows the last line,
/// so a block of n lines is n x (line box + leading) tall and the next block starts on the grid of lines.
/// Without it, consecutive blocks sit one line box apart and their lines overlap.
#let grid-block(c) = block(width: 100%, above: 0pt, below: body-leading, c)

/// Single-spaced lines (court title, caption, signature): one item per line, with a single gap between items.
#let single-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items)
}

// ---------------------------------------------------------------------------
// Page furniture and cover (Rule 9004(b): court, title, case number, designation)
// ---------------------------------------------------------------------------

#let page-footer() = context align(center, text(size: type-size, counter(page).display("1")))

#let court-title(meta) = {
  let lines = need(meta, "court").map(l => align(center, text(weight: "bold", upper(inl(l)))))
  single-stack(lines)
}

/// Debtor on the left, case number and chapter on the right.
#let caption(meta) = {
  let c = need(meta, "caption")
  let debtor = c.debtor
  let left = single-stack(
    debtor.names.map(n => inl(n)) + (pad(left: 0.9in, inl(debtor.designation)),),
  )
  let right = single-stack(([Case No: #need(meta, "case_number")], [Chapter #need(meta, "chapter")]))
  grid(columns: (caption-left, 1fr), column-gutter: 0.2in, left, right)
}

#let cover(meta) = {
  court-title(meta)
  block(height: body-leading * 1.5)
  caption(meta)
  block(height: body-leading * 1.5)
  align(center, grid-block(text(weight: "bold", upper(need(meta, "brief_title")))))
}

// ---------------------------------------------------------------------------
// Body: headings, paragraphs, lists (factor lists), the signature and the certificate of service
// ---------------------------------------------------------------------------

/// Headings are numbered by level (level 2: I., 3: A., 4: 1., 5: a.), and the numbers are typed by the template,
/// not the author. Level 1 is not used in the sample.
#let body-of(md) = {
  let chunks = md.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let c2 = 0
  let c3 = 0
  let c4 = 0
  let c5 = 0
  let out = []
  for c in chunks {
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
      } else {
        c5 += 1
        label = numbering("a.", c5)
      }
      // Sticky: the heading stays on the page with the text after it.
      out += block(width: 100%, above: 0pt, below: body-leading, sticky: true,
        par(hanging-indent: 0.5in, first-line-indent: 0pt, leading: body-leading,
          text(weight: "bold", [#label#h(0.5in)#upper(title)])))
    } else if t.find(regex("^\\d+\\.\\s")) != none {
      // A markdown list of factors or items: each item is labelled (1), (2), ... and hangs from its label.
      let li = 0
      for item in t.split(regex("\\r?\\n")).filter(l => l.trim() != "") {
        li += 1
        let text-of = item.trim().replace(regex("^\\d+\\.\\s+"), "")
        out += grid-block({
          set par(leading: body-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
          pad(left: 0.5in, [(#li)#h(0.5in)#inl(text-of)])
        })
      }
    } else {
      out += grid-block({
        set par(leading: body-leading, first-line-indent: 0pt)
        [#h(para-indent)#inl(t)]
      })
    }
  }
  out
}

#let signature-block(meta) = block(breakable: false, above: body-leading, {
  let sig = need(meta, "signature")
  pad(left: 3.25in, {
    single-stack(([Respectfully submitted,], block(height: body-leading * 0.5)))
    single-stack(sig.map(l => inl(l)))
  })
})

#let certificate(meta) = {
  let cos = need(meta, "certificate_of_service")
  block(breakable: false, above: body-leading, {
    align(center, block(width: 100%, below: body-leading, sticky: true,
      text(weight: "bold", [CERTIFICATE OF SERVICE])))
    grid-block({
      set par(leading: body-leading, first-line-indent: 0pt)
      [#h(para-indent)#inl(cos.text)]
    })
    pad(left: 0.5in, single-stack(cos.recipients.map(r => inl(r))))
    block(height: body-leading * 1.5)
    pad(left: 3.25in, single-stack(cos.signer.map(l => inl(l))))
  })
}

#let arwb-motion-brief(meta, md) = {
  set page(paper: "us-letter", margin: margin-all, footer: page-footer())
  set text(font: font-family, size: type-size, lang: "en", region: "us", hyphenate: false)
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  cover(meta)

  if "lead_in" in meta {
    grid-block({
      set par(leading: body-leading, first-line-indent: 0pt)
      [#h(para-indent)#inl(meta.lead_in)]
    })
  }

  body-of(md)

  signature-block(meta)
  if "certificate_of_service" in meta { certificate(meta) }
}
