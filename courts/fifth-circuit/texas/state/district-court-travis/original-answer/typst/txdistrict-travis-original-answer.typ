// Travis County district courts (txdistrict-travis): original answer, with an optional counterclaim.
//
// Rule-driven and content-agnostic; the shared parts are in /lib/typst/txdistrict-travis-common.typ and the rules in ../../rules.md.
// TRCP 45: a pleading is a petition and an answer; TRCP 57: signed by an attorney of record with the State Bar number,
// address, telephone number and email; TRCP 21(d), 21a(e): certificate of service on the filed paper; TRCP 93: a
// verified plea carries a verification. Body headings and text are the filer's: the template counts the parts
// (I., II., ...) and the paragraphs, and prints everything else the rules require.
#import "/lib/typst/txdistrict-travis-common.typ": *

#let txdistrict-travis-original-answer(meta, body) = {
  for k in ("cause_number", "judicial_district", "caption", "title", "signature", "service") { let _ = need(meta, k) }
  show: page-setup.with(meta)
  head(meta)
  with-signature(body-blocks(body, numbered: meta.at("numbered_paragraphs", default: true)), signature-block(meta))
  service-certificate(meta)
  if "verification" in meta { v(0pt); pagebreak(weak: true); verification(meta) }
}
