# Exemplars: motion with memorandum (U.S. Bankruptcy Court, D. Utah)

One filed motion, combined with its supporting memorandum in a single document as LBR 9013-1(c)(1) requires.

| File | Case | Docket | Filer | Date filed | Date fetched |
|---|---|---|---|---|---|
| `FILED-EXAMPLE-motion-brief.pdf` | *Plaza 106, LLC v. First Utah Bank*, Adv. No. 26-02063 (Bankr. D. Utah) | 26-02063, Doc 32 | Plaza 106, LLC, Plaintiff and Counterclaim Defendant, by Valerga LLP (Brody Valerga); "Motion to Dismiss Counts One and Three of First Utah Bank's Counterclaim, and Memorandum in Support" | 2026-07-06 | 2026-10-14 |

Source: https://www.courtlistener.com/docket/73210741/plaza-106-llc-adversary-proceeding/ (Doc 32; RECAP path `recap/gov.uscourts.utb.478798/gov.uscourts.utb.478798.32.0.pdf`). Found through the CourtListener search API (`/api/rest/v4/search/?type=rd&court=utb`), query "memorandum motion dismiss".

## Notes for reviewers

- Only one combined motion-and-memorandum was found in the court's RECAP documents that could be fetched. The search also surfaced Power Block Coin, LLC's motion to dismiss (25-02000, Doc 5, 4 pp.); its memorandum is a separate RECAP document that is not in RECAP, so it is not used. Its Doc 5 is kept only as a pointer.
- The filing's word-limit certificate cites DUCivR 7-1(a)(4) through LBR 1001-1(a) and certifies 3,285 words. The 12(b)(6) limit in DUCivR 7-1(a)(4)(A) is 7,750 words, so that certificate is within limits. The 15-page limit in LBR 9013-1(h) is met: 11 body pages, 16 pages in total with caption, tables and certificates (see `../README.md`).
