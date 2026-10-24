// Travis County district courts (txdistrict-travis): motion with its brief incorporated, certificate of conference,
// certificate of service; or, with `document: proposed-order`, the proposed order as its own paper.
//
// Rule-driven and content-agnostic; shared parts in ../../typst/travis-common.typ, rules in ../../rules.md.
// TRCP 21(a): a motion states its grounds and sets out the relief sought; TRCP 91a.2: a Rule 91a motion says it is made
// under the rule, identifies each cause of action and states the reasons; Travis Local Rule 2.2: certification of
// conference and of the setting; TRCP 21(d), 21a(e): certificate of service; Local Rules 11.4, 11.5: the order.
// The Technology Standards treat a proposed order as its own PDF, so it is rendered from its own sample.
#import "/courts/fifth-circuit/texas/state/district-court-travis/typst/travis-common.typ": *

#let txdistrict-travis-motion-brief(meta, body) = {
  for k in ("cause_number", "judicial_district", "caption", "title") { let _ = need(meta, k) }
  show: page-setup.with(meta)
  let doc = meta.at("document", default: "motion")
  if doc == "proposed-order" {
    order-paper(meta, body)
  } else if doc == "motion" {
    for k in ("signature", "service", "conference") { let _ = need(meta, k) }
    head(meta)
    with-signature(body-blocks(body, numbered: meta.at("numbered_paragraphs", default: true)), signature-block(meta))
    conference-certificate(meta)
    service-certificate(meta)
  } else {
    panic("txdistrict-travis: document must be `motion` or `proposed-order`")
  }
}
