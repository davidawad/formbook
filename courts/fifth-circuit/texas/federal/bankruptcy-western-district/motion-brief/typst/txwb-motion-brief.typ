// Motion with incorporated argument for the U.S. Bankruptcy Court, Western District of Texas (txwb).
// Rules: Fed. R. Bankr. P. 9013 (motions: in writing, stating the grounds with particularity); W.D. Tex. L.R. 9014-1(a)
// (negative-notice form language, bold, at least 12 pt, immediately below the caption and before the body);
// Fed. R. Bankr. P. 9004(a) (legible). See ../README.md. Content-agnostic: case words come from the sample's frontmatter.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a stated convention; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // vendored in fonts/; the only font the build can use
#let type-size = 12pt                   // L.R. 9014-1(a) names 12 pt for the notice; the body is set at the same size
#let margin = 1in                       // convention; the exemplar's margins are about one inch
#let body-leading = 1.35em              // double spacing (about 24 pt pitch at 12 pt)
#let single-leading = 0.5em
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let caption-left = 3.4in               // width of the parties column of the caption
#let text-width = 8.5in - 2 * margin

// Negative-notice form language: L.R. 9014-1(a) as posted at txwb.uscourts.gov (fetched 2026-10-14). Fixed text of the
// rule, never case-specific. The Clerk's mailing address is the one thing the rule asks to be filled in: it comes from
// the sample's `clerk_address` (see ../README.md, the address is not verified).
#let negative-notice(meta) = (
  "This pleading requests relief that may be adverse to your interests.",
  "If no timely response is filed within 21 days from the date of service, the relief requested herein may be granted without a hearing being held.",
  "A timely filed response is necessary for a hearing to be held.",
  "Any response must be timely filed with the United States Bankruptcy Clerk, Western District of Texas, " + meta.clerk_address + ".",
  "If a timely response is filed, the Court will then set a hearing on the Motion, and you will be provided with notice of the date, time, and place of the hearing.",
  "If you do not attend the hearing, the Court may decide that you do not oppose the Motion.",
)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("txwb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names with *italics*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

#let footer-page-number() = context align(center, text(size: type-size, counter(page).display()))

// ---------------------------------------------------------------------------
// Caption: court title, parties (left), case numbers (right), title of the paper
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(leading: body-leading, spacing: body-leading)
  align(center, text(weight: "bold", [IN THE UNITED STATES BANKRUPTCY COURT]))
  align(center, text(weight: "bold", [FOR THE WESTERN DISTRICT OF TEXAS]))
  if "division" in meta and meta.division != none {
    align(center, text(weight: "bold", upper(meta.division) + [ DIVISION]))
  }
  v(body-leading)
}

#let caption(meta) = {
  let parties = ()
  parties.push(line-stack(("In re:", meta.debtor.name)))
  parties.push(block(inset: (left: 0.5in), line-stack(("Debtor.",))))
  parties.push(v(single-leading * 2))
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names + (p.designation,)
  }
  parties.push(line-stack(rows))
  block(width: text-width, grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.3in,
    block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), stack(dir: ttb, spacing: single-leading, ..parties)),
    block(inset: (left: 0.1in), {
      line-stack(("Case No. " + meta.debtor.case_number, meta.debtor.chapter))
      v(body-leading)
      line-stack(("Adv. Pro. No. " + meta.adversary_number,))
    }),
  ))
  v(body-leading)
}

/// The negative-notice block: bold, directly below the caption and before the body (L.R. 9014-1(a)).
#let negative-notice-block(meta) = block(width: text-width, {
  set par(leading: single-leading, spacing: single-leading)
  for line in negative-notice(meta) {
    text(weight: "bold", line)
    linebreak()
  }
})

// ---------------------------------------------------------------------------
// Body: numbered paragraphs, lettered list items, headings
// ---------------------------------------------------------------------------

/// Numbered paragraphs (each blank-line-separated chunk); headings and lists are unnumbered.
/// A heading is kept with the chunk after it (`sticky`), so it never ends a page.
#let body-chunks(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Lists (the issues, the relief): lettered by the template; a list may break across pages.
      set par(leading: body-leading)
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else {
      para-counter.step()
      block(width: text-width, {
        set par(leading: body-leading)
        h(para-indent)
        context [#(para-counter.display()). #h(0.2in)]
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block and certificate of service
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(breakable: false, width: text-width, {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  grid(
    columns: (2.6in, 1fr),
    column-gutter: 0.2in,
    [Dated: #meta.date],
    {
      [Respectfully submitted,]
      v(body-leading)
      for (k, g) in meta.signature.groups.enumerate() {
        if k > 0 {
          v(body-leading)
          [-AND-]
          v(body-leading)
        }
        // A signed group: "By: /s/ Name", the name, then the lines under it.
        if "signer" in g {
          line-stack(("By: /s/ " + g.signer, g.signer) + g.lines)
        } else {
          line-stack(g.lines)
        }
      }
      if "role" in meta.signature {
        v(body-leading)
        line-stack(meta.signature.role)
      }
    },
  )
})

#let certificate-block(meta) = block(breakable: false, width: text-width, {
  set par(leading: body-leading, spacing: body-leading)
  align(center, text(weight: "bold", [CERTIFICATE OF SERVICE]))
  v(body-leading)
  block(width: text-width, { h(para-indent); inl(meta.certificate.text) })
  v(body-leading)
  grid(
    columns: (1fr, 1fr),
    column-gutter: 0.3in,
    ..meta.certificate.service.map(g => line-stack(g.lines)),
  )
  v(body-leading)
  grid(
    columns: (2.6in, 1fr),
    column-gutter: 0.2in,
    [],
    line-stack(("By: /s/ " + meta.certificate.signer, meta.certificate.signer) + meta.certificate.lines),
  )
})

#let txwb-motion-brief(meta, body) = {
  let para-counter = counter("paragraph")

  set page(
    paper: "us-letter",
    margin: margin,
    footer: footer-page-number(),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)
  // Prayer and issue items (markdown lists) are lettered (a), (b), ... as in the filed form.
  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in)

  // Headings: level 1 is a centered bold section (unnumbered); level 2 a centered italic sub-heading; level 3 bold.
  show heading.where(level: 1): it => block(width: text-width, sticky: true,
    align(center, text(size: type-size, weight: "bold", it.body)))
  show heading.where(level: 2): it => block(width: text-width, sticky: true,
    align(center, text(size: type-size, style: "italic", it.body)))
  show heading.where(level: 3): it => block(width: text-width, sticky: true,
    text(size: type-size, weight: "bold", style: "italic", it.body))

  court-title(meta)
  caption(meta)
  negative-notice-block(meta)
  v(body-leading)
  align(center, text(weight: "bold", upper(meta.brief_title)))
  v(body-leading)
  if "addressee" in meta {
    block(width: text-width, meta.addressee)
    v(body-leading)
  }
  if "lead_in" in meta {
    block(width: text-width, { h(para-indent); inl(meta.lead_in) })
  }
  body-chunks(body, para-counter)
  v(body-leading)
  signature-block(meta)
  v(body-leading)
  certificate-block(meta)
}
