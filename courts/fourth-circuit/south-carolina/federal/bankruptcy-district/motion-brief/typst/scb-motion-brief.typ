// Motion with memorandum of law, adversary proceeding, U.S. Bankruptcy Court, District of South Carolina (scb).
// Rules: Fed. R. Bankr. P. 7012(b) (Rule 12(b) defenses by motion in an adversary proceeding), 9013(b) (a
// motion states its grounds with particularity and the relief sought), 9004(a)-(b) (legible; caption with the
// court's name), 9037(a) (redaction). Local: SC LBR 7012-1 (notice to a pro se party; text reproduced below),
// 9013-2(a) (a memorandum is filed and served no later than seven days before the hearing), 9011-4 (signature with
// "/s/" and typed name). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a named style choice; see README.md)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")        // No SC bankruptcy rule names a typeface; Times New Roman substitute per docs/FONTS.md, vendored in /fonts.
#let type-size = 12pt                   // no SC bankruptcy rule sets a size; the 12 pt convention (docs/FONTS.md)
#let page-margin = 1in
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let number-box = 0.5in                 // a numbered fact: the number after the indent, in a box (docx: a tab)
#let list-indent = 0.5in                // a list item's letter starts half an inch in ...
#let letter-box = 0.4in                 // ... in a box of its own; the text wraps under the text
#let quote-indent = 0.5in               // block quotations: indented both sides
#let caption-left = 2.9in               // width of the party column of the caption
#let caption-paren = 0.25in             // the column of ")" marks
#let caption-pad = 0.15in               // the case column stands off the ")" column
#let designation-pad = 0.12in           // a right-aligned designation stands off the ")" column
#let versus-indent = 0.4in              // "v." between the parties
#let h3-box = 0.5in                     // a level-3 heading's letter box (A., B., ...) at the margin
#let h4-box = 0.5in                     // a level-4 heading's number box (1., 2., ...) half an inch in
#let sig-left = 3.25in                  // the signature block's left edge

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/scb-motion-brief.lua and docx/reference.xml set
// the same twips).
#let pitch-body = 24pt                  // double spacing: the line pitch of body text
#let pitch-single = 16.2pt              // court title, caption, signature block, block quotations, footnotes
#let caption-above = 12pt               // the court title to the caption
#let title-above = 24pt                 // the caption to the motion's title ...
#let title-below = 12pt                 // ... and the title to the text
#let notice-above = 12pt                // the caption to the notice's heading ...
#let notice-below = 12pt                // ... and the heading to the text
#let heading-above = 12pt               // a heading: the space above it (none below; it sits on the body pitch)
#let quote-above = 12pt                 // a block quotation: the space above it ...
#let quote-below = 12pt                 // ... below it ...
#let quote-gap = 10.8pt                 // ... and between its paragraphs
#let signature-above = 24pt             // the last paragraph to the signature block
#let sig-gap = 12pt                     // between the parts of the signature block, and before the date
#let note-gap = 6pt                     // between two footnotes (docx: Footnote Text 120 twips after)
#let note-clearance = 8pt               // the text to the footnote rule: with typst's 6 pt (note-gap) from the rule to the first note, the 14 pt LibreOffice keeps (docx)

// Text of the notice that SC LBR 7012-1 requires where the non-moving party has no counsel
// (SC LBR 7012-1, as amended 2025; reproduced from the rule's text, 2026 local rules PDF, fetched 2026-10-14).
#let notice-text = "A motion to dismiss is a request that one or more issues in a case be decided without holding a trial. Motions to dismiss are governed by Rule 12, Federal Rules of Civil Procedure. Your complaint, or the portions of your complaint that the motion seeks to dismiss, may be dismissed if the court finds that the complaint does not contain sufficient allegations to state a claim upon which the court can grant relief. If you wish to oppose the motion to dismiss, you must file with the court and serve on the other party a written response within the time period set forth in a notice that will be separately mailed to you by the Clerk of Court. If you file a written response, a hearing will be held at the location and time set forth in the notice from the Clerk of Court. If you fail to file a timely written response to the motion, the court will consider the motion unopposed and may grant the motion without holding a hearing. This will result in the termination of the proceeding, or some part thereof, in favor of the moving party."

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("scb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Required frontmatter field: a missing key fails loudly rather than printing nothing.
#let need(meta, key) = {
  if key not in meta { panic("scb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Inline markdown (italic case names, smart quotes) as content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Inline content without the paragraph breaks cmarker may put around it (they may not occur inside a paragraph).
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// One single-spaced line (a paragraph of its own), with an explicit space above it.
#let line-block(above: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  body
})

/// A body paragraph at the body pitch.
#let body-par(indent: para-indent, content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: indent, all: true), unloose(content)))

/// A centered bold line on the body pitch (the titles; docx: the same paragraph).
#let title-block(above, below, body) = block(width: 100%, sticky: true, above: above, below: below,
  { set par(first-line-indent: 0pt); align(center, text(weight: "bold", body)) })

// ---------------------------------------------------------------------------
// Cover: court title and caption (")" style; Fed. R. Bankr. P. 9004(b): the court's name, the title of the case,
// the case and adversary numbers, the document's designation)
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  for l in need(meta, "court") { line-block(align(center, inl(l))) }
}

/// One caption cell. A left entry starting with `~` is right-aligned (designations: "Debtors.",
/// "Plaintiff,", "Defendant."); one starting with `>` is indented (the "v." between the parties).
#let cap-cell(s) = {
  if s.starts-with("~") { pad(right: designation-pad, align(right, inl(s.slice(1)))) }
  else if s.starts-with(">") { pad(left: versus-indent, inl(s.slice(1))) }
  else { inl(s) }
}

/// The caption as one row per line: party names on the left, a ")" on every row, and the case
/// information on the right.
#let caption(meta) = {
  let rows = need(meta, "caption").rows
  block(width: 100%, above: caption-above, below: 0pt, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    grid(
      columns: (caption-left, caption-paren, 1fr),
      ..rows.map(r => (cap-cell(r.at(0)), [)], pad(left: caption-pad, inl(r.at(1))))).flatten(),
    )
  })
}

// ---------------------------------------------------------------------------
// Signature block (Fed. R. Bankr. P. 9011 and SC LBR 9011-4: "/s/" with the typed name)
// ---------------------------------------------------------------------------

#let signature-block(sig, respectfully: true) = {
  block(width: 100%, above: signature-above, below: 0pt, pad(left: sig-left, {
    if respectfully { line-block[Respectfully submitted,] }
    line-block(above: if respectfully { sig-gap } else { 0pt }, inl(sig.firm))
    line-block(above: sig-gap)[/s/ #sig.signer]
    for l in sig.lines { line-block(inl(l)) }
    line-block(inl(sig.role))
  }))
  line-block(above: sig-gap, inl(sig.date))
}

// ---------------------------------------------------------------------------
// Notice to a pro se party (SC LBR 7012-1), when the frontmatter has `notice`
// ---------------------------------------------------------------------------

#let notice-part(meta) = {
  court-title(meta)
  caption(meta)
  title-block(notice-above, notice-below)[NOTICE REQUIRED BY SC LBR 7012-1]
  body-par(indent: 0pt)[TO: #need(meta, "notice").addressee]
  body-par[#notice-text]
  // the space above the signature is its own block's, which a container does not carry at its start: set it here
  block(width: 100%, breakable: false, above: signature-above, below: 0pt, signature-block(need(meta, "signature"), respectfully: false))
}

// ---------------------------------------------------------------------------
// Body: the motion and memorandum. Paragraphs are numbered only inside the section named by the
// frontmatter field `numbered_section` (the facts); argument prose is not numbered. Headings are
// level 2 (centered), level 3 (A., B., ...) and level 4 (1., 2., ...).
// ---------------------------------------------------------------------------

#let chunk-kind(t) = {
  if t.starts-with("#") { "heading" }
  else if t.starts-with(">") { "quote" }
  else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) { "list" }
  else { "para" }
}

/// A heading kept with the text after it, on the body pitch (docx: Heading 2 to 4).
#let heading-block(level, label, s) = block(width: 100%, sticky: true, above: heading-above, below: 0pt, {
  set par(first-line-indent: 0pt)
  if level <= 2 { align(center, text(weight: "bold", inl(s))) }
  else if level == 3 { par(hanging-indent: h3-box, text(weight: "bold", [#box(width: h3-box, label)#unloose(inl(s))])) }
  else { par(hanging-indent: para-indent + h4-box,
    text(weight: "bold", [#h(para-indent)#box(width: h4-box, label)#unloose(inl(s))])) }
})

/// A block quotation: single-spaced, indented both sides, its paragraphs apart (docx: the same paragraphs).
#let quote-block(src) = block(width: 100%, above: quote-above, below: quote-below,
  pad(left: quote-indent, right: quote-indent, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, spacing: quote-gap)
    inl(src)
  }))

/// A single line that anchors a footnote goes to the next page with its note when the note does not fit below it, as
/// Word and LibreOffice set it (they keep a reference and its note on one page; typst would keep the line and carry
/// the note over alone). The probe stands before the line, so its decision does not move what it measures. `notes`:
/// the markdown of the line's footnotes.
#let note-carry(notes, blk) = {
  if notes.len() == 0 { return blk }
  context {
    let w = page.width - 2 * page-margin
    let h = measure(block(width: w, blk)).height
    if h <= pitch-body + 0.1pt {
      let entry(c) = measure(block(width: w, {
        set text(..edges(pitch-single))
        set par(first-line-indent: 0pt)
        c
      })).height
      let here-page = here().page()
      let prior = query(selector(footnote).before(here())).filter(f => f.location().page() == here-page).map(f => f.body)
      let all = prior + notes.map(inl)
      let need = note-clearance + all.map(entry).sum() + note-gap * all.len()
      if here().position().y + h + need > page.height - page-margin { colbreak(weak: true) }
    }
  }
  blk
}

/// A lettered list: a), b), ... (the markdown item number as a letter; a loose list is one chunk per item) half an
/// inch in, the text hanging (docx: List Letter). An item is (number or none for a bullet, text, its footnotes).
#let letter-list(items) = {
  for (num, item, notes) in items {
    note-carry(notes, block(width: 100%, above: 0pt, below: 0pt, pad(left: list-indent,
      par(first-line-indent: 0pt, hanging-indent: letter-box,
        [#box(width: letter-box)[#if num == none [•] else { numbering("a)", num) }]#unloose(inl(item))]))))
  }
}

/// Walk the markdown body chunk by chunk.
#let motion-body(md, prefix) = {
  // Footnote definitions are rendered with the chunk that cites them: cmarker sees a reference and its
  // definition in the same call, and the definition lines are taken out of the body here.
  let defs = (:)
  for m in md.matches(regex("(?m)^\\[\\^([^\\]]+)\\]:[ \\t]*(.*)$")) {
    defs.insert(m.captures.at(0), m.captures.at(1))
  }
  let text = md.replace(regex("(?m)^\\[\\^[^\\]]+\\]:.*$"), "")
  let chunks = text.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let refs-of(s) = s.matches(regex("\\[\\^([^\\]]+)\\]")).map(m => m.captures.at(0)).dedup()
  let notes-of(s) = refs-of(s).map(l => defs.at(l))
  let with-notes(s) = {
    let refs = refs-of(s)
    s + refs.map(l => "\n\n[^" + l + "]: " + defs.at(l)).join()
  }
  let numbered = false
  let counts = (0, 0, 0, 0, 0, 0)
  let n = 0
  let out = ()
  for c in chunks {
    let k = chunk-kind(c)
    if k == "heading" {
      let level = calc.min(c.match(regex("^(#+)")).captures.at(0).len(), 4)
      let title = c.replace(regex("^#+[ \t]*"), "")
      if level <= 2 { numbered = prefix != none and title.starts-with(prefix) }
      counts.at(level - 1) += 1
      for q in range(level, 6) { counts.at(q) = 0 }
      let label = if level == 3 { numbering("A.", counts.at(2)) } else if level == 4 { numbering("1.", counts.at(3)) } else { none }
      out.push(heading-block(level, label, title))
    } else if k == "quote" {
      out.push(quote-block(with-notes(c.replace(regex("(?m)^>[ \t]?"), ""))))
    } else if k == "list" {
      let item-re = regex("^(\\d+\\.|[-*+])[ \\t]+")
      out.push(letter-list(c.split("\n").map(l => l.trim()).filter(l => l.starts-with(item-re))
        .map(l => {
          let d = l.match(regex("^(\\d+)\\."))
          let s = l.replace(item-re, "")
          (if d == none { none } else { int(d.captures.at(0)) }, with-notes(s), notes-of(s))
        })))
    } else if numbered {
      n += 1
      out.push(note-carry(notes-of(c), body-par[#box(width: number-box)[#n.]#unloose(inl(with-notes(c)))]))
    } else {
      out.push(note-carry(notes-of(c), body-par(inl(with-notes(c)))))
    }
  }
  out
}

/// Place the chunks, then the signature. The last two chunks (a closing heading and its paragraph, or a
/// lead-in and its list) go on one page with the signature block, so a signature never stands alone.
#let place-with-signature(parts, sig-block) = {
  let keep = calc.max(0, parts.len() - 2)
  for p in parts.slice(0, keep) { p }
  block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
    for p in parts.slice(keep) { p }
    sig-block
  })
}

#let motion-part(meta, md) = {
  court-title(meta)
  caption(meta)
  title-block(title-above, title-below, upper(need(meta, "title")))
  let parts = motion-body(md, meta.at("numbered_section", default: none))
  place-with-signature(parts, signature-block(need(meta, "signature")))
}

// ---------------------------------------------------------------------------
// The filing
// ---------------------------------------------------------------------------

#let scb-motion-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "bankruptcy", "caption", "title", "signature") {
    let _ = need(meta, k)
  }

  set document(title: need(meta, "title"), author: need(meta, "signature").signer)
  // Every page numbered, bottom centre; the number in a single-spaced line box (Word's footer).
  set page(
    paper: "us-letter",
    margin: page-margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, footnote marks at 58 %, a section sign kept with its number. No markdown lists reach typst's list
  // layout (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)

  // Footnotes: the type size, single-spaced, a short rule above them (docx: Footnote Text).
  set footnote.entry(separator: line(length: 30%, stroke: 0.5pt), gap: note-gap, clearance: note-clearance, indent: 0pt)
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  if "notice" in meta and meta.notice != none {
    notice-part(meta)
    pagebreak()
  }
  motion-part(meta, md)
}
