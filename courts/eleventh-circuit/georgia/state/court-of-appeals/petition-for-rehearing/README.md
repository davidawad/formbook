# Georgia Court of Appeals (gactapp): petition-for-rehearing

Doc type: Georgia has no petition for rehearing; the closest real type is the **motion for reconsideration** (Rule 37). Exemplar: **yes** (`exemplars/FILED-EXAMPLE-sierra-club-v-psc-A21A1129-petition-for-rehearing.pdf`, Appellant's Motion for Reconsideration with its Brief in Support, *Sierra Club, Inc. v. Georgia Public Service Commission*, No. A21A1129, filed November 3, 2021 by Robert B. Jackson, IV, LLC and Sierra Club, Inc.; source in `exemplars/SOURCE.md`). Nothing here sets a `court.json` status.

## Status

| Item | Result |
|---|---|
| `exemplars/` | 1 filing, text PDF, 15 pages: the motion (pages 1-2), its certificate of service (3), then the brief in support (4-15), each with its own cover; court e-filing stamp "Case A21A1129 Filed 11/03/2021" on every page |
| `samples/INPUT-rehearing-sample.md` | transcription of the whole brief in support (filed pages 4-15). The two-page motion itself is not transcribed: it is a short request that refers to the brief. Id kept for the existing docx outputs |
| render | ok: `samples/OUTPUT-rehearing-sample.pdf`, 11 pages, exit 0, no warnings, Liberation Serif embedded |
| overlay | ok: `samples/OVERLAY-rehearing-sample.pdf` / `.txt` |
| pages reviewed | 11 of 11 at 60 dpi, plus the 15 exemplar pages |

## Governing rules (primary source, read 2026-10-16)

Rules effective March 26, 2026 (URL and archive copy as in `../motion-brief/README.md`). Rule 37 (a): motions for reconsideration are prepared in accordance with Rule 24, limited to 4,200 words, with the certification "This submission does not exceed the word count limit imposed by Rule 24." just above the signature block. 37 (b): filed within 10 days of the judgment, by 4:30 p.m.; 37 (d): second motion only with permission; 37 (e): grounds (overlooked material fact, statute or controlling decision, or erroneous construction of law); 37 (h): no oral argument. Rule 24 (g): no attachments. Form rules (2 (c), 24 (c), (e)), signature (2 (a) (2) (ii)) and service (6) as in the motion-brief README. Deadline, second-motion and grounds rules are not enforced by the template (filer's job).

## Overlay page map

Ours 1-8 with filed 4-11 (cover 93%, body 45-86%), ours 9-10 with filed 13 (conclusion), ours 11 with filed 15 (certificate of service, 89%). The filed brief's signature page (14) pairs with none of ours because our signature sits under the conclusion on page 10.

## Gate 2 review (11 of 11 pages)

| Page | Finding |
|---|---|
| 1 | Cover: "IN THE COURT OF APPEALS STATE OF GEORGIA", Case No. A21A1129, three-party caption (Appellant, Appellee, Intervenor-Appellee, joined by "v." and "&"), title, counsel. OK |
| 2-3 | Opening paragraph, Argument, the Order's four numbered findings as a single-spaced block quote. OK |
| 4-6 | Argument text, heading I (bold, single spaced), the filer's bold passage kept bold. OK |
| 7 | *Stein* block quotation. OK |
| 8-9 | Heading II, numbered list "1)" / "2)", Conclusion. OK |
| 10 | Conclusion end, Rule 24 certification, date, underlined "/s/ Robert Jackson" with the name below and both counsel's lines. OK; the second counsel's "/s/ Dorothy Jaffe" is a plain line, not underlined (contract limit, see Gaps) |
| 11 | Certificate of service (Rule 6 (b) (2) prior-agreement wording), two recipient blocks, "SO CERTIFIED", signature. OK |

## What changed

`typst/gactapp-petition-for-rehearing.typ` is the motion template (`../motion-brief/README.md`, "What changed") with the Rule 37 references: separate cover page by default, the Rule 24 certification in the rule's wording (the old template printed its own word-count sentence), underlined conformed signature, certificate of service from `paragraphs` / `recipients` / `closing`, 14 pt headings, optional contents and authorities. Sample replaced by the transcription.

## Gaps

1. Word count (4,200) not computed.
2. A second signer's conformed signature is not underlined (the contract has one `signer_line`).
3. The filer's motion and brief are two documents in one PDF; the template renders one document per sample.
4. docx: **not regenerated** (no `soffice` here); outputs are renders of the old synthetic sample with the old certificate wording. Open docx items as in `../motion-brief/README.md`.
