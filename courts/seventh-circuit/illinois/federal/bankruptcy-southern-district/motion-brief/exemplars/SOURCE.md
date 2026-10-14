# Exemplar source

BLOCKED: no exemplar. No filed brief in support of a motion, from this court, is publicly available as a text PDF.

No file is saved here. The folder is built from the rules (see ../README.md), and `samples/INPUT-generic-motion-brief.md` is fictional.

## Searches tried (2026-10-14)

CourtListener REST search, `type=r` (RECAP documents), `court=ilsb`, with the document description returned for each hit and the `is_available` flag checked:

| Query | Result |
|---|---|
| `"adversary proceeding" complaint` | Complaints and motions only; no brief. |
| `"brief in support" "motion to dismiss"` | Briefs listed as attachments (`# 1 Brief in Support of Motion to Dismiss`), not available. |
| `"Brief/Memorandum"` | Brief entries in main cases (e.g. 98-32246, 14-41167, 12-60237) and adversaries (10-04017, 13-03017, 20-06008, 25-04000). All `is_available: false`. |
| `"Support Brief"` + `Motion` | Same set; e.g. Gargula v. Deighan Law LLC, Adv. 20-03052 doc 5 attachment 1 and Adv. 20-03054 doc 3 attachment 1 (motion to dismiss briefs), and LPB MHC LLC v. Zanotti, Adv. 25-04000 doc 11 (brief supporting motion to dismiss and to compel arbitration). All `is_available: false`. |
| `"Brief in Support"` (court=ilsb) | Opinions that cite the motions, and an unavailable brief. |
| `"Memorandum of Law" "Adversary"` | Opinions only. |

Where the search results give a `recap_documents` entry with a `filepath_local`, the document is downloadable. Every brief entry above had `filepath_local: null`, so no brief PDF could be fetched. The RECAP documents API (`/api/rest/v4/recap-documents/`) requires an authenticated token and returned "Authentication credentials were not provided."

Web search (standard mode): "Southern District of Illinois bankruptcy adversary brief in support motion to dismiss pdf", "Bankruptcy Court for the Southern District of Illinois motion memorandum of law PDF RECAP docket". Results: court docket PDFs (calendars, no filings), the court's administrative guide, and courtrules.net's copy of L.R. 9013-5. No brief PDF.

Court website: the local rules PDF (`LocalRules-BkSoDistrict_12-01-15.pdf`), the Electronic Filing Rules (Sept. 2021), the Style Guide and the Administrative Guide (March 19, 2026) were read. None sets a typeface, a type size or margins for briefs. The style guide concerns CM/ECF docket-entry style, not documents.

## What would settle it

A copy of any brief in support of a motion to dismiss filed in an S.D. Ill. adversary proceeding, text-based PDF, public record. For example, Gargula v. Deighan Law LLC, Adv. No. 20-03052-lkg, Doc 5, attachment 1 (Brief in Support), available on PACER. A second filer is needed for the tier-2 check (two or three exemplars from different filers). Until one is supplied, the tier-2 review is not possible.
