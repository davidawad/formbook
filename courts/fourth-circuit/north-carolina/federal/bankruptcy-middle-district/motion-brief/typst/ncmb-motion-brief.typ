// U.S. Bankruptcy Court, Middle District of North Carolina: brief or memorandum of law in support of a written
// motion in an adversary proceeding (LR 7007-1(c)); the same form serves a contested-matter motion (LR 9013-1(e)).
// Rules: LR 7007-1(a) (motion: facts, relief, rules cited, service), 7007-1(c) (brief filed and served with the
// motion; 20-page limit), LR 9013-1(b) and (e), LR 9011-4 (signature block: state bar number, telephone, email),
// LR 9004-1 (certificate of service: recipient, method, address, person who served), Fed. R. Bankr. P. 9004(a)
// (clearly legible) and 9004(b) and 7010 (caption, Official Form 416D). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a named style choice; see ../README.md)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // the local rules set no typeface; Times New Roman, the house standard (docs/FONTS.md), as in the exemplar
#let type-size = 12pt                   // FRBP 9004(a): "clearly legible"; no local size rule, so the 12 pt convention (docs/FONTS.md)
#let page-margin = 1in
#let para-indent = 0.5in                // first-line indent; a list's label box
#let heading-tab = 0.5in                // a numbered heading's label box; each level half an inch further in
#let caption-left = 3.2in               // party column of the caption
#let caption-paren = 0.35in             // the ")" column
#let caption-inset = 0.25in             // the case numbers start this far right of the ")" column
#let recipient-indent = 0.5in           // certificate of service: the recipients' blocks
#let signature-indent = 3.25in

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt                // the double-spaced line pitch of the filed exemplar
#let pitch-single = 13.8pt              // single spacing: 1.15 x the type size (court lines, title, headings, signature, certificate, footnotes)
#let cap-row = 16pt                     // one caption row; the ")" column aligns row by row
#let gap-half = 12pt                    // half a double line: around the title and headings; in the signature block
#let caption-rule-gap = 9pt             // from the last caption row to the rule under the caption
#let note-gap = 7pt                     // between two footnotes (Word: Footnote Text 140 twips after)
#let note-clearance = 9pt               // between the body and the footnote separator: LibreOffice fits a body line whose box ends 16.8 pt
                                        // above the first note line's box (measured: typst breaks alike at 9 pt, not at 10 pt)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ncmb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names, citations, section symbols) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// A required frontmatter field: a missing one fails the build with its name.
#let need(d, key) = {
  if key not in d { panic("ncmb-motion-brief: missing required field `" + key + "`") }
  d.at(key)
}

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: below,
  pad(left: left, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    body
  }))

/// Single lines at `left`, the first with space above it.
#let group(above, left, items) = for (i, l) in items.enumerate() {
  line-block(above: if i == 0 { above } else { 0pt }, left: left, inl(l))
}

// ---------------------------------------------------------------------------
// Caption (Form 416D: court, parties, case numbers, title of the paper)
// ---------------------------------------------------------------------------

/// A caption row is a string, or a dictionary {t: text, a: "l" | "c" | "r"} for its alignment in the column.
#let cap-cell(item) = {
  let t = if type(item) == dictionary { item.t } else { item }
  let a = if type(item) == dictionary { item.at("a", default: "l") } else { "l" }
  align(if a == "c" { center } else if a == "r" { right } else { left }, inl(t))
}

/// The caption: one row per line, the left column (parties), a ")" column in every row, the right column (case
/// numbers). The number of rows is the longer column; the shorter one is padded with empty rows, so the ")" marks
/// run the full height. A rule closes it.
#let caption(meta) = {
  let cap = need(meta, "caption")
  let left = need(cap, "left")
  let right = cap.at("right", default: ())
  let n = calc.max(left.len(), right.len())
  block(width: 100%, above: pitch-double, below: 0pt, {
    set text(..edges(cap-row))
    set par(first-line-indent: 0pt)
    grid(
      columns: (caption-left, caption-paren, 1fr),
      ..range(n).map(i => (
        cap-cell(if i < left.len() { left.at(i) } else { "" }),
        align(center, [)]),
        pad(left: caption-inset, cap-cell(if i < right.len() { right.at(i) } else { "" })),
      )).flatten(),
    )
  })
  block(width: 100%, height: caption-rule-gap, above: 0pt, below: 0pt, stroke: (bottom: 0.75pt))
}

/// The first page: court title, caption, title of the paper. The body starts on the same page.
#let cover(meta) = {
  for l in need(meta, "court") { line-block(align(center, inl(l))) }
  caption(meta)
  line-block(above: gap-half, below: gap-half, align(center, strong(inl(need(meta, "title")))))
}

// ---------------------------------------------------------------------------
// Body: paragraphs, headings (I., A., 1., a.), numbered lists, footnotes
// ---------------------------------------------------------------------------

/// Printed label of a numbered heading: level 2 "I.", 3 "A.", 4 "1.", 5 "a.". Level 1 is unnumbered.
#let heading-label(level, k) = numbering(("I.", "A.", "1.", "a.").at(level - 2), k)

/// A body paragraph at the double pitch, first line indented.
#let body-par(content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), content))

/// Each blank-line-separated chunk of markdown is a heading, a footnote definition (printed at its reference), a
/// numbered list, or a paragraph. cmarker does not convert markdown footnotes: `[^key]` in a paragraph is rendered
/// as a typst footnote with the text of its `[^key]: text` definition.
#let body-chunks(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let notes = (:)
  for c in chunks {
    let m = c.trim().match(regex("^\\[\\^([^\\]]+)\\]:[ \\t]*"))
    if m != none { notes.insert(m.captures.at(0), c.trim().slice(m.end).replace(regex("\\s*\\n\\s*"), " ")) }
  }
  // Inline markdown with footnote references; cmarker trims a piece's outer spaces, so they are put back.
  let with-notes(t) = {
    let piece(s) = [#if s.starts-with(" ") [ ]#inl(s)#if s.ends-with(" ") [ ]]
    let out = []
    let last = 0
    for r in t.matches(regex("\\[\\^([^\\]]+)\\]")) {
      if r.start > last { out += piece(t.slice(last, r.start)) }
      out += footnote(inl(notes.at(r.captures.at(0))))
      last = r.end
    }
    if last < t.len() { out += piece(t.slice(last)) }
    out
  }
  let counts = (0, 0, 0, 0, 0, 0)
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      let level = t.position(" ")
      let title = t.slice(level).trim()
      if level == 1 {
        block(sticky: true, width: 100%, above: gap-half, below: gap-half, {
          set text(..edges(pitch-single))
          set par(first-line-indent: 0pt)
          align(center, strong(upper(inl(title))))
        })
      } else {
        if level > 5 { panic("ncmb-motion-brief: headings deeper than level 5 are not supported") }
        counts.at(level) += 1
        for k in range(level + 1, 6) { counts.at(k) = 0 }
        let ind = (level - 2) * heading-tab
        block(sticky: true, width: 100%, above: gap-half, below: gap-half, {
          set text(..edges(pitch-single))
          pad(left: ind, par(hanging-indent: heading-tab, first-line-indent: 0pt,
            [#box(width: heading-tab, heading-label(level, counts.at(level)))#strong(inl(title))]))
        })
      }
    } else if t.starts-with(regex("^\\[\\^[^\\]]+\\]:")) {
      // a footnote definition: printed at its reference
    } else if t.starts-with(regex("^\\d+\\.[ \\t]")) {
      // A numbered list: the number at the paragraph indent in a box of its width, the text hanging after it.
      let items = t.split(regex("(?m)^\\d+\\.[ \\t]+")).filter(s => s.trim() != "")
      for (i, it) in items.enumerate() {
        block(width: 100%, above: 0pt, below: 0pt, pad(left: para-indent,
          par(hanging-indent: para-indent, first-line-indent: 0pt,
            [#box(width: para-indent, [#(i + 1).])#with-notes(it.trim().replace(regex("\\s*\\n\\s*"), " "))])))
      }
    } else {
      body-par(with-notes(t))
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (LR 9011-4: state bar number, telephone and email on every paper)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
    line-block(inl(need(sig, "dated")))
    group(gap-half, signature-indent, ("/s/ " + need(sig, "signed_by"),))
    for s in need(sig, "signers") {
      group(gap-half, signature-indent,
        (need(s, "name"), "N.C. State Bar No. " + need(s, "bar"), "Email: " + need(s, "email")))
    }
    group(gap-half, signature-indent, need(sig, "firm") + need(sig, "address") + ("Telephone: " + need(sig, "phone"),))
    group(gap-half, signature-indent, need(sig, "role"))
  })
}

// ---------------------------------------------------------------------------
// Certificate of service (LR 9004-1: recipient, method, address if not electronic, and who served)
// ---------------------------------------------------------------------------

#let certificate(meta) = {
  let svc = need(meta, "service")
  let sig = need(meta, "signature")
  pagebreak(weak: true)
  line-block(align(center, strong("CERTIFICATE OF SERVICE")))
  block(width: 100%, above: gap-half, below: 0pt,
    par(first-line-indent: (amount: para-indent, all: true), inl(need(svc, "statement"))))
  // Each recipient: the name and address lines, then the method in italics; never split across a page.
  for r in need(svc, "recipients") {
    block(width: 100%, breakable: false, above: gap-half, below: 0pt, {
      group(0pt, recipient-indent, need(r, "lines"))
      line-block(left: recipient-indent, emph(inl(need(r, "method"))))
    })
  }
  block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
    line-block(inl(if "dated" in svc { svc.dated } else { sig.dated }))
    group(gap-half, signature-indent, ("/s/ " + need(sig, "signed_by"),))
  })
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let ncmb-motion-brief(meta, md) = {
  for k in ("court", "caption", "title", "signature") { let _ = need(meta, k) }

  set document(title: need(meta, "title"), author: need(need(meta, "signature"), "signed_by"))
  // No page number on the first page (the caption page); the others are numbered at the foot, centered, in a
  // single-spaced line box, where Word's footer sets it.
  set page(
    paper: "us-letter",
    margin: page-margin,
    footer-descent: 30%,
    footer: context {
      if counter(page).get().first() > 1 { align(center, text(..edges(pitch-single), counter(page).display("1"))) }
    },
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (double spaced).
  show: xengine.with(pitch: pitch-double, list-indent: none)
  // A doubled sign stays with its number too ("¶¶ 16-17"; xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)

  // Footnotes: the type size, single-spaced; the mark, a space, the note.
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt,
    separator: line(length: 1.5in, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)   // the entry does not inherit the body's leading
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  cover(meta)
  body-chunks(md)
  signature-block(meta)
  if "service" in meta { certificate(meta) }
}
