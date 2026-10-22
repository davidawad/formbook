// Motion with incorporated argument for the U.S. Bankruptcy Court, Western District of Texas (txwb).
// Rules: Fed. R. Bankr. P. 9013 (motions: in writing, stating the grounds with particularity); W.D. Tex. L.R. 9014-1(a)
// (negative-notice form language, bold, at least 12 pt, immediately below the caption and before the body);
// Fed. R. Bankr. P. 9004(a) (legible). See ../README.md. Content-agnostic: case words come from the sample's frontmatter.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a stated convention; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                   // L.R. 9014-1(a) names 12 pt for the notice; the body is set at the same size
#let margin = 1in                       // convention; the exemplar's margins are about one inch
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let num-box = 0.4in                    // the paragraph number's box after it: the text starts 0.9 in from the margin
#let item-indent = 0.5in                // list items: the letter half an inch in
#let item-box = 0.6in                   // the letter's box: the item text hangs 1.1 in from the margin
#let caption-left = 3.4in               // width of the parties column of the caption
#let caption-gutter = 0.3in             // between the parties column and the case block
#let caption-inset = 10pt               // the parties column's text stands off its right rule
#let caption-pad = 8pt                  // the bottom rule stands off the last party line
#let right-inset = 0.1in                // the case block stands off the gutter
#let debtor-indent = 0.5in              // "Debtor." under the debtor's name
#let sig-left = 2.6in                   // signature grid: the "Dated" column, a gutter, the signature column
#let sig-gutter = 0.2in
#let sig-gap = 10pt                     // between the groups of the signature column
#let service-gutter = 0.3in             // between the two columns of the service list

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // a single line: 1.15 x the type size; caption, notice, signature, service list
#let pitch-double = 24pt                // the body: double spacing at the template's 24 pt pitch
#let party-gap = pitch-single           // a single line between the debtor block and the adversary parties

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
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One line block (a paragraph of its own) at a pitch, with explicit space above it.
#let line-block(above: 0pt, below: 0pt, pitch: pitch-single, indent: 0pt, body) = block(width: 100%, above: above,
  below: below, pad(left: indent, {
    set text(..edges(pitch))
    set par(first-line-indent: 0pt)
    body
  }))

/// A body paragraph at the double pitch: unnumbered (first-line indent) or numbered (the number in a box after the
/// first-line indent, the text after it). `keep`: kept whole on the page of the block after it (the last paragraph
/// stays with the signature block).
#let body-par(num, content, keep: false, above: 0pt) = block(width: 100%, above: above, below: 0pt, sticky: keep,
  breakable: not keep, if num == none {
  par(first-line-indent: (amount: para-indent, all: true), content)
} else {
  par(first-line-indent: (amount: para-indent, all: true), [#box(width: num-box, [#num.])#content])
})

// ---------------------------------------------------------------------------
// Caption: court title, parties (left), case numbers (right)
// ---------------------------------------------------------------------------

/// The court's name, centered and bold, on lines of the body pitch.
#let court-title(meta) = {
  let lines = ("IN THE UNITED STATES BANKRUPTCY COURT", "FOR THE WESTERN DISTRICT OF TEXAS")
  if "division" in meta and meta.division != none { lines.push(upper(meta.division) + " DIVISION") }
  for l in lines { line-block(pitch: pitch-double, align(center, text(weight: "bold", l))) }
}

#let caption(meta) = block(width: 100%, above: pitch-single, below: 0pt, grid(
  columns: (caption-left, 1fr),
  column-gutter: caption-gutter,
  block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-inset, bottom: caption-pad), {
    // The debtor block (In re), then the adversary parties: each side's names, then its designation.
    line-block("In re:")
    line-block(inl(meta.debtor.name))
    line-block(indent: debtor-indent, "Debtor.")
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { line-block("v.") }
      for (j, n) in p.names.enumerate() { line-block(above: if k == 0 and j == 0 { party-gap } else { 0pt }, inl(n)) }
      line-block(inl(p.designation))
    }
  }),
  pad(left: right-inset, {
    line-block(inl("Case No. " + meta.debtor.case_number))
    line-block(inl(meta.debtor.chapter))
    line-block(above: pitch-single, inl("Adv. Pro. No. " + meta.adversary_number))
  }),
))

/// The negative-notice block: bold, directly below the caption and before the body (L.R. 9014-1(a)); each
/// sentence of the rule a single-spaced paragraph of its own.
#let negative-notice-block(meta) = block(width: 100%, above: pitch-double, below: 0pt, {
  for s in negative-notice(meta) { line-block(text(weight: "bold", inl(s))) }
})

// ---------------------------------------------------------------------------
// Body: numbered paragraphs, lettered list items, headings
// ---------------------------------------------------------------------------

/// Each blank-line-separated chunk is a heading, a list (lettered (a), (b), ...) or a numbered paragraph.
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph content
/// recurses without end in typst 0.15.
#let body-chunks(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let n = 0
  for (i, c) in chunks.enumerate() {
    let t = c.trim()
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Lists (the issues, the relief): lettered by the template, the letter half an inch in; a list may break
      // across pages.
      pad(left: item-indent, md(t))
    } else {
      n += 1
      body-par(n, md(t), keep: i == chunks.len() - 1)
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block and certificate of service
// ---------------------------------------------------------------------------

/// Lines of a column, the first `gap` below the line before.
#let lines-block(lines, gap: 0pt) = for (i, l) in lines.enumerate() {
  line-block(above: if i == 0 { gap } else { 0pt }, inl(l))
}

/// "Dated:" at the left; "Respectfully submitted," each signed group ("By: /s/ Name", the name and the lines under
/// it) and the role at the right, the groups a gap apart, -AND- between them. It never breaks across a page.
#let signature-block(meta) = block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
  let sig = meta.signature
  grid(
    columns: (sig-left, 1fr),
    column-gutter: sig-gutter,
    line-block(inl("Dated: " + meta.date)),
    {
      line-block[Respectfully submitted,]
      for (k, g) in sig.groups.enumerate() {
        if k > 0 { line-block(above: sig-gap, "-AND-") }
        // A signed group: "By: /s/ Name", the name, then the lines under it.
        let lines = if "signer" in g { ("By: /s/ " + g.signer, g.signer) + g.lines } else { g.lines }
        lines-block(lines, gap: sig-gap)
      }
      lines-block(sig.at("role", default: ()), gap: sig-gap)
    },
  )
})

/// Certificate of service (L.R. 9013-1(c)): a centered bold heading, the certifying paragraph, the service list in
/// two columns and the signer under the signature column. It never breaks across a page.
#let certificate-block(meta) = if "certificate" in meta {
  let c = meta.certificate
  block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
    line-block(pitch: pitch-double, align(center, text(weight: "bold", "CERTIFICATE OF SERVICE")))
    body-par(none, inl(c.text), above: pitch-single)
    block(width: 100%, above: pitch-single, below: 0pt, grid(
      columns: (1fr, 1fr),
      column-gutter: service-gutter,
      row-gutter: pitch-single,
      ..c.service.map(g => lines-block(g.lines)),
    ))
    block(width: 100%, above: pitch-single, below: 0pt, pad(left: sig-left + sig-gutter,
      lines-block(("By: /s/ " + c.signer, c.signer) + c.at("lines", default: ()))))
  })
}

#let txwb-motion-brief(meta, body) = {
  // Page numbers centered, arabic, on every page; the number in a single-spaced line box, so it sits at the same
  // place on every page (Word's footer).
  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch; lists as a label box (item-box) with the text hanging.
  show: xengine.with(pitch: pitch-double, list-indent: item-box)
  // A doubled sign stays with its number ("§§ 24.005"): xengine binds one sign, which leaves a break between the
  // two (the docx filter binds the same).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // Issue and relief items (markdown lists) are lettered (a), (b), ... as in the filed form.
  set enum(numbering: "(a)")

  // Headings at the body size and pitch: level 1 a centered bold section (unnumbered); level 2 a centered bold italic
  // sub-heading; level 3 bold italic at the margin. No space of their own (the double pitch sets them off);
  // sticky, so a heading never ends a page.
  show heading: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    let b = if it.level == 1 { align(center, text(weight: "bold", it.body)) } else if it.level == 2 {
      align(center, text(weight: "bold", style: "italic", it.body))
    } else { text(weight: "bold", style: "italic", it.body) }
    block(sticky: true, width: 100%, above: 0pt, below: 0pt, b)
  }

  court-title(meta)
  caption(meta)
  negative-notice-block(meta)
  // The title of the motion: bold capitals, centered, at the body pitch.
  line-block(pitch: pitch-double, above: pitch-double, below: pitch-single,
    align(center, text(weight: "bold", upper(meta.brief_title))))
  if "addressee" in meta { line-block(pitch: pitch-double, below: pitch-single, inl(meta.addressee)) }
  if "lead_in" in meta { body-par(none, inl(meta.lead_in)) }
  body-chunks(body)
  signature-block(meta)
  certificate-block(meta)
}
