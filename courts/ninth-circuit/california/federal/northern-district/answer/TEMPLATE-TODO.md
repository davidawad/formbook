# TEMPLATE-TODO: cand answer

Scaffolded by `brief-build scaffold-template` from `/tmp/fb/courts/ninth-circuit/california/federal/northern-district/complaint` (cand complaint, pleading family) because formbook had no answer template for cand. Work this list, then delete this file in the commit that lands the template.

## Checklist

- [ ] Exemplars: 2 or 3 filed answer PDFs from different filers in this court into `usage/` as `FILED-EXAMPLE-answer[-n].pdf`, each recorded in `usage/SOURCE.md` (`legal-writer exemplar-search --court cand --doc-type answer --download usage`; free RECAP copies only).
- [ ] Rules: re-read the court's local rules for this paper (first page, caption, paper title, footer, page limits) and fill the README's rules table. A donor from another court carries that court's rules: check every one.
- [ ] Body: change what differs from the donor's complaint (caption title, lead-in, section structure, closing blocks); keep the shared page layout.
- [ ] Sample: transcribe `usage/FILED-EXAMPLE-answer.pdf` into `usage/INPUT-answer.md` (frontmatter fields the template reads).
- [ ] Render and check every engine: `just render courts/ninth-circuit/california/federal/northern-district/answer`, `just check courts/ninth-circuit/california/federal/northern-district/answer`, `sh tools/render.sh --engine docx courts/ninth-circuit/california/federal/northern-district/answer usage/INPUT-answer.md`, `sh tools/check.sh courts/ninth-circuit/california/federal/northern-district/answer --engine docx`.
- [ ] Calibrate (AI/skills/legal-brief-writer/references/format-calibration-loop.md): overlay against each exemplar, fix tier 1 and tier 2 differences, log tier 3 as accepted.
- [ ] README.md: status, exemplars, rules table, known gaps. Delete this file. Commit and land in formbook.

## Exemplar queries (CourtListener v4 search, type=rd)

- court=cand q=`short_description:"Answer to Complaint" AND is_available:true`

## Other donors considered

- tier 1 cand motion-brief (same court; pleading family donor)
- tier 1 cand notice (same court; pleading family)
- tier 3 akd complaint (pleading family; same circuit and level)
- tier 3 akd motion-brief (pleading family; same circuit and level)
