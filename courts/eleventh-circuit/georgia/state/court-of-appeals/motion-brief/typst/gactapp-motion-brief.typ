// Georgia Court of Appeals: motion (motion-brief). Rule-driven and content-agnostic.
//
// Rules: Court of Appeals of Georgia Rules, effective March 26, 2026,
// https://www.gaappeals.gov/wp-content/uploads/2026/03/COA-Rules-Complete-Eff-26-March-26.pdf
// (read 2026-10-16 from the Wayback Machine copy; see ../README.md). Rule 41 (b): motions are
// prepared in accordance with Rule 24 (preparation of briefs) and limited to 4,200 words as
// certified by the filer. No case-specific text, no coordinates measured off an exemplar, no
// forced line breaks. The body is markdown rendered by cmarker; the cover, caption, signature
// and certificates come from the YAML frontmatter of the same sample file.
//
// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box
// of its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the
// space below the one and above the other (Word's exact line spacing). ../docx/gactapp-motion.lua writes the same
// layout in the same twips (20 x pt), so the docx breaks every line and page where this render does.

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (the only numbers here; each traces to a rule, a named substitute, or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // Rule 2 (c) (3) names Times New Roman as a compliant face (data/exemplar-fonts.json; docs/FONTS.md rule 6)
#let type-size = 14pt                   // Rule 2 (c) (3): serif, proportionally spaced, 14-point or larger, footnotes included
#let pitch-body = 32.2pt                // Rule 2 (c) (2): no less than double spacing (2 x Word's 16.1 pt single line at 14 pt)
#let pitch-single = 16.1pt              // Rule 2 (c) (2) exclusions: caption, headings, block quotations, footnotes; cover, tables, signature, page number
#let half = pitch-single / 2            // half a single line: below headings, between table rows and quotation paragraphs, between footnotes
#let note-clearance = 11.5pt           // the text to the footnote rule: with the rule and half a line, the 20.1 pt Word (LibreOffice) leaves above the first note
#let margin = 1in                       // Rule 24 (c): not less than one inch at top, sides and bottom
#let footer-descent = 30%               // Rule 24 (e): the page number at the bottom of the page, in the bottom margin
#let para-indent = 0.5in
#let role-indent = 3.25in               // a party's designation under its name, from the middle of the line (exemplar)
#let title-inset = 0.4875in             // the cover title in the middle 85 % of the line
#let sig-indent = 2.5in                 // the signature block
#let counsel-gutter = 0.25in            // between the two columns of cover counsel
#let recipient-indent = 1in             // the certificate of service's addressees
#let toc-hang = 0.5in                   // a wrapped contents row hangs this far; deeper levels start this far in per level
#let toa-hang = 21pt                    // a wrapped authority hangs this far
#let toc-col = 36pt                     // the contents' page column
#let toa-col = 56pt                     // the authorities' page column, or the page list's own width when wider
#let toc-depth = 3
#let word-count-text = "This submission does not exceed the word count limit imposed by Rule 24."  // Rules 24 (f) (1), 41 (b): mandated wording

#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("gactapp-motion-brief: missing required frontmatter field `" + key + "`") }
  meta.at(key)
}

#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("gactapp-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-spaced paragraph with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, right: 0pt, sticky: false, breakable: true, body) = block(
  width: 100%, above: above, below: below, sticky: sticky, breakable: breakable, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt)
    pad(left: left, right: right, body)
  })

/// A body paragraph at the body pitch, its first line indented.
#let body-par(body, above: 0pt) = block(width: 100%, above: above, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), body))

// ---------------------------------------------------------------------------
// Cover: court title, case number, caption, title of the motion, counsel (own page)
// ---------------------------------------------------------------------------

/// `own-page: false` (`cover_page: false`): no counsel and no page break; the text starts a double line below the title.
#let cover(meta, own-page) = {
  line-block(align(center, strong(upper(need(meta, "court")))))
  line-block(above: pitch-single, align(center, strong[Case No. #need(meta, "case_number")]))
  for (i, p) in need(meta, "parties").enumerate() {
    line-block(above: if i == 0 { pitch-body } else { pitch-single }, align(center, inl(p.name)))
    if p.role != "" { line-block(left: role-indent, emph(inl(p.role))) }
  }
  if "lower_court_case" in meta {
    line-block(above: pitch-single, align(center, inl(meta.lower_court_case)))
  }
  line-block(above: pitch-body, below: if own-page { 0pt } else { pitch-body }, left: title-inset, right: title-inset,
    align(center, strong(upper(inl(need(meta, "title"))))))
  if not own-page { return }
  // Counsel (exemplar): a group without lines (a "Counsel for ..." line) centered across the page; the others two to
  // a row in half-width columns, names bold, each column single-spaced.
  let column(g) = for r in g.names.map(n => strong(inl(n))) + g.lines.map(inl) { line-block(r) }
  let pending = ()
  let above = pitch-body
  let flush(groups, above) = block(width: 100%, above: above, below: 0pt, breakable: false,
    grid(columns: (1fr, 1fr), column-gutter: counsel-gutter, ..groups.map(column), ..(if groups.len() == 1 { ([],) } else { () })))
  for g in meta.at("counsel", default: ()) {
    if g.lines.len() == 0 {
      if pending.len() > 0 { flush(pending, above); pending = (); above = pitch-single }
      for n in g.names { line-block(above: above, align(center, inl(n))); above = 0pt }
      above = pitch-single
    } else {
      pending.push(g)
      if pending.len() == 2 { flush(pending, above); pending = (); above = pitch-single }
    }
  }
  if pending.len() > 0 { flush(pending, above) }
  pagebreak()
}

// ---------------------------------------------------------------------------
// Table of contents and table of authorities (optional; Rule 25 (a) (1) by analogy through Rule 41 (b) -> Rule 24)
// Each authority's `find` string is marked wherever it appears in the body; the table lists the pages.
// ---------------------------------------------------------------------------

#let mark-authorities(meta, content) = {
  let out = content
  for group in meta.at("authorities", default: ()) {
    for e in group.entries {
      if "find" in e {
        let key = e.find
        out = {
          show key: it => it + [#metadata(key)<gactapp-toa>]
          out
        }
      }
    }
  }
  out
}

#let table-title(t) = line-block(below: pitch-single, align(center, strong(upper(t))))

#let contents() = context {
  table-title[Table of Contents]
  for (i, h) in query(heading.where(outlined: true)).filter(h => h.level <= toc-depth).enumerate() {
    let pg = str(counter(page).at(h.location()).first())
    let ind = (h.level - 1) * toc-hang
    block(above: if i == 0 { 0pt } else { half }, below: 0pt, width: 100%, {
      set text(..edges(pitch-single))
      pad(left: ind, listing-row(h.location(), h.body, pg, toc-col, toc-hang, 0pt))
    })
  }
  pagebreak()
}

#let toa-pages(key) = {
  let pages = query(<gactapp-toa>)
    .filter(m => m.value == key)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
    .sorted()
  if pages.len() == 0 { "--" } else { pages.map(str).join(", ") }
}

#let authorities-table(meta) = {
  heading(level: 1)[Table of Authorities]
  for group in meta.authorities {
    line-block(above: pitch-single, below: half, sticky: true, strong(group.heading))
    for e in group.entries {
      context {
        let pg = if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") }
        // the page column: 56 pt, or the page list's width when wider, in whole twips (as the docx writes it)
        let col = calc.max(toa-col, calc.ceil(measure(text(pg)).width.pt() * 20) / 20 * 1pt)
        block(above: half, below: 0pt, width: 100%, {
          set text(..edges(pitch-single))
          listing-row(none, inl(e.cite), pg, col, toa-hang, 0pt)
        })
      }
    }
  }
  pagebreak()
}

// ---------------------------------------------------------------------------
// Certificates and signature block
// ---------------------------------------------------------------------------

/// Rule 2 (a) (2) (ii): "/s/" and the typed name, underlined; the typed name again below the underline.
#let signature-rows(sig, short: false) = {
  let rows = (underline(inl(need(sig, "signer_line"))),)
  if "name" in sig { rows.push(inl(sig.name)) }
  let rest = sig.at("signer", default: ())
  rows + (if short { rest.slice(0, calc.min(1, rest.len())) } else { rest }).map(inl)
}

/// Rule 24 (f) (1) / Rule 41 (b): the certification just above the signature block; the date line; the signature.
/// Kept on one page.
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  // the space above stands on the unbreakable block: typst drops a block's first space inside it
  block(breakable: false, above: half, below: 0pt, width: 100%, {
    body-par[#word-count-text]
    if "date" in sig { body-par[Respectfully submitted this #inl(sig.date).] }
    let lines = sig.at("lines", default: ()).map(inl)
    let rows = signature-rows(sig)
    for (i, r) in lines.enumerate() { line-block(above: if i == 0 { pitch-single } else { 0pt }, left: sig-indent, r) }
    for (i, r) in rows.enumerate() {
      line-block(above: if i == 0 { pitch-single } else { 0pt }, left: sig-indent, r)
    }
  })
}

/// Rule 6: the certificate of service on a page of its own; the statement, the addressees, the closing and the
/// signer's /s/ line, name and first line. The last addressee is kept with the closing and the signature.
#let certificate-of-service(meta) = {
  let svc = need(meta, "service")
  let sig = need(meta, "signature")
  pagebreak(weak: true)
  heading(level: 1)[Certificate of Service]
  if "paragraphs" in svc {
    for p in svc.paragraphs { body-par(inl(p)) }
  } else {
    body-par[I certify that on #svc.date, I served a copy of this #svc.doc_type on #svc.served_on by #svc.method, addressed as follows:]
  }
  let recips = if "recipients" in svc { svc.recipients } else { (svc.at("address", default: ()),) }
  // each addressee a single line below the text before it, the space on the unbreakable block (typst drops a
  // block's first space inside it)
  let addressee(r) = for l in r { line-block(left: recipient-indent, inl(l)) }
  for r in recips.slice(0, calc.max(0, recips.len() - 1)) {
    block(breakable: false, above: pitch-single, below: 0pt, width: 100%, addressee(r))
  }
  block(breakable: false, above: pitch-single, below: 0pt, width: 100%, {
    if recips.len() > 0 { addressee(recips.last()) }
    if "closing" in svc { body-par(above: if recips.len() > 0 { pitch-single } else { 0pt }, inl(svc.closing)) }
    for (i, r) in signature-rows(sig, short: true).enumerate() {
      line-block(above: if i == 0 and (recips.len() > 0 or "closing" in svc) { pitch-single } else { 0pt },
        left: sig-indent, r)
    }
  })
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let gactapp-motion-brief(meta, body) = {
  set document(title: need(meta, "title"))
  // Rule 24 (e): every page numbered sequentially with an Arabic numeral at the bottom, the cover included; the
  // number centered in a single line box (Word's footer).
  set page(paper: "us-letter", margin: margin, footer-descent: footer-descent,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, lists with the label in a half-inch box.
  show: xengine.with(pitch: pitch-body, list-indent: para-indent)
  // A doubled sign stays with its number ("§§ 21-2-501(a)(1)"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)
  set par(first-line-indent: (amount: para-indent, all: true))

  // Block quotations: single-spaced, half an inch in on both sides, half a line from the text and between their
  // paragraphs.
  show quote.where(block: true): it => block(width: 100%, above: half, below: half, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, spacing: half)
    pad(left: para-indent, right: para-indent, it.body)
  })
  // Footnotes: 14 pt (Rule 2 (c) (3)) in single line boxes, half a line apart; the mark, a space, the note.
  set footnote.entry(gap: half, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    // one unbreakable block: Word keeps a note's lines together (Footnote Text)
    block(breakable: false, mark-authorities(meta, [#super(num) #note.body]))
  }
  // Headings: single-spaced, bold, a single line above, half a line below, kept with the text after them.
  // Level 1 centered capitals; levels 2 and 3 at the margin, wrapped lines hanging half an inch (level 3 italic).
  show heading: it => {
    let body = text(size: type-size, weight: "bold", style: if it.level == 3 { "italic" } else { "normal" },
      if it.level == 1 { upper(it.body) } else { it.body })
    line-block(above: pitch-single, below: half, sticky: true,
      if it.level == 1 { align(center, par(body)) } else { par(hanging-indent: para-indent, body) })
  }

  // A separate cover page is the default (both filed exemplars of this court's motions use one).
  cover(meta, meta.at("cover_page", default: true))
  if meta.at("toc", default: false) { contents() }
  if "authorities" in meta { authorities-table(meta) }

  mark-authorities(meta, cmarker.render(body, raw-typst: false, smart-punctuation: true))

  signature-block(meta)
  certificate-of-service(meta)
}
