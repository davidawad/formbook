// Motion with memorandum for the United States Bankruptcy Court, District of Rhode Island (rib), one filed document.
// Rules: FRBP 9013 (motions: written, with the grounds and the relief sought); LBR 9013-1(a) (points and
// authorities in or with the paper, citing the Code, the Rules, or other authority), 9013-1(b) (caption with case,
// adversary number and chapter; double spaced; 8 1/2 x 11; text at least 11 point; footnotes at least 10 point;
// memoranda limited to 20 pages absent leave); LBR 1005-1(a)-(c) (caption on every paper and on the signature
// page; signer's identification; the response-time language of 1005-1(d)(1) on every motion except those in
// 1005-1(d)(2)); LBR 7007-1 (papers in adversary proceedings follow LBR 1005-1); FRBP 7005 / FRCP 5 (service;
// certificate of service). See ../README.md for each rule's text and date.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif"          // Times New Roman substitute per docs/FONTS.md, vendored in fonts/liberation-serif; no system font is used
#let type-size = 12pt                     // LBR 9013-1(b) and 1005-1(b): text at least 11 point
#let footnote-size = 10pt                 // LBR 9013-1(b) and 1005-1(b): footnotes at least 10 point
#let body-leading = 1.345em               // double spacing: the Liberation Serif line box is 0.655em, so 2em = 24 pt pitch at 12 pt
#let single-leading = 0.5em               // single spacing: caption, quotations, signature, certificate (exempt under 1005-1(b))
#let para-indent = 0.5in
#let page-w = 8.5in                       // LBR 9013-1(b) and 1005-1(b): 8 1/2 x 11 inch paper
#let page-h = 11in
#let margin = 1in                         // not set by the LBRs; the usual 1 inch on every side
#let text-width = page-w - 2 * margin
#let caption-left = 3.3in
#let court-name = ("UNITED STATES BANKRUPTCY COURT", "DISTRICT OF RHODE ISLAND")   // court-level text, not case text
// LBR 1005-1(d)(1): the response-time language for a motion. Verbatim from the rule text; the court address is part of it.
#let response-default = "Within fourteen (14) days after service, if served electronically, as evidenced by the certification, and an additional three (3) days pursuant to Fed. R. Bank. P. 9006(f) if served by mail or other excepted means specified, any party against whom such paper has been served, or any other party who objects to the relief sought, shall serve and file an objection or other appropriate response to said paper with the Bankruptcy Court Clerk's Office, 380 Westminster Street, 6th Floor, Providence, RI 02903, (401) 626-3100. If no objection or other response is timely filed, the paper will be deemed unopposed and will be granted unless: (1) the requested relief is forbidden by law; (2) the requested relief is against public policy; or (3) in the opinion of the Court, the interest of justice requires otherwise."

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("rib-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names, names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Single-spaced lines: one item per line; the stack keeps single spacing.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

/// A block that is kept whole, so it never breaks across a page.
#let keep-with(c) = block(breakable: false, width: text-width, c)

// ---------------------------------------------------------------------------
// Caption and title (repeated on the memorandum's first page, as the filing does)
// ---------------------------------------------------------------------------

#let court-title() = {
  for line in court-name {
    align(center, text(weight: "bold", line))
  }
}

#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.25in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), {
    line-stack(("IN RE:",))
    v(single-leading)
    line-stack(meta.in_re)
    v(single-leading * 0.5)
    align(right, line-stack((meta.debtor_designation,)))
    v(single-leading * 2)
    {
      let rows = ()
      for (k, p) in meta.caption.parties.enumerate() {
        if k > 0 { rows.push("v.") }
        rows += p.names + (p.designation,)
      }
      line-stack(rows)
    }
  }),
  block(inset: (left: 0.1in), {
    line-stack((
      "Chapter " + meta.chapter,
      "Bankruptcy Case No. " + meta.case_number,
      "",
      "Adversary Proceeding No. " + meta.adversary_number,
    ))
  }),
)

#let titled-caption(meta, title) = {
  court-title()
  v(body-leading)
  caption(meta)
  v(body-leading)
  align(center, text(weight: "bold", upper(title)))
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Signature, response language, certificate of service
// ---------------------------------------------------------------------------

/// The signature block: the case line (LBR 1005-1(a)), "Respectfully submitted", the signer, and any "Of Counsel"
/// lines. It is kept whole, so the names never separate from the signature.
#let signature-block(meta, sig, of-counsel) = keep-with(block(width: text-width, {
  // LBR 1005-1(a): the bankruptcy case name, number and chapter appear on the signature page too.
  set par(leading: single-leading, spacing: 0pt, justify: false)
  text(size: type-size, [In re #meta.in_re.join(", "), Debtor; Chapter #meta.chapter; Bankruptcy Case No. #meta.case_number; Adversary Proceeding No. #meta.adversary_number])
  v(body-leading)
  grid(
    columns: (2.8in, 1fr),
    column-gutter: 0.2in,
    if "date" in meta { [Dated: #meta.date] } else { [] },
    {
      [Respectfully submitted,]
      v(single-leading * 2)
      line-stack((sig.client, sig.by))
      v(single-leading * 2)
      line-stack(("/s/ " + sig.signer, sig.signer))
      v(single-leading)
      line-stack(sig.firm + ("RI Bar No. " + sig.bar_id,) + sig.lines)
    },
  )
  if of-counsel != none {
    v(body-leading)
    line-stack(of-counsel)
  }
}))

#let certificate-block(meta) = {
  let c = meta.certificate
  keep-with(block(width: text-width, {
    align(center, text(weight: "bold", "CERTIFICATE OF SERVICE"))
    v(body-leading)
    set par(leading: body-leading, spacing: body-leading)
    h(para-indent)
    [I hereby certify that on #c.date, I electronically filed the within #meta.title with the Clerk of the Bankruptcy Court for the District of Rhode Island using the CM/ECF System. The following participant has received notice electronically:]
    v(single-leading)
    set par(leading: single-leading, spacing: 0pt)
    pad(left: 0.5in, line-stack(c.recipients))
    v(body-leading)
    align(right, block(width: 3in, line-stack(("/s/ " + meta.signature.signer, meta.signature.signer))))
  }))
}

// ---------------------------------------------------------------------------
// Body: paragraphs (unnumbered: a motion and its memorandum are not numbered), headings, lists, quotations
// ---------------------------------------------------------------------------

/// Footnote definitions (`[^key]: text`) by key. cmarker resolves a reference only within the text it renders,
/// so each chunk that refers to a footnote is rendered together with that footnote's definition.
#let footnote-defs(items) = {
  let defs = (:)
  for c in items {
    let m = c.trim().match(regex("^\\[\\^([^\\]]+)\\]:"))
    if m != none { defs.insert(m.captures.at(0), c.trim()) }
  }
  defs
}

/// Body chunks. A chunk is one blank-line-separated piece of markdown:
/// - a heading: `#` centered bold caps, `##` centered bold, `###` bold italic; sticky, so it stays with the next chunk;
/// - a list (`1.` items): numbered 1., 2., ...;
/// - a block quotation (`>`): single spaced, indented;
/// - a paragraph: first line indented, double spaced;
/// - a footnote definition: rendered with the chunk that refers to it.
#let chunks(body) = {
  let items = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let defs = footnote-defs(items)
  for c in items {
    let t = c.trim()
    if t.match(regex("^\\[\\^[^\\]]+\\]:")) != none { continue }
    let keys = t.matches(regex("\\[\\^([^\\]]+)\\]")).map(m => m.captures.at(0)).filter(k => k in defs)
    let full = ((t,) + keys.map(k => defs.at(k))).join("\n\n")
    if t.starts-with("#") {
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^\\d+\\.[ \\t]")) {
      set par(leading: body-leading, spacing: body-leading)
      set enum(numbering: "1.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
      cmarker.render(full, raw-typst: false, smart-punctuation: true, h1-level: 1)
      v(body-leading)
    } else if t.starts-with(">") {
      set par(leading: single-leading, spacing: body-leading * 0.5)
      pad(left: 0.75in, right: 0.5in, cmarker.render(full, raw-typst: false, smart-punctuation: true, h1-level: 1))
      v(body-leading * 0.5)
    } else {
      set par(leading: body-leading, spacing: body-leading)
      h(para-indent)
      cmarker.render(full, raw-typst: false, smart-punctuation: true, h1-level: 1)
    }
  }
}

#let rib-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    footer: context align(center, text(size: 11pt, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)
  // Footnotes: 10 point and single spaced (LBR 9013-1(b)); a footnote may not hold body text.
  show footnote.entry: set text(size: footnote-size)
  show footnote.entry: set par(leading: single-leading, spacing: 0pt)

  // A heading is sticky: it stays on the page of the chunk after it, and that chunk may still break.
  show heading.where(level: 1): it => block(width: text-width, breakable: false, sticky: true, {
    v(body-leading * 0.5, weak: true)
    align(center, text(size: type-size, weight: "bold", upper(it.body)))
  })
  show heading.where(level: 2): it => block(width: text-width, breakable: false, sticky: true, {
    v(body-leading * 0.5, weak: true)
    align(center, text(size: type-size, weight: "bold", it.body))
  })
  show heading.where(level: 3): it => block(width: text-width, breakable: false, sticky: true, {
    v(body-leading * 0.5, weak: true)
    text(size: type-size, weight: "bold", style: "italic", it.body)
  })

  // The sample's body has up to two parts, split by a line holding only `---`: the motion, then the memorandum.
  let parts = body.split(regex("\\r?\\n---[ \\t]*\\r?\\n"))
  let motion = parts.at(0)
  let memo = if parts.len() > 1 { parts.at(1) } else { none }

  // Part 1: the motion. Caption, title, the motion's paragraphs, the response-time language, signature.
  titled-caption(meta, meta.title)
  chunks(motion)
  // The response language and the signature are kept together, so a signature never stands alone on a page.
  keep-with({
    if meta.at("response", default: "14-days") != "none" {
      let text-response = meta.at("response_text", default: response-default)
      // LBR 1005-1(d)(1): the response language may be single or double spaced, in at least 11 point type.
      set par(leading: single-leading, spacing: 0pt)
      h(para-indent)
      text-response
      v(body-leading)
    }
    signature-block(meta, meta.signature, none)
  })

  // Part 2: the memorandum starts on a new page with the caption repeated and its own title.
  if memo != none {
    pagebreak()
    titled-caption(meta, meta.memorandum_title)
    chunks(memo)
    signature-block(meta, meta.signature, meta.at("of_counsel", default: none))
  }

  if "certificate" in meta and meta.certificate != none {
    pagebreak()
    certificate-block(meta)
  }
}
