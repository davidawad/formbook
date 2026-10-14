# txed: motion to dismiss with memorandum (Rule 12(b)(6))

Doc type: **motion-brief** (a Rule 12(b)(6) motion to dismiss, with its memorandum) in the United States District Court for the Eastern District of Texas (`txed`).
Folder: `courts/fifth-circuit/texas/federal/eastern-district/motion-brief/`.

BLOCKED: no exemplar. A real search (eight queries and downloads, logged in `exemplars/SOURCE.md`) found no downloadable filed E.D. Tex. Rule 12(b)(6) motion. The template was built from the rules instead, as the brief directs.

| Item | Status |
|---|---|
| exemplar | no (BLOCKED: no exemplar; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-generic-motion-to-dismiss.md`: fictional, not transcribed from any filing (every name, number and citation is made up, except *Ashcroft v. Iqbal*, 556 U.S. 662, 678 (2009), which is cited for the standard) |
| render | ok: `samples/OUTPUT-generic-motion-to-dismiss.pdf`, 4 pages, typst 0.15.0 via `tools/render.sh`, vendored EB Garamond only, no warnings |
| overlay | fail: `tools/overlay.sh` exits 1 ("no exemplar pdf in exemplars"). Not run against a filing, so no `OVERLAY-*` file exists. |
| pages reviewed | 4 of 4 (every page rendered at 60 dpi and viewed after the last template change) |
| checks | the statement-of-issues check and the 30-page check were each tested with a mutant sample: a sample without the statement heading fails the build (exit 1); a 31+ page sample fails the build (exit 1). The mutants were deleted afterward. |

## Governing rules

Primary sources. Verified 2026-10-14 against the same E.D. Tex. Local Rules copy as the complaint folder (https://www.txed.uscourts.gov/sites/default/files/LocalRules.pdf, headed "as of [December 1, 2018]"; see `../complaint/README.md` for the version caveat, which applies here too).

| Rule | Requirement | Where it is in the template |
|---|---|---|
| CV-10(a)(1) | Endorsed with the style and number of the action. | `court`, `case_number`. |
| CV-10(a)(2) | Caption with the filer's name and designation, and the character of the document (the example is "Defendant John Doe's Motion to Dismiss under Rule 12(b)(6)"). | `caption`; `brief_title` (the sample supplies the whole title). |
| CV-10(a)(3) | Signed by the lead attorney or with his or her permission. | `signature` block. |
| CV-10(a)(4) and (5) | 8 1/2 by 11 inch paper; double spaced; font no smaller than 12-point. | `page-w`, `page-h`; `body-leading` (1.47 em, a 27.6 pt pitch, the same grid as the complaint); `type-size = 13pt`. |
| CV-7(a) | Each motion is a separate document, with a separate proposed order (searchable PDF, no copy-blocking security). | The motion is one document. The proposed order is not produced (a separate file; see Known gaps). |
| CV-7(a)(1) | A case dispositive motion (a motion to dismiss is one) states the issues to be decided by the court; not to exceed 30 pages, excluding attachments. | The template panics if the body has no "Statement of the Issue" heading; it panics if the document exceeds 30 pages (`counter(page).final()`). Both tested with mutants (see above). |
| CV-5(c) | A certificate of service indicates the date and the method of service (Fed. R. Civ. P. 5(d)). | `service` frontmatter (`date`, `method`), generated as "CERTIFICATE OF SERVICE". |
| CV-7(h), (i) | The "meet and confer" and certificate of conference rules. The exceptions in CV-7(h)/(i) include a motion "to dismiss", so no certificate of conference is generated for this motion. | Not produced (deliberately). |
| Fed. R. Civ. P. 12(b)(6) | Failure to state a claim upon which relief can be granted may be raised by motion. Fetched from https://www.law.cornell.edu/rules/frcp/rule_12 (text carries "Apr. 2, 2024, eff. Dec. 1, 2024"). | The defense named in the motion title. |
| Fed. R. Civ. P. 10(a) | Caption (court, title, file number, parties). Fetched from https://www.law.cornell.edu/rules/frcp/rule_10. | `court`, `caption`, `case_number`. |

Not verified, and not used: the judge-specific standing orders on page limits, and any E.D. Tex. rule on tables of contents or authorities for motions. CV-7(d) (the table-of-contents rule for documents over ten pages) is written for civil-rights complaints and their responsive pleadings only, so the template does not produce a table of contents or authorities for this doc type.

## Layout

- Letter, 1 inch margins, page numbers centered in the footer (11 pt).
- Court title, caption, and title of the paper as in the complaint folder (the same two-column caption and the same single-spaced lines of 13.8 pt).
- Body double spaced (27.6 pt pitch). Level-1 headings are sections (centered, bold, capitals, `I.`, `II.`, ... by the template); level-2 headings are subsections (bold, left, `A.`, `B.`, ... by the template, restarting under each section); level-3 headings are bold italic run-in lines.
- Body paragraphs have a first-line indent and no numbers (briefs are not numbered like complaints).
- Lists are lettered (`a.`, `b.`, ...) with a hanging indent (the relief list in the conclusion).
- Signature block (single spaced), then a "CERTIFICATE OF SERVICE" with the date and method from the frontmatter.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter fields: `court`, `caption` (as in the complaint folder), `case_number`, `brief_title` (the whole title, e.g. "DEFENDANT EXAMPLE DEFENDANT, INC.'S MOTION TO DISMISS UNDER RULE 12(b)(6)"), `signature` (`firm`, `signer`, `lines`, `role`), `service` (`date`, `method`; optional but required by CV-5(c) in practice).
- Body: a `# Statement of the Issue(s) to Be Decided` heading (required: the template panics without it); `#` headings for sections; `##` and `###` for subsections; `-` items for the relief list; plain paragraphs otherwise. Use `*...*` for case names and signals.
- Not supported: tables, footnotes (not used), raw typst, numbered lists in the body (the template letters `-` lists only).

## Known gaps and open choices

1. **No exemplar (BLOCKED).** Nothing to compare against, so tier 2 (professional convention) is judged from the rules and the complaint folder only. Closing the block needs a text-based filed E.D. Tex. Rule 12(b)(6) motion; see `exemplars/SOURCE.md`.
2. **Motion and memorandum as one document.** CV-10(a)(2)'s example names a single "Motion to Dismiss under Rule 12(b)(6)", so the template produces one document with the memorandum inside it. CV-7(a) says each motion is a separate document; whether the memorandum must be a separate document is not settled by the text read here. This is a question for David, not a blocker: the template could produce a separate memorandum by splitting the sample.
3. **Proposed order not produced.** CV-7(a) requires a separate proposed order (searchable PDF, endorsed with the style and number, no date or signature block). It is a separate file and is not part of this template.
4. **Signature block alone on a page.** In the generic sample the signature block (unbreakable) moves to page 4 with the certificate, while page 3 ends with the relief list. Conventionally the signature should stay with the last text. The template does not yet keep the last paragraph with the signature; the sample shows the case.
5. **Font.** EB Garamond only, as in the complaint folder (see `../complaint/README.md`, Known gaps 2).
6. **Local-rule version.** See the version caveat above.
7. **Page limit check uses the rendered page count.** It counts every page of the document (the signature and certificate included), which is the conservative reading: the rule excludes attachments only, and attachments are not part of this build.

## Review record

- Pages 1 to 4 of `samples/OUTPUT-generic-motion-to-dismiss.pdf` were rendered at 60 dpi and viewed after the last template change. Page 1: the two-line title sits clear of the first paragraph (after the fix below). Page 2: subsections A and B bold, with a gap below each. Page 3: level-3 lines and the relief list lettered a-d. Page 4: signature and certificate.
- Defects found and fixed during review: (a) the two-line motion title overlapped the first paragraph (a fixed one-line block; now grows with its lines); (b) subsection headings took the surrounding size (now set to the body size); (c) headings had no gap below them (now `below: body-gap`).
