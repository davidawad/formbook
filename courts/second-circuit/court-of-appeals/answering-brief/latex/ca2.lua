-- Second Circuit brief, LaTeX engine: the parts of the typst template (typst/ca2-<doc>.typ) that pandoc
-- cannot write itself. Read by tools/render-latex.sh as a pandoc filter, next to template.tex.
--
-- Builds from the frontmatter: the cover, the corporate disclosure page (if any), the table of
-- contents and the table of authorities (both two-pass, see template.tex), the signature block and
-- the certificates. Headings get their labels here (I., A., 1., a. in the Argument; A., 1., a., (1)
-- elsewhere) and become \briefhead / \briefpoint / \briefsub commands. Each citation of an authority
-- (a link to toa:<key>) gets a page mark.
--
-- DOC selects the wording of the doc type's own template: "opening", "answering" or "reply".
local DOC = "answering"
local WORD_LIMIT = ({ opening = 14000, answering = 14000, reply = 7000 })[DOC]   -- Local Rule 32.1(a), FRAP 32(a)(7)(B)
local FIRST_ARG_LEVEL = 3  -- sub-heading indent steps start at level 3 inside the Argument (typst label-indent)

-- Helpers
-- ---------------------------------------------------------------------------

-- Meta inlines (or a plain string) to LaTeX, without the trailing newline.
local function tex(x)
  if x == nil then return "" end
  if type(x) == "string" then x = pandoc.read(x, "markdown").blocks[1].content end
  local s = pandoc.write(pandoc.Pandoc({ pandoc.Plain(x) }), "latex")
  return (s:gsub("%s+$", ""))
end

-- Plain text of meta inlines, for comparisons.
local function plain(x)
  if x == nil then return "" end
  if type(x) == "string" then return x end
  return pandoc.utils.stringify(x)
end

local function need(m, key)
  if m[key] == nil then error("ca2.lua: missing required metadata field `" .. key .. "`") end
  return m[key]
end

local function raw(s) return pandoc.RawBlock("latex", s) end

local function roman(n)
  local vals = { { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local out = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do out = out .. p[2]; n = n - p[1] end
  end
  return out
end

local function letter(n, lower)
  return string.char((lower and 96 or 64) + n)
end

local function sort_key(a)
  local k = a.sort and plain(a.sort) or (plain(a.name) .. " " .. plain(a.cite))
  return (k:lower():gsub("[^a-z0-9 ]", ""))
end

-- 11622 -> "11,622"
local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

-- ---------------------------------------------------------------------------
-- Headings: labels and the table-of-contents entry (see template.tex)
-- ---------------------------------------------------------------------------

local counts = { 0, 0, 0, 0, 0 }
local in_argument = false
local header_words = 0   -- words in headings (typst counts them; pandoc turns them into raw blocks)
local cited = {}         -- authority keys linked from the body
local marker_words = 0   -- decimal list markers (1., 2., ...): typst does not count them

local function heading_label(level)
  local n = counts[level]
  if in_argument then
    if level == 2 then return roman(n) .. "."
    elseif level == 3 then return letter(n, false) .. "."
    elseif level == 4 then return tostring(n) .. "."
    elseif level == 5 then return letter(n, true) .. "."
    end
  else
    if level == 2 then return letter(n, false) .. "."
    elseif level == 3 then return tostring(n) .. "."
    elseif level == 4 then return letter(n, true) .. "."
    elseif level == 5 then return "(" .. n .. ")"
    end
  end
  error("ca2.lua: headings deeper than level 5 are not supported")
end

function Header(h)
  local lvl = h.level
  if lvl > 5 then error("ca2.lua: headings deeper than level 5 are not supported") end
  local title = tex(h.content)
  local _, words = plain(h.content):gsub("\u{00A0}", " "):gsub("%S+", "")
  header_words = header_words + words
  if lvl == 1 then
    in_argument = plain(h.content):lower():match("^%s*(.-)%s*$") == "argument"
    for j = 2, 5 do counts[j] = 0 end
    counts[1] = counts[1] + 1
    local upper = title:find("\\") and ("\\MakeUppercase{" .. title .. "}") or title:upper()
    return raw(string.format("\\briefhead{%s}\\addcontentsline{toc}{brieftoc}{%s}", title, upper))
  end
  counts[lvl] = counts[lvl] + 1
  for j = lvl + 1, 5 do counts[j] = 0 end
  local label = heading_label(lvl)
  if in_argument and lvl == 2 then
    return raw(string.format("\\briefpoint{%s}{%s}\\addcontentsline{toc}{briefpt}{\\numberline{%s}%s}",
      label, title, label, title))
  end
  -- The label's indent is counted in half inches from the margin (typst label-indent): the Argument's
  -- point headings are centered, so their sub-headings start at the first step.
  local first = in_argument and FIRST_ARG_LEVEL or 2
  local steps = lvl - first + 1
  local style = lvl >= 4 and "\\bfseries\\itshape" or "\\bfseries"
  local toc = ({ [1] = "briefa", [2] = "briefb", [3] = "briefc" })[steps]
  local ind = ({ [1] = "0.5in", [2] = "1in", [3] = "1.5in" })[steps]
  return raw(string.format("\\briefsub{%s}{%s}{%s}{%s}\\addcontentsline{toc}{%s}{\\numberline{%s}%s}",
    ind, label, style, title, toc, label, title))
end


-- Markers such as (A) that open a paragraph are text, as written (typst prints them as written);
-- pandoc reads them as list items, which would be renumbered.
local function marker(style, n)
  if style == "UpperAlpha" then return string.char(64 + n)
  elseif style == "LowerAlpha" then return string.char(96 + n)
  elseif style == "UpperRoman" then return roman(n)
  elseif style == "LowerRoman" then return roman(n):lower()
  end
  return tostring(n)
end

function OrderedList(l)
  local a = l.listAttributes
  local out = {}
  for i, item in ipairs(l.content) do
    local lab = marker(a.style, a.start + i - 1)
    if a.style == "Decimal" then marker_words = marker_words + 1 end
    if a.delimiter == "TwoParens" then lab = "(" .. lab .. ")"
    elseif a.delimiter == "OneParen" then lab = lab .. ")"
    else lab = lab .. "." end
    local first = item[1]
    if first and (first.t == "Para" or first.t == "Plain") then
      local inl = pandoc.List({ pandoc.Str(lab), pandoc.Space() })
      for _, x in ipairs(first.content) do inl:insert(x) end
      item[1] = pandoc.Para(inl)
    end
    for _, b in ipairs(item) do table.insert(out, b) end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Citations of authorities: a link to toa:<key> marks its page (see template.tex)
-- ---------------------------------------------------------------------------

function Link(el)
  local key = el.target:match("^toa:(.+)$")
  if key == nil then return nil end
  cited[key] = true
  local out = { pandoc.RawInline("latex", "\\toamark{" .. key .. "}") }
  for _, i in ipairs(el.content) do table.insert(out, i) end
  return out
end

-- ---------------------------------------------------------------------------
-- Cover, tables, signature and certificates
-- ---------------------------------------------------------------------------

local GAP = "\\vfill"   -- the cover spreads its parts over the page (typst fills it with the largest gap that fits)

-- One counsel group: names, italic lines, then its telephone number (reply: per group; otherwise the
-- frontmatter's phone under the last group).
local function counsel_block(g, phone)
  local block = {}
  for _, n in ipairs(g.names) do table.insert(block, tex(n) .. "\\\\") end
  for _, l in ipairs(g.lines or {}) do table.insert(block, "\\hspace*{0.5em}\\emph{" .. tex(l) .. "}\\\\") end
  if phone then table.insert(block, "\\hspace*{0.5em}" .. (DOC == "reply" and tex(phone) or ("\\emph{" .. tex(phone) .. "}")) .. "\\\\") end
  return table.concat(block)
end

local function cover(m)
  local out = {}
  local function add(s) table.insert(out, s) end
  local court = DOC == "opening"
    and "IN THE UNITED STATES COURT OF APPEALS\\\\FOR THE SECOND CIRCUIT"
    or "IN THE\\\\United States Court of Appeals for the Second Circuit"
  add("\\thispagestyle{empty}")
  -- Local Rule 32.1(a)(1): docket number "in type at least one inch high" (72 pt = 1 in).
  add("{\\centering\\bfseries\\fontsize{72}{80}\\selectfont " .. tex(need(m, "case_number")) .. "\\par}")
  add("\\vspace{7pt}\\briefdouble" .. GAP)
  add("{\\centering\\briefsingle\\bfseries " .. court .. "\\par}")
  add(RULE)
  add("{\\centering\\briefsingle")
  local sides = need(m, "caption")
  for i, side in ipairs(sides) do
    for _, name in ipairs(side.names) do add(tex(name) .. "\\par") end
    if DOC == "opening" then
      add("\\briefcaptiondesig{" .. tex(side.designation) .. "}")
    else
      add(tex(side.designation) .. "\\par")
    end
    if i < #sides then
      add(DOC == "opening" and "\\par\\vfill-v-\\par\\vfill" or "\\par\\vfill\\textendash\\ v.\\ \\textendash\\par\\vfill")
    end
  end
  add("\\par}")
  add(RULE)
  add("{\\centering\\briefsingle " .. tex(need(m, "proceeding")) .. "\\par}")
  if m.district_court_case or m.judge then
    local dc = ""
    if m.district_court_case then dc = (DOC == "reply" and "Case No.\\ " or "D.C.\\ No.\\ ") .. tex(m.district_court_case) end
    if m.district_court_case and m.judge then dc = dc .. "; " end
    if m.judge then dc = dc .. tex(m.judge) end
    add("{\\centering\\briefsingle " .. dc .. "\\par}")
  end
  add(RULE)
  add("{\\centering\\briefsingle\\bfseries\\MakeUppercase{" .. tex(need(m, "brief_title")) .. "}\\par}")
  add(RULE)
  local groups = need(m, "counsel")
  if DOC == "reply" then
    -- two columns of counsel, as the reply typst template sets them: the first half of the groups
    -- stacked on the left, the rest on the right
    local half = math.ceil(#groups / 2)
    local function column(first, last)
      local parts = {}
      for gi = first, last do table.insert(parts, counsel_block(groups[gi], groups[gi].phone)) end
      return "\\begin{minipage}[t]{0.45\\linewidth}\\briefsingle\\raggedright " ..
        table.concat(parts, "\\vspace{0.6em}\\par ") .. "\\end{minipage}"
    end
    add("\\noindent" .. column(1, half) .. "\\hfill" .. column(half + 1, #groups))
    if m.counsel_for then add("\\par\\vspace{0.5em}\\emph{" .. tex(m.counsel_for) .. "}") end
  else
    for gi, g in ipairs(groups) do
      local phone = g.phone or (gi == #groups and m.phone or nil)
      add("\\briefcounselblock{\\briefsingle " .. counsel_block(g, phone) .. "}")
      if gi < #groups then add("\\vspace{0.5em}") end
    end
  end
  add(GAP .. "\\briefdouble")
  -- a page-high box: the gaps share the page and the cover never breaks onto a second page
  return "\\noindent\\begin{minipage}[t][\\textheight][t]{\\textwidth}\n" .. table.concat(out, "\n") .. "\n\\end{minipage}"
end

local function disclosure(m)
  return "\\clearpage\n\\briefhead{Corporate Disclosure Statement}\n" .. tex(m.disclosure) .. "\n\\clearpage"
end

-- Table of contents: the entries come from the .toc file (addcontentsline, see the headings above).
local function toc()
  return "{\\centering \\bfseries\\briefsingle\\fontsize{16.1}{19.9}\\selectfont TABLE OF CONTENTS\\par\\par}\n" ..
    "\\briefTOC"
end

-- Table of authorities: groups of the authorities cited in the body, in typst's order.
local TOA_GROUPS = {
  { { "case" }, "Cases:" },
  { { "constitution" }, "Constitutional Provisions:" },
  { { "statute" }, "Statutes:" },
  { { "regulation" }, "Regulations:" },
  { { "rule" }, "Rules:" },
  { { "other" }, "Other Authorities:" },
}

local function toa(auths)
  local out = {
    "{\\centering \\bfseries\\briefsingle\\fontsize{16.1}{19.9}\\selectfont TABLE OF AUTHORITIES\\par\\par}",
    "\\addcontentsline{toc}{brieftoc}{TABLE OF AUTHORITIES}",
  }
  local first = true
  for _, g in ipairs(TOA_GROUPS) do
    local members = {}
    for key, a in pairs(auths) do
      if plain(a.kind) == g[1][1] and cited[key] then table.insert(members, { key = key, a = a }) end
    end
    if #members > 0 then
      table.sort(members, function(x, y) return sort_key(x.a) < sort_key(y.a) end)
      table.insert(out, (first and "\\toagroupfirst{" or "\\toagroup{") .. g[2] .. "}")
      first = false
      for _, mem in ipairs(members) do
        local cite = tex(mem.a.cite)
        if mem.a.name then
          local name = (g[1][1] == "case") and ("\\emph{" .. tex(mem.a.name) .. "}") or tex(mem.a.name)
          table.insert(out, "\\toaitem{" .. mem.key .. "}{" .. name .. "}{" .. cite .. "}")
        else
          table.insert(out, "\\toaitemnoname{" .. mem.key .. "}{" .. cite .. "}")
        end
      end
    end
  end
  return table.concat(out, "\n")
end



local function signature(m)
  local sig = need(m, "signature")
  local out = {}
  -- answering and reply: the date and city come above the signature (their typst templates)
  if DOC ~= "opening" and m.date then
    table.insert(out, "\\par\\noindent Dated: " .. tex(m.date) .. (m.city and (", " .. tex(m.city)) or "") .. "\\par")
  end
  local sigline = DOC == "opening" and "s/ " or "/s/ "
  local name = DOC == "opening" and ("\\MakeUppercase{" .. tex(sig.signer) .. "}") or tex(sig.signer)
  local block = { "\\begin{briefsig}Respectfully submitted,\\\\[1.2em]" .. sigline .. tex(sig.signer) .. "\\\\" .. name }
  for _, l in ipairs(sig.lines or {}) do table.insert(block, "\\\\\\hspace*{0.5em}\\emph{" .. tex(l) .. "}") end
  if DOC == "reply" and m.counsel_for then table.insert(block, "\\\\[0.6em]\\emph{" .. tex(m.counsel_for) .. "}") end
  table.insert(block, "\\end{briefsig}")
  table.insert(out, table.concat(block))
  if DOC == "opening" and m.date then table.insert(out, "\\par\\vspace{0.8em}" .. tex(m.date) .. "\\par") end
  return table.concat(out, "")
end
local function words_of(blocks)
  local n = 0
  local function count(el)
    local _, k = pandoc.utils.stringify(el):gsub("\u{00A0}", " "):gsub("%S+", "")
    n = n + k
  end
  pandoc.Pandoc(blocks):walk({ Para = count, Plain = count })
  return n
end

-- A certificate's signature and date line (typst form-sig-line).
local function sig_foot(signer, date)
  local s = (DOC == "opening" and "s/ " or "/s/ ") .. tex(signer)
  return "\\briefsigfoot{" .. s .. "}{" .. (date and tex(date) or "") .. "}"
end

local function certificate_of_compliance(m, words)
  local n = group_digits(words)
  local typeface = "Liberation Serif"
  local body
  if DOC == "opening" then
    body = "1.\\ This document complies with the type-volume limit of Fed.\\ R.\\ App.\\ P.\\ 32(a)(7)(B) and Local Rule 32.1(a) because, excluding the parts of the document exempted by Fed.\\ R.\\ App.\\ P.\\ 32(f): this document contains " .. n .. " words.\\par\n" ..
      "2.\\ This document complies with the typeface requirements of Fed.\\ R.\\ App.\\ P.\\ 32(a)(5) and the type style requirements of Fed.\\ R.\\ App.\\ P.\\ 32(a)(6) because: this document has been prepared in a proportionally spaced typeface using " .. typeface .. " in 14-point type.\\par\n"
  elseif DOC == "answering" then
    body = "This brief complies with the type-volume limitation of Fed.\\ R.\\ App.\\ P.\\ 32(a)(7)(B) and Local Rule 32.1(a)(4)(A) because this brief contains " .. n .. " words, excluding the parts of the brief exempted by Fed.\\ R.\\ App.\\ P.\\ 32(f).\\par\n" ..
      "This brief complies with the typeface requirements of Fed.\\ R.\\ App.\\ P.\\ 32(a)(5) and the type style requirements of Fed.\\ R.\\ App.\\ P.\\ 32(a)(6) because this brief has been prepared in a proportionally spaced typeface using LaTeX in 14-point " .. typeface .. ".\\par\n"
  else
    body = "This brief complies with the type-volume limitation set forth in Local Rule 32.1(a)(4)(B) because it contains " .. n .. " words, excluding the parts of the brief exempted by Federal Rule of Appellate Procedure 32(f).\\par\n" ..
      "This brief complies with the typeface requirements of Federal Rule of Appellate Procedure 32(a)(5) and the type-style requirements of Federal Rule of Appellate Procedure 32(a)(6) because it was prepared in a proportionally spaced typeface using LaTeX in 14-point " .. typeface .. " font.\\par\n"
  end
  local date = m.date and plain(m.date) or ""
  local foot = sig_foot(need(m, "signature").signer, date)
  if DOC ~= "opening" then foot = "\\par\\noindent Dated: " .. tex(m.date) .. "\\par" .. foot end
  return "\\clearpage\n\\briefhead{Certificate of Compliance}\n\\begin{briefcert}" .. body .. "\\end{briefcert}\n" .. foot
end

local function certificate_of_service(m)
  local svc = need(m, "service")
  local out = { "\\clearpage\n\\briefhead{Certificate of Service}\n\\begin{briefcert}" }
  if DOC == "opening" then
    table.insert(out, "I certify that on " .. tex(svc.date) .. ", I served one copy of the foregoing " .. tex(m.brief_title) ..
      " on the following counsel of record, by the method stated:\\par")
    for _, p in ipairs(svc.parties) do
      table.insert(out, "\\begin{quote}\\noindent\\setlength{\\parskip}{0pt}" .. tex(p.name) .. "\\\\" .. tex(p.address) ..
        "\\\\\\emph{" .. tex(p.method) .. "}\\end{quote}")
    end
    table.insert(out, "\\end{briefcert}")
    local signer = svc.signer or need(m, "signature").signer
    table.insert(out, sig_foot(signer, svc.date and plain(svc.date) or ""))
  elseif DOC == "answering" then
    table.insert(out, "I hereby certify that on " .. tex(m.date) .. ", a true and correct copy of the foregoing was served via " ..
      tex(svc.method or "ACMS") .. " to all counsel of record or parties pro se.\\par")
    local unreg = svc.unregistered or {}
    if #unreg > 0 then
      table.insert(out, "The following case participants are NOT registered for electronic filing and were served by mail or another method (name and address):\\par")
      for _, u in ipairs(unreg) do table.insert(out, "\\begin{quote}" .. tex(u.name) .. ", " .. tex(u.address) .. "\\end{quote}") end
    end
    table.insert(out, "\\end{briefcert}")
    table.insert(out, sig_foot(need(m, "signature").signer, m.date and plain(m.date) or ""))
  else
    table.insert(out, "I hereby certify that, on " .. tex(m.date) .. ", I electronically filed the foregoing " .. tex(m.brief_title) ..
      " with the United States Court of Appeals for the Second Circuit using the Court\u{2019}s electronic filing system, which will serve copies on all registered counsel.\\par")
    table.insert(out, "\\end{briefcert}")
    table.insert(out, "\\par\\noindent Dated: " .. tex(m.date) .. "\\par" .. sig_foot(need(m, "signature").signer, nil))
  end
  return table.concat(out, "\n")
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local m = doc.meta
  local blocks = doc.blocks
  local auths = m.authorities or {}
  for key in pairs(cited) do
    if auths[key] == nil then error("ca2.lua: link `toa:" .. key .. "` has no entry under `authorities:`") end
  end
  for _, k in ipairs({ "case_number", "caption", "proceeding", "brief_title", "counsel", "signature", "service" }) do
    need(m, k)
  end

  -- Word count (FRAP 32(f) exclusions: cover, tables, signature, certificates): the body, headings
  -- included, as typst counts it.
  local words = words_of(blocks) + header_words - marker_words
  if words > WORD_LIMIT then
    error("ca2.lua: the brief has " .. words .. " words; Local Rule 32.1(a) allows " .. WORD_LIMIT)
  end

  local out = {}
  local function add(b) table.insert(out, b) end

  -- front matter: the cover (no number), then lower-case roman numbering
  add(raw(cover(m)))
  add(raw("\\clearpage\\pagenumbering{roman}\\setcounter{page}{1}"))
  if m.disclosure then add(raw(disclosure(m))) end
  add(raw(toc()))
  add(raw("\\clearpage"))
  add(raw(toa(auths)))

  -- body (arabic from 1); the last paragraph stays with the signature block
  add(raw("\\clearpage\\pagenumbering{arabic}\\setcounter{page}{1}"))
  local n = #blocks
  for i = 1, n do
    if i == n and blocks[i].t == "Para" then
      add(raw("\\begin{samepage}"))
      add(blocks[i])
      add(raw("\\nopagebreak[4]"))
      add(raw(signature(m)))
      add(raw("\\end{samepage}"))
    else
      add(blocks[i])
    end
  end
  if n == 0 or blocks[n].t ~= "Para" then add(raw(signature(m))) end

  -- certificates (FRAP 32(g); FRAP 25(d))
  add(raw(certificate_of_compliance(m, words)))
  -- the certificate of service: always for the opening brief; otherwise only when the frontmatter asks for it
  if DOC == "opening" or (m.service and m.service.certificate) then add(raw(certificate_of_service(m))) end

  return pandoc.Pandoc(out, doc.meta)
end
