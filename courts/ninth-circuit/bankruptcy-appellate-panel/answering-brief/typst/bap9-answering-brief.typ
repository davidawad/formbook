// Bankruptcy Appellate Panel of the Ninth Circuit: appellee's answering brief (FRBP 8014, 8015).
//
// Rule-driven and content-agnostic. Requirement IDs (BAP-...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of
// the same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")          // BAP-FORM-002: proportionally spaced; vendored in /fonts.
#let type-size = 14pt                      // BAP-FORM-002: 14-point or larger, everywhere.
#let body-leading = 1.3em                  // BAP-FORM-003: double spacing; calibrated by measured line pitch (../README.md).
#let single-leading = 0.12em               // headings, quotations, footnotes, TOC/TOA, certificates.
#let page-margin = 1in                     // BAP-FORM-001: one inch on all four sides.
#let para-indent = 0.5in
#let passim-threshold = 7                  // an authority cited on this many pages or more: "passim".
#let court-name = "United States Bankruptcy Appellate Panel of the Ninth Circuit"

// ---------------------------------------------------------------------------
// Per-document-type settings (this folder: appellee's answering brief)
// ---------------------------------------------------------------------------
#let doc = (
  kind: "answering",
  title: "Appellee's Answering Brief",
  // BAP-CONTENT-001: FRBP 8014(b). The appellee's brief meets the same requirements as the opening brief,
  // except that the statements of jurisdiction, of issues and standards of review, and of the case need not be
  // included. The summary, argument and conclusion (FRBP 8014(a)(6)-(7)) remain required.
  // Each entry is a requirement with the titles a brief may use (see the opening-brief template). The Klein
  // exemplar titles its argument "Discussion" (FRBP 8014(a)(8) fixes the content, not the title).
  required: (
    ("Summary of Argument", "Summary of the Argument"),
    ("Argument", "Discussion"),
    ("Conclusion",),
  ),
  // BAP-LENGTH-001: FRBP 8015(a)(7): 30 pages, or the type-volume limit of 8015(a)(7)(B).
  word-limit: 13000,
  // BAP-CERT-001: BAP Litigants Manual §VIII.5 item 6: the responsive brief carries a certification of interested
  // parties (BAP R. 8015(a)-1). It does not carry a certification of related cases.
  certs: ("interested-parties", "compliance", "service"),
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

/// A dot leader for the tables.
#let dot-leader = box(width: 1fr, repeat[.#h(0.2em)])

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

/// Sort key for the table of authorities (the explicit `sort` field, else the name, else the cite).
/// Numbers compare by value, not digit by digit ("11 U.S.C. § 349" before "§ 1112"): each run of digits is
/// zero-padded to a common width before the comparison.
#let sort-key(a) = lower(a.at("sort", default: a.at("name", default: "") + " " + a.at("cite", default: ""))).replace(
  regex("\\d+"), m => "0" * calc.max(0, 10 - m.text.len()) + m.text,
)

// ---------------------------------------------------------------------------
// Cover (BAP-COVER-001: FRBP 8015(a)(2) and Litigants Manual §VIII.5 item 4 ff.)
// ---------------------------------------------------------------------------
/// The brief title on the cover (FRBP 8015(a)(2)(E): it identifies the party or parties for whom the brief is filed).
/// `brief_title` in the frontmatter overrides the default when the filer is more than one party or names the brief
/// it answers ("Appellants' Reply to Brief of Appellee ...").
#let brief-title(meta) = meta.at("brief_title", default: doc.title)

#let cover(meta) = page(numbering: none, footer: none, {
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.35em, justify: false)
  set align(center)
  strong[#need(meta, "case_number")]
  if "district_court_case" in meta { linebreak(); inl(meta.district_court_case) }
  v(1.2em)
  strong(upper(court-name))
  v(1.4em)
  // FRBP 8015(a)(2)(C) and 8003(d)(2)(A): the title of the case is the title of the bankruptcy case ("In re ...,
  // Debtor") and then the parties to the appeal. Optional key `bankruptcy_case` (names, designation), printed first.
  if "bankruptcy_case" in meta {
    let bk = meta.bankruptcy_case
    for name in bk.at("names") {
      inl(name)
      linebreak()
    }
    inl(bk.at("designation"))
    v(1.0em)
  }
  for (i, side) in need(meta, "caption").enumerate() {
    for name in side.at("names") {
      inl(name)
      linebreak()
    }
    inl(side.at("designation"))
    v(0.6em)
    if i == 0 {
      [v.]
      v(0.6em)
    }
  }
  v(0.8em)
  inl(need(meta, "proceeding"))
  v(1.6em)
  strong(upper(brief-title(meta)))
  v(1.6em)
  // counsel: printed as given, with the telephone number under the last group (FRAP 32(a)(2)(F), FRBP 8015(a)(2))
  let groups = need(meta, "counsel")
  for (gi, g) in groups.enumerate() {
    for name in g.at("names") {
      inl(name)
      linebreak()
    }
    for line in g.at("lines", default: ()) {
      emph(inl(line))
      linebreak()
    }
    if gi == groups.len() - 1 {
      inl(need(meta, "phone"))
    }
    if gi < groups.len() - 1 { v(0.9em) }
  }
})

// ---------------------------------------------------------------------------
// Front matter: table of contents and table of authorities (FRBP 8014(a)(2))
// ---------------------------------------------------------------------------

/// Table of authorities. Every link `[text](toa:KEY)` in the body is recorded (tag below) with its page.
#let toa-section(authorities) = context {
  align(center, strong[TABLE OF AUTHORITIES])
  v(1em)
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
    block(above: 1em, below: 0.6em, breakable: false, par(first-line-indent: 0pt, leading: single-leading, strong(label)))
    for (key, a) in items.sorted(key: p => sort-key(p.last())) {
      let pages = hits.filter(h => h.value == key).map(h => counter(page).at(h.location()).first())
      if pages.len() == 0 { panic("bap9-" + doc.kind + ": authority `" + key + "` is listed but never cited") }
      let uniq = pages.dedup().sorted()
      let shown = if uniq.len() >= passim-threshold { "passim" } else { uniq.map(str).join(", ") }
      // the name is printed before the cite only when it adds something (a case name; a rule's name is its cite)
      let display = if "name" in a and a.name != a.cite { inl(a.name) + [, ] } else { [] }
      block(above: 0.5em, below: 0.4em, breakable: false, par(
        first-line-indent: 0pt, hanging-indent: 0.4in, leading: single-leading, justify: false,
        [#display#inl(a.cite)#dot-leader #shown],
      ))
    }
  }
}

#let toc-section() = {
  // Sub-headings are indented under their section (tier 2: the Klein, Hujazi and Beavor tables of contents all
  // indent them; a flush-left list hid the hierarchy).
  outline(title: align(center, strong[TABLE OF CONTENTS]), depth: 2, indent: para-indent)
}

// ---------------------------------------------------------------------------
// Signature block and certificates (BAP Litigants Manual, Rule 5(b) and sample certificates)
// ---------------------------------------------------------------------------
#let signature-block(meta) = block(above: 1.6em, breakable: false, {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  let sig = need(meta, "signature")
  pad(left: 3in, [
    /s/ #sig.at("signer")#linebreak()
    #for line in sig.at("lines", default: ()) {
      emph(inl(line))
      linebreak()
    }
    #if "date" in meta { inl(meta.date) }
  ])
})

/// One certificate, never split across a page: its heading and text stay together.
#let certificate(title, body) = block(above: 1.2em, below: 0.6em, breakable: false, {
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.9em, justify: false)
  align(center, strong(upper(title)))
  v(0.9em)
  body
})

#let certificates(meta, words) = {
  let sig = need(meta, "signature")
  let sigline = pad(left: 3in, [/s/ #sig.at("signer")])
  if "interested-parties" in doc.certs {
    certificate("Certification of Interested Parties", {
      [The following listed parties have an interest in the outcome of this case. These representations are made in order that judges of the Panel may evaluate possible disqualification or recusal.]
      for p in need(meta, "interested_parties") {
        par(first-line-indent: 0pt, hanging-indent: 0.4in, leading: single-leading, [#inl(p)])
      }
      sigline
    })
  }
  if "related-cases" in doc.certs {
    certificate("Certification of Related Cases", {
      let rc = need(meta, "related_cases")
      if rc.at("status", default: "none") == "none" {
        [Appellant is aware of no related cases or appeals pending before this Panel, the Ninth Circuit Court of Appeals, or the district court.]
      } else {
        [The following related cases and appeals are known to the appellant:]
        for c in rc.at("cases") {
          par(first-line-indent: 0pt, hanging-indent: 0.4in, leading: single-leading, [#inl(c.at("number")), #inl(c.at("name")), #inl(c.at("relationship"))])
        }
      }
      sigline
    })
  }
  if "compliance" in doc.certs {
    certificate("Certificate of Compliance", {
      [This brief complies with the type-volume limitation of Fed. R. Bankr. P. 8015(a)(7) because it contains #group-digits(words) words, excluding the parts of the brief exempted by Fed. R. Bankr. P. 8015(g).]
      parbreak()
      [This brief complies with the typeface and type-style requirements of Fed. R. Bankr. P. 8015(a)(5) and (6) because it has been prepared in a proportionally spaced typeface, 14-point #font-family, with plain roman type and italics for emphasis.]
      sigline
    })
  }
  if "service" in doc.certs {
    certificate("Certificate of Service", {
      let svc = meta.at("service", default: (:))
      let unreg = svc.at("unregistered", default: ())
      [I hereby certify that on #inl(need(meta, "date")), I electronically filed the foregoing document with the Clerk of the Court for the Bankruptcy Appellate Panel for the Ninth Circuit by using the CM/ECF system.]
      parbreak()
      if unreg.len() == 0 {
        [I certify that all parties of record to this appeal either are registered CM/ECF users, or have registered for electronic notice, or have consented in writing to electronic service, and that service will be accomplished through the CM/ECF system.]
      } else {
        // BAP sample certificate ("not all case participants are registered"): the registered parties are served
        // through CM/ECF, and the others by mail, listed. Both statements are printed.
        [I further certify that parties of record to this appeal who either are registered CM/ECF users, or who have registered for electronic notice, or who have consented in writing to electronic service, will be served through the CM/ECF system.]
        parbreak()
        [I further certify that some of the parties of record to this appeal have not consented to electronic service. I have mailed the foregoing document by First-Class Mail, postage prepaid, or have dispatched it to a third party commercial carrier for delivery within 3 calendar days, to the following parties:]
        for u in unreg {
          par(first-line-indent: 0pt, hanging-indent: 0.4in, leading: single-leading, [#inl(u.at("name")), #inl(u.at("address"))])
        }
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
  let authorities = meta.at("authorities", default: none)

  // ---- required sections (BAP-CONTENT-001) ----
  for titles in doc.required {
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
  set page(paper: "us-letter", margin: page-margin, number-align: center)
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: "ascender", bottom-edge: "descender",
  )
  set par(
    leading: body-leading, spacing: body-leading,
    first-line-indent: (amount: para-indent, all: true), justify: false,
  )
  set heading(numbering: none)
  set footnote.entry(
    gap: 0.5em, clearance: 0.9em, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt),
  )
  show footnote.entry: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, spacing: 0.5em)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }
  show quote.where(block: true): it => block(above: 1em, below: 1em, pad(left: para-indent, right: para-indent, {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.9em)
    it.body
  }))
  // Never break inside a token of adjacent parentheses ("60(b)(5)") or between § / ¶ and the number.
  show regex("\\S*\\)\\(\\S*"): it => box(it)
  show regex("[§¶] \\S+"): it => box(it)
  // Headings: level 1 are the brief's sections (centered, bold); level 2 are argument headings (bold, left);
  // level 3 are the sub-headings under them (bold, left, hanging).
  // Each level has its own rule: a generic `show heading` rule ahead of these returned the heading unchanged.
  // Level 1 needs the explicit width: without it the block shrinks and `align(center)` does not center.
  // Space above each heading is larger than the paragraph spacing (body-leading), and space below is smaller,
  // so a heading sits with the text it introduces (it sat closer to the preceding paragraph before).
  show heading.where(level: 1): it => block(width: 100%, above: body-leading + 0.8em, below: 1.1em, breakable: false, {
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, justify: false)
    set text(size: type-size, weight: "bold")
    align(center, it.body)
  })
  show heading.where(level: 2): it => block(above: body-leading + 0.5em, below: 0.9em, breakable: false, {
    set par(first-line-indent: 0pt, hanging-indent: 0.5in, leading: single-leading, justify: false)
    set text(size: type-size, weight: "bold")
    it.body
  })
  show heading.where(level: 3): it => block(above: body-leading + 0.5em, below: 0.8em, breakable: false, {
    set par(first-line-indent: 0pt, hanging-indent: 0.5in, leading: single-leading, justify: false)
    set text(size: type-size, weight: "bold")
    it.body
  })
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      [#it.body#metadata(it.dest.slice(4))<toa-hit>]
    } else { it.body }
  }

  // ---- cover ----
  cover(meta)

  // ---- front matter (lowercase roman) ----
  set page(numbering: "i")
  counter(page).update(1)
  toc-section()
  if authorities != none {
    pagebreak()
    toa-section(authorities)
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
  set par(first-line-indent: 0pt)
  certificates(meta, words)
}
