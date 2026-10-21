/// Ninth Circuit Form 8 certificate. Court-specific layout callbacks remain supplied by the brief overlay.
#let ca9-compliance(meta, words, heading-fn, leading, need-fn, group-digits-fn,
  options, option-row-fn, signature-fn) = {
  let basis = meta.at("word_limit_basis", default: "standard")
  let longer = ("longer-joint", "longer-multiple", "longer-response-to-joint")
  heading-fn(level: 1, numbering: none)[Certificate of Compliance]
  set par(first-line-indent: 0pt, leading: leading, spacing: 1em, justify: false)
  [9th Cir. Case Number(s) #need-fn(meta, "case_number")]
  parbreak()
  [I am the attorney or self-represented party.]
  parbreak()
  [This brief contains #group-digits-fn(words) words, including #meta.at("manual_image_words", default: 0) words manually counted in any visual images, and excluding the items exempted by FRAP 32(f). The brief’s type size and typeface comply with FRAP 32(a)(5) and (6).]
  parbreak()
  [I certify that this brief (select only one):]
  for (key, body) in options { option-row-fn(basis == key, body) }
  option-row-fn(basis in longer, [complies with the longer length limit permitted by Cir. R. 32-2(b) because (select only one):])
  option-row-fn(basis == "longer-joint", [it is a joint brief submitted by separately represented parties.], indent: 1.6em)
  option-row-fn(basis == "longer-multiple", [a party or parties are filing a single brief in response to multiple briefs.], indent: 1.6em)
  option-row-fn(basis == "longer-response-to-joint", [a party or parties are filing a single brief in response to a longer joint brief.], indent: 1.6em)
  option-row-fn(basis == "court-order", [complies with the length limit designated by court order dated #meta.at("court_order_date", default: "__________").])
  option-row-fn(basis == "motion-to-exceed", [is accompanied by a motion to file a longer brief pursuant to Cir. R. 32-2(a).])
  signature-fn(meta)
}

/// Ninth Circuit Form 15 certificate, including optional service on unregistered participants.
#let ca9-service(meta, heading-fn, leading, need-fn, inline-fn, signature-fn) = {
  let svc = meta.service
  heading-fn(level: 1, numbering: none)[Certificate of Service]
  set par(first-line-indent: 0pt, leading: leading, spacing: 1em, justify: false)
  [9th Cir. Case Number(s) #need-fn(meta, "case_number")]
  parbreak()
  [I hereby certify that I electronically filed the foregoing/attached document(s) on this date with the Clerk of the Court for the United States Court of Appeals for the Ninth Circuit using the Appellate Electronic Filing system.]
  let unreg = svc.at("unregistered", default: ())
  if unreg.len() > 0 {
    parbreak()
    strong[Service on Case Participants Who Are NOT Registered for Electronic Filing:]
    parbreak()
    [I certify that I served the foregoing/attached document(s) on this date by hand delivery, mail, third party commercial carrier for delivery within 3 calendar days, or, having obtained prior consent, by email to the following unregistered case participants (list each name and mailing/email address):]
    for u in unreg { block(above: 0.7em, breakable: false, pad(left: 0.5in, [#u.name, #u.address])) }
  }
  parbreak()
  strong[Description of Document(s) (required for all documents):]
  parbreak()
  inline-fn(need-fn(meta, "brief_title"))
  signature-fn(meta)
}
