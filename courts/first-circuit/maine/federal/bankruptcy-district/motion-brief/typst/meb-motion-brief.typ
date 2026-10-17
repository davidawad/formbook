// Motion with incorporated memorandum for the U.S. Bankruptcy Court, District of Maine (meb).
// Rules: Fed. R. Bankr. P. 9013 (a motion states its grounds with particularity and the relief sought);
// 9004(a) (legible); D. Me. LBR 9013-1(a) (every written motion has a proposed order; not produced here),
// 9013-3 (legend "Relief Requested Without a Hearing" in the upper right corner of the first page);
// D. Me. LBR 7003-1(a) (caption of a paper in an adversary proceeding: main case caption, party names,
// title, adversary number; the adversary rows are used only when the sample has `parties`).
// See ../README.md for the rule text, dates verified and the open questions.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or to a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // no D. Me. rule on typeface; Times New Roman substitute per docs/FONTS.md, vendored in fonts/ (README.md, gap 2)
#let type-size = 12pt                   // legible, 12 point is the convention in the filed exemplar
#let page-w = 8.5in
#let page-h = 11in
#let margin = 1in                       // no D. Me. margin rule; the exemplar uses one inch on all sides
#let text-width = page-w - 2 * margin
#let body-leading = 1.345em             // double spacing (about 24 pt baseline pitch at 12 pt, as the exemplar)
#let pitch = 24pt                       // one double-spaced line; blocks are rounded up to whole lines
#let single-leading = 0.5em             // single spacing: caption, court name, signature, service list
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let caption-left = 3.4in               // width of the party column of the caption
#let court-name = ("UNITED STATES BANKRUPTCY COURT", "DISTRICT OF MAINE")

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("meb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Fill whole double-spaced lines: the block is rounded up to a multiple of `pitch`, so whatever
/// follows it starts on the next line of the grid and no line is drawn over another.
#let on-grid(c) = context {
  let h = measure(width: text-width, c).height
  block(width: text-width, height: calc.ceil(h / pitch) * pitch, above: 0pt, below: 0pt, c)
}

/// Single-spaced lines: each item is one block; the stack keeps single spacing between them.
#let single-lines(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Cover: legend, court name, caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title() = {
  set par(leading: single-leading, spacing: 0pt)
  stack(dir: ttb, spacing: single-leading, ..court-name.map(n => align(center, text(weight: "bold", n))))
}

/// The caption: the main case (debtor, chapter, case number) and, below it, the adversary proceeding
/// when the sample has `parties`. A contested matter in the main case has only the first row.
#let caption(meta) = {
  let debtor = meta.debtor
  let case-rows = ((
    single-lines(("In re:",) + debtor.names + (debtor.designation,)),
    single-lines(("Chapter " + meta.chapter, "Case No. " + meta.case_number)),
  ),)
  if "parties" in meta and meta.parties != none {
    let rows = ()
    for (k, p) in meta.parties.enumerate() {
      if k > 0 { rows.push("v.") }
      rows += p.names + (p.designation,)
    }
    case-rows.push((
      single-lines(rows),
      single-lines(("Adv. Proc. No. " + meta.adv_number,)),
    ))
  }
  let cells = ()
  for (left, right) in case-rows {
    cells.push(block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, top: 6pt, bottom: 10pt), left))
    cells.push(block(width: 100%, stroke: (bottom: 0.75pt), inset: (left: 0.2in, top: 6pt, bottom: 10pt), right))
  }
  grid(columns: (caption-left, 1fr), ..cells)
}

#let cover(meta) = {
  if "without_hearing" in meta and meta.without_hearing {
    // D. Me. LBR 9013-3: the legend goes in the upper right corner of the first page.
    align(right, text(weight: "bold", "RELIEF REQUESTED WITHOUT A HEARING"))
    v(pitch * 0.5)
  }
  court-title()
  v(pitch)
  caption(meta)
  v(pitch)
  align(center, text(weight: "bold", upper(meta.title)))
  v(pitch * 0.5)
}

// ---------------------------------------------------------------------------
// Body: headings, numbered paragraphs, lists, relief, signature, certificate
// ---------------------------------------------------------------------------

/// Numbered paragraphs. Each blank-line-separated chunk of markdown that is neither a heading nor a
/// list is one numbered paragraph. Headings and lists are rendered unnumbered. The number is a plain
/// loop variable, not a counter in `context`: a context block per paragraph left the paragraphs'
/// heights short by a line.
#let numbered-body(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let n = 0
  // A heading is kept in one unbreakable block with the chunk after it, so it never ends a page.
  let pending = []
  let has-pending = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      // Headings are set here, not by cmarker: cmarker's own heading output ignores the show rules.
      let h = t.match(regex("^(#{1,3})\\s+([\\s\\S]*)$"))
      let level = h.captures.at(0).len()
      let title = h.captures.at(1).trim()
      pending += on-grid(block(width: text-width, above: pitch * 0.5, below: pitch * 0.5, sticky: true, {
        if level == 1 {
          align(center, text(weight: "bold", title))
        } else if level == 2 {
          text(weight: "bold", title)
        } else {
          text(weight: "bold", style: "italic", title)
        }
      }))
      has-pending = true
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Lists: items lettered (a), (b), ...; a list may break across pages.
      let items = {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      }
      if has-pending {
        block(breakable: false, width: text-width, { pending; items })
      } else {
        items
      }
      pending = []
      has-pending = false
    } else {
      n += 1
      let piece = on-grid({
        set par(leading: body-leading)
        h(para-indent)
        [#str(n).#h(0.3in)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)]
      })
      if has-pending {
        block(breakable: false, width: text-width, { pending; piece })
      } else {
        piece
      }
      pending = []
      has-pending = false
    }
  }
  if pending != [] { block(breakable: false, width: text-width, pending) }
}

/// The unnumbered opening paragraphs ("NOW COMES ..."). Each blank-line-separated paragraph is its own
/// measured block: several paragraphs in one block left the last line of one drawn over the next.
#let lead-in(meta) = {
  if "lead_in" in meta and meta.lead_in != none {
    for chunk in meta.lead_in.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "") {
      on-grid({
        set par(leading: body-leading)
        h(para-indent)
        inl(chunk.trim())
      })
    }
  }
}

/// The unnumbered closing paragraph ("WHEREFORE ..."), indented as a body paragraph.
#let relief(meta) = {
  if "wherefore" in meta and meta.wherefore != none {
    on-grid({
      set par(leading: body-leading)
      h(para-indent)
      inl(meta.wherefore)
    })
  }
}

/// Date and signature block, single-spaced, kept together.
#let signature-block(meta) = block(breakable: false, above: pitch, width: text-width, grid(
  columns: (2.8in, 1fr),
  column-gutter: 0.2in,
  [Dated: #meta.date],
  single-lines(("/s/ " + meta.signature.signer,) + meta.signature.lines),
))

/// Certificate of service on its own page (the exemplar has one). The service rule it certifies is not
/// cited by this template (see README.md, known gaps).
#let certificate(meta) = {
  if "certificate" in meta and meta.certificate != none {
    let c = meta.certificate
    pagebreak()
    align(center, text(weight: "bold", upper(c.title)))
    v(pitch * 0.5)
    for para in c.body {
      on-grid({
        set par(leading: body-leading)
        h(para-indent)
        inl(para)
      })
    }
    v(pitch * 0.5)
    block(breakable: false, width: text-width, grid(
      columns: (2.8in, 1fr),
      column-gutter: 0.2in,
      [Dated: #c.date],
      single-lines(("/s/ " + c.signature.signer,) + c.signature.lines),
    ))
    v(pitch)
    block(breakable: false, width: text-width, single-lines(c.service))
  }
}

#let meb-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    footer: context align(center, text(size: type-size, [#"- "#counter(page).display()#" -"])),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  cover(meta)

  lead-in(meta)

  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  numbered-body(body)

  // The closing paragraph stays on the page with the signature block it leads into.
  block(breakable: false, width: text-width, {
    relief(meta)
    signature-block(meta)
  })
  certificate(meta)
}
