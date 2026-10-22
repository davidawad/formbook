// Bankruptcy Appellate Panel of the Ninth Circuit: appellant's opening brief (FRBP 8014(a), 8015).
//
// Rule-driven and content-agnostic. Requirement IDs (BAP-...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of
// the same file (schema: ../README.md, "Markdown contract").
// The three BAP9 templates (opening, answering, reply) are one text; only the per-document-type block differs.

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // BAP-FORM-002: proportionally spaced (docs/FONTS.md); the docx sets the same face
#let type-size = 14pt                      // BAP-FORM-002: 14-point or larger, everywhere (footnotes too).
// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same pitches and spaces).
#let pitch-double = 31pt                   // BAP-FORM-003: double spacing (2.2 x the 14 pt type)
#let pitch-single = 17pt                   // headings, quotations, footnotes, cover, tables, certificates
#let page-margin = 1in                     // BAP-FORM-001: one inch on all four sides.
#let para-indent = 0.5in
#let toc-page-col = 36pt                   // TOC: the page numbers keep the last 36 pt of the line to themselves
#let toa-page-col = 56pt                   // TOA: page lists (a longer list widens its own row's column)
#let toa-hang = 0.4in                      // TOA: a wrapped entry hangs under its first line
#let sig-indent = 3in                      // the signature block and the certificates' signatures
#let passim-threshold = 7                  // an authority cited on this many pages or more: "passim".
#let court-name = "United States Bankruptcy Appellate Panel of the Ninth Circuit"
// Spaces between blocks, in pt (the docx engine writes the same, in twips).
#let space = (
  cover: 18pt,        // between the cover's parts
  cover-small: 10pt,  // around "v." and between counsel groups
  h1: (24pt, 14pt),   // section headings: above, below
  h2: (20pt, 12pt),   // argument headings
  h3: (18pt, 12pt),   // sub-headings
  quote: 12pt,        // above and below a block quotation
  note: 7pt,          // between footnotes
  toc-row: 6pt,       // above a table row
  toa-group: (18pt, 6pt),
  sig: 24pt,          // above the signature block
  cert: (24pt, 14pt), // a certificate's title: above, below
  cert-par: 12pt,     // between a certificate's paragraphs
)

// ---------------------------------------------------------------------------
// Per-document-type settings (this folder: appellant's opening brief)
// ---------------------------------------------------------------------------
#let doc = (
  kind: "opening",
  title: "Appellant's Opening Brief",
  // BAP-CONTENT-001: FRBP 8014(a)(1)-(7). Each entry is a requirement; the brief must have a level-1 heading
  // with one of its titles. FRBP 8014 fixes the content, not the wording: filed briefs title these differently
  // (the Meridian exemplar uses "Jurisdictional Statement", "Standard of Review" and so on).
  required: (
    ("Statement of Jurisdiction", "Jurisdictional Statement"),
    ("Statement of Issues and Standards of Review", "Statement of Issues", "Standard of Review", "Standards of Review"),
    ("Statement of the Case", "Statement of Case"),
    ("Summary of Argument", "Summary of the Argument"),
    ("Argument",),
    ("Conclusion",),
  ),
  // BAP-LENGTH-001: FRBP 8015(a)(7): 30 pages, or the type-volume limit of 8015(a)(7)(B).
  word-limit: 13000,
  // a table of authorities is printed when the frontmatter has a registry (a reply must have one: FRBP 8014(c))
  authorities-required: false,
  // BAP-CERT-001 and BAP-CERT-002: BAP R. 8015(a)-1 (certification of interested parties and related cases).
  certs: ("interested-parties", "related-cases", "compliance", "service"),
)

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Metadata field, with a loud failure when it is missing.
#let need(meta, key) = {
  if key not in meta { panic("bap9-" + doc.kind + ": missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("bap9-" + doc.kind + ": the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Words of the body, for the type-volume certificate (FRBP 8015(h)): text only, no link targets or markup.
#let count-words(md) = {
  let t = md.replace(regex("\\]\\([^)]*\\)"), "]").replace("\n", " ").replace("\t", " ")
  t.split(" ").filter(w => w.find(regex("[A-Za-z0-9]")) != none).len()
}

/// Put an invisible `tag` right after the first word of `c`, keeping any emphasis around it: a citation is filed
/// under the page where it starts (the docx engine finds it by its first word). Returns (content, placed). Not in
/// front of the first word: a tag at the start of a line is filed under the previous line, maybe the previous page.
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

/// Thousands separator for printed counts.
#let group-digits(n) = {
  let s = str(n)
  let out = ""
  let k = 0
  for ch in s.clusters().rev() {
    if k > 0 and calc.rem(k, 3) == 0 { out = "," + out }
    out = ch + out
    k += 1
  }
  out
}

/// Sort key for the table of authorities (the explicit `sort` field, else the name, else the cite), without the
/// markup (emphasis marks) and with straight quotes. Numbers compare by value, not digit by digit ("11 U.S.C. § 349"
/// before "§ 1112"): each run of digits is zero-padded first. The docx filter builds the same key.
#let sort-key(a) = {
  let s = lower(a.at("sort", default: a.at("name", default: "") + " " + a.at("cite", default: "")))
  s = s.replace(regex("[*_]"), "").replace(regex("[‘’]"), "'").replace(regex("[“”]"), "\"")
  s.replace(regex("\\d+"), m => "0" * calc.max(0, 10 - m.text.len()) + m.text)
}

/// The brief title on the cover (FRBP 8015(a)(2)(E): it identifies the party or parties for whom the brief is filed).
/// `brief_title` in the frontmatter overrides the default when the filer is more than one party or names the brief
/// it answers ("Appellants' Reply to Brief of Appellee ...").
#let brief-title(meta) = meta.at("brief_title", default: doc.title)

/// A single-spaced paragraph block with explicit space above (the line boxes carry the rest).
#let line-block(above, body, below: 0pt) = block(above: above, below: below, width: 100%, body)

// ---------------------------------------------------------------------------
// Cover (BAP-COVER-001: FRBP 8015(a)(2) and Litigants Manual §VIII.5 item 4 ff.)
// ---------------------------------------------------------------------------
#let cover(meta) = page(numbering: none, footer: none, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  set align(center)
  let gap = space.cover
  let small = space.cover-small
  line-block(0pt, strong[#need(meta, "case_number")])
  if "district_court_case" in meta { line-block(0pt, inl(meta.district_court_case)) }
  line-block(gap, strong(upper(court-name)))
  // FRBP 8015(a)(2)(C) and 8003(d)(2)(A): the title of the case is the title of the bankruptcy case ("In re ...,
  // Debtor") and then the parties to the appeal. Optional key `bankruptcy_case` (names, designation), printed first.
  let first = true
  if "bankruptcy_case" in meta {
    let bk = meta.bankruptcy_case
    for name in bk.at("names") { line-block(if first { gap } else { 0pt }, inl(name)); first = false }
    line-block(0pt, inl(bk.at("designation")))
  }
  for (i, side) in need(meta, "caption").enumerate() {
    if i > 0 { line-block(small, [v.]) }
    for (k, name) in side.at("names").enumerate() {
      line-block(if k == 0 { if i == 0 { gap } else { small } } else { 0pt }, inl(name))
    }
    line-block(0pt, inl(side.at("designation")))
  }
  let proceeding = need(meta, "proceeding")
  if proceeding != "" { line-block(gap, inl(proceeding)) }
  line-block(gap, strong(upper(inl(brief-title(meta)))))
  // counsel: printed as given, with the telephone number under the last group (FRAP 32(a)(2)(F), FRBP 8015(a)(2))
  let groups = need(meta, "counsel")
  for (gi, g) in groups.enumerate() {
    for (ni, name) in g.at("names").enumerate() {
      line-block(if ni == 0 { if gi == 0 { gap } else { small } } else { 0pt }, inl(name))
    }
    for line in g.at("lines", default: ()) { line-block(0pt, inl(line)) }
    if gi == groups.len() - 1 { line-block(0pt, inl(need(meta, "phone"))) }
  }
})

// ---------------------------------------------------------------------------
// Front matter: table of contents and table of authorities (FRBP 8014(a)(2))
// ---------------------------------------------------------------------------

/// A front-matter or certificate title: bold capitals, centered.
#let section-title(title, above) = block(width: 100%, above: above, below: space.h1.at(1), sticky: true,
  align(center, strong(upper(title))))

/// One table-of-contents row: level-1 headings at the margin, level-2 headings a paragraph indent in; the title
/// wraps before the page column and hangs under itself.
#let toc-entry(it) = {
  let hd = it.element
  let ind = (hd.level - 1) * para-indent
  listing-row(hd.location(), { h(ind); hd.body }, it.page(), toc-page-col, ind + para-indent, space.toc-row)
}

#let toc-section() = {
  section-title("Table of Contents", 0pt)
  show outline.entry: toc-entry
  outline(title: none, depth: 2, indent: 0pt)
}

/// Table of authorities. Every link `[text](toa:KEY)` in the body is recorded (tag below) with its page.
#let toa-section(authorities) = context {
  section-title("Table of Authorities", 0pt)
  let hits = query(<toa-hit>)
  let groups = (
    ("case", "Cases"),
    ("constitution", "Constitutional Provisions"),
    ("statute", "Statutes"),
    ("rule", "Rules"),
    ("regulation", "Regulations"),
    ("other", "Other Authorities"),
  )
  for (kind, label) in groups {
    let items = authorities.pairs().filter(p => p.last().at("kind", default: "other") == kind)
    if items.len() == 0 { continue }
    block(above: space.toa-group.at(0), below: space.toa-group.at(1), sticky: true, strong(label))
    for (key, a) in items.sorted(key: p => sort-key(p.last())) {
      let pages = hits.filter(h => h.value == key).map(h => counter(page).at(h.location()).first())
      if pages.len() == 0 { panic("bap9-" + doc.kind + ": authority `" + key + "` is listed but never cited") }
      let uniq = pages.dedup().sorted()
      let shown = if uniq.len() >= passim-threshold { "passim" } else { uniq.map(str).join(", ") }
      // the name is printed before the cite only when it adds something (a case name; a rule's name is its cite)
      let display = if "name" in a and a.name != a.cite { inl(a.name) + [, ] } else { [] }
      listing-row(none, [#display#inl(a.cite)], shown, calc.max(toa-page-col, measure(shown).width), toa-hang,
        space.toc-row)
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block and certificates (BAP Litigants Manual, Rule 5(b) and sample certificates)
// ---------------------------------------------------------------------------
#let signature-block(meta) = block(above: space.sig, below: 0pt, breakable: false, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  let sig = need(meta, "signature")
  pad(left: sig-indent, {
    block(above: 0pt, below: 0pt)[/s/ #sig.at("signer")]
    for line in sig.at("lines", default: ()) { block(above: 0pt, below: 0pt, inl(line)) }
    if "date" in meta { block(above: 0pt, below: 0pt, inl(meta.date)) }
  })
})

/// A certificate's paragraph: single-spaced, flush left, space above.
#let cert-par(body) = block(above: space.cert-par, below: 0pt, width: 100%, body)
/// A listed party or case: hanging under its first line.
#let cert-item(body) = block(above: space.cert-par, below: 0pt, width: 100%,
  par(hanging-indent: toa-hang, first-line-indent: 0pt, body))

/// One certificate, never split across a page: its heading and text stay together. The first one opens its page.
#let certificate(first, title, body) = block(above: if first { 0pt } else { space.cert.at(0) }, below: 0pt,
  breakable: false, width: 100%, {
    block(width: 100%, above: 0pt, below: space.cert.at(1), align(center, strong(upper(title))))
    body
  })

#let certificates(meta, words) = {
  let sig = need(meta, "signature")
  let sigline = block(above: space.cert-par, below: 0pt, pad(left: sig-indent, [/s/ #sig.at("signer")]))
  let first = true
  if "interested-parties" in doc.certs {
    certificate(first, "Certification of Interested Parties", {
      cert-par[The following listed parties have an interest in the outcome of this case. These representations are made in order that judges of the Panel may evaluate possible disqualification or recusal.]
      for p in need(meta, "interested_parties") { cert-item(inl(p)) }
      sigline
    })
    first = false
  }
  if "related-cases" in doc.certs {
    certificate(first, "Certification of Related Cases", {
      let rc = need(meta, "related_cases")
      if rc.at("status", default: "none") == "none" {
        cert-par[Appellant is aware of no related cases or appeals pending before this Panel, the Ninth Circuit Court of Appeals, or the district court.]
      } else {
        cert-par[The following related cases and appeals are known to the appellant:]
        for c in rc.at("cases") {
          cert-item[#inl(c.at("number")), #inl(c.at("name")), #inl(c.at("relationship"))]
        }
      }
      sigline
    })
    first = false
  }
  if "compliance" in doc.certs {
    certificate(first, "Certificate of Compliance", {
      cert-par[This brief complies with the type-volume limitation of Fed. R. Bankr. P. 8015(a)(7) because it contains #group-digits(words) words, excluding the parts of the brief exempted by Fed. R. Bankr. P. 8015(g).]
      cert-par[This brief complies with the typeface and type-style requirements of Fed. R. Bankr. P. 8015(a)(5) and (6) because it has been prepared in a proportionally spaced typeface, 14-point #font-family.first(), with plain roman type and italics for emphasis.]
      sigline
    })
    first = false
  }
  if "service" in doc.certs {
    certificate(first, "Certificate of Service", {
      let svc = meta.at("service", default: (:))
      let unreg = svc.at("unregistered", default: ())
      cert-par[I hereby certify that on #inl(need(meta, "date")), I electronically filed the foregoing document with the Clerk of the Court for the Bankruptcy Appellate Panel for the Ninth Circuit by using the CM/ECF system.]
      if unreg.len() == 0 {
        cert-par[I certify that all parties of record to this appeal either are registered CM/ECF users, or have registered for electronic notice, or have consented in writing to electronic service, and that service will be accomplished through the CM/ECF system.]
      } else {
        // BAP sample certificate ("not all case participants are registered"): the registered parties are served
        // through CM/ECF, and the others by mail, listed. Both statements are printed.
        cert-par[I further certify that parties of record to this appeal who either are registered CM/ECF users, or who have registered for electronic notice, or who have consented in writing to electronic service, will be served through the CM/ECF system.]
        cert-par[I further certify that some of the parties of record to this appeal have not consented to electronic service. I have mailed the foregoing document by First-Class Mail, postage prepaid, or have dispatched it to a third party commercial carrier for delivery within 3 calendar days, to the following parties:]
        for u in unreg { cert-item[#inl(u.at("name")), #inl(u.at("address"))] }
      }
      sigline
    })
  }
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------
#let bap9-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "caption", "proceeding", "counsel", "phone", "signature") { let _ = need(meta, k) }
  let authorities = if doc.authorities-required { need(meta, "authorities") } else { meta.at("authorities", default: none) }

  // ---- required sections (BAP-CONTENT-001) ----
  // Optional key `section_check: false` turns the check off for a transcription of a filed brief that predates or
  // departs from FRBP 8014 as amended Dec. 1, 2014 (e.g. a brief with no summary of argument); the panic would
  // otherwise drop the whole filed body. New briefs leave it unset.
  let required = if meta.at("section_check", default: true) == false { () } else { doc.required }
  for titles in required {
    // a title matches with or without an enumerator ("V. Discussion") and in any case ("CONCLUSION").
    let found = titles.any(h => md.match(regex("(?mi)^#[ \t]+(?:[IVXLC]+\\.[ \t]+)?" + h + "[ \t]*$")) != none)
    if not found {
      panic("bap9-" + doc.kind + ": the brief has no level-1 heading `" + titles.join("` or `") + "` (FRBP 8014(a))")
    }
  }

  // ---- length (BAP-LENGTH-001): body only; cover, tables, signature and certificates are excluded ----
  let words = count-words(md)
  if words > doc.word-limit {
    panic("bap9-" + doc.kind + ": the brief has " + str(words) + " words; FRBP 8015(a)(7) allows " + str(doc.word-limit))
  }

  // ---- document-wide settings ----
  set document(
    title: brief-title(meta) + ", " + need(meta, "case_number"),
    author: need(meta, "signature").at("signer"),
  )
  // The page number: centered in a single-spaced line box (the docx footer's), at the same place on every page.
  set page(paper: "us-letter", margin: page-margin, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model (lib/typst/xengine.typ): first fit, no kerning or ligatures, no hyphenation, line
  // boxes of the body pitch, footnote marks at 58 %, lists with the number in a half-inch box, a section sign kept
  // with its number, no break inside "60(b)(5)".
  show: xengine.with(pitch: pitch-double, list-indent: para-indent)
  // Footnote marks are the digit scaled down (Word's and LibreOffice's superscript), not the font's own superscript
  // figures, which have other advances.
  set super(typographic: false)
  // No break after a slash inside a word ("CM/ECF", "and/or"): LibreOffice and Word keep the word whole.
  show regex("\\S+/\\S+"): it => box(it)
  set heading(numbering: none)
  // The footnote area as Word's: a 2 in rule, and between the body and the first note the height of Word's separator
  // paragraph (one 14 pt Times New Roman line, 16.1 pt, measured on LibreOffice: a body line fits above a note with
  // 16.1 pt to spare, not with 16.05) = clearance + gap; the notes 7 pt apart (Footnote Text, 7 pt after).
  set footnote.entry(
    gap: space.note, clearance: 16.1pt - space.note, indent: 0pt,
    separator: line(length: 2in, stroke: 0.5pt),
  )
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)   // footnotes are laid out outside the body: the line boxes touch here too
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    // the mark, a word space (Word's footnote: the reference mark, then a space), the note
    [#super(num) #note.body]
  }
  show quote.where(block: true): it => block(above: space.quote, below: space.quote,
    pad(left: para-indent, right: para-indent, {
      set text(..edges(pitch-single))
      set par(first-line-indent: 0pt)
      it.body
    }))
  // Headings: level 1 are the brief's sections (centered, bold); level 2 are argument headings (bold, left);
  // level 3 are the sub-headings under them (bold, left, hanging). Single-spaced; kept with the text after them.
  show heading: it => {
    set text(size: type-size, weight: "bold", ..edges(pitch-single))
    set par(first-line-indent: 0pt)
    if it.level == 1 {
      block(width: 100%, above: space.h1.at(0), below: space.h1.at(1), sticky: true, align(center, it.body))
    } else {
      let (a, b) = if it.level == 2 { space.h2 } else { space.h3 }
      block(width: 100%, above: a, below: b, sticky: true,
        par(hanging-indent: para-indent, first-line-indent: 0pt, it.body))
    }
  }
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      tag-after-first-word(it.body, [#metadata(it.dest.slice(4))<toa-hit>]).first()
    } else { it.body }
  }

  // ---- cover ----
  cover(meta)

  // ---- front matter (lowercase roman) ----
  set page(numbering: "i")
  counter(page).update(1)
  {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    toc-section()
    if authorities != none {
      pagebreak()
      toa-section(authorities)
    }
  }

  // ---- body (arabic from 1) ----
  set page(numbering: "1")
  counter(page).update(1)
  pagebreak()
  // The signature block never stands alone: the brief's last paragraph is kept with it.
  let text-md = md.trim(at: end)
  let seps = text-md.matches(regex("\n[ \t]*\n"))
  let cut = if seps.len() == 0 { 0 } else { seps.last().start }
  cmarker.render(text-md.slice(0, cut), raw-typst: false, smart-punctuation: true, h1-level: 1)
  block(breakable: false, {
    cmarker.render(text-md.slice(cut), raw-typst: false, smart-punctuation: true, h1-level: 1)
    signature-block(meta)
  })

  // ---- certificates (after the body; FRBP 8015(h), BAP R. 8015(a)-1) ----
  pagebreak()
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  certificates(meta, words)
}
