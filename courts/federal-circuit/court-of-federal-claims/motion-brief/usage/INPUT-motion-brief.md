---
case_number: "18-1880C"
judge: "Senior Judge Eric G. Bruggink"
bid_protest: true
parties:
  - name: "ORACLE AMERICA, INC.,"
    role: "Plaintiff,"
  - name: "v."
  - name: "THE UNITED STATES,"
    role: "Defendant,"
  - name: "and"
  - name: "AMAZON WEB SERVICES, INC.,"
    role: "Defendant-Intervenor."
brief_title: "Memorandum of Law in Support of Plaintiff's Motion for Judgment on the Administrative Record"
counsel:
  - names: ["*Of Counsel:*", "Kara L. Daniels", "Dana E. Koffman", "Amanda J. Sherwood", "Nathaniel E. Castellano", "Arnold & Porter Kaye Scholer LLP", "601 Massachusetts Ave., N.W.", "Washington, D.C. 20001"]
    lines: []
  - names: ["Craig A. Holman", "ARNOLD & PORTER KAYE SCHOLER LLP", "601 Massachusetts Ave., N.W.", "Washington, D.C. 20001", "Fax: (202) 942-5999"]
    lines: ["Attorney of Record for Oracle America, Inc."]
phone: "(202) 942-5722"
email: "craig.holman@arnoldporter.com"
signature:
  signer: "Craig A. Holman"
  lines: ["Arnold & Porter Kaye Scholer LLP", "601 Massachusetts Ave., N.W., Washington, D.C. 20001", "Attorney of Record for Oracle America, Inc."]
date: "February 5, 2019"
service:
  day: "5th day of February 2019"
  manner: "electronic delivery"
  documents: "Motion, Memorandum of Law, and Proposed Order"
  recipients:
    - lines: ["William P. Rayel", "U.S. Department of Justice", "Post Office Box 480, Ben Franklin Station", "Washington, D.C. 20044", "William.Rayel@usdoj.gov", "*Counsel for Defendant*"]
    - lines: ["Daniel R. Forman", "Crowell & Moring LLP", "1001 Pennsylvania Avenue, N.W.", "Washington, D.C. 20004-2595", "dforman@crowell.com", "*Counsel for Defendant-Intervenor*"]
authorities:
  amalgamated: {kind: case, name: "Amalgamated Transit Union v. Skinner", cite: "894 F.2d 1362 (D.C. Cir. 1990)"}
  epic: {kind: case, name: "Epic Sys. Corp. v. Lewis", cite: "138 S. Ct. 1612 (2018)"}
  winstar: {kind: case, name: "WinStar Commc'ns, Inc. v. United States", cite: "41 Fed. Cl. 748 (1998)"}
  palantir: {kind: case, name: "Palantir USG, Inc. v. United States", cite: "904 F.3d 980 (Fed. Cir. 2018)"}
  distributed: {kind: case, name: "Distributed Sols., Inc. v. United States", cite: "539 F.3d 1340 (Fed. Cir. 2008)"}
  impresa: {kind: case, name: "Impresa Construzioni Geom. Domenico Garufi v. United States", cite: "238 F.3d 1324 (Fed. Cir. 2001)", sort: "impresa"}
  precision: {kind: case, name: "Precision Asset Mgmt. Corp. v. United States", cite: "135 Fed. Cl. 342 (2017)"}
  cwgov: {kind: case, name: "CW Gov't Travel, Inc. v. United States", cite: "61 Fed. Cl. 559 (2004)"}
  weeks: {kind: case, name: "Weeks Marine v. United States", cite: "575 F.3d 1352 (Fed. Cir. 2009)"}
  s2304a3: {kind: statute, cite: "10 U.S.C. § 2304a(d)(3)"}
  s2304a4: {kind: statute, cite: "10 U.S.C. § 2304a(d)(4)"}
  s1491: {kind: statute, cite: "28 U.S.C. § 1491(b)"}
  s706: {kind: statute, cite: "5 U.S.C. § 706"}
  r16504c: {kind: regulation, cite: "48 C.F.R. § 16.504(c)(1)(ii)(D)"}
  r16504i: {kind: regulation, cite: "48 C.F.R. § 16.504(c)(1)(i)"}
---

# Introduction

Plaintiff Oracle America, Inc. ("Oracle") seeks declaratory and injunctive relief to remedy defects related to Department of Defense ("DoD") Solicitation No. HQ0034-18-R-0077 (the "RFP"), commonly known as the Joint Enterprise Defense Infrastructure Cloud procurement ("JEDI"). The RFP solicits a single awardee to provide infrastructure as a service ("IaaS") and platform as a service ("PaaS") cloud services across DoD, under a ten-year, ten billion dollar, Indefinite Delivery Indefinite Quantity ("IDIQ") contract.

By Congressional design, competition and integrity mandates undergird the entire federal procurement system. *See, e.g.*, 48 C.F.R. § 1.102(b). Oracle challenges three pre-award JEDI actions that break from specific statutory and regulatory direction to the substantial prejudice of the public and Oracle: (i) DoD's violation of a specific high-dollar value, single award IDIQ contract prohibition and disregard of a broader "maximum extent practicable" mandate for multiple awards; (ii) DoD's use of three gate criteria to limit competition in violation of statutory proscriptions on qualification requirements, unduly restrictive specifications, and DoD contracting authority; and (iii) DoD's involvement of heavily-conflicted former government officials in JEDI, and AWS' rehiring of one of them during JEDI.

DoD, demanding deference, asks the Court to temper its review of Oracle's protest despite that the protest principally applies statutes and regulations designed to restrict DoD. DoD, however, lacks discretion to disregard the law, whatever DoD's intent. *See* [*Amalgamated Transit Union v. Skinner*, 894 F.2d 1362, 1364 (D.C. Cir. 1990)](toa:amalgamated) ("Where Congress prescribes the form in which an agency may exercise its authority ... [courts] cannot elevate the goals of an agency's action, however reasonable, over that prescribed form."). The power to legislate (and appropriate funds) belongs to Congress. [*Epic Sys. Corp. v. Lewis*, 138 S. Ct. 1612, 1624 (2018)](toa:epic). The Court, thus, cannot condone what Congress has restricted, no matter what DoD's motivation.

First, DoD has violated [10 U.S.C. § 2304a(d)(3)](toa:s2304a3) by soliciting this $10 billion IDIQ contract, with near constant technology refresh requirements, as a single award. In 2008, Congress, confronted with numerous examples of DoD's runaway, single source IDIQ contracts, prohibited use of such contracts absent a head-of-agency determination that one of four narrow exceptions existed. As relevant here (based on the exception DoD selected), section 2304a(d)(3) permits the award of an IDIQ contract valued over $112 million to a single source if "the contract provides only for firm, fixed price task orders or delivery orders for ... services for which prices are established in the contract for the specific tasks to be performed." [10 U.S.C. § 2304a(d)(3)](toa:s2304a3); [48 C.F.R. § 16.504(c)(1)(ii)(D)](toa:r16504c). DoD, by the challenged determination and finding ("D&F"), asserts that the awardee's cloud catalog proposed for JEDI and incorporated into the contract will cover all services delivered across the potential ten years of performance and include a "single, fixed unit price for delivery of that particular cloud service." (AR Tab 16 at 319.) The RFP and record demonstrate that this is not so.

DoD designed JEDI to help DoD keep pace with the rapidly evolving commercial cloud arena by having the awardee regularly add new commercial cloud services onto the JEDI contract. In this respect, JEDI is a classic IDIQ technology contract of the very type that led Congress to enact provisions favoring task order competition. The Office of Management and Budget ("OMB") has described the backdrop for the earliest single IDIQ contract restrictions:

> Use of multiple award contracts may be especially effective for maintaining better prices and quality in the IT market. Before FASA, many agencies relied on long-term ID/IQ and umbrella contracts with technology refreshment and price reduction clauses to take advantage of falling prices and new technology. Even with these clauses, the government had to negotiate in a sole-source environment and was often unable to realize the economies and efficiencies afforded by vigorous competition among vendors in the marketplace.

(AR Tab 77 at 5310.) New record documents not shared with the U.S. Government Accountability Office ("GAO") confirm that DoD knew the solicited "IaaS/PaaS offerings are not static and will be updated overtime [sic] both in terms of available services and applicable pricing." (AR Tab 130 at 8721.) Indeed, DoD crafted a special technology refreshment clause under which the awardee will continually add new services to the contract, the prices of which the awardee and DoD will set when incorporating the future service onto the contract. (AR Tab 35 at 740-41.) Gartner estimates that major cloud providers release 40 to 50 new cloud services in any given month.[^gartner] Given that, Chris Cornillie, a Bloomberg technology writer, succinctly posited the question raised by Oracle's Count I: "How can the Pentagon request firm fixed prices on services that don't yet exist?"[^cornillie]

Second, the Contracting Officer ("CO") separately violated statutory and regulatory directives (applicable to all IDIQ contract competitions, regardless of size) to favor a multiple award IDIQ acquisition strategy to the "maximum extent practicable." *See* [10 U.S.C. § 2304a(d)(4)](toa:s2304a4); [48 C.F.R. § 16.504(c)(1)(i)](toa:r16504i); [*WinStar Commc'ns, Inc. v. United States*, 41 Fed. Cl. 748, 759 (1998)](toa:winstar) (holding agency failed to comply with "maximum extent practicable" requirement). Congress' "maximum extent practicable" direction is not an empty decree. *Cf.* [*Palantir USG, Inc. v. United States*, 904 F.3d 980, 992-93 (Fed. Cir. 2018)](toa:palantir) (affirming that Army actions undermined different "maximum extent practicable" commercial item preference).

But, even with the CO's inflated numbers, the scales would have tipped in favor of competition had the CO considered the benefits of multiple awards as FAR 16.504(c) requires: "Each of these [FAR 16.504(c)(1)] criteria plainly requires consideration of the benefits of multiple awards." [*WinStar*, 41 Fed. Cl. at 758](toa:winstar) (overturning each of three invoked single award reasons). Yet, the CO here neither quantifies nor weighs any benefits of task order competition.

# Questions Presented

1\. Whether DoD violated the statutory prohibition on single source awards by attempting to recast the JEDI contract and its technology refresh provisions as seeking only "services for which prices are established in the contract for the specific tasks to be performed."

2\. Whether DoD violated applicable law by failing to "give preference to making multiple [IDIQ] awards" to the "maximum extent practicable."

3\. Whether DoD's imposition of the three challenged gate criteria (Subfactors 1.2, 1.1, and 1.6) violates statutory and regulatory proscriptions governing qualification requirements, barring unduly restrictive specifications, and limiting DoD's authority.

4\. Whether the CO's determination that the participation of heavily-conflicted former government officials had no impact on the procurement's integrity, and the CO's failure to investigate AWS' rehiring of one of them, violate procurement law or otherwise lack a rational basis.

# Statement of Facts

## From The Outset, DoD Chose The Convenience Of A Single Award.

On September 13, 2017, the DSD issued a memorandum establishing the Cloud Executive Steering Group ("CESG") and initiating JEDI. (AR Tab 91 at 5955.) The very next day, the CESG held its first meeting, where the CESG expressed its commitment to a single award approach and an intention to withhold that decision from the public to delay scrutiny. (*See* AR Tab 86 at 5928 (CESG meeting minutes withheld from GAO showing CESG sought to "[a]void specifying that there is a single vendor," because doing so "will create perception issues with vendors already in use.").)[^withheld] The CESG's October 5, 2017 meeting minutes reiterate the single award approach: "Single cloud solution necessary for this enterprise initiative to be successful and allow DoD to achieve its mission objectives with cloud adoption." (AR Tab 88 at 5934; *see also* AR Tab 51 at 4325 (October 27, 2017 update to DSD: "the CESG acquisition strategy is focusing on a single award.").) On November 6, 2017, DoD confirmed publicly the chosen "Acquisition Strategy" of a "Single-award [IDIQ] contract . . . ." (AR Tab 92 at 5957.) In its May 2018 report to Congress, DoD asserted that its single award approach would avoid the administrative burden of task order competition. (AR Tab 109 at 6496-97.)

On July 17, 2018, nearly ten months after the first CESG meeting choosing the single award approach, the CO signed a memorandum setting forth three purported justifications for adopting this acquisition strategy. (AR Tab 24.) The CO's one-sided analysis reflects one purpose: to support DoD's foregone single award conclusion. (*Id.*) In her memorandum, the CO does not consider the benefits of task order competition, much less give the maximum practicable preference to multiple awards. (*Id.*) Each finding is inaccurate, unsubstantiated, or both. For instance, the CO relies on a flawed calculation to conclude that a single award approach will save the government half a billion dollars in administrative costs and prevent "770 years worth of time . . . of delaying warfighters." (*Id.* at 460.) The CO testified that she derived the inputs for these calculations from her "personal experience" (AR Tab 78 at 5717:1-5), but acknowledged that she has never purchased cloud services under an IDIQ contract before, and offered no explanation for how her prior experience relates to JEDI. (*See id.* at 5707:10-17.)

Two days later, on July 19, 2018, the Under Secretary of Defense for Acquisition and Sustainment signed a D&F declaring JEDI exempt from the statutory prohibition against large, single-award IDIQ contracts. (AR Tab 16.) The D&F rests on a single conclusion, i.e., the JEDI contract will provide only for firm, fixed price ("FFP") "task orders or delivery orders for services for which prices are established in the contract for the specific tasks to be performed." (*Id.* at 318.)

## DoD Structured The Challenged Gate Criteria To Restrict Competition.

DoD also structured the RFP to reduce the administrative burden of competing the base contract. Specifically, to avoid potential delays from receiving more proposals or protests than expected, DoD imposed several RFP gate criteria, evaluated on a "go/no-go" basis in Phase One of the RFP's two-phased evaluation process:

> The JEDI program schedule could be negatively impacted if source selection extends beyond the planned timeline due to an unexpected number of proposals or lengthy protest delays. To mitigate this risk, the solicitation will use a gated evaluation approach that includes "go/no go" gate criteria. Offerors must meet the established minimum criteria in order to be considered a viable competitor.

(AR Tab 21 at 422; AR Tab 25 at 504; AR Tab 78 at 5473:2-11; AR Tab 35 at 805.) If an offeror receives an Unacceptable rating under any gate, the RFP provides that "the remainder of the proposal will not be evaluated and will not be considered for award." (AR Tab 35 at 805.) DoD designed the metrics and capabilities required by the gate criteria to "get to one" contractor. (*See* AR Tab 47c at 3123 ("So if multiple cloud providers can meet the metrics, then we won't get to one.").)

The gate criteria served their improper purpose. DoD's market research noted the existence of a robust commercial cloud services market. (AR Tab 20 at 366.) When first announced, JEDI sparked intense interest in the contracting community: hundreds of companies attended the industry day, and more than sixty companies submitted detailed RFI responses identifying extensive, sometimes unique capabilities. (AR Tab 70 at 4986-87, 5022.) But following the issuance of the final RFP and its restrictive gate criteria, only four companies attended DoD's in-person question and answer ("Q&A") session and ultimately submitted proposals. (*See* AR Tabs 120-123.) Three of the four offerors expressed concerns during the Q&A session regarding the restrictive nature of the gate criteria and the considerable effort and resources necessary to pass the gates and compete. (*See id.*) Two of the four offerors (Oracle and IBM) ultimately filed protests challenging the restrictive specifications, and a third offeror (Microsoft) publicly criticized the restrictive gates.[^ibm]

Of the seven gates, three are relevant here. First, Subfactor 1.2 mandates that each offeror have, at the time of proposal submission, no fewer than (i) three physically existing data centers, (ii) within the customs territory of the United States, (iii) that are separated by at least 150 miles, (iv) capable of automated failover to the others, and (v) each "supporting at least one IaaS offering and at least one PaaS offering that are FedRAMP Moderate 'Authorized' by the Joint Authorization Board (JAB) or a Federal agency as demonstrated by official FedRAMP documentation." (AR Tab 35 at 792; AR Tab 32 at 661 (response to Q26 and Q27); AR Tab 42 at 946-47.) DoD first required FedRAMP authorized services in all three data centers in the July 26, 2018 final RFP. (*Compare* AR Tab 105 at 6241 (requiring "FedRAMP Moderate compliant") *with* AR Tab 35 at 792.) DoD thus gave interested providers less than two months to obtain FedRAMP authorization, a process that takes at least six months to complete.

# Jurisdiction and Standard of Review

This Court has jurisdiction to review this bid protest action pursuant to [28 U.S.C. § 1491(b)](toa:s1491). *See* [*Distributed Sols., Inc. v. United States*, 539 F.3d 1340, 1344 (Fed. Cir. 2008)](toa:distributed). To obtain declaratory relief, Oracle must show that the challenged decisions and RFP criteria violate procurement law or are arbitrary and capricious and competitively prejudice Oracle. *See* [28 U.S.C. § 1491(b)(4)](toa:s1491) (incorporating [5 U.S.C. § 706](toa:s706)); [*Impresa Construzioni Geom. Domenico Garufi v. United States*, 238 F.3d 1324, 1332-33 (Fed. Cir. 2001)](toa:impresa). To obtain permanent injunctive relief, Oracle must show that: (i) Oracle has achieved success on the merits; (ii) Oracle will suffer irreparable injury if injunctive relief does not issue; (iii) the harm to Oracle if an injunction does not issue outweighs the harm to the government if an injunction issues; and (iv) the injunction serves the public interest. *See* [*Precision Asset Mgmt. Corp. v. United States*, 135 Fed. Cl. 342, 359 (2017)](toa:precision). Once Oracle establishes success on the merits, a rebuttable presumption arises regarding irreparable harm. *See, e.g.*, [*CW Gov't Travel, Inc. v. United States*, 61 Fed. Cl. 559, 577 (2004)](toa:cwgov).

# The Court Should Grant Judgment In Favor Of Oracle.

## The Single Award D&F Violates 10 U.S.C. § 2304a(d)(3) And FAR 16.504(c)(1)(ii)(D) (Count I).

The D&F purporting to justify the $10 billion, single award JEDI contract violates the statutory prohibition on such awards by relying on an inapplicable exception. The D&F claims that the JEDI contract will involve only "[FFP] task orders or delivery orders for services for which prices are established in the contract for the specific tasks to be performed." (AR Tab 16 at 318.) This is inaccurate. Neither the prices nor the specific tasks to be performed are "fixed" or "established." Instead, the RFP includes a custom, technology refresh provision requiring the contractor to update the available services continually, as the awardee daily or weekly adds and removes cloud service offerings. The JEDI contract does not price these non-existent future services; instead it seeks to peg the not-yet-created services to future not-yet-issued catalogs.

The D&F, accordingly, invokes a statutory exception to the single-award prohibition that does not apply, rendering the single award decision unlawful and irrational. The improper D&F also works competitive prejudice against Oracle. By limiting the number of awards, DoD deprived Oracle of the opportunity to compete for one of multiple JEDI awards, and all subsequent task order competitions. *See* [*Weeks Marine v. United States*, 575 F.3d 1352, 1361-62 (Fed. Cir. 2009)](toa:weeks); [*WinStar*, 41 Fed. Cl. at 762-63](toa:winstar) (finding protester prejudiced).

### Congress Prohibits Large, Single Award IDIQ Contracts Except in Limited Circumstances.

For IDIQ contracts estimated to exceed $112 million, statute and regulation prohibit a single award unless the head of the contracting activity (or senior procurement executive for DoD procurements) issues a written determination that one of four stated exceptions exists.

# Conclusion

For each of the foregoing reasons, Oracle respectfully requests that the Court grant judgment in favor of Oracle and (i) issue the declaratory and injunctive relief set forth in Oracle's Complaint and herein, and (ii) provide such other and further relief as the Court deems just and proper.

[^withheld]: DoD withheld much of the record from GAO, including the documents at AR Tabs 86-186.

[^gartner]: Chris Pemberton, *Hidden Cloud Opportunities for Technology Service Providers*, Gartner (June 20, 2018), https://www.gartner.com/smarterwithgartner/7-hidden-cloud-growth-opportunities-for-technology-service-providers/ (last visited 2/4/19).

[^cornillie]: Chris Cornillie, *Five Takeaways from GAO's JEDI Decision Denying Oracle*, Bloomberg (Nov. 30, 2018), https://about.bgov.com/blog/five-takeaways-jedi-decision-oracle/ (last visited 2/4/19).

[^ibm]: Sam Gordy, *JEDI: Why We're Protesting*, IBM (Oct. 10, 2018), https://www.ibm.com/blogs/policy/jedi-protest/ (explaining that "Certain requirements in the RFP either mirror one vendor's internal processes or unnecessarily mandate that certain capabilities be in place by the bid submission deadline versus when the work would actually begin.") (last visited 2/4/19).
