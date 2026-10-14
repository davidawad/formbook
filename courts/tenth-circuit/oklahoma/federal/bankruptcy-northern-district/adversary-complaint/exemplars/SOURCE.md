# Exemplar source: adversary complaint, N.D. Okla. Bankruptcy Court (oknb)

**Status: no exemplar. BLOCKED: no exemplar.** No filed adversary complaint from this court was found, so there is no `FILED-EXAMPLE-*.pdf` in this folder. The template and the sample are built from the governing rules (see `../README.md`).

Searched 2026-10-14. Everything below was checked (some items only from search snippets, marked as such); none of it is an adversary complaint filed in this court.

| Source | What it is | Used? |
|---|---|---|
| https://www.oknb.uscourts.gov/sites/oknb/files/Filing%20a%20New%20Adversary%20Proceeding.pdf (May 2024) | The court's own how-to for opening an adversary in CM/ECF. It walks through a sample dischargeability complaint with example case 23-10020. Guidance, not a filing. | No (not a filed document) |
| https://www.govinfo.gov/content/pkg/USCOURTS-oknb-4_17-ap-01038/pdf/USCOURTS-oknb-4_17-ap-01038-0.pdf | *Renfrow v. Pettigrew* (Adv. No. 17-01038-R), Order on objection to clerk's default, Document 43, filed 09/11/18. A court order, not a party filing. Read with pdftotext: confirms the caption form (In re block, Case No., Chapter, Adv. No.). | No (court order) |
| govinfo `USCOURTS-oknb-4_17-ap-01034`, `4_17-ap-01027`, `4_21-ap-01016`, `4_19-ap-01039` | Court orders on §523 and dismissal motions in N.D. Okla. adversaries. Described from search snippets only; not opened. Orders, not filings. | No |
| https://www.courtlistener.com/ (search `court_id:oknb`, adversary complaints) | Blocked to automated fetches (HTTP 403 to WebFetch and curl HEAD) in this session. Not searchable from this box. | No (not reachable) |
| WebSearch: "Northern District of Oklahoma" + adversary complaint / motion to dismiss / 523 / Adv. No. (standard and extended modes, about 8 queries) | Returned local rules, the how-to above, govinfo orders, and other districts' complaints (e.g. D. Ariz. 2:25-bk-11801, not Oklahoma). | No |
| https://www.courtrules.net/courts/federal/bankruptcy-northern-district-oklahoma/ | Local rule index. Used only for rule text cross-checks. | Rule text only |

## What would settle it

- A CourtListener RECAP query for `court_id:oknb` with `document_type` Complaint and `cause` 11:523, from a box that can reach courtlistener.com. Save a text-based PDF as `FILED-EXAMPLE-<case>-<docket>-adversary-complaint.pdf` and fill in this file.
- Or a PACER copy of any adversary complaint in the N.D. Okla. bankruptcy court (public court record).
