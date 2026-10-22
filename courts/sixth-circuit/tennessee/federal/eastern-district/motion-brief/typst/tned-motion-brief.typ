// Memorandum of law supporting a motion (Rule 12(b)(6) motion to dismiss) for the U.S. District Court
// for the Eastern District of Tennessee (tned).
//
// Rule-driven and content-agnostic. Governing rules: E.D. Tenn. LR 5.1 (paper, type size, spacing,
// margins, page numbers) and LR 7.1 (briefing; 25-page limit, LR 7.1(b)); Fed. R. Civ. P. 7(b)(1), 12(b)(6).
// Rule text, verification dates and known gaps: ../README.md.
// Every case-specific word comes from the sample's frontmatter, never from this file.

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // LR 5.1 names no typeface; Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                   // LR 5.1: no smaller than 12, footnotes included
#let page-margin = 1in                  // LR 5.1: at least one inch on all four sides
#let para-indent = 0.5in                // first-line indent of body paragraphs; a heading's label box
#let caption-left = 3.2in               // the party column of the caption, closed by rules on the right and below
#let caption-inset = 10pt               // the party column's text to its rules
#let caption-gap = 0.25in               // the rule to the case number
#let designation-indent = 1in           // "Plaintiff," / "Defendant." under the party names
#let versus-indent = 0.5in              // "v." between the parties
#let quote-indent = 0.5in               // LR 5.1: quotations indented (both sides) and single-spaced
#let sig-indent = 3.25in                // the signature block stands at the middle of the page
#let recipient-indent = 1in             // the certificate's recipients

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-body = 24pt                  // LR 5.1: double-spaced at 12 pt
#let pitch-single = 13.8pt              // LR 5.1: single-spaced headings, quotations, footnotes; also the court title, caption, title, signature, certificate lines and page number: Word's single line, 1.15 x 12 pt
#let gap = pitch-single                 // a blank single line: between the caption's and the signature's groups
#let title-above = 24pt                 // the caption to the title of the paper
#let title-below = 12pt                 // the title to the body
#let head-gap = 12pt                    // above and below a heading
#let quote-gap = 12pt                   // above and below a block quotation
#let note-gap = 7pt                     // between footnotes
#let note-clearance = 7pt               // between the text and the footnote rule: with the gap, the room LibreOffice keeps above a note
#let cert-gap = 12pt                    // the certificate's title to its text, and its text to the recipients

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("tned-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced paragraph with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, sticky: false, body) = block(width: 100%, above: above,
  below: below, sticky: sticky, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt)
    pad(left: left, body)
  })

/// The plain text of a heading's content (cmarker writes text, spaces and smart quotes).
#let plain(c) = {
  if type(c) == str { c }
  else if c.has("text") { c.text }
  else if c.has("children") { c.children.map(plain).join() }
  else if c.has("body") { plain(c.body) }
  else if c.func() == smartquote { if c.double { "\"" } else { "’" } }
  else if c == [ ] { " " }
  else { "" }
}

// ---------------------------------------------------------------------------
// Cover: court title, caption (Fed. R. Civ. P. 10(a)), title of the paper
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  let lines = ("UNITED STATES DISTRICT COURT", "EASTERN DISTRICT OF TENNESSEE")
  if "division" in meta and meta.division != none { lines.push(upper(meta.division)) }
  for (i, l) in lines.enumerate() {
    line-block(below: if i == lines.len() - 1 { pitch-body } else { 0pt }, align(center, strong(l)))
  }
}

/// The caption: the parties on the left (names, a blank line, the designation; "v." a blank line from each side) in a
/// column closed by rules on the right and below; the case number on the right.
#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-inset,
    bottom: caption-inset), {
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { line-block(above: gap, left: versus-indent)[v.] }
      for (j, n) in p.names.enumerate() { line-block(above: if k > 0 and j == 0 { gap } else { 0pt }, inl(n)) }
      line-block(above: gap, left: designation-indent, inl(p.designation))
    }
  }),
  block(inset: (left: caption-gap), line-block[No. #meta.case_number]),
)

// ---------------------------------------------------------------------------
// Signature and certificate of service
// ---------------------------------------------------------------------------

/// At the middle of the page: "Respectfully submitted,", the firm, the e-signature, each attorney (name and BPR
/// number, LR 5.1) with the address lines, the role (italic); a blank single line between the groups. Kept on one page.
#let signature(meta) = {
  let sig = meta.signature
  let s(above: 0pt, body) = line-block(above: above, left: sig-indent, body)
  block(width: 100%, breakable: false, above: pitch-body, below: 0pt, {
    s[Respectfully submitted,]
    for (i, f) in sig.at("firm", default: ()).enumerate() { s(above: if i == 0 { gap } else { 0pt }, inl(f)) }
    s(above: gap)[By: /s/ #inl(sig.by)]
    for a in sig.at("attorneys", default: ()) {
      let head = if "bpr" in a and a.bpr != none { a.name + ", " + a.bpr } else { a.name }
      s(above: gap, inl(head))
      for l in a.at("lines", default: ()) { s(inl(l)) }
    }
    if "role" in sig and sig.role != none { s(above: gap, emph(inl(sig.role))) }
  })
}

/// Fed. R. Civ. P. 5(b): the certificate of service, on its own page: the title (bold, underlined, as both exemplars),
/// the text at the body pitch, the recipients an inch in, the e-signature at the middle of the page.
#let certificate(c) = {
  pagebreak(weak: true)
  line-block(below: cert-gap, sticky: true, align(center, strong(underline[CERTIFICATE OF SERVICE])))
  block(width: 100%, above: 0pt, below: 0pt, par(inl(c.text)))
  block(width: 100%, breakable: false, above: cert-gap, below: 0pt, {
    for (i, r) in c.at("recipients", default: ()).enumerate() {
      for (j, l) in r.enumerate() {
        line-block(above: if i > 0 and j == 0 { gap } else { 0pt }, left: recipient-indent, inl(l))
      }
    }
    line-block(above: gap, left: sig-indent)[By: /s/ #inl(c.by)]
    line-block(left: sig-indent, inl(c.by))
  })
}

// ---------------------------------------------------------------------------
// Entry
// ---------------------------------------------------------------------------

#let tned-motion-brief(meta, body) = {
  set document(title: meta.title + " (" + meta.case_number + ")")
  // LR 5.1: page numbers consecutively at the bottom; no other text in the bottom margin. The number centered in a
  // single-spaced line box (Word's footer).
  set page(paper: "us-letter", margin: page-margin, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  // Every body paragraph is indented, the first after a heading or quotation too (as both exemplars).
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch.
  show: xengine.with(pitch: pitch-body, list-indent: para-indent)
  // A doubled sign stays with its number ("¶¶ 14, 15"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)
  // A web address breaks only after its "://" and after a "/", ".", "-", "_", "?", "=", "&" or "#" inside it (not
  // after one that follows another): each piece in a box, the line may break between them. Left alone, typst also
  // splits a long address inside a word, which no other engine does. The docx filter marks the same places with a
  // zero-width space.
  show regex("[A-Za-z]+://\\S+"): it => {
    let s = it.text
    let head = s.match(regex("^[A-Za-z]+://"))
    let pieces = (head.text,)
    let cur = ""
    let cs = s.slice(head.end).clusters()
    let skip = false
    for (i, ch) in cs.enumerate() {
      cur += ch
      if not skip and ch in ("/", ".", "-", "_", "?", "=", "&", "#") and i < cs.len() - 1 {
        skip = true
      } else if skip {
        skip = false
        pieces.push(cur.slice(0, cur.len() - ch.len()))
        cur = ch
      }
    }
    pieces.push(cur)
    pieces.filter(p => p != "").map(p => box(p)).join()
  }

  // Footnotes: 12 pt (LR 5.1), single-spaced; the mark, a space, the note (Word's footnote layout).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: type-size, ..edges(pitch-single), costs: (widow: 0%, orphan: 0%))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    [#super(num) #note.body]
  }

  show heading: set text(size: type-size)
  // Headings, single-spaced (LR 5.1), bold, kept with what follows, 12 pt above and below. Level 1 ("I. Introduction")
  // centered in capitals; deeper levels the typed label ("A.", "1.") in a half-inch box, the text hanging after it,
  // level 2 at the margin, level 3 half an inch in, level 4 an inch in and italic.
  show heading: it => {
    let s = plain(it.body).trim()
    if it.level == 1 {
      line-block(above: head-gap, below: head-gap, sticky: true, align(center, strong(upper(s))))
    } else {
      let m = s.match(regex("^(\\(?[A-Za-z0-9]{1,5}[.)])\\s+"))
      let lab = if m == none { "" } else { m.captures.at(0) }
      let rest = if m == none { s } else { s.slice(m.end) }
      let lvl = calc.min(it.level, 4)
      let body = strong[#box(width: para-indent, lab)#rest]
      line-block(above: head-gap, below: head-gap, sticky: true, left: (lvl - 2) * para-indent,
        par(hanging-indent: para-indent, if lvl == 4 { emph(body) } else { body }))
    }
  }
  // Block quotations: single-spaced, half an inch in on both sides (LR 5.1).
  show quote.where(block: true): it => block(width: 100%, above: quote-gap, below: quote-gap, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    pad(x: quote-indent, it.body)
  })

  court-title(meta)
  caption(meta)
  line-block(above: title-above, below: title-below, sticky: true, align(center, strong(upper(inl(meta.title)))))

  // The body in one render; its last paragraph is kept on one page with the signature block. Every footnote
  // definition goes with both parts (a reference and its definition must be in the same render).
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let defs = chunks.filter(c => c.starts-with("[^"))
  let text-chunks = chunks.filter(c => not c.starts-with("[^"))
  let tail = if text-chunks.len() > 0 and not text-chunks.last().starts-with("#") { text-chunks.last() } else { none }
  let head = if tail == none { text-chunks } else { text-chunks.slice(0, -1) }
  inl((head + defs).join("\n\n"))
  if tail == none {
    signature(meta)
  } else {
    block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
      inl(((tail,) + defs).join("\n\n"))
      signature(meta)
    })
  }
  if "certificate_of_service" in meta and meta.certificate_of_service != none {
    certificate(meta.certificate_of_service)
  }
}
