# Exemplar source

- File: `FILED-EXAMPLE-motion-brief.pdf` (20 pages; sha256 `0aebccd34bd13884de94a7166e3e196e94cb1326cfa39d02ac5707ac7e4f7e1e`)
- Court: United States Bankruptcy Court, Southern District of Illinois (Effingham Division, per the caption of Doc 18 on the same docket; the attachment itself has no caption)
- Case: *Gargula v. Deighan Law LLC, et al.* (Nancy J. Gargula, United States Trustee, v. Deighan Law LLC f/k/a Law Solutions Chicago LLC d/b/a UpRight Law LLC and James E. Ford), Adversary No. 20-06018-lkg, in the Chapter 7 case *In re Burns*, No. 19-60349
- Document: Memorandum in Support of Motion to Withdraw (Doc 15-1), an attachment to the defendants' Motion to Withdraw the Reference (Doc 15, not fetched). A brief supporting a motion, the doc type of this folder. Text layer: yes (Times family, Times-Italic for case names).
- Filer: Defendants Deighan Law LLC and James E. Ford, by Mark T. Lavery (signing, counsel for defendants) and Charles A. Armgardt (of counsel, Deighan Law LLC)
- Date filed: 2021-04-12 (ECF header on every page: "Filed 04/12/21")
- Fetched from: https://storage.courtlistener.com/recap/gov.uscourts.ilsb.189476/gov.uscourts.ilsb.189476.15.1_1.pdf (CourtListener RECAP; docket page https://www.courtlistener.com/docket/27332661/gargula-v-deighan-law-llc/)
- Date fetched: 2026-10-14
- Public court record (RECAP, `is_available: true`). Used as the layout reference for this folder.

## What is transcribed

`usage/INPUT-motion-brief.md` transcribes:

- pages 1 to 10 of the filing, through Argument V.A.3 (footnotes 1 to 29, all of which sit on those pages; footnote 1 is moved from the title to the first sentence of the body, because the template's title is plain text);
- the Conclusion and the signature block (pages 19 and 20).

Pages 10 (from Argument V.A.4) to 19 (the end of Part V.C) are not transcribed. The sample says so in a visible note before the Conclusion. Footnotes 30 to 38 sit on those pages and are omitted with them.

The rendered sample is 10 pages (`usage/OUTPUT-motion-brief.typst.pdf`).

## Gaps between the transcription and the filing

- **Caption.** The attachment's first page has no caption; it opens with the title. The caption in the sample (`In re:` block, Case No. 19-60349, Chapter 7, Adversary No. 20-06018, and the Effingham Division) is copied from Doc 18 of the same docket (the United States Trustee's objection to the motion to withdraw, filed 04/26/21, which carries the caption of this adversary). The overlay's page 1 caption block is therefore template-only. Nothing in the caption is invented.
- **Certificate of service.** The filing has none (the attachment ends with the signature block). The sample has no `service` block, so the template generates no certificate.
- **Attorney block.** The filing gives no state bar number (L.R. 9011(A) asks for one in the attorney block). The sample reproduces the filing and adds none. The template's attorney block has no bar-number line either.
- **Italics.** The filing italicizes case names and *Id.* The sample is plain text.
- **Date label.** The filing reads "Date:"; the template reads "Dated:" (its fixed label).
- **Typeface.** The filing is Times New Roman; the template is EB Garamond (the only vendored serif family, see ../README.md).
- **ECF header.** The filing's "Case 20-06018-lkg Doc 15-1 Filed 04/12/21 Page x of 20" header is not reproduced.

## Searches tried (2026-10-14)

CourtListener search API (`https://www.courtlistener.com/api/rest/v4/search/`, `type=r`, `court=ilsb`, `available_only=on`; the RECAP documents endpoint needs a token, the search endpoint does not), with the description, page count and `filepath_local` of every hit checked:

| Query | Result |
|---|---|
| `"brief in support of motion"` | Opinions, and the 2010 Naumann brief below. |
| `"memorandum in support" "motion to dismiss"` | Gargula v. Deighan Law LLC, Adv. 20-06018 Doc 15-1 (this exemplar). |
| `"brief in support" "adversary" "motion to dismiss"` | Gateway Wireless and ACJK opinions; no brief available. |
| `"Brief in Support of Motion to Dismiss"` | Bevelot opinion only. |
| `Gargula Deighan` (all docket numbers) | Complaints, answers, the UST's objections (Adv. 20-06008 Doc 43; Adv. 20-06018 Doc 18; Adv. 21-03005 Doc 6), and this memorandum. |
| `memorandum support motion` for each Gargula adversary docket (20-06018, 21-03005, 20-03052, 20-06008) | 20-06018: Doc 15-1 (memorandum) and Doc 18 (UST's objection). 21-03005: Doc 6 (UST's objection). 20-03052: Doc 1, Doc 4 and Doc 16 (complaint, summons, answer); no brief. |

Earlier in the search, the brief said to be on PACER (Gargula 20-03052, Doc 5, attachment 1) did not come back as available. The 20-03052 docket returned only the complaint, summons and answer. The govinfo file USCOURTS-ilsb-3_20-ap-03039 is an opinion, not a brief.

Web search (standard and extended): "Southern District of Illinois bankruptcy adversary brief in support motion to dismiss" and similar. Results: opinions, docket calendars and the court's guides. No brief PDF.

## Second filer (not saved)

The tier-2 comparison wants a second filer. The only other available brief in this court is:

- *In re Naumann*, No. 09-32092 (Bankr. S.D. Ill., Chapter 13), Doc 35: "Brief in Support of Shell Community Federal Credit Union's Objection to Confirmation of Plan", 7 pages, filed 03/01/10, filer Shell Community Federal Credit Union (signed by Paul H. Lauber). Caption present. Source: https://storage.courtlistener.com/recap/gov.uscourts.ilsb.139952.35.0.pdf. It supports an objection to confirmation, not a motion, so it is not kept as the exemplar for this doc type. It is a candidate for the second filer if the tier-2 review needs one.

## What would settle it further

A second text-based brief supporting a motion (for example, a brief supporting a motion to dismiss) from a different filer, with its own caption, would settle the caption and the tier-2 comparison.
