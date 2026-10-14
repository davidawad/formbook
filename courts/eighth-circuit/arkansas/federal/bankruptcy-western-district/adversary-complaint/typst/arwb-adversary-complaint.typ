// Adversary complaint for the U.S. Bankruptcy Court, Western District of Arkansas.
// Rules: Fed. R. Bankr. P. 7010 (caption substantially conforms to Official Form 416, the adversary
// caption), 9004(a) (legible), 9004(b) (caption: court, title, case number and adversary number, designation);
// Fed. R. Civ. P. 10(b) as applied by Rule 7010 (numbered paragraphs). See ../README.md for the rule IDs,
// sources and the known gaps (the W.D. Ark. local rules text was not retrievable).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a named layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // vendored in fonts/; no Times New Roman is vendored (README.md, gap 2)
#let type-size = 13pt                   // EB Garamond sets narrower than Times, so 13 pt gives about the exemplar's line length (README.md, gap 2)
#let body-leading = 1.2em               // double spacing: 0.65em line box + 1.2em leading = 24 pt baseline pitch at 13 pt (measured, README.md)
#let single-leading = 0.55em            // single spacing for caption, court title and signature: 0.65em box + 0.55em = 1.2em pitch
#let para-indent = 0.5in                // first-line indent of numbered paragraphs and of the opening paragraph
#let number-gap = 0.3in                 // gap between a paragraph number and its text
#let caption-left = 3.7in               // width of the debtor and party column of the caption
#let margin-all = 1in

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
// Page furniture
// ---------------------------------------------------------------------------

/// Page number centred in the footer, in the form used by the filed exemplar ("- 1 -").
#let page-footer() = context align(center, text(size: type-size, counter(page).display("- 1 -")))

// ---------------------------------------------------------------------------
// Cover: court title, caption (Official Form 416 layout), title of the paper
// ---------------------------------------------------------------------------

/// The court's name, one centred line per item, as the caption requires (Rule 9004(b)(1)).
#let court-title(meta) = {
  let lines = need(meta, "court").map(l => align(center, upper(inl(l))))
  single-stack(lines)
}

/// The caption: the debtor ("In re") and the parties on the left, the case, chapter and adversary numbers on
/// the right (Official Form 416; Rule 7010). The debtor block and the party block are separated by a gap.
#let caption(meta) = {
  let c = need(meta, "caption")
  let debtor = c.debtor
  let left-items = ([In re:],)
  left-items += debtor.names.map(n => inl(n))
  left-items.push(pad(left: 0.9in, inl(debtor.designation)))
  left-items.push(block(height: body-leading * 0.5))
  for (k, p) in c.parties.enumerate() {
    left-items += p.names.map(n => inl(n))
    left-items.push(pad(left: 0.9in, inl(p.designation)))
    if k < c.parties.len() - 1 {
      left-items.push(block(height: body-leading * 0.5))
      left-items.push(pad(left: 0.9in, [v.]))
      left-items.push(block(height: body-leading * 0.5))
    }
  }
  let right = single-stack((
    [Case No. #need(meta, "case_number")],
    [Chapter #need(meta, "chapter")],
    block(height: body-leading * 2),
    [Adv. Pro. No. #need(meta, "adversary_number")],
  ))
  grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.2in,
    single-stack(left-items),
    right,
  )
}

#let cover(meta) = {
  court-title(meta)
  block(height: body-leading * 1.5)
  caption(meta)
  block(height: body-leading * 1.5)
  align(center, grid-block(text(weight: "bold", upper(need(meta, "document_title")))))
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs, centred headings, the prayer, the signature
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(breakable: false, above: body-leading, {
  pad(left: 3.25in, {
    single-stack(([Respectfully Submitted,], block(height: body-leading * 0.5)))
    for (i, b) in need(meta, "signature").enumerate() {
      if i > 0 { block(height: body-leading) }
      single-stack(b.map(l => inl(l)))
    }
  })
})

/// Numbered paragraphs (Fed. R. Civ. P. 10(b), as applied by Rule 7010). Each blank-line-separated chunk of
/// markdown that is neither a heading nor a list is one numbered paragraph. A chunk that begins with
/// `WHEREFORE` is the prayer and is not numbered. Headings are kept with the paragraph after them.
/// Numbering is a plain variable, not a counter, so each paragraph's number is fixed when the body is built.
#let allegations(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let n = 0
  let out = []
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      // A section heading is plain capitals in the sample: its text is set directly, so cmarker's own heading size is not used.
      // Sticky: the heading stays on the page with the paragraph after it. Nothing is wrapped around a paragraph
      // (a non-breakable wrapper lost the grid spacing after the paragraph and let lines overlap).
      let title = t.replace(regex("^#+\\s*"), "")
      out += block(width: 100%, above: 0pt, below: body-leading, sticky: true,
        align(center, text(size: type-size, weight: "bold", upper(title))))
    } else if t.starts-with("WHEREFORE") {
      // The prayer stays on the page with the signature block that follows it (sticky), as in the exemplar.
      out += block(width: 100%, above: 0pt, below: body-leading, sticky: true, {
        set par(leading: body-leading, first-line-indent: 0pt)
        [#h(para-indent)#inl(t)]
      })
    } else {
      n += 1
      out += grid-block({
        set par(leading: body-leading, first-line-indent: 0pt)
        [#h(para-indent)#n#"."#h(number-gap)#inl(t)]
      })
    }
  }
  out
}

#let arwb-adversary-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin-all,
    footer: page-footer(),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", hyphenate: false)
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  cover(meta)

  if "lead_in" in meta {
    grid-block({
      set par(leading: body-leading, first-line-indent: 0pt)
      [#h(para-indent)#inl(meta.lead_in)]
    })
  }

  allegations(body)

  signature-block(meta)
}
