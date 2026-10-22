// U.S. District Court, District of Montana: brief in support of a motion (memorandum).
//
// Rule-driven and content-agnostic. Rule IDs (MT-...) refer to ../README.md, which quotes the rule
// text: D. Mont. L.R. 1.5 (form of documents), 7.1(d) (briefs: length, table of contents and
// authorities, certificate of compliance). No case-specific text, no coordinates measured off the
// exemplar, no forced line breaks. The markdown body is rendered by cmarker; the metadata comes from
// the YAML frontmatter of the same file (schema: ../README.md).
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // MT-FORM-002: the rules name no face; Times New Roman, the house face (docs/FONTS.md), metric-compatible substitute vendored in /fonts
#let face-name = font-family.first()    // the face the certificate of compliance names
#let type-size = 14pt                   // MT-FORM-002: typewritten in 14-point font (L.R. 1.5(a)(2)), footnotes included
#let margin = 1in                       // MT-FORM-001 (L.R. 1.5(a)(1)): one-inch margins
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let heading-tab = 0.5in                // a heading's label box; each deeper level half an inch in
#let caption-left = 3.4in               // width of the party column of the caption
#let caption-pad = 0.2in                // the caption's text keeps this far from its rule
#let designation-indent = 1.4in         // a party's designation stands this far in
#let counsel-gutter = 0.3in             // between the two columns of counsel
#let sig-left = 3.4in                   // the signature grid: the date column, then the signature column
#let toc-col = 36pt                     // contents: the page numbers keep the last 36 pt of the line to themselves
#let toa-col = 72pt                     // authorities: the page lists keep the last inch of the line to themselves
#let toa-hang = 0.35in                  // authorities: the lines after the first hang this far
#let passim-threshold = 7               // an authority cited on this many pages or more prints "passim"
#let word-limit = 6500                  // MT-LEN-001 (L.R. 7.1(d)(2)(A)): briefs in support of a motion

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 16pt                // a single line at 14 pt (cover, headings, tables, signature, footnotes)
#let pitch-double = 2 * pitch-single    // MT-FORM-003 (L.R. 1.5(a)(2)): double-spaced
#let gap-half = pitch-single            // half a double line: around a heading, between counsel groups, around "v."
#let row-gap = 8pt                      // between the rows of the tables
#let group-gap = 16pt                   // above a group of the table of authorities (Cases, Statutes)
#let note-gap = 7pt                     // between two footnotes
#let note-clearance = 3.5pt             // from the last text line to the separator (with note-gap, the space LibreOffice keeps)

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mtd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, italic role lines, etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

#let need(meta, key) = {
  if key not in meta { panic("mtd-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: below,
  pad(left: left, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    body
  }))

/// Thousands separators for a printed word count: 6496 -> "6,496".
#let commas(n) = {
  let out = ""
  let k = 0
  for ch in str(n).clusters().rev() {
    if k > 0 and calc.rem(k, 3) == 0 { out = "," + out }
    out = ch + out
    k += 1
  }
  out
}

/// Words in the brief, for the certificate of compliance: whitespace-separated tokens of the markdown
/// body that contain a letter or a digit. Footnote labels and the `(toa:KEY)` targets are not words.
/// An approximation of a word processor's count; a `word_count` in the frontmatter overrides it.
#let count-words(md) = {
  let plain = md.replace(regex("\\[\\^[^\\]]*\\]"), " ").replace(regex("\\(toa:[^)]*\\)"), " ")
  plain.split(regex("\\s+")).filter(w => w.find(regex("[A-Za-z0-9]")) != none).len()
}

// ---------------------------------------------------------------------------
// Headings: numbering (the template's, not the author's)
// ---------------------------------------------------------------------------

/// Printed label of a numbered heading: level 2 "I.", 3 "A.", 4 "1.", 5 "a.". Level 1 is unnumbered.
#let heading-num(..n) = {
  let lv = n.pos().len()
  let k = n.pos().last()
  if lv == 2 { numbering("I.", k) } else if lv == 3 { numbering("A.", k) } else if lv == 4 { numbering("1.", k) } else if lv == 5 { numbering("a.", k) } else { "" }
}

/// Left edge of a heading's label: level 2 at the margin, each deeper level half an inch in.
#let label-indent(level) = calc.max(level - 2, 0) * heading-tab

/// The label of a heading element ("" for level 1 and for the certificates).
#let heading-label(hd) = if hd.numbering == none { "" } else {
  heading-num(..counter(heading).at(hd.location()).slice(0, hd.level))
}

// ---------------------------------------------------------------------------
// Tables of contents and authorities (L.R. 7.1(d)(2)(C); MT-CONT-001)
// ---------------------------------------------------------------------------

/// A table's title (centered, bold capitals) and the label of its page column at the right.
#let table-head(title, label) = {
  line-block(align(center, strong(upper(title))))
  line-block(above: gap-half, align(right, strong(label)))
}

#let toc-section() = {
  table-head("Table of Contents", "Page")
  context {
    for hd in query(heading.where(outlined: true)) {
      if hd.level > 3 { continue }
      let lab = heading-label(hd)
      let ind = if hd.level == 1 { 0pt } else { label-indent(hd.level) }
      let box-w = if lab == "" { 0pt } else { heading-tab }
      let pg = str(counter(page).at(hd.location()).first())   // every heading is in the body, numbered from 1
      set text(..edges(pitch-single))
      listing-row(hd.location(), {
        h(ind)
        if lab != "" { box(width: heading-tab, lab) }
        if hd.level == 1 { upper(hd.body) } else { hd.body }
      }, pg, toc-col, ind + box-w, row-gap)
    }
  }
}

#let toa-groups = (
  ("case", "Cases"),
  ("constitution", "Constitutional Provisions"),
  ("statute", "Statutes"),
  ("rule", "Rules"),
  ("regulation", "Regulations"),
  ("other", "Other Authorities"),
)

#let sort-key(a) = lower(a.at("name", default: a.at("cite", default: "")))

/// Table of authorities, built from the `toa:` links found in the body.
#let toa-section(authorities) = {
  table-head("Table of Authorities", "Page(s)")
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("mtd-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    let first = true
    for (kind, title) in toa-groups {
      let members = authorities.pairs()
        .filter(p => p.last().kind == kind and hits.any(h => h.value == p.first()))
        .sorted(key: p => sort-key(p.last()))
      if members.len() == 0 { continue }
      line-block(above: if first { 0pt } else { group-gap }, strong(title))
      first = false
      for (key, a) in members {
        // Distinct printed page labels, in document order.
        let pages = ()
        for h in hits.filter(h => h.value == key) {
          let label = str(counter(page).at(h.location()).first())
          if label not in pages { pages.push(label) }
        }
        let page-text = if pages.len() >= passim-threshold { emph[passim] } else { pages.join(", ") }
        set text(..edges(pitch-single))
        listing-row(none, {
          if "name" in a {
            if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }
            [, ]
          }
          inl(a.cite)
        }, page-text, toa-col, toa-hang, row-gap)
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Cover: counsel (upper left), court title, caption, title of the paper (Appendix C, Form A)
// ---------------------------------------------------------------------------

/// Where the counsel groups split into two columns: the first `k` groups on the left, so that the taller column
/// has as few lines as possible (the first such split). One group stands in the left column alone.
#let counsel-split(groups) = {
  let n = groups.len()
  if n < 2 { return n }
  let lines(gs) = gs.map(g => g.len()).sum(default: 0) + calc.max(gs.len() - 1, 0)
  let best = 1
  for k in range(1, n) {
    if calc.max(lines(groups.slice(0, k)), lines(groups.slice(k))) < calc.max(lines(groups.slice(0, best)), lines(groups.slice(best))) {
      best = k
    }
  }
  best
}

#let counsel-column(groups) = for (i, g) in groups.enumerate() {
  for (j, l) in g.enumerate() { line-block(above: if i > 0 and j == 0 { gap-half } else { 0pt }, inl(l)) }
}

/// The counsel groups in two columns, the role (italic) at the foot of the left column, half a double line below it.
#let counsel-block(meta) = {
  let groups = need(meta, "counsel")
  let k = counsel-split(groups)
  block(width: 100%, above: 0pt, below: 0pt, grid(
    columns: (1fr, 1fr), column-gutter: counsel-gutter,
    {
      counsel-column(groups.slice(0, k))
      line-block(above: gap-half, emph(inl(need(meta, "counsel_role"))))
    },
    counsel-column(groups.slice(k)),
  ))
}

/// One centred line each: the court, the district, the division (Appendix C, Form A).
#let court-title(meta) = {
  let lines = ("IN THE UNITED STATES DISTRICT COURT", "FOR THE DISTRICT OF MONTANA", upper(need(meta, "division")))
  for (i, l) in lines.enumerate() { line-block(above: if i == 0 { pitch-double } else { 0pt }, align(center, strong(l))) }
}

#let caption-table(meta) = {
  let sides = need(meta, "caption")
  block(width: 100%, above: gap-half, below: 0pt, grid(
    columns: (caption-left, 1fr),
    stroke: (x, y) => if x == 0 { (right: 0.75pt, bottom: 0.75pt) } else { none },
    pad(right: caption-pad, bottom: gap-half, {
      for (i, side) in sides.enumerate() {
        if i > 0 { line-block(above: gap-half, below: gap-half)[v.] }
        for n in side.names { line-block(inl(n)) }
        line-block(above: gap-half, left: designation-indent, inl(side.designation))
      }
    }),
    pad(left: caption-pad, {
      line-block[Case No. #need(meta, "case_number")]
      line-block(above: pitch-double, strong(upper(inl(need(meta, "brief_title")))))
    }),
  ))
}

// ---------------------------------------------------------------------------
// Signature and certificates (L.R. 1.5(b), 7.1(d)(2)(E); FRCP 5(b))
// ---------------------------------------------------------------------------

/// The signature block: the date at the left; the preamble lines, then "/s/" over the printed name and the lines.
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  let pre = sig.at("preamble", default: ())
  let right = ()
  for l in pre { right.push(line-block(inl(l))) }
  right.push(line-block(above: if pre.len() > 0 { pitch-double } else { 0pt })[/s/ #sig.signer])
  right.push(line-block(inl(sig.signer)))
  for l in sig.at("lines", default: ()) { right.push(line-block(inl(l))) }
  block(width: 100%, breakable: false, above: pitch-double, below: 0pt, grid(
    columns: (sig-left, 1fr),
    line-block[DATED: #need(meta, "date")],
    right.join(),
  ))
}

/// A certificate: its heading, its text (double-spaced, first line indented), and the signature grid; one block.
#let certificate(title, above, text, left, signer) = block(width: 100%, breakable: false, above: above, below: 0pt, {
  heading(level: 1, numbering: none, title)
  block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: (amount: para-indent, all: true), text))
  block(width: 100%, above: pitch-double, below: 0pt, grid(
    columns: (sig-left, 1fr),
    line-block(left),
    { line-block[/s/ #signer]; line-block(inl(signer)) },
  ))
})

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let mtd-motion-brief(meta, md-body) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "division", "counsel", "counsel_role", "caption", "brief_title", "signature", "date") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))
  let words = meta.at("word_count", default: count-words(md-body))
  // L.R. 7.1(d)(2)(A): a brief in support of a motion is limited to 6500 words.
  assert(words <= word-limit, message: "mtd-motion-brief: L.R. 7.1(d)(2)(A): " + str(words) + " words exceeds the " + str(word-limit) + "-word limit")

  // ---- document-wide settings ----
  set page(paper: "us-letter", margin: margin, footer-descent: 30%)
  set document(title: need(meta, "brief_title"), author: need(meta, "signature").signer)
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (double-spaced).
  show: xengine.with(pitch: pitch-double, list-indent: none)
  // A doubled sign stays with its number too ("§§2201"; xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)
  // The numbering function is what labels the headings; the show rule below draws the labels.
  set heading(numbering: heading-num)

  // Footnotes (MT-FORM-002): 14 pt, single-spaced; the mark, a space, the note (Word's footnote).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 2in, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    [#super(num)#h(0.25em)#note.body]
  }

  // Authority links: a link whose target is `toa:KEY` is recorded with the page it starts on.
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      [#metadata(it.dest.slice(4))<toa-hit>#it.body]
    } else {
      it
    }
  }

  // Headings, single-spaced and bold, half a double line above and below, kept with what follows: level 1 centered
  // capitals; deeper levels with their label in a half-inch box, the lines after the first hanging after it.
  show heading: it => block(sticky: true, breakable: false, width: 100%, above: gap-half, below: gap-half, {
    set text(..edges(pitch-single), size: type-size)
    set par(first-line-indent: 0pt)
    if it.level == 1 { align(center, strong(upper(it.body))) } else {
      let lab = heading-label(it)
      pad(left: label-indent(it.level), par(hanging-indent: heading-tab, strong[#box(width: heading-tab, lab)#it.body]))
    }
  })

  // The body's chunks: the last paragraph is kept with the signature block (a signature never stands alone on a
  // page); footnote definitions go with both parts, since cmarker binds a reference only to a definition in the
  // same call.
  let chunks = md-body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let defs = chunks.filter(t => t.starts-with("[^"))
  let main = chunks.filter(t => not t.starts-with("[^"))
  let notes = defs.join("\n\n", default: "")

  // Cover: no page number (the tables are numbered from i, the body from 1, as filed).
  page(footer: none, {
    counsel-block(meta)
    court-title(meta)
    caption-table(meta)
  })
  // Table of contents and table of authorities: lower roman from i.
  page(footer: context align(center, text(..edges(pitch-single), counter(page).display("i"))), {
    counter(page).update(1)
    toc-section()
    pagebreak()
    toa-section(authorities)
  })
  // The memorandum: arabic numbering from 1.
  page(footer: context align(center, text(..edges(pitch-single), counter(page).display("1"))), {
    counter(page).update(1)
    md(main.slice(0, -1).join("\n\n") + "\n\n" + notes)
    block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
      md(main.last() + "\n\n" + notes)
      signature-block(meta)
    })
    pagebreak()
    let sig = need(meta, "signature")
    certificate("Certificate of Compliance", 0pt,
      [Pursuant to Local Rule 7.1(d)(2)(E), I certify that this brief is printed with a proportionately spaced #face-name typeface of 14 points; is double-spaced except for footnotes and for quoted and indented material; and the word count is #commas(words) words, excluding caption, certificate of compliance, table of contents and authorities, exhibit index, and certificate of service.],
      [], sig.signer)
    if meta.at("certificate_service", default: true) {
      certificate("Certificate of Service", pitch-double,
        [I hereby certify that on this date, an accurate copy of the foregoing document was served electronically through the Court's CM/ECF system on registered counsel.],
        [Dated: #need(meta, "date")], sig.signer)
    }
  })
}
