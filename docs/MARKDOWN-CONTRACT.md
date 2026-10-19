# Markdown brief contract

Brief inputs are UTF-8 Markdown files with a YAML frontmatter object, a closing `---`, and then the filing body. The reusable metadata profile is [schema/brief.schema.json](../schema/brief.schema.json). A court or document type may add fields; fields not used by its template are preserved as metadata and can be ignored. The schema also accepts the established ca9 brief profile while templates migrate.

## Metadata

The shared profile requires:

| Field | Shape | Meaning |
|---|---|---|
| `filing_type` | non-empty string | Name of the filing, such as `Opening Brief`. |
| `caption` | non-empty string | Court-ready caption text. The template controls its placement and layout. |
| `parties` | list of `{name, role}` | One entry per party; roles identify the party's procedural posture. |
| `lower_court` | `{name, case_number}` with optional `judge` | Source court and docket information for an appeal. Trial-court filings may describe the relevant lower-court context appropriate to that court. |
| `counsel` | list of `{names, lines}` | Counsel names and office, firm, address, and contact lines. |

Optional `signature` metadata has a `signer` and `lines`. Optional `certificates` is a list of `{type, text}` entries; `type` is `service`, `compliance`, or `other`, and `date` and `signer` may be supplied. Templates own the placement, wording required by local rules, and any required signature rendering. Keep rule-specific fields (for example, word-count certifications or local service options) in additional frontmatter properties and document them in the court or document-type README.

The Ninth Circuit brief inputs predate the shared profile. Their accepted `ca9Legacy` shape uses `case_number`, a two-sided `caption` with `names` and `designation`, `proceeding` for lower-court context, `brief_title`, `counsel`, `phone`, and `signature`. `authorities` is an optional map keyed by short stable identifiers. See the ca9 README for its rule-specific fields and rendering details.

## Body Markdown

Use ordinary Markdown headings, paragraphs, lists, block quotes, emphasis, and footnotes. A template may impose heading levels and required sections; its README must say which. Do not put court-specific page layout or line breaks into the body.

### Citations and table of authorities

For a template that generates a table of authorities, mark a citation with a Markdown link to `toa:<key>`, where `<key>` names an entry in frontmatter `authorities`. The link text is the full citation as it should appear in the argument, and the template uses the key to collect and group cited authorities for the table. Short forms can link to the same key. Example:

```markdown
[*Horne v. Flores*, 557 U.S. 433, 447 (2009)](toa:horne)
```

Templates that do not generate a table of authorities may treat ordinary links as ordinary Markdown links. A bare URL does not create an authority entry.

### Emphasis for case names

Markdown emphasis is literal and author-controlled. Italicize case names and conventional signals where the applicable rules or style call for it, for example `*Horne v. Flores*`, `*Id.*`, `*see*`, or `*supra*`. Templates do not infer case names from unmarked text.

### Block quotations

Use Markdown block quote syntax (`>`). The court template sets indentation, leading, and any required quotation spacing; do not simulate these with spaces or manual line breaks.

### Footnotes

Use standard Markdown footnote references and definitions:

```markdown
The proposition appears in the record.[^record]

[^record]: Record citation and explanatory text.
```

The renderer controls marker style, numbering, and footnote typography. Define every referenced note once. A court-specific README must document any footnote restrictions or non-standard behavior.

### Signature and certificates

Use the shared `signature` and `certificates` metadata when the template supports those fields. The template places these blocks and applies required court wording and formatting. Do not type a fake signature block into the argument body to control its location. When a court requires variable certification text, put the filer-supplied text in certificate metadata and let the template supply mandatory language.

## Lint

`just lint-metadata <input.md>` parses the frontmatter and checks it against either the shared profile or the supported ca9 legacy profile. A successful result is `LINT metadata <input>: valid`; invalid YAML, absent delimiters, or incorrectly shaped required metadata return exit status 1. This linter checks metadata structure only; it does not validate legal sufficiency, citation accuracy, or court rules.
