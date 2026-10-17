BLOCKED fb-595.20.18: bap8/reply-brief has no public filed exemplar after a fourth search pass (CourtListener RECAP files bap8 under ca8 22-6NNN; appellant reply in 22-6006 not in RECAP; Justia blocked from the box); answering-brief done (Swackhammer 22-6006).
BLOCKED fb-595.20.23: No public filed Tenth Circuit BAP answering brief was located after the 2026-10-17 search; the accessible Rusk filing is an appellant's brief, and CourtListener's anonymous RECAP API denies access. No matching exemplar, transcription, or overlay can be responsibly produced.
BLOCKED nmib adversary-complaint: no public filed complaint found after additional web, official-court-site, and CourtListener RECAP searches (2026-10-17). The official 1:13-ap-00003 ECF 57 decision only describes the complaint; it is not the complaint filing. CourtListener's anonymous REST API returns HTTP 403, and no RECAP complaint PDF is indexed. Without the filing, a faithful transcribed input, valid overlay, and exemplar-based all-page review cannot be completed. Existing synthetic render inspected on all three pages; not an exemplar comparison. See `courts/ninth-circuit/northern-mariana-islands/federal/bankruptcy-district/adversary-complaint/README.md`.
BLOCKED nmcca answering-brief: no publicly accessible NMCCA-filed answer brief located after an additional CourtListener RECAP API, NMCCA site, Navy filings-records portal, and web search pass on 2026-10-17; see courts/military/navy-marine-corps-court-of-criminal-appeals/answering-brief/exemplars/SOURCE.md. Without a filed NMCCA answer, the requested transcription, overlay, and exemplar-based all-page review cannot be completed.
BLOCKED pamb/adversary-complaint: no second public filed adversary complaint (different filer) found; searched Internet Archive CDX of CourtListener RECAP gov.uscourts.pamb.* (5 archived files, none a complaint), web search, Stretto claims-agent docket (SpiriTrust Lutheran; reCAPTCHA); CourtListener search API throttled for the day (2026-10-17)
BLOCKED pamb/motion-brief: no second public filed motion brief (different filer) found; same searches as pamb/adversary-complaint (CDX of RECAP gov.uscourts.pamb.*: 5 files, none a brief; web search; Stretto reCAPTCHA); CourtListener search API throttled (2026-10-17)
BLOCKED paeb/motion-brief: no second public memorandum of law in support of a motion (different filer) found; searched Internet Archive CDX of CourtListener RECAP gov.uscourts.paeb.* (83 archived files read: petitions, notices, trustee motions, orders; no memorandum); CourtListener search API throttled for the day (2026-10-17)
BLOCKED pawb/adversary-complaint: no second public filed adversary complaint (different filer) found; searched Internet Archive CDX of CourtListener RECAP gov.uscourts.pawb.* (9 archived files read; petitions, schedules, notices; no complaint); CourtListener search API throttled for the day (2026-10-17)
BLOCKED pawb/motion-brief: no second public brief in support of a motion (different filer) found; same CDX search of RECAP gov.uscourts.pawb.* (9 files, no brief); CourtListener search API throttled (2026-10-17)
BLOCKED njb/motion-brief: no second public memorandum of law supporting a motion (different filer) found; searched Internet Archive CDX of CourtListener RECAP gov.uscourts.njb.* (1,519 archived files; page 1 of 29 adversary/chapter 11 candidates read, none a memorandum of law) and one web search; CourtListener search API throttled for the day (2026-10-17)
BLOCKED vib/adversary-complaint: no second public filed adversary complaint (different filer) found; Internet Archive CDX index has no storage.courtlistener.com/recap/gov.uscourts.vib.* files, web search for gov.uscourts.vib RECAP files found none, CourtListener search API throttled for the day (2026-10-17)
BLOCKED vib/motion-brief: no second public brief supporting a motion (different filer) found; same searches as vib/adversary-complaint (no archived RECAP vib files; web search; CourtListener API throttled) (2026-10-17)
BLOCKED acca/opening-brief: no second public ACCA appellant brief from a different filer with a text layer; web searches (Manning ARMY 20130739, Bergdahl, Hasan: only CAAF-level briefs and an ACCA amicus brief) and the prior Internet Archive CDX search of jagcnet.army.mil (only Akbar, and image-only Gray) (2026-10-17)
BLOCKED acca/answering-brief: no second public ACCA appellee brief with a text layer; same searches as acca/opening-brief; only Akbar (Government Appellate Division) and image-only Gray are public (2026-10-17)
BLOCKED meb/adversary-complaint: no second-filer adversary complaint fetched. CourtListener search API hit its anonymous limits (5/min, 50/hour, then daily: "Expected available in 85759 seconds") from both curl and WebFetch on 2026-10-17 with the parallel R1 forks; web searches (CourtListener, richter.ca MM&A case documents, inforuptcy [403]) found no public PDF of a D. Me. bankruptcy adversary complaint by a filer other than Manhart/Perkins Thompson. Retry the CL search (court=meb, q=complaint, document_number:1) when the quota resets; date 2026-10-17
BLOCKED nhb/adversary-complaint: no second-filer adversary complaint fetched. CourtListener search API quota exhausted for curl and WebFetch on 2026-10-17 (anonymous 5/min, 50/hour, then daily limit) with the parallel R1 forks; web searches found no public D.N.H. bankruptcy adversary complaint PDF from a filer other than Smith/Sheehan Phinney (inforuptcy docket pages 403). Candidates named in the README (Goodman v. U.S. Bank, 25-01034; Seacoast Powersports v. Hemstreet, 25-01004) need their CL storage URLs once the quota resets; date 2026-10-17
BLOCKED nhb/motion-brief: no second-filer motion/memorandum fetched. CourtListener search API quota exhausted (curl and WebFetch) on 2026-10-17; web searches of nhb.uscourts.gov and the open web returned only court opinions and forms, no filed memorandum from a party other than Mission Product Holdings/Bernstein Shur. Retry CL (court=nhb, q=memorandum) when the quota resets; date 2026-10-17
BLOCKED bap1/opening-brief,answering-brief,reply-brief: no second-filer opening or answering brief and no reply brief found; CourtListener RECAP search API (court=ca1, BAP Official Form 2 phrase) exhausted for the box (429, 125/day anonymous quota), web searches (BAP site, justice.gov/ust, general) found only forms, opinions and a redacted sample; retry the ca1 RECAP query when the quota resets (2026-10-17)
BLOCKED tax/petition: no second public filed Tax Court Form 1 petition from a different filer (fb-595.21.1, 2026-10-17). Searched: WebSearch (extended) for filed petitions with assignments of error (only Tax Notes copies, which return HTTP 403 to this box: Meta 16081-25, Abbott Labs 20193-24, Lu 10523-23); SEC EDGAR full-text search for "UNITED STATES TAX COURT" petitions attached as exhibits (none); CourtListener search API throttled (50/hour, exhausted) all day; DAWSON filings are not public. rules.md written; tier 2 rests on one filer (Lawrence, pro se).
BLOCKED tax/pretrial-memorandum: no second public filed pretrial memorandum (petitioner side or other filer) (fb-595.21.1, 2026-10-17). Searched: WebSearch and EDGAR full-text ("pretrial memorandum" "united states tax court": only 10-K/10-Q mentions); Tax Notes copies (Blum 5313-16, GFS Holding 11800-22) HTTP 403; CourtListener API throttled. The 2026 Pretrial Memorandum form (ustaxcourt.gov, PDF dated 2026-09-04) was read and its new fields recorded in rules.md.
BLOCKED bia/brief-on-appeal: no second filed BIA brief on appeal from a different filer (fb-595.21.1, 2026-10-17). Searched: WebSearch (extended) for respondent and DHS BIA briefs on advocacy and court sites; the only other candidate, CLINIC's "Sample BIA Appeal Brief" (Jezic & Moyse, bond appeal), has placeholder names, A-number, amounts and dates, so it cannot be shown to be a filed document; justice.gov (EOIR) returns HTTP 403 to this box; CourtListener API throttled.
BLOCKED orb/adversary-complaint: the court's existing RECAP search found only the Green Oregon Enterprises adversary complaint PDF; Dejong, Columbia Bank, and Large candidates had no public RECAP PDF available. A second different-filer exemplar could not be fetched from public sources on 2026-10-17; see courts/ninth-circuit/oregon/federal/bankruptcy-district/adversary-complaint/exemplars/SOURCE.md.
BLOCKED orb/motion-brief: the existing source search found no second public motion PDF with a matching adversary-motion form; the available Dirksen v. Sheehy motion is the only saved exemplar. Additional public filings were not retrievable after search on 2026-10-17; see courts/ninth-circuit/oregon/federal/bankruptcy-district/motion-brief/exemplars/SOURCE.md.
BLOCKED waed/motion-brief: the public RECAP search recorded for Hartsock v. Battelle found no second motion-to-dismiss brief; located entries were court orders, not party filings. A different-filer exemplar was not found on 2026-10-17; see courts/ninth-circuit/washington/federal/eastern-district/motion-brief/exemplars/SOURCE.md.
BLOCKED wawd/motion-brief: the public RECAP search recorded for Hoffman v. 4 Pillar Consulting found no second motion-to-dismiss brief. A different-filer exemplar was not found on 2026-10-17; see courts/ninth-circuit/washington/federal/western-district/motion-brief/exemplars/SOURCE.md.
BLOCKED bap9/opening-brief: the existing source log records public web and CourtListener searches for a second Ninth Circuit BAP opening brief; only the County of Imperial opening brief is saved. No distinct public filer exemplar was identified by 2026-10-17; see courts/ninth-circuit/bankruptcy-appellate-panel/opening-brief/exemplars/SOURCE.md.
BLOCKED ned/motion-brief: only the Sandoval supporting brief is saved; a distinct second public filer brief is not recorded in the exemplar source log. See courts/eighth-circuit/nebraska/federal/district/motion-brief/exemplars/SOURCE.md.
BLOCKED nebraskab/motion-brief: the saved source set has only one public motion-brief filer; the second-filer search remains unresolved. See courts/eighth-circuit/nebraska/federal/bankruptcy-district/motion-brief/exemplars/SOURCE.md.
BLOCKED ndb/adversary-complaint: the saved source set has one public adversary-complaint filer; no second distinct filer PDF is saved. See courts/eighth-circuit/north-dakota/federal/bankruptcy-district/adversary-complaint/exemplars/SOURCE.md.
BLOCKED ndb/motion-brief: the saved source set has one public motion-brief filer; no second distinct filer PDF is saved. See courts/eighth-circuit/north-dakota/federal/bankruptcy-district/motion-brief/exemplars/SOURCE.md.
BLOCKED sdd/complaint: only one public complaint filer is recorded in the sample folder; no second different-filer PDF is saved. See courts/eighth-circuit/south-dakota/federal/district/complaint/exemplars/SOURCE.md.
BLOCKED sdd/motion-brief: only one public motion-brief filer is recorded in the sample folder; no second different-filer PDF is saved. See courts/eighth-circuit/south-dakota/federal/district/motion-brief/exemplars/SOURCE.md.
BLOCKED sdb/adversary-complaint: only one public adversary complaint filer is saved; the logged exemplar search did not produce a second public filing. See courts/eighth-circuit/south-dakota/federal/bankruptcy-district/adversary-complaint/exemplars/SOURCE.md.
BLOCKED sdb/motion-brief: only one public motion memorandum filer is saved; a second distinct filer exemplar was not located in the source searches. See courts/eighth-circuit/south-dakota/federal/bankruptcy-district/motion-brief/exemplars/SOURCE.md.
BLOCKED bap8/opening-brief: no second public Eighth Circuit BAP appellant opening brief located; existing SOURCE.md records searches through CourtListener, public web sources, ncbrc, and the ca8-indexed RECAP route (2026-10-14 to 2026-10-16); the only publicly retrievable BAP opening brief remains Fisette, filed by a different filer category than an appellee.
BLOCKED bap8/answering-brief: no second public Eighth Circuit BAP appellee brief located; existing SOURCE.md records search across the ca8-indexed BAP dockets and public web sources (2026-10-14 to 2026-10-16); Swackhammer remains the only publicly retrievable appellee brief.
BLOCKED bap8/reply-brief: no public filed Eighth Circuit BAP reply brief located after the four logged search passes through CourtListener/RECAP and public web sources (2026-10-14 to 2026-10-16); Justia is blocked from this box and the appellant's reply in BAP 22-6006 is not in RECAP.
BLOCKED akb/adversary-complaint: only one public filed complaint PDF could be retrieved for the Bankruptcy Court for the District of Alaska. The court site has no complaint PDFs; other known CourtListener adversary dockets had no free PDF or returned throttling, and additional web searches on 2026-10-17 found no second filer. Tier-2 comparison remains incomplete.
BLOCKED azd/complaint: the existing Harod amended complaint is the only court-site/RECAP-accessible exemplar in the folder. A 2026-10-17 search verified that other likely complaints were scanned or lacked a free CourtListener PDF; the accessible Cooprider docket was identified, but no public filing PDF from an allowed source was available.
BLOCKED azd/motion-brief: the existing Evancho motion is the only court-site/RECAP-accessible exemplar in the folder. Candidate filings (Fontes, Steiner) were located, but searches on 2026-10-17 did not yield a filing PDF from an allowed court, CourtListener/RECAP, govinfo, or agency source.
BLOCKED arb/adversary-complaint: one public RECAP complaint by Woodnick Law is available; the additional public searches on 2026-10-17 found no second adversary complaint PDF by a different filer from a court, CourtListener/RECAP, govinfo, or agency source.
BLOCKED arb/motion-brief: only one public court-hosted motion memorandum by a filer is available in the folder. The court-hosted additional Titan trustees' motion was filed by the same firm and does not meet the different-filer requirement; CourtListener and other allowed-source searches on 2026-10-17 found no second filer PDF.
BLOCKED gud/motion-brief: only one public motion-brief exemplar by a filer is available in the existing folder; a 2026-10-17 CourtListener/RECAP and court-site search did not locate a second accessible motion memorandum from a different filer.
BLOCKED gub/adversary-complaint: the existing folder has one public adversary complaint; searches of the official court sources and CourtListener/RECAP on 2026-10-17 did not locate a second freely accessible complaint PDF by a different filer.
BLOCKED gub/motion-brief: the existing folder has one public motion brief; searches of the official court sources and CourtListener/RECAP on 2026-10-17 did not locate a second freely accessible motion brief by a different filer.
BLOCKED hid/complaint: the existing SFFA filing is the sole saved accessible complaint PDF; the README records searches of RECAP and other public repositories but the second filer candidate was not retrieved into the exemplar folder.
BLOCKED hid/motion-brief: the existing State of Hawaii filing is the sole saved accessible motion memorandum PDF; README search notes found no second public filer PDF, and exemplar PDF is absent from this source snapshot.
BLOCKED hib/adversary-complaint: only the Hawaii Brewery adversary complaint is saved; SOURCE.md/README identifies a Collins v. Hughes Network Systems candidate but no public PDF was collected into the folder.
BLOCKED hib/motion-brief: the field-rolloffs motion is the only saved exemplar; no second filer PDF is recorded in SOURCE.md and the README reports one filer only.
BLOCKED mtd/complaint: Free Speech Coalition v. Knudsen is the sole saved complaint exemplar; README records other located Montana filings were unsuitable or not saved as a second filer complaint.
BLOCKED mtd/motion-brief: Free Speech Coalition v. Knudsen is the sole saved supporting brief exemplar; README records no second filer memorandum of this type was located.
BLOCKED mtb/adversary-complaint: the Bache/Noble complaint is the sole saved public adversary complaint; no second different-filer complaint PDF is recorded in SOURCE.md.
BLOCKED mtb/motion-brief: the Mohler trustee-sale motion is the sole saved exemplar; no second different-filer contested-matter motion PDF is recorded in SOURCE.md.
BLOCKED nvd/complaint: the Lovato v. Sasson complaint is the sole saved exemplar; README records other candidates but no second filer PDF was collected.
BLOCKED nvd/motion-brief: the Epica motion is the sole saved exemplar; README records a second candidate but it was not collected, and pro se filings are not a counseled model.
BLOCKED nvb/adversary-complaint: the Lovato v. Sasson adversary complaint is the sole saved exemplar; README records other candidates but no second different-filer PDF was collected.
BLOCKED nvb/motion-brief: the Epica motion is the sole saved exemplar; no second different-filer counseled motion PDF is recorded in SOURCE.md.
BLOCKED nmid/complaint: Ewing complaint is the sole saved exemplar; no second public filed complaint PDF by a different filer is recorded in SOURCE.md.
BLOCKED nmid/motion-brief: Imperial Pacific motion memorandum is the sole saved exemplar; no second different-filer public motion brief PDF is recorded in SOURCE.md.
BLOCKED nmid/rules: the court-hosted 2017 Local Rules source is a Final Redline and available materials do not establish whether its text was adopted or superseded; local rule verification is incomplete.
BLOCKED casb/motion-brief: Only one distinct filer exemplar is available in the folder. The existing source notes identify Medina v. National Collegiate Student Loan Trust (19-90065, Docs 50 and 52) as a second candidate, but its docket and RECAP storage URLs returned 403 in this box; the additional public search pass on 2026-10-17 did not locate another freely accessible S.D. Cal. bankruptcy motion brief. No PACER purchase made. A second filer exemplar is still needed for tier-2 comparison.
BLOCKED mnd/complaint: A second filer complaint is still needed. The prior search found no retrievable public D. Minn. complaint beyond the 3M complaint: Adams Dkt. 1 is sealed and the Luckoff Dkt. 1 RECAP object returns 404; additional CourtListener REST requests are rate-limited/403 and Justia returns 403 from this box. No PACER purchase made.
BLOCKED mnd/motion-brief: A second filer memorandum is still needed. The only saved filing is Adams v. Innes; current CourtListener anonymous RECAP search/API access is rate-limited/403, and prior searches of Justia/Clearinghouse and the court site produced no retrievable second memorandum. No PACER purchase made.
BLOCKED moed/complaint: A second filer complaint is still needed. Jones-Williams v. Missouri Department of Revenue, 4:26-cv-00772-SEP, Doc. 1 is identified as a distinct public filing, but the direct Justia PDF endpoint returns HTTP 403 from this box and CourtListener's anonymous API does not expose the document URL; the accessible opinion/order is not a substitute for the complaint. No PACER purchase made.
BLOCKED moed/motion-brief: A second filer memorandum is still needed. Killgo v. Washington University, 4:25-cv-01407-CMS, Doc. 51 is identified as a distinct public filing, but Justia direct PDF access returns HTTP 403 and the CourtListener anonymous API did not yield a downloadable RECAP object; accessible docket orders are not a substitute. No PACER purchase made.
BLOCKED mowd/complaint: A second filer complaint is still needed. Cincinnati Specialty Underwriters Insurance Co. v. Union Station Kansas City Inc., 4:26-cv-00504, Doc. 1 is identified in public docket search results, but no public RECAP PDF URL was available through the anonymous API and no retrievable public PDF was found in the court search. No PACER purchase made.
BLOCKED mowd/motion-brief: A second filer suggestions/memorandum is still needed. Ketcherside v. Foley, 5:26-cv-06042, Doc. 18 returned HTTP 404 from RECAP storage; Vincenti v. USA Fencing Association, 4:25-cv-00850, Doc. 14 was identified but no public PDF was retrievable. No PACER purchase made.
BLOCKED ared/complaint: rules were added, but a second different-filer public complaint was not collected or source-recorded in this run; tier-2 comparison remains incomplete.
BLOCKED ared/motion-brief: rules were added, but a second different-filer public motion brief was not collected or source-recorded in this run; tier-2 comparison remains incomplete.
BLOCKED arwd/complaint: this court unit was not completed in this run; current local-rule verification and second-filer public exemplar collection/source record remain outstanding.
BLOCKED arwd/motion-brief: this court unit was not completed in this run; current local-rule verification and second-filer public exemplar collection/source record remain outstanding.
BLOCKED areb/adversary-complaint: this court unit was not completed in this run; current local-rule verification and second-filer public exemplar collection/source record remain outstanding.
BLOCKED areb/motion-brief: this court unit was not completed in this run; current local-rule verification and second-filer public exemplar collection/source record remain outstanding.
BLOCKED arwb/adversary-complaint: this court unit was not completed in this run; current local-rule verification and second-filer public exemplar collection/source record remain outstanding.
BLOCKED arwb/motion-brief: this court unit was not completed in this run; current local-rule verification and second-filer public exemplar collection/source record remain outstanding.
BLOCKED iand/complaint: this court unit was not completed in this run; current local-rule verification and second-filer public exemplar collection/source record remain outstanding.
BLOCKED iand/motion-brief: this court unit was not completed in this run; current local-rule verification and second-filer public exemplar collection/source record remain outstanding.
BLOCKED iasd/complaint: this court unit was not completed in this run; current local-rule verification and second-filer public exemplar collection/source record remain outstanding.
BLOCKED iasd/motion-brief: this court unit was not completed in this run; current local-rule verification and second-filer public exemplar collection/source record remain outstanding.
BLOCKED ianb/adversary-complaint: this court unit was not completed in this run; current local-rule verification and second-filer public exemplar collection/source record remain outstanding.
BLOCKED ianb/motion-brief: this court unit was not completed in this run; current local-rule verification and second-filer public exemplar collection/source record remain outstanding.
BLOCKED iasb/adversary-complaint: this court unit was not completed in this run; current local-rule verification and second-filer public exemplar collection/source record remain outstanding.
BLOCKED iasb/motion-brief: this court unit was not completed in this run; current local-rule verification and second-filer public exemplar collection/source record remain outstanding.

BLOCKED ca7/answering-brief: court-specific local-rule provisions and judge standing orders still need full verification against the cited primary sources.
BLOCKED ca7/opening-brief: court-specific local-rule text review remains; a second distinct-filer public exemplar has not been collected.
BLOCKED ca7/reply-brief: court-specific local-rule provisions and judge standing orders still need full verification against the cited primary sources.
BLOCKED ilcb/adversary-complaint: court-specific local-rule provisions and judge standing orders still need full verification against the cited primary sources.
BLOCKED ilcb/motion-brief: court-specific local-rule provisions and judge standing orders still need full verification against the cited primary sources.
BLOCKED ilnb/adversary-complaint: court-specific local-rule text review remains; a second distinct-filer public exemplar has not been collected.
BLOCKED ilnb/motion-brief: court-specific local-rule text review remains; a second distinct-filer public exemplar has not been collected.
BLOCKED ilsb/adversary-complaint: court-specific local-rule text review remains; a second distinct-filer public exemplar has not been collected.
BLOCKED ilsb/motion-brief: court-specific local-rule text review remains; a second distinct-filer public exemplar has not been collected.
BLOCKED ilcd/complaint: court-specific local-rule text review remains; a second distinct-filer public exemplar has not been collected.
BLOCKED ilcd/motion-brief: court-specific local-rule text review remains; a second distinct-filer public exemplar has not been collected.
BLOCKED ilnd/complaint: court-specific local-rule text review remains; a second distinct-filer public exemplar has not been collected.
BLOCKED ilnd/motion-brief: court-specific local-rule text review remains; a second distinct-filer public exemplar has not been collected.
BLOCKED ilsd/complaint: court-specific local-rule text review remains; a second distinct-filer public exemplar has not been collected.
BLOCKED ilsd/motion-brief: court-specific local-rule text review remains; a second distinct-filer public exemplar has not been collected.
BLOCKED innb/adversary-complaint: court-specific local-rule provisions and judge standing orders still need full verification against the cited primary sources.
BLOCKED innb/motion-brief: court-specific local-rule text review remains; a second distinct-filer public exemplar has not been collected.
BLOCKED insb/adversary-complaint: court-specific local-rule text review remains; a second distinct-filer public exemplar has not been collected.
BLOCKED insb/motion-brief: court-specific local-rule text review remains; a second distinct-filer public exemplar has not been collected.
BLOCKED innd/complaint: court-specific local-rule provisions and judge standing orders still need full verification against the cited primary sources.
BLOCKED innd/motion-brief: court-specific local-rule provisions and judge standing orders still need full verification against the cited primary sources.
BLOCKED insd/complaint: court-specific local-rule provisions and judge standing orders still need full verification against the cited primary sources.
BLOCKED insd/motion-brief: court-specific local-rule provisions and judge standing orders still need full verification against the cited primary sources.
BLOCKED wieb/adversary-complaint: court-specific local-rule text review remains; a second distinct-filer public exemplar has not been collected.
BLOCKED wieb/motion-brief: court-specific local-rule text review remains; a second distinct-filer public exemplar has not been collected.
BLOCKED wiwb/adversary-complaint: court-specific local-rule text review remains; a second distinct-filer public exemplar has not been collected.
BLOCKED wiwb/motion-brief: court-specific local-rule text review remains; a second distinct-filer public exemplar has not been collected.
BLOCKED wied/complaint: court-specific local-rule provisions and judge standing orders still need full verification against the cited primary sources.
BLOCKED wied/motion-brief: court-specific local-rule provisions and judge standing orders still need full verification against the cited primary sources.
BLOCKED wiwd/complaint: court-specific local-rule provisions and judge standing orders still need full verification against the cited primary sources.
BLOCKED wiwd/motion-brief: court-specific local-rule text review remains; a second distinct-filer public exemplar has not been collected.
## fb-595.21.2 — Fourth Circuit remainder (2026-10-17)

BLOCKED mdb/adversary-complaint: court-level rules.md has not yet been written for this court; source verification and the second-filer exemplar audit remain outstanding.
BLOCKED mdb/motion-brief: court-level rules.md has not yet been written for this court; source verification and the second-filer exemplar audit remain outstanding.
BLOCKED mdd/complaint: court-level rules.md has not yet been written for this court; source verification and the second-filer exemplar audit remain outstanding.
BLOCKED mdd/motion-brief: court-level rules.md has not yet been written for this court; source verification and the second-filer exemplar audit remain outstanding.
BLOCKED nceb/adversary-complaint: court-level rules.md has not yet been written for this court; source verification and the second-filer exemplar audit remain outstanding.
BLOCKED nceb/motion-brief: court-level rules.md has not yet been written for this court; source verification and the second-filer exemplar audit remain outstanding.
BLOCKED ncmb/adversary-complaint: court-level rules.md has not yet been written for this court; source verification and the second-filer exemplar audit remain outstanding.
BLOCKED ncmb/motion-brief: court-level rules.md has not yet been written for this court; source verification and the second-filer exemplar audit remain outstanding.
BLOCKED ncwb/adversary-complaint: court-level rules.md has not yet been written for this court; source verification and the second-filer exemplar audit remain outstanding.
BLOCKED ncwb/motion-brief: court-level rules.md has not yet been written for this court; source verification and the second-filer exemplar audit remain outstanding.
BLOCKED nced/complaint: court-level rules.md has not yet been written for this court; source verification and the second-filer exemplar audit remain outstanding.
BLOCKED nced/motion-brief: court-level rules.md has not yet been written for this court; source verification and the second-filer exemplar audit remain outstanding.
BLOCKED ncmd/complaint: court-level rules.md has not yet been written for this court; source verification and the second-filer exemplar audit remain outstanding.
BLOCKED ncmd/motion-brief: court-level rules.md has not yet been written for this court; source verification and the second-filer exemplar audit remain outstanding.
BLOCKED ncwd/complaint: court-level rules.md has not yet been written for this court; source verification and the second-filer exemplar audit remain outstanding.
BLOCKED ncwd/motion-brief: court-level rules.md has not yet been written for this court; source verification and the second-filer exemplar audit remain outstanding.
BLOCKED scb/adversary-complaint: court-level rules.md has not yet been written for this court; source verification and the second-filer exemplar audit remain outstanding.
BLOCKED scb/motion-brief: court-level rules.md has not yet been written for this court; source verification and the second-filer exemplar audit remain outstanding.
BLOCKED scd/complaint: court-level rules.md has not yet been written for this court; source verification and the second-filer exemplar audit remain outstanding.
BLOCKED scd/motion-brief: court-level rules.md has not yet been written for this court; source verification and the second-filer exemplar audit remain outstanding.
BLOCKED vaeb/adversary-complaint: court-level rules.md has not yet been written for this court; source verification and the second-filer exemplar audit remain outstanding.
BLOCKED vaeb/motion-brief: court-level rules.md has not yet been written for this court; source verification and the second-filer exemplar audit remain outstanding.
BLOCKED vawb/adversary-complaint: court-level rules.md has not yet been written for this court; source verification and the second-filer exemplar audit remain outstanding.
BLOCKED vawb/motion-brief: court-level rules.md has not yet been written for this court; source verification and the second-filer exemplar audit remain outstanding.
BLOCKED vaed/complaint: court-level rules.md has not yet been written for this court; source verification and the second-filer exemplar audit remain outstanding.
BLOCKED vaed/motion-brief: court-level rules.md has not yet been written for this court; source verification and the second-filer exemplar audit remain outstanding.
BLOCKED vawd/complaint: court-level rules.md has not yet been written for this court; source verification and the second-filer exemplar audit remain outstanding.
BLOCKED vawd/motion-brief: court-level rules.md has not yet been written for this court; source verification and the second-filer exemplar audit remain outstanding.
BLOCKED wvnb/adversary-complaint: court-level rules.md has not yet been written for this court; source verification and the second-filer exemplar audit remain outstanding.
BLOCKED wvnb/motion-brief: court-level rules.md has not yet been written for this court; source verification and the second-filer exemplar audit remain outstanding.
BLOCKED wvsb/adversary-complaint: court-level rules.md has not yet been written for this court; source verification and the second-filer exemplar audit remain outstanding.
BLOCKED wvsb/motion-brief: court-level rules.md has not yet been written for this court; source verification and the second-filer exemplar audit remain outstanding.
BLOCKED wvnd/complaint: court-level rules.md has not yet been written for this court; source verification and the second-filer exemplar audit remain outstanding.
BLOCKED wvnd/motion-brief: court-level rules.md has not yet been written for this court; source verification and the second-filer exemplar audit remain outstanding.
BLOCKED wvsd/complaint: court-level rules.md has not yet been written for this court; source verification and the second-filer exemplar audit remain outstanding.
BLOCKED wvsd/motion-brief: court-level rules.md has not yet been written for this court; source verification and the second-filer exemplar audit remain outstanding.
## fb-595.21.2 — Sixth Circuit remainder (2026-10-17)

BLOCKED bap6/opening-brief: no second-filer filed opening brief was saved; searches surfaced only the official blank pro se form and opinions.
BLOCKED bap6/answering-brief: no second-filer filed answering brief was saved; no usable public BAP answer brief was found in the available court and RECAP sources.
BLOCKED bap6/reply-brief: no second-filer filed reply brief was saved; no usable public BAP reply brief was found in the available court and RECAP sources.
BLOCKED kyeb/motion-brief: the additional Wells Fargo PDF is a motion without a separately filed memorandum, so it does not qualify as a second motion-brief exemplar.
BLOCKED kyed/complaint: court-level rules.md and verified additional exemplar are unfinished.
BLOCKED kyed/motion-brief: court-level rules.md and verified additional exemplar are unfinished.
BLOCKED kywb/adversary-complaint: court-level rules.md and verified additional exemplar are unfinished.
BLOCKED kywb/motion-brief: court-level rules.md and verified additional exemplar are unfinished.
BLOCKED mieb/adversary-complaint: court-level rules.md and second-filer exemplar are unfinished.
BLOCKED mieb/motion-brief: court-level rules.md and second-filer exemplar are unfinished.
BLOCKED mied/complaint: court-level rules.md and second-filer exemplar are unfinished.
BLOCKED mied/motion-brief: court-level rules.md and second-filer exemplar are unfinished.
BLOCKED miwd/complaint: court-level rules.md is unfinished; two public exemplars from different filers are saved.
BLOCKED miwd/motion-brief: court-level rules.md is unfinished; two public exemplars from different filers are saved.
BLOCKED ohnb/complaint: court-level rules.md is unfinished; two public exemplars from different filers are saved.
BLOCKED ohnb/motion-brief: court-level rules.md is unfinished; two public exemplars from different filers are saved.
BLOCKED ohsb/adversary-complaint: court-level rules.md and second-filer exemplar are unfinished.
BLOCKED ohsb/motion-brief: court-level rules.md and second-filer exemplar are unfinished.
BLOCKED ohsd/complaint: court-level rules.md and second-filer exemplar are unfinished.
BLOCKED ohsd/motion-brief: court-level rules.md and second-filer exemplar are unfinished.
BLOCKED tneb/adversary-complaint: court-level rules.md and second-filer exemplar are unfinished.
BLOCKED tneb/motion-brief: court-level rules.md and second-filer exemplar are unfinished.
BLOCKED tnmb/adversary-complaint: court-level rules.md and second-filer exemplar are unfinished.
BLOCKED tnmb/motion-brief: court-level rules.md and second-filer exemplar are unfinished.
BLOCKED tnwb/adversary-complaint: court-level rules.md and second-filer exemplar are unfinished.
BLOCKED tnwb/motion-brief: court-level rules.md and second-filer exemplar are unfinished.
BLOCKED tned/complaint: only one qualifying complaint is saved; the candidate filer record was not retrieved.
BLOCKED tnmd/complaint: the candidate PDF was inspected but shows a placeholder docket number (3:26-mc-9999), so it is not a verified filed exemplar; retrieve a true public docket filing.
BLOCKED tnmd/motion-brief: only one motion-brief exemplar is saved; no second public filing from another filer was retrieved.
BLOCKED tnwd/complaint: court-level rules.md and second-filer exemplar are unfinished.
BLOCKED tnwd/motion-brief: court-level rules.md and second-filer exemplar are unfinished.
## fb-595.21.2 — Fifth Circuit remainder (2026-10-17)

BLOCKED laed/complaint: second complaint exemplar from a different filer, public source metadata, and SHA-256 remain to be added.
BLOCKED laed/motion-brief: second motion/memorandum exemplar from a different filer, public source metadata, and SHA-256 remain to be added.
BLOCKED lamd/complaint: second complaint exemplar from a different filer, public source metadata, and SHA-256 remain to be added.
BLOCKED lamd/motion-brief: second motion/memorandum exemplar from a different filer, public source metadata, and SHA-256 remain to be added.
BLOCKED lawd/complaint: second complaint exemplar from a different filer, public source metadata, and SHA-256 remain to be added.
BLOCKED lawd/motion-brief: second motion/memorandum exemplar from a different filer, public source metadata, and SHA-256 remain to be added.
BLOCKED msnd/complaint: second complaint exemplar from a different filer, public source metadata, and SHA-256 remain to be added.
BLOCKED msnd/motion-brief: second motion/memorandum exemplar from a different filer, public source metadata, and SHA-256 remain to be added.
BLOCKED mssd/complaint: second complaint exemplar from a different filer, public source metadata, and SHA-256 remain to be added.
BLOCKED mssd/motion-brief: second motion/memorandum exemplar from a different filer, public source metadata, and SHA-256 remain to be added.

BLOCKED laeb/adversary-complaint: current Eastern District of Louisiana bankruptcy rules and the second distinct-filer public exemplar have not been verified.
BLOCKED laeb/motion-brief: current Eastern District of Louisiana bankruptcy rules and the second distinct-filer public exemplar have not been verified.
BLOCKED lamb/adversary-complaint: current Middle District of Louisiana bankruptcy rules have not been verified.
BLOCKED lamb/motion-brief: current Middle District of Louisiana bankruptcy rules and the second distinct-filer public exemplar have not been verified.
BLOCKED lawb/adversary-complaint: current Western District of Louisiana bankruptcy rules and the second distinct-filer public exemplar have not been verified.
BLOCKED lawb/motion-brief: current Western District of Louisiana bankruptcy rules and the second distinct-filer public exemplar have not been verified.
BLOCKED msnb/adversary-complaint: current Northern District of Mississippi bankruptcy rules and the second distinct-filer public exemplar have not been verified.
BLOCKED msnb/motion-brief: current Northern District of Mississippi bankruptcy rules and the second distinct-filer public exemplar have not been verified.
BLOCKED mssb/adversary-complaint: current Southern District of Mississippi bankruptcy rules have not been verified.
BLOCKED mssb/motion-brief: current Southern District of Mississippi bankruptcy rules and the second distinct-filer public exemplar have not been verified.

BLOCKED txeb/adversary-complaint: current Eastern District of Texas bankruptcy rules and the second distinct-filer public exemplar have not been verified.
BLOCKED txeb/motion-brief: current Eastern District of Texas bankruptcy rules and the second distinct-filer public exemplar have not been verified.
BLOCKED txnb/adversary-complaint: current Northern District of Texas bankruptcy rules and the second distinct-filer public exemplar have not been verified.
BLOCKED txnb/motion-brief: current Northern District of Texas bankruptcy rules and the second distinct-filer public exemplar have not been verified.
BLOCKED txsb/adversary-complaint: current Southern District of Texas bankruptcy rules and the second distinct-filer public exemplar have not been verified.
BLOCKED txsb/motion-brief: current Southern District of Texas bankruptcy rules and the second distinct-filer public exemplar have not been verified.
BLOCKED txwb/adversary-complaint: current Western District of Texas bankruptcy rules and the second distinct-filer public exemplar have not been verified.
BLOCKED txwb/motion-brief: current Western District of Texas bankruptcy rules and the second distinct-filer public exemplar have not been verified.

BLOCKED txed/complaint: current Eastern District of Texas civil rules have not been verified.
BLOCKED txed/motion-brief: current Eastern District of Texas civil rules have not been verified.
BLOCKED txnd/complaint: current Northern District of Texas civil rules have not been verified.
BLOCKED txnd/motion-brief: current Northern District of Texas civil rules have not been verified.
BLOCKED txsd/complaint: current Southern District of Texas civil rules have not been verified; a second distinct-filer exemplar is also required.
BLOCKED txsd/motion-brief: current Southern District of Texas civil rules have not been verified; a second distinct-filer exemplar is also required.
BLOCKED txwd/complaint: current Western District of Texas civil rules have not been verified.
BLOCKED txwd/motion-brief: current Western District of Texas civil rules have not been verified; a second distinct-filer exemplar is also required.

# State appellate court scope reconciliation
The state-court index has 149 entries labeled `state-supreme` or `state-appellate`. The requested scope is 140 state supreme and appellate courts. These nine indexed entries are out of scope because they are administrative, historical, or trial-level courts rather than state supreme/intermediate appellate courts:
| Alias | Court | Reason excluded |
|---|---|---|
| `masstaxbd` | Massachusetts Appellate Tax Board | Administrative tax tribunal; not an appellate court. |
| `maworkcompcom` | Massachusetts Department of Industrial Accidents | Administrative workers' compensation agency; not an appellate court. |
| `connworkcompcom` | Connecticut Compensation Review Board | Administrative workers' compensation review board; outside the state appellate judiciary. |
| `nycommnapp` | New York Commission of Appeals | Historical court, abolished in 1895. |
| `nyimpct` | New York Court for the Trial of Impeachments | Impeachment trial body, not an appellate court. |
| `nychanctsara` | Saratoga Chancery Court | Historical trial-level chancery court. |
| `risuperct` | Superior Court of Rhode Island | Trial-level court. |
| `delch` | Delaware Court of Chancery | Trial-level court of equity. |
| `delfamct` | Delaware Family Court | Trial-level court. |
The remaining 140 indexed entries are the scope set. The index also contains separate aliases for distinct intermediate appellate courts/districts; those remain separate because each is a separate court folder and has its own filing practice.
## Exemplar collection status
Each in-scope court's `exemplars/SOURCE.md` records the requested document types and whether a qualifying public filed PDF with an extractable text layer was verified. An item marked `BLOCKED` is unfinished and must not be treated as a sourced exemplar. This run did not complete the 700-document source collection; see each court's source manifest for the unresolved types.

## Font-audit replacement searches (2026-10-17)

BLOCKED ared/complaint font-audit replacement: the Hess complaint is a scan with OCR. The only other federal-court complaint candidate recorded in `courts/eighth-circuit/arkansas/federal/eastern-district/complaint/exemplars/SOURCE.md` is Frazier v. People Trust CU, whose PDF is also a scan with hidden OCR rather than a text-based filing. No suitable born-digital replacement was established in this pass.
BLOCKED iasb/adversary-complaint font-audit replacement: the Sturm complaint is a scan with OCR. The source log records that other S.D. Iowa adversary complaints either have no public PDF or are image-only scans; no text-based replacement was identified.
BLOCKED iand/motion-brief font-audit replacement: Gharavi's memorandum has a text layer but uses Segoe UI/Calibri/Arial. The source log records Hane and Close motion-to-dismiss candidates, but their briefs were not available as public PDFs in CourtListener; no replacement filing could be audited.
BLOCKED sdd/complaint font-audit replacement: Knosp's AO form complaint is OCR from a scan. The source log records other D.S.D. complaints but their RECAP PDFs were unavailable; no text-based replacement was identified.
BLOCKED bap1/answering-brief font-audit replacement: Blumsack's answering brief uses Garamond. The only alternate filed brief recorded in the source is the same-case opening brief, a different document type; no other public answering brief with a text layer was identified in the recorded search.
BLOCKED wvsd/complaint font-audit replacement: Castro's complaint is a scan without body text. The source log records other S.D. W. Va. complaints, but the accessible Clearinghouse PDFs returned HTTP 403 and the CourtListener entries had no downloadable PDF; no text-based replacement was identified.
BLOCKED national/tax-court/petition font-audit replacement: no public, downloadable deficiency Form 1 petition with a text layer was found. The closest filed example is a Form 2 CDP petition, a different pleading type; other leads were blank forms or inaccessible.
BLOCKED national/tax-court/pretrial-memorandum font-audit replacement: no public, downloadable filed pretrial memorandum with a text layer was found. Search results were forms and samples; promising Tax Notes filings were inaccessible from this box.
BLOCKED bap9/opening-brief font-audit replacement: no alternate same-court BAP9 opening brief with a text layer was identified; the available Meridian brief is an image scan with OCR.
BLOCKED ca6/opening-brief font-audit replacement: a searchable same-court opening brief was identified (*Yumori-Kaku v. City of Santa Clara*, H046105/H046696, https://www.svvoice.com/wp-content/uploads/2019/10/cvra-city-opening-brief-2019.pdf), but the host returned an HTML access challenge, so no replacement PDF could be saved and verified.
BLOCKED ohsd/complaint font-audit replacement: a searchable same-court complaint was identified (*Thomas v. Wayner*, No. 2:26-cv-00734, Doc. 1, https://docketnexus.com/doc/483024133.pdf), but the host returned an HTML access challenge, so no replacement PDF could be saved and verified.

BLOCKED fb-9fyu Times New Roman render verification: this box has no `/usr/share/fonts/truetype/msttcorefonts` directory and `ttf-mscorefonts-installer` is not installed. The box user has no `sudo`, so the pinned licensed font cannot be installed here. `fb render` stops when that pinned directory is absent; render and embedded-font checks need rerunning on a provisioned Linux or macOS box.
BLOCKED ianb/adversary-complaint font-audit replacement: the two saved complaints, Childers and Hanrahan, both have extractable text but use Calisto, and the recorded ianb search found no text-layer Times New Roman/redistributable-face alternative. Hanrahan v. Ostafi is the same filer's same-structure filing and was not saved; no qualifying alternate is available in the exemplar directory.
BLOCKED acca/answering-brief font-audit replacement: the saved Akbar appellee brief is an image scan with OCR; its page map includes image-only pages. The only other archived ACCA answer found was Gray, which is image-only without a text layer. No text-based ACCA answering brief replacement is saved or identified; CAAF filings belong to a different court.
BLOCKED acca/opening-brief font-audit replacement: the saved Akbar appellant brief is an image scan with OCR; its page map includes image-only pages. The only other archived ACCA opening brief found was Gray, which is image-only without a text layer. The Lorance attachment lead is unavailable from RECAP; no text-based ACCA opening brief replacement is saved or identified. CAAF filings belong to a different court.
## fb-qyxe exemplar download pass (2026-10-17)
All 140 in-scope state court folders now have no PENDING row: 685 doc-type rows COLLECTED (public filed PDF downloaded, text layer checked with pdftotext, SHA-256 recorded; `fb fetch` passes on all 140 folders) and 492 BLOCKED, each with a reason in that court's `exemplars/SOURCE.md`.
BLOCKED fb-qyxe/not-received: 123 rows are filings the court does not receive (rule or statute cited in the row); some cites were written from memory and still need checking against the rule text.
BLOCKED fb-qyxe/search-cap: 128 rows were blocked once the session's web-search cap ran out, or after fewer searches than planned. They are untested, not settled; retry them in a run with search budget, starting with the Missouri Court of Appeals (4 folders), Connecticut, Indiana, Utah, Alaska, Vermont and Rhode Island.
BLOCKED fb-qyxe/no-public-copy: the remaining rows had no free public copy found, the court site blocked this box (Wyoming docket and Missouri Case.net return 403), or the document was a scan with no text layer.
BLOCKED fb-qyxe/no-exemplars: these 20 folders have no exemplar on any row (defunct, administrative or trial-level bodies, or no public docket): `eighth-circuit/arkansas/state/workers-compensation-commission` `eighth-circuit/missouri/state/court-of-appeals-southern-district` `eighth-circuit/north-dakota/state/court-of-appeals` `fifth-circuit/texas/state/court-of-review-tribunal` `first-circuit/massachusetts/state/district-court-appellate-division` `fourth-circuit/north-carolina/state/industrial-commission` `fourth-circuit/south-carolina/state/court-of-chancery` `ninth-circuit/american-samoa/state/high-court` `ninth-circuit/arizona/state/tax-court` `ninth-circuit/california/state/superior-court-appellate-division` `ninth-circuit/montana/state/tax-appeal-board` `ninth-circuit/northern-mariana-islands/state/supreme-court` `ninth-circuit/oregon/state/tax-court` `seventh-circuit/indiana/state/tax-court` `sixth-circuit/ohio/state/court-of-claims` `tenth-circuit/colorado/state/industrial-claim-appeals-office` `tenth-circuit/oklahoma/state/court-on-the-judiciary` `tenth-circuit/oklahoma/state/judicial-ethics-advisory-panel` `third-circuit/delaware/state/court-on-the-judiciary` `third-circuit/new-jersey/state/tax-court`
NOTE fb-qyxe/refetch: some recorded URLs may not re-download with plain curl: Florida ACIS (proof-of-work), Arkansas caseinfo (r.jina.ai proxy, links expire), Tennessee (JS challenge), Turtle Talk/mass.gov/1851center (user-agent 403). Several Idaho, Utah, Arizona, Kansas, New Hampshire and Missouri copies are Wayback Machine URLs. Democracy Docket copies carry a watermark.

## Follow-up audit — fb-l129.4 (2026-10-17)
BLOCKED rows re-searched for Texas state courts; targeted public-source queries reviewed against official Texas Judicial Branch rules, SCJC postings, and Texas statutes. No additional qualifying downloadable text-layer PDF was verified.
BLOCKED fb-l129.4 Texas texreview/opening-brief: official rules/forms, SCJC opinions, Texas statutes and targeted filing searches yielded no retrievable qualifying PDF; see courts/fifth-circuit/texas/state/special-court-of-review/exemplars/SOURCE.md
BLOCKED fb-l129.4 Texas texreview/petition-for-discretionary-review: official rules/forms, SCJC opinions, Texas statutes and targeted filing searches yielded no retrievable qualifying PDF; see courts/fifth-circuit/texas/state/special-court-of-review/exemplars/SOURCE.md
BLOCKED fb-l129.4 Texas texreview/petition-for-review: official rules/forms, SCJC opinions, Texas statutes and targeted filing searches yielded no retrievable qualifying PDF; see courts/fifth-circuit/texas/state/special-court-of-review/exemplars/SOURCE.md
BLOCKED fb-l129.4 Texas texreview/petition-for-writ: official rules/forms, SCJC opinions, Texas statutes and targeted filing searches yielded no retrievable qualifying PDF; see courts/fifth-circuit/texas/state/special-court-of-review/exemplars/SOURCE.md
BLOCKED fb-l129.4 Texas texreview/amicus-brief: official rules/forms, SCJC opinions, Texas statutes and targeted filing searches yielded no retrievable qualifying PDF; see courts/fifth-circuit/texas/state/special-court-of-review/exemplars/SOURCE.md
BLOCKED fb-l129.4 Texas texjpml/opening-brief: official rules/forms, SCJC opinions, Texas statutes and targeted filing searches yielded no retrievable qualifying PDF; see courts/fifth-circuit/texas/state/judicial-panel-on-multidistrict-litigation/exemplars/SOURCE.md
BLOCKED fb-l129.4 Texas texjpml/petition-for-discretionary-review: official rules/forms, SCJC opinions, Texas statutes and targeted filing searches yielded no retrievable qualifying PDF; see courts/fifth-circuit/texas/state/judicial-panel-on-multidistrict-litigation/exemplars/SOURCE.md
BLOCKED fb-l129.4 Texas texjpml/petition-for-review: official rules/forms, SCJC opinions, Texas statutes and targeted filing searches yielded no retrievable qualifying PDF; see courts/fifth-circuit/texas/state/judicial-panel-on-multidistrict-litigation/exemplars/SOURCE.md
BLOCKED fb-l129.4 Texas texjpml/petition-for-writ: official rules/forms, SCJC opinions, Texas statutes and targeted filing searches yielded no retrievable qualifying PDF; see courts/fifth-circuit/texas/state/judicial-panel-on-multidistrict-litigation/exemplars/SOURCE.md
BLOCKED fb-l129.4 Texas texcrimapp/petition-for-review: official rules/forms, SCJC opinions, Texas statutes and targeted filing searches yielded no retrievable qualifying PDF; see courts/fifth-circuit/texas/state/court-of-criminal-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4 Texas texcrimapp/petition-for-writ: official rules/forms, SCJC opinions, Texas statutes and targeted filing searches yielded no retrievable qualifying PDF; see courts/fifth-circuit/texas/state/court-of-criminal-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4 Texas texapp/petition-for-discretionary-review: official rules/forms, SCJC opinions, Texas statutes and targeted filing searches yielded no retrievable qualifying PDF; see courts/fifth-circuit/texas/state/court-of-civil-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4 Texas texapp/petition-for-review: official rules/forms, SCJC opinions, Texas statutes and targeted filing searches yielded no retrievable qualifying PDF; see courts/fifth-circuit/texas/state/court-of-civil-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4 Texas texrevtrib/opening-brief: official rules/forms, SCJC opinions, Texas statutes and targeted filing searches yielded no retrievable qualifying PDF; see courts/fifth-circuit/texas/state/court-of-review-tribunal/exemplars/SOURCE.md
BLOCKED fb-l129.4 Texas texrevtrib/answering-brief: official rules/forms, SCJC opinions, Texas statutes and targeted filing searches yielded no retrievable qualifying PDF; see courts/fifth-circuit/texas/state/court-of-review-tribunal/exemplars/SOURCE.md
BLOCKED fb-l129.4 Texas texrevtrib/reply-brief: official rules/forms, SCJC opinions, Texas statutes and targeted filing searches yielded no retrievable qualifying PDF; see courts/fifth-circuit/texas/state/court-of-review-tribunal/exemplars/SOURCE.md
BLOCKED fb-l129.4 Texas texrevtrib/petition-for-discretionary-review: official rules/forms, SCJC opinions, Texas statutes and targeted filing searches yielded no retrievable qualifying PDF; see courts/fifth-circuit/texas/state/court-of-review-tribunal/exemplars/SOURCE.md
BLOCKED fb-l129.4 Texas texrevtrib/motion-brief: official rules/forms, SCJC opinions, Texas statutes and targeted filing searches yielded no retrievable qualifying PDF; see courts/fifth-circuit/texas/state/court-of-review-tribunal/exemplars/SOURCE.md
BLOCKED fb-l129.4 Texas texrevtrib/petition-for-review: official rules/forms, SCJC opinions, Texas statutes and targeted filing searches yielded no retrievable qualifying PDF; see courts/fifth-circuit/texas/state/court-of-review-tribunal/exemplars/SOURCE.md
BLOCKED fb-l129.4 Texas texrevtrib/petition-for-writ: official rules/forms, SCJC opinions, Texas statutes and targeted filing searches yielded no retrievable qualifying PDF; see courts/fifth-circuit/texas/state/court-of-review-tribunal/exemplars/SOURCE.md
BLOCKED fb-l129.4 Texas texrevtrib/amicus-brief: official rules/forms, SCJC opinions, Texas statutes and targeted filing searches yielded no retrievable qualifying PDF; see courts/fifth-circuit/texas/state/court-of-review-tribunal/exemplars/SOURCE.md

## Follow-up audit — fb-l129.4 (2026-10-17)
BLOCKED rows re-searched for Indiana state courts; official appellate rules, Clerk/MyCase access guidance, Attorney General appeals materials, and targeted filing queries reviewed. No newly retrieved filing matched a BLOCKED row.
BLOCKED fb-l129.4 Indiana ind/brief-on-the-merits: official rules, clerk/MyCase guidance, AG materials, targeted filing search; no applicable text-layer PDF retrieved; see courts/seventh-circuit/indiana/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 Indiana ind/answering-brief: official rules, clerk/MyCase guidance, AG materials, targeted filing search; no applicable text-layer PDF retrieved; see courts/seventh-circuit/indiana/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 Indiana ind/reply-brief: official rules, clerk/MyCase guidance, AG materials, targeted filing search; no applicable text-layer PDF retrieved; see courts/seventh-circuit/indiana/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 Indiana ind/petition-for-review: official rules, clerk/MyCase guidance, AG materials, targeted filing search; no applicable text-layer PDF retrieved; see courts/seventh-circuit/indiana/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 Indiana ind/petition-for-writ: official rules, clerk/MyCase guidance, AG materials, targeted filing search; no applicable text-layer PDF retrieved; see courts/seventh-circuit/indiana/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 Indiana ind/amicus-brief: official rules, clerk/MyCase guidance, AG materials, targeted filing search; no applicable text-layer PDF retrieved; see courts/seventh-circuit/indiana/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 Indiana indctapp/petition-for-discretionary-review: official rules, clerk/MyCase guidance, AG materials, targeted filing search; no applicable text-layer PDF retrieved; see courts/seventh-circuit/indiana/state/court-of-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4 Indiana indctapp/motion-brief: official rules, clerk/MyCase guidance, AG materials, targeted filing search; no applicable text-layer PDF retrieved; see courts/seventh-circuit/indiana/state/court-of-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4 Indiana indctapp/petition-for-review: official rules, clerk/MyCase guidance, AG materials, targeted filing search; no applicable text-layer PDF retrieved; see courts/seventh-circuit/indiana/state/court-of-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4 Indiana indctapp/petition-for-writ: official rules, clerk/MyCase guidance, AG materials, targeted filing search; no applicable text-layer PDF retrieved; see courts/seventh-circuit/indiana/state/court-of-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4 Indiana indctapp/amicus-brief: official rules, clerk/MyCase guidance, AG materials, targeted filing search; no applicable text-layer PDF retrieved; see courts/seventh-circuit/indiana/state/court-of-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4 Indiana indtc/opening-brief: official rules, clerk/MyCase guidance, AG materials, targeted filing search; no applicable text-layer PDF retrieved; see courts/seventh-circuit/indiana/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 Indiana indtc/answering-brief: official rules, clerk/MyCase guidance, AG materials, targeted filing search; no applicable text-layer PDF retrieved; see courts/seventh-circuit/indiana/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 Indiana indtc/reply-brief: official rules, clerk/MyCase guidance, AG materials, targeted filing search; no applicable text-layer PDF retrieved; see courts/seventh-circuit/indiana/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 Indiana indtc/petition-for-discretionary-review: official rules, clerk/MyCase guidance, AG materials, targeted filing search; no applicable text-layer PDF retrieved; see courts/seventh-circuit/indiana/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 Indiana indtc/motion-brief: official rules, clerk/MyCase guidance, AG materials, targeted filing search; no applicable text-layer PDF retrieved; see courts/seventh-circuit/indiana/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 Indiana indtc/petition-for-review: official rules, clerk/MyCase guidance, AG materials, targeted filing search; no applicable text-layer PDF retrieved; see courts/seventh-circuit/indiana/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 Indiana indtc/petition-for-writ: official rules, clerk/MyCase guidance, AG materials, targeted filing search; no applicable text-layer PDF retrieved; see courts/seventh-circuit/indiana/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 Indiana indtc/amicus-brief: official rules, clerk/MyCase guidance, AG materials, targeted filing search; no applicable text-layer PDF retrieved; see courts/seventh-circuit/indiana/state/tax-court/exemplars/SOURCE.md

## Follow-up audit — fb-l129.4 (2026-10-17)
BLOCKED rows re-searched for mississippi state courts; official rules/docket indexes and targeted public-filing queries reviewed. No additional qualifying downloadable text-layer PDF was verified for the remaining BLOCKED rows.
BLOCKED fb-l129.4  miss/petition-for-review: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/fifth-circuit/mississippi/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4  miss/petition-for-discretionary-review: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/fifth-circuit/mississippi/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4  missctapp/petition-for-discretionary-review: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/fifth-circuit/mississippi/state/court-of-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4  missctapp/petition-for-review: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/fifth-circuit/mississippi/state/court-of-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4  missctapp/petition-for-writ: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/fifth-circuit/mississippi/state/court-of-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4  misschanceryct/opening-brief: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/fifth-circuit/mississippi/state/chancery-courts/exemplars/SOURCE.md
BLOCKED fb-l129.4  misschanceryct/answering-brief: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/fifth-circuit/mississippi/state/chancery-courts/exemplars/SOURCE.md
BLOCKED fb-l129.4  misschanceryct/reply-brief: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/fifth-circuit/mississippi/state/chancery-courts/exemplars/SOURCE.md
BLOCKED fb-l129.4  misschanceryct/petition-for-discretionary-review: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/fifth-circuit/mississippi/state/chancery-courts/exemplars/SOURCE.md
BLOCKED fb-l129.4  misschanceryct/petition-for-review: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/fifth-circuit/mississippi/state/chancery-courts/exemplars/SOURCE.md
BLOCKED fb-l129.4  misschanceryct/petition-for-writ: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/fifth-circuit/mississippi/state/chancery-courts/exemplars/SOURCE.md
BLOCKED fb-l129.4  misschanceryct/amicus-brief: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/fifth-circuit/mississippi/state/chancery-courts/exemplars/SOURCE.md

## Follow-up audit — fb-l129.4 (2026-10-17)
BLOCKED rows re-searched for pennsylvania state courts; official rules/docket indexes and targeted public-filing queries reviewed. No additional qualifying downloadable text-layer PDF was verified for the remaining BLOCKED rows.
BLOCKED fb-l129.4  pasuperct/petition-for-discretionary-review: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/third-circuit/pennsylvania/state/superior-court/exemplars/SOURCE.md
BLOCKED fb-l129.4  pasuperct/petition-for-review: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/third-circuit/pennsylvania/state/superior-court/exemplars/SOURCE.md
BLOCKED fb-l129.4  pasuperct/petition-for-writ: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/third-circuit/pennsylvania/state/superior-court/exemplars/SOURCE.md
BLOCKED fb-l129.4  pacommwct/petition-for-discretionary-review: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/third-circuit/pennsylvania/state/commonwealth-court/exemplars/SOURCE.md
BLOCKED fb-l129.4  cjdpa/opening-brief: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/third-circuit/pennsylvania/state/court-of-judicial-discipline/exemplars/SOURCE.md
BLOCKED fb-l129.4  cjdpa/answering-brief: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/third-circuit/pennsylvania/state/court-of-judicial-discipline/exemplars/SOURCE.md
BLOCKED fb-l129.4  cjdpa/reply-brief: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/third-circuit/pennsylvania/state/court-of-judicial-discipline/exemplars/SOURCE.md
BLOCKED fb-l129.4  cjdpa/petition-for-discretionary-review: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/third-circuit/pennsylvania/state/court-of-judicial-discipline/exemplars/SOURCE.md
BLOCKED fb-l129.4  cjdpa/petition-for-review: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/third-circuit/pennsylvania/state/court-of-judicial-discipline/exemplars/SOURCE.md
BLOCKED fb-l129.4  cjdpa/petition-for-writ: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/third-circuit/pennsylvania/state/court-of-judicial-discipline/exemplars/SOURCE.md
BLOCKED fb-l129.4  cjdpa/amicus-brief: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/third-circuit/pennsylvania/state/court-of-judicial-discipline/exemplars/SOURCE.md

## Follow-up audit — fb-l129.4 (2026-10-17)
BLOCKED rows re-searched for new-jersey state courts; official rules/docket indexes and targeted public-filing queries reviewed. No additional qualifying downloadable text-layer PDF was verified for the remaining BLOCKED rows.
BLOCKED fb-l129.4  nj/reply-brief: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/third-circuit/new-jersey/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4  nj/petition-for-review: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/third-circuit/new-jersey/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4  nj/petition-for-discretionary-review: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/third-circuit/new-jersey/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4  nj/petition-for-rehearing: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/third-circuit/new-jersey/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4  njtaxct/opening-brief: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/third-circuit/new-jersey/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4  njtaxct/answering-brief: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/third-circuit/new-jersey/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4  njtaxct/reply-brief: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/third-circuit/new-jersey/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4  njtaxct/petition-for-discretionary-review: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/third-circuit/new-jersey/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4  njtaxct/motion-brief: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/third-circuit/new-jersey/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4  njtaxct/petition-for-review: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/third-circuit/new-jersey/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4  njtaxct/petition-for-writ: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/third-circuit/new-jersey/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4  njtaxct/amicus-brief: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/third-circuit/new-jersey/state/tax-court/exemplars/SOURCE.md

## Follow-up audit — fb-l129.4 (2026-10-17)
BLOCKED rows re-searched for oregon state courts; official rules/docket indexes and targeted public-filing queries reviewed. No additional qualifying downloadable text-layer PDF was verified for the remaining BLOCKED rows.
BLOCKED fb-l129.4  orctapp/petition-for-discretionary-review: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/ninth-circuit/oregon/state/court-of-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4  orctapp/petition-for-writ: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/ninth-circuit/oregon/state/court-of-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4  ortc/opening-brief: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/ninth-circuit/oregon/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4  ortc/answering-brief: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/ninth-circuit/oregon/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4  ortc/reply-brief: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/ninth-circuit/oregon/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4  ortc/petition-for-discretionary-review: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/ninth-circuit/oregon/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4  ortc/motion-brief: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/ninth-circuit/oregon/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4  ortc/petition-for-review: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/ninth-circuit/oregon/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4  ortc/petition-for-writ: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/ninth-circuit/oregon/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4  ortc/amicus-brief: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/ninth-circuit/oregon/state/tax-court/exemplars/SOURCE.md

## Follow-up audit — fb-l129.4 (2026-10-17)
BLOCKED rows re-searched for tennessee state courts; official rules/docket indexes and targeted public-filing queries reviewed. No additional qualifying downloadable text-layer PDF was verified for the remaining BLOCKED rows.
BLOCKED fb-l129.4  tenncrimapp/reply-brief: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/sixth-circuit/tennessee/state/court-of-criminal-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4  tenncrimapp/petition-for-discretionary-review: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/sixth-circuit/tennessee/state/court-of-criminal-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4  tenncrimapp/petition-for-review: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/sixth-circuit/tennessee/state/court-of-criminal-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4  tenncrimapp/petition-for-writ: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/sixth-circuit/tennessee/state/court-of-criminal-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4  tenn/petition-for-writ: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/sixth-circuit/tennessee/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4  tennctapp/motion-brief: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/sixth-circuit/tennessee/state/court-of-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4  tennctapp/petition-for-review: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/sixth-circuit/tennessee/state/court-of-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4  tennctapp/petition-for-writ: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/sixth-circuit/tennessee/state/court-of-appeals/exemplars/SOURCE.md

## Follow-up audit — fb-l129.4 (2026-10-17)
BLOCKED rows re-searched for montana state courts; official rules/docket indexes and targeted public-filing queries reviewed. No additional qualifying downloadable text-layer PDF was verified for the remaining BLOCKED rows.
BLOCKED fb-l129.4  monttc/opening-brief: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/ninth-circuit/montana/state/tax-appeal-board/exemplars/SOURCE.md
BLOCKED fb-l129.4  monttc/answering-brief: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/ninth-circuit/montana/state/tax-appeal-board/exemplars/SOURCE.md
BLOCKED fb-l129.4  monttc/reply-brief: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/ninth-circuit/montana/state/tax-appeal-board/exemplars/SOURCE.md
BLOCKED fb-l129.4  monttc/petition-for-discretionary-review: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/ninth-circuit/montana/state/tax-appeal-board/exemplars/SOURCE.md
BLOCKED fb-l129.4  monttc/motion-brief: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/ninth-circuit/montana/state/tax-appeal-board/exemplars/SOURCE.md
BLOCKED fb-l129.4  monttc/petition-for-review: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/ninth-circuit/montana/state/tax-appeal-board/exemplars/SOURCE.md
BLOCKED fb-l129.4  monttc/petition-for-writ: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/ninth-circuit/montana/state/tax-appeal-board/exemplars/SOURCE.md
BLOCKED fb-l129.4  monttc/amicus-brief: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/ninth-circuit/montana/state/tax-appeal-board/exemplars/SOURCE.md

## Follow-up audit — fb-l129.4 (2026-10-17)
BLOCKED rows re-searched for iowa state courts; official rules/docket indexes and targeted public-filing queries reviewed. No additional qualifying downloadable text-layer PDF was verified for the remaining BLOCKED rows.
BLOCKED fb-l129.4  iowa/petition-for-writ: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/eighth-circuit/iowa/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4  iowactapp/petition-for-discretionary-review: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/eighth-circuit/iowa/state/court-of-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4  iowactapp/motion-brief: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/eighth-circuit/iowa/state/court-of-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4  iowactapp/petition-for-review: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/eighth-circuit/iowa/state/court-of-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4  iowactapp/petition-for-writ: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/eighth-circuit/iowa/state/court-of-appeals/exemplars/SOURCE.md

## Follow-up audit — fb-l129.4 (2026-10-17)
BLOCKED rows re-searched for wyoming state courts; official rules/docket indexes and targeted public-filing queries reviewed. No additional qualifying downloadable text-layer PDF was verified for the remaining BLOCKED rows.
BLOCKED fb-l129.4  wyo/answering-brief: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/tenth-circuit/wyoming/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4  wyo/petition-for-review: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/tenth-circuit/wyoming/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4  wyo/motion-brief: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/tenth-circuit/wyoming/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4  wyo/petition-for-discretionary-review: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/tenth-circuit/wyoming/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4  wyo/petition-for-writ: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/tenth-circuit/wyoming/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4  wyo/petition-for-rehearing: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/tenth-circuit/wyoming/state/supreme-court/exemplars/SOURCE.md

## Follow-up audit — fb-l129.4 (2026-10-17)
BLOCKED rows re-searched for vermont state courts; official rules/docket indexes and targeted public-filing queries reviewed. No additional qualifying downloadable text-layer PDF was verified for the remaining BLOCKED rows.
BLOCKED fb-l129.4  vt/petition-for-review: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/second-circuit/vermont/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4  vt/motion-brief: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/second-circuit/vermont/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4  vt/petition-for-discretionary-review: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/second-circuit/vermont/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4  vt/petition-for-writ: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/second-circuit/vermont/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4  vt/petition-for-rehearing: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/second-circuit/vermont/state/supreme-court/exemplars/SOURCE.md

## Follow-up audit — fb-l129.4 (2026-10-17)
BLOCKED rows re-searched for illinois state courts; official rules/docket indexes and targeted public-filing queries reviewed. No additional qualifying downloadable text-layer PDF was verified for the remaining BLOCKED rows.
BLOCKED fb-l129.4  ill/petition-for-rehearing: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/seventh-circuit/illinois/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4  illappct/petition-for-discretionary-review: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/seventh-circuit/illinois/state/appellate-court/exemplars/SOURCE.md
BLOCKED fb-l129.4  illappct/petition-for-writ: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/seventh-circuit/illinois/state/appellate-court/exemplars/SOURCE.md

## Follow-up audit — fb-l129.4 (2026-10-17)
BLOCKED rows re-searched for michigan state courts; official rules/docket indexes and targeted public-filing queries reviewed. No additional qualifying downloadable text-layer PDF was verified for the remaining BLOCKED rows.
BLOCKED fb-l129.4  michctapp/answering-brief: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/sixth-circuit/michigan/state/court-of-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4  michctapp/petition-for-review: follow-up official-source and public filing searches found no retrievable qualifying filing; see courts/sixth-circuit/michigan/state/court-of-appeals/exemplars/SOURCE.md

RESOLVED fb-l129.4 Vermont rule cite: `vt/petition-for-review` is verified against 3 V.S.A. § 815(a), (c) and the official V.R.A.P. 3-4 Notice of Appeal form. Agency review is commenced by notice of appeal, so the existing row remains BLOCKED as not a petition type, with a primary-source citation now recorded in `courts/second-circuit/vermont/state/supreme-court/exemplars/SOURCE.md`.
RESOLVED fb-l129.4 Vermont cite checks: V.R.A.P. 5 permission-to-appeal route, Rule 21 extraordinary-relief petitions, and Rule 40 motions for reargument verified against Vermont Supreme Court opinions dated 2023-11-17 and 2016-10-07. The cited official opinions are now recorded in the three corresponding blocked rows in `courts/second-circuit/vermont/state/supreme-court/exemplars/SOURCE.md`; the exemplar rows remain blocked because no qualifying filed text-layer PDFs were retrieved.

## fb-l129.4 audit identifier correction

The per-row entries in the initial L4 follow-up sections omit the state name between the bead id and court alias due to a logging-variable error. The following appended entries repeat those identifiers with the state field populated; use these corrected rows when matching unresolved statuses to SOURCE.md.
BLOCKED fb-l129.4 texas texreview/opening-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/fifth-circuit/texas/state/special-court-of-review/exemplars/SOURCE.md
BLOCKED fb-l129.4 texas texreview/petition-for-discretionary-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/fifth-circuit/texas/state/special-court-of-review/exemplars/SOURCE.md
BLOCKED fb-l129.4 texas texreview/petition-for-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/fifth-circuit/texas/state/special-court-of-review/exemplars/SOURCE.md
BLOCKED fb-l129.4 texas texreview/petition-for-writ: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/fifth-circuit/texas/state/special-court-of-review/exemplars/SOURCE.md
BLOCKED fb-l129.4 texas texreview/amicus-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/fifth-circuit/texas/state/special-court-of-review/exemplars/SOURCE.md
BLOCKED fb-l129.4 texas texjpml/opening-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/fifth-circuit/texas/state/judicial-panel-on-multidistrict-litigation/exemplars/SOURCE.md
BLOCKED fb-l129.4 texas texjpml/petition-for-discretionary-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/fifth-circuit/texas/state/judicial-panel-on-multidistrict-litigation/exemplars/SOURCE.md
BLOCKED fb-l129.4 texas texjpml/petition-for-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/fifth-circuit/texas/state/judicial-panel-on-multidistrict-litigation/exemplars/SOURCE.md
BLOCKED fb-l129.4 texas texjpml/petition-for-writ: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/fifth-circuit/texas/state/judicial-panel-on-multidistrict-litigation/exemplars/SOURCE.md
BLOCKED fb-l129.4 texas texcrimapp/petition-for-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/fifth-circuit/texas/state/court-of-criminal-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4 texas texcrimapp/petition-for-writ: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/fifth-circuit/texas/state/court-of-criminal-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4 texas texapp/petition-for-discretionary-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/fifth-circuit/texas/state/court-of-civil-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4 texas texapp/petition-for-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/fifth-circuit/texas/state/court-of-civil-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4 texas texrevtrib/opening-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/fifth-circuit/texas/state/court-of-review-tribunal/exemplars/SOURCE.md
BLOCKED fb-l129.4 texas texrevtrib/answering-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/fifth-circuit/texas/state/court-of-review-tribunal/exemplars/SOURCE.md
BLOCKED fb-l129.4 texas texrevtrib/reply-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/fifth-circuit/texas/state/court-of-review-tribunal/exemplars/SOURCE.md
BLOCKED fb-l129.4 texas texrevtrib/petition-for-discretionary-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/fifth-circuit/texas/state/court-of-review-tribunal/exemplars/SOURCE.md
BLOCKED fb-l129.4 texas texrevtrib/motion-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/fifth-circuit/texas/state/court-of-review-tribunal/exemplars/SOURCE.md
BLOCKED fb-l129.4 texas texrevtrib/petition-for-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/fifth-circuit/texas/state/court-of-review-tribunal/exemplars/SOURCE.md
BLOCKED fb-l129.4 texas texrevtrib/petition-for-writ: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/fifth-circuit/texas/state/court-of-review-tribunal/exemplars/SOURCE.md
BLOCKED fb-l129.4 texas texrevtrib/amicus-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/fifth-circuit/texas/state/court-of-review-tribunal/exemplars/SOURCE.md
BLOCKED fb-l129.4 indiana ind/brief-on-the-merits: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/seventh-circuit/indiana/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 indiana ind/answering-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/seventh-circuit/indiana/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 indiana ind/reply-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/seventh-circuit/indiana/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 indiana ind/petition-for-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/seventh-circuit/indiana/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 indiana ind/petition-for-writ: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/seventh-circuit/indiana/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 indiana ind/amicus-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/seventh-circuit/indiana/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 indiana indctapp/petition-for-discretionary-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/seventh-circuit/indiana/state/court-of-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4 indiana indctapp/motion-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/seventh-circuit/indiana/state/court-of-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4 indiana indctapp/petition-for-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/seventh-circuit/indiana/state/court-of-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4 indiana indctapp/petition-for-writ: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/seventh-circuit/indiana/state/court-of-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4 indiana indctapp/amicus-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/seventh-circuit/indiana/state/court-of-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4 indiana indtc/opening-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/seventh-circuit/indiana/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 indiana indtc/answering-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/seventh-circuit/indiana/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 indiana indtc/reply-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/seventh-circuit/indiana/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 indiana indtc/petition-for-discretionary-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/seventh-circuit/indiana/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 indiana indtc/motion-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/seventh-circuit/indiana/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 indiana indtc/petition-for-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/seventh-circuit/indiana/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 indiana indtc/petition-for-writ: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/seventh-circuit/indiana/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 indiana indtc/amicus-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/seventh-circuit/indiana/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 mississippi miss/petition-for-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/fifth-circuit/mississippi/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 mississippi miss/petition-for-discretionary-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/fifth-circuit/mississippi/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 mississippi missctapp/petition-for-discretionary-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/fifth-circuit/mississippi/state/court-of-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4 mississippi missctapp/petition-for-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/fifth-circuit/mississippi/state/court-of-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4 mississippi missctapp/petition-for-writ: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/fifth-circuit/mississippi/state/court-of-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4 mississippi misschanceryct/opening-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/fifth-circuit/mississippi/state/chancery-courts/exemplars/SOURCE.md
BLOCKED fb-l129.4 mississippi misschanceryct/answering-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/fifth-circuit/mississippi/state/chancery-courts/exemplars/SOURCE.md
BLOCKED fb-l129.4 mississippi misschanceryct/reply-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/fifth-circuit/mississippi/state/chancery-courts/exemplars/SOURCE.md
BLOCKED fb-l129.4 mississippi misschanceryct/petition-for-discretionary-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/fifth-circuit/mississippi/state/chancery-courts/exemplars/SOURCE.md
BLOCKED fb-l129.4 mississippi misschanceryct/petition-for-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/fifth-circuit/mississippi/state/chancery-courts/exemplars/SOURCE.md
BLOCKED fb-l129.4 mississippi misschanceryct/petition-for-writ: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/fifth-circuit/mississippi/state/chancery-courts/exemplars/SOURCE.md
BLOCKED fb-l129.4 mississippi misschanceryct/amicus-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/fifth-circuit/mississippi/state/chancery-courts/exemplars/SOURCE.md
BLOCKED fb-l129.4 pennsylvania pasuperct/petition-for-discretionary-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/third-circuit/pennsylvania/state/superior-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 pennsylvania pasuperct/petition-for-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/third-circuit/pennsylvania/state/superior-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 pennsylvania pasuperct/petition-for-writ: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/third-circuit/pennsylvania/state/superior-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 pennsylvania pacommwct/petition-for-discretionary-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/third-circuit/pennsylvania/state/commonwealth-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 pennsylvania cjdpa/opening-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/third-circuit/pennsylvania/state/court-of-judicial-discipline/exemplars/SOURCE.md
BLOCKED fb-l129.4 pennsylvania cjdpa/answering-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/third-circuit/pennsylvania/state/court-of-judicial-discipline/exemplars/SOURCE.md
BLOCKED fb-l129.4 pennsylvania cjdpa/reply-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/third-circuit/pennsylvania/state/court-of-judicial-discipline/exemplars/SOURCE.md
BLOCKED fb-l129.4 pennsylvania cjdpa/petition-for-discretionary-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/third-circuit/pennsylvania/state/court-of-judicial-discipline/exemplars/SOURCE.md
BLOCKED fb-l129.4 pennsylvania cjdpa/petition-for-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/third-circuit/pennsylvania/state/court-of-judicial-discipline/exemplars/SOURCE.md
BLOCKED fb-l129.4 pennsylvania cjdpa/petition-for-writ: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/third-circuit/pennsylvania/state/court-of-judicial-discipline/exemplars/SOURCE.md
BLOCKED fb-l129.4 pennsylvania cjdpa/amicus-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/third-circuit/pennsylvania/state/court-of-judicial-discipline/exemplars/SOURCE.md
BLOCKED fb-l129.4 new-jersey nj/reply-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/third-circuit/new-jersey/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 new-jersey nj/petition-for-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/third-circuit/new-jersey/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 new-jersey nj/petition-for-discretionary-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/third-circuit/new-jersey/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 new-jersey nj/petition-for-rehearing: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/third-circuit/new-jersey/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 new-jersey njtaxct/opening-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/third-circuit/new-jersey/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 new-jersey njtaxct/answering-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/third-circuit/new-jersey/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 new-jersey njtaxct/reply-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/third-circuit/new-jersey/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 new-jersey njtaxct/petition-for-discretionary-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/third-circuit/new-jersey/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 new-jersey njtaxct/motion-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/third-circuit/new-jersey/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 new-jersey njtaxct/petition-for-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/third-circuit/new-jersey/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 new-jersey njtaxct/petition-for-writ: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/third-circuit/new-jersey/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 new-jersey njtaxct/amicus-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/third-circuit/new-jersey/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 oregon orctapp/petition-for-discretionary-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/ninth-circuit/oregon/state/court-of-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4 oregon orctapp/petition-for-writ: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/ninth-circuit/oregon/state/court-of-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4 oregon ortc/opening-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/ninth-circuit/oregon/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 oregon ortc/answering-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/ninth-circuit/oregon/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 oregon ortc/reply-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/ninth-circuit/oregon/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 oregon ortc/petition-for-discretionary-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/ninth-circuit/oregon/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 oregon ortc/motion-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/ninth-circuit/oregon/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 oregon ortc/petition-for-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/ninth-circuit/oregon/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 oregon ortc/petition-for-writ: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/ninth-circuit/oregon/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 oregon ortc/amicus-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/ninth-circuit/oregon/state/tax-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 tennessee tenncrimapp/reply-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/sixth-circuit/tennessee/state/court-of-criminal-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4 tennessee tenncrimapp/petition-for-discretionary-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/sixth-circuit/tennessee/state/court-of-criminal-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4 tennessee tenncrimapp/petition-for-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/sixth-circuit/tennessee/state/court-of-criminal-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4 tennessee tenncrimapp/petition-for-writ: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/sixth-circuit/tennessee/state/court-of-criminal-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4 tennessee tenn/petition-for-writ: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/sixth-circuit/tennessee/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 tennessee tennctapp/motion-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/sixth-circuit/tennessee/state/court-of-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4 tennessee tennctapp/petition-for-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/sixth-circuit/tennessee/state/court-of-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4 tennessee tennctapp/petition-for-writ: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/sixth-circuit/tennessee/state/court-of-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4 montana monttc/opening-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/ninth-circuit/montana/state/tax-appeal-board/exemplars/SOURCE.md
BLOCKED fb-l129.4 montana monttc/answering-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/ninth-circuit/montana/state/tax-appeal-board/exemplars/SOURCE.md
BLOCKED fb-l129.4 montana monttc/reply-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/ninth-circuit/montana/state/tax-appeal-board/exemplars/SOURCE.md
BLOCKED fb-l129.4 montana monttc/petition-for-discretionary-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/ninth-circuit/montana/state/tax-appeal-board/exemplars/SOURCE.md
BLOCKED fb-l129.4 montana monttc/motion-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/ninth-circuit/montana/state/tax-appeal-board/exemplars/SOURCE.md
BLOCKED fb-l129.4 montana monttc/petition-for-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/ninth-circuit/montana/state/tax-appeal-board/exemplars/SOURCE.md
BLOCKED fb-l129.4 montana monttc/petition-for-writ: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/ninth-circuit/montana/state/tax-appeal-board/exemplars/SOURCE.md
BLOCKED fb-l129.4 montana monttc/amicus-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/ninth-circuit/montana/state/tax-appeal-board/exemplars/SOURCE.md
BLOCKED fb-l129.4 iowa iowa/petition-for-writ: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/eighth-circuit/iowa/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 iowa iowactapp/petition-for-discretionary-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/eighth-circuit/iowa/state/court-of-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4 iowa iowactapp/motion-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/eighth-circuit/iowa/state/court-of-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4 iowa iowactapp/petition-for-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/eighth-circuit/iowa/state/court-of-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4 iowa iowactapp/petition-for-writ: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/eighth-circuit/iowa/state/court-of-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4 wyoming wyo/answering-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/tenth-circuit/wyoming/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 wyoming wyo/petition-for-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/tenth-circuit/wyoming/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 wyoming wyo/motion-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/tenth-circuit/wyoming/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 wyoming wyo/petition-for-discretionary-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/tenth-circuit/wyoming/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 wyoming wyo/petition-for-writ: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/tenth-circuit/wyoming/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 wyoming wyo/petition-for-rehearing: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/tenth-circuit/wyoming/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 vermont vt/petition-for-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/second-circuit/vermont/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 vermont vt/motion-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/second-circuit/vermont/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 vermont vt/petition-for-discretionary-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/second-circuit/vermont/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 vermont vt/petition-for-writ: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/second-circuit/vermont/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 vermont vt/petition-for-rehearing: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/second-circuit/vermont/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 illinois ill/petition-for-rehearing: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/seventh-circuit/illinois/state/supreme-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 illinois illappct/petition-for-discretionary-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/seventh-circuit/illinois/state/appellate-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 illinois illappct/petition-for-writ: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/seventh-circuit/illinois/state/appellate-court/exemplars/SOURCE.md
BLOCKED fb-l129.4 michigan michctapp/answering-brief: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/sixth-circuit/michigan/state/court-of-appeals/exemplars/SOURCE.md
BLOCKED fb-l129.4 michigan michctapp/petition-for-review: re-searched official public sources; no qualifying text-layer PDF retrievable; see courts/sixth-circuit/michigan/state/court-of-appeals/exemplars/SOURCE.md
