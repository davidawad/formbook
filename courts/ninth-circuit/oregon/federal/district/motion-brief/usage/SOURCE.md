# Exemplar source: motion to dismiss with memorandum (ord)

| Field | Value |
|---|---|
| File | `SAMPLE-ord-motion-brief-columbiaveterinaryzoetis326cv01863.pdf` |
| URL fetched from | https://storage.courtlistener.com/recap/gov.uscourts.ord.196429/gov.uscourts.ord.196429.3.0.pdf (CourtListener RECAP copy of the ECF document) |
| How it was found | CourtListener search API, `type=r`, `court=ord`, `q="motion to dismiss" "memorandum"`, sorted by date filed: https://www.courtlistener.com/api/rest/v4/search/?type=r&court=ord&q=%22motion+to+dismiss%22+%22memorandum%22&order_by=dateFiled+desc&page_size=10 |
| Case | *Columbia Veterinary Hospital v. Zoetis, Inc.* |
| Court and division | United States District Court, District of Oregon, Portland Division |
| Docket number | 3:26-cv-01863-AN |
| Document | Document 3: Defendant Zoetis, Inc.'s Rule 12 Motion to Dismiss, with the Memorandum of Points and Authorities and a Certificate of Service (11 pages) |
| Filer | Defendant Zoetis, Inc., by Schwabe, Williamson & Wyatt, P.C. (Mario E. Delegato, OSB #195840; Cordelia Addington, OSB #243899) and Shook, Hardy & Bacon L.L.P. (pro hac vice applications to be filed) |
| Date filed | 09/15/26 (ECF header: "Filed 09/15/26"; the signature date and the certificate of service also read September 15, 2026). CourtListener's RECAP index lists the entry as 2026-09-08; the ECF header is used here. |
| Date fetched | 2026-10-14 |
| Public record | Yes: a federal court filing on CourtListener RECAP, not sealed |
| Text layer | Yes. `pdftotext` reads the whole document. Fonts: Times New Roman (body and bold), Arial, Liberation Sans, embedded. No italic face is visible in the text layer, so case names are transcribed roman |

## Notes on the exemplar

- The ECF header (case number, "Document 3", "Filed", "Page n of 11") is in the top margin of each page; it is not the filer's text.
- The footer on each page carries "Page n - [short title]" and the filer's firm block on the right. The template's footer carries the page number and the short title; the firm block is not reproduced in the footer (see README).
- The certificate of service lists its service methods as checkboxes. The text layer shows the options but not which boxes are ticked. The sample transcribes the one option the text layer marks as text: "other (specify) Email (courtesy copy)".
- No table of contents or table of authorities: the memorandum is under 20 pages (LR 7-1(c)).

## Other candidates found and not saved

- *Beckstrom v. Beckstrom*, 6:26-cv-00920-AA (Eugene Division), Twin Lakes Church's Motion to Dismiss and Supporting Memorandum of Law (8 pages, RECAP `gov.uscourts.ord.193990.25.0_1.pdf`), filed by counsel John Kaempf. The memorandum is in the same document. This is a second counsel-filed motion with a combined memorandum, usable for the tier-2 second-filer check.
- *Stapleton v. PeaceHealth*, 6:26-cv-00684 (39 pages), a larger combined motion; not downloaded.

## Second exemplar (retrieved 2026-10-17)

| Field | Value |
|---|---|
| File | `SAMPLE-ord-motion-brief-kaempfbeckstrom626cv00920.pdf` |
| Filer | Defendant Twin Lakes Church, filed by attorney John Kaempf (different filer from Zoetis) |
| Case | *Beckstrom v. Beckstrom*, No. 6:26-cv-00920-AA |
| Document | Document 25, Motion to Dismiss and Supporting Memorandum of Law, 8 pages |
| Date filed | 2026-06-30 (PDF metadata; CourtListener RECAP entry) |
| URL | https://storage.courtlistener.com/recap/gov.uscourts.ord.193990/gov.uscourts.ord.193990.25.0_1.pdf |
| Date retrieved | 2026-10-17 |
| SHA-256 | `c7a6df600489e7c42b6f9491ac850d8697d9072d3cb8e5af7e1ad71f5db32cb6` |
| Public record | CourtListener RECAP copy of the non-sealed ECF filing |

Downloaded from the public RECAP storage URL and checked with `pdfinfo` and `pdftotext`; the PDF is 8 pages with extractable text.
