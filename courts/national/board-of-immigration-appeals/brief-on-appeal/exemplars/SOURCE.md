# Exemplar source: BIA brief on appeal

Status: **BLOCKED: no exemplar.** No public filed brief on appeal (a brief filed with the Board of Immigration Appeals) was found that meets the rule "real filed document, public court record". No PDF is saved in this folder.

## Searches tried (2026-10-14)

- CourtListener search for "brief on appeal" + "Board of Immigration Appeals" + "Certificate of Service" (RECAP): `https://www.courtlistener.com/?q=...&type=r`. Returned HTTP 403 from this box, so the search could not be run. Not retried.
- Web searches (standard and extended modes): "RESPONDENT'S BRIEF ON APPEAL" + "Board of Immigration Appeals" + exhibit; "DHS BRIEF ON APPEAL" + EOIR + A# + certificate of service; "brief on appeal" + "before the Board of Immigration Appeals" + pdf. Results: BIA forms (EOIR-26, EOIR-29), practice guides, and petition-for-review briefs filed in the courts of appeals. No filed BIA brief on appeal in a public court record.

## Candidates found and rejected

| Source | What it is | Why rejected |
|---|---|---|
| `https://www.cliniclegal.org/sites/default/files/2019-12/Sample%20BIA%20Appeal%20Brief-Himedes%20Chicas.pdf` | "Respondent's Brief in Support of Bond Appeal", Jezic & Moyse LLC, 22 pp. Titled "Sample" in its URL. | Practitioner-published sample, not a public court record. Not confirmed as filed; counsel name and file number are redacted. Bond appeal, not a removal-appeal brief. |
| `https://www.ilrc.org/sites/default/files/sample-pdf/c_brief_on_appeal.pdf` | "Respondent-Appellant's Brief on Appeal", Ozment Law, 33 pp. Filed under a `sample-pdf` path. | Same problem: advocacy-published sample; respondent name and file number blanked; not confirmed as filed. |

Neither candidate was used as an exemplar or transcribed. The sample in `samples/` is synthetic, with placeholder names and citations, and says so in its own text.

## What would unblock this

A text-based PDF of a brief on appeal (from either side) filed with the Board, from a public court record (for example, an exhibit to a federal petition for review, in a RECAP docket), with the filer named in `SOURCE.md`. Re-run CourtListener search from a box that can reach it.
