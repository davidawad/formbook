// Travis County, Texas, district courts (txdistrict-travis): the parts shared by every doc type of this court folder:
// the caption, the body, the signature block (TRCP 57), the certificates (TRCP 21(d), 21a(e); Travis Local Rule 2.2),
// the verification (Tex. Civ. Prac. & Rem. Code 132.001) and the order page (Travis Local Rules 11.4, 11.5).
//
// Rule-driven and content-agnostic. The rules and the date each was read are in ../rules.md. No case-specific text,
// no coordinates measured off a filed paper, no forced line breaks: every case word comes from the sample's frontmatter
// or its markdown body. Neither TRCP nor the Travis Local Rules set a typeface, size, margin or spacing for papers in
// the district courts, so each number below that is not tied to a rule is a NAMED STYLE CHOICE (tier 2: the
// convention seen in the filed exemplars, usage/SOURCE.md), marked "style".
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // style: the house face when a court names none
#let type-size = 12pt                  // style: 12 pt body (the filed exemplars; no rule sets a size)
#let page-w = 8.5in                    // TRCP 45 (paper filings): approximately 8 1/2 by 11 inches; Technology Standards 3.1(A): 8.5x11
#let page-h = 11in
#let margin-side = 1in                 // style: one inch (no rule)
#let margin-top = 1in                  // style: one inch; the clerk's e-file stamp prints in the top right (exemplars)
#let margin-bottom = 1in               // style
#let pitch = 27.6pt                    // style: double spacing (Word's double, 2 x 1.15 x 12 pt), body text
#let pitch-single = 13.8pt             // style: single spacing (Word's single, 1.15 x 12 pt): caption, quotations,
                                       // signature block, service list, footnotes
#let para-indent = 0.5in               // style: first-line indent of a paragraph
#let quote-inset = 0.5in               // style: block quotations, both sides, single-spaced
#let sig-col = 3.25in                  // style: the signature block starts at the right half of the page
#let caption-left = 47%                // style: the parties' column; the section-sign column and the court column follow
#let caption-mid = 0.4in               // style: the column of section signs between them
#let note-size = 12pt                  // style: footnotes in the body size
#let footer-size = 10pt
#let title-underline-offset = 2.5pt  // style: underline below the descenders of bold capitals (font default sits about 1.3pt below the baseline and touches them)                // style: the footer title
#let heading-gap = 12pt                // style: space above and below a heading
#let sign-gap = 18pt                   // style: space above the date line, the signature block, a certificate
#let court-name = "Travis County, Texas"   // the court's constant text; the number of the district is the filer's
#let salutation = "TO THE HONORABLE JUDGE OF SAID COURT:"   // convention in every exemplar (usage/SOURCE.md)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

#let edges(p) = (top-edge: 0.8 * p, bottom-edge: -0.2 * p)   // every line a box of its pitch, the baseline at 0.8 of it

#let need(meta, key) = {
  if key not in meta { panic("txdistrict-travis: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("txdistrict-travis: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let render(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)
#let inl(s) = cmarker.render(str(s), raw-typst: false, smart-punctuation: true)
#let as-list(v) = if v == none { () } else if type(v) == array { v } else { (v,) }

#let single(c) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  c
}

#let roman(n) = {
  let out = ""
  let n = n
  for (v, s) in ((10, "X"), (9, "IX"), (5, "V"), (4, "IV"), (1, "I")) {
    while n >= v { out += s; n -= v }
  }
  out
}

// ---------------------------------------------------------------------------
// Caption: the cause number, then the parties in the left column, a column of section signs, and the court in the
// right column ("IN THE DISTRICT COURT OF", the district, the county), then the title (convention in every exemplar).
// ---------------------------------------------------------------------------

#let caption(meta) = {
  let sides = need(meta, "caption")
  let left = {
    for (k, s) in sides.enumerate() {
      if k > 0 { block(above: pitch-single, single(align(left, [v.]))) }
      block(above: if k > 0 { pitch-single } else { 0pt }, single({
        strong(upper(inl(need(s, "names").replace("/", "/\u{2060}"))))
        if "designation" in s { linebreak(); h(1em); emph(inl(s.designation)) }
      }))
    }
  }
  align(center, block(below: pitch-single, single(strong[CAUSE NO. #need(meta, "cause_number")])))
  layout(size => {
    let lw = size.width * caption-left
    let h = measure(width: lw, left).height
    let n = calc.max(3, int(calc.round(h / pitch-single)))
    grid(
      columns: (caption-left, caption-mid, 1fr),
      column-gutter: 0pt,
      block(height: h, left),
      single(align(center, block(height: h, for _ in range(n) { [§] + linebreak() }))),
      block(height: h, inset: (left: 0.15in), single(grid(
        rows: (1fr, 1fr, 1fr), columns: 100%,
        align(top, strong[IN THE DISTRICT COURT OF]),
        align(horizon, strong[#upper(inl(need(meta, "judicial_district"))) JUDICIAL DISTRICT]),
        align(bottom, strong(upper(court-name))),
      ))),
    )
  })
}

/// Capitals for a title, except inside a bracketed drafting marker ("[VERIFY: ...]"), which prints as typed.
#let upper-markers(s) = {
  let s = str(s)
  let out = []
  let pos = 0
  for m in s.matches(regex("\\[[^\\]]*\\]")) { out += upper(inl(s.slice(pos, m.start))); if m.start > 0 { out += [ ] }; out += inl(m.text); pos = m.end }
  out + upper(inl(s.slice(pos)))
}

// `title_underline: true` underlines the title (as in original-answer exemplar 2); default off.
#let title-block(meta) = align(center, block(above: sign-gap, below: sign-gap, width: 100%, {
  let t = strong(upper-markers(need(meta, "title")))
  single(if meta.at("title_underline", default: false) == true { underline(offset: title-underline-offset, t) } else { t })
}))

// ---------------------------------------------------------------------------
// The body: each blank-line-separated chunk of markdown is a heading, a block quotation, a list or a paragraph.
// Footnote definitions travel with the chunk that refers to them.
// ---------------------------------------------------------------------------

#let split-label(t) = {
  let m = t.match(regex("^([A-Za-z]{1,4}|\\d{1,3})\\.[ \\t]+"))
  if m == none { (none, t) } else { (m.captures.at(0) + ".", t.slice(m.end)) }
}

/// Level 1: centered bold capitals with a Roman numeral counted by the template (style: the exemplars number their
/// parts I., II., ...). Level 2: bold, the author's label ("A.") hanging. Level 3: bold italic.
#let heading-block(level, t, n, parts: true) = block(width: 100%, sticky: true, above: heading-gap, below: heading-gap, single({
  set text(weight: "bold")
  if level == 1 {
    align(center, { if parts { block[#roman(n).] }; if t != "(none)" { block(upper(inl(t))) } })
  } else {
    let (lab, rest) = split-label(t)
    let ind = (level - 2) * 0.5in
    let body = if level >= 3 { emph(inl(rest)) } else { inl(rest) }
    if lab == none { par(hanging-indent: ind, { h(ind); body }) }
    else { par(hanging-indent: ind + 0.5in, { h(ind); box(width: 0.5in, lab); body }) }
  }
}))

#let body-par(num, c) = block(width: 100%, {
  h(para-indent)
  if num != none { [#num.#h(0.5em)] }
  c
})

#let list-block(c) = block(width: 100%, pad(left: 0.5in, single(c)))

#let block-quote(c) = block(width: 100%, above: pitch-single, below: pitch-single,
  pad(left: quote-inset, right: quote-inset, single(c)))

/// The markdown body as an array of typeset blocks. Paragraphs after the first heading are numbered 1., 2., ... through the
/// whole body when `numbered` (the exemplars number every paragraph of the pleading under its parts). Not numbered: the paragraphs
/// before the first heading (the opening), those under a heading that begins "Prayer", and one that begins "WHEREFORE".
/// `parts: false` leaves the Roman numeral off level-one headings (the text of an order is not numbered).
#let body-blocks(body, numbered: true, parts: true) = {
  let notes = (:)
  for m in body.matches(regex("(?m)^\\[\\^([^\\]]+)\\]:[ \\t]*(.*)$")) { notes.insert(m.captures.at(0), m.captures.at(1)) }
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
    .filter(c => not c.starts-with(regex("^\\[\\^[^\\]]+\\]:")))
  let h = 0
  let p = 0
  let out = ()
  let prayer = false
  for t in chunks {
    let defs = ""
    for r in t.matches(regex("\\[\\^([^\\]]+)\\]")) { defs += "\n\n[^" + r.captures.at(0) + "]: " + notes.at(r.captures.at(0), default: "") }
    let m = t.match(regex("^(#+)[ \\t]+(.*)$"))
    if t == "---" {
      // A thematic break is a part with a numeral and no heading text (the Seattle Children's joint motion: "I.", "II.").
      h += 1; prayer = false
      out.push(heading-block(1, "(none)", h, parts: parts))
    } else if m != none {
      let level = m.captures.at(0).len()
      if level == 1 { h += 1; prayer = lower(m.captures.at(1).trim()).starts-with("prayer") }
      out.push(heading-block(level, m.captures.at(1).trim(), h, parts: parts))
    } else if t.starts-with(">") {
      out.push(block-quote(render(t.replace(regex("(?m)^>[ \\t]?"), "") + defs)))
    } else if t.starts-with(regex("^([-*+]|\\d+\\.)[ \\t]")) {
      out.push(list-block(render(t + defs)))
    } else if numbered and h > 0 and not prayer and not t.starts-with("WHEREFORE") {
      p += 1
      out.push(body-par(p, render(t + defs)))
    } else {
      out.push(body-par(none, render(t + defs)))
    }
  }
  out
}

// ---------------------------------------------------------------------------
// Signature block (TRCP 57): name, State Bar of Texas number, address, telephone, email, fax if any; the electronic
// signature "/s/ Name". Kept whole on a page.
// ---------------------------------------------------------------------------

#let signature-block(meta, closing: "Respectfully submitted,") = {
  let sig = need(meta, "signature")
  block(width: 100%, above: sign-gap, breakable: false, single({
    if "date" in sig { block(below: pitch-single, [Dated: #inl(sig.date)]) }
    pad(left: sig-col, {
      if closing != none { block(below: pitch-single, closing) }
      if "firm" in sig { block(strong(upper(inl(sig.firm)))) }
      block(above: pitch-single, [By: /s/ #inl(need(sig, "signer"))])
      block(upper(inl(need(sig, "signer"))))
      block([State Bar of Texas No. #inl(need(sig, "bar_no"))])
      for l in as-list(need(sig, "lines")) { block(inl(l)) }
      block([Telephone: #inl(need(sig, "phone"))])
      if "fax" in sig { block([Fax: #inl(sig.fax)]) }
      block([Email: #inl(need(sig, "email"))])
      for o in as-list(sig.at("others", default: ())) {
        block(above: pitch-single, upper(inl(need(o, "name"))))
        block([State Bar of Texas No. #inl(need(o, "bar_no"))])
        block([Email: #inl(need(o, "email"))])
      }
      if "role" in sig { block(above: pitch-single, strong(upper(inl(sig.role)))) }
    })
  }))
}

// ---------------------------------------------------------------------------
// Certificates. Each is a centered bold heading and a paragraph, then the signature line of the signer.
// ---------------------------------------------------------------------------

#let cert-heading(t) = block(width: 100%, sticky: true, below: heading-gap, single(align(center, strong(upper(t)))))

#let cert-sign(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, above: pitch-single, breakable: false, single(pad(left: sig-col, {
    block([/s/ #inl(need(sig, "signer"))])
    block(inl(need(sig, "signer")))
  })))
}

/// Travis Local Rule 2.2: the setting certification (every motion) and, for a motion that is not dispositive, the
/// conference certification, in the words of the rule.
#let conference-certificate(meta) = block(width: 100%, above: sign-gap, breakable: false, {
  let c = need(meta, "conference")
  let with-all = (conferred: "conferred with", efforts: "made reasonable efforts to confer with")
  let setting = need(c, "setting")
  if setting not in with-all { panic("txdistrict-travis: conference.setting must be `conferred` or `efforts`") }
  cert-heading[Certificate of Conference]
  // `text` replaces the Local Rule 2.2 sentences (for example a joint or agreed motion, where every party conferred and agrees).
  if "text" in c {
    block(width: 100%, body-par(none, inl(c.text)))
  } else {
  block(width: 100%, body-par(none, [I certify that counsel has #with-all.at(setting) all parties about the date, time, and format of the setting.]))
  if not c.at("dispositive", default: false) {
    let issues = need(c, "issues")
    if issues == "conferred" {
      block(width: 100%, body-par(none, [Counsel has conferred with all parties who may be affected by the relief sought in this motion in a good faith effort to resolve or narrow the issues raised.]))
    } else if issues == "efforts" {
      block(width: 100%, body-par(none, [Counsel has made reasonable efforts to confer with all parties who may be affected by the relief sought in this motion but has been unable to do so.]))
    } else { panic("txdistrict-travis: conference.issues must be `conferred` or `efforts`") }
  }
  }
  if "detail" in c { block(width: 100%, body-par(none, inl(c.detail))) }
  cert-sign(meta)
})

/// A certificate of service laid out so that a long list of recipients can run onto another page (an unbreakable block
/// taller than a page loses its overflow): `top` (heading and statement) stays whole with the first recipient, the middle
/// recipients flow, and the last recipient stays whole with the signature line. Each recipient is its own unbreakable block.
#let cert-flow(top, items, sign) = {
  let item-gap = pitch-single
  if items.len() <= 1 {
    block(width: 100%, above: sign-gap, breakable: false, { top; for r in items { r }; sign })
  } else {
    block(width: 100%, above: sign-gap, breakable: false, { top; items.first() })
    for r in items.slice(1, items.len() - 1) { r }
    block(width: 100%, above: item-gap, breakable: false, { items.last(); sign })
  }
}

/// A recipient of a certificate of service: the name and address lines, indented.
#let recipient-block(r) = block(width: 100%, above: pitch-single, breakable: false, single(pad(left: 0.5in, {
  block(inl(need(r, "name")))
  for l in as-list(r.at("lines", default: ())) { block(inl(l)) }
})))

/// TRCP 21(d), 21a(e): the party or attorney certifies compliance in writing over signature on the filed paper,
/// stating the date and manner of service and whom it reached.
#let service-certificate(meta) = {
  let s = need(meta, "service")
  let method = s.at("method", default: "electronic service through the electronic filing manager")
  cert-flow({
    cert-heading[Certificate of Service]
    block(width: 100%, body-par(none, [I certify that on #inl(need(s, "date")), a true and correct copy of the foregoing document was served in accordance with Texas Rule of Civil Procedure 21a, by #inl(method), on the following counsel of record or parties:]))
  }, as-list(need(s, "recipients")).map(recipient-block), cert-sign(meta))
}

/// Tex. Civ. Prac. & Rem. Code 132.001: an unsworn declaration in place of a verification, with the statutory jurat.
#let verification(meta) = block(width: 100%, above: sign-gap, breakable: false, {
  let v = need(meta, "verification")
  cert-heading[Verification]
  block(width: 100%, body-par(none, inl(need(v, "statement"))))
  block(width: 100%, body-par(none, [My name is #inl(need(v, "declarant")), my date of birth is #inl(need(v, "birth_date")), and my address is #inl(need(v, "address")), #inl(v.at("country", default: "United States of America")). I declare under penalty of perjury that the foregoing is true and correct.]))
  block(width: 100%, body-par(none, [Executed in #inl(need(v, "county")) County, State of #inl(v.at("state", default: "Texas")), on the #inl(need(v, "day")) day of #inl(need(v, "month")), #inl(need(v, "year")).]))
  block(width: 100%, above: pitch-single, breakable: false, single(pad(left: sig-col, {
    block(line(length: 100%, stroke: 0.5pt))
    block(inl(need(v, "declarant")))
    block[Declarant]
  })))
})

// ---------------------------------------------------------------------------
// The page and the paper as a whole
// ---------------------------------------------------------------------------

#let page-setup(meta, doc) = {
  set page(
    width: page-w, height: page-h,
    margin: (top: margin-top, bottom: margin-bottom, left: margin-side, right: margin-side),
    // `footer: none` (YAML `footer: none`) drops the footer; no rule requires one. Default: page number, with footer_title.
    footer: if str(meta.at("footer", default: "page")) == "none" { none } else { context {
      set text(size: footer-size)
      set par(first-line-indent: 0pt)
      align(center, {
        if "footer_title" in meta { upper(inl(meta.footer_title)); [ #sym.dash.en ] }
        [Page #counter(page).display("1")]
      })
    } },
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false, ..edges(pitch))
  set par(first-line-indent: 0pt, leading: 0pt, spacing: 0pt, justify: false)
  set block(above: 0pt, below: 0pt)
  set footnote.entry(gap: 4pt, clearance: 8pt, indent: 0pt, separator: line(length: 2in, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: note-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt)
    it
  }
  show regex("[§¶]+ \\S+"): it => box(it)
  doc
}

/// The caption block and the title; for papers addressed to the court, the salutation.
#let head(meta, salute: true) = {
  caption(meta)
  title-block(meta)
  if salute { block(width: 100%, [#salutation]) }
}

/// `last` (the final block of the body, which may be a long list) flows and may break across pages; `tail` (the signature
/// material) stays whole. `last` is sticky, so it travels with the tail and the signature never stands alone on a page
/// (Local Rule 11.4); an unbreakable block taller than a page would lose its overflow, so `last` is never made unbreakable.
/// `above` and `gap` are the space before `last` and between `last` and `tail` (a block's own `above` is dropped at the
/// start of the wrapper, so the caller names it).
#let keep-tail(last, tail, above: 0pt, gap: 0pt) = {
  if last != none { block(width: 100%, sticky: true, above: above, last) }
  block(width: 100%, breakable: false, above: gap, tail)
}

/// A proposed order (Travis Local Rule 11.4): its own paper with the cause number, the style of the case and the
/// court; its judge's signature line on a page with other text; the date signed (Local Rule 11.5: never "entered").
#let order-paper(meta, body) = {
  head(meta, salute: false)
  let pieces = body-blocks(body, numbered: false, parts: false)
  for b in pieces.slice(0, calc.max(0, pieces.len() - 1)) { b }
  keep-tail(if pieces.len() > 0 { pieces.last() } else { none }, block(width: 100%, above: 2 * sign-gap, single({
    block(below: 2 * pitch-single, [SIGNED on #box(width: 2in, line(length: 100%, stroke: 0.5pt)), 20#box(width: 0.5in, line(length: 100%, stroke: 0.5pt)).])
    pad(left: sig-col, {
      block(line(length: 100%, stroke: 0.5pt))
      block[JUDGE PRESIDING]
    })
  })), above: sign-gap, gap: 2 * sign-gap)
}

/// The body's blocks with the signature block, the last block kept on the same page as the signature (a signature
/// alone on a page is not a convention in any exemplar).
#let with-signature(pieces, sig) = {
  for p in pieces.slice(0, calc.max(0, pieces.len() - 1)) { p }
  keep-tail(if pieces.len() > 0 { pieces.last() } else { none }, sig, gap: sign-gap)
}
