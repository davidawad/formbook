-- First Circuit brief, LaTeX engine (mirrors ../typst/ca1-opening-brief.typ). Pandoc filter: builds the
-- cover, the disclosure page, the table of contents and of authorities, the certificates and the
-- addendum from the YAML frontmatter, and turns headings and citation links (toa:KEY) into the macros
-- defined in template.tex. The body text itself is left to pandoc.
-- Per-folder setting: the word limit (FRAP 32(a)(7)(B)); the rest is the same in all three doc types.

local WORD_LIMIT = 13000          -- FRAP 32(a)(7)(B)
local ADDENDUM = "optional"       -- 1st Cir. R. 28.0(b)(1): not required in this brief
local TOC_DEPTH = 4               -- heading levels listed in the table of contents (typst toc-depth)
local ROMAN = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV" }
local TOA_GROUPS = {
  { "case", "Cases:" },
  { "constitution", "Constitutional Provisions:" },
  { "statute", "Statutes:" },
  { "regulation", "Regulations:" },
  { "rule", "Rules:" },
  { "other", "Other Authorities:" },
}

-- The inline rules of the cross-engine layout model (lib/latex/xengine.lua): break opportunities as typst has them,
-- ligature characters as commands, a section sign bound to its number. Run on the body and on every metadata value.
local xe_texify = require("latex.xengine").inlines

-- An ellipsis (U+2026) as one em-wide glyph whose PDF text is the character itself (template.tex \caoneellipsis):
-- pandoc would write \ldots, three periods narrower than the typst and Word glyph.
local ELLIPSIS = "\u{2026}"
local function ellipses(l)
  local out = pandoc.Inlines({})
  for _, el in ipairs(l) do
    if el.t == "Str" and el.text:find(ELLIPSIS, 1, true) then
      local rest = el.text
      while true do
        local s, e = rest:find(ELLIPSIS, 1, true)
        if not s then break end
        if s > 1 then out:insert(pandoc.Str(rest:sub(1, s - 1))) end
        out:insert(pandoc.RawInline("latex", "\\caoneellipsis{}"))
        rest = rest:sub(e + 1)
      end
      if rest ~= "" then out:insert(pandoc.Str(rest)) end
    else
      out:insert(el)
    end
  end
  return out
end
-- No line break before a closing or separating mark even after a space ("her case . . .," stays whole): Unicode line
-- breaking (UAX #14, rules LB13 and LB15d), which typst follows and TeX does not, has no break opportunity before
-- . , : ; ! ? ) ] } / (a period or comma before a digit excepted, LB15c). The space is tied (~), same width.
local function bind_closers(l)
  local out = pandoc.Inlines({})
  for i, el in ipairs(l) do
    local nx = l[i + 1]
    if el.t == "Space" and nx and nx.t == "Str" and nx.text:match("^[%.,:;!%?%)%]}/]")
        and not nx.text:match("^[%.,:;]%d") then
      out:insert(pandoc.RawInline("latex", "~"))
    else
      out:insert(el)
    end
  end
  return out
end
local function xe_inlines(l)
  return bind_closers(ellipses(xe_texify(l)))
end

local authorities = {}
local hits = {}
local counters = { 0, 0, 0, 0, 0 }   -- levels 2..5 of the body headings
local inarg = false                  -- inside the Argument (or the reply's Argument): roman point headings
local heads = {}                     -- the body headings, for the table of contents

local function raw(s)
  return pandoc.RawBlock("latex", s)
end

local function str(x)
  return pandoc.utils.stringify(x)
end

-- Inlines (or a plain string, or blocks) to LaTeX, trimmed, with the cross-engine inline rules.
local function tex(x)
  if x == nil then return "" end
  local doc
  if type(x) == "string" then
    doc = pandoc.Pandoc({ pandoc.Plain(xe_inlines(pandoc.Inlines({ pandoc.Str(x) }))) })
  elseif x.t == "MetaBlocks" then
    doc = pandoc.Pandoc(x):walk({ Inlines = xe_inlines })
  else
    doc = pandoc.Pandoc({ pandoc.Plain(xe_inlines(pandoc.Inlines(x))) })
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

-- The indent of a sub-heading's label in half inches (typst label-indent): one step per level below the first.
local function steps(level)
  local first = inarg and 3 or 2
  return level - first + 1
end

local function on_header_body(h)
  local title = tex(h.content)
  local id = "h" .. (#heads + 1)
  if h.level == 1 then
    local lp = str(h.content):lower()
    inarg = (lp == "argument" or lp == "reply argument")
    for i = 2, 5 do counters[i] = 0 end
    heads[#heads + 1] = { level = 1, steps = 0, label = "", title = title, id = id }
    return raw("\\caonesec{" .. title .. "}{" .. id .. "}")
  end
  if h.level > 5 then error("ca1: headings deeper than level 5 are not supported") end
  counters[h.level] = counters[h.level] + 1
  for i = h.level + 1, 5 do counters[i] = 0 end
  local lab = label(h.level, counters[h.level])
  if inarg and h.level == 2 then
    -- the centered point heading: its contents row starts at the margin
    heads[#heads + 1] = { level = 2, steps = 0, label = lab, title = title, id = id }
    return raw("\\caonepoint{" .. lab .. "}{" .. title .. "}{" .. id .. "}")
  end
  local s = steps(h.level)
  heads[#heads + 1] = { level = h.level, steps = s, label = lab, title = title, id = id }
  return raw("\\caonesub{" .. s .. "}{" .. lab .. "}{" .. title .. "}{" .. h.level .. "}{" .. id .. "}")
end

-- The addendum's own contents list: one row per sub-heading, its page read from a \label.
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

local function tocline(level, s, lab, title, id)
  return string.format("\\caonetocline{%d}{%d}{%s}{%s}{%s}", level, s, lab, title, id)
end

-- A citation writes its page before its first word (\toahit): a citation that begins a line is filed under that line.
local function on_link(l)
  if l.target:sub(1, 4) ~= "toa:" then return nil end
  local key = l.target:sub(5)
  if authorities[key] == nil then
    error("ca1: link `toa:" .. key .. "` has no entry under `authorities:` in the frontmatter")
  end
  hits[key] = true
  local out = pandoc.Inlines({ pandoc.RawInline("latex", "\\toahit{" .. key .. "}") })
  out:extend(l.content)
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
local function OrderedList(l)
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
      item[1] = pandoc.Para(c)
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

-- The cover (FRAP 32(a)(2)(A)-(F)) [cover-body]: single-spaced, centered; the designations and counsel start at the
-- middle of the page. The gaps stretch to fill the page and shrink when the page is full.
local function cover(meta)
  local o = {}
  local function p(s) o[#o + 1] = s end
  p("\\thispagestyle{empty}\\begingroup\\singlespacing\\centering\\parindent=0pt")
  p("\\cagap{}\\textbf{No. " .. tex(meta.case_number) .. "}\\par\\cagap{}")
  p("\\caonedoublerule\\cagap{}")
  p("\\textbf{\\MakeUppercase{United States Court of Appeals for the First Circuit}}\\par\\cagap{}")
  p("\\caoneshortrule\\cagap{}")
  local sides = meta.caption
  for i, side in ipairs(sides) do
    for _, name in ipairs(side.names) do p(tex(name) .. "\\par\\addvspace{4.9bp}") end
    p("{\\raggedright\\leftskip=0.5\\linewidth " .. tex(side.designation) .. "\\par}")
    if i < #sides then p("\\cahalfgap{}v.\\par\\cahalfgap{}") end
  end
  p("\\cagap{}\\caoneshortrule\\cagap{}")
  p(tex(meta.proceeding) .. "\\par")
  if meta.district_court_case or meta.judge then
    local dc = {}
    if meta.district_court_case then dc[#dc + 1] = "D.C. No. " .. tex(meta.district_court_case) end
    if meta.judge then dc[#dc + 1] = tex(meta.judge) end
    p("\\addvspace{4.9bp}" .. table.concat(dc, "; ") .. "\\par")
  end
  p("\\cagap{}\\caoneshortrule\\cagap{}")
  p("\\textbf{\\MakeUppercase{" .. tex(meta.brief_title) .. "}}\\par\\cagap{}")
  p("\\caoneshortrule\\cagap{}")
  -- counsel, from the middle of the page, left-aligned; address lines half an em in
  p("{\\raggedright\\leftskip=0.5\\linewidth")
  local groups = meta.counsel
  for gi, g in ipairs(groups) do
    if gi > 1 then p("\\addvspace{7bp}") end
    for _, n in ipairs(g.names) do p(tex(n) .. "\\par\\nobreak") end
    local lines = {}
    for _, l in ipairs(g.lines or {}) do lines[#lines + 1] = l end
    if gi == #groups then lines[#lines + 1] = meta.phone end
    for _, l in ipairs(lines) do
      p("\\hspace*{0.5em}\\emph{" .. tex(l) .. "}\\par\\nobreak")
    end
  end
  p("}")
  p("\\cagap{}\\caonedoublerule\\par\\endgroup")
  return table.concat(o, "\n")
end

-- Signature block [signature-block]: "Respectfully submitted," then 16.8 bp, the signature and the signer's lines in
-- the right half (the address lines 0.5 em in), then 11.2 bp and the date at the margin; kept with the last paragraph.
local function signature(meta)
  local sig = meta.signature
  local o = {}
  o[#o + 1] = "\\par\\nobreak\\addvspace{19.6bp}\\nobreak"
  o[#o + 1] = "\\begingroup\\singlespacing\\leftskip=0.5\\linewidth\\parindent=0pt"
  o[#o + 1] = "Respectfully submitted,\\par\\nobreak\\vspace{16.8bp}\\nobreak"
  o[#o + 1] = "/s/ " .. tex(sig.signer) .. "\\par\\nobreak"
  o[#o + 1] = "\\MakeUppercase{" .. tex(sig.signer) .. "}\\par\\nobreak"
  for _, l in ipairs(sig.lines or {}) do o[#o + 1] = "\\hspace*{0.5em}\\emph{" .. tex(l) .. "}\\par\\nobreak" end
  o[#o + 1] = "\\endgroup"
  if meta.date then
    o[#o + 1] = "\\nobreak\\vspace{11.2bp}\\nobreak\\begingroup\\singlespacing\\noindent " .. tex(meta.date) .. "\\par\\endgroup"
  end
  return table.concat(o, "\n")
end

-- Attorney line under a certificate [form-sig-line]: the right half, 22.4 bp below the text.
local function form_signature(meta)
  local sig = meta.signature
  local o = {}
  o[#o + 1] = "\\par\\addvspace{22.4bp}\\nobreak\\begingroup\\singlespacing\\leftskip=0.5\\linewidth\\parindent=0pt"
  o[#o + 1] = "/s/ " .. tex(sig.signer) .. "\\par\\nobreak"
  o[#o + 1] = "Attorney for " .. tex(sig["for"] or "") .. "\\par\\nobreak"
  if meta.date then o[#o + 1] = "Dated: " .. tex(meta.date) .. "\\par" end
  o[#o + 1] = "\\endgroup"
  return table.concat(o, "\n")
end

local function certificate_compliance(meta, words)
  local o = {}
  o[#o + 1] = "\\caonesec{Certificate of Compliance}{cc}"
  o[#o + 1] = "\\caonenumpar{1.}{This document complies with the type-volume limit of Fed. R. App. P. 32(a)(7)(B) because, excluding the parts of the document exempted by Fed. R. App. P. 32(f):}"
  o[#o + 1] = "\\caonecheckrow{this document contains " .. group_digits(words) .. " words.}"
  o[#o + 1] = "\\caonenumpar{2.}{This document complies with the typeface requirements of Fed. R. App. P. 32(a)(5) and the type-style requirements of Fed. R. App. P. 32(a)(6) because:}"
  o[#o + 1] = "\\caonecheckrow{this document has been prepared in a proportionally spaced typeface using "
    .. tex(meta.word_processor) .. " in 14-point " .. tex(meta.typeface) .. " roman type.}"
  o[#o + 1] = form_signature(meta)
  return table.concat(o, "\n")
end

local function certificate_service(meta)
  local o = {}
  o[#o + 1] = "\\caonesec{Certificate of Service}{cs}"
  o[#o + 1] = "\\begingroup\\singlespacing\\parindent=0pt\\parskip=0pt\\relax"
  o[#o + 1] = "I hereby certify that on " .. tex(meta.date or "__________") .. ", I electronically filed the foregoing with the Clerk of the Court for the United States Court of Appeals for the First Circuit by using the appellate CM/ECF system, which will send notification of such filing to all counsel of record.\\par"
  local unreg = meta.service.unregistered or {}
  if #unreg > 0 then
    o[#o + 1] = "\\addvspace{14bp}I further certify that on the same date I served the foregoing by mail on the following persons who are not registered for electronic filing:\\par"
    for _, u in ipairs(unreg) do
      o[#o + 1] = "\\addvspace{9.8bp}{\\leftskip=0.5in " .. tex(u.name) .. ", " .. tex(u.address) .. "\\par}"
    end
  end
  o[#o + 1] = "\\endgroup"
  o[#o + 1] = form_signature(meta)
  return table.concat(o, "\n")
end

-- Table of authorities [toa-section]: groups by kind, sorted, pages from the aux file.
local function toa(meta)
  local list = {}
  for key, a in pairs(authorities) do
    if hits[key] then list[#list + 1] = { key = key, a = a, sort = sort_key(a) } end
  end
  table.sort(list, function(x, y) return x.sort < y.sort end)
  local o = { "\\caonesec{Table of Authorities}{toa}" }
  local first = true
  for _, g in ipairs(TOA_GROUPS) do
    local kind, title = g[1], g[2]
    local printed_group = false
    for _, m in ipairs(list) do
      if str(m.a.kind) == kind then
        if not printed_group then
          o[#o + 1] = "\\toagroup{" .. title .. "}{" .. (first and 1 or 0) .. "}"
          first = false
          printed_group = true
        end
        local name = m.a.name and tex(m.a.name) or ""
        o[#o + 1] = string.format("\\toaitem{%s}{%s}{%d}{%s}", name, tex(m.a.cite), kind == "case" and 1 or 0, m.key)
      end
    end
  end
  return table.concat(o, "\n")
end

local function disclosure(meta)
  -- 14 bp between its paragraphs, none above the first (the heading's space applies)
  local text = tex(meta.disclosure):gsub("\n%s*\n", "\n\n\\addvspace{14bp}\n")
  return "\\caonesec{Disclosure Statement}{ds}\n\\begingroup\\singlespacing\\parindent=0pt\\relax\n"
    .. text .. "\\par\n\\endgroup"
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
  body = pandoc.Blocks(body):walk({ Link = on_link, OrderedList = OrderedList })
  body = body:walk({ Inlines = xe_inlines })
  body = body:walk({ Header = on_header_body })
  add = pandoc.Blocks(add):walk({ Link = on_link, OrderedList = OrderedList })
  add = add:walk({ Inlines = xe_inlines })
  add = add:walk({ Header = on_header_add })

  -- The signature never stands alone: the brief's last block (a paragraph, a tight list, a quotation) is not broken across pages and stays with the
  -- signature block (typst: one unbreakable block).
  local n = #body
  if n > 0 and (body[n].t == "Para" or body[n].t == "BulletList" or body[n].t == "OrderedList" or body[n].t == "BlockQuote") then
    body:insert(n, raw("\\begingroup\\caonekeep"))
    body:insert(raw("\\par\\endgroup"))
  end

  local out = {}
  local function push(b) out[#out + 1] = b end
  push(raw("\\singlespacing"))
  push(raw(cover(meta)))
  push(raw("\\clearpage\\pagenumbering{roman}"))
  if meta.disclosure then
    push(raw(disclosure(meta)))
    push(raw("\\clearpage"))
  end
  -- table of contents [toc-section]: the table of authorities, every heading up to the toc depth, the certificates,
  -- the addendum
  local toc = { "\\caonesec{Table of Contents}{toc}", "\\caonetocpage", tocline(1, 0, "", "Table of Authorities", "toa") }
  for _, h in ipairs(heads) do
    if h.level <= TOC_DEPTH then toc[#toc + 1] = tocline(h.level, h.steps, h.label, h.title, h.id) end
  end
  toc[#toc + 1] = tocline(1, 0, "", "Certificate of Compliance", "cc")
  local with_service = meta.service and meta.service.certificate
  if with_service then toc[#toc + 1] = tocline(1, 0, "", "Certificate of Service", "cs") end
  if had_add then toc[#toc + 1] = tocline(1, 0, "", "Addendum", "add") end
  push(raw(table.concat(toc, "\n")))
  push(raw("\\clearpage"))
  push(raw(toa(meta)))
  push(raw("\\clearpage\\pagenumbering{arabic}\\normalsize"))
  for _, b in ipairs(body) do push(b) end
  push(raw(signature(meta)))
  push(raw("\\clearpage\\singlespacing"))
  push(raw(certificate_compliance(meta, words)))
  if with_service then
    push(raw("\\clearpage"))
    push(raw(certificate_service(meta)))
  end
  if had_add then
    push(raw("\\clearpage\\renewcommand\\thepage{Add-\\arabic{page}}\\setcounter{page}{1}"))
    push(raw("\\caonesec{Addendum}{add}"))
    push(raw("\\caonesec{Table of Contents}{addtoc}"))
    local rows = {}
    for _, e in ipairs(addlist) do rows[#rows + 1] = tocline(2, 0, "", e.title, e.lbl) end
    push(raw(table.concat(rows, "\n")))
    push(raw("\\clearpage\\normalsize"))
    for _, b in ipairs(add) do push(b) end
  end

  doc.blocks = out
  return doc
end
