// Motion or memorandum in support, for the United States Bankruptcy Court, E.D. Missouri (moeb).
// Governing text: E.D. Mo. Local Rules of Bankruptcy Procedure, "as revised effective December 1, 2025"
// (PDF fetched 2026-10-14 from the court's site through WebFetch; see ../README.md):
//   L.R. 9004(A): caption; top left the debtor, and for motions the movant and respondent; top right the case
//   number with judge code, chapter, motion number, hearing date, time and location, and the response date.
//   L.R. 9004(B): descriptive title.
//   L.R. 9004(C): paper 8-1/2 x 11, margins no less than 1 inch, one side, standard 12-point font; no motion,
//   memorandum or brief to exceed 15 pages exclusive of signature page, certificate and attachments; numbered
//   paragraphs except in memoranda of law.
//   L.R. 9004(D): every filing includes or is accompanied by a certificate of service.
//   L.R. 9013-1(E): a memorandum, if filed, is filed with the motion; 15-page limit as above.
// Content-agnostic: every case word comes from the sample's frontmatter and body, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"       // Vendored in fonts/. No rule names a typeface; see README.md.
#let type-size = 12pt                  // L.R. 9004(C): standard 12-point font, footnotes and footer included.
#let margin = 1in                      // L.R. 9004(C): margins no less than 1 inch.
#let text-width = 8.5in - 2 * margin
#let body-leading = 1.65em             // Double spacing: EB Garamond's line box is 0.65em, so this is a 27.6 pt pitch at 12 pt (2 x 13.8 pt).
#let single-leading = 0.5em            // Single spacing for captions, block quotes, footnotes, signature block and headings (13.8 pt at 12 pt).
#let para-indent = 0.5in               // First-line indent of numbered paragraphs.
#let quote-indent = 0.5in              // Left and right indent of block quotes.
#let caption-left = 3.6in              // Width of the left (debtor and parties) column of the caption.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("moeb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, section signs, and so on).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Markdown with footnote markers `[^n]`. The text of each footnote comes from the frontmatter `footnotes`
/// map, so the markdown body stays one paragraph per chunk and the notes sit where the marker is.
#let md(t, fns) = {
  // cmarker trims the whitespace at each end of what it renders, so a space that follows a marker
  // ("case. [^2] On") is put back as an explicit space after the note.
  let out = []
  let last = 0
  for m in t.matches(regex("\\[\\^(\\d+)\\]")) {
    let before = t.slice(last, m.start)
    out += cmarker.render(before.trim(), raw-typst: false, smart-punctuation: true, h1-level: 1)
    let note = fns.at(m.captures.at(0), default: none)
    assert(note != none, message: "moeb-motion-brief: footnote " + m.captures.at(0) + " has no text in the frontmatter")
    // Footnote text is 12 point, the same as the body: L.R. 9004(C) sets one size for the document.
    out += footnote(par(leading: single-leading, justify: false, inl(note)))
    last = m.end
    if t.slice(last).starts-with(" ") { out += [ ] }
  }
  out + cmarker.render(t.slice(last).trim(), raw-typst: false, smart-punctuation: true, h1-level: 1)
}

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Caption and first page (L.R. 9004(A); L.R. 9013-1)
// ---------------------------------------------------------------------------

#let court-title() = {
  // Fixed court name, not case-specific. Three single-spaced lines, centered and bold.
  align(center, text(weight: "bold", line-stack((
    "UNITED STATES BANKRUPTCY COURT",
    "EASTERN DISTRICT OF MISSOURI",
    "EASTERN DIVISION",
  ))))
}

#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.25in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), {
    // Debtor block (L.R. 9004(A): top left, the debtor), then the movant and respondent, "v." between them.
    line-stack(meta.caption.debtor)
    v(body-leading * 0.5)
    let rows = ()
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { rows.push("v.") }
      rows += p.names + (p.designation,)
    }
    line-stack(rows)
  }),
  block(inset: (left: 0.15in), {
    // Top right (L.R. 9004(A)): case number with judge, chapter, motion or adversary number, then the hearing date,
    // time and location, and the response date.
    let rows = ("Case No. " + meta.case_number,)
    if "judge" in meta { rows.push(meta.judge) }
    if "chapter" in meta { rows.push(meta.chapter) }
    if meta.at("motion_number", default: "") != "" { rows.push("Motion No. " + meta.motion_number) }
    if "hearing" in meta and meta.hearing != none { rows += meta.hearing }
    line-stack(rows)
  }),
)

// ---------------------------------------------------------------------------
// Body: headings, numbered paragraphs, block quotes, unnumbered paragraphs
// ---------------------------------------------------------------------------

/// Numbered paragraphs (L.R. 9004(C) requires them except in memoranda; the sample follows the numbering of two
/// of the three filed exemplars, see README.md). Each blank-line-separated chunk is one of:
///   `# ...`, `## ...`   heading (level 1 centered caps; level 2 bold, indented)
///   `> ...`             block quotation: single-spaced, indented both sides, unnumbered
///   `%%...`             centered, unnumbered
///   `%...`              unnumbered paragraph (continuations, WHEREFORE clauses)
///   anything else       numbered paragraph
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph content
/// recurses without end in typst 0.15.
#let allegations(body, para-counter, meta, tail) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let fns = meta.at("footnotes", default: (:))
  // A heading that follows the previous chunk waits in `pending` and is placed with the next one.
  // The last chunk is kept in one unbreakable block with the signature and certificate (`tail`), so neither
  // stands alone on a page.
  let pending = []
  let has-pending = false
  for (i, c) in chunks.enumerate() {
    // Non-breaking spaces keep "11 U.S.C. § 548" together and keep "§ 548" on one line.
    let t = c.trim().replace(" U.S.C.", "\u{00A0}U.S.C.").replace("U.S.C. §", "U.S.C.\u{00A0}§").replace("§ ", "§\u{00A0}")
    let last = i == chunks.len() - 1
    if t.starts-with("#") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
    } else {
      let piece = if t.starts-with(">") {
        block(width: text-width, below: body-leading * 0.5, {
          set par(leading: single-leading)
          pad(left: quote-indent, right: quote-indent, md(t.slice(1).trim(), fns))
        })
      } else if t.starts-with("%%") {
        // Each paragraph is a block: inline content with its own paragraphs would not reserve its height.
        // Its trailing spacing is explicit (`below`), because a block does not include the leading after its last line.
        block(width: text-width, below: body-leading, {
          set par(leading: body-leading)
          align(center, md(t.slice(2).trim(), fns))
        })
      } else if t.starts-with("%") {
        block(width: text-width, below: body-leading, {
          set par(leading: body-leading)
          h(para-indent)
          md(t.slice(1).trim(), fns)
        })
      } else {
        // The number is stepped here and displayed in context, so it reads the count at its own position.
        para-counter.step()
        block(width: text-width, below: body-leading, {
          set par(leading: body-leading)
          context [#h(para-indent)#(para-counter.display()).#h(0.5in)#md(t, fns)]
        })
      }
      if last {
        block(breakable: false, width: text-width, {
          if has-pending { pending }
          piece
          tail
        })
      } else if has-pending {
        // Headings are sticky (see the show rules below), so the heading moves with the first line of the
        // paragraph after it. The paragraph itself may break across pages.
        pending
        piece
      } else {
        piece
      }
      pending = []
      has-pending = false
    }
  }
  if pending != [] { block(breakable: false, width: text-width, pending) }
}

// ---------------------------------------------------------------------------
// Signature block and certificate of service
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let s = meta.signature
  v(body-leading)
  block(breakable: false, width: text-width, grid(
    columns: (3in, 1fr),
    column-gutter: 0.2in,
    [Dated: #s.date],
    {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      [Respectfully submitted,]
      v(body-leading * 0.5)
      line-stack((s.firm,))
      v(body-leading * 0.5)
      line-stack(("By: " + s.by,))
      // Attorney names and contact lines sit under "By:", as in the filed signature block. The explicit v()
      // is the leading a stack does not report after its last line (see README.md, layout findings).
      v(single-leading)
      pad(left: 0.4in, line-stack(s.attorneys + s.lines))
    },
  ))
}

/// Certificate of service (L.R. 9004(D)). Required: a sample without `certificate` fails the build, because
/// every filing must include or accompany one. The served parties are listed by name and address for those
/// not served through CM/ECF (L.R. 9004(D)(2)).
#let certificate-block(meta) = {
  assert("certificate" in meta, message: "moeb-motion-brief: every filing needs a certificate of service (L.R. 9004(D))")
  block(breakable: false, width: text-width, below: body-leading, {
    v(body-leading)
    align(center, text(weight: "bold", "CERTIFICATE OF SERVICE"))
    v(body-leading * 0.5)
    for p in meta.certificate {
      block(width: text-width, below: single-leading, {
        set par(leading: single-leading)
        h(para-indent)
        inl(p)
      })
    }
  })
}

// ---------------------------------------------------------------------------
// The filing
// ---------------------------------------------------------------------------

#let moeb-motion-brief(meta, body) = {
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: margin,
    footer: context align(center, text(size: type-size, counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 is a centered caps section; level 2 a bold sub-heading indented to the paragraph text.
  show heading.where(level: 1): it => block(width: text-width, above: body-leading, below: body-leading * 0.5, sticky: true,
    align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: text-width, above: 0pt, below: body-leading, sticky: true,
    pad(left: 0.5in, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => block(width: text-width, above: body-leading * 0.5, below: 0pt, sticky: true,
    text(weight: "bold", style: "italic", it.body))

  court-title()
  v(body-leading)
  caption(meta)
  v(body-leading)
  align(center, text(weight: "bold", upper(meta.title)))
  v(body-leading * 0.5)

  if "lead_in" in meta {
    block(width: text-width, below: body-leading, {
      set par(leading: body-leading)
      h(para-indent)
      md(meta.lead_in, meta.at("footnotes", default: (:)))
    })
  }

  allegations(body, para-counter, meta, {
    signature-block(meta)
    certificate-block(meta)
  })
}
