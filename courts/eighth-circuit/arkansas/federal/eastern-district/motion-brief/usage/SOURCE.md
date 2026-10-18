# Exemplar source

- File: `FILED-EXAMPLE-motion-brief.pdf`
- Court: United States District Court, Eastern District of Arkansas, Central Division
- Case: *Campbell v. Ensurety Ventures, LLC d/b/a Omega Auto Care*
- Docket: No. 4:26-CV-387-LPR (Document 10)
- Document: "Defendant's Brief in Support of its Motion to Dismiss" (8 pages), Fed. R. Civ. P. 12(b)(6), TCPA (47 U.S.C. § 227)
- Filer: Defendant Ensurety Ventures, LLC, by counsel Niki T. Cung, Kutak Rock LLP (Fayetteville, AR)
- Date filed: 2026-06-15 (stamped "Filed 06/15/26" on every page)
- Fetched from: https://storage.courtlistener.com/recap/gov.uscourts.ared.152256/gov.uscourts.ared.152256.10.0.pdf (CourtListener RECAP; docket https://www.courtlistener.com/docket/73213278/)
- Date fetched: 2026-10-14
- Text layer: yes. `pdftotext` yields clean text; Times New Roman embedded (Word export, re-saved through iText).
- Public court record (RECAP). Used as a structural reference only.

Second filer: not collected. The brief asks for one exemplar per doc type, so EVAL-LOOP's tier-2 rule (2 or 3 filers) is not met (README.md, gap 1).

Search trail (CourtListener API v4 `search/?type=r&court=ared&available_only=on`):
- Query `"brief in support" "motion to dismiss"`: hits listed, with the document description and page count. Read in full: Campbell (8 pages, chosen). Read in part: Leflar v. HP Inc (4:22-cv-00690, Doc. 11, 22 pages, Times New Roman, Lonoke-to-federal removal, HP's memorandum brief in support of its Rule 12(b)(6) motion). Not chosen: 22 pages, over the sample target; it is the natural second filer (see README.md, gap 1).
- Other hits, not downloaded: Snodgrass v. Progressive (4:24-cv-01133, Doc. 9, 4 pages), Lancaster v. Thurston (2:24-cv-00161, Doc. 10, 10 pages), Cummins v. Gibson (4:23-cv-00425, Doc. 41, 10 pages), Nextgear Capital v. Arkansas Auto Exchange (4:14-cv-00256, Doc. 10, 7 pages).
