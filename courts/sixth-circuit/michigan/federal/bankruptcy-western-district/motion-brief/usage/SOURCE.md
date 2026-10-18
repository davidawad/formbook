# Exemplars: motion with brief in support (miwb)

Both are public court records from the W.D. Mich. Bankruptcy Court's CM/ECF docket, as published through RECAP. Fetched 2026-10-14 by a plain HTTPS GET of the storage URL (no login).

| File | Case | Docket | Filer (party, counsel) | Filed | Fetched from |
|---|---|---|---|---|---|
| `SAMPLE-miwb-motion-brief-cluchey2100524.pdf` (7 pp.: motion 2 pp. + brief 5 pp., text layer) | *World Energy Innovations, LLC v. Cluchey* (adversary of Ch. 7 *In re Larry Allen Cluchey*) | Main case 21-00524-jwb; adversary 21-80053; Doc #18 (motion) and #18-1 (brief in support, attachment 1) | Sherry D. Cluchey, Defendant. Counsel: CBH Attorneys & Counselors, PLLC (Steven M. Bylenga, P73492; Andrew R. McInnis, P83626) | 2021-06-14 | Motion: https://storage.courtlistener.com/recap/gov.uscourts.miwb.387866/gov.uscourts.miwb.387866.18.0.pdf ; brief: https://storage.courtlistener.com/recap/gov.uscourts.miwb.387866/gov.uscourts.miwb.387866.18.1.pdf (docket page: https://www.courtlistener.com/docket/59911781/world-energy-innovations-llc-v-cluchey/). The two PDFs were joined in docket order with `pdfunite` for this folder. |
| `SAMPLE-miwb-motion-brief-murtha1006974.pdf` (8 pp., text layer, Acrobat PDFMaker 9) | *Murtha v. Spencer* (adversary of Ch. 7 *In re Debra J. Spencer*) | Main case 10-06974 (swd); adversary 10-80566; Doc #20 | Robert A. Murtha, Plaintiff. Counsel: Maxwell Dunn, PLC (Ethan D. Dunn, P69665) | 2011-07-22 | https://storage.courtlistener.com/recap/gov.uscourts.miwb.267336/gov.uscourts.miwb.267336.20.0.pdf (docket page: https://www.courtlistener.com/docket/43817390/murtha-v-spencer/) |

## Why these two

- Both are a motion with a brief in support in this court (W.D. Mich.), by different filers: a defendant's motion to dismiss in a 2021 Chapter 7 adversary, and a plaintiff's motion for summary disposition in a 2011 Chapter 7 adversary. The Cluchey filing is the primary exemplar (it has the court's current caption pattern: "In re", case number, chapter, adversary number).
- Found by CourtListener search (`court=miwb`, `type=r`, `Brief in Support` / `Motion to Dismiss Adversary Proceeding` descriptions). Other miwb brief entries were not used: Morris v. Charron (15-80086) is a cross-motion for summary judgment with its brief, and the two used filers were enough for tier 2.

## What the exemplars do not show

- The ECF header line ("Case:21-80053-jwb Doc #:18-1 Filed: 06/14/2021 Page 1 of 5") is added by the court on filing. The template does not reproduce it.
- The Cluchey motion is attachment-filed: the brief is docket entry 18-1, separate from the motion (entry 18). The Murtha motion and brief are one PDF.
- No notice of hearing and no certificate of service are in either PDF.
- The Murtha filing states "PLAINTIFF'S MOTION FOR SUMMARY JUDGMENT" in its first title and "PLAINTIFF'S BRIEF IN SUPPORT OF MOTION FOR SUMMARY DISPOSITION" for the brief; the template uses the title given in the sample.
