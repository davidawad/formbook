// Motion with integrated memorandum, United States Bankruptcy Court, Southern District of Texas (txsb).
// Rules (see ../README.md): FRBP 9004(a)-(b) (legibility, caption), FRBP 9013 (written motion stating its
// grounds and the relief), FRCP 10(b) (numbered paragraphs), BLR 7007-1 and 9013-1 (motions in adversary
// proceedings: title, the notice below the title, emergency motions, hearing, certificate of service, proposed
// order), LR10.1 (caption), LR10.2 (8 1/2 x 11, double spaced, paginated).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif"   // no typeface is set by the S.D. Tex. rules; Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                   // no point size is set by the S.D. Tex. rules; 12 pt is the usual minimum
#let page-w = 8.5in                     // LR10.2: 8 1/2 by 11 inch paper
#let page-h = 11in
#let margin = 1in                       // not set by the rules; a 1 inch convention (see README.md)
#let text-width = page-w - 2 * margin
#let body-leading = 1.345em             // LR10.2 double spacing: 0.655em line box + 1.345em = 2.0em, 24 pt at 12 pt
#let single-leading = 0.495em            // caption, counsel and signature blocks
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let caption-left = 3.25in              // width of the party column of the caption

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("txsb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, bold, italics).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Plain lines, single spaced, no markdown (caption and signature text is set as written).
#let plain-lines(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => text(i)))
}

/// Blank-line-separated chunks of the markdown body.
#let body-chunks(body) = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")

// ---------------------------------------------------------------------------
// Cover: court, division, caption, title
// ---------------------------------------------------------------------------

/// Debtor names, with the debtor footnote (if any) on the last name line.
#let debtor-lines(c) = {
  let names = c.debtor_names
  let out = names.slice(0, names.len() - 1).map(n => text(n))
  let last = text(names.last())
  if "debtor_footnote" in c {
    last = last + footnote[#c.debtor_footnote]
  }
  out.push(last)
  out
}

/// Right column of the caption: chapter, case number, adversary number.
#let right-rows(meta) = {
  let rows = (meta.chapter, "", meta.case_number)
  if "joint_admin" in meta { rows.push(meta.joint_admin) }
  rows + ("", "", meta.adversary_number)
}

#let caption(c, meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.25in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 12pt, bottom: 10pt), stack(
    dir: ttb,
    spacing: single-leading,
    text("In re:"),
    ..debtor-lines(c),
    pad(left: 1.25in, text(c.debtor_designation)),
    v(body-leading),
    ..c.plaintiff_names.map(n => text(n)),
    pad(left: 1.25in, text(c.plaintiff_designation)),
    pad(left: 0.5in, text("v.")),
    ..c.defendant_names.map(n => text(n)),
    pad(left: 1.25in, text(c.defendant_designation)),
  )),
  block(inset: (left: 0.1in), plain-lines(right-rows(meta))),
)

#let cover(meta) = {
  align(center)[
    #set par(leading: single-leading, spacing: 0pt)
    #text(weight: "bold")[IN THE UNITED STATES BANKRUPTCY COURT] \
    #text(weight: "bold")[FOR THE SOUTHERN DISTRICT OF TEXAS] \
    #text(weight: "bold")[#upper(meta.division)]
  ]
  v(body-leading)
  caption(meta.caption, meta)
  v(body-leading)
  block(width: text-width, below: body-leading)[
    #set par(leading: single-leading, spacing: 0pt)
    #align(center)[#text(weight: "bold")[#upper(meta.title)]]
  ]
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// Numbered paragraphs (FRCP 10(b)). Each blank-line-separated chunk that is neither a heading nor a list is
/// one numbered paragraph; headings and lists are not numbered. A heading is sticky: it stays with the
/// paragraph after it and never ends a page.
#let allegations(body) = {
  let n = 0
  let chunks = body-chunks(body)
  for (i, c) in chunks.enumerate() {
    if c.starts-with("#") {
      cmarker.render(c, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if c.starts-with(regex("^\\d+\\.[ \\t]")) {
      block(width: text-width, below: body-leading)[
        #set par(leading: body-leading)
        #set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
        #cmarker.render(c, raw-typst: false, smart-punctuation: true, h1-level: 1)
      ]
    } else if c.starts-with(">") {
      // An unnumbered paragraph (a WHEREFORE or prayer clause the filing does not number): markdown "> text".
      block(width: text-width, below: body-leading)[
        #set par(leading: body-leading)
        #h(para-indent)#inl(c.slice(1).trim())
      ]
    } else {
      n += 1
      // The last paragraph stays on the page of the signature block, so a signature never stands alone.
      block(width: text-width, below: body-leading, sticky: i == chunks.len() - 1)[
        #set par(leading: body-leading)
        #h(para-indent)#str(n).#h(0.3in)#inl(c)
      ]
    }
  }
}

#let signature(meta) = block(breakable: false, width: text-width, above: body-leading)[
  #grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.25in,
    [Dated: #meta.dated],
    [
      #set par(leading: single-leading, spacing: 0pt, justify: false)
      Respectfully submitted,
      #v(body-leading)
      #for (k, b) in meta.signature.blocks.enumerate() [
        #if k > 0 [#v(body-leading) -and- #v(body-leading)]
        #plain-lines(b)
      ]
    ],
  )
]

// ---------------------------------------------------------------------------
// BLR 9013-1 notices. The text of the rule is fixed here; the case words come from the sample.
// ---------------------------------------------------------------------------

/// BLR 9013-1(b): required immediately below the title of every pleading that seeks an order (verbatim).
#let negative-notice = (
  "This motion seeks an order that may adversely affect you. If you oppose the motion, you should immediately contact the moving party to resolve the dispute. If you and the moving party cannot agree, you must file a response and send a copy to the moving party. You must file and serve your response within 21 days of the date this was served on you. Your response must state why the motion should not be granted. If you do not file a timely response, the relief may be granted without further notice to you. If you oppose the motion and have not reached an agreement, you must attend the hearing. Unless the parties agree otherwise, the court may consider evidence at the hearing and may decide the motion at the hearing.",
  "Represented parties should act through their attorney.",
)

/// BLR 9013-1(i): added to the notice of an emergency motion, which must also have "Emergency" in its title (verbatim).
#let emergency-notice = "Emergency relief has been requested. If the Court considers the motion on an emergency basis, then you will have less than 21 days to answer. If you object to the requested relief or if you believe that the emergency consideration is not warranted, you should file an immediate response."

/// The notice block: BLR 9013-1(b) always; BLR 9013-1(i) for an emergency motion; BLR 9013-1(c) hearing line
/// when the judge's web page allows self-calendaring.
#let notice-block(meta) = block(width: text-width, below: body-leading)[
  #set par(leading: single-leading, spacing: single-leading, justify: false)
  #for p in negative-notice [#p #v(single-leading)]
  #if "emergency" in meta and meta.emergency [
    #v(single-leading)
    #meta.relief_by
    #v(single-leading)
    #emergency-notice
  ]
  #if "hearing" in meta [
    #v(single-leading)
    There will be a hearing on this motion on #meta.hearing.date at #meta.hearing.time in courtroom #meta.hearing.courtroom, #meta.hearing.address.
  ]
]

/// BLR 9013-1(f): certificate of service, filed with the motion. The wording is the ECF service form; the date
/// and signer come from the sample.
#let certificate(meta) = if "certificate" in meta {
  let c = meta.certificate
  block(breakable: false, width: text-width, above: body-leading)[
    #align(center)[#text(weight: "bold")[CERTIFICATE OF SERVICE]]
    #v(body-leading)
    #block(width: text-width)[
      #set par(leading: body-leading)
      #h(para-indent)I certify that on #c.date, I caused a copy of the foregoing document to be served by the Electronic Case Filing System for the United States Bankruptcy Court for the Southern District of Texas.
    ]
    #v(body-leading)
    #pad(left: caption-left)[#plain-lines(c.signature)]
  ]
}

#let txsb-motion-brief(meta, body) = {
  set page(paper: "us-letter", margin: margin, numbering: "1")
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 centered bold; level 2 centered bold (count headings); level 3 bold, left (A., B., ...).
  show heading.where(level: 1): it => block(sticky: true, width: text-width, above: 0pt, below: body-leading,
    align(center, text(size: type-size, weight: "bold", it.body)))
  show heading.where(level: 2): it => block(sticky: true, width: text-width, above: 0pt, below: body-leading,
    align(center, text(size: type-size, weight: "bold", it.body)))
  show heading.where(level: 3): it => block(sticky: true, width: text-width, above: 0pt, below: body-leading,
    text(size: type-size, weight: "bold", it.body))

  cover(meta)
  notice-block(meta)

  // Unnumbered lead-in paragraph, if the filing has one.
  if "lead_in" in meta {
    block(width: text-width, below: body-leading)[
      #set par(leading: body-leading)
      #h(para-indent)#inl(meta.lead_in)
    ]
  }

  allegations(body)
  signature(meta)
  certificate(meta)
}
