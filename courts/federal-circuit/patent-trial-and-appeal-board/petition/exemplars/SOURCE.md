# Exemplar source

Two filed petitions from different filers, both text-based PDFs, both public through RECAP. The tier-2 comparison in the README uses both.

## 1. `FILED-EXAMPLE-salesforce-wsou-IPR2022-00154-petition.pdf` (used for the sample)

| Field | Value |
|---|---|
| Document | Petition for Inter Partes Review of U.S. Patent No. 8,369,827 (IPR No. 2022-00154), with table of contents and list of exhibits |
| Case | *Salesforce.com, Inc. v. WSOU Investments, LLC d/b/a Brazos Licensing and Development*, IPR No. 2022-00154, PTAB |
| Filer | Salesforce.com, Inc. (Petitioner); counsel Quinn Emanuel Urquhart & Sullivan, LLP (James Glass, lead counsel) |
| Date | Dated November 8, 2021 (on the petition and both certificates). PTAB filing date not verified. |
| Filed publicly as | Exhibit A to Petitioner's notice of filing an IPR petition in *WSOU Investments, LLC v. Salesforce.com, Inc.*, No. 6:20-cv-01167-ADA (W.D. Tex.), ECF No. 51-1, filed November 19, 2021 |
| Source URL | https://storage.courtlistener.com/recap/gov.uscourts.txwd.1117986/gov.uscourts.txwd.1117986.51.1.pdf (docket: https://www.courtlistener.com/docket/18757189/wsou-investments-llc-v-salesforce-inc/) |
| Date fetched | 2026-10-14, curl, unmodified |
| Pages | 73, text-based, Times New Roman |
| Caveat | The "Case 6:20-cv-01167-ADA Document 51-1 Filed 11/19/21 Page n of 73" line on each page is the district-court ECF header, not part of the PTAB petition. |

## 2. `FILED-EXAMPLE-huawei-wsou-IPR2021-00689-petition.pdf` (second filer, tier-2 comparison)

| Field | Value |
|---|---|
| Document | Petition for Inter Partes Review of U.S. Patent No. 7,933,211 (Control No. IPR2021-00689), with table of contents |
| Case | Petition by Huawei Technologies Co., Ltd. against U.S. Patent No. 7,933,211, patent owner WSOU Investments, LLC; Control No. IPR2021-00689 (this copy has no PTAB caption page with a "v." line) |
| Filer | Huawei Technologies Co., Ltd. (Petitioner); counsel of record Nicholas W. Stephens |
| Date | Dated April 6, 2021 (on the petition, the certificate and the certificate of service). PTAB filing date not verified. |
| Filed publicly as | Exhibit A to the notice of filing an IPR petition in *WSOU Investments LLC v. Huawei Technologies Co., Ltd.*, No. 6:20-cv-00893-ADA (W.D. Tex.), ECF No. 38-1, filed April 20, 2021 |
| Source URL | https://storage.courtlistener.com/recap/gov.uscourts.txwd.1109453/gov.uscourts.txwd.1109453.38.1.pdf (docket: https://www.courtlistener.com/docket/18487349/wsou-investments-llc-v-huawei-technologies-co-ltd/) |
| Date fetched | 2026-10-14, curl, unmodified |
| Pages | 84 (the first page is the exhibit slip sheet; the petition runs from page 2), text-based, Times New Roman with Cambria and Calibri in places |
| Caveat | The "Case 6:20-cv-00893-ADA Document 38-1 Filed 04/20/21 Page n of 84" header is the district-court ECF header. The petition word count certificate is 13,876 words. |

## Search record

- CourtListener search API (`/api/rest/v4/search/`, type `r`) for `"Petition for Inter Partes Review"` with `"Mandatory Notices"`: returned several "Notice of filing an IPR petition, Ex. A" filings from WSOU cases in W.D. Tex. Both chosen above were downloaded and checked for a petition caption and text.
- Patent owner responses: see `../../patent-owner-response/exemplars/SOURCE.md`.
