// U.S. Bankruptcy Court, District of Kansas: memorandum in support of a motion (FRBP 9013; LBR 9013.1,
// 9013.3, 7012.1). The memorandum is the brief; the motion it supports is a separate filing.
//
// Rule-driven and content-agnostic. Requirement IDs (KSB-...) refer to ../README.md, which quotes
// the rule text (Fed. R. Bankr. P. 7010, 9004, 9011, 9013; D. Kan. LBR 9004.1, 9013.1, 9013.3, 7012.1).
// No case-specific text, no coordinates measured off the exemplar, no forced line breaks. The metadata
// comes from the YAML frontmatter of the sample; the body is its markdown, read block by block here
// (inline markdown by cmarker), as docx/ksb-motion-brief.lua reads it (schema: ../README.md).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")    // no D. Kan. rule names a face; Times New Roman, the house standard and the exemplar's face (vendored metric twin)
#let type-size = 16pt                    // KSB-FORM-002: 12 pt or larger, and an average of no more than 12 characters per inch (LBR 9004.1(a)(1)). Measured in Liberation Serif on the sample text (typst 0.15.0, 2026-10-17): 12.8 cpi at 14 pt, 11.9 at 15 pt, 11.2 at 16 pt; 16 pt keeps a margin under 12.
#let page-margin = 1in                   // style choice: 1 inch on all sides (no margin figure in the rules).
#let para-indent = 0.5in                 // first-line indent of body paragraphs; quotations this far in on both sides.
#let heading-tab = 0.5in                 // a heading's label (A., 1., a.) in a box this wide, the title hanging after it; each level below 2 half an inch further in.
#let designation-indent = 2in            // caption: "Debtor.", "Plaintiff,", "Defendant." under the names.
#let caption-left = 3.6in                // caption: width of the party column.
#let caption-pad = 0.2in                 // caption: the party column's text this far off its right rule,
#let caption-gap = 0.2in                 // and the case column's this far off it.
#let sig-left = 3.3in                    // signature block: its column this far from the left margin (the right half).
#let toc-col = 36pt                      // table of contents: the column of the page numbers; a title wraps before it.
#let toa-col = 72pt                      // table of authorities: the column of the page lists.
#let toa-hang = 0.35in                   // table of authorities: a wrapped entry's lines this far in.
#let passim-threshold = 7                // authority cited on this many pages or more: "passim".
#let lead-slack = 4pt                    // tables: a row's last word keeps this much free before the leader (spacing glued to it), as LibreOffice wants it before the leader tab (docs/EVAL-LOOP.md, "What the federal-circuit fan-out found"), so a row wraps alike in both engines.
#let rule = 0.75pt

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 32pt                 // KSB-FORM-003: double-spaced where practicable (LBR 9004.1(a)(1)): two type sizes per line.
#let pitch-single = 18.4pt               // single spacing (1.15 x the size): counsel, court, caption, title, headings, tables, quotations, signature.
#let half-line = 9.2pt                   // half a single line: the blank rows of the caption, the space above a table row.

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("ksb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ksb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it. An empty line keeps
/// its height (`height`: another height for it); `sticky`: kept with the block after it.
#let line-block(above: 0pt, below: 0pt, height: pitch-single, sticky: false, body) = block(width: 100%, above: above,
  below: below, sticky: sticky,
  height: if body == "" or body == [] { height } else { auto }, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if type(body) == str { inl(body) } else { body }
})

// ---------------------------------------------------------------------------
// Headings (LBR 9013.1(a)): level 1 a section, centered bold capitals, unnumbered; level 2 "A.", level 3 "1.",
// level 4 "a." (each reset under the level above), the label in a box of heading-tab, the title hanging after it.
// ---------------------------------------------------------------------------

/// Left edge of a heading's label: levels 1 and 2 at the margin, each deeper level half an inch in.
#let label-indent(level) = calc.max(level - 2, 0) * heading-tab

/// A heading, single-spaced, a single line above and below, sticky.
#let show-heading(it) = block(width: 100%, above: pitch-single, below: pitch-single, sticky: true, breakable: false, {
  set text(size: type-size, weight: "regular", ..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if it.level == 1 { align(center, strong(upper(it.body))) } else {
    let ind = label-indent(it.level)
    par(hanging-indent: ind + heading-tab, strong[#h(ind)#box(width: heading-tab, it.supplement)#it.body])
  }
})

// ---------------------------------------------------------------------------
// Tables of contents and authorities (LBR 9004.1(a)(2): numbered with the rest; exemplar convention)
// ---------------------------------------------------------------------------

#let page-label(loc) = numbering(loc.page-numbering(), ..counter(page).at(loc))

/// A table's title (centered bold capitals) and, a single line below, its column label at the right.
#let table-title(title, col-label) = {
  line-block(align(center, strong(upper(title))))
  line-block(above: pitch-single, align(right, strong(col-label)))
}

#let toc-section() = {
  table-title("Table of Contents", "Page")
  context {
    set text(..edges(pitch-single))
    for hd in query(heading.where(outlined: true)) {
      let ind = label-indent(hd.level)
      let body = if hd.level == 1 { upper(hd.body) } else { [#h(ind)#box(width: heading-tab, hd.supplement)#hd.body] }
      listing-row(hd.location(), [#body#h(lead-slack)], page-label(hd.location()), toc-col, ind + heading-tab, half-line)
    }
  }
}

#let toa-groups = (
  ("case", "Cases"),
  ("statute", "Federal Statutes"),
  ("rule", "Federal Rules"),
  ("regulation", "Federal Regulations"),
  ("other", "Other Authorities"),
)

/// Entries sort by name (or citation) in lower case, then citation, then key.
#let sort-key(key, a) = (lower(a.at("name", default: a.cite)) + "\u{1}" + lower(a.cite) + "\u{1}" + key)

/// Table of authorities, built from the `toa:` links found in the body: each group's title in bold a single line
/// below the one before, its entries in order; each entry's distinct pages in document order, "passim" from
/// passim-threshold pages.
#let toa-section(authorities) = {
  table-title("Table of Authorities", "Page(s)")
  context {
    set text(..edges(pitch-single))
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("ksb-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    for (kind, title) in toa-groups {
      let members = authorities.pairs()
        .filter(p => p.last().kind == kind and hits.any(h => h.value == p.first()))
        .sorted(key: p => sort-key(p.first(), p.last()))
      if members.len() == 0 { continue }
      line-block(above: pitch-single, sticky: true, strong(title))
      for (key, a) in members {
        let pages = ()
        for h in hits.filter(h => h.value == key) {
          let label = page-label(h.location())
          if label not in pages { pages.push(label) }
        }
        let page-text = if pages.len() >= passim-threshold { emph[passim] } else { pages.join(", ") }
        let body = {
          if "name" in a {
            if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }
            [, ]
          }
          inl(a.cite)
        }
        listing-row(none, [#body#h(lead-slack)], page-text, toa-col, toa-hang, half-line)
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Cover and caption (FRBP 7010 by analogy; FRBP 9004(b): court, title, case number, designation)
// ---------------------------------------------------------------------------

/// The caption: a table of one row per single line, the party column ruled at its right, the case column beside it.
/// The party column: "In re:", the debtor's names and designation, then each side's names and designation, "v."
/// between the sides, each part half a line apart (blank rows). The case column: the case number and the chapter
/// beside the debtor's names, the adversary number beside "v.". Never split.
#let caption-block(meta) = {
  let debtor = need(meta, "debtor")
  let sides = need(meta, "caption")
  let adv = meta.at("adversary_number", default: "Adv. No. " + "_" * 10)
  let gap = line-block(height: half-line, "")
  let left = (line-block("In re:"), gap)
  let at-debtor = left.len()
  for n in debtor.names { left.push(line-block(n)) }
  left.push(line-block(pad(left: designation-indent, inl(debtor.designation))))
  let at-v = none
  for (i, side) in sides.enumerate() {
    left.push(gap)
    if i > 0 {
      if at-v == none { at-v = left.len() }
      left.push(line-block(align(center)[v.]))
      left.push(gap)
    }
    for n in side.names { left.push(line-block(n)) }
    left.push(line-block(pad(left: designation-indent, inl(side.designation))))
  }
  if at-v == none { at-v = left.len() - 1 }
  let right = left.map(b => if b == gap { gap } else { line-block("") })
  right.at(at-debtor) = line-block(need(meta, "bankruptcy_case"))
  right.at(at-debtor + 1) = line-block(need(meta, "chapter"))
  right.at(at-v) = line-block(adv)
  let cells = ()
  for i in range(left.len()) {
    cells.push(table.cell(stroke: (right: rule), inset: (right: caption-pad), left.at(i)))
    cells.push(table.cell(inset: (left: caption-gap), right.at(i)))
  }
  block(width: 100%, breakable: false, above: 0pt, below: 0pt,
    table(columns: (caption-left, 1fr), stroke: none, inset: 0pt, ..cells))
}

/// The cover (page 1): the counsel block, a single line below it the party represented in italics; a single line
/// below that the court; a single line below it the caption; a single line below that the title.
#let cover(meta) = {
  for l in need(meta, "counsel") { line-block(l) }
  line-block(above: pitch-single, emph(inl(need(meta, "counsel_role"))))
  for (i, l) in need(meta, "court").enumerate() {
    line-block(above: if i == 0 { pitch-single } else { 0pt }, align(center, strong(upper(inl(l)))))
  }
  block(width: 100%, above: pitch-single, below: 0pt, caption-block(meta))
  line-block(above: pitch-single, align(center, strong(upper(inl(need(meta, "title"))))))
}

// ---------------------------------------------------------------------------
// Body: blank-line-separated blocks. "#" to "####" headings, "> " quotations (single-spaced, half an inch in on
// both sides, a single line above and below), any other block a paragraph at the double pitch.
// ---------------------------------------------------------------------------

#let body-blocks(body) = body.replace("\r\n", "\n").split(regex("\n[ \t]*\n")).map(s => s.trim()).filter(s => s != "")

/// A body paragraph at the double pitch with the first-line indent; `keep`: kept whole on the page of the block after
/// it (the last block stays with the signature).
#let body-par(content, keep: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: keep, breakable: not keep,
  par(first-line-indent: (amount: para-indent, all: true), content))

#let render-body(blocks) = {
  let c = (0, 0, 0)
  for (i, b) in blocks.enumerate() {
    let last = i == blocks.len() - 1
    let h = b.match(regex("^(#{1,4})\\s+(.*)$"))
    if h != none {
      let lvl = h.captures.at(0).len()
      let lab = none
      if lvl == 1 { c = (0, 0, 0) } else {
        c.at(lvl - 2) += 1
        for k in range(lvl - 1, 3) { c.at(k) = 0 }
        lab = numbering(("A.", "1.", "a.").at(lvl - 2), c.at(lvl - 2))
      }
      heading(level: lvl, outlined: true, supplement: lab, inl(h.captures.at(1).trim()))
    } else if b.starts-with(">") {
      block(width: 100%, above: pitch-single, below: pitch-single, sticky: last, breakable: not last,
        pad(left: para-indent, right: para-indent, {
          set text(..edges(pitch-single))
          par(first-line-indent: 0pt, inl(b.split("\n").map(l => l.trim(">", at: start).trim()).join(" ")))
        }))
    } else {
      body-par(keep: last, inl(b.replace("\n", " ")))
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block and certificate of service (LBR 9013.3(a); FRBP 9011(a))
// ---------------------------------------------------------------------------

/// A signature column at sig-left, a double line below the block before it, single-spaced, never split: `lines` are
/// (content, space above) pairs; `date`, when given, at the left margin beside the first line.
#let signature-column(lines, date: none) = block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
  if date != none { place(top + left, line-block(date)) }
  for (k, (body, above)) in lines.enumerate() {
    line-block(above: if k == 0 { 0pt } else { above }, pad(left: sig-left, body))
  }
})

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  let lines = sig.at("preamble", default: ()).map(l => (inl(l), 0pt))
  lines.push(([/s/ #inl(sig.signer)], pitch-single))
  lines.push(([#inl(sig.signer)#if "bar" in sig [, #inl(sig.bar)]], 0pt))
  for l in sig.at("lines", default: ()) { lines.push((inl(l), 0pt)) }
  if "role" in sig { lines.push((emph(inl(sig.role)), pitch-single)) }
  signature-column(lines, date: [Dated: #inl(need(meta, "date"))])
}

/// Certificate of service, on a page of its own. The wording is the local rule's example (LBR 9013.3(a)(1)) for
/// service through the CM/ECF system; the metadata names the document and the signer.
#let certificate-of-service(meta) = {
  let svc = need(meta, "service")
  let sig = need(meta, "signature")
  pagebreak()
  line-block(below: pitch-single, align(center, strong(upper("Certificate of Service"))))
  body-par[I hereby certify that on #inl(need(meta, "date")), I electronically filed the foregoing #upper(inl(svc.document)) with the Clerk of the Court using the CM/ECF system, which will send notice of electronic filing to all counsel of record.]
  let lines = (([/s/ #inl(sig.signer)], 0pt), (inl(svc.signer), 0pt))
  if "role" in sig { lines.push((emph(inl(sig.role)), 0pt)) }
  signature-column(lines)
}

// ---------------------------------------------------------------------------
// The memorandum
// ---------------------------------------------------------------------------

#let ksb-motion-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "debtor", "bankruptcy_case", "chapter", "caption", "title", "counsel", "counsel_role", "date", "signature", "service") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))

  // LBR 9013.1(a)(1)-(4): the memorandum must state the nature of the matter, the facts, the question
  // presented and the argument. A missing section is a build failure, not a silent omission.
  for frag in ("NATURE", "FACT", "QUESTION", "ARGUMENT") {
    if md.find(regex("(?m)^# [^\n]*" + frag)) == none { panic("ksb-motion-brief: no `# ...` section heading containing `" + frag + "` (LBR 9013.1(a))") }
  }

  // ---- document-wide settings ----
  // LBR 9004.1(a)(1): 8-1/2 x 11 inch paper; (a)(2): numbered from the first page, the cover and tables included. The
  // number centered at the foot in a single line box, where Word's footer sets it.
  set page(paper: "us-letter", margin: page-margin, numbering: "1", footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("1"))))
  set document(title: need(meta, "title"), author: need(meta, "signature").signer)
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (double spacing).
  show: xengine.with(pitch: pitch-double, list-indent: none)
  // A doubled section sign stays with its number (xengine binds a single sign), as the docx filter binds it.
  show regex("[§¶]{2,} \\S+"): it => box(it)
  show heading: show-heading

  // Authority links: a link whose target is `toa:KEY` is recorded with the page it starts on.
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      [#metadata(it.dest.slice(4))<toa-hit>#it.body]
    } else {
      it
    }
  }

  cover(meta)
  pagebreak()
  toc-section()
  pagebreak()
  toa-section(authorities)
  pagebreak()
  render-body(body-blocks(md))
  signature-block(meta)
  certificate-of-service(meta)
}
