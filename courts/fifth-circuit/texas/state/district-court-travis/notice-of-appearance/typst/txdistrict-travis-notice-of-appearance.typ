// Travis County district courts (txdistrict-travis): notice of appearance, with or without the designation of an
// attorney in charge.
//
// Rule-driven and content-agnostic; shared parts in /lib/typst/txdistrict-travis-common.typ, rules in ../../rules.md
// and README.md. TRCP 8: the attorney whose signature first appears on a party's initial pleadings is the attorney in
// charge unless another is specifically designated, and the designation is changed by written notice served under
// Rule 21a; TRCP 57, 21(f)(2): signature block with State Bar number, address, telephone, email; TRCP 21(d), 21a(e):
// certificate of service. A notice asks the court for no ruling, so: no salutation, no certificate of conference
// (Local Rule 2.2 reaches motions), paragraphs unnumbered. The caption and the footer are the shared ones; the title
// between two rules, the generated text, the signature block (with the attorney-in-charge label, optional officials'
// column) and the certificate of service (recipients optional) are this doc type's own and are candidates for lib.
#import "/lib/typst/txdistrict-travis-common.typ": *

#let rule-stroke = 1pt                 // style: the rules above and below the title (both exemplars)

// `title_underline: true` instead prints the title underlined with no rules, to match the other papers in a case.
#let title-rules(meta, default-title) = {
  let t = meta.at("title", default: default-title)
  if meta.at("title_underline", default: false) == true {
    return align(center, block(above: sign-gap, below: sign-gap, width: 100%,
      single(strong(underline(offset: title-underline-offset, upper(inl(t)))))))
  }
  block(width: 100%, above: sign-gap, below: sign-gap, stroke: (top: rule-stroke, bottom: rule-stroke),
    inset: (y: 0.4 * pitch-single), single(align(center, strong(upper(inl(t))))))
}

/// "A", "A and B", "A, B and C".
#let join-names(ns) = if ns.len() <= 1 { ns.join() } else { ns.slice(0, -1).join(", ") + " and " + ns.last() }

/// The attorneys of the signature block, signer first: (name, label) where label is "Attorney-in-Charge" or none.
#let attorneys(meta) = {
  let sig = need(meta, "signature")
  let c = meta.at("attorney_in_charge", default: none)
  let all = (need(sig, "signer"),) + as-list(sig.at("others", default: ())).map(o => need(o, "name"))
  let who = if c == none or c == false { none } else if c == true { all.first() } else { c }
  if who != none and who not in all { panic("txdistrict-travis: attorney_in_charge `" + who + "` is not the signer or one of signature.others") }
  all.map(n => (n, if n == who { "Attorney-in-Charge" } else { none }))
}

/// The opening text generated from the frontmatter (the filer adds to it, or replaces it with `generate: false`).
#let opening(meta) = {
  let ats = attorneys(meta)
  let names = ats.map(a => a.at(0))
  let party = need(meta, "appearing_for")
  let out = ()
  out.push([Notice is given that #inl(join-names(names)) #if names.len() == 1 [appears] else [appear] in the above-captioned case as counsel for #inl(party)#if not party.trim().ends-with(".") [.]])
  let chief = ats.filter(a => a.at(1) != none)
  if chief.len() == 1 {
    out.push([#inl(chief.first().at(0)) is designated as attorney in charge for #inl(party) under Texas Rule of Civil Procedure 8. All communications from the court or other counsel with respect to this case should be sent to the attorney in charge.])
  }
  if meta.at("serve_undersigned", default: false) {
    out.push([All future notices and pleadings in this case should be served on the undersigned at the address in the signature block.])
  }
  for r in as-list(meta.at("reservation", default: ())) { out.push(inl(r)) }
  out.map(c => body-par(none, c))
}

/// Signature block (TRCP 57): date, closing, firm, "/s/" signature, name, title, label, State Bar number, address,
/// telephone, fax, email; further attorneys the same way. With `signature.officials` (name and title lines), they stand
/// in a left column beside it. Kept whole on a page.
#let notice-signature(meta) = {
  let sig = need(meta, "signature")
  let ats = attorneys(meta)
  let label-of(n) = ats.find(a => a.at(0) == n).at(1)
  let who(n, s, first: false) = {
    if first { block([/s/ #emph(inl(n))]) } else { block(inl(n)) }
    if "title" in s { block(inl(s.title)) }
    if label-of(n) != none { block(label-of(n)) }
    block([State Bar of Texas No. #inl(need(s, "bar_no"))])
  }
  let right = {
    block(below: pitch-single, [Respectfully submitted,])
    who(need(sig, "signer"), sig, first: true)
    if "firm" in sig { block(above: pitch-single, strong(upper(inl(sig.firm)))) }
    for l in as-list(sig.at("lines", default: ())) { block(inl(l)) }
    block([Telephone: #inl(need(sig, "phone"))])
    if "fax" in sig { block([Fax: #inl(sig.fax)]) }
    block([Email: #inl(need(sig, "email"))])
    for o in as-list(sig.at("others", default: ())) {
      block(above: pitch-single, who(need(o, "name"), o))
      if "email" in o { block([Email: #inl(o.email)]) }
      if "phone" in o { block([Telephone: #inl(o.phone)]) }
    }
    if "role" in sig { block(above: pitch-single, strong(upper(inl(sig.role)))) }
  }
  let left = {
    if "date" in sig { block(below: pitch-single, [Date: #inl(sig.date)]) }
    for o in as-list(sig.at("officials", default: ())) {
      block(below: 0.5 * pitch-single, { block(upper(inl(need(o, "name")))); block(inl(need(o, "title"))) })
    }
  }
  let officials = "officials" in sig
  block(width: 100%, above: sign-gap, breakable: false, single({
    grid(columns: if officials { (1fr, 1fr) } else { (sig-col, 1fr) }, column-gutter: if officials { 0.25in } else { 0pt }, left, right)
  }))
}

/// The recipients of the certificate. A recipient with `side` (lines) puts them in a right-hand column beside its own
/// lines (a firm and address beside the lawyers, exemplar 1); otherwise, with `columns: 2` (the default for two or
/// more recipients), recipients fill two columns left to right.
#let recipient-list(recipients, columns, tail: none) = {
  let cell(r) = block(width: 100%, breakable: false, {
    block(inl(need(r, "name")))
    for l in as-list(r.at("lines", default: ())) { block(inl(l)) }
  })
  let side(r) = block(width: 100%, breakable: false, for l in as-list(r.at("side", default: ())) { block(inl(l)) })
  if recipients.any(r => "side" in r) {
    let row(r, gap: pitch-single) = block(width: 100%, above: gap, breakable: false, single(grid(columns: (1fr, 1fr), column-gutter: 0.25in, cell(r), side(r))))
    for r in recipients.slice(0, -1) { row(r) }
    block(width: 100%, above: pitch-single, breakable: false, { row(recipients.last(), gap: 0pt); tail })
  } else if columns == 2 {
    block(width: 100%, above: pitch-single, breakable: false, {
      block(width: 100%, single(grid(columns: (1fr, 1fr), column-gutter: 0.25in, row-gutter: pitch-single, ..recipients.map(cell))))
      tail
    })
  } else if recipients.len() > 0 {
    let row(r, gap: pitch-single) = block(width: 100%, above: gap, breakable: false, single(pad(left: 0.5in, cell(r))))
    for r in recipients.slice(0, -1) { row(r) }
    block(width: 100%, above: pitch-single, breakable: false, { row(recipients.last(), gap: 0pt); tail })
  } else { tail }
}

/// Certificate of service (TRCP 21(d), 21a(e)): date and manner over the signature; recipients optional. Without any,
/// the text says the notice was served on all parties and counsel of record. `service.own_page: true` starts it on a page.
#let notice-service(meta) = {
  let s = need(meta, "service")
  let method = s.at("method", default: "electronic service through the electronic filing manager")
  let recipients = as-list(s.at("recipients", default: ()))
  if s.at("own_page", default: false) { v(0pt); pagebreak(weak: true) }
  block(width: 100%, above: sign-gap, {
    cert-heading[Certificate of Service]
    let para = block(width: 100%, body-par(none, [I certify that on #inl(need(s, "date")), a true and correct copy of the foregoing document was served in accordance with Texas Rule of Civil Procedure 21a, by #inl(method), #if recipients.len() == 0 [on all parties and counsel of record.] else [on the following counsel of record or parties:]]))
    if recipients.len() == 0 { block(width: 100%, breakable: false, { para; cert-sign(meta) }) } else { para }
    if recipients.len() > 0 { recipient-list(recipients, s.at("columns", default: if recipients.len() >= 2 { 2 } else { 1 }), tail: cert-sign(meta)) }
  })
}

#let txdistrict-travis-notice-of-appearance(meta, body) = {
  for k in ("cause_number", "judicial_district", "caption", "signature", "service") { let _ = need(meta, k) }
  let generate = meta.at("generate", default: true)
  if generate { let _ = need(meta, "appearing_for") }
  show: page-setup.with(meta)
  caption(meta)
  title-rules(meta, if meta.at("attorney_in_charge", default: none) in (none, false) { "Notice of Appearance" } else { "Notice of Appearance and Designation of Attorney in Charge" })
  let own = body-blocks(body, numbered: meta.at("numbered_paragraphs", default: false))
  let pieces = (if generate { opening(meta) } else { () }) + own
  for p in pieces { p }
  notice-signature(meta)
  notice-service(meta)
}
