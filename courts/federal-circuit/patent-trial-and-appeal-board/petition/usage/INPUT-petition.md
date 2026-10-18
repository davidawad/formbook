---
petitioner:
  name: "SALESFORCE.COM, INC."
  role: "Petitioner"
patent-owner:
  name: "WSOU INVESTMENTS, LLC d/b/a BRAZOS LICENSING AND DEVELOPMENT"
  role: "Patent Owner"
patent-number: "U.S. Patent No. 8,369,827"
patent-title: "“Method of Determining a Unique Subscriber from an Arbitrary Set of Subscriber Attributes”"
case-number: "Inter Partes Review No. 2022-00154"
title: "PETITION FOR INTER PARTES REVIEW OF U.S. PATENT NO. 8,369,827 UNDER 35 U.S.C. §§ 311–319 AND 37 C.F.R. §§ 42.100 ET SEQ."
word-count: 10543
date: "November 8, 2021"
signature:
  signer: "James Glass"
  signer-name: "James Glass"
  reg-no: "46729"
service:
  manner: "FedEx"
  recipients:
    - name: "Kramer & Amado, P.C."
      lines:
        - "225 Reinekers Ln, Suite 300"
        - "Alexandria, VA 22314"
    - name: "ETHERIDGE LAW GROUP, PLLC"
      lines:
        - "2600 E. Southlake Blvd., Suite 120 / 324"
        - "Southlake, Texas 76092"
---

# Introduction

Patent Owner Brazos Licensing and Development (“Brazos”) is a non-practicing entity, and states that it is based in Waco, Texas. Brazo recently sued Petitioner Salesforce simultaneously filing nine other litigations alleging infringement of nine separate patents. All of these patents stem from different patent families and claim different technologies.

One of those ten patents, U.S. Patent No. 8,369,827 (“the ’827 patent”) is the subject of the present petition. The ’827 patent is directed to managing a legacy subscriber system by using a subscriber profile repository (SPR). The patent claims a rudimentary search protocol using portions of a subscriber record to identify a full record. Yet this “SPR,” the alleged point of novelty for the ’827 patent is precisely what it acknowledges was taught in the prior art. Specifically, the 3GPP standard, on which the ’827 patent is built, expressly discloses the SPR. The ’827 patent claims additional details not expressly described in the 3GPP standard, but those details are simple obvious design choices that were all expressly disclosed in the secondary references identified below. The claimed search protocols were thus well-known more than a decade prior to the filing of the ’827 patent and are rendered obvious by the prior art teachings detailed below.

Accordingly, Petitioner salesforce.com, Inc. (“Salesforce” or “Petitioner”) respectfully requests Inter Partes review of claims 1–8, 14–21 (“the challenged claims”) of the ’827 patent assigned to WSOU Investments LLC (“Patent Owner” or “WSOU”), pursuant to 35 U.S.C. § 311 and 37 C.F.R. § 42.100.

# Mandatory Notices

Pursuant 37 C.F.R. § 42.8(a)(1), the following mandatory notices are provided as part of this Petition.

## Real Party-in-Interest (37 C.F.R. § 42.8(b)(1))

The real party-in-interest for Petitioner is Salesforce.

## Related Matters (37 C.F.R. § 42.8(b)(2))

### Related Patent Office Proceedings

There are no related Patent Office proceedings.

### Related Litigation

WSOU is currently asserting the ’827 patent against Petitioner in *WSOU Investments, LLC d/b/a Brazos Licensing and Development v. Salesforce.com, Inc.*, Case No. 6:20-cv-1167-ADA (W.D. Tex.).

## Lead and Back-Up Counsel (37 C.F.R. § 42.8(b)(3)) and Service Information (37 C.F.R. § 42.8(b)(3)–(4))

Petitioner provides the following counsel and service information. Pursuant to 37 C.F.R. § 42.10(b), a Power of Attorney accompanies this Petition.

Lead counsel: James Glass, Reg. No. 46729, jimglass@quinnemanuel.com, Quinn Emanuel Urquhart & Sullivan, LLP, 51 Madison Ave., 22nd Floor, New York, NY 10010, Tel: (212) 849-7000.

Back-up counsel:

- Sam Stake (pro hac vice to be requested upon grant authorization), samstake@quinnemanuel.com, Quinn Emanuel Urquhart & Sullivan, LLP, 50 California St., 22nd Floor, San Francisco, CA 94111, Tel: (415) 875-6600.
- Ray Zado (pro hac vice to be requested upon grant authorization), rayzado@quinnemanuel.com, Quinn Emanuel Urquhart & Sullivan, LLP, 555 Twin Dolphin Dr., 5th Floor, Redwood Shores, CA 94065, Tel: (650) 801-5000.
- Joshua Scheufler (pro hac vice to be requested upon grant authorization), joshuascheufler@quinnemanuel.com, Quinn Emanuel Urquhart & Sullivan, LLP, 711 Louisiana Street, Suite 500, Houston, TX 77002, Tel: (713) 221-7000.
- Ian Wang (pro hac vice to be requested upon grant authorization), ianwang@quinnemanuel.com, Quinn Emanuel Urquhart & Sullivan, LLP, 2755 E. Cottonwood Parkway, Suite 430, Salt Lake City, UT 84121, Tel: (801) 515-7300.

Petitioner consents to electronic service at qewsouvsalesforce@quinnemanuel.com and at the email addresses listed above.

## Payment of Fees (37 C.F.R. § 42.15(a))

The undersigned authorizes the Office to charge the fee required for this Petition for Inter Partes review to Deposit Account No. 50-5708. Any additional fees that might be due are also authorized.

# Requirements for Inter Partes Review

Petitioner certifies it is not barred or estopped from requesting this proceeding, the ’827 patent is available for Inter Partes review, and the prohibitions of 35 U.S.C. §§ 315(a)–(b) are inapplicable.

# Statement of Relief Requested for Each Challenged Claim

Petitioner respectfully requests Inter Partes review of the challenged claims based on the following obviousness grounds:

- Ground 1: Feyerabend and 3GPP render claims 1–4, 6, 8, 14–17, 19, and 21 obvious.
- Ground 2: Feyerabend, 3GPP, and Zhang render claims 2–5, and 15–18 obvious.
- Ground 3: Feyerabend, 3GPP, and Bland render claims 7 and 20 obvious.

# Overview of the ’827 Patent

## Technology

U.S. Patent No. 8,369,827 (“the ’827 patent”) is directed to managing a legacy subscriber system using a subscriber profile repository (SPR) and claims a rudimentary search protocol to identify a unique subscriber record using a set of subscription identifiers:

> 1\. A method performed by a Subscriber Profile Repository (SPR) for determining a unique subscriber record from a set of subscription identifiers, the method comprising: receiving a message including at least one subscription identifier; for each subscription identifier of the at least one subscription identifier; determining whether the subscription identifier matches a subscriber record; and determining that the subscriber record is the unique subscriber record when each subscription identifier that matches the subscriber record matches an identical subscriber record.

Ex-1001 at Cl. 1; *see also id.* at Fig. 5.

The ’827 patent is an alleged improvement of the 3rd Generation Partnership Project (“3GPP”) to provide a “system that is interoperable with different network devices and messages.” *Id.* at 1:58–60. The 3rd Generation Partnership Project provides a framework for LTE networks, in particular applying Internet Protocol (IP) on top of voice communication infrastructure. *Id.* at 1:12–47. As such the ’827 patent states that there is a need for a fast and flexible means to identify a subscriber and access the record associated with that subscriber across a wide variety of devices. *Id.* at 1:66–2:54.

The ’827 patent acknowledges that a database called the “subscriber profile repository,” or “SPR,” is disclosed by technical specifications of the 3GPP but asserts that the specifications “do not specify any details associated” with processing requests for subscriber records from the SPR. *Id.* at 1:28–62. This is important, because the SPR is the primary focus of the claims, indeed, many of the limitations are directed to various functionality of the SPR. As such, it purports to introduce the claimed search protocol for identifying unique subscriber records in an SPR through the use of one or more subscription identifiers, including International Mobile Subscriber Identification (IMSI) numbers. *See id.* at 2:2–54, 5:20–28. The search protocol in question, however, was well known more than a decade prior to the filing of the ’827 patent, and the prior art teachings detailed below render them obvious.

## Priority Date

Because the prior art cited in this Petition predates the earliest possible priority date of the ’827 patent (June 4, 2010) by at least one year, each cited reference herein qualifies as prior art under at least one of pre-AIA 35 U.S.C. 102(a), (b), and/or (e).

## Prosecution History

The ’827 patent was filed on June 4, 2010. Ex. 1002 at 1. After a preliminary amendment on June 4, 2010, *id.* at 57, the application was allowed on September 24, 2012 with a Patent Term Adjustment of 417 days, *id.* at 74–75. No office actions were issued and the examiner discussed only one piece of prior art, US 2008/0214173, which did not teach whether the subscription identifier matches a subscriber record and determining the unique subscriber record. *Id.* at 80.

# Person of Ordinary Skill in the Art

A person of ordinary skill in the art (“POSITA”) relating to the subject matter of the ’827 patent is a person with a Bachelor of Science degree in electrical engineering or computer science or related field plus at least two to four years of professional experience in the field of relational databases. Ex. 1003, ¶ 35.

# Claim Construction

The construction process has begun in the litigation—the parties have exchanged proposed constructions (Ex. 1009) and begun briefing. A Markman hearing scheduled for December 15. Ex. 1011. The only term in contest between the parties regarding the ’827 patent is “Subscriber Profile Repository SPR.” Petitioner has proposed that this term be construed according to the 3GPP standard: “a logical entity containing all subscriber/subscription related information needed for subscription-based policies and Policy and Charging Control rules as defined by the 3GPP standard.” Patent Owner has proposed plain and ordinary meaning without more explanation. Further, as this term appears in the preamble, Petitioner has proposed that the preamble be limiting, while Patent Owner has taken the opposite view.

Petitioner has dropped all constructions but that of Subscriber Profile Repository SPR. Petitioner believes its proposed construction provided in Exhibit 1009 is correct. In particular, Petitioner’s proposed construction of Subscriber Profile Repository (SPR) reflects the intrinsic record. Ex. 1001 at 1:49–51 (citing 3GPP to explain an SPR). Similarly, this construction matches a POSITA’s understanding of the technical term “Subscriber Profile Repository.” But the competing constructions differ in ways that are not material to the invalidity analysis in this Petition.

Petitioner has provided how the prior art discloses an SPR but the claims would be equally invalid under Patent Owner’s construction that the preamble is not limiting. As explained below, Petitioner cites the 3GPP to provide a framework, including a subscriber profile repository, and thus provides a subscriber profile repository under Petitioner’s narrower construction and under the plain and ordinary meaning, to the extent there is found to be a difference. Likewise, Petitioner has demonstrated below that the preamble is disclosed in prior art. Thus, because the challenged claims are unpatentable under any of the proposed constructions, there is no need to construe any terms in the context of this IPR.

# Asserted Prior Art

## U.S. Patent No. 7,123,626 (“Feyerabend”)

Feyerabend was filed in 2000 and issued in 2006, years before the earliest filing date of the ’827 patent. Feyerabend discloses a method to facilitate the efficient transmission of data between communication systems with different subscriber address types. *See* Ex. 1006 at 2:53–57. This method involves mapping an IP address of a data packet to an international mobile subscriber identity (IMSI) or other standard subscriber identifier, as illustrated below in Figure 6. *See id.* at 1:31–2:5, 3:57–5:20, 11:30–12:19, Fig. 6.

Feyerabend teaches a multi-step process to convert an IP address into an IMSI number. *See id.* at 3:57–5:55, 11:23–12:3, Fig. 6. First, a first portion of an IP address of the data packet being transmitted (i.e., the network identifier) is used to look up and retrieve a first portion of a subscriber’s IMSI number. *See id.* at 11:25–55, Fig. 6 (looking up the MCC and MNC values of the IMSI number using the network identifier). Next, a second portion the IP address (i.e., host identifier) is converted into a second portion of the subscriber’s IMSI number by (i) converting each byte of the host identifier into its hexadecimal equivalent, (ii) concatenating the three hexadecimal numbers into a single hexadecimal number, and (iii) then converting the single hexadecimal number into its equivalent decimal number. *See id.* at 11:56–12:3, Fig. 6. Finally, the two portions of the IMSI number are concatenated to form the subscriber’s IMSI number. *See id.* at Fig. 6.

Feyerabend discloses that “[i]n a further preferred embodiment of the present invention,” the IMSI number or “subscriber identity is used in the cellular communications system to retrieve subscriber data from the subscriber profile database (HLR).” *Id.* at 5:45–51. For example, Feyerabend discloses that using a subscriber identity (e.g., IMSI number), “[a] gateway [can] request[] further subscriber data from a subscriber record database” to transmit data to a subscriber’s mobile terminal. *Id.* at 7:49–58.

## U.S. Patent No. 6,810,259 (“Zhang”)

Zhang, filed on December 14, 2000 and issued on October 26, 2004, describes means for managing subscriber profile information in mobile communications networks. Zhang teaches managing subscriber profile information in a distributed database system with a variety of base station caches. Zhang teaches using local cache databases to quickly obtain subscriber information and a central database for the records that the local caches do not hold.

# Conclusion

For at least the foregoing reasons, this Petition should be instituted.
