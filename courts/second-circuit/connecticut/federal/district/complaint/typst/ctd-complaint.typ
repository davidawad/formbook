// U.S. District Court, District of Connecticut (ctd): complaint.
//
// Rule-driven and content-agnostic. Requirement IDs (CTD-...) refer to ../README.md, which quotes the
// rule text (D. Conn. Local Rule 10; Fed. R. Civ. P. 8, 10; the Electronic Filing Policies and Procedures).
// No case-specific text, no coordinates measured off the exemplar, no forced line breaks. The markdown
// body is rendered by cmarker; the metadata comes from the YAML frontmatter of the same file (schema: ../README.md).
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")     // CTD-FORM-006: the rules name no font (see README); Times New Roman, the house face (vendored, docs/FONTS.md)
#let type-size = 12pt                // CTD-FORM-010: 12-point text (L.R. 7(a)(5) for memoranda; Rule 10 is silent for pleadings)
#let margin = 1in                    // CTD-FORM-002/003: at least one inch left and right (L.R. 10); 1 in top and bottom
#let text-width = 8.5in - 2 * margin
#let para-indent = 0.5in             // first-line indent of every body paragraph
#let number-box = 0.5in              // a paragraph number's box: the text starts 1 in from the margin (docx: a tab)
#let list-indent = 0.5in             // a list item's label starts half an inch in ...
#let label-box = 0.5in               // ... in a box of its own; the text hangs 1 in from the margin
#let caption-left = 3.3in            // width of the party column of the caption
#let caption-rule-pad = 10pt         // the party column's text to its right rule
#let caption-gutter = 0.2in          // the party column's rule to the right column ...
#let caption-pad = 0.1in             // ... and the right column's text stands off the gutter by this much
#let designation-indent = 1.5in      // designations ("Plaintiffs,", "Defendant.") sit under the names
#let sig-left = 2.8in                // the signature column's left edge ("Dated:" at the margin, CTD-SIG-001)

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/complaint.lua and docx/reference.xml set the
// same twips).
#let pitch-body = 27.6pt             // CTD-FORM-004: double spacing (L.R. 10), twice the 13.8 pt single line of 12 pt Times
#let pitch-single = 13.8pt           // single spacing: court title, caption, signature block, page number
#let gap = 27.6pt                    // one blank body line: court title to caption, caption to text, text to signature,
                                     // "Respectfully submitted," to the /s/ line
#let caption-gap = 13.8pt            // inside the caption's right column: a blank single line before the title
#let caption-below = 13.8pt          // the party column's last line to its bottom rule (a blank single line)
// CTD-FORM-005 (L.R. 10: page numbers in the bottom margin of each page after page 1): the number in a single-spaced
// line box whose foot is 0.5 in above the bottom edge (docx: footer distance 720 twips): 72 - 36 - 13.8 = 22.2 pt.
#let footer-descent = 22.2pt

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ctd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Inline content without the paragraph breaks cmarker may put around it (they may not occur inside a paragraph).
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

#let need(meta, key) = {
  if key not in meta { panic("ctd-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Single-spaced lines, one paragraph each; an empty item is a blank single line. `above`: the space before the
/// first line. An item is a string (markdown) or content.
#let line-stack(items, above: 0pt) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  let g = above
  for i in items {
    if i == "" { g += pitch-single } else {
      block(width: 100%, above: g, below: 0pt, if type(i) == str { unloose(inl(i)) } else { i })
      g = 0pt
    }
  }
}

/// A body paragraph at the body pitch, its first line indented half an inch.
#let body-par(content, above: 0pt) = block(width: 100%, above: above, below: 0pt, par(unloose(content)))

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (CTD-FIRST-001..002, CTD-CAP-001..004)
// ---------------------------------------------------------------------------

#let caption(meta) = {
  // The parties: each party's names, then its designation indented under them.
  let rows = ()
  for (k, p) in need(meta, "caption").parties.enumerate() {
    if k > 0 { rows += ("", "v.", "") }   // "v." between the parties, a blank single line either side
    rows += p.names
    rows.push(pad(left: designation-indent, unloose(inl(p.designation))))
  }
  let right = ("Case No. " + need(meta, "case_number"), "Date: " + need(meta, "date"), "",
    text(weight: "bold", unloose(inl(need(meta, "brief_title")))))
  if "jury_demand" in meta and meta.jury_demand { right += ("", text(weight: "bold")[DEMAND FOR JURY TRIAL]) }
  block(width: 100%, above: gap, below: 0pt, breakable: false, grid(
    columns: (caption-left, 1fr),
    column-gutter: caption-gutter,
    block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt),
      inset: (right: caption-rule-pad, bottom: caption-below), line-stack(rows)),
    pad(left: caption-pad, line-stack(right)),
  ))
}

#let court-title(meta) = line-stack(need(meta, "court").map(l => align(center, text(weight: "bold", upper(l)))))

// ---------------------------------------------------------------------------
// Body: headings, numbered paragraphs, lists (FRCP 10(b))
// ---------------------------------------------------------------------------

/// Headings on the body pitch, kept with the block after them: level 1 a centered bold section in capitals; level 2
/// a centered bold sub-heading; level 3 bold italic at the margin.
#let heading-block(level, s) = {
  let c = unloose(inl(s))
  let body = if level == 1 { strong(upper(c)) } else if level == 2 { strong(c) } else { strong(emph(c)) }
  block(width: 100%, above: 0pt, below: 0pt, sticky: true,
    align(if level <= 2 { center } else { left }, par(first-line-indent: 0pt, body)))
}

/// The body. Each blank-line-separated chunk of markdown is one of:
///   `#` heading (levels 1 to 3), kept with the text after it;
///   `1.` or `-` list: one item per line that starts with a label (lettered (a), (b), ... or bulleted), the label
///   half an inch in, the text hanging 1 in from the margin; the letters start again with each list;
///   a chunk that starts with `<!-- unnumbered -->` (stripped): an unnumbered paragraph (the wherefore clause, the
///   jury demand);
///   anything else: one numbered paragraph (Fed. R. Civ. P. 10(b)), the number continuing from `n`.
#let item-re = regex("^(\\d+\\.|[-*+])[ \\t]+")
#let unnumbered-mark = "<!-- unnumbered -->"
#let allegations(chunks, n) = {
  let out = []
  for t in chunks {
    if t.starts-with("#") {
      let level = t.match(regex("^#+")).end
      out += heading-block(calc.min(level, 3), t.slice(level).trim())
    } else if t.starts-with(item-re) {
      let bullet = not t.starts-with(regex("^\\d"))
      let items = ()
      for l in t.split("\n").map(l => l.trim()).filter(l => l != "") {
        if l.starts-with(item-re) or items.len() == 0 { items.push(l.replace(item-re, "")) } else { items.last() += " " + l }
      }
      for (k, item) in items.enumerate() {
        let lab = if bullet { [•] } else { numbering("(a)", k + 1) }
        out += block(width: 100%, above: 0pt, below: 0pt, pad(left: list-indent,
          par(first-line-indent: 0pt, hanging-indent: label-box,
            [#box(width: label-box, lab)#unloose(inl(item))])))
      }
    } else if t.starts-with(unnumbered-mark) {
      out += body-par(inl(t.slice(unnumbered-mark.len()).trim()))
    } else {
      n += 1
      out += body-par[#box(width: number-box)[#n.]#unloose(inl(t))]
    }
  }
  (out, n)
}

// ---------------------------------------------------------------------------
// Signature block (CTD-SIG-001: EFPP XI.B and L.R. 10)
// ---------------------------------------------------------------------------

/// "Dated:" at the margin and "Respectfully submitted," in the signature column on the same line; a blank body line;
/// then "/s/" and the signer, the signer's name with the federal bar number, and the address lines.
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  let name-line = if "bar" in sig { sig.signer + ", Fed. Bar No. " + sig.bar } else { sig.signer }
  block(width: 100%, above: gap, below: 0pt, grid(columns: (sig-left, 1fr),
    line-stack(("Dated: " + need(meta, "date"),)),
    line-stack(("Respectfully submitted,",))))
  block(width: 100%, above: gap, below: 0pt,
    pad(left: sig-left, line-stack(("/s/ " + sig.signer, name-line) + sig.at("lines", default: ()))))
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let ctd-complaint(meta, body) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "court", "caption", "brief_title", "date", "signature") {
    let _ = need(meta, k)
  }

  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: footer-descent,
    // CTD-FORM-005: page numbers in the bottom margin of each page after page 1.
    footer: context {
      if counter(page).get().first() > 1 {
        align(center, text(..edges(pitch-single), counter(page).display()))
      }
    },
  )
  set document(title: need(meta, "brief_title") + ", No. " + need(meta, "case_number"), author: need(meta, "signature").signer)
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch. Lists are written by allegations() (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays whole and with its number ("§§ 2301"): typst would break between the signs.
  show regex("[§¶]{2,} \\S+"): it => box(it)

  court-title(meta)
  caption(meta)
  if "lead_in" in meta { body-par(above: gap, inl(meta.lead_in)) }

  // The last chunk (a paragraph, or a whole list) stays on the page with the signature block: a signature never
  // starts a page alone.
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let (main, n) = allegations(chunks.slice(0, -1), 0)
  // No lead-in: the first block takes the gap below the caption.
  if not "lead_in" in meta { v(gap, weak: true) }
  main
  block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
    allegations(chunks.slice(-1), n).at(0)
    signature-block(meta)
  })
}
