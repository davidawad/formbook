# Exemplars: motion-brief, D.R.I. Bankruptcy Court (rib)

Date fetched (all files): 2026-10-14. Fetch method: `curl` of the RECAP storage PDF, with a browser user agent (CourtListener returns 403 to a bare client).

Search that found them: CourtListener search API, `court=rib`, `type=r` (RECAP), queries `"motion to dismiss" "memorandum"` and `"memorandum of law in support" motion`, restricted to adversary dockets (`-ap-`).

| File | Case | Docket | Filer | Filed | Source URL |
|---|---|---|---|---|---|
| `FILED-EXAMPLE-hidalgo-astrue-12-ap-01039-motion-brief.pdf` | *Hidalgo v. Astrue* (Commissioner, Social Security Administration): Motion to Dismiss and, in the Alternative, Motion for Summary Judgment, with the memorandum in the same document, plus certificate of service. 9 pages. | 1:12-ap-01039 (underlying BK 11-10203) | Defendant Michael J. Astrue, Commissioner, SSA, by the U.S. Attorney (D.R.I.) | 10/23/2012 (Doc 11) | https://storage.courtlistener.com/recap/gov.uscourts.rib.100784/gov.uscourts.rib.100784.11.0.pdf (docket: https://www.courtlistener.com/docket/31500775/11/raymond-hidalgo-and-flor-hidalgo-adversary-proceeding/) |
| `FILED-EXAMPLE-donovan-christiana-17-ap-01028-motion-brief.pdf` | *Donovan v. Christiana Trust* (Defendant's Memorandum in Support of Its Motion to Dismiss, Rule 12(b)(1)). Memorandum only, 13 pages; the motion itself (Doc 7, entry 7.0) was not retrievable. | 1:17-ap-01028 (underlying 1:16-bk-11439) | Defendant Christiana Trust, a division of Wilmington Savings Fund Society, FSB, as Trustee of ARLP Trust 5 | 11/08/2017 (Doc 7-1) | https://storage.courtlistener.com/recap/gov.uscourts.rib.115200/gov.uscourts.rib.115200.7.1.pdf (docket: https://www.courtlistener.com/docket/16509470/7/1/donovan-v-christina-trust-a-division-of-wilmington-saving/) |

Two filers: the U.S. Attorney for the government defendant, and a creditor-defendant's counsel. Both are public court records (RECAP). Both have a text layer.

Why the Donovan file is a memorandum alone: it is the only RI adversary memorandum in RECAP that is text-based and sits in its own document. It shows the memorandum caption and the Rule 12(b)(1) structure. The Hidalgo file is the one complete motion-with-memorandum in one document, so it is the sample's basis.

Caveat: both filings are from 2012 and 2017, before the current LBR 1005-1(d) response-time text was in force. The template follows the current rules (see README.md).
