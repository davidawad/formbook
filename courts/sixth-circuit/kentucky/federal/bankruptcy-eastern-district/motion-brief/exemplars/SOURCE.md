# Exemplar source: motion with memorandum (E.D. Ky. bankruptcy)

One filed exemplar, found 2026-10-15 on CourtListener RECAP. It is a public court record. Only one filer is saved so far; EVAL-LOOP asks for two or three from different filers before tier 2 can be judged (see the README, gap 1).

## 1. `FILED-EXAMPLE-williams-24-60490-motion-brief.pdf` (8 pages, text layer present)

- File URL (fetched): https://storage.courtlistener.com/recap/gov.uscourts.kyeb.330792/gov.uscourts.kyeb.330792.36.0.pdf
- Docket page: https://www.courtlistener.com/docket/68564913/36/michael-jason-williams/ (CourtListener docket 68564913, entry 36)
- Court: United States Bankruptcy Court, Eastern District of Kentucky, London Division
- Case: *In re Michael Jason Williams*, Chapter 11, Case No. 24-60490 (Judge Gregory R. Schaaf); caption also reads "aka Jason Williams, aka Michael J. Williams"
- Document: Motion for Relief from Automatic Stay of Property Known as a 2023 Harley-Davidson FLHRXS Road King SPE, with the memorandum in support (Doc 36). Pages 1 to 4 are the motion, memorandum, NOTICE and certificate of service, and are what the sample transcribes. Pages 5 to 8 are a mailing matrix (labels), which is not part of the motion and is not transcribed.
- Filer: Harley-Davidson dba Eaglemark Savings Bank (movant); counsel Molly Slutsky Simons (Sottile & Barile, Attorneys at Law, Loveland, OH)
- Date filed: September 11, 2024 (ECF header "Filed 09/11/24 Entered 09/11/24 11:27:19"; the motion's certificate of service is dated September 11, 2024)
- Date fetched: 2026-10-15
- sha256: `e24967f0cedfcf9e2738018e0306397b24352bbd10b1eb74617b577c6a0f362d` (220940 bytes)
- Text layer: present (`pdftotext` returns it). Body text is embedded Times New Roman; the ECF header is Liberation Sans. The PDF was produced with Nitro Pro and then iText (`pdfinfo`), so it is a re-saved copy, not the filer's original file.
- How it was found: CourtListener search API (v4), `type=r`, `court=kyeb`, query "Eaglemark" and "memorandum in support" (no API key; anonymous requests worked from this box on 2026-10-15). The RECAP copy is on the CourtListener storage host, so no PACER fee applies.

## 2. Candidate for a second exemplar (not saved)

The EVAL-LOOP tier-2 rule needs a second filer. The strongest candidate found is a motion from a different filer, but it has no separate memorandum section, so it does not match this doc type as closely:

- Wells Fargo Bank, N.A., Motion for Relief from the Automatic Stay and for Abandonment (3 Broad Street, Van Lear, KY), Case No. 18-70393 (Pikeville Division), Doc 12, filed 08/21/2018. Counsel Joel K. Jensen (Lerner, Sampson & Rothfuss). Text layer present, 33 pages including an Exhibit A proof of claim with its loan documents. Motion pages are 1 to 5 (numbered paragraphs, "Notice and Opportunity for Hearing", signature). URL: https://storage.courtlistener.com/recap/gov.uscourts.kyeb.298864/gov.uscourts.kyeb.298864.12.0_3.pdf. Docket page: https://www.courtlistener.com/docket/7219995/12/william-charles-polly-jr/

## Searches tried (2026-10-14, before the RECAP find)

- WebSearch (standard and extended): "Eastern District of Kentucky bankruptcy motion to dismiss memorandum pdf" and variants with "Adv. No.", "Desc Main", "MEMORANDUM IN SUPPORT", "Lexington OR London OR Covington OR Frankfort". Results were opinions and orders (for example the Covington adversary 16-2006 and Lexington adversary 16-1040 orders on govinfo, which cite motions and memoranda by ECF number but do not include them), and docket aggregators (PacerMonitor, Inforuptcy) with docket text only.
- govinfo (USCOURTS-kyeb-*): publishes opinions and orders, not party filings. Searched for "MOTION" and "MEMORANDUM IN SUPPORT" with the kyeb prefix; no party motion found.
- Epiq document server (document.epiq11.com, Cambrian Holding 19-51200 and Americore Holdings 19-61608): found an affidavit in support of a stay-relief motion (Cambrian Doc 1273, 3 pages; that is an affidavit, not a motion), a confirmation order (Doc 1542) and an adversary-related complaint (Doc 1800). No motion with a memorandum. A 125-page docket listing (docId 852155) is the plan disclosure, not a docket.
- Search for a motion to dismiss in the Fox v. Biden adversary (22-06032): none found; the trustee's complaint is the only filing located for that adversary.
- CourtListener website (homepage): HTTP 403 to this box on 2026-10-14. (On 2026-10-15 the search API answered, which is how the exemplar above was found; see section 1.)
- PacerMonitor docket pages for Edwards v. Saylor (24-ap-06054) and Spradlin v. 3D Dycus (16-ap-01033): docket text only, no document links.
- Second pass (2026-10-14): WebSearch on "motion for relief from stay" memorandum (only docket pages and opinions); sale free and clear with memorandum (docket pages and an opinion); CourtListener RECAP via WebSearch (no RECAP documents returned); Cambrian 19-51200 with "Lexington Division" (govinfo opinions only); Epiq docId 3867825 (a 73-page confirmation order, not a motion); Cambrian Key-Way motion to compel (no Epiq PDF of the motion); Americore 19-61608 (docket listing and news only); Justia (a Cloudflare challenge page, not a PDF); Sixth Circuit appendix (BAP calendars and judgments only).

Not tried: PACER (requires an account and fees; not used by this box), and the court's own CM/ECF document viewer (login required).
