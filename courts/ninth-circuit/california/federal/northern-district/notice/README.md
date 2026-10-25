# N.D. Cal. (cand): notice

Doc type: **notice** (a short paper filed on its own: notice of appearance, notice of special appearance, notice of withdrawal). Court: United States District Court for the Northern District of California. Folder: `courts/ninth-circuit/california/federal/northern-district/notice/`.

Status: exemplar=none saved (synthetic sample, see `usage/SOURCE.md`); render=ok (Times New Roman, pleading paper, 1 page); overlay=not applicable (no exemplar); pages reviewed 1 of 1 (rasterized and looked at: counsel block, caption, one paragraph, signature, footer). Engines: typst only; no docx or latex template. Not a court-level `court.json` status; nothing here sets `status`.

Typeface: Times New Roman 12 pt, as the motion brief (Civil L.R. 3-4(c)(2)(A)-(B); docs/FONTS.md rule 6).

## Governing rules

Same form as the motion brief and the complaint; the rule text is quoted in `../motion-brief/README.md` and the requirement IDs are in `../rules.md` (CAND-FORM-001 to 006; CAND-CONT-010 is this doc type's).

| Rule | Requirement | Where it lives |
|---|---|---|
| Civil L.R. 3-4(c)(1) | Letter paper, numbered lines. | `margins`, `line-numbers`, `pleading-rules` |
| Civil L.R. 3-4(c)(2) | Double-spaced text, at most 28 lines; counsel block, caption, footnotes and quotations exempt. | `pitch-double` 24 pt, `lines-per-page` 28; `pitch-single` 12 pt |
| Civil L.R. 3-4(c)(3) | Footer on each page with the paper's title and the case number. | `running-footer` (page number, title, case number; 10 pt) |
| Civil L.R. 3-4(a) | Counsel block upper left; court title, caption, case number, title of the paper. | `counsel-block`, `cover` |
| Civil L.R. 7-4(a)(2) (CAND-CONT-010) | No table of contents or authorities (those are for a brief over 10 pages); text starts on page 1 under the caption. | `cand-notice` (no tables) |

## Sample and render

```sh
sh tools/render.sh courts/ninth-circuit/california/federal/northern-district/notice usage/INPUT-notice.md
sh tools/check.sh courts/ninth-circuit/california/federal/northern-district/notice
```

Frontmatter is the motion brief's, without `authorities` and with `hearing` optional (give it only if the notice sets a hearing). The body is markdown: paragraphs, and headings if wanted (numbered by the template, I., A., 1.). The signature block prints `/s/ Signer` in italics.

## Known gaps and open choices

1. **No filed exemplar and one sample.** The tier-2 rule asks for 2 or 3 filers. The template is the motion brief's, which has two; the notice form itself is not compared with a filed notice.
2. **No docx or latex engine.** There is no `docx/` folder, so no cross-engine gate; `eval.yaml` carries only the margin parameters.
3. **Footer.** Same limit as the motion brief: four lines, so a title of at most two lines.
4. **Signature on its own page.** The signature block never breaks across pages; if the body ends near the foot, the whole block moves to page 2. The sample is kept to one paragraph so that it fits page 1.
5. **Characters per inch** (Civil L.R. 3-4(c)(2)(C)): see motion-brief README, Known gap 1; not enforced.
