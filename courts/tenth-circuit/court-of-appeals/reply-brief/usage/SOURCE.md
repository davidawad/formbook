# Exemplars: reply brief, Tenth Circuit

Both files are public court records from the RECAP archive (CourtListener), which mirrors the PACER filing as-is. Both have a text layer (`pdftotext` yields the body), embedded fonts, and no annotations added by us. Fetched 2026-10-14 through the CourtListener REST search API (`/api/rest/v4/search/`, `type=rd`, `court=ca10`).

| File | Case | Docket no. | Filer | Date filed | Pages | Fetched from |
|---|---|---|---|---|---|---|
| `SAMPLE-ca10-reply-brief-oliver262126.pdf` | *United States v. Maggie Toulouse Oliver* (Secretary of State of New Mexico, defendant-appellee; intervenors New Mexico Alliance for Retired Americans et al.) | 26-2126 (D.N.M. 1:25-cv-1193-JCH-JFR) | United States of America (DOJ Civil Rights Division, Appellate Section), appellant | 2026-10-08 (ECF doc 66; "Reply Brief for the United States as Appellant") | 44 (brief text pp. 1-33; word count stated as 6,496) | https://storage.courtlistener.com/recap/gov.uscourts.ca10.92366/gov.uscourts.ca10.92366.66.0_1.pdf (docket page: https://www.courtlistener.com/docket/73678095/66/united-states-v-oliver/) |
| `SAMPLE-ca10-reply-brief-lyman264014.pdf` | *Phil Lyman v. Deidre Henderson* (Lt. Governor of Utah) | 26-4014 (D. Utah 4:25-CV-00069-DN-PK) | Phil Lyman, appellant (counsel: Public Interest Legal Foundation) | 2026-07-27 (ECF doc 23; "Appellant's Reply Brief") | 14 (word count stated as 1,579) | https://storage.courtlistener.com/recap/gov.uscourts.ca10.91454/gov.uscourts.ca10.91454.23.0.pdf |

## Use

- **Primary exemplar** for the sample transcription and the overlay: the Oliver brief (`usage/INPUT-ca10-reply-brief-oliver.md`, `usage/OVERLAY-oliver-reply-brief.pdf`). It is from a federal filer; it is the one with a full structure (cover, TOC, TOA, Argument with point headings, conclusion, signature, Form 6 certificate).
- **Second filer** (tier-2 convention check, different filer from the first): the Lyman brief. It shows the Certificate of Digital Submission (citing 10th Cir. R. 25.5 and FRAP 25(a)(5)) and a Certificate of Service, which the template produces when `digital_submission: true`. It is not transcribed; the template's digital-submission branch was tested on a temporary transcription of the Oliver sample, not committed.
- Neither exemplar is a sealed or non-public filing. Both are public records.

## Not used

- Other reply briefs found in the same search (Muscogee (Creek) Nation, Osage Nation, Astro Companies, Frankspeech LLC/Lindell, Susan DeHerrera/Jose Guerrero) have hosted PDFs and are reply briefs in this court, but were not downloaded: the eval loop asks for two or three exemplars from different filers, and two are enough to judge the tier-2 conventions this template covers.
