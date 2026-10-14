# Exemplar source: motion with incorporated memorandum, Bankruptcy Court M.D. La. (lamb)

Exemplar: `FILED-EXAMPLE-kologik-24-10311-motion-brief.pdf`, pages 1-19 of 42 (unaltered pages of the filed PDF).

| Field | Value |
|---|---|
| URL | https://kellyhart.com/pleadings/Filing/10311/PLEADDoc8.pdf (the filer's counsel's copy of the ECF-stamped filing) |
| Court | United States Bankruptcy Court, Middle District of Louisiana |
| Case | *In re Kologik, LLC, et al.*, Chapter 11, Case No. 24-10311 (jointly administered with 24-10312 and 24-10313) |
| Docket | Doc. 8 |
| Document | Debtors' Emergency Motion for Entry of Interim and Final Orders (I) Authorizing Debtors to Utilize Cash Collateral, (II) Granting Adequate Protection to Prepetition Secured Parties, (III) Modifying the Automatic Stay, (IV) Scheduling a Final Hearing, and (V) Granting Related Relief |
| Filer | Debtors Kologik, LLC; Kologik Capital, LLC; Kologik Capital II, LLC, by proposed counsel Kelly Hart Pitre (Louis M. Phillips, #10505; second block: Erin K. Arnold, Amelia L. Hurt, New Orleans) |
| Date filed | 04/23/2024 (ECF stamp "Filed 04/23/24 Entered 04/23/24 15:48:16") |
| Date fetched | 2026-10-14 |
| Local file | `FILED-EXAMPLE-kologik-24-10311-motion-brief.pdf`: pages 1-19 extracted from the 42-page fetched PDF (`pdfseparate` and `pdfunite`, no page changed). SHA-256 of the fetched 42-page file `d2716b3cb128a8982a2b30996b702ac405ac04af323a8b1d84f87b4b445fe909`; of the 19-page file `c17a354c04d90297db846271de08a2ca3855b99098336d6735e8aecae1b5e116`. Restored 2026-10-14: the PDF was missing from the tree, so the overlay could not run. |
| Pages kept | 1-19 (the motion, its Basis for Relief, Conclusion and signature). Pages 20-42 of Doc. 8 (the proposed Interim Order and Final Order) are not in the exemplar. |
| Text | Text-based PDF (`pdftotext` extracts the full text). |

## Why it is this doc type

The motion carries its own argument: "BASIS FOR RELIEF" (¶¶ 17-41, pp. 9-18) sets out the statute, the adequate-protection and carve-out authorities, and the interim-relief argument under sub-headings A-D. No separate memorandum is filed. That matches the "motion with incorporated memorandum" that LR 9013-2 describes.

Differences the overlay will show, all in the filing itself: no LR 9013-1(b)(2) notice of hearing (the filing is an emergency motion; the template's notice paragraph is therefore filled with placeholders); a three-column Material Terms table on pp. 2-5 that is single-spaced; footnotes 1-9; a second counsel block that the template does not print.

## Searches

| Source | Result |
|---|---|
| WebSearch, Middle District bankruptcy motion or memorandum queries (about 4 rounds) | Returned the court's blank motion form (`Motion (Blank).pdf`), the 2022 local rules, the notice-of-hearing form, and inforuptcy.com docket pages. No filed motion PDF from this court, apart from the Kologik pleadings below. |
| `kellyhart.com/pleadings/Filing/10311/PLEADDoc1.pdf` to `PLEADDoc12.pdf` (Kelly Hart's copies of the Kologik first-day papers, all M.D. La., all text-based) | Docs 1-3 are petition papers; Doc 4 is an emergency motion for joint administration (10 pp.); Doc 5 is an emergency motion limiting notice (7 pp. of motion, then an exhibit); Docs 6, 7, 8, 9, 11 are emergency motions with interim and final proposed orders (cash management, wages, cash collateral, adequate assurance, prepetition claims); Doc 10 is a compensation motion; Doc 12 is a retention application. Docs 4-9, 11 and 12 contain a "BASIS FOR RELIEF" section, so several would have served; Doc 8 was chosen because its argued section is the longest (19 pp. of motion, sub-sections A-D, a table, nine footnotes, a block quotation), which exercises more of the template. |
| govinfo, `USCOURTS-lamb-3_23-ap-01002` (*Foster v. Capital City Credit*, Adv. 23-1002) and `USCOURTS-lamb-3_18-ap-01025` (*Schott v. Massengale*, Adv. 18-1025) | Court opinions (memorandum opinion; proposed findings and conclusions), not motions. Not used. The `-1` and `-2` attachment URLs are not PDFs. |
| CourtListener RECAP | Not reachable from this box (HTTP 403 / timeouts). |
| The court's site `lamb.uscourts.gov` | Direct requests refused; the blank motion form and local rules were read through WebFetch. |

## Governing text used with it

- Local Rules of the Bankruptcy Court, M.D. La., amended January 1, 2022: https://www.lamb.uscourts.gov/sites/lamb/files/2022_Local_Rules.pdf (rules 5005-2, 9013-1, 9013-2, 9013-4, 9013-5). The filing was made in 2024, so its local-rule citations (LR 9013-3(d)(3), 4001) reflect the rules then in force; the template follows the 2022 text.

## Transcription

`../samples/INPUT-motion-brief-sample.md` transcribes exemplar pp. 1-19 in full, including the Material Terms table, all nine footnotes, the block quotation of 11 U.S.C. § 363(c)(2) and the signature block. Changes from the filed text, all for layout or for the template's frontmatter:

- The footnote 3 marker (UCC-1 caveat) is attached in ¶ 7 instead of inside the table cell (a typst footnote inside a table cell printed the footnote on the wrong page). The footnote text is unchanged.
- The table cell text for the adequate-protection and carve-out rows keeps the filed sub-items (a.-c., A.-B., (A)-(B)) as run-in text, not as separate lines.
- The caption's "(Joint Administration Requested)" and the "Case No." block are not in the template's caption; they are not transcribed as caption text.
- The notice of hearing, the hearing placeholders, and the second counsel block are not in the filing (the first is supplied by the template; the second is omitted).

## To replace

If a filed M.D. La. motion with a longer incorporated memorandum (for example a contested motion with a notice of hearing under LR 9013-1(b)(2)) turns up in a public source, save it here alongside this file and re-run the overlay.
