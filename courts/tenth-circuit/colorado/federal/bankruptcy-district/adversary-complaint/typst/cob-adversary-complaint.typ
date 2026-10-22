// United States Bankruptcy Court, District of Colorado: complaint in an adversary proceeding
// (FRBP 7001, 7008, 7010; Fed. R. Civ. P. 10 as applied by FRBP 7010).
//
// Rule-driven and content-agnostic. Requirement IDs (COB-...) refer to ../README.md and ../../rules.md, which quote
// the rule text. No case-specific text, no coordinates measured off the exemplar, no forced line breaks. The markdown
// body is split into blank-line blocks here: a block starting with "#" is a heading, "~ " centered single lines (a
// claim's sub-caption), "^" an unnumbered paragraph, "1. " or "- " a list, "> " a quotation, and every other block a
// numbered paragraph (Fed. R. Civ. P. 10(b)). Metadata comes from the YAML frontmatter of the same file (schema:
// ../README.md).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")    // COB-FORM-001: no LBR names a face; Times New Roman, the house standard (vendored metric twin)
#let type-size = 12pt                    // COB-FORM-001: no LBR sets a size; 12 point, the D.C.COLO.LCivR 10.1 proxy (README).
#let margin-top = 1.5in                  // proxy D.C.COLO.LCivR 10.1: 1.5 in top, 1 in elsewhere (README).
#let margin-other = 1in
#let para-indent = 0.5in                 // first-line indent; the paragraph number in a box of this width after it
#let list-indent = 0.5in                 // list items: the label half an inch in
#let list-label = 0.4in                  // and in a box of 0.4 in, the text hanging after it
#let quote-indent = 0.5in                // quotations: this far in on both sides
#let caption-right = 2.6in               // the caption's case column
#let caption-gutter = 0.3in              // between the party column and the case column
#let name-indent = 0.4in                 // the debtor's names under "IN RE:"
#let designation-indent = 0.8in          // "Debtor.", "Plaintiffs,", "v.", "Defendant." under the names
#let signature-column = 3.2in            // the signature column at the right; "Dated:" at the left margin
#let fill-line = 18                      // an unassigned adversary number: a fill-in line of this many underscores
#let footer-size = 11pt                  // the page number

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt                 // proxy D.C.COLO.LCivR 10.1: double spacing (2 x 12 pt)
#let pitch-single = 13.8pt               // single spacing (1.15 x 12 pt): court title, caption, title, headings,
                                         // sub-captions, quotations, signature, page number

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

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it. An empty line keeps
/// its height.
#let line-block(above: 0pt, below: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: below,
  height: if body == "" or body == [] { pitch-single } else { auto }, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: left, if type(body) == str { inl(body) } else { body })
})

// ---------------------------------------------------------------------------
// Caption (COB-CONT-001, -002: FRBP 7010 and Official Form 416D, the adversary caption; FRBP 9004(b))
// ---------------------------------------------------------------------------

/// A caption block, never split: the party column at the left, the case column beside it.
#let caption-block(above, left, right) = block(width: 100%, above: above, below: 0pt, breakable: false,
  grid(columns: (1fr, caption-right), column-gutter: caption-gutter, left.join(), right.join()))

/// The court title, a single line below it the debtor block, a single line below that the adversary block, and the
/// title of the paper a single line above and below.
#let caption(meta) = {
  for l in need(meta, "court") { line-block(align(center, strong(upper(inl(l))))) }

  // Debtor block: the bankruptcy case (FRBP 9004(b)(3), Form 416D).
  let debtor = need(meta, "debtor")
  let left = (line-block[IN RE:], line-block(""))
  for n in debtor.names { left.push(line-block(left: name-indent, n)) }
  left += (line-block(""), line-block(left: designation-indent, debtor.at("designation", default: "Debtor.")))
  let right = (line-block[Case No. #debtor.case_number],)
  if "chapter" in debtor { right.push(line-block(debtor.chapter)) }
  caption-block(pitch-single, left, right)

  // Adversary block (FRBP 7010, Form 416D): each side's names and designation, a blank line between the sides. An
  // unassigned number is printed as a fill-in line.
  let adv = need(meta, "adversary")
  let left = ()
  for (i, side) in adv.parties.enumerate() {
    if i > 0 { left.push(line-block("")) }
    for n in side.names { left.push(line-block(n)) }
    left.push(line-block(left: designation-indent, side.designation))
  }
  let num = adv.at("case_number", default: "")
  let num = if num == none or num == "" { "_" * fill-line } else { num }
  caption-block(pitch-single, left, (line-block[Adv. Proc. No. #num],))

  line-block(above: pitch-single, below: pitch-single, align(center, strong(inl(need(meta, "title")))))
}

// ---------------------------------------------------------------------------
// Consent statement (FRBP 7008: COB-CONT-003): generated from frontmatter, rule wording
// ---------------------------------------------------------------------------

/// `proceeding` is "core" or "non-core"; `consent` is "consents", "does not consent", or "missing".
/// "missing" prints a bracketed flag, so a complaint that omits the statement shows it.
#let consent-text(meta) = {
  let proceeding = need(meta, "proceeding")
  let consent = need(meta, "consent")
  let kind = if proceeding == "core" { "a core proceeding" } else { "a non-core proceeding" }
  let verdict = if consent == "missing" {
    strong[\[FRBP 7008(a) CONSENT STATEMENT ABSENT FROM THE FILED COMPLAINT\]]
  } else {
    [Plaintiff #consent to the entry of final orders or judgment by the bankruptcy judge.]
  }
  [This proceeding is #kind under 28 U.S.C. § 157. #verdict]
}

// ---------------------------------------------------------------------------
// Body (COB-CONT-004: numbered paragraphs, FRCP 10(b) via FRBP 7010)
// ---------------------------------------------------------------------------

/// A heading, single-spaced, a single line above and below it, sticky so it never ends a page: level 1 centered bold
/// capitals, deeper levels bold at the margin.
#let heading-block(level, c) = block(width: 100%, above: pitch-single, below: pitch-single, sticky: true, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if level == 1 { align(center, strong(upper(inl(c)))) } else { strong(inl(c)) }
})

/// A body paragraph at the double pitch: the first-line indent, then (when numbered) the number in a box of the
/// paragraph indent and the text after it. `keep`: kept whole on the page of the block after it (the last block stays
/// with the signature).
#let body-par(num, content, keep: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: keep,
  breakable: not keep,
  par(first-line-indent: (amount: para-indent, all: true),
    if num == none { content } else { [#box(width: para-indent, [#num.])#content] }))

/// A list item at the double pitch: the label half an inch in, in a box of list-label, the text hanging after it.
#let list-item(label, content, keep: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: keep,
  breakable: not keep, pad(left: list-indent,
    par(first-line-indent: 0pt, hanging-indent: list-label, [#box(width: list-label, label)#content])))

#let letter(i) = "abcdefghijklmnopqrstuvwxyz".at(i)

#let render-body(meta, md) = {
  let blocks = md.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(s => s.trim()).filter(s => s != "")
  let n = 0
  let consent-done = false
  for (k, blk) in blocks.enumerate() {
    let last = k == blocks.len() - 1
    // The FRBP 7008(a) statement is paragraph 1. It follows the unnumbered opening paragraphs ("Plaintiffs ... state
    // and allege as follows") and comes before the first other block.
    if not consent-done and not blk.starts-with("^") {
      consent-done = true
      n += 1
      body-par(n, consent-text(meta))
    }
    let h = blk.match(regex("^(#+)\\s+(.*)$"))
    if h != none {
      heading-block(h.captures.at(0).len(), h.captures.at(1))
    } else if blk.starts-with("~ ") {
      // Centered, single-spaced, unnumbered lines (a claim's sub-caption), one per source line, kept with the text
      // after them, a single line below.
      let lines = blk.slice(2).split("\n").map(l => l.trim())
      for (i, l) in lines.enumerate() {
        block(width: 100%, above: 0pt, below: if i == lines.len() - 1 { pitch-single } else { 0pt }, sticky: true,
          line-block(align(center, inl(l))))
      }
    } else if blk.starts-with("^") {
      // Unnumbered paragraph (the opening "Plaintiffs ... state as follows", the reservation, prayer items).
      body-par(none, inl(blk.slice(1).trim()), keep: last)
    } else if blk.starts-with("- ") or blk.match(regex("^\\d+\\. ")) != none {
      // A list: "1." items lettered (a), (b), ... by position, "- " items bulleted; one item per source line.
      let items = ()
      for l in blk.split("\n") {
        let m = l.match(regex("^\\s*(\\d+\\.|-)\\s+(.*)$"))
        if m != none or items.len() == 0 { items.push(l) } else { items.push(items.pop() + " " + l.trim()) }
      }
      for (i, it) in items.enumerate() {
        let lab = if it.trim().starts-with("-") { [•] } else { [(#letter(i))] }
        list-item(lab, inl(it.replace(regex("^\\s*(\\d+\\.|-)\\s+"), "")), keep: last and i == items.len() - 1)
      }
    } else if blk.starts-with(">") {
      // Quotation: single-spaced, indented both sides, a single line above and below; one quoted paragraph.
      block(width: 100%, above: pitch-single, below: pitch-single, sticky: last, breakable: not last,
        pad(left: quote-indent, right: quote-indent, {
          set text(..edges(pitch-single))
          par(first-line-indent: 0pt, inl(blk.split("\n").map(l => l.trim(">", at: start).trim()).join(" ")))
        }))
    } else {
      n += 1
      body-par(n, inl(blk), keep: last)
    }
  }
  if not consent-done {
    n += 1
    body-par(n, consent-text(meta), keep: true)
  }
}

// ---------------------------------------------------------------------------
// Signature block (COB-CERT-001, -002: FRBP 9011(a), LBR 9011-4)
// ---------------------------------------------------------------------------

// One signatory: firm, a blank line, mark and signer, address lines. "/s/" sits on the name's line; any other mark
// (a handwritten signature, "By:") gets its own line.
#let sig-column(sig, above: 0pt) = {
  let out = ()
  for l in sig.at("firm", default: ()) { out.push(line-block(l)) }
  if out.len() > 0 { out.push(line-block("")) }
  let mark = sig.at("mark", default: "/s/")
  if mark == "/s/" or mark.starts-with("By: /s/") {
    out.push(line-block(mark + " " + sig.signer))
  } else {
    out.push(line-block(mark))
    out.push(line-block(sig.signer))
  }
  for l in sig.at("lines", default: ()) { out.push(line-block(l)) }
  out.at(0) = block(above: above, below: 0pt, out.at(0))
  out
}

/// A double line below the body: "Dated:" at the left margin, the signatories in a column at the right, a double line
/// between them; single-spaced, never split.
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  let right = ()
  if sig.at("lead", default: true) { right += (line-block[Respectfully submitted,], line-block("")) }
  right += sig-column(sig)
  for extra in sig.at("also", default: ()) { right += sig-column(extra, above: pitch-double) }
  block(width: 100%, above: pitch-double, below: 0pt, breakable: false,
    grid(columns: (1fr, signature-column), line-block("Dated: " + str(need(meta, "date"))), right.join()))
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let cob-adversary-complaint(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "debtor", "adversary", "title", "proceeding", "consent", "signature", "date") {
    let _ = need(meta, k)
  }

  // Pages numbered at the foot, centered, in a single line box, where Word's footer sets it.
  set page(paper: "us-letter", margin: (top: margin-top, bottom: margin-other, x: margin-other),
    footer-descent: 30%,
    footer: context align(center, text(size: footer-size, ..edges(pitch-single), counter(page).display("1"))))
  set document(title: need(meta, "title"), author: need(meta, "signature").signer)
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (double spacing).
  show: xengine.with(pitch: pitch-double, list-indent: none)
  // A doubled section sign stays with its number (xengine binds a single sign), as the docx filter binds it.
  show regex("[§¶]{2,} \\S+"): it => box(it)

  caption(meta)
  render-body(meta, md)
  signature-block(meta)
}
