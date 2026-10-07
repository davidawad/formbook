# formbook

An open formbook of court filing templates for markdown-first litigators. Templates are written in Typst (primary) and LaTeX (where a court's rules force it), organized by court, and consume markdown. Every court has a folder with its rules, real filed exemplars, sample inputs, and templates; progress is tracked per court below.

## Using aliases programmatically

Every court's alias is its CourtListener court id (from [courts-db](https://github.com/freelawproject/courts-db)). `data/index.json` maps alias to folder path, and each court folder holds a `court.json` with the same metadata.

```sh
jq -r '.courts.casd.path' data/index.json        # courts/ninth-circuit/california/federal/southern-district
jq -r '.legacy_aliases.calsuppctsd' data/index.json   # calsuperct-sandiego
```

`calsuperct-sandiego` is the one alias that is not a CourtListener id (a county subdivision of `calsuperct`).

## Tracker

Regenerate with `tools/tracker.sh` (the completion logic is in [Bend](https://github.com/HigherOrderCO/Bend), `tools/tracker.bend`). Per-court detail is in [STATUS.md](STATUS.md). A court is `done` only when a human sets it in its `court.json`.

<!-- tracker:start -->
| Group | Courts | Done | Up for review | In progress | Todo | % done | % up for review | Avg checklist % |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Supreme Court of the United States | 1 | 0 | 0 | 1 | 0 | 0.0% | 0.0% | 17.0% |
| Federal Circuit and feeder courts | 6 | 0 | 0 | 0 | 6 | 0.0% | 0.0% | 0.0% |
| Military courts | 6 | 0 | 0 | 0 | 6 | 0.0% | 0.0% | 0.0% |
| National courts and tribunals | 5 | 0 | 0 | 0 | 5 | 0.0% | 0.0% | 0.0% |
| First Circuit | 23 | 0 | 0 | 0 | 23 | 0.0% | 0.0% | 0.0% |
| Second Circuit | 23 | 0 | 0 | 0 | 23 | 0.0% | 0.0% | 0.0% |
| Third Circuit | 23 | 0 | 0 | 0 | 23 | 0.0% | 0.0% | 0.0% |
| Fourth Circuit | 32 | 0 | 0 | 0 | 32 | 0.0% | 0.0% | 0.0% |
| Fifth Circuit | 30 | 0 | 0 | 0 | 30 | 0.0% | 0.0% | 0.0% |
| Sixth Circuit | 30 | 0 | 0 | 0 | 30 | 0.0% | 0.0% | 0.0% |
| Seventh Circuit | 22 | 0 | 0 | 0 | 22 | 0.0% | 0.0% | 0.0% |
| Eighth Circuit | 39 | 0 | 0 | 0 | 39 | 0.0% | 0.0% | 0.0% |
| Ninth Circuit | 65 | 0 | 0 | 3 | 62 | 0.0% | 0.0% | 0.7% |
| Tenth Circuit | 34 | 0 | 0 | 0 | 34 | 0.0% | 0.0% | 0.0% |
| Eleventh Circuit | 32 | 0 | 0 | 0 | 32 | 0.0% | 0.0% | 0.0% |
| D.C. Circuit | 4 | 0 | 0 | 0 | 4 | 0.0% | 0.0% | 0.0% |
| **Total** | 375 | 0 | 0 | 4 | 371 | 0.0% | 0.0% | 0.1% |
<!-- tracker:end -->

## Index

<!-- index:start -->
## Supreme Court of the United States

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [Supreme Court of the United States](courts/supreme-court-of-the-united-states) | `scotus` | supreme | in progress | 17 |

## Federal Circuit and feeder courts

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [Court of Appeals for the Federal Circuit](courts/federal-circuit/court-of-appeals) | `cafc` | appellate | todo | 0 |
| [United States Court of Federal Claims](courts/federal-circuit/court-of-federal-claims) | `uscfc` | national | todo | 0 |
| [United States Court of International Trade](courts/federal-circuit/court-of-international-trade) | `cit` | national | todo | 0 |
| [United States Court of Veteran Appeals](courts/federal-circuit/court-of-veteran-appeals) | `cavc` | national | todo | 0 |
| [Patent Trial and Appeal Board](courts/federal-circuit/patent-trial-and-appeal-board) | `ptab` | agency | todo | 0 |
| [Trademark Trial and Appeal Board](courts/federal-circuit/trademark-trial-and-appeal-board) | `ttab` | agency | todo | 0 |

## Military courts

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [U S Air Force Court of Criminal Appeals](courts/military/air-force-court-of-criminal-appeals) | `afcca` | military | todo | 0 |
| [U S Army Court of Criminal Appeals](courts/military/army-court-of-criminal-appeals) | `acca` | military | todo | 0 |
| [U S Coast Guard Court of Criminal Appeals](courts/military/coast-guard-court-of-criminal-appeals) | `uscgcoca` | military | todo | 0 |
| [United States Court of Appeals For The Armed Forces](courts/military/court-of-appeals-for-the-armed-forces) | `armfor` | military | todo | 0 |
| [United States Court of Military Commission Review](courts/military/court-of-military-commission-review) | `mc` | military | todo | 0 |
| [U S Navy Marine Corps Court of Criminal Appeals](courts/military/navy-marine-corps-court-of-criminal-appeals) | `nmcca` | military | todo | 0 |

## National courts and tribunals

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Department of Justice Board of Immigration Appeals](courts/national/board-of-immigration-appeals) | `bia` | agency | todo | 0 |
| [United States Foreign Intelligence Surveillance Court](courts/national/foreign-intelligence-surveillance-court) | `fisc` | national | todo | 0 |
| [United States Foreign Intelligence Surveillance Court of Review](courts/national/foreign-intelligence-surveillance-court-of-review) | `fiscr` | national | todo | 0 |
| [United States Judicial Panel on Multidistrict Litigation](courts/national/judicial-panel-on-multidistrict-litigation) | `jpml` | national | todo | 0 |
| [United States Tax Court](courts/national/tax-court) | `tax` | national | todo | 0 |

## First Circuit

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Appellate Panel of The First Circuit](courts/first-circuit/bankruptcy-appellate-panel) | `bap1` | bap | todo | 0 |
| [Court of Appeals for the First Circuit](courts/first-circuit/court-of-appeals) | `ca1` | appellate | todo | 0 |

### Maine

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Maine](courts/first-circuit/maine/federal/bankruptcy-district) | `meb` | bankruptcy | todo | 0 |
| [District Court, D. Maine](courts/first-circuit/maine/federal/district) | `med` | district | todo | 0 |
| [Supreme Judicial Court of Maine](courts/first-circuit/maine/state/supreme-judicial-court) | `me` | state-supreme | todo | 0 |

### Massachusetts

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Massachusetts](courts/first-circuit/massachusetts/federal/bankruptcy-district) | `mab` | bankruptcy | todo | 0 |
| [District Court, D. Massachusetts](courts/first-circuit/massachusetts/federal/district) | `mad` | district | todo | 0 |
| [Massachusetts Appeals Court](courts/first-circuit/massachusetts/state/appeals-court) | `massappct` | state-appellate | todo | 0 |
| [Massachusetts Appellate Tax Board](courts/first-circuit/massachusetts/state/appellate-tax-board) | `masstaxbd` | state-appellate | todo | 0 |
| [Massachusetts Department of Industrial Accidents](courts/first-circuit/massachusetts/state/department-of-industrial-accidents) | `maworkcompcom` | state-appellate | todo | 0 |
| [Massachusetts District Court, Appellate Division](courts/first-circuit/massachusetts/state/district-court-appellate-division) | `massdistctapp` | state-appellate | todo | 0 |
| [Massachusetts Supreme Judicial Court](courts/first-circuit/massachusetts/state/supreme-judicial-court) | `mass` | state-supreme | todo | 0 |

### New Hampshire

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, D. New Hampshire](courts/first-circuit/new-hampshire/federal/bankruptcy-district) | `nhb` | bankruptcy | todo | 0 |
| [District Court, D. New Hampshire](courts/first-circuit/new-hampshire/federal/district) | `nhd` | district | todo | 0 |
| [Supreme Court of New Hampshire](courts/first-circuit/new-hampshire/state/supreme-court) | `nh` | state-supreme | todo | 0 |

### Puerto Rico

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Puerto Rico](courts/first-circuit/puerto-rico/federal/bankruptcy-district) | `prb` | bankruptcy | todo | 0 |
| [District Court, D. Puerto Rico](courts/first-circuit/puerto-rico/federal/district) | `prd` | district | todo | 0 |
| [Tribunal De Apelaciones De Puerto Rico/Court of Appeals of Puerto Rico](courts/first-circuit/puerto-rico/state/court-of-appeals) | `prapp` | state-appellate | todo | 0 |
| [Supreme Court of Puerto Rico](courts/first-circuit/puerto-rico/state/supreme-court) | `prsupreme` | state-supreme | todo | 0 |

### Rhode Island

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Rhode Island](courts/first-circuit/rhode-island/federal/bankruptcy-district) | `rib` | bankruptcy | todo | 0 |
| [District Court, D. Rhode Island](courts/first-circuit/rhode-island/federal/district) | `rid` | district | todo | 0 |
| [Superior Court of Rhode Island](courts/first-circuit/rhode-island/state/superior-court) | `risuperct` | state-appellate | todo | 0 |
| [Supreme Court of Rhode Island](courts/first-circuit/rhode-island/state/supreme-court) | `ri` | state-supreme | todo | 0 |

## Second Circuit

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [Court of Appeals for the Second Circuit](courts/second-circuit/court-of-appeals) | `ca2` | appellate | todo | 0 |

### Connecticut

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Connecticut](courts/second-circuit/connecticut/federal/bankruptcy-district) | `ctb` | bankruptcy | todo | 0 |
| [United States District Court for the District of Connecticut](courts/second-circuit/connecticut/federal/district) | `ctd` | district | todo | 0 |
| [Connecticut Compensation Review Board](courts/second-circuit/connecticut/state/compensation-review-board) | `connworkcompcom` | state-appellate | todo | 0 |
| [Connecticut Court of Appeals](courts/second-circuit/connecticut/state/court-of-appeals) | `connappct` | state-appellate | todo | 0 |
| [Connecticut Supreme Court](courts/second-circuit/connecticut/state/supreme-court) | `conn` | state-supreme | todo | 0 |

### New York

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, E.D. New York](courts/second-circuit/new-york/federal/bankruptcy-eastern-district) | `nyeb` | bankruptcy | todo | 0 |
| [United States Bankruptcy Court, N.D. New York](courts/second-circuit/new-york/federal/bankruptcy-northern-district) | `nynb` | bankruptcy | todo | 0 |
| [United States Bankruptcy Court, S.D. New York](courts/second-circuit/new-york/federal/bankruptcy-southern-district) | `nysb` | bankruptcy | todo | 0 |
| [United States Bankruptcy Court, W.D. New York](courts/second-circuit/new-york/federal/bankruptcy-western-district) | `nywb` | bankruptcy | todo | 0 |
| [District Court, E.D. New York](courts/second-circuit/new-york/federal/eastern-district) | `nyed` | district | todo | 0 |
| [District Court, N.D. New York](courts/second-circuit/new-york/federal/northern-district) | `nynd` | district | todo | 0 |
| [District Court, S.D. New York](courts/second-circuit/new-york/federal/southern-district) | `nysd` | district | todo | 0 |
| [District Court, W.D. New York](courts/second-circuit/new-york/federal/western-district) | `nywd` | district | todo | 0 |
| [Appellate Terms of the Supreme Court of New York](courts/second-circuit/new-york/state/appellate-terms-of-the-supreme-court) | `nyappterm` | state-appellate | todo | 0 |
| [New York Commission of Appeals](courts/second-circuit/new-york/state/commission-of-appeals) | `nycommnapp` | state-appellate | todo | 0 |
| [Court for the Trial of Impeachments](courts/second-circuit/new-york/state/court-for-the-trial-of-impeachments) | `nyimpct` | state-appellate | todo | 0 |
| [New York Court of Appeals](courts/second-circuit/new-york/state/court-of-appeals) | `ny` | state-supreme | todo | 0 |
| [The Four Departments of the Appellate Division](courts/second-circuit/new-york/state/four-departments-of-the-appellate-division) | `nyappdiv` | state-appellate | todo | 0 |
| [Saratoga Chancery Court](courts/second-circuit/new-york/state/saratoga-chancery-court) | `nychanctsara` | state-appellate | todo | 0 |

### Vermont

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Vermont](courts/second-circuit/vermont/federal/bankruptcy-district) | `vtb` | bankruptcy | todo | 0 |
| [District Court, D. Vermont](courts/second-circuit/vermont/federal/district) | `vtd` | district | todo | 0 |
| [Supreme Court of Vermont](courts/second-circuit/vermont/state/supreme-court) | `vt` | state-supreme | todo | 0 |

## Third Circuit

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [Court of Appeals for the Third Circuit](courts/third-circuit/court-of-appeals) | `ca3` | appellate | todo | 0 |

### Delaware

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Delaware](courts/third-circuit/delaware/federal/bankruptcy-district) | `deb` | bankruptcy | todo | 0 |
| [United States District Court for the District of Delaware](courts/third-circuit/delaware/federal/district) | `ded` | district | todo | 0 |
| [Delaware Court of Chancery](courts/third-circuit/delaware/state/court-of-chancery) | `delch` | state-appellate | todo | 0 |
| [Court on the Judiciary of Delaware](courts/third-circuit/delaware/state/court-on-the-judiciary) | `deljudct` | state-appellate | todo | 0 |
| [Delaware Family Court](courts/third-circuit/delaware/state/family-court) | `delfamct` | state-appellate | todo | 0 |
| [Delaware Supreme Court](courts/third-circuit/delaware/state/supreme-court) | `del` | state-supreme | todo | 0 |

### New Jersey

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, D. New Jersey](courts/third-circuit/new-jersey/federal/bankruptcy-district) | `njb` | bankruptcy | todo | 0 |
| [District Court, D. New Jersey](courts/third-circuit/new-jersey/federal/district) | `njd` | district | todo | 0 |
| [Supreme Court of New Jersey](courts/third-circuit/new-jersey/state/supreme-court) | `nj` | state-supreme | todo | 0 |
| [New Jersey Tax Court](courts/third-circuit/new-jersey/state/tax-court) | `njtaxct` | state-appellate | todo | 0 |

### Pennsylvania

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, E.D. Pennsylvania](courts/third-circuit/pennsylvania/federal/bankruptcy-eastern-district) | `paeb` | bankruptcy | todo | 0 |
| [United States Bankruptcy Court, M.D. Pennsylvania](courts/third-circuit/pennsylvania/federal/bankruptcy-middle-district) | `pamb` | bankruptcy | todo | 0 |
| [United States Bankruptcy Court, W.D. Pennsylvania](courts/third-circuit/pennsylvania/federal/bankruptcy-western-district) | `pawb` | bankruptcy | todo | 0 |
| [District Court, E.D. Pennsylvania](courts/third-circuit/pennsylvania/federal/eastern-district) | `paed` | district | todo | 0 |
| [District Court, M.D. Pennsylvania](courts/third-circuit/pennsylvania/federal/middle-district) | `pamd` | district | todo | 0 |
| [District Court, W.D. Pennsylvania](courts/third-circuit/pennsylvania/federal/western-district) | `pawd` | district | todo | 0 |
| [Commonwealth Court of Pennsylvania](courts/third-circuit/pennsylvania/state/commonwealth-court) | `pacommwct` | state-appellate | todo | 0 |
| [Court of Judicial Discipline of Pennsylvania](courts/third-circuit/pennsylvania/state/court-of-judicial-discipline) | `cjdpa` | state-appellate | todo | 0 |
| [Superior Court of Pennsylvania](courts/third-circuit/pennsylvania/state/superior-court) | `pasuperct` | state-appellate | todo | 0 |
| [Supreme Court of Pennsylvania](courts/third-circuit/pennsylvania/state/supreme-court) | `pa` | state-supreme | todo | 0 |

### Virgin Islands

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Virgin Islands](courts/third-circuit/virgin-islands/federal/bankruptcy-district) | `vib` | bankruptcy | todo | 0 |
| [District Court, Virgin Islands](courts/third-circuit/virgin-islands/federal/district) | `vid` | district | todo | 0 |

## Fourth Circuit

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [Court of Appeals for the Fourth Circuit](courts/fourth-circuit/court-of-appeals) | `ca4` | appellate | todo | 0 |

### Maryland

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Maryland](courts/fourth-circuit/maryland/federal/bankruptcy-district) | `mdb` | bankruptcy | todo | 0 |
| [District Court, D. Maryland](courts/fourth-circuit/maryland/federal/district) | `mdd` | district | todo | 0 |
| [Court of Appeals of Maryland](courts/fourth-circuit/maryland/state/court-of-appeals) | `md` | state-supreme | todo | 0 |
| [Court of Special Appeals of Maryland](courts/fourth-circuit/maryland/state/court-of-special-appeals) | `mdctspecapp` | state-appellate | todo | 0 |

### North Carolina

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, E.D. North Carolina](courts/fourth-circuit/north-carolina/federal/bankruptcy-eastern-district) | `nceb` | bankruptcy | todo | 0 |
| [United States Bankruptcy Court, M.D. North Carolina](courts/fourth-circuit/north-carolina/federal/bankruptcy-middle-district) | `ncmb` | bankruptcy | todo | 0 |
| [United States Bankruptcy Court, W.D. North Carolina](courts/fourth-circuit/north-carolina/federal/bankruptcy-western-district) | `ncwb` | bankruptcy | todo | 0 |
| [District Court, E.D. North Carolina](courts/fourth-circuit/north-carolina/federal/eastern-district) | `nced` | district | todo | 0 |
| [District Court, M.D. North Carolina](courts/fourth-circuit/north-carolina/federal/middle-district) | `ncmd` | district | todo | 0 |
| [District Court, W.D. North Carolina](courts/fourth-circuit/north-carolina/federal/western-district) | `ncwd` | district | todo | 0 |
| [Court of Appeals of North Carolina](courts/fourth-circuit/north-carolina/state/court-of-appeals) | `ncctapp` | state-appellate | todo | 0 |
| [North Carolina Industrial Commission](courts/fourth-circuit/north-carolina/state/industrial-commission) | `ncworkcompcom` | state-appellate | todo | 0 |
| [Superior Court of North Carolina](courts/fourth-circuit/north-carolina/state/superior-court) | `ncsuperct` | state-appellate | todo | 0 |
| [Supreme Court of North Carolina](courts/fourth-circuit/north-carolina/state/supreme-court) | `nc` | state-supreme | todo | 0 |

### South Carolina

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, D. South Carolina](courts/fourth-circuit/south-carolina/federal/bankruptcy-district) | `scb` | bankruptcy | todo | 0 |
| [District Court, D. South Carolina](courts/fourth-circuit/south-carolina/federal/district) | `scd` | district | todo | 0 |
| [Court of Appeals of South Carolina](courts/fourth-circuit/south-carolina/state/court-of-appeals) | `scctapp` | state-appellate | todo | 0 |
| [Court of Chancery of South Carolina](courts/fourth-circuit/south-carolina/state/court-of-chancery) | `ctchansc` | state-appellate | todo | 0 |
| [Supreme Court of South Carolina](courts/fourth-circuit/south-carolina/state/supreme-court) | `sc` | state-supreme | todo | 0 |

### Virginia

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, E.D. Virginia](courts/fourth-circuit/virginia/federal/bankruptcy-eastern-district) | `vaeb` | bankruptcy | todo | 0 |
| [United States Bankruptcy Court, W.D. Virginia](courts/fourth-circuit/virginia/federal/bankruptcy-western-district) | `vawb` | bankruptcy | todo | 0 |
| [District Court, E.D. Virginia](courts/fourth-circuit/virginia/federal/eastern-district) | `vaed` | district | todo | 0 |
| [District Court, W.D. Virginia](courts/fourth-circuit/virginia/federal/western-district) | `vawd` | district | todo | 0 |
| [Court of Appeals of Virginia](courts/fourth-circuit/virginia/state/court-of-appeals) | `vactapp` | state-appellate | todo | 0 |
| [Supreme Court of Virginia](courts/fourth-circuit/virginia/state/supreme-court) | `va` | state-supreme | todo | 0 |

### West Virginia

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States District Court, N.D. West Virginia](courts/fourth-circuit/west-virginia/federal/bankruptcy-northern-district) | `wvnb` | bankruptcy | todo | 0 |
| [United States Bankruptcy Court, S.D. West Virginia](courts/fourth-circuit/west-virginia/federal/bankruptcy-southern-district) | `wvsb` | bankruptcy | todo | 0 |
| [District Court, N.D. West Virginia](courts/fourth-circuit/west-virginia/federal/northern-district) | `wvnd` | district | todo | 0 |
| [District Court, S.D. West Virginia](courts/fourth-circuit/west-virginia/federal/southern-district) | `wvsd` | district | todo | 0 |
| [Intermediate Court of Appeals of West Virginia](courts/fourth-circuit/west-virginia/state/intermediate-court-of-appeals) | `wvactapp` | state-appellate | todo | 0 |
| [West Virginia Supreme Court](courts/fourth-circuit/west-virginia/state/supreme-court) | `wva` | state-supreme | todo | 0 |

## Fifth Circuit

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [Court of Appeals for the Fifth Circuit](courts/fifth-circuit/court-of-appeals) | `ca5` | appellate | todo | 0 |

### Louisiana

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, E.D. Louisiana](courts/fifth-circuit/louisiana/federal/bankruptcy-eastern-district) | `laeb` | bankruptcy | todo | 0 |
| [United States Bankruptcy Court, M.D. Louisiana](courts/fifth-circuit/louisiana/federal/bankruptcy-middle-district) | `lamb` | bankruptcy | todo | 0 |
| [United States Bankruptcy Court, W.D. Louisiana](courts/fifth-circuit/louisiana/federal/bankruptcy-western-district) | `lawb` | bankruptcy | todo | 0 |
| [United States District Court Eastern District of Louisiana](courts/fifth-circuit/louisiana/federal/eastern-district) | `laed` | district | todo | 0 |
| [District Court, M.D. Louisiana](courts/fifth-circuit/louisiana/federal/middle-district) | `lamd` | district | todo | 0 |
| [District Court, W.D. Louisiana](courts/fifth-circuit/louisiana/federal/western-district) | `lawd` | district | todo | 0 |
| [Louisiana Court of Appeal](courts/fifth-circuit/louisiana/state/court-of-appeal) | `lactapp` | state-appellate | todo | 0 |
| [Supreme Court of Louisiana](courts/fifth-circuit/louisiana/state/supreme-court) | `la` | state-supreme | todo | 0 |

### Mississippi

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, N.D. Mississippi](courts/fifth-circuit/mississippi/federal/bankruptcy-northern-district) | `msnb` | bankruptcy | todo | 0 |
| [United States Bankruptcy Court, S.D. Mississippi](courts/fifth-circuit/mississippi/federal/bankruptcy-southern-district) | `mssb` | bankruptcy | todo | 0 |
| [District Court, N.D. Mississippi](courts/fifth-circuit/mississippi/federal/northern-district) | `msnd` | district | todo | 0 |
| [District Court, S.D. Mississippi](courts/fifth-circuit/mississippi/federal/southern-district) | `mssd` | district | todo | 0 |
| [Mississippi Chancery Courts](courts/fifth-circuit/mississippi/state/chancery-courts) | `misschanceryct` | state-appellate | todo | 0 |
| [Court of Appeals of Mississippi](courts/fifth-circuit/mississippi/state/court-of-appeals) | `missctapp` | state-appellate | todo | 0 |
| [Mississippi Supreme Court](courts/fifth-circuit/mississippi/state/supreme-court) | `miss` | state-supreme | todo | 0 |

### Texas

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, E.D. Texas](courts/fifth-circuit/texas/federal/bankruptcy-eastern-district) | `txeb` | bankruptcy | todo | 0 |
| [United States Bankruptcy Court, N.D. Texas](courts/fifth-circuit/texas/federal/bankruptcy-northern-district) | `txnb` | bankruptcy | todo | 0 |
| [United States Bankruptcy Court, S.D. Texas](courts/fifth-circuit/texas/federal/bankruptcy-southern-district) | `txsb` | bankruptcy | todo | 0 |
| [United States Bankruptcy Court, W.D. Texas](courts/fifth-circuit/texas/federal/bankruptcy-western-district) | `txwb` | bankruptcy | todo | 0 |
| [District Court, E.D. Texas](courts/fifth-circuit/texas/federal/eastern-district) | `txed` | district | todo | 0 |
| [District Court, N.D. Texas](courts/fifth-circuit/texas/federal/northern-district) | `txnd` | district | todo | 0 |
| [District Court, S.D. Texas](courts/fifth-circuit/texas/federal/southern-district) | `txsd` | district | todo | 0 |
| [District Court, W.D. Texas](courts/fifth-circuit/texas/federal/western-district) | `txwd` | district | todo | 0 |
| [Court of Civil Appeals of Texas](courts/fifth-circuit/texas/state/court-of-civil-appeals) | `texapp` | state-appellate | todo | 0 |
| [Court of Criminal Appeals of Texas](courts/fifth-circuit/texas/state/court-of-criminal-appeals) | `texcrimapp` | state-supreme | todo | 0 |
| [Texas Court of Review Tribunal](courts/fifth-circuit/texas/state/court-of-review-tribunal) | `texrevtrib` | state-appellate | todo | 0 |
| [Texas Judicial Panel on Multidistrict Litigation](courts/fifth-circuit/texas/state/judicial-panel-on-multidistrict-litigation) | `texjpml` | state-appellate | todo | 0 |
| [Texas Special Court of Review](courts/fifth-circuit/texas/state/special-court-of-review) | `texreview` | state-appellate | todo | 0 |
| [Texas Supreme Court](courts/fifth-circuit/texas/state/supreme-court) | `tex` | state-supreme | todo | 0 |

## Sixth Circuit

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Appellate Panel of The Sixth Circuit](courts/sixth-circuit/bankruptcy-appellate-panel) | `bap6` | bap | todo | 0 |
| [Court of Appeals for the Sixth Circuit](courts/sixth-circuit/court-of-appeals) | `ca6` | appellate | todo | 0 |

### Kentucky

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, E.D. Kentucky](courts/sixth-circuit/kentucky/federal/bankruptcy-eastern-district) | `kyeb` | bankruptcy | todo | 0 |
| [United States Bankruptcy Court, W.D. Kentucky](courts/sixth-circuit/kentucky/federal/bankruptcy-western-district) | `kywb` | bankruptcy | todo | 0 |
| [District Court, E.D. Kentucky](courts/sixth-circuit/kentucky/federal/eastern-district) | `kyed` | district | todo | 0 |
| [District Court, W.D. Kentucky](courts/sixth-circuit/kentucky/federal/western-district) | `kywd` | district | todo | 0 |
| [Court of Appeals of Kentucky](courts/sixth-circuit/kentucky/state/court-of-appeals) | `kyctapp` | state-appellate | todo | 0 |
| [Kentucky Supreme Court](courts/sixth-circuit/kentucky/state/supreme-court) | `ky` | state-supreme | todo | 0 |

### Michigan

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, E.D. Michigan](courts/sixth-circuit/michigan/federal/bankruptcy-eastern-district) | `mieb` | bankruptcy | todo | 0 |
| [United States Bankruptcy Court, W.D. Michigan](courts/sixth-circuit/michigan/federal/bankruptcy-western-district) | `miwb` | bankruptcy | todo | 0 |
| [District Court, E.D. Michigan](courts/sixth-circuit/michigan/federal/eastern-district) | `mied` | district | todo | 0 |
| [District Court, W.D. Michigan](courts/sixth-circuit/michigan/federal/western-district) | `miwd` | district | todo | 0 |
| [Michigan Court of Appeals](courts/sixth-circuit/michigan/state/court-of-appeals) | `michctapp` | state-appellate | todo | 0 |
| [Michigan Supreme Court](courts/sixth-circuit/michigan/state/supreme-court) | `mich` | state-supreme | todo | 0 |

### Ohio

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, N.D. Ohio](courts/sixth-circuit/ohio/federal/bankruptcy-northern-district) | `ohnb` | bankruptcy | todo | 0 |
| [United States Bankruptcy Court, S.D. Ohio](courts/sixth-circuit/ohio/federal/bankruptcy-southern-district) | `ohsb` | bankruptcy | todo | 0 |
| [District Court, N.D. Ohio](courts/sixth-circuit/ohio/federal/northern-district) | `ohnd` | district | todo | 0 |
| [District Court, S.D. Ohio](courts/sixth-circuit/ohio/federal/southern-district) | `ohsd` | district | todo | 0 |
| [Ohio Court of Appeals](courts/sixth-circuit/ohio/state/court-of-appeals) | `ohioctapp` | state-appellate | todo | 0 |
| [Ohio Court of Claims](courts/sixth-circuit/ohio/state/court-of-claims) | `ohioctcl` | state-appellate | todo | 0 |
| [Ohio Supreme Court](courts/sixth-circuit/ohio/state/supreme-court) | `ohio` | state-supreme | todo | 0 |

### Tennessee

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, E.D. Tennessee](courts/sixth-circuit/tennessee/federal/bankruptcy-eastern-district) | `tneb` | bankruptcy | todo | 0 |
| [United States Bankruptcy Court, M.D. Tennessee](courts/sixth-circuit/tennessee/federal/bankruptcy-middle-district) | `tnmb` | bankruptcy | todo | 0 |
| [United States Bankruptcy Court, W.D. Tennessee](courts/sixth-circuit/tennessee/federal/bankruptcy-western-district) | `tnwb` | bankruptcy | todo | 0 |
| [District Court, E.D. Tennessee](courts/sixth-circuit/tennessee/federal/eastern-district) | `tned` | district | todo | 0 |
| [District Court, M.D. Tennessee](courts/sixth-circuit/tennessee/federal/middle-district) | `tnmd` | district | todo | 0 |
| [District Court, W.D. Tennessee](courts/sixth-circuit/tennessee/federal/western-district) | `tnwd` | district | todo | 0 |
| [Court of Appeals of Tennessee](courts/sixth-circuit/tennessee/state/court-of-appeals) | `tennctapp` | state-appellate | todo | 0 |
| [Court of Criminal Appeals of Tennessee](courts/sixth-circuit/tennessee/state/court-of-criminal-appeals) | `tenncrimapp` | state-appellate | todo | 0 |
| [Tennessee Supreme Court](courts/sixth-circuit/tennessee/state/supreme-court) | `tenn` | state-supreme | todo | 0 |

## Seventh Circuit

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [Court of Appeals for the Seventh Circuit](courts/seventh-circuit/court-of-appeals) | `ca7` | appellate | todo | 0 |

### Illinois

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, C.D. Illinois](courts/seventh-circuit/illinois/federal/bankruptcy-central-district) | `ilcb` | bankruptcy | todo | 0 |
| [United States Bankruptcy Court, N.D. Illinois](courts/seventh-circuit/illinois/federal/bankruptcy-northern-district) | `ilnb` | bankruptcy | todo | 0 |
| [United States Bankruptcy Court, S.D. Illinois](courts/seventh-circuit/illinois/federal/bankruptcy-southern-district) | `ilsb` | bankruptcy | todo | 0 |
| [District Court, C.D. Illinois](courts/seventh-circuit/illinois/federal/central-district) | `ilcd` | district | todo | 0 |
| [District Court, N.D. Illinois](courts/seventh-circuit/illinois/federal/northern-district) | `ilnd` | district | todo | 0 |
| [District Court, S.D. Illinois](courts/seventh-circuit/illinois/federal/southern-district) | `ilsd` | district | todo | 0 |
| [Appellate Court of Illinois](courts/seventh-circuit/illinois/state/appellate-court) | `illappct` | state-appellate | todo | 0 |
| [Illinois Supreme Court](courts/seventh-circuit/illinois/state/supreme-court) | `ill` | state-supreme | todo | 0 |

### Indiana

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, N.D. Indiana](courts/seventh-circuit/indiana/federal/bankruptcy-northern-district) | `innb` | bankruptcy | todo | 0 |
| [United States Bankruptcy Court, S.D. Indiana](courts/seventh-circuit/indiana/federal/bankruptcy-southern-district) | `insb` | bankruptcy | todo | 0 |
| [District Court, N.D. Indiana](courts/seventh-circuit/indiana/federal/northern-district) | `innd` | district | todo | 0 |
| [District Court, S.D. Indiana](courts/seventh-circuit/indiana/federal/southern-district) | `insd` | district | todo | 0 |
| [Indiana Court of Appeals](courts/seventh-circuit/indiana/state/court-of-appeals) | `indctapp` | state-appellate | todo | 0 |
| [Indiana Supreme Court](courts/seventh-circuit/indiana/state/supreme-court) | `ind` | state-supreme | todo | 0 |
| [Indiana Tax Court](courts/seventh-circuit/indiana/state/tax-court) | `indtc` | state-appellate | todo | 0 |

### Wisconsin

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, E.D. Wisconsin](courts/seventh-circuit/wisconsin/federal/bankruptcy-eastern-district) | `wieb` | bankruptcy | todo | 0 |
| [United States Bankruptcy Court, W.D. Wisconsin](courts/seventh-circuit/wisconsin/federal/bankruptcy-western-district) | `wiwb` | bankruptcy | todo | 0 |
| [District Court, E.D. Wisconsin](courts/seventh-circuit/wisconsin/federal/eastern-district) | `wied` | district | todo | 0 |
| [District Court, W.D. Wisconsin](courts/seventh-circuit/wisconsin/federal/western-district) | `wiwd` | district | todo | 0 |
| [Court of Appeals of Wisconsin](courts/seventh-circuit/wisconsin/state/court-of-appeals) | `wisctapp` | state-appellate | todo | 0 |
| [Wisconsin Supreme Court](courts/seventh-circuit/wisconsin/state/supreme-court) | `wis` | state-supreme | todo | 0 |

## Eighth Circuit

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Appellate Panel of The Eighth Circuit](courts/eighth-circuit/bankruptcy-appellate-panel) | `bap8` | bap | todo | 0 |
| [Court of Appeals for the Eighth Circuit](courts/eighth-circuit/court-of-appeals) | `ca8` | appellate | todo | 0 |

### Arkansas

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, E.D. Arkansas](courts/eighth-circuit/arkansas/federal/bankruptcy-eastern-district) | `areb` | bankruptcy | todo | 0 |
| [United States Bankruptcy Court, W.D. Arkansas](courts/eighth-circuit/arkansas/federal/bankruptcy-western-district) | `arwb` | bankruptcy | todo | 0 |
| [United States District Court for the Eastern District of Arkansas](courts/eighth-circuit/arkansas/federal/eastern-district) | `ared` | district | todo | 0 |
| [United States District Court for the Western District of Arkansas](courts/eighth-circuit/arkansas/federal/western-district) | `arwd` | district | todo | 0 |
| [Arkansas Court of Appeals](courts/eighth-circuit/arkansas/state/court-of-appeals) | `arkctapp` | state-appellate | todo | 0 |
| [Arkansas Supreme Court](courts/eighth-circuit/arkansas/state/supreme-court) | `ark` | state-supreme | todo | 0 |
| [Arkansas Workers' Compensation Commission](courts/eighth-circuit/arkansas/state/workers-compensation-commission) | `arkworkcompcom` | state-appellate | todo | 0 |

### Iowa

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, N.D. Iowa](courts/eighth-circuit/iowa/federal/bankruptcy-northern-district) | `ianb` | bankruptcy | todo | 0 |
| [United States Bankruptcy Court, S.D. Iowa](courts/eighth-circuit/iowa/federal/bankruptcy-southern-district) | `iasb` | bankruptcy | todo | 0 |
| [District Court, N.D. Iowa](courts/eighth-circuit/iowa/federal/northern-district) | `iand` | district | todo | 0 |
| [District Court, S.D. Iowa](courts/eighth-circuit/iowa/federal/southern-district) | `iasd` | district | todo | 0 |
| [Court of Appeals of Iowa](courts/eighth-circuit/iowa/state/court-of-appeals) | `iowactapp` | state-appellate | todo | 0 |
| [Supreme Court of Iowa](courts/eighth-circuit/iowa/state/supreme-court) | `iowa` | state-supreme | todo | 0 |

### Minnesota

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Minnesota](courts/eighth-circuit/minnesota/federal/bankruptcy-district) | `mnb` | bankruptcy | todo | 0 |
| [District Court, D. Minnesota](courts/eighth-circuit/minnesota/federal/district) | `mnd` | district | todo | 0 |
| [Court of Appeals of Minnesota](courts/eighth-circuit/minnesota/state/court-of-appeals) | `minnctapp` | state-appellate | todo | 0 |
| [Supreme Court of Minnesota](courts/eighth-circuit/minnesota/state/supreme-court) | `minn` | state-supreme | todo | 0 |

### Missouri

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, E.D. Missouri](courts/eighth-circuit/missouri/federal/bankruptcy-eastern-district) | `moeb` | bankruptcy | todo | 0 |
| [United States Bankruptcy Court, W.D. Missouri](courts/eighth-circuit/missouri/federal/bankruptcy-western-district) | `mowb` | bankruptcy | todo | 0 |
| [District Court, E.D. Missouri](courts/eighth-circuit/missouri/federal/eastern-district) | `moed` | district | todo | 0 |
| [District Court, W.D. Missouri](courts/eighth-circuit/missouri/federal/western-district) | `mowd` | district | todo | 0 |
| [Missouri Court of Appeals](courts/eighth-circuit/missouri/state/court-of-appeals) | `moctapp` | state-appellate | todo | 0 |
| [Missouri Court of Appeals, Eastern District](courts/eighth-circuit/missouri/state/court-of-appeals-eastern-district) | `moctapped` | state-appellate | todo | 0 |
| [Missouri Court of Appeals, Southern District](courts/eighth-circuit/missouri/state/court-of-appeals-southern-district) | `moctappsd` | state-appellate | todo | 0 |
| [Missouri Court of Appeals, Western District](courts/eighth-circuit/missouri/state/court-of-appeals-western-district) | `moctappwd` | state-appellate | todo | 0 |
| [Supreme Court of Missouri](courts/eighth-circuit/missouri/state/supreme-court) | `mo` | state-supreme | todo | 0 |

### Nebraska

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Nebraska](courts/eighth-circuit/nebraska/federal/bankruptcy-district) | `nebraskab` | bankruptcy | todo | 0 |
| [United States District Court, Nebraska](courts/eighth-circuit/nebraska/federal/district) | `ned` | district | todo | 0 |
| [Nebraska Court of Appeals](courts/eighth-circuit/nebraska/state/court-of-appeals) | `nebctapp` | state-appellate | todo | 0 |
| [Nebraska Supreme Court](courts/eighth-circuit/nebraska/state/supreme-court) | `neb` | state-supreme | todo | 0 |

### North Dakota

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, D. North Dakota](courts/eighth-circuit/north-dakota/federal/bankruptcy-district) | `ndb` | bankruptcy | todo | 0 |
| [District Court, D. North Dakota](courts/eighth-circuit/north-dakota/federal/district) | `ndd` | district | todo | 0 |
| [North Dakota Court of Appeals](courts/eighth-circuit/north-dakota/state/court-of-appeals) | `ndctapp` | state-appellate | todo | 0 |
| [North Dakota Supreme Court](courts/eighth-circuit/north-dakota/state/supreme-court) | `nd` | state-supreme | todo | 0 |

### South Dakota

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, D. South Dakota](courts/eighth-circuit/south-dakota/federal/bankruptcy-district) | `sdb` | bankruptcy | todo | 0 |
| [District Court, D. South Dakota](courts/eighth-circuit/south-dakota/federal/district) | `sdd` | district | todo | 0 |
| [Supreme Court of South Dakota](courts/eighth-circuit/south-dakota/state/supreme-court) | `sd` | state-supreme | todo | 0 |

## Ninth Circuit

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Appellate Panel of The Ninth Circuit](courts/ninth-circuit/bankruptcy-appellate-panel) | `bap9` | bap | todo | 0 |
| [Court of Appeals for the Ninth Circuit](courts/ninth-circuit/court-of-appeals) | `ca9` | appellate | in progress | 17 |

### Alaska

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Alaska](courts/ninth-circuit/alaska/federal/bankruptcy-district) | `akb` | bankruptcy | todo | 0 |
| [United States District Court for the District of Alaska](courts/ninth-circuit/alaska/federal/district) | `akd` | district | todo | 0 |
| [Alaska Court of Appeals](courts/ninth-circuit/alaska/state/court-of-appeals) | `alaskactapp` | state-appellate | todo | 0 |
| [Alaska Supreme Court](courts/ninth-circuit/alaska/state/supreme-court) | `alaska` | state-supreme | todo | 0 |

### Arizona

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Arizona](courts/ninth-circuit/arizona/federal/bankruptcy-district) | `arb` | bankruptcy | todo | 0 |
| [United States District Court for the District of Arizona](courts/ninth-circuit/arizona/federal/district) | `azd` | district | todo | 0 |
| [Arizona Court of Appeals](courts/ninth-circuit/arizona/state/court-of-appeals) | `arizctapp` | state-appellate | todo | 0 |
| [Arizona Supreme Court](courts/ninth-circuit/arizona/state/supreme-court) | `ariz` | state-supreme | todo | 0 |
| [Arizona Tax Court](courts/ninth-circuit/arizona/state/tax-court) | `ariztaxct` | state-appellate | todo | 0 |

### California

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, C.D. California](courts/ninth-circuit/california/federal/bankruptcy-central-district) | `cacb` | bankruptcy | todo | 0 |
| [United States Bankruptcy Court, E.D. California](courts/ninth-circuit/california/federal/bankruptcy-eastern-district) | `caeb` | bankruptcy | todo | 0 |
| [United States Bankruptcy Court, N.D. California](courts/ninth-circuit/california/federal/bankruptcy-northern-district) | `canb` | bankruptcy | todo | 0 |
| [United States Bankruptcy Court, S.D. California](courts/ninth-circuit/california/federal/bankruptcy-southern-district) | `casb` | bankruptcy | todo | 0 |
| [United States District Court for the Central District of California](courts/ninth-circuit/california/federal/central-district) | `cacd` | district | todo | 0 |
| [United States District Court for the Eastern District of California](courts/ninth-circuit/california/federal/eastern-district) | `caed` | district | todo | 0 |
| [United States District Court for the Northern District of California](courts/ninth-circuit/california/federal/northern-district) | `cand` | district | todo | 0 |
| [United States District Court for the Southern District of California](courts/ninth-circuit/california/federal/southern-district) | `casd` | district | in progress | 17 |
| [California Court of Appeal, Fifth Appellate District](courts/ninth-circuit/california/state/court-of-appeal-fifth-district) | `calctapp5d` | state-appellate | todo | 0 |
| [California Court of Appeal, First Appellate District](courts/ninth-circuit/california/state/court-of-appeal-first-district) | `calctapp1d` | state-appellate | todo | 0 |
| [California Court of Appeal, Fourth Appellate District](courts/ninth-circuit/california/state/court-of-appeal-fourth-district) | `calctapp4d` | state-appellate | todo | 0 |
| [California Court of Appeal, Second Appellate District](courts/ninth-circuit/california/state/court-of-appeal-second-district) | `calctapp2d` | state-appellate | todo | 0 |
| [California Court of Appeal, Sixth Appellate District](courts/ninth-circuit/california/state/court-of-appeal-sixth-district) | `calctapp6d` | state-appellate | todo | 0 |
| [California Court of Appeal, Third Appellate District](courts/ninth-circuit/california/state/court-of-appeal-third-district) | `calctapp3d` | state-appellate | todo | 0 |
| [California Courts of Appeal](courts/ninth-circuit/california/state/courts-of-appeal) | `calctapp` | state-appellate | todo | 0 |
| [California Superior Court](courts/ninth-circuit/california/state/superior-court) | `calsuperct` | state-trial | todo | 0 |
| [California Superior Court, San Diego County](courts/ninth-circuit/california/state/superior-court/san-diego-county) | `calsuperct-sandiego` | state-trial | in progress | 17 |
| [California Superior Court, Appellate Division](courts/ninth-circuit/california/state/superior-court-appellate-division) | `calappdeptsuper` | state-appellate | todo | 0 |
| [California Supreme Court](courts/ninth-circuit/california/state/supreme-court) | `cal` | state-supreme | todo | 0 |

### Guam

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Guam](courts/ninth-circuit/guam/federal/bankruptcy-district) | `gub` | bankruptcy | todo | 0 |
| [District Court, D. Guam](courts/ninth-circuit/guam/federal/district) | `gud` | district | todo | 0 |
| [Supreme Court of Guam](courts/ninth-circuit/guam/state/supreme-court) | `guam` | state-supreme | todo | 0 |

### Hawaii

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Hawaii](courts/ninth-circuit/hawaii/federal/bankruptcy-district) | `hib` | bankruptcy | todo | 0 |
| [United States District Court for the District of Hawaii](courts/ninth-circuit/hawaii/federal/district) | `hid` | district | todo | 0 |
| [Hawaii Intermediate Court of Appeals](courts/ninth-circuit/hawaii/state/intermediate-court-of-appeals) | `hawapp` | state-appellate | todo | 0 |
| [Hawaii State Tax Appeal Court](courts/ninth-circuit/hawaii/state/state-tax-appeal-court) | `hawtax` | state-appellate | todo | 0 |
| [Supreme Court of Hawaii](courts/ninth-circuit/hawaii/state/supreme-court) | `haw` | state-supreme | todo | 0 |

### Idaho

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Idaho](courts/ninth-circuit/idaho/federal/bankruptcy-district) | `idb` | bankruptcy | todo | 0 |
| [United States District Court for the District of Idaho](courts/ninth-circuit/idaho/federal/district) | `idd` | district | todo | 0 |
| [Idaho Court of Appeals](courts/ninth-circuit/idaho/state/court-of-appeals) | `idahoctapp` | state-appellate | todo | 0 |
| [Idaho Supreme Court](courts/ninth-circuit/idaho/state/supreme-court) | `idaho` | state-supreme | todo | 0 |

### Montana

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Montana](courts/ninth-circuit/montana/federal/bankruptcy-district) | `mtb` | bankruptcy | todo | 0 |
| [District Court, D. Montana](courts/ninth-circuit/montana/federal/district) | `mtd` | district | todo | 0 |
| [Montana Supreme Court](courts/ninth-circuit/montana/state/supreme-court) | `mont` | state-supreme | todo | 0 |
| [Montana Tax Appeal Board](courts/ninth-circuit/montana/state/tax-appeal-board) | `monttc` | state-appellate | todo | 0 |

### Nevada

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Nevada](courts/ninth-circuit/nevada/federal/bankruptcy-district) | `nvb` | bankruptcy | todo | 0 |
| [District Court, D. Nevada](courts/ninth-circuit/nevada/federal/district) | `nvd` | district | todo | 0 |
| [Court of Appeals of Nevada](courts/ninth-circuit/nevada/state/court-of-appeals) | `nevapp` | state-appellate | todo | 0 |
| [Nevada Supreme Court](courts/ninth-circuit/nevada/state/supreme-court) | `nev` | state-supreme | todo | 0 |

### Northern Mariana Islands

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, Northern Mariana Islands](courts/ninth-circuit/northern-mariana-islands/federal/bankruptcy-district) | `nmib` | bankruptcy | todo | 0 |
| [District Court, Northern Mariana Islands](courts/ninth-circuit/northern-mariana-islands/federal/district) | `nmid` | district | todo | 0 |
| [Supreme Court of The Commonwealth of The Northern Mariana Islands](courts/ninth-circuit/northern-mariana-islands/state/supreme-court) | `nmi` | state-supreme | todo | 0 |

### Oregon

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Oregon](courts/ninth-circuit/oregon/federal/bankruptcy-district) | `orb` | bankruptcy | todo | 0 |
| [District Court, D. Oregon](courts/ninth-circuit/oregon/federal/district) | `ord` | district | todo | 0 |
| [Court of Appeals of Oregon](courts/ninth-circuit/oregon/state/court-of-appeals) | `orctapp` | state-appellate | todo | 0 |
| [Oregon Supreme Court](courts/ninth-circuit/oregon/state/supreme-court) | `or` | state-supreme | todo | 0 |
| [Oregon Tax Court](courts/ninth-circuit/oregon/state/tax-court) | `ortc` | state-appellate | todo | 0 |

### Washington

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, E.D. Washington](courts/ninth-circuit/washington/federal/bankruptcy-eastern-district) | `waeb` | bankruptcy | todo | 0 |
| [United States Bankruptcy Court, W.D. Washington](courts/ninth-circuit/washington/federal/bankruptcy-western-district) | `wawb` | bankruptcy | todo | 0 |
| [District Court, E.D. Washington](courts/ninth-circuit/washington/federal/eastern-district) | `waed` | district | todo | 0 |
| [District Court, W.D. Washington](courts/ninth-circuit/washington/federal/western-district) | `wawd` | district | todo | 0 |
| [Court of Appeals of Washington](courts/ninth-circuit/washington/state/court-of-appeals) | `washctapp` | state-appellate | todo | 0 |
| [Washington Supreme Court](courts/ninth-circuit/washington/state/supreme-court) | `wash` | state-supreme | todo | 0 |

### American Samoa

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [High Court of American Samoa](courts/ninth-circuit/american-samoa/state/high-court) | `amsamoa` | state-supreme | todo | 0 |

## Tenth Circuit

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Appellate Panel of The Tenth Circuit](courts/tenth-circuit/bankruptcy-appellate-panel) | `bap10` | bap | todo | 0 |
| [Court of Appeals for the Tenth Circuit](courts/tenth-circuit/court-of-appeals) | `ca10` | appellate | todo | 0 |

### Colorado

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Colorado](courts/tenth-circuit/colorado/federal/bankruptcy-district) | `cob` | bankruptcy | todo | 0 |
| [United States District Court for the District of Colorado](courts/tenth-circuit/colorado/federal/district) | `cod` | district | todo | 0 |
| [Colorado Court of Appeals](courts/tenth-circuit/colorado/state/court-of-appeals) | `coloctapp` | state-appellate | todo | 0 |
| [Colorado Industrial Claim Appeals office](courts/tenth-circuit/colorado/state/industrial-claim-appeals-office) | `coloworkcompcom` | state-appellate | todo | 0 |
| [Colorado Supreme Court](courts/tenth-circuit/colorado/state/supreme-court) | `colo` | state-supreme | todo | 0 |

### Kansas

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Kansas](courts/tenth-circuit/kansas/federal/bankruptcy-district) | `ksb` | bankruptcy | todo | 0 |
| [District Court, D. Kansas](courts/tenth-circuit/kansas/federal/district) | `ksd` | district | todo | 0 |
| [Court of Appeals of Kansas](courts/tenth-circuit/kansas/state/court-of-appeals) | `kanctapp` | state-appellate | todo | 0 |
| [Supreme Court of Kansas](courts/tenth-circuit/kansas/state/supreme-court) | `kan` | state-supreme | todo | 0 |

### New Mexico

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, D. New Mexico](courts/tenth-circuit/new-mexico/federal/bankruptcy-district) | `nmb` | bankruptcy | todo | 0 |
| [District Court, D. New Mexico](courts/tenth-circuit/new-mexico/federal/district) | `nmd` | district | todo | 0 |
| [New Mexico Court of Appeals](courts/tenth-circuit/new-mexico/state/court-of-appeals) | `nmctapp` | state-appellate | todo | 0 |
| [New Mexico Supreme Court](courts/tenth-circuit/new-mexico/state/supreme-court) | `nm` | state-supreme | todo | 0 |

### Oklahoma

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, E.D. Oklahoma](courts/tenth-circuit/oklahoma/federal/bankruptcy-eastern-district) | `okeb` | bankruptcy | todo | 0 |
| [United States Bankruptcy Court, N.D. Oklahoma](courts/tenth-circuit/oklahoma/federal/bankruptcy-northern-district) | `oknb` | bankruptcy | todo | 0 |
| [United States Bankruptcy Court, W.D. Oklahoma](courts/tenth-circuit/oklahoma/federal/bankruptcy-western-district) | `okwb` | bankruptcy | todo | 0 |
| [United States District Court for the District of Oklahoma](courts/tenth-circuit/oklahoma/federal/district) | `okd` | district | todo | 0 |
| [United States District Court, Oklahoma Eastern](courts/tenth-circuit/oklahoma/federal/eastern-district) | `oked` | district | todo | 0 |
| [United States District Court, Oklahoma Northern](courts/tenth-circuit/oklahoma/federal/northern-district) | `oknd` | district | todo | 0 |
| [United States District Court, Oklahoma Western](courts/tenth-circuit/oklahoma/federal/western-district) | `okwd` | district | todo | 0 |
| [Court of Civil Appeals of Oklahoma](courts/tenth-circuit/oklahoma/state/court-of-civil-appeals) | `oklacivapp` | state-appellate | todo | 0 |
| [Court of Criminal Appeals of Oklahoma](courts/tenth-circuit/oklahoma/state/court-of-criminal-appeals) | `oklacrimapp` | state-supreme | todo | 0 |
| [Court on the Judiciary of Oklahoma](courts/tenth-circuit/oklahoma/state/court-on-the-judiciary) | `oklacoj` | state-appellate | todo | 0 |
| [Oklahoma Judicial Ethics Advisory Panel](courts/tenth-circuit/oklahoma/state/judicial-ethics-advisory-panel) | `oklajeap` | state-appellate | todo | 0 |
| [Supreme Court of Oklahoma](courts/tenth-circuit/oklahoma/state/supreme-court) | `okla` | state-supreme | todo | 0 |

### Utah

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Utah](courts/tenth-circuit/utah/federal/bankruptcy-district) | `utb` | bankruptcy | todo | 0 |
| [District Court, D. Utah](courts/tenth-circuit/utah/federal/district) | `utd` | district | todo | 0 |
| [Court of Appeals of Utah](courts/tenth-circuit/utah/state/court-of-appeals) | `utahctapp` | state-appellate | todo | 0 |
| [Utah Supreme Court](courts/tenth-circuit/utah/state/supreme-court) | `utah` | state-supreme | todo | 0 |

### Wyoming

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, D. Wyoming](courts/tenth-circuit/wyoming/federal/bankruptcy-district) | `wyb` | bankruptcy | todo | 0 |
| [District Court, D. Wyoming](courts/tenth-circuit/wyoming/federal/district) | `wyd` | district | todo | 0 |
| [Wyoming Supreme Court](courts/tenth-circuit/wyoming/state/supreme-court) | `wyo` | state-supreme | todo | 0 |

## Eleventh Circuit

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Court of Appeals for the Eleventh Circuit](courts/eleventh-circuit/court-of-appeals) | `ca11` | appellate | todo | 0 |

### Alabama

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court for the Middle District of Alabama](courts/eleventh-circuit/alabama/federal/bankruptcy-middle-district) | `almb` | bankruptcy | todo | 0 |
| [United States Bankruptcy Court, N.D. Alabama](courts/eleventh-circuit/alabama/federal/bankruptcy-northern-district) | `alnb` | bankruptcy | todo | 0 |
| [United States Bankruptcy Court, S.D. Alabama](courts/eleventh-circuit/alabama/federal/bankruptcy-southern-district) | `alsb` | bankruptcy | todo | 0 |
| [United States District Court for the Middle District of Alabama](courts/eleventh-circuit/alabama/federal/middle-district) | `almd` | district | todo | 0 |
| [United States District Court for the Northern District of Alabama](courts/eleventh-circuit/alabama/federal/northern-district) | `alnd` | district | todo | 0 |
| [United States District Court for the Southern District of Alabama](courts/eleventh-circuit/alabama/federal/southern-district) | `alsd` | district | todo | 0 |
| [Alabama Court of Civil Appeals](courts/eleventh-circuit/alabama/state/court-of-civil-appeals) | `alacivapp` | state-appellate | todo | 0 |
| [Alabama Court of Criminal Appeals](courts/eleventh-circuit/alabama/state/court-of-criminal-appeals) | `alacrimapp` | state-appellate | todo | 0 |
| [Supreme Court of Alabama](courts/eleventh-circuit/alabama/state/supreme-court) | `ala` | state-supreme | todo | 0 |

### Florida

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, M.D. Florida](courts/eleventh-circuit/florida/federal/bankruptcy-middle-district) | `flmb` | bankruptcy | todo | 0 |
| [United States Bankruptcy Court, N.D. Florida](courts/eleventh-circuit/florida/federal/bankruptcy-northern-district) | `flnb` | bankruptcy | todo | 0 |
| [United States Bankruptcy Court, Southern District Florida](courts/eleventh-circuit/florida/federal/bankruptcy-southern-district) | `flsb` | bankruptcy | todo | 0 |
| [United States District Court for the Middle District of Florida](courts/eleventh-circuit/florida/federal/middle-district) | `flmd` | district | todo | 0 |
| [United States District Court for the Northern District of Florida](courts/eleventh-circuit/florida/federal/northern-district) | `flnd` | district | todo | 0 |
| [United States District Court for the Southern District of Florida](courts/eleventh-circuit/florida/federal/southern-district) | `flsd` | district | todo | 0 |
| [Florida District Courts of Appeal](courts/eleventh-circuit/florida/state/district-courts-of-appeal) | `fladistctapp` | state-appellate | todo | 0 |
| [Florida Fifth District Court of Appeal](courts/eleventh-circuit/florida/state/fifth-district-court-of-appeal) | `fladistctapp5` | state-appellate | todo | 0 |
| [Florida First District Court of Appeal](courts/eleventh-circuit/florida/state/first-district-court-of-appeal) | `fladistctapp1` | state-appellate | todo | 0 |
| [Florida Fourth District Court of Appeal](courts/eleventh-circuit/florida/state/fourth-district-court-of-appeal) | `fladistctapp4` | state-appellate | todo | 0 |
| [Florida Second District Court of Appeal](courts/eleventh-circuit/florida/state/second-district-court-of-appeal) | `fladistctapp2` | state-appellate | todo | 0 |
| [Florida Sixth District Court of Appeal](courts/eleventh-circuit/florida/state/sixth-district-court-of-appeal) | `fladistctapp6` | state-appellate | todo | 0 |
| [Florida Supreme Court](courts/eleventh-circuit/florida/state/supreme-court) | `fla` | state-supreme | todo | 0 |
| [Florida Third District Court of Appeal](courts/eleventh-circuit/florida/state/third-district-court-of-appeal) | `fladistctapp3` | state-appellate | todo | 0 |

### Georgia

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, M.D. Georgia](courts/eleventh-circuit/georgia/federal/bankruptcy-middle-district) | `gamb` | bankruptcy | todo | 0 |
| [United States Bankruptcy Court, N.D. Georgia](courts/eleventh-circuit/georgia/federal/bankruptcy-northern-district) | `ganb` | bankruptcy | todo | 0 |
| [United States Bankruptcy Court, S.D. Georgia](courts/eleventh-circuit/georgia/federal/bankruptcy-southern-district) | `gasb` | bankruptcy | todo | 0 |
| [United States District Court for the Middle District of Georgia](courts/eleventh-circuit/georgia/federal/middle-district) | `gamd` | district | todo | 0 |
| [United States District Court for the Northern District of Georgia](courts/eleventh-circuit/georgia/federal/northern-district) | `gand` | district | todo | 0 |
| [United States District Court for the Southern District of Georgia](courts/eleventh-circuit/georgia/federal/southern-district) | `gasd` | district | todo | 0 |
| [Georgia Court of Appeals](courts/eleventh-circuit/georgia/state/court-of-appeals) | `gactapp` | state-appellate | todo | 0 |
| [Georgia Supreme Court](courts/eleventh-circuit/georgia/state/supreme-court) | `ga` | state-supreme | todo | 0 |

## D.C. Circuit

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [Court of Appeals for the D.C. Circuit](courts/dc-circuit/court-of-appeals) | `cadc` | appellate | todo | 0 |

### District of Columbia

| Court | Alias | Level | Status | % |
|---|---|---|---|---:|
| [United States Bankruptcy Court, District of Columbia](courts/dc-circuit/district-of-columbia/federal/bankruptcy-district) | `dcb` | bankruptcy | todo | 0 |
| [District Court, District of Columbia](courts/dc-circuit/district-of-columbia/federal/district) | `dcd` | district | todo | 0 |
| [District of Columbia Court of Appeals](courts/dc-circuit/district-of-columbia/state/court-of-appeals) | `dc` | state-supreme | todo | 0 |

## Unplaced

In scope but with a location the circuit map cannot place; no folder is created until a human decides.

| Alias | Name | courts-db location |
|---|---|---|
| `dakotasup` | Supreme Court of Dakota | Dakota Territory |

<!-- index:end -->

## License

LICENSE: TBD
