# Exemplar sources: E.D. Wisconsin, brief supporting a Rule 12(b)(6) motion to dismiss

Found through the CourtListener search API (`https://www.courtlistener.com/api/rest/v4/search/?type=r&court=wied`), RECAP documents, searched for "brief in support" and "motion to dismiss". Fetched 2026-10-14 from the RECAP storage URLs below. Public court records; no sealed or redacted material.

| File | Case | Docket | Filer | Date filed | Fetched from | Pages |
|---|---|---|---|---|---|---|
| `SAMPLE-wied-motion-brief-nocams226cv01863.pdf` | Nocams Muskego, Inc. v. City of Muskego, et al. | 2:26-cv-01863 (E.D. Wis.), ECF 4 | All Defendants, Crivello, Nichols & Hall, S.C. (Samuel C. Hall, Jr.; Molly K. Woodford) | 2026-10-07 | https://storage.courtlistener.com/recap/gov.uscourts.wied.118635/gov.uscourts.wied.118635.4.0.pdf | 14 |
| `SAMPLE-wied-motion-brief-schmidt226cv00611.pdf` | Schmidt v. Naqvi, et al. | 2:26-cv-00611 (E.D. Wis.), ECF 23 | Defendant Kevin Morrison, Laffey, Leitner & Goode LLC (Mark M. Leitner; John M. O'Shea) | 2026-08-28 (date on the brief; the search row shows 2026-04-10 for the docket) | https://storage.courtlistener.com/recap/gov.uscourts.wied.116212/gov.uscourts.wied.116212.23.0_1.pdf | 9 |

## Use

- The overlay (`usage/OVERLAY-nocams-motion-brief.pdf`) compares against the first file in this folder (Nocams, alphabetically first).
- Nocams is the layout reference for the brief: caption with the case number on the right, unnumbered double-spaced paragraphs, Roman-numeral argument headings with lettered sub-headings, CONCLUSION, signature block. Schmidt is the second filer: the same structure, a two-line title, Times-type body in the text layer, `INTRODUCTION` and `ARGUMENT` headings with roman numerals.
- The Nocams sample (`usage/INPUT-wied-motion-brief-nocams.md`) transcribes the whole brief from its text layer. Case names are italicized by the transcription, as General L.R. 5(a)(7) requires; the text layer carries no italic information, so the italics are not from the filing. Typos in the filing (for example "dipositive", "4 F.th", "For this additional reasons") are kept as filed.

## Why these two

Searched: CourtListener RECAP, `court=wied`, queries "brief in support" and "motion to dismiss". Downloaded and checked for a text layer: Nocams (14 pp.), Schmidt (9 pp.). Downloaded but not used: Richardson v. City of Milwaukee (2:26-cv-00595, 15 pp., a motion rather than a brief). Listed but not downloaded: Bronstin v. Ixonia Bank (2:26-cv-00970, 22 pp., a reply brief). Nocams and Schmidt were chosen because they are a principal brief supporting a Rule 12(b)(6) motion, from two different firms.
