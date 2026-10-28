# Exemplar source: motion-brief (pamb)

- File: `FILED-EXAMPLE-motion-brief.pdf`
- Fetched from: `https://storage.courtlistener.com/recap/gov.uscourts.pamb.273556/gov.uscourts.pamb.273556.32.0.pdf` (CourtListener RECAP archive, document 32; found through the CourtListener search API, `type=rd`, `court=pamb`).
- Case: *In re James Mullen* (a/k/a James Robert Mullen, James Mullen), Chapter 13, Case No. 5-22-00237-MJC (M.D. Pa. Bankr.).
- Title on the document: "Brief in Support of Debtor's Motion to Deem Bankruptcy Filing Effective as of February 4, 2022".
- Filer: James Mullen, debtor, by counsel Tullio DeLuca, Esq.
- Date filed: 2022-05-16 (ECF header: "Filed 05/16/22"; filed on the Court's order directing a memorandum of law on or before May 16, 2022, as the brief itself recites).
- Date fetched: 2026-10-14.
- Public record: RECAP-hosted PDF of a filing on the public docket.
- Text layer: yes (8 pages; `pdftotext` yields the body).

## Limits of this exemplar

- It is the **brief** (the memorandum of law) filed under FRBP 9013 with the debtor's separate motion. The motion itself (the debtor's Motion to Deem Bankruptcy Filing Nunc Pro Tune, filed 2022-04-16, RECAP entry not retrieved; the RECAP storage for that entry returned 404) is not in this folder. The template's motion-brief therefore covers the motion's caption, title, and memorandum body, and the sample is the memorandum that was filed.
- The exemplar has no table of contents or table of authorities; it is under 15 pages (L.B.R. 9013-2(a), (d)).
- Only one exemplar of a motion memorandum from M.D. Pa. was found as a text-based PDF. The eval-loop tier-2 rule (2 or 3 exemplars from different filers) is not met. See `../README.md`.

## Searches tried

- CourtListener search API, `type=rd`, `court=pamb`: "Brief in Support", "Memorandum of Law", "Motion" with "Memorandum of Law", "Motion" with "Brief in Support". Candidates examined and rejected: Madeam, Chapter 13 trustee's Memorandum of Law in Support of Motion to Dismiss (5-22-bk-01575, Doc 33; text-based but a standalone memorandum from a trustee's motion; kept as a secondary reference in `../README.md`, not used for the sample); the Sanctions motion (214443, Doc 127, 26 pages, scanned: no text layer); Rosario, Memorandum of Law and Fact (264466, Doc 59, 3 pages, not checked in full).
- Web search for pamb memoranda and briefs: no additional text-based PDFs.

## Initial font-audit search note (superseded)

At the initial search pass, the Madeam memorandum had been identified but its public PDF URL had not yet been recovered. It has since been downloaded, verified, and selected below.

## Selected font-audit replacement — In re Madeam

The Mullen PDF is flagged for Liberation Sans in the font audit and is an OCR/text-layer scan. The saved Madeam memorandum is selected as the same-court motion-brief replacement: it is a public filing supporting a motion to dismiss, with a native searchable text layer and Times New Roman body text. It is a separate memorandum from the motion and was filed by a Chapter 13 trustee, so it is a font-audit replacement rather than a direct substitute for Mullen's sample.

| Field | Value |
|---|---|
| File | `FILED-EXAMPLE-motion-brief-2.pdf` |
| Court | U.S. Bankruptcy Court for the Middle District of Pennsylvania |
| Case | *In re Alfredo F. Madeam, Jr.*, Chapter 13, No. 5-22-bk-01575-MJC |
| Document | Memorandum of Law in Support of Trustee's Motion to Dismiss, ECF Doc. 33 (7 pages) |
| Filer | Jack N. Zaharopoulos, Standing Chapter 13 Trustee |
| Date filed | January 12, 2023 |
| Source URL | https://storage.courtlistener.com/recap/gov.uscourts.pamb.274935/gov.uscourts.pamb.274935.33.0.pdf (CourtListener RECAP; docket entry 33) |
| Date retrieved | 2026-10-17 |
| Text and fonts | Native text layer (`pdftotext` extracts 1,966 words); embedded Times New Roman regular and italic; Liberation Sans and standard fonts also appear in cover/signature material. |
| SHA-256 | `36e0ef70eda367e94ff449bd3cbd57a1cbf0e64872e27f91547a6f6f748b67ca` |

## Replacement exemplar (fb-9fyu, RECAP): `FILED-EXAMPLE-motion-brief-3.pdf`

- File: `FILED-EXAMPLE-motion-brief-3.pdf` (6 pages)
- Case: *In re Mulkerin*, No. 1:24-bk-03264-HWV, Chapter 7 (Doc. 481)
- Document: Trustee's Brief in Support of Application to Pay Special Counsel's Fee
- Filer: Chapter 7 trustee, through Steven M. Carr, Ream, Carr, Markey, Woloshin & Hunter, LLP
- Date filed: 2025-06-27
- URL: https://storage.courtlistener.com/recap/gov.uscourts.pamb.282280/gov.uscourts.pamb.282280.481.0.pdf
- Date retrieved: 2026-10-28 (CourtListener RECAP search, staged by the PM)
- Text layer: yes (`pdftotext` returns 1370 words); Times New Roman embedded for the body (`pdffonts`; `fb fonts audit` class metric-exact, body timesnewroman 0.931)
- SHA-256: `7c7c3dafe82a0b14ea85a8a26cdaff9ae313d223fa588b9f3d103b266003efb4`
- Replacement for `FILED-EXAMPLE-motion-brief.pdf` (fb-9fyu: scanned image with an OCR text layer). The old exemplar is kept; no INPUT is transcribed from this one.
