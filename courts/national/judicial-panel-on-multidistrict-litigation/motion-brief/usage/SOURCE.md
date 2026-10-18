# Exemplar source

## 1. `SAMPLE-jpml-motion-brief-chevroletboltbattery20cv07109.pdf` (primary; used for the overlay and the sample)

- URL fetched from: https://chimicles.com/wp-content/uploads/2021/01/In-re-Chevrolet-Bolt-Battery-MDL-Filing.pdf
- Court: Judicial Panel on Multidistrict Litigation (heading "Before the United States Judicial Panel on Multidistrict Litigation"); MDL number blank on the filing ("MDL No. __________"), so none was assigned as of the filing.
- Case: *In re Chevrolet Bolt Battery Litigation*. Underlying action whose plaintiffs move: *Torres v. General Motors LLC*, No. 1:20-cv-07109 (N.D. Ill.).
- Docket no.: none on the filing (MDL blank). Action docket: 1:20-cv-07109.
- Filer: Moving Plaintiffs in *Torres* (Andres Torres, Thomas Whittaker, Carol Whittaker, Mary Elizabeth McQuarrie, DeShawn Dickinson, Greg Field, Joseph Poletti, James Kotchmar, Robert Allen), by Chimicles Schwartz Kriner & Donaldson-Smith LLP, Wittels McInturff Palikovic, and Bardo Law, P.C.
- Documents in the file: Motion for Transfer of Actions Pursuant to 28 U.S.C. § 1407 (pp. 1–2); Memorandum of Law in Support (cover p. 3, table of contents p. 4, table of authorities pp. 5–7, body pp. 8–24, body numbered 1–17); Certificate of Service (p. 25). The compilation runs to 387 pages.
- What is kept: pp. 1–25 of the 387-page compilation. Pp. 26–387 (the Schedule of Actions and the complaints and docket sheets required by JPML Rule 6.1(b)(ii) and (iv)) are omitted for size. They are concurrent filings, not part of the motion or memorandum.
- Date filed: January 22, 2021 (the "DATED" line on the motion and memorandum; no ECF header on this copy).
- Date fetched: 2026-10-14.
- Text layer: present. `pdffonts` shows embedded Times (Type 1C and CID TrueType), and `pdftotext` reads it.

Why this one: the only text-based, public JPML filing found that is a complete § 1407 motion with its memorandum (motion, cover, TOC, TOA, memorandum body with footnotes, signature, certificate). Searched for a motion with a text layer; this one is the best match.

## 2. `SAMPLE-jpml-motion-brief-usplabsdietarysupplementmdl2523.pdf` (second exemplar; motion only)

- URL fetched from: https://www.thesenatorsfirm.com/wp-content/uploads/2023/07/USP-Labs-Motion-1.pdf (a copy hosted by a law firm; the filing itself is a public JPML record)
- Court: Judicial Panel on Multidistrict Litigation.
- Case: *In re USPlabs Dietary Supplement Litigation*, MDL No. 2523. Underlying action: *Battuello v. USPlabs, LLC*, No. 2:13-cv-04101-NIQA (E.D. Pa.).
- Filer: USPlabs, LLC (defendant), a different filer from exemplar 1.
- Document: Motion of Defendant USPlabs, LLC for Transfer of Actions to the Eastern District of Pennsylvania Pursuant to 28 U.S.C. § 1407. The accompanying Brief in Support is not in this file. Three pages. The motion refers to its brief, which is not in the file.
- Date filed: 01/13/2014 (from the ECF header "Case MDL No. 2523 Document 1 Filed 01/13/14 Page 1 of 3").
- Date fetched: 2026-10-14.
- Text layer: present.

Why this one: a second filer, for the caption and the numbered-paragraph form of a motion. It is not used for the sample or the overlay; the overlay tool compares one exemplar per run (exemplar 1, the default).

## Searches tried

- WebSearch, JPML Rules of Procedure, Rule 6.2 and form-of-papers text: results were secondary sources and older rule editions. The current rules were found through the JPML's own PDF, cited below.
- WebFetch of https://www.jpml.uscourts.gov/ pages and the rules PDF: HTTP 404 from this box through WebFetch and curl for the paths tried. The current rules PDF was found by search (https://www.jpml.uscourts.gov/sites/jpml/files/Panel%20Rules%20Effective%202-19-2026.pdf), WebFetch returned it as binary, and its text was extracted locally with `pdftotext`. The rules text used in `../README.md` is from that PDF: "Rules of Procedure of the United States Judicial Panel on Multidistrict Litigation (Effective February 19, 2026)".
- CourtListener (https://www.courtlistener.com/?court=jpml): HTTP 403 from this box. Not usable here.
- WebSearch, JPML pro se forms and filed § 1407 motions: returned the JPML pro se motion and memorandum forms (not used; they are fill-in forms, not a filed brief) and several filings, of which the two above were downloaded and checked for text layers.
- Docketalarm Baby Food MDL (2997) pages (returned by WebSearch): not fetched; the Bolt filing was the one downloaded and used.
