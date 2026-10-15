# Exemplar source: adversary complaint, Bankruptcy Court M.D. La. (lamb)

Status: **two filed exemplars**, both public RECAP copies of Doc. 1 (the complaint) from M.D. La. adversary proceedings, both text-based PDFs. Both were downloaded 2026-10-15 from `storage.courtlistener.com` (the RECAP archive behind CourtListener).

| File | Adversary | Main case | Filer (counsel) | Filed / entered | Pages | Text layer |
|---|---|---|---|---|---|---|
| `FILED-EXAMPLE-hoven-19-01027-adversary-complaint.pdf` | *Pull-A-Part, LLC v. Hoven*, Adv. 19-01027, Doc. 1 | 19-10514 (chapter 7) | Andrew Murrell Law Firm (J. Andrew Murrell) for Pull-A-Part, LLC, plaintiff | Filed 08/13/2019 (entered 08/13/2019 14:26:26) | 5 | yes: Word 2016 export, Calibri and Times, all pages extract |
| `FILED-EXAMPLE-criss-18-01006-adversary-complaint.pdf` | *Criss v. Criss*, Adv. 18-01006, Doc. 1 | 17-11210 (chapter 7) | Grand Law Firm, LLC (Trenton A. Grand; Robert W. Hoke) for Sinarta Criss, plaintiff | Filed 03/16/2018 (entered 03/16/2018 16:45:52) | 2 | yes: Word 2016 export, Times, all pages extract |

Two different filers, as the tier-2 standard asks. Both filings are older than the 2022 local rules this template is built from, so they settle conventions the rules leave open, not compliance with the current rules.

## Where each came from

- Hoven: CourtListener docket `https://www.courtlistener.com/docket/16056753/1/christopher-scott-hoven-adversary-proceeding/` (docket id 16056753, RECAP document id 496354968). PDF: `https://storage.courtlistener.com/recap/gov.uscourts.lamb.67161/gov.uscourts.lamb.67161.1.0.pdf` (`pacer_doc_id` 08606275816). Filer's caption reads "PULL-A-PART LLC, Plaintiff; CHRISTOPHER SCOTT HOVEN, Defendant"; the complaint header reads "Case 19-01027 Doc 1 Filed 08/13/19 Entered 08/13/19 14:26:26 Page 1 of 5".
- Criss: CourtListener docket `https://www.courtlistener.com/docket/6673138/1/criss-v-criss/` (docket id 6673138, RECAP document id 144293052, the main complaint; the attachments are not used). PDF: `https://storage.courtlistener.com/recap/gov.uscourts.lamb.64943/gov.uscourts.lamb.64943.1.0.pdf` (`pacer_doc_id` not recorded in the search result; the storage path is the one CourtListener lists for document 1). Header: "Case 18-01006 Doc 1 Filed 03/16/18 Entered 03/16/18 16:45:52 Page 1 of 2".

Both documents are public court records as RECAP-uploaded PDFs. Personal identifiers in them (party names, a loan and an address in Criss) are reproduced only in the exemplar PDFs, not in the template or the sample.

## How they were used

- Structure only: an unnumbered opening paragraph before the first numbered allegation (both), numbered allegations (both), an unnumbered WHEREFORE paragraph (both), and a counsel signature block with `/s/` and the firm name (both). Both put the caption in a Form 416 style, with case, chapter and adversary numbers at the right. Neither has section headings, a certificate, a proposed order, a consent statement, or a cover sheet.
- No text, coordinates or line breaks from either filing is in any template. The sample `samples/INPUT-adversary-complaint-sample.md` is fictitious and only mirrors the structure.

## Searches (2026-10-15)

| Search | Result |
|---|---|
| CourtListener REST search, `court=lamb&type=r` (anonymous). 860 RECAP hits for "complaint". Anonymous calls are throttled to 5 per minute, so queries were paced. | Reachable this time, unlike the 2026-10-14 pass. Returned adversary complaints with RECAP PDFs for the candidates below. |
| Candidates checked (`page_count`, `is_available`, text layer) | **Used:** Hoven 19-01027 Doc 1 (5 pp, text), Criss 18-01006 Doc 1 (2 pp, text). **Rejected, scanned images with no text layer** (words per page: 13, the header only; `pdfimages` shows CCITT page images): Foster v. Capital City Credit, Adv. 23-01002 Doc 1 (24 pp, Southeast Louisiana Legal Services, a motion for sanctions with complaint); Campbell v. AES/Barclays, Adv. 23-01015 Doc 1 (5 pp, NAPS2 scan, 65 words). **Not available** (RECAP entry is not in the archive): Callais v. Worley 18-01021, Worley 20-01008 (Investar), Carey Guglielmo 21-01005, Foster Tommy 20-01025, Barber 20-01022, Rice 20-01047, Selders 19-01002 (Louisiana Workforce Commission), Brown 18-01052 (Tower Credit), Kozar 16-01019/01020, Emery 09-01134, Sterling 12-01070. **Other:** Criss v. Williams 18-01020 Doc 1 (1 pp, text), not used, because a one-page complaint says nothing the two above do not. |
| Court web site `https://www.lamb.uscourts.gov/` | Reachable from this box. No complaints are posted there; the 2026-10-14 notes stand. |
| `https://www.courtlistener.com/docket/.../` HTML pages | HTTP 403 to anonymous requests; the storage PDFs are not blocked. |

## Other leads from the 2026-10-14 pass (still valid)

- Governing text used (not an exemplar): Local Rules of the Bankruptcy Court, M.D. La., amended January 1, 2022 (`https://www.lamb.uscourts.gov/sites/lamb/files/2022_Local_Rules.pdf`); Standing Order 2026-1, cover sheet for adversary proceedings (`https://www.lamb.uscourts.gov/sites/lamb/files/Standing%20Order%202026-1%20adversary%20cover%20sheet.pdf`); Fed. R. Bankr. P. 7008, 7010, 9004 (Cornell LII).
- Watson (Adv. 04-1006, 2004 memorandum opinion), Foster (Adv. 23-1002, Doc. 67 memorandum opinion), and Schott (Adv. 18-1025 orders) are opinions, not complaints.

## Limits

- Two exemplars from two filers is the number the tier-2 standard asks for. Neither filing is recent. Both predate the 2022 local rules and Standing Order 2026-1, so the template's rule-driven choices (consent statement, the B1040 cover sheet) are not settled by these exemplars and are kept from the rules.
- Both filings are short (2 and 5 pages). The sample is 4 pages. A longer M.D. La. complaint from the same period was not findable as text.
