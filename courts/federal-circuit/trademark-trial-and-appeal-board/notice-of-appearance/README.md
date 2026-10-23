# TTAB: notice of appearance, power of attorney, change of correspondence (typst + docx)

Doc type `notice-of-appearance` under the Trademark Trial and Appeal Board (`court` ttab): an attorney's notice of appearance for a party in an opposition or cancellation, in three variants (appearance only; appearance and change of correspondence address; power of attorney, appearance and change of correspondence address), with the signature blocks and the certificate of service. Self-contained: the exemplars, the samples, the templates and this README live in this folder. Requirements and sources: [../rules.md](../rules.md), section "Doc type: notice-of-appearance" (TTAB-NOA-001 to -010). Filed exemplars: [usage/SOURCE.md](usage/SOURCE.md). Loop history: [../LOG.md](../LOG.md). Reviews: [../reviews/](../reviews/).

## Status

| Item | State |
|---|---|
| Exemplars | four filers, both sides, 2015-2026 (DLA Piper for Happi Co., POA + appearance + correspondence; Chubb Law Group for Creatively Disruptive, appearance; Jones Day for BCBSMI, appearance + correspondence; Webb Law Firm for GNC, appearance for opposer). See `usage/SOURCE.md` |
| Samples | `INPUT-notice-of-appearance.md` (Happi, generated wording, power of attorney); `INPUT-notice-of-appearance-2.md` (Creatively Disruptive, the filer's own text, `generate: false`); `INPUT-notice-of-appearance-5.md` (fictional: cancellation, plaintiff's side, two attorneys with bar information, generated title, extra body paragraph, drafting note, two recipients) |
| Render (typst) | `just render courts/federal-circuit/trademark-trial-and-appeal-board/notice-of-appearance` writes `usage/OUTPUT-notice-of-appearance[-n].typst.pdf` (3, 2 and 3 pages) |
| Render (docx) | `sh tools/render.sh --engine docx <this dir> usage/INPUT-notice-of-appearance[-n].md` writes `.docx` and `.docx.pdf` |
| Check gates (`fb check`) | typst 24 passed, 0 failed; docx 36 passed, 0 failed (`data/checks-default.yaml` with `eval.yaml`); stamps `usage/.check-typst.txt`, `.check-docx.txt` |
| Cross-engine (Gate 4) | gated (`eval.yaml` `params.cross_engine: gate`): the docx breaks every line and page as typst does (XENG-001..003 PASS on all three samples) |
| Pages reviewed | every page of both engines of all three samples (16 pages); `../reviews/2026-10-23.md` |
| LaTeX engine | not built |

## Rules the template applies

| ID | Requirement (short) | Source | What the template does |
|---|---|---|---|
| TTAB-FORM-001/002 | at least 11 pt, double-spaced | 37 C.F.R. § 2.126(a)(1) | 12 pt; body pitch 27.6 pt (Word double for Times New Roman at 12 pt) |
| TTAB-NOA-001 | caption: parties, proceeding number, application or registration and mark | TBMP § 106.01; § 2.194(b) | parties left, `Opposition No.` / `Cancellation No.` and the `matter` lines right |
| TTAB-NOA-002 | title names each act | exemplars | `title`, or generated from `power_of_attorney` and `correspondence` |
| TTAB-NOA-003 | appearance recognizes the attorney; it represents authority | 37 C.F.R. § 2.17(b)(1)(iii), (b)(2); TBMP § 114.03 | appearance paragraph citing 37 C.F.R. § 2.17(b) and TBMP § 114.03 |
| TTAB-NOA-004 | attorney under § 11.1; bar state, admission date, number | 37 C.F.R. §§ 11.1, 11.14(a), 2.17(b)(3) | one sentence per attorney, with `bar` when given |
| TTAB-NOA-005 | power of attorney names the practitioner and is signed by the party; new power revokes the old | 37 C.F.R. §§ 2.17(c), 2.19(a)(4); TBMP § 114.03 | POA paragraph in the TBMP wording; `revoke_prior` adds the § 2.19(a)(4) sentence; refuses to build without `party_signature` |
| TTAB-NOA-006 | correspondence to the attorney; keep addresses current | 37 C.F.R. §§ 2.18(a)(2), (c), 2.119(b); TBMP §§ 117.01, 117.07 | request paragraph and a single-spaced correspondence block (name, firm, address, telephone, emails) |
| TTAB-NOA-007, TTAB-CERT-002/003 | `/Name/` signature, name and title below; party signs a POA | 37 C.F.R. §§ 2.193(c)(1), (d), 2.17(c)(2) | party block (when given) above counsel's block, each "By: /Name/" over a rule |
| TTAB-NOA-008, TTAB-CERT-004/005 | certificate of service by email | 37 C.F.R. § 2.119(a), (b); TBMP § 113.03 | own page: date, paper, "by email", each recipient's name, role, address, email |

## Markdown contract

```yaml
kind: opposition                  # or: cancellation
proceeding_number: "91123456"
matter: ["Serial No. 00000000", "Mark: EXAMPLE"]   # right-hand caption lines under the number
plaintiff: { name: "Opposer Name,", role: "Opposer," }
defendant: { name: "Applicant Name,", role: "Applicant." }
appearing_for: defendant          # or plaintiff; the role (punctuation dropped) is the party's label in the text
title: "..."                      # optional; generated from the variant when absent
generate: true                    # false: the body is the whole text (the correspondence block follows it)
power_of_attorney: false          # true: POA paragraph; needs party_signature
revoke_prior: false               # with a POA: the 37 C.F.R. § 2.19(a)(4) sentence
counsel:
  firm: "Firm Name"               # optional
  attorneys:
    - name: "Attorney Name"
      bar: { state: "California", admitted: "June 1, 2020", number: "000000" }   # optional; each key optional
correspondence:                   # optional: request paragraph + block
  name: "Attorney Name"
  firm: "Firm Name"
  lines: ["street", "city, state zip"]
  phone: "(555) 555-5555"
  emails: ["a@example.com", "docket@example.com"]
party_signature:                  # required with power_of_attorney
  party: "PARTY NAME"
  esign: "/Signer Name/"
  name: "Signer Name"
  title: "Applicant, individually"   # or officer title
  lines: []
signature:
  date: "..."
  firm: "FIRM NAME"
  esign: "/Attorney Name/"
  name: "Attorney Name"
  title: "Attorney for Applicant"
  lines: ["bar line", "address", "telephone", "email"]
service:                          # omit to omit the certificate page
  date: "..."
  paper: "..."                    # optional; defaults to the title
  method: "email"
  recipients:
    - { name: "Counsel Name", role: "counsel of record for Opposer", lines: ["Firm", "Address"], email: "..." }
  esign: "/Attorney Name/"
  name: "Attorney Name"
  title: "Attorney for Applicant"
```

Body (optional): CommonMark paragraphs, set after the correspondence block (or, with `generate: false`, before it). `**[NOTE ...]**` on its own line is a drafting note (flush left, single-spaced, italic; TTAB-TOOL-002). Bullet lists are supported; headings, numbered lists, block quotations, tables and footnotes are not styled by this template.

## Decisions

- **Generated wording.** The rules fix what the paper must do, not its words; the generated paragraphs say each act once with its citation (37 C.F.R. § 2.17(b), § 11.1, § 2.17(b)(3) bar data, § 2.17(c) and § 2.19(a)(4) for a POA, § 2.18(a)(2) and TBMP § 117 for correspondence). `generate: false` lets a filer use their own text, which the Creatively Disruptive sample shows.
- **Caption** on the exemplars' shape (parties left, number, application and mark right), drawn with the answer template's rules in place of a column of parentheses.
- **The same measurements as the answer** (font, pitches, signature indent, certificate page), so papers in one proceeding match.
- **Signature blocks**: the party's block above counsel's, as in Happi. Bar data for the paper goes in `signature.lines` or `counsel.attorneys[].bar`.
- **docx hyphens**: in the single-spaced block lines the docx filter writes a plain hyphen instead of the shared filter's no-break hyphen before a digit, because Times New Roman has no U+2011 glyph and LibreOffice drew it from a fallback face (DEF-FONT-002). Body paragraphs keep the shared behaviour, so a hyphen-digit ("20006-1157") in body text still fails DEF-FONT-002 in the docx engine.

## Known limits

- No `checks.yaml`; `fb check` judges with `data/checks-default.yaml` and `eval.yaml`. No LaTeX engine.
- The generated wording is English boilerplate in the template, not taken from any one filer; review it for each filing.
- The ESTTA / TTAB Center cover sheet is generated by the filing system and is not part of the template. Which form (Appearance, Correspondence/Parties) to use is checked on the day of filing (TTAB-NOA-009).
- Whether the Board will record a represented party's own emails as additional correspondence addresses is not verified (rules.md, "Not verified").
