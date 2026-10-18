# Exemplar source

- File: `SAMPLE-nmid-motion-brief-imperialpacific24cv00001.pdf` (19 pages; Word 2016 document with embedded TrueType fonts; text layer present: `pdftotext` reads it)
- URL fetched from: https://storage.courtlistener.com/recap/gov.uscourts.nmid.6427/gov.uscourts.nmid.6427.61.1.pdf (CourtListener RECAP; docket https://www.courtlistener.com/docket/68279516/61/1/imperial-pacific-international-cnmi-llc-v-commonwealth-of-the-northern/, found through the CourtListener search API with `court=nmid`)
- Court: United States District Court for the Northern Mariana Islands
- Case: *Imperial Pacific International (CNMI) LLC v. Commonwealth of the Northern Mariana Islands, et al.*
- Docket no.: 1:24-cv-00001 (caption: "CIVIL CASE NO. 1:24-CV-0001"; ECF header: "Case 1:24-cv-00001 Document 61-1 Filed 08/13/24")
- Document: "Memorandum in Support of Its Motion to Dismiss Plaintiff's Second Amended Complaint Pursuant to Federal Rule of Civil Procedure 12(b)(1) and (6)" (ECF 61-1; the motion itself is ECF 61, whose RECAP entry is the docket page above)
- Filer: Defendant Commonwealth of the Northern Mariana Islands, by the Office of the Attorney General (J. Robert Glass, Jr., Assistant Attorney General; signed as Chief Solicitor)
- Date filed: August 13, 2024 (ECF header and signature date)
- Date fetched: 2026-10-14

## Why this one

Searched CourtListener (search API, `court=nmid`, `type=r`) for motions to dismiss with a memorandum in this court. Options with a text layer: this memorandum (2024, Attorney General, 19 pages, Times New Roman, numbered lines, complete TOC, TOA, argument and signature structure); Laramie Fealty LLC v. United Micronesia Development Association (1:08-cv-00028, Doc 4, 2008, motion with memorandum, 24 pages, not fetched, older form); Fanter v. Imperial Pacific (1:20-cv-00003: only the reply, doc 31, appeared in the search results; the motion at doc 11 was not located; not fetched); Imperial Pacific v. Yeom (1:24-cv-00002, Doc 24, 2-page motion, not a memorandum). The brief asks for one exemplar per doc type.

## Caveats

- This is the memorandum; the notice of motion is ECF 61 (not fetched). The template is built for the memorandum, which carries the hearing caption and the notice language on its first page.
- The filing leaves the hearing date and time blank; the template prints the blanks as given (LR 5.2.e requires them on a filed motion; see `../README.md`).
- The filing's text is kept as filed, including its typos (see the README).

## Second filer

Not collected in this pass (see above). EVAL-LOOP's tier-2 rule (2 or 3 filers) is not met; recorded in `../README.md`.
