// California Court of Appeal: appellant's reply brief.
//
// Rule-driven and content-agnostic. Rule numbers in comments refer to README.md and ../rules.md, which give the
// citation, the URL and the date verified for each. No case-specific text, no coordinates measured off any filed
// brief, no forced line breaks. The markdown body is rendered by cmarker; the metadata comes from the YAML
// frontmatter of the same file (schema: README.md, "Markdown contract"). docx/calctapp.lua builds the same document
// for Word from the same sample, line for line (docs/EVAL-LOOP.md, "Cross-engine gate").

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

// Rule 8.74(b)(1), 8.204(b)(2): a proportionally spaced serif face; Century Schoolbook is preferred, not required
// (rules.md CALCTAPP-FORM-002), so the house face, Times New Roman (docs/FONTS.md), vendored in fonts/.
#let font-family = ("Times New Roman", "Liberation Serif")
#let type-size = 13pt                      // Rule 8.204(b)(4), 8.74(b)(1): 13-point, footnotes included.
#let side-margin = 1.5in                   // Rule 8.204(b)(6), 8.74(b)(3): 1-1/2 inches left and right.
#let top-margin = 1in                      // Rule 8.204(b)(6): 1 inch top and bottom.
#let footer-distance = 0.5in               // the page number's line box ends half an inch above the page edge (docx: footer 720)
#let para-indent = 0.5in                   // first-line indent of body paragraphs
#let label-box = 0.5in                     // a heading label in a box; each deeper level steps in by it
#let quote-indent = 0.5in                  // Rule 8.204(b)(6): quotations may be block indented; both sides
#let caption-left = 3.4in                  // the party column of the cover caption, ruled at its right and foot
#let caption-pad = 0.1in                   // the party text to its rule, and the rule to the case number
#let designation-indent = 1.5in            // "PLAINTIFFS AND APPELLANTS," and "v." under the party names
#let sig-col = 3in                         // the signature column, at the right of the text
#let served-indent = 0.5in                 // the persons served, in the proof of service
#let toc-col = 0.5in                       // contents: the page column the rows wrap before
#let toa-col = 1in                         // authorities: the page column ("9, 10, 11" fits)
#let toa-hang = 0.35in                     // an authority's later lines hang this far in
#let lead-slack = 4pt                      // a row keeps its last word before the leader only with this much to spare:
                                           // LibreOffice wants about 4 pt free after the leader's three spaces
                                           // (docs/EVAL-LOOP.md, federal-circuit fan-out), so typst asks for it too
#let toc-depth = 5
#let passim-threshold = 7                  // an authority cited on this many pages or more: "passim".
#let word-limit = 14000                    // Rule 8.204(c)(1): computer-generated brief.

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/calctapp.lua and docx/reference.xml set the same
// twips: 20 x pt).
#let pitch-body = 22.5pt                   // Rule 8.74(b)(2), 8.204(b)(5): 1.5 spaced, one and a half single lines
#let pitch-single = 15pt                   // single spacing (cover, headings, quotations, footnotes, tables, signature,
                                           // certificates, page number): Word's 1.15 x 13 pt, to the half point
#let gap = 30pt                            // between the cover's parts: two blank single lines
#let head-above = 15pt                     // above a heading: a blank single line
#let head-below = 7.5pt                    // below a heading: half a single line
#let quote-gap = 7.5pt                     // above, between and below the paragraphs of a block quotation
#let para-gap = 15pt                       // between the paragraphs of the certificates and the proof of service
#let toc-above = 7.5pt                     // above a level 1 row of the contents
#let toc-sub-above = 4pt                   // above a deeper row
#let toa-above = 7.5pt                     // above an authority
#let note-gap = 7pt                        // between two footnotes (Word: Footnote Text's space after)
#let note-clearance = 7.5pt                // from the text to the footnote rule (the space LibreOffice keeps above it)

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Inline content without the paragraph breaks cmarker may put around it.
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = unloose(cmarker.render(s, raw-typst: false, smart-punctuation: true))

/// Plain text of a piece of content, for comparisons only.
#let plain(c) = {
  if type(c) == str { c }
  else if c == [] { "" }
  else if c.has("text") { c.text }
  else if c.has("children") { c.children.map(plain).join() }
  else if c.has("body") { plain(c.body) }
  else if c.func() == [ ].func() { " " }
  else { "" }
}

#let need(meta, key) = {
  if key not in meta { panic("calctapp-reply-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("calctapp-reply-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Put an invisible `tag` right after the first word of `c`, keeping any emphasis around it.
/// Returns (content, placed). Why not simply put the tag in front: when a citation begins at the
/// start of a line, typst files a tag that sits before the first word under the PREVIOUS line, which
/// may be on the previous page, so the table of authorities would cite the wrong page.
#let tag-after-first-word(c, tag) = {
  if type(c) == str or c.func() == text {
    let t = if type(c) == str { c } else { c.text }
    let m = t.match(regex("^\\s*\\S+"))
    if m == none { return (c, false) }
    return ([#m.text#tag#t.slice(m.end)], true)
  }
  if c.func() == emph { let r = tag-after-first-word(c.body, tag); return (emph(r.first()), r.last()) }
  if c.func() == strong { let r = tag-after-first-word(c.body, tag); return (strong(r.first()), r.last()) }
  if c.func() == [].func() {
    let out = ()
    let placed = false
    for ch in c.children {
      if placed { out.push(ch) }
      else { let r = tag-after-first-word(ch, tag); out.push(r.first()); placed = r.last() }
    }
    return (out.join(), placed)
  }
  (c, false)
}

/// 11942 -> "11,942"
#let group-digits(n) = {
  let s = str(n)
  let out = ""
  for (i, c) in s.clusters().enumerate() {
    if i > 0 and calc.rem(s.len() - i, 3) == 0 { out += "," }
    out += c
  }
  out
}

/// Word count of markdown source, whitespace-delimited like a word processor.
/// Markup characters are removed first; links keep their text; footnote text is counted.
/// docx/calctapp.lua counts the same way.
#let count-words(md) = {
  let s = md
  s = s.replace(regex("<!--[\\s\\S]*?-->"), " ")
  s = s.replace(regex("(?m)^\\[\\^[^\\]]+\\]:"), " ")      // footnote definition labels
  s = s.replace(regex("\\[\\^[^\\]]+\\]"), "")             // footnote references
  // (typst's string replacement has no $1: a function returns the captured text)
  let keep(m) = m.captures.at(0)
  s = s.replace(regex("\\[([^\\]]*)\\]\\([^)]*\\)"), keep)  // links keep their text
  s = s.replace(regex("(?m)^#{1,6}[ \t]+"), "")
  s = s.replace(regex("(?m)^>[ \t]?"), "")
  s = s.replace(regex("(?m)^[ \t]*([-*+]|[0-9]+[.)])[ \t]+"), "")   // list markers are not words
  s = s.replace(regex("\\\\(.)"), keep)                    // backslash escapes
  s = s.replace(regex("[*]"), "")
  s = s.replace(regex("(^|[\\s(\\[\u{201C}\"])_"), keep)
  s = s.replace(regex("_([\\s.,;:)\\]\u{201D}\"!?]|$)"), keep)
  s.split(regex("\\s+")).filter(w => w != "").len()
}

/// Single-spaced lines, one paragraph each; "" is a blank single line. `above`: space above the first line.
#let line-stack(items, above: 0pt, left: 0pt) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt, hanging-indent: 0pt)
  let g = above
  for i in items {
    if i == "" { g += pitch-single } else {
      block(width: 100%, above: g, below: 0pt, pad(left: left, if type(i) == str { inl(i) } else { i }))
      g = 0pt
    }
  }
}

/// A single-spaced paragraph (certificates, proof of service), `above` it.
#let single-par(above, body) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  par(first-line-indent: 0pt, body)
})

/// The title of a part that is not a heading of the brief (tables, certificates): centered bold capitals, single
/// spaced, half a single line below it.
#let part-title(t) = block(width: 100%, above: 0pt, below: head-below, sticky: true, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  align(center, strong(upper(t)))
})

#let page-label(loc) = numbering(loc.page-numbering(), ..counter(page).at(loc))

// ---------------------------------------------------------------------------
// Headings: numbering scheme and styles
// ---------------------------------------------------------------------------

/// Printed label of a numbered heading: I. / A. / 1. / a. (level 2 to 5).
/// Same scheme in the statements and the argument: the sections are "Sections" of one brief.
#let heading-label(h) = {
  let n = counter(heading).at(h.location()).at(h.level - 1, default: 1)
  if h.level == 2 { numbering("I.", n) }
  else if h.level == 3 { numbering("A.", n) }
  else if h.level == 4 { numbering("1.", n) }
  else if h.level == 5 { numbering("a.", n) }
  else { panic("calctapp-reply-brief: headings deeper than level 5 are not supported") }
}

/// Headings: single spaced (Rule 8.204(b)(5)), bold, a blank single line above and half a line below, kept with the
/// text after them. Level 1 centered capitals; deeper levels their label in a half-inch box at (level - 2) half
/// inches, later lines under the text; levels 4 and 5 bold italic.
#let style-heading(it) = {
  set text(size: type-size, ..edges(pitch-single))
  set par(first-line-indent: 0pt, hanging-indent: 0pt)
  let b = if it.level == 1 {
    align(center, strong(upper(it.body)))
  } else if it.numbering == none {
    strong(it.body)
  } else {
    let ind = (it.level - 2) * label-box
    let t = if it.level >= 4 { strong(emph(it.body)) } else { strong(it.body) }
    pad(left: ind, par(hanging-indent: label-box, [#box(width: label-box, strong(heading-label(it)))#t]))
  }
  block(width: 100%, sticky: true, above: head-above, below: head-below, b)
}

// ---------------------------------------------------------------------------
// Tables of contents and authorities
// ---------------------------------------------------------------------------

/// The table of contents lists the body's headings: the ones after `<body-start>` and before `<body-end>`. The
/// level 1 headings at the margin in capitals; a deeper one's label where it sits in the body, its title's later
/// lines under the title.
#let toc-section() = {
  part-title[Table of Contents]
  block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
    set text(..edges(pitch-single))
    align(right, strong[Page])
  })
  context {
    set text(..edges(pitch-single))
    let hs = query(selector(heading).after(<body-start>).before(<body-end>))
    for hd in hs {
      if hd.level > toc-depth { continue }
      let numbered = hd.numbering != none and hd.level >= 2
      let ind = if hd.level >= 2 { (hd.level - 2) * label-box } else { 0pt }
      let t = if hd.level == 1 { upper(hd.body) } else if numbered { [#box(width: label-box, heading-label(hd))#hd.body] } else { hd.body }
      listing-row(hd.location(), [#h(ind)#t#h(lead-slack)], page-label(hd.location()), toc-col,
        ind + label-box, if hd.level == 1 { toc-above } else { toc-sub-above })
    }
  }
}

#let toa-groups = (
  ("case", "Cases:"),
  ("constitution", "Constitutional Provisions:"),
  ("statute", "Statutes:"),
  ("regulation", "Regulations:"),
  ("rule", "Rules:"),
  ("other", "Other Authorities:"),
)

/// The sort key of an authority: its name and citation (or its `sort`), in lower case, letters, digits and spaces.
#let sort-key(a) = {
  let s = lower(plain(inl(a.at("sort", default: a.at("name", default: "") + " " + a.cite))))
  s.replace(regex("[^a-z0-9 ]"), "")
}

/// Table of authorities, built from the `toa:` links found in the body: by group, sorted; a case's name in
/// italics before its citation, the pages it is cited on.
#let toa-section(authorities) = {
  part-title[Table of Authorities]
  context {
    set text(..edges(pitch-single))
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("calctapp-reply-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    let first = true
    for (kind, title) in toa-groups {
      let members = authorities.pairs()
        .filter(p => p.last().kind == kind and hits.any(h => h.value == p.first()))
        .sorted(key: p => sort-key(p.last()))
      if members.len() == 0 { continue }
      block(width: 100%, above: if first { head-below } else { head-above }, below: 0pt, sticky: true,
        par(first-line-indent: 0pt, {
          strong(title)
          if first { h(1fr); strong[Page(s)] }
        }))
      first = false
      for (key, a) in members {
        // Distinct printed page labels, in document order.
        let pages = ()
        for h in hits.filter(h => h.value == key) {
          let label = page-label(h.location())
          if label not in pages { pages.push(label) }
        }
        let page-text = if pages.len() >= passim-threshold { emph[passim] } else { pages.join(", ") }
        let t = if "name" in a {
          if kind == "case" { [#emph(inl(a.name)) #inl(a.cite)] } else { [#inl(a.name), #inl(a.cite)] }
        } else { inl(a.cite) }
        listing-row(none, [#t#h(lead-slack)], page-text, toa-col, toa-hang, toa-above)
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Cover (Rule 8.204(b)(10), 8.74(a)(9), (c)(1); the cover is page 1 and is not printed with a number)
// ---------------------------------------------------------------------------

/// The caption: the parties in a column ruled at its right and foot, the Court of Appeal number beside it.
#let caption(meta) = {
  let parties = ()
  for (k, side) in need(meta, "caption").enumerate() {
    if k > 0 { parties += ("", pad(left: designation-indent, [v.]), "") }
    parties += side.names
    parties.push(pad(left: designation-indent, inl(side.designation)))
  }
  block(width: 100%, above: gap, below: 0pt, breakable: false, grid(
    columns: (caption-left, 1fr),
    stroke: (x, y) => if x == 0 { (right: 0.75pt, bottom: 0.75pt) } else { none },
    align: left + top,
    pad(right: caption-pad, bottom: pitch-single, line-stack(parties)),
    pad(left: caption-pad, line-stack(([Court of Appeal Case No. #need(meta, "case_number")],))),
  ))
}

#let cover(meta) = {
  line-stack(need(meta, "court_lines").map(l => align(center, strong(inl(l)))))
  caption(meta)
  // Superior court, its number and the judge; the title of the brief; counsel (Rule 8.74(a)(9): name, address,
  // telephone, e-mail and State Bar number) and the party they represent.
  line-stack((need(meta, "trial_court"), [Case No. #need(meta, "superior_case_number")], need(meta, "judge"))
    .map(l => align(center, if type(l) == str { inl(l) } else { l })), above: gap)
  line-stack((align(center, strong(upper(inl(need(meta, "brief_title"))))),), above: gap)
  let lines = ()
  for (k, g) in need(meta, "counsel").enumerate() {
    if k > 0 { lines.push("") }
    lines += g.names + g.at("lines", default: ())
  }
  lines += ("", emph(inl(need(meta, "counsel_for"))))
  line-stack(lines.map(l => if l == "" { l } else { align(center, if type(l) == str { inl(l) } else { l }) }), above: gap)
}

// ---------------------------------------------------------------------------
// Signature, certificates (Rule 8.204(c)(1)), proof of service
// ---------------------------------------------------------------------------

/// The date at the left; the firm, "s/", the signer and the role in a column at the right.
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, width: 100%, above: pitch-body, below: 0pt, grid(columns: (1fr, sig-col),
    line-stack(([Dated: #need(meta, "date")],)),
    line-stack((sig.firm, "s/" + sig.signer, sig.signer, emph(inl(sig.role))))))
}

/// Certificate of word count: Rule 8.204(c)(1). The number is the count of the brief's text
/// (body, headings, footnotes) in `count-words`, not a figure typed in by hand.
#let certificate-of-word-count(meta, words) = {
  part-title[Certificate of Word Count]
  single-par(0pt)[Under Rule 8.204, subdivision (c)(1), of the California Rules of Court, I certify that the attached #emph(inl(need(meta, "brief_title"))) is 1½-spaced, typed in a proportionally spaced, 13-point font, and the brief contains #group-digits(words) words of text, including footnotes, as counted by the word-count feature of the word-processing program used to prepare the brief.]
  signature-block(meta)
}

/// Proof of service. Its wording follows the exemplar; the parties and the method come from the frontmatter.
#let proof-of-service(meta) = {
  let svc = need(meta, "service")
  part-title[Proof of Service]
  line-stack(([Case Name: #inl(need(meta, "case_name"))], [Court of Appeal Case No.: #need(meta, "case_number")],
    [Superior Court Case No.: #need(meta, "superior_case_number")]))
  single-par(para-gap)[I, #svc.declarant, am employed in #svc.employed_in. I am over the age of eighteen (18) years and am not a party to the within action. My business address is #svc.business_address.]
  single-par(para-gap)[On #need(meta, "date"), I served a copy of the foregoing document described as: #need(meta, "brief_title"), on the following parties, as follows:]
  for s in svc.served {
    block(width: 100%, above: para-gap, below: 0pt, breakable: false,
      line-stack((inl(s.name), [Served #s.method.]), left: served-indent))
  }
  single-par(para-gap)[I declare under penalty of perjury under the laws of the State of California that the foregoing is true and correct.]
  single-par(para-gap)[Executed on #svc.executed.]
  block(width: 100%, above: pitch-body, below: 0pt, breakable: false,
    grid(columns: (1fr, sig-col), [], line-stack((svc.declarant, [Declarant]))))
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let calctapp-reply-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court_lines", "case_number", "case_name", "caption", "trial_court", "superior_case_number", "judge",
            "brief_title", "counsel", "counsel_for", "signature", "date", "service") { let _ = need(meta, k) }
  let authorities = meta.at("authorities", default: (:))

  // ---- count, then fail loudly on the word limit ----
  let words = count-words(md)
  if words > word-limit {
    panic("calctapp-reply-brief: the brief has " + str(words) + " words; Rule 8.204(c)(1) allows " + str(word-limit))
  }

  // ---- document-wide settings ----
  set document(
    title: plain(inl(need(meta, "brief_title"))) + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  // Pages numbered in arabic from the cover as page 1, the cover's number not printed (Rule 8.74(a)(2), 8.204(b)(7)):
  // centered at the foot, in a single-pitch line box that ends footer-distance above the page edge.
  set page(
    paper: "us-letter", margin: (x: side-margin, y: top-margin), numbering: "1",
    footer-descent: top-margin - footer-distance - pitch-single,
    footer: context if counter(page).get().first() > 1 {
      align(center, text(size: type-size, ..edges(pitch-single), counter(page).display()))
    },
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))    // Rule 8.74(b)(4): left aligned (xengine: ragged)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number.
  show: xengine.with(pitch: pitch-body)
  // A doubled sign stays with its number ("§§ 1.24.010"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)
  // Footnotes: 13 pt (Rule 8.204(b)(4): footnotes included), single spaced (Rule 8.204(b)(5)); the mark, a space,
  // the note; a note that does not fit goes on over the page, as in Word (Footnote Text does not keep its lines together:
  // kept whole, typst moved the anchoring line on with its note where LibreOffice kept the line and moved the note).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt, spacing: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num) #note.body]
  }
  // Block quotations: single spaced, half an inch in on both sides, paragraph by paragraph.
  show quote.where(block: true): it => block(width: 100%, above: quote-gap, below: quote-gap, pad(left: quote-indent,
    right: quote-indent, {
      set text(..edges(pitch-single))
      set par(first-line-indent: 0pt, spacing: quote-gap)
      it.body
    }))
  set heading(numbering: none)
  show heading: style-heading
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      tag-after-first-word(it.body, [#metadata(it.dest.slice(4))<toa-hit>]).first()
    } else { it.body }
  }

  // ---- cover (page 1) ----
  cover(meta)

  // ---- tables (pages 2 onward; Rule 8.204(a)(1)(A)) ----
  pagebreak()
  toc-section()
  pagebreak()
  toa-section(authorities)
  pagebreak()

  // ---- body ----
  [#metadata(none)<body-start>]
  {
    set heading(numbering: "1")
    // The signature block never stands alone on a page: the brief's last paragraph is kept with it. Footnote
    // definitions may follow it in the markdown; a footnote reference resolves only in the same render call, so they
    // are rendered with the text before it (the last paragraph is kept with the signature only when it holds no
    // footnote reference itself, or is a heading).
    let lines = md.trim(at: end).split("\n")
    let defs = lines.filter(l => l.starts-with("[^")).join("\n")
    let text-md = lines.filter(l => not l.starts-with("[^")).join("\n").trim(at: end)
    let breaks = text-md.matches(regex("\n[ \t]*\n"))
    let cut = if breaks.len() > 0 { breaks.last().end } else { 0 }
    let tail = text-md.slice(cut)
    let keep = tail.len() > 0 and not tail.starts-with("#") and not tail.contains("[^")
    let render(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)
    if keep {
      render(text-md.slice(0, cut) + "\n\n" + defs)
      block(breakable: false, width: 100%, above: 0pt, below: 0pt, { render(tail); signature-block(meta) })
    } else {
      render(text-md + "\n\n" + defs)
      signature-block(meta)
    }
  }
  [#metadata(none)<body-end>]

  // ---- certificates and proof of service ----
  pagebreak()
  certificate-of-word-count(meta, words)
  pagebreak()
  proof-of-service(meta)
}
