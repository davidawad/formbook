# Exemplar source: opening-brief, United States Bankruptcy Appellate Panel for the Eighth Circuit (bap8)

**Exemplar: yes.** `FILED-EXAMPLE-opening-brief.pdf` is a real, public, text-based Brief of Appellant filed in this court. The copy is the full 68-page filing, unmodified.

| Field | Value |
|---|---|
| URL (fetched) | <https://www.ncbrc.org/wp-content/uploads/Fisette-BAP-8th-Cir-debtor-brief.pdf> (the search result gave the same path over `http://`, which returned HTTP 406 to a default client; the `https://` URL with a browser user agent returned the PDF) |
| Case | *In re Fisette*; *Fisette v. Keller*. Appeal from the United States Bankruptcy Court for the District of Minnesota, Bankruptcy Case No. 10-32295-DDO |
| Docket | BAP No. 11-6012 (ECF header: "Appellate Case: 11-6012") |
| Doc type | Brief of Appellant (opening brief), FRBP 8014(a) |
| Filer | Michael James Fisette, Debtor-Appellant. Counsel: Craig W. Andresen (Attorney No. 186557). Appellee: Jasmine Z. Keller, Chapter 13 Trustee |
| Date filed | 2011-04-07 (ECF header "Date Filed: 04/07/2011"; signature dated April 7, 2011) |
| Date fetched | 2026-10-14 |
| Text layer | Yes. `pdftotext` extracts the full text; fonts are Times New Roman, not embedded |
| Pages | 68 (cover, parties, contents, authorities, body pp. 1-27, relevant bankruptcy-court documents p. 28, certificates pp. 29-30, addenda) |

Search log for this exemplar, 2026-10-14:

| # | Tool / query | Result |
|---|---|---|
| 1 | WebSearch (standard): "Bankruptcy Appellate Panel for the Eighth Circuit" "brief of appellant" "Fed. R. Bankr. P. 8014" pdf | Surfaced the ncbrc.org copy (BAP No. 11-6012) as a "Brief of Appellant". |
| 2 | WebFetch/curl of the ncbrc.org URL | HTTP 406 over `http://` with a default client; HTTP 200 PDF over `https://` with a browser user agent. |
| 3 | Justia docket entries (`cases.justia.com/.../11-6012/811734875/{1,3,4,5,6}.pdf`) | HTTP 403 (blocked from this box). Not used. |

Searches that did not turn up the other two doc types of this court are in `../../answering-brief/usage/SOURCE.md` and `../../reply-brief/usage/SOURCE.md`.

Search results that were not used as exemplars: other BAP 8th Cir. opinions and clerk letters (opinions, not briefs).

The eight searches logged before this exemplar was found (the previous version of this file, in git history at the `5303cc0` commit) used the same queries for all three doc types and found no opening brief.
