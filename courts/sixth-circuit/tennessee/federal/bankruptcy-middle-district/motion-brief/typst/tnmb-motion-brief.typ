// Memorandum of law in support of a motion, for the United States Bankruptcy Court, M.D. Tennessee (tnmb).
// Rules: LBR 5005-3(a), (b) (8 1/2 x 11, 12-point, one-inch margins, page numbers at the bottom with room for
// the CM/ECF footer); LBR 9004-2 (caption: case number, chapter, judge, adversary number, title); LBR 9013-2
// (briefs and memoranda; citations retrievable from Westlaw or Lexis); LBR 9013-3 (certificate of service:
// manner of service, names and addresses served). A motion travels with an LBR 9013-1 Notice and a proposed
// order; those are separate filings and are not produced here. See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or to the filed exemplar; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif") // no family is named by the rules; Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                 // LBR 5005-3(a): clearly legible in 12-point font (footnotes and page number too)
#let margin = 1in                     // LBR 5005-3(a): one-inch margins throughout, 8 1/2 x 11 inch paper
#let footer-descent = 0.6in           // LBR 5005-3(b): the page number low in the bottom margin, clear of the text
#let para-indent = 0.5in              // first-line indent of paragraphs (exemplar)
#let heading-box = 0.5in              // a level 2 heading: its typed label ("A.") in a box at the indent, the text hanging after it
#let heading-right = 0.5in            // a level 2 heading stops this far short of the right margin (exemplar)
#let quote-indent = 0.5in             // block quotations, both sides (exemplar)
#let caption-left = 3.7in             // party column of the caption: a party name must fit one row (README.md)
#let caption-mid = 0.3in              // the ")" column
#let designation-indent = 0.5in       // "Debtor." / "Plaintiff," / "Defendant." under the names (exemplar)
#let sig-indent = 2.5in               // the signature block; the firm's name fits one line from here
#let recipient-indent = 0.5in         // the certificate's addressees (exemplar)

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-body = 24pt                // double spacing at 12 pt (exemplar)
#let pitch-single = 13.8pt            // a single line (Word's single line at 12 pt, 1.15 x): court title, caption, title, headings, quotations, signature, certificate, footnotes, page number
#let gap = pitch-body / 2             // around headings and block quotations, between a quotation's paragraphs and the certificate's addressees
#let note-gap = 7pt                   // between footnotes
#let note-clearance = 7pt             // the text to the footnote rule

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("tnmb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in *italics*, section symbols, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced paragraph with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, right: 0pt, sticky: false, body) = block(width: 100%,
  above: above, below: below, sticky: sticky, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt)
    pad(left: left, right: right, body)
  })

/// A body paragraph: the body pitch, no space of its own (double spacing runs on).
#let body-par(body, indent: true) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: if indent { para-indent } else { 0pt }, all: true), body))

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (LBR 9004-2)
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  let lines = ("IN THE UNITED STATES BANKRUPTCY COURT", "FOR THE MIDDLE DISTRICT OF TENNESSEE")
  if "division" in meta { lines.push(upper(meta.division)) }
  for (i, l) in lines.enumerate() {
    line-block(below: if i == lines.len() - 1 { pitch-body } else { 0pt }, align(center, strong(l)))
  }
}

/// The caption: the debtor and the parties in the left column, a ")" column, and on the right the
/// case number, chapter, judge and adversary number (LBR 9004-2(a)(1), (b)). One single line per row.
#let caption(meta) = {
  let c = meta.caption
  // (text, indent); none is a blank row
  let left = (("IN RE:", 0pt), none)
  for d in c.debtor { left.push((d, 0pt)) }
  left += (("Debtor.", designation-indent), none)
  for (k, p) in c.parties.enumerate() {
    if k > 0 { left += (("v.", 0pt), none) }
    for n in p.names { left.push((n, 0pt)) }
    left += ((p.designation, designation-indent), none)
  }
  let adv = if "adv_proc_no" in meta and meta.adv_proc_no != "" { meta.adv_proc_no } else { "_" * 8 }
  let right = (
    "Case No. " + str(meta.case_number),
    "Chapter " + str(meta.chapter),
    "Judge " + str(meta.judge),
    none,
    "Adv. Proc. No. " + str(adv),
  )
  let n = calc.max(left.len(), right.len())
  let cells = ()
  for i in range(n) {
    let l = left.at(i, default: none)
    let r = right.at(i, default: none)
    cells.push(if l == none { line-block[] } else { line-block(left: l.at(1), inl(l.at(0))) })
    cells.push(line-block[)])
    cells.push(if r == none { line-block[] } else { line-block(inl(r)) })
  }
  block(above: 0pt, below: 0pt, grid(columns: (caption-left, caption-mid, 1fr), ..cells))
}

// ---------------------------------------------------------------------------
// Body: headings, paragraphs, quotations, lists, signature, certificate of service
// ---------------------------------------------------------------------------

/// The body, one blank-line-separated chunk at a time: a heading (`#` centered bold, `##` and deeper bold with the
/// typed label in a box at the indent and the text hanging after it), a list, a block quotation (`>`), or a
/// paragraph (not numbered: a memorandum, not a pleading). A paragraph right after a quotation (its citation) is set
/// at the margin. Footnote definitions ("[^n]: text") go with the chunk that cites them. The last paragraph is kept
/// on one page with the signature block, so a signature never starts a page alone.
#let body-flow(body, signature) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let defs = (:)
  for c in chunks {
    let key = c.match(regex("^\\[\\^([^\\]]+)\\]:"))
    if key != none { defs.insert(key.captures.at(0), c) }
  }
  let md(t) = {
    let tail = ""
    for (key, d) in defs {
      if t.contains("[^" + key + "]") { tail += "\n\n" + d }
    }
    cmarker.render(t + tail, raw-typst: false, smart-punctuation: true, h1-level: 1)
  }
  let live = chunks.filter(c => not c.starts-with("[^"))
  let last = live.len() - 1
  let after-quote = false
  for (i, t) in live.enumerate() {
    let is-quote = t.starts-with(">")
    let hd = t.match(regex("^(#+)[ \\t]+(([A-Za-z]|[0-9]+|[IVXLC]+)\\.[ \\t]+)?([\\s\\S]*)$"))
    let piece = if hd != none {
      // Headings: single-spaced, bold, half a body line from the text on either side, kept with the text after
      // them; level 1 centered as typed (the exemplar's are capitals), level 2 and deeper at the indent, the typed
      // label ("A.") in a box and the text hanging after it.
      let (marks, _, lab, txt) = hd.captures
      if marks.len() == 1 {
        line-block(above: gap, below: gap, sticky: true, align(center, strong(md(txt))))
      } else {
        line-block(above: gap, below: gap, sticky: true, left: para-indent, right: heading-right,
          par(hanging-indent: heading-box, strong[#box(width: heading-box, if lab != none { lab + "." })#md(txt)]))
      }
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      md(t)
    } else if is-quote {
      block(width: 100%, above: gap, below: gap, {
        set text(..edges(pitch-single))
        set par(first-line-indent: 0pt, spacing: gap)
        show quote.where(block: true): it => it.body
        pad(left: quote-indent, right: quote-indent, md(t))
      })
    } else {
      body-par(md(t), indent: not after-quote)
    }
    if i == last and not is-quote and not t.starts-with("#") {
      block(width: 100%, breakable: false, above: 0pt, below: 0pt, { piece; signature })
    } else {
      piece
      if i == last { signature }
    }
    after-quote = is-quote
  }
}

/// "Respectfully submitted," and the signer's lines, a blank single line between; kept together.
#let signature-block(meta) = block(width: 100%, breakable: false, above: pitch-single, below: 0pt, {
  line-block(left: sig-indent)[Respectfully submitted,]
  for (i, l) in meta.signature.enumerate() {
    line-block(above: if i == 0 { pitch-single } else { 0pt }, left: sig-indent, inl(l))
  }
})

/// Certificate of service (LBR 9013-3): its title, the statement of service, each addressee single-spaced; kept
/// together.
#let certificate-block(meta) = if "certificate" in meta {
  let cert = meta.certificate
  block(width: 100%, breakable: false, above: pitch-body, below: 0pt, {
    line-block(below: gap, align(center, strong(underline[CERTIFICATE OF SERVICE])))
    line-block(par(first-line-indent: (amount: para-indent, all: true), inl(cert.text)))
    for addressee in cert.recipients {
      for (j, l) in addressee.enumerate() {
        line-block(above: if j == 0 { gap } else { 0pt }, left: recipient-indent, inl(l))
      }
    }
  })
}

#let tnmb-motion-brief(meta, body) = {
  // LBR 5005-3(b): every page numbered at the bottom, centered, in a single line box (Word's footer).
  set page(paper: "us-letter", margin: margin, footer-descent: footer-descent,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch.
  show: xengine.with(pitch: pitch-body, list-indent: para-indent)
  // A doubled sign stays with its number ("§§ 541(a)(1)"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)

  // Footnotes: 12 pt (LBR 5005-3(a) applies 12-point type to all filings; the exemplar's are smaller, README.md),
  // single-spaced; the mark, a space, the note (Word's footnote layout). A note is kept whole on one page, as Word's
  // Footnote Text keeps its lines together: a note split by typst under a sticky heading left its first line on the
  // page before the heading.
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    block(breakable: false, [#super(num) #note.body])
  }

  court-title(meta)
  caption(meta)
  for (i, l) in meta.title.enumerate() {
    line-block(above: if i == 0 { pitch-body } else { 0pt }, below: if i == meta.title.len() - 1 { pitch-body } else { 0pt },
      align(center, strong(upper(l))))
  }

  body-flow(body, signature-block(meta))
  certificate-block(meta)
}
