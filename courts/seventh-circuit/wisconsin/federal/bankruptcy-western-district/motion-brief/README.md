# W.D. Wis. Bankruptcy Court: motion with brief in support

BLOCKED: no exemplar

Doc type: **motion with brief in support** (a written motion, here a motion to dismiss an adversary complaint, with the memorandum that supports it in the same filed document). Court: United States Bankruptcy Court, Western District of Wisconsin (`wiwb`). Folder: `courts/seventh-circuit/wisconsin/federal/bankruptcy-western-district/motion-brief/`.

Status: exemplar=no, render=ok, overlay=fail (no exemplar PDF, so `tools/overlay.sh` exits 1), pages reviewed 19 of 19 (of `samples/OUTPUT-hiawatha-memorandum.pdf`, fonts pass 2026-10-15). Nothing here sets `court.json` status.

## What is here, and what is not

- **Template** (`typst/wiwb-motion-brief.typ`), built from the rules below, because the brief asks for a template when no exemplar can be found.
- **Sample** (`samples/INPUT-hiawatha-memorandum.md`): a 19-page post-trial memorandum in support of a motion to dismiss under 11 U.S.C. § 1208(c) (Hiawatha National Bank, *In re* Johnson, 18-10327-12). This README earlier described a constructed sample; that file is not in the folder. Its provenance (transcribed or drafted) is not recorded here and needs confirming. It cites case law, which was not checked against the reporters. It is not evidence of how this court's filers write, and it is used only to test the layout.
- **No exemplar.** The eval loop's tier 2 (judged against two or three filed exemplars) cannot be run. Tier 2 is untested for this doc type. Tier 1 items below are from rules; the rule text for the local practice was not found.

## Governing rules

Rule text was read from the Legal Information Institute (LII) pages on 2026-10-14 (LII shows the 2024 restyled text).

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| WIWB-MO-001 | Fed. R. Bankr. P. 9013(a)-(b) | A request for an order is made by written motion. The motion must state its grounds with particularity and set forth the relief or order requested. | template **asserts** a `# RELIEF REQUESTED` and a `# GROUNDS` heading (the build fails otherwise). |
| WIWB-MO-002 | Fed. R. Bankr. P. 7012(b) | Fed. R. Civ. P. 12(b) defenses (here, 12(b)(6)) apply in adversary proceedings. Rule text not fetched. | sample's relief paragraph. |
| WIWB-MO-003 | Fed. R. Bankr. P. 9004(b) | Caption: court name; case title; case number and adversary number if any; brief designation of the document. | `court-title()`, `caption()`, `cover()` |
| WIWB-MO-004 | Fed. R. Bankr. P. 9004(a) | Clearly legible. | body 12 pt, `type-size` |
| WIWB-MO-005 | Fed. R. Bankr. P. 9011 (signature) | Signed by an attorney, with address, telephone and bar number (e-mail if any). Rule text not fetched. | `signature()` |
| WIWB-MO-006 | Fed. R. Bankr. P. 9014 | Contested matters (motions that are not adversary-proceeding motions) are governed by Rule 9014. Cited for the caption choice only; rule text not fetched. | caption `In re` block (main case) |

**Local rules.** The court's published local rules page (`https://ecf.wiwb.uscourts.gov/wiwb/Decisions/local_rules.htm`, "Revised 6/2015", fetched 2026-10-14) lists seven rules, none on motions, memoranda, page limits, or form of papers. The 2017 notice on `wiwb.uscourts.gov/node/481` says local rules were being amended; the current text was not found. **A W.D. Wis. rule on the brief's form, page limit, or the memorandum requirement is not verified and may exist.** The template therefore does not impose a page limit or a required memorandum section list.

**Not generated, on purpose:** notice of hearing (no local rule found requiring a fixed format), proposed order, certificate of service (Fed. R. Bankr. P. 7005/9014 service rules not fetched), table of contents and table of authorities (not required by any rule found, and they would be built from `toa:` links the sample does not carry).

## Parameters: rule or convention

| Parameter | Value | Basis |
|---|---|---|
| Paper | 8½ × 11 in, 1 in margins | Convention (no W.D. Wis. rule found). |
| Typeface | Face required: none. Vendored substitute: none, EB Garamond kept (OFL), 12 pt. Fit: n/a. | No face is named by a rule that governs a motion or brief. The W.D. Wis. LBR 1007-2 names Arial, Times New Roman or Courier, but only for the creditor matrix of a voluntary petition. Per `docs/FONTS.md` ("No face named"), EB Garamond stays. |
| Line spacing | 24 pt baseline pitch in the body (leading 1.35em; paragraph gap 1.35em; 0.65em line box) | Convention, measured on the render (`pdftotext -bbox-layout`, see below). |
| Paragraphs | first-line indent, not numbered | A brief is argument, not allegations (Fed. R. Civ. P. 10(b) numbering is for complaints). |
| Headings | level 1 centered bold caps; level 2 bold, left | Convention. |

## Render

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/seventh-circuit/wisconsin/federal/bankruptcy-western-district/motion-brief samples/INPUT-hiawatha-memorandum.md
sh tools/overlay.sh courts/seventh-circuit/wisconsin/federal/bankruptcy-western-district/motion-brief hiawatha-memorandum   # exits 1: no exemplar
```

- `samples/OUTPUT-hiawatha-memorandum.pdf`: 19 pages. Typst compiled with no warnings. `pdffonts`: EB Garamond Regular, Bold and Italic only (vendored, embedded).
- The overlay step is **not** run to a result: there is no exemplar to overlay. It fails with "no exemplar pdf in exemplars" (exit 1). `samples/OVERLAY-hiawatha-memorandum.txt` is left over from an earlier run and does not match this render; it is not regenerated.

## Visual review (Gate 2 record, all 19 pages rendered at 60 dpi and looked at, 2026-10-15)

| Page | Finding |
|---|---|
| 1–18 | OK. Caption, title, numbered paragraphs, headings (level 1 centred caps; level 2 and 3 bold, left), block quotes, footnotes and the bullets sit correctly; no overlapping or orphaned headings seen. |
| 19 | **OPEN (tier 2):** the signature block (date, firm, `/s/` line, signer) is alone on the last page; the Conclusion ends on page 18. Layout only, not typeface; not changed in this pass. |

Reviewed pages: 19 of 19.

## Known gaps and open choices (must be closed before this doc type is used)

1. **BLOCKED: no exemplar.** No party-filed motion with a supporting brief from this court (with a text layer) was found. The searches are in `exemplars/SOURCE.md`. The next step is a docket-level search of an adversary docket with a known motion to dismiss (the Johnson adversary 1-23-00041, or Parr 1-22-00050) for the filed motion, or PACER's case locator.
2. **Local rule.** The current W.D. Wis. bankruptcy local rules on motions, memoranda and page limits were not found. The template's form choices are conventions until they are read.
3. **Tier 2 untested.** With no exemplar there is nothing to judge the layout against. Look at the sample PDF as a rendering only.
4. **Sample content.** The sample cites case law; none of it was checked against the reporters, and its provenance needs confirming (see "What is here"). The citation form is not checked against the court's rules.
5. **Overlay naming.** The brief's shorthand (`<id>-overlay.pdf`) is not what `tools/overlay.sh` writes (`OVERLAY-<id>.pdf`); the tool's name is used.
