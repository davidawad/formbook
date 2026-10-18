# Exemplar sources: trial brief

Fetched 2026-10-14 from the USPTO TTABVUE public docket (https://ttabvue.uspto.gov/).

| File | Filer (counsel) | Case | Docket | Date filed | ESTTA | Fetched from |
|---|---|---|---|---|---|---|
| `SAMPLE-ttab-trial-brief-treefrog91232860.pdf` | TreeFrog Development, Inc. (Heather J. Kliebenstein and Eric R. Chad, Merchant & Gould P.C.) | TreeFrog Development, Inc. v. Sakar International, Inc. (LIFEJACKET; App. No. 86905410) | Opposition No. 91232860 | 11/29/2018 | ESTTA938126 | https://ttabvue.uspto.gov/ttabvue/ttabvue-91232860-OPP-39.pdf |

What the file is. The TTABVUE item is the 406-page ESTTA filing bundle (17 MB) for "Other Motions/Papers" that carries "Opposers Rebuttal Brief_Redacted.pdf" as its first attachment, followed by declarations and exhibits. The exemplar is the brief only: pages 2-27 of the bundle, that is the caption page, the table of authorities, the body and the certificate of service. The ESTTA receipt page and the attachments after the brief are removed. Ghostscript (`-dPDFSETTINGS=/ebook`) reduced the extract from 8.7 MB to 2 MB; text and fonts are unchanged (pdffonts shows the embedded fonts, pdftotext returns the text).

Type. This is the opposer's rebuttal (reply) trial brief, not the opposer's main brief. It is the only trial brief found in the search (see README.md, "Searches").

Redacted. The filing is the public "Redacted Version" that the caption page states.

## 2. SAMPLE-ttab-trial-brief-sakar91232860.pdf

- Court: Trademark Trial and Appeal Board (USPTO)
- Case: TreeFrog Development, Inc. v. Sakar International, Inc. (LIFEJACKET; App. No. 86905410), Opposition No. 91232860
- Docket: TTABVUE entry 37, "D MAIN BRIEF: TM RULE 2.128" (ESTTA934894; submission type "Other Motions/Papers"; attachments "Sakar supplemental brief redacted part 1-3.pdf")
- Document title: "Applicant's Supplemental Brief" (the defendant's brief on the case under the parties' Accelerated Case Resolution stipulation, docket entry 28 and Board order entry 35), redacted public version
- Filer: Sakar International, Inc., applicant/defendant (Theodore R. Remaklus, Wood, Herron & Evans, L.L.P., Cincinnati). Different party and different firm from exemplar 1 (TreeFrog, Merchant & Gould)
- Date filed: 11/14/2018
- Pages: 31 (pages 2-32 of the 236-page TTABVUE bundle: caption page with table of contents (i), table of authorities (ii), body 1-27 with conclusion and signature, certificate of service (28)). The ESTTA filing-form page (bundle p.1) and the Remaklus declaration and exhibits (bundle pp. 33-236) are removed, with poppler `pdfseparate`/`pdfunite`; page content unchanged
- Text layer: yes (Times New Roman embedded; pdftotext returns the text). 3.1 MB
- URL fetched: https://ttabvue.uspto.gov/ttabvue/ttabvue-91232860-OPP-37.pdf (bundle sha256 70d568c8befb435f78bb9d810dac2588d3e0e5898dd61ca8b62dee7ee6fe9edc, 16,574,555 bytes); docket listing https://ttabvue.uspto.gov/ttabvue/v?pno=91232860&pty=OPP
- Date retrieved: 2026-10-17
- sha256 (extract): ac87abcce4dc65dd6a1c4709c2401f53ddaf0d24e8c8c1dd06b3a1f5a5fe9a7b

Note: same proceeding as exemplar 1, opposite side. Together they give two filers (opposer's rebuttal brief, applicant's main brief). An ACR brief; a conventional (non-ACR) main brief from a third proceeding was not found in the time spent (dockets 91274910, 91301120, 91233515, 91269187, 91266266 checked on TTABVUE; none had a brief on the case).
