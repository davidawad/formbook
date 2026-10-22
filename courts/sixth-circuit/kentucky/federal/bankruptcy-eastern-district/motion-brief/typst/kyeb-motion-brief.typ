// U.S. Bankruptcy Court, Eastern District of Kentucky: motion with memorandum (FRBP 9013; LBR 9013-1).
//
// Rule-driven and content-agnostic. Requirement IDs (KYEB-...) refer to ../README.md, which quotes the
// rule text (FRBP 9004, 9011, 9013, 9014; KYEB LBR 9013-1, 9014-1). No case-specific text, no coordinates
// measured off an exemplar, no forced line breaks. The body is markdown rendered by cmarker; the metadata
// comes from the YAML frontmatter of the same file (schema: ../README.md).
//
// Open choices the filed exemplar settles (usage/FILED-EXAMPLE-motion-brief.pdf, and
// see ../README.md): single-spaced body with a gap between paragraphs; numbered paragraphs; a judge line in
// the caption; the title between two rules; the "/s/" signature block with a rule under the signer's name,
// repeated in the certificate of service; NOTICE after the signature and before the certificate.

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")    // KYEB-FORM-001: no E.D. Ky. bankruptcy rule sets a typeface; Times New Roman, the default per docs/FONTS.md (the exemplar is Times too)
#let type-size = 12pt                    // KYEB-FORM-001: a legible size (FRBP 9004(a)); 12 pt, the usual floor (footnotes too)
#let margins = (top: 1in, bottom: 1in, left: 1in, right: 1in)
#let text-width = 8.5in - margins.left - margins.right
#let para-indent = 0.5in                 // first-line indent of an unnumbered paragraph
#let item-indent = 0.25in                // numbered paragraph: the number sits here from the margin...
#let item-text = 0.6in                   // ...and the text hangs from here
#let bullet-indent = 0.5in               // a bulleted item: the bullet here, in a box of bullet-box
#let bullet-box = 0.4in
#let caption-left = 3.25in               // the right-hand column starts at the middle of the text block
#let caption-pad = 0.2in                 // the caption's columns stand this far apart from the middle
#let designation-indent = 1.8in          // caption: "Plaintiff,", "Defendant."
#let rule-stroke = 0.75pt                // the rules around the title and under the signer (docx: w:sz 6)

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/kyeb-motion-brief.lua sets the same twips,
// 20 x pt). Every block carries its space below it, none above, so no space is lost or kept at the top of a page.
#let pitch = 14pt                        // KYEB-FORM-003: single spacing, body and all (the exemplar)
#let gap = 12pt                          // KYEB-FORM-003: the one vertical gap, between paragraphs and blocks
#let half-gap = 6pt                      // caption: "In re:" to the debtor, the case number to the chapter, "v."; the title to its rules
#let court-below = 18pt                  // the court's name to the caption
#let judge-above = 18pt                  // caption: the chapter to the judge line
#let row-gap = 12pt                      // caption: the debtors to the parties of an adversary caption
#let cert-gap = 3pt                      // between the paragraphs of the certificate of service
#let note-gap = 6pt                      // between two footnotes
#let note-clearance = 12pt               // the body text to the footnote rule
#let footer-distance = 0.3in             // the page number line stands this far above the foot of the page (docx: footer 432 twips)

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Inline content without the paragraph breaks cmarker may put around it (they may not occur inside a paragraph).
#let unloose(body) = {
  if type(body) != content or body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

#let need(meta, key) = {
  if key not in meta { panic("kyeb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("kyeb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One line (a paragraph of its own), with an explicit space above or below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, center: false, sticky: false, body) = block(width: 100%,
  above: above, below: below, sticky: sticky,
  pad(left: left, align(if center { std.center } else { start },
    par(first-line-indent: 0pt, hanging-indent: 0pt, unloose(body)))))

// ---------------------------------------------------------------------------
// Caption (FRBP 9004(b): court, title of the case, case number and adversary number if any, designation)
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  let court = need(meta, "court")
  for (i, l) in court.enumerate() {
    line-block(center: true, below: if i == court.len() - 1 { court-below } else { 0pt }, strong(inl(l)))
  }
}

#let caption-table(meta) = {
  let cap = need(meta, "caption")
  let debtors = cap.debtors
  let left-top = {
    line-block("In re:")
    for (i, n) in debtors.names.enumerate() { line-block(above: if i == 0 { half-gap } else { 0pt }, inl(n)) }
    line-block(inl(debtors.designation))
  }
  let right-top = {
    line-block([Case No. #need(meta, "case_number")])
    if need(meta, "jointly_administered") { line-block([(Jointly Administered)]) }
    line-block(above: half-gap, inl(need(meta, "chapter")))
    if "judge" in meta { line-block(above: judge-above, inl(meta.judge)) }
  }
  // An adversary caption has parties on the left; a main-case motion has the debtors only.
  let parties = cap.at("parties", default: ())
  let left-bottom = {
    for (i, side) in parties.enumerate() {
      for n in side.names { line-block(inl(n)) }
      line-block(left: designation-indent, inl(side.designation))
      if i < parties.len() - 1 { line-block(above: half-gap, below: half-gap, [v.]) }
    }
  }
  let right-bottom = {
    let adv = meta.at("adversary_number", default: "")
    if adv != "" { line-block([Adv. No. #adv]) }
  }
  let cells = (
    grid.cell(inset: (right: caption-pad), left-top),
    grid.cell(inset: (left: caption-pad), right-top),
  )
  if parties.len() > 0 {
    cells += (
      grid.cell(inset: (top: row-gap, right: caption-pad), left-bottom),
      grid.cell(inset: (top: row-gap, left: caption-pad), right-bottom),
    )
  }
  block(above: 0pt, below: gap, grid(columns: (caption-left, text-width - caption-left), ..cells))
}

/// The title sits between two rules, bold and centred, as in the exemplar.
#let title-block(meta) = block(width: 100%, above: 0pt, below: gap, grid(columns: 100%,
  grid.cell(stroke: (top: rule-stroke, bottom: rule-stroke), inset: (y: half-gap),
    align(center, par(first-line-indent: 0pt, strong(need(meta, "title").map(inl).join(" ")))))))

// ---------------------------------------------------------------------------
// Notice of opportunity for hearing (LBR 9013-1(a)) and hearing date (LBR 9014-1(a))
// ---------------------------------------------------------------------------

/// Printed under the title when the motion is set for hearing or with an objection deadline.
#let hearing-notice(meta) = {
  let h = meta.at("hearing", default: none)
  if h != none {
    let rows = ()
    if "date" in h { rows.push([Hearing: #h.date]) }
    if "time" in h { rows.push([Time: #h.time]) }
    if "place" in h { rows.push([Place: #h.place]) }
    if "objection_deadline" in h { rows.push([Objections due: #h.objection_deadline]) }
    for (i, r) in rows.enumerate() { line-block(below: if i == rows.len() - 1 { gap } else { 0pt }, r) }
  }
}

// ---------------------------------------------------------------------------
// Body: unnumbered paragraphs are first-line indented; numbered paragraphs run on through the motion;
// headings are typed by the author
// ---------------------------------------------------------------------------

#let footnote-def = regex("^\\[\\^([^\\]]+)\\]:[ \\t]*([\\s\\S]*)$")
#let footnote-ref = regex("\\[\\^([^\\]]+)\\]")

/// Inline content of a paragraph. Each `[^key]` becomes a footnote whose text is the definition `key`.
#let with-notes(t, notes) = {
  let out = []
  let rest = t
  let m = rest.match(footnote-ref)
  while m != none {
    out += unloose(inl(rest.slice(0, m.start)))
    out += footnote(unloose(inl(notes.at(m.captures.at(0)))))
    rest = rest.slice(m.end)
    // Markdown trims the leading space of the text after a footnote mark, so the space is put back here.
    if rest.starts-with(" ") {
      out += [ ]
      rest = rest.slice(1)
    }
    m = rest.match(footnote-ref)
  }
  out + unloose(inl(rest))
}

/// Split a chunk of list lines ("N. text", "- text") into its items. A line that does not start an item
/// continues the item above it, so a wrapped line of markdown stays in its paragraph.
#let list-items(t) = {
  let items = ()
  for line in t.split(regex("\\r?\\n")) {
    let m = line.match(regex("^\\s*(?:\\d+\\.|[-*+])[ \\t]+"))
    if m != none {
      items.push(line.slice(m.end).trim())
    } else if items.len() > 0 {
      items.at(-1) += " " + line.trim()
    }
  }
  items
}

/// Headings: level 1 centred bold capitals; level 2 centred bold; level 3 bold at the margin; kept with the block
/// after them.
#let heading-block(level, s) = block(width: 100%, above: 0pt, below: gap, sticky: true, {
  set par(first-line-indent: 0pt)
  if level == 1 { align(center, strong(upper(unloose(inl(s))))) }
  else if level == 2 { align(center, strong(unloose(inl(s)))) }
  else { strong(unloose(inl(s))) }
})

#let body-blocks(body, notes) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  // The paragraph numbers run on through the whole motion, as the exemplar's do; the author types none that count.
  let n = 0
  for t in chunks {
    if t.match(footnote-def) != none { continue }
    if t.starts-with("#") {
      let level = t.match(regex("^(#+)")).captures.at(0).len()
      heading-block(level, t.replace(regex("^#+[ \t]*"), ""))
    } else if t.match(regex("^\\d+\\.[ \\t]")) != none {
      for it in list-items(t) {
        n += 1
        block(width: 100%, above: 0pt, below: gap, pad(left: item-indent,
          par(first-line-indent: 0pt, hanging-indent: item-text - item-indent,
            [#box(width: item-text - item-indent)[#n.]#with-notes(it, notes)])))
      }
    } else if t.match(regex("^[-*+][ \\t]")) != none {
      for it in list-items(t) {
        block(width: 100%, above: 0pt, below: gap, pad(left: bullet-indent,
          par(first-line-indent: 0pt, hanging-indent: bullet-box, [#box(width: bullet-box)[•]#with-notes(it, notes)])))
      }
    } else {
      block(width: 100%, above: 0pt, below: gap,
        par(first-line-indent: (amount: para-indent, all: true), with-notes(t, notes)))
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (FRBP 9011(a)), NOTICE, and certificate of service (FRBP 9014(b), by convention)
// ---------------------------------------------------------------------------

/// The "/s/" block at the right of the page, with a rule under the signer's name. The exemplar repeats it in
/// the certificate of service, so it is one function; `opening` adds "Respectfully Submitted,". The rule takes
/// its own width below the line (as Word's paragraph border does).
#let signature-block(meta, opening: true) = {
  let sig = need(meta, "signature")
  block(width: 100%, breakable: false, above: 0pt, below: gap, grid(
    columns: (text-width - caption-left, caption-left),
    [],
    {
      if opening { line-block(below: gap, [Respectfully Submitted,]) }
      block(width: 100%, above: 0pt, below: 0pt, stroke: (bottom: rule-stroke), inset: (bottom: rule-stroke),
        par(first-line-indent: 0pt, [/s/ #inl(sig.signer)]))
      if "firm" in sig { line-block(inl(sig.firm)) }
      for l in sig.at("lines", default: ()) { line-block(inl(l)) }
    },
  ))
}

#let notice-block(meta) = {
  let n = meta.at("notice", default: none)
  if n != none {
    line-block(center: true, below: gap, sticky: true, strong[NOTICE])
    block(width: 100%, above: 0pt, below: gap, par(first-line-indent: 0pt, unloose(inl(n))))
  }
}

/// The certificate is kept whole, with its signature block.
#let certificate-block(meta) = {
  let cert = meta.at("certificate_of_service", default: none)
  if cert != none {
    block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
      line-block(center: true, below: gap, strong(upper("Certificate of Service")))
      block(width: 100%, above: 0pt, below: half-gap, {
        set par(first-line-indent: 0pt, spacing: cert-gap)
        cmarker.render(cert.text, raw-typst: false, smart-punctuation: true)
      })
      signature-block(meta, opening: false)
    })
  }
}

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

#let kyeb-motion-brief(meta, body) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "caption", "chapter", "case_number", "jointly_administered", "title", "date", "signature") {
    let _ = need(meta, k)
  }
  let notes = (:)
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")) {
    let m = c.trim().match(footnote-def)
    if m != none { notes.insert(m.captures.at(0), m.captures.at(1)) }
  }

  // ---- document-wide settings ----
  // Every page numbered, bottom centre (KYEB-FORM-004); the number in a single line box (Word's footer).
  set page(
    paper: "us-letter",
    margin: margins,
    footer: context align(center + bottom, pad(bottom: footer-distance,
      text(..edges(pitch), counter(page).display()))),
  )
  set document(
    title: need(meta, "title").join(" ") + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // pitch, footnote marks at 58 %, a section sign kept with its number. No markdown list reaches typst's list
  // layout (the template sets the items itself).
  show: xengine.with(pitch: pitch, list-indent: none)
  // A doubled section sign stays with its number too ("§§ 362"; the Word filter binds it too, bind_double): a
  // no-break space after the signs.
  show regex("[§¶]{2,} "): it => it.text.trim() + "\u{00A0}"
  set footnote.entry(separator: line(length: 30%, stroke: 0.5pt), gap: note-gap, clearance: note-clearance, indent: 0pt)
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch))
    set par(first-line-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  // ---- first page: court, caption, title, hearing notice ----
  court-title(meta)
  caption-table(meta)
  title-block(meta)
  hearing-notice(meta)

  // ---- body ----
  body-blocks(body, notes)

  signature-block(meta)
  notice-block(meta)
  certificate-block(meta)
}
