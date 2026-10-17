# Exemplar source

- File: `FILED-EXAMPLE-swain-landing-25-10013-motion-brief.pdf` (7 pages, text layer present: `pdftotext` reads it; `pdffonts` lists Times-Roman, Times-Bold, Times-Italic and Courier, none embedded)
- Court: United States Bankruptcy Court for the District of Columbia (`dcb`)
- Case: *Swain Landing LaPlata JC, LLC v. Catherine Swain and Percy Swain*, adversary proceeding, in the chapter 11 case of *Swain Landing LaPlata JC, LLC*, No. 25-184 ELG (the ECF header reads `Case 25-10013-ELG Doc 5`; the caption reads "Adversary No. 18-00173 MMH" and "Case No. 25-184 ELG")
- Document: Defendants' Catherine Swain and Percy Swain's Motion to Dismiss Adversary Complaint and Memorandum in Support (ECF Doc 5). Rule 12(b)(1) (Rooker-Feldman) and 12(b)(6) grounds, with a memorandum, a certificate of service
- Filer: Defendants, by counsel Craig M. Palik (McNamee Hosea, P.A.), Greenbelt, Maryland
- Date filed: 2025-08-04 (ECF header "Filed 08/04/25")
- Fetched from: https://storage.courtlistener.com/recap/gov.uscourts.dcb.50424/gov.uscourts.dcb.50424.5.0.pdf (CourtListener RECAP)
- Date fetched: 2026-10-14
- Public court record (RECAP). Used as a visual and structural reference.

## How it was found

- CourtListener API, `type=r&court=dcb`, query `"motion to dismiss" adversary`, read through WebFetch. The result list is the entry "Swain Landing LaPlata JC LLC v. Swain, 25-10013, entry 5: Motion to Dismiss Adversary Proceeding and Memorandum in Support, 2025-08-04". It is the only motion-with-memorandum in those results that was checked and is text-based. JPK NewCo (25-10015, entry 20) was not checked; Anglin Consulting (25-10032, entry 43) has no PDF.
- WebSearch "Bankr. D.D.C." motion, "Local Bankruptcy Rule 9013" memorandum: returned the court's local rules and general orders, no filing.
- The search also found Engelhorn (25-10044) and Developer RE1 (25-10037) motions; they are not text-checked and not used.

## Caveats

- The exemplar has no notice of motion, objection deadline, or hearing. LBR 9013-1(c) requires one (conforming substantially to Official Form B 420A) for a motion in an adversary proceeding, unless it is a contemporaneous motion under LBR 9013-2. The filing omits it. The template generates the notice from frontmatter fields; see README.md.
- The caption number ("Adversary No. 18-00173 MMH") does not match the ECF number (25-10013). The sample keeps the caption number as printed.

## 2. Second filer: Webster v. R13 Community Partners LLC (defendants' motion to dismiss)

- File: `FILED-EXAMPLE-r13-25-10053-motion-brief.pdf` (18 pages)
- Court: United States Bankruptcy Court for the District of Columbia (`dcb`)
- Case: *Wendell W. Webster, chapter 7 Trustee v. R13 Community Partners LLC, et al.*, Adv. No. 25-10053-ELG, in the chapter 7 case of *Broughton Construction Co., LLC*, No. 23-00378-ELG
- Docket / document: Doc 12, "DEFENDANTS' MOTION TO DISMISS AND BRIEF IN SUPPORT" (FRBP 7012 / FRCP 12(b)(6); introduction, background, argument, conclusion, signature, certificate of service; motion and brief combined in one paper, as LBR 9013-1(e)(2) permits)
- Filer: Defendant R13 Community Partners LLC (on behalf of itself and three co-defendants), by Christopher J. Giaimo (Bar # 458974), Squire Patton Boggs (US) LLP. Different party and counsel from Swain (McNamee Hosea, P.A.).
- Date filed: 2026-03-02 (ECF header "Filed 03/02/26 Entered 03/02/26 16:17:12")
- URL fetched: https://storage.courtlistener.com/recap/gov.uscourts.dcb.50854/gov.uscourts.dcb.50854.12.0.pdf (CourtListener RECAP)
- Date retrieved: 2026-10-17
- Text layer: yes (Power PDF Create; `pdftotext` yields the full text; Times New Roman named but not embedded)
- sha256: `253038486a433e6f75ee80c6b9c3f490262814abff9d8cb90946d931bc80c2f1`
- Notes: no attorney block on page 1 (LBR 5005-1(c)), no notice of motion (LBR 9013-1(c)) and no consent statement in the document; page numbers "-n-" centered at the foot. Found by checking RECAP storage URLs for the Webster adversary dockets (the search API was rate-limited).
