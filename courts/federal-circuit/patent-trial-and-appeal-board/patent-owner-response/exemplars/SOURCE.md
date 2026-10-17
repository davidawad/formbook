# Exemplar source

One filed patent owner response, text-based PDF. Tier 2 needs 2 or 3 exemplars from different filers (`docs/EVAL-LOOP.md`); only one was found, so tier 2 cannot be finished here (see the README).

## 1. `FILED-EXAMPLE-juniper-swarm-IPR2021-01445-patent-owner-response.pdf` (used for the sample and the overlay)

| Field | Value |
|---|---|
| Document | Patent Owner Response under 37 C.F.R. § 42.120, IPR2021-01445 (the document does not state its paper number; the blog's file name ends "-21"), U.S. Patent No. 9,852,004, with table of contents, table of authorities, exhibit list, certificate of compliance and certificate of service. 65 pages. |
| Case | *Juniper Networks, Inc. v. Swarm Technology, LLC*, IPR2021-01445, PTAB |
| Filer | Swarm Technology, LLC (Patent Owner); lead counsel Daniel R. Pote, Jennings Strouss & Salmon PLC |
| Date | Dated May 25, 2022 (on the response, the certificate of compliance and the certificate of service). The response's scheduling-order reference is Paper 16 (PTAB, March 2, 2022). PTAB filing date not verified. |
| Source URL | https://www.ptablitigationblog.com/wp-content/uploads/2023/04/Patent-Owner-Response_PTAB-IPR2021-01445-21.pdf (PTAB Litigation Blog, posted April 2023; the file is the Board paper as published there) |
| Date fetched | 2026-10-14, curl, unmodified |
| Pages | 65, text-based. Fonts: Times New Roman (body), Cambria and Calibri in places. |
| Caveat | The blog is a third-party republisher, not the PTAB E2E record. The text is the response as filed, but the copy's provenance is the blog's post. |

## Search record (2026-10-14)

- CourtListener RECAP (v4 search, document and docket types), for patent owner response phrases: the hits were excerpts (Google v. Sonos, doc. 297, 7 pages, which attaches only Sonos's response excerpts as Exhibit 4), notices, and district-court exhibits whose attachments are not in the RECAP archive (Ultratec v. Sorenson, 3:13-cv-00346, docket 213, exhibits 1, 3, 8, 10, 12: 404 at `storage.courtlistener.com`). Not usable as full exemplars.
- ptab.uspto.gov: unreachable from this box (no HTTP response). ptacts.uspto.gov: HTTP 403 to this box.
- Unified Patents portal (portal.unifiedpatents.com): a JavaScript app with no static document links.
- uspto.gov Board papers (`sites/default/files/documents/IPR2021-01124Paper*.pdf`): only Paper 13 (a judgment) is hosted.
- Web search (2026-10-14): found the Juniper response above. A second search for a different filer's response returned nothing usable (other hits were decisions, replies, or preliminary responses).

## 2. `FILED-EXAMPLE-omni-medsci-ipr2021-00453-patent-owner-response.pdf` (second filer, tier-2 comparison)

| Field | Value |
|---|---|
| Document | "Patent Owner's Response to Petition for Inter Partes Review under 37 C.F.R. § 42.107" (title as printed; the paper is the post-institution response: it answers the Board's Institution Decision and lists the patent owner's new exhibits through Ex. 2136), U.S. Patent No. 10,517,484, with table of contents, table of authorities, updated list of exhibits, certificate of service and "Certificate of Compliance Pursuant to 37 C.F.R. § 42.24" (8,936 words). |
| Case | *Apple Inc. v. Omni MedSci, Inc.*, IPR2021-00453, PTAB |
| Filer | Omni MedSci, Inc. (Patent Owner); counsel Thomas A. Lewry and others, Brooks Kushman P.C. (Southfield, Michigan). Different party and firm from entry 1 (Swarm Technology / Jennings Strouss & Salmon). |
| Date | Dated November 12, 2021 (signature, certificate of service, certificate of compliance). PDF CreationDate 2021-11-12 (Microsoft Word for Microsoft 365). PTAB paper number not stated in the copy. |
| Filed publicly as | Samsung Ex. 1012 in PGR2025-00064 (Samsung v. Omni), as stamped on page 1 ("Samsung Ex. 1012 / Samsung v. Omni / PGR2025-00064 / Page 00001"); each page carries the re-filer's footer "PGR2025-00064 Page 000nn". Downloaded from P-TACTS public documents (no login). |
| Source URL | https://ptacts.uspto.gov/ptacts/public-informations/petitions/1558192/download-documents?artifactId=c2gjZwYm42VA3DdOaQVSmmi-coK4MPIPz5WAeHtzj07c7p9UkeqkSns (found through a web search for PTAB papers citing § 42.24) |
| Date retrieved | 2026-10-17, curl, unmodified |
| Pages | 51 (caption page, front matter i-v, body 1-43, signature, certificate of service p. 44, certificate of compliance p. 45), 612 x 792 pt, text-based (pdftotext extracts every page). Fonts: Times New Roman family (several not embedded), Calibri, Arial-Bold. |
| sha256 | dd7e002f76dc3cfeaf20d91190e6f6f23186c54f711ef1ecbb4f2ed90aee5ae5 |
| Caveat | The exhibit label on page 1 and the "PGR2025-00064 Page" footer were added when Samsung re-filed the paper as an exhibit; they are not part of the response. The title's "§ 42.107" is the filer's own text. |

## Search record (2026-10-17)

- CourtListener v4 search API: HTTP 429 (50/hour, exhausted) at the time of the search.
- developer.uspto.gov PTAB API: 301 (retired); api.uspto.gov trials documents: 401 (API key required); P-TACTS case-document listing endpoints (`/ptacts/public-informations/petitions/<id>/...`): 401. Individual P-TACTS `download-documents?artifactId=...` links are public and returned the PDF above.
- Web search for patent owner response PDFs with § 42.120 / § 42.24 certificates: the Omni MedSci response above (via its P-TACTS link); other hits were decisions, replies, rules text, and docket listings (Patexia, DocketAlarm) without free PDFs.
