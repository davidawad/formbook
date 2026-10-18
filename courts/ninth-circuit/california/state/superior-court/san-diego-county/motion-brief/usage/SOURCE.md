# Exemplar source: motion-brief (San Diego County Superior Court)

| Field | Value |
|---|---|
| Saved file | `SAMPLE-calsuperct-sandiego-motion-brief-atamianolaplex37202400018492.pdf` (pages 1-24 of the packet below: notice of motion, table of contents, table of authorities, memorandum through the signature block) |
| URL fetched from | https://docs.simpluris.com/websites/7daec45f-cb53-4706-bad7-f7d98756b79c/documents/27f78e7c-8c42-4967-959a-e336e1449233/Motion%20for%20Attorneys%20Fees%20Costs%20and%20Service%20Awards.pdf (copy of the filed packet posted by Simpluris, Inc., the claims administrator in the case) |
| Full packet | 98 pages: notice and motion (pp. 1-3), TOC and TOA (pp. 4-8), memorandum (pp. 9-24), declarations of Abbas Kazerounian, Jason A. Ibey, Gil Melili, Pamela E. Prescott, Miray Atamian and Christopher Leung, proof of service (pp. 25-98). Only pp. 1-24 are saved; the declarations are a separate doc type. |
| Case name | Miray Atamian, Individually and On Behalf of All Others Similarly Situated v. Olaplex, Inc.; and Olaplex Holdings, Inc. |
| Court | Superior Court of California, County of San Diego, Central (Hall of Justice), Dept. C-72 (Hon. Marcella O. McLaughlin) |
| Docket no. | 37-2024-00018492-CU-BT-CTL |
| Filer | Plaintiff Miray Atamian, by Kazerouni Law Group, APC (Abbas Kazerounian, SBN 249203; Gil Melili, SBN 337116) |
| Document | Notice of Motion and Plaintiff's Motion for Attorneys' Fees, Costs and Service Award; Memorandum of Points and Authorities in Support (memorandum at pp. 9-24 of the packet, with TOC and TOA at pp. 4-8, as CRC 3.1113(f) requires for a memorandum over 10 pages) |
| Date filed | 2025-04-21 (e-filing stamp "4/21/2025 4:51:10 PM", Clerk of the Superior Court) |
| Date fetched | 2026-10-15 |
| Form of the copy | Public record (a filing in an open civil case, posted by the claims administrator). Text PDF with an OCR text layer (the caption carries "[IMAGED FILE]"; the fonts are embedded TrueType, Times New Roman names). `pdftotext` returns the text. The file's cross-reference table is damaged; poppler reconstructs it, and the excerpt still opens and renders. |
| Size of the saved file | 6.7 MB (pages 1-24 of a scanned-then-OCR'd packet). Larger than the other exemplars in this repo; kept because the eval loop needs the real page to overlay. |
| How the excerpt was made | `pdfseparate -f 1 -l 24` then `pdfunite`, from the packet above. No page was altered. |

Why this one: a real, filed San Diego Superior Court motion (notice and memorandum) in a civil case, with a Dept. C-72 hearing reservation, on the same 28-line pleading format as the sibling complaint. The search that found it is in `../README.md`.

Tier 2 note: this is one filer (Kazerouni Law Group, APC). EVAL-LOOP requires two or three exemplars from different filers before a convention can be judged, so tier 2 cannot be finished for this doc type on this one exemplar.
