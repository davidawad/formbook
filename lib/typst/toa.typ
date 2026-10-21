/// Validate every recorded authority link against the frontmatter authority map.
#let linked-authorities(authorities, error-prefix: "template") = {
  let hits = query(<toa-hit>)
  for hit in hits {
    if hit.value not in authorities {
      panic(error-prefix + ": link `toa:" + hit.value + "` has no entry under `authorities:` in the frontmatter")
    }
  }
  hits
}

/// Authorities of one group that are cited in the body, sorted by the court's supplied key.
#let cited-authorities(authorities, hits, kind-name, sort-key-fn) = {
  let selected = ()
  for pair in authorities.pairs() {
    let authority-key = pair.first()
    if pair.last().kind == kind-name and hits.any(hit => hit.value == authority-key) {
      selected.push(pair)
    }
  }
  selected.sorted(key: pair => sort-key-fn(pair.last()))
}

/// Distinct page labels for one authority, in first-citation order, or `passim` at the threshold.
#let authority-page-labels(hits, key, threshold) = {
  let pages = ()
  for hit in hits.filter(hit => hit.value == key) {
    let loc = hit.location()
    let label = numbering(loc.page-numbering(), ..counter(page).at(loc))
    if label not in pages { pages.push(label) }
  }
  if pages.len() >= threshold { emph[passim] } else { pages.join(", ") }
}
