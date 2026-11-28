# Judges: a standing order as a layer over the court's layout

A court's template sets what the Federal Rules and the local rules require. Many judges add requirements of their own in a standing order: a lower word limit for replies, a footnote size, a mandated face. `fb judges` reads those requirements from a judge feed, checks each one against the order the court itself hosts, and `fb build --judge` renders a filing on the court's layout with the judge's requirements applied.

The layers, each overlaying the one before:

1. `lib/layouts/frcp-motion-brief.yaml`: the generic FRCP brief.
2. `courts/<court>/<doctype>/typst/layout.yaml`: the district's local rules (`base:` names layer 1).
3. `courts/<court>/judges/<slug>.yaml`: one judge's standing order, applied at build time.

## Use

```sh
just judges sources                                  # the courts a feed covers
just judges sync cacd                                # read the feed, write courts/.../central-district/judges/*.yaml
just judges sync cacd --cached                       # the same, from the documents the last sync fetched
just judges list cacd                                # one line a judge: the facts read ("?" marks an unverified one)
just judges show cacd aenlle-rocha-fernando          # the facts, their sentences and sources, and what they change
just judges check cacd                               # every profile against every doc type on the model

just build cacd motion-brief brief.md brief.pdf --judge aenlle-rocha-fernando
just build cacd motion-brief reply.md reply.pdf --judge aenlle-rocha-fernando --paper reply --engine docx
```

A filing can name its judge instead of the option, in its frontmatter:

```yaml
judge_profile: aenlle-rocha-fernando      # the profile's slug (`judge` is a display name in some courts' inputs)
paper: reply                               # memorandum (default), opposition or reply: which limit applies
word_limit_order_date: "March 3, 2026"     # the date of the order that set the limit, for the certificate
```

`fb build` without a judge is unchanged.

## The source is an index; the court's document is the authority

The feed is LawSnap's per-court JSON (`data/judge-sources.json`: `https://lawsnap.com/data/<court>-judges.json`, the data behind pages such as `https://lawsnap.com/courts/ca-cd/judges/aenlle-rocha-fernando/`). For each judge it quotes the standing orders field by field and cites the document the court hosts.

`sync` does three things with it:

1. **Reads typed facts** out of the quoted text (`tools/fb/src/judges/extract.rs`). The feed's hard-wrapped lines are joined first: a line break ends a sentence only after sentence punctuation, at a blank line or at a list item. A number is taken only beside its unit (`14 point`, `12-font`, `size 13`, `7,000 words`, `25 double-spaced pages`) in a sentence that states a rule (`no less than`, `shall not exceed`, `no ... shall exceed`, `cannot exceed`, `shall not total more than`, `N pages or fewer`, `only`); a number whose words and digits disagree (`twenty (25)`) is none. A limit is the limit of each paper its subject names (`Opposition and reply briefs` gives the opposition's and the reply's; `briefs in support of and in opposition to a motion` is the memorandum, whose limit an opposition takes), never of a paper the sentence names as an object (`raised in the response`) or of another paper (supplemental, sur-reply, trial, letter briefs). A sentence that names one kind of motion (`motions for summary judgment`, `Daubert motions`, `dispositive motion`, `per expert`), or stands under a label or a heading that does (`For MSJ:`, `Motions for Summary Judgment.`), is set apart, unless it sets that kind aside (`Except for summary judgment motions, ...`). A size named in a limit (`limited to 25 pages, 12-point type font`) is required; a face only where a mandatory sentence names one face and no other. Two values for one fact are no fact, for the rest of the judge. What the reader saw and did not take goes to the profile's `review` list.
2. **Finds each sentence in the court's own document** (`verify.rs`). The cited file is fetched from the court's host (`primary_hosts`: `uscourts.gov`), read (a PDF with pdftotext, a Word file with pandoc, a court page as its text) and normalized (pleading-paper line numbers and running footers out, lines joined). Only https URLs on those hosts are fetched, redirects included, and a document whose fetch ends off them is not read. Each `sync` fetches the documents afresh (a court replaces an order at the same URL); `--cached` reuses what the last sync fetched, for development. Where a court publishes an index of a judge's current documents (`court_index`; C.D. Cal.'s Judges' Procedures API), a sentence whose cited file has been replaced is looked up in the current ones.

   A fact is `verified: true` only when its whole sentence, as one run, is in a court-hosted document: a quote the feed elided (`...`) never verifies, and an occurrence that is the tail of a longer sentence or stands under a label (the document's text before it ends in `,`, `;` or `:`) does not count. That proves the court's document holds the sentence; it does not prove the sentence's context (the section it stands in, a heading that narrows it to one kind of motion two lines up). The reader sets narrow sentences apart from the feed's text, not from the document's. A fact found in a document other than the one its own field cites says where, in `matched`: `other-cited` (another document the feed cites for the judge) or `court-index` (a document the court's index lists for the judge); `show` prints it. Read such a sentence in its document before relying on it.
3. **Writes one profile a judge**: the facts, each with its sentence, its source URL and the hash of the document it was found in, and a checklist of the topics a render cannot enforce.

What is stored is the court's text and the facts read from it. The feed's own commentary (its summaries and "key traps") is never copied. A checklist keeps only the sentences found in the court's document, with `[...]` where one that was not is left out.

## Facts

| Fact | Meaning | On the layout |
|---|---|---|
| `body.min_pt`, `body.exact_pt` | the body's type size: a floor, or exactly that | checked against `size`; never changed |
| `body.face` | a face the order mandates | checked against the template's face; never changed |
| `footnote.same_as_body` | footnotes at the body's size | sets `footnote.size` |
| `footnote.exact_pt`, `footnote.min_pt` | a footnote size: exactly that, or a floor | sets `footnote.size` (a floor only raises it) |
| `footnote.max_smaller_pt` | footnotes at most that many points under the body's | raises `footnote.size` if needed |

The footnote facts of a profile are weighed together: the footnotes take the one exact size (`same_as_body`, `exact_pt`), else the highest floor, never lower than the court's; exact sizes that disagree, or an exact size under a floor, are a `CONFLICT`. "These typeface requirements apply to footnoted material" carries the body's rule over: a floor stays a floor.
| `words.memorandum`, `words.opposition`, `words.reply` | a word limit for that paper | sets `words.limit`; the render stops over it |
| `pages.memorandum`, `pages.opposition`, `pages.reply` | a page limit for that paper | a note: the render does not count pages |
| `certificate.required` | a certificate of compliance | checked: the layout sets one |

A floor never lowers what the local rule set: "no less than 12 point" leaves a 14-point court at 14. An opposition takes the memorandum's limit unless the order gives it its own; a reply takes only a reply's.

## What a build does with them

`fb build --judge` prints one line a fact, with the sentence it rests on:

- `satisfied`: the court's layout already meets it.
- `applied`: the layout changes (the line shows the source URL, as do `CONFLICT` and `UNVERIFIED`).
- `note`: the render cannot enforce it; the filer checks.
- `CONFLICT`: the order asks for what this layer does not change (a body size or a face other than the court layout's). The build stops: that judge needs a layout of their own, written and reviewed like any other.
- `UNVERIFIED`: the fact would change the layout and its sentence was not found in the court's document. The build stops; read the order at the URL given, then pass `--allow-unverified`.

Then it writes the court's resolved layout, with the facts applied, as a doc folder of its own under the gitignored `out/judges/<alias>/<slug>/<doctype>/` (`typst/layout.yaml`, a typst entry point on the shared document model with the court template's face, and the latex and docx engines `fb engines gen` generates), and renders the filing there with the usual renderer. No court folder and no shared library is touched, so no committed output can change.

A doc type must be on the shared document model (`typst/layout.yaml`); a hand-written template has no layer to overlay.

### The certificate under a judge's limit

Where a court's certificate names the basis of its word limit, `courts/<court>/judges/_court.yaml` says how it names a limit an order set, with the rule. C.D. Cal. L.R. 11-6.2 gives both forms: the count "complies with the word limit of L.R. 11-6.1", or it "complies with the word limit set by court order dated [date]". Under a judge's own limit:

- with `word_limit_order_date` in the frontmatter, the certificate cites the order;
- without it, a limit under the local rule's keeps the local rule's form (a count under the lower limit meets both) and the build notes it; a limit over the local rule's stops the build until the date is given.

## Limits

- The reader models type sizes, word and page limits and the certificate of compliance. Other formatting an order may require (the line spacing of footnotes, margins, a notice in bold, words in the caption) is not modeled: it shows only in the quoted sentences and the checklist.
- A body size or a face other than the court layout's is a `CONFLICT`, not a change: line pitch, pleading lines and headings all hang on the body's size, so that judge needs a reviewed layout of their own. `just judges check <alias>` lists them.
- Only what a feed's fields state is read. A judge with no profile facts ("the feed states no type size or length") gets the court's layout unchanged: that is not a finding that the judge has no requirements.
- `verified` proves the sentence is in a court-hosted document, not that the reader took its context right: a fact applied to a filing rests on one sentence, so `show` it and read it in the order.
- A profile is as current as its last `sync`. `sync` again before a filing; a requirement the judge changed since shows up as a fact that no longer verifies.
- Page limits are notes, not checks.
- The checklist (hearing days, proposed orders by email, chambers copies, sealing) is for a person to read: the render enforces none of it.
- These profiles are not legal advice. Read the judge's order before you file.
