// Travis County district courts (txdistrict-travis): a proposed order (or a signed order) as its own paper.
//
// Rule-driven and content-agnostic; shared parts in /lib/typst/txdistrict-travis-common.typ, rules in ../../rules.md.
// Local Rule 11.4: a draft order is not typed on a page with a pleading, motion or certificate of service, carries the
// cause number, style of the case and court, and its judge's signature line is on a page with other text; Local Rule
// 11.5: the date an order is signed is never shown with the word "entered"; Local Rule 11.1: a proposed order is
// not filed stand-alone, only as an attachment to the motion or other pleading; it is its own PDF. An order needs no filer's signature or certificate of service (TRCP 21, 21a, 57 reach filed
// papers of a party); the optional "approved as to form" blocks are the filers' convention (usage/SOURCE.md).
// The title, the recitals, the findings and the decretal paragraphs are the filer's: the template typesets them and
// prints the caption, the signed-on line with a blank date, the judge's line and any approval blocks.
#import "/lib/typst/txdistrict-travis-common.typ": *

#let blank(w) = box(width: w, line(length: 100%, stroke: 0.5pt))
#let box-mark = box(width: 0.7em, height: 0.7em, stroke: 0.6pt, baseline: 0.05em)

/// The title between two horizontal rules (two of the three exemplars).
/// `title_underline: true` instead prints the title underlined with no rules, to match the other papers in a case.
#let order-title(meta) = if meta.at("title_underline", default: false) == true { title-block(meta) } else {
  block(width: 100%, above: sign-gap, below: sign-gap, {
    line(length: 100%, stroke: 0.8pt)
    block(width: 100%, above: 6pt, below: 6pt, single(align(center, strong(upper(inl(need(meta, "title")))))))
    line(length: 100%, stroke: 0.5pt)
  })
}

#let order-heading(level, t) = block(width: 100%, sticky: true, above: heading-gap, below: heading-gap, single({
  set text(weight: "bold")
  if level == 1 { align(center, upper(inl(t))) } else { inl(t) }
}))

/// A decretal list: each item is a paragraph with its number, double spaced, hanging.
#let order-list(t) = {
  let items = ()
  for line in t.split(regex("\\r?\\n")) {
    let m = line.match(regex("^([-*+]|\\d+\\.)[ \\t]+(.*)$"))
    if m != none { items.push((m.captures.at(0), m.captures.at(1))) }
    else if items.len() > 0 { let (l, s) = items.pop(); items.push((l, s + " " + line.trim())) }
  }
  for (lab, s) in items {
    block(width: 100%, par(hanging-indent: para-indent + 0.5in, {
      h(para-indent)
      box(width: 0.5in, if lab.starts-with(regex("\\d")) { lab } else { [–] })
      inl(s)
    }))
  }
}

/// Alternative choices the judge checks (for example with or without prejudice): one check box per choice.
#let choices-block(meta) = {
  let cs = as-list(meta.at("choices", default: none))
  if cs.len() > 0 {
    block(width: 100%, above: pitch-single, below: pitch-single, breakable: false, single({
      if "choices_intro" in meta { block(below: pitch-single, body-par(none, inl(meta.choices_intro))) }
      for c in cs {
        block(width: 100%, below: pitch-single, pad(left: 0.5in, par(hanging-indent: 0.4in, { box-mark; h(0.15in); inl(c) })))
      }
    }))
  }
}

#let blocks-of(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let out = ()
  for t in chunks {
    let h = t.match(regex("^(#+)[ \\t]+(.*)$"))
    if h != none { out.push(order-heading(h.captures.at(0).len(), h.captures.at(1).trim())) }
    else if t.starts-with(regex("^([-*+]|\\d+\\.)[ \\t]")) { out.push(order-list(t)) }
    else { out.push(body-blocks(t, numbered: false).at(0)) }
  }
  out
}

#let date-line(meta) = {
  let word = meta.at("date_line", default: "signed")
  if word not in ("signed", "so-ordered") { panic("txdistrict-travis: date_line must be `signed` or `so-ordered`") }
  // Local Rule 11.5: "SIGNED" or "SO ORDERED", never "entered".
  let lead = if word == "signed" { [SIGNED] } else { [SO ORDERED] }
  let month = meta.at("month", default: none)
  let year = meta.at("year", default: none)
  block(width: 100%, [#lead on this #blank(0.6in) day of #if month != none { inl(month) } else { blank(1.5in) }, #if year != none { inl(year) } else { [20#blank(0.4in)] }.])
}

#let judge-block(meta) = {
  v(3 * pitch-single)
  pad(left: sig-col, single({
    block(line(length: 100%, stroke: 0.5pt))
    block(upper(inl(meta.at("judge_title", default: "Judge Presiding"))))
    if meta.at("judge_court", default: true) {
      block(upper(inl(need(meta, "judicial_district"))) + [ DISTRICT COURT])
      block(upper(court-name))
    }
  }))
}

/// "Approved as to form" blocks (TRCP 57 data for each approving attorney); not required for an order.
#let approval-blocks(meta) = {
  let ap = as-list(meta.at("approved", default: none))
  if ap.len() > 0 {
    block(width: 100%, above: 2 * sign-gap, sticky: true, single(strong(upper(inl(meta.at("approved_heading", default: "Approved as to form:"))))))
    block(width: 100%, above: sign-gap, breakable: false, grid(columns: (1fr, 1fr), column-gutter: 0.3in, row-gutter: sign-gap, ..ap.map(a => single({
        if "firm" in a { block(strong(upper(inl(a.firm)))) }
        block(above: pitch-single, [By: /s/ #inl(need(a, "name"))])
        block([State Bar of Texas No. #inl(need(a, "bar_no"))])
        for l in as-list(a.at("lines", default: ())) { block(inl(l)) }
        if "phone" in a { block([Telephone: #inl(a.phone)]) }
        block([Email: #inl(need(a, "email"))])
        if "for" in a { block(above: pitch-single, emph(inl(a.for))) }
      }))))
  }
}

#let txdistrict-travis-proposed-order(meta, body) = {
  for k in ("cause_number", "judicial_district", "caption", "title") { let _ = need(meta, k) }
  show: page-setup.with(meta)
  caption(meta)
  order-title(meta)
  let pieces = blocks-of(body)
  let ending(last) = keep-tail(last, {
    choices-block(meta)
    block(width: 100%, above: sign-gap, single(date-line(meta)))
    judge-block(meta)
  }, gap: if as-list(meta.at("choices", default: none)).len() > 0 { pitch-single } else { sign-gap })
  // Local Rule 11.4: the judge's signature line shares a page with the last paragraph.
  for p in pieces.slice(0, calc.max(0, pieces.len() - 1)) { p }
  ending(if pieces.len() > 0 { pieces.last() } else { none })
  approval-blocks(meta)
}
