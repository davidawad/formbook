// Memorandum in support of a motion for the U.S. District Court for the Northern District of Illinois (ilnd).
// Rules: N.D. Ill. LR 5.2(e) (8 1/2 x 11 paper; line spacing at least 2.0 lines; 12-point body type;
// footnotes at least 11 points; margins at least 1 inch on all four sides); LR 7.1 (a brief in support of a
// motion is capped at 15 pages without prior approval; a longer brief needs a table of contents and a table of
// cases, which this template does not generate: see ../README.md); Fed. R. Civ. P. 7(b), 11(a), 12(b).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // no font is mandated by LR 5.2(e); Times New Roman (vendored in fonts/), the exemplar's face; Liberation Serif is its metric twin
#let type-size = 12pt                   // LR 5.2(e)(1): 12-point type in the body of the text
#let note-size = 11pt                   // LR 5.2(e)(1): footnotes no less than 11 points
#let margin = 1in                       // LR 5.2(e)(2): each margin at least 1 inch; 8 1/2 x 11 inch paper
#let para-indent = 0.5in                // first-line indent of body paragraphs; a heading label's box; each heading level further in
#let caption-left = 3.2in               // width of the party column of the caption
#let caption-paren = 0.3in              // the column of ")" marks between the parties and the case number
#let designation-indent = 0.5in         // "Plaintiffs," / "Defendant." under the party names
#let versus-indent = 1in                // "v." between the sides
#let counsel-left = 3.3in               // the counsel block on the cover and the certificate's signature (3.2 in wide, at the right margin)
#let sig-left = 3in                     // the signature column ("Respectfully submitted," and below)
#let quote-indent = 0.5in               // block quotations, both sides

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-body = 27.6pt                // LR 5.2(e): at least 2.0 lines; Word's double line at 12 pt (2 x 13.8 pt), the exemplar's pitch
#let pitch-single = 13.8pt              // single lines (court title, caption, headings, counsel, signature, quotations, page number): Word's single line at 12 pt
#let pitch-note = 12.65pt               // footnotes single-spaced at 11 pt (LR 5.2(e)(1)): Word's single line, 1.15 x 11 pt
#let blank = 13.8pt                     // one blank single line: under the court title, between caption rows' groups, above a heading, around quotations
#let head-below = 6.9pt                 // below a heading: half a single line
#let title-gap = 27.6pt                 // the caption to the title (one body line)
#let counsel-gap = 55.2pt               // the title to the counsel block (two body lines)
#let note-gap = 6pt                     // between two footnotes
#let note-clearance = 12.6pt            // the body text to the footnote rule (where LibreOffice sets Word's)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ilnd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in italics, footnote marks). Smart punctuation keeps the author's characters.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split the body into blank-line-separated chunks.
#let chunks-of(body) = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")

/// Footnote definitions ("[^key]: text") are set aside and attached to the chunk that cites them, because cmarker
/// resolves a footnote only inside the markdown that contains its definition.
#let body-chunks(body) = {
  let defs = (:)
  let out = ()
  for c in chunks-of(body) {
    let m = c.match(regex("^\\[\\^([^\\]]+)\\]:"))
    if m != none { defs.insert(m.captures.at(0), c) } else { out.push(c) }
  }
  out.map(c => {
    let keys = c.matches(regex("\\[\\^([^\\]]+)\\]")).map(m => m.captures.at(0))
    let extra = keys.filter(k => k in defs).map(k => defs.at(k))
    (text: c, defs: extra.join("\n\n", default: ""))
  })
}

/// Inline markdown with the footnote definitions it cites.
#let inl-notes(s, defs) = inl(if defs == "" { s } else { s + "\n\n" + defs })

/// One single-spaced paragraph with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt, hanging-indent: 0pt)
  pad(left: left, body)
})

/// A paragraph at the body pitch; `keep`: not split, and kept with what follows.
#let body-par(keep: false, content) = block(width: 100%, above: 0pt, below: 0pt, sticky: keep,
  breakable: not keep, par(first-line-indent: 0pt, content))

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper, counsel (the cover page carries no page number)
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  let lines = ("IN THE UNITED STATES DISTRICT COURT", "FOR THE NORTHERN DISTRICT OF ILLINOIS")
  if "division" in meta { lines.push(upper(meta.division)) }
  for l in lines { line-block(align(center, text(weight: "bold", l))) }
}

/// Caption: one single line per row: each party's names, a blank row and its designation, then a blank row, "v." and
/// a blank row between the parties; a ")" on every row. The case number, a blank row and the judge stand on the rows
/// at the middle of the caption.
#let caption(meta) = {
  let rows = ()
  let parties = meta.caption.parties
  for (k, p) in parties.enumerate() {
    for n in p.names { rows.push((inl(n), 0pt)) }
    rows.push(none)
    rows.push((inl(p.designation), designation-indent))
    if k < parties.len() - 1 { rows += (none, ([v.], versus-indent), none) }
  }
  let right = ([Case No. #meta.case_number],)
  if "judge" in meta and meta.judge != none { right += (none, [Honorable #meta.judge]) }
  let first = calc.div-euclid(rows.len() - right.len(), 2)
  let cells = ()
  for (i, r) in rows.enumerate() {
    cells.push(if r == none { line-block[] } else { line-block(left: r.at(1), r.at(0)) })
    cells.push(line-block[)])
    let j = i - first
    let rt = if j >= 0 and j < right.len() { right.at(j) } else { none }
    cells.push(line-block(if rt == none { [] } else { rt }))
  }
  block(width: 100%, above: blank, below: 0pt, breakable: false,
    grid(columns: (caption-left, caption-paren, 1fr), ..cells))
}

#let cover(meta) = {
  court-title(meta)
  caption(meta)
  for (i, l) in meta.brief_title.enumerate() {
    line-block(above: if i == 0 { title-gap } else { 0pt }, align(center, text(weight: "bold", inl(l))))
  }
  for (k, g) in meta.counsel.enumerate() {
    for (i, l) in g.enumerate() {
      line-block(above: if i > 0 { 0pt } else if k == 0 { counsel-gap } else { blank }, left: counsel-left, inl(l))
    }
  }
}

// ---------------------------------------------------------------------------
// Signature and certificate (Fed. R. Civ. P. 11(a), 5(b))
// ---------------------------------------------------------------------------

/// "Dated" at the margin and "Respectfully submitted," on the same line at the signature column; below it the party,
/// then "By: /s/" the signer and the role lines, a blank line between the groups. Not split.
#let signature-block(meta) = {
  let sig = meta.signature
  let rows = ((box(width: sig-left)[Dated: #meta.date] + [Respectfully submitted,], 0pt, 0pt),)
  for (i, l) in sig.party.enumerate() { rows.push((inl(l), sig-left, if i == 0 { blank } else { 0pt })) }
  rows.push(([By: /s/ #sig.signer], sig-left, blank))
  for l in sig.role { rows.push((inl(l), sig-left, 0pt)) }
  block(width: 100%, breakable: false, above: blank, below: 0pt, {
    for (t, left, above) in rows { line-block(above: above, left: left, t) }
  })
}

/// The certificate of service (Fed. R. Civ. P. 5(b)), when the sample gives one: its own page, a centered heading,
/// double-spaced text, the signer at the right.
#let certificate(meta) = if "certificate" in meta {
  let c = meta.certificate
  pagebreak()
  line-block(below: head-below, align(center, text(weight: "bold", underline[CERTIFICATE OF SERVICE])))
  body-par[#h(para-indent)#inl(c.text)]
  block(width: 100%, breakable: false, above: pitch-body, below: 0pt, {
    line-block(left: counsel-left, [/s/ #c.signer])
    for l in c.role { line-block(left: counsel-left, inl(l)) }
  })
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// A heading's typed label ("I.", "A.", "1.") and the rest of its text.
#let split-label(t) = {
  let m = t.match(regex("^(([IVXLC]+|[A-Za-z]|[0-9]+)\\.)\\s+"))
  if m == none { (none, t) } else { (m.captures.at(0), t.slice(m.end)) }
}

#let ilnd-motion-brief(meta, body) = {
  // LR 5.2(e): letter paper, one-inch margins. The cover has no page number; the body pages are numbered from 1 (as
  // in the filed exemplar), centered in the bottom margin in a single-spaced line box (Word's footer).
  set page(paper: "us-letter", margin: margin, footer-descent: 30%, footer: none)
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch; list labels in a half-inch box.
  show: xengine.with(pitch: pitch-body, list-indent: para-indent)
  // A doubled sign stays with its number ("¶¶ 14–15"), as a single one does in xengine.
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
        // the piece ends with the character after the separator's (Lua's gsub "(sep)(.)" consumes it)
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
  // Footnotes: at least 11 points, single-spaced (LR 5.2(e)(1)): the mark, a space, the note (Word's footnote
  // layout), note-gap between notes.
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: note-size, ..edges(pitch-note))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt, spacing: 0pt)
    [#super(num) #note.body]
  }

  cover(meta)

  pagebreak()
  set page(footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  counter(page).update(1)

  let chunks = body-chunks(body)
  // The last paragraph and the headings right before it are kept with the signature block.
  let is-head(c) = c.text.starts-with("#")
  let tail = chunks.len() - 1
  while tail > 0 and is-head(chunks.at(tail - 1)) { tail -= 1 }
  for (k, c) in chunks.enumerate() {
    let t = c.text
    let keep = k >= tail
    if is-head(c) {
      // Headings: single lines, a blank line above, half of one below, kept with what follows. Level 1 centered,
      // bold, underlined, in capitals; levels 2 to 4 with the typed label in a half-inch box, each level half an
      // inch further in, the text hanging after the label: levels 2 and 3 bold, level 4 bold italic.
      let level = calc.min(t.match(regex("^#+")).text.len(), 4)
      let rest = t.replace(regex("^#+\\s*"), "")
      let head = if level == 1 {
        align(center, underline(upper(inl-notes(rest, c.defs))))
      } else {
        let (lab, txt) = split-label(rest)
        let at = (level - 2) * para-indent
        let style = if level == 4 { (style: "italic") } else { (:) }
        par(hanging-indent: at + para-indent,
          [#h(at)#box(width: para-indent, if lab != none { lab })#text(..style, inl-notes(txt, c.defs))])
      }
      block(width: 100%, sticky: true, breakable: false, above: blank, below: head-below, {
        set text(..edges(pitch-single), weight: "bold")
        set par(first-line-indent: 0pt)
        head
      })
    } else if t.starts-with(">") {
      // block quotations: single lines, indented on both sides, a blank line above and below
      block(width: 100%, above: blank, below: blank, sticky: keep, breakable: not keep, {
        set text(..edges(pitch-single))
        set par(first-line-indent: 0pt)
        pad(x: quote-indent, inl-notes(t.replace(regex("(?m)^>\\s?"), ""), c.defs))
      })
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      block(width: 100%, above: 0pt, below: 0pt, sticky: keep, breakable: not keep,
        cmarker.render(if c.defs == "" { t } else { t + "\n\n" + c.defs }, raw-typst: false, smart-punctuation: true))
    } else {
      body-par(keep: keep)[#h(para-indent)#inl-notes(t, c.defs)]
    }
  }

  signature-block(meta)
  certificate(meta)
}
