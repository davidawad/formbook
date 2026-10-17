// Motion (with an optional supporting memorandum) for the United States Bankruptcy Court, E.D. Missouri (moeb).
// Governing text: E.D. Mo. Local Rules of Bankruptcy Procedure, "as revised effective December 1, 2025"
// (PDF fetched 2026-10-14 from https://www.moeb.uscourts.gov/sites/moeb/files/Local_Rules_Dec_1_2025.pdf; see ../README.md):
//   L.R. 9004(A): caption; top left the debtor, and for a motion the movant and respondent; top right the case
//   number with judge code, chapter, motion number, current hearing date, time and location, and the response date.
//   L.R. 9004(B): descriptive title of the relief sought.
//   L.R. 9004(C): letter paper, margins no less than 1 inch, one side, standard 12-point font, numbered paragraphs
//   (memoranda excepted), and no motion or memorandum over 15 pages without leave, exclusive of the signature
//   page, certificate of service and attachments.
//   L.R. 9004(D): every filing has a certificate of service stating who was served, the date, and the manner.
//   L.R. 9013-1(E): a memorandum of law is optional; if filed, it is filed with the motion or 7 days before hearing.
//   L.R. 9013-1(F): a consent motion's title must say so.
// Content-agnostic: every case word comes from the sample's frontmatter and body, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")       // Vendored in fonts/. L.R. 9004(C) names no typeface; see README.md.
#let type-size = 12pt                  // L.R. 9004(C): standard 12-point font, footer included.
#let margin = 1in                      // L.R. 9004(C): margins no less than 1 inch.
#let text-width = 8.5in - 2 * margin
#let body-leading = 1.65em             // Double spacing: EB Garamond's line box is 0.65em, so this is a 27.6 pt pitch at 12 pt (2 x 13.8 pt).
#let single-leading = 0.5em            // Single spacing for captions, signature block and headings (13.8 pt at 12 pt).
#let para-indent = 0.5in               // First-line indent of numbered paragraphs.
#let caption-left = 3.6in              // Width of the left (debtor, movant, respondent) column of the caption.

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

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

/// Footnote definitions (`[^key]: text`) are collected from the body. Each is attached to the paragraph that uses
/// its marker, because cmarker resolves a footnote only within the string it renders.
#let footnote-defs(body) = {
  let defs = (:)
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")) {
    let m = c.trim().match(regex("^\\[\\^([^\\]]+)\\]:[ \\t]*([\\s\\S]*)$"))
    if m != none { defs.insert(m.captures.at(0), m.captures.at(1)) }
  }
  defs
}

/// The text of one paragraph with the definitions of the footnotes it cites appended.
#let attach-notes(t, defs) = {
  let keys = t.matches(regex("\\[\\^([^\\]]+)\\]")).map(m => m.captures.at(0))
  t + keys.map(k => {
    assert(k in defs, message: "moeb-motion-brief: footnote [^" + k + "] has no definition")
    "\n\n[^" + k + "]: " + defs.at(k)
  }).join("")
}

// ---------------------------------------------------------------------------
// Caption and first page (L.R. 9004(A); Local Form 22)
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
    // Top left (L.R. 9004(A)): the debtor, then the movant and respondent, each with its names and designation.
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
    // Top right (L.R. 9004(A)): case number with judge code, chapter, motion number, hearing and response date.
    // A motion is filed before a motion number or hearing is assigned, so those lines appear only when the sample
    // supplies them.
    let rows = ("Case No. " + meta.case_number,)
    if "judge" in meta { rows.push(meta.judge) }
    if "chapter" in meta { rows.push(meta.chapter) }
    if meta.at("motion_number", default: "") != "" { rows.push("Motion No. " + meta.motion_number) }
    if "hearing" in meta and meta.hearing != none { rows += meta.hearing }
    if meta.at("response_date", default: "") != "" { rows.push(meta.response_date) }
    line-stack(rows)
  }),
)

// ---------------------------------------------------------------------------
// Body: headings, numbered paragraphs, lists, unnumbered paragraphs
// ---------------------------------------------------------------------------

/// Numbered paragraphs (L.R. 9004(C)). Each blank-line-separated chunk is one of:
///   `# ...`, `## ...`   heading (level 1 centered caps; level 2 centered bold)
///   `1. ...` or `- ...` list (lettered (a), (b), ... by the template)
///   `%%...`             centered, unnumbered
///   `%...`              unnumbered paragraph (for WHEREFORE clauses)
///   `[^key]: ...`       footnote definition (attached to the paragraph that cites it)
///   anything else       numbered paragraph
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph content
/// recurses without end in typst 0.15.
#let allegations(body, para-counter, tail) = {
  let defs = footnote-defs(body)
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "" and not c.trim().starts-with("[^"))
  // A heading is kept in one unbreakable block with the chunk after it, so it never ends a page.
  // The last chunk is kept in one unbreakable block with the signature (`tail`), so a signature never stands alone.
  let pending = []
  let has-pending = false
  for (i, c) in chunks.enumerate() {
    // Non-breaking spaces keep "11 U.S.C. § 548" together and keep "§ 548" on one line.
    let raw-t = c.trim().replace(" U.S.C.", "\u{00A0}U.S.C.").replace("U.S.C. §", "U.S.C.\u{00A0}§").replace("§ ", "§\u{00A0}")
    let t = attach-notes(raw-t, defs)
    let last = i == chunks.len() - 1
    if t.starts-with("#") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
    } else {
      let piece = if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
        // A list may break across pages; each item fills whole lines and the trailing v() closes the last one.
        {
          set par(leading: body-leading)
          cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
          v(body-leading * 0.5)
        }
      } else if t.starts-with("%%") {
        // Each paragraph is a block: inline content with its own paragraphs would not reserve its height.
        // Its trailing spacing is explicit (`below`), because a block does not include the leading after its last line.
        block(width: text-width, below: body-leading, {
          set par(leading: body-leading)
          align(center, cmarker.render(attach-notes(t.slice(2).trim(), defs), raw-typst: false, smart-punctuation: true, h1-level: 1))
        })
      } else if t.starts-with("%") {
        block(width: text-width, below: body-leading, {
          set par(leading: body-leading)
          h(para-indent)
          cmarker.render(attach-notes(t.slice(1).trim(), defs), raw-typst: false, smart-punctuation: true, h1-level: 1)
        })
      } else {
        // The number is stepped here and displayed in context, so it reads the count at its own position.
        para-counter.step()
        block(width: text-width, below: body-leading, {
          set par(leading: body-leading)
          context [#h(para-indent)#(para-counter.display()).#h(0.5in)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)]
        })
      }
      if last {
        block(breakable: false, width: text-width, {
          if has-pending { pending }
          piece
          tail
        })
      } else if has-pending {
        block(breakable: false, width: text-width, below: body-leading, { pending; piece })
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
    [Date: #s.date],
    {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      [Respectfully Submitted,]
      v(body-leading * 0.5)
      line-stack((s.firm,))
      v(body-leading * 0.5)
      line-stack(("By: " + s.by,) + s.attorneys + s.lines)
    },
  ))
}

/// The certificate of service (L.R. 9004(D)). Required: every filing must include one, or be accompanied by one.
/// It names each person served, the date, and the manner (CM/ECF or first-class mail).
#let certificate-block(meta) = {
  assert("certificate" in meta, message: "moeb-motion-brief: every motion needs a certificate of service (L.R. 9004(D))")
  let c = meta.certificate
  block(breakable: false, width: text-width, below: body-leading, {
    v(body-leading)
    align(center, text(weight: "bold", "CERTIFICATE OF SERVICE"))
    v(body-leading * 0.5)
    for p in c.paragraphs {
      block(width: text-width, below: body-leading, {
        set par(leading: body-leading)
        h(para-indent)
        inl(p)
      })
    }
    if "served" in c {
      for entry in c.served {
        block(width: text-width, below: single-leading * 2, {
          set par(leading: single-leading, spacing: 0pt, justify: false)
          h(para-indent)
          line-stack(entry)
        })
      }
      v(body-leading * 0.5)
    }
    block(breakable: false, width: text-width, grid(
      columns: (3in, 1fr),
      column-gutter: 0.2in,
      [Date: #c.date],
      [#c.signature],
    ))
  })
}

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

#let moeb-motion(meta, body) = {
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: margin,
    footer: context align(center, text(size: type-size, counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 is a centered caps section; level 2 a centered bold sub-heading; level 3 bold italic.
  show heading.where(level: 1): it => block(width: text-width, above: body-leading, below: body-leading * 0.5, sticky: true,
    align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: text-width, above: 0pt, below: body-leading, sticky: true,
    align(center, text(weight: "bold", it.body)))
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
      inl(meta.lead_in)
    })
  }

  // The certificate is its own block, so a short final page holds the WHEREFORE and signature and the certificate
  // moves as a whole only when it does not fit.
  allegations(body, para-counter, signature-block(meta))
  certificate-block(meta)
}
