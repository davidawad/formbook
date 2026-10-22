// Court of Appeals of Georgia (gactapp): answering brief (see the doc-type name in the README).
//
// Content-agnostic. Every number is a named parameter below and traces to the rule
// cited next to it (Court of Appeals of Georgia Rules, effective March 26, 2026,
// https://www.gaappeals.gov/wp-content/uploads/2026/03/COA-Rules-Complete-Eff-26-March-26.pdf,
// read 2026-10-16 from the Wayback Machine copy; see ../README.md). No case-specific text,
// no coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the
// sample (schema: ../README.md, "Markdown contract").
//
// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing). The docx engine (docx/gactapp-brief.lua,
// docx/reference.xml) sets the same pitches and spaces, in twips (20 x pt), so it breaks every line and page alike.

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")     // Rule 2 (c) (3) names Times New Roman as a compliant face; Liberation Serif is its metric-compatible substitute (docs/FONTS.md).
#let type-size = 14pt                      // Rule 2 (c) (3): serif, proportionally spaced, 14-point or larger (footnotes included).
#let pitch-double = 32.2pt                 // Rule 2 (c) (2): no less than double spacing: twice the 16.1 pt single line of
                                           // Times New Roman at 14 pt (Word's "double").
#let pitch-single = 16.1pt                 // Rule 2 (c) (2) excludes block quotations, headings, captions and footnotes: single-spaced.
#let title-size = 16pt                     // the cover's brief title
#let pitch-title = 18.4pt                  // its single line
#let gap = 16.1pt                          // a blank single line: around quotations, between their paragraphs, around recipients
#let gap-small = 8pt                       // between table rows, footnotes, counsel groups
#let head1-above = 24pt                    // section headings (level 1)
#let head1-below = 16pt
#let head2-above = 16pt                    // sub-headings (levels 2 and 3)
#let head2-below = 12pt
#let cover-gap = 21.6pt                    // between the parts of the cover caption (0.3 in)
#let cover-title-gap = 72pt                // above the brief title and above the counsel on the cover (1 in)
#let page-margin = 1in                     // Rule 24 (c): not less than one inch at top, sides and bottom.
#let footer-descent = 19.9pt               // the page number's line ends 0.5 in above the page edge (1 in - 19.9 pt - 16.1 pt)
#let para-indent = 0.5in
#let toc-depth = 3
#let toc-step = 0.5in                      // each contents level steps in by this, and its wrapped lines by as much again
#let toc-page-col = 36pt                   // the contents' page numbers keep the last 36 pt of the line to themselves
#let toa-page-col = 56pt                   // the authorities' page lists ("8, 15") keep 56 pt
#let toa-hang = 0.5in
#let note-clearance = 8.1pt                // above the footnote separator; with the entry gap below it, one single line (16.1 pt), the room LibreOffice keeps above the notes for its separator
#let sig-indent = 3.2in                    // signature block starts right of centre (style; exemplars do the same).
#let sig-firm-gap = 12pt                   // below the firm name, and between signers
#let recipient-indent = 1in
#let word-count-text = "This submission does not exceed the word count limit imposed by Rule 24."  // Rule 24 (f) (1): mandated wording.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("gactapp-answering-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("gactapp-answering-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One single-spaced line (or wrapped paragraph) of its own, `above` clear of the one before.
#let line-block(above, body, align-to: left, sticky: false) = block(width: 100%, above: above, below: 0pt,
  sticky: sticky, align(align-to, par(first-line-indent: 0pt, body)))

/// One caption side: centred names, then the designation.
#let caption-side(side, above) = {
  for (j, n) in side.names.enumerate() { line-block(if j == 0 { above } else { 0pt }, inl(n), align-to: center) }
  line-block(0pt, emph(side.designation), align-to: center)
}

/// Signers of the signature block. Rule 2 (a) (2) (ii): "/s/" and the typed name, underlined,
/// with the typed name again below the underline; Rule 2 (a): bar number, address, phone, e-mail.
#let signers(sig) = {
  if "signers" in sig { sig.signers } else { ((name: need(sig, "signer"), lines: ()),) }
}

/// The signature block, single-spaced, `sig-indent` from the margin, kept whole and with what comes before it.
#let signature-block(sig, above, first-only: false) = {
  let all = signers(sig)
  let list = if first-only { (all.first(),) } else { all }
  let row(above, body) = block(width: 100%, above: above, below: 0pt, sticky: true,
    pad(left: sig-indent, par(first-line-indent: 0pt, body)))
  block(width: 100%, breakable: false, above: above, below: 0pt, {
    set text(..edges(pitch-single))
    let next = 0pt
    if "firm" in sig { row(0pt, strong(sig.firm)); next = sig-firm-gap }
    for (i, s) in list.enumerate() {
      row(if i > 0 { sig-firm-gap } else { next }, underline[/s/ #emph(s.name)])
      row(0pt, s.name)
      for l in s.at("lines", default: ()) { row(0pt, inl(l)) }
    }
    for (i, l) in sig.at("lines", default: ()).enumerate() { row(if i == 0 { gap-small } else { 0pt }, inl(l)) }
  })
}

/// Table of authorities. Each entry carries `find`: a string that appears in every citation of
/// the authority in the body (e.g. the volume and reporter, "324 Ga. App."). A show rule on that
/// string drops a marker after each occurrence; the table lists the pages of the markers.
#let toa-marker(key) = [#metadata(key)<gactapp-toa>]

#let mark-authorities(meta, content) = {
  let out = content
  for group in meta.at("authorities", default: ()) {
    for e in group.entries {
      if "find" in e {
        let key = e.find
        out = {
          show key: it => it + toa-marker(key)
          out
        }
      }
    }
  }
  out
}

#let toa-pages(key) = context {
  let pages = query(<gactapp-toa>)
    .filter(m => m.value == key)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
    .sorted()
  if pages.len() == 0 { "--" } else { pages.map(str).join(", ") }
}

#let authorities-table(meta) = {
  heading(level: 1, outlined: true)[Table of Authorities]
  set text(..edges(pitch-single))
  for group in meta.authorities {
    line-block(gap, strong(inl(group.heading)), sticky: true)
    for e in group.entries {
      let pages = if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") }
      listing-row(none, inl(e.cite), pages, toa-page-col, toa-hang, gap-small)
    }
  }
}

/// Table of contents (Rule 25 (a) (1)): every heading to `toc-depth` with the page it starts on.
#let contents() = context {
  set text(..edges(pitch-single))
  block(width: 100%, above: 0pt, below: gap, align(center, par(first-line-indent: 0pt, strong[TABLE OF CONTENTS])))
  for hd in query(heading.where(outlined: true)).filter(h => h.level <= toc-depth) {
    let ind = (hd.level - 1) * toc-step
    let pg = str(counter(page).at(hd.location()).first())
    listing-row(hd.location(), [#h(ind)#hd.body], pg, toc-page-col, ind + toc-step, gap-small)
  }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let gactapp-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // Rule 24 (e): every page numbered sequentially with an Arabic numeral at the bottom; the cover is page 1. The
  // number sits centered in a single line box, so it stands at the same place on every page (Word's footer).
  set page(paper: "us-letter", margin: page-margin, numbering: "1", footer-descent: footer-descent,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("1"))))
  set text(font: font-family, size: type-size, lang: "en")
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, no kerning or ligatures, no hyphenation, line boxes of the body pitch,
  // footnote marks at 58 %, a section sign kept with its number, no break inside "60(b)(5)".
  show: xengine.with(pitch: pitch-double, list-indent: para-indent)
  // A doubled sign stays with its number ("¶¶ 2"), as one sign does (the docx filter binds them alike).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // typst breaks after a slash before a letter; the docx filter allows the same break.
  set heading(numbering: none)

  // Heading levels in the markdown body: level 1 is a section (centred, capitals, bold);
  // level 2 and 3 are sub-headings (bold, left; level 3 italic too), the wrapped lines hanging half an inch.
  show heading: set text(size: type-size, ..edges(pitch-single))
  show heading.where(level: 1): it => block(width: 100%, above: head1-above, below: head1-below, sticky: true,
    align(center, par(first-line-indent: 0pt, strong(upper(it.body)))))
  show heading.where(level: 2): it => block(width: 100%, above: head2-above, below: head2-below, sticky: true,
    par(first-line-indent: 0pt, hanging-indent: para-indent, strong(it.body)))
  show heading.where(level: 3): it => block(width: 100%, above: head2-above, below: head2-below, sticky: true,
    par(first-line-indent: 0pt, hanging-indent: para-indent, strong(emph(it.body))))

  // Block quotations: indented half an inch on both sides, single-spaced (Rule 2 (c) (2) exclusion), a blank single
  // line around them and between their paragraphs.
  show quote.where(block: true): it => block(above: gap, below: gap, pad(left: para-indent, right: para-indent, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, spacing: gap)
    it.body
  }))
  // Footnotes: 14 pt like the text (Rule 2 (c) (3)), single-spaced (Rule 2 (c) (2) exclusion), each kept whole on
  // one page (Word's Footnote Text keeps its lines together), the mark and a space before the text.
  set footnote.entry(gap: gap-small, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    block(breakable: false, mark-authorities(meta, [#super(num) #note.body]))  // citations in footnotes count toward the table of authorities
  }

  // ---- Cover ----
  page({
    set text(..edges(pitch-single))
    line-block(0pt, strong[IN THE COURT OF APPEALS OF THE STATE OF GEORGIA], align-to: center)
    line-block(cover-gap, strong[Case No. #need(meta, "case_number")], align-to: center)
    caption-side(meta.caption.at(0), cover-gap)
    line-block(cover-gap, [v.], align-to: center)
    caption-side(meta.caption.at(1), cover-gap)
    let next = cover-gap
    if "proceeding" in meta { line-block(next, inl(meta.proceeding), align-to: center); next = 0pt }
    if "trial_court_case" in meta { line-block(next, inl(meta.trial_court_case), align-to: center) }
    line-block(cover-title-gap, text(size: title-size, ..edges(pitch-title), strong(upper(inl(need(meta, "brief_title"))))),
      align-to: center)
    let row(above, body) = block(width: 100%, above: above, below: 0pt, pad(left: sig-indent, par(first-line-indent: 0pt, body)))
    for (gi, g) in need(meta, "counsel").enumerate() {
      for (j, n) in g.names.enumerate() {
        row(if j > 0 { 0pt } else if gi == 0 { cover-title-gap } else { gap-small }, strong(n))
      }
      for l in g.lines { row(0pt, inl(l)) }
    }
    if "phone" in meta { row(gap-small, meta.phone) }
  })

  // ---- Table of contents (Rule 25 (a) (1)) ----
  if meta.at("toc", default: true) {
    page(contents())
  }

  // ---- Table of authorities (Rule 25 (a) (1)) ----
  if "authorities" in meta {
    page(authorities-table(meta))
  }

  // ---- Body ----
  mark-authorities(meta, cmarker.render(body, raw-typst: false, smart-punctuation: true))

  // ---- Word-count certification, date, signature block (Rule 24 (f) (1): just above the signature block) ----
  block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
    par(word-count-text)
    if "date" in meta { par(inl(meta.date)) }
    signature-block(need(meta, "signature"), gap-small)
  })

  // ---- Certificate of service (Rules 2 (a), 6) ----
  if "service" in meta {
    let svc = meta.service
    pagebreak(weak: true)
    heading(level: 1)[Certificate of Service]
    for p in svc.at("paragraphs", default: ()) { par(inl(p)) }
    for r in svc.at("recipients", default: ()) {
      block(above: gap, below: gap, breakable: false, pad(left: recipient-indent, {
        set text(..edges(pitch-single))
        for l in r { block(above: 0pt, below: 0pt, par(first-line-indent: 0pt, inl(l))) }
      }))
    }
    if "closing" in svc { par(inl(svc.closing)) }
    signature-block(need(meta, "signature"), gap-small, first-only: svc.at("first_signer_only", default: true))
  }
}
