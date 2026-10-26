// Travis County district courts (txdistrict-travis): a Rule 11 agreement filed with the clerk, in the form the Travis
// exemplar uses (usage/SOURCE.md): a signed letter agreement between counsel. Tex. R. Civ. P. 11: no agreement between
// attorneys or parties touching any suit pending is enforced unless it is in writing, signed and filed with the papers as
// part of the record (or made in open court and entered of record).
//
// Rule-driven and content-agnostic; shared parts in /lib/typst/txdistrict-travis-common.typ, rules in ../../rules.md.
// The letterhead, date, addressees, subject line, terms and signature blocks are the filer's: the template typesets them.
// The terms are a markdown body: paragraphs and numbered items (the author types the number and any bold lead-in).
// The signature of each side is a block of the paper (TRCP 11 "signed"); the template prints the sender's
// block and an "AGREED:" block for each other signer, each with a date line.
#import "/lib/typst/txdistrict-travis-common.typ": *

#let gap = 12pt   // style: space between the paragraphs of a letter (single-spaced text)

#let letter-par(c) = block(width: 100%, above: gap, par(first-line-indent: para-indent, c))

/// One item of a numbered list, at nesting `level` (0: "1.", 1: "a.", 2: "i."); each level is indented another half inch and
/// hangs its label (the exemplar's terms are numbered in bold, with lettered and Roman sub-items).
#let letter-item(level, label, c) = block(width: 100%, above: if level == 0 { gap } else { 6pt }, par(hanging-indent: 0.5in * (level + 2), {
  h(0.5in * (level + 1))
  box(width: 0.5in, if level == 0 { strong[#label.] } else { [#label.] })
  c
}))

/// The body: paragraphs and lists. A list chunk (no blank line inside) has one item per line that starts with a label
/// ("1.", "a.", "i."), nested by two spaces of indent per level; other lines continue the previous item. Footnote
/// definitions travel with the chunk that refers to them.
#let letter-body(body) = {
  let out = ()
  let notes = (:)
  for m in body.matches(regex("(?m)^\\[\\^([^\\]]+)\\]:[ \\t]*(.*)$")) { notes.insert(m.captures.at(0), m.captures.at(1)) }
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
    .filter(c => not c.trim().starts-with(regex("^\\[\\^[^\\]]+\\]:")))
  for chunk in chunks {
    let t = chunk.trim(at: end)
    let with-defs(x) = {
      let defs = ""
      for r in x.matches(regex("\\[\\^([^\\]]+)\\]")) { defs += "\n\n[^" + r.captures.at(0) + "]: " + notes.at(r.captures.at(0), default: "") }
      x + defs
    }
    let label = regex("^( *)(\\d+|[a-z]|[ivx]+)\\.[ \\t]+(.*)$")
    if t.split(regex("\\r?\\n")).first().match(label) == none { out.push(letter-par(render(with-defs(t.trim())))) }
    else {
      let items = ()
      for line in t.split(regex("\\r?\\n")) {
        let m = line.match(label)
        if m != none { items.push((m.captures.at(0).len() / 2, m.captures.at(1), m.captures.at(2))) }
        else if items.len() > 0 { let (lv, lb, tx) = items.pop(); items.push((lv, lb, tx + " " + line.trim())) }
      }
      for (lv, lb, tx) in items { out.push(letter-item(int(lv), lb, render(with-defs(tx)))) }
    }
  }
  out
}

#let letterhead(meta) = {
  let l = need(meta, "letterhead")
  align(center, block(below: gap, {
    block(strong(upper(inl(need(l, "firm")))))
    for x in as-list(l.at("lines", default: ())) { block(inl(x)) }
    block(above: 4pt, line(length: 100%, stroke: 0.5pt))
  }))
}

#let addressee(a) = block(width: 100%, above: pitch-single, breakable: false, {
  block(inl(need(a, "name")))
  for x in as-list(a.at("lines", default: ())) { block(inl(x)) }
})

#let sign-line(w) = box(width: w, line(length: 100%, stroke: 0.5pt))

/// A signature block: the signature line (or the e-signature), the name, State Bar number, role, and the date.
#let sign-block(s, esign: false) = block(width: 100%, above: 2 * pitch-single, breakable: false, {
  if esign { block([/s/ #inl(need(s, "name"))]) } else { block(sign-line(3in)) }
  block(inl(need(s, "name")))
  if "bar_no" in s { block([State Bar of Texas No. #inl(s.bar_no)]) }
  if "firm" in s { block(inl(s.firm)) }
  if "role" in s { block(inl(s.role)) }
  block(above: pitch-single, [Date: #sign-line(1.6in)])
})

#let txdistrict-travis-rule-11-agreement(meta, body) = {
  for k in ("letterhead", "date", "addressees", "re", "salutation", "signer", "agreed") { let _ = need(meta, k) }
  show: page-setup.with(meta)
  set text(..edges(pitch-single))
  set par(justify: true)
  letterhead(meta)
  block(above: gap, inl(need(meta, "date")))
  if "via" in meta { block(above: gap, strong(inl(meta.via))) }
  for a in as-list(meta.addressees) { addressee(a) }
  block(width: 100%, above: gap, par(hanging-indent: 0.5in, { box(width: 0.5in, strong[RE:]); inl(need(meta, "re")) }))
  block(above: gap, inl(need(meta, "salutation")))
  let pieces = letter-body(body)
  for p in pieces.slice(0, calc.max(0, pieces.len() - 1)) { p }
  let s = need(meta, "signer")
  // The closing, the firm and the sender's signature stay on one page; each "AGREED:" block stays whole.
  // The last paragraph travels with the closing and the sender's signature (the exemplar's signature page carries text).
  keep-tail(if pieces.len() > 0 { pieces.last() } else { none }, {
    block(inl(s.at("closing", default: "Very truly yours,")))
    block(width: 100%, above: pitch-single, strong(upper(inl(need(s, "firm")))))
    sign-block(s, esign: true)
  }, above: gap, gap: gap)
  for a in as-list(meta.agreed) {
    block(width: 100%, above: 2 * pitch-single, breakable: false, {
      strong(inl(meta.at("agreed_heading", default: "AGREED:")))
      sign-block(a)
    })
  }
}
