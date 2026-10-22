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
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // Times New Roman substitute per docs/FONTS.md, vendored; no system font is used
#let type-size = 12pt                     // LBR 9013-1(b) and 1005-1(b): text at least 11 point
#let note-size = 10pt                     // LBR 9013-1(b) and 1005-1(b): footnotes at least 10 point
#let footer-size = 11pt                   // the page number
#let para-indent = 0.5in
#let margin = 1in                         // not set by the LBRs; the usual 1 inch on every side
#let caption-left = 3.3in                 // width of the party column of the caption
#let caption-pad = 10pt                   // the party text stands off the column's right rule
#let caption-foot = 8pt                   // ... and off its bottom rule
#let caption-right = 0.35in               // the case-number column stands off the party column
#let label-box = 0.4in                    // the number of a list item, after the paragraph indent
#let quote-left = 0.75in                  // quotations: indented on both sides
#let quote-right = 0.5in
#let sig-col = 3in                        // the signature column starts this far in
#let cert-sig = 3.5in                     // the certificate's signature: a 3 in column at the right margin
#let rule = 0.75pt
#let court-name = ("UNITED STATES BANKRUPTCY COURT", "DISTRICT OF RHODE ISLAND")   // court-level text, not case text
// LBR 1005-1(d)(1): the response-time language for a motion. Verbatim from the rule text; the court address is part of it.
#let response-default = "Within fourteen (14) days after service, if served electronically, as evidenced by the certification, and an additional three (3) days pursuant to Fed. R. Bank. P. 9006(f) if served by mail or other excepted means specified, any party against whom such paper has been served, or any other party who objects to the relief sought, shall serve and file an objection or other appropriate response to said paper with the Bankruptcy Court Clerk's Office, 380 Westminster Street, 6th Floor, Providence, RI 02903, (401) 626-3100. If no objection or other response is timely filed, the paper will be deemed unopposed and will be granted unless: (1) the requested relief is forbidden by law; (2) the requested relief is against public policy; or (3) in the opinion of the Court, the interest of justice requires otherwise."

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt                  // LBR 9013-1(b) and 1005-1(b): double spaced
#let pitch-single = 13.8pt                // a single line: 1.15 x the type size (caption, quotations, signature; exempt)
#let pitch-note = 11.5pt                  // a footnote line: 1.15 x the footnote size
#let note-gap = 7pt                       // between two footnotes (Word: Footnote Text's space after)
#let pitch-footer = 1.15 * footer-size
#let gap = pitch-single                   // a blank single line between groups
#let half-gap = pitch-single / 2

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

/// One single-spaced paragraph of its own, with explicit space above it.
#let line-block(above: 0pt, indent: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: indent, body)
})

/// A double-spaced paragraph with the first line indented.
#let body-par(body) = block(width: 100%, above: 0pt, below: 0pt, par(body))

// ---------------------------------------------------------------------------
// Caption and title (repeated on the memorandum's first page, as the filing does)
// ---------------------------------------------------------------------------

/// The caption: the bankruptcy case (In re) above, the adversary proceeding (parties) below, in a column ruled on
/// the right and at the foot; the chapter and case numbers on the right. Everything comes from the frontmatter.
#let caption(meta) = {
  let left = {
    line-block[IN RE:]
    for (i, n) in meta.in_re.enumerate() { line-block(above: if i == 0 { half-gap } else { 0pt }, inl(n)) }
    line-block(align(right, inl(meta.debtor_designation)))
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { line-block[v.] }
      for (i, n) in p.names.enumerate() { line-block(above: if k == 0 and i == 0 { gap } else { 0pt }, inl(n)) }
      line-block(inl(p.designation))
    }
  }
  let right = {
    line-block[Chapter #meta.chapter]
    line-block[Bankruptcy Case No. #meta.case_number]
    line-block(above: half-gap)[Adversary Proceeding No. #meta.adversary_number]
  }
  block(above: pitch-double, below: 0pt, grid(
    columns: (caption-left, 1fr),
    block(width: 100%, stroke: (right: rule, bottom: rule), inset: (right: caption-pad, bottom: caption-foot), left),
    pad(left: caption-right, right),
  ))
}

#let titled-caption(meta, title) = {
  for l in court-name { line-block(align(center, strong(l))) }
  caption(meta)
  block(above: pitch-double, below: pitch-single, line-block(align(center, strong(upper(inl(title))))))
}

// ---------------------------------------------------------------------------
// Signature, response language, certificate of service
// ---------------------------------------------------------------------------

/// The signature block: the case line (LBR 1005-1(a)), the date at the margin beside "Respectfully submitted,", the
/// signature column, and any "Of Counsel" lines. Its lines are returned loose; the caller keeps them in one block.
#let signature-lines(meta, of-counsel) = {
  let s = meta.signature
  let col(above: 0pt, body) = line-block(above: above, indent: sig-col, body)
  line-block("In re " + meta.in_re.join(", ") + ", Debtor; Chapter " + meta.chapter + "; Bankruptcy Case No. "
    + meta.case_number + "; Adversary Proceeding No. " + meta.adversary_number)
  block(width: 100%, above: gap, below: 0pt, grid(columns: (sig-col, 1fr),
    line-block(if "date" in meta [Dated: #inl(meta.date)]),
    line-block[Respectfully submitted,]))
  col(above: gap, inl(s.client))
  col(inl(s.by))
  col(above: gap)[/s/ #inl(s.signer)]
  col(inl(s.signer))
  for l in s.firm { col(inl(l)) }
  col[RI Bar No. #inl(s.bar_id)]
  for l in s.lines { col(inl(l)) }
  if of-counsel != none {
    for (i, l) in of-counsel.enumerate() { line-block(above: if i == 0 { gap } else { 0pt }, inl(l)) }
  }
}

/// The certificate of service: on a page of its own, the CM/ECF statement, the recipients, the signer.
#let certificate-block(meta) = {
  let c = meta.certificate
  block(breakable: false, width: 100%, above: 0pt, below: 0pt, {
    line-block(align(center, strong[CERTIFICATE OF SERVICE]))
    block(width: 100%, above: pitch-single, below: 0pt, par(inl("I hereby certify that on " + c.date
      + ", I electronically filed the within " + meta.title + " with the Clerk of the Bankruptcy Court for the District"
      + " of Rhode Island using the CM/ECF System. The following participant has received notice electronically:")))
    for (i, l) in c.recipients.enumerate() { line-block(above: if i == 0 { half-gap } else { 0pt }, indent: para-indent, inl(l)) }
    line-block(above: pitch-double, indent: cert-sig)[/s/ #inl(meta.signature.signer)]
    line-block(indent: cert-sig, inl(meta.signature.signer))
  })
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
/// - a heading: `#` centered bold caps, `##` centered bold, `###` bold italic at the margin; sticky;
/// - a list (`1.` items): numbered 1., 2., ..., the number in a box after the paragraph indent;
/// - a block quotation (`>`): single spaced, indented on both sides;
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
      let lvl = t.match(regex("^#+")).text.len()
      let txt = inl(t.slice(lvl).trim())
      // Headings at the body size and pitch, no space of their own; sticky: a heading never ends a page.
      block(sticky: true, width: 100%, above: 0pt, below: 0pt, {
        set par(first-line-indent: 0pt)
        if lvl == 1 { align(center, strong(upper(txt))) } else if lvl == 2 { align(center, strong(txt)) } else { strong(emph(txt)) }
      })
    } else if t.starts-with(regex("^\\d+\\.[ \\t]")) {
      let items = t.split(regex("(?m)^\\d+\\.[ \\t]+")).map(i => i.trim()).filter(i => i != "")
      for (i, item) in items.enumerate() {
        block(width: 100%, above: 0pt, below: 0pt, pad(left: para-indent, par(first-line-indent: 0pt,
          hanging-indent: label-box, [#box(width: label-box)[#(i + 1).]#inl(item.replace(regex("\\s*\\n\\s*"), " "))])))
      }
    } else if t.starts-with(">") {
      // A quotation: single spaced, indented on both sides, half a double line off the text; its paragraphs a
      // blank single line apart.
      let paras = t.split(regex("\\n>[ \\t]*(\\n|$)")).map(p => p.replace(regex("(?m)^>[ \\t]?"), "").trim())
        .filter(p => p != "")
      block(width: 100%, above: pitch-double / 2, below: pitch-double / 2, {
        set text(..edges(pitch-single))
        set par(first-line-indent: 0pt)
        for (i, p) in paras.enumerate() {
          block(width: 100%, above: if i == 0 { 0pt } else { gap }, below: 0pt,
            pad(left: quote-left, right: quote-right, inl(p.replace(regex("\\s*\\n\\s*"), " "))))
        }
      })
    } else {
      body-par(cmarker.render(full, raw-typst: false, smart-punctuation: true))
    }
  }
}

#let rib-motion-brief(meta, body) = {
  set page(paper: "us-letter", margin: margin, footer-descent: 30%, footer: context {
    set text(size: footer-size, ..edges(pitch-footer))
    align(center, counter(page).display())
  })
  set document(title: meta.title)
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (double-spaced).
  show: xengine.with(pitch: pitch-double, list-indent: none)
  // A doubled section sign stays with its number ("§§ 362"), as the docx engine binds it.
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // Footnotes at 10 pt, single-spaced, the mark and a space before the note (Word's Footnote Text).
  set footnote.entry(gap: note-gap, clearance: 12.6pt, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: note-size, ..edges(pitch-note))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  // The sample's body has up to two parts, split by a line holding only `---`: the motion, then the memorandum.
  let parts = body.split(regex("\\r?\\n---[ \\t]*\\r?\\n"))
  let motion = parts.at(0)
  let memo = if parts.len() > 1 { parts.at(1) } else { none }

  // Part 1: the motion. Caption, title, the motion's paragraphs, the response-time language, signature; the
  // response language and the signature are one block, so a signature never stands alone on a page.
  titled-caption(meta, meta.title)
  chunks(motion)
  block(breakable: false, width: 100%, above: pitch-single, below: 0pt, {
    if meta.at("response", default: "14-days") != "none" {
      // LBR 1005-1(d)(1): the response language may be single or double spaced, in at least 11 point type.
      block(width: 100%, above: 0pt, below: pitch-double, {
        set text(..edges(pitch-single))
        par(meta.at("response_text", default: response-default))
      })
    }
    signature-lines(meta, none)
  })

  // Part 2: the memorandum starts on a new page with the caption repeated and its own title.
  if memo != none {
    pagebreak()
    titled-caption(meta, meta.memorandum_title)
    chunks(memo)
    block(breakable: false, width: 100%, above: pitch-single, below: 0pt,
      signature-lines(meta, meta.at("of_counsel", default: none)))
  }

  if "certificate" in meta and meta.certificate != none {
    pagebreak()
    certificate-block(meta)
  }
}
