-- U.S. Court of Appeals for the Third Circuit: pandoc filter for the LaTeX engine (one copy per doc type).
-- The same content as the typst template of this doc type (typst/ca3-*.typ), from the same markdown
-- contract (../README.md). It writes raw LaTeX for the cover, the disclosure, the headings, the tables,
-- the signature blocks and the certificates; template.tex defines the macros it calls.
-- Nothing here is case-specific. The only line that differs between the copies is TYPE.

local TYPE = "reply" -- "opening" | "answering" | "reply"

local LIMIT = ({ opening = 13000, answering = 13000, reply = 6500 })[TYPE]
-- "opening": I. A. 1. a. everywhere. "argument": the Argument has I. A. 1. a. (its level 2 is a centered
-- point heading); elsewhere A. 1. a. (1).
local SCHEME = (TYPE == "opening") and "opening" or "argument"
local PREPARED_WITH = "LaTeX"
-- The face template.tex loads (named in the certificate of compliance).
local FACE = "Times"

-- Authority groups, in the order the table prints them (same as the typst templates).
local TOA_GROUPS = {
  { "case", "Cases:" },
  { "constitution", "Constitutional Provisions:" },
  { "statute", "Statutes:" },
  { "regulation", "Regulations:" },
  { "rule", "Rules:" },
  { "other", "Other Authorities:" },
}

-- pandoc wraps long inline output over several lines; a blank line would end a macro argument,
-- so every string is flattened to one line here.
local function trim(s)
  local t = s:gsub("%s*\n%s*", " ")
  t = t:gsub("^%s+", "")
  t = t:gsub("%s+$", "")
  return t
end

-- LaTeX for a frontmatter value (inline markdown, as pandoc reads it).
local function tex(m)
  if m == nil then return "" end
  if type(m) == "string" then
    return trim(pandoc.write(pandoc.read(m, "markdown"), "latex"))
  end
  if m.t == "MetaInlines" then
    return trim(pandoc.write(pandoc.Pandoc({ pandoc.Plain(m) }), "latex"))
  elseif m.t == "MetaString" then
    return trim(pandoc.write(pandoc.read(m, "markdown"), "latex"))
  end
  return trim(pandoc.write(pandoc.Pandoc(m), "latex"))
end

local function need(meta, key)
  if meta[key] == nil then error("ca3-" .. TYPE .. ": missing required metadata field `" .. key .. "`") end
  return meta[key]
end

local function roman(n)
  local vals = { { 10, "x" }, { 9, "ix" }, { 5, "v" }, { 4, "iv" }, { 1, "i" } }
  local out = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do
      out = out .. p[2]
      n = n - p[1]
    end
  end
  return string.upper(out)
end

-- Printed label of a numbered heading, and the indent of its label column (half inches from the margin).
local function label_for(level, n, in_arg)
  if SCHEME == "opening" or in_arg then
    if level == 2 then return roman(n) .. "." end
    if level == 3 then return string.char(64 + n) .. "." end
    if level == 4 then return tostring(n) .. "." end
    if level == 5 then return string.char(96 + n) .. "." end
  else
    if level == 2 then return string.char(64 + n) .. "." end
    if level == 3 then return tostring(n) .. "." end
    if level == 4 then return string.char(96 + n) .. "." end
    if level == 5 then return "(" .. n .. ")" end
  end
  error("ca3-" .. TYPE .. ": headings deeper than level 5 are not supported")
end

local function indent_for(level, in_arg)
  if SCHEME == "opening" or in_arg then return level - 2 end
  return level - 1
end

-- Inline `toa:key` links: a hit (the page of the citation goes to the aux file), then the link text.
function Link(el)
  if el.target:sub(1, 4) == "toa:" then
    local out = { pandoc.RawInline("latex", "\\toahit{" .. el.target:sub(5) .. "}") }
    for _, x in ipairs(el.content) do out[#out + 1] = x end
    return out
  end
  return nil
end

-- Word count of markdown, as typst counts it: whitespace-delimited words, markup removed.
local function count_words(src)
  local s = src
  s = s:gsub("<!%-%-.-%-%->", " ")
  s = s:gsub("%[%^[^%]]+%]:", " ")
  s = s:gsub("%[%^[^%]]+%]", "")
  s = s:gsub("%[([^%]]*)%]%([^)]*%)", "%1")
  s = s:gsub("\n#+[ \t]+", "\n")
  s = s:gsub("^#+[ \t]+", "")
  s = s:gsub("\n>[ \t]?", "\n")
  s = s:gsub("\n[ \t]*[-*+][ \t]+", "\n")
  s = s:gsub("\n[ \t]*%d+[.)][ \t]+", "\n")
  s = s:gsub("%*", "")
  local n = 0
  for _ in s:gmatch("%S+") do n = n + 1 end
  return n
end

local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

-- The markdown body (after the frontmatter), and the part of it before an "# Addendum" heading.
local function body_source()
  local f = assert(io.open(PANDOC_STATE.input_files[1], "r"))
  local src = f:read("a")
  f:close()
  local body = src:match("^%-%-%-\r?\n.-\r?\n%-%-%-[ \t]*\r?\n(.*)$") or src
  local s = body:find("\n#[ \t]+[Aa]ddendum[ \t]*\r?\n")
  if s then return body:sub(1, s) end
  return body
end

local function body_words(meta)
  local n = count_words(body_source())
  if TYPE == "opening" then
    n = n + count_words(pandoc.utils.stringify(need(meta, "related_cases")))
  end
  return n
end

-- The cover. The lines the three types set differently are chosen by TYPE.
local function cover(meta)
  local out = {}
  local function add(s) out[#out + 1] = s end
  local function gap(em) add("\\vspace{" .. (em * 0.2) .. "em}") end
  local function dbl()
    add("\\par\\noindent\\rule{\\linewidth}{1.6pt}\\par\\vspace{2.5pt}\\noindent\\rule{\\linewidth}{0.5pt}\\par")
  end
  local function short() add("\\par\\begin{center}\\rule{2in}{0.7pt}\\end{center}\\par") end
  add("\\thispagestyle{empty}")
  add("{\\casingle\\begin{center}")
  add("\\textbf{No.\\ " .. tex(need(meta, "case_number")) .. "}\\par")
  gap(0.5)
  dbl()
  gap(0.5)
  if TYPE == "opening" then
    add("\\textbf{IN THE UNITED STATES COURT OF APPEALS FOR THE\\ THIRD\\ CIRCUIT}\\par")
  else
    add("\\textbf{IN THE UNITED STATES COURT OF APPEALS\\\\ FOR THE THIRD CIRCUIT}\\par")
  end
  gap(0.5)
  short()
  gap(0.5)
  local sides = need(meta, "caption")
  for i, side in ipairs(sides) do
    for _, name in ipairs(side.names) do add(tex(name) .. "\\par") end
    add(tex(side.designation) .. "\\par")
    if i < #sides then
      gap(0.3)
      add("v.\\par")
      gap(0.3)
    end
  end
  gap(0.5)
  short()
  gap(0.5)
  add(tex(need(meta, "proceeding")) .. "\\par")
  if TYPE == "opening" then
    if meta.district_court_case then add("(" .. tex(meta.district_court_case) .. ")\\par") end
    if meta.judge then add("(" .. tex(meta.judge) .. ")\\par") end
  elseif TYPE == "answering" then
    local parts = {}
    if meta.district_court_case then parts[#parts + 1] = "D.C. No. " .. tex(meta.district_court_case) end
    if meta.judge then parts[#parts + 1] = tex(meta.judge) end
    if #parts > 0 then add(table.concat(parts, "; ") .. "\\par") end
  else
    if meta.district_court_case then add("No. " .. tex(meta.district_court_case) .. "\\par") end
    if meta.judge then add(tex(meta.judge) .. "\\par") end
  end
  gap(0.5)
  short()
  gap(0.5)
  add("\\textbf{\\MakeUppercase{" .. tex(need(meta, "brief_title")) .. "}}\\par")
  if meta.appendix then add(tex(meta.appendix) .. "\\par") end
  gap(0.5)
  short()
  gap(0.5)
  add("\\end{center}")
  add("{\\fontsize{14}{14.5}\\selectfont\\hspace*{0.5\\linewidth}\\begin{minipage}[t]{0.5\\linewidth}\\raggedright")
  for _, g in ipairs(need(meta, "counsel")) do
    for _, n in ipairs(g.names) do add(tex(n) .. "\\\\") end
    for _, l in ipairs(g.lines or {}) do add("\\hspace*{0.5em}" .. tex(l) .. "\\\\") end
    add("\\vspace{0.2em}")
  end
  add("\\hspace*{0.5em}" .. tex(need(meta, "phone")))
  if meta.counsel_for then add("\\\\\\hspace*{0.5em}\\emph{" .. tex(meta.counsel_for) .. "}") end
  add("\\end{minipage}}")
  dbl()
  add("}")
  add("\\clearpage")
  return table.concat(out, "\n")
end

-- The signature lines: "/s/ signer", then the counsel lines. Answering and reply also give the name in
-- capitals and the lines in italics. `respect` adds "Respectfully submitted,"; `with_date` the date line.
local function signature_tex(meta, respect, with_date)
  local sig = need(meta, "signature")
  local lines = { "/s/ " .. tex(sig.signer) }
  if TYPE ~= "opening" then
    lines[#lines + 1] = string.upper(tex(sig.signer))
    for _, l in ipairs(sig.lines or {}) do lines[#lines + 1] = "\\hspace*{0.5em}\\emph{" .. tex(l) .. "}" end
  else
    for _, l in ipairs(sig.lines or {}) do lines[#lines + 1] = tex(l) end
  end
  local out = table.concat(lines, "\\\\\n")
  if respect then out = "Respectfully submitted,\\\\[1.2em]\n" .. out end
  if with_date and meta.date then out = out .. "\n\\par\\vspace{0.8em}" .. tex(meta.date) end
  return out
end

local function sigblock(meta, respect, with_date)
  return "\\sigblock{" .. signature_tex(meta, respect, with_date) .. "}"
end

-- The certificates, in the order of each type's filed exemplar.
local function certificates(meta, words)
  local out = {}
  local function cert(title, body)
    out[#out + 1] = "\\clearpage"
    out[#out + 1] = "\\caheadplain{" .. title .. "}"
    out[#out + 1] = body
  end
  local ind = "\\noindent\\hspace*{0.5in}"
  if TYPE == "opening" then
    local prepared = meta.prepared_with and tex(meta.prepared_with) or PREPARED_WITH
    cert("Certificate of Compliance",
      ind .. "This brief complies with the type-volume limitation of Fed. R. App. P. 32(a)(7)(B) because it contains "
      .. group_digits(words) .. " words, excluding the parts of the brief exempted by Fed. R. App. P. 32(f).\\par\n"
      .. ind .. "This brief complies with the typeface requirements of Fed. R. App. P. 32(a)(5) and the type-style requirements of Fed. R. App. P. 32(a)(6) because it has been prepared in a proportionally spaced typeface using "
      .. prepared .. " in font size 14, font style " .. FACE .. ".\\par\n"
      .. sigblock(meta, false, true))
    cert("Certification of Bar Membership",
      ind .. "I certify that at least one of the attorneys whose names appear on this brief is a member of the bar of this Court, or has filed an application for admission under 3d Cir. L.A.R. 46.1.\\par\n"
      .. sigblock(meta, false, true))
    local virus = ""
    if meta.virus_software then
      virus = ind .. "I certify that a virus check was performed on the PDF file of this brief. The virus software used was "
        .. tex(meta.virus_software) .. ".\\par\n"
    end
    cert("Certification of Text of E-Brief and Virus Check",
      ind .. "I certify that the text of the E-Brief and the text of the hard copies of this brief are identical.\\par\n"
      .. virus .. sigblock(meta, false, true))
    local service = meta.service and meta.service.certificate
    if service == nil or service == true then
      cert("Certificate of Service",
        ind .. "I, " .. tex(need(meta, "signature").signer)
        .. ", counsel for the filer and a member of the bar of this Court, certify that, on " .. tex(need(meta, "date"))
        .. ", the brief and all accompanying appendices were filed electronically through the appellate CM/ECF system with the Clerk of Court. I further certify that all parties required to be served have been served.\\par\n"
        .. sigblock(meta, false, true))
    end
  elseif TYPE == "answering" then
    cert("Certificate of Bar Membership",
      ind .. "I hereby certify that at least one of the attorneys whose names appear on this brief is a member of the bar of this Court.\\par\n"
      .. sigblock(meta, false, false))
    cert("Electronic-Filing Certification",
      ind .. "I hereby certify that the text of the electronically filed brief is identical to the text in the paper copies. I also certify that a virus detection program has been run on the electronic file and that no virus was detected. The virus detection program used, and its version, is \\rule{2.2in}{0.5pt}.\\par\n"
      .. sigblock(meta, false, false))
    cert("Certificate of Compliance",
      ind .. "1.\\ This brief complies with the type-volume limitation of Fed. R. App. P. 32(a)(7)(B) because it contains "
      .. group_digits(words) .. " words, excluding the parts of the brief exempted by Fed. R. App. P. 32(f). The count includes "
      .. tostring(meta.manual_image_words or 0) .. " words counted by hand in any visual images.\\par\n"
      .. ind .. "2.\\ This brief complies with the typeface requirements of Fed. R. App. P. 32(a)(5) and the type-style requirements of Fed. R. App. P. 32(a)(6) because it has been prepared in a proportionally spaced typeface using "
      .. PREPARED_WITH .. " in 14-point, " .. FACE .. ".\\par\n"
      .. sigblock(meta, false, false))
    if meta.service then
      local svc = meta.service
      local items = {}
      for _, u in ipairs(svc.to or {}) do
        items[#items + 1] = "\\noindent\\hspace*{0.5in}" .. tex(u.name) .. "\\\\\n" .. tex(u.address) .. "\\par"
      end
      cert("Certificate of Service",
        ind .. "I certify that on " .. tex(svc.date) .. " I caused the foregoing " .. tex(need(meta, "brief_title"))
        .. " to be served by " .. tex(svc.method) .. " on the following:\\par\n"
        .. table.concat(items, "\n") .. "\n"
        .. sigblock(meta, false, false))
    end
  else -- reply
    cert("Certificate of Compliance",
      ind .. "The undersigned counsel certifies pursuant to L.A.R. 46.1(e) that counsel is a member in good standing of the bar of this Court.\\par\n"
      .. ind .. "This brief complies with the type-volume limitation of FRAP 32(a)(7)(B)(ii) because it contains " .. group_digits(words)
      .. " words, including headings, footnotes, and quotations, and excluding the items exempted by FRAP 32(f). It is prepared in "
      .. tex(meta.typeface or "14-point, proportionally spaced serif type")
      .. " and complies with the typeface and type-style requirements of FRAP 32(a)(5) and (6).\\par\n"
      .. ind .. "The text of the electronic document is identical to the paper copies. Pursuant to L.A.R. 31.1(c), this electronic document was scanned for viruses using "
      .. tex(need(meta, "virus_scanner")) .. " prior to filing and found to be virus free.\\par\n"
      .. sigblock(meta, false, false))
    local svc = meta.service
    if svc then
      local unreg = svc.unregistered or {}
      local extra = ""
      if #unreg > 0 then
        local items = {}
        for _, u in ipairs(unreg) do
          items[#items + 1] = "\\noindent\\hspace*{0.5in}" .. tex(u.name) .. "\\\\\n" .. tex(u.address) .. "\\par"
        end
        extra = "\\noindent\\textbf{Service on Case Participants Who Are NOT Registered for Electronic Filing:}\\par\n"
          .. ind .. "I certify that I served the foregoing document on this date by hand delivery, mail, third party commercial carrier for delivery within 3 calendar days, or, having obtained prior consent, by email to the following unregistered case participants (list each name and mailing/email address):\\par\n"
          .. table.concat(items, "\n") .. "\n"
      end
      cert("Certificate of Service",
        ind .. "I hereby certify that the foregoing brief was electronically filed on this date with the Clerk of the Court for the United States Court of Appeals for the Third Circuit by using the appellate CM/ECF system. Participants in the case who are registered CM/ECF users will be served by the appellate CM/ECF system.\\par\n"
        .. extra .. sigblock(meta, false, false))
    end
  end
  return table.concat(out, "\n")
end

-- Table of contents and table of authorities (front matter, roman pages). The entries come from the aux
-- file of the previous pass (template.tex).
local function tables_tex(meta)
  local out = {}
  out[#out + 1] = "\\begingroup"
  out[#out + 1] = "\\caheadplain{Table of Contents}"
  out[#out + 1] = "\\noindent\\hfill\\textbf{\\underline{Page}}\\par"
  out[#out + 1] = "\\tocprint"
  out[#out + 1] = "\\clearpage"
  out[#out + 1] = "\\caheadplain{Table of Authorities}"
  local authorities = meta.authorities or {}
  local first = 1
  for _, g in ipairs(TOA_GROUPS) do
    local members = {}
    for k, a in pairs(authorities) do
      if a.kind and pandoc.utils.stringify(a.kind) == g[1] then
        local name = a.name and pandoc.utils.stringify(a.name) or ""
        local sort = string.lower(name .. " " .. pandoc.utils.stringify(a.cite)):gsub("[^a-z0-9 ]", "")
        members[#members + 1] = { key = k, a = a, sort = sort }
      end
    end
    table.sort(members, function(x, y) return x.sort < y.sort end)
    if #members > 0 then
      local keys = {}
      for _, m in ipairs(members) do keys[#keys + 1] = m.key end
      out[#out + 1] = "\\toagroup{" .. g[2] .. "}{" .. table.concat(keys, ",") .. "}{" .. first .. "}"
      first = 0
      for _, m in ipairs(members) do
        local shown = tex(m.a.cite)
        if m.a.name then
          local nm = tex(m.a.name)
          if g[1] == "case" then nm = "\\emph{" .. nm .. "}" end
          shown = nm .. ",\\\\" .. shown
        end
        out[#out + 1] = "\\toaitem{" .. m.key .. "}{" .. shown .. "}{}"
      end
    end
  end
  out[#out + 1] = "\\endgroup"
  out[#out + 1] = "\\clearpage"
  return table.concat(out, "\n")
end

function Pandoc(doc)
  local meta = doc.meta
  local words = body_words(meta)
  if words > LIMIT then
    error("ca3-" .. TYPE .. ": the brief has " .. words .. " words; the limit is " .. LIMIT)
  end
  local blocks = doc.blocks
  local addendum_at = nil
  for i, b in ipairs(blocks) do
    if b.t == "Header" and b.level == 1 and string.lower(pandoc.utils.stringify(b.content)) == "addendum" then
      addendum_at = i
      break
    end
  end
  local body_end = addendum_at and (addendum_at - 1) or #blocks

  -- The body: every heading becomes a call to the template's heading macros.
  local counts = { 0, 0, 0, 0, 0 }
  local in_arg = false
  local body = {}
  local placed = false
  for i = 1, body_end do
    local b = blocks[i]
    if b.t == "Header" then
      local title = pandoc.utils.stringify(b.content)
      local ttl = trim(pandoc.write(pandoc.Pandoc({ pandoc.Plain(b.content) }), "latex"))
      if b.level == 1 then
        counts = { 0, 0, 0, 0, 0 }
        in_arg = (SCHEME == "argument") and (string.lower(title) == "argument")
        if string.lower(title) == "statement of the case" then
          body[#body + 1] = pandoc.RawBlock("latex", "\\cahead{1}{0}{}{Statement of Related Cases}")
          if meta.related_cases then body[#body + 1] = pandoc.Para(need(meta, "related_cases")) end
          placed = true
        end
        body[#body + 1] = pandoc.RawBlock("latex", "\\cahead{1}{0}{}{" .. ttl .. "}")
      else
        counts[b.level] = counts[b.level] + 1
        for k = b.level + 1, 5 do counts[k] = 0 end
        if SCHEME == "argument" and in_arg and b.level == 2 then
          body[#body + 1] = pandoc.RawBlock("latex", "\\capoint{" .. label_for(2, counts[2], true) .. "}{" .. ttl .. "}")
        else
          body[#body + 1] = pandoc.RawBlock("latex", "\\cahead{" .. b.level .. "}{" .. indent_for(b.level, in_arg)
            .. "}{" .. label_for(b.level, counts[b.level], in_arg) .. "}{" .. ttl .. "}")
        end
      end
    else
      body[#body + 1] = b
    end
  end
  if SCHEME == "opening" and not placed then
    error("ca3-" .. TYPE .. ": the body needs a `# Statement of the Case` heading")
  end

  -- The whole document, in print order.
  local out = {}
  local function raw(s) out[#out + 1] = pandoc.RawBlock("latex", s) end
  raw(cover(meta))
  raw("\\pagenumbering{roman}\\setcounter{page}{1}")
  if meta.disclosure then
    raw("\\caheadplain{Corporate Disclosure Statement}")
    -- a block scalar with several paragraphs is a list of inline values, one per paragraph
    local d = meta.disclosure
    if d.t == "MetaString" then
      for _, p in ipairs(pandoc.read(d, "markdown").blocks) do out[#out + 1] = p end
    elseif d.t == "MetaInlines" then
      out[#out + 1] = pandoc.Para(d)
    else
      for _, p in ipairs(d) do out[#out + 1] = pandoc.Para({ pandoc.Str(pandoc.utils.stringify(p)) }) end
    end
    raw("\\clearpage")
  end
  raw(tables_tex(meta))
  raw("\\pagenumbering{arabic}\\setcounter{page}{1}")
  for _, b in ipairs(body) do out[#out + 1] = b end
  raw(sigblock(meta, true, true))
  raw(certificates(meta, words))
  if addendum_at then
    raw("\\clearpage\\renewcommand{\\thepage}{Add-\\arabic{page}}\\setcounter{page}{1}\\caheadplain{Addendum}")
    for i = addendum_at + 1, #blocks do
      local b = blocks[i]
      if b.t == "Header" then
        raw("\\cahead{" .. b.level .. "}{0}{}{" .. trim(pandoc.write(pandoc.Pandoc({ pandoc.Plain(b.content) }), "latex")) .. "}")
      else
        out[#out + 1] = b
      end
    end
  end
  doc.blocks = out
  return doc
end
