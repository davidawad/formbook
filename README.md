# formbook

**Court-filing templates for markdown-first lawyers: write your brief in markdown, get a PDF that meets the court's rules, checked against a real filed example.**

![markdown input, formbook's rendered cover page, and the cover page of the brief actually filed with the court](docs/showcase/hero.png)

formbook is an open collection of court-filing templates, one folder per court and document type (opening brief, complaint, motion brief, and so on). Templates are written in [Typst](https://typst.app) and take markdown with a YAML header; the template generates the cover or caption, tables of contents and authorities, spacing, fonts, certificates and signature block that the court's rules call for.

Every template is checked against public record: each folder's `usage/` carries a real filed exemplar PDF (`FILED-EXAMPLE-*.pdf`, with its source URL in `SOURCE.md`), a markdown input (`INPUT-*.md`) and our rendered output PDF (`OUTPUT-*.typst.pdf`). `just overlay <folder>` lays our render over the filed exemplar as a red/blue overlay PDF (generated on demand into the gitignored `.overlay/`, not committed). As of this checkout:

- 479 folders have a Typst template (`typst/main.typ`), across 233 courts (federal, state, bankruptcy, and the U.S. Supreme Court).
- 453 folders have at least one filed exemplar PDF (558 PDFs in all).
- More pictures, and the command that regenerates each: [docs/showcase.md](docs/showcase.md). Per-court progress is in the [index](#index) at the bottom.

These templates are not legal advice and do not check your arguments or citations. Verify every output against the court's current rules before you file; the court index below marks what is finished and what is still in progress.

## Contribute to open access to the law

Anyone can point their own AI agent at this repo to add courts and document types. Work is split into small units (one court, one document type) listed in `data/worklist.json`; you take one, build it against a real public exemplar, and open a PR. Paste this into Claude Code, Codex, or any agent with a shell and git:

> Clone github.com/davidawad/formbook and read CONTRIBUTING.md and AGENTS.md. Run `sh tools/bootstrap.sh`, then `just contribute pick`. Claim the unit it gives you with `just contribute claim <id>`, do exactly what `just contribute brief <id>` says inside the claimed worktree, make `just contribute verify <id>` pass, then `just contribute submit <id>`. Use only public court records, record every source URL, and look at every rendered page before submitting. If you are blocked on a decision only a human can make, stop and say so in the PR.

The loop that prompt runs:

```sh
just contribute pick            # get a unit; you take the one you are given
just contribute claim <id>      # atomic claim (branch contrib/<id>, or a draft PR from a fork)
just contribute brief <id>      # prints the exact task
just contribute verify <id>     # mechanical floor: layout, renders, exemplar source
just contribute submit <id>     # reruns verify, opens the PR
```

**The agent skill.** [`skills/formbook`](skills/formbook/SKILL.md) teaches an agent to use these templates (find the court, start from a sample, render, look at every page) and to write a new one when a court or document type is missing. To install it for Claude Code, symlink it into a skills directory:

```sh
mkdir -p ~/.claude/skills && ln -s "$PWD/skills/formbook" ~/.claude/skills/formbook   # every project
mkdir -p .claude/skills && ln -s "$PWD/skills/formbook" .claude/skills/formbook       # one project
```

For other agents (Codex, Cursor, a plain LLM with a shell), point them at `skills/formbook/SKILL.md`, for example "Read skills/formbook/SKILL.md and follow it". Details: [skills/README.md](skills/README.md). Full contribution rules, quality bar and review process: [CONTRIBUTING.md](CONTRIBUTING.md).

## Use a template

Needs `typst`, poppler, `jq`, `just` and `cargo` (it builds `tools/fb`, which runs every recipe) on your PATH. On Linux, `sh tools/bootstrap.sh` installs the pinned toolchain without root (its micromamba download is linux-64 only; on macOS install typst, poppler, jq and just with Homebrew instead; the templates rendered here with typst 0.15.1).

```sh
export PATH="$HOME/.local/share/formbook/env/bin:$PATH"                 # if you used bootstrap.sh
just find ca1                                   # court folder and the doc types that have a template
just new-filing ca1 opening-brief ./my-filing   # copies the sample markdown to ./my-filing/filing.md
# edit ./my-filing/filing.md: replace every party, fact and cite
just render-filing courts/first-circuit/court-of-appeals/opening-brief ./my-filing/filing.md ./my-filing/filing.pdf
```

Then look at every page of the PDF. Each doc type's `README.md` lists its rules, markdown contract and known gaps.

## License

GNU GPL v3.0: see [LICENSE](LICENSE).

## Using aliases programmatically

Every court's alias is its CourtListener court id (from [courts-db](https://github.com/freelawproject/courts-db)). `data/index.json` maps alias to folder path, and each court folder holds a `court.json` with the same metadata.

```sh
jq -r '.courts.casd.path' data/index.json        # courts/ninth-circuit/california/federal/southern-district
jq -r '.legacy_aliases.calsuppctsd' data/index.json   # calsuperct-sandiego
```

`calsuperct-sandiego` is the one alias that is not a CourtListener id (a county subdivision of `calsuperct`).

## Building a template

Every court template follows the same eval loop, defined in [docs/EVAL-LOOP.md](docs/EVAL-LOOP.md): content gate, per-requirement rule checks, a recorded visual review of every page, and a second structurally different sample. The reference implementation is [courts/ninth-circuit/court-of-appeals](courts/ninth-circuit/court-of-appeals/README.md) (`tools/render.sh`, `tools/check.sh`, `tools/check-selftest.sh`).

## Index

<!-- index:start -->
## Supreme Court of the United States

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [Supreme Court of the United States](courts/supreme-court-of-the-united-states) | `scotus` | in progress | — | — | — | 14 |

## Federal Circuit and feeder courts

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [Court of Appeals for the Federal Circuit](courts/federal-circuit/court-of-appeals) | `cafc` | up for review | — | — | — | 14 |
| [United States Court of Federal Claims](courts/federal-circuit/court-of-federal-claims) | `uscfc` | up for review | — | — | — | 14 |
| [United States Court of International Trade](courts/federal-circuit/court-of-international-trade) | `cit` | up for review | — | — | — | 14 |
| [United States Court of Veteran Appeals](courts/federal-circuit/court-of-veteran-appeals) | `cavc` | up for review | — | — | — | 14 |
| [Patent Trial and Appeal Board](courts/federal-circuit/patent-trial-and-appeal-board) | `ptab` | in progress | — | — | — | 14 |
| [Trademark Trial and Appeal Board](courts/federal-circuit/trademark-trial-and-appeal-board) | `ttab` | in progress | — | — | — | 14 |

## Military courts

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [U S Air Force Court of Criminal Appeals](courts/military/air-force-court-of-criminal-appeals) | `afcca` | up for review | — | — | — | 14 |
| [U S Army Court of Criminal Appeals](courts/military/army-court-of-criminal-appeals) | `acca` | up for review | — | — | — | 14 |
| [U S Coast Guard Court of Criminal Appeals](courts/military/coast-guard-court-of-criminal-appeals) | `uscgcoca` | up for review | — | — | — | 14 |
| [United States Court of Appeals For The Armed Forces](courts/military/court-of-appeals-for-the-armed-forces) | `armfor` | up for review | — | — | — | 14 |
| [United States Court of Military Commission Review](courts/military/court-of-military-commission-review) | `mc` | up for review | — | — | — | 14 |
| [U S Navy Marine Corps Court of Criminal Appeals](courts/military/navy-marine-corps-court-of-criminal-appeals) | `nmcca` | in progress | — | — | — | 0 |

## National courts and tribunals

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Department of Justice Board of Immigration Appeals](courts/national/board-of-immigration-appeals) | `bia` | up for review | — | — | — | 14 |
| [United States Foreign Intelligence Surveillance Court](courts/national/foreign-intelligence-surveillance-court) | `fisc` | up for review | — | — | — | 14 |
| [United States Foreign Intelligence Surveillance Court of Review](courts/national/foreign-intelligence-surveillance-court-of-review) | `fiscr` | up for review | — | — | — | 14 |
| [United States Judicial Panel on Multidistrict Litigation](courts/national/judicial-panel-on-multidistrict-litigation) | `jpml` | up for review | — | — | — | 14 |
| [United States Tax Court](courts/national/tax-court) | `tax` | up for review | — | — | — | 14 |

## First Circuit

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Appellate Panel of The First Circuit](courts/first-circuit/bankruptcy-appellate-panel) | `bap1` | up for review | — | — | — | 14 |
| [Court of Appeals for the First Circuit](courts/first-circuit/court-of-appeals) | `ca1` | up for review | — | — | — | 14 |

### Maine

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Maine](courts/first-circuit/maine/federal/bankruptcy-district) | `meb` | up for review | — | — | — | 14 |
| [District Court, D. Maine](courts/first-circuit/maine/federal/district) | `med` | up for review | — | — | — | 14 |
| [Supreme Judicial Court of Maine](courts/first-circuit/maine/state/supreme-judicial-court) | `me` | in progress | — | — | — | 14 |

### Massachusetts

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Massachusetts](courts/first-circuit/massachusetts/federal/bankruptcy-district) | `mab` | up for review | — | — | — | 14 |
| [District Court, D. Massachusetts](courts/first-circuit/massachusetts/federal/district) | `mad` | up for review | — | — | — | 14 |
| [Massachusetts Appeals Court](courts/first-circuit/massachusetts/state/appeals-court) | `massappct` | in progress | — | — | — | 14 |
| [Massachusetts Appellate Tax Board](courts/first-circuit/massachusetts/state/appellate-tax-board) | `masstaxbd` | todo | — | — | — | 0 |
| [Massachusetts Department of Industrial Accidents](courts/first-circuit/massachusetts/state/department-of-industrial-accidents) | `maworkcompcom` | todo | — | — | — | 0 |
| [Massachusetts District Court, Appellate Division](courts/first-circuit/massachusetts/state/district-court-appellate-division) | `massdistctapp` | todo | — | — | — | 0 |
| [Massachusetts Supreme Judicial Court](courts/first-circuit/massachusetts/state/supreme-judicial-court) | `mass` | in progress | — | — | — | 14 |

### New Hampshire

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, D. New Hampshire](courts/first-circuit/new-hampshire/federal/bankruptcy-district) | `nhb` | up for review | — | — | — | 14 |
| [District Court, D. New Hampshire](courts/first-circuit/new-hampshire/federal/district) | `nhd` | up for review | — | — | — | 14 |
| [Supreme Court of New Hampshire](courts/first-circuit/new-hampshire/state/supreme-court) | `nh` | in progress | — | — | — | 14 |

### Puerto Rico

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Puerto Rico](courts/first-circuit/puerto-rico/federal/bankruptcy-district) | `prb` | up for review | — | — | — | 14 |
| [District Court, D. Puerto Rico](courts/first-circuit/puerto-rico/federal/district) | `prd` | up for review | — | — | — | 14 |
| [Tribunal De Apelaciones De Puerto Rico/Court of Appeals of Puerto Rico](courts/first-circuit/puerto-rico/state/court-of-appeals) | `prapp` | in progress | — | — | — | 14 |
| [Supreme Court of Puerto Rico](courts/first-circuit/puerto-rico/state/supreme-court) | `prsupreme` | in progress | — | — | — | 14 |

### Rhode Island

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Rhode Island](courts/first-circuit/rhode-island/federal/bankruptcy-district) | `rib` | up for review | — | — | — | 14 |
| [District Court, D. Rhode Island](courts/first-circuit/rhode-island/federal/district) | `rid` | up for review | — | — | — | 14 |
| [Superior Court of Rhode Island](courts/first-circuit/rhode-island/state/superior-court) | `risuperct` | todo | — | — | — | 0 |
| [Supreme Court of Rhode Island](courts/first-circuit/rhode-island/state/supreme-court) | `ri` | in progress | — | — | — | 14 |

## Second Circuit

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [Court of Appeals for the Second Circuit](courts/second-circuit/court-of-appeals) | `ca2` | up for review | — | — | — | 14 |

### Connecticut

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Connecticut](courts/second-circuit/connecticut/federal/bankruptcy-district) | `ctb` | in progress | — | — | — | 14 |
| [United States District Court for the District of Connecticut](courts/second-circuit/connecticut/federal/district) | `ctd` | up for review | — | — | — | 14 |
| [Connecticut Compensation Review Board](courts/second-circuit/connecticut/state/compensation-review-board) | `connworkcompcom` | todo | — | — | — | 0 |
| [Connecticut Court of Appeals](courts/second-circuit/connecticut/state/court-of-appeals) | `connappct` | in progress | — | — | — | 14 |
| [Connecticut Supreme Court](courts/second-circuit/connecticut/state/supreme-court) | `conn` | in progress | — | — | — | 14 |

### New York

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, E.D. New York](courts/second-circuit/new-york/federal/bankruptcy-eastern-district) | `nyeb` | up for review | — | — | — | 14 |
| [United States Bankruptcy Court, N.D. New York](courts/second-circuit/new-york/federal/bankruptcy-northern-district) | `nynb` | up for review | — | — | — | 14 |
| [United States Bankruptcy Court, S.D. New York](courts/second-circuit/new-york/federal/bankruptcy-southern-district) | `nysb` | in progress | — | — | — | 14 |
| [United States Bankruptcy Court, W.D. New York](courts/second-circuit/new-york/federal/bankruptcy-western-district) | `nywb` | up for review | — | — | — | 14 |
| [District Court, E.D. New York](courts/second-circuit/new-york/federal/eastern-district) | `nyed` | up for review | — | — | — | 14 |
| [District Court, N.D. New York](courts/second-circuit/new-york/federal/northern-district) | `nynd` | up for review | — | — | — | 14 |
| [District Court, S.D. New York](courts/second-circuit/new-york/federal/southern-district) | `nysd` | up for review | — | — | — | 14 |
| [District Court, W.D. New York](courts/second-circuit/new-york/federal/western-district) | `nywd` | up for review | — | — | — | 14 |
| [Appellate Terms of the Supreme Court of New York](courts/second-circuit/new-york/state/appellate-terms-of-the-supreme-court) | `nyappterm` | in progress | — | — | — | 14 |
| [New York Commission of Appeals](courts/second-circuit/new-york/state/commission-of-appeals) | `nycommnapp` | todo | — | — | — | 0 |
| [Court for the Trial of Impeachments](courts/second-circuit/new-york/state/court-for-the-trial-of-impeachments) | `nyimpct` | todo | — | — | — | 0 |
| [New York Court of Appeals](courts/second-circuit/new-york/state/court-of-appeals) | `ny` | in progress | — | — | — | 14 |
| [The Four Departments of the Appellate Division](courts/second-circuit/new-york/state/four-departments-of-the-appellate-division) | `nyappdiv` | in progress | — | — | — | 14 |
| [Saratoga Chancery Court](courts/second-circuit/new-york/state/saratoga-chancery-court) | `nychanctsara` | todo | — | — | — | 0 |

### Vermont

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Vermont](courts/second-circuit/vermont/federal/bankruptcy-district) | `vtb` | up for review | — | — | — | 14 |
| [District Court, D. Vermont](courts/second-circuit/vermont/federal/district) | `vtd` | up for review | — | — | — | 14 |
| [Supreme Court of Vermont](courts/second-circuit/vermont/state/supreme-court) | `vt` | in progress | — | — | — | 14 |

## Third Circuit

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [Court of Appeals for the Third Circuit](courts/third-circuit/court-of-appeals) | `ca3` | up for review | — | — | — | 14 |

### Delaware

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Delaware](courts/third-circuit/delaware/federal/bankruptcy-district) | `deb` | up for review | — | — | — | 14 |
| [United States District Court for the District of Delaware](courts/third-circuit/delaware/federal/district) | `ded` | up for review | — | — | — | 14 |
| [Delaware Court of Chancery](courts/third-circuit/delaware/state/court-of-chancery) | `delch` | todo | — | — | — | 0 |
| [Court on the Judiciary of Delaware](courts/third-circuit/delaware/state/court-on-the-judiciary) | `deljudct` | todo | — | — | — | 0 |
| [Delaware Family Court](courts/third-circuit/delaware/state/family-court) | `delfamct` | todo | — | — | — | 0 |
| [Delaware Supreme Court](courts/third-circuit/delaware/state/supreme-court) | `del` | in progress | — | — | — | 14 |

### New Jersey

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, D. New Jersey](courts/third-circuit/new-jersey/federal/bankruptcy-district) | `njb` | up for review | — | — | — | 14 |
| [District Court, D. New Jersey](courts/third-circuit/new-jersey/federal/district) | `njd` | up for review | — | — | — | 14 |
| [Supreme Court of New Jersey](courts/third-circuit/new-jersey/state/supreme-court) | `nj` | in progress | — | — | — | 14 |
| [New Jersey Tax Court](courts/third-circuit/new-jersey/state/tax-court) | `njtaxct` | todo | — | — | — | 0 |

### Pennsylvania

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, E.D. Pennsylvania](courts/third-circuit/pennsylvania/federal/bankruptcy-eastern-district) | `paeb` | up for review | — | — | — | 14 |
| [United States Bankruptcy Court, M.D. Pennsylvania](courts/third-circuit/pennsylvania/federal/bankruptcy-middle-district) | `pamb` | up for review | — | — | — | 14 |
| [United States Bankruptcy Court, W.D. Pennsylvania](courts/third-circuit/pennsylvania/federal/bankruptcy-western-district) | `pawb` | up for review | — | — | — | 14 |
| [District Court, E.D. Pennsylvania](courts/third-circuit/pennsylvania/federal/eastern-district) | `paed` | up for review | — | — | — | 14 |
| [District Court, M.D. Pennsylvania](courts/third-circuit/pennsylvania/federal/middle-district) | `pamd` | up for review | — | — | — | 14 |
| [District Court, W.D. Pennsylvania](courts/third-circuit/pennsylvania/federal/western-district) | `pawd` | up for review | — | — | — | 14 |
| [Commonwealth Court of Pennsylvania](courts/third-circuit/pennsylvania/state/commonwealth-court) | `pacommwct` | in progress | — | — | — | 14 |
| [Court of Judicial Discipline of Pennsylvania](courts/third-circuit/pennsylvania/state/court-of-judicial-discipline) | `cjdpa` | in progress | — | — | — | 0 |
| [Superior Court of Pennsylvania](courts/third-circuit/pennsylvania/state/superior-court) | `pasuperct` | in progress | — | — | — | 14 |
| [Supreme Court of Pennsylvania](courts/third-circuit/pennsylvania/state/supreme-court) | `pa` | in progress | — | — | — | 14 |

### Virgin Islands

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Virgin Islands](courts/third-circuit/virgin-islands/federal/bankruptcy-district) | `vib` | up for review | — | — | — | 14 |
| [District Court, Virgin Islands](courts/third-circuit/virgin-islands/federal/district) | `vid` | up for review | — | — | — | 14 |

## Fourth Circuit

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [Court of Appeals for the Fourth Circuit](courts/fourth-circuit/court-of-appeals) | `ca4` | up for review | — | — | — | 14 |

### Maryland

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Maryland](courts/fourth-circuit/maryland/federal/bankruptcy-district) | `mdb` | in progress | — | — | — | 0 |
| [District Court, D. Maryland](courts/fourth-circuit/maryland/federal/district) | `mdd` | in progress | — | — | — | 0 |
| [Court of Appeals of Maryland](courts/fourth-circuit/maryland/state/court-of-appeals) | `md` | in progress | — | — | — | 14 |
| [Court of Special Appeals of Maryland](courts/fourth-circuit/maryland/state/court-of-special-appeals) | `mdctspecapp` | in progress | — | — | — | 14 |

### North Carolina

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, E.D. North Carolina](courts/fourth-circuit/north-carolina/federal/bankruptcy-eastern-district) | `nceb` | in progress | — | — | — | 0 |
| [United States Bankruptcy Court, M.D. North Carolina](courts/fourth-circuit/north-carolina/federal/bankruptcy-middle-district) | `ncmb` | in progress | — | — | — | 0 |
| [United States Bankruptcy Court, W.D. North Carolina](courts/fourth-circuit/north-carolina/federal/bankruptcy-western-district) | `ncwb` | in progress | — | — | — | 0 |
| [District Court, E.D. North Carolina](courts/fourth-circuit/north-carolina/federal/eastern-district) | `nced` | in progress | — | — | — | 0 |
| [District Court, M.D. North Carolina](courts/fourth-circuit/north-carolina/federal/middle-district) | `ncmd` | in progress | — | — | — | 0 |
| [District Court, W.D. North Carolina](courts/fourth-circuit/north-carolina/federal/western-district) | `ncwd` | in progress | — | — | — | 0 |
| [Court of Appeals of North Carolina](courts/fourth-circuit/north-carolina/state/court-of-appeals) | `ncctapp` | in progress | — | — | — | 14 |
| [North Carolina Industrial Commission](courts/fourth-circuit/north-carolina/state/industrial-commission) | `ncworkcompcom` | todo | — | — | — | 0 |
| [Superior Court of North Carolina](courts/fourth-circuit/north-carolina/state/superior-court) | `ncsuperct` | in progress | — | — | — | 14 |
| [Supreme Court of North Carolina](courts/fourth-circuit/north-carolina/state/supreme-court) | `nc` | in progress | — | — | — | 14 |

### South Carolina

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, D. South Carolina](courts/fourth-circuit/south-carolina/federal/bankruptcy-district) | `scb` | in progress | — | — | — | 0 |
| [District Court, D. South Carolina](courts/fourth-circuit/south-carolina/federal/district) | `scd` | in progress | — | — | — | 0 |
| [Court of Appeals of South Carolina](courts/fourth-circuit/south-carolina/state/court-of-appeals) | `scctapp` | in progress | — | — | — | 14 |
| [Court of Chancery of South Carolina](courts/fourth-circuit/south-carolina/state/court-of-chancery) | `ctchansc` | todo | — | — | — | 0 |
| [Supreme Court of South Carolina](courts/fourth-circuit/south-carolina/state/supreme-court) | `sc` | in progress | — | — | — | 14 |

### Virginia

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, E.D. Virginia](courts/fourth-circuit/virginia/federal/bankruptcy-eastern-district) | `vaeb` | in progress | — | — | — | 0 |
| [United States Bankruptcy Court, W.D. Virginia](courts/fourth-circuit/virginia/federal/bankruptcy-western-district) | `vawb` | in progress | — | — | — | 0 |
| [District Court, E.D. Virginia](courts/fourth-circuit/virginia/federal/eastern-district) | `vaed` | in progress | — | — | — | 0 |
| [District Court, W.D. Virginia](courts/fourth-circuit/virginia/federal/western-district) | `vawd` | in progress | — | — | — | 0 |
| [Court of Appeals of Virginia](courts/fourth-circuit/virginia/state/court-of-appeals) | `vactapp` | in progress | — | — | — | 14 |
| [Supreme Court of Virginia](courts/fourth-circuit/virginia/state/supreme-court) | `va` | in progress | — | — | — | 14 |

### West Virginia

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States District Court, N.D. West Virginia](courts/fourth-circuit/west-virginia/federal/bankruptcy-northern-district) | `wvnb` | in progress | — | — | — | 0 |
| [United States Bankruptcy Court, S.D. West Virginia](courts/fourth-circuit/west-virginia/federal/bankruptcy-southern-district) | `wvsb` | in progress | — | — | — | 0 |
| [District Court, N.D. West Virginia](courts/fourth-circuit/west-virginia/federal/northern-district) | `wvnd` | in progress | — | — | — | 0 |
| [District Court, S.D. West Virginia](courts/fourth-circuit/west-virginia/federal/southern-district) | `wvsd` | in progress | — | — | — | 0 |
| [Intermediate Court of Appeals of West Virginia](courts/fourth-circuit/west-virginia/state/intermediate-court-of-appeals) | `wvactapp` | in progress | — | — | — | 14 |
| [West Virginia Supreme Court](courts/fourth-circuit/west-virginia/state/supreme-court) | `wva` | in progress | — | — | — | 14 |

## Fifth Circuit

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [Court of Appeals for the Fifth Circuit](courts/fifth-circuit/court-of-appeals) | `ca5` | up for review | — | — | — | 14 |

### Louisiana

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, E.D. Louisiana](courts/fifth-circuit/louisiana/federal/bankruptcy-eastern-district) | `laeb` | in progress | — | — | — | 0 |
| [United States Bankruptcy Court, M.D. Louisiana](courts/fifth-circuit/louisiana/federal/bankruptcy-middle-district) | `lamb` | in progress | — | — | — | 0 |
| [United States Bankruptcy Court, W.D. Louisiana](courts/fifth-circuit/louisiana/federal/bankruptcy-western-district) | `lawb` | in progress | — | — | — | 0 |
| [United States District Court Eastern District of Louisiana](courts/fifth-circuit/louisiana/federal/eastern-district) | `laed` | up for review | — | — | — | 14 |
| [District Court, M.D. Louisiana](courts/fifth-circuit/louisiana/federal/middle-district) | `lamd` | up for review | — | — | — | 14 |
| [District Court, W.D. Louisiana](courts/fifth-circuit/louisiana/federal/western-district) | `lawd` | up for review | — | — | — | 14 |
| [Louisiana Court of Appeal](courts/fifth-circuit/louisiana/state/court-of-appeal) | `lactapp` | in progress | — | — | — | 14 |
| [Supreme Court of Louisiana](courts/fifth-circuit/louisiana/state/supreme-court) | `la` | in progress | — | — | — | 14 |

### Mississippi

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, N.D. Mississippi](courts/fifth-circuit/mississippi/federal/bankruptcy-northern-district) | `msnb` | in progress | — | — | — | 0 |
| [United States Bankruptcy Court, S.D. Mississippi](courts/fifth-circuit/mississippi/federal/bankruptcy-southern-district) | `mssb` | in progress | — | — | — | 0 |
| [District Court, N.D. Mississippi](courts/fifth-circuit/mississippi/federal/northern-district) | `msnd` | up for review | — | — | — | 14 |
| [District Court, S.D. Mississippi](courts/fifth-circuit/mississippi/federal/southern-district) | `mssd` | up for review | — | — | — | 14 |
| [Mississippi Chancery Courts](courts/fifth-circuit/mississippi/state/chancery-courts) | `misschanceryct` | in progress | — | — | — | 0 |
| [Court of Appeals of Mississippi](courts/fifth-circuit/mississippi/state/court-of-appeals) | `missctapp` | in progress | — | — | — | 14 |
| [Mississippi Supreme Court](courts/fifth-circuit/mississippi/state/supreme-court) | `miss` | in progress | — | — | — | 14 |

### Texas

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, E.D. Texas](courts/fifth-circuit/texas/federal/bankruptcy-eastern-district) | `txeb` | in progress | — | — | — | 0 |
| [United States Bankruptcy Court, N.D. Texas](courts/fifth-circuit/texas/federal/bankruptcy-northern-district) | `txnb` | in progress | — | — | — | 0 |
| [United States Bankruptcy Court, S.D. Texas](courts/fifth-circuit/texas/federal/bankruptcy-southern-district) | `txsb` | in progress | — | — | — | 0 |
| [United States Bankruptcy Court, W.D. Texas](courts/fifth-circuit/texas/federal/bankruptcy-western-district) | `txwb` | in progress | — | — | — | 0 |
| [District Court, E.D. Texas](courts/fifth-circuit/texas/federal/eastern-district) | `txed` | in progress | — | — | — | 0 |
| [District Court, N.D. Texas](courts/fifth-circuit/texas/federal/northern-district) | `txnd` | in progress | — | — | — | 0 |
| [District Court, S.D. Texas](courts/fifth-circuit/texas/federal/southern-district) | `txsd` | in progress | — | — | — | 0 |
| [District Court, W.D. Texas](courts/fifth-circuit/texas/federal/western-district) | `txwd` | in progress | — | — | — | 0 |
| [Court of Civil Appeals of Texas](courts/fifth-circuit/texas/state/court-of-civil-appeals) | `texapp` | in progress | — | — | — | 14 |
| [Court of Criminal Appeals of Texas](courts/fifth-circuit/texas/state/court-of-criminal-appeals) | `texcrimapp` | in progress | — | — | — | 14 |
| [Texas Court of Review Tribunal](courts/fifth-circuit/texas/state/court-of-review-tribunal) | `texrevtrib` | todo | — | — | — | 0 |
| [Texas Judicial Panel on Multidistrict Litigation](courts/fifth-circuit/texas/state/judicial-panel-on-multidistrict-litigation) | `texjpml` | in progress | — | — | — | 14 |
| [Texas Special Court of Review](courts/fifth-circuit/texas/state/special-court-of-review) | `texreview` | in progress | — | — | — | 14 |
| [Texas Supreme Court](courts/fifth-circuit/texas/state/supreme-court) | `tex` | in progress | — | — | — | 14 |

## Sixth Circuit

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Appellate Panel of The Sixth Circuit](courts/sixth-circuit/bankruptcy-appellate-panel) | `bap6` | up for review | — | — | — | 14 |
| [Court of Appeals for the Sixth Circuit](courts/sixth-circuit/court-of-appeals) | `ca6` | up for review | — | — | — | 14 |

### Kentucky

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, E.D. Kentucky](courts/sixth-circuit/kentucky/federal/bankruptcy-eastern-district) | `kyeb` | in progress | — | — | — | 14 |
| [United States Bankruptcy Court, W.D. Kentucky](courts/sixth-circuit/kentucky/federal/bankruptcy-western-district) | `kywb` | in progress | — | — | — | 0 |
| [District Court, E.D. Kentucky](courts/sixth-circuit/kentucky/federal/eastern-district) | `kyed` | in progress | — | — | — | 0 |
| [District Court, W.D. Kentucky](courts/sixth-circuit/kentucky/federal/western-district) | `kywd` | up for review | — | — | — | 14 |
| [Court of Appeals of Kentucky](courts/sixth-circuit/kentucky/state/court-of-appeals) | `kyctapp` | in progress | — | — | — | 14 |
| [Kentucky Supreme Court](courts/sixth-circuit/kentucky/state/supreme-court) | `ky` | in progress | — | — | — | 14 |

### Michigan

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, E.D. Michigan](courts/sixth-circuit/michigan/federal/bankruptcy-eastern-district) | `mieb` | in progress | — | — | — | 0 |
| [United States Bankruptcy Court, W.D. Michigan](courts/sixth-circuit/michigan/federal/bankruptcy-western-district) | `miwb` | up for review | — | — | — | 14 |
| [District Court, E.D. Michigan](courts/sixth-circuit/michigan/federal/eastern-district) | `mied` | in progress | — | — | — | 0 |
| [District Court, W.D. Michigan](courts/sixth-circuit/michigan/federal/western-district) | `miwd` | in progress | — | — | — | 0 |
| [Michigan Court of Appeals](courts/sixth-circuit/michigan/state/court-of-appeals) | `michctapp` | in progress | — | — | — | 14 |
| [Michigan Supreme Court](courts/sixth-circuit/michigan/state/supreme-court) | `mich` | in progress | — | — | — | 14 |

### Ohio

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, N.D. Ohio](courts/sixth-circuit/ohio/federal/bankruptcy-northern-district) | `ohnb` | in progress | — | — | — | 0 |
| [United States Bankruptcy Court, S.D. Ohio](courts/sixth-circuit/ohio/federal/bankruptcy-southern-district) | `ohsb` | in progress | — | — | — | 0 |
| [District Court, N.D. Ohio](courts/sixth-circuit/ohio/federal/northern-district) | `ohnd` | up for review | — | — | — | 14 |
| [District Court, S.D. Ohio](courts/sixth-circuit/ohio/federal/southern-district) | `ohsd` | in progress | — | — | — | 0 |
| [Ohio Court of Appeals](courts/sixth-circuit/ohio/state/court-of-appeals) | `ohioctapp` | in progress | — | — | — | 14 |
| [Ohio Court of Claims](courts/sixth-circuit/ohio/state/court-of-claims) | `ohioctcl` | in progress | — | — | — | 0 |
| [Ohio Supreme Court](courts/sixth-circuit/ohio/state/supreme-court) | `ohio` | in progress | — | — | — | 14 |

### Tennessee

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, E.D. Tennessee](courts/sixth-circuit/tennessee/federal/bankruptcy-eastern-district) | `tneb` | in progress | — | — | — | 0 |
| [United States Bankruptcy Court, M.D. Tennessee](courts/sixth-circuit/tennessee/federal/bankruptcy-middle-district) | `tnmb` | in progress | — | — | — | 0 |
| [United States Bankruptcy Court, W.D. Tennessee](courts/sixth-circuit/tennessee/federal/bankruptcy-western-district) | `tnwb` | in progress | — | — | — | 0 |
| [District Court, E.D. Tennessee](courts/sixth-circuit/tennessee/federal/eastern-district) | `tned` | up for review | — | — | — | 14 |
| [District Court, M.D. Tennessee](courts/sixth-circuit/tennessee/federal/middle-district) | `tnmd` | up for review | — | — | — | 14 |
| [District Court, W.D. Tennessee](courts/sixth-circuit/tennessee/federal/western-district) | `tnwd` | in progress | — | — | — | 0 |
| [Court of Appeals of Tennessee](courts/sixth-circuit/tennessee/state/court-of-appeals) | `tennctapp` | in progress | — | — | — | 14 |
| [Court of Criminal Appeals of Tennessee](courts/sixth-circuit/tennessee/state/court-of-criminal-appeals) | `tenncrimapp` | in progress | — | — | — | 14 |
| [Tennessee Supreme Court](courts/sixth-circuit/tennessee/state/supreme-court) | `tenn` | in progress | — | — | — | 14 |

## Seventh Circuit

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [Court of Appeals for the Seventh Circuit](courts/seventh-circuit/court-of-appeals) | `ca7` | up for review | — | — | — | 14 |

### Illinois

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, C.D. Illinois](courts/seventh-circuit/illinois/federal/bankruptcy-central-district) | `ilcb` | up for review | — | — | — | 14 |
| [United States Bankruptcy Court, N.D. Illinois](courts/seventh-circuit/illinois/federal/bankruptcy-northern-district) | `ilnb` | up for review | — | — | — | 14 |
| [United States Bankruptcy Court, S.D. Illinois](courts/seventh-circuit/illinois/federal/bankruptcy-southern-district) | `ilsb` | in progress | — | — | — | 14 |
| [District Court, C.D. Illinois](courts/seventh-circuit/illinois/federal/central-district) | `ilcd` | up for review | — | — | — | 14 |
| [District Court, N.D. Illinois](courts/seventh-circuit/illinois/federal/northern-district) | `ilnd` | up for review | — | — | — | 14 |
| [District Court, S.D. Illinois](courts/seventh-circuit/illinois/federal/southern-district) | `ilsd` | up for review | — | — | — | 14 |
| [Appellate Court of Illinois](courts/seventh-circuit/illinois/state/appellate-court) | `illappct` | in progress | — | — | — | 14 |
| [Illinois Supreme Court](courts/seventh-circuit/illinois/state/supreme-court) | `ill` | in progress | — | — | — | 14 |

### Indiana

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, N.D. Indiana](courts/seventh-circuit/indiana/federal/bankruptcy-northern-district) | `innb` | up for review | — | — | — | 14 |
| [United States Bankruptcy Court, S.D. Indiana](courts/seventh-circuit/indiana/federal/bankruptcy-southern-district) | `insb` | in progress | — | — | — | 14 |
| [District Court, N.D. Indiana](courts/seventh-circuit/indiana/federal/northern-district) | `innd` | up for review | — | — | — | 14 |
| [District Court, S.D. Indiana](courts/seventh-circuit/indiana/federal/southern-district) | `insd` | up for review | — | — | — | 14 |
| [Indiana Court of Appeals](courts/seventh-circuit/indiana/state/court-of-appeals) | `indctapp` | in progress | — | — | — | 14 |
| [Indiana Supreme Court](courts/seventh-circuit/indiana/state/supreme-court) | `ind` | in progress | — | — | — | 14 |
| [Indiana Tax Court](courts/seventh-circuit/indiana/state/tax-court) | `indtc` | todo | — | — | — | 0 |

### Wisconsin

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, E.D. Wisconsin](courts/seventh-circuit/wisconsin/federal/bankruptcy-eastern-district) | `wieb` | up for review | — | — | — | 14 |
| [United States Bankruptcy Court, W.D. Wisconsin](courts/seventh-circuit/wisconsin/federal/bankruptcy-western-district) | `wiwb` | in progress | — | — | — | 14 |
| [District Court, E.D. Wisconsin](courts/seventh-circuit/wisconsin/federal/eastern-district) | `wied` | up for review | — | — | — | 14 |
| [District Court, W.D. Wisconsin](courts/seventh-circuit/wisconsin/federal/western-district) | `wiwd` | up for review | — | — | — | 14 |
| [Court of Appeals of Wisconsin](courts/seventh-circuit/wisconsin/state/court-of-appeals) | `wisctapp` | in progress | — | — | — | 14 |
| [Wisconsin Supreme Court](courts/seventh-circuit/wisconsin/state/supreme-court) | `wis` | in progress | — | — | — | 14 |

## Eighth Circuit

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Appellate Panel of The Eighth Circuit](courts/eighth-circuit/bankruptcy-appellate-panel) | `bap8` | up for review | — | — | — | 14 |
| [Court of Appeals for the Eighth Circuit](courts/eighth-circuit/court-of-appeals) | `ca8` | up for review | — | — | — | 14 |

### Arkansas

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, E.D. Arkansas](courts/eighth-circuit/arkansas/federal/bankruptcy-eastern-district) | `areb` | in progress | — | — | — | 0 |
| [United States Bankruptcy Court, W.D. Arkansas](courts/eighth-circuit/arkansas/federal/bankruptcy-western-district) | `arwb` | in progress | — | — | — | 0 |
| [United States District Court for the Eastern District of Arkansas](courts/eighth-circuit/arkansas/federal/eastern-district) | `ared` | up for review | — | — | — | 14 |
| [United States District Court for the Western District of Arkansas](courts/eighth-circuit/arkansas/federal/western-district) | `arwd` | in progress | — | — | — | 0 |
| [Arkansas Court of Appeals](courts/eighth-circuit/arkansas/state/court-of-appeals) | `arkctapp` | in progress | — | — | — | 14 |
| [Arkansas Supreme Court](courts/eighth-circuit/arkansas/state/supreme-court) | `ark` | in progress | — | — | — | 14 |
| [Arkansas Workers' Compensation Commission](courts/eighth-circuit/arkansas/state/workers-compensation-commission) | `arkworkcompcom` | todo | — | — | — | 0 |

### Iowa

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, N.D. Iowa](courts/eighth-circuit/iowa/federal/bankruptcy-northern-district) | `ianb` | in progress | — | — | — | 0 |
| [United States Bankruptcy Court, S.D. Iowa](courts/eighth-circuit/iowa/federal/bankruptcy-southern-district) | `iasb` | in progress | — | — | — | 0 |
| [District Court, N.D. Iowa](courts/eighth-circuit/iowa/federal/northern-district) | `iand` | in progress | — | — | — | 0 |
| [District Court, S.D. Iowa](courts/eighth-circuit/iowa/federal/southern-district) | `iasd` | in progress | — | — | — | 0 |
| [Court of Appeals of Iowa](courts/eighth-circuit/iowa/state/court-of-appeals) | `iowactapp` | in progress | — | — | — | 14 |
| [Supreme Court of Iowa](courts/eighth-circuit/iowa/state/supreme-court) | `iowa` | in progress | — | — | — | 14 |

### Minnesota

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Minnesota](courts/eighth-circuit/minnesota/federal/bankruptcy-district) | `mnb` | up for review | — | — | — | 14 |
| [District Court, D. Minnesota](courts/eighth-circuit/minnesota/federal/district) | `mnd` | up for review | — | — | — | 14 |
| [Court of Appeals of Minnesota](courts/eighth-circuit/minnesota/state/court-of-appeals) | `minnctapp` | in progress | — | — | — | 14 |
| [Supreme Court of Minnesota](courts/eighth-circuit/minnesota/state/supreme-court) | `minn` | in progress | — | — | — | 14 |

### Missouri

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, E.D. Missouri](courts/eighth-circuit/missouri/federal/bankruptcy-eastern-district) | `moeb` | in progress | — | — | — | 14 |
| [United States Bankruptcy Court, W.D. Missouri](courts/eighth-circuit/missouri/federal/bankruptcy-western-district) | `mowb` | up for review | — | — | — | 14 |
| [District Court, E.D. Missouri](courts/eighth-circuit/missouri/federal/eastern-district) | `moed` | up for review | — | — | — | 14 |
| [District Court, W.D. Missouri](courts/eighth-circuit/missouri/federal/western-district) | `mowd` | up for review | — | — | — | 14 |
| [Missouri Court of Appeals](courts/eighth-circuit/missouri/state/court-of-appeals) | `moctapp` | in progress | — | — | — | 14 |
| [Missouri Court of Appeals, Eastern District](courts/eighth-circuit/missouri/state/court-of-appeals-eastern-district) | `moctapped` | in progress | — | — | — | 14 |
| [Missouri Court of Appeals, Southern District](courts/eighth-circuit/missouri/state/court-of-appeals-southern-district) | `moctappsd` | in progress | — | — | — | 14 |
| [Missouri Court of Appeals, Western District](courts/eighth-circuit/missouri/state/court-of-appeals-western-district) | `moctappwd` | in progress | — | — | — | 14 |
| [Supreme Court of Missouri](courts/eighth-circuit/missouri/state/supreme-court) | `mo` | in progress | — | — | — | 14 |

### Nebraska

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Nebraska](courts/eighth-circuit/nebraska/federal/bankruptcy-district) | `nebraskab` | up for review | — | — | — | 14 |
| [United States District Court, Nebraska](courts/eighth-circuit/nebraska/federal/district) | `ned` | up for review | — | — | — | 14 |
| [Nebraska Court of Appeals](courts/eighth-circuit/nebraska/state/court-of-appeals) | `nebctapp` | in progress | — | — | — | 14 |
| [Nebraska Supreme Court](courts/eighth-circuit/nebraska/state/supreme-court) | `neb` | in progress | — | — | — | 14 |

### North Dakota

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, D. North Dakota](courts/eighth-circuit/north-dakota/federal/bankruptcy-district) | `ndb` | up for review | — | — | — | 14 |
| [District Court, D. North Dakota](courts/eighth-circuit/north-dakota/federal/district) | `ndd` | up for review | — | — | — | 14 |
| [North Dakota Court of Appeals](courts/eighth-circuit/north-dakota/state/court-of-appeals) | `ndctapp` | in progress | — | — | — | 14 |
| [North Dakota Supreme Court](courts/eighth-circuit/north-dakota/state/supreme-court) | `nd` | in progress | — | — | — | 14 |

### South Dakota

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, D. South Dakota](courts/eighth-circuit/south-dakota/federal/bankruptcy-district) | `sdb` | in progress | — | — | — | 14 |
| [District Court, D. South Dakota](courts/eighth-circuit/south-dakota/federal/district) | `sdd` | up for review | — | — | — | 14 |
| [Supreme Court of South Dakota](courts/eighth-circuit/south-dakota/state/supreme-court) | `sd` | in progress | — | — | — | 14 |

## Ninth Circuit

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Appellate Panel of The Ninth Circuit](courts/ninth-circuit/bankruptcy-appellate-panel) | `bap9` | up for review | — | — | — | 14 |
| [Court of Appeals for the Ninth Circuit](courts/ninth-circuit/court-of-appeals) | `ca9` | up for review | pass | built | — | 71 |

### Alaska

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Alaska](courts/ninth-circuit/alaska/federal/bankruptcy-district) | `akb` | up for review | — | — | — | 14 |
| [United States District Court for the District of Alaska](courts/ninth-circuit/alaska/federal/district) | `akd` | up for review | — | — | — | 14 |
| [Alaska Court of Appeals](courts/ninth-circuit/alaska/state/court-of-appeals) | `alaskactapp` | in progress | — | — | — | 0 |
| [Alaska Supreme Court](courts/ninth-circuit/alaska/state/supreme-court) | `alaska` | in progress | — | — | — | 14 |

### Arizona

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Arizona](courts/ninth-circuit/arizona/federal/bankruptcy-district) | `arb` | in progress | — | — | — | 14 |
| [United States District Court for the District of Arizona](courts/ninth-circuit/arizona/federal/district) | `azd` | in progress | — | — | — | 14 |
| [Arizona Court of Appeals](courts/ninth-circuit/arizona/state/court-of-appeals) | `arizctapp` | in progress | — | — | — | 14 |
| [Arizona Supreme Court](courts/ninth-circuit/arizona/state/supreme-court) | `ariz` | in progress | — | — | — | 14 |
| [Arizona Tax Court](courts/ninth-circuit/arizona/state/tax-court) | `ariztaxct` | in progress | — | — | — | 0 |

### California

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, C.D. California](courts/ninth-circuit/california/federal/bankruptcy-central-district) | `cacb` | in progress | — | — | — | 14 |
| [United States Bankruptcy Court, E.D. California](courts/ninth-circuit/california/federal/bankruptcy-eastern-district) | `caeb` | in progress | — | — | — | 14 |
| [United States Bankruptcy Court, N.D. California](courts/ninth-circuit/california/federal/bankruptcy-northern-district) | `canb` | in progress | — | — | — | 14 |
| [United States Bankruptcy Court, S.D. California](courts/ninth-circuit/california/federal/bankruptcy-southern-district) | `casb` | in progress | — | — | — | 14 |
| [United States District Court for the Central District of California](courts/ninth-circuit/california/federal/central-district) | `cacd` | in progress | — | — | — | 14 |
| [United States District Court for the Eastern District of California](courts/ninth-circuit/california/federal/eastern-district) | `caed` | in progress | — | — | — | 14 |
| [United States District Court for the Northern District of California](courts/ninth-circuit/california/federal/northern-district) | `cand` | in progress | — | — | — | 14 |
| [United States District Court for the Southern District of California](courts/ninth-circuit/california/federal/southern-district) | `casd` | in progress | — | — | — | 14 |
| [California Court of Appeal, Fifth Appellate District](courts/ninth-circuit/california/state/court-of-appeal-fifth-district) | `calctapp5d` | in progress | — | — | — | 14 |
| [California Court of Appeal, First Appellate District](courts/ninth-circuit/california/state/court-of-appeal-first-district) | `calctapp1d` | in progress | — | — | — | 14 |
| [California Court of Appeal, Fourth Appellate District](courts/ninth-circuit/california/state/court-of-appeal-fourth-district) | `calctapp4d` | in progress | — | — | — | 14 |
| [California Court of Appeal, Second Appellate District](courts/ninth-circuit/california/state/court-of-appeal-second-district) | `calctapp2d` | in progress | — | — | — | 14 |
| [California Court of Appeal, Sixth Appellate District](courts/ninth-circuit/california/state/court-of-appeal-sixth-district) | `calctapp6d` | in progress | — | — | — | 14 |
| [California Court of Appeal, Third Appellate District](courts/ninth-circuit/california/state/court-of-appeal-third-district) | `calctapp3d` | in progress | — | — | — | 14 |
| [California Courts of Appeal](courts/ninth-circuit/california/state/courts-of-appeal) | `calctapp` | in progress | — | — | — | 14 |
| [California Superior Court](courts/ninth-circuit/california/state/superior-court) | `calsuperct` | in progress | — | — | — | 0 |
| [California Superior Court, San Diego County](courts/ninth-circuit/california/state/superior-court/san-diego-county) | `calsuperct-sandiego` | in progress | — | — | — | 0 |
| [California Superior Court, Appellate Division](courts/ninth-circuit/california/state/superior-court-appellate-division) | `calappdeptsuper` | todo | — | — | — | 0 |
| [California Supreme Court](courts/ninth-circuit/california/state/supreme-court) | `cal` | in progress | — | — | — | 14 |

### Guam

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Guam](courts/ninth-circuit/guam/federal/bankruptcy-district) | `gub` | in progress | — | — | — | 14 |
| [District Court, D. Guam](courts/ninth-circuit/guam/federal/district) | `gud` | up for review | — | — | — | 14 |
| [Supreme Court of Guam](courts/ninth-circuit/guam/state/supreme-court) | `guam` | in progress | — | — | — | 14 |

### Hawaii

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Hawaii](courts/ninth-circuit/hawaii/federal/bankruptcy-district) | `hib` | up for review | — | — | — | 14 |
| [United States District Court for the District of Hawaii](courts/ninth-circuit/hawaii/federal/district) | `hid` | up for review | — | — | — | 14 |
| [Hawaii Intermediate Court of Appeals](courts/ninth-circuit/hawaii/state/intermediate-court-of-appeals) | `hawapp` | in progress | — | — | — | 14 |
| [Hawaii State Tax Appeal Court](courts/ninth-circuit/hawaii/state/state-tax-appeal-court) | `hawtax` | in progress | — | — | — | 14 |
| [Supreme Court of Hawaii](courts/ninth-circuit/hawaii/state/supreme-court) | `haw` | in progress | — | — | — | 14 |

### Idaho

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Idaho](courts/ninth-circuit/idaho/federal/bankruptcy-district) | `idb` | in progress | — | — | — | 14 |
| [United States District Court for the District of Idaho](courts/ninth-circuit/idaho/federal/district) | `idd` | up for review | — | — | — | 14 |
| [Idaho Court of Appeals](courts/ninth-circuit/idaho/state/court-of-appeals) | `idahoctapp` | in progress | — | — | — | 14 |
| [Idaho Supreme Court](courts/ninth-circuit/idaho/state/supreme-court) | `idaho` | in progress | — | — | — | 14 |

### Montana

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Montana](courts/ninth-circuit/montana/federal/bankruptcy-district) | `mtb` | up for review | — | — | — | 14 |
| [District Court, D. Montana](courts/ninth-circuit/montana/federal/district) | `mtd` | up for review | — | — | — | 14 |
| [Montana Supreme Court](courts/ninth-circuit/montana/state/supreme-court) | `mont` | in progress | — | — | — | 14 |
| [Montana Tax Appeal Board](courts/ninth-circuit/montana/state/tax-appeal-board) | `monttc` | todo | — | — | — | 0 |

### Nevada

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Nevada](courts/ninth-circuit/nevada/federal/bankruptcy-district) | `nvb` | in progress | — | — | — | 14 |
| [District Court, D. Nevada](courts/ninth-circuit/nevada/federal/district) | `nvd` | up for review | — | — | — | 14 |
| [Court of Appeals of Nevada](courts/ninth-circuit/nevada/state/court-of-appeals) | `nevapp` | in progress | — | — | — | 14 |
| [Nevada Supreme Court](courts/ninth-circuit/nevada/state/supreme-court) | `nev` | in progress | — | — | — | 14 |

### Northern Mariana Islands

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, Northern Mariana Islands](courts/ninth-circuit/northern-mariana-islands/federal/bankruptcy-district) | `nmib` | in progress | — | — | — | 0 |
| [District Court, Northern Mariana Islands](courts/ninth-circuit/northern-mariana-islands/federal/district) | `nmid` | in progress | — | — | — | 14 |
| [Supreme Court of The Commonwealth of The Northern Mariana Islands](courts/ninth-circuit/northern-mariana-islands/state/supreme-court) | `nmi` | in progress | — | — | — | 0 |

### Oregon

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Oregon](courts/ninth-circuit/oregon/federal/bankruptcy-district) | `orb` | up for review | — | — | — | 14 |
| [District Court, D. Oregon](courts/ninth-circuit/oregon/federal/district) | `ord` | up for review | — | — | — | 14 |
| [Court of Appeals of Oregon](courts/ninth-circuit/oregon/state/court-of-appeals) | `orctapp` | in progress | — | — | — | 14 |
| [Oregon Supreme Court](courts/ninth-circuit/oregon/state/supreme-court) | `or` | in progress | — | — | — | 14 |
| [Oregon Tax Court](courts/ninth-circuit/oregon/state/tax-court) | `ortc` | todo | — | — | — | 0 |

### Washington

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, E.D. Washington](courts/ninth-circuit/washington/federal/bankruptcy-eastern-district) | `waeb` | in progress | — | — | — | 14 |
| [United States Bankruptcy Court, W.D. Washington](courts/ninth-circuit/washington/federal/bankruptcy-western-district) | `wawb` | in progress | — | — | — | 14 |
| [District Court, E.D. Washington](courts/ninth-circuit/washington/federal/eastern-district) | `waed` | in progress | — | — | — | 14 |
| [District Court, W.D. Washington](courts/ninth-circuit/washington/federal/western-district) | `wawd` | up for review | — | — | — | 14 |
| [Court of Appeals of Washington](courts/ninth-circuit/washington/state/court-of-appeals) | `washctapp` | in progress | — | — | — | 14 |
| [Washington Supreme Court](courts/ninth-circuit/washington/state/supreme-court) | `wash` | in progress | — | — | — | 14 |

### American Samoa

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [High Court of American Samoa](courts/ninth-circuit/american-samoa/state/high-court) | `amsamoa` | todo | — | — | — | 0 |

## Tenth Circuit

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Appellate Panel of The Tenth Circuit](courts/tenth-circuit/bankruptcy-appellate-panel) | `bap10` | in progress | — | — | — | 0 |
| [Court of Appeals for the Tenth Circuit](courts/tenth-circuit/court-of-appeals) | `ca10` | in progress | — | — | — | 0 |

### Colorado

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Colorado](courts/tenth-circuit/colorado/federal/bankruptcy-district) | `cob` | in progress | — | — | — | 0 |
| [United States District Court for the District of Colorado](courts/tenth-circuit/colorado/federal/district) | `cod` | in progress | — | — | — | 0 |
| [Colorado Court of Appeals](courts/tenth-circuit/colorado/state/court-of-appeals) | `coloctapp` | in progress | — | — | — | 14 |
| [Colorado Industrial Claim Appeals office](courts/tenth-circuit/colorado/state/industrial-claim-appeals-office) | `coloworkcompcom` | todo | — | — | — | 0 |
| [Colorado Supreme Court](courts/tenth-circuit/colorado/state/supreme-court) | `colo` | in progress | — | — | — | 14 |

### Kansas

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Kansas](courts/tenth-circuit/kansas/federal/bankruptcy-district) | `ksb` | in progress | — | — | — | 0 |
| [District Court, D. Kansas](courts/tenth-circuit/kansas/federal/district) | `ksd` | in progress | — | — | — | 0 |
| [Court of Appeals of Kansas](courts/tenth-circuit/kansas/state/court-of-appeals) | `kanctapp` | in progress | — | — | — | 14 |
| [Supreme Court of Kansas](courts/tenth-circuit/kansas/state/supreme-court) | `kan` | in progress | — | — | — | 14 |

### New Mexico

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, D. New Mexico](courts/tenth-circuit/new-mexico/federal/bankruptcy-district) | `nmb` | in progress | — | — | — | 0 |
| [District Court, D. New Mexico](courts/tenth-circuit/new-mexico/federal/district) | `nmd` | in progress | — | — | — | 0 |
| [New Mexico Court of Appeals](courts/tenth-circuit/new-mexico/state/court-of-appeals) | `nmctapp` | in progress | — | — | — | 14 |
| [New Mexico Supreme Court](courts/tenth-circuit/new-mexico/state/supreme-court) | `nm` | in progress | — | — | — | 14 |

### Oklahoma

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, E.D. Oklahoma](courts/tenth-circuit/oklahoma/federal/bankruptcy-eastern-district) | `okeb` | in progress | — | — | — | 0 |
| [United States Bankruptcy Court, N.D. Oklahoma](courts/tenth-circuit/oklahoma/federal/bankruptcy-northern-district) | `oknb` | in progress | — | — | — | 0 |
| [United States Bankruptcy Court, W.D. Oklahoma](courts/tenth-circuit/oklahoma/federal/bankruptcy-western-district) | `okwb` | in progress | — | — | — | 0 |
| [United States District Court for the District of Oklahoma](courts/tenth-circuit/oklahoma/federal/district) | `okd` | in progress | — | — | — | 0 |
| [United States District Court, Oklahoma Eastern](courts/tenth-circuit/oklahoma/federal/eastern-district) | `oked` | in progress | — | — | — | 0 |
| [United States District Court, Oklahoma Northern](courts/tenth-circuit/oklahoma/federal/northern-district) | `oknd` | in progress | — | — | — | 0 |
| [United States District Court, Oklahoma Western](courts/tenth-circuit/oklahoma/federal/western-district) | `okwd` | in progress | — | — | — | 0 |
| [Court of Civil Appeals of Oklahoma](courts/tenth-circuit/oklahoma/state/court-of-civil-appeals) | `oklacivapp` | in progress | — | — | — | 0 |
| [Court of Criminal Appeals of Oklahoma](courts/tenth-circuit/oklahoma/state/court-of-criminal-appeals) | `oklacrimapp` | in progress | — | — | — | 14 |
| [Court on the Judiciary of Oklahoma](courts/tenth-circuit/oklahoma/state/court-on-the-judiciary) | `oklacoj` | todo | — | — | — | 0 |
| [Oklahoma Judicial Ethics Advisory Panel](courts/tenth-circuit/oklahoma/state/judicial-ethics-advisory-panel) | `oklajeap` | todo | — | — | — | 0 |
| [Supreme Court of Oklahoma](courts/tenth-circuit/oklahoma/state/supreme-court) | `okla` | in progress | — | — | — | 14 |

### Utah

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Utah](courts/tenth-circuit/utah/federal/bankruptcy-district) | `utb` | in progress | — | — | — | 0 |
| [District Court, D. Utah](courts/tenth-circuit/utah/federal/district) | `utd` | in progress | — | — | — | 0 |
| [Court of Appeals of Utah](courts/tenth-circuit/utah/state/court-of-appeals) | `utahctapp` | in progress | — | — | — | 14 |
| [Utah Supreme Court](courts/tenth-circuit/utah/state/supreme-court) | `utah` | in progress | — | — | — | 14 |

### Wyoming

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Wyoming](courts/tenth-circuit/wyoming/federal/bankruptcy-district) | `wyb` | in progress | — | — | — | 0 |
| [District Court, D. Wyoming](courts/tenth-circuit/wyoming/federal/district) | `wyd` | in progress | — | — | — | 0 |
| [Wyoming Supreme Court](courts/tenth-circuit/wyoming/state/supreme-court) | `wyo` | in progress | — | — | — | 14 |

## Eleventh Circuit

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Court of Appeals for the Eleventh Circuit](courts/eleventh-circuit/court-of-appeals) | `ca11` | in progress | — | — | — | 0 |

### Alabama

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court for the Middle District of Alabama](courts/eleventh-circuit/alabama/federal/bankruptcy-middle-district) | `almb` | in progress | — | — | — | 0 |
| [United States Bankruptcy Court, N.D. Alabama](courts/eleventh-circuit/alabama/federal/bankruptcy-northern-district) | `alnb` | in progress | — | — | — | 0 |
| [United States Bankruptcy Court, S.D. Alabama](courts/eleventh-circuit/alabama/federal/bankruptcy-southern-district) | `alsb` | in progress | — | — | — | 0 |
| [United States District Court for the Middle District of Alabama](courts/eleventh-circuit/alabama/federal/middle-district) | `almd` | in progress | — | — | — | 0 |
| [United States District Court for the Northern District of Alabama](courts/eleventh-circuit/alabama/federal/northern-district) | `alnd` | in progress | — | — | — | 0 |
| [United States District Court for the Southern District of Alabama](courts/eleventh-circuit/alabama/federal/southern-district) | `alsd` | in progress | — | — | — | 0 |
| [Alabama Court of Civil Appeals](courts/eleventh-circuit/alabama/state/court-of-civil-appeals) | `alacivapp` | in progress | — | — | — | 14 |
| [Alabama Court of Criminal Appeals](courts/eleventh-circuit/alabama/state/court-of-criminal-appeals) | `alacrimapp` | in progress | — | — | — | 14 |
| [Supreme Court of Alabama](courts/eleventh-circuit/alabama/state/supreme-court) | `ala` | in progress | — | — | — | 14 |

### Florida

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, M.D. Florida](courts/eleventh-circuit/florida/federal/bankruptcy-middle-district) | `flmb` | in progress | — | — | — | 0 |
| [United States Bankruptcy Court, N.D. Florida](courts/eleventh-circuit/florida/federal/bankruptcy-northern-district) | `flnb` | in progress | — | — | — | 0 |
| [United States Bankruptcy Court, Southern District Florida](courts/eleventh-circuit/florida/federal/bankruptcy-southern-district) | `flsb` | in progress | — | — | — | 0 |
| [United States District Court for the Middle District of Florida](courts/eleventh-circuit/florida/federal/middle-district) | `flmd` | in progress | — | — | — | 0 |
| [United States District Court for the Northern District of Florida](courts/eleventh-circuit/florida/federal/northern-district) | `flnd` | in progress | — | — | — | 0 |
| [United States District Court for the Southern District of Florida](courts/eleventh-circuit/florida/federal/southern-district) | `flsd` | in progress | — | — | — | 0 |
| [Florida District Courts of Appeal](courts/eleventh-circuit/florida/state/district-courts-of-appeal) | `fladistctapp` | in progress | — | — | — | 14 |
| [Florida Fifth District Court of Appeal](courts/eleventh-circuit/florida/state/fifth-district-court-of-appeal) | `fladistctapp5` | in progress | — | — | — | 14 |
| [Florida First District Court of Appeal](courts/eleventh-circuit/florida/state/first-district-court-of-appeal) | `fladistctapp1` | in progress | — | — | — | 14 |
| [Florida Fourth District Court of Appeal](courts/eleventh-circuit/florida/state/fourth-district-court-of-appeal) | `fladistctapp4` | in progress | — | — | — | 14 |
| [Florida Second District Court of Appeal](courts/eleventh-circuit/florida/state/second-district-court-of-appeal) | `fladistctapp2` | in progress | — | — | — | 14 |
| [Florida Sixth District Court of Appeal](courts/eleventh-circuit/florida/state/sixth-district-court-of-appeal) | `fladistctapp6` | in progress | — | — | — | 14 |
| [Florida Supreme Court](courts/eleventh-circuit/florida/state/supreme-court) | `fla` | in progress | — | — | — | 14 |
| [Florida Third District Court of Appeal](courts/eleventh-circuit/florida/state/third-district-court-of-appeal) | `fladistctapp3` | in progress | — | — | — | 14 |

### Georgia

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, M.D. Georgia](courts/eleventh-circuit/georgia/federal/bankruptcy-middle-district) | `gamb` | in progress | — | — | — | 0 |
| [United States Bankruptcy Court, N.D. Georgia](courts/eleventh-circuit/georgia/federal/bankruptcy-northern-district) | `ganb` | in progress | — | — | — | 0 |
| [United States Bankruptcy Court, S.D. Georgia](courts/eleventh-circuit/georgia/federal/bankruptcy-southern-district) | `gasb` | in progress | — | — | — | 0 |
| [United States District Court for the Middle District of Georgia](courts/eleventh-circuit/georgia/federal/middle-district) | `gamd` | in progress | — | — | — | 0 |
| [United States District Court for the Northern District of Georgia](courts/eleventh-circuit/georgia/federal/northern-district) | `gand` | in progress | — | — | — | 0 |
| [United States District Court for the Southern District of Georgia](courts/eleventh-circuit/georgia/federal/southern-district) | `gasd` | in progress | — | — | — | 0 |
| [Georgia Court of Appeals](courts/eleventh-circuit/georgia/state/court-of-appeals) | `gactapp` | in progress | — | — | — | 14 |
| [Georgia Supreme Court](courts/eleventh-circuit/georgia/state/supreme-court) | `ga` | in progress | — | — | — | 14 |

## D.C. Circuit

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [Court of Appeals for the D.C. Circuit](courts/dc-circuit/court-of-appeals) | `cadc` | up for review | — | — | — | 14 |

### District of Columbia

| Court | Alias | Status | Typst | LaTeX | DOCX | % |
|---|---|---|---|---|---|---:|
| [United States Bankruptcy Court, District of Columbia](courts/dc-circuit/district-of-columbia/federal/bankruptcy-district) | `dcb` | up for review | — | — | — | 14 |
| [District Court, District of Columbia](courts/dc-circuit/district-of-columbia/federal/district) | `dcd` | up for review | — | — | — | 14 |
| [District of Columbia Court of Appeals](courts/dc-circuit/district-of-columbia/state/court-of-appeals) | `dc` | in progress | — | — | — | 14 |

## Unplaced

In scope but with a location the circuit map cannot place; no folder is created until a human decides.

| Alias | Name | courts-db location |
|---|---|---|
| `dakotasup` | Supreme Court of Dakota | Dakota Territory |

<!-- index:end -->

## License

GNU General Public License v3.0 (see [LICENSE](LICENSE)) for the templates, tools and skill. The filed exemplars (`courts/**/usage/FILED-EXAMPLE-*.pdf`) are public court records reproduced for reference; each folder's `SOURCE.md` names its docket and source.

## Tracker

Regenerate with `tools/tracker.sh` (the manifest and completion logic are the Rust tool `tools/fb`: `fb manifest`, `fb tracker`). Per-court detail is in [STATUS.md](STATUS.md). A court is `done` only when a human sets it in its `court.json`.

<!-- tracker:start -->
| Group | Courts | Done | Up for review | In progress | Todo | % done | % up for review | Typst pass | LaTeX pass | DOCX pass | Avg checklist % |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Supreme Court of the United States | 1 | 0 | 0 | 1 | 0 | 0.0% | 0.0% | 0 | 0 | 0 | 14.0% |
|  | 1 | 0 | 0 | 1 | 0 | 0.0% | 0.0% | 0 | 0 | 0 | 0.0% |
| Federal Circuit and feeder courts | 6 | 0 | 4 | 2 | 0 | 0.0% | 66.6% | 0 | 0 | 0 | 14.0% |
| Military courts | 6 | 0 | 5 | 1 | 0 | 0.0% | 83.3% | 0 | 0 | 0 | 11.6% |
| National courts and tribunals | 5 | 0 | 5 | 0 | 0 | 0.0% | 100.0% | 0 | 0 | 0 | 14.0% |
| First Circuit | 23 | 0 | 12 | 7 | 4 | 0.0% | 52.1% | 0 | 0 | 0 | 11.5% |
| Second Circuit | 23 | 0 | 11 | 8 | 4 | 0.0% | 47.8% | 0 | 0 | 0 | 11.5% |
| Third Circuit | 23 | 0 | 13 | 6 | 4 | 0.0% | 56.5% | 0 | 0 | 0 | 10.9% |
| Fourth Circuit | 32 | 0 | 1 | 29 | 2 | 0.0% | 3.1% | 0 | 0 | 0 | 5.2% |
| Fifth Circuit | 30 | 0 | 6 | 23 | 1 | 0.0% | 20.0% | 0 | 0 | 0 | 7.0% |
| Sixth Circuit | 30 | 0 | 7 | 23 | 0 | 0.0% | 23.3% | 0 | 0 | 0 | 7.9% |
| Seventh Circuit | 22 | 0 | 12 | 9 | 1 | 0.0% | 54.5% | 0 | 0 | 0 | 13.3% |
| Eighth Circuit | 39 | 0 | 13 | 25 | 1 | 0.0% | 33.3% | 0 | 0 | 0 | 11.1% |
| Ninth Circuit | 65 | 0 | 14 | 47 | 4 | 0.0% | 21.5% | 1 | 0 | 0 | 12.7% |
| Tenth Circuit | 34 | 0 | 0 | 31 | 3 | 0.0% | 0.0% | 0 | 0 | 0 | 4.5% |
| Eleventh Circuit | 32 | 0 | 0 | 32 | 0 | 0.0% | 0.0% | 0 | 0 | 0 | 5.6% |
| D.C. Circuit | 4 | 0 | 3 | 1 | 0 | 0.0% | 75.0% | 0 | 0 | 0 | 14.0% |
| **Total** | 376 | 0 | 106 | 246 | 24 | 0.0% | 28.1% | 1 | 0 | 0 | 9.5% |

Typst per doc type (a doc type is complete with template, sample, render and exemplar; it is up for review when its typst eval passes; per-doc-type rows in STATUS.md):

| Group | Doc types | Template | Sample | Render | Exemplar | Typst complete | % complete | Up for review |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
|  | 2 | 2 | 2 | 2 | 2 | 2 | 100.0% | 1 |
| Supreme Court of the United States | 3 | 3 | 3 | 3 | 3 | 3 | 100.0% | 0 |
| Federal Circuit and feeder courts | 13 | 13 | 13 | 13 | 13 | 13 | 100.0% | 10 |
| Military courts | 12 | 12 | 12 | 12 | 11 | 11 | 91.6% | 12 |
| National courts and tribunals | 6 | 6 | 6 | 6 | 5 | 5 | 83.3% | 6 |
| First Circuit | 26 | 26 | 26 | 26 | 25 | 25 | 96.1% | 26 |
| Second Circuit | 32 | 32 | 32 | 32 | 32 | 32 | 100.0% | 29 |
| Third Circuit | 27 | 27 | 27 | 27 | 27 | 27 | 100.0% | 27 |
| Fourth Circuit | 39 | 39 | 39 | 39 | 39 | 39 | 100.0% | 36 |
| Fifth Circuit | 46 | 46 | 46 | 46 | 46 | 46 | 100.0% | 43 |
| Sixth Circuit | 42 | 42 | 42 | 42 | 42 | 42 | 100.0% | 38 |
| Seventh Circuit | 31 | 31 | 31 | 31 | 31 | 31 | 100.0% | 28 |
| Eighth Circuit | 46 | 46 | 46 | 46 | 45 | 45 | 97.8% | 42 |
| Ninth Circuit | 72 | 72 | 72 | 72 | 70 | 70 | 97.2% | 46 |
| Tenth Circuit | 39 | 39 | 39 | 39 | 36 | 36 | 92.3% | 36 |
| Eleventh Circuit | 48 | 48 | 48 | 48 | 48 | 48 | 100.0% | 45 |
| D.C. Circuit | 7 | 7 | 7 | 7 | 7 | 7 | 100.0% | 7 |
| **Total** | 491 | 491 | 491 | 491 | 482 | 482 | 98.1% | 432 |
<!-- tracker:end -->
