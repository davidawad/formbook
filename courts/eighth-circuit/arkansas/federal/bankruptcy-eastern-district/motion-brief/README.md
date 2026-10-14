# Motion with memorandum (brief) in support: U.S. Bankruptcy Court, E.D. Ark. (areb)

**BLOCKED: no exemplar.** No filed motion or brief from this court was found. The searches tried are recorded in `exemplars/SOURCE.md`. The sample is synthetic and labelled as such. The overlay cannot run without an exemplar PDF.

Status: template built from the rules; render and page review done (below); overlay not run (no exemplar).

## What is here

| Path | What |
|---|---|
| `typst/areb-motion-brief.typ` | Template: `areb-motion-brief(meta, md)`. Every number is a named parameter at the top, and each traces to a rule ID or is marked as a convention. |
| `typst/main.typ` | Entry point. Reads the sample named by `--input sample=...`, splits the frontmatter from the body, calls the template. |
| `samples/INPUT-generic-motion-brief.md` | Synthetic sample: a chapter 11 sale motion under 11 U.S.C. § 363 with a memorandum. Invented names, numbers and dates. |
| `samples/OUTPUT-generic-motion-brief.pdf` | Render of the sample (4 pages). |
| `exemplars/SOURCE.md` | The exemplar search log. No PDF saved. |

Build (from the repo root, with `PATH="$HOME/tb/bin:$PATH"` per the box setup):

```sh
D=courts/eighth-circuit/arkansas/federal/bankruptcy-eastern-district/motion-brief
sh tools/render.sh $D samples/INPUT-generic-motion-brief.md   # -> samples/OUTPUT-generic-motion-brief.pdf
sh tools/overlay.sh $D generic-motion-brief             # fails: no exemplar PDF in exemplars/
```

Fonts are the vendored EB Garamond only (`--ignore-system-fonts`); any typst warning fails the render.

## Governing rules

Verified 2026-10-14. Federal rule text came from the Legal Information Institute (law.cornell.edu), which mirrors the current restyled rules (effective Dec. 1, 2024). The local rules came from the court's own site.

| ID | Requirement | Source (URL) |
|---|---|---|
| AREB-MOT-001 | A written motion (FRBP 9013(a)) must state its grounds with particularity and set forth the relief or order requested. The template gives numbered motion paragraphs for grounds and relief. | FRBP 9013(a)-(b), https://www.law.cornell.edu/rules/frbp/rule_9013 |
| AREB-MOT-002 | The movant serves the motion on the trustee or debtor in possession and the entities the rules or the court designate, within the time under Rule 9006(d). The certificate of service states the method and the parties. | FRBP 9013(b), https://www.law.cornell.edu/rules/frbp/rule_9013 (9006(d) not fetched) |
| AREB-CAP-001 | Caption: court name, case title, case number and adversary number (if any), brief designation of the document | FRBP 9004(b), https://www.law.cornell.edu/rules/frbp/rule_9004 |
| AREB-SIG-001 | Signed by at least one attorney of record in the attorney's individual name; each document states the signer's address and telephone | FRBP 9011(a), https://www.law.cornell.edu/rules/frbp/rule_9011 |
| AREB-ATTY-001 | Every filing: attorney's complete address, telephone number and state bar number | E.D./W.D. Ark. Local Rule 5005-4 (adopted 1/12/2006), https://www.areb.uscourts.gov/sites/arb/files/LocalRules.pdf (complete set; the court index lists it as revised 8/2/2018) |
| AREB-MEM-001 | No rule requires a memorandum or brief with a bankruptcy motion in this court. The memorandum is a convention, and the sample's structure (introduction, facts, argument, conclusion) is the usual shape. | convention; no E.D. Ark. Local Rule 9013-1 exists (see findings) |
| AREB-FORM-003 | Margins: one inch (convention; no rule sets margins for this court) | convention |
| AREB-FORM-004 | Type size 12 pt, body about double spaced (convention; no rule sets type size or spacing for this court) | convention |

Court-specific findings, to be read before editing the template:

- **No Local Rule 9013-1.** The complete local rules set (`LocalRules.pdf`, 17 pages) lists rules 1001-1, 1020-1, 2015-1, 2072-1, 2090-1, 2090-2, 3015-1, 5001-2, 5005-4, 7033-1, 9015-1 and 9019-1. It has no motion rule, and no rule on the form of papers (font, size, margins, spacing, page limits). The brief requested "per this court's local bankruptcy rules", but the court's local rules do not supply one. The template therefore takes its layout from FRBP 9013 and conventions.
- **Local Rule 9019-1** governs consent orders and routine orders. It does not govern motions and is not used here. Under it a proposed order is submitted only if it is a consent or routine order.
- **Local Rule 5005-4** applies to all filings, electronic or not, and requires the attorney's address, phone and bar number.

## What the overlay shows

Not run. The overlay compares our render against a filed exemplar, and none exists, so there is nothing to pair. Once a filed motion is saved in `exemplars/`, run the overlay and record the page map in this README.

## Page review (Gate 2)

Rendered 2026-10-14 at 60 dpi. Every page of `samples/OUTPUT-generic-motion-brief.pdf` was viewed.

| Page | Result |
|---|---|
| 1 | Caption (no adversary block, since the motion is in the main case), title, numbered motion paragraphs 1-5. Pass. |
| 2 | Motion paragraphs 6-8, WHEREFORE clause, memorandum heading, introduction, facts. Pass. |
| 3 | Facts, argument with sub-headings A-C, start of conclusion. Pass. |
| 4 | Rest of conclusion, date, signature line (`s/ COUNSEL EXAMPLE`), counsel block, certificate of service with the served list. Pass. |

The adversary-caption branch is not exercised by the sample (a main-case motion). A temporary sample with an adversary block was rendered with no warnings and its page-1 caption read back correctly (text layer only); that temporary file was deleted.

## Known gaps

- **No exemplar.** Tier-2 conventions (caption proportions, memorandum length and placement, page furniture) are unchecked against a filed motion. The 12 pt and double-spacing choices are conventions, not rule requirements.
- **Adversary branch checked by text only.** Its caption is confirmed in the text layer, not reviewed as an image. Look at it before relying on it.
- **Certificate of service wording is a convention.** FRBP 9014(b) and 7004 govern service of contested-matter motions. Those rules were not fetched, so the method and the service list are not checked against them.
- **Sale-motion authorities not fetched.** The sample cites 11 U.S.C. §§ 363(b), 363(f), 1107, 1108, 157 and 1408 and Fed. R. Bankr. P. 6004. These are the sample's content, not the template's, and the text of the statutes and Rule 6004 was not read. Check them before any use of the sample as a model.
- **Page limits and standing orders not checked.** No local rule limits motion or brief length. Chief Judge or judge-specific standing orders were not searched, and they may impose limits or proposed-order requirements.
- **Proposed order not generated.** Many courts want a proposed order with a motion. This court's rules were not found to require one for a motion. The template does not produce one.
- **Electronic-filing and signature conventions** (`s/ NAME`, `Dated:` placement) follow common practice; they are not verified against the court's ECF procedures (not fetched).
