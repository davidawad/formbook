# Exemplar source

**BLOCKED: no exemplar.** No filed motion with a memorandum of points and authorities, in the Central District of California bankruptcy court, was found as a text-based public PDF. No file is saved here. The template is built from the rules (see `../README.md`); the sample is synthetic.

## Searches tried (2026-10-14)

- WebSearch: C.D. Cal. bankruptcy "memorandum of points and authorities" with "LBR 9013-1" and "Chapter 7 trustee". Returned court notice forms (F 9013-1.2 notice of no hearing; LBR 9013-1(o) notices) and a Rule 9019 docket line. No motion text.
- WebSearch: "NOTICE OF MOTION AND MOTION" "MEMORANDUM OF POINTS AND AUTHORITIES" "Chapter 11 trustee" "Santa Ana Division" (standard and extended). Returned inforuptcy docket pages (no PDFs) and a Santa Ana Chapter 7 trustee motion (AB Capital, 8:22-bk-11585), not opened.
- WebSearch: gov.uscourts.cacb (CourtListener RECAP) with motion and memorandum terms. No CourtListener pages returned.
- WebSearch: Marshack Hays / Litigation Practice Group motion with memorandum (casedocs.omniagentsolutions.com). Returned an order (Doc 2632, June 11, 2026: order approving stipulation continuing the hearing on United Partnerships' administrative claim motion, Dk. 671) and a stipulation reference (Dk. 2587, 2630). The motion itself (Dk. 671) is not among the results; the trustee's opposition was due October 15, 2026.
- WebSearch: cacb.uscourts.gov notice-of-sales with memorandum terms. Returned sale-motion URLs (RS14-17941MJ, ND-24-10606-MB, RS-24-13864-RB, RS-23-10011-RB). Three were fetched and returned HTTP 404 or no text; RS14-17941MJ returned HTTP 404.
- WebFetch: cacb.uscourts.gov/rules returned HTTP 404.
- Fetched and read, not used as exemplars:
  - `about.ag/pics/bk/656.pdf` and `692.pdf` (Tulving Company, 8:14-bk-11492-ES, Chapter 7 trustee's notice of motion and motion for cash disbursements, form F 2016-2.2, 2017). A court-approved optional form with exhibits; it carries no memorandum of points and authorities. Not the doc type.
  - `about.ag/pics/bk/583.pdf` (Tulving, 2016): a declaration under LBR 9013-1(o)(3) on the court form. Not a motion.
  - `ecf-ciao.cacb.uscourts.gov/kioskPDF/ER_051723.pdf`: a hearing calendar (Judge Robles, May 17, 2023) listing a trustee's turnover motion with a memorandum (Doc 181). The calendar describes the motion; the motion is not in the PDF.
  - `govinfo.gov/.../USCOURTS-cacb-1_12-bk-10986-2.pdf`: a memorandum decision on a chapter 7 trustee's sale motion (San Fernando Valley, case 1:12-bk-10986-MB), not a motion.
- Not reachable from this box: CourtListener (direct), PACER, the court's full docket.

## What would settle it

A text-layer PDF of a C.D. Cal. bankruptcy motion with a memorandum, from a different filer than the trustee's own form (e.g., a debtor's or creditor's motion). The overlay (`tools/overlay.sh`) needs one `exemplars/*.pdf` to run.
