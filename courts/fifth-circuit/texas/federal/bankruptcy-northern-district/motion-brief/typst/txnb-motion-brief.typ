// Motion with brief in support, for the U.S. Bankruptcy Court, N.D. Texas (txnb).
// Rules: Fed. R. Bankr. P. 9013 (motions: written, grounds stated with particularity), 7005 and 9014(b) (service),
// 9004(a)-(b) (legible; caption contents); L.B.R. 9013-1(a) (applies L.B.R. 7007-1(a)-(c) and 7007-3),
// L.B.R. 7007-1(b) and (f) (certificate of conference), 7007-1(c) (proposed order as a separate exhibit),
// 7007-1(e) (certificate of service), L.B.R. 7007-2(a) (legible form), (c) (25-page limit, excluding the table
// of contents and authorities), (d) (tables of contents and authorities for a brief over 10 pages).
// See ../README.md. Content-agnostic: every case-specific word comes from the sample's frontmatter.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a stated convention; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // no font rule in the N.D. Tex. bankruptcy rules for motions; the only vendored font
#let type-size = 12pt                   // convention
#let page-w = 8.5in                     // FRBP 9004(a): legible paper; 8 1/2 by 11 inch is the practice
#let page-h = 11in
#let margin = 1in                       // convention
#let body-leading = 1.35em              // double spacing: about 24 pt pitch at 12 pt (convention, see README.md)
#let single-leading = 0.5em             // single spacing for counsel, caption, block quotes and signature
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-left = 3.25in              // width of the party column of the caption

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("txnb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Cover: counsel (top left), court title, caption (Form 416 style), title of the paper
// ---------------------------------------------------------------------------

#let counsel-block(meta) = line-stack(meta.counsel)

#let court-title(meta) = {
  align(center, text(weight: "bold", "UNITED STATES BANKRUPTCY COURT"))
  align(center, text(weight: "bold", "NORTHERN DISTRICT OF TEXAS"))
  if "division" in meta and meta.division != none {
    align(center, text(weight: "bold", upper(meta.division)))
  }
}

/// Form 416 style caption: the debtor and the adversary parties on the left, the case and adversary
/// numbers on the right. "v." separates the adversary parties.
#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.25in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), {
    let rows = ()
    if "debtor" in meta.caption and meta.caption.debtor != none {
      rows += ("In re: " + meta.caption.debtor, "", "Debtor.", "")
    }
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { rows.push("v.") }
      rows += p.names + (p.designation + ".",)
    }
    line-stack(rows)
  }),
  block(inset: (left: 0.1in), {
    line-stack((
      "Chapter " + str(meta.chapter),
      "",
      "Case No. " + meta.case_number,
      "",
      "Adversary Proceeding No. " + meta.adversary_number,
    ))
  }),
)

#let cover(meta) = {
  counsel-block(meta)
  v(24pt)
  court-title(meta)
  v(24pt)
  caption(meta)
  v(24pt)
  align(center, text(weight: "bold", inl(meta.title)))
  v(24pt)
}

// ---------------------------------------------------------------------------
// Body, signature and certificates
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(breakable: false, {
  [Dated: #meta.date]
  v(12pt)
  grid(
    columns: (3in, 1fr),
    [],
    {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      [Respectfully submitted,]
      v(12pt)
      line-stack(meta.signature.firm)
      v(12pt)
      line-stack(("By: /s/ " + meta.signature.signer,) + meta.signature.lines)
    },
  )
})

/// A closing certificate: a centered bold heading and its text (kept on one page with its heading).
#let certificate(title, text-md, signer) = block(breakable: false, {
  v(24pt, weak: true)
  align(center, text(weight: "bold", upper(title)))
  v(12pt, weak: true)
  cmarker.render(text-md.replace("[noindent]", "").trim(), raw-typst: false, smart-punctuation: true, h1-level: 1)
  v(12pt, weak: true)
  align(right, [/s/ #signer])
})

/// Body paragraphs are not numbered (a brief). Each blank-line-separated chunk of markdown is one paragraph,
/// first-line indented, except headings and lists. A chunk starting with "[noindent]" is not indented
/// (block quotes, a short closing line).
/// Numbering is not used, so there is no counter; the template does not add numbers to a brief.
#let brief-body(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Lists are numbered 1., 2., ... as written (relief items in a motion are usually numbered).
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with("[noindent]") {
      cmarker.render(t.slice("[noindent]".len()).trim(), raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else {
      h(para-indent)
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    }
    parbreak()
  }
}

#let txnb-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    footer: context align(center, text(size: 10pt, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)

  // Headings: level 1 is a centered section; level 2 a bold sub-heading; level 3 bold italic.
  show heading.where(level: 1): it => {
    v(24pt, weak: true)
    align(center, text(weight: "bold", upper(it.body)))
    v(12pt, weak: true)
  }
  show heading.where(level: 2): it => {
    v(12pt, weak: true)
    text(weight: "bold", it.body)
    v(12pt, weak: true)
  }
  show heading.where(level: 3): it => {
    v(12pt, weak: true)
    text(weight: "bold", style: "italic", it.body)
    v(12pt, weak: true)
  }

  cover(meta)

  // Tables of contents and authorities (L.B.R. 7007-2(d)) are required for a brief over 10 pages.
  // Only the table of contents is generated (outline of the headings below). The table of authorities
  // is not generated: see README.md, known gaps.
  if "toc" in meta and meta.toc {
    pagebreak()
    align(center, text(weight: "bold", "TABLE OF CONTENTS"))
    v(12pt)
    outline(title: none, depth: 2, indent: 1.5em)
    pagebreak()
  }

  brief-body(body)

  signature-block(meta)

  if "certificate_conference" in meta and meta.certificate_conference != none {
    v(24pt)
    certificate("Certificate of Conference", meta.certificate_conference, meta.signature.signer)
  }
  if "certificate_service" in meta and meta.certificate_service != none {
    v(24pt)
    certificate("Certificate of Service", meta.certificate_service, meta.signature.signer)
  }
}
