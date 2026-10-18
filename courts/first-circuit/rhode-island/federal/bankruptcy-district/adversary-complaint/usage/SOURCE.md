# Exemplars: adversary-complaint, D.R.I. Bankruptcy Court (rib)

Date fetched (all files): 2026-10-14. Fetch method: `curl` of the RECAP storage PDF, with a browser user agent (CourtListener returns 403 to a bare client).

Search that found them: CourtListener search API, `court=rib`, `type=r` (RECAP), query `"complaint" "adversary proceeding"`, then the entry-1 storage PDF of each adversary docket.

| File | Case | Docket | Filer | Filed | Source URL |
|---|---|---|---|---|---|
| `FILED-EXAMPLE-adversary-complaint.pdf` | *Pisaturo v. Sunflower Real Estate, LLC* (Ch. 7 trustee's turnover complaint, 11 U.S.C. § 542) | 1:19-ap-01020 (underlying 1:17-bk-11357) | Plaintiff Charles A. Pisaturo, Jr., Chapter 7 Trustee | 05/21/2019 (Doc 1) | https://storage.courtlistener.com/recap/gov.uscourts.rib.118898/gov.uscourts.rib.118898.1.0.pdf (docket: https://www.courtlistener.com/docket/15655042/4/pisaturo-v-sunflower-real-estate-llc/) |
| `FILED-EXAMPLE-adversary-complaint-2.pdf` | *Harrington (U.S. Trustee) v. Ziegelmayer* (complaint for revocation of discharge, 11 U.S.C. § 727(d)) | 1:18-ap-01066 (underlying 1:17-bk-11357) | Plaintiff William K. Harrington, United States Trustee, Region One | 12/06/2018 (Doc 1) | https://storage.courtlistener.com/recap/gov.uscourts.rib.117951/gov.uscourts.rib.117951.1.0.pdf (CourtListener RECAP search hit, case name "US Trustee v. Ziegelmayer") |

Two filers: a private Chapter 7 trustee and the U.S. Trustee's office. Different filers, different claims, both D.R.I. Bankruptcy Court.

Both are public court records (RECAP). Both have a text layer (`pdffonts` shows embedded TrueType; `pdftotext` reads the caption, headings and numbered paragraphs).

Caveat: both filings are from 2018-2019, before the current FRBP 7008 and LBR 1005-1 text was in force. The template follows the current rules (see README.md); the exemplars settle only what the rules leave open.
