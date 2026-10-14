// United States Bankruptcy Court, District of Colorado: complaint in an adversary proceeding
// (FRBP 7001, 7008, 7010; Fed. R. Civ. P. 10 as applied by FRBP 7010).
//
// Rule-driven and content-agnostic. Requirement IDs (COB-...) refer to ../README.md, which quotes
// the rule text. No case-specific text, no coordinates measured off the exemplar, no forced line
// breaks. The markdown body is split into blank-line blocks here: a block starting with "#" is a
// heading, a block starting with a list marker is a list, and every other block is a numbered
// paragraph (Fed. R. Civ. P. 10(b)). Metadata comes from the YAML frontmatter of the same file
// (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"         // COB-FORM-002: proportionally spaced, vendored in /fonts.
#let type-size = 13pt                    // COB-FORM-002: 12 point or larger. 13 pt because EB Garamond sets smaller than Times at the same size; see ../README.md.
#let line-pitch = 24pt                   // COB-FORM-003: double spacing (proxy rule, see README).
#let body-leading = 0.54em               // gap between body lines; tuned so the baseline pitch is line-pitch at 13 pt.
#let single-leading = 0.2em              // caption, headings that wrap, block quotations, signature block.
#let margin-top = 1.5in                  // COB-FORM-004 (proxy): 1.5 in top, 1 in elsewhere.
#let margin-other = 1in
#let para-indent = 0.5in
#let footer-size = 11pt

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("cob-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("cob-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// ---------------------------------------------------------------------------
// Caption (COB-FIRST-001: FRBP 7010 and Official Form 416)
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, strong(upper(
    need(meta, "court").map(l => [#l]).join(linebreak())
  )))
}

#let caption-block(left-body, right-body) = grid(
  columns: (1fr, 2.6in),
  column-gutter: 0.3in,
  {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    left-body
  },
  {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    right-body
  },
)

#let caption(meta) = {
  // Debtor block: the bankruptcy case (FRBP 9004(b)(3), Form 416).
  let debtor = need(meta, "debtor")
  caption-block(
    {
      [IN RE:]
      v(single-leading * 2)
      for n in debtor.names { pad(left: 0.4in, [#n]); linebreak() }
      v(single-leading * 2)
      pad(left: 0.8in, [#debtor.at("designation", default: "Debtor.")])
    },
    {
      [Case No. #debtor.case_number]
      linebreak()
      if "chapter" in debtor { inl(debtor.chapter) }
    },
  )

  // Adversary block (FRBP 7010, Form 416A). A blank number is printed as a fill-in line.
  let adv = need(meta, "adversary")
  v(line-pitch * 0.5)
  caption-block(
    {
      for (i, side) in adv.parties.enumerate() {
        for n in side.names { [#n]; linebreak() }
        pad(left: 0.8in, [#side.designation])
        if i < adv.parties.len() - 1 { v(single-leading * 2) }
      }
    },
    {
      [Adv. Proc. No. ]
      if adv.at("case_number", default: "") != "" { adv.case_number } else { [#box(width: 1.6in, repeat[\_])] }
    },
  )
}

#let title-block(meta) = {
  v(line-pitch * 0.5)
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, strong(upper(inl(need(meta, "title")))))
  v(line-pitch * 0.5)
}

// ---------------------------------------------------------------------------
// Consent statement (FRBP 7008(a)): generated from frontmatter, rule wording
// ---------------------------------------------------------------------------

/// `proceeding` is "core" or "non-core"; `consent` is "consents", "does not consent", or "missing".
/// "missing" prints a bracketed flag, so a complaint that omits the statement shows it.
#let consent-text(meta) = {
  let proceeding = need(meta, "proceeding")
  let consent = need(meta, "consent")
  let kind = if proceeding == "core" { "a core proceeding" } else { "a non-core proceeding" }
  let verdict = if consent == "missing" {
    text(weight: "bold", [\[FRBP 7008(a) CONSENT STATEMENT ABSENT FROM THE FILED COMPLAINT\]])
  } else {
    [Plaintiff #consent to the entry of final orders or judgment by the bankruptcy judge.]
  }
  [This proceeding is #kind under 28 U.S.C. § 157. #verdict]
}

// ---------------------------------------------------------------------------
// Signature block (no local rule cited for the form; see ../README.md)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  let mark = sig.at("mark", default: "/s/")
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(columns: (1fr, 3.2in), [Dated: #need(meta, "date")], {
      [Respectfully submitted,]
      v(line-pitch * 0.5)
      for l in sig.at("firm", default: ()) { inl(l); linebreak() }
      v(line-pitch * 0.5)
      // "/s/" sits on the name's line; any other mark (a handwritten signature) gets its own line.
      if mark == "/s/" { [#mark #sig.signer] } else { [#mark]; linebreak(); [#sig.signer] }
      linebreak()
      for l in sig.at("lines", default: ()) { inl(l); linebreak() }
    })
  })
}

// ---------------------------------------------------------------------------
// Headings and lists
// ---------------------------------------------------------------------------

#let heading-tab = 0.5in

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let cob-adversary-complaint(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "debtor", "adversary", "title", "proceeding", "consent", "signature", "date") {
    let _ = need(meta, k)
  }

  // ---- document-wide settings ----
  set page(
    paper: "us-letter",
    margin: (top: margin-top, bottom: margin-other, x: margin-other),
    numbering: "1",
    footer: context align(center, text(size: footer-size, numbering("1", ..counter(page).get()))),
  )
  set document(
    title: need(meta, "title"),
    author: need(meta, "signature").signer,
  )
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: "ascender", bottom-edge: "descender",
  )
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  set heading(numbering: none)
  // Lists are lettered (a), (b), ... as the body's lettered items.
  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.5em, spacing: line-pitch * 0.5)
  set list(indent: 0.5in, body-indent: 0.5em, spacing: line-pitch * 0.5)

  // Headings keep the body size (typst scales heading text by default). Level 1: centered bold
  // capitals; level 2: bold at the margin. Neither is numbered.
  show heading: it => {
    set text(size: type-size)
    if it.level == 1 {
      block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
        align(center, strong(upper(it.body))))
    } else {
      block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
        strong(it.body))
    }
  }

  // Block quotations: single spaced, indented both sides.
  show quote.where(block: true): it => block(
    width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5,
    pad(left: 0.5in, right: 0.5in, par(leading: single-leading, justify: false, it.body)),
  )

  court-title(meta)
  v(line-pitch * 0.5)
  caption(meta)
  title-block(meta)

  // ---- the statement required by FRBP 7008(a), as the first numbered paragraph ----
  let n = 0
  n += 1
  par(first-line-indent: 0pt)[#h(para-indent) #str(n).#h(para-indent) #consent-text(meta)]

  // ---- body blocks: headings, lists and numbered paragraphs ----
  let blocks = md.split(regex("\n\\s*\n")).map(s => s.trim()).filter(s => s != "")
  for blk in blocks {
    if blk.starts-with("#") {
      cmarker.render(blk, raw-typst: false, smart-punctuation: true)
    } else if blk.starts-with("- ") or blk.match(regex("^\\d+\\. ")) != none {
      cmarker.render(blk, raw-typst: false, smart-punctuation: true)
    } else if blk.starts-with(">") {
      cmarker.render(blk, raw-typst: false, smart-punctuation: true)
    } else {
      n += 1
      par(first-line-indent: 0pt, [#h(para-indent) #str(n).#h(para-indent) #inl(blk)])
    }
  }

  signature-block(meta)
}
