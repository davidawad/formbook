# PTAB: patent owner response (IPR)

Doc type `patent-owner-response` of court `ptab`. Self-contained folder, like `../petition/`.

BLOCKED: no exemplar

No public, text-based PDF of a filed patent owner response in an IPR could be found. The searches run on 2026-10-14 are recorded in `exemplars/SOURCE.md`. Without an exemplar there is no sample to transcribe, so there is no `samples/` output, no overlay, and no Gate 2 review for this doc type.

What exists: a template built from the rules, `typst/ptab-patent-owner-response.typ` with `typst/main.typ`. It is the petition template with the response wording and word-limit citation, and it has been compiled once in a scratch copy with the petition sample as input (the build succeeds; that output is not a response and is not committed).

| Item | Status |
|---|---|
| exemplar | no (see `exemplars/SOURCE.md`) |
| render | fail: not run, no sample. The template uses 14-point Times New Roman, which is not vendored (same blocker as `../petition/`). |
| overlay | fail: not run, no render |
| pages reviewed | 0 |

## Governing rules

Verified at Cornell LII on 2026-10-14 (https://www.law.cornell.edu/cfr/text/37/42.120 and /42.24 and /42.6).

| ID | Requirement | Source | Template |
|---|---|---|---|
| PTAB-POR-FORM-001 to -004 | Same format as the petition: 8½ × 11 in; 14-point Times New Roman; double spacing; margins at least 1 inch | 37 C.F.R. § 42.6(a)(1), (a)(2)(i)–(iv) | same constants as the petition |
| PTAB-POR-LEN-001 | Patent owner response word count is the same as the petition's (14,000 words for an IPR) | § 42.24(b)(2) (text verified: "The word counts for a patent owner response to petition are the same as the word counts for the petition"); the exclusions in § 42.24(b) and (a) apply | `response-word-limit` = 14000; the build fails over the limit |
| PTAB-POR-FORM-008 | Certification of word count | § 42.24(d) | `certificate-of-word-count`, cites § 42.24(b)(2) |
| PTAB-POR-FORM-009 | Certificate of service with date, manner and each person served | § 42.6(e)(4)(i), (iii). The response is served on the petitioner under § 42.6(e); § 42.105(a), which the petition cites, applies to the petition | `certificate-of-service`, cites § 42.6(e) only |
| PTAB-POR-TIME-001 | Due date: the Board order sets it; if none does, three months from institution | § 42.120(b) (text verified) | not generated: a timing check, for the filing calendar |
| PTAB-POR-SCOPE-001 | One response to the petition and/or decision on institution, filed as an opposition under the § 42.24 page limits | § 42.120(a) (text verified) | content, not generated |

Not verified because no exemplar was read: the response's required sections (responses to each ground and claim, claim construction, the declaration exhibits), any heading convention, and whether a response carries mandatory notices. The template does not generate any of these, and the sample metadata does not exist yet.

## What is needed to finish this doc type

1. One filed patent owner response (text-based PDF, different filer from any future exemplar) saved as `exemplars/FILED-EXAMPLE-<short-case>-<IPR-number>-patent-owner-response.pdf`, with its source recorded in `exemplars/SOURCE.md`.
2. A markdown transcription in `samples/<id>.md` (follow `../petition/README.md`, "Markdown contract").
3. Vendor the Times-metric font (the petition blocker), then `sh tools/render.sh courts/federal-circuit/patent-trial-and-appeal-board/patent-owner-response samples/<id>.md` and `sh tools/overlay.sh … <id>`.
4. Review every page; record the review here.

## Gaps

- No exemplar; nothing in this folder is checked against a filed document.
- The word-limit check is only the limit itself; the response's count is author-supplied, like the petition's.
- The template is the petition template with the response wording. Its cover text and headings are the petition's; they may need changes once a real response is in hand.

Searches are listed in `exemplars/SOURCE.md`.
