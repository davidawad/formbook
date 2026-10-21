-- First Circuit brief, LaTeX engine (mirrors ../typst/ca1-opening-brief.typ). Pandoc filter: builds the
-- cover, the disclosure page, the table of contents and of authorities, the certificates and the
-- addendum from the YAML frontmatter, and turns headings and citation links (toa:KEY) into the macros
-- defined in template.tex. The body text itself is left to pandoc.
-- Per-folder setting: the word limit (FRAP 32(a)(7)(B)); the rest is the same in all three doc types.

local WORD_LIMIT = 13000          -- FRAP 32(a)(7)(B)(i) principal brief (reply: 6500)
local ADDENDUM = "required"       -- 1st Cir. R. 28.0(a)(1) for the appellant's brief; "optional" in the others
local PASSIM = 7                  -- authority cited on this many pages or more: "passim"
local ROMAN = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV" }
local TOA_GROUPS = {
  { "case", "Cases:" },
  { "constitution", "Constitutional Provisions:" },
  { "statute", "Statutes:" },
  { "regulation", "Regulations:" },
  { "rule", "Rules:" },
  { "other", "Other Authorities:" },
}

local authorities = {}
local hits = {}
local counters = { 0, 0, 0, 0, 0 }   -- levels 2..5 of the body headings
local inarg = false                  -- inside the Argument (or the reply's Argument): roman point headings
local inadd = false                  -- inside the addendum

local function raw(s)
  return pandoc.RawBlock("latex", s)
end

local function str(x)
  return pandoc.utils.stringify(x)
end

-- Inlines (or a plain string, or blocks) to LaTeX, trimmed.
local function tex(x)
  if x == nil then return "" end
  local doc
  if type(x) == "string" then
    doc = pandoc.Pandoc({ pandoc.Plain({ pandoc.Str(x) }) })
  elseif x.t == "MetaBlocks" then
    doc = pandoc.Pandoc(x)
  else
    doc = pandoc.Pandoc({ pandoc.Plain(x) })
  end
  local s = pandoc.write(doc, "latex")
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

-- 11622 -> "11,622"
local function group_digits(n)
  local s = tostring(n)
  local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (out:gsub("^,", ""))
end

local function label(level, n)
  if inarg then
    if level == 2 then return ROMAN[n] .. "." end
    if level == 3 then return string.char(64 + n) .. "." end
    if level == 4 then return n .. "." end
    if level == 5 then return string.char(96 + n) .. "." end
  else
    if level == 2 then return string.char(64 + n) .. "." end
    if level == 3 then return n .. "." end
    if level == 4 then return string.char(96 + n) .. "." end
    if level == 5 then return "(" .. n .. ")" end
  end
  error("ca1: no label for heading level " .. level)
end

-- Left edge of a sub-heading's label (typst label-indent): half an inch per level below the first.
local function indent(level)
  local first = inarg and 3 or 2
  return ((level - first + 1) * 0.5) .. "in"
end

local function on_header_body(h)
  local title = tex(h.content)
  if h.level == 1 then
    local lp = str(h.content):lower()
    inarg = (lp == "argument" or lp == "reply argument")
    for i = 2, 5 do counters[i] = 0 end
    return raw("\\caonesec{" .. title .. "}")
  end
  if h.level > 5 then error("ca1: headings deeper than level 5 are not supported") end
  counters[h.level] = counters[h.level] + 1
  for i = h.level + 1, 5 do counters[i] = 0 end
  local lab = label(h.level, counters[h.level])
  if inarg and h.level == 2 then
    return raw("\\caonepoint{" .. lab .. "}{" .. title .. "}")
  end
  return raw("\\caonesub{" .. indent(h.level) .. "}{" .. lab .. "}{" .. title .. "}{" .. h.level .. "}")
end

-- The addendum's own contents list: one line per sub-heading, its page read from a \label (see template.tex).
local addlist = {}
local function on_header_add(h)
  if h.level == 2 then
    local title = tex(h.content)
    local lbl = "addsub" .. (#addlist + 1)
    addlist[#addlist + 1] = { title = title, lbl = lbl }
    return raw("\\caoneaddsub{" .. title .. "}{" .. lbl .. "}")
  end
  error("ca1: the addendum may only use level-2 headings")
end

local function addendum_toc()
  local o = {}
  for _, e in ipairs(addlist) do
    o[#o + 1] = "\\caoneaddtocline{" .. e.title .. "}{" .. e.lbl .. "}"
  end
  return table.concat(o, "\n")
end

local function on_link(l)
  if l.target:sub(1, 4) ~= "toa:" then return nil end
  local key = l.target:sub(5)
  if authorities[key] == nil then
    error("ca1: link `toa:" .. key .. "` has no entry under `authorities:` in the frontmatter")
  end
  hits[key] = true
  local out = { pandoc.RawInline("latex", "\\toahit{" .. key .. "}{") }
  for _, i in ipairs(l.content) do out[#out + 1] = i end
  out[#out + 1] = pandoc.RawInline("latex", "}")
  return out
end

-- Words in a block, footnotes included (pandoc's stringify leaves notes out). Unicode spaces (no-break,
-- thin) separate words as they do in typst's \s. A roman or letter list label ("II.") is a word of text
-- (typst reads it as text; only decimal markers are stripped).
local block_words
local function block_words_of(b)
  local text = {}
  -- a note becomes a space, so the words either side of it stay apart
  local plain = pandoc.Blocks({ b }):walk({ Note = function(nt)
    text[#text + 1] = str(nt.content)
    return pandoc.Space()
  end })
  table.insert(text, 1, str(plain))
  local n = 0
  for _, s in ipairs(text) do
    s = s:gsub("\194\160", " "):gsub("\226\128\137", " "):gsub("\226\128\175", " ")
    for _ in s:gmatch("%S+") do n = n + 1 end
  end
  return n
end

-- Lists and quotations are counted item by item (stringify would run the items together).
block_words = function(b)
  if b.t == "BulletList" or b.t == "OrderedList" then
    local n = 0
    if b.t == "OrderedList" and b.listAttributes.style ~= "Decimal" then n = #b.content end   -- "II." is text
    for _, item in ipairs(b.content) do
      for _, c in ipairs(item) do n = n + block_words(c) end
    end
    return n
  elseif b.t == "BlockQuote" then
    local n = 0
    for _, c in ipairs(b.content) do n = n + block_words(c) end
    return n
  end
  return block_words_of(b)
end

-- Word count of the body as a word processor counts it: the oral-argument statement is excluded
-- (FRAP 32(f)); headings, footnotes and quotations count.
local function count_words(blocks)
  local n = 0
  local skipping = false
  for _, b in ipairs(blocks) do
    if b.t == "Header" and b.level == 1 then
      skipping = str(b.content):lower():find("oral argument", 1, true) ~= nil
    end
    if not skipping then n = n + block_words(b) end
  end
  return n
end

-- Roman and letter lists are paragraphs, not lists: "II. Whether ..." is text (CommonMark, as typst reads it).
local ROMAN_VALUES = { { 1000, "M" }, { 900, "CM" }, { 500, "D" }, { 400, "CD" }, { 100, "C" }, { 90, "XC" },
  { 50, "L" }, { 40, "XL" }, { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
local function roman_upper(n)
  local out = ""
  for _, v in ipairs(ROMAN_VALUES) do
    while n >= v[1] do out = out .. v[2]; n = n - v[1] end
  end
  return out
end
function OrderedList(l)
  local style = l.listAttributes.style
  if style == "Decimal" then return nil end
  local blocks = {}
  for i, item in ipairs(l.content) do
    local n = l.listAttributes.start + i - 1
    local lab
    if style == "LowerRoman" then lab = roman_upper(n):lower()
    elseif style == "UpperRoman" then lab = roman_upper(n)
    elseif style == "LowerAlpha" then lab = string.char(96 + n)
    else lab = string.char(64 + n) end
    lab = lab .. "."
    local first = item[1]
    if first and (first.t == "Para" or first.t == "Plain") then
      local c = { pandoc.Str(lab), pandoc.Space() }
      for _, x in ipairs(first.content) do c[#c + 1] = x end
      first.content = c
    end
    for _, b in ipairs(item) do blocks[#blocks + 1] = b end
  end
  return blocks
end

local function sort_key(a)
  local s
  if a.sort then s = str(a.sort)
  else s = (a.name and str(a.name) or "") .. " " .. str(a.cite) end
  return (s:lower():gsub("[^a-z0-9 ]", ""))
end

-- The cover (FRAP 32(a)(2)(A)-(F)).
local function cover(meta)
  local o = {}
  local function p(s) o[#o + 1] = s end
  p("\\thispagestyle{empty}\\begingroup\\caonesingle")
  p("\\begin{center}")
  p("\\vspace*{0em}")
  p("\\textbf{No. " .. tex(meta.case_number) .. "}\\par\\vspace{0.45em}")
  p("\\caonedoublerule\\vspace{0.45em}")
  p("\\textbf{\\MakeUppercase{United States Court of Appeals for the First Circuit}}\\par\\vspace{0.45em}")
  p("\\caoneshortrule\\vspace{0.45em}")
  local sides = meta.caption
  for i, side in ipairs(sides) do
    for _, name in ipairs(side.names) do p(tex(name) .. "\\par") end
    p("\\begin{flushleft}\\hspace*{0.5\\textwidth}" .. tex(side.designation) .. "\\end{flushleft}\\par")
    if i < #sides then p("\\vspace{0.4em}v.\\vspace{0.4em}\\par") end
  end
  p("\\vspace{0.45em}\\caoneshortrule\\vspace{0.45em}")
  p(tex(meta.proceeding) .. "\\par")
  if meta.district_court_case or meta.judge then
    local dc = {}
    if meta.district_court_case then dc[#dc + 1] = "D.C. No. " .. tex(meta.district_court_case) end
    if meta.judge then dc[#dc + 1] = tex(meta.judge) end
    p(table.concat(dc, "; ") .. "\\par")
  end
  p("\\vspace{0.45em}\\caoneshortrule\\vspace{0.45em}")
  p("\\textbf{\\MakeUppercase{" .. tex(meta.brief_title) .. "}}\\par\\vspace{0.45em}")
  p("\\caoneshortrule\\vspace{0.45em}")
  p("\\end{center}")
  -- counsel, at the middle of the page, left-aligned
  p("\\begin{flushleft}\\hspace*{0.5\\textwidth}\\begin{minipage}[t]{0.5\\textwidth}\\raggedright")
  local groups = meta.counsel
  for gi, g in ipairs(groups) do
    for _, n in ipairs(g.names) do p(tex(n) .. "\\\\") end
    local lines = {}
    for _, l in ipairs(g.lines or {}) do lines[#lines + 1] = l end
    if gi == #groups then lines[#lines + 1] = meta.phone end
    for _, l in ipairs(lines) do
      p("\\hspace*{0.5em}\\emph{" .. tex(l) .. "}\\\\")
    end
    if gi < #groups then p("\\vspace{0.2em}") end
  end
  p("\\end{minipage}\\end{flushleft}")
  p("\\vspace{0.45em}\\caonedoublerule\\endgroup")
  return table.concat(o, "\n")
end

-- Signature block (typst signature-block): left half of the page; date at the margin. One minipage, so the
-- date never parts from the signature at a page break.
local function signature(meta)
  local sig = meta.signature
  local o = {}
  o[#o + 1] = "\\vspace{1.4em}\\par\\noindent\\begin{minipage}{\\textwidth}\\caonesingle"
  o[#o + 1] = "\\begin{flushleft}\\hspace*{0.5\\textwidth}\\begin{minipage}[t]{0.5\\textwidth}\\raggedright"
  o[#o + 1] = "Respectfully submitted,\\\\[1.2em]"
  o[#o + 1] = "/s/ " .. tex(sig.signer) .. "\\\\"
  o[#o + 1] = "\\MakeUppercase{" .. tex(sig.signer) .. "}"
  for _, l in ipairs(sig.lines or {}) do o[#o + 1] = "\\\\\\hspace*{0.5em}\\emph{" .. tex(l) .. "}" end
  o[#o + 1] = "\\end{minipage}\\end{flushleft}"
  if meta.date then o[#o + 1] = "\\vspace{0.45em}" .. tex(meta.date) end
  o[#o + 1] = "\\end{minipage}\\par"
  return table.concat(o, "\n")
end

-- Attorney line under a certificate (typst form-sig-line).
local function form_signature(meta)
  local sig = meta.signature
  local o = {}
  o[#o + 1] = "\\par\\vspace{1.6em}\\begingroup\\caonesingle\\noindent\\hspace*{0.5\\textwidth}\\begin{minipage}[t]{0.5\\textwidth}\\raggedright"
  o[#o + 1] = "/s/ " .. tex(sig.signer) .. "\\\\"
  o[#o + 1] = "Attorney for " .. tex(sig["for"] or "") .. (meta.date and "\\\\Dated: " .. tex(meta.date) or "")
  o[#o + 1] = "\\end{minipage}\\par\\endgroup"
  return table.concat(o, "\n")
end

local function certificate_compliance(meta, words)
  local o = {}
  o[#o + 1] = "\\caonesec{Certificate of Compliance}"
  o[#o + 1] = "\\begingroup\\caonesingle\\setlength{\\parindent}{0pt}\\setlength{\\parskip}{1em}"
  o[#o + 1] = "\\hangindent=0.3in\\hangafter=1 1. This document complies with the type-volume limit of Fed. R. App. P. 32(a)(7)(B) because, excluding the parts of the document exempted by Fed. R. App. P. 32(f):\\par"
  o[#o + 1] = "\\noindent\\hspace*{1.6em}\\caonecheckbox{1}\\hspace{0.6em}this document contains " .. group_digits(words) .. " words.\\par"
  o[#o + 1] = "\\hangindent=0.3in\\hangafter=1 2. This document complies with the typeface requirements of Fed. R. App. P. 32(a)(5) and the type-style requirements of Fed. R. App. P. 32(a)(6) because:\\par"
  o[#o + 1] = "\\noindent\\hspace*{1.6em}\\caonecheckbox{1}\\hspace{0.6em}this document has been prepared in a proportionally spaced typeface using "
    .. tex(meta.word_processor) .. " in 14-point " .. tex(meta.typeface) .. " roman type.\\par"
  o[#o + 1] = "\\endgroup"
  o[#o + 1] = form_signature(meta)
  return table.concat(o, "\n")
end

local function certificate_service(meta)
  local o = {}
  o[#o + 1] = "\\caonesec{Certificate of Service}"
  o[#o + 1] = "\\begingroup\\caonesingle\\setlength{\\parindent}{0pt}\\setlength{\\parskip}{1em}"
  o[#o + 1] = "I hereby certify that on " .. tex(meta.date or "__________") .. ", I electronically filed the foregoing with the Clerk of the Court for the United States Court of Appeals for the First Circuit by using the appellate CM/ECF system, which will send notification of such filing to all counsel of record.\\par"
  local unreg = meta.service.unregistered or {}
  if #unreg > 0 then
    o[#o + 1] = "I further certify that on the same date I served the foregoing by mail on the following persons who are not registered for electronic filing:\\par"
    for _, u in ipairs(unreg) do
      o[#o + 1] = "\\noindent\\hspace*{0.5in}" .. tex(u.name) .. ", " .. tex(u.address) .. "\\par"
    end
  end
  o[#o + 1] = "\\endgroup"
  o[#o + 1] = form_signature(meta)
  return table.concat(o, "\n")
end

-- Table of authorities (typst toa-section): groups by kind, sorted, pages from the aux file.
local function toa(meta)
  local list = {}
  for key, a in pairs(authorities) do
    if hits[key] then list[#list + 1] = { key = key, a = a, sort = sort_key(a) } end
  end
  table.sort(list, function(x, y) return x.sort < y.sort end)
  local o = { "\\caonesec{Table of Authorities}" }
  local first = true
  for _, g in ipairs(TOA_GROUPS) do
    local kind, title = g[1], g[2]
    local printed_group = false
    for _, m in ipairs(list) do
      if str(m.a.kind) == kind then
        if not printed_group then
          if first then o[#o + 1] = "\\caonetoaheadpages{" .. title .. "}"
          else o[#o + 1] = "\\caonetoahead{" .. title .. "}" end
          first = false
          printed_group = true
        end
        local cite = tex(m.a.cite)
        local display = cite
        if m.a.name then
          local name = tex(m.a.name)
          if kind == "case" then name = "\\emph{" .. name .. "}" end
          display = name .. ",\\\\" .. cite
        end
        o[#o + 1] = "\\caonetoaentry{" .. display .. "}{" .. m.key .. "}"
      end
    end
  end
  return table.concat(o, "\n")
end

local function disclosure(meta)
  return "\\caonesecnotoc{Disclosure Statement}\n\\begingroup\\caonesingle\\setlength{\\parindent}{0pt}\\setlength{\\parskip}{1em}\n"
    .. tex(meta.disclosure) .. "\n\\endgroup"
end

function Pandoc(doc)
  local meta = doc.meta
  authorities = meta.authorities or {}
  -- ---- split off the addendum at its "# Addendum" heading ----
  local body, add = {}, nil
  for _, b in ipairs(doc.blocks) do
    if add == nil and b.t == "Header" and b.level == 1 and str(b.content):lower():match("^%s*addendum%s*$") then
      add = {}
    elseif add then
      add[#add + 1] = b
    else
      body[#body + 1] = b
    end
  end
  local had_add = add ~= nil
  if not had_add then
    if ADDENDUM == "required" then
      error("ca1: 1st Cir. R. 28.0(a)(1) requires an addendum with the order or decision appealed from; add a `# Addendum` section")
    end
    add = {}
  end

  -- ---- body: word limit (counted on the markdown, before headings become macros), headings, citations ----
  local words = count_words(body)
  if words > WORD_LIMIT then
    error("ca1: the brief has " .. words .. " words; FRAP 32(a)(7)(B) allows " .. WORD_LIMIT)
  end
  inarg = false
  inadd = false
  body = pandoc.Blocks(body):walk({ Header = on_header_body, Link = on_link, OrderedList = OrderedList })
  inadd = true
  add = pandoc.Blocks(add):walk({ Header = on_header_add, Link = on_link, OrderedList = OrderedList })
  inadd = false

  local out = {}
  local function push(b) out[#out + 1] = b end
  push(raw(cover(meta)))
  push(raw("\\clearpage\\pagenumbering{roman}"))
  if meta.disclosure then
    push(raw(disclosure(meta)))
    push(raw("\\clearpage"))
  end
  push(raw("\\caonesecnotoc{Table of Contents}\\hfill\\textbf{\\underline{Page}}\\par\\nobreak"))
  push(raw("\\caonetocprint"))
  push(raw("\\clearpage"))
  push(raw(toa(meta)))
  push(raw("\\clearpage\\pagenumbering{arabic}"))
  for _, b in ipairs(body) do push(b) end
  push(raw(signature(meta)))
  push(raw("\\clearpage"))
  push(raw(certificate_compliance(meta, words)))
  if meta.service and meta.service.certificate then
    push(raw("\\clearpage"))
    push(raw(certificate_service(meta)))
  end
  if had_add then
    push(raw("\\clearpage\\renewcommand\\thepage{Add-\\arabic{page}}\\setcounter{page}{1}"))
    push(raw("\\caonesec{Addendum}"))
    push(raw("\\caonesecnotoc{Table of Contents}"))
    push(raw(addendum_toc()))
    push(raw("\\clearpage"))
    for _, b in ipairs(add) do push(b) end
  end

  doc.blocks = out
  return doc
end
