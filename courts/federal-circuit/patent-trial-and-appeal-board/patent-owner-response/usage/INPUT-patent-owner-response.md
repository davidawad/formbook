---
petitioner:
  name: "JUNIPER NETWORKS, INC."
  role: "Petitioner"
patent-owner:
  name: "SWARM TECHNOLOGY, LLC"
  role: "Patent Owner"
patent-number: "U.S. Patent No. 9,852,004"
patent-title: "“System and Method for Parallel Processing Using Dynamically Configurable Proactive Co-Processing Cells”"
case-number: "Inter Partes Review No. 2021-01445"
title: "PATENT OWNER RESPONSE UNDER 37 C.F.R. § 42.120"
word-count: 11176
date: "May 25, 2022"
signature:
  signer: "Daniel R. Pote"
  signer-name: "Daniel R. Pote"
  reg-no: "43,011"
  lines:
    - "Jennings Strouss & Salmon PLC"
    - "One East Washington Street, Suite 1900"
    - "Phoenix, Arizona 85004"
    - "Phone: 602.262.5832"
    - "Email: p@jsslaw.com; dpote@jsslaw.com"
    - "Lead Counsel for Patent Owner"
service:
  manner: "electronic mail"
  recipients:
    - name: "Joe Edell and Kyle K. Tsui, FISCH SIGLER LLP"
      lines:
        - "5301 Wisconsin Avenue NW, Fourth Floor"
        - "Washington, DC 20015"
        - "Joe.Edell@fischllp.com; kyle.tsui@fischllp.com"
---

Pursuant to 37 C.F.R. § 42.120, Patent Owner Swarm Technology, LLC (“Patent Owner”) hereby files its Response to the Petition in IPR2021-01445 requesting inter partes review of claims 1-12 of U.S. Pat. No. 9,852,004 (“the ’004 Patent”) (Exhibit 1001). This Response is timely filed according to the Scheduling Order set forth in Paper 16 at 11 (PTAB, March 2, 2022).

# Introduction

The patentability of claims 1-12 of the ’004 Patent should be confirmed. As shown below, and as supported by the Declaration of Dr. Brent Nelson (Exhibit 2007, “Nelson”), Petitioner has failed to show by a preponderance of evidence that any claim of the ’004 Patent is unpatentable under 35 U.S.C. § 103.

Specifically, Petitioner has failed to show that the cited references teach or suggest, inter alia, the claimed:

- i) “controller configured to populate the task pool with a plurality of first tasks and a plurality of second tasks”
- ii) “co-processor configured to … retrieve a first task from the task pool; deliver the first task to the first co-processor”
- iii) dynamic addition of co-processors “on a plug-and-play basis without any communication with the controller”
- iv) co-processor including an agent “configured to search the task pool for a task of a first type”
- v) agent comprising a first payload including “a first function which the first co-processor is configured to perform”
- vi) agent comprising a first payload including “a descriptor of the first task;”
- vii) co-processor “configured to modify a task within the task pool”
- viii) task pool “configured to notify the controller upon completion of the first task.”
- ix) co-processor “configured to deposit a new task into the task pool.”

Furthermore, Petitioner has failed to show that a person of ordinary skill in the art (POSITA) would have been motivated to modify Leong to include the teachings of AppleTalk as suggested by Petitioner, or that such a combination would have a reasonable expectation of success.

# The ’004 Patent

## Overview of the ’004 Patent

Alfonso Íñiguez is the sole inventor of U.S. Patent No. 9,852,004 titled “System and Method for Parallel Processing Using Dynamically Configurable Proactive Co-Processing Cells” (“the ’004 Patent”). Prior to Mr. Íñiguez’ invention, conventional multiprocessor systems included a central processing unit (a controller), and one or more co-processors (responders). Under the conventional “controller/responder” paradigm, the controller partitions the system’s computational requirements into tasks and distributes those tasks to the co-processors. Completed tasks, or threads of tasks, are reported to the controller, which continues to distribute additional tasks, or threads of tasks, to the co-processors as needed.[^2] Such parallel processing architectures are disadvantageous in that “a significant amount of CPU bandwidth is consumed by task distribution; waiting for tasks to be completed before distributing new tasks (often with dependencies on previous tasks); responding to interrupts from co-processors when a task is completed; and responding to other messages from co-processors. In addition, co-processors often remain idle while waiting for a new task from the CPU.”[^3]

The ’004 Patent describes novel and nonobvious parallel processing computing architectures that reduce CPU management overhead and more effectively exploit co-processing resources. This architecture includes, among other things, a controller, a task pool and one or more co-processors.[^4] The controller is configured to divide a large computational task into a group of tasks, or task threads, and populate a task pool with a set of first tasks and a set of second tasks.[^5] The task threads can represent a computational task that is a component or subset of a larger aggregate computational requirement imposed on the CPU.[^6] The tasks, or threads, can include a task type and a descriptor.[^7] The task type indicates which co-processors are capable of performing the task.[^8] The descriptor can comprise a data structure that defines, among other things, the executable task instruction(s) and the location of the data to be processed.[^9]

The plurality of first tasks can be performed by certain co-processors that are capable of performing first task types. The second plurality of tasks can be performed by certain co-processors that are capable of performing second task types.[^10] The co-processors are configured to autonomously retrieve, deliver, and complete a suitable task from the task pool. Each co-processor is proactive in that it may interact with the task pool without being instructed to do so by the controller or the task pool.[^11] Additional devices and their associated co-processors may be dynamically accepted into the processing system on a “plug and play” basis without communication with the controller.[^12]

As shown in Fig. 6, a controller populates the task pool with previously parsed tasks or threads (602). Each co-processor proactively dispatches an agent to the task pool to identify a particular task suitable for that co-processor (604). Each co-processor retrieves and processes a task and does so without communication with the CPU (606). The task pool and controller are separately notified when the task is complete (608). Additional co-processor(s) can be dynamically recruited into the system as needed.[^13]

## Prosecution History

The ’004 Patent was filed on July 24, 2014 and is a continuation of U.S. Application No. 13/750,696 filed on January 25, 2013, now U.S. Patent 9,146,777 (“the ’777 Patent”). The ’004 and ’777 Patents were each examined by Examiner Wissam Rashid. The ’777 Patent received its first office action on March 11, 2015 and was subsequently allowed by Examiner Rashid on June 29, 2015. Examiner Rashid then turned his attention to U.S. Application No. 14/340,322 (which became the ’004 Patent) and issued a first office action rejection on November 30, 2016. Over the following year, the ’004 Patent was rigorously examined by Examiner Rashid. After three rounds of rejection, argument and amendment, Examiner Rashid issued a notice of allowance of the ’004 Patent on November 16, 2017.

## Claim Construction

In an IPR, claims are construed using the same claim construction standard as is used in the federal courts. See 37 C.F.R. § 42.100(b). Patent Owner submits that all claim terms of the ’004 Patent should be given their ordinary and customary meaning as understood by one of ordinary skill in the art in light of the specification and ’004 Patent file history.

In view of the positions advanced by the Petition, the Declaration of Dr. Jon B. Weissman (Dr. Weissman), and the deposition testimony of Dr. Weissman, Patent Owner now understands that Petitioner and Patent Owner apparently dispute the “ordinary and customary” meaning of the following claim terms: i) a controller ii) a task pool, iii) a task, iv) a first task, v) retrieve, vi) deliver, vii) dynamically accept, viii) plug and play basis, ix) without communication, x) descriptor, and xi) notify.

# Level of Ordinary Skill in the Art

For purposes of the ’004 Patent claims, a POSITA would have held at least a bachelor’s degree in computer science, electrical engineering, computer engineering, or a closely related field, and one or more years of experience in the design and development of parallel or distributed processing systems.

Alternatively, a POSITA would have a master’s degree or similar post-graduate work in computer science, electrical engineering, computer engineering, or a closely related field, and less design and development experience.

# The Declaration of Dr. Sylvia D. Hall-Ellis and AppleTalk Should Be Accorded Limited Weight

Similar to district courts in a bench trial, “the Board, sitting as a non-jury tribunal with administrative expertise, is well positioned to determine and assign appropriate weight to evidence presented.”[^14]

Sylvia D. Hall-Ellis, Ph.D. was hired by Petitioner to provide expert testimony regarding the “public availability and authenticity of [Exhibit 1006].”[^15] Patent Owner respectfully submits that Dr. Hall-Ellis’s testimony regarding the public availability and authenticity of Exhibit 1006 (“AppleTalk PDF”) should be given limited weight by the Board because Dr. Hall-Ellis failed to: (i) base her testimony on sufficient facts or data, (ii) provide testimony that was the product of reliable principles and methods, and (iii) reliably apply those principles and methods to the facts of this case.

Furthermore, as a consequence of Dr. Hall-Ellis’s failure to properly authenticate the AppleTalk PDF, Patent Owner respectfully submits that the AppleTalk PDF should also be given limited (or no) weight by the Board.

[^2]: See ’004 Patent, 1:56-59.

[^3]: Id. 1:61-2:3.

[^4]: See id. Abstract; see also 1:14-18.

[^5]: See id. 6:39-42.

[^6]: Id., 7:8-12.

[^7]: Id., 7:12-16.

[^8]: Id., 7:16-17.

[^9]: Id., 7:37-58 and 9:32-46.

[^10]: Id., 6:42-44.

[^11]: Id., 2:36-40.

[^12]: Id. 3:40-42.

[^13]: Id., 12:25-34.

[^14]: Corning Inc. v. DSM IP Assets B.V., IPR2013-00053, Paper 66 at 19 (PTAB May 1, 2014). See, e.g., Donnelly Garment Co. v. NLRB, 123 F.2d 215, 224 (8th Cir. 1941) (“One who is capable of ruling accurately upon the admissibility of evidence is equally capable of sifting it accurately after it has been received ….”).

[^15]: See Ex. 1018 at 2 (“Hall-Ellis Declaration”).

# Conclusion

The Petition is fatally deficient because, inter alia, Petitioner has failed to show that the cited references teach or suggest, inter alia, the claimed:

- i) “controller configured to populate the task pool with a plurality of first tasks and a plurality of second tasks”
- ii) “co-processor configured to … retrieve a first task from the task pool; deliver the first task to the first co-processor”
- iii) dynamic addition of co-processors “on a plug-and-play basis without any communication with the controller”
- iv) co-processor including an agent “configured to search the task pool for a task of a first type”
- v) agent comprising a first payload including “a first function which the first co-processor is configured to perform”
- vi) agent comprising a first payload including “a descriptor of the first task;”
- vii) co-processor “configured to modify a task within the task pool”
- viii) task pool “configured to notify the controller upon completion of the first task.”
- ix) co-processor “configured to deposit a new task into the task pool.”

In addition, Petitioner has failed to show a motivation to combine AppleTalk with Leong because Leong expressly teaches away from a combination with AppleTalk and because a POSITA would have no reasonable expectation of success in combining Leong and AppleTalk as proposed by Petitioner.

In sum, Petitioner has failed to show by a preponderance of evidence that any claim of the ’004 Patent is unpatentable under 35 U.S.C. § 103.

For all of the foregoing reasons, Patent Owner respectfully submits that the Board maintain the claims of the ’004 Patent and determine that no challenged claims are unpatentable.

