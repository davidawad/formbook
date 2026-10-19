# Input contract: markdown + YAML frontmatter

Every template reads ONE file: a YAML frontmatter block between `---` lines, then a markdown body. The template reads it in `typst/main.typ` (`split-frontmatter`, then `yaml(...)` on the block; the body goes through `cmarker` v0.1.10 with `raw-typst: false`, `smart-punctuation: true`).

**The exact keys differ per doc type and per court.** The authority is that doc type's `README.md` section "Markdown contract" (a table of fields) and its `usage/INPUT-*.md`. Verify with `grep -o 'need(meta, "[a-z_]*")\|meta\.[a-z_]*' <doctype>/typst/*.typ | sort -u`: `need(...)` keys are required (the build panics without them), `meta.x` / `meta.at("x"` keys are optional.

## Shared shape

| Concern | Convention |
|---|---|
| Frontmatter | Metadata only: case number, parties, counsel, titles, date, signature, authority registry. A `#` comment line at the top of the block is allowed (samples use it to say what was transcribed). |
| Strings with `:`, leading `*`, or `*` anywhere | Quote them in YAML. A literal asterisk in a cite is `'\*2-3'` in single quotes. |
| Inline markdown in frontmatter strings | Allowed in party names, counsel lines (`"*Attorneys for Plaintiff*"`, `"**FIRM LLP**"`). |
| Body | Markdown only. Headings (`#`..`#####`), paragraphs, `> block quotes`, lists, `*emphasis*`, `[^k]` footnotes with `[^k]: text`, links. |
| Not supported | Tables, images, raw HTML, raw Typst, headings deeper than level 5. |
| Escaping | A line that starts `90.`, `1)`, `-`, `+`, `#`, `>` is a list/heading/quote. Write `90\. The record shows`. |
| Punctuation | Smart punctuation is on: `--` en dash, `---` em dash, `...` ellipsis, straight quotes become curly. Typing the real characters is also fine. |
| Case names, *Id.*, *supra* | Italicize them yourself with `*...*`; templates never guess. |
| Authorities | Appellate briefs and the NY memorandum: cite as `[*Horne v. Flores*, 557 U.S. 433, 447 (2009)](toa:horne)`, with `horne` registered under `authorities:` as `{kind: case, name: "Horne v. Flores", cite: "557 U.S. 433 (2009)"}`. `kind`: `case`, `constitution`, `statute`, `regulation`, `rule`, `other`. Short forms and *Id.* link to the same key. Only linked citations enter the table of authorities. An unknown key stops the build; a link inside a heading is refused. |
| Generated, never typed | Cover/caption, TOC, TOA, certificates (compliance, service), signature block (appended after the Conclusion), page numbers, word count. |
| Word limits | Computed from the markdown and enforced by the template (e.g. FRAP 32(a)(7): 13,000 words principal brief; NY 22 NYCRR 202.8-b: 7,000 in chief / 4,200 reply). |

## Annotated example (appellate brief; modeled on `courts/first-circuit/court-of-appeals/opening-brief` and `courts/ninth-circuit/court-of-appeals`)

```markdown
---
case_number: "24-1311"                     # cover top line, certificates, PDF title
caption:                                   # list of two sides; template inserts "v."
  - names: ["UNITED STATES,"]              # one centered line per entry
    designation: "Appellee,"
  - names: ["MARK ANTHONY FIGUEROA,"]
    designation: "Defendant - Appellant."
proceeding: "On Appeal from Judgment of Conviction in the United States District Court for the District of Massachusetts"
brief_title: "Brief of Appellant"          # printed in capitals on the cover
counsel:                                   # groups; names printed as given, lines italic under them
  - names: ["David J. Nathanson", "First Circuit Bar No. 81606"]
    lines: ["Jellison & Nathanson, LLP", "55 Union Street, 4th Floor", "Boston, MA 02108"]
phone: "(617) 248-1806"                    # required by FRAP 32(a)(2)(F)
signature:                                 # appended after the Conclusion and on each certificate
  signer: "David J. Nathanson"
  for: "Defendant - Appellant Mark Anthony Figueroa"      # ca1 only
  lines: ["Jellison & Nathanson, LLP", "Tel. (617) 248-1806"]
date: "March 17, 2025"
word_processor: "Typst 0.15.1"             # ca1 certificate of compliance
typeface: "Liberation Serif"               # ca1 certificate of compliance
service: {certificate: true}               # adds a certificate of service
authorities:                               # registry for toa: links
  mahone: {kind: case, name: "United States v. Mahone", cite: "453 F.3d 68 (1st Cir. 2006)"}
  usc1291: {kind: statute, cite: "28 U.S.C. § 1291"}
---

# Statement of Jurisdiction                 <- level 1 = a section: bold, capitals, centered

This is a direct appeal under [28 U.S.C. § 1291](toa:usc1291).[^1]

# Argument

## Sentence Was Procedurally Unreasonable    <- under Argument: level 2 = centered point heading,
                                                 numbered "I." by the template (do not type "I.")
### Standard of Review                        <- level 3 = "A."; level 4 = "1."; level 5 = "a."

Review is for abuse of discretion. [*United States v. Mahone*, 453 F.3d 68, 71 (1st Cir. 2006)](toa:mahone).

> Block quotations are indented and single-spaced.

# Conclusion

For these reasons, the judgment should be reversed.

[^1]: Footnote text, one paragraph, at body size (14 pt for FRAP courts).
```

Body rules for this family (`opening-brief`, `answering-brief`, `reply-brief`, ca9 root): required level-1 sections in FRAP 28(a) order (statement of jurisdiction, issues, case, summary of argument, argument, conclusion; reply briefs need fewer: check the README); a "standard of review" heading or sentence; `# Addendum` (where the court requires one) ends the brief and starts its own pages and TOC. A heading with "oral argument" in it is excluded from the word count (ca1). The ca9 template adds optional `related_cases`, `word_limit_basis`, `manual_image_words`, `service.unregistered`; ca1 adds optional `disclosure`, `district_court_case`, `judge`.

## Per-doc-type differences

| Doc type / court | Differences from the appellate shape |
|---|---|
| `complaint` (e.g. `cand`, `nysupct`) | Pleading paper. cand: `case_number`, `caption.parties` (note: `parties`, not a bare list), `brief_title`, `footer_title` (page footer), `counsel` (flat list of lines for the numbered-line counsel block), optional `lead_in` (unnumbered), `jury_demand`, optional `legend`, `division`, `date`, `signature` (`firm`, `signer`, `lines`). The template NUMBERS paragraphs (Fed. R. Civ. P. 10(b)): never type paragraph numbers. Headings: level 1 centered caps, level 2 centered bold, level 3 bold italic left, each on one line (a two-line heading fails the build). Lists are lettered `(a)`, `(b)` by the template. No footnotes, no TOA. |
| `motion-brief` NY Supreme (`nysupct`) | Keys: `county`, `index_no`, `parties` (not `caption`; `-against-` between groups), `title`, optional `judge`, `motion_seq`, `filing: in-chief\|reply` (word limit), `toc`, `date`, `place`, `counsel` as `{names, lines, on_brief}`, `signature {firm, signer, lines}`, optional `to` (service list), `authorities` (required). Sub-headings ARE typed by the author: `## I. ...`, `### A. ...`, `#### i. ...`. TOC in roman numerals; certification of word count generated. |
| `motion-brief` other courts | Check each README: caption keys vary (`parties`, `caption`), word/page limits vary, some have no TOC/TOA. |
| `adversary-complaint`, bankruptcy doc types | Same family as `complaint` with the bankruptcy caption; read the README. |
| `opening-brief` / `answering-brief` / `reply-brief` | Heading numbering is automatic (do not type "I." / "A."); `answering-brief` and `reply-brief` differ from `opening-brief` in `required-sections`, word limit (reply is half) and cover title. |
| Court-root template (ca9 layout) | Same appellate contract; the folder is the court itself (`typst/` at court root, inputs in `usage/`). |

## Checking a contract you are unsure about

1. Read `<doctype>/README.md` "Markdown contract".
2. `grep -n 'need(meta' <doctype>/typst/*.typ` for required keys.
3. Render the unmodified sample first (`just render-filing`), then change one thing at a time.
4. Make the build fail on purpose (drop one key) to read the exact error message; the messages name the key.
