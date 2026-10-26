// Travis County district courts (txdistrict-travis): notice of hearing (or of submission) on a motion, with its signature
// block and certificate of service.
//
// Rule-driven and content-agnostic; shared parts in /lib/typst/txdistrict-travis-common.typ (read-only), rules in
// ../../rules.md. TRCP 21(b): notice of a court proceeding is served not less than three days before it (an author
// responsibility, the template computes no dates) and carries what participants need (location or joining instructions);
// TRCP 21(d), 21a(e): certificate of service over signature; TRCP 57, 21(f)(2): signature block. Travis Local Rules 2.2,
// 2.3 reach motions, not a notice; LR 2.4: the notice states date, time and total time needed; LR 1.4: it never names the
// case-style court as the hearing court (rules.md NOH-001..006). A notice asks the court for no ruling: no salutation.
//
// Three things differ from the shared helpers and are defined here (candidates for lib, README "Known gaps"): the caption
// (author's capitalization, plain weight, and a stacked fallback when the party list is too long for the section-sign
// grid), the signature block ("Date:" beside "Respectfully submitted,"), and the certificate of service (recipients optional).
#import "/lib/typst/txdistrict-travis-common.typ": *

#let caption-max = 5.6in        // style: a party column taller than this (after widening to `caption-wide`) stacks the court block below the parties
#let caption-wide = 57%         // style: the parties' column of a long caption, wider than the shared `caption-left`
#let hearing-word = "hearing"   // the noun of the generated opening; the author's `hearing.kind` replaces it

// Caption: parties (as typed) in the left column, a column of section signs, the court in the right column.
#let nh-caption(meta) = {
  let sides = need(meta, "caption")
  // `caption_style`: `lib` (default: party names and court column in bold capitals, as the shared lib caption) or `plain`
  // (names as typed, court column in plain weight, as the filed notices in this folder).
  let cs = meta.at("caption_style", default: "lib")
  if cs not in ("lib", "plain") { panic("txdistrict-travis: caption_style must be `lib` or `plain`") }
  let lib-style = cs == "lib"
  let party(k, s) = {
    block(above: if k > 0 { pitch-single } else { 0pt }, single({
      let nm = inl(need(s, "names").replace("/", "/\u{2060}"))
      if lib-style { strong(upper(nm)) } else { nm }
      if "designation" in s { linebreak(); h(1em); emph(inl(s.designation)) }
    }))
  }
  let left = {
    for (k, s) in sides.enumerate() {
      if k > 0 { block(above: pitch-single, single(align(left, [v.]))) }
      party(k, s)
    }
  }
  let court = (
    [IN THE DISTRICT COURT OF],
    [#upper(inl(need(meta, "judicial_district"))) JUDICIAL DISTRICT],
    [#upper(court-name)],
  ).map(c => if lib-style { strong(c) } else { c })
  // `court_column_order`: `district-middle` (default, the shared lib caption: court, district, county) or `county-middle`
  // (court, county, district). Papers in one case must match, so the author picks the one the case already uses.
  let order = meta.at("court_column_order", default: "district-middle")
  if order not in ("district-middle", "county-middle") { panic("txdistrict-travis: court_column_order must be `district-middle` or `county-middle`") }
  let (mid, last) = if order == "district-middle" { (court.at(1), court.at(2)) } else { (court.at(2), court.at(1)) }
  align(center, block(below: pitch-single, single(strong[CAUSE NO. #need(meta, "cause_number")])))
  layout(size => {
    let h0 = measure(width: size.width * caption-left, left).height
    let wide = h0 > caption-max
    let cw = if wide { caption-wide } else { caption-left }
    let h = if wide { measure(width: size.width * cw, left).height } else { h0 }
    if h <= caption-max {
      let n = calc.max(3, int(calc.round(h / pitch-single)))
      grid(
        columns: (cw, caption-mid, 1fr),
        column-gutter: 0pt,
        block(height: h, left),
        single(align(center, block(height: h, for _ in range(n) { [§] + linebreak() }))),
        block(height: h, inset: (left: 0.15in), single(grid(
          rows: (1fr, 1fr, 1fr), columns: 100%,
          align(top, court.at(0)), align(horizon, mid), align(bottom, last),
        ))),
      )
    } else {
      // Too many parties for the grid: parties at full width, then the court, so the caption can break across pages.
      single({
        for (k, s) in sides.enumerate() {
          if k > 0 { block(above: pitch-single, [v.]) }
          party(k, s)
        }
        block(above: pitch-single, width: 100%, align(center, (court.at(0), mid, last).join(linebreak())))
      })
    }
  })
}

#let nh-title(meta) = align(center, block(above: sign-gap, below: sign-gap, width: 100%,
  single(strong(underline(offset: title-underline-offset, upper(inl(need(meta, "title"))))))))

// Signature block (TRCP 57): "Date:" at the left beside the block, which starts "Respectfully submitted,". Returned as
// (head, rest): the head (date, firm, signing lawyer) is kept whole and glued to the last paragraph by the caller; each
// further lawyer and the role are their own unbreakable blocks, so a long block can break between lawyers.
#let nh-signature(meta) = {
  let sig = need(meta, "signature")
  let others = as-list(sig.at("others", default: ()))
  let head = block(width: 100%, above: sign-gap, breakable: false, single(grid(
    columns: (sig-col, 1fr),
    if "date" in sig { [Date: #inl(sig.date)] } else { [] },
    {
      block(below: pitch-single, [Respectfully submitted,])
      if "firm" in sig { block(strong(upper(inl(sig.firm)))) }
      block(above: pitch-single, [/s/ #inl(need(sig, "signer"))])
      block(inl(need(sig, "signer")))
      block([State Bar of Texas No. #inl(need(sig, "bar_no"))])
      for l in as-list(sig.at("lines", default: ())) { block(inl(l)) }
      block([Telephone: #inl(need(sig, "phone"))])
      if "fax" in sig { block([Fax: #inl(sig.fax)]) }
      block([Email: #inl(need(sig, "email"))])
      if others.len() == 0 and "role" in sig { block(above: pitch-single, strong(upper(inl(sig.role)))) }
    },
  )))
  let rest = ()
  for (k, o) in others.enumerate() {
    rest.push(block(width: 100%, above: pitch-single, breakable: false, single(pad(left: sig-col, {
      block(inl(need(o, "name")))
      block([State Bar of Texas No. #inl(need(o, "bar_no"))])
      block([Email: #inl(need(o, "email"))])
      if k == others.len() - 1 and "role" in sig { block(above: pitch-single, strong(upper(inl(sig.role)))) }
    }))))
  }
  (head, rest)
}


// TRCP 21(d), 21a(e): certificate over signature, stating date and manner; recipients optional ("all counsel of record").
#let nh-service(meta) = {
  let s = need(meta, "service")
  let method = s.at("method", default: "electronic service through the electronic filing manager")
  let rs = as-list(s.at("recipients", default: ()))
  let listed = rs.any(r => as-list(r.at("lines", default: ())).len() > 0)
  let who = if rs.len() == 0 { [all counsel of record] }
    else if listed { [the following counsel of record or parties:] }
    else { rs.map(r => inl(need(r, "name"))).join("; ") }
  // `cert-flow` (shared): a long recipient list may run onto another page.
  cert-flow({
    cert-heading[Certificate of Service]
    block(width: 100%, body-par(none, [I certify that on #inl(need(s, "date")), a true and correct copy of the foregoing document was served in accordance with Texas Rule of Civil Procedure 21a, by #inl(method), on #who#if not listed [.]]))
  }, if listed { rs.map(recipient-block) } else { () }, cert-sign(meta))
}

// The generated opening, from `hearing:` (TRCP 21(b): when, where, how to join), as body-blocks-style paragraphs.
#let nh-opening(meta) = {
  if "hearing" not in meta { return () }
  let hg = meta.hearing
  for k in ("motion", "date", "time", "length") { let _ = need(hg, k) }
  let kind = hg.at("kind", default: hearing-word)
  // Local Rule 1.4: a notice must not direct the parties to the court in the case style (the number randomly assigned at
  // filing), so the default names the Travis County Civil District Courts; `hearing.court` names a specially assigned court.
  let where = if "court" in hg [#inl(hg.court)]
    else if hg.at("central_docket", default: false) [on the Central Docket in the Travis County Civil District Courts]
    else [in the Travis County Civil District Courts]
  let length = [ and is estimated to take #inl(hg.length)]
  // TRCP 21(b) and Local Rule 1.4: the notice must say where to appear or how to join; a generated opening therefore
  // requires `format`, a `location` for an in-person hearing, and `joining` instructions for a remote one.
  let fmt = need(hg, "format")
  let out = (body-par(none, [PLEASE TAKE NOTICE that #inl(hg.motion) has been set for #kind on #strong[#inl(hg.date), at #inl(hg.time)] #where#length.]),)
  if fmt == "in-person" {
    out.push(body-par(none, [This #kind will take place #strong[in person] at #inl(need(hg, "location")).#if "joining" in hg [ #inl(hg.joining)]]))
  } else if fmt == "remote" {
    out.push(body-par(none, [This #kind will take place #strong[#inl(need(hg, "remote"))]. #inl(need(hg, "joining"))]))
  } else { panic("txdistrict-travis: hearing.format must be `in-person` or `remote`") }
  out
}

#let txdistrict-travis-notice-of-hearing(meta, body) = {
  for k in ("cause_number", "judicial_district", "caption", "title", "signature", "service") { let _ = need(meta, k) }
  if "hearing" not in meta and body.trim() == "" { panic("txdistrict-travis: a notice of hearing needs `hearing:` or a body") }
  show: page-setup.with(meta)
  nh-caption(meta)
  nh-title(meta)
  let pieces = nh-opening(meta) + body-blocks(body, numbered: meta.at("numbered_paragraphs", default: false))
  for p in pieces.slice(0, calc.max(0, pieces.len() - 1)) { p }
  let (sig-head, sig-rest) = nh-signature(meta)
  keep-tail(if pieces.len() > 0 { pieces.last() } else { none }, sig-head, gap: sign-gap)
  for r in sig-rest { r }
  nh-service(meta)
}
