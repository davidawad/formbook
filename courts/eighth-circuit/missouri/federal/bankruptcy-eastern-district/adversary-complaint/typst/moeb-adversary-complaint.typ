// Adversary complaint for the United States Bankruptcy Court, E.D. Missouri (moeb).
// Governing text: E.D. Mo. Local Rules of Bankruptcy Procedure, "as revised effective December 1, 2025"
// (PDF fetched 2026-10-14 from the court's site through WebFetch; see ../README.md), and the Federal Rules of
// Bankruptcy Procedure as published by LII (fetched 2026-10-14):
//   Fed. R. Bankr. P. 7010 (caption substantially conforms to the appropriate version of Official Form 416); 7008(a) (jurisdiction, and whether the pleader
//   consents to final orders); Fed. R. Civ. P. 10(a) and 10(b) (caption; numbered paragraphs).
//   L.R. 7003(A): Adversary Proceeding Cover Sheet (Local Form 18) must accompany the complaint. It is a separate
//   clerk form, not produced here.
//   L.R. 9004(A): caption; top left the debtor and the parties; top right the case number with judge, chapter,
//   adversary number and any hearing.
//   L.R. 9004(C): letter paper, margins no less than 1 inch, one side, standard 12-point font, numbered paragraphs.
//   L.R. 9004(D): every filing has a certificate of service (optional block here; see README.md).
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
#let caption-left = 3.6in              // Width of the left (debtor and parties) column of the caption.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("moeb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, bold placeholders, section signs, and so on).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

/// The FRBP 7008(a) consent sentence, which the sample places inline as {{consent}} in the jurisdiction
/// paragraph. A sample without a `consent` value renders a bold placeholder, so an unfinished statement is
/// visible in the render and cannot pass for a finished one.
#let consent-md(meta) = {
  let c = meta.at("consent", default: none)
  if c == none {
    "**[COUNSEL TO STATE WHETHER PLAINTIFF CONSENTS OR DOES NOT CONSENT TO THE ENTRY OF FINAL ORDERS OR JUDGMENT BY THE BANKRUPTCY JUDGE, FED. R. BANKR. P. 7008(a)]**"
  } else {
    assert(c == "consents" or c == "does not consent", message: "moeb-adversary-complaint: consent must be \"consents\" or \"does not consent\"")
    "Pursuant to Fed. R. Bankr. P. 7008(a), Plaintiff " + c + " to the entry of final orders or judgment by the bankruptcy judge."
  }
}

// ---------------------------------------------------------------------------
// Caption and first page (L.R. 9004(A); Fed. R. Bankr. P. 7010)
// ---------------------------------------------------------------------------

#let court-title() = {
  // Fixed court name, not case-specific. Three single-spaced lines, centered and bold.
  align(center, text(weight: "bold", line-stack((
    "UNITED STATES BANKRUPTCY COURT",
    "FOR THE EASTERN DISTRICT OF MISSOURI",
    "EASTERN DIVISION",
  ))))
}

#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.25in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), {
    // Debtor block, then the parties: each with its names and designation, "v." between them.
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
    // Top right of the first page (L.R. 9004(A)): case number with judge, chapter, adversary number, and hearing
    // data once they exist. A complaint is filed before any adversary number or hearing is assigned, so those
    // lines appear only when the sample supplies them.
    let rows = ("Case No. " + meta.case_number,)
    if "judge" in meta { rows.push(meta.judge) }
    if "chapter" in meta { rows.push(meta.chapter) }
    if meta.at("adversary_number", default: "") != "" { rows.push("Adv. Proc. No. " + meta.adversary_number) }
    if "hearing" in meta and meta.hearing != none { rows += meta.hearing }
    line-stack(rows)
  }),
)

// ---------------------------------------------------------------------------
// Body: headings, numbered paragraphs, lists, unnumbered paragraphs
// ---------------------------------------------------------------------------

/// Numbered paragraphs (Fed. R. Civ. P. 10(b) as applied by Fed. R. Bankr. P. 7010; L.R. 9004(C)).
/// Each blank-line-separated chunk is one of:
///   `# ...`, `## ...`   heading (level 1 centered caps; level 2 centered bold)
///   `1. ...` or `- ...` list (lettered (a), (b), ... by the template)
///   `%%...`             centered, unnumbered
///   `%...`              unnumbered paragraph (for WHEREFORE clauses)
///   anything else       numbered paragraph
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph content
/// recurses without end in typst 0.15.
#let allegations(body, para-counter, meta, tail) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // A heading is kept in one unbreakable block with the chunk after it, so it never ends a page.
  // The last chunk is kept in one unbreakable block with the signature (`tail`), so a signature never stands alone.
  let pending = []
  let has-pending = false
  for (i, c) in chunks.enumerate() {
    // Non-breaking spaces keep "11 U.S.C. § 548" together and keep "§ 548" on one line.
    let t = c.trim().replace("{{consent}}", consent-md(meta)).replace(" U.S.C.", "\u{00A0}U.S.C.").replace("U.S.C. §", "U.S.C.\u{00A0}§").replace("§ ", "§\u{00A0}")
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
          align(center, cmarker.render(t.slice(2).trim(), raw-typst: false, smart-punctuation: true, h1-level: 1))
        })
      } else if t.starts-with("%") {
        block(width: text-width, below: body-leading, {
          set par(leading: body-leading)
          h(para-indent)
          cmarker.render(t.slice(1).trim(), raw-typst: false, smart-punctuation: true, h1-level: 1)
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
      [Respectfully submitted,]
      v(body-leading * 0.5)
      line-stack((s.firm,))
      v(body-leading * 0.5)
      line-stack(("By: " + s.by,) + s.attorneys + s.lines)
    },
  ))
}

/// Optional: a certificate of service (L.R. 9004(D)). Rendered only when the sample gives one. The sample for
/// this court's exemplar has none; the rule allows it to be filed separately within 24 hours (L.R. 9004(D)(3)).
#let certificate-block(meta) = {
  if "certificate" in meta {
    block(breakable: false, width: text-width, below: body-leading, {
      v(body-leading)
      align(center, text(weight: "bold", "CERTIFICATE OF SERVICE"))
      v(body-leading * 0.5)
      for p in meta.certificate {
        block(width: text-width, below: body-leading, {
          set par(leading: body-leading)
          h(para-indent)
          inl(p)
        })
      }
    })
  }
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let moeb-adversary-complaint(meta, body) = {
  assert(body.contains("{{consent}}"), message: "moeb-adversary-complaint: the jurisdiction paragraph must carry {{consent}} (Fed. R. Bankr. P. 7008(a))")
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

  allegations(body, para-counter, meta, {
    signature-block(meta)
    certificate-block(meta)
  })
}
