// Complaint in an adversary proceeding, United States Bankruptcy Court, Eastern District of Louisiana.
// Rules: Fed. R. Bankr. P. 7003 (commencement: Fed. R. Civ. P. 3 applies), 7010 (Fed. R. Civ. P. 10 applies;
// the caption must substantially conform to Form 416), 9004(a) (legible), 9004(b) (caption contents);
// Fed. R. Civ. P. 10(a) (caption) and 10(b) (numbered paragraphs). The court's 2013 Local Rules set no
// paper, type or margin rule for pleadings (see ../README.md). Typography is a convention, not a rule.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let court-lines = ("UNITED STATES BANKRUPTCY COURT", "EASTERN DISTRICT OF LOUISIANA")  // Fed. R. Bankr. P. 9004(b)
#let font-family = "Liberation Serif"   // no E.D. La. font rule; Times New Roman substitute per docs/FONTS.md (the exemplar is Times New Roman)
#let type-size = 12pt                   // convention: the exemplar's body is 12 pt
#let page-w = 8.5in                     // letter paper
#let page-h = 11in
#let margin = 1in                       // convention: the exemplar's margins are 1 inch
#let text-width = page-w - 2 * margin
#let body-leading = 1.345em             // double spacing: Liberation Serif's line box is 0.655em, so 24 pt pitch at 12 pt
#let single-leading = 0.495em            // single spacing for caption, counsel and signature block
#let para-indent = 0.5in                // first-line indent of numbered paragraphs (number sits at the indent)
#let caption-left = 3.4in               // width of the party column of the caption
#let footer-size = 11pt

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("laeb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Blank-line-separated chunks of the body, without empty ones.
#let chunks-of(body) = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")

/// Footnote definitions (`[^key]: text`) are collected from the whole body. A chunk that uses a key gets
/// its definition appended, so cmarker renders the footnote where it is referenced.
#let note-defs(chunks) = {
  let defs = (:)
  for c in chunks {
    let m = c.match(regex("^\\[\\^([^\\]]+)\\]:[ \\t]*([\\s\\S]*)$"))
    if m != none { defs.insert(m.captures.at(0), m.captures.at(1)) }
  }
  defs
}

#let with-notes(t, defs) = {
  let keys = ()
  for m in t.matches(regex("\\[\\^([^\\]]+)\\]")) {
    let k = m.captures.at(0)
    if k not in keys { keys.push(k) }
  }
  t + keys.map(k => "\n\n[^" + k + "]: " + defs.at(k)).join("")
}

/// "# Text" is level 1, "## Text" level 2, "### Text" level 3.
#let heading-level(t) = t.split(" ").first().len()
#let heading-text(t) = t.slice(heading-level(t)).trim()

/// Single-spaced lines (caption, counsel, signature).
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => if type(i) == str { inl(i) } else { i }))
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

#let footer-block() = context {
  let p = counter(page).get().first()
  let n = counter(page).final().first()
  align(center, text(size: footer-size, [Page #p of #n]))
}

// ---------------------------------------------------------------------------
// Caption: court title, parties (left, with a rule at its right edge), case information (right)
// ---------------------------------------------------------------------------

/// Parties in order. Each party is {names, designation, sep}; "v." (or the sample's own word in `sep`)
/// is printed before every party but the first, unless `sep` is "" (a debtor's line, for example).
#let party-stack(c) = {
  let items = ()
  if "lead" in c { items.push(c.lead) }
  for (k, p) in c.parties.enumerate() {
    let sep = p.at("sep", default: "v.")
    if k > 0 {
      items.push([])  // a blank line between parties, as in the caption of the exemplar
      if sep != "" { items.push(sep) }
    }
    for n in p.names { items.push(n) }
    items.push(pad(left: 1.6in, p.designation))
  }
  line-stack(items)
}

#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.25in,
  block(width: caption-left, stroke: (right: 0.75pt), inset: (right: 10pt, bottom: 6pt), party-stack(meta.caption)),
  block(inset: (left: 0.1in), line-stack(meta.case_info)),
)

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// A heading is kept with the paragraph after it (sticky), so it never ends a page.
#let heading-block(t) = {
  let lvl = heading-level(t)
  let txt = heading-text(t)
  let content = if lvl == 1 {
    align(center, text(weight: "bold", inl(upper(txt))))
  } else {
    align(center, text(weight: "bold", inl(txt)))
  }
  // A block carries no leading below its last line, so every block ends with one pitch (body-leading):
  // paragraphs then stay on the double-spaced grid and a heading has one blank line above it.
  block(width: text-width, above: body-leading, below: body-leading, sticky: true, content)
}

/// Numbered allegations (Fed. R. Civ. P. 10(b)). Each chunk that is neither a heading nor a list is one
/// numbered paragraph; a list is lettered (a), (b), ... by the template. Numbering is per chunk, not a
/// `show par` rule: a show rule that re-wraps paragraph content recurses without end in typst 0.15.
#let allegations(body, defs, para-counter) = {
  for t in chunks-of(body) {
    if t.starts-with("[^") { continue }
    if t.starts-with("#") {
      heading-block(t)
    } else if t.starts-with(">") {
      // A block quotation is not an allegation: it is indented and not numbered.
      block(width: text-width, below: body-leading, pad(left: 0.5in, right: 0.5in, {
        set par(leading: body-leading)
        inl(with-notes(t, defs))
      }))
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      block(width: text-width, below: body-leading, {
        set par(leading: body-leading)
        inl(with-notes(t, defs))
      })
    } else {
      para-counter.step()
      block(width: text-width, below: body-leading, context {
        set par(leading: body-leading)
        [#h(para-indent)#(para-counter.display()).#h(0.3in)#inl(with-notes(t, defs))]
      })
    }
  }
}

/// Counsel signature block (single-spaced, on the right half of the page).
#let signature-block(meta) = block(width: text-width, breakable: false, above: body-leading, {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  if "date" in meta { [Dated: #meta.date] ; v(body-leading) }
  pad(left: 3in, {
    [Respectfully submitted,]
    v(body-leading)
    [BY: #meta.signature.by]
    v(body-leading * 0.5)
    for (i, b) in meta.signature.blocks.enumerate() {
      if i > 0 {
        v(body-leading * 0.5)
        [And]
        v(body-leading * 0.5)
      }
      line-stack(b)
    }
  })
})

#let laeb-adversary-complaint(meta, body) = {
  let para-counter = counter("laeb-allegation")
  let defs = note-defs(chunks-of(body))

  set page(
    paper: "us-letter",
    margin: margin,
    footer: footer-block(),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)

  align(center, line-stack(court-lines.map(l => text(weight: "bold", l))))
  v(body-leading)
  caption(meta)
  v(body-leading)
  align(center, text(weight: "bold", meta.title))
  v(body-leading)

  if "lead_in" in meta {
    block(width: text-width, below: body-leading, {
      set par(leading: body-leading)
      h(para-indent)
      inl(meta.lead_in)
    })
  }

  allegations(body, defs, para-counter)

  signature-block(meta)
}
