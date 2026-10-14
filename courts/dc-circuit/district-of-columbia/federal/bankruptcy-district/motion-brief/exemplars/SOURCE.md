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
