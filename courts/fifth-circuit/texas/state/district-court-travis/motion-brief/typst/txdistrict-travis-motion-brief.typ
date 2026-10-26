// Travis County district courts (txdistrict-travis): motion with its brief incorporated, certificate of conference,
// certificate of service; with `document: proposed-order`, the proposed order as its own paper; or, with
// `document: notice`, a notice that asks the court for no ruling (notice of appearance or designation of attorney in
// charge, TRCP 8; notice of hearing or submission, TRCP 21(b)): signature and service certificate, no certificate of
// conference, because Local Rule 2.2 reaches motions only.
//
// Rule-driven and content-agnostic; shared parts in /lib/typst/txdistrict-travis-common.typ, rules in ../../rules.md.
// TRCP 21(a): a motion states its grounds and sets out the relief sought; TRCP 91a.2: a Rule 91a motion says it is made
// under the rule, identifies each cause of action and states the reasons; Travis Local Rule 2.2: certification of
// conference and of the setting; TRCP 21(d), 21a(e): certificate of service; Local Rules 11.4, 11.5: the order.
// A joint motion: `signatures` (a list) instead of `signature`; a `---` line between paragraphs starts a part with a numeral and no heading text.
// A proposed order is its own PDF (rendered from its own sample) and is filed only as an attachment to the motion (Local Rule 11.1).
#import "/lib/typst/txdistrict-travis-common.typ": *

/// A motion signed by more than one firm (a joint motion): `signatures` is a list of signature blocks, each as `signature`.
/// The first (with "Respectfully submitted,") stays with the last paragraph of the body; the others follow it, each whole.
/// The certificates use the first signer.
#let sig-of(meta, k, s) = signature-block(meta + (signature: s), closing: if k == 0 { "Respectfully submitted," } else { none })

#let signed-body(meta, pieces) = if "signatures" in meta {
  let sigs = as-list(meta.signatures)
  with-signature(pieces, sig-of(meta, 0, sigs.first()))
  for (k, s) in sigs.enumerate().slice(1) { sig-of(meta, k, s) }
} else { with-signature(pieces, signature-block(meta)) }

#let txdistrict-travis-motion-brief(meta, body) = {
  let meta = if "signatures" in meta and "signature" not in meta { meta + (signature: as-list(meta.signatures).first()) } else { meta }
  for k in ("cause_number", "judicial_district", "caption", "title") { let _ = need(meta, k) }
  show: page-setup.with(meta)
  let doc = meta.at("document", default: "motion")
  if doc == "proposed-order" {
    order-paper(meta, body)
  } else if doc == "motion" {
    for k in ("signature", "service", "conference") { let _ = need(meta, k) }
    head(meta)
    signed-body(meta, body-blocks(body, numbered: meta.at("numbered_paragraphs", default: true)))
    conference-certificate(meta)
    service-certificate(meta)
  } else if doc == "notice" {
    for k in ("signature", "service") { let _ = need(meta, k) }
    head(meta)
    with-signature(body-blocks(body, numbered: meta.at("numbered_paragraphs", default: false)), signature-block(meta))
    service-certificate(meta)
  } else {
    panic("txdistrict-travis: document must be `motion`, `notice` or `proposed-order`")
  }
}
